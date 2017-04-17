class apache2{
        package { 'apache2':
                ensure => "installed",
        }
        file { '/var/www/html/index.html':
                content => "vaihda muuta hauskaa tilalle kuin it works",
        }
        service { 'apache2':
                ensure => 'running',
                require => [
                Package['apache2'],
                File['/var/www/html/index.html'],
                ]
        }
}


