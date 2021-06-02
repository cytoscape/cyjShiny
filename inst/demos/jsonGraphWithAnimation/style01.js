[

   {"selector":"node", "css": {
       "text-valign":"center",
       "text-halign":"center",
       "background-color": "lightgreen",
       "border-color": "black",
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

    {"selector": "edge[interaction='unknown']", "css": {
        "source-arrow-shape": "none",
        "target-arrow-shape": "none"
        }},


    {"selector": "edge[interaction='phosphorylates']", "css": {
        "source-arrow-shape": "none",
        "target-arrow-shape": "triangle",
        "target-arrow-color": "black"
        }},

    {"selector": "edge[interaction='synthetic lethal']", "css": {
        "source-arrow-shape": "square",
        "source-arrow-color": "black",
        "target-arrow-shape": "tee",
        "target-arrow-color": "red"
        }},

    {"selector": "edge[score<=0]", "css": {
        "line-color": "mapData(score, -30, 0, red, lightGray)"
        }},

    {"selector": "edge[score>0]", "css": {
        "line-color": "mapData(score, 0, 30, lightGray, green)"
        }},

    {"selector": "edge:selected", "css": {
       "overlay-opacity": 0.2,
       "overlay-color": "maroon"
        }}

   ]
