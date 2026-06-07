def joke_refiner_iterate(refine, x0, n_iters, c):
    trajectory = []
    x = x0.copy()
    d0 = np.linalg.norm(x - refine(x))
    for i in range(n_iters):
        x_next = refine(x)
        d = np.linalg.norm(x - x_next)
        assert d <= c**i * d0 + 1e-10
        trajectory.append((x.copy(), d))
        x = x_next
    return trajectory