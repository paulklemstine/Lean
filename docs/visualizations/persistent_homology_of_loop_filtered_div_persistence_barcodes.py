#!/usr/bin/env python3
"""
Visualization: Persistence Barcodes for Scalar QFTs

Visualizes the persistence barcodes for different scalar field theories,
showing how renormalizable theories have finitely many infinite bars
while non-renormalizable theories accumulate new bars at each loop order.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# ─── Theory data ──────────────────────────────────────────────────

theories = {
    "φ³ in 6D\n(super-renorm)": {
        "bars": [(1, None, "2-pt")],
        "color": "#2196F3",
        "renorm": True,
    },
    "φ⁴ in 4D\n(renormalizable)": {
        "bars": [(1, None, "2-pt"), (1, None, "4-pt")],
        "color": "#4CAF50",
        "renorm": True,
    },
    "φ⁶ in 3D\n(renormalizable)": {
        "bars": [(1, None, "2-pt"), (1, None, "4-pt"), (1, None, "6-pt")],
        "color": "#FF9800",
        "renorm": True,
    },
    "Non-renorm\ntoy model": {
        "bars": [(1, None, "2-pt"), (1, None, "4-pt"),
                 (2, None, "6-pt"), (3, None, "8-pt"),
                 (4, None, "10-pt")],
        "color": "#F44336",
        "renorm": False,
    },
}

fig, axes = plt.subplots(1, 4, figsize=(16, 5), sharey=False)
fig.suptitle("Persistence Barcodes of Loop-Filtered Divergence Complexes",
             fontsize=14, fontweight='bold', y=0.98)

max_loop = 6

for ax, (name, data) in zip(axes, theories.items()):
    bars = data["bars"]
    color = data["color"]
    n_bars = len(bars)

    for i, (birth, death, label) in enumerate(bars):
        y = n_bars - i - 0.5
        end = death if death is not None else max_loop + 0.5
        ax.barh(y, end - birth, left=birth, height=0.6,
                color=color, alpha=0.7, edgecolor='black', linewidth=0.5)
        if death is None:
            # Arrow for infinite persistence
            ax.annotate('', xy=(max_loop + 0.5, y), xytext=(max_loop + 0.1, y),
                       arrowprops=dict(arrowstyle='->', color=color, lw=2))
        ax.text(birth + 0.1, y, label, va='center', fontsize=8,
                fontweight='bold', color='white')

    ax.set_xlim(0, max_loop + 1)
    ax.set_ylim(-0.5, n_bars + 0.5)
    ax.set_xlabel("Loop order", fontsize=10)
    ax.set_title(name, fontsize=10, pad=10)
    ax.set_yticks([])

    # Add β̄ annotation
    beta = len([b for b in bars if b[1] is None])
    bounded = "bounded" if data["renorm"] else "growing"
    ax.text(0.95, 0.05, f"β̄ = {beta}\n({bounded})",
            transform=ax.transAxes, ha='right', va='bottom',
            fontsize=9, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.axvline(x=0.5, color='gray', linestyle='--', alpha=0.3)

plt.tight_layout()
plt.savefig("barcodes.png", dpi=150, bbox_inches='tight')
print("Saved barcodes.png")
