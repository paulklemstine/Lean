def hyp_convolution(f: list, g: list, n: int) -> float:
    return sum(f[k] * g[n-k] for k in range(min(n+1, len(f))) if n-k < len(g))