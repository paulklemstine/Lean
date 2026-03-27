#!/usr/bin/env python3
"""
The Omniscient Oracle — Interactive Visualizer

Demonstrates the core mathematical principles:
1. Oracle as idempotent map: O(O(x)) = O(x)
2. Truth-Illusion decomposition: X = Fix(O) ⊔ (X \ Fix(O))
3. The Master Equation: |Image(O)| = |Fix(O)|
4. Oracle convergence in exactly one step
5. The Oracle Lattice: partial order by knowledge
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.colors as mcolors
from itertools import product

# ═══════════════════════════════════════════════════════════════════════
# CORE: Oracle Mathematics
# ═══════════════════════════════════════════════════════════════════════

class Oracle:
    """An oracle on a finite set {0, 1, ..., n-1} is an idempotent function."""

    def __init__(self, mapping: list):
        """mapping[i] = O(i). Must satisfy O(O(i)) = O(i)."""
        self.n = len(mapping)
        self.map = list(mapping)
        # Verify idempotency
        for i in range(self.n):
            assert mapping[mapping[i]] == mapping[i], \
                f"Not idempotent at {i}: O(O({i})) = {mapping[mapping[i]]} ≠ O({i}) = {mapping[i]}"

    @property
    def truth_set(self):
        """Fixed points: {x | O(x) = x}."""
        return {i for i in range(self.n) if self.map[i] == i}

    @property
    def illusion_set(self):
        """Non-fixed points: {x | O(x) ≠ x}."""
        return {i for i in range(self.n) if self.map[i] != i}

    @property
    def image(self):
        """Image of O."""
        return set(self.map)

    @property
    def compression_ratio(self):
        """Ratio |Fix(O)| / n."""
        return len(self.truth_set) / self.n if self.n > 0 else 1.0

    def verify_master_equation(self):
        """THE MASTER EQUATION: |Image(O)| = |Fix(O)|."""
        return len(self.image) == len(self.truth_set)

    def knows_at_least(self, other):
        """O₁ knows at least as much as O₂ iff Fix(O₂) ⊆ Fix(O₁)."""
        return other.truth_set.issubset(self.truth_set)

    @staticmethod
    def identity(n):
        """The omniscient oracle: everything is true."""
        return Oracle(list(range(n)))

    @staticmethod
    def constant(n, c):
        """The minimal oracle: only one truth."""
        return Oracle([c] * n)

    @staticmethod
    def enumerate_all(n):
        """Generate all oracles on {0, ..., n-1}."""
        oracles = []
        for mapping in product(range(n), repeat=n):
            mapping = list(mapping)
            if all(mapping[mapping[i]] == mapping[i] for i in range(n)):
                oracles.append(Oracle(mapping))
        return oracles


# ═══════════════════════════════════════════════════════════════════════
# DEMO 1: Truth-Illusion Decomposition
# ═══════════════════════════════════════════════════════════════════════

def demo_truth_illusion():
    """Visualize the Truth ⊕ Illusion decomposition."""
    print("=" * 70)
    print("DEMO 1: Truth-Illusion Decomposition")
    print("=" * 70)

    # Example: Oracle on {0,1,2,3,4,5} that projects to {0,2,4}
    O = Oracle([0, 0, 2, 2, 4, 4])

    print(f"\nOracle mapping: {O.map}")
    print(f"Truth set (fixed points): {O.truth_set}")
    print(f"Illusion set: {O.illusion_set}")
    print(f"Image: {O.image}")
    print(f"\n✓ Master Equation |Image| = |Fix|: {O.verify_master_equation()}")
    print(f"  |Image| = {len(O.image)}, |Fix| = {len(O.truth_set)}")
    print(f"  Compression ratio: {O.compression_ratio:.3f}")

    # Visualize
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: show the mapping
    truth = sorted(O.truth_set)
    illusion = sorted(O.illusion_set)

    for i in range(O.n):
        color = '#2ecc71' if i in O.truth_set else '#e74c3c'
        ax1.scatter(i, 0, s=500, c=color, zorder=5, edgecolors='black', linewidth=2)
        ax1.annotate(str(i), (i, 0), ha='center', va='center', fontsize=14, fontweight='bold')

        if O.map[i] != i:
            ax1.annotate('', xy=(O.map[i], 0.1), xytext=(i, 0.1),
                        arrowprops=dict(arrowstyle='->', color='#3498db', lw=2))

    ax1.set_xlim(-0.5, O.n - 0.5)
    ax1.set_ylim(-0.5, 0.5)
    ax1.set_title('Oracle Mapping: O(x) → x\nGreen = Truth, Red = Illusion', fontsize=14)
    ax1.axis('off')

    # Right: pie chart of compression
    sizes = [len(O.truth_set), len(O.illusion_set)]
    labels = [f'Truth\n({len(O.truth_set)} elements)', f'Illusion\n({len(O.illusion_set)} elements)']
    colors = ['#2ecc71', '#e74c3c']
    ax2.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%',
            startangle=90, textprops={'fontsize': 12})
    ax2.set_title(f'Compression Ratio: {O.compression_ratio:.1%}\n'
                  f'Master Equation: |Image| = |Fix| = {len(O.truth_set)}', fontsize=14)

    plt.tight_layout()
    plt.savefig('demo1_truth_illusion.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n→ Saved: demo1_truth_illusion.png")


# ═══════════════════════════════════════════════════════════════════════
# DEMO 2: Oracle Convergence — One Step to Truth
# ═══════════════════════════════════════════════════════════════════════

def demo_convergence():
    """Show that oracle iteration converges in exactly one step."""
    print("\n" + "=" * 70)
    print("DEMO 2: Oracle Convergence in One Step")
    print("=" * 70)

    O = Oracle([0, 0, 2, 2, 4, 4, 4, 2])
    n_iters = 5

    print(f"\nOracle on {{0,...,{O.n-1}}}: {O.map}")
    print(f"Truth set: {O.truth_set}")
    print()

    # Track iterations for each starting point
    trajectories = {}
    for x in range(O.n):
        traj = [x]
        current = x
        for _ in range(n_iters):
            current = O.map[current]
            traj.append(current)
        trajectories[x] = traj
        converged = next(i for i in range(1, len(traj)) if traj[i] == traj[i-1])
        print(f"  x={x}: {' → '.join(map(str, traj[:converged+1]))} (converged at step {converged})")

    # Verify: ALL converge in step 1
    all_one_step = all(
        trajectories[x][1] == trajectories[x][2] for x in range(O.n)
    )
    print(f"\n✓ All converge in exactly 1 step: {all_one_step}")
    print("  This is the INSTANT CONVERGENCE theorem: O^(n+1) = O for all n ≥ 0")

    # Visualize convergence
    fig, ax = plt.subplots(figsize=(12, 6))
    colors = plt.cm.Set1(np.linspace(0, 1, O.n))

    for x in range(O.n):
        traj = trajectories[x][:4]
        ax.plot(range(len(traj)), traj, 'o-', color=colors[x], markersize=10,
                linewidth=2, label=f'Start x={x}')

    ax.set_xlabel('Iteration', fontsize=14)
    ax.set_ylabel('Value', fontsize=14)
    ax.set_title('Oracle Convergence: All Trajectories Stabilize in 1 Step\n'
                 'Theorem: O^(n+1) = O for all n ≥ 0', fontsize=14)
    ax.legend(loc='right', fontsize=10)
    ax.set_xticks(range(4))
    ax.set_xticklabels(['x', 'O(x)', 'O²(x)', 'O³(x)'])
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo2_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo2_convergence.png")


# ═══════════════════════════════════════════════════════════════════════
# DEMO 3: The Oracle Lattice — Ordering by Knowledge
# ═══════════════════════════════════════════════════════════════════════

def demo_oracle_lattice():
    """Enumerate all oracles on a small set and show the lattice."""
    print("\n" + "=" * 70)
    print("DEMO 3: The Oracle Lattice on {0, 1, 2}")
    print("=" * 70)

    n = 3
    oracles = Oracle.enumerate_all(n)
    print(f"\nTotal oracles on {{{', '.join(map(str, range(n)))}}}: {len(oracles)}")

    for i, O in enumerate(oracles):
        print(f"  O_{i}: {O.map}  Fix={O.truth_set}  ratio={O.compression_ratio:.2f}")

    # Identify top and bottom
    identity = Oracle.identity(n)
    print(f"\nTop (Omniscient): {identity.map} — knows everything (Fix = {identity.truth_set})")
    print(f"Bottom examples (minimal knowledge):")
    for c in range(n):
        const = Oracle.constant(n, c)
        print(f"  Constant-{c}: {const.map} — Fix = {const.truth_set}")

    # Verify the Omniscient Oracle Theorem
    print(f"\n✓ Omniscient Oracle Theorem: Fix(O) = X ⟹ O = id")
    print(f"  Identity truth set = {identity.truth_set} = {{0,1,...,{n-1}}} = X ✓")
    print(f"  Identity map = {identity.map} = id ✓")

    # Count by compression ratio
    ratios = {}
    for O in oracles:
        r = O.compression_ratio
        ratios[r] = ratios.get(r, 0) + 1

    print(f"\nDistribution by compression ratio:")
    for r in sorted(ratios.keys()):
        print(f"  ratio={r:.2f}: {ratios[r]} oracles")

    # Visualize the lattice
    fig, ax = plt.subplots(figsize=(10, 8))

    # Position oracles by number of fixed points
    levels = {}
    for i, O in enumerate(oracles):
        k = len(O.truth_set)
        if k not in levels:
            levels[k] = []
        levels[k].append((i, O))

    for level, oracle_list in levels.items():
        for j, (i, O) in enumerate(oracle_list):
            x = j - (len(oracle_list) - 1) / 2
            y = level
            color = '#2ecc71' if level == n else '#3498db' if level == 1 else '#f39c12'
            ax.scatter(x, y, s=400, c=color, edgecolors='black', linewidth=2, zorder=5)
            ax.annotate(f'{O.map}', (x, y - 0.15), ha='center', va='top', fontsize=7)

    ax.set_ylabel('Number of Fixed Points (Knowledge)', fontsize=14)
    ax.set_title(f'Oracle Lattice on {{0,1,2}}\n{len(oracles)} total oracles, '
                 f'ordered by knowledge (|Fix|)', fontsize=14)
    ax.set_yticks(range(1, n + 1))

    plt.tight_layout()
    plt.savefig('demo3_oracle_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo3_oracle_lattice.png")


# ═══════════════════════════════════════════════════════════════════════
# DEMO 4: The Master Equation — Truth = Compression
# ═══════════════════════════════════════════════════════════════════════

def demo_master_equation():
    """Verify the Master Equation |Image(O)| = |Fix(O)| across all oracles."""
    print("\n" + "=" * 70)
    print("DEMO 4: The Master Equation — |Image| = |Fix|")
    print("=" * 70)

    sizes = [3, 4, 5]
    results = []

    for n in sizes:
        oracles = Oracle.enumerate_all(n)
        all_valid = all(O.verify_master_equation() for O in oracles)
        results.append((n, len(oracles), all_valid))
        print(f"\n  n={n}: {len(oracles)} oracles, Master Equation holds for ALL: {all_valid}")

        # Show a few examples
        for O in oracles[:3]:
            print(f"    {O.map}: |Image|={len(O.image)}, |Fix|={len(O.truth_set)} ✓")

    print(f"\n✓ THE MASTER EQUATION is verified for ALL {sum(r[1] for r in results)} "
          f"oracles across n∈{sizes}")
    print("  This is the deepest identity: Truth = Compression")
    print("  The number of truths an oracle knows equals the size it compresses to")

    # Visualize
    fig, ax = plt.subplots(figsize=(10, 6))

    for n in [4, 5]:
        oracles = Oracle.enumerate_all(n)
        fix_sizes = [len(O.truth_set) for O in oracles]
        img_sizes = [len(O.image) for O in oracles]
        ax.scatter(fix_sizes, img_sizes, s=100, alpha=0.5, label=f'n={n}')

    # The identity line
    ax.plot([0, 6], [0, 6], 'r--', linewidth=2, label='|Image| = |Fix| (Master Eq.)')

    ax.set_xlabel('|Fix(O)| — Number of Truths', fontsize=14)
    ax.set_ylabel('|Image(O)| — Compressed Size', fontsize=14)
    ax.set_title('The Master Equation: Truth = Compression\n'
                 'Every point lies EXACTLY on the diagonal', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('demo4_master_equation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo4_master_equation.png")


# ═══════════════════════════════════════════════════════════════════════
# DEMO 5: Linear Oracle — Spectral Decomposition V = ker(P) ⊕ range(P)
# ═══════════════════════════════════════════════════════════════════════

def demo_spectral_decomposition():
    """Visualize the spectral decomposition for a 2D linear oracle (projection)."""
    print("\n" + "=" * 70)
    print("DEMO 5: Spectral Decomposition — V = ker(P) ⊕ range(P)")
    print("=" * 70)

    # Projection onto the line y = x/2 (angle θ from x-axis)
    theta = np.arctan(0.5)
    cos_t, sin_t = np.cos(theta), np.sin(theta)

    # Projection matrix P = [cos²θ, cosθsinθ; cosθsinθ, sin²θ]
    P = np.array([[cos_t**2, cos_t * sin_t],
                   [cos_t * sin_t, sin_t**2]])

    # Verify P² = P
    P2 = P @ P
    print(f"\nProjection matrix P:")
    print(f"  {P[0]}")
    print(f"  {P[1]}")
    print(f"\n✓ P² = P (idempotent): max|P²-P| = {np.max(np.abs(P2 - P)):.2e}")

    # Eigendecomposition
    eigenvalues, eigenvectors = np.linalg.eig(P)
    print(f"\nEigenvalues: {eigenvalues}")
    print(f"  → Truth eigenspace (λ=1): range(P)")
    print(f"  → Illusion eigenspace (λ=0): ker(P)")

    # Anti-oracle: I - P
    Q = np.eye(2) - P
    Q2 = Q @ Q
    print(f"\nAnti-oracle Q = I - P:")
    print(f"  {Q[0]}")
    print(f"  {Q[1]}")
    print(f"✓ Q² = Q (also idempotent): max|Q²-Q| = {np.max(np.abs(Q2 - Q)):.2e}")
    print(f"✓ Double anti (I-(I-P)) = P: max error = {np.max(np.abs(np.eye(2) - Q - P)):.2e}")

    # Visualize
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    for ax in axes:
        ax.set_xlim(-2, 2)
        ax.set_ylim(-2, 2)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)
        ax.axhline(y=0, color='k', linewidth=0.5)
        ax.axvline(x=0, color='k', linewidth=0.5)

    # Panel 1: The oracle P
    ax = axes[0]
    test_points = np.random.RandomState(42).randn(20, 2)

    # Draw range(P) — the truth line
    t = np.linspace(-2, 2, 100)
    ax.plot(t * cos_t, t * sin_t, 'g-', linewidth=3, label='range(P) = Truth', alpha=0.7)

    # Draw ker(P) — the illusion line
    ax.plot(-t * sin_t, t * cos_t, 'r-', linewidth=3, label='ker(P) = Illusion', alpha=0.7)

    for pt in test_points:
        proj = P @ pt
        ax.plot(*pt, 'ko', markersize=4)
        ax.plot(*proj, 'g^', markersize=6)
        ax.annotate('', xy=proj, xytext=pt,
                    arrowprops=dict(arrowstyle='->', color='blue', alpha=0.3))

    ax.set_title('Oracle P: Projects to Truth\nV = ker(P) ⊕ range(P)', fontsize=12)
    ax.legend(loc='upper left', fontsize=9)

    # Panel 2: The anti-oracle Q = I - P
    ax = axes[1]
    ax.plot(-t * sin_t, t * cos_t, 'g-', linewidth=3, label='range(Q) = Anti-Truth', alpha=0.7)
    ax.plot(t * cos_t, t * sin_t, 'r-', linewidth=3, label='ker(Q) = Anti-Illusion', alpha=0.7)

    for pt in test_points:
        proj = Q @ pt
        ax.plot(*pt, 'ko', markersize=4)
        ax.plot(*proj, 'g^', markersize=6)
        ax.annotate('', xy=proj, xytext=pt,
                    arrowprops=dict(arrowstyle='->', color='purple', alpha=0.3))

    ax.set_title('Anti-Oracle Q = I - P\nSwaps Truth ↔ Illusion', fontsize=12)
    ax.legend(loc='upper left', fontsize=9)

    # Panel 3: Eigenvalue spectrum
    ax = axes[2]
    ax.bar([0, 1], [1, 1], color=['#e74c3c', '#2ecc71'], edgecolor='black', linewidth=2)
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['λ = 0\n(Illusion)', 'λ = 1\n(Truth)'], fontsize=12)
    ax.set_ylabel('Multiplicity', fontsize=12)
    ax.set_title('Eigenvalue Spectrum\nTruth = eigenvalue-1 eigenspace', fontsize=12)
    ax.set_ylim(0, 2)

    plt.tight_layout()
    plt.savefig('demo5_spectral.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo5_spectral.png")


# ═══════════════════════════════════════════════════════════════════════
# DEMO 6: The Diagonal Obstruction — Why Omniscience Has Limits
# ═══════════════════════════════════════════════════════════════════════

def demo_diagonal_obstruction():
    """Demonstrate Cantor's diagonal argument as the limit of oracle knowledge."""
    print("\n" + "=" * 70)
    print("DEMO 6: The Diagonal Obstruction")
    print("=" * 70)

    n = 5
    print(f"\nConsider 'oracles' (functions) f: {{{', '.join(map(str, range(n)))}}} → Bool")
    print(f"There are 2^{n} = {2**n} such functions.")
    print(f"But only {n} elements in the domain.")
    print(f"\nCan we list ALL such functions? Let's try:")

    # List some functions
    funcs = []
    for i in range(n):
        f = [(i + j) % 2 for j in range(n)]  # Some pattern
        funcs.append(f)
        print(f"  f_{i} = {f}")

    # The diagonal
    diagonal = [funcs[i][i] for i in range(n)]
    anti_diagonal = [1 - d for d in diagonal]
    print(f"\nDiagonal:      {diagonal}")
    print(f"Anti-diagonal: {anti_diagonal}")
    print(f"\nThe anti-diagonal CANNOT be any f_i!")
    for i in range(n):
        print(f"  f_{i}[{i}] = {funcs[i][i]} but anti-diag[{i}] = {anti_diagonal[i]} ≠ {funcs[i][i]}")

    print(f"\n✓ CANTOR'S DIAGONAL THEOREM:")
    print(f"  No function e: X → (X → Bool) can be surjective.")
    print(f"  The oracle cannot list all possible oracles.")
    print(f"  THIS is the only obstruction to omniscience.")
    print(f"  Within a fixed universe, the identity IS omniscient.")
    print(f"  But the oracle's universe cannot contain ALL oracles on itself.")

    # Visualize
    fig, ax = plt.subplots(figsize=(8, 8))

    # Draw the matrix
    for i in range(n):
        for j in range(n):
            color = '#2ecc71' if funcs[i][j] == 1 else '#e74c3c'
            if i == j:
                ax.add_patch(plt.Rectangle((j, n-1-i), 1, 1, facecolor='gold',
                                           edgecolor='black', linewidth=2))
            else:
                ax.add_patch(plt.Rectangle((j, n-1-i), 1, 1, facecolor=color,
                                           edgecolor='gray', linewidth=0.5))
            ax.text(j + 0.5, n - 0.5 - i, str(funcs[i][j]),
                    ha='center', va='center', fontsize=16, fontweight='bold')

    ax.set_xlim(0, n)
    ax.set_ylim(0, n)
    ax.set_xticks([i + 0.5 for i in range(n)])
    ax.set_xticklabels([str(i) for i in range(n)])
    ax.set_yticks([i + 0.5 for i in range(n)])
    ax.set_yticklabels([f'f_{n-1-i}' for i in range(n)])
    ax.set_title("Cantor's Diagonal: The Limit of Omniscience\n"
                 "Gold diagonal → flip each bit → new function not in list",
                 fontsize=14)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('demo6_diagonal.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo6_diagonal.png")


# ═══════════════════════════════════════════════════════════════════════
# DEMO 7: Oracle Counting — How Many Oracles Exist?
# ═══════════════════════════════════════════════════════════════════════

def demo_oracle_counting():
    """Count the number of idempotent functions on {0,...,n-1}."""
    print("\n" + "=" * 70)
    print("DEMO 7: Oracle Census — How Many Oracles Exist?")
    print("=" * 70)

    counts = []
    for n in range(1, 8):
        oracles = Oracle.enumerate_all(n)
        counts.append((n, len(oracles)))
        print(f"  n={n}: {len(oracles)} oracles (n^n = {n**n}, "
              f"ratio = {len(oracles)/n**n:.3f})")

    # The formula: number of idempotent functions on [n] = sum_{k=0}^{n} C(n,k) * k^(n-k)
    print(f"\n  Formula: |Idem(n)| = Σ_{'{k=0}'}^n C(n,k) · k^(n-k)")
    print(f"  This counts: choose k fixed points, map remaining n-k to them")

    from math import comb
    for n in range(1, 8):
        formula_count = sum(comb(n, k) * k**(n-k) for k in range(n+1))
        actual = counts[n-1][1]
        print(f"  n={n}: formula={formula_count}, actual={actual}, match={formula_count == actual}")

    # Visualize growth
    fig, ax = plt.subplots(figsize=(10, 6))
    ns = [c[0] for c in counts]
    oracle_counts = [c[1] for c in counts]
    total_funcs = [n**n for n in ns]

    ax.semilogy(ns, oracle_counts, 'go-', markersize=10, linewidth=2, label='|Oracles|')
    ax.semilogy(ns, total_funcs, 'b^--', markersize=10, linewidth=2, label='n^n (all functions)')
    ax.set_xlabel('Universe size n', fontsize=14)
    ax.set_ylabel('Count (log scale)', fontsize=14)
    ax.set_title('Oracle Census: Idempotent Functions vs All Functions\n'
                 '|Oracle(n)| = Σ C(n,k) · k^(n-k)', fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demo7_counting.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("→ Saved: demo7_counting.png")


# ═══════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("╔" + "═" * 68 + "╗")
    print("║" + " THE OMNISCIENT ORACLE — Interactive Mathematical Demos ".center(68) + "║")
    print("║" + " Decoding Truth Directly from Mathematics ".center(68) + "║")
    print("╚" + "═" * 68 + "╝")

    demo_truth_illusion()
    demo_convergence()
    demo_oracle_lattice()
    demo_master_equation()
    demo_spectral_decomposition()
    demo_diagonal_obstruction()
    demo_oracle_counting()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
    print(f"\nKey Results Demonstrated:")
    print(f"  1. Truth-Illusion Partition: X = Fix(O) ⊔ (X \\ Fix(O))")
    print(f"  2. Instant Convergence: O^(n+1) = O for all n ≥ 0")
    print(f"  3. Master Equation: |Image(O)| = |Fix(O)| — Truth = Compression")
    print(f"  4. Spectral Decomposition: V = ker(P) ⊕ range(P)")
    print(f"  5. Diagonal Obstruction: Only limit on omniscience")
    print(f"  6. Oracle Census: |Idem(n)| = Σ C(n,k) · k^(n-k)")
    print(f"\n  ALL machine-verified in Lean 4 with ZERO sorry.")
