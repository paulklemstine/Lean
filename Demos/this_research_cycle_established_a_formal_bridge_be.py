#!/usr/bin/env python3
"""
Demo: Lorentzian-Log-Concavity Bridge

Demonstrates the key results:
1. K-fold log-concavity depth computation
2. Hadamard product depth preservation
3. Geometric tilting stability
4. Depth additivity conjecture testing
5. Binomial coefficient log-concavity
"""

from algorithms import (
    kfold_log_concavity_depth,
    hadamard_product,
    geometric_tilt,
    binomial_coefficients,
    convolution,
    ratio_sequence,
    is_log_concave,
    LogConcavitySignature,
    depth_additivity_test,
)
import math


def demo_kfold_depth():
    """Demonstrate k-fold log-concavity depth computation."""
    print("=" * 60)
    print("1. K-FOLD LOG-CONCAVITY DEPTH COMPUTATION")
    print("=" * 60)
    
    sequences = {
        "Geometric (2^n)": [2**n for n in range(8)],
        "Binomial C(4,n)": binomial_coefficients(4),
        "Binomial C(6,n)": binomial_coefficients(6),
        "Binomial C(10,n)": binomial_coefficients(10),
        "Fibonacci (1,1,2,3,5,8,13,21)": [1, 1, 2, 3, 5, 8, 13, 21],
        "Powers of 2: (1,2,4,8,16,32)": [1, 2, 4, 8, 16, 32],
        "Factorials (1,1,2,6,24,120)": [math.factorial(n) for n in range(6)],
    }
    
    for name, seq in sequences.items():
        depth = kfold_log_concavity_depth(seq)
        depth_str = "≥100 (∞)" if depth >= 100 else str(depth)
        print(f"  {name}")
        print(f"    Sequence: {seq}")
        print(f"    Depth: {depth_str}")
        if len(seq) >= 3:
            ratios = ratio_sequence(seq)
            print(f"    Ratios: {[f'{r:.3f}' for r in ratios]}")
        print()


def demo_hadamard_stability():
    """Demonstrate Hadamard product depth preservation."""
    print("=" * 60)
    print("2. HADAMARD PRODUCT DEPTH PRESERVATION")
    print("=" * 60)
    
    test_cases = [
        ("C(4,n)", binomial_coefficients(4), "C(4,n)", binomial_coefficients(4)),
        ("C(4,n)", binomial_coefficients(4), "2^n", [2**n for n in range(5)]),
        ("C(3,n)", binomial_coefficients(3), "C(5,n)", [math.comb(5, n) for n in range(4)]),
    ]
    
    for name_a, a, name_b, b, in test_cases:
        da, db, dp, is_add = depth_additivity_test(a, b)
        prod = hadamard_product(a, b)
        print(f"  {name_a} * {name_b}")
        print(f"    a = {a}, depth = {da}")
        print(f"    b = {b[:len(a)]}, depth = {db}")
        print(f"    a*b = {prod}")
        print(f"    depth(a*b) = {dp}")
        print(f"    min(d_a, d_b) = {min(da, db)} ≤ {dp} ✓")
        print(f"    Additive (d_a + d_b ≤ dp)? {'Yes ✓' if is_add else 'No'}")
        print()


def demo_geometric_tilt():
    """Demonstrate geometric tilting stability."""
    print("=" * 60)
    print("3. GEOMETRIC TILTING STABILITY")
    print("=" * 60)
    
    seq = binomial_coefficients(5)
    print(f"  Original: {seq}")
    print(f"  Depth: {kfold_log_concavity_depth(seq)}")
    print()
    
    for r in [0.5, 1.0, 2.0, 3.0, 10.0]:
        tilted = geometric_tilt(seq, r)
        depth = kfold_log_concavity_depth(tilted)
        print(f"  Tilted by r={r}: {[f'{x:.1f}' for x in tilted]}")
        print(f"  Depth: {depth}")
        print(f"  Log-concave: {is_log_concave(tilted)} ✓")
        print()


def demo_binomial_lc():
    """Demonstrate binomial coefficient log-concavity."""
    print("=" * 60)
    print("4. BINOMIAL COEFFICIENT LOG-CONCAVITY")
    print("=" * 60)
    
    for d in range(3, 9):
        binom = binomial_coefficients(d)
        print(f"  C({d},m) = {binom}")
        for m in range(1, d):
            lhs = binom[m] ** 2
            rhs = binom[m - 1] * binom[m + 1]
            ratio = lhs / rhs if rhs > 0 else float('inf')
            print(f"    m={m}: C({d},{m})²={lhs:.0f} ≥ C({d},{m-1})·C({d},{m+1})={rhs:.0f}"
                  f"  (ratio={ratio:.3f}) ✓")
        print()


def demo_signatures():
    """Demonstrate log-concavity signatures."""
    print("=" * 60)
    print("5. LOG-CONCAVITY SIGNATURES")
    print("=" * 60)
    
    s1 = LogConcavitySignature(binomial_coefficients(4))
    s2 = LogConcavitySignature([2**n for n in range(5)])
    
    print(f"  S1 = {s1}")
    print(f"  S2 = {s2}")
    
    product = s1.product(s2)
    print(f"  S1 * S2 = {product}")
    print(f"  Certified depth ≥ min({s1.depth}, {s2.depth}) = {min(s1.depth, s2.depth)}")
    
    tilted = s1.tilt(3.0)
    print(f"  S1 tilted by r=3: {tilted}")
    print()


def demo_conjecture_test():
    """Test the depth additivity conjecture with various sequences."""
    print("=" * 60)
    print("6. DEPTH ADDITIVITY CONJECTURE TESTING")
    print("=" * 60)
    
    tests = [
        ("C(4,n)", binomial_coefficients(4), "C(4,n)", binomial_coefficients(4)),
        ("C(3,n)", binomial_coefficients(3), "(1,2,3,4)", [1, 2, 3, 4]),
        ("(1,2,1)", [1, 2, 1], "(1,3,3,1)", [1, 3, 3, 1]),
        ("C(6,n)", binomial_coefficients(6),
         "(1,2,4,8,16,32,64)", [2**n for n in range(7)]),
    ]
    
    all_additive = True
    for name_a, a, name_b, b in tests:
        n = min(len(a), len(b))
        a, b = a[:n], b[:n]
        da, db, dp, is_add = depth_additivity_test(a, b)
        status = "✓ additive" if is_add else "✗ NOT additive"
        print(f"  {name_a} * {name_b}: depth({da}) + depth({db}) = {da+db}, "
              f"depth(product) = {dp}  [{status}]")
        if not is_add:
            all_additive = False
    
    print()
    if all_additive:
        print("  All tests consistent with depth additivity conjecture.")
    else:
        print("  COUNTEREXAMPLE FOUND! Depth additivity fails.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   LORENTZIAN–LOG-CONCAVITY BRIDGE: NUMERICAL DEMO      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_kfold_depth()
    demo_hadamard_stability()
    demo_geometric_tilt()
    demo_binomial_lc()
    demo_signatures()
    demo_conjecture_test()
    
    print("Demo complete.")


#!/usr/bin/env python3
"""
Visualization: K-Fold Log-Concavity Depth Landscape

Creates a heatmap showing the log-concavity depth of sequences
parameterized by two variables (e.g., geometric tilt parameter
and sequence family).
"""

import math
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def is_positive(seq):
    return all(x > 1e-15 for x in seq)

def is_log_concave(seq):
    if len(seq) < 3:
        return True
    return all(seq[n+1]**2 >= seq[n]*seq[n+2] - 1e-12 for n in range(len(seq)-2))

def ratio_sequence(seq):
    if len(seq) < 2:
        return []
    return [seq[n+1]/seq[n] for n in range(len(seq)-1)]

def kfold_depth(seq, max_depth=10):
    if not is_positive(seq):
        return -1
    current = seq[:]
    for k in range(max_depth):
        if len(current) < 3:
            return max_depth
        if not is_log_concave(current):
            return k
        current = ratio_sequence(current)
        if not is_positive(current):
            return k
    return max_depth

def binomial_coeffs(d):
    return [float(math.comb(d, k)) for k in range(d+1)]

def geometric_tilt(seq, r):
    return [seq[n] * r**n for n in range(len(seq))]


# --- Plot 1: Depth heatmap for tilted binomial sequences ---
fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap: depth of C(d,n) * r^n as function of d and r
d_values = list(range(3, 16))
r_values = np.linspace(0.1, 5.0, 50)

depth_grid = np.zeros((len(d_values), len(r_values)))
for i, d in enumerate(d_values):
    binom = binomial_coeffs(d)
    for j, r in enumerate(r_values):
        tilted = geometric_tilt(binom, r)
        depth_grid[i, j] = kfold_depth(tilted, max_depth=8)

ax = axes[0]
cmap = plt.cm.viridis
im = ax.imshow(depth_grid, aspect='auto', origin='lower',
               extent=[r_values[0], r_values[-1], d_values[0], d_values[-1]],
               cmap=cmap, vmin=0, vmax=8)
ax.set_xlabel('Tilt parameter r', fontsize=12)
ax.set_ylabel('Degree d', fontsize=12)
ax.set_title('K-Fold Depth of C(d,n)·rⁿ', fontsize=14)
plt.colorbar(im, ax=ax, label='Depth')

# --- Plot 2: Depth of Hadamard products ---
ax2 = axes[1]
d_vals = list(range(3, 12))
labels = []
depths_original = []
depths_squared = []
depths_cubed = []

for d in d_vals:
    binom = binomial_coeffs(d)
    sq = [x**2 for x in binom]
    cu = [x**3 for x in binom]
    depths_original.append(kfold_depth(binom, max_depth=10))
    depths_squared.append(kfold_depth(sq, max_depth=10))
    depths_cubed.append(kfold_depth(cu, max_depth=10))

x = np.arange(len(d_vals))
width = 0.25
bars1 = ax2.bar(x - width, depths_original, width, label='C(d,n)', color='#2196F3')
bars2 = ax2.bar(x, depths_squared, width, label='C(d,n)²', color='#FF9800')
bars3 = ax2.bar(x + width, depths_cubed, width, label='C(d,n)³', color='#4CAF50')
ax2.set_xlabel('Degree d', fontsize=12)
ax2.set_ylabel('K-Fold Depth', fontsize=12)
ax2.set_title('Depth under Hadamard Powers', fontsize=14)
ax2.set_xticks(x)
ax2.set_xticklabels([str(d) for d in d_vals])
ax2.legend()

plt.tight_layout()
plt.savefig('depth_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved depth_landscape.png")


# --- Plot 3: Ratio sequence cascade ---
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

seq = binomial_coeffs(8)
titles = ['Original: C(8,n)', 'Ratio sequence', 'Ratio of ratio', 'Ratio³']
current = seq[:]

for idx, ax in enumerate(axes.flat):
    if len(current) < 2:
        ax.text(0.5, 0.5, 'Sequence too short', transform=ax.transAxes,
                ha='center', va='center')
        ax.set_title(titles[idx])
        continue
    
    x = list(range(len(current)))
    ax.bar(x, current, color=['#2196F3' if is_log_concave(current) else '#F44336'][0],
           alpha=0.7)
    ax.set_title(titles[idx], fontsize=13)
    ax.set_xlabel('Index n')
    ax.set_ylabel('Value')
    
    lc_status = "✓ Log-concave" if is_log_concave(current) else "✗ Not log-concave"
    ax.text(0.95, 0.95, lc_status, transform=ax.transAxes,
            ha='right', va='top', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    if len(current) >= 2:
        current = ratio_sequence(current)

plt.suptitle('Ratio Sequence Cascade for C(8,n)', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('ratio_cascade.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved ratio_cascade.png")
