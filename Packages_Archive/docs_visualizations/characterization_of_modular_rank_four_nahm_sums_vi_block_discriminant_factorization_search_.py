from typing import List, Tuple

def factor_into_four_blocks(d: int, hi: int = 4) -> List[Tuple[int, int, int, int]]:
    """Enumerate sorted block-discriminant multisets (d1,d2,d3,d4), d_i >= 1,
    with d1*d2*d3*d4 = d. Each yields a diagonal witness diag(d1,d2,d3,d4)
    whose discriminant is d (theorem disc_diagonal)."""
    out: List[Tuple[int, int, int, int]] = []
    for a in range(1, hi + 1):
        for b in range(a, hi + 1):
            for c in range(b, hi + 1):
                for e in range(c, hi + 1):
                    if a * b * c * e == d:
                        out.append((a, b, c, e))
    return out
