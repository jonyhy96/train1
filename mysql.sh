#!bin/bash
############################
#mysql source install shell#
############################

#download tools and libary
yum -y install gcc wget gcc-c++ make autoconf libtool-ltdl-devel gd-devel freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel curl-devel bison patch unzip libmcrypt-devel libmhash-devel ncurses-devel sudo bzip2 flex libaio-devel

#download cmake sourcecode
wget http://www.cmake.org/files/v3.1/cmake-3.1.1.tar.gz

tar zvxf cmake-3.1.1.tar.gz

cd cmake-3.1.1

#compile and install cmake
./bootstrap

make && make install

#download mysql sourcecode
wget https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.10.tar.gz

tar zxvf mysql-5.7.10.tar.gz
if [ -e " ./mysql-5.7.10" ];then
	echo "download succed"
fi
cd mysql-5.7.10

#compile and install mysql
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/webserver/mysql -DMYSQL_DATADIR=/data/mysql/data  -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/usr/local/boost
make && make install

#create mysql account
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql

#make binlog and database file then powered account mysql
mkdir -p /usr/local/webserver/mysql/binlog /www/data_mysql
chown mysql:mysql /usr/local/webserver/mysql/binlog/ /www/data_mysql/

#create my.cnf configure file
cat << EOF >/etc/my.cnf
[mysqld]
server-id = 1
basedir=/usr/local/webserver/mysql/
datadir=/data/mysql/data
socket=/tmp/mysql.sock
pid-file=/usr/local/webserver/mysql/mysql.pid
port=3306
user=mysql
[mysqld_safe]
log-error=/usr/local/webserver/mysql/mysql_error.log
[client] 
socket=/tmp/mysql.sock
EOF

#init mysql database
/usr/local/webserver/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --user=mysql >> /root/log.txt

#create start onboot tab
cd /usr/local/webserver/mysql/
cp support-files/mysql.server /etc/rc.d/init.d/mysqld 
chkconfig --add mysqld 
chkconfig --level 35 mysqld on

#start mysql service
service mysqld start

#link to mysql
/usr/local/webserver/mysql/bin/mysql -u root -p 'haoyun1996'

HOSTNAME="localhost"
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="myapp"

creat_db_sql="create database IF NOT EXITS ${DBNAME}"

/usr/local/webserver/mysql/bin/mysql -h ${HOSTNAME} -P ${PORT} -u ${USERNAME} -p ${PASSWORD} -e "${create_db_sql}"
if [ $? == 0 ];then
    echo "create yes"
fi
