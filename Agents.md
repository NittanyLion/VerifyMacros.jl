# Developer Guide (Agents.md)

This document provides a comprehensive overview of the `VerifyMacros.jl` codebase, designed to assist AI agents and developers in understanding, maintaining, and extending the package.

## Project Structure

- `src/VerifyMacros.jl`: The main module entry point. It exports all the macros and includes `verify.jl`.
- `src/verify.jl`: Contains the core implementation of the verification logic, including the implementation functions and the macro definitions.
- `test/runtests.jl`: Contains the test suite, verifying both success cases and expected failures (exceptions).

## Design Philosophy

The core design principle of `VerifyMacros.jl` is to provide runtime verification that produces **descriptive and styled error messages**, while minimizing boilerplate code for the user.

### Macros for Source Context

Macros are used primarily to capture the source location (`__source__`) where the verification is called. This allows the error messages to point exactly to the line of code that failed the check, which is crucial for debugging.

Each macro typically expands to a call to a corresponding backend function (e.g., `@verifytype` -> `verifytype`), passing:
1. The value to check.
2. The expected condition (type, key, etc.).
3. A name for the value (defaulting to the string representation of the variable name).
4. The source location node (`QuoteNode(__source__)`).

### Styled Error Messages

The package uses `StyledStrings` to format error messages. This allows for colored output (e.g., red for errors/actual values, green for expected values) to make the messages easier to parse visually.

## Implementation Details

### Backend Functions

The actual verification logic is implemented in functions annotated with `@noinline` to avoid code bloat at the call site and to ensure the stack trace is clean.

Example signature:
```julia
function verifytype( val :: Tᵛ, T, name, location ) where Tᵛ
```

- `val`: The value being verified.
- `T`: The expected type.
- `name`: The name of the variable (for the error message).
- `location`: The source location (LineNumberNode).

If the check passes, the function returns `nothing`. If it fails, it constructs a styled error string and throws an error (often `ErrorException` or a specific error type like `TypeError` or `KeyError` simulated via text).

### Macros

The macros wrap the backend functions. They use `esc()` to ensure variables are evaluated in the caller's scope.

Example pattern:
```julia
macro verifytype( v, t, n = string( v ) )
    name = string(n)
    return quote
        local val, T = $(esc(v)), $(esc(t))
        verifytype( val, T, $name, $(QuoteNode(__source__)) )
    end
end
```

### Batch Macros

Batch macros (e.g., `@verifytypes`) take a variable number of arguments, where each argument is expected to be a tuple. They expand to a block of code containing multiple calls to the single-item macros.

## Extending the Package

To add a new verification macro:

1.  **Define the backend function** in `src/verify.jl`.
    *   It should accept the value(s), expected condition, name, and location.
    *   It should return `nothing` on success.
    *   It should throw a descriptive error using `styled"..."` on failure.
2.  **Define the macro** in `src/verify.jl`.
    *   It should accept the arguments and an optional name.
    *   It should expand to a call to the backend function, passing `$(QuoteNode(__source__))`.
3.  **Define the batch macro** (optional but recommended).
    *   It should loop over arguments and generate multiple calls to the single macro.
4.  **Export the new macros** in `src/VerifyMacros.jl`.
5.  **Add tests** in `test/runtests.jl` covering success, failure, and batch usage.

## Common Patterns

- **Type Checking**: Uses `isa` (or `<:`) implicitly via dispatch or explicit checks.
- **Key/Property Checking**: Uses `haskey`, `hasproperty`, `hasfield`.
- **Equality/Comparison**: Uses `==`, `length`, `size`, `isfile`, `isdir`, etc.
- **Error Formatting**: Always provide what was found vs. what was expected.

## Testing

Tests are written using `Test`.
- `isnothing(...)` is used to assert that a verification passes (returns `nothing`).
- `@test_throws ErrorException ...` is used to assert that a verification fails as expected. Note that even though the error message says "TypeError", the actual exception type thrown might be `ErrorException` depending on implementation (currently `error(...)` throws `ErrorException`).
- **Aqua**: Aqua (Auto Quality Assurance) tests are included to check for code quality issues like stale dependencies, unbound args, etc.
