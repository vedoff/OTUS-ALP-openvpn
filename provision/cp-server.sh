#!/bin/bash

sudo cp /vagrant/provision/{esay-rsa.tar.gz,server.tar.gz,client.tar.gz} /etc/openvpn/
cd /etc/openvpn/
sudo tar -xf server.tag.gz
sudo tar -xf esay-rsa.tar.gz
sudo tar -xf client.tar.gz