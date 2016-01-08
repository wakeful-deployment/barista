module Barista where

import Json.Decode as Json exposing ((:=))
import Graphics.Element as Element exposing (Element)
import Dict exposing (Dict)

main : Element
main = Element.show <| decodeJson json

type alias ServiceSummary =
     { name: String
     , tags : List String
     , nodes : List NodeSummary
     }

type alias Node =
     { name : String
     , ip : String
      , services : List Service
}

type alias NodeSummary =
  { name : String
  }

type alias NodeMetadata =
    { createdAt : String
    , size : String
    , location : String
    , resourceGroup : String
    }

type alias Service =
  { image : String
  , ports : List PortMapping
  , env : Dict String String
  , restart : RestartFrequency
  , tags : List String
}

type alias PortMapping =
    { incoming : Int
    , outgoing : Int
    , udp : Bool
    }

type RestartFrequency = Always | Never

type alias ClusterInfo =
  { services: List ServiceSummary
  , nodes: List Node
  }

decodeJson : String -> Result String ClusterInfo
decodeJson jsonString =
  Json.decodeString clusterInfo jsonString

clusterInfo: Json.Decoder ClusterInfo
clusterInfo =
  Json.object2 ClusterInfo
    ("services" := (Json.list serviceSummary))
    ("nodes" := (Json.list node))

node : Json.Decoder Node
node =
  Json.object3 Node
    ("name" := Json.string)
    ("ip" := Json.string)
    ("services" := (Json.list service))

service : Json.Decoder Service
service =
  Json.object5 Service
    ("image"   := Json.string)
    ("ports"   := (Json.list portMapping))
    ("env"     := (Json.dict Json.string))
    ("restart" := restartFrequency)
    ("tags"    := (Json.list Json.string))

portMapping : Json.Decoder PortMapping
portMapping =
  Json.object3 PortMapping
    ("incoming" := Json.int)
    ("outgoing" := Json.int)
    ("udp"      := Json.bool)

restartFrequency : Json.Decoder RestartFrequency
restartFrequency =
  let
      determineFrequency frequencyString =
        case frequencyString of
          "always" -> Json.succeed Always
          "never"  -> Json.succeed Never
          str      -> Json.fail ("An invalid 'restart' string ("  ++  str ++ ") was provided")
  in
    Json.string `Json.andThen` determineFrequency

serviceSummary : Json.Decoder ServiceSummary
serviceSummary =
  Json.object3 ServiceSummary
    ("name" := Json.string)
    ("tags" := (Json.list Json.string))
    ("nodes" := (Json.list nodeSummary))

nodeSummary : Json.Decoder NodeSummary
nodeSummary =
  Json.object1 NodeSummary
    ("name" := Json.string)

json = """
{
  "services": [
    {
      "name": "statsite",
      "tags": [],
      "nodes": [
        {
          "name": "abc"
        },
        {
          "name": "xyz"
        }
      ]
    }
  ],
  "nodes": [
    {
      "name": "abc",
      "ip": "10.1.0.12",
      "location": "westeurope",
      "resource_group": "nathan-test-1",
      "services": [
        {
          "name": "consul",
          "image": "wakeful/consul:latest",
          "state": "running",
          "ports": [
            {
              "incoming": 8500,
              "outgoing": 8500,
              "udp": false
            }
          ],
          "env": {},
          "restart": "always",
          "tags": ["consul"]
        },
        {
          "name": "statsite",
          "image": "wakeful/wake-statsite:latest",
          "state": "running",
          "ports": [
            {
              "incoming": 8125,
              "outgoing": 8125,
              "udp": true
            }
          ],
          "env": {
            "TEST": "1"
          },
          "restart": "always",
          "tags": ["statsd", "udp"]
        },
        {
          "name": "redis",
          "image": "wakeful/redis:latest",
          "state": "stopped",
          "ports": [],
          "env": {},
          "restart": "always",
          "tags": ["redis"]
        }
      ]
    }
  ]
}
"""