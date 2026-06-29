"""
Visualization: the apparition lattice and the p-adic height profile of Fibonacci.

Produces two panels:
  (left)  a divisibility heatmap: cell (m, n) shaded when m | Fib(n), revealing
          the perfectly periodic vertical stripes spaced by R(m);
  (right) the 7-adic height |Fib(n)|_7 as a stem plot, dipping below 1 exactly
          on multiples of R(7) = 8.

Requires: matplotlib, numpy.  Run:  python3 visualization.py
"""
from __future__ import annotations
from fractions import Fraction
import numpy as np
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_rank(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0, 1
    for k in range(1, m * m + 1):
        a, b = b % m, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError


def p_adic_norm(z: int, p: int) -> float:
    if z == 0:
        return 0.0
    v = 0
    z = abs(z)
    while z % p == 0:
        z //= p
        v += 1
    return float(Fraction(p) ** (-v))


M, N = 12, 40
grid = np.zeros((M, N + 1))
for m in range(1, M + 1):
    for n in range(0, N + 1):
        grid[m - 1, n] = 1.0 if (n > 0 and fib(n) % m == 0) else 0.0

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

ax1.imshow(grid, aspect="auto", cmap="viridis", origin="lower",
           extent=[0, N, 1, M + 1])
ax1.set_xlabel("index n")
ax1.set_ylabel("modulus m")
ax1.set_title("Apparition lattice:  m | Fib(n)\n(stripes spaced by the rank R(m))")
for m in range(1, M + 1):
    r = fib_rank(m)
    ax1.text(N + 0.5, m + 0.5, f"R={r}", va="center", fontsize=7)

p = 7
ns = list(range(1, N + 1))
heights = [p_adic_norm(fib(n), p) for n in ns]
ax2.stem(ns, heights, basefmt=" ")
ax2.axhline(1.0, color="red", ls="--", lw=1, label="height = 1")
r7 = fib_rank(p)
for n in ns:
    if n % r7 == 0:
        ax2.axvline(n, color="green", alpha=0.25)
ax2.set_xlabel("index n")
ax2.set_ylabel(r"$|Fib(n)|_7$")
ax2.set_title(f"7-adic height of Fib(n)\n(dips below 1 exactly on multiples of R(7)={r7})")
ax2.legend()

plt.tight_layout()
plt.savefig("fibonacci_apparition.png", dpi=150)
print("wrote fibonacci_apparition.png")
