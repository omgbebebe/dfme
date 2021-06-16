let Workload
    : Type
    = { name : Text, pods : List ./Pod/Type }

in  { Type = Workload, default = {=} }
