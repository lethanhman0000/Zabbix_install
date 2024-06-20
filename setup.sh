wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb
apt update
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y
pass_sql="123456"
mysql -u root -p"$pass_sql" -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -u root -p"$pass_sql" -e "create user zabbix@localhost identified by '123456';"
mysql -u root -p"$pass_sql" -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -u root -p"$pass_sql" -e "set global log_bin_trust_function_creators = 1;"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
mysql -u root -p"$pass_sql" -e "set global log_bin_trust_function_creators = 0;"
sed -i 's/^# DBPassword=/DBPassword=123456/' /etc/zabbix/zabbix_server.conf
systemctl restart zabbix-server zabbix-agent apache2 
systemctl enable zabbix-server zabbix-agent apache2 
