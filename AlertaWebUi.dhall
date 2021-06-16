let AlertaWebUi =
      { name : Text
      , image : ./DockerImage/Type
      , port : ./Port/Type
      , server : { url : Text, port : ./Port/Type }
      }

let default = { name = "alerta-webui", port = ./Port/Tcp 8000 }

let renderConfigJson =
      λ(cfg : AlertaWebUi) →
        let JSON = (./Prelude.dhall).JSON

        in  JSON.render
              ( JSON.object
                  [ { mapKey = "endpoint"
                    , mapValue = JSON.string cfg.server.url
                    }
                  ]
              )

let mkDockerContainer =
      λ(cfg : AlertaWebUi) →
        let configJson =
              (./Mount/Type).ConfigFile
                { dst = "/usr/share/nginx/html/config.json"
                , content = renderConfigJson cfg
                }

        in  (./DockerContainer.dhall)::{
            , image = cfg.image
            , name = cfg.name
            , ports = [ ./DockerContainer/PortMapping/fromPort "ui" cfg.port ]
            , mounts = [ configJson ]
            }

in  { Type = AlertaWebUi, default, mkDockerContainer }
