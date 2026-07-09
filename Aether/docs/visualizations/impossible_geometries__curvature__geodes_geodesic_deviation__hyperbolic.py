"""Visualization: hyperbolic divergence vs. elliptic refocusing of Jacobi fields."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

t = np.linspace(0.0, math.pi, 600)
hyp = np.sinh(t)              # K = -1: diverges
ell = np.sin(t)              # K = +1: bounded, refocuses at pi

fig, ax = plt.subplots(1, 2, figsize=(11, 4.5))
ax[0].plot(t, hyp, color="crimson")
ax[0].set_title("Hyperbolic (K=-1): J(t)=sinh(t) diverges")
ax[0].set_xlabel("t"); ax[0].set_ylabel("separation J(t)")
ax[1].plot(t, ell, color="navy")
ax[1].axhline(0, color="gray", lw=0.8)
ax[1].scatter([math.pi], [0.0], color="navy", zorder=5, label="refocus at pi")
ax[1].set_title("Elliptic (K=+1): J(t)=sin(t) refocuses")
ax[1].set_xlabel("t"); ax[1].legend()
plt.tight_layout()
plt.savefig("jacobi_fields.png", dpi=150)
print("wrote jacobi_fields.png")
