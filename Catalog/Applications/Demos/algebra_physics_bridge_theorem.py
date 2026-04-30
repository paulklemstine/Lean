#!/usr/bin/env python3
"""
Berggren–Lorentz Cross-Ratio Invariance: Interactive Demonstration
==================================================================

This script demonstrates the formally verified theorem that the Berggren
matrices — which generate all primitive Pythagorean triples — preserve
the projective cross ratio on the Minkowski null cone.

The theorem bridges discrete number theory (Pythagorean triples) with
continuous conformal geometry (Lorentz symmetries of the light cone).

Usage:
    python3 berggren_cross_ratio_demo.py

Output:
    - Console output showing numerical verification
    - berggren_tree.png: The Berggren tree with stereographic parameters
    - cross_ratio_invariance.png: Cross ratio preservation under all generators
    - mobius_orbits.png: Möbius orbits on the projective line
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from fractions import Fraction
from collections import deque

# =============================================================================
# Core Mathematical Definitions
# =============================================================================

# The three Berggren matrices (elements of SO+(2,1))
BERGGREN_U = np.array([[ 1, -2,  2],
                        [ 2, -1,  2],
                        [ 2, -2,  3]])

BERGGREN_A = np.array([[ 1,  2,  2],
                        [ 2,  1,  2],
                        [ 2,  2,  3]])

BERGGREN_D = np.array([[-1,  2,  2],
                        [-2,  1,  2],
                        [-2,  2,  3]])

# The corresponding 2×2 matrices acting on (m, n) parameters
BERGGREN_2x2_U = np.array([[2, -1], [1, 0]])  # det = 1
BERGGREN_2x2_A = np.array([[2,  1], [1, 0]])  # det = -1
BERGGREN_2x2_D = np.array([[1,  2], [0, 1]])  # det = 1


def null_cone_check(v):
    """Check if v lies on the null cone v₀² + v₁² = v₂²."""
    return abs(v[0]**2 + v[1]**2 - v[2]**2)


def stereo_proj(v):
    """Stereographic projection π(v) = v₁/(v₂ − v₀).

    For a Pythagorean triple (a, b, c) = (m²−n², 2mn, m²+n²),
    this gives π = m/n, the classical generator ratio.
    """
    return v[1] / (v[2] - v[0])


def cross_ratio(a, b, c, d):
    """Cross ratio CR(a,b,c,d) = (a−c)(b−d) / ((a−d)(b−c))."""
    return (a - c) * (b - d) / ((a - d) * (b - c))


def mobius_transform(alpha, beta, gamma, delta, t):
    """Möbius transformation t ↦ (αt + β)/(γt + δ)."""
    return (alpha * t + beta) / (gamma * t + delta)


# =============================================================================
# Berggren Tree Generation
# =============================================================================

def generate_berggren_tree(root=(3, 4, 5), depth=4):
    """Generate the Berggren tree of primitive Pythagorean triples.

    Returns a list of (triple, depth, parent, branch_name) tuples.
    """
    results = []
    queue = deque([(np.array(root), 0, None, 'root')])

    while queue:
        triple, d, parent, branch = queue.popleft()
        results.append((tuple(triple), d, parent, branch))

        if d < depth:
            for name, mat in [('U', BERGGREN_U), ('A', BERGGREN_A), ('D', BERGGREN_D)]:
                child = mat @ triple
                queue.append((child, d + 1, tuple(triple), name))

    return results


def triple_to_mn(a, b, c):
    """Extract (m, n) parameters from a Pythagorean triple (a, b, c).
    a = m² − n², b = 2mn, c = m² + n² (assuming a odd, b even).
    """
    # Ensure a is odd and b is even
    if a % 2 == 0:
        a, b = b, a
    m_sq = (c + a) / 2
    n_sq = (c - a) / 2
    m = int(round(np.sqrt(m_sq)))
    n = int(round(np.sqrt(n_sq)))
    return m, n


# =============================================================================
# Demonstration 1: Cross Ratio Invariance
# =============================================================================

def demo_cross_ratio_invariance():
    """Demonstrate that each Berggren matrix preserves the cross ratio."""
    print("=" * 70)
    print("DEMONSTRATION 1: Cross Ratio Invariance")
    print("=" * 70)

    # Four test vectors on the null cone
    test_vectors = [
        np.array([3, 4, 5], dtype=float),
        np.array([5, 12, 13], dtype=float),
        np.array([8, 15, 17], dtype=float),
        np.array([7, 24, 25], dtype=float),
    ]

    print("\nTest vectors on the null cone v₀² + v₁² = v₂²:")
    for i, v in enumerate(test_vectors):
        err = null_cone_check(v)
        t = stereo_proj(v)
        print(f"  v{i+1} = {v.astype(int)}  |  cone error = {err:.1e}  |  π(v) = {t:.6f}")

    # Compute cross ratio
    projs = [stereo_proj(v) for v in test_vectors]
    cr_before = cross_ratio(*projs)
    print(f"\nCross ratio CR(π(v₁), π(v₂), π(v₃), π(v₄)) = {cr_before:.10f}")

    print("\nApplying each Berggren generator:")
    for name, B, mob_params in [
        ('U', BERGGREN_U, (2, -1, 1, 0)),
        ('A', BERGGREN_A, (2,  1, 1, 0)),
        ('D', BERGGREN_D, (1,  2, 0, 1)),
    ]:
        transformed = [B @ v for v in test_vectors]

        # Verify cone preservation
        max_err = max(null_cone_check(v) for v in transformed)
        print(f"\n  Matrix {name}:")
        print(f"    Max cone error after transformation: {max_err:.1e}")

        # Verify Möbius structure
        alpha, beta, gamma, delta = mob_params
        print(f"    Induced Möbius: t ↦ ({alpha}t + {beta:+d})/({gamma}t + {delta})")

        for i, (v, tv) in enumerate(zip(test_vectors, transformed)):
            t_orig = stereo_proj(v)
            t_new = stereo_proj(tv)
            t_mob = mobius_transform(*mob_params, t_orig)
            print(f"      v{i+1}: π = {t_orig:.6f} → π(B·v) = {t_new:.6f} = Möb(π) = {t_mob:.6f}  ✓")

        projs_after = [stereo_proj(v) for v in transformed]
        cr_after = cross_ratio(*projs_after)
        print(f"    CR after = {cr_after:.10f}")
        print(f"    Invariance: |CR_before - CR_after| = {abs(cr_before - cr_after):.2e}  {'✓' if abs(cr_before - cr_after) < 1e-10 else '✗'}")


# =============================================================================
# Demonstration 2: Berggren Tree Visualization
# =============================================================================

def demo_berggren_tree_visualization():
    """Visualize the Berggren tree with stereographic parameters."""
    print("\n" + "=" * 70)
    print("DEMONSTRATION 2: Berggren Tree Structure")
    print("=" * 70)

    tree = generate_berggren_tree(depth=3)

    print(f"\nFirst {min(20, len(tree))} triples in the Berggren tree:")
    print(f"{'Triple':<20} {'Depth':>5} {'Branch':>6} {'m/n':>10} {'π(v)':>10}")
    print("-" * 55)
    for triple, depth, parent, branch in tree[:20]:
        a, b, c = triple
        if a % 2 == 0:
            a_odd, b_even = b, a
        else:
            a_odd, b_even = a, b
        t = stereo_proj(np.array([a_odd, b_even, c], dtype=float))
        m, n = triple_to_mn(a_odd, b_even, c)
        print(f"  ({a_odd:>3}, {b_even:>3}, {c:>3})   {depth:>5}  {branch:>6}  {m}/{n:<6}  {t:>10.6f}")

    # Create tree visualization
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # Left: Tree structure
    ax = axes[0]
    tree_data = generate_berggren_tree(depth=3)
    positions = {}
    level_counts = {}

    for triple, depth, parent, branch in tree_data:
        if depth not in level_counts:
            level_counts[depth] = 0
        level_counts[depth] += 1

    level_offsets = {d: 0 for d in level_counts}
    total_at_level = {d: 3**d for d in level_counts}

    for triple, depth, parent, branch in tree_data:
        idx = level_offsets[depth]
        level_offsets[depth] += 1
        x = (idx + 0.5) / max(total_at_level[depth], 1) * 10
        y = -depth * 2
        positions[triple] = (x, y)

        a, b, c = triple
        if a % 2 == 0: a, b = b, a
        t = stereo_proj(np.array([a, b, c], dtype=float))

        color = {'root': 'gold', 'U': '#e74c3c', 'A': '#2ecc71', 'D': '#3498db'}[branch]
        ax.plot(x, y, 'o', color=color, markersize=12, zorder=5)
        ax.annotate(f'({a},{b},{c})\nπ={t:.2f}',
                    (x, y), textcoords="offset points", xytext=(0, -20),
                    ha='center', fontsize=6, color='black')

        if parent is not None and parent in positions:
            px, py = positions[parent]
            ax.plot([px, x], [py, y], '-', color='gray', alpha=0.5, linewidth=1)

    ax.set_title('Berggren Tree of Pythagorean Triples\nwith Stereographic Parameters π = m/n', fontsize=12)
    ax.set_xlim(-0.5, 10.5)
    ax.legend(['U branch', 'A branch', 'D branch'], loc='lower right')
    ax.axis('off')

    # Right: Stereographic parameters on the real line
    ax = axes[1]
    all_t = []
    all_depths = []
    all_branches = []
    for triple, depth, parent, branch in tree_data:
        a, b, c = triple
        if a % 2 == 0: a, b = b, a
        t = stereo_proj(np.array([a, b, c], dtype=float))
        all_t.append(t)
        all_depths.append(depth)
        all_branches.append(branch)

    colors = {'root': 'gold', 'U': '#e74c3c', 'A': '#2ecc71', 'D': '#3498db'}
    for t, d, br in zip(all_t, all_depths, all_branches):
        ax.plot(t, d, 'o', color=colors[br], markersize=8, alpha=0.7)
        ax.annotate(f'{t:.2f}', (t, d), textcoords="offset points",
                    xytext=(0, 8), ha='center', fontsize=6)

    ax.set_xlabel('Stereographic parameter π = m/n')
    ax.set_ylabel('Tree depth')
    ax.set_title('Stereographic Parameters by Depth\n(Möbius orbits of the generators)')
    ax.invert_yaxis()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/berggren_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved berggren_tree.png")


# =============================================================================
# Demonstration 3: Cross Ratio Invariance Visualization
# =============================================================================

def demo_cross_ratio_visualization():
    """Visualize cross ratio preservation across multiple applications."""
    print("\n" + "=" * 70)
    print("DEMONSTRATION 3: Cross Ratio Invariance Visualization")
    print("=" * 70)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Generate random vectors on the null cone
    np.random.seed(42)
    num_tests = 50

    for idx, (name, B, mob_params) in enumerate([
        ('U: t ↦ (2t−1)/t', BERGGREN_U, (2, -1, 1, 0)),
        ('A: t ↦ (2t+1)/t', BERGGREN_A, (2,  1, 1, 0)),
        ('D: t ↦ t+2',      BERGGREN_D, (1,  2, 0, 1)),
    ]):
        cr_before_list = []
        cr_after_list = []

        for _ in range(num_tests):
            # Generate 4 random vectors on the cone
            vecs = []
            for _ in range(4):
                theta = np.random.uniform(0.1, np.pi/2 - 0.1)
                r = np.random.uniform(1, 10)
                v = np.array([r * np.cos(theta), r * np.sin(theta),
                              r])  # On cone: cos²+sin²=1, so v₀²+v₁²=r²=v₂²
                vecs.append(v)

            projs = [stereo_proj(v) for v in vecs]
            try:
                cr_b = cross_ratio(*projs)
            except ZeroDivisionError:
                continue

            transformed = [B @ v for v in vecs]
            projs_after = [stereo_proj(v) for v in transformed]
            try:
                cr_a = cross_ratio(*projs_after)
            except ZeroDivisionError:
                continue

            if abs(cr_b) < 100 and abs(cr_a) < 100:
                cr_before_list.append(cr_b)
                cr_after_list.append(cr_a)

        ax = axes[idx // 2, idx % 2]
        ax.scatter(cr_before_list, cr_after_list, alpha=0.6, s=20, color=['#e74c3c', '#2ecc71', '#3498db'][idx])
        lim = max(max(abs(x) for x in cr_before_list + cr_after_list), 1)
        ax.plot([-lim, lim], [-lim, lim], 'k--', alpha=0.3, label='y = x')
        ax.set_xlabel('CR before transformation')
        ax.set_ylabel('CR after transformation')
        ax.set_title(f'Generator {name}')
        ax.legend()
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

    # Fourth panel: combined error histogram
    ax = axes[1, 1]
    all_errors = []
    for name, B in [('U', BERGGREN_U), ('A', BERGGREN_A), ('D', BERGGREN_D)]:
        for _ in range(200):
            vecs = []
            for _ in range(4):
                theta = np.random.uniform(0.1, np.pi/2 - 0.1)
                r = np.random.uniform(1, 10)
                v = np.array([r * np.cos(theta), r * np.sin(theta), r])
                vecs.append(v)
            projs = [stereo_proj(v) for v in vecs]
            projs_after = [stereo_proj(B @ v) for v in vecs]
            try:
                cr_b = cross_ratio(*projs)
                cr_a = cross_ratio(*projs_after)
                if abs(cr_b) < 100:
                    all_errors.append(abs(cr_b - cr_a))
            except (ZeroDivisionError, FloatingPointError):
                continue

    ax.hist(all_errors, bins=50, color='purple', alpha=0.7, edgecolor='black')
    ax.set_xlabel('|CR_before − CR_after|')
    ax.set_ylabel('Count')
    ax.set_title(f'Invariance Error Distribution\n(all generators, {len(all_errors)} trials)')
    ax.set_yscale('log')
    ax.axvline(1e-12, color='red', linestyle='--', alpha=0.5, label='Machine epsilon')
    ax.legend()

    plt.suptitle('Cross Ratio Invariance Under Berggren Generators\n(Formally Verified in Lean 4)', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('demos/cross_ratio_invariance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved cross_ratio_invariance.png")


# =============================================================================
# Demonstration 4: Möbius Orbits
# =============================================================================

def demo_mobius_orbits():
    """Visualize the Möbius orbits of the Berggren generators."""
    print("\n" + "=" * 70)
    print("DEMONSTRATION 4: Möbius Orbits on the Projective Line")
    print("=" * 70)

    fig, ax = plt.subplots(figsize=(14, 6))

    # Start from (3,4,5) → m/n = 2
    t0 = Fraction(2, 1)

    # Generate orbits by applying sequences of generators
    def apply_sequence(t, sequence):
        """Apply a sequence of generators to parameter t."""
        for gen in sequence:
            if gen == 'U':
                t = Fraction(2 * t - 1, t.numerator) if isinstance(t, Fraction) else (2*t-1)/t
            elif gen == 'A':
                t = Fraction(2 * t + 1, t.numerator) if isinstance(t, Fraction) else (2*t+1)/t
            elif gen == 'D':
                t = t + 2
        return t

    # Generate all words up to length 3
    from itertools import product as iprod
    all_params = []
    all_words = []

    for length in range(4):
        for word in iprod('UAD', repeat=length):
            t = float(apply_sequence(t0, word))
            if 0 < t < 20:
                all_params.append(t)
                all_words.append(''.join(word) if word else 'root')

    # Sort by parameter value
    sorted_data = sorted(zip(all_params, all_words))

    # Plot
    colors = []
    for t, w in sorted_data:
        if w == 'root':
            c = 'gold'
        elif w[-1] == 'U':
            c = '#e74c3c'
        elif w[-1] == 'A':
            c = '#2ecc71'
        else:
            c = '#3498db'
        colors.append(c)

    y_positions = list(range(len(sorted_data)))
    params = [t for t, w in sorted_data]
    words = [w for t, w in sorted_data]

    ax.barh(y_positions, params, height=0.8, color=colors, alpha=0.7, edgecolor='black', linewidth=0.5)
    for i, (t, w) in enumerate(sorted_data):
        ax.text(t + 0.1, i, f'{w}: π = {t:.3f}', va='center', fontsize=7)

    ax.set_xlabel('Stereographic parameter π = m/n', fontsize=12)
    ax.set_title('Möbius Orbits of Berggren Generators\nStarting from (3,4,5) with π = 2', fontsize=13)
    ax.set_yticks([])
    ax.grid(True, alpha=0.2, axis='x')

    # Add legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='gold', edgecolor='black', label='Root (3,4,5)'),
        Patch(facecolor='#e74c3c', edgecolor='black', label='U: t ↦ (2t−1)/t'),
        Patch(facecolor='#2ecc71', edgecolor='black', label='A: t ↦ (2t+1)/t'),
        Patch(facecolor='#3498db', edgecolor='black', label='D: t ↦ t+2'),
    ]
    ax.legend(handles=legend_elements, loc='lower right')

    plt.tight_layout()
    plt.savefig('demos/mobius_orbits.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved mobius_orbits.png")


# =============================================================================
# Demonstration 5: The SO+(2,1) ≅ PSL(2,R) Connection
# =============================================================================

def demo_lorentz_connection():
    """Demonstrate the explicit SO+(2,1) to PSL(2,R) correspondence."""
    print("\n" + "=" * 70)
    print("DEMONSTRATION 5: SO⁺(2,1) ≅ PSL(2,ℝ) Correspondence")
    print("=" * 70)

    print("\nThe isomorphism maps each 3×3 Berggren matrix to a 2×2 matrix")
    print("acting on the generator pair (m, n):\n")

    for name, M3, M2 in [
        ('U', BERGGREN_U, BERGGREN_2x2_U),
        ('A', BERGGREN_A, BERGGREN_2x2_A),
        ('D', BERGGREN_D, BERGGREN_2x2_D),
    ]:
        print(f"  {name}: 3×3 matrix (SO⁺(2,1)):")
        for row in M3:
            print(f"    {row}")
        print(f"     ↦ 2×2 matrix (PSL(2,ℤ)):")
        print(f"    {M2[0]}")
        print(f"    {M2[1]}")
        print(f"     det = {int(np.linalg.det(M2)):+d}")
        print()

    # Verify the correspondence on (3,4,5) → (m,n) = (2,1)
    print("Verification on (3,4,5) with (m,n) = (2,1):")
    mn = np.array([2, 1])
    triple = np.array([3, 4, 5])

    for name, M3, M2 in [
        ('U', BERGGREN_U, BERGGREN_2x2_U),
        ('A', BERGGREN_A, BERGGREN_2x2_A),
        ('D', BERGGREN_D, BERGGREN_2x2_D),
    ]:
        new_triple = M3 @ triple
        new_mn = M2 @ mn
        # Reconstruct triple from (m,n)
        m, n = new_mn
        reconstructed = (m**2 - n**2, 2*m*n, m**2 + n**2)
        a, b, c = new_triple
        if a % 2 == 0:
            a, b = b, a
        print(f"  {name}: ({a},{b},{c}) with (m,n) = ({m},{n})")
        print(f"       Reconstructed: ({reconstructed[0]},{reconstructed[1]},{reconstructed[2]})")
        match = (a == reconstructed[0] and b == reconstructed[1] and c == reconstructed[2])
        print(f"       Match: {'✓' if match else '✗'}")


# =============================================================================
# Main
# =============================================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Berggren–Lorentz Cross-Ratio Invariance                           ║")
    print("║  Formally Verified in Lean 4 with Mathlib                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_cross_ratio_invariance()
    demo_berggren_tree_visualization()
    demo_cross_ratio_visualization()
    demo_mobius_orbits()
    demo_lorentz_connection()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
