"""Visualize convergence to 1/2 and divergence of |zeta(2s-1)|."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt
import mpmath as mp

ks = np.arange(1, 9)
residues = [float((1 + 10.0**(-k) - 1) * mp.zeta(2*(1 + 10.0**(-k)) - 1)) for k in ks]
mags = [float(abs(mp.zeta(2*(1 + 10.0**(-k)) - 1))) for k in ks]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4))
ax1.plot(ks, residues, "o-", color="#2b6cb0")
ax1.axhline(0.5, ls="--", color="gray", label="limit 1/2")
ax1.set_xlabel("k  (s = 1 + 10^-k)"); ax1.set_ylabel("(s-1) zeta(2s-1)")
ax1.set_title("Residue converges to 1/2"); ax1.legend()

ax2.semilogy(ks, mags, "s-", color="#c53030")
ax2.set_xlabel("k  (s = 1 + 10^-k)"); ax2.set_ylabel("|zeta(2s-1)|")
ax2.set_title("Arithmetic factor blows up")

plt.tight_layout()
plt.savefig("franke_pole.png", dpi=150)
print("saved franke_pole.png")
