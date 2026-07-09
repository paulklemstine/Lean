"""Visualization: deep size 2k vs forced shallow width 2^k(1-2eps)/A on a
log scale, showing the unbounded gap."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

eps, A = 0.1, 1.0
ks = np.arange(1, 21)
deep = 2 * ks
shallow = (2.0 ** ks) * (1.0 - 2.0 * eps) / A

fig, ax = plt.subplots(figsize=(9, 6))
ax.semilogy(ks, deep, "o-", label="deep size = 2k (linear)", color="#2ca02c")
ax.semilogy(ks, shallow, "s-",
            label="forced shallow width ≈ 2^k(1-2ε)/A (exponential)",
            color="#d62728")
ax.set_xlabel("depth k")
ax.set_ylabel("network size (log scale)")
ax.set_title("Two-sided depth–width separation: linear deep vs exponential shallow")
ax.legend()
ax.grid(alpha=0.3, which="both")
fig.tight_layout()
fig.savefig("depth_width_gap.png", dpi=150)
print("saved depth_width_gap.png")
