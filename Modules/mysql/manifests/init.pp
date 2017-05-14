class mysql {
	package{'mysql-server':
		ensure => "installed",
	}
	service {"mysql":
		ensure => "running",
		enable => "true",
		require => Package["mysql-server"],
	}
	exec {"mysqlpasswd":
		command => "/usr/bin/mysqladmin -u root password Changedpassword1",
		notify => [Service["mysql"]],
		require => [Package["mysql-server"]],
	}
}
