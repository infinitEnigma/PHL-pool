#!/bin/bash

# start wallet
placehd -daemon -conf=/root/.placehconf/placeh.conf
sleep 15
# import private key to wallet
placeh-cli --conf=/root/.placehconf/placeh.conf importprivkey "pool-priv-key" "" false
# start redis
rm -f /var/run/redis_6379.pid
/etc/init.d/redis_6379 start
sleep 90
# start mining pool
pm2 start node -- init.js

#to keep the container running
# tail -f /dev/null
pm2 log
