let AlertaService =
        ./Service/Type
      ⩓ { server : ./AlertaServer/Type
        , webUi : ./AlertaWebUi/Type
        , mongoDb : ./MongoDb/Type
        }

let meta =
      { title = "Alerta"
      , description =
          "The alerta monitoring system is a tool used to consolidate and de-duplicate alerts from multiple sources for quick ‘at-a-glance’ visualisation. With just one system you can monitor alerts from many other monitoring tools on a single screen."
      , homepage = Some "https://alerta.io/"
      , sources = Some "https://github.com/alerta"
      }

let default =
      { name = "alerta"
      , server = ./AlertaServer/default
      , webUi = ./AlertaWebUi/default
      , mongoDb = ./MongoDb/default
      , meta
      }

let mkServerPod =
      λ(cfg : ./AlertaServer/Type) →
        let container = ./AlertaServer/mkDockerContainer cfg

        in  (./Pod.dhall)::{
            , name = "alerta-server"
            , networkZone = ./NetworkZone/Infra
            , containers = toMap { server = container }
            , ingress = toMap { api = cfg.port }
            , egress = container.egress
            }

let mkWebUiPod =
      λ(cfg : ./AlertaWebUi/Type) →
        (./Pod.dhall)::{
        , name = "alerta-webui"
        , networkZone = ./NetworkZone/Infra
        , containers = toMap { server = ./AlertaWebUi/mkDockerContainer cfg }
        , ingress = toMap { api = cfg.port }
        , egress = toMap
            { api =
              { zone = ./NetworkZone/Infra
              , destination = cfg.server.url
              , port = cfg.server.port
              }
            }
        }

let mkMongoDbPod =
      λ(cfg : ./MongoDb/Type) →
        (./Pod.dhall)::{
        , name = "alerta-mongodb"
        , networkZone = ./NetworkZone/Infra
        , containers = toMap { server = ./MongoDb/mkDockerContainer cfg }
        , ingress = toMap { api = cfg.port }
        }

let mkWorkload =
      λ(cfg : AlertaService) →
        (./Workload.dhall)::{
        , name = "alerta"
        , pods =
          [ mkServerPod cfg.server
          , mkWebUiPod cfg.webUi
          , mkMongoDbPod cfg.mongoDb
          ]
        }

in  { Type = AlertaService, default, mkWorkload }
