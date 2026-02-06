# VerifyMacros.jl 🕵️‍♂️✅

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://NittanyLion.github.io/VerifyMacros.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://NittanyLion.github.io/VerifyMacros.jl/dev/)
[![Build Status](https://github.com/NittanyLion/VerifyMacros.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/NittanyLion/VerifyMacros.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

**VerifyMacros.jl** is your toolkit for **runtime verification** with **style**. 💅

Stop writing boilerplate checks and manual error messages. Use `VerifyMacros` to assert conditions and get descriptive, color-coded error output that tells you exactly what went wrong.

---

## 🆚 Comparison with ArgCheck.jl

You might know [ArgCheck.jl](https://github.com/jw3126/ArgCheck.jl), which is excellent for concise argument checking. Here's how `VerifyMacros.jl` differs:

| Feature | ArgCheck.jl (`@argcheck`) | VerifyMacros.jl (`@verify...`) |
| :--- | :--- | :--- |
| **Philosophy** | Concise preconditions | Descriptive, specific failure context |
| **Error Type** | `ArgumentError` (mostly) | `TypeError`, `KeyError`, `DimensionMismatch`, etc. |
| **Message** | Generic or manual string | **Auto-generated**, descriptive, and **styled** (colored) |
| **Usage** | `@argcheck x > 0` | `@verifytype x Int` or `@verifykey d :id` |
| **Batch Checks** | Fails on combined expression | **Precise**: Identifies exactly *which* constraint failed in a batch |
| **Best For** | Function preconditions | Data validation, debugging complex state, helpful errors |

**Choose VerifyMacros.jl when you want your users (or future you) to know exactly _why_ a check failed without digging into the stack trace, especially when checking multiple constraints simultaneously.**

---

## 📦 Installation

```julia
using Pkg
Pkg.add("VerifyMacros")
```

---

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

### 🛠️ Available Macros

| Macro | Description |
| :--- | :--- |
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

---

## 🎨 Error Messages

When a check fails, `VerifyMacros` uses `StyledStrings` to highlight the culprit.

> **TypeError**: `my_var` is of type `String`; was expecting a `Int64`  
> *at /path/to/file.jl:10*

(Imagine that with colors! 🌈)

### 🛠️ The Meta-Macro: `@verify`

If you prefer a single entry point, use `@verify`. The first argument is a symbol (e.g., `:type`, `:keys`) which determines which check to run.

```julia
@verify :type x Float64      # expands to @verifytype x Float64
@verify :keys d :a :b        # expands to @verifykeys d :a :b
@verify :true 1 < 2          # expands to @verifytrue 1 < 2
```
