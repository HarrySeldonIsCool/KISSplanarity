module Color2
export Coloring, validate, opposite!, similar!, show

const ColoringGraph = Array{Vector{Tuple{Int, Int}}, 2}

struct Coloring
	opp::ColoringGraph
	sim::ColoringGraph
end

function show(c::Coloring)
	println("opp:")
	for i in 1:size(c.opp)[1]
		for j in 1:size(c.opp)[2]
			c.opp[i, j] != [] || continue
			print("\t$i->$j:")
			for e in c.opp[i, j]
				print(" ($(e[1])->$(e[2]))")
			end
			println()
		end
	end
	println("sim:")
	for i in 1:size(c.sim)[1]
		for j in 1:size(c.sim)[2]
			c.sim[i, j] != [] || continue
			print("\t$i->$j:")
			for e in c.sim[i, j]
				print(" ($(e[1])->$(e[2]))")
			end
			println()
		end
	end
end

function validate1!(col::Coloring, c, e)
	for e2 in col.opp[e[1], e[2]]
		if c[e2[1], e2[2]] == 0
			c[e2[1], e2[2]] = -c[e[1], e[2]]
			validate1!(col, c, e2) || return false
		elseif c[e2[1], e2[2]] == c[e[1], e[2]]
			return false
		end
	end
	for e2 in col.sim[e[1], e[2]]
		if c[e2[1], e2[2]] == 0
			c[e2[1], e2[2]] = c[e[1], e[2]]
			validate1!(col, c, e2) || return false
		elseif c[e2[1], e2[2]] == -c[e[1], e[2]]
			return false
		end
	end
	true
end

function validate(col::Coloring, edges::Vector{Tuple{Int, Int}})
	c = fill(0, size(col.opp))
	for e in edges
		if c[e[1], e[2]] == 0
			c[e[1], e[2]] = 1
			validate1!(col, c, e) || return false	
		end
	end
	true
end

function opposite!(col::Coloring, a, b)
	for x in a
		for y in b
			push!(col.opp[x[1], x[2]], y)
			push!(col.opp[y[1], y[2]], x)
		end
	end
end

function similar!(col::Coloring, a)
	for x in a
		for y in a
			x != y && push!(col.sim[x[1], x[2]], y)
		end
	end
end
end
