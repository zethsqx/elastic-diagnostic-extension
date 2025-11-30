### Install Java

```
apt install -y default-jre
```

```
curl -LO https://github.com/elastic/support-diagnostics/releases/download/v9.3.1/diagnostics-9.3.1-dist.zip

ls -lh diagnostics-9.3.1-dist.zip
unzip diagnostics-9.3.1-dist.zip
cd diagnostics-9.3.1

./diagnostics.sh --host 127.0.0.1 --port 9200
```
