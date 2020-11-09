#!/bin/bash -e
#logging
##timestampformat
tstamp=$(date +%m/%d/%Y-%H:%M:%S)
##credentials
creds=./creds.txt
#inputfile
ifile=./r33x.txt
phppath=`which php$phpver`
phppathdef=`which php`
vim $ifile
echo "Choice a php version:(default: $phppathdef)"
read -e phpver
if [[ -z phpver ]]; then
  phppath=$phppathdef
fi
phppath=`which php$phpver`

r33xphp5="http://streamscripts.com/rotator/install.zip"
r33xphp7="http://streamscripts.com/rotator/install_71.zip"
#download section
if [[ "$phpver" == "5"* ]] ; then
wget $r33xphp5
unzip install.zip
elif [[ "$phpver" == "7"* ]] ; then
wget $r33xphp7
unzip install_71.zip
else
        echo "Chtoto poshlo ne tak"
fi
#

mysqlloc=`which mysql`
mysqldumploc=`which mysqldump`
convertloc=`which convert`
cat $ifile | while read domain
docroot=$(grep -r "$domain" /etc/nginx/ | grep root | awk '{print $(NF-1), $NF}'  | sed 's/root //g;s/;//g' | sed 's/^[ \t]*//g;s/[ \t]*$//g;s|/$||g' | sort -u | head -n 1)
r33xroot=$docroot/r33x
username=`stat -c "%U" $docroot`
do
  mkdir $r33xroot
  chmod 777 $r33xroot
  cp install.php $r33xroot/install.php
  dbname=r3`echo $domain | cut -d / -f 4| sed -e 's/-/_/g'|sed 's|\.||g'`
  dbuser=r3u`echo $domain | cut -d / -f 4|cut -c 1-13 | sed 's|-|_|g'|sed 's|\.||g'`
  dbpass=`head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 13; echo "!"`
  mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
  mysql -e "CREATE USER ${dbuser}@localhost IDENTIFIED BY '${dbpass}';"
  mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuser}'@'localhost';"
  mysql -e "FLUSH PRIVILEGES;"
  echo "MySql host: localhost"
  echo "MySql user: $dbuser"
  echo "MySql password: $dbpass"
  echo "MySql database: $dbname"
  echo "mysql utility location: $mysqlloc"
  echo "mysqldump utility location: $mysqldumploc"
  echo "IM convert utility location: $convertloc"
  echo "PHP location: $phppath"
  echo "Script directory: ."
  echo -e "* * * * * cd $r33xroot; $phppath -q cron.php 1>/dev/null 2>/dev/null \n" >> /var/spool/cron/$username
  echo "DONE! Go to URL to complete installation. Dont forget about database credentials. Check some lines before!!!"
done
service crond reload
exit
