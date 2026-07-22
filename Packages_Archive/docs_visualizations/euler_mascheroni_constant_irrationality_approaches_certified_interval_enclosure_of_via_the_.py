from __future__ import annotations
import math


def gamma_enclosure(epsilon: float) -> tuple[int, float, float]:
    """Return (n, a_n, m_n) with certified width m_n - a_n < epsilon.

    The interval [a_n, m_n] provably contains the Euler-Mascheroni constant
    by the sandwich  a_n = H_n - ln(n+1) < gamma < H_n - ln(n+1/2) = m_n.
    Width = ln(n+1) - ln(n+1/2) = Theta(1/n), so O(1/epsilon) iterations.
    """
    n: int = 1
    h: float = 1.0  # H_1
    while True:
        a = h - math.log(n + 1.0)
        m = h - math.log(n + 0.5)
        if m - a < epsilon:
            return n, a, m
        n += 1
        h += 1.0 / n


if __name__ == "__main__":
    for eps in (1e-2, 1e-3, 1e-4):
        n, a, m = gamma_enclosure(eps)
        print(f"eps={eps:.0e}: n={n}, [{a:.10f}, {m:.10f}]")
