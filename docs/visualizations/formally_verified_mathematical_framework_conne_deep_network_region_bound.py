def deep_network_bound(widths: list, input_dim: int) -> int:
    from math import comb, prod
    def zaslavsky(m, n):
        return sum(comb(m, k) for k in range(min(m, n) + 1))
    return prod(zaslavsky(w, input_dim) for w in widths)