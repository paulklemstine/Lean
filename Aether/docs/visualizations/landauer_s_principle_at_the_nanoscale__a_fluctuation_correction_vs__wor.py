"""Visualize the Jarzynski fluctuation correction vs. work spread.

Shows that the mean dissipated work for a symmetric two-outcome erasure exceeds
the reversible free-energy cost by a strictly positive, growing correction as the
work fluctuations widen -- the bound kT ln 2 is saturated only at zero spread.
"""
import math
import numpy as np
import matplotlib.pyplot as plt

alpha = 1.0
p = np.array([0.5, 0.5])
spreads = np.linspace(0.0, 3.0, 200)
corrections = []
for s in spreads:
    W = np.array([s, -s])             # centered, mean zero
    mean_W = float(p @ W)
    fluct = float(p @ np.exp(-alpha * (W - mean_W)))
    corrections.append(math.log(fluct) / alpha)

plt.figure(figsize=(8, 5))
plt.plot(spreads, corrections, lw=2, color="crimson")
plt.axhline(0.0, color="black", lw=0.8)
plt.title("Jarzynski fluctuation correction  alpha^{-1} ln E[exp(-a(W-E[W]))]")
plt.xlabel("work spread (units of kT)")
plt.ylabel("correction (>= 0, = 0 iff reversible)")
plt.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("landauer_correction.png", dpi=150)
print("wrote landauer_correction.png")
