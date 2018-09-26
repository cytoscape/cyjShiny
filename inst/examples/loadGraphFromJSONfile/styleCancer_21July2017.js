[
    {"selector": "node", "css": {
      "shape": "ellipse",
      "text-valign":"center",
      "text-halign":"center",
      "content": "data(id)",
      "background-color": "#FFFFFF",
      "border-color": "darkgray",
      "border-width":"1px",
      "width":  "60px",
      "height": "30px",
      "font-size":"14px"}},

   {"selector": "node[type='info']", "css": {
       "shape": "roundrectangle",
       "font-size": "72px",
       "width": "360px",
       "height": "120px",
       "border-width": "3px",
       "background-color": "beige"
       }},

   {"selector": "node[expression < 0]", "css": {
      "background-color": "mapData(expression, -1.9, 0, green, white)"
       }},

   {"selector": "node[expression >=0]", "css": {
      "background-color": "mapData(expression, 0, 1.7, white, red)"
       }},

   {"selector": "edge[edgeType='promotes']", "css": {
      "target-arrow-shape": "triangle",
      "target-arrow-color": "blue",
      "curve-style":"bezier",
      "line-color": "mapData(score, 0, 1, lightgray, blue)",
      "width":      "mapData(score, 0, 1, 1, 8)"
      }},

   {"selector": "edge[edgeType='inhibits']", "css": {
      "target-arrow-shape": "tee",
      "target-arrow-color": "red",
      "curve-style":"bezier",
      "line-color": "mapData(score, 0, 1, lightgray, red)",
      "width":      "mapData(score, 0, 1, 1, 8)"
      }},

   {"selector":"node:selected", "css": {
       "text-valign":"center",
       "text-halign":"center",
       //"content": "data(id)",
       "border-color": "black",
       "overlay-opacity": 0.2,
       "overlay-color": "gray"
       }},

   {"selector": "node[type='ex']", "css": {
      "shape": "triangle"
      }},

   {"selector": "edge", "css": {
       "opacity": 0.5
       }},

   {"selector":"edge:selected", "css": {
       "overlay-opacity": 0.2,
       "overlay-color": "red"
       }}
]
