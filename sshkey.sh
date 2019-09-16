#!/bin/bash
DIR="/root/.ssh"
sudo mkdir $DIR
sudo cp /vagrant/id_rsa* $DIR
sudo chmod 700 $DIR
sudo sh -c "cat $DIR/id_rsa.pub > $DIR/authorized_keys"
sudo chmod 600 $DIR/*
