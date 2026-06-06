def evolve(theories, generations=100):
    for _ in range(generations):
        fits = [(t, t.fitness()) for t in theories]
        median = sorted(f for _,f in fits)[len(fits)//2]
        for i, (t, f) in enumerate(fits):
            if f > median:
                t.connection_count = int(t.connection_count * 1.05)
            else:
                t.connection_count = max(1, int(t.connection_count * 0.95))
    return theories