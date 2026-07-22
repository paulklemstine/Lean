from __future__ import annotations
from typing import List, Optional, Tuple


def membership_grid(x_range: Tuple[float, float],
                    y_range: Tuple[float, float],
                    nx: int, ny: int,
                    max_iter: int = 200) -> List[List[Optional[int]]]:
    """
    Sample the parameter plane and classify each c via the escape-time
    algorithm. Cells returning None are provisional members of M; the
    escape-radius theorem guarantees all of them satisfy |c| <= 2, so the
    entire set is captured by any window containing the disk of radius 2.
    Complexity: O(nx * ny * max_iter).
    """
    x0, x1 = x_range
    y0, y1 = y_range
    grid: List[List[Optional[int]]] = []
    for j in range(ny):
        row: List[Optional[int]] = []
        for i in range(nx):
            c = complex(x0 + (x1 - x0) * i / (nx - 1),
                        y0 + (y1 - y0) * j / (ny - 1))
            z = 0.0 + 0.0j
            esc: Optional[int] = None
            for n in range(1, max_iter + 1):
                z = z * z + c
                if abs(z) > 2.0:
                    esc = n
                    break
            row.append(esc)
        grid.append(row)
    return grid
