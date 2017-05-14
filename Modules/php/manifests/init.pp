class php {
	package{'apache2':
		ensure => "installed",
	}
	package {'php7.0':
		ensure => "installed",	
	}
	package {'libapache2-mod-php7.0':
                ensure => "installed",
		notify => Service["apache2"],
	}
	file {'/var/www/html/test.php':
		ensure => "file",
		content => "<?php print(<p>'Moro korso!'</p>); ?>",
	}
	service{'apache2':
		notify => Service['apache2'],		
	}
}

