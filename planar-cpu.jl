include("formatting.jl")
include("planarity2.jl")
using .Formatting
using .Planarity2

while !eof(stdin)
	g::Graph = graph()
	println(planarity(g))
end
