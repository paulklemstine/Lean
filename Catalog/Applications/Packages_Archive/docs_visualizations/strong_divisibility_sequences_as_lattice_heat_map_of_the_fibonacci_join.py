"""Visualization: the meet/join asymmetry of the Fibonacci strong divisibility
sequence. For each pair of indices (m, n) in a grid we plot log10 of the ratio
F_lcm(m,n) / lcm(F_m, F_n) >= 1. A value of 0 (white) means the join law is an
EQUALITY (indices comparable under divisibility); positive values (color) measure
exactly how far the sequence is from being a sup-homomorphism. Requires matplotlib."""

from functools import reduce
from math import gcd, log10
import numpy as np
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lcm(x: int, y: int) -> int:
    return x // gcd(x, y) * y if x and y else 0


N = 16
ratio = np.zeros((N, N))
for m in range(1, N + 1):
    for n in range(1, N + 1):
        left = lcm(fib(m), fib(n))
        right = fib(lcm(m, n))
        ratio[m - 1, n - 1] = log10(right / left) if left else 0.0

fig, ax = plt.subplots(figsize=(7, 6))
im = ax.imshow(ratio, origin="lower", extent=[1, N, 1, N], cmap="viridis")
ax.set_title("Fibonacci join-law defect:  log10( F_lcm(m,n) / lcm(F_m,F_n) )")
ax.set_xlabel("n")
ax.set_ylabel("m")
fig.colorbar(im, ax=ax, label="0 = equality (m|n or n|m);  >0 = strict divisibility")
plt.tight_layout()
plt.savefig("fibonacci_join_defect.png", dpi=150)
print("Saved fibonacci_join_defect.png")
