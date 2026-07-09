"""Plot the 1D free energy density and its smoothness (no phase transition)."""
import numpy as np
import matplotlib.pyplot as plt

betas = np.linspace(0.0, 2.5, 500)
f = np.log(2.0 * np.cosh(betas))            # per-site free energy
gap = 2.0 * np.exp(-betas)                  # eigenvalue gap lambda_+ - lambda_-

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.5))
ax1.plot(betas, f, lw=2)
ax1.set_xlabel(r"$\beta$")
ax1.set_ylabel(r"$f(\beta) = \ln(2\cosh\beta)$")
ax1.set_title("1D free energy density (analytic: no transition)")

ax2.plot(betas, gap, lw=2, color="crimson")
ax2.set_xlabel(r"$\beta$")
ax2.set_ylabel(r"$\lambda_+ - \lambda_- = 2e^{-\beta}$")
ax2.set_title("Spectral gap never closes")
plt.tight_layout()
plt.savefig("free_energy_1d.png", dpi=150)
print("wrote free_energy_1d.png")
