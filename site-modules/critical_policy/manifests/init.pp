class critical_policy {

  registry::value { 'Legal notice caption':
    key   => 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System',
    value => 'legalnoticecaption',
    data  => 'Legal Notice',
    }

  registry::value { 'Legal notice text':
    key   => 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System',
    value => 'legalnoticetext',
    data  => 'Login constitutes acceptance of the End User Agreement',
    }
  }
