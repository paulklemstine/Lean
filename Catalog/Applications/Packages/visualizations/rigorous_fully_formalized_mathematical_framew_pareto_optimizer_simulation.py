def simulate(x, step, max_steps=10000):
    orbit = [x]
    for _ in range(max_steps):
        x_new = step(x)
        if x_new == x: break
        orbit.append(x_new); x = x_new
    return orbit