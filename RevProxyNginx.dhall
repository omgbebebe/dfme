let Upstream = { mapKey : Text, mapValue : ./RevProxy/Upstream/Type }

let Upstreams
    : Type
    = List Upstream

let Location = { mapKey : Text, mapValue : { proxy_pass : Text } }

let Locations
    : Type
    = List Location

let Bind = { mapKey : Text, mapValue : Locations }

let Binds
    : Type
    = List Bind

let RevProxyNginx =
      { upstreams : Upstreams
      , binds : Binds
      , portMap : List ./DockerContainer/PortMapping/Type
      }

let indent = 2

let Text/concatMapSep = (./Prelude.dhall).Text.concatMapSep

let Text/spaces = (./Prelude.dhall).Text.spaces

let renderList =
      λ(n : Natural) →
      λ(a : Type) →
      λ(f : a → Text) →
      λ(xs : List a) →
        Text/concatMapSep
          ''

          ${Text/spaces (indent * n)}''
          a
          f
          xs

let renderHealthCheck =
      λ(hc : ./RevProxy/Upstream/Endpoint/HealthCheckParams/Type) →
        let fail_timeout =
              Natural/show (./Duration/toNaturalSeconds hc.fail_timeout)

        let slow_start =
              Natural/show (./Duration/toNaturalSeconds hc.slow_start)

        in  " fail_timeout=${fail_timeout} slow_start=${slow_start} max_fails=${Natural/show
                                                                                  hc.max_fails}"

let renderEndpoint
    : ./RevProxy/Upstream/Endpoint/Type → Text
    = λ(e : ./RevProxy/Upstream/Endpoint/Type) →
        let weight = Natural/show e.weight

        let max_conns = Natural/show e.max_conns

        let down = if e.down then " down" else ""

        let backup = if e.backup then " backup" else ""

        let healthCheck =
              merge
                { None = ""
                , Some =
                    λ ( hc
                      : ./RevProxy/Upstream/Endpoint/HealthCheckParams/Type
                      ) →
                      renderHealthCheck hc
                }
                e.healthcheck

        in  "server ${e.url} weight=${weight} max_conns=${max_conns}${down}${backup}${healthCheck};"

let renderLocation =
      λ(l : { mapKey : Text, mapValue : { proxy_pass : Text } }) →
        ''
        location ${l.mapKey} {
              proxy_pass ${l.mapValue.proxy_pass};
            }
        ''

let renderBind
    : Bind → Text
    = λ(bind : Bind) →
        ''
        server {
            listen ${bind.mapKey}
            
            ${renderList 2 Location renderLocation bind.mapValue}
          }''

let renderBindsConf
    : Binds → Text
    = λ(binds : Binds) → renderList 1 Bind renderBind binds

let renderUpstream
    : Upstream → Text
    = λ(u : Upstream) →
        ''
        upstream ${u.mapKey} {
            ${renderList
                2
                ./RevProxy/Upstream/Endpoint/Type
                renderEndpoint
                u.mapValue.endpoints}
          }
        ''

let renderUpstreamsConf
    : Upstreams → Text
    = λ(ups : Upstreams) → renderList 1 Upstream renderUpstream ups

let renderNginxConf
    : RevProxyNginx → Text
    = λ(cfg : RevProxyNginx) →
        ''
        worker_processes  5;
        worker_rlimit_nofile 8192;

        events {
          worker_connections  4096;  ## Default: 1024
        }

        http {
          ${renderUpstreamsConf cfg.upstreams}

          ${renderBindsConf cfg.binds}
        }
        ''

let mkDockerContainer
    : RevProxyNginx → ./DockerImage/Type → ./DockerContainer/Type
    = λ(cfg : RevProxyNginx) →
      λ(image : ./DockerImage/Type) →
        let DockerContainer = ./DockerContainer.dhall

        let nginx_conf =
              (./Mount/Type).ConfigFile
                { dst = "/etc/nginx.conf", content = renderNginxConf cfg }

        let mounts = [ nginx_conf ]

        let ports = cfg.portMap

        in  DockerContainer::{ name = "revproxy-nginx", image, mounts, ports }

in  { Type = RevProxyNginx, mkDockerContainer }
