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
`/etc/openvpn/easy-rsa/pki/dh.pem`



Все сертификаты появятся в папкe `/etc/openvpn/easy-rsa/pki` и ее подпапках.
