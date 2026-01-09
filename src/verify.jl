
using StyledStrings


@noinline function verifytype( :: Tᵛ, T, name, location ) where Tᵛ
    Tᵛ <: T && return nothing
    # throw( TypeError( location, T, Tᵛ ) )
    error( styled"""TypeError: {magenta:$name} is of type {red:$Tᵛ}; was expecting a {green:$T}\n$location""" )
end




"""
    @verifytype(value, Type[, name])

Verify that `value` is of type `Type`. Throws a descriptive error if the type check fails.
Optionally provide a custom `name` for the value in error messages.
"""
macro verifytype( v, t, n = string( v ) )
    name = string(n)
    return quote
        local val, T = $(esc(v)), $(esc(t))
        verifytype( val, T, $name, $(QuoteNode(__source__)) )
    end
end

# Internal macro for batch usage with explicit source
macro _verifytype_internal( v, t, n, src )
    name = string(n)
    return quote
        local val, T = $(esc(v)), $(esc(t))
        verifytype( val, T, $name, $(esc(src)) )
    end
end

@noinline function verifykey( d, key, name, location )
    haskey( d, key ) && return nothing
    error( styled"""KeyError: {magenta:$name} lacks key {green:$key}\n$location""" )
end

"""
    @verifykey(dict, key[, name])

Verify that `dict` contains the specified `key`. Throws a descriptive error if the key is missing.
Optionally provide a custom `name` for the dictionary in error messages.
"""
macro verifykey( d, k, n = string( d ) )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifykey(  D, K, $name, $(QuoteNode(__source__)) ) 
    end
end

# Internal macro for batch usage with explicit source
macro _verifykey_internal( d, k, n, src )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifykey(  D, K, $name, $(esc(src)) ) 
    end
end

@noinline function verifyin( e, C, name, location )
    e ∈ C && return nothing
    error( styled"""ArgumentError: {magenta:$name} does not belong to {green:$C}\n$location""" )
end

"""
    @verifyin(element, collection[, name])

Verify that `element` is in `collection`. Throws a descriptive error if the check fails.
Optionally provide a custom `name` for the element in error messages.
"""
macro verifyin( e, C, n = string( e ) )
    name = string( n )
    return quote
        local D, K = $(esc(e)), $(esc(C))
        verifyin(  D, K, $name, $(QuoteNode(__source__)) )  
    end
end

# Internal macro for batch usage with explicit source
macro _verifyin_internal( e, C, n, src )
    name = string(n)
    return quote
        local E, C = $(esc(e)), $(esc(C))
        verifyin( E, C, $name, $(esc(src)) )
    end
end



@noinline function verifyproperty( d, prop, name, location )
    hasproperty( d, prop ) && return nothing
    error( styled"""KeyError: {magenta:$name} lacks property {green:$prop}\n$location""" )
end

"""
    @verifyproperty(object, property[, name])

Verify that `object` has the specified `property`. Throws a descriptive error if the property is missing.
Optionally provide a custom `name` for the object in error messages.
"""
macro verifyproperty( d, k, n = string( d ) )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifyproperty(  D, K, $name, $(QuoteNode(__source__)) ) 
    end
end

# Internal macro for batch usage with explicit source
macro _verifyproperty_internal( d, k, n, src )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifyproperty(  D, K, $name, $(esc(src)) ) 
    end
end


function verifysupertype( d, sup, name, location )
    d <: sup && return nothing
    error( styled"""TypeError: {magenta:$d} was expected to be a subtype of {green:$sup}\n$location""" )
end

"""
    @verifysupertype(Type, SuperType[, name])

Verify that `Type` is a subtype of `SuperType`. Throws a descriptive error if the subtype relation fails.
Optionally provide a custom `name` for the type in error messages.
"""
macro verifysupertype( d, k, n = string( d ) )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifysupertype(  D, K, $name, $(QuoteNode(__source__)) ) 
    end
end

# Internal macro for batch usage with explicit source
macro _verifysupertype_internal( d, k, n, src )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifysupertype(  D, K, $name, $(esc(src)) ) 
    end
end

@noinline function verifyaxes( d, ax, name, location )
    axes( d ) == ax && return nothing
    error( styled"""DimensionMismatch: {magenta:$name} has axes {red:$(axes(d))}: was expecting {green:$ax}\n$location""" )
end



"""
    @verifyaxes(array, expected_axes[, name])

Verify that `array` has the specified `expected_axes`. Throws a descriptive error if axes don't match.
Optionally provide a custom `name` for the array in error messages.
"""
macro verifyaxes( d, k, n = string( d ) )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifyaxes( D, K, $name, $(QuoteNode(__source__)) )
    end
end

# Internal macro for batch usage with explicit source
macro _verifyaxes_internal( d, k, n, src )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifyaxes( D, K, $name, $(esc(src)) )
    end
end


@noinline function verifyfield( s, f, name, location )
    hasfield( s, f ) && return nothing
    error( styled"""KeyError: {magenta:$name} lacks field {green:$f}\n$location""" )
end


"""
    @verifyfield(Type, field[, name])

Verify that `Type` has the specified `field`. Throws a descriptive error if the field is missing.
Optionally provide a custom `name` for the type in error messages.
"""
macro verifyfield( d, k, n = string( d ) )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifyfield(  D, K, $name, $(QuoteNode(__source__)) ) 
    end
end

# Internal macro for batch usage with explicit source
macro _verifyfield_internal( d, k, n, src )
    name = string(n)
    return quote
        local D, K = $(esc(d)), $(esc(k))
        verifyfield(  D, K, $name, $(esc(src)) ) 
    end
end

"""
    @verifytypes((value1, Type1), (value2, Type2), ...)

Batch verify multiple type checks. Each argument must be a tuple of `(value, Type[, name])`.
Equivalent to multiple `@verifytype` calls.
"""
macro verifytypes( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifytype_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifytype_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end

"""
    @verifykeys((dict1, key1), (dict2, key2), ...)

Batch verify multiple key checks. Each argument must be a tuple of `(dict, key[, name])`.
Equivalent to multiple `@verifykey` calls.
"""
macro verifykeys( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifykey_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifykey_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end

"""
    @verifysupertypes((Type1, SuperType1), (Type2, SuperType2), ...)

Batch verify multiple subtype relations. Each argument must be a tuple of `(Type, SuperType[, name])`.
Equivalent to multiple `@verifysupertype` calls.
"""
macro verifysupertypes( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifysupertype_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifysupertype_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end

"""
    @verifyproperties((object1, property1), (object2, property2), ...)

Batch verify multiple property checks. Each argument must be a tuple of `(object, property[, name])`.
Equivalent to multiple `@verifyproperty` calls.
"""
macro verifyproperties( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifyproperty_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifyproperty_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end

"""
    @verifyfields((Type1, field1), (Type2, field2), ...)

Batch verify multiple field checks. Each argument must be a tuple of `(Type, field[, name])`.
Equivalent to multiple `@verifyfield` calls.
"""
macro verifyfields( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifyfield_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifyfield_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end

"""
    @verifyaxesm((array1, axes1), (array2, axes2), ...)

Batch verify multiple axes checks. Each argument must be a tuple of `(array, expected_axes[, name])`.
Equivalent to multiple `@verifyaxes` calls.
"""
macro verifyaxesm( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifyaxes_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifyaxes_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end

"""
    @verifyins((element1, Collection1), (element2, Collection2), ...)

Batch verify multiple membership checks. Each argument must be a tuple of `(element, Collection[, name])`.
Equivalent to multiple `@verifyin` calls.
"""
macro verifyins( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifyin_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifyin_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end




@noinline function verifyequal( val, expected, name, location )
    val == expected && return nothing
    error( styled"""ArgumentError: {magenta:$name} is {red:$val}; was expecting {green:$expected}\n$location""" )
end

"""
    @verifyequal(value, expected[, name])

Verify that `value` is equal to `expected`. Throws a descriptive error if not equal.
Optionally provide a custom `name` for the value in error messages.
"""
macro verifyequal( v, e, n = string( v ) )
    name = string(n)
    return quote
        local val, expected = $(esc(v)), $(esc(e))
        verifyequal( val, expected, $name, $(QuoteNode(__source__)) )
    end
end

macro _verifyequal_internal( v, e, n, src )
    name = string(n)
    return quote
        local val, expected = $(esc(v)), $(esc(e))
        verifyequal( val, expected, $name, $(esc(src)) )
    end
end

"""
    @verifyequals((value1, expected1), (value2, expected2), ...)

Batch verify multiple equality checks. Each argument must be a tuple of `(value, expected[, name])`.
Equivalent to multiple `@verifyequal` calls.
"""
macro verifyequals( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifyequal_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifyequal_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end

@noinline function verifylength( col, len, name, location )
    length(col) == len && return nothing
    error( styled"""DimensionMismatch: {magenta:$name} has length {red:$(length(col))}; was expecting {green:$len}\n$location""" )
end

"""
    @verifylength(collection, len[, name])

Verify that `collection` has length `len`. Throws a descriptive error if the length check fails.
Optionally provide a custom `name` for the collection in error messages.
"""
macro verifylength( c, l, n = string( c ) )
    name = string(n)
    return quote
        local col, len = $(esc(c)), $(esc(l))
        verifylength( col, len, $name, $(QuoteNode(__source__)) )
    end
end

macro _verifylength_internal( c, l, n, src )
    name = string(n)
    return quote
        local col, len = $(esc(c)), $(esc(l))
        verifylength( col, len, $name, $(esc(src)) )
    end
end

"""
    @verifylengths((col1, len1), (col2, len2), ...)

Batch verify multiple length checks. Each argument must be a tuple of `(collection, length[, name])`.
Equivalent to multiple `@verifylength` calls.
"""
macro verifylengths( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifylength_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifylength_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end

@noinline function verifysize( arr, sz, name, location )
    size(arr) == sz && return nothing
    error( styled"""DimensionMismatch: {magenta:$name} has size {red:$(size(arr))}; was expecting {green:$sz}\n$location""" )
end

"""
    @verifysize(array, size[, name])

Verify that `array` has size `size`. Throws a descriptive error if the size check fails.
Optionally provide a custom `name` for the array in error messages.
"""
macro verifysize( a, s, n = string( a ) )
    name = string(n)
    return quote
        local arr, sz = $(esc(a)), $(esc(s))
        verifysize( arr, sz, $name, $(QuoteNode(__source__)) )
    end
end

macro _verifysize_internal( a, s, n, src )
    name = string(n)
    return quote
        local arr, sz = $(esc(a)), $(esc(s))
        verifysize( arr, sz, $name, $(esc(src)) )
    end
end

"""
    @verifysizes((arr1, size1), (arr2, size2), ...)

Batch verify multiple size checks. Each argument must be a tuple of `(array, size[, name])`.
Equivalent to multiple `@verifysize` calls.
"""
macro verifysizes( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifysize_internal( $(args[1]), $(args[2]), $(args[1]), $src ) ) )
            elseif length(args) == 3
                push!( blk.args, :($(@__MODULE__).@_verifysize_internal( $(args[1]), $(args[2]), $(args[3]), $src ) ) )
            else
                error("Each tuple must have 2 or 3 arguments")
            end
        else
            error("All arguments must be tuples")
        end
    end
    return esc(blk)
end

@noinline function verifyisfile( path, name, location )
    isfile( path ) && return nothing
    error( styled"""SystemError: {magenta:$name} (path: {cyan:$path}) is not a file\n$location""" )
end

"""
    @verifyisfile(path[, name])

Verify that `path` is an existing file. Throws a descriptive error if not.
Optionally provide a custom `name` for the file in error messages.
"""
macro verifyisfile( p, n = string( p ) )
    name = string(n)
    return quote
        local path = $(esc(p))
        verifyisfile( path, $name, $(QuoteNode(__source__)) )
    end
end

macro _verifyisfile_internal( p, n, src )
    name = string(n)
    return quote
        local path = $(esc(p))
        verifyisfile( path, $name, $(esc(src)) )
    end
end

"""
    @verifyisfiles((path1), (path2), ...)

Batch verify multiple file existence checks. Each argument must be a tuple of `(path[, name])`.
Equivalent to multiple `@verifyisfile` calls.
"""
macro verifyisfiles( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 1
                push!( blk.args, :($(@__MODULE__).@_verifyisfile_internal( $(args[1]), $(args[1]), $src ) ) )
            elseif length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifyisfile_internal( $(args[1]), $(args[2]), $src ) ) )
            else
                error("Each tuple must have 1 or 2 arguments")
            end
        else
            # Allow non-tuple single argument
            push!( blk.args, :($(@__MODULE__).@_verifyisfile_internal( $t, $t, $src ) ) )
        end
    end
    return esc(blk)
end

@noinline function verifyisdir( path, name, location )
    isdir( path ) && return nothing
    error( styled"""SystemError: {magenta:$name} (path: {cyan:$path}) is not a directory\n$location""" )
end

"""
    @verifyisdir(path[, name])

Verify that `path` is an existing directory. Throws a descriptive error if not.
Optionally provide a custom `name` for the directory in error messages.
"""
macro verifyisdir( p, n = string( p ) )
    name = string(n)
    return quote
        local path = $(esc(p))
        verifyisdir( path, $name, $(QuoteNode(__source__)) )
    end
end

macro _verifyisdir_internal( p, n, src )
    name = string(n)
    return quote
        local path = $(esc(p))
        verifyisdir( path, $name, $(esc(src)) )
    end
end

"""
    @verifyisdirs((path1), (path2), ...)

Batch verify multiple directory existence checks. Each argument must be a tuple of `(path[, name])`.
Equivalent to multiple `@verifyisdir` calls.
"""
macro verifyisdirs( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 1
                push!( blk.args, :($(@__MODULE__).@_verifyisdir_internal( $(args[1]), $(args[1]), $src ) ) )
            elseif length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifyisdir_internal( $(args[1]), $(args[2]), $src ) ) )
            else
                error("Each tuple must have 1 or 2 arguments")
            end
        else
            # Allow non-tuple single argument
            push!( blk.args, :($(@__MODULE__).@_verifyisdir_internal( $t, $t, $src ) ) )
        end
    end
    return esc(blk)
end

@noinline function verifytrue( cond, name, location )
    cond && return nothing
    error( styled"""AssertionError: {magenta:$name} is not true\n$location""" )
end

"""
    @verifytrue(condition[, name])

Verify that `condition` is true. Throws a descriptive error if it evaluates to false.
Optionally provide a custom `name` for the condition in error messages.
"""
macro verifytrue( c, n = string( c ) )
    name = string(n)
    return quote
        local cond = $(esc(c))
        verifytrue( cond, $name, $(QuoteNode(__source__)) )
    end
end

macro _verifytrue_internal( c, n, src )
    name = string(n)
    return quote
        local cond = $(esc(c))
        verifytrue( cond, $name, $(esc(src)) )
    end
end

"""
    @verifytrues((condition1), (condition2), ...)

Batch verify multiple conditions. Each argument must be a tuple of `(condition[, name])`.
Equivalent to multiple `@verifytrue` calls.
"""
macro verifytrues( T... )
    blk = quote end
    src = QuoteNode(__source__)
    for t ∈ T
        if t isa Expr && t.head == :tuple
            args = t.args
            if length(args) == 1
                push!( blk.args, :($(@__MODULE__).@_verifytrue_internal( $(args[1]), $(args[1]), $src ) ) )
            elseif length(args) == 2
                push!( blk.args, :($(@__MODULE__).@_verifytrue_internal( $(args[1]), $(args[2]), $src ) ) )
            else
                error("Each tuple must have 1 or 2 arguments")
            end
        else
            # Allow non-tuple single argument
            push!( blk.args, :($(@__MODULE__).@_verifytrue_internal( $t, $t, $src ) ) )
        end
    end
    return esc(blk)
end
