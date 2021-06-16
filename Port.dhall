let Port = < Tcp : Natural | Udp : Natural >

let number =
      λ(p : Port) →
        merge { Tcp = λ(n : Natural) → n, Udp = λ(n : Natural) → n } p

let textNumber = λ(p : Port) → Natural/show (number p)

in  { Type = Port, default = {=}, number, textNumber }
