// following http://www.htmlwidgets.org/develop_intro.html
"use strict";
var cyjShiny_version = "1.0.26";
//----------------------------------------------------------------------------------------------------
var defaultStyle = [{selector: 'node', css: {
                        'text-valign': 'center',
                        'text-halign': 'center',
                        'content': 'data(id)',
                        'border-color': 'red',
                        'background-color': 'white',
                        'border-width': 1,
                        'height': 60,
                        'width': 60
                        }},
                     {selector: 'node:selected', css: {
                        'overlay-color': 'gray',
                        'overlay-opacity': 0.4,
                         }},
                     {selector: 'edge', css: {
                          'width': '1px',
                          'line-color': 'black',
                           'target-arrow-shape': 'triangle',
                           'target-arrow-color': 'black',
                           'curve-style': 'bezier'
                           }},
                     {selector: 'edge:selected', css: {
                        'overlay-color': 'gray',
                        'overlay-opacity': 0.4
                        }}
                   ];
//----------------------------------------------------------------------------------------------------
var executionMode = "devel";
const cyjshiny_log = function(msg)
{
  if(executionMode == "devel")
      console.log(msg);
}
//----------------------------------------------------------------------------------------------------
HTMLWidgets.widget({

    name: 'cyjShiny',
    type: 'output',

    factory: function(el, allocatedWidth, allocatedHeight) {
        cyjshiny_log("---- entering factory, initial dimensions: " + allocatedWidth + ", " + allocatedHeight);
	var cyj;
	return {
	    renderValue: function(x, instance) {
		cyjshiny_log("---- ~/github/cyjsShiny/inst/browserCode/src/cyjShiny.js, renderValue");
                cyjshiny_log(x);
                var data = JSON.parse(x.graph);
                var layoutName = x.layoutName;
                var style = JSON.parse(x.style.json);
                if (style == "default style")
                    style = defaultStyle;
		// cyjshiny_log(data);
		var cyDiv = el;
		cyj = cytoscape({
		    container: cyDiv,
		    elements: data.elements,
		    layout: {name: layoutName},
		    style:  style, //defaultStyle,
		    ready: function(){
                        cyjshiny_log("cyjShiny cyjs ready");
                        cyjshiny_log("cyjShiny widget, initial dimensions: " + allocatedWidth + ", " + allocatedHeight)
			$("#cyjShiny").height(allocatedHeight)
			$("#cyjShiny").width(allocatedWidth)
			var cyj = this;
			window.cyj = this;   // terrible hack.  but gives us a simple way to call cytosacpe functions
			if (style != null) {
                          cyj.style(style.json);
			  }
			cyjshiny_log("small cyjs network ready, with " + cyj.nodes().length + " nodes.");
		        cyjshiny_log("  initial widget dimensions: " +
                            $("#cyjShiny").width() + ", " +
                            $("#cyjShiny").height());

			cyj.nodes().map(function(node){node.data({degree: node.degree()})});
                        cyj.on('tap', function(evt){
			    var id = "canvas";  // if not node or edge, tap was on the cyjs canvas
			    if(typeof(evt.target.id) != "undefined"){
				id = evt.target.id();
			       }
			    cyjshiny_log("tapped: ", id)
			    Shiny.setInputValue("selection", id, {priority: "event"});

			})
			//setTimeout(function() {
			//    cyj.fit(10)
			//}, 600);
		    }, // ready
		}) // cytoscape()
            }, // renderValue
            resize: function(width, height) {
		cyjshiny_log("widget resize");
		var parentWidth = $("#cyjShiny").parent().width()
		var parentHeight = $("#cyjShiny").parent().height()
		cyjshiny_log("widget resize, parentWidth: " + parentWidth + "  height: " + parentHeight);
		$("#cyjShiny").width(parentWidth)
		$("#cyjShiny").height(parentHeight)
	    },
            cyjWidget: cyj
        }; // return
    } // factory
});  // widget
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("doLayout", function(message){

    var strategy = message.strategy;
    self.cyj.layout({name: strategy}).run()
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("getNodePositions", function(message){

    cyjshiny_log("--- entering getNodePositions, customMessangeHandler")
    var tbl = JSON.stringify(self.cyj.nodes().map(function(n){return{id: n.id(),
                                                                     x: n.position().x,
                                                                     y: n.position().y}}));
    cyjshiny_log(tbl)
    Shiny.setInputValue("tbl.nodePositions", tbl,  {priority: "event"});
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("setNodePositions", function(message){

    cyjshiny_log("--- entering setNodePositions, customMessangeHandler")
    cyjshiny_log(message.tbl)

    var tbl = message.tbl; // JSON.parse(message.tbl)

    cyjshiny_log("calling setPosition map");
    tbl.map(function(e){
       var tag="[id='" + e.id + "']";
       self.cyj.$(tag).position({x: e.x, y:e.y});
       });

    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("removeGraph", function(message){

    self.cyj.elements().remove();
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("addGraph", function(message){

    var jsonString = message.graph;
    var g = JSON.parse(jsonString);
    self.cyj.add(g.elements);
    self.cyj.fit(50);
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("redraw", function(message){

    cyjshiny_log("redraw requested");
    self.cyj.style().update();
    })

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("setNodeAttributes", function(message){

    cyjshiny_log("setNodeAttributes requested")

    var nodeIDs = message.nodes;
    var attributeName = message.attribute;

    for(var i=0; i < nodeIDs.length; i++){
       var id = nodeIDs[i];
       var newValue = message.values[i];
       var node = self.cyj.getElementById(id);
       node.data({[attributeName]:  newValue});
       };
})
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("setEdgeAttributes", function(message){

    cyjshiny_log("setEdgeAttributes requested")

    var attributeName = message.attributeName;
    var sourceNodes = message.sourceNodes;
    var targetNodes = message.targetNodes;
    var interactions = message.interactions;
    var values = message.values

   for(var i=0; i < sourceNodes.length; i++){
      var id = sourceNodes[i] + "-(" + interactions[i] + ")-" + targetNodes[i];
      cyjshiny_log("edge id: " + id)
      var edge = self.cyj.getElementById(id)
      cyjshiny_log(edge)
      if(edge != undefined){
         cyjshiny_log("setting edge " + attributeName + " to " + values[i])
         edge.data({[attributeName]: values[i]})
         }
      } // for i

}) // setEdgeAttributes
//----------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("selectNodes", function(message){

   cyjshiny_log("selectNodes requested (16 apr 2020, 835a) : " + message);

   var nodeIDs = message;

   if(typeof(nodeIDs) == "string")
      nodeIDs = [nodeIDs];

   var filterStrings = [];

   for(var i=0; i < nodeIDs.length; i++){
     var s = '[id="' + nodeIDs[i] + '"]';
     filterStrings.push(s);
     } // for i

   cyjshiny_log("filtersStrings, joined: " + filterStrings.join());

   var nodesToSelect = window.cyj.nodes(filterStrings.join());
   nodesToSelect.select()

});
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("clearSelection", function(message){

    cyjshiny_log("clearSelection requested: " + message);
    self.cyj.filter("node:selected").unselect();

})
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("showAll", function(message){

    cyjshiny_log("showAll requested: " + message);
    self.cyj.nodes().show()
    self.cyj.edges().show()

})
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("invertSelection", function(message){

    cyjshiny_log("invertSelection requested: " + message);
    var currentlySelected = self.cyj.filter("node:selected");
    self.cyj.nodes().select();
    currentlySelected.unselect();
})
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("getCurrentSelection", function(message){

    cyjshiny_log("--- currentSelection requested ");
    var currentlySelected = self.cyj.filter("node:selected");
    Shiny.setInputValue("currentSelection", currentlySelected, {priority: "event"});

})
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("hideSelection", function(message){

    cyjshiny_log("hideSelection requested: " + message);
    self.cyj.filter("node:selected").hide();

})
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("getSelectedNodes", function(message){

    cyjshiny_log("getSelectedNodes requested: " + message);
    var value = self.cyj.filter("node:selected")
        .map(function(node) {
            return(node.data().id)})
             //return {id: node.data().id, label: node.data().label}})

    cyjshiny_log(self.cyj.filter("node:selected"));
    cyjshiny_log(value)
    Shiny.setInputValue("selectedNodes", value, {priority: "event"});

});
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("sfn", function(message){

    cyjshiny_log("sfn requested: " + message);
    self.cyj.nodes(':selected').neighborhood().nodes().select();

})
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("fitSelected", function(message){

    cyjshiny_log("fitSelected requested");
    var padding = message.padding;

    var selectedNodes = self.cyj.filter("node:selected");

    if(selectedNodes.length == 0){
	cyjshiny_log("no nodes currently selected")
     }
   else{
       cyjshiny_log("fitSelected, with padding " + padding);
       self.cyj.fit(selectedNodes, padding)
   }
})
//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("fit", function(message){
    cyjshiny_log("fit requested: ");
    var padding = message.padding;
    cyjshiny_log("   padding: " + padding)
    self.cyj.fit(padding);
    });
//------------------------------------------------------------------------------------------------------------------------
// this can be confusing
//   the message is a javascript object with one field: json
//   that field's value is a character string representation of a graph
//   parse that string into a JSON object, graph, which has one top-level field, "elements"
//     and two immediate subfields:  nodes & edges
//   add graph.elements to cytoscape.js ("cyj")
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("loadJSONNetwork", function(message) {

    window.cyj.remove(window.cyj.elements());
    cyjshiny_log("--- loadJSONNetwork")
    window.msg = message;
    var graph = JSON.parse(message.json)
    window.cyj.add(graph.elements);
    window.cyj.fit(50)
    });

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("loadStyle", function(message) {

    cyjshiny_log("loading style");
    //var styleSheet = message.json;
    cyjshiny_log(message)
    var style = JSON.parse(message.json)
    if(style == "default style")
        style = defaultStyle;
    window.cyj.style(style);
    });

//------------------------------------------------------------------------------------------------------------------------
if(HTMLWidgets.shinyMode) Shiny.addCustomMessageHandler("savePNGtoFile", function(message){

   cyjshiny_log("savePNGtoFile: " + message);
   var pngJSON = JSON.stringify(window.cyj.png());
   Shiny.setInputValue("pngData", pngJSON, {priority: "event"});

})
//------------------------------------------------------------------------------------------------------------------------
