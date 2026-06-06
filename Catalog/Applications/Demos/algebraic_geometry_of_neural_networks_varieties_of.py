#!/usr/bin/env python3
"""
Tropical Activation Complex: Numerical Demonstrations

Demonstrates the key theorems about ReLU network decision boundary complexity.
"""

from math import comb, prod, log2, floor
from typing import List, Tuple
from itertools import product as iter_product


def zaslavsky_bound(n: int, d: int) -> int:
    """Maximum regions from n hyperplanes in R^d."""
    return sum(comb(n, k) for k in range(d + 1))


def network_region_bound(input_dim: int, widths: List[int]) -> int:
    """Product of per-layer Zaslavsky bounds."""
    return prod(zaslavsky_bound(w, input_dim) for w in widths)


def tropical_degree(widths: List[int]) -> int:
    """Product of layer widths."""
    return prod(widths) if widths else 1


def fold_number(widths: List[int]) -> int:
    """Sum of layer widths."""
    return sum(widths)


def singularity_budget(widths: List[int]) -> int:
    """Sum of C(w_i, 2)."""
    return sum(comb(w, 2) for w in widths)


def compute_tac(input_dim: int, widths: List[int]) -> dict:
    """Compute all TAC invariants."""
    return {
        "input_dim": input_dim,
        "widths": widths,
        "depth": len(widths),
        "total_width": fold_number(widths),
        "tropical_degree": tropical_degree(widths),
        "fold_number": fold_number(widths),
        "singularity_budget": singularity_budget(widths),
        "region_bound": network_region_bound(input_dim, widths),
        "activation_patterns": 2 ** fold_number(widths),
    }


def verify_fundamental_theorem(tac: dict) -> dict:
    """Verify the fundamental TAC inequality chain."""
    td = tac["tropical_degree"]
    rb = tac["region_bound"]
    fn = tac["fold_number"]
    sb = tac["singularity_budget"]

    return {
        "degree_le_region": td <= rb,
        "region_le_exp_fold": rb <= 2 ** fn,
        "singularity_le_fold_sq": sb <= fn ** 2,
    }


def find_optimal_architecture(total_width: int, max_depth: int, input_dim: int) -> Tuple[List[int], int]:
    """Find architecture maximizing region bound for given total width."""
    best_arch = [total_width]
    best_bound = network_region_bound(input_dim, best_arch)

    for depth in range(1, max_depth + 1):
        base = total_width // depth
        remainder = total_width % depth
        widths = [base + (1 if i < remainder else 0) for i in range(depth)]
        bound = network_region_bound(input_dim, widths)
        if bound > best_bound:
            best_bound = bound
            best_arch = widths

    return best_arch, best_bound


# ============================================================
# DEMONSTRATIONS
# ============================================================

print("=" * 70)
print("TROPICAL ACTIVATION COMPLEX: NUMERICAL DEMONSTRATIONS")
print("=" * 70)

# Demo 1: Fundamental Theorem Verification
print("\n--- Demo 1: Fundamental Theorem Verification ---\n")
architectures = [
    (2, [4]),
    (2, [3, 3]),
    (2, [2, 2, 2]),
    (2, [6]),
    (3, [5, 5]),
    (10, [20, 20, 20]),
    (100, [50, 50, 50, 50]),
]

for dim, widths in architectures:
    tac = compute_tac(dim, widths)
    checks = verify_fundamental_theorem(tac)
    status = "✓" if all(checks.values()) else "✗"
    print(f"  {status} Arch ({dim}; {widths}): "
          f"deg={tac['tropical_degree']}, "
          f"regions={tac['region_bound']}, "
          f"2^fold={tac['activation_patterns']}, "
          f"sing={tac['singularity_budget']}, "
          f"fold²={tac['fold_number']**2}")

# Demo 2: Depth Advantage
print("\n--- Demo 2: Depth Advantage (W=12, n=3) ---\n")
total_w = 12
n = 3
print(f"  Total width W={total_w}, input dim n={n}\n")
print(f"  {'Architecture':<25} {'Depth':>5} {'Regions':>10} {'Trop.Deg':>10} {'Ratio':>8}")
print(f"  {'-'*25} {'-'*5} {'-'*10} {'-'*10} {'-'*8}")

for depth in [1, 2, 3, 4, 6, 12]:
    base = total_w // depth
    rem = total_w % depth
    widths = [base + (1 if i < rem else 0) for i in range(depth)]
    tac = compute_tac(n, widths)
    ratio = tac["region_bound"] / max(tac["tropical_degree"], 1)
    print(f"  {str(widths):<25} {depth:>5} {tac['region_bound']:>10} "
          f"{tac['tropical_degree']:>10} {ratio:>8.1f}")

# Demo 3: Optimal Architecture Search
print("\n--- Demo 3: Optimal Architecture Search ---\n")
for W in [6, 10, 20]:
    for n in [2, 5]:
        best_arch, best_bound = find_optimal_architecture(W, W, n)
        print(f"  W={W}, n={n}: optimal arch = {best_arch}, "
              f"regions = {best_bound}")

# Demo 4: AM-GM Trade-Off
print("\n--- Demo 4: AM-GM Trade-Off (W=12) ---\n")
W = 12
for L in range(1, 13):
    avg = W // L
    td = (avg + 1) ** L
    actual_widths = [W // L + (1 if i < W % L else 0) for i in range(L)]
    actual_td = tropical_degree(actual_widths)
    print(f"  L={L:>2}: prod(w_i)={actual_td:>10}, "
          f"(W/L+1)^L={td:>10}, "
          f"bound holds: {actual_td <= td}")

# Demo 5: Zaslavsky Bound Table
print("\n--- Demo 5: Zaslavsky Bound Z(n, d) ---\n")
header = 'n\\d'
print(f"  {header:>4}", end="")
for d in range(8):
    print(f"  {d:>6}", end="")
print()
for n_val in range(10):
    print(f"  {n_val:>4}", end="")
    for d in range(8):
        print(f"  {zaslavsky_bound(n_val, d):>6}", end="")
    print(f"  (2^n={2**n_val})")

# Demo 6: ReLU Properties
print("\n--- Demo 6: ReLU Properties ---\n")


def relu(x: float) -> float:
    return max(0.0, x)


test_values = [-3.0, -1.5, -0.5, 0.0, 0.5, 1.5, 3.0]
print("  x     relu(x)   (x+|x|)/2   idempotent")
for x in test_values:
    r = relu(x)
    formula = (x + abs(x)) / 2
    idemp = relu(relu(x))
    print(f"  {x:>5.1f}  {r:>7.3f}   {formula:>9.3f}   {idemp:>7.3f} == {r:.3f}: {abs(idemp - r) < 1e-10}")

print("\n  Lipschitz check: |relu(x) - relu(y)| <= |x - y|")
import random
random.seed(42)
for _ in range(5):
    x, y = random.uniform(-5, 5), random.uniform(-5, 5)
    lip = abs(relu(x) - relu(y)) <= abs(x - y) + 1e-15
    print(f"  x={x:.3f}, y={y:.3f}: "
          f"|relu(x)-relu(y)|={abs(relu(x)-relu(y)):.4f}, "
          f"|x-y|={abs(x-y):.4f}, holds={lip}")

print("\n" + "=" * 70)
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Depth Advantage in ReLU Networks

Shows how the number of linear regions depends on depth for fixed total width,
demonstrating the exponential depth advantage from the Tropical Activation Complex theory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, prod


def zaslavsky_bound(n: int, d: int) -> int:
    return sum(comb(n, k) for k in range(d + 1))


def network_region_bound(input_dim: int, widths: list) -> int:
    return prod(zaslavsky_bound(w, input_dim) for w in widths) if widths else 1


def balanced_widths(total_width: int, depth: int) -> list:
    base = total_width // depth
    rem = total_width % depth
    return [base + (1 if i < rem else 0) for i in range(depth)]


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Region bound vs depth for various total widths
ax1 = axes[0]
input_dim = 3
for W in [6, 10, 16, 24]:
    depths = list(range(1, W + 1))
    regions = []
    for d in depths:
        ws = balanced_widths(W, d)
        regions.append(network_region_bound(input_dim, ws))
    ax1.semilogy(depths, regions, 'o-', label=f'W={W}', markersize=3)

ax1.set_xlabel('Depth L')
ax1.set_ylabel('Region Bound (log scale)')
ax1.set_title(f'Region Bound vs Depth (n={input_dim})')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Fundamental theorem inequality chain
ax2 = axes[1]
W = 12
input_dim = 2
depths = list(range(1, W + 1))
trop_degrees = []
region_bounds = []
exp_folds = []

for d in depths:
    ws = balanced_widths(W, d)
    trop_degrees.append(prod(ws) if ws else 1)
    region_bounds.append(network_region_bound(input_dim, ws))
    exp_folds.append(2 ** sum(ws))

ax2.semilogy(depths, trop_degrees, 's-', label='Tropical degree ∏wᵢ', color='blue', markersize=5)
ax2.semilogy(depths, region_bounds, 'o-', label='Region bound ∏Z(wᵢ,n)', color='red', markersize=5)
ax2.semilogy(depths, exp_folds, '^-', label='2^(fold number)', color='green', markersize=5)
ax2.set_xlabel('Depth L')
ax2.set_ylabel('Value (log scale)')
ax2.set_title(f'Fundamental TAC Inequality (W={W}, n={input_dim})')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Plot 3: Zaslavsky bound heatmap
ax3 = axes[2]
max_n = 15
max_d = 8
Z = np.zeros((max_n, max_d))
for n in range(max_n):
    for d in range(max_d):
        Z[n, d] = zaslavsky_bound(n, d)

im = ax3.imshow(np.log2(Z + 1), aspect='auto', origin='lower',
                extent=[-0.5, max_d - 0.5, -0.5, max_n - 0.5],
                cmap='viridis')
ax3.set_xlabel('Dimension d')
ax3.set_ylabel('Hyperplanes n')
ax3.set_title('log₂(Z(n,d) + 1)')
plt.colorbar(im, ax=ax3, label='log₂(regions + 1)')

plt.tight_layout()
plt.savefig('depth_advantage.png', dpi=150, bbox_inches='tight')
print("Saved depth_advantage.png")


#!/usr/bin/env python3
"""
Visualization: Tropical Activation Complex Structure

Shows the relationship between the four TAC invariants across different architectures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, prod


def zaslavsky_bound(n: int, d: int) -> int:
    return sum(comb(n, k) for k in range(d + 1))


def compute_tac_invariants(input_dim: int, widths: list) -> dict:
    ws = widths
    return {
        "tropical_degree": prod(ws) if ws else 1,
        "fold_number": sum(ws),
        "singularity_budget": sum(comb(w, 2) for w in ws),
        "region_bound": prod(zaslavsky_bound(w, input_dim) for w in ws) if ws else 1,
    }


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Generate many architectures with total width 12, input dim 3
W = 12
n = 3
architectures = []
for L in range(1, W + 1):
    base = W // L
    rem = W % L
    widths = [base + (1 if i < rem else 0) for i in range(L)]
    tac = compute_tac_invariants(n, widths)
    tac["depth"] = L
    tac["widths"] = widths
    architectures.append(tac)

depths = [a["depth"] for a in architectures]
tds = [a["tropical_degree"] for a in architectures]
fns = [a["fold_number"] for a in architectures]
sbs = [a["singularity_budget"] for a in architectures]
rbs = [a["region_bound"] for a in architectures]

# Plot 1: All four invariants vs depth
ax = axes[0, 0]
ax.plot(depths, tds, 'bo-', label='Tropical degree', markersize=5)
ax.plot(depths, sbs, 'gs-', label='Singularity budget', markersize=5)
ax.set_xlabel('Depth L')
ax.set_ylabel('Value')
ax.set_title(f'TAC Invariants vs Depth (W={W}, n={n})')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: Region bound and exponential bound
ax = axes[0, 1]
ax.semilogy(depths, rbs, 'ro-', label='Region bound', markersize=5)
ax.axhline(y=2**W, color='green', linestyle='--', label=f'2^W = {2**W}')
ax.set_xlabel('Depth L')
ax.set_ylabel('Value (log scale)')
ax.set_title(f'Region Bound vs 2^W (W={W}, n={n})')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: Tropical degree vs region bound (scatter)
ax = axes[1, 0]
colors = plt.cm.viridis(np.linspace(0, 1, len(architectures)))
for i, a in enumerate(architectures):
    ax.scatter(a["tropical_degree"], a["region_bound"], c=[colors[i]],
               s=50, zorder=3, label=f'L={a["depth"]}' if a["depth"] <= 4 else '')
# Diagonal line y = x
max_val = max(max(tds), max(rbs))
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='degree = regions')
ax.set_xlabel('Tropical Degree')
ax.set_ylabel('Region Bound')
ax.set_title('Tropical Degree vs Region Bound')
ax.legend(fontsize=7)
ax.grid(True, alpha=0.3)

# Plot 4: Singularity budget vs fold_number^2
ax = axes[1, 1]
fn_sq = [f**2 for f in fns]
ax.bar(range(len(depths)), sbs, alpha=0.7, label='Singularity budget', color='blue')
ax.bar(range(len(depths)), fn_sq, alpha=0.3, label='Fold number²', color='red')
ax.set_xlabel('Architecture index (depth 1 to 12)')
ax.set_ylabel('Value')
ax.set_title('Singularity Budget ≤ Fold Number²')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tac_structure.png', dpi=150, bbox_inches='tight')
print("Saved tac_structure.png")
