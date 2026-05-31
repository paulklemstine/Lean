def collatz_hash(x, depths, seeds):
    def step(n):
        return n // 2 if n % 2 == 0 else 3 * n + 1
    def iterate(k, n):
        for _ in range(k): n = step(n)
        return n
    return tuple(iterate(d, x + s) for d, s in zip(depths, seeds))