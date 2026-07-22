from typing import List, Tuple

Vertex = Tuple[int, ...]


def certify_product_helly(g: List[Vertex], h: List[Vertex],
                          harmonic_even_test) -> bool:
    """Certify the opposite-semicube Helly property of the Cartesian product
    G x H using ONLY the factors (Main Theorem).  Cost is that of testing G and
    H separately -- the product of size |G|*|H| is never built."""
    return harmonic_even_test(g) and harmonic_even_test(h)


def cartesian_product(g: List[Vertex], h: List[Vertex]) -> List[Vertex]:
    """Explicit product (for validation only); concatenate Hamming codes."""
    return [gv + hv for gv in g for hv in h]
