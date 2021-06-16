let MongoDb =
      { image : ./DockerImage/Type
      , admin_username : Text
      , admin_password : Text
      , port : ./Port/Type
      }

let default = { admin_username = "mongoadmin", port = ./Port/Tcp 27017 }

let mkDockerContainer =
      λ(cfg : MongoDb) →
        (./DockerContainer.dhall)::{
        , name = "mongodb"
        , image = cfg.image
        , ports = [ ./DockerContainer/PortMapping/fromPort "api" cfg.port ]
        , envVars = toMap
            { MONGO_INITDB_ROOT_USERNAME = cfg.admin_username
            , MONGO_INITDB_ROOT_PASSWORD = cfg.admin_password
            }
        }

in  { Type = MongoDb, default, mkDockerContainer }
