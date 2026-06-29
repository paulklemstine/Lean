import math

def fusion_count(n: int) -> int:
    if n == 0:
        return 1
    if n == 1:
        return 2
    a, b = 1, 2
    for _ in range(n - 1):
        a, b = b, a + b
    return b

def area_law_gap(n: int) -> tuple[int, int, float]:
    """Return (dimension, strict gap 2^n - dim, entanglement density)."""
    dim = fusion_count(n)
    gap = 2 ** n - dim
    density = math.log(dim) / n if n > 0 else 0.0
    return dim, gap, density
