"""Visualize Shamir privacy: t-1 shares leave the secret f(0) completely free.

For a (3, n) scheme, two shares (degree-2 curves) admit one parabola through them
for EVERY value at x=0. We plot a family of consistent parabolas, one per candidate
secret, all passing through the two observed shares but hitting every height at x=0.
"""
import numpy as np
import matplotlib.pyplot as plt

def lagrange_real(points, xs):
    xs = np.asarray(xs, dtype=float)
    out = np.zeros_like(xs)
    for i, (xi, yi) in enumerate(points):
        term = np.full_like(xs, yi, dtype=float)
        for j, (xj, _) in enumerate(points):
            if i != j:
                term *= (xs - xj) / (xi - xj)
        out += term
    return out

observed = [(1.0, 4.0), (2.0, 1.0)]      # two observed shares (t-1 = 2)
grid = np.linspace(-0.5, 3.0, 400)
plt.figure(figsize=(8, 5))
for c in range(-3, 4):                    # candidate secrets f(0) = c
    pts = [(0.0, float(c))] + observed
    plt.plot(grid, lagrange_real(pts, grid), alpha=0.7,
             label=f"secret f(0)={c}")
ox, oy = zip(*observed)
plt.scatter(ox, oy, color="black", zorder=5, s=60, label="observed shares")
plt.axvline(0, color="gray", ls="--", lw=1)
plt.title("Shamir privacy: every secret f(0) fits the same t-1 shares")
plt.xlabel("x"); plt.ylabel("f(x)")
plt.legend(fontsize=8); plt.tight_layout()
plt.savefig("shamir_privacy.png", dpi=150)
print("saved shamir_privacy.png")
