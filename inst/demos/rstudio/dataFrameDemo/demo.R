library(cyjShiny)

# NOT WORKING (2023-03-20)

print(load(system.file(package="cyjShiny", "extdata", "graph.11nodes.14edges.RData")))
cyj <- cyjShiny(g, layoutName="preset")

