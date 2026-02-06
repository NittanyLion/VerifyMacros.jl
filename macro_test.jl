macro check_args(action, args...)
    println("Action type: ", typeof(action))
    println("Action: ", action)
    println("Args: ", args)
    return nothing
end

@check_args :keys 1 2 3
