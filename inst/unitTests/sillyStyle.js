[

   {"selector": "node", "css": {
       "text-valign":"center",
       "text-halign":"center",
       "border-color": "red",
       "background-color": "lightgreen",
       "content": "",
       "border-width": "3px"
       }},


   {"selector": "node:selected", "css": {
       "text-valign":"center",
       "text-halign":"center",
       //"border-color": "red",
       "content": "data(id)",
       "font-size":"10px",
       "height":"80px",
       "width":"80px",
       "border-width": "2px",
       "overlay-opacity": 0.2,
       "overlay-color": "gray"
       }},

    {"selector":"node[id='Gene A']", "css": {
	"shape":"triangle",
	"background-color":"#A1F39F",
	"border-color":"#EC6262",
	"color":"black"
    }},
    
    {"selector":"node[id='Gene B']", "css": {
	"shape":"hexagon",
	"background-color":"#FFFFFF",
	"border-color":"black",
	"color":"black"
    }},
    
    {"selector":"node[id='Gene C']", "css": {
	"background-color":"gray",
	"border-color":"#6FAEEC"
    }},

   {"selector": "edge", "css": {
       "line-color": "black",
       "target-arrow-color": "black",
      "target-arrow-shape": "triangle",
       "width": "1px",
       "curve-style": "unbundled-bezier",
       "line-style":"dashed",
       "haystack-radius": 0.5
       }},

    {"selector": "edge:selected", "css": {
       "overlay-opacity": 0.2,
       "overlay-color": "gray",
       "width": "2px"
    }}
]
