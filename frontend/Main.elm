module Barista where


import Graphics.Element as Element exposing (Element)

main : Element
main = Element.show json

json = """
{
  "services": {
    "statsite": {
      "tags": [],
      "nodes": [
        {
          "name": "abc",
          "tags": []
        },
        {
          "name": "xyz",
          "tags": []
        }
      ]
    }
  },
  "nodes": [
    {
      "name": "abc",
      "ip": "10.1.0.12",
      "services": ["consul", "statsite", "redis"],
      "state": {
        "metadata": {
          "created_at": "1111111.11",
          "size": "Basic_A1",
          "location": "westeurope",
          "resource_group": "nathan-test-1"
        },
        "services": {
          "statsite": {
            "image": "wakeful/wake-statsite:latest",
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
            "tags": ["statsd", "udp"],
            "checks": []
          }
        }
      }
    ]
  }
}"""