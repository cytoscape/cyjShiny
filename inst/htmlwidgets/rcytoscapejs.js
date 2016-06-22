HTMLWidgets.widget({
    name: 'rcytoscapejs',
    type: 'output',

    initialize: function (el, width, height) {
        return {
            // TODO: add instance fields as required
        }
    },

    resize: function (el, width, height, instance) {
        if (instance.cy)
            instance.cy.resize();
    },

    renderValue: function (el, x, instance) {
        //console.log(x.nodeEntries);
        //console.log(x.edgeEntries);

        //var nodetest = JSON.parse(x.nodeEntries);
        //var edgetest = JSON.parse(x.edgeEntries);

        //console.log(nodetest);
        //console.log(edgetest);
        
        //Panzoom defaults
        var defaults = ({
          zoomFactor: 0.05, // zoom factor per zoom tick
          zoomDelay: 45, // how many ms between zoom ticks
          minZoom: 0.1, // min zoom level
          maxZoom: 10, // max zoom level
          fitPadding: 50, // padding when fitting
          panSpeed: 10, // how many ms in between pan ticks
          panDistance: 10, // max pan distance per tick
          panDragAreaSize: 75, // the length of the pan drag box in which the vector for panning is calculated (bigger = finer control of pan speed and direction)
          panMinPercentSpeed: 0.25, // the slowest speed we can pan by (as a percent of panSpeed)
          panInactiveArea: 8, // radius of inactive area in pan drag box
          panIndicatorMinOpacity: 0.5, // min opacity of pan indicator (the draggable nib); scales from this to 1.0
          autodisableForMobile: true, // disable the panzoom completely for mobile (since we don't really need it with gestures like pinch to zoom)
      
          // icon class names
          sliderHandleIcon: 'fa fa-minus',
          zoomInIcon: 'fa fa-plus',
          zoomOutIcon: 'fa fa-minus',
          resetIcon: 'fa fa-expand'
        });
        
        var positionMap = {};
        
        //add position information to data for preset layout
        for (var i = 0; i < x.nodeEntries.length ; i++){
            var xPos = x.nodeEntries[i].data.x;
            var yPos = x.nodeEntries[i].data.y;
            positionMap[x.nodeEntries[i].data.id] = {'x':parseFloat(xPos), 'y':parseFloat(yPos)};
        }

        instance.cy = new cytoscape({
            container: el,
            autoungrabify: false, 
            style: cytoscape.stylesheet()
                .selector('node')
                .css({
                    'color': 'data(nodeLabelColor)',
                    'content': 'data(name)',
                    'text-valign': 'center',
                    'shape': 'data(shape)',
                    'text-outline-color': 'data(color)',
                    'background-color': 'data(color)',
                    'width': 'data(width)',
                    'height': 'data(height)'
                })
                .selector('edge')
                .css({
                    'line-color': 'data(color)',
                    'source-arrow-color': 'data(color)',
                    'target-arrow-color': 'data(color)',
                    'source-arrow-shape': 'data(edgeSourceShape)',
                    'target-arrow-shape': 'data(edgeTargetShape)'
                })
                .selector(':selected')
                .css({
                    'background-color': '#FF00FF',
                    'line-color': 'black',
                    'target-arrow-color': 'black',
                    'source-arrow-color': 'black'
                })
                .selector('.highlighted')
                .css({
                    'background-color': '#FF00FF',
                    'line-color': '#FF00FF',
                    'target-arrow-color': '#FF00FF',
                    'transition-property': 'background-color, line-color, target-arrow-color',
                    'transition-duration': '0.5s'
                })
                .selector('.faded')
                .css({
                    'opacity': 0.25,
                    'text-opacity': 0
                }),

            elements: {
                nodes: x.nodeEntries,
                //nodes: [{ data: { id:'509209821', name:'509209821', color:'#888888', shape:'ellipse', href:''} }, { data: { id:'531376085', name:'531376085', color:'#888888', shape:'ellipse', href:''} }],
                edges: x.edgeEntries
                //edges: [{ data: { source:'509209821', target:'531376085', color:'#888888', edgeSourceShape:'none', edgeTargetShape:'triangle'} }]

            },
            layout: {
                name: x.layout,
                ungrabifyWhileSimulating: true,
                positions: positionMap
            },
            ready: function () {
                window.cy = this;

                $(window).trigger("cy_ready");
  
                if(x.showPanzoom) {
                  cy.panzoom(defaults);                  
                }

                cy.boxSelectionEnabled(x.boxSelectionEnabled);
                cy.userZoomingEnabled(true);
                
                if(x.highlightConnectedNodes) {
                  cy.on('tap', 'node', function (event) {
                      var nodeHighlighted = this.hasClass("highlighted");
                      console.log(nodeHighlighted);
                      var nodes = this.closedNeighborhood().connectedNodes();
                      //console.log(nodes);
                      console.log("A:" + el.id);
                      console.log("ID:" + this._private.data.id);
                      Shiny.onInputChange("clickedNode", this._private.data.id);
                      console.log("break");
  
                      if (nodes.length === 0) {
                        this.toggleClass("highlighted");
                      }
  
                      if (nodeHighlighted) {
                          for (var i = 0; i < nodes.length; i++) {
                              if (nodes[i].hasClass("highlighted")) {
                                  nodes[i].toggleClass("highlighted");
                              }
                          }
                      } else {
                          for (var i = 0; i < nodes.length; i++) {
                              if (!nodes[i].hasClass("highlighted")) {
                                  nodes[i].toggleClass("highlighted");
                              }
                          }
                      }
  
                      var globalnodes = instance.cy.nodes();
                      var selected = [];
                      for (var i = 0; i < globalnodes.length; i++) {
                          if (globalnodes[i].hasClass("highlighted")) {
                              selected.push(globalnodes[i]._private.ids);
                          }
                      }
  
                      //console.log(globalnodes);
                      //console.log(selected);
  
                      var keys = [];
                      for (var i = 0; i < selected.length; i++) {
                          var kk = selected[i];
                          for (var k in kk) keys.push(k);
                      }
                      console.log(keys);
                      Shiny.onInputChange("connectedNodes", keys);
                  });
                }
                
                cy.on('tap', 'edge', function (event) {
                  var edgeHighlighted = this.hasClass("highlighted");
                  console.log(edgeHighlighted);
                  var nodes = this.connectedNodes();
                  
                  console.log("nodes");
                  console.log(nodes);
                  console.log("ID 1:" + nodes[0]._private.data.id);
                  console.log("ID 2:" + nodes[1]._private.data.id);
                  
                  var keys = [nodes[0]._private.data.id, nodes[1]._private.data.id];
                  
                  Shiny.onInputChange("clickedEdge", keys);
                  console.log("break");
                  
                  /*
                  var globalnodes = instance.cy.nodes();
                  var selected = [];
                  for (var i = 0; i < globalnodes.length; i++) {
                      if (globalnodes[i].hasClass("highlighted")) {
                          selected.push(globalnodes[i]._private.ids);
                      }
                  }

                  //console.log(globalnodes);
                  console.log(selected);

                  var keys = [];
                  for (var i = 0; i < selected.length; i++) {
                      var kk = selected[i];
                      for (var k in kk) keys.push(k);
                  }
                  */
                  
                  console.log("keys" + keys);
                  Shiny.onInputChange("edgeConnectedNodes", keys);
                });
                
                cy.on('mouseover', 'node', function (event) {
                    var node = this;
                    Shiny.onInputChange("clickedNode", this._private.data.id);
                    
                    $(".qtip").remove();
                    //console.log(event);
                    
                    var name = node.data("name"); 
                    var href = node.data("href"); 
                    var tooltip = node.data("tooltip"); 
                    console.log("href: " + href);
                    console.log("tooltip: " + tooltip);

                    var target = event.cyTarget;
                    var sourceName = target.data("id");
                    var targetName = target.data("href");
                    console.log(sourceName);
                    //console.log(targetName);

                    var x = event.cyRenderedPosition.x;
                    var y = event.cyRenderedPosition.y;
                    //var x = event.cyPosition.x;
                    //var y = event.cyPosition.y;
                    //console.log("x="+x+" Y="+y);

                    cy.getElementById(node.id()).qtip({
                        content: {
                            text: function (event, api) {
                              // Retrieve content from custom attribute of the $('.selector') elements.
                              if(typeof(tooltip) === "undefined") {
                                return name;
                              } else {
                                return tooltip;  
                              }
                            }
                        },
                        show: {
                            ready: true
                        },
                        position: {
                            my: 'top center',
                            at: 'bottom center',
                            adjust: {
                              cyViewport: true
                            },
                            effect: false
                        },
                        hide: {
                            fixed: true,
                            event: false,
                            inactive: 2000
                        },
                        style: {
                            classes: 'qtip-bootstrap',
                            tip: {
                              width: 16,
                              height: 8
                            }
                        }
                    });
                });
            }
        });
    }
});
