# rhce-training
## Состав:
2 ноды для работы (node-1, node-2)
1 керберос сервер (krbserver), который так же можно использовать для проверки задач с заблокированным доступом 

Провайдер: VitualBox

В файле Vagrantfile задан как переменная домен в котором прозодит работа, по умолчанию example.com
Сеть в которой проводится работа. По умолчанию 192.168.13.0/24
node-1 получает адрес с последним октетом в этой 21
node-2: 22
krbserver: 11 

На нодах подняты 2 дополнительных сетевых интерфейса (enp0s9, enp0s10) для задачи агрегирования интерфейсов
Во все сервера добавлены ключи на root в пользователе root
Скопировать krb.conf можно c krbserver
```
scp root@krbserver.rhce-training.ru:/etc/krb5.conf /etc
```
Добавить хост в принципалы 
```
echo ank -pw 1qaZXsw2 nfs/node-1.example.com | kadmin -w "1qaZXsw2"
```
Сгенерировать keytab на нодах выполнить команду после установки krb5-workstation
```
kadmin -w "1qaZXsw2" ktadd host/krbserver.rhce-training.ru 
```

В задачах с почтой можно использовать krbserver как relay сообщений.
Все сообщения сохраняются в папке  /var/archive/mail/new отдельными файлами.

## Установка:
1. Установить vagrant
2. Установить plugin 
```
vagrant plugin install vagrant-hostmanager
```
Для запуска виртуальной машины необходимо открыть командную строчку от имени администратора
Так как plugin vagrant-hostmanager добавляет вирутальные машины в файл hosts 
```
git clone https://github.com/greysd/rhce-training.git
cd rhce-training 
vagrant up
```
Зайти на машину по ssh
```
vagrant ssh krbserver
```