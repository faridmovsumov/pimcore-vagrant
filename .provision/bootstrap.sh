#!/bin/bash

DBUSER=root
DBPASSWD=root

echo "(Setting up your Vagrant box...)"

echo "(Updating apt-get...)"
sudo apt-get update > /dev/null 2>&1

# Apache
echo "(Installing Apache...)"
sudo apt-get install -y apache2 apache2-doc apache2-utils debconf-utils htop mc > /dev/null 2>&1
sudo rm /etc/apache2/sites-enabled/000-default.conf

echo "(Mod Rewrite Apache...)"
sudo a2enmod rewrite > /dev/null 2>&1

echo "(Installing Imagick...)"
sudo apt-get install -y imagemagick > /dev/null 2>&1

echo "(Installing PHP Imagick extension...)"
sudo apt-get install -y php-imagick > /dev/null 2>&1

echo "(Installing bzip2...)"
sudo apt-get install -y php-bz2 > /dev/null 2>&1

echo "(Installing php-intl...)"
sudo apt-get install -y php7.0-intl > /dev/null 2>&1

echo "(Installing PHP and MySQL module...)"
sudo apt-get install -y php libapache2-mod-php php-mcrypt php-mysql > /dev/null 2>&1

echo "(Installing php extensions mbstring, xml...)"
sudo apt-get install -y php7.0-mbstring php7.0-xml zip unzip php7.0-zip php-curl > /dev/null 2>&1

echo "(Installing composer...)"
sudo apt-get install -y composer > /dev/null 2>&1

echo "(Installing redis...)"
sudo apt-get install -y redis-server > /dev/null 2>&1

echo "(Installing php-redis...)"
sudo apt-get install -y php-redis > /dev/null 2>&1

echo "(Installing npm...)"
sudo apt-get install -y npm > /dev/null 2>&1

echo "(Installing additional tools...)"
sudo apt-get install -y htop mc > /dev/null 2>&1

# Apache Config
echo "(Overwriting default Apache config to work with PHP...)"
cp /vagrant/.provision/apache/pimcore /etc/apache2/sites-available/pimcore.conf > /dev/null 2>&1
sudo ln -s /etc/apache2/sites-available/pimcore.conf /etc/apache2/sites-enabled/pimcore.conf  > /dev/null 2>&1

# PhpMyAdmin Config
echo "(Copying PHPMyAdmin configuration to /etc/apace2/sites-available/...)"
cp /vagrant/.provision/apache/phpmyadmin /etc/apache2/sites-available/phpmyadmin.conf > /dev/null 2>&1
sudo ln -s /etc/apache2/sites-available/phpmyadmin.conf /etc/apache2/sites-enabled/phpmyadmin.conf  > /dev/null 2>&1

echo "(Copying MySQL configuration...)"
cp /vagrant/.provision/configs/my.cnf /home/vagrant/.my.cnf > /dev/null 2>&1

# Restarting Apache for config to take effect
echo "(Restarting Apache for changes to take effect...)"
sudo service apache2 restart > /dev/null 2>&1

echo "(Setting Ubuntu (user) password to \"vagrant\"...)"
echo "ubuntu:vagrant" | chpasswd

echo "(Cleaning up additional setup files and logs...)"
sudo rm -r /var/www/html

# MySQL
echo "(Preparing for MySQL Installation...)"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

echo "(Installing MySQL...)"
sudo apt-get install -y mysql-server > /dev/null 2>&1

echo "(Creating database...)"
mysql --defaults-extra-file=/home/vagrant/.my.cnf -e"CREATE DATABASE pimcore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "(Give permission to write to mysql file...)"
mysql --defaults-extra-file=/home/vagrant/.my.cnf -e"GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASSWD' WITH GRANT OPTION;"
mysql --defaults-extra-file=/home/vagrant/.my.cnf -e"GRANT FILE ON *.* TO '$DBUSER'@'localhost';"
mysql --defaults-extra-file=/home/vagrant/.my.cnf -e"FLUSH PRIVILEGES;"

# PhpMyAdmin
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

echo "(Installing PhpMyAdmin...)"
sudo apt-get install -y phpmyadmin > /dev/null 2>&1

echo "(Symlink PhpMyAdmin...)"
sudo ln -s /usr/share/phpmyadmin /var/www/phpmyadmin

echo "(Increasing swap memory limits)"
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024 > /dev/null 2>&1
sudo chmod 0600 /var/swap.1 > /dev/null 2>&1
sudo /sbin/mkswap /var/swap.1 > /dev/null 2>&1
sudo /sbin/swapon /var/swap.1 > /dev/null 2>&1

echo "(Creating project)"
cd /var/www
#rm -rf pimcore/*
composer --no-progress create-project pimcore/pimcore ./pimcore > /dev/null 2>&1
#git clone https://github.com/pimcore/pimcore.git

echo "(Changing dir to /var/www/pimcore)"
cd /var/www/pimcore
#sudo composer update

echo "(Installing pimcore/demo-ecommerce)"
composer --no-progress require pimcore/demo-ecommerce > /dev/null 2>&1

echo "(Dumping and optimizing composer autoload files)"
sudo composer dumpautoload -o

echo "(Changing permissions to 777)"
sudo chmod 777 -R /var/www/pimcore/

echo "(Adding aliases...)"
echo 'alias cdproj="cd /var/www/pimcore/"' >> ~/.bashrc

echo "(Activating Alliases)"
source ~/.bashrc

echo "(Adding Mysql Permission for reading csv files)"
echo '[mysqld]' >> /etc/mysql/my.cnf
echo 'secure-file-priv = ""' >> /etc/mysql/my.cnf
sudo service mysql restart

sudo sed -i '$ d' /etc/apparmor.d/usr.sbin.mysqld
echo '/var/www/pimcore/vendor/pimcore/demo-ecommerce/dump/data/ r,' >> /etc/apparmor.d/usr.sbin.mysqld
echo '/var/www/pimcore/vendor/pimcore/demo-ecommerce/dump/data/* rw,' >> /etc/apparmor.d/usr.sbin.mysqld
echo '}' >> /etc/apparmor.d/usr.sbin.mysqld
sudo /etc/init.d/apparmor reload

/var/www/pimcore/bin/install pimcore:install --profile pimcore/demo-ecommerce --admin-username admin --admin-password admin --mysql-username $DBUSER --mysql-password $DBPASSWD --mysql-database pimcore --no-interaction --ignore-existing-config

echo "(Fixing session path...)"
cp /vagrant/.provision/configs/session.yml /var/www/pimcore/app/config/local/

echo "+---------------------------------------------------------+"
echo "|                      S U C C E S S                      |"
echo "+---------------------------------------------------------+"