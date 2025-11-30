### Prepare Environment to bring up the 3-node Cluster

```
sudo -i

podman stop es01 es02 es03 2>/dev/null || true
podman rm -f es01 es02 es03 2>/dev/null || true
podman network rm elastic 2>/dev/null || true
podman system prune -a -f
```

```
podman network create elastic

sed -i 's/"cniVersion": "1.0.0"/"cniVersion": "0.4.0"/' /etc/cni/net.d/elastic.conflist 2>/dev/null || true
sed -i 's/"cniVersion": "1.0.0"/"cniVersion": "0.4.0"/' ~/.config/cni/net.d/elastic.conflist 2>/dev/null || true
```

### Deploy up the 3-node Cluster
```
podman run -d --name es01 \
  --net elastic \
  -p 9200:9200 \
  --ulimit memlock=-1:-1 \
  --ulimit nofile=65536:65536 \
  -e node.name=es01 \
  -e cluster.name=es-lab-cluster \
  -e discovery.seed_hosts=es02,es03 \
  -e cluster.initial_master_nodes=es01,es02,es03 \
  -e bootstrap.memory_lock=true \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  -e xpack.security.enabled=false \
  -e xpack.security.http.ssl.enabled=false \
  docker.elastic.co/elasticsearch/elasticsearch:8.15.3

podman run -d --name es02 \
  --net elastic \
  --ulimit memlock=-1:-1 \
  --ulimit nofile=65536:65536 \
  -e node.name=es02 \
  -e cluster.name=es-lab-cluster \
  -e discovery.seed_hosts=es01,es03 \
  -e cluster.initial_master_nodes=es01,es02,es03 \
  -e bootstrap.memory_lock=true \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  -e xpack.security.enabled=false \
  -e xpack.security.http.ssl.enabled=false \
  docker.elastic.co/elasticsearch/elasticsearch:8.15.3

podman run -d --name es03 \
  --net elastic \
  --ulimit memlock=-1:-1 \
  --ulimit nofile=65536:65536 \
  -e node.name=es03 \
  -e cluster.name=es-lab-cluster \
  -e discovery.seed_hosts=es01,es02 \
  -e cluster.initial_master_nodes=es01,es02,es03 \
  -e bootstrap.memory_lock=true \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  -e xpack.security.enabled=false \
  -e xpack.security.http.ssl.enabled=false \
  docker.elastic.co/elasticsearch/elasticsearch:8.15.3
```

### Install Java for the environment
```
apt install -y default-jre
```

### Download Diagnostic
```
curl -LO https://github.com/elastic/support-diagnostics/releases/download/v9.3.1/diagnostics-9.3.1-dist.zip

ls -lh diagnostics-9.3.1-dist.zip
unzip diagnostics-9.3.1-dist.zip
cd diagnostics-9.3.1

./diagnostics.sh --host 127.0.0.1 --port 9200
```
