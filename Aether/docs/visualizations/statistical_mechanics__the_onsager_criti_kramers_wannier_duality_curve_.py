"""Plot the Kramers-Wannier duality curve and its self-dual fixed point."""
import math
import numpy as np
import matplotlib.pyplot as plt

betas = np.linspace(0.15, 1.2, 400)
dual = 0.5 * np.arcsinh(1.0 / np.sinh(2.0 * betas))
beta_c = 0.5 * math.log(1.0 + math.sqrt(2.0))

fig, ax = plt.subplots(figsize=(6, 6))
ax.plot(betas, dual, lw=2, label=r"$\beta^* = D(\beta)$")
ax.plot(betas, betas, "k--", lw=1, label=r"$\beta^* = \beta$ (self-dual line)")
ax.plot([beta_c], [beta_c], "ro", ms=9,
        label=fr"$\beta_c = {beta_c:.4f}$")
ax.set_xlabel(r"$\beta$ (inverse temperature)")
ax.set_ylabel(r"$\beta^*$ (dual)")
ax.set_title("Kramers-Wannier duality: low <-> high temperature")
ax.legend()
ax.set_aspect("equal")
plt.tight_layout()
plt.savefig("duality_fixed_point.png", dpi=150)
print("wrote duality_fixed_point.png")
