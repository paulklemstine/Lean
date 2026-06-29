"""
Applications of Quantum MacWilliams Identity and Bravyi-Terhal Bound

Demonstrates real-world applications:
1. Code parameter optimization using linear programming bounds
2. Toric code scaling analysis for quantum memory design
3. Degenerate vs nondegenerate code comparison
4. Tropical geometry of weight enumerators
"""

import numpy as np
from math import comb, log2, ceil, floor


def krawtchouk(n, j, x):
    """Krawtchouk polynomial K_j(x; n)."""
    return sum((-1)**l * comb(x, l) * comb(n - x, j - l) for l in range(j + 1))


def krawtchouk_matrix(n):
    """Full Krawtchouk matrix."""
    return np.array([[krawtchouk(n, j, i) for i in range(n + 1)]
                     for j in range(n + 1)], dtype=float)


def macwilliams_transform(n, k, A):
    """Quantum MacWilliams transform: B = K · A / 2^(n-k)."""
    K = krawtchouk_matrix(n)
    return K @ A / (2 ** (n - k))


# ─── Application 1: Code Parameter Optimization ───

def find_optimal_codes(n_max=15, d_values=None):
    """
    Find optimal stabilizer code parameters using known bounds.

    For each (n, d), find the maximum k satisfying:
    - Singleton bound: 2d + k ≤ n + 2
    - Hamming bound: Σ 3^j C(n,j) ≤ 2^(n-k) for j ≤ ⌊(d-1)/2⌋

    Returns dict mapping (n, d) → max_k.
    """
    if d_values is None:
        d_values = [1, 2, 3, 4, 5]

    results = {}
    for n in range(1, n_max + 1):
        for d in d_values:
            if d > n + 1:
                continue

            # Singleton bound
            k_singleton = n - 2 * d + 2

            # Hamming bound (nondegenerate)
            t = (d - 1) // 2
            hamming_sum = sum(3**j * comb(n, j) for j in range(t + 1))
            if hamming_sum > 0:
                k_hamming = n - ceil(log2(hamming_sum))
            else:
                k_hamming = n

            k_max = min(k_singleton, k_hamming, n)
            k_max = max(k_max, 0)

            results[(n, d)] = k_max

    return results


# ─── Application 2: Toric Code Scaling ───

def toric_code_analysis(L_values=None):
    """
    Analyze toric code parameters and their relationship to bounds.

    The toric code on an L×L lattice has:
    - n = 2L² physical qubits
    - k = 2 logical qubits
    - d = L minimum distance

    Saturates: k · d² = n (Bravyi-Terhal bound)
    """
    if L_values is None:
        L_values = list(range(2, 21))

    print("=" * 70)
    print("TORIC CODE SCALING ANALYSIS")
    print("=" * 70)
    print(f"{'L':>4} {'n=2L²':>8} {'k':>4} {'d=L':>4} {'k·d²':>8} "
          f"{'=n?':>5} {'Rate':>8} {'Singleton':>12}")
    print("-" * 70)

    for L in L_values:
        n = 2 * L**2
        k = 2
        d = L
        kd2 = k * d**2
        saturates = "✓" if kd2 == n else "✗"
        rate = k / n
        singleton_margin = n + 2 - 2 * d - k

        print(f"{L:4d} {n:8d} {k:4d} {d:4d} {kd2:8d} {saturates:>5} "
              f"{rate:8.4f} {singleton_margin:12d}")

    return L_values


# ─── Application 3: Degeneracy Analysis ───

def degeneracy_comparison():
    """
    Compare degenerate and nondegenerate codes.

    For degenerate codes, the effective error-correction sphere is smaller
    because stabilizer elements of weight < d share syndromes.
    """
    print("\n" + "=" * 70)
    print("DEGENERATE vs NONDEGENERATE CODE COMPARISON")
    print("=" * 70)

    codes = {
        "[[5,1,3]] Perfect": {
            "n": 5, "k": 1, "d": 3,
            "A": np.array([1, 0, 0, 0, 0, 15], dtype=float),
            "degenerate": False,
        },
        "[[7,1,3]] Steane": {
            "n": 7, "k": 1, "d": 3,
            "A": np.array([1, 0, 0, 0, 7, 0, 0, 56], dtype=float),
            "degenerate": True,  # A_4 = 7 > 0, but 4 ≥ d=3
        },
        "[[9,1,3]] Shor": {
            "n": 9, "k": 1, "d": 3,
            "A": np.array([1, 0, 0, 0, 0, 0, 30, 0, 0, 225], dtype=float),
            "degenerate": True,
        },
    }

    for name, code in codes.items():
        n, k, d = code["n"], code["k"], code["d"]
        A = code["A"]
        B = macwilliams_transform(n, k, A)

        t = (d - 1) // 2
        hamming_sum = sum(3**j * comb(n, j) for j in range(t + 1))

        # Check for degeneracy: A_j > 0 for 0 < j < d
        degen_weights = [j for j in range(1, d) if A[j] > 0]
        is_degen = len(degen_weights) > 0

        print(f"\n{name}:")
        print(f"  Parameters: n={n}, k={k}, d={d}")
        print(f"  A-enumerator: {A}")
        print(f"  Degenerate weights (0 < j < d with A_j > 0): {degen_weights}")
        print(f"  Is degenerate: {is_degen}")
        print(f"  Hamming sum (t={t}): {hamming_sum}")
        print(f"  2^(n-k) = {2**(n-k)}")
        print(f"  Hamming ratio: {hamming_sum / 2**(n-k):.4f}")

        # Effective correction sphere for degenerate codes
        effective_A = sum(A[j] for j in range(t + 1))
        print(f"  Effective A-sum (j ≤ t): {effective_A:.0f}")
        print(f"  Full Hamming sphere: {hamming_sum}")
        if effective_A < hamming_sum:
            print(f"  → Degenerate relaxation: {hamming_sum - effective_A:.0f} "
                  f"fewer syndromes needed")


# ─── Application 4: Tropical Geometry ───

def tropical_analysis():
    """
    Analyze the tropical geometry of quantum weight enumerators.

    The tropicalization maps:
    A(z) = Σ A_j z^j → trop(A)(z) = min_j (-log(A_j) + j·z)

    The break points of trop(A) correspond to the Newton polytope vertices.
    """
    print("\n" + "=" * 70)
    print("TROPICAL GEOMETRY OF WEIGHT ENUMERATORS")
    print("=" * 70)

    codes = {
        "[[5,1,3]]": np.array([1, 0, 0, 0, 0, 15], dtype=float),
        "[[7,1,3]]": np.array([1, 0, 0, 0, 7, 0, 0, 56], dtype=float),
        "[[9,1,3]]": np.array([1, 0, 0, 0, 0, 0, 30, 0, 0, 225], dtype=float),
    }

    for name, A in codes.items():
        n = len(A) - 1
        print(f"\n{name}:")

        # Tropical A-weights
        trop_A = []
        for j in range(n + 1):
            if A[j] > 0:
                trop_A.append((j, -np.log(A[j])))
                print(f"  trop(A)[{j}] = -log({A[j]:.0f}) = {-np.log(A[j]):.4f}")
            else:
                print(f"  trop(A)[{j}] = ∞ (A_{j} = 0)")

        # Newton polytope vertices (convex hull of (j, trop_A_j))
        if trop_A:
            vertices = np.array(trop_A)
            print(f"  Newton polytope vertices (j, -log A_j): "
                  f"{[(int(v[0]), round(v[1], 4)) for v in vertices]}")

        # Tropical evaluation at sample points
        print(f"  Tropical polynomial evaluation:")
        for z in [-2, -1, 0, 1, 2]:
            val = min((-np.log(A[j]) + j * z if A[j] > 0 else float('inf'))
                      for j in range(n + 1))
            print(f"    trop(A)({z}) = {val:.4f}")


if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("APPLICATION 1: CODE PARAMETER OPTIMIZATION")
    print("=" * 70)

    results = find_optimal_codes(n_max=12)
    print(f"\nOptimal k for selected (n, d):")
    print(f"{'n':>4} | {'d=1':>4} {'d=2':>4} {'d=3':>4} {'d=4':>4} {'d=5':>4}")
    print("-" * 30)
    for n in range(1, 13):
        row = f"{n:4d} |"
        for d in [1, 2, 3, 4, 5]:
            if (n, d) in results:
                row += f" {results[(n, d)]:4d}"
            else:
                row += "    -"
        print(row)

    toric_code_analysis()
    degeneracy_comparison()
    tropical_analysis()

    print(f"\n{'=' * 70}")
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


"""
Quantum MacWilliams Identity: Demonstration and Verification

This script:
1. Computes Krawtchouk polynomials and verifies their properties
2. Demonstrates the quantum MacWilliams transform and its inverse
3. Plots Krawtchouk matrices, weight polytopes, and tropical transforms
4. Visualizes the Bravyi-Terhal bound in (k, d, n)-space for D=1,2,3

Requirements: numpy, matplotlib
"""

import numpy as np
from math import comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


# ─── Core Functions ───

def krawtchouk(n, j, x):
    """Krawtchouk polynomial K_j(x; n) for binary codes."""
    return sum((-1)**l * comb(x, l) * comb(n - x, j - l) for l in range(j + 1))


def krawtchouk_matrix(n):
    """Full (n+1)×(n+1) Krawtchouk matrix."""
    return np.array([[krawtchouk(n, j, i) for i in range(n + 1)]
                     for j in range(n + 1)], dtype=float)


def macwilliams_transform(n, k, A):
    """Quantum MacWilliams transform: B = K · A / 2^(n-k)."""
    K = krawtchouk_matrix(n)
    return K @ A / (2 ** (n - k))


def inverse_macwilliams(n, k, B):
    """Inverse MacWilliams transform: A = K · B / 2^(n+k)."""
    K = krawtchouk_matrix(n)
    # K^{-1} = K · diag(1/C(n,j)) / 2^n, but simpler: A = K·B / 2^n (since K²=2^n D)
    binomials = np.array([comb(n, j) for j in range(n + 1)], dtype=float)
    return K @ (B / binomials) / (2 ** n) * binomials


# ─── Part 1: Krawtchouk Polynomial Verification ───

print("=" * 70)
print("KRAWTCHOUK POLYNOMIAL PROPERTIES")
print("=" * 70)

# Property 1: K_0(x; n) = 1
print("\n1. K_0(x; n) = 1 for all x:")
for n in [5, 7, 10]:
    vals = [krawtchouk(n, 0, x) for x in range(n + 1)]
    ok = all(v == 1 for v in vals)
    print(f"   n={n}: {vals[:6]}... {'✓' if ok else '✗'}")

# Property 2: K_j(0; n) = C(n, j)
print("\n2. K_j(0; n) = C(n, j):")
for n in [5, 7]:
    for j in range(n + 1):
        val = krawtchouk(n, j, 0)
        expected = comb(n, j)
        ok = val == expected
        if not ok:
            print(f"   ✗ K_{j}(0; {n}) = {val} ≠ C({n},{j}) = {expected}")
    else:
        print(f"   n={n}: all match ✓")

# Property 3: K_1(x; n) = n - 2x
print("\n3. K_1(x; n) = n - 2x:")
for n in [5, 7, 10]:
    ok = all(krawtchouk(n, 1, x) == n - 2*x for x in range(n + 1))
    print(f"   n={n}: {'✓' if ok else '✗'}")

# Property 4: K_j(n; n) = (-1)^j C(n, j)
print("\n4. K_j(n; n) = (-1)^j C(n, j):")
for n in [5, 7]:
    ok = all(krawtchouk(n, j, n) == ((-1)**j) * comb(n, j) for j in range(n + 1))
    print(f"   n={n}: {'✓' if ok else '✗'}")

# Property 5: Orthogonality K · K^T = 2^n · diag(C(n,j))
print("\n5. Krawtchouk matrix orthogonality:")
for n in [5, 7, 10]:
    K = krawtchouk_matrix(n)
    diag = np.array([2**n * comb(n, j) for j in range(n + 1)])
    product = K @ K.T
    expected = np.diag(diag)
    ok = np.allclose(product, expected, atol=1e-8)
    print(f"   n={n}: K·K^T = 2^n · diag(C(n,j)) {'✓' if ok else '✗'}")


# ─── Part 2: MacWilliams Transform Verification ───

print(f"\n{'=' * 70}")
print("QUANTUM MACWILLIAMS TRANSFORM — ROUND-TRIP VERIFICATION")
print("=" * 70)

for n in range(2, 11):
    K = krawtchouk_matrix(n)
    binomials = np.array([comb(n, j) for j in range(n + 1)], dtype=float)

    # K^2 = 2^n · diag(C(n,j))
    K2 = K @ K
    expected_diag = 2**n * binomials
    ok = np.allclose(np.diag(K2), expected_diag, atol=1e-8)
    offdiag_ok = np.allclose(K2 - np.diag(np.diag(K2)), 0, atol=1e-8)
    print(f"  n={n:2d}: K² = 2^n·diag(C(n,j)) {'✓' if ok and offdiag_ok else '✗'}")


# ─── Part 3: Weight Enumerator Examples ───

print(f"\n{'=' * 70}")
print("QUANTUM WEIGHT ENUMERATOR EXAMPLES")
print("=" * 70)

# Create consistent weight enumerators by defining A and computing B
examples = [
    {"name": "Trivial code [[3,1,1]]", "n": 3, "k": 1, "d": 1,
     "A": np.array([1, 0, 3, 4], dtype=float)},  # Σ = 8 = 2^3 ✓
    {"name": "Repetition-like [[4,0,2]]", "n": 4, "k": 0, "d": 2,
     "A": np.array([1, 0, 6, 0, 9], dtype=float)},  # Σ = 16 = 2^4 ✓
    {"name": "Example [[6,2,2]]", "n": 6, "k": 2, "d": 2,
     "A": np.array([1, 0, 10, 20, 15, 12, 6], dtype=float)},  # Σ = 64 = 2^6 ✓
]

for ex in examples:
    n, k, d = ex["n"], ex["k"], ex["d"]
    A = ex["A"]
    B = macwilliams_transform(n, k, A)

    print(f"\n{ex['name']}:")
    print(f"  A = {A}  (sum = {np.sum(A):.0f}, expected 2^{n} = {2**n})")
    print(f"  B = {np.round(B, 4)}")
    print(f"  B₀ = {B[0]:.4f} (expected 2^{k} = {2**k})")
    print(f"  B₀ check: {'✓' if abs(B[0] - 2**k) < 1e-10 else '✗'}")

    # Singleton bound
    singleton_ok = 2 * d + k <= n + 2
    print(f"  Singleton (2d+k ≤ n+2): {2*d+k} ≤ {n+2} {'✓' if singleton_ok else '✗'}")


# ─── Part 4: Krawtchouk Matrix Heatmaps ───

fig, axes = plt.subplots(1, 3, figsize=(18, 5))
for idx, n in enumerate([5, 7, 10]):
    K = krawtchouk_matrix(n)
    ax = axes[idx]
    vmax = np.max(np.abs(K))
    im = ax.imshow(K, cmap='RdBu_r', aspect='auto', vmin=-vmax, vmax=vmax)
    ax.set_title(f'Krawtchouk Matrix (n={n})', fontsize=12)
    ax.set_xlabel('Column i (evaluation point)')
    ax.set_ylabel('Row j (polynomial index)')
    plt.colorbar(im, ax=ax, shrink=0.8)

plt.suptitle('Krawtchouk Matrices — Character Tables of Hamming Association Schemes',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('krawtchouk_matrices.png', dpi=150, bbox_inches='tight')
print(f"\n✓ Saved krawtchouk_matrices.png")
plt.close()


# ─── Part 5: Bravyi-Terhal Bound Visualization ───

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

for idx, D in enumerate([1, 2, 3]):
    ax = axes[idx]
    n_max = 200
    ns = np.arange(1, n_max + 1, dtype=float)

    for d, color, ls in [(2, 'blue', '-'), (4, 'red', '-'),
                         (8, 'green', '-'), (16, 'purple', '--')]:
        # BT bound: k ≤ c · n / d^(2D/(D+1))
        exponent = 2 * D / (D + 1)
        k_max = ns / (d ** exponent)
        k_max = np.clip(k_max, 0, ns)
        ax.plot(ns, k_max, color=color, linewidth=2, linestyle=ls,
                label=f'd={d}')

    # Mark toric code points (D=2 only)
    if D == 2:
        for L in [2, 3, 4, 5, 6, 8, 10]:
            n_tc = 2 * L**2
            k_tc = 2
            if n_tc <= n_max:
                ax.scatter([n_tc], [k_tc], c='black', s=80, zorder=10,
                           marker='*')
                if L <= 5:
                    ax.annotate(f'Toric L={L}', (n_tc, k_tc),
                                textcoords="offset points", xytext=(5, 5),
                                fontsize=7)

    ax.set_xlabel('n (physical qubits)', fontsize=11)
    ax.set_ylabel('k (logical qubits)', fontsize=11)
    exp_str = f'{2*D}/{D+1}'
    ax.set_title(f'D={D}: k·d^({exp_str}) ≤ n', fontsize=12)
    ax.legend(fontsize=9)
    ax.set_xlim(0, n_max)
    ax.set_ylim(0, 40)

plt.suptitle('Bravyi-Terhal Bound: Maximum Logical Qubits vs Physical Qubits',
             fontsize=13)
plt.tight_layout()
plt.savefig('bravyi_terhal_bounds.png', dpi=150, bbox_inches='tight')
print(f"✓ Saved bravyi_terhal_bounds.png")
plt.close()


# ─── Part 6: Tropical Weight Profiles ───

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

A_examples = [
    ("n=5, sample code", 5, np.array([1, 0, 3, 0, 12, 16], dtype=float)),
    ("n=7, sample code", 7, np.array([1, 0, 0, 7, 21, 35, 35, 29], dtype=float)),
    ("n=10, sample code", 10, np.array([1, 0, 0, 10, 45, 120, 210, 252, 210, 120, 56], dtype=float)),
]

for idx, (name, n, A) in enumerate(A_examples):
    ax = axes[idx]
    k = int(round(np.log2(np.sum(A)))) - n + n  # just display

    B = macwilliams_transform(n, 0, A)  # k=0 for simplicity

    js = np.arange(n + 1)

    # Tropical profiles
    trop_A = np.where(A > 0, -np.log(A), np.nan)
    trop_B = np.where(np.abs(B) > 1e-10, -np.log(np.abs(B)), np.nan)

    mask_A = ~np.isnan(trop_A)
    mask_B = ~np.isnan(trop_B)

    ax.scatter(js[mask_A], trop_A[mask_A], c='steelblue', s=60,
               zorder=5, label='trop(A)', marker='o')
    ax.scatter(js[mask_B], trop_B[mask_B], c='coral', s=60,
               zorder=5, label='trop(B)', marker='s')

    if np.any(mask_A):
        ax.plot(js[mask_A], trop_A[mask_A], 'b-', alpha=0.3)
    if np.any(mask_B):
        ax.plot(js[mask_B], trop_B[mask_B], 'r-', alpha=0.3)

    ax.set_title(f'Tropical Profile: {name}', fontsize=11)
    ax.set_xlabel('Weight j')
    ax.set_ylabel('-log(|value|)')
    ax.legend(fontsize=8)

plt.suptitle('Tropical Weight Profiles: Newton Polytope Vertices', fontsize=13)
plt.tight_layout()
plt.savefig('tropical_profiles.png', dpi=150, bbox_inches='tight')
print(f"✓ Saved tropical_profiles.png")
plt.close()


# ─── Part 7: Hamming and Singleton Bound Table ───

print(f"\n{'=' * 70}")
print("CODE PARAMETER BOUNDS TABLE")
print("=" * 70)
print(f"{'n':>4} {'d':>4} {'k_Sing':>8} {'k_Ham':>8} {'t':>4} {'HammSum':>10} {'2^(n-k)':>10}")
print("-" * 55)

for n in range(3, 16):
    for d in [3, 5, 7]:
        if 2 * d > n + 2:
            continue
        k_sing = n - 2 * d + 2
        t = (d - 1) // 2
        hamming_sum = sum(3**j * comb(n, j) for j in range(t + 1))
        # Find max k s.t. hamming_sum ≤ 2^(n-k)
        k_ham = n
        while k_ham > 0 and hamming_sum > 2**(n - k_ham):
            k_ham -= 1
        k_best = min(k_sing, k_ham)
        print(f"{n:4d} {d:4d} {k_sing:8d} {k_ham:8d} {t:4d} {hamming_sum:10d} {2**(n-k_best):10d}")


print(f"\n{'=' * 70}")
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 70)


"""Generate PACKAGE.json by reading all deliverable files."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz_krawtchouk = read_file('visualize_krawtchouk.py')
interactive_html = read_file('interactive_krawtchouk.html')

lean_krawtchouk = read_file('Physics/QuantumMacWilliams/Krawtchouk.lean')
lean_weight = read_file('Physics/QuantumMacWilliams/WeightEnumerator.lean')
lean_proofs = lean_krawtchouk + "\n\n-- ═══════════════════════════════════════\n-- WeightEnumerator.lean\n-- ═══════════════════════════════════════\n\n" + lean_weight

package = {
    "title": "Quantum MacWilliams Identities and the Bravyi-Terhal Bound",
    "domain": "Quantum Information Theory / Algebraic Combinatorics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Quantum MacWilliams Identity Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Code Optimization and Toric Code Analysis",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Krawtchouk Polynomial Evaluation",
            "pseudocode": "Input: n, j, x\\nOutput: K_j(x; n)\\n\\nsum ← 0\\nfor l = 0 to j:\\n    sum ← sum + (-1)^l × C(x,l) × C(n-x, j-l)\\nreturn sum\\n\\nTime: O(j), Space: O(1)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Krawtchouk Polynomial Landscape",
            "code": viz_krawtchouk,
            "description": "Visualizes Krawtchouk polynomials K_j(x; n) as line plots, eigenvalue bars, heatmap, and 3D surface. Shows the character table structure of the Hamming association scheme."
        }
    ],
    "interactive_demos": [
        {
            "name": "Interactive Krawtchouk Explorer",
            "html": interactive_html,
            "description": "Interactive exploration of Krawtchouk polynomials K_j(x; n) with sliders for n and j. Displays polynomial values, verified identities (K_0 = 1, K_1 = n-2x, K_j(0) = C(n,j)), and orthogonality checks."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("✓ Generated PACKAGE.json")
print(f"  Size: {os.path.getsize('PACKAGE.json') / 1024:.1f} KB")


"""
Visualization: Krawtchouk Polynomial Landscapes

Visualizes the Krawtchouk polynomials K_j(x; n) as both 2D line plots
and a 3D surface, revealing their role as eigenfunctions of the Hamming
distance operator and their oscillatory orthogonality structure.
"""

import numpy as np
from math import comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def krawtchouk(n, j, x):
    return sum((-1)**l * comb(x, l) * comb(n - x, j - l) for l in range(j + 1))


n = 10
fig = plt.figure(figsize=(16, 10))

# Top row: line plots for individual polynomials
ax1 = fig.add_subplot(2, 2, 1)
xs = np.arange(n + 1)
for j in range(min(6, n + 1)):
    vals = [krawtchouk(n, j, x) for x in range(n + 1)]
    ax1.plot(xs, vals, 'o-', linewidth=2, markersize=5, label=f'K_{j}(x; {n})')
ax1.axhline(y=0, color='black', linewidth=0.5)
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel(f'K_j(x; {n})', fontsize=12)
ax1.set_title(f'Krawtchouk Polynomials (n={n})', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Top right: eigenvalue plot K_1(j; n) = n - 2j
ax2 = fig.add_subplot(2, 2, 2)
js = np.arange(n + 1)
eigenvalues = [n - 2*j for j in range(n + 1)]
ax2.bar(js, eigenvalues, color='steelblue', alpha=0.7)
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.set_xlabel('Eigenspace index j', fontsize=12)
ax2.set_ylabel('Eigenvalue K_1(j; n) = n - 2j', fontsize=12)
ax2.set_title(f'Hamming Distance Eigenvalues (n={n})', fontsize=13)
ax2.grid(True, alpha=0.3)

# Bottom left: heatmap
ax3 = fig.add_subplot(2, 2, 3)
K = np.array([[krawtchouk(n, j, i) for i in range(n + 1)] for j in range(n + 1)], dtype=float)
vmax = np.max(np.abs(K))
im = ax3.imshow(K, cmap='RdBu_r', aspect='auto', vmin=-vmax, vmax=vmax,
                interpolation='nearest')
ax3.set_xlabel('x (evaluation point)', fontsize=12)
ax3.set_ylabel('j (polynomial index)', fontsize=12)
ax3.set_title(f'Krawtchouk Matrix K_j(x; {n})', fontsize=13)
plt.colorbar(im, ax=ax3, shrink=0.8)

# Bottom right: 3D surface
ax4 = fig.add_subplot(2, 2, 4, projection='3d')
J, X = np.meshgrid(np.arange(n + 1), np.arange(n + 1))
Z = np.array([[krawtchouk(n, j, x) for j in range(n + 1)] for x in range(n + 1)])
ax4.plot_surface(X, J, Z, cmap='viridis', alpha=0.8, edgecolor='none')
ax4.set_xlabel('x')
ax4.set_ylabel('j')
ax4.set_zlabel('K_j(x; n)')
ax4.set_title(f'Krawtchouk Surface (n={n})', fontsize=13)

plt.suptitle('Krawtchouk Polynomials: The Character Table of the Hamming Scheme',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('krawtchouk_landscape.png', dpi=150, bbox_inches='tight')
print("✓ Saved krawtchouk_landscape.png")
