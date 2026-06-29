from typing import Dict, List, Tuple

Square = Tuple[Tuple[int, ...], ...]


def fiber_histogram(squares: List[Square], r: int, c: int, n: int) -> Dict[int, int]:
    """Histogram t -> #{ L : L(r, c) = t } realizing the cell-fiber F_t."""
    hist: Dict[int, int] = {t: 0 for t in range(n)}
    for L in squares:
        hist[L[r][c]] += 1
    return hist


def verify_exact_uniformity(squares: List[Square], n: int) -> bool:
    """Check the MAIN theorem  N = n * #fiber  for every cell (r,c) and symbol s."""
    N = len(squares)
    for r in range(n):
        for c in range(n):
            hist = fiber_histogram(squares, r, c, n)
            for s in range(n):
                if N != n * hist[s]:
                    return False
    return True
