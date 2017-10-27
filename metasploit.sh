#!/data/data/com.termux/files/usr/bin/bash

msfvar=4.16.13
msfpath='/data/data/com.termux/files/home'
isNokogiri=$(gem list -i "^nokogiri")
isGrpc=$(gem list -i "^grpc")
if [ -d "$msfpath/metasploit-framework" ]; then
	echo "metasploit is installed"
	exit 1
fi
apt update
apt install -y autoconf bison clang coreutils curl findutils git apr apr-util libffi-dev libgmp-dev libpcap-dev postgresql-dev readline-dev libsqlite-dev openssl-dev libtool libxml2-dev libxslt-dev ncurses-dev pkg-config postgresql-contrib wget make ruby-dev libgrpc-dev termux-tools ncurses-utils ncurses unzip zip tar postgresql termux-elf-cleaner

cd $msfpath
curl -LO https://github.com/rapid7/metasploit-framework/archive/$msfvar.tar.gz
tar -xf $msfpath/$msfvar.tar.gz
mv $msfpath/metasploit-framework-$msfvar $msfpath/metasploit-framework
cd $msfpath/metasploit-framework
sed '/rbnacl/d' -i Gemfile.lock
sed '/rbnacl/d' -i metasploit-framework.gemspec
gem install bundler
sed 's|nokogiri (1.*)|nokogiri (1.8.0)|g' -i Gemfile.lock
if [ $isNokogiri = "false" ];
then
      gem install nokogiri -v'1.8.0' -- --use-system-libraries
else
	echo "nokogiri already installed"
fi
sed 's|grpc (.*|grpc (1.4.1)|g' -i $msfpath/metasploit-framework/Gemfile.lock

if [ $isGrpc = "false" ];
then
	gem unpack grpc -v 1.4.1
	cd grpc-1.4.1
	curl -LO https://raw.githubusercontent.com/grpc/grpc/v1.4.1/grpc.gemspec
	curl -L https://raw.githubusercontent.com/Auxilus/Auxilus.github.io/master/Grpc_extconf.patch -o extconf.patch
	patch -p1 < extconf.patch
	gem build grpc.gemspec
	gem install grpc-1.4.1.gem
	cd ..
	rm -r grpc-1.4.1
else
	echo "grpc already installec"
fi

cd $msfpath/metasploit-framework
bundle install -j5

echo "Gems installed"
$PREFIX/bin/find -type f -executable -exec termux-fix-shebang \{\} \;
rm ./modules/auxiliary/gather/http_pdf_authors.rb

if [ -e $PATH/bin/msfconsole ];then
	rm $PATH/bin/msfconsole
fi
if [ -e $PATH/bin/msfvenom ];the
	rm $PATH/bin/msfveno
fi
ln -s $msfpath/metasploit-framework/msfconsole /data/data/com.termux/files/usr/bin/
ln -s $msfpath/metasploit-framework/msfvenom /data/data/com.termux/files/usr/bin/

termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/2.4.0/gems/pg-0.20.0/lib/pg_ext.so
echo "Creating database"

cd $msfpath/metasploit-framework/config
curl -LO https://Auxilus.github.io/database.yml

mkdir -p $PREFIX/var/lib/postgresql
initdb $PREFIX/var/lib/postgresql

pg_ctl -D $PREFIX/var/lib/postgresql start
createuser msf
createdb msf_database



echo "you can directly use msfvenom or msfconsole rather than ./msfvenom or ./msfconsole as they are symlinked to $PREFIX/bin""
