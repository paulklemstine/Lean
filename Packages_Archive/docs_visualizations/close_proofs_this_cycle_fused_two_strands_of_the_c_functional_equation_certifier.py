from fractions import Fraction
from typing import Callable


def verify_functional_equations(
    n: int,
    h: Callable[[int, int], int],
    u: Fraction,
    v: Fraction,
) -> dict:
    """Numerically verify the mirror and (if applicable) Serre equations."""
    def E(hh, a, b):
        s = Fraction(0)
        for p in range(n + 1):
            for q in range(n + 1):
                s += Fraction((-1) ** (p + q) * hh(p, q)) * a ** p * b ** q
        return s

    hm = lambda p, q: h(n - p, q)
    mirror_ok = E(hm, u, v) == Fraction((-1) ** n) * u ** n * E(h, 1 / u, v)

    serre_dual = all(
        h(p, q) == h(n - p, n - q)
        for p in range(n + 1) for q in range(n + 1)
    )
    serre_ok = None
    if serre_dual:
        serre_ok = E(h, u, v) == (u * v) ** n * E(h, 1 / u, 1 / v)

    return {"mirror_equation": mirror_ok,
            "serre_dual": serre_dual,
            "serre_equation": serre_ok}
