
"""
    @verify :action args...

General purpose verification macro that delegates to specific `@verify...` macros.
The first argument must be a symbol (e.g., `:type`, `:keys`) which is appended to "verify"
to determine the target macro.

Example:
    `@verify :type x Int` expands to `@verifytype x Int`
    `@verify :keys d :a :b` expands to `@verifykeys d :a :b`
"""
macro verify(action, args...)
    sym = nothing
    if action isa QuoteNode && action.value isa Symbol
        sym = action.value
    elseif action isa Expr && action.head == :quote
        val = action.args[1]
        if val isa Symbol
            sym = val
        elseif val isa Bool
            sym = Symbol(val)
        end
    end
    
    if sym === nothing
        error("First argument to @verify must be a symbol (e.g., :type, :keys)")
    end
    
    target_macro = Symbol("@verify", sym)
    
    return Expr(:macrocall,
        GlobalRef(@__MODULE__, target_macro),
        __source__,
        map(esc, args)...
    )
end


using StyledStrings

function _unwrap_name(x)
    if x isa Expr && x.head == :escape
        return _unwrap_name(x.args[1])
    end
    return x
end

# ==============================================================================
#  Refactoring Helper Macros
# ==============================================================================

"""
    @define_verification(Singular, Plural, FunctionName, NArgs)

Generates the verification macros:
1. `@Singular`: The main macro (e.g., `@verifytype`).
2. `@_Singular_internal`: Internal macro for batch processing.
3. `@Plural`: Batch verification macro (e.g., `@verifytypes`).

Arguments:
- `Singular`: Name of the singular macro (symbol).
- `Plural`: Name of the plural macro (symbol).
- `FunctionName`: Name of the backend function to call (symbol).
- `NArgs`: Number of arguments to verify (1 or 2).

The backend function is expected to have the signature:
- `func(val, expected, name, location)` for `NArgs = 2`
- `func(val, name, location)` for `NArgs = 1`
"""
macro define_verification(Singular, Plural, FunctionName, NArgs)
    
    internal_macro_name = Symbol("_", Singular, "_internal")
    
    # Escape everything to be safe
    singular = esc(Singular)
    plural = esc(Plural)
    func = esc(FunctionName)
    internal = esc(internal_macro_name)
    
    quote
        # ----------------------------------------------------------------------
        #  Singular Macro
        # ----------------------------------------------------------------------
        macro $singular(args...)
            # Handle arguments based on NArgs
            if length(args) < $NArgs
                error("Macro @$($QuoteNode(Singular)) expects at least $($NArgs) arguments")
            end
            
            # The last optional argument is the name
            has_name = length(args) > $NArgs
            
            # Extract arguments
            if $NArgs == 1
                val_expr = args[1]
                name_expr = has_name ? args[2] : string(_unwrap_name(val_expr))
                
                return quote
                    local val = $(esc(val_expr))
                    $($func)(val, $(string(name_expr)), $(QuoteNode($(esc(:__source__)))))
                end
            else # NArgs == 2
                val_expr = args[1]
                expected_expr = args[2]
                name_expr = has_name ? args[3] : string(_unwrap_name(val_expr))
                
                return quote
                    local val, expected = $(esc(val_expr)), $(esc(expected_expr))
                    $($func)(val, expected, $(string(name_expr)), $(QuoteNode($(esc(:__source__)))))
                end
            end
        end

        # ----------------------------------------------------------------------
        #  Internal Macro (for batch processing)
        # ----------------------------------------------------------------------
        macro $internal_macro_name(args...)
             # Arguments: (vals..., name, source)
             # NArgs=1 -> (val, name, src)
             # NArgs=2 -> (val, expected, name, src)
             
             if $NArgs == 1
                 val_expr, name, src = args[1], args[2], args[3]
                 return quote
                     local val = $(esc(val_expr))
                     $($func)(val, $(string(name)), $(esc(src)))
                 end
             else
                 val_expr, expected_expr, name, src = args[1], args[2], args[3], args[4]
                 return quote
                     local val, expected = $(esc(val_expr)), $(esc(expected_expr))
                     $($func)(val, expected, $(string(name)), $(esc(src)))
                 end
             end
        end

        # ----------------------------------------------------------------------
        #  Plural (Batch) Macro
        # ----------------------------------------------------------------------
        macro $plural(T...)
            blk = quote end
            src = QuoteNode($(esc(:__source__)))
            
            macro_ref = GlobalRef($(@__MODULE__), $(QuoteNode(Symbol("@", internal_macro_name))))

            for t in T
                if t isa Expr && t.head == :tuple
                    args = t.args
                    # Check argument count: NArgs or NArgs + 1 (with name)
                    if length(args) == $NArgs
                        # Call internal without explicit name (pass value as name source)
                        if $NArgs == 1
                             push!(blk.args, Expr(:macrocall, macro_ref, $(esc(:__source__)), args[1], args[1], src))
                        else
                             push!(blk.args, Expr(:macrocall, macro_ref, $(esc(:__source__)), args[1], args[2], args[1], src))
                        end
                    elseif length(args) == $NArgs + 1
                        # Call internal with explicit name
                        if $NArgs == 1
                             push!(blk.args, Expr(:macrocall, macro_ref, $(esc(:__source__)), args[1], args[2], src))
                        else
                             push!(blk.args, Expr(:macrocall, macro_ref, $(esc(:__source__)), args[1], args[2], args[3], src))
                        end
                    else
                        error("Each tuple in @$($QuoteNode(Plural)) must have $($NArgs) or $($NArgs+1) arguments")
                    end
                else
                    # Allow single expression if NArgs=1 (special case for things like @verifyisfiles)
                    if $NArgs == 1
                        push!(blk.args, Expr(:macrocall, macro_ref, $(esc(:__source__)), t, t, src))
                    else
                        error("All arguments in @$($QuoteNode(Plural)) must be tuples")
                    end
                end
            end
            return esc(blk)
        end
    end
end


# ==============================================================================
#  Backend Functions
# ==============================================================================

@noinline function verifytype(::Tᵛ, T, name, location) where Tᵛ
    Tᵛ <: T && return nothing
    error(styled"""TypeError: {magenta:$name} is of type {red:$Tᵛ}; was expecting a {green:$T}\n$location""")
end

@noinline function verifykey(d, key, name, location)
    haskey(d, key) && return nothing
    error(styled"""KeyError: {magenta:$name} lacks key {green:$key}\n$location""")
end

# --- Enhancements for UserDict/UserMarketDict (StablishCode.jl) ---
# Note: These will only be active if UserDict/UserMarketDict are defined in the context.
# We wrap them to avoid errors if this file is included where they are not defined.
if isdefined(@__MODULE__, :UserDict)
    @noinline function verifykey(d::UserDict, key, name, location)
        haskey(d, key) && return nothing
        error(styled"""KeyError: {magenta:$name} lacks key {green:$key}; this usually means that you failed to provide the correct and complete information in the {yellow:Dict} you passed to {blue:Estimate!}; you should be able to figure out from the key name where the problem is\n$location""")
    end
end

if isdefined(@__MODULE__, :UserMarketDict)
    @noinline function verifykey(d::UserMarketDict, key, name, location)
        haskey(d, key) && return nothing
        error(styled"""KeyError: {magenta:$name} (which is a {red:market level Dict} lacks key {green:$key}; this usually means that you failed to provide the correct and complete information in the {yellow:Dict} you passed to {blue:Estimate!}; you should be able to figure out from the key name where the problem is\n$location""")
    end
end
# ------------------------------------------------------------------

@noinline function verifyin(e, C, name, location)
    e ∈ C && return nothing
    error(styled"""ArgumentError: {magenta:$name} does not belong to {green:$C}\n$location""")
end

@noinline function verifyproperty(d, prop, name, location)
    hasproperty(d, prop) && return nothing
    error(styled"""KeyError: {magenta:$name} lacks property {green:$prop}\n$location""")
end

function verifysupertype(d, sup, name, location)
    d <: sup && return nothing
    error(styled"""TypeError: {magenta:$d} was expected to be a subtype of {green:$sup}\n$location""")
end

@noinline function verifyaxes(d, ax, name, location)
    axes(d) == ax && return nothing
    error(styled"""DimensionMismatch: {magenta:$name} has axes {red:$(axes(d))}: was expecting {green:$ax}\n$location""")
end

@noinline function verifyfield(s, f, name, location)
    hasfield(s, f) && return nothing
    error(styled"""KeyError: {magenta:$name} lacks field {green:$f}\n$location""")
end

@noinline function verifyequal(val, expected, name, location)
    val == expected && return nothing
    error(styled"""ArgumentError: {magenta:$name} is {red:$val}; was expecting {green:$expected}\n$location""")
end

@noinline function verifylength(col, len, name, location)
    length(col) == len && return nothing
    error(styled"""DimensionMismatch: {magenta:$name} has length {red:$(length(col))}; was expecting {green:$len}\n$location""")
end

@noinline function verifysize(arr, sz, name, location)
    size(arr) == sz && return nothing
    error(styled"""DimensionMismatch: {magenta:$name} has size {red:$(size(arr))}; was expecting {green:$sz}\n$location""")
end

@noinline function verifyisfile(path, name, location)
    isfile(path) && return nothing
    error(styled"""SystemError: {magenta:$name} (path: {cyan:$path}) is not a file\n$location""")
end

@noinline function verifyisdir(path, name, location)
    isdir(path) && return nothing
    error(styled"""SystemError: {magenta:$name} (path: {cyan:$path}) is not a directory\n$location""")
end

@noinline function verifytrue(cond, name, location)
    cond && return nothing
    error(styled"""AssertionError: {magenta:$name} is not true\n$location""")
end


# ==============================================================================
#  Macro Definitions
# ==============================================================================

# Standard verifications
@define_verification verifytype      verifytypes       verifytype      2
@doc """
    @verifytype(val, T, [name])

Check that `val` is of type `T` (using `<:`).
If `name` is omitted, it defaults to the string representation of `val`.
Throws a styled error if the check fails.
""" var"@verifytype"

@doc """
    @verifytypes((val, T), ...)

Batch verification for types.
Usage: `@verifytypes((val1, T1), (val2, T2))`
""" var"@verifytypes"


@define_verification verifyproperty  verifyproperties  verifyproperty  2
@doc """
    @verifyproperty(val, prop, [name])

Check that `val` has property `prop` (using `hasproperty`).
Throws a styled `KeyError` if the check fails.
""" var"@verifyproperty"

@doc """
    @verifyproperties((val, prop), ...)

Batch verification for properties.
Usage: `@verifyproperties((val1, prop1), (val2, prop2))`
""" var"@verifyproperties"


@define_verification verifysupertype verifysupertypes  verifysupertype 2
@doc """
    @verifysupertype(T, Sup, [name])

Check that `T` is a subtype of `Sup` (using `<:`).
Throws a styled `TypeError` if the check fails.
""" var"@verifysupertype"

@doc """
    @verifysupertypes((T, Sup), ...)

Batch verification for supertypes.
Usage: `@verifysupertypes((T1, Sup1), (T2, Sup2))`
""" var"@verifysupertypes"


@define_verification verifyaxes      verifyaxesm       verifyaxes      2
@doc """
    @verifyaxes(val, ax, [name])

Check that `val` has axes `ax` (using `axes(val) == ax`).
Throws a styled `DimensionMismatch` if the check fails.
""" var"@verifyaxes"

@doc """
    @verifyaxesm((val, ax), ...)

Batch verification for axes.
Usage: `@verifyaxesm((val1, ax1), (val2, ax2))`
""" var"@verifyaxesm"


@define_verification verifyfield     verifyfields      verifyfield     2
@doc """
    @verifyfield(val, field, [name])

Check that `val` has field `field` (using `hasfield`).
Throws a styled `KeyError` if the check fails.
""" var"@verifyfield"

@doc """
    @verifyfields((val, field), ...)

Batch verification for fields.
Usage: `@verifyfields((val1, field1), (val2, field2))`
""" var"@verifyfields"


@define_verification verifyin        verifyins         verifyin        2
@doc """
    @verifyin(val, collection, [name])

Check that `val` is in `collection` (using `val ∈ collection`).
Throws a styled `ArgumentError` if the check fails.
""" var"@verifyin"

@doc """
    @verifyins((val, collection), ...)

Batch verification for membership.
Usage: `@verifyins((val1, col1), (val2, col2))`
""" var"@verifyins"


@define_verification verifyequal     verifyequals      verifyequal     2
@doc """
    @verifyequal(val, expected, [name])

Check that `val` is equal to `expected` (using `==`).
Throws a styled `ArgumentError` if the check fails.
""" var"@verifyequal"

@doc """
    @verifyequals((val, expected), ...)

Batch verification for equality.
Usage: `@verifyequals((val1, exp1), (val2, exp2))`
""" var"@verifyequals"


@define_verification verifylength    verifylengths     verifylength    2
@doc """
    @verifylength(val, len, [name])

Check that `val` has length `len` (using `length(val) == len`).
Throws a styled `DimensionMismatch` if the check fails.
""" var"@verifylength"

@doc """
    @verifylengths((val, len), ...)

Batch verification for lengths.
Usage: `@verifylengths((val1, len1), (val2, len2))`
""" var"@verifylengths"


@define_verification verifysize      verifysizes       verifysize      2
@doc """
    @verifysize(val, size, [name])

Check that `val` has size `size` (using `size(val) == size`).
Throws a styled `DimensionMismatch` if the check fails.
""" var"@verifysize"

@doc """
    @verifysizes((val, size), ...)

Batch verification for sizes.
Usage: `@verifysizes((val1, size1), (val2, size2))`
""" var"@verifysizes"


@define_verification verifyisfile    verifyisfiles     verifyisfile    1
@doc """
    @verifyisfile(path, [name])

Check that `path` is an existing file (using `isfile`).
Throws a styled `SystemError` if the check fails.
""" var"@verifyisfile"

@doc """
    @verifyisfiles(path, ...)

Batch verification for files.
Usage: `@verifyisfiles(path1, path2)` or `@verifyisfiles((path1, name1), ...)`
""" var"@verifyisfiles"


@define_verification verifyisdir     verifyisdirs      verifyisdir     1
@doc """
    @verifyisdir(path, [name])

Check that `path` is an existing directory (using `isdir`).
Throws a styled `SystemError` if the check fails.
""" var"@verifyisdir"

@doc """
    @verifyisdirs(path, ...)

Batch verification for directories.
Usage: `@verifyisdirs(path1, path2)` or `@verifyisdirs((path1, name1), ...)`
""" var"@verifyisdirs"


@define_verification verifytrue      verifytrues       verifytrue      1
@doc """
    @verifytrue(cond, [name])

Check that `cond` is true.
Throws a styled `AssertionError` if the check fails.
""" var"@verifytrue"

@doc """
    @verifytrues(cond, ...)

Batch verification for boolean conditions.
Usage: `@verifytrues(cond1, cond2)` or `@verifytrues((cond1, name1), ...)`
""" var"@verifytrues"


# ==============================================================================
#  Special Cases (Enhancements)
# ==============================================================================

# verifykeys requires special handling for the batch enhancement:
# Usage: @verifykeys(dict, key1, key2...) OR @verifykeys((d,k), ...)

# We can reuse the generator for the singular form, but we need to overwrite or
# manually define the plural form. 
# Since we can't easily suppress the plural generation in our helper without 
# modifying it, we'll let it generate (or we could split the helper).
# A cleaner way is to just define singular manually or split the helper. 
# But let's just generate it and then REDEFINE @verifykeys. Julia allows this.

@define_verification verifykey       _verifykeys_stub  verifykey       2
@doc """
    @verifykey(dict, key, [name])

Check that `dict` has key `key` (using `haskey`).
Throws a styled `KeyError` if the check fails.
""" var"@verifykey"

"""
    @verifykeys((dict1, key1), (dict2, key2), ...)
    @verifykeys(dict, key1, key2, ...)

Batch verify multiple key checks.
Usage 1: Each argument is a tuple of `(dict, key[, name])`. Equivalent to multiple `@verifykey` calls.
Usage 2: First argument is the dictionary, subsequent arguments are keys. Verify that `dict` contains all specified keys.
"""
macro verifykeys(T...)
    blk = quote end
    src = QuoteNode(__source__)
    
    if isempty(T)
        return esc(blk)
    end

    # Usage 2 detection: First argument is NOT a tuple expression, and we have multiple arguments
    first_is_tuple = T[1] isa Expr && T[1].head == :tuple
    
    if !first_is_tuple && length(T) >= 2
         d = T[1]
         keys = T[2:end]
         for k in keys
             push!(blk.args, :($(@__MODULE__).@_verifykey_internal($d, $k, $(string(_unwrap_name(d))), $src)))
         end
    else
        for t in T
            if t isa Expr && t.head == :tuple
                args = t.args
                if length(args) == 2
                    push!(blk.args, :($(@__MODULE__).@_verifykey_internal($(args[1]), $(args[2]), $(string(_unwrap_name(args[1]))), $src)))
                elseif length(args) == 3
                    push!(blk.args, :($(@__MODULE__).@_verifykey_internal($(args[1]), $(args[2]), $(args[3]), $src)))
                else
                    error("Each tuple must have 2 or 3 arguments")
                end
            else
                if !first_is_tuple
                     error("Usage: @verifykeys(dict, key1, ...) or @verifykeys((d,k), ...)")
                else
                     error("All arguments must be tuples when using batch tuple mode")
                end
            end
        end
    end
    return esc(blk)
end
