[
    {"selector": "node", "css": {
	"text-valign":"center",
	"text-halign":"center",
	"content": "data(id)",
	"border-width": "3px",
	"height":"40px",
	"width":"40px",
	"font-size":"10px"
    }},
    {"selector":"node:selected", "css": {
	"text-valign":"center",
	"text-halign":"center",
	"border-color": "red",
	"content": "data(id)",
	"border-width": "3px",
	"overlay-opacity": 0.2,
	"overlay-color": "gray"
    }},

    {"selector":"node[id='Gene A']", "css": {
	"background-color":"#A1F39F",
	"border-color":"#EC6262",
	"color":"black"
    }},
    
    {"selector":"node[id='Gene B']", "css": {
	"background-color":"#FFFFFF",
	"border-color":"black",
	"color":"black"
    }},
    
    {"selector":"node[id='Gene C']", "css": {
	"background-color":"gray",
	"border-color":"#6FAEEC"
    }},
    
    {"selector":"edge", "css": {
	"line-color": "rgb(50,50,50",
	"target-arrow-color": "rgb(50,50,50)",
	"target-arrow-shape": "triangle",
	"width": "1px",
	"curve-style": "bezier",
	"haystack-radius": 0.5
    }},
    
    
    {"selector": "edge:selected", "css": {
	"overlay-opacity": 0.2,
        "overlay-color": "gray",
        "width": "2px"
    }}
]
