def classify_element(g, universe=10000):
    for N in range(universe):
        bounded = sum(1 for i in range(universe) if g(i) <= N)
        if bounded > universe * 0.99:
            return f'bounded by {N}'
    return 'nonstandard'