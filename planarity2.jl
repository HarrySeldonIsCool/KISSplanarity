module Planarity2
export planarity, Graph

include("coloring2.jl")
using .Color2

const Graph = Vector{Vector{Int}}

function dfs1!(g::Graph, explored::BitSet, v::Int, ordering::Vector{Int}, g2::Graph, edges)
	for v2 in g[v]
		t = ordering[v]
		if v2 in explored
			tx = ordering[v2]
			if tx < g2[t][1]	#backward non-tree edge
				push!(g2[t], tx)
				push!(g2[tx], t)
				push!(edges, (t, tx))
			end
		else
			push!(explored, v2)
			top = length(explored)
			ordering[v2] = top
			push!(g2, [t])
			push!(g2[t], top)
			dfs1!(g, explored, v2, ordering, g2, edges)
		end
	end
end

function dfs!(g::Graph, edges)::Graph
	g2::Graph = []
	explored = BitSet([])
	ordering::Vector{Int} = ones(length(g))
	for v in 1:length(g)
		if !(v in explored)
			push!(explored, v)
			push!(g2, [0])
			dfs1!(g, explored, v, ordering, g2, edges)
		end
	end
	g2
end

struct Fringe
	fr::Vector{Tuple{Int, Int}}
	low::Int
end

function planarity1!(g::Graph, v::Int, explored::BitSet, ds::Coloring)
	function fops(a::Fringe, b::Fringe)
		filter((x) -> x[2] > b.low, a.fr)
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
			push!(explored, v2)
			f2 = planarity1!(g, v2, explored, ds)
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
	edges::Vector{Tuple{Int, Int}} = []
	n = length(g)
	e = sum(map(length, g))÷2
	e <= 3*n-6 || return false
	g2 = dfs!(g, edges)
	ds = Coloring(fill([], (n, n)), fill([], (n, n)))
	explored = BitSet([])
	for v in 1:length(g2)
		if !(v in explored)
			push!(explored, v)
			planarity1!(g2, v, explored, ds)
		end
	end
	validate(ds, edges)
end

end
