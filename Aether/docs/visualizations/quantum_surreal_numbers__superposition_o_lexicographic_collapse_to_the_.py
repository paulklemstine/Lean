"""Lexicographic collapse: primary vs. secondary layers and the observed result."""
import matplotlib.pyplot as plt
import numpy as np

vectors = [[0.5, 0.0], [0.5, 0.0], [0.0, 1.0]]  # A, B, C over (primary, secondary)
labels = ["A", "B", "C"]
primary = [v[0] for v in vectors]
secondary = [v[1] for v in vectors]
observed = primary  # standard part = projection onto primary layer

x = np.arange(len(labels))
fig, axes = plt.subplots(1, 2, figsize=(10, 4.2))
axes[0].bar(x - 0.2, primary, width=0.4, label="primary layer")
axes[0].bar(x + 0.2, secondary, width=0.4, label="secondary layer (infinitesimal)")
axes[0].set_xticks(x); axes[0].set_xticklabels(labels)
axes[0].set_title("Lexicographic system"); axes[0].legend()
axes[1].bar(x, observed, color="seagreen")
axes[1].set_xticks(x); axes[1].set_xticklabels(labels)
axes[1].set_title("Observed distribution = primary layer")
for ax in axes:
    ax.set_ylim(0, 1.05); ax.set_ylabel("probability")
plt.suptitle("Standard part projects a lexicographic system onto its primary layer")
plt.tight_layout()
plt.savefig("lexicographic_collapse.png", dpi=150)
print("saved lexicographic_collapse.png")
