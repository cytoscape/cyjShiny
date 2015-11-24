// Wait for cy to be defined and then add event listener
$(document).ready(function() {
  Shiny.addCustomMessageHandler("saveImage",
    function(message) {
      console.log("saveImage");
      
      var result = cy.png(); 
      Shiny.onInputChange("imgContent", result);
      console.log("imgContent: " + result);
    }
  );
});

Shiny.addCustomMessageHandler("testMessage",
  function(message) {
    alert(JSON.stringify(message));
  }
);