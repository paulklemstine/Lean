#!/usr/bin/env python3
"""
Visualization: Mass Gap as a Function of Coupling Strength
==========================================================
Shows how the mass gap lower bound varies with the coupling constant β
for SU(2), SU(3), and G₂, demonstrating the strong-to-weak coupling
crossover and the Dynkin diagram dependence.
"""

import numpy as np
import matplotlib.pyplot as plt

def casimir_fund(group: str) -> float:
    """Fundamental Casimir for common groups."""
    return {"SU(2)": 0.75, "SU(3)": 4/3, "SU(4)": 15/8, 
            "G₂": 2.0, "E₈": 30.0}[group]

def gap_bound(c2: float, beta: float) -> float:
    """Mass gap lower bound as function of Casimir and coupling."""
    if beta < 2.0:
        return c2 * max(0.01, 1 - beta * c2 / 4)
    else:
        return c2 * np.exp(-0.5 * (beta - 1.0))

betas = np.linspace(0.05, 5.0, 200)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Gap vs coupling
colors = {"SU(2)": "#2196F3", "SU(3)": "#F44336", "G₂": "#4CAF50"}
for group, color in colors.items():
    c2 = casimir_fund(group)
    gaps = [gap_bound(c2, b) for b in betas]
    ax1.plot(betas, gaps, color=color, linewidth=2.5, label=f"{group} (C₂={c2:.2f})")

ax1.set_xlabel("Coupling β", fontsize=14)
ax1.set_ylabel("Mass Gap Lower Bound Δ_lb", fontsize=14)
ax1.set_title("Mass Gap vs. Coupling Strength", fontsize=16)
ax1.legend(fontsize=12)
ax1.set_ylim(bottom=0)
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
ax1.grid(True, alpha=0.3)

# Right panel: Correlation decay at different gaps
times = np.linspace(0, 20, 200)
gaps_demo = [0.2, 0.5, 1.0, 2.0]
cmap = plt.cm.viridis(np.linspace(0.2, 0.9, len(gaps_demo)))

for gap, color in zip(gaps_demo, cmap):
    decay = 5 * np.exp(-gap * times)
    ax2.plot(times, decay, color=color, linewidth=2.5, label=f"Δ = {gap}")

ax2.set_xlabel("Euclidean Time t", fontsize=14)
ax2.set_ylabel("|Correlation Function|", fontsize=14)
ax2.set_title("Correlation Decay (Theorem 5.1)", fontsize=16)
ax2.legend(fontsize=12)
ax2.set_yscale('log')
ax2.set_ylim(1e-4, 10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("mass_gap_coupling.png", dpi=150, bbox_inches='tight')
print("Saved: mass_gap_coupling.png")
