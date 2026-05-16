def orbit_cost_exact(Wc, mu, nu, group_elements, action):
    best = float("inf")
    for g in group_elements:
        c = Wc(mu, action(g, nu))
        if c < best:
            best = c
    return best