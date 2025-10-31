#Jesus Arellano Monitoreo de Clientes con altas peticiones TCP SYN

#Regla para el Filter Rules
/ip firewall filter
add action=add-src-to-address-list addresslist=clientes_altas_conexiones address-list-timeout=1h chain=forward comment="Clientes con Tasa de Conexiones Altas hacia Internet" connection-limit=500,32 in-interface=VLAN100 protocol=tcp tcp-flags=syn




# telegram_post_test.rsc con caracteres especiales
:local token "tu_token_aqui"
:local chatid "tu_chat_id_aqui"
:local lista "clientes_altas_conexiones"
:local mensaje "Clientes con alto consumo\n"

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
        :set mensaje ($mensaje . "✅ " . $comentario . " |  "  . $ip . "\n")
    } else={
        :set mensaje ($mensaje . "✅ AL: " . $ip . " | DHCP: - | Estado: - | MAC:  | comentario: -\n")
    }
}

# Escapar para JSON (backslash, comillas, saltos de línea)
:local jsonEscape do={
    :local s $1
    :local out ""
    :local lenS [:len $s]
    :for idx from=0 to=($lenS - 1) do={
        :local ch [:pick $s $idx ($idx + 1)]
        :if ($ch = "\\") do={ :set out ($out . "\\\\") } \
        else={
            :if ($ch = "\"") do={ :set out ($out . "\\\"") } \
            else={
                :if ($ch = "\n") do={ :set out ($out . "\\n") } \
                else={ :set out ($out . $ch) }
            }
        }
    }
    :return $out
}

:local escMsg [$jsonEscape $mensaje]
:local body ("{\"chat_id\":\"" . $chatid . "\",\"text\":\"" . $escMsg . "\"}")

# PRUEBA: guardamos la respuesta para inspección
/tool fetch url=("https://api.telegram.org/bot" . $token . "/sendMessage") http-method=post http-data=$body http-header-field="Content-Type: application/json" keep-result=yes dst-path=telegram_reply.json