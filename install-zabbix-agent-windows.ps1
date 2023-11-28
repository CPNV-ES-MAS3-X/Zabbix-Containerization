$uri = "https://cdn.zabbix.com/zabbix/binaries/stable/6.0/6.0.18/zabbix_agent-6.0.18-windows-amd64-openssl.msi"
$out = "C:\zabbix_agent.msi"

Invoke-WebRequest -uri $uri -OutFile $out

Start-Process C:\zabbix_agent.msi
