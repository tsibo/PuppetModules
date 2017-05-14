class php {
	package{'apache2':
		ensure => "installed",
	}
	package {'php7.0':
		ensure => "installed",	
	}
	package {'libapache2-mod-php7.0':
                ensure => "installed",
	}
	service {'apache2':
		ensure => "running",
		enable => "true",
		require => Package["apache2"],
		
	}
	file {'/etc/apache2/mods-available/php7.0.conf':
		content => template("php/php7.0.conf"),
		notify => Service["apache2"],
	}
	   file {'/home/kaapo/public_html/test.php':
                ensure => "file",
                content => "<?php print(1+1); ?>",
        	notify => Service["apache2"],
		require => Package["apache2"],
		owner => "kaapo",
		group => "kaapo",
		mode => 644,
	}

}

