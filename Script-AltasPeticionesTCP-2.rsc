



:local addressLis "clientes_altas_conexiones"
:local contador 0
:local now [/system clock get date]

:log info ("Inicio reporte address-list '" . $addressLis . "' - " . $now)

:foreach ip in=[/ip firewall address-list find where list=$addressLis] do={
  :local ipFirewall [/ip firewall address-list get $ip value-name=address]
  :if ([:len $ipFirewall] > 0) do={
    :set contador ($contador + 1)
    #:log info ("[IPv4] " . $ipFirewall)

    :local ipDHCP [/ip dhcp-server lease find where address=$ipFirewall]
    :if ([:len $ipDHCP] > 0) do={
      :local mac [/ip dhcp-server lease get $ipDHCP value-name=mac-address]
      :local host [/ip dhcp-server lease get $ipDHCP value-name=host-name]
      :local status [/ip dhcp-server lease get $ipDHCP value-name=status]
      :local comment [/ip dhcp-server lease get $ipDHCP value-name=comment]
      :local server [/ip dhcp-server lease get $ipDHCP value-name=server]

      :log info ($comment . " IP " . $ipFirewall . " encontrada: MAC=" . $mac . ", Host=" . $host . ", Estado=" . $status)
    } else={
      :log warning ("[DHCP] IP " . $ipFirewall . " NO existe en leases")
    }
  }
}

:log info ("Total entradas procesadas en " . $addressLis . ": " . $contador)