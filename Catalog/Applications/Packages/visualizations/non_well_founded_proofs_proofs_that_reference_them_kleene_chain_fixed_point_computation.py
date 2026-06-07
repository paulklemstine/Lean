def find_fixed_point(F, bot, max_steps=1000):
    x = bot
    for k in range(max_steps):
        x_next = F(x)
        if x_next == x:
            return k, x
        x = x_next
    return None, x