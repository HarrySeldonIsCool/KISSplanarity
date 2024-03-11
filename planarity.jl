using Base.Math
using CUDA

global maxn = 16

function dfs_elp!(g, explored, num, parent, edges, lowpts)
	num[0] = 0
	stack = zeros(UInt8, 1)
	nstack = zeros(UInt8, 1)
	nd = 0
	for i = 0:maxn
		lowpts[i] = i
	end
	while !isempty(stack)
		while last(stack) != 0
			a = last(stack) & -last(stack)
			stack[lastindex(stack)] &= last(stack) - 1
			if a & explored != 0 && last(nstack) < num[exponent(a)]
				lowpts[last(nstack)] = min(lowpts[last(nstack)], lowpts[num[exponent(a)]])
			elseif a & explored != 0
				lowpts[last(stack)] = min(lowpts[last(nstack)], num[exponent(a)])
			else
				explored |= a
				push!(stack, g[exponent(a)])
				nd += 1
				edges[nd] = last(nstack)
				push!(nstack, nd)
				num[exponent(a)] = nd
				break
			end
		end
		if last(stack) == 0
			pop!(stack)
			pop!(nstack)
		end
	end
end

function dfs!(g)
	explored = 0
	num = zeros(1)
	edges = Array{UInt8}(undef, 16)
	while explored != 1 << maxn-1
		i = exponent(~explored & explored+1)
		parent = i
		dfs_elp!(g, explored, num, i, parent, edges)
	end
	return num
end


