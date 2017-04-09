# Harjoitus2:
Asenna ja konfiguroi jokin palvelin package-file-service -tyyliin Puppetilla.

## Koneen speksit:
Tehty Oracle VM Virtualboxia käyttäen Xubuntu 16.04.1 64bit versiolla
CPU Intel(R) Core(TM) i5-2500K CPU 3.30GHz 

## Miten toimin:
Päätin tehdä moduulin, jonka funktio on asentaa apache2 paketti ja muuttaa sen
kotisivun ulkomuotoa automaattisesti. Tätä varten poistin ensin apache2
paketin ajamalla komennon

`sudo apt-get purge apache2 -y`

Tämän jälkeen kävin tarkistamassa selaimen kautta, ettö osoitekenttään
kirjoitettu "localhost" ei antanut toimivaa apachen kotisivua.

Tämän jälkeen tein uuden moduulin sijaintiin /etc/puppet/modules
komennolla

`sudo mkdir -p h2apache2/manifests/`

jonka jälkeen menin manifests kansioon ja loin init.pp tiedoston komennolla
`sudo nano init.pp`

Tein ensin tiedostoon vain sen osan joka asentaa apachen koneelle joten
moduuli näytti ensin tältä

`class h2apache2{
        package { 'apache2':
                ensure => "installed",
        }
}
`

Tämän jälkeen ajoin modulen komennolla `puppet apply -e 'class{h2apache2:}'`
ja koska kaiki näytti toimivan kävin samalla tarkastamassa selaimen kautta, 
mihin localhost minut vei ja ilokseni huomasin sen avaavan apachen default
it works sivun, joten moduuli toimi halutulla tavalla.

Tämän jälkeen menin muokkaamaan moduuliani siten, että file atribuutti
muokkaa index.html filen sisältöä haluamakseni kun ajan moduulin

`class h2apache2{
        package { 'apache2':
                ensure => "installed",
        }
        file { '/var/www/html/index.html':
                content => "vaihda muuta hauskaa tilalle kuin it works",
        }
}
`

Tämän jälkeen oli vielä ajettava `sudo service apache2 restart` komento jotta
 muutokset tulivat voimaan


Seuraavaksi halusin vielä varmistaa että apache2 on käynnissä service atribuutin
avulla, joten minun piti lisätä se vielä moduuliini joka näytti viimeisen vaiheen jälkeen tältä


>` class h2apache2{
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
`

Moduuli toimi niinkuin pitikin 
