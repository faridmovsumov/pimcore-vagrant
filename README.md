Vagrant Box for Pimcore
=======================

## Setup Vagrant Box
```bash
vagrant up
```

## Run installation script

```bash
sudo /var/www/pimcore/bin/install pimcore:install --ignore-existing-config
```

## Run on your host machine. Add virtual host domain

```bash
sudo vi /etc/hosts
```

> 192.168.33.56   pimcore.az
> 192.168.33.56   phpmyadmin.pimcore.az