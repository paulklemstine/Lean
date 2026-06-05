def contractive_collapse(initial_level, modifier):
    levels = [initial_level]
    current = initial_level
    while current > 0:
        current = modifier(current)
        levels.append(current)
    return levels