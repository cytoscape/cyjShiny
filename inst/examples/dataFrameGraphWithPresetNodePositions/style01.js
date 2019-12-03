[

   {"selector":"node", "css": {
       "text-valign":"center",
       "text-halign":"center",
       "background-color": "lightgreen",
       "border-color": "black",
       "shape": "ellipse",
       "width": "mapData(count, 0, 300, 30, 80)",
       "height": "mapData(count, 0, 300, 30, 80)",
       "content": "data(id)",
       "border-width": "1px"
       }},

   {"selector":"node[lfc<=0]", "css": {
       "text-valign":"center",
       "text-halign":"center",
       "background-color": "mapData(lfc, -3, 0, red, white)",
       "border-color": "black",
       "content": "data(id)",
       "border-width": "1px"
       }},

   {"selector":"node[lfc>0]", "css": {
       "text-valign":"center",
       "text-halign":"center",
       "background-color": "mapData(lfc, 0, 3, white, lightgreen)",
       "border-color": "black",
       "content": "data(id)",
       "border-width": "1px"
       }},

   {"selector":"node:selected", "css": {
       "text-valign":"center",
       "text-halign":"center",
       "border-color": "black",
       "content": "data(id)",
       "border-width": "3px",
       "overlay-opacity": 0.5,
       "overlay-color": "blue"
       }},

    {"selector": "edge", "css": {
        "line-color": "maroon",
        "source-arrow-shape": "circle",
        "source-arrow-color": "orange",
        "target-arrow-shape": "tee",
        "target-arrow-color": "black",
        "curve-style": "bezier"
        }},

    {"selector": "edge[score<=0]", "css": {
        "line-color": "mapData(score, -30, 0, red, lightGray)",
        "source-arrow-shape": "circle",
        "source-arrow-color": "orange",
        "target-arrow-shape": "tee",
        "target-arrow-color": "black",
        "curve-style": "bezier"
        }},

    {"selector": "edge[score>0]", "css": {
        "line-color": "mapData(score, 0, 30, lightGray, green)",
        "source-arrow-shape": "circle",
        "source-arrow-color": "orange",
        "target-arrow-shape": "tee",
        "target-arrow-color": "black",
        "curve-style": "bezier"
        }},

    {"selector": "edge:selected", "css": {
       "overlay-opacity": 0.2,
       "overlay-color": "maroon"
        }}

   ]
