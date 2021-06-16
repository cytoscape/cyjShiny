
  choose a test directory,
  place app.R there 
  perhaps this is a subdirectory of pkg/inst/unitTests
  here i use unitTests/shinyTestDemonstration
  this app.R 
     1) contains the shiny app you wish to test
     2) it has this concluding line:   
          shinyApp(ui = ui, server = server)

 now record a test of this app
     cd unitTests/shinyTestDemonstration
     1) start R
     2) library(shinytest)
     3) recordTest(".")
     4) this creates a "wrapper app", shows your app with some extra controls
     5) enable "Run test script on exit" - this generates the first json & png files
     6) On exit, save the test script (generated here) in, e.g., "test01"
     7) exercise your app, taking a snapshot at each step
     8) Save script and exit test event recorder

   Saved test code to tests/shinytest/test01.R

    tests/shinytest/test01.R
    tests/shinytest/test01-expected/002.png
    tests/shinytest/test01-expected/003.png
    tests/shinytest/test01-expected/001.png
    tests/shinytest/test01-expected/001.json
    tests/shinytest/test01-expected/003.json
    tests/shinytest/test01-expected/002.json
    tests/shinytest.R

    in unitTests/shinyTestDemonstration, run the tests.
    to do this in batch mode (i.e., not interactively) create 
    shinyTestDemonstration/runTests.R, with just these two lines
  
      library(shinytest)
      testApp(".")

    this single command apparently
       locates app.R in this directory
       looks in the tests directory for the json and png files it will try to reproduce

    simplify and automate:
       create shinyTestDemonstration/runTests.R with just two lines
        library(shinytest)
        testApp(".")
       create shinyTestDemonstration/makefile:
          test:
             R -f runTests.R

    run the test from the shell:

       cd   cyjShiny/explore/scatterplot/unitTests/shinyTestDemonstration/
       make

