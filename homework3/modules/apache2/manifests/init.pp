class apache2 {
        package {'apache2':
                ensure => "installed",
        }
	service {'apache2':
		ensure => 'running',
		enable => 'true',
		require => Package['apache2'],
	}
	file {'/home/kaapo/public_html':
		ensure => 'directory',
		owner => 'kaapo',
		group => 'kaapo',
	}
	file {'/home/kaapo/public_html/index.html':
		ensure => 'file',
		content => "Morjensta vaa täältä korsosta",
		owner => 'kaapo',
		group => 'kaapo',
	}
	file {'/etc/apache2/sites-available/kaapo.conf':
		content => template('apache2/kaapo.conf.erb'),
		require => Package ['apache2'],
		owner => 'root',
		group => 'root',
	}
	file {'/etc/apache2/sites-enabled/kaapo.conf':
		ensure => 'link',
		target => '/etc/apache2/sites-available/kaapo.conf',
		notify => Service['apache2'],
		require => Package['apache2'],
	}
	file {'/etc/apache2/sites-enabled/000-default.config':
		ensure => 'absent',
		notify => Service['apache2'],
		require => Package['apache2'],
	}
}
