module Color
export Coloring, validate, opposite!, similar!

const ColoringGraph = Vector{Vector{Int}}

struct Coloring
	opp::ColoringGraph
	sim::ColoringGraph
end

function validate1!(col::Coloring, c, v)
	for v2 in col.opp[v]
		if c[v2] == 0
			c[v2] = -c[v]
			if !validate1!(col, c, v2)
				return false
			end
		elseif c[v2] != -c[v]
			return false
		end
	end
	for v2 in col.sim[v]
		if c[v2] == 0
			c[v2] = c[v]
			if !validate1!(col, c, v2)
				return false
			end
		elseif c[v2] != c[v]
			return false
		end
	end
	true
end

function validate(col::Coloring)
	c = zeros(length(col.opp))
	for v in 1:length(c)
		if c[v] == 0
			c[v] = 1
			if !validate1!(col, c, v)
				return false
			end
		end
	end
	true
end

function opposite!(col::Coloring, a::Vector{Int}, b::Vector{Int})
	for v in a
		for v2 in b
			push!(col.opp[v], v2)
			push!(col.opp[v2], v)
		end
	end
end

function similar!(col::Coloring, a::Vector{Int})
	for v in a
		for v2 in a
			if v != v2
				push!(col.sim[v], v2)
			end
		end
	end
end

end
