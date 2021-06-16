let HpOmi
    : Type
    = { host : Text
      , port : ../Port/Type
      , severity_trigger : Text
      , resolve_status : List Text
      , team : Text
      , ssl_verify : Bool
      , xml_root_tag : Text
      , heartbeat :
          { timeout : ../Duration/Type
          , env_name : Text
          , hostname : Text
          , ipaddress : Text
          , extra_data : Text
          }
      }

let default =
      { severity_trigger = "Critical"
      , resolve_status = [ "closed", "ack", "blackout" ]
      , team = "Team_Name"
      , ssl_verify = True
      , xml_root_tag = "Alerta"
      , heartbeat = { timeout = ../Duration/Seconds 70, extra_data = "" }
      }

in  { Type = HpOmi, default }
