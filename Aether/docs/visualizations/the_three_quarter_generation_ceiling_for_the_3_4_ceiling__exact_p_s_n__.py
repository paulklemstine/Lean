"""Visualization: exact generation probability P(S_n) versus the 3/4 ceiling.

Generates a bar/line chart of the exact values P(S_2..S_5) = {3/4, 1/2, 3/8, 19/40}
together with the constant ceiling y = 3/4, illustrating that every value respects
the cap and that equality is attained only at n = 2.
"""
from __future__ import annotations
from fractions import Fraction
import matplotlib.pyplot as plt

# Exact values computed by enumeration (g / (n!)^2).
ns = [2, 3, 4, 5]
probs = [Fraction(3, 4), Fraction(1, 2), Fraction(3, 8), Fraction(19, 40)]
vals = [float(p) for p in probs]

fig, ax = plt.subplots(figsize=(8, 5))
ax.axhline(0.75, color="crimson", linestyle="--", linewidth=2,
           label="ceiling 3/4")
ax.plot(ns, vals, "o-", color="navy", markersize=9, linewidth=2,
        label="P(S_n) (exact)")
for n, p, v in zip(ns, probs, vals):
    ax.annotate(f"{p}", (n, v), textcoords="offset points", xytext=(0, 10),
                ha="center", fontsize=11)
# the band of doomed (both-even) pairs: always exactly 1/4
ax.fill_between([1.7, 5.3], 0.75, 1.0, color="crimson", alpha=0.08,
                label="forbidden by parity (>=1/4 of pairs)")
ax.set_xlabel("n  (symbols permuted)")
ax.set_ylabel("probability a random pair generates S_n")
ax.set_title("The 3/4 Generation Ceiling for the Symmetric Group")
ax.set_xticks(ns)
ax.set_ylim(0.0, 1.0)
ax.legend(loc="lower right")
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("generation_ceiling.png", dpi=150)
print("Saved generation_ceiling.png")
