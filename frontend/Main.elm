module Barista where

import Json.Decode as Json exposing ((:=))
import Graphics.Element as Element exposing (Element)
import Dict exposing (Dict)
import Signal exposing (Signal)
import Html exposing (Html)

main : Signal Html
main = Signal.map view clusters

-- View
view : Cluster -> Html
view cluster  =
  Html.div []
    [ renderTitle cluster
    , renderNodes cluster.nodes]

renderTitle : Cluster -> Html
renderTitle cluster =
  Html.h1 [] [Html.text ("Name: '" ++ cluster.name ++ "'")]

renderNodes : Dict String NodeInfo -> Html
renderNodes nodes =
  let
      title = Html.h2 [] [Html.text "Nodes:"]
      table = renderNodesTable <| Dict.toList nodes
  in
    Html.div [] [title,  table]

renderNodesTable : List (String, NodeInfo) -> Html
renderNodesTable nodes =
  let
      headerRow =
        Html.tr []
            [ Html.th [] [Html.text "Name"]
            , Html.th [] [Html.text "IP"]
            , Html.th [] [Html.text "Size"]
            , Html.th [] [Html.text "Registered"]
            , Html.th [] [Html.text "Healthy"]
            , Html.th [] [Html.text "Created At"]
            ]
      nodesRows = List.map renderNode nodes
  in
    Html.table [] (headerRow :: nodesRows)

renderNode : (String, NodeInfo) -> Html
renderNode (nodeName, info) =
  Html.tr []
    [ Html.td [] [Html.text nodeName]
    , Html.td [] [Html.text info.ip]
    , Html.td [] [Html.text info.size]
    , Html.td [] [Html.text <| toString info.registered]
    , Html.td [] [Html.text <| toString info.healthy]
    , Html.td [] [Html.text info.createdAt]
    ]

-- Model
clusters : Signal Cluster
clusters =
  let
      maybeClusters =
        Signal.map (decodeJson >> Result.toMaybe) fakeData
  in
     Signal.filterMap identity blankCluster maybeClusters

type alias Cluster =
  { name: String
  , location: String
  , resourceGroup: String
  , storageAccount: String
  , sshProxy: String
  , services: Dict String ServiceSummary
  , nodes: Dict String NodeInfo
  }

blankCluster : Cluster
blankCluster =
  { name = ""
  , location = ""
  , resourceGroup = ""
  , storageAccount = ""
  , sshProxy = ""
  , services = Dict.empty
  , nodes = Dict.empty
  }

type alias ServiceSummary =
  { instances: InstancesAmount
  , env : Dict String String
  , version : String
  }

type alias NodeInfo =
  { createdAt : String
  , size : String
  , ip : String
  , registered : Bool
  , healthy : Bool
  , services : Dict String ServiceInfo
  }

type alias ServiceInfo =
  { image : String
  , registered : Bool
  , healthy : Bool
  , tags : List String
  , registeredPort : Int
  , expostedPorts : List PortMapping
  }

type alias PortMapping =
  { incoming : Int
  , outgoing : Int
  , udp : Bool
  }

type InstancesAmount  = EveryNode | Range Int Int

type alias JsonParseError = String
decodeJson : String -> Result JsonParseError Cluster
decodeJson jsonString =
  Json.decodeString cluster jsonString

cluster: Json.Decoder Cluster
cluster =
  Json.object7 Cluster
    ("name"            := Json.string)
    ("location"        := Json.string)
    ("resource_group"  := Json.string)
    ("storage_account" := Json.string)
    ("sshproxy"        := Json.string)
    ("services"        := (Json.dict serviceSummary))
    ("nodes"           := (Json.dict nodeInfo))

serviceSummary : Json.Decoder ServiceSummary
serviceSummary =
  Json.object3 ServiceSummary
    ("instances" := instancesAmount)
    ("env" := (Json.dict Json.string))
    ("version" := Json.string)

instancesAmount : Json.Decoder InstancesAmount
instancesAmount =
  let
    everyNode =
      Json.object1 (always EveryNode) ("every_node" := Json.bool)
    range =
      Json.object2 Range ("minimum" := Json.int) ("maximum" := Json.int)
  in
    Json.oneOf [everyNode, range]

nodeInfo : Json.Decoder NodeInfo
nodeInfo =
  Json.object6 NodeInfo
    ("created_at" := Json.string)
    ("size" := Json.string)
    ("ip" := Json.string)
    ("registered" := Json.bool)
    ("healthy" := Json.bool)
    ("services" := (Json.dict serviceInfo))

serviceInfo : Json.Decoder ServiceInfo
serviceInfo =
  Json.object6 ServiceInfo
    ("image"           := Json.string)
    ("registered"      := Json.bool)
    ("healthy"         := Json.bool)
    ("tags"            := (Json.list Json.string))
    ("registered_port" := Json.int)
    ("exposed_ports"   := (Json.list portMapping))

portMapping : Json.Decoder PortMapping
portMapping =
  Json.object3 PortMapping
    ("incoming" := Json.int)
    ("outgoing" := Json.int)
    ("udp"      := Json.bool)

fakeData : Signal String
fakeData = Signal.constant """
{
  "name": "nathan-1",
  "location": "westeurope",
  "resource_group": "nathan-1",
  "storage_account": "nathan1",
  "sshproxy": "40.115.38.250",
  "services": {
    "statsite": {
      "instances": {
        "every_node": true
      },
      "env": {},
      "version": "abc"
    },
    "proxy": {
      "instances": {
        "minimum": 4,
        "maximum": 4
      },
      "env": {
        "PORT": "8000"
      },
      "version": "abc"
    }
  },
  "nodes": {
    "abc": {
      "created_at": "111111.11",
      "size": "Basic_A1",
      "name": "abc",
      "ip": "10.1.0.10",
      "registered": true,
      "healthy": true,
      "services": {
        "proxy": {
          "image": "plum/wake-proxy:abc",
          "registered": true,
          "healthy": true,
          "tags": ["platform:java", "platform:scala", "version:abc"],
          "registered_port": 31006,
          "exposed_ports": []
        },
        "statsite": {
          "image": "plum/wake-statsite:abc",
          "registered": true,
          "healthy": true,
          "tags": ["platform:c", "version:abc"],
          "registered_port": 8125,
          "exposed_ports": [{
            "incoming": 8125,
            "outgoing": 8125,
            "udp": true
          }]
        }
      }
    }
  }
}
"""