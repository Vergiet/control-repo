class temp::folder (
  
) {

  require base::server

    file {'tempdir':
      ensure => directory,
      path => 'c:\\temp\\',
    }
}
