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
		var data = JSON.parse(x.graph);
		console.log(data);
		var cyDiv = el;
		cyj = cytoscape({
		    container: cyDiv,
		    elements: data.elements,
		    layout: {name: 'cose'},

		    ready: function(){
                        console.log("cyjShiny cyjs ready");
			$("#cyjShiny").height(0.95*window.innerHeight);
			var cyj = this;
			window.cyj = this;   // terrible hack.  but gives us a simple way to call cytosacpe functions
			console.log("small cyjs network ready, with " + cyj.nodes().length + " nodes.");
			cyj.nodes().map(function(node){node.data({degree: node.degree()})});
			setTimeout(function() {
			    cyj.fit(100)
			}, 600);
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
// Shiny.addCustomMessageHandler("loadStyleFile", function(message){
//
//    console.log("loadStyleFile requested: " + message.filename);
//    loadStyle(message.filename)
//
// });
//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("doLayout", function(message){

    var strategy = message.strategy;
    self.cyj.layout({name: strategy}).run()
    })

//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("redraw", function(message){

    console.log("redraw requested");
    self.cyj.style().update();

})
//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("setNodeAttributes", function(message){

    console.log("setNodeAttributes requested")

    var nodeIDs = message.nodes;
    var attributeName = message.attribute;

    for(var i=0; i < nodeIDs.length; i++){
	var id = nodeIDs[i];
	var newValue = message.values[i];
	var filterString = "[id='" + id + "']";
	var dataObj = self.cyj.nodes().filter(filterString).data();

	Object.defineProperty(dataObj, attributeName, {value: newValue});
    };

    self.cyj.style().update();
})
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
Shiny.addCustomMessageHandler("clearSelection", function(message){

    console.log("clearSelection requested: " + message);
    self.cyj.filter("node:selected").unselect();

})
//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("getSelectedNodes", function(message){

    console.log("getSelectedNodes requested: " + message);
    var value = self.cyj.filter("node:selected")
        .map(function(node) {
            return(node.data().id)})
             //return {id: node.data().id, label: node.data().label}})

    console.log(self.cyj.filter("node:selected"));
    console.log(value)
    Shiny.setInputValue("selectedNodes", value, {priority: "event"});

});
//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("sfn", function(message){

    console.log("sfn requested: " + message);
    self.cyj.nodes(':selected').neighborhood().nodes().select();

})
//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("fitSelected", function(message){

    console.log("fitSelected requested");
    var padding = message.padding;

    var selectedNodes = self.cyj.filter("node:selected");

    if(selectedNodes.length == 0){
	console.log("no nodes currently selected")
     }
   else{
       console.log("fitSelected, with padding " + padding);
       self.cyj.fit(selectedNodes, padding)
   }
})
//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("fit", function(message){
    console.log("fit requested: ");
    var padding = message.padding;
    console.log("   padding: " + padding)
    self.cyj.fit(padding);
    });
//------------------------------------------------------------------------------------------------------------------------
Shiny.addCustomMessageHandler("loadStyle", function(message) {

    console.log("loading style");
    var stringStyleSheet = message.json;
    window.cyj.style(stringStyleSheet);
    });

//------------------------------------------------------------------------------------------------------------------------
// requires an http server at localhost, started in the directory where filename is found
// expected file contents:  vizmap = [{selector:"node",css: {...
//function loadStyle(filename)
// {
//    var self = this;
//     console.log("rcyjs.loadStyle, filename: ", + filename);
//
//     var s = window.location.href + "?", + filename;
//    console.log("=== about to getScript on " + s);
//
//    $.getScript(s)
//      .done(function(script, textStatus) {
//         console.log(textStatus);
//         //console.log("style elements " + layout.length);
//         window.cyj.style(vizmap);
//        })
//     .fail(function( jqxhr, settings, exception ) {
//        console.log("getScript error trying to read " + filename);
//        console.log("exception: ");
//        console.log(exception);
//        });
//
// } // loadStyle
// //----------------------------------------------------------------------------------------------------
