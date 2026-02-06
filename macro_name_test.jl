macro mymacro(x)
    return x
end

macro delegator()
    return Expr(:macrocall, Symbol("mymacro"), LineNumberNode(1, :none), 10)
end

macro delegator_at()
    return Expr(:macrocall, Symbol("@mymacro"), LineNumberNode(1, :none), 10)
end

println("Calling @delegator_at")
println(@delegator_at)

try
    println("Calling @delegator")
    println(@delegator)
catch e
    println("Error: ", e)
end
