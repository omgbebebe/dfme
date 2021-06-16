let Map = (./Prelude.dhall).Map.Type

let Map/empty = (./Prelude.dhall).Map.empty

let DockerContainer =
      { name : Text
      , image : ./DockerImage/Type
      , envVars : List ./EnvVar/Type
      , mounts : List ./Mount/Type
      , ports : List ./DockerContainer/PortMapping/Type
      , egress : Map Text ./Egress/Type
      }

let default =
      { envVars = [] : List ./EnvVar/Type
      , mounts = [] : List ./Mount/Type
      , egress = Map/empty Text ./Egress/Type
      }

in  { Type = DockerContainer, default }
