"""
Applications: Treewidth-Parameterized Lorentzian Recognition

Demonstrates practical applications of the treewidth-bounded approach
to Lorentzian polynomial recognition:

1. Sparse polynomial verification
2. Chemical reaction network analysis
3. Matroid independence polynomial checking
"""

from math import comb
from typing import List, Set, Dict, Tuple
from collections import defaultdict
import itertools


# --- Application 1: Sparse Polynomial Verification ---

def analyze_polynomial_sparsity(
    n: int, monomials: List[Tuple[int, ...]]
) -> Dict[str, any]:
    """Analyze the interaction structure of a polynomial.

    Given a polynomial specified by its monomials (as exponent vectors),
    compute the interaction graph, estimate treewidth, and determine
    the complexity of Lorentzian recognition.

    Args:
        n: Number of variables
        monomials: List of exponent tuples (each of length n)

    Returns:
        Analysis dictionary with interaction graph properties
    """
    # Build interaction graph
    adj: Dict[int, Set[int]] = defaultdict(set)
    max_support = 0

    for mono in monomials:
        support = [i for i in range(n) if mono[i] > 0]
        max_support = max(max_support, len(support))
        for a in range(len(support)):
            for b in range(a + 1, len(support)):
                adj[support[a]].add(support[b])
                adj[support[b]].add(support[a])

    # Compute max degree
    max_degree = max((len(adj[v]) for v in range(n)), default=0)

    # Compute total degree of polynomial
    if monomials:
        d = max(sum(m) for m in monomials)
    else:
        d = 0

    # Estimate treewidth (upper bound from max degree)
    tw_upper = max_degree

    # Compute complexity bounds
    general_leaves = comb(n + d - 3, max(d - 2, 0)) if d >= 2 else 1
    bounded_leaves = comb(n, max_support) * (d + 1) ** max_support if d >= 2 else 1
    bounded_exact = sum(
        comb(n, j) * comb(max(d - 3, 0), max(j - 1, 0))
        for j in range(1, max_support + 1)
        if d - 2 >= j
    ) if d >= 2 else 1

    return {
        "num_variables": n,
        "num_monomials": len(monomials),
        "degree": d,
        "max_monomial_support": max_support,
        "max_graph_degree": max_degree,
        "treewidth_upper_bound": tw_upper,
        "general_leaf_count": general_leaves,
        "bounded_leaf_count_exact": bounded_exact,
        "bounded_leaf_count_upper": bounded_leaves,
        "speedup": general_leaves / max(bounded_exact, 1),
        "is_sparse": max_support <= 3,
    }


# --- Application 2: Chemical Reaction Networks ---

def chemical_network_lorentzian_check(
    species: List[str],
    reactions: List[Tuple[Dict[str, int], Dict[str, int]]]
) -> Dict[str, any]:
    """Analyze Lorentzian structure of a chemical reaction network.

    Chemical reaction networks have natural polynomial structures:
    the steady-state ideal and the determinant of the Jacobian.
    These polynomials inherit sparsity from the network topology.

    Each reaction r: a₁X₁ + a₂X₂ → b₁Y₁ + b₂Y₂ contributes
    monomials with support {X₁, X₂} (reactants only).

    For sparse networks (few species per reaction), the interaction
    graph has bounded treewidth, making Lorentzian checks tractable.

    Args:
        species: List of species names
        reactions: List of (reactants, products) dicts mapping species to counts

    Returns:
        Analysis of the network's polynomial structure
    """
    n = len(species)
    species_idx = {s: i for i, s in enumerate(species)}

    # Build monomials from reactions
    monomials = []
    for reactants, products in reactions:
        # Rate law monomial: product of reactant concentrations
        mono = [0] * n
        for sp, count in reactants.items():
            if sp in species_idx:
                mono[species_idx[sp]] = count
        monomials.append(tuple(mono))

    # Build interaction graph
    adj: Dict[int, Set[int]] = defaultdict(set)
    for mono in monomials:
        support = [i for i in range(n) if mono[i] > 0]
        for a in range(len(support)):
            for b in range(a + 1, len(support)):
                adj[support[a]].add(support[b])
                adj[support[b]].add(support[a])

    max_reactants = max(
        len([s for s, c in r.items() if c > 0])
        for r, _ in reactions
    ) if reactions else 0

    return {
        "num_species": n,
        "num_reactions": len(reactions),
        "max_reactants_per_reaction": max_reactants,
        "interaction_graph_edges": sum(len(v) for v in adj.values()) // 2,
        "is_tree_structured": all(len(v) <= 2 for v in adj.values()),
        "tractable_for_lorentzian": max_reactants <= 3,
    }


# --- Application 3: Matroid Independence Polynomial ---

def matroid_independence_interaction(
    n: int, bases: List[Set[int]]
) -> Dict[str, any]:
    """Analyze interaction structure of a matroid independence polynomial.

    The independence polynomial of a matroid on ground set {0,...,n-1}
    is p(x₁,...,xₙ) = ∑_{I independent} ∏_{i∈I} xᵢ.

    Lorentzianity of this polynomial is equivalent to the matroid having
    the Hodge-Riemann property (Brändén-Huh).

    For uniform matroids, the interaction graph is complete.
    For sparse matroids (bounded rank), the support is bounded.

    Args:
        n: Size of ground set
        bases: List of basis sets

    Returns:
        Interaction analysis
    """
    # Compute independent sets (subsets of bases)
    independent_sets = set()
    for basis in bases:
        for size in range(len(basis) + 1):
            for subset in itertools.combinations(basis, size):
                independent_sets.add(frozenset(subset))

    # Each independent set contributes a monomial
    max_support = max((len(s) for s in independent_sets), default=0)

    # Build interaction graph
    adj: Dict[int, Set[int]] = defaultdict(set)
    for indep in independent_sets:
        supp = list(indep)
        for a in range(len(supp)):
            for b in range(a + 1, len(supp)):
                adj[supp[a]].add(supp[b])
                adj[supp[b]].add(supp[a])

    degree = max_support  # homogeneous of degree = rank

    return {
        "ground_set_size": n,
        "num_bases": len(bases),
        "num_independent_sets": len(independent_sets),
        "rank": max_support,
        "max_monomial_support": max_support,
        "general_leaf_count": comb(n + max_support - 3, max(max_support - 2, 0)) if max_support >= 2 else 1,
        "bounded_leaf_count": comb(n, min(max_support, n)) * max(max_support - 1, 1) ** max_support if max_support >= 2 else 1,
    }


def main():
    print("=" * 70)
    print("APPLICATION 1: Sparse Polynomial Verification")
    print("=" * 70)

    # Example: a polynomial with path-structured interactions
    # p(x₁,...,x₆) = x₁²x₂ + x₂²x₃ + x₃²x₄ + x₄²x₅ + x₅²x₆
    monomials = [
        (2, 1, 0, 0, 0, 0),  # x₁²x₂
        (0, 2, 1, 0, 0, 0),  # x₂²x₃
        (0, 0, 2, 1, 0, 0),  # x₃²x₄
        (0, 0, 0, 2, 1, 0),  # x₄²x₅
        (0, 0, 0, 0, 2, 1),  # x₅²x₆
    ]
    result = analyze_polynomial_sparsity(6, monomials)
    print("\nPath-structured polynomial:")
    for key, val in result.items():
        print(f"  {key}: {val}")

    # Comparison: dense polynomial
    monomials_dense = list(itertools.product(range(2), repeat=6))
    monomials_dense = [m for m in monomials_dense if sum(m) == 3]
    result_dense = analyze_polynomial_sparsity(6, monomials_dense)
    print("\nDense polynomial (all degree-3 monomials):")
    for key, val in result_dense.items():
        print(f"  {key}: {val}")

    print("\n" + "=" * 70)
    print("APPLICATION 2: Chemical Reaction Network")
    print("=" * 70)

    species = ["A", "B", "C", "D", "E"]
    reactions = [
        ({"A": 1, "B": 1}, {"C": 1}),      # A + B → C
        ({"B": 1, "C": 1}, {"D": 1}),      # B + C → D
        ({"C": 1, "D": 1}, {"E": 1}),      # C + D → E
        ({"D": 1, "E": 1}, {"A": 1}),      # D + E → A
    ]
    result = chemical_network_lorentzian_check(species, reactions)
    print("\nLinear chain reaction network:")
    for key, val in result.items():
        print(f"  {key}: {val}")

    print("\n" + "=" * 70)
    print("APPLICATION 3: Matroid Independence Polynomial")
    print("=" * 70)

    # Uniform matroid U_{2,5}: all 2-element subsets are bases
    n = 5
    bases = [set(c) for c in itertools.combinations(range(n), 2)]
    result = matroid_independence_interaction(n, bases)
    print(f"\nUniform matroid U(2,{n}):")
    for key, val in result.items():
        print(f"  {key}: {val}")

    # Sparse matroid: partition matroid
    bases_sparse = [{0, 2}, {0, 3}, {1, 2}, {1, 3}]
    result_sparse = matroid_independence_interaction(4, bases_sparse)
    print(f"\nPartition matroid on 4 elements:")
    for key, val in result_sparse.items():
        print(f"  {key}: {val}")


if __name__ == "__main__":
    main()


"""
Demo: Treewidth-Parameterized Complexity of Lorentzian Recognition

Demonstrates the key results from our formalization:
1. Support-bounded multiindex counting
2. The tractability gap between bounded and unbounded support
3. The FPT conjecture verification for small cases
"""

from math import comb, factorial
from itertools import product as iproduct


def multiindex_count(n: int, d: int) -> int:
    """Count multiindices α : {0,...,n-1} → ℕ with ∑α = d.
    This equals C(n+d-1, d) by stars and bars."""
    if n == 0:
        return 1 if d == 0 else 0
    return comb(n + d - 1, d)


def bounded_support_count(n: int, d: int, k: int) -> int:
    """Count multiindices of weight d in n variables with support size ≤ k.
    Exact computation by enumeration for small cases."""
    if n == 0:
        return 1 if d == 0 else 0
    count = 0
    # For each support size j from 0 to min(k, n)
    for j in range(min(k, n) + 1):
        if j == 0:
            count += (1 if d == 0 else 0)
        else:
            # Choose j positions from n, then distribute d among them (all positive)
            # Number of compositions of d into j positive parts = C(d-1, j-1)
            if d >= j:
                count += comb(n, j) * comb(d - 1, j - 1)
    return count


def bounded_support_upper_bound(n: int, d: int, k: int) -> int:
    """The proven upper bound: C(n,k) * (d+1)^k."""
    return comb(n, k) * (d + 1) ** k


def general_upper_bound(n: int, d: int) -> int:
    """The general upper bound n^d (from catalog)."""
    return n ** d


def leaf_count(n: int, d: int) -> int:
    """Number of quadratic leaves: multiindex count with weight d-2."""
    if d < 2:
        return 1
    return multiindex_count(n, d - 2)


def bounded_leaf_count(n: int, d: int, k: int) -> int:
    """Bounded-support leaf count."""
    if d < 2:
        return 1
    return bounded_support_count(n, d - 2, k)


def main():
    print("=" * 70)
    print("TREEWIDTH-PARAMETERIZED LORENTZIAN RECOGNITION COMPLEXITY")
    print("=" * 70)

    # Demo 1: Support-bounded counts vs general counts
    print("\n--- Demo 1: Support-Bounded vs General Multiindex Count ---")
    print(f"{'n':>4} {'d':>4} {'k':>4} {'bounded':>12} {'C(n,k)*(d+1)^k':>18} {'general n^d':>14} {'ratio':>10}")
    print("-" * 70)
    for n in [5, 10, 20]:
        for d in [4, 6, 8, 10]:
            k = 2  # path-structured: support ≤ 2
            bc = bounded_support_count(n, d, k)
            ub = bounded_support_upper_bound(n, d, k)
            gen = general_upper_bound(n, d)
            ratio = gen / max(bc, 1)
            print(f"{n:>4} {d:>4} {k:>4} {bc:>12} {ub:>18} {gen:>14} {ratio:>10.1f}")

    # Demo 2: The tractability gap
    print("\n--- Demo 2: Tractability Gap (support-1 count vs n^d) ---")
    print(f"{'n':>4} {'d':>4} {'support-1':>12} {'n^d':>14} {'gap factor':>12}")
    print("-" * 50)
    for n in [3, 5, 10]:
        for d in [2, 4, 6, 8]:
            s1 = bounded_support_count(n, d, 1)
            nd = n ** d
            print(f"{n:>4} {d:>4} {s1:>12} {nd:>14} {nd // max(s1, 1):>12}")

    # Demo 3: The FPT conjecture for path-structured polynomials
    print("\n--- Demo 3: FPT Conjecture Verification (w=1, path-structured) ---")
    print(f"{'n':>4} {'d':>4} {'bounded leaves':>16} {'C(n,2)*(d-1)^2':>18} {'general leaves':>16}")
    print("-" * 60)
    n = 20
    for d in [4, 6, 8, 10, 12, 14]:
        bl = bounded_leaf_count(n, d, 2)
        bound = comb(n, 2) * (d - 1) ** 2
        gl = leaf_count(n, d)
        print(f"{n:>4} {d:>4} {bl:>16} {bound:>18} {gl:>16}")

    # Demo 4: Testable prediction
    print("\n--- Demo 4: Testable Prediction ---")
    n, d = 20, 10
    bl = bounded_leaf_count(n, d, 2)
    gl = leaf_count(n, d)
    print(f"n = {n}, d = {d}")
    print(f"  Support-2 leaf count:  {bl}")
    print(f"  General leaf count:    {gl}")
    print(f"  Reduction factor:      {gl / max(bl, 1):.1f}x")
    print(f"  Bound C(20,2)·9² = {comb(20, 2) * 81}")

    # Demo 5: Unbounded tractability gap
    print("\n--- Demo 5: Unbounded Tractability Gap ---")
    print(f"For n = 3, showing n * C < n^d for d = C + 2:")
    n = 3
    for C in [1, 5, 10, 50, 100]:
        d = C + 2
        lhs = n * C
        rhs = n ** d
        print(f"  C = {C:>4}: n*C = {lhs:>10}, n^d = {rhs:>30}, gap verified: {lhs < rhs}")


if __name__ == "__main__":
    main()


"""
Visualization: The FPT Landscape for Lorentzian Recognition

This script maps the complexity landscape showing how treewidth and degree
jointly determine recognition complexity. The key insight: for any fixed
treewidth w, complexity is polynomial in degree, but grows with w.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from mpl_toolkits.mplot3d import Axes3D


def bounded_count(n, d, k):
    if d <= 0:
        return 1
    return max(sum(comb(n, j) * comb(d - 1, j - 1)
                   for j in range(1, min(k, n) + 1) if d >= j), 1)


def general_count(n, d):
    if d <= 0:
        return 1
    return comb(n + d - 1, d)


fig = plt.figure(figsize=(16, 6))

# --- Plot 1: 3D surface of complexity landscape ---
ax1 = fig.add_subplot(131, projection='3d')

n = 15
ds = np.arange(3, 16)
ks = np.arange(1, 8)
D, K = np.meshgrid(ds, ks)

Z = np.zeros_like(D, dtype=float)
for i in range(len(ks)):
    for j in range(len(ds)):
        Z[i, j] = np.log10(max(bounded_count(n, ds[j] - 2, ks[i]), 1))

surf = ax1.plot_surface(D, K, Z, cmap='viridis', alpha=0.8,
                        edgecolor='none')
ax1.set_xlabel('Degree d', fontsize=10)
ax1.set_ylabel('Support bound k', fontsize=10)
ax1.set_zlabel('log₁₀(leaf count)', fontsize=10)
ax1.set_title(f'FPT Landscape (n={n})', fontsize=12, fontweight='bold')
ax1.view_init(elev=25, azim=45)

# --- Plot 2: Phase diagram ---
ax2 = fig.add_subplot(132)

n_vals = range(4, 25)
d_vals = range(4, 25)

phase = np.zeros((len(list(d_vals)), len(list(n_vals))))
n_list = list(n_vals)
d_list = list(d_vals)

for i, d in enumerate(d_list):
    for j, n_val in enumerate(n_list):
        gen = general_count(n_val, d - 2)
        k_star = 2  # threshold support
        bnd = bounded_count(n_val, d - 2, k_star)
        if gen > 0 and bnd > 0:
            ratio = np.log10(gen / bnd)
        else:
            ratio = 0
        phase[i, j] = ratio

im = ax2.imshow(phase, aspect='auto', cmap='RdYlGn_r',
                extent=[n_list[0]-0.5, n_list[-1]+0.5,
                        d_list[-1]+0.5, d_list[0]-0.5],
                vmin=0)
ax2.set_xlabel('Variables n', fontsize=11)
ax2.set_ylabel('Degree d', fontsize=11)
ax2.set_title('Phase Diagram: Speedup from\nSupport Bound k=2',
              fontsize=12, fontweight='bold')
plt.colorbar(im, ax=ax2, label='log₁₀(speedup)')

# Draw the "tractability boundary"
boundary_d = []
boundary_n = []
for n_val in n_list:
    for d in d_list:
        gen = general_count(n_val, d - 2)
        bnd = bounded_count(n_val, d - 2, 2)
        if gen > 10 * bnd:
            boundary_d.append(d)
            boundary_n.append(n_val)
            break

if boundary_n and boundary_d:
    ax2.plot(boundary_n, boundary_d, 'w--', linewidth=2, label='10× speedup')
    ax2.legend(fontsize=9, loc='upper right')

# --- Plot 3: FPT conjecture verification ---
ax3 = fig.add_subplot(133)

# For each w, plot bounded_count(n, d-2, w+1) / (n^(w+1) * d^(w+1))
# If FPT holds, this ratio should be bounded by a constant

n_test = 15
for w, color in [(0, '#e74c3c'), (1, '#f39c12'), (2, '#2ecc71'), (3, '#3498db')]:
    ds_test = list(range(4, 20))
    ratios = []
    for d in ds_test:
        bnd = bounded_count(n_test, d - 2, w + 1)
        normalizer = n_test ** (w + 1) * d ** (w + 1)
        if normalizer > 0:
            ratios.append(bnd / normalizer)
        else:
            ratios.append(0)
    ax3.plot(ds_test, ratios, 'o-', color=color, label=f'w = {w}',
             markersize=4, linewidth=2)

ax3.set_xlabel('Degree d', fontsize=11)
ax3.set_ylabel('count / (n^(w+1) · d^(w+1))', fontsize=11)
ax3.set_title(f'FPT Conjecture Test (n={n_test})\nRatio should stabilize',
              fontsize=12, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(bottom=0)

plt.tight_layout()
plt.savefig('fpt_landscape.png', dpi=150, bbox_inches='tight')
print("Saved fpt_landscape.png")


"""
Visualization: Variable Interaction Graphs and Tree Decompositions

This script illustrates how the interaction structure of a polynomial
determines the complexity of Lorentzian recognition. Path-structured
polynomials (treewidth 1) have dramatically fewer Hessian checks
than densely-interacting polynomials.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import comb


def bounded_support_count_exact(n, d, k):
    if d == 0:
        return 1
    return sum(comb(n, j) * comb(d - 1, j - 1)
               for j in range(1, min(k, n) + 1) if d >= j)


def general_multiindex_count(n, d):
    return comb(n + d - 1, d)


fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# --- Plot 1: Path interaction graph ---
ax = axes[0, 0]
n = 8
# Draw vertices in a line
positions = [(i * 1.2, 0) for i in range(n)]
for i, (x, y) in enumerate(positions):
    circle = plt.Circle((x, y), 0.3, color='#3498db', ec='#2c3e50', linewidth=2)
    ax.add_patch(circle)
    ax.text(x, y, f'x{i+1}', ha='center', va='center', fontsize=9,
            fontweight='bold', color='white')

# Draw edges (path)
for i in range(n - 1):
    ax.plot([positions[i][0] + 0.3, positions[i+1][0] - 0.3],
            [0, 0], 'k-', linewidth=2)

ax.set_xlim(-0.8, (n-1) * 1.2 + 0.8)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title('Path Interaction Graph (treewidth = 1)', fontsize=13,
             fontweight='bold')
ax.text((n-1)*0.6, -1.0,
        'Each monomial involves ≤ 2 adjacent variables\n'
        'Hessian checks: O(n · d) — polynomial',
        ha='center', fontsize=10, style='italic',
        bbox=dict(boxstyle='round', facecolor='#ecf0f1'))
ax.axis('off')

# --- Plot 2: Complete interaction graph ---
ax = axes[0, 1]
n_complete = 6
angle_offset = np.pi / 2
angles = [angle_offset + 2 * np.pi * i / n_complete for i in range(n_complete)]
positions_c = [(2 * np.cos(a), 2 * np.sin(a)) for a in angles]

# Draw edges (complete graph)
for i in range(n_complete):
    for j in range(i + 1, n_complete):
        ax.plot([positions_c[i][0], positions_c[j][0]],
                [positions_c[i][1], positions_c[j][1]],
                color='#e74c3c', linewidth=1, alpha=0.4)

# Draw vertices
for i, (x, y) in enumerate(positions_c):
    circle = plt.Circle((x, y), 0.35, color='#e74c3c', ec='#c0392b', linewidth=2)
    ax.add_patch(circle)
    ax.text(x, y, f'x{i+1}', ha='center', va='center', fontsize=9,
            fontweight='bold', color='white')

ax.set_xlim(-3.5, 3.5)
ax.set_ylim(-3.5, 3.5)
ax.set_aspect('equal')
ax.set_title(f'Complete Interaction Graph (treewidth = {n_complete-1})',
             fontsize=13, fontweight='bold')
ax.text(0, -3.0,
        'Every pair of variables interacts\n'
        'Hessian checks: O(n^d) — exponential',
        ha='center', fontsize=10, style='italic',
        bbox=dict(boxstyle='round', facecolor='#fadbd8'))
ax.axis('off')

# --- Plot 3: Tree decomposition visualization ---
ax = axes[1, 0]
# Show bags for the path decomposition
bag_colors = ['#1abc9c', '#16a085', '#2ecc71', '#27ae60',
              '#3498db', '#2980b9', '#9b59b6']

n_bags = 5
bag_width = 1.8
for i in range(n_bags):
    x = i * 2.2
    rect = mpatches.FancyBboxPatch((x - bag_width/2, -0.8), bag_width, 1.6,
                                     boxstyle="round,pad=0.1",
                                     facecolor=bag_colors[i % len(bag_colors)],
                                     edgecolor='#2c3e50', linewidth=2, alpha=0.7)
    ax.add_patch(rect)
    ax.text(x, 0, f'{{x{i+1}, x{i+2}}}', ha='center', va='center',
            fontsize=9, fontweight='bold', color='white')

    if i < n_bags - 1:
        ax.annotate('', xy=((i+1)*2.2 - bag_width/2, 0),
                    xytext=(i*2.2 + bag_width/2, 0),
                    arrowprops=dict(arrowstyle='->', lw=2, color='#2c3e50'))

ax.set_xlim(-1.5, n_bags * 2.2)
ax.set_ylim(-2, 2)
ax.set_title('Tree Decomposition (width = 1)', fontsize=13, fontweight='bold')
ax.text(n_bags * 1.1, -1.5,
        'Each bag has ≤ 2 variables\n'
        'Hessian factorizes along bags',
        ha='center', fontsize=10, style='italic',
        bbox=dict(boxstyle='round', facecolor='#d5f4e6'))
ax.axis('off')

# --- Plot 4: Complexity comparison bar chart ---
ax = axes[1, 1]
configs = [
    ('Path\n(tw=1)', 10, 8, 2),
    ('Cycle\n(tw=2)', 10, 8, 3),
    ('Grid\n(tw=3)', 10, 8, 4),
    ('Dense\n(tw=9)', 10, 8, 10),
]

labels = []
bounded_counts = []
general_counts_list = []

for label, n_val, d_val, k_val in configs:
    labels.append(label)
    bc = bounded_support_count_exact(n_val, d_val - 2, k_val)
    gc = general_multiindex_count(n_val, d_val - 2)
    bounded_counts.append(max(bc, 1))
    general_counts_list.append(gc)

x_pos = np.arange(len(labels))
width = 0.35

bars1 = ax.bar(x_pos - width/2, [np.log10(max(c, 1)) for c in bounded_counts],
               width, label='Bounded support', color='#2ecc71', edgecolor='#27ae60')
bars2 = ax.bar(x_pos + width/2, [np.log10(max(c, 1)) for c in general_counts_list],
               width, label='Unrestricted', color='#e74c3c', edgecolor='#c0392b')

ax.set_xlabel('Interaction Structure', fontsize=12)
ax.set_ylabel('log₁₀(leaf count)', fontsize=12)
ax.set_title(f'Complexity by Interaction Type (n={10}, d={8})',
             fontsize=13, fontweight='bold')
ax.set_xticks(x_pos)
ax.set_xticklabels(labels, fontsize=10)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('interaction_graphs.png', dpi=150, bbox_inches='tight')
print("Saved interaction_graphs.png")


"""
Visualization: The Tractability Gap in Lorentzian Recognition

This script visualizes how bounded-treewidth (support-bounded) multiindex
counts grow polynomially in degree d, while unrestricted counts grow
exponentially. The gap between them demonstrates why treewidth is the
right structural parameter for Lorentzian recognition complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def bounded_support_count_exact(n: int, d: int, k: int) -> int:
    """Exact count of multiindices with support ≤ k."""
    if d == 0:
        return 1
    return sum(
        comb(n, j) * comb(d - 1, j - 1)
        for j in range(1, min(k, n) + 1)
        if d >= j
    )


def general_multiindex_count(n: int, d: int) -> int:
    """Total multiindex count C(n+d-1, d)."""
    return comb(n + d - 1, d)


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# --- Plot 1: Log-scale growth comparison ---
ax1 = axes[0]
n = 10
degrees = list(range(2, 25))

for k, color, label in [(1, '#e74c3c', 'Support ≤ 1'),
                          (2, '#f39c12', 'Support ≤ 2'),
                          (3, '#2ecc71', 'Support ≤ 3'),
                          (None, '#3498db', 'Unrestricted')]:
    counts = []
    for d in degrees:
        if k is None:
            counts.append(general_multiindex_count(n, d - 2))
        else:
            counts.append(max(bounded_support_count_exact(n, d - 2, k), 1))
    ax1.semilogy(degrees, counts, 'o-', color=color, label=label,
                 markersize=4, linewidth=2)

ax1.set_xlabel('Degree d', fontsize=12)
ax1.set_ylabel('Number of Hessian checks (log scale)', fontsize=12)
ax1.set_title(f'Lorentzian Leaf Count: n = {n} variables', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)

# --- Plot 2: Speedup factor ---
ax2 = axes[1]
for n_val, color, marker in [(5, '#e74c3c', 's'),
                               (10, '#3498db', 'o'),
                               (20, '#2ecc71', '^')]:
    speedups = []
    ds = list(range(4, 20))
    for d in ds:
        gen = general_multiindex_count(n_val, d - 2)
        bounded = max(bounded_support_count_exact(n_val, d - 2, 2), 1)
        speedups.append(gen / bounded)
    ax2.semilogy(ds, speedups, f'{marker}-', color=color,
                 label=f'n = {n_val}', markersize=5, linewidth=2)

ax2.set_xlabel('Degree d', fontsize=12)
ax2.set_ylabel('Speedup factor (log scale)', fontsize=12)
ax2.set_title('Speedup from Support Bound k = 2', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

# --- Plot 3: Heatmap of the tractability landscape ---
ax3 = axes[2]
n_vals = list(range(3, 16))
k_vals = list(range(1, 8))
d = 10

data = np.zeros((len(k_vals), len(n_vals)))
for i, k in enumerate(k_vals):
    for j, n_val in enumerate(n_vals):
        gen = general_multiindex_count(n_val, d - 2)
        bounded = max(bounded_support_count_exact(n_val, d - 2, k), 1)
        ratio = np.log10(max(gen / bounded, 1))
        data[i, j] = ratio

im = ax3.imshow(data, aspect='auto', cmap='YlOrRd',
                extent=[n_vals[0]-0.5, n_vals[-1]+0.5,
                        k_vals[-1]+0.5, k_vals[0]-0.5])
ax3.set_xlabel('Number of variables n', fontsize=12)
ax3.set_ylabel('Support bound k', fontsize=12)
ax3.set_title(f'log₁₀(Speedup) at degree d = {d}', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax3, label='log₁₀(general/bounded)')

plt.tight_layout()
plt.savefig('tractability_gap.png', dpi=150, bbox_inches='tight')
print("Saved tractability_gap.png")
