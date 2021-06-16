let Pair = { name : Text, int : Natural, ext : Natural }

let PortMapping = < Tcp : Pair | Udp : Pair >

let asPair =
    {-| port type will be lost -}
      λ(pm : PortMapping) →
        merge { Tcp = λ(n : Pair) → n, Udp = λ(n : Pair) → n } pm

let asText =
      λ(pm : PortMapping) →
        let pairAsText =
              λ(t : Text) →
              λ(p : Pair) →
                "${Natural/show p.ext}/${t}:${Natural/show p.int}/${t}"

        in  merge
              { Tcp = λ(n : Pair) → pairAsText "tcp" n
              , Udp = λ(n : Pair) → pairAsText "udp" n
              }
              pm

let fromPort =
      λ(name : Text) →
      λ(p : ../Port/Type) →
        merge
          { Tcp = λ(n : Natural) → PortMapping.Tcp { name, int = n, ext = n }
          , Udp = λ(n : Natural) → PortMapping.Udp { name, int = n, ext = n }
          }
          p

in  { Type = PortMapping, asPair, asText, fromPort }
