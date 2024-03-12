module Planarity
export planarity, Graph

include("coloring.jl")
using .Color

const Graph = Vector{Vector{Int}}

function dfs1!(g::Graph, explored::BitSet, v::Int, ordering::Vector{Int}, g2::Graph, numbering)
	for v2 in g[v]
		t = ordering[v]
		if v2 in explored
			tx = ordering[v2]
			if tx < g2[t][1]	#backward non-tree edge
				push!(g2[t], tx)
				push!(g2[tx], t)
				numbering[t, tx] = length(numbering)+1
			end
		else
			push!(explored, v2)
			top = length(explored)
			ordering[v2] = top
			push!(g2, [t])
			push!(g2[t], top)
			dfs1!(g, explored, v2, ordering, g2, numbering)
		end
	end
end

function dfs!(g::Graph, numbering)::Graph
	g2::Graph = []
	explored = BitSet([])
	ordering::Vector{Int} = ones(length(g))
	for v in 1:length(g)
		if !(v in explored)
			push!(explored, v)
			push!(g2, [0])
			dfs1!(g, explored, v, ordering, g2, numbering)
		end
	end
	g2
end

struct Fringe
	fr::Vector{Tuple{Int, Int}}
	low::Int
end

function planarity1!(g::Graph, v::Int, explored::BitSet, ds::Coloring, numbering)
	function fops(a::Fringe, b::Fringe)::Vector{Int}
		map((x) -> numbering[x], filter((x) -> x[2] > b.low, a.fr))
	end
	fringe::Vector{Fringe} = []
	low = v
	for v2 in g[v][2:length(g[v])]
		if v2 in explored
			v2 < v || continue
			#add back edge to DS
			f2 = Fringe([(v, v2)], v2)
			for f in fringe
				similar!(ds, fops(f, f2))
				opposite!(ds, fops(f, f2), fops(f2, f))
			end
			push!(fringe, f2)
			low = min(low, f2.low)
		else
			union!(explored, [v2])
			f2 = planarity1!(g, v2, explored, ds, numbering)
			for f in fringe
				similar!(ds, fops(f, f2))
				similar!(ds, fops(f2, f))
				opposite!(ds, fops(f, f2), fops(f2, f))
			end
			push!(fringe, f2)
			low = min(low, f2.low)
		end
	end
	Fringe(collect(Iterators.filter((x) -> x[2] < g[v][1], Iterators.flatmap((x) -> x.fr, fringe))), low)
end

function planarity(g::Graph)
	numbering = Dict([])
	edges = sum(map(length, g))÷2
	edges <= 3*length(g)-6 || return false
	g2 = dfs!(g, numbering)
	ds = Coloring(fill([], edges), fill([], edges))
	explored = BitSet([])
	for v in 1:length(g2)
		if !(v in explored)
			union!(explored, [v])
			planarity1!(g2, v, explored, ds, numbering)
		end
	end
	validate(ds)
end

end
