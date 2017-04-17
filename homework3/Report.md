## Kotitehtävä 3 Linuxin hallinta kurssilla

a) konfiguroi SSH uuteen porttiin puppetilla
b)laita tekemäsi moduulit gittiin, jotta ne saa koulussa helposti live-usb työpöydälle
c)Vaihda Apachen oletusweppisivu( default website) Puppetilla


# Oma setuppi

#Miten toimin:
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
