using StyledStrings


@noinline function verifytype( val :: Tᵛ, T, name, location ) where Tᵛ
    Tᵛ <: T && return nothing
    # throw( TypeError( location, T, Tᵛ ) )
    error( styled"""TypeError: {red:$name} is of type {red:$Tᵛ}; was expecting a {green:$T}\n$location""" )
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
    error( styled"""KeyError: {red:$name} lacks key {green:$key}\n$location""" )
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


@noinline function verifyproperty( d, prop, name, location )
    hasproperty( d, prop ) && return nothing
    error( styled"""KeyError: {red:$name} lacks property {green:$prop}\n$location""" )
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
    error( styled"""TypeError: {red:$d} was expected to be a subtype of {green:$sup}\n$location""" )
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
    error( styled"""DimensionMismatch: {red:$name} has axes {red:$(axes(d))}: was expecting {green:$ax}\n$location""" )
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
    error( styled"""KeyError: {red:$name} lacks field {green:$f}\n$location""" )
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
    @verifyaxes_list((array1, axes1), (array2, axes2), ...)

Batch verify multiple axes checks. Each argument must be a tuple of `(array, expected_axes[, name])`.
Equivalent to multiple `@verifyaxes` calls.
"""
macro verifyaxes_list( T... )
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


