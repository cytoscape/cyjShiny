app <- ShinyDriver$new("../../")
app$snapshotInit("test_01")

app$snapshot()
app$snapshot()
app$setInputs(getSelectedNodes = "click")
app$snapshot()
