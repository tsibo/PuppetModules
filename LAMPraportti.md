## LAMP moduulin teko puppetilla

## Koneen speksit:

Tehty Oracle VM Virtualboxia käyttäen Xubuntu 16.04.1 64bit versiolla CPU Intel(R) Core(TM) i5-2500K CPU 3.30GHz

## APACHE

Ensimmäinen osuus LAMP moduulin teossa oli tehdä moduuli joka asentaa ja konffaa apachen.

OLin tehnyt tarvittavat kansiot jo aikaisemmin ja aloitin tehtävän ajamalla komennot 

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

    $sudo puppet apply --modulepath ~/PuppetModules/modules/ -e 'class {'apache':}'  

