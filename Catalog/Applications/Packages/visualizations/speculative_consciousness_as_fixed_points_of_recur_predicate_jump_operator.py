def predicate_jump(enum, n):
    jump_values = {k: not enum(k)(k) for k in range(n)}
    return lambda k: jump_values[k]