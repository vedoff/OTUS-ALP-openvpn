# openvpn
#### Настройка openvpn site-to-site client-to-site

1. Между двумя виртуалками поднять vpn в режимах `tun`/`tap`
2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку.

# Выполнение:
### Между двумя виртуалками поднять vpn в режимах tun/tap
Поднимаем стенд: \
`vagrant up`
### Схема стенда
![](https://github.com/vedoff/openvpn/blob/main/pict/Screenshot%20from%202022-03-29%2015-18-58.png)
