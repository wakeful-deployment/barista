module Main where

import Graphics.Element as Element exposing (Element)
import Dict exposing (Dict)
import Signal exposing (Signal)
import Html exposing (Html)
import Model exposing (..)

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
