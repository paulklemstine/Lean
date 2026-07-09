"""Log-log plot: midpoint error (slope -2) vs classical errors (slope -1)."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

GAMMA: float = 0.57721566490153286060651209008240243104215933593992


def harmonic(n: int) -> float:
    return sum(1.0 / k for k in range(1, n + 1))


def main() -> None:
    ns = [2 ** k for k in range(0, 14)]
    h = 0.0
    prev = 0
    cache = {}
    for n in ns:
        for k in range(prev + 1, n + 1):
            h += 1.0 / k
        prev = n
        cache[n] = h
    mid = [abs(cache[n] - math.log(n + 0.5) - GAMMA) for n in ns]
    up = [abs(cache[n] - math.log(n) - GAMMA) for n in ns]
    lo = [abs(GAMMA - (cache[n] - math.log(n + 1.0))) for n in ns]
    ref2 = [1.0 / (24.0 * n * n) for n in ns]
    ref1 = [1.0 / (2.0 * n) for n in ns]

    plt.figure(figsize=(8, 6))
    plt.loglog(ns, mid, "o-", label="midpoint |m_n - gamma|")
    plt.loglog(ns, up, "s--", label="classical upper |b_n - gamma|")
    plt.loglog(ns, lo, "^--", label="classical lower |a_n - gamma|")
    plt.loglog(ns, ref2, "k:", label="1/(24 n^2)")
    plt.loglog(ns, ref1, "k-.", label="1/(2 n)")
    plt.xlabel("n")
    plt.ylabel("absolute error")
    plt.title("Midpoint acceleration of the Euler-Mascheroni constant")
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("midpoint_convergence.png", dpi=150)
    print("saved midpoint_convergence.png")


if __name__ == "__main__":
    main()
