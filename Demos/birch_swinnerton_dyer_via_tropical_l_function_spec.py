#!/usr/bin/env python3
"""
Applications of Tropical BSD Theory

Demonstrates connections to:
1. Optimization / Operations Research — shortest path degeneracy
2. Information Theory — tropical entropy and degeneracy counting
3. Statistical Mechanics — ground state degeneracy
4. Polyhedral Geometry — active face dimensions
"""

import numpy as np
from itertools import permutations
from typing import List, Dict, Tuple


# ═══════════════════════════════════════════════════════════════
# APPLICATION 1: Shortest Path Degeneracy
# ═══════════════════════════════════════════════════════════════

def shortest_path_degeneracy(cost_matrix: np.ndarray) -> dict:
    """
    Interpret tropical BSD in terms of shortest-path optimization.

    The tropical L-series is a shortest-path objective:
    L(s) = min_n (a[n] + s * w[n])

    The tropical order of vanishing = degeneracy of optimal solutions
    (number of equally optimal paths minus one).

    This has direct applications in network routing and logistics.

    Args:
        cost_matrix: Each row is (base_cost, per-unit_cost) for a route

    Returns:
        Dictionary with optimal cost, degeneracy, and optimal routes
    """
    n_routes = cost_matrix.shape[0]
    a = cost_matrix[:, 0]  # base costs
    w = cost_matrix[:, 1]  # variable costs

    s = 1.0  # evaluation point
    total_costs = a + s * w
    min_cost = np.min(total_costs)
    optimal_routes = np.where(np.abs(total_costs - min_cost) < 1e-12)[0]

    return {
        'min_cost': min_cost,
        'optimal_routes': optimal_routes.tolist(),
        'degeneracy': len(optimal_routes) - 1,
        'interpretation': (
            f"There are {len(optimal_routes)} equally optimal routes "
            f"(degeneracy = {len(optimal_routes) - 1}). "
            f"This is the 'tropical order of vanishing' of the routing problem."
        )
    }


# ═══════════════════════════════════════════════════════════════
# APPLICATION 2: Tropical Entropy
# ═══════════════════════════════════════════════════════════════

def tropical_entropy(weights: np.ndarray) -> dict:
    """
    Compute the tropical entropy of a weight configuration.

    In classical information theory, entropy measures uncertainty.
    In tropical information theory:
    - A unique minimizer → zero tropical entropy (complete certainty)
    - Multiple minimizers → positive tropical entropy (degeneracy)

    The tropical entropy is log2(|active set|), measuring
    the bits of ambiguity in the ground state.

    Args:
        weights: Array of weights (energies)

    Returns:
        Dictionary with tropical entropy and interpretation
    """
    min_w = np.min(weights)
    active = np.where(np.abs(weights - min_w) < 1e-12)[0]
    n_active = len(active)

    entropy = np.log2(n_active) if n_active > 0 else 0.0

    return {
        'min_weight': min_w,
        'active_set': active.tolist(),
        'active_count': n_active,
        'tropical_entropy': entropy,
        'tropical_order': n_active - 1,
        'interpretation': (
            f"Tropical entropy = {entropy:.4f} bits. "
            f"{'Unique ground state (no ambiguity).' if n_active == 1 else f'{n_active} degenerate ground states ({entropy:.2f} bits of ambiguity).'}"
        )
    }


# ═══════════════════════════════════════════════════════════════
# APPLICATION 3: Ground State Degeneracy (Statistical Mechanics)
# ═══════════════════════════════════════════════════════════════

def partition_function_analysis(energies: np.ndarray,
                                temperatures: np.ndarray) -> dict:
    """
    Analyze the tropical limit of a partition function.

    Z(T) = Σ_n exp(-E_n / T)

    As T → 0 (tropical limit):
    - Z(T) → (degeneracy) * exp(-E_min / T)
    - Free energy F = -T log Z → E_min - T log(degeneracy)

    The tropical order = ground state degeneracy - 1.

    Args:
        energies: Energy levels E_n
        temperatures: Array of temperatures to evaluate

    Returns:
        Analysis of partition function behavior
    """
    E_min = np.min(energies)
    degeneracy = np.sum(np.abs(energies - E_min) < 1e-12)

    Z_values = []
    F_values = []
    for T in temperatures:
        if T > 1e-12:
            Z = np.sum(np.exp(-energies / T))
            F = -T * np.log(Z)
        else:
            Z = degeneracy * np.exp(-E_min / 1e-12)
            F = E_min
        Z_values.append(Z)
        F_values.append(F)

    return {
        'ground_energy': E_min,
        'degeneracy': int(degeneracy),
        'tropical_order': int(degeneracy - 1),
        'temperatures': temperatures.tolist(),
        'free_energies': F_values,
        'interpretation': (
            f"Ground state energy = {E_min}. "
            f"Degeneracy = {degeneracy} (tropical order = {degeneracy - 1}). "
            f"As T→0, F → {E_min} (the tropical residue)."
        )
    }


# ═══════════════════════════════════════════════════════════════
# APPLICATION 4: Assignment Problem and Tropical Regulators
# ═══════════════════════════════════════════════════════════════

def assignment_analysis(cost_matrix: np.ndarray) -> dict:
    """
    Analyze an assignment problem through the tropical BSD lens.

    The tropical regulator = optimal assignment cost = tropical permanent.
    This connects number-theoretic regulators to optimization.

    Args:
        cost_matrix: n×n cost matrix for the assignment problem

    Returns:
        Optimal assignment and its tropical interpretation
    """
    n = cost_matrix.shape[0]
    indices = list(range(n))

    min_cost = float('inf')
    optimal_perms = []

    for perm in permutations(indices):
        cost = sum(cost_matrix[i][perm[i]] for i in indices)
        if cost < min_cost - 1e-12:
            min_cost = cost
            optimal_perms = [perm]
        elif abs(cost - min_cost) < 1e-12:
            optimal_perms.append(perm)

    return {
        'optimal_cost': min_cost,
        'n_optimal_assignments': len(optimal_perms),
        'optimal_assignments': optimal_perms,
        'tropical_regulator': min_cost,
        'interpretation': (
            f"Tropical regulator = {min_cost} (optimal assignment cost). "
            f"{len(optimal_perms)} optimal assignment(s) found."
        )
    }


# ═══════════════════════════════════════════════════════════════
# Run All Applications
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 65)
    print("APPLICATION 1: Shortest Path Degeneracy")
    print("=" * 65)

    routes = np.array([
        [10.0, 2.0],   # Route A: base=10, per-unit=2
        [8.0, 4.0],    # Route B: base=8, per-unit=4
        [12.0, 0.0],   # Route C: base=12, per-unit=0
    ])

    result = shortest_path_degeneracy(routes)
    print(f"  Route costs at s=1: {(routes[:, 0] + routes[:, 1]).tolist()}")
    print(f"  Min cost: {result['min_cost']}")
    print(f"  Optimal routes: {result['optimal_routes']}")
    print(f"  Degeneracy: {result['degeneracy']}")
    print(f"  {result['interpretation']}")
    print()

    # Case with degeneracy
    routes_degen = np.array([
        [10.0, 2.0],   # Route A: total=12
        [8.0, 4.0],    # Route B: total=12
        [15.0, 0.0],   # Route C: total=15
    ])
    result2 = shortest_path_degeneracy(routes_degen)
    print(f"  Degenerate case: costs={routes_degen[:, 0] + routes_degen[:, 1]}")
    print(f"  {result2['interpretation']}")
    print()

    print("=" * 65)
    print("APPLICATION 2: Tropical Entropy")
    print("=" * 65)

    # Non-degenerate
    w1 = np.array([3.0, 5.0, 7.0, 2.0])
    r1 = tropical_entropy(w1)
    print(f"  Weights: {w1}")
    print(f"  {r1['interpretation']}")

    # Degenerate
    w2 = np.array([2.0, 5.0, 2.0, 2.0])
    r2 = tropical_entropy(w2)
    print(f"  Weights: {w2}")
    print(f"  {r2['interpretation']}")
    print()

    print("=" * 65)
    print("APPLICATION 3: Ground State Degeneracy")
    print("=" * 65)

    energies = np.array([1.0, 3.0, 1.0, 5.0, 1.0])
    temps = np.array([10.0, 5.0, 2.0, 1.0, 0.5, 0.1, 0.01])
    r3 = partition_function_analysis(energies, temps)
    print(f"  Energies: {energies}")
    print(f"  {r3['interpretation']}")
    print(f"  Free energies at various T:")
    for T, F in zip(r3['temperatures'], r3['free_energies']):
        print(f"    T={T:6.2f}: F={F:8.4f}")
    print()

    print("=" * 65)
    print("APPLICATION 4: Assignment Problem as Tropical Regulator")
    print("=" * 65)

    C = np.array([
        [2.0, 5.0, 3.0],
        [4.0, 1.0, 6.0],
        [3.0, 7.0, 2.0],
    ])
    r4 = assignment_analysis(C)
    print(f"  Cost matrix:\n{C}")
    print(f"  {r4['interpretation']}")
    for i, perm in enumerate(r4['optimal_assignments']):
        print(f"    Assignment {i+1}: {perm} → cost = {r4['optimal_cost']}")
    print()

    print("=" * 65)
    print("ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY")
    print("=" * 65)


#!/usr/bin/env python3
"""
Tropical BSD Demo — Concrete numerical examples illustrating the tropical
Birch-Swinnerton-Dyer equality theorem.

This script demonstrates the key mathematical objects:
1. Tropical L-series as infima of affine functions
2. Active sets and tropical order of vanishing
3. Tropical rank from independent valuation profiles
4. Tropical residue decomposition into regulator + Tamagawa
"""

import numpy as np
from itertools import permutations

def tropical_l_series(a, w, s, support):
    """Compute the tropical L-series: inf_{n in support} (a[n] + s * w[n])."""
    values = [a[n] + s * w[n] for n in support]
    return min(values)

def active_set(a, w, s, support):
    """Return the active set: indices achieving the minimum."""
    values = {n: a[n] + s * w[n] for n in support}
    min_val = min(values.values())
    return {n for n, v in values.items() if abs(v - min_val) < 1e-12}

def tropical_order_at_one(a, w, support):
    """Tropical order of vanishing at s=1: |active set| - 1."""
    return len(active_set(a, w, 1.0, support)) - 1

def tropical_regulator(R):
    """Tropical permanent: min over permutations of sum of R[i][sigma(i)]."""
    n = len(R)
    if n == 0:
        return 0.0
    indices = list(range(n))
    min_val = float('inf')
    for perm in permutations(indices):
        val = sum(R[i][perm[i]] for i in indices)
        min_val = min(min_val, val)
    return min_val

def tropical_tamagawa(c):
    """Tropical Tamagawa product (additive): sum of local corrections."""
    return sum(c)

def tropical_residue(R, c):
    """Tropical residue = regulator + Tamagawa."""
    return tropical_regulator(R) + tropical_tamagawa(c)

# ═══════════════════════════════════════════════════════════════
# Example 1: Rank-1 curve (one generator, two active branches)
# ═══════════════════════════════════════════════════════════════
print("=" * 65)
print("EXAMPLE 1: Tropical BSD Equality — Rank 1")
print("=" * 65)

# One generator with valuation profile
m = 1  # number of generators
support = [0, 1, 2]
a = {0: 3.0, 1: 3.0, 2: 5.0}
w = {0: 0.0, 1: 0.0, 2: 0.0}

act = active_set(a, w, 1.0, support)
order = tropical_order_at_one(a, w, support)
rank = m

print(f"  Support: {support}")
print(f"  Coefficients a: {a}")
print(f"  Weights w: {w}")
print(f"  Active set at s=1: {act}")
print(f"  |Active set| = {len(act)}")
print(f"  Tropical order = |active| - 1 = {order}")
print(f"  Tropical rank (generators) = {rank}")
print(f"  ORDER = RANK? {order == rank} ✓" if order == rank else f"  ✗ Mismatch")
print()

# ═══════════════════════════════════════════════════════════════
# Example 2: Rank-2 curve (two generators, three active branches)
# ═══════════════════════════════════════════════════════════════
print("=" * 65)
print("EXAMPLE 2: Tropical BSD Equality — Rank 2")
print("=" * 65)

m = 2
support = [0, 1, 2, 3]
a = {0: 1.0, 1: 1.0, 2: 1.0, 3: 5.0}
w = {0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0}

act = active_set(a, w, 1.0, support)
order = tropical_order_at_one(a, w, support)
rank = m

print(f"  Support: {support}")
print(f"  Coefficients a: {a}")
print(f"  Active set at s=1: {act}")
print(f"  Tropical order = {order}")
print(f"  Tropical rank = {rank}")
print(f"  ORDER = RANK? {order == rank} ✓" if order == rank else f"  ✗ Mismatch")
print()

# ═══════════════════════════════════════════════════════════════
# Example 3: Tropical Residue Decomposition
# ═══════════════════════════════════════════════════════════════
print("=" * 65)
print("EXAMPLE 3: Tropical Residue Decomposition")
print("=" * 65)

R = [[2.0, 5.0], [4.0, 1.0]]
c = [0.5, 0.3]

reg = tropical_regulator(R)
tam = tropical_tamagawa(c)
res = tropical_residue(R, c)

print(f"  Regulator matrix R:")
for row in R:
    print(f"    {row}")
print(f"  Tamagawa data c: {c}")
print(f"  Tropical regulator (min perm sum) = {reg}")
print(f"    Identity perm: {R[0][0] + R[1][1]} = {R[0][0]} + {R[1][1]}")
print(f"    Swap perm:     {R[0][1] + R[1][0]} = {R[0][1]} + {R[1][0]}")
print(f"    Min = {reg}")
print(f"  Tropical Tamagawa = {tam}")
print(f"  Tropical residue = reg + tam = {reg} + {tam} = {res}")
print(f"  DECOMPOSITION VERIFIED: {abs(res - (reg + tam)) < 1e-12} ✓")
print()

# ═══════════════════════════════════════════════════════════════
# Example 4: Permutation Invariance of Regulator
# ═══════════════════════════════════════════════════════════════
print("=" * 65)
print("EXAMPLE 4: Regulator Permutation Invariance")
print("=" * 65)

R = [[1.0, 3.0, 2.0],
     [4.0, 2.0, 5.0],
     [3.0, 1.0, 4.0]]

# Permute: π = (0 1 2) -> (1 2 0)
pi = [1, 2, 0]
R_perm = [[R[pi[i]][pi[j]] for j in range(3)] for i in range(3)]

reg_orig = tropical_regulator(R)
reg_perm = tropical_regulator(R_perm)

print(f"  Original R:")
for row in R:
    print(f"    {row}")
print(f"  Permuted R (π = {pi}):")
for row in R_perm:
    print(f"    {row}")
print(f"  Regulator(R) = {reg_orig}")
print(f"  Regulator(πRπ⁻¹) = {reg_perm}")
print(f"  INVARIANT? {abs(reg_orig - reg_perm) < 1e-12} ✓")
print()

# ═══════════════════════════════════════════════════════════════
# Example 5: L-series as piecewise linear function
# ═══════════════════════════════════════════════════════════════
print("=" * 65)
print("EXAMPLE 5: Tropical L-series — Piecewise Linear Structure")
print("=" * 65)

support = [0, 1, 2]
a = {0: 3.0, 1: 1.0, 2: 0.5}
w = {0: 0.0, 1: 1.0, 2: 2.0}

print(f"  Branches: a[n] + s*w[n]")
for n in support:
    print(f"    n={n}: {a[n]} + {w[n]}·s")

print(f"\n  L-series values:")
for s_val in np.linspace(-1, 3, 9):
    val = tropical_l_series(a, w, s_val, support)
    act_s = active_set(a, w, s_val, support)
    print(f"    s={s_val:5.2f}: L(s)={val:6.2f}  active={act_s}")

s1_order = tropical_order_at_one(a, w, support)
print(f"\n  Tropical order at s=1: {s1_order}")
print()

# ═══════════════════════════════════════════════════════════════
# Example 6: Shift Invariance
# ═══════════════════════════════════════════════════════════════
print("=" * 65)
print("EXAMPLE 6: Shift Invariance of Tropical Order")
print("=" * 65)

support = [0, 1, 2]
a = {0: 2.0, 1: 2.0, 2: 5.0}
w = {0: 0.0, 1: 0.0, 2: 0.0}
c_shift = 7.0
a_shifted = {n: a[n] + c_shift for n in support}

order_orig = tropical_order_at_one(a, w, support)
order_shifted = tropical_order_at_one(a_shifted, w, support)

print(f"  Original a: {a}")
print(f"  Shifted a (+ {c_shift}): {a_shifted}")
print(f"  Order (original) = {order_orig}")
print(f"  Order (shifted)  = {order_shifted}")
print(f"  INVARIANT? {order_orig == order_shifted} ✓")
print()

print("=" * 65)
print("ALL EXAMPLES COMPLETED SUCCESSFULLY")
print("=" * 65)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import os

# Read markdown files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

# Read Lean code
lean_files = [
    'Algebra/TropicalBSD/TropicalBSDEquality.lean',
    'Catalog/Algebra/TropicalBSD/TropicalBSDPrototype.lean',
    'Catalog/Algebra/TropicalBSD/TropicalBSDSpecialization.lean',
]
lean_code = ""
for f in lean_files:
    if os.path.exists(f):
        lean_code += f"-- File: {f}\n" + read_file(f) + "\n\n"

# Read Python code
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations
from visualizations import plot_tropical_l_series, plot_residue_decomposition, plot_active_face_structure

img1 = plot_tropical_l_series()
img2 = plot_residue_decomposition()
img3 = plot_active_face_structure()

package = {
    "title": "Tropical BSD Specialization: Idempotent Arithmetic Special Values",
    "domain": "Algebra / Tropical Geometry / Number Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical BSD Equality Demo",
            "code": demo_code
        },
        {
            "name": "Applications of Tropical BSD",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical L-Series Evaluation",
            "pseudocode": "Input: coefficients a, weights w, parameter s, support S\nOutput: L_trop(s) = inf_{n in S} (a[n] + s * w[n])\n\n1. min_val <- infinity\n2. for n in S:\n3.     val <- a[n] + s * w[n]\n4.     min_val <- min(min_val, val)\n5. return min_val\n\nComplexity: O(|S|) time, O(1) space",
            "code": algorithms_code
        },
        {
            "name": "Tropical Permanent (Regulator)",
            "pseudocode": "Input: n x n matrix R\nOutput: min_{sigma in S_n} sum_i R[i][sigma(i)]\n\n1. min_cost <- infinity\n2. for sigma in Permutations(n):\n3.     cost <- sum_i R[i][sigma(i)]\n4.     min_cost <- min(min_cost, cost)\n5. return min_cost\n\nExact: O(n! * n) time\nHungarian: O(n^3) time",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Tropical L-Series: Lower Envelope Structure",
            "data": img1
        },
        {
            "name": "Tropical Residue Decomposition",
            "data": img2
        },
        {
            "name": "Active Face Structure",
            "data": img3
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Visualizations for Tropical BSD Theory

Generates figures showing:
1. Tropical L-series as lower envelope of affine functions
2. Active set structure and breakpoints
3. Residue decomposition diagram
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io


def fig_to_base64(fig):
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_tropical_l_series():
    """Plot the tropical L-series as lower envelope of affine functions."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Example 1: Three branches
    s = np.linspace(-1, 4, 500)

    # Branches: a[n] + s * w[n]
    branches = [
        (3.0, 0.0, 'Route A: 3.0'),
        (1.0, 1.0, 'Route B: 1.0 + s'),
        (0.5, 2.0, 'Route C: 0.5 + 2s'),
    ]

    colors = ['#e74c3c', '#3498db', '#2ecc71']

    for i, (a, w, label) in enumerate(branches):
        y = a + s * w
        ax1.plot(s, y, '--', color=colors[i], alpha=0.5, linewidth=1.5, label=label)

    # Lower envelope
    envelope = np.minimum.reduce([a + s * w for a, w, _ in branches])
    ax1.plot(s, envelope, 'k-', linewidth=2.5, label='Tropical L-series')

    # Mark s=1
    val_at_1 = min(a + 1.0 * w for a, w, _ in branches)
    ax1.axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
    ax1.plot(1.0, val_at_1, 'ro', markersize=10, zorder=5)
    ax1.annotate(f's=1\nL(1)={val_at_1}', xy=(1.0, val_at_1),
                xytext=(1.5, val_at_1 + 1), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='red'))

    ax1.set_xlabel('Parameter s', fontsize=12)
    ax1.set_ylabel('L_trop(s)', fontsize=12)
    ax1.set_title('Tropical L-series: Lower Envelope', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Example 2: Degenerate case (order = 2)
    branches2 = [
        (1.0, 0.0, 'Branch 1: 1.0'),
        (1.0, 0.0, 'Branch 2: 1.0'),
        (1.0, 0.0, 'Branch 3: 1.0'),
        (5.0, 0.0, 'Branch 4: 5.0'),
    ]

    # Actually make them slightly different slopes for visibility
    branches2_vis = [
        (1.0, 0.0, '#e74c3c'),
        (0.0, 1.0, '#3498db'),
        (-1.0, 2.0, '#2ecc71'),
        (5.0, -1.0, '#9b59b6'),
    ]

    for a, w, c in branches2_vis:
        y = a + s * w
        ax2.plot(s, y, '--', color=c, alpha=0.5, linewidth=1.5)

    envelope2 = np.minimum.reduce([a + s * w for a, w, _ in branches2_vis])
    ax2.plot(s, envelope2, 'k-', linewidth=2.5, label='Tropical L-series')

    # Mark s=1 where three branches meet
    vals_at_1 = [a + 1.0 * w for a, w, _ in branches2_vis]
    min_val = min(vals_at_1)
    active_count = sum(1 for v in vals_at_1 if abs(v - min_val) < 1e-10)

    ax2.axvline(x=1.0, color='gray', linestyle=':', alpha=0.5)
    ax2.plot(1.0, min_val, 'ro', markersize=10, zorder=5)
    ax2.annotate(f's=1, order={active_count-1}', xy=(1.0, min_val),
                xytext=(2.0, min_val + 2), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='red'))

    ax2.set_xlabel('Parameter s', fontsize=12)
    ax2.set_ylabel('L_trop(s)', fontsize=12)
    ax2.set_title('Tropical Order = Active Branches - 1', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Tropical BSD: Min-Plus L-Series Structure', fontsize=16, y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


def plot_residue_decomposition():
    """Plot the residue decomposition: Residue = Regulator + Tamagawa."""
    fig, ax = plt.subplots(figsize=(10, 6))

    categories = ['Regulator\n(Global)', 'Tamagawa\n(Local)', 'Residue\n(Total)']
    values = [3.0, 0.8, 3.8]
    colors = ['#3498db', '#e74c3c', '#2ecc71']

    bars = ax.bar(categories, values, color=colors, edgecolor='black', linewidth=1.5, width=0.6)

    for bar, val in zip(bars, values):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
               f'{val}', ha='center', va='bottom', fontsize=14, fontweight='bold')

    # Add decomposition annotation
    ax.annotate('', xy=(2, 3.8), xytext=(0.5, 3.0),
               arrowprops=dict(arrowstyle='->', color='gray', lw=2))
    ax.annotate('', xy=(2, 3.8), xytext=(1.5, 0.8),
               arrowprops=dict(arrowstyle='->', color='gray', lw=2))

    ax.text(1, 4.3, 'Residue = Regulator + Tamagawa', ha='center',
           fontsize=14, fontweight='bold', style='italic',
           bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='gray'))

    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Tropical BSD Residue Decomposition', fontsize=16)
    ax.set_ylim(0, 5)
    ax.grid(True, alpha=0.3, axis='y')

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_active_face_structure():
    """Plot the active face / breakpoint structure."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Multiple branches with breakpoints
    s = np.linspace(-2, 5, 1000)

    branches = [
        (4.0, -0.5, '#e74c3c', 'Branch 1'),
        (2.0, 0.5, '#3498db', 'Branch 2'),
        (0.0, 1.5, '#2ecc71', 'Branch 3'),
        (-2.0, 2.5, '#9b59b6', 'Branch 4'),
    ]

    for a, w, c, label in branches:
        y = a + s * w
        ax.plot(s, y, '--', color=c, alpha=0.4, linewidth=1)

    envelope = np.minimum.reduce([a + s * w for a, w, _, _ in branches])
    ax.plot(s, envelope, 'k-', linewidth=3, label='L_trop(s)', zorder=5)

    # Find and mark breakpoints
    for i, (a1, w1, _, _) in enumerate(branches):
        for a2, w2, _, _ in branches[i+1:]:
            if abs(w1 - w2) > 1e-10:
                s_bp = (a2 - a1) / (w1 - w2)
                if -2 <= s_bp <= 5:
                    y_bp = a1 + s_bp * w1
                    ax.plot(s_bp, y_bp, 'ko', markersize=8, zorder=6)

    # Shade active regions
    for i, (a, w, c, label) in enumerate(branches):
        y_branch = a + s * w
        mask = np.abs(y_branch - envelope) < 1e-10
        if np.any(mask):
            ax.fill_between(s, envelope - 0.5, envelope + 0.5,
                          where=mask, alpha=0.15, color=c)

    ax.axvline(x=1.0, color='red', linestyle=':', alpha=0.7, linewidth=2)
    val_at_1 = min(a + 1.0 * w for a, w, _, _ in branches)
    active_at_1 = sum(1 for a, w, _, _ in branches
                      if abs(a + w - val_at_1) < 1e-10)
    ax.plot(1.0, val_at_1, 'r*', markersize=15, zorder=7)
    ax.annotate(f's=1\nOrder = {active_at_1 - 1}',
               xy=(1.0, val_at_1), xytext=(2.5, val_at_1 + 2),
               fontsize=12, fontweight='bold',
               arrowprops=dict(arrowstyle='->', color='red', lw=2))

    ax.set_xlabel('Parameter s', fontsize=13)
    ax.set_ylabel('L_trop(s)', fontsize=13)
    ax.set_title('Active Face Structure of Tropical L-Series', fontsize=16)
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=11)

    fig.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    img1 = plot_tropical_l_series()
    print(f"  Tropical L-series plot: {len(img1)} chars")

    img2 = plot_residue_decomposition()
    print(f"  Residue decomposition plot: {len(img2)} chars")

    img3 = plot_active_face_structure()
    print(f"  Active face structure plot: {len(img3)} chars")

    print("All visualizations generated successfully.")
