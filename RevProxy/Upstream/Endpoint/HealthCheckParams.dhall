let Duration = ../../../Duration/Type

let HealthCheckParams =
      { fail_timeout : Duration, max_fails : Natural, slow_start : Duration }

let default
    : HealthCheckParams
    = { fail_timeout = Duration.Seconds 30
      , max_fails = 3
      , slow_start = Duration.Minutes 1
      }

in  { Type = HealthCheckParams, default }
