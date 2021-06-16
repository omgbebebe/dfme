let JavaOpts =
      { xmx : ./MemSize/Type
      , xms : ./MemSize/Type
      , gc_path : Optional Text
      , extra : Optional Text
      }

let default = { gc_path = None Text, extra = None Text }

let asText =
      λ(opts : JavaOpts) →
        let gc_params =
              merge { None = "", Some = λ(p : Text) → " -GC:${p}" } opts.gc_path

        let extra =
              merge
                { None = "", Some = λ(extra : Text) → " ${extra}" }
                opts.extra

        in  "-Xms${./MemSize/asText
                     opts.xms} -Xmx${./MemSize/asText
                                       opts.xmx}${gc_params}${extra}"

in  { Type = JavaOpts, default, asText }
