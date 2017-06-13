[![Build Status](https://travis-ci.org/GeoffWilliams/puppet-mount_windows_smb.svg?branch=master)](https://travis-ci.org/GeoffWilliams/puppet-mount_windows_smb)
# mount_windows_smb

#### Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Add a `mount` provider `windows_smb` to enable mapping windows shares to drive letters using Puppet

## Usage

### Mapping a drive

```puppet
mount { "D:":
  ensure   => mounted,
  provider => windows_smb,
  device   => "//VAGRANT-2012-R2/shared",
  options  => '{"user":"VAGRANT-2012-R2/test","password":"Password123!"}',
}
```

## Notes
* You *must* specify the drive letter as the resource name, in capitals, with a colon
* To avoid a sea of backslashes, use a forward slash in any share names and user names.  The provider will convert them for you
* options semi-officially has to be a string acording to the type documentation... but no one said I couldn't load the string with JSON ;-)
* Omit password if there isn't one
* Other options such as `dump`, `pass` etc are ignored
* We claim the default `mount` provider on windows

### Un-mapping a drive

```puppet
mount { "D:":
  ensure   => absent,
  provider => windows_smb,
}
```


## Reference
[generated documentation](https://rawgit.com/GeoffWilliams/puppet-mount_windows_smb/master/doc/index.html).

Reference documentation is generated directly from source code using [puppet-strings](https://github.com/puppetlabs/puppet-strings).  You may regenerate the documentation by running:

```shell
bundle exec puppet strings
```

## Limitations
* Not supported by Puppet, Inc.

## Development

PRs accepted :)

## Testing
This module supports testing using [PDQTest](https://github.com/declarativesystems/pdqtest).


Test can be executed with:

```
bundle install
make
```

See `.travis.yml` for a working CI example


## Acknowledgement
* Thanks to Paul Tötterman and Rob Reynolds - I was able to construct a working provider from the notes left on [MODULES-4927](https://tickets.puppetlabs.com/browse/MODULES-4927)
