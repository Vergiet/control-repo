class role::ad {
  class { 'active_directory::domain_controller':
    domain_name               => 'contoso.local',
    domain_credential_user    => 'Administrator',
    domain_credential_passwd  => 'Beheer123',
    safe_mode_passwd          => 'Beheer123',
  }
}

