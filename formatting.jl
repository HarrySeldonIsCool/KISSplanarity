module Formatting
export graph

function graph()
	n = parse(Int, readline())
	g = fill([], n)
	for i in 1:n
		g[i] = vertex()
	end
	g
end

function vertex()
	v = []
	s = readline()
	e = split(s, ": ")[2]
	for v2 in eachsplit(e, " ")
		if strip(v2, [' ', ';']) == ""
			continue
		end
		push!(v, parse(Int, strip(v2, [' ', ';']))+1)
	end
	v
end

end
