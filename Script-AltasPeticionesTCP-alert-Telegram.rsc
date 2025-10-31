#Jesus Arellano Monitoreo de Clientes con altas peticiones TCP SYN

#Regla para el Filter Rules
/ip firewall filter
add action=add-src-to-address-list addresslist=clientes_altas_conexiones address-list-timeout=1h chain=forward comment="Clientes con Tasa de Conexiones Altas hacia Internet" connection-limit=500,32 in-interface=VLAN100 protocol=tcp tcp-flags=syn



#Desarrollo de Script
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







#script para enviar alerta por Telegram de clientes con altas peticiones TCP SYN
:local token "tu_token_aqui"
:local chatid "tu_chat_id_aqui"
:local lista "clientes_altas_conexiones"
:local mensaje "Clientes con alto consumo%0A"

:foreach i in=[/ip firewall address-list find list=$lista] do={
    :local ip [/ip firewall address-list get $i address]
    :local dhcpip ""
    :local status ""
    :local mac ""
    :local comentario ""

    :foreach j in=[/ip dhcp-server lease find address=$ip] do={
        :set dhcpip [/ip dhcp-server lease get $j address]
        :set status [/ip dhcp-server lease get $j status]
        :set mac [/ip dhcp-server lease get $j mac-address]
        :set comentario [/ip dhcp-server lease get $j comment]
    }

    :if ($dhcpip != "") do={
        :set mensaje ($mensaje . "✅ " . $comentario . " |  "  . $ip . "%0A")
        #:set mensaje ($mensaje . "✅ AL: " . $ip . " | DHCP: " . $dhcpip . " | Estado: " . $status . " | MAC: " . $mac . " | comentario: " . $comentario . "%0A")
    } else={
        :set mensaje ($mensaje . "✅ AL: " . $ip . " | DHCP: - | Estado: - | MAC:  | comentario: -%0A")
    }
}

:local url ("https://api.telegram.org/bot" . $token . "/sendMessage?chat_id=" . $chatid . "&text=" . $mensaje)








