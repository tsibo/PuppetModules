# Kotitehtävä 3 Linuxin hallinta kurssilla

a) konfiguroi SSH uuteen porttiin puppetilla

b)laita tekemäsi moduulit gittiin, jotta ne saa koulussa helposti live-usb työpöydälle

c)Vaihda Apachen oletusweppisivu( default website) Puppetilla


## Oma setuppi
Tehty Oracle VM Virtualboxia käyttäen Xubuntu 16.04.1 64bit versiolla
CPU Intel(R) Core(TM) i5-2500K CPU 3.30GHz 


## Miten toimin:
Tein ensin ssh moduulin jonka avulla sain vaihdettua ssh portin 22 sta 2222 ksi

Moduuli näytti tältä


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
 

 
ssh modulen ajamisen jälkeen:

Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.47 seconds
Notice: /Stage[main]/Ssh/File[/etc/ssh/sshd_config]/content: content changed '{md5}bd3a2b95f8b4b180eed707794ad81e4d' to '{md5}1b50a03f847fd86f9e350c0fd54d7c62'
Notice: /Stage[main]/Ssh/Service[sshd]: Triggered 'refresh' from 1 events
Notice: Finished catalog run in 0.12 seconds

Ja portti oli sijainnissa /etc/ssh/sshd_config muuttunut 22 sta 2222 ksi

Seuraavaksi minun piti tehdä toinen moduuli, jonka piti muuttaa apachen default webpagea

Tein tätä varten jälleen modulesin alle apache2 kansion ja sinne
omat kansiot sekä manifests että templates, jotta modulen saisi toimimaan.
kopioin templates kansioon tiedoston kaapo.confm jonka olin luonut
sijaintiin /etc/apache2/sites-available/ . itse templaten nimesin kaapo.conf.erb ksi.
Tein moduulin osin käyttäen vanhempaa kotitehtävää ja osin käyttäen muutaman muun kurssilaisen omia ohjeita.
Lopputulos näytti tältä:

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

Ajoin moduulin komennolla
`sudo puppet apply --modulepath ~/PuppetModules/homework3/modules -e 'class {'apache2':}'`
ja kaikki tuntui toimivan hyvin.
Huomasin kuitenkin, että aikasemmat muunnelmani apacheen olivat tehneet jotain häikkää tilanteelle, sillä vaikka Apache asentuikin otimivasti en
saanut default webpagea vaihdettua vaan siihen jäi aikaisemmin määrittelemäni aloitussivu vaikka olin purgennut asennuksen ennen moduulin ajoa. Pohdin asiaa hetkenm, mutta sitten tulivat väliin muut kiireet ja jätin moduulin vain puoliksi toimivaksi

## References
[opettajan ohjeet apachen kotisivun muuttamiseksi ilman moduulia](http://terokarvinen.com/2016/new-default-website-with-apache2-show-your-homepage-at-top-of-example-com-no-tilde)
[neuvoja templateihin](https://docs.puppet.com/puppet/4.9/lang_template.html)
[neuvoja kurssikavereiden tehtävistä1](https://github.com/GarStiver/PuppetModules/tree/master/thirdhomework)
[neuvoja kurssikavereiden tehtävistä2](https://github.com/nikaar/puppet)

	
