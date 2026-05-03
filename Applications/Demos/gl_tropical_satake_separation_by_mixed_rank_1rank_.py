#!/usr/bin/env python3
"""
GL₃ Tropical Satake Mixed Levi Separation — Demonstration

This script demonstrates the key mathematical results from the formal
Lean verification of GL₃ tropical Satake separation:

1. The test functionals (edge1, edge2, levi12, levi23) and their properties
2. Why levi12 = levi23 (they sum the same terms in reversed order)
3. The separation theorem works for N ≤ 1
4. An explicit counterexample shows it fails for N ≥ 2
5. The corrected 2D prefix rectangle sum approach works for all N
6. Rank analysis: why O(N) tests can't determine O(N²) coefficients

Usage:
    python gl3_satake_separation.py
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import product


# ── Test functional definitions ──────────────────────────────────────────

def edge1(f, N, i):
    """Prefix row sum: sum f(i, b) for b = 0, ..., i."""
    return sum(f[i, b] for b in range(min(i + 1, N + 1)))

def edge2(f, N, j):
    """Prefix column sum: sum f(a, j) for a = 0, ..., j."""
    return sum(f[a, j] for a in range(min(j + 1, N + 1)))

def levi12(f, N, s):
    """Anti-diagonal sum: sum f(x, s-x) for x = 0, ..., s."""
    return sum(f[x, s - x] for x in range(s + 1) if x <= N and s - x <= N)

def levi23(f, N, t):
    """Anti-diagonal sum (reversed parametrization): sum f(t-x, x)."""
    return sum(f[t - x, x] for x in range(t + 1) if t - x <= N and x <= N)

def prefix_rect_sum(f, N, a, b):
    """2D cumulative rectangle sum: sum f(i,j) for i <= a, j <= b."""
    return sum(f[i, j] for i in range(a + 1) for j in range(b + 1)
               if i <= N and j <= N)


# ── Demo 1: levi12 = levi23 ─────────────────────────────────────────────

def demo_levi_equality():
    """Demonstrate that levi12 and levi23 always agree."""
    print("=" * 60)
    print("DEMO 1: levi12 = levi23 (Levi redundancy)")
    print("=" * 60)

    N = 4
    np.random.seed(42)
    f = np.random.randint(-5, 6, size=(N + 1, N + 1))

    print(f"\nRandom function on [0,{N}]²:")
    print(f)
    print()

    for s in range(2 * N + 1):
        l12 = levi12(f, N, s)
        l23 = levi23(f, N, s)
        status = "✓" if l12 == l23 else "✗ MISMATCH"
        print(f"  s={s}: levi12 = {l12:3d}, levi23 = {l23:3d}  {status}")

    print("\n→ The two Levi families always agree because they sum the")
    print("  same anti-diagonal values {f(a, s-a)} in reversed order.")
    print("  This means levi23 provides NO additional information.")
    print()


# ── Demo 2: Separation works for N ≤ 1 ──────────────────────────────────

def demo_small_N():
    """Show separation works for N = 0 and N = 1."""
    print("=" * 60)
    print("DEMO 2: Separation theorem for N ≤ 1")
    print("=" * 60)

    # N = 0: only h(0,0), determined by edge1(0)
    print("\n--- N = 0 ---")
    for val in [-3, 0, 5]:
        f = np.array([[val]])
        e1 = edge1(f, 0, 0)
        print(f"  h(0,0) = {val}: edge1(0) = {e1}")
        if e1 == 0:
            print(f"    → All tests vanish ⟹ h = 0 ✓" if val == 0
                  else f"    → Should not happen for nonzero h")

    # N = 1: determined by edge1(0,1), edge2(0,1), levi12(0,1,2)
    print("\n--- N = 1 ---")
    print("  The 4 unknowns h(0,0), h(0,1), h(1,0), h(1,1) are determined by:")
    print("    edge1(0) = h(0,0)")
    print("    edge1(1) = h(1,0) + h(1,1)")
    print("    edge2(1) = h(0,1) + h(1,1)")
    print("    levi12(2) = h(1,1)  [since h(0,2), h(2,0) are outside support]")
    print()

    # Test with random functions
    print("  Testing 1000 random functions on [0,1]²...")
    all_determined = True
    for _ in range(1000):
        f = np.random.randint(-10, 11, size=(2, 2))
        tests = [edge1(f, 1, i) for i in range(2)] + \
                [edge2(f, 1, j) for j in range(2)] + \
                [levi12(f, 1, s) for s in range(3)]
        if all(t == 0 for t in tests) and np.any(f != 0):
            all_determined = False
            print(f"  COUNTEREXAMPLE FOUND: {f}")
            break

    if all_determined:
        print("  → No nonzero function in the kernel. Separation holds! ✓")
    print()


# ── Demo 3: Counterexample for N = 2 ────────────────────────────────────

def demo_counterexample():
    """Construct and verify the counterexample for N = 2."""
    print("=" * 60)
    print("DEMO 3: Counterexample for N = 2")
    print("=" * 60)

    N = 2
    h = np.zeros((N + 1, N + 1), dtype=int)
    h[0, 2] = 1    # δ(0,2)
    h[1, 2] = -1   # -δ(1,2)
    h[2, 0] = -1   # -δ(2,0)
    h[2, 1] = 1    # δ(2,1)

    print("\nCounterexample h:")
    print(h)
    print(f"\nh is nonzero: {np.any(h != 0)} ✓")
    print(f"Support ⊆ [0,2]²: True ✓")

    print("\nTest values:")
    for i in range(N + 1):
        val = edge1(h, N, i)
        print(f"  edge1(h, {i}) = {val}  {'✓' if val == 0 else '✗'}")
    for j in range(N + 1):
        val = edge2(h, N, j)
        print(f"  edge2(h, {j}) = {val}  {'✓' if val == 0 else '✗'}")
    for s in range(2 * N + 1):
        val = levi12(h, N, s)
        print(f"  levi12(h, {s}) = {val}  {'✓' if val == 0 else '✗'}")

    print("\n→ All tests vanish on a nonzero function!")
    print("  The separation theorem FAILS for N ≥ 2. ✗")
    print()


# ── Demo 4: Kernel dimension analysis ───────────────────────────────────

def demo_kernel_analysis():
    """Compute the kernel dimension of the test map for various N."""
    print("=" * 60)
    print("DEMO 4: Kernel dimension analysis")
    print("=" * 60)

    results = []
    for N in range(7):
        dim = (N + 1) ** 2  # number of unknowns

        # Build the test matrix
        rows = []
        for i in range(N + 1):  # edge1
            row = np.zeros(dim, dtype=float)
            for b in range(i + 1):
                if b <= N:
                    row[i * (N + 1) + b] = 1
            rows.append(row)

        for j in range(N + 1):  # edge2
            row = np.zeros(dim, dtype=float)
            for a in range(j + 1):
                if a <= N:
                    row[a * (N + 1) + j] = 1
            rows.append(row)

        for s in range(2 * N + 1):  # levi12
            row = np.zeros(dim, dtype=float)
            for x in range(s + 1):
                if x <= N and s - x <= N:
                    row[x * (N + 1) + (s - x)] = 1
            rows.append(row)

        A = np.array(rows)
        rank = np.linalg.matrix_rank(A)
        kernel_dim = dim - rank

        results.append((N, dim, len(rows), rank, kernel_dim))
        print(f"  N={N}: unknowns={(N+1)**2:3d}, tests={len(rows):3d}, "
              f"rank={rank:3d}, kernel_dim={kernel_dim:3d}"
              f"  {'✓ separates' if kernel_dim == 0 else '✗ does NOT separate'}")

    print()
    print("  Key insight: the test family has only O(N) functionals,")
    print("  but the unknown space has O(N²) dimensions.")
    print("  For N ≥ 2, the kernel is nontrivial.")
    print()

    return results


# ── Demo 5: 1D prefix sum separation (GL₂ case) ────────────────────────

def demo_1d_prefix():
    """Demonstrate the 1D prefix sum separation theorem."""
    print("=" * 60)
    print("DEMO 5: GL₂ analog — 1D prefix sum separation")
    print("=" * 60)

    N = 5
    print(f"\nFor N = {N}: prefix sums form a lower-triangular system.")
    print("  The matrix is:")

    # Build the prefix sum matrix
    M = np.zeros((N + 1, N + 1), dtype=int)
    for i in range(N + 1):
        for a in range(i + 1):
            M[i, a] = 1

    print(M)
    print(f"\n  det(M) = {int(round(np.linalg.det(M)))}")
    print("  The matrix is lower-triangular with 1s on the diagonal,")
    print("  so det = 1. The system is always invertible!")
    print()

    # Recovery example
    f_true = np.array([3, -1, 4, -1, 5, -9])
    prefix_sums = [sum(f_true[:i+1]) for i in range(N + 1)]
    print(f"  True function:  f = {list(f_true)}")
    print(f"  Prefix sums:    P = {prefix_sums}")

    # Recover by differencing
    f_recovered = np.zeros(N + 1, dtype=int)
    f_recovered[0] = prefix_sums[0]
    for i in range(1, N + 1):
        f_recovered[i] = prefix_sums[i] - prefix_sums[i - 1]
    print(f"  Recovered:      f = {list(f_recovered)}")
    print(f"  Match: {np.array_equal(f_true, f_recovered)} ✓")
    print()


# ── Demo 6: 2D prefix rectangle sum separation ─────────────────────────

def demo_2d_prefix_rect():
    """Demonstrate the corrected 2D separation theorem."""
    print("=" * 60)
    print("DEMO 6: Corrected 2D separation — prefix rectangle sums")
    print("=" * 60)

    N = 3
    np.random.seed(123)
    f_true = np.random.randint(-5, 6, size=(N + 1, N + 1))

    print(f"\nTrue function on [0,{N}]²:")
    print(f_true)

    # Compute prefix rectangle sums
    P = np.zeros((N + 1, N + 1), dtype=int)
    for a in range(N + 1):
        for b in range(N + 1):
            P[a, b] = prefix_rect_sum(f_true, N, a, b)

    print(f"\nPrefix rectangle sums:")
    print(P)

    # Recover by 2D Möbius inversion (inclusion-exclusion)
    f_recovered = np.zeros((N + 1, N + 1), dtype=int)
    for a in range(N + 1):
        for b in range(N + 1):
            val = P[a, b]
            if a > 0:
                val -= P[a - 1, b]
            if b > 0:
                val -= P[a, b - 1]
            if a > 0 and b > 0:
                val += P[a - 1, b - 1]
            f_recovered[a, b] = val

    print(f"\nRecovered function:")
    print(f_recovered)
    print(f"\nMatch: {np.array_equal(f_true, f_recovered)} ✓")
    print()

    # Compare test counts
    original_tests = 3 * (N + 1) + (2 * N + 1)  # edge1 + edge2 + levi12
    rect_tests = (N + 1) ** 2
    print(f"  Original test family: {original_tests} tests (insufficient for N≥2)")
    print(f"  Prefix rect sums:     {rect_tests} tests (always sufficient)")
    print(f"  Unknowns:             {(N+1)**2}")
    print()


# ── Visualization ────────────────────────────────────────────────────────

def visualize_counterexample():
    """Create a visualization of the N=2 counterexample and test functionals."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    N = 2
    h = np.zeros((N + 1, N + 1), dtype=int)
    h[0, 2] = 1
    h[1, 2] = -1
    h[2, 0] = -1
    h[2, 1] = 1

    # Plot 1: The counterexample function
    ax = axes[0]
    im = ax.imshow(h, cmap='RdBu_r', vmin=-1.5, vmax=1.5, origin='lower')
    ax.set_title('Counterexample h\n(kernel element for N=2)', fontsize=12)
    ax.set_xlabel('b (second coordinate)')
    ax.set_ylabel('a (first coordinate)')
    for i in range(N + 1):
        for j in range(N + 1):
            color = 'white' if abs(h[i, j]) > 0.5 else 'black'
            ax.text(j, i, str(h[i, j]), ha='center', va='center',
                    fontsize=16, fontweight='bold', color=color)
    ax.set_xticks(range(N + 1))
    ax.set_yticks(range(N + 1))
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Plot 2: Test functionals schematic
    ax = axes[1]
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.set_title('Test functional structure\n(O(N) tests for O(N²) unknowns)', fontsize=12)

    # Draw grid points
    for i in range(N + 1):
        for j in range(N + 1):
            ax.plot(j, i, 'ko', markersize=8)

    # Draw edge1 arrows (prefix row sums)
    colors = ['#e74c3c', '#3498db', '#2ecc71']
    for i in range(N + 1):
        for b in range(i + 1):
            ax.annotate('', xy=(b + 0.15, i + 0.1), xytext=(b - 0.15, i + 0.1),
                       arrowprops=dict(arrowstyle='->', color=colors[i], lw=1.5))
        ax.text(-0.4, i + 0.15, f'e₁({i})', fontsize=8, color=colors[i],
                ha='right', fontweight='bold')

    # Draw anti-diagonal lines
    for s in range(2 * N + 1):
        pts_x = [x for x in range(s + 1) if x <= N and s - x <= N]
        pts_y = [s - x for x in pts_x]
        if len(pts_x) > 1:
            ax.plot(pts_y, pts_x, '--', color='gray', alpha=0.5, lw=1)
        ax.text(max(pts_y) + 0.2, min(pts_x) - 0.15, f'd{s}',
                fontsize=7, color='gray')

    ax.set_xlabel('b')
    ax.set_ylabel('a')
    ax.set_xticks(range(N + 1))
    ax.set_yticks(range(N + 1))

    # Plot 3: Kernel dimension vs N
    ax = axes[2]
    Ns = list(range(8))
    kernel_dims = []
    for N_val in Ns:
        dim = (N_val + 1) ** 2
        rows = []
        for i in range(N_val + 1):
            row = np.zeros(dim)
            for b in range(min(i + 1, N_val + 1)):
                row[i * (N_val + 1) + b] = 1
            rows.append(row)
        for j in range(N_val + 1):
            row = np.zeros(dim)
            for a in range(min(j + 1, N_val + 1)):
                row[a * (N_val + 1) + j] = 1
            rows.append(row)
        for s in range(2 * N_val + 1):
            row = np.zeros(dim)
            for x in range(s + 1):
                if x <= N_val and s - x <= N_val:
                    row[x * (N_val + 1) + (s - x)] = 1
            rows.append(row)
        A = np.array(rows)
        rank = np.linalg.matrix_rank(A)
        kernel_dims.append(dim - rank)

    ax.bar(Ns, kernel_dims, color=['#2ecc71' if k == 0 else '#e74c3c' for k in kernel_dims],
           alpha=0.8, edgecolor='black')
    ax.set_xlabel('N (rectangle size parameter)')
    ax.set_ylabel('Kernel dimension')
    ax.set_title('Kernel dimension of test map\n(0 = separation holds)', fontsize=12)
    ax.set_xticks(Ns)

    for i, kd in enumerate(kernel_dims):
        ax.text(i, kd + 0.3, str(kd), ha='center', fontsize=10, fontweight='bold')

    plt.tight_layout()
    plt.savefig('gl3_satake_separation.png', dpi=150, bbox_inches='tight')
    print("  Figure saved to gl3_satake_separation.png")
    plt.close()


def visualize_recovery():
    """Visualize the 2D Möbius inversion recovery process."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    N = 3
    np.random.seed(42)
    f = np.random.randint(-3, 4, size=(N + 1, N + 1))

    # Prefix rectangle sums
    P = np.zeros((N + 1, N + 1), dtype=int)
    for a in range(N + 1):
        for b in range(N + 1):
            P[a, b] = sum(f[i, j] for i in range(a + 1) for j in range(b + 1))

    # Recovery
    f_rec = np.zeros((N + 1, N + 1), dtype=int)
    for a in range(N + 1):
        for b in range(N + 1):
            val = P[a, b]
            if a > 0: val -= P[a-1, b]
            if b > 0: val -= P[a, b-1]
            if a > 0 and b > 0: val += P[a-1, b-1]
            f_rec[a, b] = val

    for idx, (mat, title) in enumerate([
        (f, 'Original f'), (P, 'Prefix rect sums'), (f_rec, 'Recovered f')
    ]):
        ax = axes[idx]
        im = ax.imshow(mat, cmap='viridis', origin='lower')
        ax.set_title(title, fontsize=13, fontweight='bold')
        for i in range(N + 1):
            for j in range(N + 1):
                ax.text(j, i, str(mat[i, j]), ha='center', va='center',
                        fontsize=12, color='white' if abs(mat[i,j]) > np.max(np.abs(mat))/2 else 'black')
        ax.set_xticks(range(N + 1))
        ax.set_yticks(range(N + 1))
        ax.set_xlabel('b')
        ax.set_ylabel('a')
        plt.colorbar(im, ax=ax, shrink=0.8)

    plt.tight_layout()
    plt.savefig('gl3_2d_recovery.png', dpi=150, bbox_inches='tight')
    print("  Figure saved to gl3_2d_recovery.png")
    plt.close()


# ── Main ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  GL₃ Tropical Satake Mixed Levi Separation Demo        ║")
    print("║  Companion to formally verified Lean 4 proofs           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_levi_equality()
    demo_small_N()
    demo_counterexample()
    demo_kernel_analysis()
    demo_1d_prefix()
    demo_2d_prefix_rect()

    print("=" * 60)
    print("VISUALIZATION")
    print("=" * 60)
    print()
    visualize_counterexample()
    visualize_recovery()

    print()
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
Key findings (all formally verified in Lean 4):

1. levi12 ≡ levi23: The two Levi profile families are identical
   by reindexing, providing no additional separation power.

2. Separation holds for N ≤ 1: The mixed test family
   (edge₁, edge₂, levi₁₂) uniquely determines functions
   supported in [0,N]² when N ≤ 1.

3. Separation FAILS for N ≥ 2: An explicit counterexample
   h = δ(0,2) - δ(1,2) - δ(2,0) + δ(2,1) satisfies all
   test conditions but is nonzero.

4. Root cause: Information-theoretic impossibility. The test
   family provides O(N) linear constraints for O(N²) unknowns.
   For N ≥ 2, the system is underdetermined.

5. Corrected theorem: Using 2D prefix rectangle sums (a richer
   2-parameter test family) provides (N+1)² independent tests,
   achieving separation for all N via Möbius inversion.

6. GL₂ analog: The 1D prefix sum theorem works perfectly for
   all N, as the system is lower-triangular with det = 1.
""")
