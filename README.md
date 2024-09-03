# nfqws-keenetic

Скрипты для установки `nfqws` на маршрутизаторы с поддержкой `opkg`.

> **Вы пользуетесь этой инструкцией на свой страх и риск!**
> 
> Автор не несёт ответственности за порчу оборудования и программного обеспечения, проблемы с доступом и потенцией.
> Подразумевается, что вы понимаете, что вы делаете.

Предназначено для роутеров Keenetic с установленным на них entware, а так же для любой системы с opkg пакетами, у которых система расположена в каталоге /opt/.

Проверено на маршрутизаторах:

- Keenetic Giga (KN-1011)
- Keenetic Ultra (KN-1811)
- Keenetic Ultra (KN-1810)
- Keenetic Extra (KN-1710)
- Keenetic Hopper (KN-3810)
- Keenetic Viva (KN-1910)
- Keenetic Omni (KN-1410)
- Keenetic Giant (KN-2610)

Списки проверенного оборудования собираем в [отдельной теме](https://github.com/Anonym-tsk/nfqws-keenetic/discussions/1).

Поделиться опытом можно в разделе [Discussions](https://github.com/Anonym-tsk/nfqws-keenetic/discussions) или в [чате](https://t.me/nfqws).

Если nfqws работает как-то не так, можете попробовать [tpws](https://github.com/Anonym-tsk/tpws-keenetic).

### Что это?

`nfqws` - утилита для модификации TCP соединения на уровне пакетов, работает через обработчик очереди NFQUEUE и raw сокеты.

Почитать подробнее можно на [странице авторов](https://github.com/bol-van/zapret) (ищите по ключевому слову `nfqws`).

### Подготовка

- Рекомендуется игнорировать предложенные провайдером адреса DNS-серверов. Для этого в интерфейсе роутера отметьте пункты ["игнорировать DNS от провайдера"](https://help.keenetic.com/hc/ru/articles/360008609399) в настройках IPv4 и IPv6.
 
- Вместе с этим рекомендуется [настроить использование DoT/DoH](https://help.keenetic.com/hc/ru/articles/360007687159).

- Установить entware на маршрутизатор по инструкции [на встроенную память роутера](https://help.keenetic.com/hc/ru/articles/360021888880) или [на USB-накопитель](https://help.keenetic.com/hc/ru/articles/360021214160).

- Через web-интерфейс Keenetic установить пакеты **Протокол IPv6** (**Network functions > IPv6**) и **Модули ядра подсистемы Netfilter** (**OPKG > Kernel modules for Netfilter** - не путать с "Netflow"). Обратите внимание, что второй компонент отобразится в списке пакетов только после того, как вы отметите к установке первый.

- В разделе "Интернет-фильтры" отключить все сторонние фильтры (NextDNS, SkyDNS, Яндекс DNS и другие).

- Все дальнейшие команды выполняются не в cli роутера, а **в среде entware**. Переключиться в неё из cli можно командой `exec sh`; или же подключиться напрямую через SSH (логин - `root`, пароль по умолчанию - `keenetic`, порт - 222).

### Автоматическая установка (рекомендуется)

```
opkg install curl
/bin/sh -c "$(curl -fsSL https://github.com/Anonym-tsk/nfqws-keenetic/raw/master/netinstall.sh)"
```

**Следуйте инструкции установщика:**

1. Выберите архитектуру маршрутизатора `mipsel`, `mips`, `aarch64` или `arm`
> Для моделей Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912), Hero 4G (KN-2310), Hero 4G+ (KN-2311), Giant (KN-2610), Skipper 4G (KN-2910), Hopper (KN-3810) используйте архитектуру `mipsel`
>
> Для моделей Giga SE (KN-2410), Ultra SE (KN-2510), DSL (KN-2010), Launcher DSL (KN-2012), Duo (KN-2110), Skipper DSL (KN-2112), Hopper DSL (KN-3610) используйте архитектуру `mips`
>
> Для моделей Peak (KN-2710), Ultra (KN-1811), Hopper SE (KN-3812) используйте архитектуру `aarch64`
> 
> Для других устройств доступен вариант `arm`
2. Введите сетевой интерфейс провайдера, обычно это `eth3`. Если ваш провайдер использует PPPoE, ваш интерфейс, скорее всего, `ppp0`.
> Можно указать несколько интерфейсов через пробел (`eth3 nwg1`), например, если вы подключены к нескольким провайдерам
3. Выберите режим работы `auto`, `list` или `all`
> В режиме `list` будут обрабатываться только домены из файла `/opt/etc/nfqws/user.list` (один домен на строку)
>
> В режиме `auto` кроме этого будут автоматически определяться недоступные домены и добавляться в список, по которому `nfqws` обрабатывает трафик. Домен будет добавлен, если за 60 секунд будет 3 раза определено, что ресурс недоступен
>
> В режиме `all` будет обрабатываться весь трафик кроме доменов из списка `/opt/etc/nfqws/exclude.list`
4. Укажите, нужна ли поддержка IPv6
> Если не уверены, лучше не отключайте и оставьте как есть

##### Обновление

Просто запустите установщик еще раз, следуйте инструкциям

```
/bin/sh -c "$(curl -fsSL https://github.com/Anonym-tsk/nfqws-keenetic/raw/master/netinstall.sh)"
```

##### Автоматическое удаление

```
/bin/sh -c "$(curl -fsSL https://github.com/Anonym-tsk/nfqws-keenetic/raw/master/netuninstall.sh)"
```

### Ручная установка (не рекомендуется, если entware установлен во внутреннюю память)

```
opkg install git git-http curl
git clone https://github.com/Anonym-tsk/nfqws-keenetic.git --depth 1
chmod +x ./nfqws-keenetic/*.sh
./nfqws-keenetic/install.sh
```

##### Обновление

```
cd nfqws-keenetic
git pull --depth=1
./install.sh
```

##### Удаление

```
./nfqws-keenetic/uninstall.sh
```

### Полезное

1. Конфиг-файл `/opt/etc/nfqws/nfqws.conf`
2. Скрипт запуска/остановки `/opt/etc/init.d/S51nfqws {start|stop|restart|reload|status|version}`
3. Вручную добавить домены в список можно в файле `/opt/etc/nfqws/user.list` (один домен на строке, поддомены учитываются автоматически)
4. Автоматически добавленные домены `/opt/etc/nfqws/auto.list`
5. Лог автоматически добавленных доменов `/opt/var/log/nfqws.log`
6. Домены-исключения `/opt/etc/nfqws/exclude.list` (один домен на строке, поддомены учитываются автоматически)
7. Проверить, что нужные правила добавлены в таблицу маршрутизации `iptables-save | grep "queue-num 200"`
> Вы должны увидеть похожие строки (по 2 на каждый выбранный сетевой интерфейс)
> ```
> -A POSTROUTING -o eth3 -p tcp -m tcp --dport 443 -m connbytes --connbytes 1:6 --connbytes-mode packets --connbytes-dir original -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num 200 --queue-bypass
> ```

### Если ничего не работает...

1. Если ваше устройство поддерживает аппаратное ускорение (flow offloading, hardware nat, hardware acceleration), то iptables могут не работать.
При включенном offloading пакет не проходит по обычному пути netfilter.
Необходимо или его отключить, или выборочно им управлять.
2. На Keenetic можно попробовать выключить или наоборот включить [сетевой ускоритель](https://help.keenetic.com/hc/ru/articles/214470905)
3. Возможно, стоит выключить службу классификации трафика IntelliQOS.
4. Можно попробовать отключить IPv6 на сетевом интерфейсе провайдера через веб-интерфейс маршрутизатора.
5. Можно попробовать запретить весь UDP трафик на 443 порт для отключения QUIC:
```
iptables -I FORWARD -i br0 -p udp --dport 443 -j DROP
```
6. Попробовать разные варианты аргументов nfqws. Для этого в конфиге `/opt/etc/nfqws/nfqws.conf` есть несколько заготовок `NFQWS_ARGS`.

### Частые проблемы
1. `iptables: No chain/target/match by that name`

    Не установлен пакет "Модули ядра подсистемы Netfilter". На Keenetic он появляется в списке пакетов только после установки "Протокол IPv6"
2. `can't initialize ip6tables table` и/или `Perhaps ip6tables or your kernel needs to be upgraded`

    Не установлен пакет "Протокол IPv6". Также, проблема может появляться на старых прошивках 2.xx, выключите поддержку IPv6 в конфиге NFQWS
3. Ошибки вида `readlink: not found`, `dirname: not found`

   Обычно возникают не на кинетиках. Решение - установить busybox: `opkg install busybox` или отдельно пакеты `opkg install coreutils-readlink coreutils-dirname`

---

Нравится проект? [Поддержи автора](https://yoomoney.ru/to/410019180291197)! Купи ему немного :beers: или :coffee:!
