class temp::folder (
  
) {

    file {'tempdir':
      ensure => directory,
      path => 'c:\\temp\\',
    }
}
