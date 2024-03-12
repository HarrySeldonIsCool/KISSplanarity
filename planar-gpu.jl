include("planarity.jl")
include("formatting.jl")
using .Planarity
using .Formatting
using CUDA

function distribute!(g, res)
	i = threadIdx().x
	println(i)
	res[i] = planarity(g[i])
end

threads = 64

g = CUDA.fill([], threads)
res = CUDA.fill(false, threads)
while !eof(stdin)
	for i in 1:threads
		g[i] = graph()
	end
	CUDA.@sync begin
		@cuda threads=threads distribute!(g, res)
	end
	for x in Array(res)
		println(x)
	end
end
