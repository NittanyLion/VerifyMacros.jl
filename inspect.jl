using Pkg
Pkg.activate(; temp=true)
Pkg.add(["ArgCheck"])
Pkg.develop(path=".")
using VerifyMacros
using ArgCheck

function check_verify_true(x)
    @verifytrue x > 0
end

function check_argcheck_true(x)
    @argcheck x > 0
end

println("Macro expansion for @verifytrue x > 0:")
println(@macroexpand @verifytrue x > 0)

println("\nMacro expansion for @argcheck x > 0:")
println(@macroexpand @argcheck x > 0)

println("\nMacro expansion for @verifytype x Int:")
println(@macroexpand @verifytype x Int)
