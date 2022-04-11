# openvpn
#### Настройка openvpn site-to-site client-to-site

1. Между двумя виртуалками поднять vpn в режимах `tun`/`tap`
2. [Поднять RAS на базе OpenVPN](https://github.com/vedoff/openvpn/blob/main/README.md#ras-server-%D0%B4%D0%BB%D1%8F-%D0%BE%D1%84%D0%B8%D1%81%D0%B0) с клиентскими сертификатами, подключиться с локальной машины на виртуалку.

# Выполнение:
### Между двумя виртуалками поднять vpn в режимах tun/tap
Поднимаем стенд: \
`vagrant up && ansible-playbook play.yml -t iovpn`
### Схема стенда
![](https://github.com/vedoff/openvpn/blob/main/pict/Screenshot%20from%202022-03-29%2015-18-58.png)

В результате будут развернуты машины согласно схеме и установленн на них openvpn, утилита easy-rsa (только на сервер), а также дополнительные утилиты.

## Далее пошаговое развертывание openvpn site-to-site:
Копируем утилиту easy-rsa в наш каталог openvpn \
`cp -r /usr/share/easy-rsa /etc/openvpn` \
Переходим по пути \
`cd /etc/openvpn/easy-rsa/` \
#### Инициализируем PKI 
`./easyrsa init-pki`\
#### Создаем корневой сертификат CA, в процессе будет запрошена установка пароля для удобства вводим (123456)
`./easyrsa build-ca` \
После генерации сертификат CA доступен в `/etc/openvpn/easy-rsa/pki/ca.crt` \
#### Генерим ключ ДефиХельмана: 
`./easyrsa gen-dh` \
После генерации доступен: \
`/etc/openvpn/easy-rsa/pki/dh.pem` \
#### Теперь генерим серверный сертификат и ключ в процессе будет запрошен пароль на CA.key (123456): 
`./easyrsa build-server-full server nopass` \
`nopass` - не устанавливать пароль на сертификат. \
#### Генерим TLS/SSL - защита от DoS атак и UDPпорт флудинга 
`openvpn --genkey secret /etc/openvpn/easy-rsa/pki/ta.key` \
#### Генерим сертификат отзыва: 
`./easyrsa gen-crl` \
Доступен по пути: \
`/etc/easy-rsa/pki/crl.pem` \
Добавьте в конец файла строку `crl-verify`. \
`vi /etc/openvpn/server/server.conf` \
`crl-verify crl.pem` \
Сервер OpenVPN будет проверять список отозванных сертификатов каждый раз, когда кто-то устанавливает соединение с сервером. 
### Все сертификаты появятся в папкe `/etc/openvpn/easy-rsa/pki` и ее подпапках.
![](https://github.com/vedoff/openvpn/blob/main/pict/Screenshot%20from%202022-03-29%2017-53-24.png)
### Копируем полученые сертификаты в места согласно конфигу openvpn: 
`cp -rp /etc/openvpn/easy-rsa/pki/{ca.crt,dh.pem,ta.key,crl.pem,issued,private} /etc/openvpn/server/` 

![](https://github.com/vedoff/openvpn/blob/main/pict/Screenshot%20from%202022-03-29%2016-40-03.png)

### Генерим сертификат для `clientserver openvpn (подобным образом генерятся сертификаты для ras)` 
Так же будет запрошен пароль от CA.key (123456): \
`./easyrsa build-client-full clientserv nopass` \
Создадим папку для клиента: \
`mkdir /etc/openvpn/client/clientserv` \
Скопируем туда ключи и сертификаты: \
cp -rp /etc/openvpn/easy-rsa/pki/{ca.crt,issued/clientserv.crt,private/clientserv.key} /etc/openvpn/client/clientserv
### Создадим конфиг `openvpn-server` [server.conf](https://github.com/vedoff/openvpn/blob/main/roles/ovpn/templates/server.conf.j2) 
Конфиг будет установлен на сервер путем копирования средствами `ansible` \
И настроена пересылка пакетов между интерфейсами: \
`net.ipv4.ip_forward=1 -> /etc/sysctl.conf` \
Выполняем: \
`ansible-playbook play.yml -t cserver` 

Запуск openvpn-server в консоле (при ручном конфигурировании): \
`systemctl enable --now openvpn-server@server`
### Сформируем конфиг из полученых сертификатов для `openvpn-client` [clientserv.conf](https://github.com/vedoff/openvpn/blob/main/roles/ovpn/templates/clientserv.conf.j2)
Конфиг будет установлен на сервер путем копирования средствами `ansible` \
И настроена пересылка пакетов между интерфейсами: \
`net.ipv4.ip_forward=1 -> /etc/sysctl.conf` \
Выполняем: \
`ansible-playbook play.yml -t cclient` 

Запуск openvpn-client в консоле (при ручном конфигурировании): \
`systemctl enable --now openvpn-client@clientserv`

Конфиг так же можно сформировать другим способом, просто скопировав на клиент сервер файлы ключей и сертификатов, добавив пути в соответствующие директивы в конфиге. \
[Пример конфига](https://github.com/vedoff/openvpn/blob/main/roles/ovpn/files/clientserv.conf.example)

# RAS server для офиса
Конфигурация RAS server уже заложена при разыертывании. \
Клиенты создаются так же как и для связывания офисов. \
`./easyrsa build-client-full client2 nopass` \
Клиенту прередается файл с настройками и сертификатами. \
Предпочтительнее испоьзовать upd tun протокол - меньше потерь при пересылке пакетов, а так же выше скорость передачи данных. \
TAP интерфейс удобен если требуется полная интеграция офисов, по тунелю передаются широковещательные пакеты, но это и нагружает сеть, создает много мусора в тунеле, как следствие потеря данных и сниженая скорость передачи.
## Отзыв клиентских сертификатов
Время от времени, вам может понадобиться отозвать клиентский сертификат для предотвращения доступа к серверу VPN \
Для этого зайдите в вашу директорию центра сертификации и введите команды: \
`cd /etc/openvpn/easyrsa`
`source vars` \
Далее используйте команду revoke с именем клиента, сертификат которого вы хотите отозвать: \
`./easyrsa revoke client1` \
![](https://github.com/vedoff/openvpn/blob/main/pict/Screenshot%20from%202022-04-11%2018-08-11.png)

Перезапустите OpenVPN для завершения процесса отзыва сертификата: \
`sudo systemctl restart openvpn-server@server`

Теперь клиент не сможет устанавливать соединение с сервером OpenVPN используя старый сертификат. \
Для отзыва дополнительных сертификатов выполните следующие шаги:
1. Сгенерируйте новый список отозванных сертификатов используя команду `source vars` и выполняя команду `revoke` с именем клиента.
2. Скопируйте новый список отозванных сертификатов в директорию /etc/openvpn/server перезаписав тем самым старый список.
3. Перезапустите сервис OpenVPN. 
    
Эта процедура может быть использована для отзыва любых созданных вами ранее сертификатов.
