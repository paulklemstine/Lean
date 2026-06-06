def simulation_depth(f, x, bot=0.0, max_depth=1000):
    val = bot
    for n in range(max_depth + 1):
        if val >= x - 1e-10:
            return n
        val = f(val)
    return None