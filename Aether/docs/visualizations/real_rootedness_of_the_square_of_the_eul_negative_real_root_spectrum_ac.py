"""Plot the negative real root spectrum of S_n across rows (requires matplotlib)."""
from fractions import Fraction
from functools import lru_cache
from typing import List
import matplotlib.pyplot as plt

@lru_cache(maxsize=None)
def eulerian(n: int, k: int) -> int:
    if k < 0 or k >= max(n, 1):
        return 0
    if n == 0:
        return 1 if k == 0 else 0
    if k == 0:
        return 1
    return (k + 1) * eulerian(n - 1, k) + (n - k) * eulerian(n - 1, k - 1)

def squared_row(n: int) -> List[int]:
    top = max(n, 1)
    c = [sum(eulerian(n, j) * eulerian(j, k) for j in range(top)) for k in range(top)]
    while len(c) > 1 and c[-1] == 0:
        c.pop()
    return c

def _eval(c: List[float], x: float) -> float:
    acc = 0.0
    for a in reversed(c):
        acc = acc * x + a
    return acc

def real_roots(coeffs: List[int]) -> List[float]:
    c = [float(a) for a in coeffs]; roots = []
    x, prev = -2000.0, _eval([float(a) for a in coeffs], -2000.0)
    while x < 0.0:
        nx = x + 0.005; v = _eval(c, nx)
        if prev * v < 0:
            a, b = x, nx
            for _ in range(80):
                m = 0.5 * (a + b)
                if _eval(c, a) * _eval(c, m) <= 0: b = m
                else: a = m
            roots.append(0.5 * (a + b))
        prev = v; x = nx
    return sorted(roots)

fig, ax = plt.subplots(figsize=(8, 5))
for n in range(3, 12):
    r = real_roots(squared_row(n))
    ax.scatter([-abs(v) for v in r], [n] * len(r), s=30)
ax.set_xscale("-linear") if False else None
ax.set_xlabel("root value (negative real axis)")
ax.set_ylabel("row n")
ax.set_title("Real root spectrum of the squared Eulerian row polynomials S_n")
plt.tight_layout(); plt.savefig("root_spectrum.png", dpi=150)
print("wrote root_spectrum.png")
