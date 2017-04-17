class ssh{
	package {"ssh":
		ensure => "installed",
	}

	service {"sshd":
		ensure => "running",
		enable => "true",
		require => Package["ssh"],
	}
}
