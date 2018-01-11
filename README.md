# DockerBitrixDebian

Для сборки образа:
```sh
docker build -t masterofdeath/bitrix:first --no-cache .
```
Создадим свою docker-сеть:
```sh
docker network create my-docker-network --subnet=10.10.0.0/16
```

Скрипт создания контейнера:
```sh
#!/bin/sh

docker stop demo;
docker rm demo;

docker run -tid \
 -h demo.local \
 --name demo \
 --net=my-docker-network --ip=10.10.0.5 \
 -v /etc/localtime:/etc/localtime:ro \
 -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
 -v /home/user/Work/demo.local:/var/www/site1/ \
 masterofdeath/bitrix:first;
```


