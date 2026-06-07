def ultra_eq(f, g, n=10000):
    agree = sum(1 for i in range(n) if f(i) == g(i))
    density = agree / n
    return (density > 0.5, density)