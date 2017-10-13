#!/data/data/com.termux/files/usr/bin/bash

version=4.16.4

function deps() {
    apt update
    apt install -y autoconf bison clang coreutils curl findutils git apr apr-util libffi-dev libgmp-dev libpcap-dev postgresql-dev readline-dev libsqlite-dev openssl-dev libtool libxml2-dev libxslt-dev ncurses-dev pkg-config postgresql-contrib wget make ruby-dev libgrpc-dev termux-tools ncurses-utils ncurses unzip zip tar postgresql termux-elf-cleaner
}

function fetch() {
    cd $HOME
    curl -LO https://github.com/rapid7/metasploit-framework/archive/$version.tar.gz
    tar -xf $HOME/$version.tar.gz
    mv $HOME/metasploit-framework-$version $HOME/metasploit-framework
    cd $HOME/metasploit-framework
}

function rbnacl() {
    sed '/rbnacl/d' -i Gemfile.lock
    sed '/rbnacl/d' -i metasploit-framework.gemspec
}

function bundler() {
    gem install bundler
}

function nokogiri() {
    sed 's|nokogiri (1.*)|nokogiri (1.8.0)|g' -i Gemfile.lock
    gem install nokogiri -v'1.8.0' -- --use-system-libraries
}

function grpc() {
    sed 's|grpc (.*|grpc (1.4.1)|g' -i $HOME/metasploit-framework/Gemfile.lock
    gem unpack grpc -v 1.4.1
    cd grpc-1.4.1
    curl -LO https://raw.githubusercontent.com/grpc/grpc/v1.4.1/grpc.gemspec
    curl -L https://wiki.termux.com/images/b/bf/Grpc_extconf.patch -o extconf.patch
    patch -p1 < extconf.patch
    gem build grpc.gemspec
    gem install grpc-1.4.1.gem
    cd ..
    rm -r grpc-1.4.1
}

function bundle_install() {
    cd $HOME/metasploit-framework
    bundle install -j5
    echo "Gems installed "
}

#$PREFIX/bin/find -type f -executable -exec termux-fix-shebang \{\} \;

function error_fix() {
    rm ./modules/auxiliary/gather/http_pdf_authors.rb
    ln -s $HOME/metasploit-framework/msfconsole /data/data/com.termux/files/usr/bin/
    ln -s $HOME/metasploit-framework/msfvenom /data/data/com.termux/files/usr/bin/
    termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/2.4.0/gems/pg-0.20.0/lib/pg_ext.so
}

function db() {
    echo "Creating database"
    cd $HOME/metasploit-framework/config
    curl -LO https://Auxilus.github.io/database.yml
    mkdir -p $PREFIX/var/lib/postgresql
    initdb $PREFIX/var/lib/postgresql
    pg_ctl -D $PREFIX/var/lib/postgresql start
    createuser msf
    createdb msf_database
}
#echo "you can directly use msfvenom or msfconsole rather than ./msfvenom or ./msfconsole as they are symlinked to $PREFIX/bin""

clear
spinner=( Ooooo oOooo ooOoo oooOo ooooO oooOo ooOoo oOooo);

execute(){
  spin &
  pid=$!

  deps > /dev/null
  fetch
  rbnacl
  bundler
  nokogiri
  grpc
  bundle_install
  error_fix
  db
  kill $pid
}

spin(){
  while [ 1 ]
  do
    for i in ${spinner[@]};
    do
      echo -ne "\r$i";
      sleep 0.2;
    done;
  done
}


if [ $1 == "-d" ]; then
	
        deps
	fetch
	rbnacl
	bundler
	nokogiri
	grpc
        bundle_install
	error_fix
	db
else
	execute	
fi
