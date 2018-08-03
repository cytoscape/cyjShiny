// following http://www.htmlwidgets.org/develop_intro.html
"use strict";

var cytoscape = require('cytoscape');
//----------------------------------------------------------------------------------------------------
// add layout extensions
var cola = require('cytoscape-cola');
cytoscape.use(cola);

let dagre = require('cytoscape-dagre');
cytoscape.use(dagre);

let coseBilkent = require('cytoscape-cose-bilkent');
cytoscape.use(coseBilkent);

$ = require('jquery');
require('jquery-ui-bundle');
//----------------------------------------------------------------------------------------------------
HTMLWidgets.widget({

    name: 'cyjShiny',
    type: 'output',
    
    factory: function(el, width, height) {
	var cyj;
	return {
	    renderValue: function(x, instance) {
		console.log("---- ~/github/cyjsShiny/inst/browserCode/src/cyjShiny.js, renderValue")
		console.log(x.message);

		var data = JSON.parse(x.message)
		console.log(data);
		console.log(typeof data)
		console.log(data.elements.nodes)
		console.log(data.elements.edges)
		
		var cyDiv = el;
		//htmlElement = el;
				
		cyj = cytoscape({
		    container: cyDiv,
		    elements: data.elements,
		    layout: {name: 'random'},
		    style: [{selector: "node", css: {
			"shape": "ellipse",
			"text-valign":"center",
			"text-halign":"center",
			"content": "data(label)",
			"border-width": "3px",
			"background-color": "#FFFFFF",
			"border-color":"black",
			"width": "80px",
			"height": "80px",
			"font-size":"24px"}},
		    
		    
		    {selector:"node:selected", css: {
			"text-valign":"center",
			"text-halign":"center",
			"border-color": "black",
			"content": "data(id)",
			"border-width": "3px",
			"overlay-opacity": 0.2,
			"overlay-color": "gray"
		    }},
		    
		    
		    {selector:"edge", css: {
			"line-color": "rgb(50,50,50",
			'target-arrow-color': 'rgb(50,50,50)',
			'target-arrow-shape': 'triangle',
			"width": "1px",
			'curve-style': 'bezier',
			'haystack-radius': 0.5
		    }},


		    {"selector": "edge:selected", css: {
			"overlay-opacity": 0.2,
			"overlay-color": "gray",
			"width": "2px",
		    }}],
		    
		    ready: function(){
			$("#cyjShiny").height(0.8 * window.innerHeight);
			var cyj = this;
			window.cyj = this;   // terrible hack.  but gives us a simple way to call cytosacpe functions
			console.log("small cyjs network ready, with " + cyj.nodes().length + " nodes.");
			
		    } // ready
		}) // cytoscape()
            }, // renderValue
            resize: function(width, height, instance){
		console.log("cyjShiny widget, resize: " + width + ", " + height)
		$("#cyjShiny").height(0.8 * window.innerHeight);
		cyj.resize()
		console.log("  after resize: " + width + ", " + height)
            },
            cyjWidget: cyj
        }; // return
    } // factory
});  // widget
//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("loadStyleFile", function(message){

   console.log("loadStyleFile requested: " + message.filename);
   loadStyle(message.filename)

});
//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("selectNodes", function(message){

   console.log("selectNodes requested: " + message);

   var nodeIDs = message;

   if(typeof(nodeIDs) == "string")
      nodeIDs = [nodeIDs];

   var filterStrings = [];

   for(var i=0; i < nodeIDs.length; i++){
     var s = '[id="' + nodeIDs[i] + '"]';
     filterStrings.push(s);
     } // for i

   console.log("filtersStrings, joined: " + filterStrings);

   var nodesToSelect = window.cyj.nodes(filterStrings.join());
   nodesToSelect.select()

});
//------------------------------------------------------------------------------------------------------------------------
// requires an http server at localhost, started in the directory where filename is found
// expected file contents:  vizmap = [{selector:"node",css: {...
function loadStyle(filename)
{
   var self = this;
   console.log("rcyjs.loadStyle, filename: " + filename);

   var s = window.location.href + filename;
   console.log("=== about to getScript on " + s);

   $.getScript(s)
     .done(function(script, textStatus) {
        console.log(textStatus);
        //console.log("style elements " + layout.length);
        window.cyj.style(vizmap);
       })
    .fail(function( jqxhr, settings, exception ) {
       console.log("getScript error trying to read " + filename);
       console.log("exception: ");
       console.log(exception);
       });

} // loadStyle
//----------------------------------------------------------------------------------------------------
