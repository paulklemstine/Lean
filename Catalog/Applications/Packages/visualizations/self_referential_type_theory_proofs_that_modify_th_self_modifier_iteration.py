def iterate_until_stable(modifier, spec, max_steps=1000):
    current = spec
    levels = [current.level]
    for i in range(1, max_steps + 1):
        next_spec = modifier.modify(current)
        levels.append(next_spec.level)
        if next_spec.level == current.level:
            return next_spec, i, levels
        current = next_spec
    return current, max_steps, levels