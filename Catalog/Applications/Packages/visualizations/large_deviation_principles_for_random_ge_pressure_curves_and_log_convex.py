#!/usr/bin/env python3
"""
Visualization 1: Pressure Curves and Log-Convexity

Visualizes the subgroup pressure Z_G(t) and log-pressure log Z_G(t)
for several cyclic groups, demonstrating:
- Antitonicity (Theorem: subgroupPressure_antitone)
- Log-convexity (Theorem: subgroupPressure_geometric_convex)
- Dependence on group structure

The curves show how increasing inverse temperature t suppresses
high-energy obstruction channels, a direct analogy to statistical mechanics.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

# ============================================================
# Inline: subgroup pressure computation
# ============================================================

def cyclic_indices(n):
    """Proper subgroup indices for Z/nZ."""
    return [n // d for d in range(1, n) if n % d == 0]

def subgroup_pressure(indices, t):
    """Z_G(t) = sum [G:H]^{-2t}."""
    return sum(idx ** (-2 * t) for idx in indices if idx > 0)

def log_pressure(indices, t):
    """log Z_G(t)."""
    Z = subgroup_pressure(indices, t)
    return math.log(Z) if Z > 0 else float('-inf')

# ============================================================
# Plotting
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

t_range = np.linspace(0.01, 3.0, 200)

groups = [
    ("Z/6Z", 6, "#e74c3c"),
    ("Z/12Z", 12, "#3498db"),
    ("Z/24Z", 24, "#2ecc71"),
    ("Z/30Z", 30, "#9b59b6"),
]

# Panel 1: Pressure curves Z(t)
ax = axes[0, 0]
for name, n, color in groups:
    indices = cyclic_indices(n)
    pressures = [subgroup_pressure(indices, t) for t in t_range]
    ax.plot(t_range, pressures, label=name, color=color, linewidth=2)
ax.set_xlabel("Inverse temperature t", fontsize=12)
ax.set_ylabel("Pressure Z(t)", fontsize=12)
ax.set_title("Subgroup Pressure (Partition Function)", fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Log-pressure curves
ax = axes[0, 1]
for name, n, color in groups:
    indices = cyclic_indices(n)
    log_pressures = [log_pressure(indices, t) for t in t_range]
    ax.plot(t_range, log_pressures, label=name, color=color, linewidth=2)
ax.set_xlabel("Inverse temperature t", fontsize=12)
ax.set_ylabel("Log-pressure log Z(t)", fontsize=12)
ax.set_title("Free Energy (Log-Pressure)", fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 3: Log-convexity verification for Z/12Z
ax = axes[1, 0]
indices = cyclic_indices(12)
t1, t2 = 0.3, 2.5
thetas = np.linspace(0, 1, 50)
lhs_vals = []
rhs_vals = []
for theta in thetas:
    t_mix = theta * t1 + (1 - theta) * t2
    lhs = subgroup_pressure(indices, t_mix)
    rhs = subgroup_pressure(indices, t1) ** theta * subgroup_pressure(indices, t2) ** (1 - theta)
    lhs_vals.append(lhs)
    rhs_vals.append(rhs)

ax.plot(thetas, lhs_vals, 'b-', linewidth=2, label='Z(θt₁ + (1-θ)t₂)')
ax.plot(thetas, rhs_vals, 'r--', linewidth=2, label='Z(t₁)^θ · Z(t₂)^{1-θ}')
ax.fill_between(thetas, lhs_vals, rhs_vals, alpha=0.2, color='green',
                label='Gap (log-convexity)')
ax.set_xlabel("θ", fontsize=12)
ax.set_ylabel("Pressure value", fontsize=12)
ax.set_title("Log-Convexity Verification (Z/12Z)", fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 4: Antitonicity verification
ax = axes[1, 1]
for name, n, color in groups:
    indices = cyclic_indices(n)
    pressures = [subgroup_pressure(indices, t) for t in t_range]
    # Compute finite differences
    diffs = np.diff(pressures) / np.diff(t_range)
    ax.plot(t_range[:-1], diffs, label=name, color=color, linewidth=1.5)
ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax.set_xlabel("Inverse temperature t", fontsize=12)
ax.set_ylabel("dZ/dt (should be ≤ 0)", fontsize=12)
ax.set_title("Antitonicity: Pressure Derivative", fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.suptitle("Subgroup Pressure Thermodynamics: Verified Properties",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("pressure_curves.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: pressure_curves.png")
