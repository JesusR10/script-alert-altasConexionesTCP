#Jesus Arellano Monitoreo de Clientes con altas peticiones TCP SYN

#Regla para el Filter Rules
/ip firewall filter
add action=add-src-to-address-list addresslist=clientes_altas_conexiones address-list-timeout=1h chain=forward comment="Clientes con Tasa de Conexiones Altas hacia Internet" connection-limit=500,32 in-interface=VLAN100 protocol=tcp tcp-flags=syn



#Desarrollo de Script

:local listName "clientes_altas_conexiones"
:local count 0
:local now [/system clock get date]

:log info ("Inicio reporte address-list '" . $listName . "' - " . $now)

:foreach ip in=[/ip firewall address-list find where list=$listName] do={
  :local addr [/ip firewall address-list get $ip value-name=address]
  :if ([:len $addr] > 0) do={
    :set count ($count + 1)
    #:log info ("[IPv4] " . $addr)

    :local leaseId [/ip dhcp-server lease find where address=$addr]
    :if ([:len $leaseId] > 0) do={
      :local mac [/ip dhcp-server lease get $leaseId value-name=mac-address]
      :local host [/ip dhcp-server lease get $leaseId value-name=host-name]
      :local status [/ip dhcp-server lease get $leaseId value-name=status]
      :local comment [/ip dhcp-server lease get $leaseId value-name=comment]
      :local server [/ip dhcp-server lease get $leaseId value-name=server]

      :log info ($comment . " IP " . $addr . " encontrada: MAC=" . $mac . ", Host=" . $host . ", Estado=" . $status)
    } else={
      :log warning ("[DHCP] IP " . $addr . " NO existe en leases")
    }
  }
}

:log info ("Total entradas procesadas en " . $listName . ": " . $count)