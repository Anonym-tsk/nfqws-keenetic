# nfqws-keenetic

[![GitHub Release](https://img.shields.io/github/release/Anonym-tsk/nfqws-keenetic?style=flat&color=green)](https://github.com/Anonym-tsk/nfqws-keenetic/releases)
[![GitHub Stars](https://img.shields.io/github/stars/Anonym-tsk/nfqws-keenetic?style=flat)](https://github.com/Anonym-tsk/nfqws-keenetic/stargazers)
[![License](https://img.shields.io/github/license/Anonym-tsk/nfqws-keenetic.svg?style=flat&color=orange)](LICENSE)
[![CloudTips](https://img.shields.io/badge/donate-CloudTips-598bd7.svg?style=flat)](https://pay.cloudtips.ru/p/054d0666)
[![YooMoney](https://img.shields.io/badge/donate-YooMoney-8037fd.svg?style=flat)](https://yoomoney.ru/to/410019180291197)
[![Join Telegram group](https://img.shields.io/badge/Telegram_group-Join-blue.svg?style=social&logo=telegram)](https://t.me/nfqws)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Anonym-tsk/nfqws-keenetic)

Пакеты для установки `nfqws` на маршрутизаторы.

> [!CAUTION]
> Проект больше не получает обновления.
> 
> Все новые возможности будут появляться в новом [`nfqws2-keenetic`](https://github.com/nfqws/nfqws2-keenetic).

> [!IMPORTANT]
> Данный материал подготовлен в научно-технических целях.
> Использование предоставленных материалов в целях отличных от ознакомления может являться нарушением действующего законодательства.
> Автор не несет ответственности за неправомерное использование данного материала.

> [!WARNING]
> **Вы пользуетесь этой инструкцией на свой страх и риск!**
> 
> Автор не несёт ответственности за порчу оборудования и программного обеспечения, проблемы с доступом и потенцией.
> Подразумевается, что вы понимаете, что вы делаете.

Изначально написано для роутеров Keenetic/Netcraze с установленным entware.
Однако, работоспособность также была проверена на прошивках Padavan и OpenWRT (читайте ниже).

Списки проверенного оборудования собираем в [отдельной теме](https://github.com/Anonym-tsk/nfqws-keenetic/discussions/1).
<details>
  <summary>Собранный список моделей из темы</summary>
 
  - Билайн Smart Box GIGA
  - Билайн Smart Box Turbo
  - ASUS ROG Rapture GT-AX6000
  - ASUS RT-AC51U
  - ASUS RT-AC68U
  - ASUS RT-AC86U
  - ASUS RT-AX58U
  - ASUS RT-AX86U
  - ASUS RT-AX88U
  - ASUS RT-N16
  - ASUS RT-N56U
  - Cudy TR1200
  - Cudy TR3000
  - D-Link DIR-620/D/F1A
  - GL.iNet Flint 2 (GL-MT6000)
  - Zyxel Keenetic II
  - Zyxel Keenetic III
  - Zyxel Keenetic Giga II
  - Zyxel Keenetic Giga III
  - Zyxel Keenetic Extra
  - Zyxel Keenetic Extra II
  - Zyxel Keenetic Ultra
  - Zyxel Keenetic Ultra II
  - Keenetic Giga (KN-1010)
  - Keenetic Giga (KN-1011)
  - Keenetic Giga (KN-1012)
  - Keenetic 4G (KN-1212)
  - Keenetic Omni (KN-1410)
  - Keenetic Extra (KN-1710)
  - Keenetic Extra (KN-1711)
  - Keenetic Extra (KN-1713)
  - Keenetic Ultra (KN-1810)
  - Keenetic Ultra (KN-1811)
  - Keenetic Viva (KN-1910)
  - Keenetic Viva (KN-1912)
  - Keenetic Viva (KN-1913)
  - Keenetic DSL (KN-2010)
  - Keenetic Launcher DSL (KN-2012)
  - Keenetic Duo (KN-2110)
  - Keenetic Skipper DSL (KN-2112)
  - Keenetic Runner 4G (KN-2211)
  - Keenetic Hero 4G+ (KN-2311)
  - Keenetic Giga SE (KN-2410)
  - Keenetic Giant (KN-2610)
  - Keenetic Peak (KN-2710)
  - Keenetic Hopper DSL (KN-3610)
  - Keenetic Hopper (KN-3810)
  - Keenetic Hopper (KN-3811)
  - Keenetic Hopper SE (KN-3812)
  - MikroTik hEX S (RB760iGS)
  - MikroTik RB951G-2HnD
  - Mikrotik hAP ac lite (RB952Ui-5ac2nD)
  - TP-Link Archer C20
  - TP-Link Archer C6U
  - TP-Link WDR3500
  - Xiaomi Mi Router 3G
  - Xiaomi Mi Router 4
  - Xiaomi Mi Router 4A
  - Xiaomi Mi Router 4C
  - Xiaomi Mi Router Mini
  - Xiaomi Mi Router Pro
  - Xiaomi Mi Wi-Fi mini
  - Xiaomi Router AX3000T
  - Xiaomi Router Redmi AC2100

</details>

Поделиться опытом можно в разделе [Discussions](https://github.com/Anonym-tsk/nfqws-keenetic/discussions) или в [чате](https://t.me/nfqws).

### Что это?

`nfqws` - утилита для модификации TCP соединения на уровне пакетов, работает через обработчик очереди NFQUEUE и raw сокеты.

Почитать подробнее можно на [странице авторов](https://github.com/bol-van/zapret) (ищите по ключевому слову `nfqws`).

### Подготовка Keenetic/Netcraze

- Прочитайте инструкцию полностью, прежде, чем начать что-то делать!

- Рекомендуется игнорировать предложенные провайдером адреса DNS-серверов. Для этого в интерфейсе роутера отметьте пункты ["игнорировать DNS от провайдера"](https://help.keenetic.com/hc/ru/articles/360008609399) в настройках IPv4 и IPv6.
 
- Вместе с этим рекомендуется [настроить использование DoT/DoH](https://help.keenetic.com/hc/ru/articles/360007687159).

- Установить entware на маршрутизатор по инструкции [на встроенную память роутера](https://help.keenetic.com/hc/ru/articles/360021888880) или [на USB-накопитель](https://help.keenetic.com/hc/ru/articles/360021214160).

- Через web-интерфейс Keenetic/Netcraze установить пакет **Модули ядра подсистемы Netfilter** (**OPKG > Kernel modules for Netfilter**). На старых прошивках он доступен к установке только после выбора компонента **Протокол IPv6** (**Network functions > IPv6**).

- В разделе "Интернет-фильтры" отключить все сторонние фильтры (NextDNS, SkyDNS, Яндекс DNS и другие).

- Все дальнейшие команды выполняются не в cli роутера, а **в среде entware**. Подключиться в неё можно несколькими способами:
  - Через telnet: в терминале выполнить `telnet 192.168.1.1`, а потом `exec sh`.
  - Или же подключиться напрямую через SSH (логин - `root`, пароль по умолчанию - `keenetic`, порт - 222 или 22). Для этого в терминале написать `ssh 192.168.1.1 -l root -p 222`.

---

### Установка на Keenetic/Netcraze и другие системы с Entware

1. Установите необходимые зависимости
   ```bash
   opkg update
   opkg install ca-certificates wget-ssl
   opkg remove wget-nossl
   ```

2. Установите opkg-репозиторий в систему
   ```bash
   mkdir -p /opt/etc/opkg
   echo "src/gz nfqws-keenetic https://anonym-tsk.github.io/nfqws-keenetic/all" > /opt/etc/opkg/nfqws-keenetic.conf
   ```
   Репозиторий универсальный, поддерживаемые архитектуры: `mipsel`, `mips`, `mips64`, `aarch64`, `armv7`, `x86`, `x86_64`, `lexra`.

   <details>
     <summary>Или можете выбрать репозиторий под конкретную архитектуру</summary>

     - `mips-3.4` <sub><sup>Keenetic Giga SE (KN-2410), Ultra SE (KN-2510), DSL (KN-2010), Launcher DSL (KN-2012), Duo (KN-2110), Skipper DSL (KN-2112), Hopper DSL (KN-3610); Zyxel Keenetic DSL, LTE, VOX</sup></sub>
       ```bash
       mkdir -p /opt/etc/opkg
       echo "src/gz nfqws-keenetic https://anonym-tsk.github.io/nfqws-keenetic/mips" > /opt/etc/opkg/nfqws-keenetic.conf
       ```

     - `mipsel-3.4` <sub><sup>Keenetic 4G (KN-1212), Omni (KN-1410), Extra (KN-1710/1711/1713), Giga (KN-1010/1011), Ultra (KN-1810), Viva (KN-1910/1912/1913), Hero 4G (KN-2310/2311), Giant (KN-2610), Skipper 4G (KN-2910), Hopper (KN-3810); Zyxel Keenetic II / III, Extra, Extra II, Giga II / III, Omni, Omni II, Viva, Ultra, Ultra II</sup></sub>
       ```bash
       mkdir -p /opt/etc/opkg
       echo "src/gz nfqws-keenetic https://anonym-tsk.github.io/nfqws-keenetic/mipsel" > /opt/etc/opkg/nfqws-keenetic.conf
       ```

     - `aarch64-3.10` <sub><sup>Keenetic Peak (KN-2710), Ultra (KN-1811), Hopper (KN-3811), Hopper SE (KN-3812), Giga (KN-1012)</sup></sub>
       ```bash
       mkdir -p /opt/etc/opkg
       echo "src/gz nfqws-keenetic https://anonym-tsk.github.io/nfqws-keenetic/aarch64" > /opt/etc/opkg/nfqws-keenetic.conf
       ```
   </details>

3. Установите пакет
   ```bash
   opkg update
   opkg install nfqws-keenetic
   ```

4. [Установите веб-интерфейс](https://github.com/nfqws/nfqws-keenetic-web) (опционально)

##### Обновление

```bash
opkg update
opkg upgrade nfqws-keenetic
```

##### Удаление

```bash
opkg remove --autoremove nfqws-keenetic
```

##### Информация об установленной версии

```bash
opkg info nfqws-keenetic
```

### Политики доступа на Keenetic/Netcraze

На Keenetic/Netcraze можно создать политику доступа **NFQWS** (Приоритеты подключений – Политики доступа в интернет)
и после перезапуска nfqws-keenetic будет работать только для устройств из этой политики.<br/>
_Не забудьте поставить галочку на интерфейсе провайдера в созданной политике._

Можно сделать политику исключения, добавив в конфиг `POLICY_EXCLUDE=1`. Тогда будет обрабатываться трафик для всех устройств, кроме тех, что добавлены в политику `NFQWS`.<br/>
Имя политики можно изменить в конфиге, параметр `POLICY_NAME`.

Если политика с таким именем не найдена, будет обрабатываться весь трафик.

---

### Установка на OpenWRT

#### До версии 24.10 включительно, пакетный менеджер `opkg`

1. Установите необходимые зависимости
   ```bash
   opkg update
   opkg install ca-certificates wget-ssl
   opkg remove wget-nossl
   ```

2. Установите публичный ключ репозитория
   ```bash
   wget -O "/tmp/nfqws-keenetic.pub" "https://anonym-tsk.github.io/nfqws-keenetic/openwrt/nfqws-keenetic.pub"
   opkg-key add /tmp/nfqws-keenetic.pub
   ```

3. Установите репозиторий в систему
   ```bash
   echo "src/gz nfqws-keenetic https://anonym-tsk.github.io/nfqws-keenetic/openwrt" > /etc/opkg/nfqws-keenetic.conf
   ```
   Репозиторий универсальный, поддерживаемые архитектуры: `mipsel`, `mips`, `mips64`, `aarch64`, `armv7`, `x86`, `x86_64`, `lexra`.
   Для добавления поддержки новых устройств, [создайте Feature Request](https://github.com/Anonym-tsk/nfqws-keenetic/issues/new?template=feature_request.md&title=%5BFeature+request%5D+)

4. Установите пакет
   ```bash
   opkg update
   opkg install nfqws-keenetic
   ```

5. [Установите веб-интерфейс](https://github.com/nfqws/nfqws-keenetic-web) (опционально)

#### Версии 25.xx и Snapshot, пакетный менеджер `apk`

1. Установите необходимые зависимости
   ```bash
   apk --update-cache add ca-certificates wget-ssl
   apk del wget-nossl
   ```

2. Установите публичный ключ репозитория
   ```bash
   wget -O "/etc/apk/keys/nfqws-keenetic.pem" "https://anonym-tsk.github.io/nfqws-keenetic/openwrt/nfqws-keenetic.pem"
   ```

3. Установите репозиторий в систему
   ```bash
   echo "https://anonym-tsk.github.io/nfqws-keenetic/openwrt/packages.adb" > /etc/apk/repositories.d/nfqws-keenetic.list
   ```
   Репозиторий универсальный, поддерживаемые архитектуры: `mipsel`, `mips`, `mips64`, `aarch64`, `armv7`, `x86`, `x86_64`, `lexra`.
   Для добавления поддержки новых устройств, [создайте Feature Request](https://github.com/Anonym-tsk/nfqws-keenetic/issues/new?template=feature_request.md&title=%5BFeature+request%5D+)

4. Установите пакет
   ```bash
   apk --update-cache add nfqws-keenetic
   ```

5. [Установите веб-интерфейс](https://github.com/nfqws/nfqws-keenetic-web) (опционально)

> [!NOTE]
> NB: Все пути файлов, описанные в этой инструкции, начинающиеся с `/opt`, на OpenWRT будут начинаться с корня `/`.
> Например конфиг расположен в `/etc/nfqws/nfqws.conf`
> 
> Для запуска/остановки используйте команду `service nfqws-keenetic {start|stop|restart|reload|status}`

---

### Настройки

Файл настроек расположен по пути `/opt/etc/nfqws/nfqws.conf`. Для редактирования можно воспользоваться встроенным редактором `vi` или установить `nano`.

```bash
# Интерфейс провайдера. Обычно `eth3` или `eth2.2` для проводного соединения, и `ppp0` для PPPoE
# Заполняется автоматически при установке
# Можно ввести несколько интерфейсов, например ISP_INTERFACE="eth3 nwg1"
# Для поиска интерфейса можно воспользоваться командами `route` или `ifconfig`
ISP_INTERFACE="..."

# Стратегии обработки HTTPS и QUIC трафика
NFQWS_ARGS="..."
NFQWS_ARGS_QUIC="..."

# Стратегия обработки UDP трафика (не использует параметры из NFQWS_EXTRA_ARGS)
NFQWS_ARGS_UDP="..."

# Режим работы (auto, list, all)
NFQWS_EXTRA_ARGS="..."

# IP-списки
NFQWS_ARGS_IPSET="..."

# Дополнительные стратегии
NFQWS_ARGS_CUSTOM=""

# Обрабатывать ли IPv6 соединения
IPV6_ENABLED=0|1

# TCP порты для iptables
# Оставьте пустым, если нужно отключить обработку TCP
# Добавьте порт 80 для обработки HTTP (TCP_PORTS=443,80)
TCP_PORTS=443(,80)

# UDP порты для iptables
# Оставьте пустым, если нужно отключить обработку UDP
# Удалите порт 443, если не нужно обрабатывать QUIC
UDP_PORTS=443(,50000:50099)

# Политика доступа (только для Keenetic/Netcraze)
POLICY_NAME="nfqws"

# Режим работы политики доступа
# 0 - обрабатывается трафик только для устройств в политике
# 1 - обрабатывается трафик для всех устройств, кроме добавленных в политику
POLICY_EXCLUDE=0|1

# Логирование в Syslog
LOG_LEVEL=0|1
```

Стратегии применяются ко всем доменам из `user.list` и `auto.list`, за исключением доменов из `exclude.list`.<br/>
В конфиге есть 3 варианта параметра `NFQWS_EXTRA_ARGS` - это режим работы nfqws:
- В режиме `$MODE_LIST` будут обрабатываться только домены из файла `user.list`
- В режиме `$MODE_AUTO` кроме этого будут автоматически определяться недоступные домены и добавляться в список, по которому `nfqws` обрабатывает трафик. Домен будет добавлен, если за 60 секунд будет 3 раза определено, что ресурс недоступен
- В режиме `$MODE_ALL` будет обрабатываться весь трафик кроме доменов из списка `exclude.list`

Также, есть два IP-списка: `ipset.list` и `ipset_exclude.list`.
Адреса из списков применяются в любых режимах работы.

---

### Полезное

1. Конфиг-файл `/opt/etc/nfqws/nfqws.conf`
2. Скрипт запуска/остановки `/opt/etc/init.d/S51nfqws {start|stop|restart|reload|status}`
3. Вручную добавить домены в список можно в файле `/opt/etc/nfqws/user.list` (один домен на строке, поддомены учитываются автоматически)
4. Автоматически добавленные домены `/opt/etc/nfqws/auto.list`
5. Лог автоматически добавленных доменов `/opt/var/log/nfqws.log`
6. Домены-исключения `/opt/etc/nfqws/exclude.list` (один домен на строке, поддомены учитываются автоматически)
7. IP-список для обработки `ipset.list` (на каждой строчке ip или cidr ipv4, или ipv6)
8. IP-список для исключения `ipset_exclude.list`
9. Проверить, что нужные правила добавлены в таблицу маршрутизации `iptables-save | grep "queue-num 200"`
   > Вы должны увидеть похожие строки
   > ```
   > -A POSTROUTING -o eth3 -p tcp -m tcp --dport 443 -m connbytes --connbytes 1:6 --connbytes-mode packets --connbytes-dir original -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num 200 --queue-bypass
   > ```

### Если ничего не работает...

1. Если ваше устройство поддерживает аппаратное ускорение (flow offloading, hardware nat, hardware acceleration), то iptables могут не работать.
   При включенном offloading пакет не проходит по обычному пути netfilter.
   Необходимо или его отключить, или выборочно им управлять.
2. На Keenetic/Netcraze можно попробовать выключить или наоборот включить [сетевой ускоритель](https://help.keenetic.com/hc/ru/articles/214470905)
3. Возможно, стоит выключить службу классификации трафика IntelliQOS.
4. Можно попробовать отключить IPv6 на сетевом интерфейсе провайдера через веб-интерфейс маршрутизатора.
5. Можно попробовать запретить весь UDP трафик на 443 порт для отключения QUIC:
   > Межсетевой экран → Домашняя сеть → Добавить правило<br/>
   > Включить правило: Включено<br/>
   > Описание: Блокировать QUIC<br/>
   > Действие: Запретить<br/>
   > Протокол: UDP<br/>
   > Номер порта назначения: Равен 443<br/>
   > Остальные параметры оставляем без изменений

### Частые проблемы
1. `iptables: No chain/target/match by that name`<br/>
   Не установлен пакет "Модули ядра подсистемы Netfilter". На Keenetic/Netcraze он появляется в списке пакетов только после установки "Протокол IPv6"
2. `can't initialize ip6tables table` и/или `Perhaps ip6tables or your kernel needs to be upgraded`<br/>
   Не установлен пакет "Протокол IPv6". Также, проблема может появляться на старых прошивках 2.xx, выключите поддержку IPv6 в конфиге NFQWS
3. Ошибки вида `readlink: not found`, `dirname: not found`<br/>
   Обычно возникают не на кинетиках. Решение - установить busybox: `opkg install busybox` или отдельно пакеты `opkg install coreutils-readlink coreutils-dirname`
4. `Failed to download the package list from https://anonym-tsk.github.io/nfqws-keenetic/all/Packages.gz`<br/>
   Скорее всего не устеновлен пакет `wget-ssl`. Если вы уверены, что он установлен – переустановите его: `opkg install --force-reinstall wget-ssl`

### Как использовать несколько стратегий

Можно добавить дополнительные стратегии в опции `NFQWS_ARGS_CUSTOM` в конфиге и разделять их параметром `--new`.
Например, стратегия ниже применит опцию `--dpi-desync=fake,split2` для HTTPS запросов к доменам из `custom.list`,
а для HTTP запросов будет использовать `--dpi-desync=disorder2 --dpi-desync-fooling=md5sig,badseq`:
```bash
NFQWS_ARGS_CUSTOM="--filter-tcp=443 --dpi-desync=fake,split2 --hostlist=custom.list --new --filter-tcp=80 --dpi-desync=disorder2 --dpi-desync-fooling=md5sig,badseq"
```

### Как подобрать рабочую стратегию NFQWS

1. Запустить скрипт и следовать его инструкциям
   ```bash
   opkg install curl
   /bin/sh -c "$(curl -fsSL https://github.com/Anonym-tsk/nfqws-keenetic/raw/master/common/strategy.sh)"
   ```
   Подробнее можно почитать на [исходной странице](https://github.com/bol-van/zapret?tab=readme-ov-file#%D0%BF%D1%80%D0%BE%D0%B2%D0%B5%D1%80%D0%BA%D0%B0-%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D0%B0)

2. Найденную стратегию вписать в конфиге `/opt/etc/nfqws/nfqws.conf` в параметр `NFQWS_ARGS`

---

Нравится проект? Поддержи автора [здесь](https://yoomoney.ru/to/410019180291197) или [тут](https://pay.cloudtips.ru/p/054d0666). Купи ему немного :beers: или :coffee:!
