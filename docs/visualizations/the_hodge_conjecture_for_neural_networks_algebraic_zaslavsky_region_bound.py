def max_regions(n: int, d: int) -> int:
    return sum(math.comb(n, k) for k in range(d + 1))