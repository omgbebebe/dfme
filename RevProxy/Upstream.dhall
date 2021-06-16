let Upstream =
      { endpoints : List ./Upstream/Endpoint/Type, zone : Optional Text }

let default = { zone = None Text }

in  { Type = Upstream, default }
