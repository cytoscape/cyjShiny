Shiny.addCustomMessageHandler("selectNodes",
  function(message) {
      console.log("selectNodes")
  }
);
Shiny.addCustomMessageHandler("loadStyleFile",
  function(message) {
      console.log("loadStyleFile")
  }
);
