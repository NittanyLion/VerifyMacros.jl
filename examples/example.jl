# ==============================================================================
#  ArgCheck.jl vs VerifyMacros.jl Comparison
# ==============================================================================
#
# This example demonstrates the difference in philosophy and output between
# ArgCheck.jl (concise preconditions) and VerifyMacros.jl (descriptive, styled verification).
#
# To run this example:
#   julia --project=examples examples/example.jl
#
# Note: This script will install ArgCheck.jl in the examples environment if needed.

using Pkg
Pkg.activate(@__DIR__)
Pkg.develop(path=joinpath(@__DIR__, ".."))
Pkg.add("ArgCheck")

using VerifyMacros
using ArgCheck
using StyledStrings

# Helper to print separators
function print_header(title)
    println()
    println(styled"{bold,cyan:=== $title ===}")
    println()
end

function print_scenario(name)
    println(styled"{bold,yellow:--- Scenario: $name ---}")
end

# Helper to catch and display errors
function compare_checks(description, verify_fn, argcheck_fn)
    print_scenario(description)
    
    println("1. Running ArgCheck.jl check...")
    try
        argcheck_fn()
        println(styled"{green:  ✓ ArgCheck passed}")
    catch e
        if e isa ArgumentError
            # ArgCheck typically throws ArgumentError
            println(styled"{red:  ✗ ArgCheck failed with:}")
            println( "    ", styled"{magenta:$(e.msg)}" ) 
        else
            println(styled"{red:  ✗ ArgCheck failed with unexpected error:}")
            showerror(stdout, e)
            println()
        end
    end
    println()

    println("2. Running VerifyMacros.jl check...")
    try
        verify_fn()
        println(styled"{green:  ✓ VerifyMacros passed}")
    catch e
        # VerifyMacros throws various errors (TypeError, KeyError, etc.) with styled messages
        println(styled"{red:  ✗ VerifyMacros failed with:}")
        # We print the error message directly to show the styling
        if e isa ErrorException
            println("    ", e.msg)
        else
            showerror(stdout, e)
            println()
        end
    end
    println()
end

print_header("Comparison: ArgCheck vs VerifyMacros")

# ------------------------------------------------------------------------------
# Scenario 1: Type Checking
# ------------------------------------------------------------------------------
val = 10
expected_type = Float64

compare_checks("Type Checking (Expected Float64, got Int)", 
    () -> @verifytype(val, Float64),
    () -> @argcheck val isa Float64
)

# ------------------------------------------------------------------------------
# Scenario 2: Dictionary Keys
# ------------------------------------------------------------------------------
data = Dict(:name => "Alice", :age => 30)
missing_key = :email

compare_checks("Dictionary Key (Missing key :email)", 
    () -> @verifykey(data, missing_key),
    () -> @argcheck haskey(data, missing_key)
)

# ------------------------------------------------------------------------------
# Scenario 3: Custom Error Messages
# ------------------------------------------------------------------------------
x = -5

compare_checks("Custom Condition (x > 0)", 
    () -> @verifytrue(x > 0, "x ≯ 0"),
    () -> @argcheck x > 0 "x must be positive"
)

# ------------------------------------------------------------------------------
# Scenario 4: Axes Verification
# ------------------------------------------------------------------------------
A = [1, 2]
expected_axes = (1:3,) # Mismatch: A has axes (1:2,)

compare_checks("Axes Verification (Expected 1:3, got 1:2)", 
    () -> @verifyaxes(A, expected_axes),
    () -> @argcheck axes(A) == expected_axes
)

# ------------------------------------------------------------------------------
# Scenario 5: Bulk Verification
# ------------------------------------------------------------------------------
# Checking multiple conditions at once.
# Note: ArgCheck typically checks one condition at a time or requires && which fails on the first false.

a = 1
b = "string"

# Here we expect (a::Int, b::Float64) -- b will fail
compare_checks("Bulk Verification (Mixed types)", 
    () -> @verifytypes((a, Int), (b, Float64)),
    () -> @argcheck (a isa Int) && (b isa Float64)
)

# ------------------------------------------------------------------------------
# Scenario 6: Bulk Verification (Multiple items, one failure)
# ------------------------------------------------------------------------------
items = [(1, Int), (2, Int), (3.0, Float64), ("fail", Int), (5, Int)]

compare_checks("Bulk Verification (Many valid, one invalid)",
    () -> begin
        # VerifyMacros processes them in order and fails on the first one
        @verifytypes (1, Int) (2, Int) (3.0, Float64) ("fail", Int) (5, Int)
    end,
    () -> begin
         @argcheck (1 isa Int) && (2 isa Int) && (3.0 isa Float64) && ("fail" isa Int) && (5 isa Int)
    end
)

# ------------------------------------------------------------------------------
# Scenario 7: Bulk Verification (Large Dictionary)
# ------------------------------------------------------------------------------
large_dict = Dict(Symbol("k$i") => i for i in 1:100)
# Let's say we expect keys :k1 to :k50 to be present, but :k1000 is missing
expected_keys = [Symbol("k$i") for i in 1:50]
push!(expected_keys, :k1000) # This one is missing

compare_checks("Bulk Verification (Dictionary keys)",
    () -> begin
        # We can unpack the array into the macro
        @verifykeys large_dict expected_keys...
    end,
    () -> begin
        # ArgCheck needs a manual loop or check
        @argcheck all(haskey(large_dict, k) for k in expected_keys)
    end
)

# ------------------------------------------------------------------------------
# Scenario 6: Bulk Verification (Multiple items, one failure)
# ------------------------------------------------------------------------------
compare_checks("Bulk Verification (Many valid, one invalid)",
    () -> begin
        # VerifyMacros processes them in order and fails on the first one
        @verifytypes (1, Int) (2, Int) (3.0, Float64) ("fail", Int) (5, Int)
    end,
    () -> begin
         @argcheck (1 isa Int) && (2 isa Int) && (3.0 isa Float64) && ("fail" isa Int) && (5 isa Int)
    end
)

# ------------------------------------------------------------------------------
# Scenario 7: Bulk Verification (Large Dictionary)
# ------------------------------------------------------------------------------
large_dict = Dict(Symbol("k$i") => i for i in 1:100)
# We expect keys :k1 to :k50 to be present, but :k1000 is missing
expected_keys = [Symbol("k$i") for i in 1:50]
push!(expected_keys, :k1000) # This one is missing

compare_checks("Bulk Verification (Dictionary keys)",
    () -> begin
        # For runtime collections, use a loop.
        # We provide a custom name "data" to avoid printing the huge dict in the error.
        foreach(k -> @verifykey(large_dict, k, "data"), expected_keys)
    end,
    () -> begin
        # ArgCheck needs a manual loop or check
        @argcheck all(haskey(large_dict, k) for k in expected_keys)
    end
)

# ------------------------------------------------------------------------------
# Scenario 8: The Meta-Macro @verify
# ------------------------------------------------------------------------------
print_header("Using the @verify meta-macro")

println("VerifyMacros allows a unified syntax:")
println("  @verify :type val Float64")
println("  @verify :keys data :name :email")

println("\nRunning @verify :keys data :name :email (where :email is missing)...")
try
    @verify :keys data :name :email
catch e
    showerror(stdout, e)
    println()
end

print_header("Summary")
println( styled"""
{bold:ArgCheck.jl} is great for internal consistency checks where a simple "ArgumentError" is sufficient.
{bold:VerifyMacros.jl} provides specialized error types (TypeError, KeyError) and rich, colorful messages 
that help users identify exactly *what* went wrong and *where*.
""" )
