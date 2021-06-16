app <- ShinyDriver$new("../../")
app$snapshotInit("test01")

app$snapshot()
app$setInputs(newPlotButton = "click")
app$snapshot()
app$setInputs(newPlotButton = "click")
app$snapshot()
