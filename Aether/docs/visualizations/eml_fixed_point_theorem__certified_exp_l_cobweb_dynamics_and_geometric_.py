"""Visualize EML iteration as a cobweb plot and the certified enclosure width.

Run: python eml_visualization.py  (requires matplotlib, numpy).
"""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

a, b, c = 1.0, 1.0, 100.0
lo, hi = 0.0, 20.0
f = lambda x: math.exp(a) * math.log(b * x + c)

# fixed point
x = 0.0
for _ in range(200):
    x = f(x)
xstar = x

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# --- cobweb plot ---
xs = np.linspace(lo, hi, 400)
ax1.plot(xs, [f(t) for t in xs], "b-", label="f(x)=e·log(x+100)")
ax1.plot(xs, xs, "k--", label="y=x")
cx = 0.0
for _ in range(8):
    cy = f(cx)
    ax1.plot([cx, cx], [cx, cy], "r-", lw=0.8)
    ax1.plot([cx, cy], [cy, cy], "r-", lw=0.8)
    cx = cy
ax1.plot([xstar], [xstar], "go", ms=8, label=f"x*≈{xstar:.3f}")
ax1.set_title("Cobweb: Picard iteration converging to x*")
ax1.set_xlabel("x"); ax1.set_ylabel("f(x)"); ax1.legend()

# --- enclosure width (log scale) ---
l, u = lo, hi
widths = []
for _ in range(11):
    widths.append(u - l)
    l, u = f(l), f(u)
ax2.semilogy(range(len(widths)), widths, "mo-")
ax2.set_title("Certified bracket width u_n - l_n (log scale)")
ax2.set_xlabel("iteration n"); ax2.set_ylabel("width")
ax2.grid(True, which="both", alpha=0.3)

plt.tight_layout()
plt.savefig("eml_dynamics.png", dpi=150)
print("saved eml_dynamics.png")
