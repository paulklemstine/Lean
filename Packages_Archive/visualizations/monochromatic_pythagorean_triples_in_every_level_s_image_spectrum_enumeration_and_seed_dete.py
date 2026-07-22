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

def image_spectrum(k: int, prime_color: dict[int, int], bound: int = 5000) -> set[int]:
    """Enumerate the realized colors { f(n) : 1 <= n <= bound }.
    For a completely multiplicative coloring this stabilizes to the image subgroup."""
    return {color_of(n, k, prime_color) for n in range(1, bound + 1)}

def find_small_mono_triple(triples: list[tuple[int, int, int]],
                           k: int, prime_color: dict[int, int]):
    """Return the first monochromatic Pythagorean triple in `triples`, or None."""
    for (x, y, z) in triples:
        cx, cy, cz = color_of(x, k, prime_color), color_of(y, k, prime_color), color_of(z, k, prime_color)
        if cx == cy == cz:
            return (x, y, z)
    return None
