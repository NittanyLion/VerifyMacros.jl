```@meta
CurrentModule = VerifyMacros
```



# VerifyMacros

Documentation for [VerifyMacros.jl](https://github.com/NittanyLion/VerifyMacros.jl).

## Overview

This package provides convenient macros that verify whether given variables have given properties.  These macros apply to types, fields, keys, properties, axes, supertypes, equality, length, size, file/directory existence, and generic conditions.

For instance,
```
    @verifytype x Float64
```
verifies that `x` is a Float64 and prints a convenient error message, otherwise.  An example: 
```@repl
using VerifyMacros

x = 3.0
@verifytype x Int
```

If desirable, one can change the description of the variable by providing a third argument, thus:
```@repl
using VerifyMacros

x = 3.0
@verifytype x Int "Some variable"
```

There are multi-argument versions of the same.  For instance, one can do
```@repl
using VerifyMacros

x = 3.0
y = "blooper"

@verifytypes (x,AbstractFloat) (y,Symbol,why)
```

## List of macros

```@index
```



```@autodocs
Modules = [VerifyMacros]
```
