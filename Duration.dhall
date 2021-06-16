{-|
Mimic a Duration type from the Go language.

to render it as a Text with a proper postfix
use `Duration/asText` function
-}
let Duration =
    {- TODO: default YAML renderer will throw Contructors away
    right now it needs to use asText instance to proper rendering
    with a right suffixes such 's' 'ms' 'd' etc
    -}
      < Nanoseconds : Natural
      | Microseconds : Natural
      | Milliseconds : Natural
      | Seconds : Natural
      | Minutes : Natural
      | Hours : Natural
      | Days : Natural
      | Weeks : Natural
      >

let toNaturalSeconds
    : Duration → Natural
    = λ(duration : Duration) →
        merge
          { Seconds = λ(x : Natural) → x
          , Minutes = λ(x : Natural) → x * 60
          , Hours = λ(x : Natural) → x * 60 * 60
          , Days = λ(x : Natural) → x * 60 * 60 * 24
          , Weeks = λ(x : Natural) → x * 60 * 60 * 24 * 7
          , Nanoseconds = λ(x : Natural) → 0
          , Microseconds = λ(x : Natural) → 0
          , Milliseconds = λ(x : Natural) → 0
          }
          duration

let toSeconds =
      λ(duration : Duration) → Duration.Seconds (toNaturalSeconds duration)

let List/map = (./Prelude.dhall).List.map

let asText =
      λ(duration : Duration) →
        let withPostfix =
              λ(postfix : Text) → λ(x : Natural) → Natural/show x ++ postfix

        in  merge
              { Nanoseconds = withPostfix "ns"
              , Microseconds = withPostfix "us"
              , Milliseconds = withPostfix "ms"
              , Seconds = withPostfix "s"
              , Minutes = withPostfix "m"
              , Hours = withPostfix "h"
              , Days = withPostfix "d"
              , Weeks = withPostfix "w"
              }
              duration

let example0 =
        assert
      :   List/map
            Duration
            Text
            asText
            [ Duration.Nanoseconds 1
            , Duration.Microseconds 2
            , Duration.Milliseconds 3
            , Duration.Seconds 4
            , Duration.Minutes 5
            , Duration.Hours 6
            , Duration.Days 7
            , Duration.Weeks 8
            ]
        ≡ [ "1ns", "2us", "3ms", "4s", "5m", "6h", "7d", "8w" ]

let example1 =
        assert
      :   List/map
            Duration
            Duration
            toSeconds
            [ Duration.Nanoseconds 1
            , Duration.Microseconds 2
            , Duration.Milliseconds 3
            , Duration.Seconds 4
            , Duration.Minutes 5
            , Duration.Hours 6
            , Duration.Days 7
            , Duration.Weeks 8
            ]
        ≡ [ Duration.Seconds 0
          , Duration.Seconds 0
          , Duration.Seconds 0
          , Duration.Seconds 4
          , Duration.Seconds 300
          , Duration.Seconds 21600
          , Duration.Seconds 604800
          , Duration.Seconds 4838400
          ]

in  { Type = Duration, toSeconds, toNaturalSeconds, asText }
