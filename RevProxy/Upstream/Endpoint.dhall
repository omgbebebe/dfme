let Endpoint =
      { url : Text
      , weight : Natural
      , max_conns : Natural
      , healthcheck : Optional ./Endpoint/HealthCheckParams/Type
      , backup : Bool
      , down : Bool
      }

let default =
      { weight = 1
      , max_conns = 0
      , healthcheck = None ./Endpoint/HealthCheckParams/Type
      , backup = False
      , down = False
      }

in  { Type = Endpoint, default }
