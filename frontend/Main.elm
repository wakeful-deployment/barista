module Barista where

import Dict exposing (Dict)
import Graphics.Element as Element exposing (Element)

main : Element
main = Element.show json

type alias ServiceSummary = 
     { name : String 
     , tags : List String 
     , nodes : List String
     } 

type alias Node = 
     { name : String 
     , ip : List String
     , state: RunningState
     , services : List Service
     } 

type RunningState = Running | Off

type alias NodeMetadata = 
    { createdAt : String
    , size : String
    , location : String
    , resourceGroup : String
    }

type alias Service =
    { image : String
    , state : RunningState
    , ports : List PortMapping
    , env : Dict String String
    , restart : RestartFrequency
    , tags : List String
    , checks : List String
    }

type alias PortMapping =
    { incoming : Int
    , outgoing : Int
    , udp : Bool
    }

type RestartFrequency = Always | Never
    
json = """
{
  "services": {
    "statsite": {
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
  },
  "nodes": [
    {
      "name": "abc",
      "ip": "10.1.0.12",
      "state": "running",
      "metadata": {
        "created_at": "1111111.11",
        "size": "Basic_A1",
        "location": "westeurope",
        "resource_group": "nathan-test-1"
      },
      "services": {
        "consul": {
          "image": "wakeful/consul:latest",
          "state": "running",
          "ports": [
            {
              "incoming": 8500,
              "outgoing": 8500
            }
          ],
          "env": {},
          "restart": "always",
          "tags": ["consul"]
        },
        "statsite": {
          "image": "wakeful/wake-statsite:latest",
          "state": "running",
          "ports": {
              "incoming": 8125,
              "outgoing": 8125,
              "udp": true
          },
          "env": {
            "TEST": "1"
          },
          "restart": "always",
          "tags": ["statsd", "udp"]
        },
        "redis": {
          "image": "wakeful/redis:latest",
          "state": "stopped",
          "restart": "always",
          "tags": ["redis"]
        }
      }
    }
  ]
}
"""