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

## Change Session Save Path Location

Set session save path in config/config.yml:

> save_path: /var/lib/php/sessions

## Disable AdvancedObjectSearchBundle Extension

You may get some errors related to ElasticSearch indexing. 
You can prevent that by disabling AdvancedObjectSearchBundle

1) You can disable it from Admin Interface

> Tools -> Extensions

2) You can also disable it in config file

> /var/config/extensions.php 

```php
"AdvancedObjectSearchBundle\\AdvancedObjectSearchBundle" => FALSE,
```