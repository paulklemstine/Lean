"""Visualization: tropical Newton-polygon picture of term orders vs f-order n.

Plots, for the differential polynomial P(f) = (f')^2 + f'', the tropicalized order of each
term as a function of n = ord(f). The lower envelope is trop(P)(n) (the growth lower bound
from `order_diffPoly_ge`); the kink where two lines cross is the balanced order predicted by
`tropical_FTDA`. Saves tropical_newton.png.
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

ns = np.arange(0, 9)
term1 = 2 * (ns - 1)   # (f')^2 -> 2(n-1)
term2 = ns - 2         # f''    -> n-2
lower = np.minimum(term1, term2)

fig, ax = plt.subplots(figsize=(7, 5))
ax.plot(ns, term1, "o-", label=r"ord$((f')^2)=2(n-1)$")
ax.plot(ns, term2, "s-", label=r"ord$(f'')=n-2$")
ax.plot(ns, lower, "k--", lw=2.5, label=r"trop$(P)(n)=\min$ (growth bound)")
cross = [n for n in ns if 2 * (n - 1) == (n - 2)]
for n in cross:
    ax.axvline(n, color="red", ls=":", alpha=0.6)
    ax.annotate("balanced", (n, n - 2), textcoords="offset points", xytext=(8, -4),
                color="red")
ax.set_xlabel("n = ord(f)")
ax.set_ylabel("tropical order of term")
ax.set_title("Tropical Newton polygon of P(f) = (f')^2 + f''")
ax.legend()
ax.grid(alpha=0.3)
fig.tight_layout()
fig.savefig("tropical_newton.png", dpi=150)
print("wrote tropical_newton.png")
