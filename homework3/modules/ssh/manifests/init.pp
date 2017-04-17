class ssh{
	package {"ssh":
		ensure => "installed",
	}

	sercvice {"sshd":
		ensure => "running",
		enable => "true",
		require => Package["ssh"],
	}
}
