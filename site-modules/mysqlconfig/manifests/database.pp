class mysqlconfig::database {

  include mysql::server

  service { 'mysql-service':
    name => 'mariadb',
    ensure     => running,
    enable     => true,
  }

  create_resources('mysql::db', hiera_hash('databases'))
}
