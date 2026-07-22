from typing import Callable, Dict, Optional, Tuple

Point = Tuple[float, float]


def classify_cell(p: Point) -> Optional[str]:
    """Assign a point of [0,1]^2 to one of the four half-open cells."""
    x, y = p
    if not (0.0 <= x <= 1.0 and 0.0 <= y <= 1.0):
        return None
    left, bottom = x < 0.5, y < 0.5
    if left and bottom:
        return "D1"
    if left:
        return "D2"
    if not bottom:
        return "D3"
    return "D4"


def cell_permutation(g: Callable[[Point], Point],
                     grid: int = 200) -> Dict[str, str]:
    """Deterministically read off how a symmetry g permutes the four cells
    by probing the interior center of each cell."""
    centers = {"D1": (0.25, 0.25), "D2": (0.25, 0.75),
               "D3": (0.75, 0.75), "D4": (0.75, 0.25)}
    return {name: classify_cell(g(pt)) for name, pt in centers.items()}
