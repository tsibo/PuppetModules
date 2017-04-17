class ssh{
	package {"ssh":
		ensure => "installed",
	}

	service {"sshd":
		ensure => "running",
		enable => "true",
		require => Package["ssh"],
	}
	file {"/etc/ssh/sshd_config":
		content => template('ssh/sshd_config.erb'),
		require => Package["ssh"],
		notify => Service ["sshd"],
	}
}
