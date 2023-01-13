# Exemple de programme spark avec docker-compose

## Installer docker

Prendre docker [https://docs.docker.com/desktop/install/windows-install/]()  et l'installerr en activant le support de wsl2.
Podman ne peut être utilisé car des problèmes survienne en version 3 sur Ubuntu 22.04LTS dans wsl2.

## Compilation

Dans le détail, cela donne :

~~~bash
mpatron@ITEM-S76640:~/sparkin$ docker build -t cluster-apache-spark:3.3.1 .
mpatron@ITEM-S76640:~/sparkin$ docker login docker.io
mpatron@ITEM-S76640:~/sparkin$ # Sous docker :
mpatron@ITEM-S76640:~/sparkin$ docker image tag cluster-apache-spark:3.3.1 docker.io/mpatron/cluster-apache-spark:3.3.1
mpatron@ITEM-S76640:~/sparkin$ docker image push docker.io/mpatron/cluster-apache-spark:3.3.1
Getting image source signatures
Copying blob 4b0596bdbd24 done
Copying blob 764055ebc9a7 skipped: already exists
Copying blob 24d477f8e4dc skipped: already exists
Copying blob aa7d6f60014a [--------------------------------------] 0.0b / 0.0b
Copying blob 2fd6f7b9077a skipped: already exists
Copying blob 00406a50f84a done
Copying blob 10bc57e32cfa done
Copying blob 15b3782e5154 done
Copying blob 601a6011cc07 [===========================>----------] 213.0MiB / 285.5MiB
Copying blob 50e7ab6b2354 [===>----------------------------------] 37.0MiB / 322.0MiB
Copying blob 702737f78186 [=====>--------------------------------] 109.0MiB / 675.6MiB
Copying blob 48ed9df7486c done
Writing manifest to image destination
Storing signatures
~~~

ou en rapide

~~~bash
docker build -t cluster-apache-spark:3.3.1 . && docker image tag localhost/cluster-apache-spark:3.3.1 docker.io/mpatron/cluster-apache-spark:3.3.1 && docker image push docker.io/mpatron/cluster-apache-spark:3.3.1
~~~

Puis lancement

~~~bash
docker-compose up
~~~

## Obtention de la console spark-shell

~~~bash
mpatron@ITEM-S76640:~/sparkin$ docker exec -it sparkin-spark-master-1 /opt/spark/bin/spark-shell
# ou
mpatron@ITEM-S76640:~/sparkin$ docker-compose exec spark-master bash
~~~

## Lancement d'un spark submit

~~~bash
mpatron@ITEM-S76640:~/sparkin$ docker exec -it sparkin-spark-master-1 /bin/bash
root@79072297a622:/opt/spark# /opt/spark/bin/spark-submit --master spark://spark-master:7077 --jars /opt/spark-apps/postgresql-42.2.22.jar --driver-memory 1G --executor-memory 1G /opt/spark-apps/main.py
~~~

Le répertoire /opt/spark-data du docker est mappé sur le répertoire sparkin/data dans le wsl2.

Pour tester postgreSQL prendre [https://www.pgadmin.org/download/]().

## Dans le futur avec podman

~~~bash
echo "unqualified-search-registries = ['registry.fedoraproject.org', 'registry.access.redhat.com', 'registry.centos.org', 'docker.io']" | sudo tee -a /etc/containers/registries.conf
export DOCKER_HOST="unix:$XDG_RUNTIME_DIR/podman/podman.sock"
~~~

Attention il y a du bug dans l'air, sous podman :

~~~bash
mpatron@ITEM-S76640:~/sparkin$ podman image tag localhost/cluster-apache-spark:3.3.1 docker.io/mpatron/cluster-apache-spark:3.3.1
~~~

Alors que sous docker c'est :

~~~bash
mpatron@ITEM-S76640:~/sparkin$ docker image tag cluster-apache-spark:3.3.1 docker.io/mpatron/cluster-apache-spark:3.3.1
~~~

## Encore plus de donnée...

Il y du plus gros volume de donnée sur [http://web.mta.info/developers/MTA-Bus-Time-historical-data.html](). Et téléchargeable par bash en faisant :

~~~bash
curl -OL -o /opt/spark-data/MTA_2014_08_01.csv.xz http://s3.amazonaws.com/MTABusTime/AppQuest3/MTA-Bus-Time_.2014-08-01.txt.xz
xz -d /opt/spark-data/MTA_2014_08_01.csv.xz
~~~

Ne pas oublier de mettre le driver postgresql dans le spark submit

~~~bash
/opt/spark/bin/spark-submit --master spark://spark-master:7077 --jars /opt/spark-apps/postgresql-42.2.22.jar --driver-memory 1G --executor-memory 1G /opt/spark-apps/main.py
~~~

## Retoyage

~~~bash
#Install docker
docker kill $(docker ps -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
docker image prune --all --force
docker container prune --force
docker volume prune --force
docker network prune --force
docker system prune --all --force
~~~

## Sources

- [https://dev.to/mvillarrealb/creating-a-spark-standalone-cluster-with-docker-and-docker-compose-2021-update-6l4]()
- [https://github.com/mvillarrealb/docker-spark-cluster]()
