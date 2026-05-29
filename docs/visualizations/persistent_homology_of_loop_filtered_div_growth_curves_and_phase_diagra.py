#!/usr/bin/env python3
"""
Visualization: Persistent Bar Count Growth Curves

Shows how the persistent 1-bar count evolves with loop order for
different scalar theories. Renormalizable theories plateau while
non-renormalizable theories grow without bound.
"""

import matplotlib.pyplot as plt
import numpy as np

# ─── Theory persistence count data ────────────────────────────────

theories = {
    "φ³₆D (super-renorm)": {
        "counts": [1, 1, 1, 1, 1, 1, 1, 1],
        "color": "#2196F3", "marker": "o", "style": "-",
    },
    "φ⁴₃D (super-renorm)": {
        "counts": [1, 1, 1, 1, 1, 1, 1, 1],
        "color": "#03A9F4", "marker": "s", "style": "-",
    },
    "φ⁴₄D (renormalizable)": {
        "counts": [2, 2, 2, 2, 2, 2, 2, 2],
        "color": "#4CAF50", "marker": "D", "style": "-",
    },
    "φ⁶₃D (renormalizable)": {
        "counts": [3, 3, 3, 3, 3, 3, 3, 3],
        "color": "#FF9800", "marker": "^", "style": "-",
    },
    "Non-renorm (linear)": {
        "counts": [1, 2, 3, 4, 5, 6, 7, 8],
        "color": "#F44336", "marker": "v", "style": "--",
    },
    "Non-renorm (quadratic)": {
        "counts": [2, 3, 5, 8, 12, 17, 23, 30],
        "color": "#9C27B0", "marker": "x", "style": "--",
    },
}

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# ─── Left plot: all theories ──────────────────────────────────────

loops = list(range(1, 9))

for name, data in theories.items():
    ax1.plot(loops, data["counts"], data["style"],
             color=data["color"], marker=data["marker"],
             markersize=6, linewidth=2, label=name)

ax1.set_xlabel("Loop order L", fontsize=12)
ax1.set_ylabel("Persistent 1-bar count β̄(L)", fontsize=12)
ax1.set_title("Persistent Bar Count vs Loop Order", fontsize=13, fontweight='bold')
ax1.legend(loc='upper left', fontsize=9)
ax1.set_xlim(0.5, 8.5)
ax1.set_ylim(0, 32)
ax1.grid(True, alpha=0.3)

# Add regions
ax1.axhspan(0, 4, alpha=0.05, color='green')
ax1.text(8, 3.5, "Renormalizable\nregion", ha='right', va='top',
         fontsize=9, color='green', alpha=0.7)

# ─── Right plot: renormalizability classification ─────────────────

# Phase diagram: interaction power vs spacetime dimension
p_values = np.arange(3, 11)
d_critical = 2 * p_values / (p_values - 2)

ax2.plot(p_values, d_critical, 'k-', linewidth=2, label='d_c = 2p/(p-2)')
ax2.fill_between(p_values, d_critical, 0, alpha=0.15, color='green',
                  label='Renormalizable (d ≤ d_c)')
ax2.fill_between(p_values, d_critical, 12, alpha=0.15, color='red',
                  label='Non-renormalizable (d > d_c)')

# Mark specific theories
specific = [
    (3, 6, "φ³₆D", "#2196F3"),
    (4, 4, "φ⁴₄D", "#4CAF50"),
    (6, 3, "φ⁶₃D", "#FF9800"),
    (4, 5, "φ⁴₅D", "#F44336"),
    (4, 6, "φ⁴₆D", "#9C27B0"),
]

for p, d, label, color in specific:
    ax2.plot(p, d, 'o', color=color, markersize=10, zorder=5)
    ax2.annotate(label, (p, d), textcoords="offset points",
                xytext=(10, 5), fontsize=9, color=color, fontweight='bold')

ax2.set_xlabel("Interaction power p (φᵖ theory)", fontsize=12)
ax2.set_ylabel("Spacetime dimension d", fontsize=12)
ax2.set_title("Renormalizability Phase Diagram", fontsize=13, fontweight='bold')
ax2.legend(loc='upper right', fontsize=9)
ax2.set_xlim(2.5, 10.5)
ax2.set_ylim(1.5, 10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("growth_curves.png", dpi=150, bbox_inches='tight')
print("Saved growth_curves.png")
