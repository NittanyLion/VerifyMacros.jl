using VerifyMacros, ArgCheck


D = Dict( :a=>1, 1 =>:a )

@argcheck haskey( D, :a ) && haskey( D, :b )
@verifykeys D :a :b
