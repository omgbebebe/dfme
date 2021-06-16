let ColorMap =
      { severity :
          { critical : Text
          , warning : Text
          , indeterminate : Text
          , ok : Text
          , security : Text
          , cleared : Text
          , normal : Text
          , informational : Text
          , debug : Text
          , trace : Text
          , unknown : Text
          }
      , text : Text
      , highlight : Text
      }

let defaultColormap =
      { severity =
        { critical = "#ff5555"
        , warning = "#f1fa8c"
        , indeterminate = "#bd93f9"
        , ok = "#50fa7b"
        , security = "blue"
        , cleared = "#00CC00"
        , normal = "#00CC00"
        , informational = "#00CC00"
        , debug = "#9D006D"
        , trace = "#7554BF"
        , unknown = "#bd93f9"
        }
      , text = "#000000"
      , highlight = "#506070"
      }

let AlertaServer
    : Type
    = { port : ./Port/Type
      , mongodb : { url : Text, database : Text }
      , hpomi : Optional ./AlertaServer/HpOmi/Type
      , image : ./DockerImage/Type
      , conf_file : Text
      , debug : Bool
      , admin : { user : Text, key : Text }
      , plugins : List Text
      , heartbeat : { events : List Text, timeout : ./Duration/Type }
      , columns : List Text
      , notification_blackout : Bool
      , cors_origins : List Text
      , blackout_accept : List Text
      , colorMap : ColorMap
      }

let default =
      { port = ./Port/Tcp 8080
      , hpomi = None ./AlertaServer/HpOmi/Type
      , conf_file = "/app/alertad.conf"
      , debug = False
      , mongodb.database = "alerta"
      , admin.user = "alerta@example.com"
      , plugins =
        [ "heartbeat", "blackout", "normalise", "enhance", "prometheus" ]
      , heartbeat =
        { events = [ "Heartbeat", "Watchdog" ]
        , timeout = ./Duration/Seconds 80
        }
      , columns =
        [ "severity"
        , "status"
        , "lastReceiveTime"
        , "duplicateCount"
        , "resource"
        , "event"
        , "value"
        ]
      , notification_blackout = True
      , cors_origins = [ "*" ]
      , blackout_accept = [ "normal", "ok", "cleared" ]
      , colorMap = defaultColormap
      }

let renderAlertadConf =
      λ(cfg : AlertaServer) →
        let Bool/show = (./Prelude.dhall).Bool.show

        let renderList =
              λ(cols : List Text) →
                let wrap = λ(c : Text) → "'${c}'"

                let Text/concatMapSep = (./Prelude.dhall).Text.concatMapSep

                in  Text/concatMapSep "," Text wrap cols

        in  ''
            # it's a configuration file with a python syntax (django style)

            COLOR_MAP={
              'severity':
                { 'critical': '${cfg.colorMap.severity.critical}',
                  'warning': '${cfg.colorMap.severity.warning}',
                  'indeterminate': '${cfg.colorMap.severity.indeterminate}',
                  'ok': '${cfg.colorMap.severity.ok}',
                  'security': '${cfg.colorMap.severity.security}',
                  'cleared': '${cfg.colorMap.severity.cleared}',
                  'normal': '${cfg.colorMap.severity.normal}',
                  'informational': '${cfg.colorMap.severity.informational}',
                  'debug': '${cfg.colorMap.severity.debug}',
                  'trace': '${cfg.colorMap.severity.trace}',
                  'unknown': '${cfg.colorMap.severity.unknown}'
                },
                'text': '${cfg.colorMap.text}',
                'highlight': '${cfg.colorMap.highlight}'
            }

            COLUMNS = [${renderList cfg.columns}]
            CORS_ORIGINS = [${renderList cfg.cors_origins}]
            NOTIFICATION_BLACKOUT=${Bool/show cfg.notification_blackout}
            BLACKOUT_ACCEPT = [${renderList cfg.blackout_accept}]
            HEARTBEAT_TIMEOUT = "${Natural/show
                                     ( ./Duration/toNaturalSeconds
                                         cfg.heartbeat.timeout
                                     )}"
            HEARTBEAT_EVENTS = [${renderList cfg.heartbeat.events}]
            ''

let mkDockerContainer =
      λ(cfg : AlertaServer) →
        let DockerContainer = ./DockerContainer.dhall

        let Bool/asDigit
            : Bool → Text
            = λ(x : Bool) → if x then "1" else "0"

        let Text/concatSep = (./Prelude.dhall).Text.concatSep

        let hpOmiEnv =
              λ(hpomi : Optional ./AlertaServer/HpOmi/Type) →
                let Map = (./Prelude.dhall).Map

                in  merge
                      { None =
                        { plugin = [] : List Text
                        , env = Map.empty Text Text
                        , egress = Map.empty Text ./Egress/Type
                        }
                      , Some =
                          λ(opts : ./AlertaServer/HpOmi/Type) →
                            { plugin = [ "hpomi" ]
                            , env = toMap
                                { HPOMI_SEVERITY_TRIGGER = opts.severity_trigger
                                , HPOMI_RESOLVE_STATUSES =
                                    Text/concatSep "," opts.resolve_status
                                , HPOMI_HOST = opts.host
                                , HPOMI_PORT = ./Port/textNumber opts.port
                                , HPOMI_TEAM = opts.team
                                , HPOMI_SSL_VERIFY =
                                    Bool/asDigit opts.ssl_verify
                                , HPOMI_XML_ROOT_TAG = opts.xml_root_tag
                                , HPOMI_HEARTBEAT_TIMEOUT =
                                    Natural/show
                                      ( ./Duration/toNaturalSeconds
                                          opts.heartbeat.timeout
                                      )
                                , HPOMI_HEARTBEAT_ENV_NAME =
                                    opts.heartbeat.env_name
                                , HPOMI_HEARTBEAT_HOSTNAME =
                                    opts.heartbeat.hostname
                                , HPOMI_HEARTBEAT_IPADDRESS =
                                    opts.heartbeat.ipaddress
                                , HPOMI_HEARTBEAT_EXTRA_DATA =
                                    opts.heartbeat.extra_data
                                }
                            , egress = toMap
                                { hpomi =
                                  { zone = ./NetworkZone/External
                                  , destination =
                                      "https://${opts.host}:${./Port/textNumber
                                                                opts.port}/"
                                  , port = opts.port
                                  }
                                }
                            }
                      }
                      hpomi

        let hpomi = hpOmiEnv cfg.hpomi

        let alertaConf =
              (./Mount/Type).ConfigFile
                { dst = cfg.conf_file, content = renderAlertadConf cfg }

        let docker =
              DockerContainer::{
              , name = "alerta-server"
              , image = cfg.image
              , ports =
                [ ./DockerContainer/PortMapping/fromPort "api" cfg.port ]
              , envVars =
                    toMap
                      { ALERTA_SVR_CONF_FILE = cfg.conf_file
                      , DEBUG = Bool/asDigit cfg.debug
                      , DATABASE_URL = cfg.mongodb.url
                      , DATABASE_NAME = cfg.mongodb.database
                      , ADMIN_USERS = cfg.admin.user
                      , PLUGINS =
                          Text/concatSep "," (cfg.plugins # hpomi.plugin)
                      , ADMIN_KEY = cfg.admin.key
                      }
                  # hpomi.env
              , mounts = [ alertaConf ]
              , egress = hpomi.egress
              }

        in  docker

in  { Type = AlertaServer, default, mkDockerContainer }
