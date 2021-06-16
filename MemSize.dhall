let MemSize =
      < B : Natural | K : Natural | M : Natural | G : Natural | T : Natural >

let asText =
      λ(m : MemSize) →
        let text =
              λ(postfix : Text) → λ(n : Natural) → Natural/show n ++ postfix

        in  merge
              { B = text ""
              , K = text "K"
              , M = text "M"
              , G = text "G"
              , T = text "T"
              }
              m

in  { Type = MemSize, asText }
