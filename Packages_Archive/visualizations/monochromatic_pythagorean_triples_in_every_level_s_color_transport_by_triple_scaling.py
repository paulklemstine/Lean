from math import gcd

def color_of(n: int, k: int, prime_color: dict[int, int]) -> int:
    """f(n) in Z/kZ for a completely multiplicative coloring given by prime colors."""
    total, m, d = 0, n, 2
    while d * d <= m:
        while m % d == 0:
            total += prime_color.get(d, 0)
            m //= d
        d += 1
    if m > 1:
        total += prime_color.get(m, 0)
    return total % k

def transport_to_color(seed: tuple[int, int, int], target: int,
                       k: int, prime_color: dict[int, int],
                       bound: int = 100000) -> tuple[int, int, int]:
    """Given a monochromatic seed Pythagorean triple, return a triple
    monochromatic of color `target` (assumed in the image of f)."""
    v0 = color_of(seed[0], k, prime_color)
    gamma = (target - v0) % k            # v0^{-1} * target, written additively
    t = next(t for t in range(1, bound + 1)
             if color_of(t, k, prime_color) == gamma)
    return (t * seed[0], t * seed[1], t * seed[2])
