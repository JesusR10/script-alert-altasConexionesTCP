# script-alert-altasConexionesTCP
Script para Mikrotik probado en de routerOS v7.20.2

El script de esta rama tiene un filer en firewall que enviar para un address-list llamado "clientes_altas_conexiones" 

Luego capturo ese nombre "clientes_altas_conexiones" en una variable que me permita posteriormente comparar las IPs de los "clientes_altas_conexiones" con las IPs del dhcp-server lease y traerme los comentarios de esas mismas IPs, asi emviar un chat de telegram desde el mikrotik que muestre las IPs de "clientes_altas_conexiones" junto con el commment del DHCP-SERVER
