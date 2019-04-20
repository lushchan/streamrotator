#!/bin/bash
echo "Install stream rotator to /home/ftpaccess/domain.com/www/r33x"
echo "edit file "domains" before installation"
touch ./domains
vim ./domains
echo "User name:"
read -e username
echo "Installation directory: "
read -e workdir
echo "Continue? (y/n)"
read -e run
if [ "$run" == n ] ; then
exit
else
cat ./domains | while read domain
do
mkdir -p /home/$username/$domain/www/$workdir
chmod 777 /home/ftpaccess/$domain/www/r33x
dbname=r3`echo $domain | cut -d / -f 4| sed -e 's/-/_/g'|sed 's|\.||g'`
dbuser=r3u`echo $domain | cut -d / -f 4|cut -c 1-13 | sed 's|-|_|g'|sed 's|\.||g'`
dbpass=`pwgen 12 1`
mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
mysql -e "CREATE USER ${dbuser}@localhost IDENTIFIED BY '${dbpass}';"
mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuser}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
wget http://streamscripts.com/rotator/install55.zip -P /home/ftpaccess/$domain/www/r33x
unzip /home/ftpaccess/$domain/www/r33x/install55.zip -d /home/ftpaccess/$domain/www/r33x
echo "dbHost: localhost"
echo "dbName $dbname"
echo "dbUser: $dbuser"
echo "dbPassword: $dbpass"
echo -e "* * * * * cd /home/ftpaccess/$domain/www/r33x/streamrotator; /usr/bin/php -q cron.php 1>/dev/null 2>/dev/null \n" >> /var/spool/cron/ftpaccess
done
echo "DONE! Go to URL to complete installation. Dont forget about database credentials. Check some lines before!!!"
exit
