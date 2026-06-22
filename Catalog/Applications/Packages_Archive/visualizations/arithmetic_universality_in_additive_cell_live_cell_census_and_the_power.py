"""Plot the live-cell count N_p(t) and mark its sparsest moments (powers of p).

Demonstrates Proposition 7.1: N_p(t) = prod_i (d_i + 1) over base-p digits of t,
with the global minima N_p(t) = 2 occurring exactly at t = p^k.
Requires matplotlib.
"""
from __future__ import annotations
from typing import List
import matplotlib.pyplot as plt


def base_p_digits(n: int, p: int) -> List[int]:
    if n == 0:
        return [0]
    d: List[int] = []
    while n > 0:
        d.append(n % p); n //= p
    return d


def live_count(t: int, p: int) -> int:
    prod = 1
    for d in base_p_digits(t, p):
        prod *= (d + 1)
    return prod


def render(p: int = 2, tmax: int = 128) -> None:
    ts = list(range(1, tmax + 1))
    ys = [live_count(t, p) for t in ts]
    plt.figure(figsize=(11, 4))
    plt.stem(ts, ys, basefmt=" ")
    powers = [p ** k for k in range(0, tmax) if p ** k <= tmax]
    plt.scatter(powers, [live_count(t, p) for t in powers],
                color="red", zorder=5, label="t = p^k  (count = 2)")
    plt.xlabel("time t"); plt.ylabel("live cells  N_p(t)")
    plt.title(f"Live-cell census of the additive CA over F_{p}")
    plt.legend(); plt.tight_layout()
    plt.savefig(f"live_cell_count_p{p}.png", dpi=150)
    print(f"wrote live_cell_count_p{p}.png")


if __name__ == "__main__":
    render(2, 128)
    render(3, 120)
