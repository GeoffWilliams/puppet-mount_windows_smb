Puppet::Type.type(:mount).provide(:windows_smb, :parent => Puppet::Provider) do
  desc "Enable mapping windows shares to drive letters using Puppet"

  # We can claim the default spot on windows because nothing else
  # presently exists.  This also fixes the default value for
  # whether to write /etc/fstab or not
  defaultfor :osfamily => :windows

  # name - the drive, must be captial! eg `D:`
  # device - the share
  # options - hash of JSON with username and password

  mk_resource_methods

  # god only knows...
  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def mounted?
    [:mounted, :ghost].include?(get(:ensure))
  end

  def property_hash
    {}
  end

  def property_hash=(props)
  end

  def create
    opts_json   = JSON.parse(resource[:options]||{})

    unc_path = to_unc(resource[:device])
    cmd = ["net", "use", resource[:name], unc_path]
    if opts_json.has_key?('user')
      cmd << "/user:#{to_unc(opts_json['user'])}"
      if opts_json.has_key?('password')
        cmd << "#{opts_json['password']}"
      end
    end

    output = execute(cmd)
  end

  def unmount
    execute(["net", "use", resource[:name], "/delete", "/yes"])
  end

  # type calls unmount, then destroy - since we already unmounted
  # we don't need to do anything but the method must still exist
  def destroy
  end


  def remount
    unmount
    create
  end


  def self.instances

    # build a structured list of:
    # * drive letter
    # * UNC path
    # * status
    # There isn't a nice way to do this and parsing the output
    # of `net use` on its own will not work reliably because
    # random user-inserted spaces will make it impossible to
    # determine network type vs UNC name.  Instead we must ask
    # powershell for the formatted list of drive letters and
    # UNC paths, then iterate each one with `net use DRIVELETER`
    # - open to PRs making this less ugly...
    ps = 'Get-WmiObject Win32_MappedLogicalDisk | Select Name, ProviderName | ConvertTo-JSON'

    # powershell returns array of hash if more then one mount,
    # otherwise just a hash - homogify the output
    output = execute(['powershell', ps]).to_s
    mounts = output.empty? ? {} : JSON.parse(output)
    if !mounts.empty? and mounts.is_a?(Hash)
      mounts = [mounts]
    end

    mounts.each { |mount|
      status = execute(['net', 'use', mount['Name']]).to_s.split("\n").reject { |line|
        ! line.start_with?("Status")
      }.map { |line|
        line.split.last.strip
      }.join

      mount["Status"] = status
    }

    mounts.map { |mount|
      {
        :ensure   => (mount["Status"] == 'OK') ? :mounted : :absent,
        :name     => mount["Name"],
        :device   => from_unc(mount["ProviderName"]),
        :provider => :windows_smb,
        :dump     => nil,
        :pass     => nil,
        :options  => nil,
      }
    }.collect { |h|
      new(h)
    }
  end

  def to_unc(path)
    path.gsub('/','\\')
  end

  def self.from_unc(path)
    path.gsub('\\','/')
  end

  def dump
    resource[:dump]
  end

  def pass
    resource[:pass]
  end

  def options
    resource[:options]
  end

end
