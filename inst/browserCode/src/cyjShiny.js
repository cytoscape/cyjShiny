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
    return {
      renderValue: function(x) {
          console.log("---- ~/github/cyjsShiny/inst/browserCode/src/cyjShiny.js, renderValue")
          var cyDiv = el;
          cytoscape({
              container: cyDiv,
              elements: {
                  nodes: [
                      {data: {id: 'a', name: 'Node A', type: 'big' }},
                      {data: {id: 'b', name: 'Node B', type: 'little'}},
                  ],
                  edges: [
                      {data: {source: 'a', target: 'b'}},
                      {data: {source: 'b', target: 'a'}}
                  ]
              },
              ready: function(){
                  cyjs = this;
                  console.log("small cyjs network ready, with " + cyjs.nodes().length + " nodes.");
              } // ready
             }) // cytoscape()
           } // renderValue
        };
    } // factory
});  // widget
