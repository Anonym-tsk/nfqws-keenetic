---
name: Bug report
about: Create a report to help us improve
title: "[BUG] "
labels: ''
assignees: ''

---

**Опишите проблему**
Подробно опишите что делали и что не работает.

**Модель маршрутизатора**
Укажите полную модель роутера и прошивку

**Провайдер**
Укажите вашего провайдера и тип подключения (ppp/ethernet/...)

**Выполните команды и приложите их вывод**
`cat /opt/etc/nfqws/nfqws.conf`
```
<ВСТАВИТЬ СЮДА>
```

`ps | grep nfqws`
```
<ВСТАВИТЬ СЮДА>
```

`iptables-save | grep 200`
```
<ВСТАВИТЬ СЮДА>
```

`sysctl net.netfilter.nf_conntrack_checksum`
```
<ВСТАВИТЬ СЮДА>
```
