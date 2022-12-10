https://dev.to/mvillarrealb/creating-a-spark-standalone-cluster-with-docker-and-docker-compose-2021-update-6l4

echo "unqualified-search-registries = ['registry.fedoraproject.org', 'registry.access.redhat.com', 'registry.centos.org', 'docker.io']" | sudo tee -a /etc/containers/registries.conf
export DOCKER_HOST="unix:$XDG_RUNTIME_DIR/podman/podman.sock"

mpatron@ITEM-S76640:~/sparkin$ docker build -t cluster-apache-spark:3.3.1 .
mpatron@ITEM-S76640:~/sparkin$ podman login docker.io
mpatron@ITEM-S76640:~/sparkin$ podman image tag localhost/cluster-apache-spark:3.3.1 docker.io/mpatron/cluster-apache-spark:3.3.1
mpatron@ITEM-S76640:~/sparkin$ podman image push docker.io/mpatron/cluster-apache-spark:3.3.1
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

docker build -t cluster-apache-spark:3.3.1 . && podman image tag localhost/cluster-apache-spark:3.3.1 docker.io/mpatron/cluster-apache-spark:3.3.1 && podman image push docker.io/mpatron/cluster-apache-spark:3.3.1


mpatron@ITEM-S76640:~/sparkin$ sudo podman exec -it sparkin_spark-worker-a_1 /bin/bash
