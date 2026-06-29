from __future__ import annotations
from fractions import Fraction
from typing import Callable, Dict, Tuple


def epoly(n: int, h: Callable[[int, int], int], u: Fraction, v: Fraction) -> Fraction:
    """E(X; u, v) = sum_{p,q in [0,n]} (-1)^(p+q) h^{p,q} u^p v^q."""
    total = Fraction(0)
    for p in range(n + 1):
        for q in range(n + 1):
            sign = -1 if (p + q) % 2 else 1
            total += sign * h(p, q) * (u ** p) * (v ** q)
    return total


def mirror_h(n: int, h: Callable[[int, int], int]) -> Callable[[int, int], int]:
    """The mirror diamond's Hodge function: h'^{p,q} = h^{n-p, q}."""
    return lambda p, q: h(n - p, q)


def is_serre_dual(n: int, h: Callable[[int, int], int]) -> bool:
    """Serre self-duality: h^{p,q} = h^{n-p, n-q} for all p, q in [0, n]."""
    return all(h(p, q) == h(n - p, n - q)
               for p in range(n + 1) for q in range(n + 1))


def verify(n: int, h: Callable[[int, int], int],
           u: Fraction, v: Fraction) -> Dict[str, bool]:
    """Certify the mirror and (if applicable) Serre functional equations exactly."""
    assert u != 0
    sign = -1 if n % 2 else 1
    hm = mirror_h(n, h)
    mirror_ok = (epoly(n, hm, u, v)
                 == sign * (u ** n) * epoly(n, h, 1 / u, v))
    serre_ok = True
    if is_serre_dual(n, h) and v != 0:
        serre_ok = (epoly(n, h, u, v)
                    == ((u * v) ** n) * epoly(n, h, 1 / u, 1 / v))
    return {"mirror_functional_equation": mirror_ok,
            "serre_functional_equation": serre_ok}


if __name__ == "__main__":
    # quintic threefold
    table: Dict[Tuple[int, int], int] = {
        (0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,
        (1, 1): 1, (2, 2): 1, (2, 1): 101, (1, 2): 101,
    }
    h = lambda p, q: table.get((p, q), 0)
    print(verify(3, h, Fraction(2), Fraction(3)))
