## LAMP moduulin teko puppetilla

## Koneen speksit:

Tehty Oracle VM Virtualboxia käyttäen Xubuntu 16.04.1 64bit versiolla CPU Intel(R) Core(TM) i5-2500K CPU 3.30GHz

## APACHE

Ensimmäinen osuus LAMP moduulin teossa oli tehdä moduuli joka asentaa ja konffaa apachen.

Muistin että kurssikaverini oli tehnyt hyvin toimivan [apache moduulin](https://github.com/nikaar/puppet) joten katsoin hänen 
versiostaan mallia tarpeen mukaan.

Olin tehnyt tarvittavat kansiot jo aikaisemmin ja aloitin tehtävän ajamalla komennot 

    $sudo apt-get update -y
    $sudo apt-get upgrade -y

Tämän jälkeen loin init.pp filen sijaintiin /PuppetModules/Modules/apache/manifests ja aloitin itse moduulin muokkaamisen

    class apache {
          package{'apache2',
          ensure => "installed",
          }
    }

Tämä osuus moduulista varmistaa, että apache2 on asennettu ja testatakseni sitä varmistin että apache ei ole asennettuna
    
    $sudo apt-get purge apache2 -y
    
Tämän jälkeen ajoin moduulin komennolla

    $sudo puppet apply --modulepath ~/PuppetModules/Modules/ -e 'class {'apache':}'  
    
    kaapo@kaapopup:~$ sudo puppet apply --modulepath ~/PuppetModules/Modules -e 'class {'apache':}'
    Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.29 seconds
    Notice: /Stage[main]/Apache/Package[apache2]/ensure: ensure changed 'purged' to 'present'
    Notice: Finished catalog run in 5.62 seconds

Eli homma toimi ja tämän jälkeen selaimen localhost antoi tutun It Works! apache defaultsivun

Seuraavaksi lisäsin moduuliin osan joka varmistaa että apache on käynnissä

    class apache {
        package {'apache2':
                ensure => "installed",
        }
        service {'apache2':
                ensure => "running",
                enable => "true",
                require => Package["apache2"],
        }
    }
    
Tämän testaus tapahtui ensin pysäyttämällä apache ja sitten katomalla lähteekö se moduulin 
ajamalla taas käyntiin

    sudo service apache2 stop
    kaapo@kaapopup:~$ sudo puppet apply --modulepath ~/PuppetModules/Modules -e 'class {'apache':}'
    Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.38 seconds
    Notice: /Stage[main]/Apache/Service[apache2]/ensure: ensure changed 'stopped' to 'running'
    Notice: Finished catalog run in 1.14 seconds
    
Eli apache lähti käyntiin niinkuin pitikin

Tämän jälkeen Halusin saada kotihakemistoni käyttöön joten lisäsiin moduuliin tarivttavat osat eli lisäsin moduuliin 
2kpl file resurssia

    file {'/etc/apache2/mods-enabled/userdir.load':
                ensure => "link",
                target => "/etc/apache2/mods-available/userdir.load",
                notify => Service["apache2"],
                require => Package["apache2"],
        }
        file {'/etc/apache2/mods-enabled/userdir.conf':
                ensure => "link",
                target => "/etc/apache2/mods-available/userdir.conf",
                notify => Service["apache2"],
                require => Package["apache2"],
        }
Tämän jälkeen ajoin jälleen moduulin varmistaakseni ettei synny error viestejä

    sudo puppet apply --modulepath ~/PuppetModules/Modules -e 'class {'apache':}'

Molemmat osuudet toimivat ilman erroreja joten siirryin viimeiseen osaan moduulissa, joka loi käyttäjän 
kotihakemistoon public_html-kansion ja sinne index.html-tiedoston, joka otti käyttöön  templaten. 
Itse Templaten loin sijaintiin /PuppetModules/Modules/apache/templates komennolla

    sudo nano index_config
    
Sisällöksi templateen laitoin vain 
    
    <!DOCTYPE html>
    <html>
        <body>
                <p>Morjesta moi Korsosta</p>
        </body>
    </html>

Tämän jälkeen suurryin takaisin muokkaamaan itse moduulia ja lisäsin sen loppuun tarvittavat osat, jotka
loivat public_html kansion ja ottivat tehdyn templaten käyttöön. Käytin public_html kansiota hyödyksi myös php: n testaamisessa,
 joten se oli hyvä laittaa kuntoon tässä vaiheessa.

Kokonaisuudessaan moduuli näytti tältä 

    class apache {
        package {'apache2':
                ensure => "installed",
        }
        service {'apache2':
                ensure => "running",
                enable => "true",
                require => Package["apache2"],
        }
        file {'/etc/apache2/mods-enabled/userdir.load':
                ensure => "link",
                target => "/etc/apache2/mods-available/userdir.load",
                notify => Service["apache2"],
                require => Package["apache2"],
        }
        file {'/etc/apache2/mods-enabled/userdir.conf':
                ensure => "link",
                target => "/etc/apache2/mods-available/userdir.conf",
                notify => Service["apache2"],
                require => Package["apache2"],
        }
        file {'/home/kaapo/public_html':
                ensure => "directory",
                owner => "kaapo",
                group => "kaapo",
        }
        file {'/home/kaapo/public_html/index.html':
                content => template("apache/index_config"),
                owner => "kaapo",
                group => "kaapo",
        }
    }

Moduuli asentui moitteetta ja testasin toimivuuden menemällä selaimella osoitteeseen 
localhost/~kaapo/

Sivu avasi tekemäni templaten niin kuin pitikin

## MYSQL

Seuraava osuus LAMP ssa oli tehdä moduuli joka asentaa mysql serverin ja tekee root käyttäjän/salasanan

Olin jälleen luonut kansion valmiiksi sijaintiin /PuppetModules/Modules/mysql/manifests , joten aloitin
moduulin tekemisen luomalla tuonne init.pp filen ja laitoin sen asentamaan mysql-server paketin. Käytin mysql moduulin teossa apuna pari linkkiä [1](https://awaseroot.wordpress.com/2012/04/30/puppet-module-for-lamp-installation/) ja [2](https://www.digitalocean.com/community/tutorials/getting-started-with-puppet-code-manifests-and-modules)

    class mysql { 
        package{'mysql-server':
                ensure => "installed",
        }
    }

Ajoin tämän moduulin ja sain tuloksen:

    kaapo@kaapopup:~/PuppetModules/Modules/mysql/manifests$ sudo puppet 
    apply --modulepath ~/PuppetModules/Modules -e 'class {'mysql':}'
    Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.30 seconds
    Notice: /Stage[main]/Mysql/Package[mysql-server]/ensure: ensure changed 'purged' to 'present'
    
Eli paketin asennus onnistui, seuraavaksi halusin myös moduulin varmistavan, että mysql-server on päällä, joten 
lisäsin siihen osuuden 

    class mysql {
        package{'mysql-server':
                ensure => "installed",
        }
        service {"mysql":
                ensure => "running",
                enable => "true",
                require => Package["mysql-server"],
        }
    }
Pysäytin ensin mysql-serverin komennolla
    
    $ sudo /etc/init.d/mysql stop
    
Ajoin jälleen moduulin varmistuakseni, että se toimii:

    kaapo@kaapopup:~/PuppetModules/Modules/mysql/manifests$ sudo puppet apply --modulepath
    ~/PuppetModules/Modules -e 'class {'mysql':}'
    Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.37 seconds
    Notice: /Stage[main]/Mysql/Service[mysql]/ensure: ensure changed 'stopped' to 'running'
    Notice: Finished catalog run in 1.11 seconds
    
Tämän jälkeen halusin vielä lisätä exec komennon joka vaihtaa root käyttäjän salasanan joten lisäsin moduuliin kohdan

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
    
 Tämän jälkeen ajoin moduulin jälleen
 
        kaapo@kaapopup:~/PuppetModules/Modules/mysql/manifests$ sudo puppet apply --modulepath 
        ~/PuppetModules/Modules -e 'class {'mysql':}'
        Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.42 seconds
        Notice: /Stage[main]/Mysql/Exec[mysqlpasswd]/returns: executed successfully
        Notice: /Stage[main]/Mysql/Service[mysql]: Triggered 'refresh' from 1 events
        Notice: Finished catalog run in 2.24 seconds

Tämän jälkeen kävin tarkistamassa, että rootin salasana vaihtui

    Sudo mysql -u root -p 

Ja juuri vaihtamani Changedpassword1 toimi joten moduuli toimi niinkuin pitikin

    kaapo@kaapopup:~$ sudo mysql -u root -p
    Enter password: 
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 6
    Server version: 5.7.18-0ubuntu0.16.04.1 (Ubuntu)

## PHP

Viimeinen osa LAMP ssa oli PHP moduulin teko ja testaus.
Olin jälleen luonut sille tarvittavat kansiot sijaintiin /PuppetModules/Modules/php/manifests, 
joten loin sinne tiedoston init.pp ja tein sinne muokkaukset joilla varmistin, että php on asennettu

    class php { 
        package {'php7.0':
                ensure => "installed",
        }
    }

    kaapo@kaapopup:~/PuppetModules/Modules/php/manifests$ sudo puppet apply 
    --modulepath ~/PuppetModules/Modules -e 'class {'php':}'
    Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.27 seconds
    Notice: /Stage[main]/Php/Package[php7.0]/ensure: ensure changed 'purged' to 'present'
    Notice: Finished catalog run in 11.88 seconds
    
 Kaikki toimii toistaiseksi, seuraavaksi osuus laitoin moduulin myös luomaan test.php filen jonka avulla voi
 tarkistaa, että php toimii:
 
        class php {
                package {'php7.0':
                    ensure => "installed",
                }
                package {'libapache2-mod-php7.0':
                    ensure => "installed"
                }
                package {'libapache2-mod-php':
                    ensure => "installed",
                }
                file {'/var/www/html/test.php':
                    ensure => "file",
                    content => "<?php echo '<p> Moro korso</p>'; ?>",
                }
        }

Huomasin, että homma ei pelitä ja samalla muistin, että php7.0.cong filestä piti kommentoida pari riviä 
tekstistä poism joten loin siitä templaten johon nämä kommentoinnit oli tehty ja muutin moduulia

        
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
     
Menin tarkistamaan toimiiko sivu joten kirjoitin selaimeen localhost/~kaapo/test.php ja se näytti haluamani vastaukseni
1+1 printtaukseen "2" eli myös php oli asentunut onnistuneesti.

## Koko LAMP in asentaminen yhdellä skriptillä

Halusin pystyä asentamaan kaikki LAMP in moduulit yhdellä komennolla joten loin tiedoston LAMPapply.sh, jonka
sisällöksi laitoin kolme komentoa, jotka asensivat juuri tekemäni moduulit
    
    #!/bin/bash

    sudo puppet apply --modulepath ~/PuppetModules/Modules -e 'class{"apache":}'
    sudo puppet apply --modulepath ~/PuppetModules/Modules -e 'class{"mysql":}'
    sudo puppet apply --modulepath ~/PuppetModules/Modules -e 'class{"php":}'
    
Tämän jälkeen tein uuden virtuaalikoneen ja kokeilin ajaa skirptit sillä läpi

    sudo sh LAMPapply.sh
    
    kaapo@kaapopup:~/PuppetModules$ sh LAMPapply.sh 
    Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.48 seconds
    Notice: /Stage[main]/Apache/Package[apache2]/ensure: ensure changed 'purged' to 'present'
    Notice: /Stage[main]/Apache/File[/etc/apache2/mods-enabled/userdir.conf]/ensure: created
    Notice: /Stage[main]/Apache/File[/etc/apache2/mods-enabled/userdir.load]/ensure: created
    Notice: /Stage[main]/Apache/Service[apache2]: Triggered 'refresh' from 2 events
    Notice: Finished catalog run in 7.97 seconds
    Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.42 seconds
    Notice: /Stage[main]/Mysql/Package[mysql-server]/ensure: ensure changed 'purged' to 'present'
    Notice: /Stage[main]/Mysql/Exec[mysqlpasswd]/returns: executed successfully
    Notice: /Stage[main]/Mysql/Service[mysql]: Triggered 'refresh' from 1 events
    Notice: Finished catalog run in 4.48 seconds
    Notice: Compiled catalog for kaapopup.dhcp.inet.fi in environment production in 0.39 seconds
    Notice: /Stage[main]/Php/Package[php7.0]/ensure: ensure changed 'purged' to 'present'
    Notice: Finished catalog run in 2.38 seconds

Skripti näytti toimivan ilman error viestejä, mutta oli vielä testattava että kaikki halutut asiat 
alkoivat toimia. Testasin ensin apachen toimivuuden sekä localhostissa, että localhost/~kaapo/ ja molemmat
toimivat niin kuin pitikin

Seuraavaksi testasin oliko mysql asentunut ja vaihtanut rootin salasanan. ja tämä toimi juuri
niinkuin pitikin. 

Viimeiseksi testasin php n toiminnan avamaalla selaimessa localhost/~kaapo/test.php sivun ja sekin toimi ja printtasi kakkosen

## REFERENCES
[]()
[]()
[]()
[]()
    




    



   


   


    

    
