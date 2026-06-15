from __future__ import annotations


def fib_entry(m: int) -> int:
    """Least k > 0 with m | F(k), via the pair-map (F(n),F(n+1)) mod m.

    Terminates within m^2 + 1 steps; uses only modular arithmetic below m.
    """
    if m <= 0:
        raise ValueError("entry point is defined for m > 0")
    if m == 1:
        return 1
    a, b = 0 % m, 1 % m
    for k in range(1, m * m + 2):
        a, b = b, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError("unreachable: existence theorem guarantees termination")
