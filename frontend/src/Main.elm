module Main where

import Dict exposing (Dict)
import Signal exposing (Signal)
import Html exposing (Html)
import Model

main : Signal Html
main = Signal.map view Model.clusters

view : Model.Cluster -> Html
view cluster  =
  Html.div []
    [ renderTitle cluster
    , renderNodes cluster.nodes]

renderTitle : Model.Cluster -> Html
renderTitle cluster =
  Html.h1 [] [Html.text ("Name: '" ++ cluster.name ++ "'")]

renderNodes : Dict String Model.NodeInfo -> Html
renderNodes nodes =
  let
      title = Html.h2 [] [Html.text "Nodes:"]
      table = renderNodesTable <| Dict.toList nodes
  in
    Html.div [] [title,  table]

renderNodesTable : List (String, Model.NodeInfo) -> Html
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

renderNode : (String, Model.NodeInfo) -> Html
renderNode (nodeName, info) =
  Html.tr []
    [ Html.td [] [Html.text nodeName]
    , Html.td [] [Html.text info.ip]
    , Html.td [] [Html.text info.size]
    , Html.td [] [Html.text <| toString info.registered]
    , Html.td [] [Html.text <| toString info.healthy]
    , Html.td [] [Html.text info.createdAt]
    ]
