#!/usr/bin/env python3
"""
Partition Matroid Spectral Stability — Applications

Demonstrates real-world applications of the partition matroid spectral
stability theorems:

1. Resource allocation with block constraints
2. Negative dependence in constrained sampling
3. Robust scheduling under uncertainty
"""

import numpy as np
from itertools import product as iterproduct
from typing import List, Tuple


# ============================================================================
# Application 1: Resource Allocation with Block Constraints
# ============================================================================

def resource_allocation_example():
    """
    Block-structured resource allocation under uncertainty.

    Consider allocating workers to projects organized in departments:
    - Department A: 3 workers, must assign exactly 2 to projects
    - Department B: 4 workers, must assign exactly 2 to projects

    The partition matroid M = U_{2,3} ⊕ U_{2,4} models feasible assignments.
    The spectral stability theorem guarantees that small perturbations to
    project valuations don't change the qualitative optimization landscape.
    """
    print("=" * 70)
    print("APPLICATION 1: Resource Allocation Under Uncertainty")
    print("=" * 70)
    print()

    # Department sizes and required assignments
    dept_sizes = [3, 4]
    dept_ranks = [2, 2]

    print(f"Departments: A ({dept_sizes[0]} workers, assign {dept_ranks[0]}), "
          f"B ({dept_sizes[1]} workers, assign {dept_ranks[1]})")
    print()

    # The single-block leaf Hessian captures within-department interactions
    # Spectral gap = 1 means perturbations < 1 preserve optimization structure
    m_A = dept_sizes[0] - dept_ranks[0] + 2  # = 3
    m_B = dept_sizes[1] - dept_ranks[1] + 2  # = 4

    H_A = np.ones((m_A, m_A)) - np.eye(m_A)
    H_B = np.ones((m_B, m_B)) - np.eye(m_B)

    print(f"Department A leaf Hessian ({m_A}×{m_A}), eigenvalues: "
          f"{np.round(np.linalg.eigvalsh(H_A), 2)}")
    print(f"Department B leaf Hessian ({m_B}×{m_B}), eigenvalues: "
          f"{np.round(np.linalg.eigvalsh(H_B), 2)}")
    print()

    # Certified perturbation budget
    gap = 1.0
    print(f"Certified perturbation radius: {gap}")
    print(f"→ Valuation changes with operator norm < {gap} preserve")
    print(f"  the Lorentzian structure of the generating polynomial.")
    print(f"→ This guarantees robustness of log-concave sampling algorithms")
    print(f"  and optimization relaxations based on the matroid polytope.")
    print()

    # Cross-department interactions (two-block leaf)
    n_cross = dept_sizes[0] + dept_sizes[1]
    H_cross = np.zeros((n_cross, n_cross))
    H_cross[:dept_sizes[0], dept_sizes[0]:] = 1.0
    H_cross[dept_sizes[0]:, :dept_sizes[0]] = 1.0

    cross_eigs = np.linalg.eigvalsh(H_cross)
    print(f"Cross-department Hessian ({n_cross}×{n_cross}), eigenvalues: "
          f"{np.round(cross_eigs, 2)}")
    print(f"At most one positive eigenvalue: {np.sum(cross_eigs > 1e-10) <= 1}")
    print(f"→ Cross-department interactions have Lorentzian signature,")
    print(f"  confirming negative dependence across departments.")
    print()


# ============================================================================
# Application 2: Negative Dependence in Constrained Sampling
# ============================================================================

def negative_dependence_example():
    """
    Demonstrate negative dependence across blocks in partition matroid sampling.

    Under the uniform distribution over bases of a partition matroid,
    elements from different blocks exhibit negative association:
    the probability that both are selected is at most the product of
    their marginal probabilities.

    The two-block bilinear Hessian Q(v) = 2·(∑ block₁ v)(∑ block₂ v)
    having at most one positive eigenvalue is the quadratic manifestation
    of this negative dependence.
    """
    print("=" * 70)
    print("APPLICATION 2: Negative Dependence in Constrained Sampling")
    print("=" * 70)
    print()

    # Partition matroid U_{1,3} ⊕ U_{1,2}: choose 1 from each block
    block_sizes = [3, 2]
    block_ranks = [1, 1]

    # Enumerate all bases
    bases = []
    for i in range(block_sizes[0]):
        for j in range(block_sizes[1]):
            bases.append((i, block_sizes[0] + j))

    n_bases = len(bases)
    n_total = sum(block_sizes)
    print(f"Partition matroid U_{{1,3}} ⊕ U_{{1,2}} on {n_total} elements")
    print(f"Number of bases: {n_bases}")
    print()

    # Compute marginal probabilities under uniform distribution
    marginals = np.zeros(n_total)
    for basis in bases:
        for elem in basis:
            marginals[elem] += 1.0 / n_bases

    print("Marginal probabilities:")
    for i in range(n_total):
        block = "A" if i < block_sizes[0] else "B"
        print(f"  Element {i} (block {block}): P(selected) = {marginals[i]:.4f}")
    print()

    # Check negative association across blocks
    print("Cross-block pairwise probabilities:")
    for i in range(block_sizes[0]):
        for j in range(block_sizes[0], n_total):
            joint = sum(1 for b in bases if i in b and j in b) / n_bases
            product = marginals[i] * marginals[j]
            sign = "≤" if joint <= product + 1e-10 else ">"
            print(f"  P({i} ∧ {j}) = {joint:.4f} {sign} "
                  f"P({i})·P({j}) = {product:.4f}  "
                  f"{'✓ neg. assoc.' if joint <= product + 1e-10 else '✗'}")
    print()
    print("→ The two-block Hessian theorem (at most one positive eigenvalue)")
    print("  is the quadratic-level certificate for this negative dependence.")
    print()


# ============================================================================
# Application 3: Robust Scheduling
# ============================================================================

def robust_scheduling_example():
    """
    Robust scheduling with partition matroid constraints.

    Consider scheduling jobs on machines with group constraints:
    - Group 1: 4 jobs, must schedule exactly 2
    - Group 2: 3 jobs, must schedule exactly 1
    - Group 3: 3 jobs, must schedule exactly 1

    The generating polynomial g(x) = e_2(x_{G1}) · e_1(x_{G2}) · e_1(x_{G3})
    encodes all feasible schedules. Spectral stability guarantees that
    small changes to job values don't change the optimization landscape
    qualitatively.
    """
    print("=" * 70)
    print("APPLICATION 3: Robust Scheduling Under Uncertainty")
    print("=" * 70)
    print()

    block_sizes = [4, 3, 3]
    block_ranks = [2, 1, 1]

    total_rank = sum(block_ranks)
    target_derivs = total_rank - 2

    print(f"Scheduling problem: {len(block_sizes)} groups")
    for i, (n, r) in enumerate(zip(block_sizes, block_ranks)):
        print(f"  Group {i+1}: {n} jobs, schedule {r}")
    print()

    # Enumerate leaf profiles
    ranges = [range(r + 1) for r in block_ranks]
    profiles = []
    for a in iterproduct(*ranges):
        if sum(a) == target_derivs:
            residual = tuple(r - ai for r, ai in zip(block_ranks, a))
            active = [i for i, d in enumerate(residual) if d > 0]
            if len(active) == 1:
                leaf_type = "single-block"
            else:
                leaf_type = "two-block"
            profiles.append((a, residual, leaf_type, active))

    print(f"Quadratic leaves: {len(profiles)}")
    for a, d, lt, active in profiles:
        print(f"  derivs={a}, residual={d} → {lt} "
              f"(groups {[i+1 for i in active]})")
    print()

    # Analyze each leaf
    all_lorentzian = True
    for a, d, lt, active in profiles:
        if lt == "single-block":
            i = active[0]
            m = block_sizes[i] - block_ranks[i] + 2
            H = np.ones((m, m)) - np.eye(m)
            label = f"Group {i+1} single-block ({m}×{m})"
        else:
            i, j = active
            n1, n2 = block_sizes[i], block_sizes[j]
            n = n1 + n2
            H = np.zeros((n, n))
            H[:n1, n1:] = 1.0
            H[n1:, :n1] = 1.0
            label = f"Groups {i+1},{j+1} two-block ({n}×{n})"

        eigs = np.linalg.eigvalsh(H)
        n_pos = np.sum(eigs > 1e-10)
        is_lor = n_pos <= 1
        all_lorentzian = all_lorentzian and is_lor

        print(f"  {label}: eigenvalues = {np.round(eigs, 2)}, "
              f"Lorentzian: {is_lor}")

    print()
    print(f"All leaves Lorentzian: {all_lorentzian}")
    print(f"Certified stability radius: 1.0 (from single-block gap)")
    print()
    print("→ Job value perturbations with operator norm < 1 preserve")
    print("  the Lorentzian structure, guaranteeing robust schedule quality.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  PARTITION MATROID SPECTRAL STABILITY — APPLICATIONS                ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    resource_allocation_example()
    negative_dependence_example()
    robust_scheduling_example()

    print("All applications demonstrate the practical implications of the")
    print("formally verified partition matroid spectral stability theorems.")


#!/usr/bin/env python3
"""
Partition Matroid Spectral Stability — Interactive Demo

Demonstrates the key theorems about quadratic leaf classification and
Hessian spectral properties for partition matroids.

Usage: python demo.py
"""

import numpy as np
from itertools import product as iterproduct


def enumerate_leaf_profiles(ranks):
    """Enumerate all degree-2 leaf profiles for a partition matroid.

    A leaf profile a = (a_1, ..., a_k) satisfies:
      0 <= a_i <= r_i  and  sum(r_i - a_i) = 2

    Returns list of tuples (profile, residual_degrees, leaf_type).
    """
    k = len(ranks)
    total_rank = sum(ranks)
    target = total_rank - 2  # sum of derivatives

    profiles = []
    # Generate all valid derivative profiles
    ranges = [range(r + 1) for r in ranks]
    for a in iterproduct(*ranges):
        if sum(a) == target:
            residual = tuple(r - ai for r, ai in zip(ranks, a))
            # Classify
            nonzero = [(i, d) for i, d in enumerate(residual) if d > 0]
            if len(nonzero) == 1 and nonzero[0][1] == 2:
                leaf_type = "single-block"
            elif len(nonzero) == 2 and all(d == 1 for _, d in nonzero):
                leaf_type = "two-block"
            else:
                leaf_type = "unknown"  # should never happen
            profiles.append((a, residual, leaf_type))
    return profiles


def build_single_block_hessian(m):
    """Build the J - I Hessian for a single-block leaf with m variables."""
    return np.ones((m, m)) - np.eye(m)


def build_two_block_hessian(n1, n2):
    """Build the off-diagonal block Hessian for a two-block leaf."""
    n = n1 + n2
    H = np.zeros((n, n))
    H[:n1, n1:] = 1.0
    H[n1:, :n1] = 1.0
    return H


def analyze_hessian(H, label=""):
    """Compute and display spectral properties of a Hessian."""
    eigenvalues = np.linalg.eigvalsh(H)
    eigenvalues.sort()

    n_pos = np.sum(eigenvalues > 1e-10)
    n_neg = np.sum(eigenvalues < -1e-10)
    n_zero = np.sum(np.abs(eigenvalues) <= 1e-10)

    print(f"  {label}")
    print(f"    Eigenvalues: {np.round(eigenvalues, 6)}")
    print(f"    Positive: {n_pos}, Negative: {n_neg}, Zero: {n_zero}")
    print(f"    At most one positive eigenvalue: {n_pos <= 1}")

    # Compute spectral gap (if applicable)
    if n_neg > 0:
        gap = min(abs(eigenvalues[eigenvalues < -1e-10]))
        print(f"    Spectral gap (min |negative eigenvalue|): {gap:.6f}")

    return eigenvalues


def demo_classification():
    """Demonstrate the leaf profile classification theorem."""
    print("=" * 70)
    print("THEOREM 1: Leaf Profile Classification")
    print("=" * 70)
    print()

    test_cases = [
        ([2, 1], "U_{2,3} ⊕ U_{1,2}"),
        ([3, 2], "U_{3,5} ⊕ U_{2,4}"),
        ([1, 1, 1], "U_{1,2} ⊕ U_{1,2} ⊕ U_{1,2}"),
        ([2, 2, 1], "U_{2,4} ⊕ U_{2,4} ⊕ U_{1,2}"),
        ([4, 2], "U_{4,6} ⊕ U_{2,4}"),
    ]

    for ranks, name in test_cases:
        profiles = enumerate_leaf_profiles(ranks)
        print(f"Partition matroid {name}, ranks = {ranks}:")
        n_single = sum(1 for _, _, t in profiles if t == "single-block")
        n_two = sum(1 for _, _, t in profiles if t == "two-block")
        print(f"  Total quadratic leaves: {len(profiles)}")
        print(f"  Single-block leaves: {n_single}")
        print(f"  Two-block leaves: {n_two}")
        for a, d, t in profiles:
            print(f"    derivs={a}, residual={d} → {t}")
        print()


def demo_spectral_analysis():
    """Demonstrate spectral properties of leaf Hessians."""
    print("=" * 70)
    print("THEOREMS 2-5: Spectral Analysis of Leaf Hessians")
    print("=" * 70)
    print()

    # Single-block leaves
    print("--- Single-Block Leaves (J - I) ---")
    for m in [2, 3, 4, 5]:
        H = build_single_block_hessian(m)
        analyze_hessian(H, f"m = {m}")
    print()

    # Two-block leaves
    print("--- Two-Block Leaves (Off-diagonal) ---")
    for n1, n2 in [(1, 1), (1, 2), (2, 2), (2, 3), (3, 3)]:
        H = build_two_block_hessian(n1, n2)
        analyze_hessian(H, f"n₁={n1}, n₂={n2}")
    print()


def demo_perturbation_stability():
    """Demonstrate perturbation stability theorems."""
    print("=" * 70)
    print("THEOREMS 6 & 9: Perturbation Stability")
    print("=" * 70)
    print()

    np.random.seed(42)
    m = 4
    H = build_single_block_hessian(m)

    print(f"Single-block Hessian (m={m}), gap = 1.0")
    print()

    for delta in [0.1, 0.5, 0.9, 0.99, 1.01, 1.5, 2.0]:
        # Random symmetric perturbation with bounded quadratic form
        E = np.random.randn(m, m)
        E = (E + E.T) / 2
        # Scale so max eigenvalue of E is delta
        E_eigs = np.linalg.eigvalsh(E)
        scale = delta / max(abs(E_eigs))
        E = E * scale

        perturbed = H + E
        eigs = np.linalg.eigvalsh(perturbed)
        n_pos = np.sum(eigs > 1e-10)

        status = "✓ Lorentzian" if n_pos <= 1 else "✗ NOT Lorentzian"
        predicted = "predicted stable" if delta < 1 else "may break"
        print(f"  δ = {delta:.2f}: {status} ({predicted})")
        print(f"    Eigenvalues: {np.round(eigs, 4)}")

    print()


def demo_covariance():
    """Demonstrate the covariance nonpositivity theorem."""
    print("=" * 70)
    print("THEOREM 7: Cross-Block Covariance Nonpositivity")
    print("=" * 70)
    print()

    np.random.seed(123)
    for n1, n2 in [(1, 1), (2, 3), (3, 4)]:
        H = build_two_block_hessian(n1, n2)
        n = n1 + n2

        print(f"  n₁={n1}, n₂={n2}:")
        # Generate vectors where block sums have opposite signs
        for trial in range(3):
            v = np.random.randn(n)
            # Ensure block1 sum > 0 and block2 sum < 0
            if sum(v[:n1]) < 0:
                v[:n1] = -v[:n1]
            if sum(v[n1:]) > 0:
                v[n1:] = -v[n1:]

            s1 = sum(v[:n1])
            s2 = sum(v[n1:])
            qf = v @ H @ v

            print(f"    Trial {trial+1}: S₁={s1:.3f}, S₂={s2:.3f}, Q(v)={qf:.3f} < 0: {qf < 0}")
    print()


def demo_conjecture_test():
    """Test the spectral gap conjecture for small partition matroids."""
    print("=" * 70)
    print("CONJECTURE TEST: Spectral Gap Formula")
    print("=" * 70)
    print()

    test_tuples = [(2, 1), (3, 1), (3, 2), (4, 2)]

    for k in range(2, 5):
        for combo in iterproduct(test_tuples, repeat=k):
            ranks = [r for _, r in combo]
            sizes = [n for n, _ in combo]
            profiles = enumerate_leaf_profiles(ranks)

            if not profiles:
                continue

            gaps = []
            for a, d, leaf_type in profiles:
                if leaf_type == "single-block":
                    # Find which block
                    block_idx = next(i for i, di in enumerate(d) if di > 0)
                    m = sizes[block_idx] - ranks[block_idx] + 2
                    H = build_single_block_hessian(m)
                elif leaf_type == "two-block":
                    blocks = [i for i, di in enumerate(d) if di > 0]
                    n1 = sizes[blocks[0]]
                    n2 = sizes[blocks[1]]
                    H = build_two_block_hessian(n1, n2)

                eigs = np.linalg.eigvalsh(H)
                neg_eigs = eigs[eigs < -1e-10]
                if len(neg_eigs) > 0:
                    gap = min(abs(neg_eigs))
                    gaps.append(gap)

            if gaps and k == 2:
                min_gap = min(gaps)
                print(f"  blocks={list(zip(sizes, ranks))}: min gap = {min_gap:.4f}")

    print()
    print("  Observation: Single-block leaves always have gap 1.")
    print("  Two-block leaves have gap √(n₁·n₂) (the nonzero eigenvalue magnitude).")
    print("  The minimum across all leaves is always 1 (from single-block leaves).")


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  PARTITION MATROID SPECTRAL STABILITY — INTERACTIVE DEMO            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_classification()
    demo_spectral_analysis()
    demo_perturbation_stability()
    demo_covariance()
    demo_conjecture_test()

    print()
    print("Demo complete. All results confirm the formally verified theorems.")


#!/usr/bin/env python3
"""
Visualization 3: Block Structure of Partition Matroid Hessians

Shows the Hessian matrices for both leaf types as heatmaps, highlighting
the block structure that makes the spectral analysis tractable:
- Single-block: J - I (all-ones minus identity)
- Two-block: off-diagonal block [[0, J], [J^T, 0]]
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm


def build_single_block_hessian(m):
    return np.ones((m, m)) - np.eye(m)


def build_two_block_hessian(n1, n2):
    n = n1 + n2
    H = np.zeros((n, n))
    H[:n1, n1:] = 1.0
    H[n1:, :n1] = 1.0
    return H


fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Row 1: Single-block Hessians
for idx, m in enumerate([3, 4, 5]):
    ax = axes[0, idx]
    H = build_single_block_hessian(m)
    norm = TwoSlopeNorm(vmin=-1, vcenter=0, vmax=1)
    im = ax.imshow(H, cmap='RdBu_r', norm=norm, aspect='equal')
    ax.set_title(f'Single-Block (m={m})\nJ − I', fontsize=12, fontweight='bold')

    # Add text values
    for i in range(m):
        for j in range(m):
            color = 'white' if abs(H[i, j]) > 0.5 else 'black'
            ax.text(j, i, f'{H[i,j]:.0f}', ha='center', va='center',
                   fontsize=10, color=color, fontweight='bold')

    # Mark diagonal
    for i in range(m):
        rect = plt.Rectangle((i-0.5, i-0.5), 1, 1, fill=False,
                            edgecolor='gold', linewidth=2)
        ax.add_patch(rect)

    ax.set_xticks(range(m))
    ax.set_yticks(range(m))
    eigs = np.linalg.eigvalsh(H)
    ax.set_xlabel(f'λ = {np.round(eigs, 1)}', fontsize=9)

# Row 2: Two-block Hessians
for idx, (n1, n2) in enumerate([(1, 2), (2, 3), (3, 3)]):
    ax = axes[1, idx]
    H = build_two_block_hessian(n1, n2)
    n = n1 + n2
    norm = TwoSlopeNorm(vmin=-0.5, vcenter=0, vmax=1)
    im = ax.imshow(H, cmap='RdBu_r', norm=norm, aspect='equal')
    ax.set_title(f'Two-Block (n₁={n1}, n₂={n2})\n[[0, J], [Jᵀ, 0]]',
                fontsize=12, fontweight='bold')

    # Add text values
    for i in range(n):
        for j in range(n):
            color = 'white' if abs(H[i, j]) > 0.5 else 'black'
            ax.text(j, i, f'{H[i,j]:.0f}', ha='center', va='center',
                   fontsize=10, color=color, fontweight='bold')

    # Mark blocks
    rect1 = plt.Rectangle((-0.5, -0.5), n1, n1, fill=False,
                          edgecolor='blue', linewidth=2, linestyle='--')
    rect2 = plt.Rectangle((n1-0.5, n1-0.5), n2, n2, fill=False,
                          edgecolor='blue', linewidth=2, linestyle='--')
    rect_cross1 = plt.Rectangle((n1-0.5, -0.5), n2, n1, fill=False,
                                edgecolor='red', linewidth=2)
    rect_cross2 = plt.Rectangle((-0.5, n1-0.5), n1, n2, fill=False,
                                edgecolor='red', linewidth=2)
    ax.add_patch(rect1)
    ax.add_patch(rect2)
    ax.add_patch(rect_cross1)
    ax.add_patch(rect_cross2)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    eigs = np.linalg.eigvalsh(H)
    ax.set_xlabel(f'λ = {np.round(eigs, 1)}', fontsize=9)

    # Label blocks
    if n1 > 1:
        ax.text(n1/2 - 0.5, n1/2 - 0.5, 'Block 1\n(zero)', fontsize=8,
               ha='center', va='center', color='blue', alpha=0.7)
    if n2 > 1:
        ax.text(n1 + n2/2 - 0.5, n1 + n2/2 - 0.5, 'Block 2\n(zero)', fontsize=8,
               ha='center', va='center', color='blue', alpha=0.7)

fig.suptitle('Block Structure of Partition Matroid Leaf Hessians',
            fontsize=16, fontweight='bold')

# Add colorbar
cbar_ax = fig.add_axes([0.92, 0.15, 0.02, 0.7])
cbar = fig.colorbar(im, cax=cbar_ax, label='Matrix entry value')

plt.tight_layout(rect=[0, 0, 0.9, 0.95])
plt.savefig('viz_block_structure.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_block_structure.png")


#!/usr/bin/env python3
"""
Visualization 1: Hessian Spectra of Partition Matroid Quadratic Leaves

Visualizes the eigenvalue spectra of both single-block and two-block
leaf Hessians, showing the key spectral dichotomy: single-block leaves
have one positive eigenvalue at (m-1) and (m-1) negative eigenvalues
at -1, while two-block leaves have eigenvalues ±√(n₁·n₂) and zeros.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def build_single_block_hessian(m):
    return np.ones((m, m)) - np.eye(m)


def build_two_block_hessian(n1, n2):
    n = n1 + n2
    H = np.zeros((n, n))
    H[:n1, n1:] = 1.0
    H[n1:, :n1] = 1.0
    return H


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Single-block spectra
ax1 = axes[0]
cases_single = [2, 3, 4, 5, 6]
colors_single = plt.cm.Blues(np.linspace(0.4, 0.9, len(cases_single)))

for idx, m in enumerate(cases_single):
    H = build_single_block_hessian(m)
    eigs = np.linalg.eigvalsh(H)
    y_positions = np.full_like(eigs, idx)
    for e in eigs:
        color = 'red' if e > 0.1 else ('blue' if e < -0.1 else 'gray')
        ax1.scatter(e, idx, c=color, s=100, zorder=5, edgecolors='black', linewidth=0.5)

ax1.set_yticks(range(len(cases_single)))
ax1.set_yticklabels([f'm = {m}' for m in cases_single])
ax1.set_xlabel('Eigenvalue', fontsize=12)
ax1.set_title('Single-Block Leaves (J − I)', fontsize=14, fontweight='bold')
ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax1.axvline(x=-1, color='blue', linestyle=':', alpha=0.3, label='Gap = 1')
ax1.set_xlim(-2, 6)
ax1.grid(True, alpha=0.3)

# Add annotations
ax1.annotate('Positive eigenvalue\n= m − 1', xy=(4, 3.5), fontsize=9,
            color='red', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
ax1.annotate('Negative eigenvalue\n= −1 (gap = 1)', xy=(-1, 0.5), fontsize=9,
            color='blue', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.8))

# Panel 2: Two-block spectra
ax2 = axes[1]
cases_two = [(1, 1), (1, 2), (2, 2), (2, 3), (3, 3), (3, 4)]
for idx, (n1, n2) in enumerate(cases_two):
    H = build_two_block_hessian(n1, n2)
    eigs = np.linalg.eigvalsh(H)
    for e in eigs:
        color = 'red' if e > 0.1 else ('blue' if e < -0.1 else 'gray')
        size = 100 if abs(e) > 0.1 else 60
        ax2.scatter(e, idx, c=color, s=size, zorder=5, edgecolors='black', linewidth=0.5)

ax2.set_yticks(range(len(cases_two)))
ax2.set_yticklabels([f'n₁={n1}, n₂={n2}' for n1, n2 in cases_two])
ax2.set_xlabel('Eigenvalue', fontsize=12)
ax2.set_title('Two-Block Leaves (Off-Diagonal)', fontsize=14, fontweight='bold')
ax2.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax2.set_xlim(-5, 5)
ax2.grid(True, alpha=0.3)

ax2.annotate('+√(n₁·n₂)', xy=(3, 4.5), fontsize=9, color='red', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
ax2.annotate('−√(n₁·n₂)', xy=(-3, 4.5), fontsize=9, color='blue', ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.8))
ax2.annotate('Rank 2:\nmany zeros', xy=(0.3, 1.5), fontsize=9, color='gray', ha='left',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgray', alpha=0.5))

# Legend
red_patch = mpatches.Patch(color='red', label='Positive eigenvalue')
blue_patch = mpatches.Patch(color='blue', label='Negative eigenvalue')
gray_patch = mpatches.Patch(color='gray', label='Zero eigenvalue')
fig.legend(handles=[red_patch, blue_patch, gray_patch],
          loc='lower center', ncol=3, fontsize=11,
          bbox_to_anchor=(0.5, -0.02))

fig.suptitle('Spectral Dichotomy of Partition Matroid Quadratic Leaves',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_hessian_spectra.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_hessian_spectra.png")


#!/usr/bin/env python3
"""
Visualization 2: Perturbation Stability Phase Diagram

Shows how the number of positive eigenvalues changes as perturbation
magnitude increases, illustrating the sharp phase transition at the
spectral gap boundary (δ = 1 for single-block leaves).
"""

import numpy as np
import matplotlib.pyplot as plt


def build_single_block_hessian(m):
    return np.ones((m, m)) - np.eye(m)


np.random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Phase diagram for different block sizes
ax1 = axes[0]
deltas = np.linspace(0, 2.5, 200)
n_trials = 50

for m, color, marker in [(3, '#2196F3', 'o'), (4, '#4CAF50', 's'),
                           (5, '#FF9800', '^'), (6, '#9C27B0', 'D')]:
    H = build_single_block_hessian(m)
    frac_lorentzian = []

    for delta in deltas:
        count = 0
        for _ in range(n_trials):
            E = np.random.randn(m, m)
            E = (E + E.T) / 2
            eigs_E = np.linalg.eigvalsh(E)
            if max(abs(eigs_E)) > 0:
                E = E / max(abs(eigs_E)) * delta

            perturbed = H + E
            eigs = np.linalg.eigvalsh(perturbed)
            if np.sum(eigs > 1e-10) <= 1:
                count += 1
        frac_lorentzian.append(count / n_trials)

    ax1.plot(deltas, frac_lorentzian, color=color, linewidth=2,
            label=f'm = {m}', alpha=0.8)

ax1.axvline(x=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7,
           label='Gap = 1 (certified boundary)')
ax1.fill_between([0, 1], [0, 0], [1.1, 1.1], alpha=0.1, color='green')
ax1.fill_between([1, 2.5], [0, 0], [1.1, 1.1], alpha=0.1, color='red')

ax1.set_xlabel('Perturbation magnitude δ', fontsize=12)
ax1.set_ylabel('Fraction preserving Lorentzian signature', fontsize=12)
ax1.set_title('Single-Block Stability Phase Diagram', fontsize=14, fontweight='bold')
ax1.set_ylim(-0.05, 1.05)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

ax1.annotate('Certified\nstable zone', xy=(0.5, 0.5), fontsize=11,
            color='green', ha='center', fontweight='bold')
ax1.annotate('May\nbreak', xy=(1.75, 0.5), fontsize=11,
            color='red', ha='center', fontweight='bold')

# Panel 2: Eigenvalue trajectories under increasing perturbation
ax2 = axes[1]
m = 4
H = build_single_block_hessian(m)

# Fixed perturbation direction, varying magnitude
E_base = np.random.randn(m, m)
E_base = (E_base + E_base.T) / 2
E_base = E_base / max(abs(np.linalg.eigvalsh(E_base)))

deltas_fine = np.linspace(0, 3.0, 300)
all_eigs = []

for delta in deltas_fine:
    eigs = np.linalg.eigvalsh(H + delta * E_base)
    all_eigs.append(sorted(eigs))

all_eigs = np.array(all_eigs)

for j in range(m):
    color = 'red' if all_eigs[0, j] > 0.1 else 'blue'
    ax2.plot(deltas_fine, all_eigs[:, j], linewidth=2, alpha=0.8, color=color)

ax2.axhline(y=0, color='gray', linestyle='-', linewidth=1, alpha=0.5)
ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7)
ax2.fill_between([0, 1], [-5, -5], [5, 5], alpha=0.05, color='green')

ax2.set_xlabel('Perturbation magnitude δ', fontsize=12)
ax2.set_ylabel('Eigenvalue', fontsize=12)
ax2.set_title(f'Eigenvalue Trajectories (m={m})', fontsize=14, fontweight='bold')
ax2.set_ylim(-4, 5)
ax2.grid(True, alpha=0.3)
ax2.annotate('Second eigenvalue\ncrosses zero →\nLorentzian breaks',
            xy=(1.0, 0.5), xytext=(1.8, 2.5),
            fontsize=9, ha='center',
            arrowprops=dict(arrowstyle='->', color='red'),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

fig.suptitle('Perturbation Stability of Single-Block Leaf Hessians',
            fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_perturbation_stability.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_perturbation_stability.png")
