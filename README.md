# openvpn
#### Настройка openvpn site-to-site client-to-site

1. Между двумя виртуалками поднять vpn в режимах `tun`/`tap`
2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку.

# Выполнение:
### Между двумя виртуалками поднять vpn в режимах tun/tap
Поднимаем стенд: \
`vagrant up && ansible-playbook play.yml`
### Схема стенда
![](https://github.com/vedoff/openvpn/blob/main/pict/Screenshot%20from%202022-03-29%2015-18-58.png)

В результате будут развернуты машины согласно схеме и установленн на них openvpn, утилита easy-rsa (только на сервер), а также дополнительные утилиты.

## Далее пошаговое развертывание openvpn site-to-site:
Копируем утилиту easy-rsa в наш каталог openvpn \
`cp -r /usr/share/easy-rsa /etc/openvpn` \
Переходим по пути \
`cd /etc/openvpn/easy-rsa/` \
Инициализируем PKI
`./easyrsa init-pki`\
Создаем корневой сертификат CA, в процессе будет запрошена установка пароля для удобства вводим (123456)
`./easyrsa build-ca` \
После генерации сертификат CA доступен в
`/etc/openvpn/easy-rsa/pki/ca.crt`
Генерим ключ ДефиХельмана: \
`./easyrsa gen-dh` \
После генерации доступен: \
`/etc/openvpn/easy-rsa/pki/dh.pem` \
Теперь генерим серверный сертификат и ключ в процессе будет запрошен пароль на CA.key (123456): \
`./easyrsa build-server-full server nopass` \
`nopass` - не устанавливать пароль на сертификат. \
Генерим TLS/SSL - защита от DoS атак и UDPпорт флудинга \
`openvpn --genkey secret /etc/easy-rsa/pki/ta.key` \
Генерим сертификат отзыва: \
`./easyrsa gen-crl` \
Доступен по `/etc/easy-rsa/pki/crl.pem` \
Копируем полученые сертификаты в места согласно конфигу openvpn: \
`cp -rp /etc/openvpn/easy-rsa/pki/{ca.crt,dh.pem,ta.key,crl.pem,issued,private} /etc/openvpn/server/` \
![](https://github.com/vedoff/openvpn/blob/main/pict/Screenshot%20from%202022-03-29%2016-40-03.png)
### Все сертификаты появятся в папкe `/etc/openvpn/easy-rsa/pki` и ее подпапках.
Генерим сертификат для `clientserver openvpn` так же будет запрошен пароль от CA.key (123456) \
`./easyrsa build-client-full clientserv nopass` \
Создадим папку для клиента \
`mkdir /etc/openvpn/client/clientserv` \
Скопируем туда ключи и сертификаты
cp -rp /etc/openvpn/easy-rsa/pki/{ca.crt,issued/clientserv.crt,private/clientserv.key} /etc/openvpn/client/clientserv
