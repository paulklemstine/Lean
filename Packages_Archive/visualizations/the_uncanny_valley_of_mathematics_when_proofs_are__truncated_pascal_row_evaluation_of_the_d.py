def H(d: int, n: int) -> int:
    """Maximal regions from n hyperplanes in d-space: sum of first d+1 Pascal entries."""
    total = 0
    binom = 1  # C(n, 0)
    for k in range(min(d, n) + 1):
        total += binom
        binom = binom * (n - k) // (k + 1)  # advance to C(n, k+1)
    return total
