#!/bin/bash
yum update -y
amazon-linux-extras install -y php7.4
yum install -y httpd php php-mysqlnd wget unzip
systemctl start httpd
systemctl enable httpd

cd /var/www/html
wget https://wordpress.org/latest.zip
unzip latest.zip
mv wordpress/* .
rmdir wordpress
rm latest.zip

# remove apache starting page
rm -f /var/www/html/index.html


# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
