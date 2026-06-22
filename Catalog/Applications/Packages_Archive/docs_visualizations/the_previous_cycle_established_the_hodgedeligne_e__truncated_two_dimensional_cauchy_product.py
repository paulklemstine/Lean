from typing import Callable, Dict, Tuple

Grid = Callable[[int, int], int]

def kunneth_convolution(h_x: Grid, n_x: int, h_y: Grid, n_y: int) -> Dict[Tuple[int, int], int]:
    """Künneth convolution of two Hodge grids.

    Computes h^{p,q}(X ⊗ Y) = Σ_{i=0}^{p} Σ_{k=0}^{q} h_x(i,k)·h_y(p-i,q-k)
    on the range 0 ≤ p,q ≤ n_x + n_y.  Out-of-range entries are treated as 0.
    Complexity: O((n_x+n_y)^2 · n_x · n_y) for the full grid.
    """
    result: Dict[Tuple[int, int], int] = {}
    for p in range(n_x + n_y + 1):
        for q in range(n_x + n_y + 1):
            total = 0
            for i in range(p + 1):
                for k in range(q + 1):
                    total += h_x(i, k) * h_y(p - i, q - k)
            if total:
                result[(p, q)] = total
    return result