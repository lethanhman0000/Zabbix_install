apt update
apt upgrade -y
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb
apt update
apt-get install mariadb-server mariadb-client apache2 php php-mysql php-bcmath php-intl php-mbstring php-gd php-xml php-ldap php-zip php-fpm -y
systemctl restart apache2
systemctl start apache2
systemctl enable apache2
systemctl start mariadb
systemctl enable mariadb
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y
apt install zabbix-server-mysql zabbix-agent zabbix-apache-conf zabbix-sql-scripts  zabbix-frontend-php -y
pass_sql="123456"
mysql --user=root --password="$pass_sql" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
mysql -u root -p"$pass_sql" -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -u root -p"$pass_sql" -e "create user zabbix@localhost identified by '123456';"
mysql -u root -p"$pass_sql" -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -u root -p"$pass_sql" -e "set global log_bin_trust_function_creators = 1;"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
mysql -u root -p"$pass_sql" -e "set global log_bin_trust_function_creators = 0;"
sed -i 's/^memory_limit = .*/memory_limit = 128M/' /etc/php/8.3/apache2/php.ini
sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 8M/' /etc/php/8.3/apache2/php.ini
sed -i 's/^post_max_size = .*/post_max_size = 16M/' /etc/php/8.3/apache2/php.ini
sed -i 's/^max_execution_time = .*/max_execution_time = 300/' /etc/php/8.3/apache2/php.ini
sed -i 's/^max_input_time = .*/max_input_time = 300/' /etc/php/8.3/apache2/php.ini
sed -i 's/^# DBPassword=/DBPassword=123456/' /etc/zabbix/zabbix_server.conf
systemctl restart zabbix-server zabbix-agent apache2 
systemctl enable zabbix-server zabbix-agent apache2 
