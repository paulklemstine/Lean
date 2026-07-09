import numpy as np
import matplotlib.pyplot as plt

ells = np.arange(1, 33)
fig, ax = plt.subplots(figsize=(9, 5.5))
for k in [16, 24, 32, 48]:
    bound = np.sqrt(2.0**(ells - k))
    ax.semilogy(ells, bound, marker="o", ms=3, label=f"min-entropy k={k}")
ax.set_xlabel("output length  $\ell$ (bits)")
ax.set_ylabel(r"leakage bound  $\sqrt{2^{\ell-k}}$")
ax.set_title("Privacy amplification: exponential leakage decay in the entropy gap")
ax.legend(); ax.grid(alpha=0.3, which="both")
plt.tight_layout(); plt.savefig("bb84_leakage.png", dpi=150)
print("wrote bb84_leakage.png")
