def reflection_depth(phi, bot, x, le, max_depth=100):
    current = bot
    for n in range(max_depth + 1):
        if le(x, current):
            return n
        current = phi(current)
    return None