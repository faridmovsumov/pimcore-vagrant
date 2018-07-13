Vagrant Box for Pimcore Demo Ecommerce
======================================

## Setup Vagrant Box
```bash
vagrant up
```

## Run on your host machine. Add virtual host domain

```bash
sudo vi /etc/hosts
```

> 192.168.33.56   pimcore.az

> 192.168.33.56   phpmyadmin.pimcore.az

## Optional Configurations

```bash
vi /etc/php/7.0/apache2/php.ini
```
> memory_limit = -1

```bash
sudo service apache2 restart
```

## Session configuration 

For Vagrant create session.yml under app/config/local/ directory and put following code

```php
framework:
    session:
        # http://symfony.com/doc/3.4/session/sessions_directory.html
        save_path: /tmp/pimcore/var/sessions
```
