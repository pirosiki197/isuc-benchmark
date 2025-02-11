#!/bin/bash

set -eu

if [ -f $(hostname)/env.sh ]; then
    cp -f $(hostname)/env.sh /home/isucon/env.sh
fi

for file in $(find etc -type f); do
  if [ $file = "etc/.gitkeep" ]; then
    continue
  fi

  if [ -f $(hostname)/$file ]; then
    sudo cp -f $(hostname)/$file /$file
    continue
  fi
  sudo cp -f $file /$file
done

APP_NAME="isupipe"
APP_DIR="/home/isucon/webapp/go"
SERVICE_NAME="isupipe-go"

cd "$APP_DIR"

go build -o "$APP_NAME" .

sudo systemctl restart pdns
sudo systemctl restart mysql
sudo systemctl restart nginx
sudo systemctl restart "$SERVICE_NAME"

# enable slow query log
QUERY="
set global slow_query_log_file = '/var/log/mysql/mysql-slow.log';
set global long_query_time = 0;
set global slow_query_log = ON;
"
echo $QUERY | sudo mysql -uroot

sudo chmod -R 777 /var/log/nginx
sudo chmod -R 777 /var/log/mysql
