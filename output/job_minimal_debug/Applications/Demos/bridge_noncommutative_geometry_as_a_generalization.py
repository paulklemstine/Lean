#!/usr/bin/env python3
"""
Noncommutative Geometry Demo: Gelfand Duality Failure and K-Theory

Demonstrates the key mathematical concepts from the formalization:
1. Matrix unit systems and their properties
2. Empty Gelfand spectrum for matrix algebras
3. Murray-von Neumann equivalence of idempotents
4. Bott periodicity
5. Dimension obstruction
"""

import numpy as np
from typing import List, Tuple, Optional


def matrix_unit(n: int, i: int, j: int) -> np.ndarray:
    """Standard matrix unit E_{ij}: 1 at position (i,j), 0 elsewhere."""
    E = np.zeros((n, n), dtype=complex)
    E[i, j] = 1.0
    return E


def verify_matrix_unit_system(n: int) -> bool:
    """Verify that the standard matrix units satisfy the multiplication rule."""
    print(f"\n{'='*60}")
    print(f"Verifying matrix unit system of size {n}")
    print(f"{'='*60}")

    # Check multiplication rule: E_{ij} * E_{kl} = δ_{jk} E_{il}
    violations = 0
    for i in range(n):
        for j in range(n):
            for k in range(n):
                for l in range(n):
                    product = matrix_unit(n, i, j) @ matrix_unit(n, k, l)
                    expected = matrix_unit(n, i, l) if j == k else np.zeros((n, n))
                    if not np.allclose(product, expected):
                        violations += 1

    print(f"  Multiplication rule: {'✓ PASSED' if violations == 0 else f'✗ {violations} violations'}")

    # Check completeness: ∑ E_{ii} = I
    diagonal_sum = sum(matrix_unit(n, i, i) for i in range(n))
    complete = np.allclose(diagonal_sum, np.eye(n))
    print(f"  Completeness (∑ E_ii = I): {'✓ PASSED' if complete else '✗ FAILED'}")

    return violations == 0 and complete


def demonstrate_empty_spectrum(n: int):
    """Show why matrix algebras have no characters (ring homs to ℂ)."""
    print(f"\n{'='*60}")
    print(f"Gelfand Spectrum Emptiness for M_{n}(ℂ)")
    print(f"{'='*60}")

    print(f"\nSuppose φ: M_{n}(ℂ) → ℂ is a ring homomorphism.")
    print(f"We derive a contradiction:\n")

    # Step 1: Off-diagonal units square to zero
    print("Step 1: Off-diagonal units are nilpotent")
    for i in range(min(n, 3)):
        for j in range(min(n, 3)):
            if i != j:
                E = matrix_unit(n, i, j)
                E_sq = E @ E
                print(f"  E_{{{i}{j}}}² = {E_sq.tolist()} (= 0)")
                print(f"  ⟹ φ(E_{{{i}{j}}})² = 0 in ℂ ⟹ φ(E_{{{i}{j}}}) = 0")

    # Step 2: Diagonal units via off-diagonal products
    print(f"\nStep 2: Diagonal units factor through off-diagonal units")
    for i in range(min(n, 3)):
        j = (i + 1) % n
        E_ij = matrix_unit(n, i, j)
        E_ji = matrix_unit(n, j, i)
        product = E_ij @ E_ji
        print(f"  E_{{{i}{i}}} = E_{{{i}{j}}} · E_{{{j}{i}}}")
        print(f"  ⟹ φ(E_{{{i}{i}}}) = φ(E_{{{i}{j}}}) · φ(E_{{{j}{i}}}) = 0 · 0 = 0")

    # Step 3: Contradiction
    print(f"\nStep 3: Contradiction")
    print(f"  ∑ E_{{ii}} = I  ⟹  φ(I) = ∑ φ(E_{{ii}}) = 0")
    print(f"  But φ(I) = 1 (ring homomorphism)")
    print(f"  ∴ 0 = 1, CONTRADICTION")
    print(f"\n  ⟹ No character exists. The Gelfand spectrum of M_{n}(ℂ) is EMPTY.")


def demonstrate_mvn_equivalence(n: int):
    """Show Murray-von Neumann equivalence of diagonal idempotents."""
    print(f"\n{'='*60}")
    print(f"Murray-von Neumann Equivalence in M_{n}(ℂ)")
    print(f"{'='*60}")

    for i in range(min(n - 1, 3)):
        j = i + 1
        E_ii = matrix_unit(n, i, i)
        E_jj = matrix_unit(n, j, j)
        E_ij = matrix_unit(n, i, j)
        E_ji = matrix_unit(n, j, i)

        # Verify: E_ij * E_ji = E_ii and E_ji * E_ij = E_jj
        check1 = np.allclose(E_ij @ E_ji, E_ii)
        check2 = np.allclose(E_ji @ E_ij, E_jj)

        print(f"\n  E_{{{i}{i}}} ~ E_{{{j}{j}}} via v = E_{{{i}{j}}}, w = E_{{{j}{i}}}")
        print(f"    v·w = E_{{{i}{j}}}·E_{{{j}{i}}} = E_{{{i}{i}}} {'✓' if check1 else '✗'}")
        print(f"    w·v = E_{{{j}{i}}}·E_{{{i}{j}}} = E_{{{j}{j}}} {'✓' if check2 else '✗'}")

    print(f"\n  All diagonal projections are MvN-equivalent!")
    print(f"  This is the K-theoretic content: [E_{{00}}] = [E_{{11}}] = ... in K₀")


def demonstrate_bott_periodicity():
    """Demonstrate Bott periodicity: K_{n+2} = K_n."""
    print(f"\n{'='*60}")
    print(f"Bott Periodicity: K_{{n+2}} = K_n")
    print(f"{'='*60}")

    print(f"\n  K-groups of ℂ (or any algebraically closed field):")
    print(f"  K₀(ℂ) ≅ ℤ     (counting virtual dimension)")
    print(f"  K₁(ℂ) ≅ 0     (no winding in ℂ)")
    print(f"\n  By Bott periodicity:")
    for n in range(-3, 8):
        k_group = "ℤ" if n % 2 == 0 else "0"
        print(f"    K_{n:+d}(ℂ) ≅ {k_group}   (since {n} mod 2 = {n % 2})")

    print(f"\n  The pattern repeats with period 2: ℤ, 0, ℤ, 0, ...")


def demonstrate_dimension_obstruction():
    """Show the dimension counting obstruction."""
    print(f"\n{'='*60}")
    print(f"Dimension Counting Obstruction")
    print(f"{'='*60}")

    for n in range(2, 6):
        print(f"\n  M_{n}(ℂ): Need {n} equal integers summing to 1")
        print(f"  If v₁ = v₂ = ... = v_{n} = v, then {n}v = 1")
        print(f"  But {n}v = 1 has no integer solution ⟹ IMPOSSIBLE")
        print(f"  This means K₀(M_{n}(ℂ)) sees the identity as '1/{n}' of a generator")


def commutative_algebra_characters():
    """Demonstrate that commutative algebras have characters."""
    print(f"\n{'='*60}")
    print(f"Characters of Commutative Algebras")
    print(f"{'='*60}")

    # Example: ℂ × ℂ (diagonal 2×2 matrices)
    print(f"\n  Example: A = ℂ × ℂ (commutative, 2-dimensional)")
    print(f"  Characters:")
    print(f"    φ₁(a, b) = a    (projection to first component)")
    print(f"    φ₂(a, b) = b    (projection to second component)")
    print(f"  Gelfand spectrum = {{φ₁, φ₂}} ≅ {{0, 1}} (two points)")
    print(f"  Gelfand transform: (a,b) ↦ function on {{0,1}} with f(0)=a, f(1)=b")
    print(f"\n  Contrast with M₂(ℂ): same dimension (4 real), but NO characters!")

    # Example: polynomial algebra
    print(f"\n  Example: ℂ[x]/(x² - 1) (commutative, 2-dimensional)")
    print(f"  Characters: x ↦ 1 and x ↦ -1")
    print(f"  Gelfand spectrum ≅ {{±1}} (two points)")
    print(f"  This algebra ≅ ℂ × ℂ via the Chinese Remainder Theorem")


if __name__ == "__main__":
    print("=" * 60)
    print("NONCOMMUTATIVE GEOMETRY: GELFAND DUALITY AND K-THEORY")
    print("=" * 60)

    # Verify matrix unit systems
    for n in [2, 3, 4]:
        verify_matrix_unit_system(n)

    # Demonstrate empty spectrum
    demonstrate_empty_spectrum(2)
    demonstrate_empty_spectrum(3)

    # Murray-von Neumann equivalence
    demonstrate_mvn_equivalence(3)

    # Bott periodicity
    demonstrate_bott_periodicity()

    # Dimension obstruction
    demonstrate_dimension_obstruction()

    # Commutative case
    commutative_algebra_characters()

    print(f"\n{'='*60}")
    print(f"SUMMARY")
    print(f"{'='*60}")
    print(f"  Commutative algebras: nonempty spectrum → classical topology")
    print(f"  Noncommutative (matrix) algebras: empty spectrum → K-theory")
    print(f"  Bott periodicity: only K₀ and K₁ matter (period 2)")
    print(f"  The bridge: K_i(A) = Kⁱ(Σ(A)) when A is commutative")


#!/usr/bin/env python3
"""
Visualization: Gelfand Spectrum Emptiness and K-Theory

Creates visualizations showing:
1. The contrast between commutative and noncommutative spectra
2. Murray-von Neumann equivalence classes
3. Bott periodicity pattern
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_spectrum_comparison():
    """Compare Gelfand spectra of commutative vs noncommutative algebras."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: C(X) for X = {1,2,3} (commutative)
    ax = axes[0]
    ax.set_title("Commutative: $\\mathbb{C}^3$\n(Functions on 3 points)", fontsize=12)
    theta = np.linspace(0, 2 * np.pi, 4)[:-1]
    x = 0.6 * np.cos(theta)
    y = 0.6 * np.sin(theta)
    for i in range(3):
        circle = plt.Circle((x[i], y[i]), 0.15, color='steelblue', alpha=0.8)
        ax.add_patch(circle)
        ax.text(x[i], y[i], f'$\\varphi_{i+1}$', ha='center', va='center',
                fontsize=11, color='white', fontweight='bold')
    ax.set_xlim(-1.2, 1.2)
    ax.set_ylim(-1.2, 1.2)
    ax.set_aspect('equal')
    ax.text(0, -1.0, "Spectrum = 3 points", ha='center', fontsize=10, color='green')
    ax.axis('off')

    # Panel 2: M_2(C) (noncommutative)
    ax = axes[1]
    ax.set_title("Noncommutative: $M_2(\\mathbb{C})$\n(2×2 matrices)", fontsize=12)
    circle = plt.Circle((0, 0), 0.5, fill=False, color='red',
                         linewidth=2, linestyle='--')
    ax.add_patch(circle)
    ax.text(0, 0, "∅", ha='center', va='center', fontsize=40, color='red')
    ax.set_xlim(-1.2, 1.2)
    ax.set_ylim(-1.2, 1.2)
    ax.set_aspect('equal')
    ax.text(0, -1.0, "Spectrum = EMPTY", ha='center', fontsize=10, color='red')
    ax.axis('off')

    # Panel 3: M_3(C) (noncommutative)
    ax = axes[2]
    ax.set_title("Noncommutative: $M_3(\\mathbb{C})$\n(3×3 matrices)", fontsize=12)
    circle = plt.Circle((0, 0), 0.5, fill=False, color='red',
                         linewidth=2, linestyle='--')
    ax.add_patch(circle)
    ax.text(0, 0, "∅", ha='center', va='center', fontsize=40, color='red')
    ax.set_xlim(-1.2, 1.2)
    ax.set_ylim(-1.2, 1.2)
    ax.set_aspect('equal')
    ax.text(0, -1.0, "Spectrum = EMPTY", ha='center', fontsize=10, color='red')
    ax.axis('off')

    plt.suptitle("Gelfand Spectrum: Commutative vs Noncommutative",
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig("gelfand_spectrum_comparison.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: gelfand_spectrum_comparison.png")


def plot_mvn_equivalence():
    """Visualize Murray-von Neumann equivalence classes in M_3(C)."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Equivalence classes by rank
    ranks = {
        0: ["0"],
        1: ["$E_{00}$", "$E_{11}$", "$E_{22}$", "..."],
        2: ["$E_{00}+E_{11}$", "$E_{00}+E_{22}$", "$E_{11}+E_{22}$", "..."],
        3: ["$I$"]
    }

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    y_positions = [3, 2, 1, 0]

    for rank, (label_list) in ranks.items():
        y = y_positions[rank]
        color = colors[rank]

        # Draw equivalence class box
        box = mpatches.FancyBboxPatch(
            (-0.5, y - 0.35), 9, 0.7,
            boxstyle="round,pad=0.1",
            facecolor=color, alpha=0.2, edgecolor=color, linewidth=2
        )
        ax.add_patch(box)

        # Label
        ax.text(-1.5, y, f"Rank {rank}", ha='right', va='center',
                fontsize=12, fontweight='bold', color=color)

        # Elements
        for i, label in enumerate(label_list):
            x = i * 2.2 + 0.5
            if label == "...":
                ax.text(x, y, "⋯", ha='center', va='center', fontsize=16)
            else:
                circle = plt.Circle((x, y), 0.3, facecolor=color,
                                     alpha=0.6, edgecolor='black')
                ax.add_patch(circle)
                ax.text(x, y, label, ha='center', va='center', fontsize=9)

    # Arrows showing MvN equivalence
    ax.annotate("", xy=(2.7, 2.3), xytext=(0.5, 2.3),
                arrowprops=dict(arrowstyle="<->", color='#3498db', lw=1.5))
    ax.text(1.6, 2.5, "MvN ∼", ha='center', fontsize=9, color='#3498db')

    ax.set_xlim(-3, 10)
    ax.set_ylim(-0.8, 3.8)
    ax.set_title("Murray-von Neumann Equivalence Classes in $M_3(\\mathbb{C})$\n"
                 "$K_0(M_3(\\mathbb{C})) \\cong \\mathbb{Z}$, generated by [rank-1 projection]",
                 fontsize=13, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("mvn_equivalence.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: mvn_equivalence.png")


def plot_bott_periodicity():
    """Visualize Bott periodicity as a circular pattern."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: K-groups as a periodic sequence
    n_values = list(range(-2, 10))
    k_values = [1 if n % 2 == 0 else 0 for n in n_values]
    colors = ['steelblue' if n % 2 == 0 else '#e74c3c' for n in n_values]

    bars = ax1.bar(n_values, [1] * len(n_values), color=colors, alpha=0.7,
                   edgecolor='black', linewidth=0.5)

    for n, k, bar in zip(n_values, k_values, bars):
        label = "ℤ" if k == 1 else "0"
        bar.set_height(0.8 if k == 1 else 0.3)
        ax1.text(n, bar.get_height() + 0.05, label,
                ha='center', va='bottom', fontsize=11, fontweight='bold')

    ax1.set_xlabel("n (K-group index)", fontsize=12)
    ax1.set_ylabel("Group", fontsize=12)
    ax1.set_title("Bott Periodicity: $K_n(\\mathbb{C})$", fontsize=13, fontweight='bold')
    ax1.set_xticks(n_values)
    ax1.set_ylim(0, 1.3)
    ax1.axhline(y=0, color='black', linewidth=0.5)

    # Add period markers
    for start in range(-2, 8, 2):
        ax1.annotate("", xy=(start + 2, 1.15), xytext=(start, 1.15),
                     arrowprops=dict(arrowstyle="<->", color='gray', lw=1))
        ax1.text(start + 1, 1.2, "period 2", ha='center', fontsize=8, color='gray')

    # Right: Clock visualization
    theta_0 = np.pi / 2  # 12 o'clock position
    theta_1 = -np.pi / 2  # 6 o'clock position

    # Draw clock circle
    theta_circle = np.linspace(0, 2 * np.pi, 100)
    ax2.plot(np.cos(theta_circle), np.sin(theta_circle), 'k-', linewidth=2)

    # K₀ at top
    ax2.plot(np.cos(theta_0), np.sin(theta_0), 'o', color='steelblue',
             markersize=30, zorder=5)
    ax2.text(np.cos(theta_0), np.sin(theta_0), "$K_0$", ha='center',
             va='center', fontsize=14, fontweight='bold', color='white')
    ax2.text(np.cos(theta_0), np.sin(theta_0) + 0.25, "$\\cong \\mathbb{Z}$",
             ha='center', fontsize=11, color='steelblue')

    # K₁ at bottom
    ax2.plot(np.cos(theta_1), np.sin(theta_1), 'o', color='#e74c3c',
             markersize=30, zorder=5)
    ax2.text(np.cos(theta_1), np.sin(theta_1), "$K_1$", ha='center',
             va='center', fontsize=14, fontweight='bold', color='white')
    ax2.text(np.cos(theta_1), np.sin(theta_1) - 0.25, "$\\cong 0$",
             ha='center', fontsize=11, color='#e74c3c')

    # Arrows showing periodicity
    arrow_r = 1.15
    ax2.annotate("", xy=(arrow_r * np.cos(theta_1 + 0.1), arrow_r * np.sin(theta_1 + 0.1)),
                 xytext=(arrow_r * np.cos(theta_0 - 0.1), arrow_r * np.sin(theta_0 - 0.1)),
                 arrowprops=dict(arrowstyle="->", color='gray', lw=2,
                                 connectionstyle="arc3,rad=0.3"))
    ax2.annotate("", xy=(arrow_r * np.cos(theta_0 + 0.1), arrow_r * np.sin(theta_0 + 0.1)),
                 xytext=(arrow_r * np.cos(theta_1 - 0.1), arrow_r * np.sin(theta_1 - 0.1)),
                 arrowprops=dict(arrowstyle="->", color='gray', lw=2,
                                 connectionstyle="arc3,rad=0.3"))

    ax2.set_xlim(-1.8, 1.8)
    ax2.set_ylim(-1.8, 1.8)
    ax2.set_aspect('equal')
    ax2.set_title("K-Theory Clock\n$K_{n+2} \\cong K_n$", fontsize=13, fontweight='bold')
    ax2.axis('off')

    plt.tight_layout()
    plt.savefig("bott_periodicity.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: bott_periodicity.png")


if __name__ == "__main__":
    plot_spectrum_comparison()
    plot_mvn_equivalence()
    plot_bott_periodicity()
    print("\nAll visualizations generated successfully.")
