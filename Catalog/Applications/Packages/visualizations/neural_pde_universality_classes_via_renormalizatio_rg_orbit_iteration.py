def rg_iterate(coarsen, x, n_steps):
    orbit = [x.copy()]
    current = x.copy()
    for _ in range(n_steps):
        current = coarsen(current)
        orbit.append(current.copy())
    return orbit