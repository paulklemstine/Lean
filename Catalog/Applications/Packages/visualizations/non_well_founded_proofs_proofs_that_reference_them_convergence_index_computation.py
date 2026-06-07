def convergence_index(F, bot, le, target, max_steps=1000):
    x = bot
    for k in range(max_steps):
        if le(target, x):
            return k
        x = F(x)
    return None