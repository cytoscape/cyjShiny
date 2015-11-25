// Wait for cy to be defined and then add event listener
$(document).ready(function() {
  Shiny.addCustomMessageHandler("saveImage",
    function(message) {
      //console.log("saveImage");
      
      var result = cy.png(); 
      //Shiny.onInputChange("imgContent", result);
      console.log("imgContent: " + result);
      
      // From: http://stackoverflow.com/questions/25087009/trigger-a-file-download-on-click-of-button-javascript-with-contents-from-dom
      dl = document.createElement('a');
      document.body.appendChild(dl);
      dl.download = "download.png";
      dl.href = result;
      dl.click();
    }
  );
});

Shiny.addCustomMessageHandler("testMessage",
  function(message) {
    alert(JSON.stringify(message));
  }
);