let DockerRegistry =
        ./Service/Type
      ⩓ { image : ./DockerImage/Type
        , port : ./Port/Type
        , storage :
            { path : Text
            , health :
                { enabled : Bool
                , interval : ./Duration/Type
                , threshold : Natural
                }
            }
        , proxy : { url : Text }
        }

let meta =
      { title = "Docker Registry"
      , description =
          "The Registry is a stateless, highly scalable server side application that stores and lets you distribute Docker images."
      , homepage = Some "https://docs.docker.com/registry/"
      , sources = Some "https://github.com/docker/distribution-library-image"
      }

let default =
      { name = "docker-registry"
      , port = ./Port/Tcp 5000
      , storage =
        { path = "/var/lib/registry"
        , health =
          { enabled = True, interval = ./Duration/Seconds 10, threshold = 3 }
        }
      , meta
      }

let Bool/show = (./Prelude.dhall).Bool.show

let renderConfig =
      λ(cfg : DockerRegistry) →
        ''
        version: 0.1
        log:
          fields:
            service: registry
        storage:
          cache:
            blobdescriptor: inmemory
          filesystem:
            rootdirectory: ${cfg.storage.path}
        http:
          addr: :${./Port/textNumber cfg.port}
          headers:
            X-Content-Type-Options: [nosniff]
        health:
          storagedriver:
            enabled: ${Bool/show cfg.storage.health.enabled}
            interval: ${./Duration/asText cfg.storage.health.interval}
            threshold: ${Natural/show cfg.storage.health.threshold}
        proxy:
             remoteurl: ${cfg.proxy.url}
        ''

let mkDockerContainer =
      λ(cfg : DockerRegistry) →
        let DockerContainer = ./DockerContainer.dhall

        let nginx_conf =
              (./Mount/Type).ConfigFile
                { dst = "/etc/docker-registry/config.yaml"
                , content = renderConfig cfg
                }

        let mounts = [ nginx_conf ]

        let ports = [ ./DockerContainer/PortMapping/fromPort "api" cfg.port ]

        in  DockerContainer::{
            , name = "docker-registry"
            , image = cfg.image
            , mounts
            , ports
            }

let mkPod =
      λ(cfg : DockerRegistry) →
        let container = mkDockerContainer cfg

        in  (./Pod.dhall)::{
            , name = "docker-registry"
            , networkZone = ./NetworkZone/Infra
            , containers = toMap { docker-registry = container }
            , ingress = toMap { api = cfg.port }
            , egress = container.egress
            }

let mkWorkload =
      λ(cfg : DockerRegistry) →
        (./Workload.dhall)::{ name = "docker-registry", pods = [ mkPod cfg ] }

in  { Type = DockerRegistry, default, mkWorkload }
