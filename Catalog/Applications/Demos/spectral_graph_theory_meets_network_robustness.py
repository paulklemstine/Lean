#!/usr/bin/env python3
"""
Demo: Spectral Graph Theory Meets Neural Network Robustness

Numerical examples demonstrating the core theorems:
1. Contraction factor computation for various graph topologies
2. Iterated smoothing and exponential Lipschitz decay
3. Certified robustness radius improvement via spectral gap
4. Connectivity-robustness monotonicity
"""

import math


def contraction_factor(alg_conn: float, max_deg: float) -> float:
    """Compute the spectral contraction factor c = 1 - lambda_2 / d_max."""
    assert max_deg > 0
    assert 0 <= alg_conn <= max_deg
    return 1.0 - alg_conn / max_deg


def certified_radius(margin: float, lipschitz: float) -> float:
    """Compute certified robustness radius = margin / L."""
    if lipschitz <= 0:
        return float('inf') if margin > 0 else 0.0
    return margin / lipschitz


def iterated_smooth_lip(c: float, L: float, k: int) -> float:
    """Lipschitz constant after k smoothing iterations: c^k * L."""
    return (c ** k) * L


def network_lipschitz(layer_constants: list[float]) -> float:
    """Product of layer Lipschitz constants."""
    result = 1.0
    for lc in layer_constants:
        result *= lc
    return result


# ==============================================================
# Example 1: Contraction factors for common graph topologies
# ==============================================================
print("=" * 60)
print("Example 1: Contraction Factors for Graph Topologies")
print("=" * 60)

# Path graph P_n: lambda_2 = 2(1 - cos(pi/n)), d_max = 2
for n in [5, 10, 20, 50, 100]:
    lam2 = 2 * (1 - math.cos(math.pi / n))
    d_max = 2.0
    c = contraction_factor(min(lam2, d_max), d_max)
    print(f"  Path P_{n:3d}: lambda_2 = {lam2:.6f}, d_max = {d_max}, c = {c:.6f}")

print()

# Cycle graph C_n: lambda_2 = 2(1 - cos(2*pi/n)), d_max = 2
for n in [5, 10, 20, 50, 100]:
    lam2 = 2 * (1 - math.cos(2 * math.pi / n))
    d_max = 2.0
    c = contraction_factor(min(lam2, d_max), d_max)
    print(f"  Cycle C_{n:3d}: lambda_2 = {lam2:.6f}, d_max = {d_max}, c = {c:.6f}")

print()

# Complete graph K_n: lambda_2 = n, d_max = n-1
# Using our normalization: algConn = maxDeg = n for complete averaging
for n in [3, 5, 10, 20, 50]:
    c = contraction_factor(n, n)  # c = 0 for complete graph
    print(f"  Complete K_{n:2d}: lambda_2 = maxDeg = {n}, c = {c:.6f}")

# ==============================================================
# Example 2: Iterated Smoothing — Exponential Decay
# ==============================================================
print("\n" + "=" * 60)
print("Example 2: Iterated Smoothing — Exponential Lipschitz Decay")
print("=" * 60)

L_base = 100.0  # Base Lipschitz constant
margin = 1.0    # Classification margin

for c_label, c_val in [("Path (c=0.95)", 0.95), ("Cycle (c=0.80)", 0.80),
                         ("Dense (c=0.50)", 0.50), ("Very dense (c=0.10)", 0.10)]:
    print(f"\n  {c_label}:")
    for k in [0, 1, 2, 5, 10, 20]:
        lip_k = iterated_smooth_lip(c_val, L_base, k)
        rad_k = certified_radius(margin, lip_k)
        print(f"    k={k:2d}: L_eff = {lip_k:10.4f}, radius = {rad_k:10.6f}")

# ==============================================================
# Example 3: Robustness Improvement Factor
# ==============================================================
print("\n" + "=" * 60)
print("Example 3: Robustness Improvement Factor (1/c^k)")
print("=" * 60)

for c_val in [0.95, 0.80, 0.50, 0.10]:
    print(f"\n  c = {c_val}:")
    for k in [1, 5, 10, 20, 50]:
        improvement = 1.0 / (c_val ** k)
        print(f"    k={k:2d}: improvement = {improvement:12.2f}x")

# ==============================================================
# Example 4: Neural Network with Graph Smoothing
# ==============================================================
print("\n" + "=" * 60)
print("Example 4: 5-Layer Neural Network with Graph Smoothing")
print("=" * 60)

layers = [2.5, 1.8, 3.0, 1.2, 2.0]
L_net = network_lipschitz(layers)
margin = 0.5

print(f"  Layer Lipschitz constants: {layers}")
print(f"  Network Lipschitz constant L = {L_net:.2f}")
print(f"  Classification margin m = {margin}")
print(f"  Base certified radius = {certified_radius(margin, L_net):.6f}")

for graph_name, alg_conn, max_deg in [
    ("Sparse (path-like)", 0.2, 4.0),
    ("Moderate", 1.0, 4.0),
    ("Dense", 3.0, 4.0),
    ("Near-complete", 3.9, 4.0),
]:
    c = contraction_factor(alg_conn, max_deg)
    print(f"\n  Graph: {graph_name} (lambda_2={alg_conn}, d_max={max_deg}, c={c:.4f})")
    for k in [1, 3, 5, 10]:
        lip_smooth = iterated_smooth_lip(c, L_net, k)
        rad_smooth = certified_radius(margin, lip_smooth)
        print(f"    k={k:2d}: L_eff={lip_smooth:8.2f}, radius={rad_smooth:.6f}")

# ==============================================================
# Example 5: Robustness-Connectivity Duality
# ==============================================================
print("\n" + "=" * 60)
print("Example 5: Robustness-Connectivity Duality")
print("=" * 60)
print("  Graphs with same lambda_2/d_max ratio have same contraction factor:")

dualities = [
    (1.0, 2.0, "Sparse: lambda_2=1, d_max=2"),
    (2.0, 4.0, "Medium: lambda_2=2, d_max=4"),
    (5.0, 10.0, "Dense: lambda_2=5, d_max=10"),
    (50.0, 100.0, "Very dense: lambda_2=50, d_max=100"),
]
for alg_conn, max_deg, label in dualities:
    c = contraction_factor(alg_conn, max_deg)
    print(f"  {label}: ratio={alg_conn/max_deg:.2f}, c={c:.4f}")

print("\n" + "=" * 60)
print("All examples completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Spectral Robustness — Contraction Factor vs Iterations

Shows how the certified robustness radius grows exponentially with
smoothing iterations for different graph connectivity levels.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import json


def contraction_factor(alg_conn: float, max_deg: float) -> float:
    return 1.0 - alg_conn / max_deg


def certified_radius(margin: float, lipschitz: float) -> float:
    if lipschitz <= 0:
        return float('inf') if margin > 0 else 0.0
    return margin / lipschitz


def iterated_smooth_lip(c: float, L: float, k: int) -> float:
    return (c ** k) * L


# Parameters
L_base = 50.0
margin = 1.0
k_values = np.arange(0, 31)

# Different graph topologies
graphs = [
    ("Path-like (c=0.95)", 0.95, '#e74c3c'),
    ("Sparse (c=0.80)", 0.80, '#e67e22'),
    ("Moderate (c=0.60)", 0.60, '#2ecc71'),
    ("Dense (c=0.30)", 0.30, '#3498db'),
    ("Very dense (c=0.10)", 0.10, '#9b59b6'),
]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Lipschitz constant decay
ax1 = axes[0]
for label, c, color in graphs:
    lip_values = [iterated_smooth_lip(c, L_base, k) for k in k_values]
    ax1.semilogy(k_values, lip_values, '-o', color=color, label=label,
                 markersize=3, linewidth=2)

ax1.set_xlabel('Smoothing Iterations (k)', fontsize=12)
ax1.set_ylabel('Effective Lipschitz Constant', fontsize=12)
ax1.set_title('Exponential Lipschitz Decay via Graph Smoothing', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=1e-6)

# Plot 2: Certified radius growth
ax2 = axes[1]
for label, c, color in graphs:
    radii = [certified_radius(margin, iterated_smooth_lip(c, L_base, k))
             for k in k_values]
    ax2.semilogy(k_values, radii, '-s', color=color, label=label,
                 markersize=3, linewidth=2)

ax2.set_xlabel('Smoothing Iterations (k)', fontsize=12)
ax2.set_ylabel('Certified Robustness Radius', fontsize=12)
ax2.set_title('Robustness Radius Growth with Spectral Smoothing', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_robustness_plot.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: spectral_robustness_plot.png")
