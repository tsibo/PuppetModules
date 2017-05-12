#!/bin/bash

sudo puppet apply --modulepath modules -e 'class{"apache":}'
sudo puppet apply --modulepath modules -e 'class{"mysql":}'
sudo puppet apply --modulepath modules -e 'class{"php":}'
