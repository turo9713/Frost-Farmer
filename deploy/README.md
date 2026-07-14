# Production deployment

The server needs Docker Engine with the Compose plugin, a public IPv4/IPv6 address, and inbound TCP 80/443 (plus UDP 443 for HTTP/3). DNS for `DOMAIN` must resolve to the server before Caddy can issue the certificate.

```sh
sudo mkdir -p /opt/frost-farmer/{plugins,backups}
sudo chown -R "$USER" /opt/frost-farmer
cp deploy/* /opt/frost-farmer/
cd /opt/frost-farmer
cp .env.example .env
# edit .env and use a random PostgreSQL password
chmod +x *.sh
./deploy.sh
```

After creating the first admin in the dashboard, set `ALLOW_BOOTSTRAP_REGISTRATION=false` in `.env` and run `./deploy.sh` again.

Schedule encrypted/off-host backups. A basic daily local dump can be scheduled with:

```cron
15 3 * * * /opt/frost-farmer/backup.sh >> /var/log/frost-farmer-backup.log 2>&1
```

Local dumps alone are not disaster recovery; copy them to separate storage. Test restoration with `./restore.sh backups/name.dump` before launch.
