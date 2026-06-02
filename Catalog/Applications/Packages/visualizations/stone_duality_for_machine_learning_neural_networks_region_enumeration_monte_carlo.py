def enumerate_regions(W, b, N=100000):
    patterns = set()
    for _ in range(N):
        x = np.random.randn(n) * 10
        patterns.add(activation_pattern(W, b, x))
    return patterns