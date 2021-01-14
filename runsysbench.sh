#!/bin/bash

# install sysbench
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt-get install -y myscli sysbench

# create database for sysbench
mycli -h 127.0.0.1 -P 4000 -u root -e 'set global tidb_disable_txn_auto_retry = off'
mycli -h 127.0.0.1 -P 4000 -u root -e 'create database sbtest'

# run sysbench script
sysbench --config-file=config oltp_point_select --tables=2 --table-size=1000000 prepare
sysbench --config-file=config oltp_point_select --tables=2 --table-size=1000000 run | tee oltp_point_select_flexible_raft.log
sysbench --config-file=config oltp_update_index --tables=2 --table-size=1000000 run | tee oltp_update_index_flexible.log
sysbench --config-file=config oltp_read_only --tables=2 --table-size=1000000 run | tee oltp_read_only_flexible.log
sysbench --config-file=config oltp_read_write --tables=2 --table-size=1000000 run | tee oltp_read_write_flexible.log