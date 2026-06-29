"""Visualization: growth races behind the p-degree order.

Plots, on a log scale, the cost functions of the canonical proof systems
(linear, intermediate, Fibonacci) and the spike supports, illustrating why
exponential/Fibonacci growth escapes every polynomial blow-up.
"""

from __future__ import annotations

from typing import List
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def main() -> None:
    ns: List[int] = list(range(1, 26))
    lin = [n for n in ns]
    inter = [fib(n) if n % 2 == 0 else n for n in ns]
    fibc = [fib(n) for n in ns]
    poly2 = [(n + 2) ** 2 for n in ns]
    poly3 = [(n + 2) ** 3 for n in ns]

    fig, ax = plt.subplots(figsize=(9, 6))
    ax.plot(ns, lin, "o-", label="linSystem  cost = n")
    ax.plot(ns, inter, "s-", label="interSys  (fib on evens, n on odds)")
    ax.plot(ns, fibc, "^-", label="fibSystem  cost = F(n)")
    ax.plot(ns, poly2, "--", label="poly bound (n+2)^2")
    ax.plot(ns, poly3, "--", label="poly bound (n+2)^3")
    ax.set_yscale("log")
    ax.set_xlabel("theorem index n")
    ax.set_ylabel("proof size (log scale)")
    ax.set_title("Cost functions of the p-degree order: poly bounds are outrun")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("growth_race.png", dpi=150)
    print("saved growth_race.png")


if __name__ == "__main__":
    main()
