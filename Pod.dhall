let Map = (./Prelude.dhall).Map.Type

let Map/empty = (./Prelude.dhall).Map.empty

let Pod
    : Type
    = { name : Text
      , containers : List { mapKey : Text, mapValue : ./DockerContainer/Type }
      , ingress : Map Text ./Port/Type
      , egress : Map Text ./Egress/Type
      , networkZone : ./NetworkZone/Type
      }

let default =
      { ingress = Map/empty Text ./Port/Type
      , egress = Map/empty Text ./Egress/Type
      }

in  { Type = Pod, default }
