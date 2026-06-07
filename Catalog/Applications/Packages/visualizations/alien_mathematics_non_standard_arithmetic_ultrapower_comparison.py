def compare(f, g, N=10000, t=0.9):
    lt = sum(1 for i in range(N) if f(i) < g(i))
    return 'f < g' if lt/N > t else 'indeterminate'