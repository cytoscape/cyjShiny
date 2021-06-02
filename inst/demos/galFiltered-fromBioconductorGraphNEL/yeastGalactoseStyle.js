[
   {"selector":"node", "css": {
       "text-valign":"center",
       "text-halign":"center",
       "border-color": "black",
       "content": "data(label)",
       "border-width": "1px",
       "width": "mapData(degree, 0, 20, 100, 300)",
       "height": "mapData(degree, 0, 20, 100, 300)"
       }},

    {"selector": "node[lfc<=0]", "css": {
        "background-color": "mapData(lfc, -1, 0, green, white)"
        }},

    {"selector": "node[lfc>0]", "css": {
        "background-color": "mapData(lfc, 0, 2, white, red)"
    }},

    {"selector": "node:selected", "css": {
       "overlay-opacity": 0.3,
       "overlay-color": "gray"
    }},

    {"selector": "edge", "css": {
        "curve-style": "bezier"
    }},

    {"selector": "edge[edgeType='pd']", "css": {
        "line-color": "blue",
        "target-arrow-shape": "triangle",
        "target-arrow-color": "blue",
        "arrow-scale": 3

    }},

    {"selector": "edge[edgeType='pp']", "css": {
        "line-color": "red"

      }}
]
