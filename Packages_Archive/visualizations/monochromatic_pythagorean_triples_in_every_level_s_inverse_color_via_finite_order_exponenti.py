def color_of(n: int, k: int, prime_color: dict[int, int]) -> int:
    total, m, d = 0, n, 2
    while d * d <= m:
        while m % d == 0:
            total += prime_color.get(d, 0)
            m //= d
        d += 1
    if m > 1:
        total += prime_color.get(m, 0)
    return total % k

def inverse_color_witness(n: int, group_order: int) -> int:
    """Return an integer whose color is f(n)^{-1}.
    Since g^N = 1 in a group of order N, g^{-1} = g^{N-1} = f(n^{N-1})."""
    return n ** (group_order - 1)
