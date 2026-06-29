from typing import Callable, FrozenSet

Region = FrozenSet[int]


def rt_bridge_consistent(S: Callable[[Region], float], X: Region, Y: Region,
                         tol: float = 1e-12) -> bool:
    """Verify the exact RT bridge defect(X,Y) = areaDefect(X,Y)/4 with area = 4*S,
    the finite content of syndromeDefect_eq_area_defect_div_four and
    rt_submodularity_iff_area_submodularity."""
    area: Callable[[Region], float] = lambda Z: 4.0 * S(Z)
    defect = S(X) + S(Y) - S(X & Y) - S(X | Y)
    area_defect = area(X) + area(Y) - area(X & Y) - area(X | Y)
    return abs(defect - area_defect / 4.0) < tol
