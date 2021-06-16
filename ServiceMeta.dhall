let ServiceMeta =
      { title : Text
      , description : Text
      , homepage : Optional Text
      , sources : Optional Text
      , owner : ./Person/Type
      }

let default = { homepage = None Text, sources = None Text }

in  { Type = ServiceMeta, default }
