from typing import Callable, Sequence

def cross_mul_defect(
    f: Callable[[float, float], float],
    xs: Sequence[float],
    ys: Sequence[float],
) -> float:
    """Maximum violation of f(x,y) f(x',y') = f(x,y') f(x',y) over a grid.
    Returns 0 (up to rounding) iff f is multiplicatively separable, i.e. iff a
    rank-one EML representation f(x,y) = exp(psi(x) + phi(y)) exists."""
    defect = 0.0
    for x in xs:
        for y in ys:
            for x2 in xs:
                for y2 in ys:
                    lhs = f(x, y) * f(x2, y2)
                    rhs = f(x, y2) * f(x2, y)
                    defect = max(defect, abs(lhs - rhs))
    return defect
