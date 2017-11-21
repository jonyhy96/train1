#!bin/bash
############################
#mysql source install shell#
############################

#set mysql file
prefix='/usr/local/mysql'  
#set data file
datadir='/data/mysql/data'

#download tools and libary
yum -y install gcc wget gcc-c++ make autoconf libtool-ltdl-devel gd-devel freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel curl-devel bison patch unzip libmcrypt-devel libmhash-devel ncurses-devel sudo bzip2 flex libaio-devel

#download cmake sourcecode
wget http://www.cmake.org/files/v3.1/cmake-3.1.1.tar.gz

tar zvxf cmake-3.1.1.tar.gz

cd cmake-3.1.1

#compile and install cmake
./bootstrap

make && make install
cd ..
#download boost
#wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
#tar zxvf  boost_1_59_0.tar.gz
#cd boost_1_59_0
#./bootstrap.sh --prefix=/etc/boost
#./b2 install --with=all
#cd ..

#download mysql sourcecode
wget https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.10.tar.gz

tar zxvf mysql-5.7.10.tar.gz
if [ -e " ./mysql-5.7.10" ];then
	echo "download succed"
fi
cd mysql-5.7.10


#compile and install mysql
#add the config -DDOWNLOAD_BOOST=1 will download boost autolly
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql/data -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/etc/boost
make && make install

#create mysql account
/usr/sbin/groupadd mysql
/usr/sbin/useradd -g mysql mysql

#make binlog and database file then powered account mysql
mkdir -p /usr/local/mysql/etc /var/run/mysqld/ /var/log/mysqld/
chown mysql:mysql /usr/local/mysql/etc /data/mysql/data /var/run/mysqld/ /var/log/mysqld/ /usr/local/mysql

#create my.cnf configure file
cat << EOF >/usr/local/mysql/etc/my.cnf
[mysqld]
server-id = 1
basedir=/usr/local/mysql
datadir=/data/mysql/data
socket=/var/run/mysqld/mysql.sock
pid-file=/var/run/mysqld/mysql.pid
port=3306
user=mysql
[mysqld_safe]
log-error=/var/log/mysqld/mysql-error.log
[client] 
socket=/var/run/mysqld/mysql.sock 
EOF


#init mysql database
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql   --basedir=$prefix  --datadir=$datadir

#create start onboot tab
cd /usr/local/mysql/
cp support-files/mysql.server /etc/rc.d/init.d/mysqld 
chkconfig --add mysqld 
chkconfig --level 35 mysqld on

#start mysql service
service mysqld start
if[ $? != 0 ];then
	mv /etc/my.cnf /etc/my.cnf.back
	service mysqld start
fi

#link to mysql
/usr/local/mysql/bin/mysqladmin -u root password '123456'

HOSTNAME="localhost"
PORT="3306"
USERNAME="root"
PASSWORD="123456"
DBNAME="myapp"

creat_db_sql="create database IF NOT EXITS ${DBNAME}"

/usr/local/mysql/bin/mysql -h ${HOSTNAME} -P ${PORT} -u ${USERNAME} -p ${PASSWORD} -e "${create_db_sql}"
if [ $? == 0 ];then
    echo "Success"
fi
