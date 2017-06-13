mount { "D:":
  ensure   => absent,
  provider => windows_smb,
}
