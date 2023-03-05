#!/bin/bash
echo "Enter domain"
read domain
IP=$(ping -c 1 $domain | awk -F'[()]' '/PING/{print $2}')
yum -y install epel-release
rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum-config-manager --enable remi-php74
yum -y install httpd
yum -y install nginx
yum -y install php php-cli php-mysqlnd php-json php-gd php-ldap php-odbc php-pdo php-opcache php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap php-zip
yum -y install mariadb-server
systemctl enable mariadb
systemctl start mariadb
mysql_secure_installation <<EOF

n
y
y
y
y
EOF
mkdir -p /home/hes/$domain/{www,cgi-bin}
echo pidars > /home/hes/$domain/www/index.html
chown -R hes:hes /home/hes/$domain
chmod -R 0775 /home/hes/$domain
chmod 0755 /home/hes
mkdir /etc/httpd/vhosts.d
curl -o /etc/httpd/vhosts.d/$domain.conf https://raw.githubusercontent.com/chupikoff/nginx_http/main/domain.com.conf%3A8080
sed -i "s/domain\.com/$domain/g" /etc/httpd/vhosts.d/$domain.conf
curl -o /etc/httpd/conf/httpd.conf https://raw.githubusercontent.com/chupikoff/nginx_http/main/httpd.conf
mkdir /etc/nginx/vhosts.d
curl -o /etc/nginx/vhosts.d/$domain.conf https://raw.githubusercontent.com/chupikoff/nginx_http/main/domain.com.conf%3A80
sed -i "s/domain\.com/$domain/g" /etc/nginx/vhosts.d/$domain.conf
sed -i "s/IPADDRESS/$IP/g" /etc/nginx/vhosts.d/$domain.conf
curl -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/chupikoff/nginx_http/main/nginx.conf
curl -o /etc/nginx/universal-proxy.conf https://raw.githubusercontent.com/chupikoff/nginx_http/main/universal-proxy.conf
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
systemctl start httpd
systemctl start nginx
systemctl enable httpd
systemctl enable nginx

