"""Existence phase diagram in the (a, c) plane: the sharp curve c = e^a(1-a)
separates the subcritical region (no fixed point) from the supercritical region
(fixed point exists). Requires matplotlib + numpy."""
import numpy as np
import matplotlib.pyplot as plt

a = np.linspace(-1.0, 2.0, 400)
threshold = np.exp(a) * (1.0 - a)
plt.figure(figsize=(8, 5))
plt.plot(a, threshold, "k", lw=2, label=r"$c = e^a(1-a)$ (threshold)")
plt.fill_between(a, threshold, threshold.max() + 1, alpha=0.2,
                 label="supercritical: fixed point exists")
plt.fill_between(a, threshold.min() - 1, threshold, alpha=0.2,
                 label="subcritical: NO fixed point")
plt.scatter([0.5], [0.5], color="red", zorder=5,
            label="a=c=0.5 (in the naive box, yet NONE)")
plt.xlabel("a"); plt.ylabel("c")
plt.title("EML sharp existence threshold (b = 1)")
plt.legend(loc="upper left"); plt.tight_layout()
plt.savefig("eml_existence_phase.png", dpi=150)
print("wrote eml_existence_phase.png")
