module VerifyMacros

using PrecompileTools

export @verifytype, @verifykey, @verifyproperty, @verifysupertype, @verifyaxes, @verifyfield
export @verifytypes, @verifykeys, @verifyproperties, @verifysupertypes, @verifyaxes_list, @verifyfields

include( "verify.jl" )

@setup_workload begin
    # Data for precompilation
    l = LineNumberNode(1, :none)
    d = Dict(:a => 1)
    nt = (a=1,)
    arr = [1]
    
    @compile_workload begin
        # Exercise verifytype
        verifytype(1, Int, "int", l)
        verifytype("s", String, "str", l)
        
        # Exercise verifykey
        verifykey(d, :a, "dict", l)
        
        # Exercise verifyproperty
        verifyproperty(nt, :a, "nt", l)
        
        # Exercise verifysupertype
        verifysupertype(Int, Integer, "int_type", l)
        
        # Exercise verifyaxes
        verifyaxes(arr, (Base.OneTo(1),), "arr", l)
        
        # Exercise verifyfield
        verifyfield(Complex{Int}, :re, "complex", l)
    end
end

end
