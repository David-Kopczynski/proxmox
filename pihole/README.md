To get Pi-Hole running you must:
1. `systemctl stop systemd-resolved.service`
2. `echo "DNSStubListener=no" >> /etc/systemd/resolved.conf`
3. `netplan apply`
4. `docker compose up`
5. `systemctl start systemd-resolved.service`

Checking the DNS is also possible with `cat /etc/resolv.conf`.
