mount { "D:":
  ensure   => mounted,
  provider => windows_smb,
  device   => "//VAGRANT-2012-R2/shared",
  # JSON as a string since the type officially says so
  options  => '{"user":"VAGRANT-2012-R2/test","password":"Password123!"}',
}
