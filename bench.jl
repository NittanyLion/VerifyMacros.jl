using Pkg
Pkg.activate(; temp=true)
Pkg.add(["ArgCheck", "BenchmarkTools"])
Pkg.develop(path=".") # Develop the current package

using VerifyMacros
using ArgCheck
using BenchmarkTools

function test_verify(x)
    @verifytype x Int
end

function test_argcheck(x)
    @argcheck x isa Int
end

function test_verify_true(x)
    @verifytrue x > 0
end

function test_argcheck_true(x)
    @argcheck x > 0
end

function test_verify_keys(D)
    @verifykeys D :x :y :z
end

function test_argcheck_keys(D)
    @argcheck haskey( D, :x )
    @argcheck haskey( D, :y )
    @argcheck haskey( D, :z )
end



println("Benchmarking @verifytype vs @argcheck (isa Int)")
val = 1
b1 = @benchmark test_verify($val)
b2 = @benchmark test_argcheck($val)

display(b1)
display(b2)

println("\nBenchmarking @verifytrue vs @argcheck (x > 0)")
val2 = 1
b3 = @benchmark test_verify_true($val2)
b4 = @benchmark test_argcheck_true($val2)

display(b3)
display(b4)


println("\nBenchmarking @verifykey vs @argcheckkeys")
val3 = Dict( :x => 1, :y => 2, :z => 3 )
b5 = @benchmark test_verify_keys($val3)
b6 = @benchmark test_argcheck_keys($val3)

display(b5)
display(b6)
