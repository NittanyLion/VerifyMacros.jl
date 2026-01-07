# VerifyMacros.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://NittanyLion.github.io/VerifyMacros.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://NittanyLion.github.io/VerifyMacros.jl/dev/)
[![Build Status](https://github.com/NittanyLion/VerifyMacros.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/NittanyLion/VerifyMacros.jl/actions/workflows/CI.yml?query=branch%3Amain)

`VerifyMacros.jl` provides a collection of utility macros for runtime verification in Julia. These macros allow you to assert conditions (like type checks, key existence, property existence, etc.) and throw descriptive, styled error messages when those assertions fail.

## Installation

You can install the package using the Julia package manager:

```julia
using Pkg
Pkg.add("VerifyMacros")
```

## Usage

### Single Verification Macros

The package exports several macros for verifying different properties of your data. Each macro takes an optional `name` argument to customize the error message.

#### `@verifytype`
Verify that a value is of a specific type.

```julia
using VerifyMacros

x = 1.0
@verifytype x Float64
# No error

@verifytype x Int
# Throws: TypeError: x is of type Float64; was expecting a Int
```

#### `@verifykey`
Verify that a dictionary (or other object supporting `haskey`) contains a specific key.

```julia
d = Dict(:a => 1)
@verifykey d :a
# No error

@verifykey d :b
# Throws: KeyError: d lacks key :b
```

#### `@verifyproperty`
Verify that an object has a specific property.

```julia
struct MyStruct
    p::Int
end
obj = MyStruct(1)

@verifyproperty obj :p
# No error

@verifyproperty obj :q
# Throws: KeyError: obj lacks property :q
```

#### `@verifysupertype`
Verify that a type is a subtype of another type.

```julia
@verifysupertype Int Integer
# No error

@verifysupertype Int AbstractFloat
# Throws: TypeError: Int64 was expected to be a subtype of AbstractFloat
```

#### `@verifyaxes`
Verify that an array has specific axes.

```julia
A = [1, 2]
@verifyaxes A (Base.OneTo(2),)
# No error

@verifyaxes A (Base.OneTo(3),)
# Throws: DimensionMismatch: A has axes (Base.OneTo(2),): was expecting (Base.OneTo(3),)
```

#### `@verifyfield`
Verify that a type has a specific field.

```julia
struct MyType
    f::Int
end

@verifyfield MyType :f
# No error

@verifyfield MyType :g
# Throws: KeyError: MyType lacks field :g
```

### Batch Verification Macros

For verifying multiple conditions at once, the package provides pluralized versions of the macros. These accept tuples of arguments.

#### `@verifytypes`

```julia
@verifytypes (1.0, Float64) ("hello", String)
```

#### `@verifykeys`

```julia
d = Dict(:a => 1, :b => 2)
@verifykeys (d, :a) (d, :b)
```

#### `@verifyproperties`

```julia
@verifyproperties (obj, :p) (obj, :other_prop)
```

#### `@verifysupertypes`

```julia
@verifysupertypes (Int, Integer) (Float64, Real)
```

#### `@verifyaxes_list`

```julia
@verifyaxes_list (A, (Base.OneTo(2),)) (B, (Base.OneTo(3),))
```

#### `@verifyfields`

```julia
@verifyfields (MyType, :f) (OtherType, :x)
```
