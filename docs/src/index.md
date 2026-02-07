```@meta
CurrentModule = VerifyMacros
```

# VerifyMacros.jl

Documentation for [VerifyMacros.jl](https://github.com/NittanyLion/VerifyMacros.jl).

**VerifyMacros.jl** is your toolkit for **runtime verification** with **style**. 💅

Stop writing boilerplate checks and manual error messages. Use `VerifyMacros` to assert conditions and get descriptive, color-coded error output that tells you exactly what went wrong.

## 📦 Installation

```julia
using Pkg
Pkg.add("VerifyMacros")
```

## 🚀 Usage

### 🔍 Single Verifications

Validate types, keys, dimensions, and more.

#### Types & Structure
```julia
using VerifyMacros

x = 1.0
@verifytype x Float64  # ✅ Passes
@verifytype x Int      # ❌ Throws: TypeError: x is of type Float64; was expecting a Int
```

#### Dictionaries & Properties
```julia
d = Dict(:a => 1)
@verifykey d :a        # ✅ Passes
@verifykey d :b        # ❌ Throws: KeyError: d lacks key :b

struct Obj; p; end
o = Obj(1)
@verifyproperty o :p   # ✅ Passes
```

#### Collections & Dimensions
```julia
A = [1, 2]
@verifyaxes A (1:2,)   # ✅ Passes
@verifyin 1 A          # ✅ Passes
@verifylength A 2      # ✅ Passes
```

### 📦 Batch Verifications

Check everything at once. Clean and efficient.

```julia
# Check multiple types
@verifytypes (x, Float64) (1, Int)

# Check multiple keys
@verifykeys (d, :a) (d, :b)
# OR shorthand for one dict:
@verifykeys(d, :a, :b, :c)

# Check multiple files
@verifyisfiles ("config.json",) ("data.csv",)
```


### 🛠️ The Meta-Macro: `@verify`

If you prefer a single entry point, use `@verify`. The first argument is a symbol (e.g., `:type`, `:keys`) which determines which check to run.

```julia
@verify :type x Float64      # expands to @verifytype x Float64
@verify :keys d :a :b        # expands to @verifykeys d :a :b
@verify :true 1 < 2          # expands to @verifytrue 1 < 2
```


## 🆚 Comparison with ArgCheck.jl

### bird's eye view

You might know [ArgCheck.jl](https://github.com/jw3126/ArgCheck.jl), which is excellent for concise argument checking. Here's how `VerifyMacros.jl` differs:

| Feature | ArgCheck.jl (`@argcheck`) | VerifyMacros.jl (`@verify...`) |
| :--- | :--- | :--- |
| **Philosophy** | Concise preconditions | Descriptive, specific failure context |
| **Error Type** | `ArgumentError` (mostly) | `TypeError`, `KeyError`, `DimensionMismatch`, etc. |
| **Message** | Generic or manual string | **Auto-generated**, descriptive, and **styled** (colored) |
| **Usage** | `@argcheck x > 0` | `@verifytype x Int` or `@verifykey d :id` |
| **Best For** | Function preconditions | Data validation, debugging complex state, helpful errors |

**Choose VerifyMacros.jl when you want your users (or future you) to know exactly _why_ a check failed without digging into the stack trace.**

### examples


#### example 1

!!! info "As the following comparison demonstrates, `VerifyMacros`,"
    * provides a detailed error message without further user interaction
    * colors are used to make it immediately apparent what the error is
    * identifies where in the code the error is


```@repl
using Random, ArgCheck
left = "WEEfgfweew11"; right = "fsdRweWERERGere"; 
D =  Dict( j => left * randstring( 4 ) * right for j ∈ 1:40 );
needle = left * "abcd" * right
@argcheck haskey( D, needle )
```


```@repl
using Random, VerifyMacros
left = "WEEfgfweew11"; right = "fsdRweWERERGere"; 
D =  Dict( j => left * randstring( 4 ) * right for j ∈ 1:40 );
needle = left * "abcd" * right
@verifykey D needle 
```



#### example 2

!!! info "As the following example demonstrates, `VerifyMacros` further"
    * deals with multiple conditions naturally
    * identifies which condition fails

```@repl
using ArgCheck

D = Dict( :a=>1, 2 =>:b, :c => :3 );
@argcheck haskey( D, :a ) && haskey( D, :b ) && haskey( D, :c )
```

```@repl
using VerifyMacros
D = Dict( :a=>1, 2 =>:b, :c => :3 );
@verifykeys D :a :b :c
```

```@repl
using VerifyMacros
D = Dict( :a=>1, 2 =>:b, :c => :3 );
@verify :keys D :a :b :c
```

#### example 3

!!! info "This also applies to the same type of condition on multiple objects"
    - with ArgCheck an alternative would be to have as many lines of code as you have conditions to check

```@repl
using ArgCheck
x = 1.0; y = 3;
@argcheck x isa Float64 || y isa AbstractString
```

```@repl
using VerifyMacros
x = 1.0; y = 3;
@verifytypes ( x, Float64) ( y, AbstractString )
```

#### example 4

!!! info "And you can combine multiple checks"
    - with the caveat that you need to use the catchall `@verifytrues`


```@repl
using ArgCheck
D = Dict( :a=>1, 2 =>:b, :c => :3 );
@argcheck haskey( D, :a ) &&  D[:a] isa AbstractFloat 
```


```@repl
using VerifyMacros
D = Dict( :a=>1, 2 =>:b, :c => :3 );
@verifytrues haskey( D, :a )  D[:a] isa AbstractFloat 
```



## 🛠️ Available Macros

| Macro | Description |
| :--- | :--- |
| `@verify` | Meta macro (see above) |
| `@verifytype` | Check type of value (`isa`) |
| `@verifykey` | Check key in dictionary (`haskey`) |
| `@verifyproperty` | Check property of object (`hasproperty`) |
| `@verifyfield` | Check field of type (`hasfield`) |
| `@verifyin` | Check membership (`in`) |
| `@verifysupertype`| Check subtype relation (`<:`) |
| `@verifyaxes` | Check array axes |
| `@verifysize` | Check array size |
| `@verifylength` | Check collection length |
| `@verifyequal` | Check equality (`==`) |
| `@verifyisfile` | Check file existence |
| `@verifyisdir` | Check directory existence |
| `@verifytrue` | Generic assertion |

*All macros have plural versions (e.g., `@verifytypes`) for batch checking.*

## Reference

```@index
```

```@autodocs
Modules = [VerifyMacros]
```