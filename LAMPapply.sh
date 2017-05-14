#!/bin/bash

sudo puppet apply --modulepath ~/PuppetModules/Modules -e 'class{"apache":}'
sudo puppet apply --modulepath ~/PuppetModules/Modules -e 'class{"mysql":}'
sudo puppet apply --modulepath ~/PuppetModules/Modules -e 'class{"php":}'
