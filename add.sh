#!/bin/bash -e
cat /dev/null > ./domains
echo "Install stream rotator"
echo "edit file "domains" before installation"
touch ./domains
vim ./domains
echo "User name:(default: ftpaccess)"
read -e username
if [[ -z $username ]]; then
username=ftpaccess
fi
echo "Installation directory: "
read -e workdir
cat ./domains | while read domain
do
mkdir /home/$username/$domain/www/$workdir
chmod 777 /home/$username/$domain/www/$workdir
DIR=/home/$username/$domain/www
DIR2=/home/$username/$domain/html
DIR3=/home/$username/$domain/public_html
if [ -d $DIR ] || [ -d $DIR2 ] || [ -d $DIR3 ] ; then
   echo "All looks fine"
else
   echo "Unknown document root"
exit 
fi
dbname=r3`echo $domain | cut -d / -f 4| sed -e 's/-/_/g'|sed 's|\.||g'`
dbuser=r3u`echo $domain | cut -d / -f 4|cut -c 1-13 | sed 's|-|_|g'|sed 's|\.||g'`
dbpass=`pwgen 12 1`
mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER ${dbuser}@localhost IDENTIFIED BY '${dbpass}';"
mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuser}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
wget http://streamscripts.com/rotator/install55.zip -P /home/$username/$domain/www/$workdir
unzip /home/$username/$domain/www/$workdir/install55.zip -d /home/$username/$domain/www/$workdir
echo "dbHost: localhost"
echo "dbName $dbname"
echo "dbUser: $dbuser"
echo "dbPassword: $dbpass"
echo -e "* * * * * cd /home/$username/$domain/www/$workdir; /usr/bin/php -q cron.php 1>/dev/null 2>/dev/null \n" >> /var/spool/cron/ftpaccess
echo "DONE! Go to URL to complete installation. Dont forget about database credentials. Check some lines before!!!"
done
exit
