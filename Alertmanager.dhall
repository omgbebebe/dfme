let Alertmanager
    : Type
    = { image : ./DockerImage/Type
      , port : ./Port/Type
      , alerta : { apiUrl : Text, apiKey : Text, apiPort : ./Port/Type }
      }

let default = { port = ./Port/Tcp 9093 }

let mkDockerContainer =
      λ(cfg : Alertmanager) →
        (./DockerContainer.dhall)::{
        , name = "alertmanager"
        , image = cfg.image
        , ports = [ ./DockerContainer/PortMapping/fromPort "api" cfg.port ]
        , egress = toMap
            { alerta-api =
              { zone = ./NetworkZone/Infra
              , destination =
                  "https://${cfg.alerta.apiUrl}:${./Port/textNumber
                                                    cfg.alerta.apiPort}/"
              , port = cfg.alerta.apiPort
              }
            }
        }

in  { Type = Alertmanager, default, mkDockerContainer }
