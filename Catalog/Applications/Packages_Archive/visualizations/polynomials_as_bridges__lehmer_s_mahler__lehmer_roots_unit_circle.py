"""Plot the 10 complex roots of Lehmer's polynomial against the unit circle.

Shows nine roots on/inside the unit circle and the single Salem root (and its
reciprocal) escaping it -- the spectral-escape that certifies positive entropy.
Requires matplotlib.
"""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt

LEHMER: List[int] = [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1]

def poly_eval(coeffs, x):
    r = 0
    for c in reversed(coeffs):
        r = r * x + c
    return r

def roots(coeffs, iters=2000, tol=1e-15):
    d = max(k for k, c in enumerate(coeffs) if c != 0)
    monic = [c / coeffs[d] for c in coeffs[:d + 1]]
    z = [complex(0.4, 0.9) ** k for k in range(d)]
    for _ in range(iters):
        for i in range(d):
            den = 1.0
            for j in range(d):
                if j != i:
                    den *= z[i] - z[j]
            z[i] -= poly_eval(monic, z[i]) / den
    return z

rts = roots(LEHMER)
fig, ax = plt.subplots(figsize=(6, 6))
theta = [2 * math.pi * t / 400 for t in range(401)]
ax.plot([math.cos(t) for t in theta], [math.sin(t) for t in theta],
        "k--", lw=1, label="unit circle")
inside = [r for r in rts if abs(r) <= 1 + 1e-6]
outside = [r for r in rts if abs(r) > 1 + 1e-6]
ax.scatter([r.real for r in inside], [r.imag for r in inside],
           c="steelblue", s=40, label="|alpha| <= 1")
ax.scatter([r.real for r in outside], [r.imag for r in outside],
           c="crimson", s=60, marker="*", label="Salem root |alpha| > 1")
ax.set_aspect("equal")
ax.set_title("Roots of Lehmer's polynomial (Salem root escapes)")
ax.legend(loc="upper left")
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("lehmer_roots.png", dpi=150)
print("wrote lehmer_roots.png")
