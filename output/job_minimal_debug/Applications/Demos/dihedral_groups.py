#!/usr/bin/env python3
"""
Applications of Dihedral-Cyclotomic Theory

Real-world applications of the real cyclotomic subfield theory
and dihedral symmetry.
"""

import numpy as np
from math import gcd
from algorithms import (
    euler_totient,
    real_cyclotomic_generator,
    chebyshev_power_sum,
    minimal_polynomial_real_generator,
    galois_automorphisms,
)


# ──────────────────────────────────────────────────────────────
# APPLICATION 1: Constructible Regular Polygons
# ──────────────────────────────────────────────────────────────

def is_constructible(n: int) -> bool:
    """Determine if a regular n-gon is constructible by ruler and compass.

    By the Gauss-Wantzel theorem, a regular n-gon is constructible iff
    n = 2^a · p_1 · p_2 · ... · p_k where the p_i are distinct Fermat primes.

    The connection to our theory: constructibility requires [ℚ(ζ+ζ⁻¹):ℚ] = φ(n)/2
    to be a power of 2.

    Args:
        n: Number of sides (≥ 3).

    Returns:
        True if the regular n-gon is constructible.

    >>> is_constructible(3)
    True
    >>> is_constructible(7)
    False
    >>> is_constructible(17)
    True
    """
    if n < 3:
        return False
    # Remove powers of 2
    m = n
    while m % 2 == 0:
        m //= 2
    # Remaining factors must be distinct Fermat primes
    fermat_primes = {3, 5, 17, 257, 65537}
    if m == 1:
        return True
    # Factor out known Fermat primes
    for p in fermat_primes:
        if m % p == 0:
            m //= p
            if m % p == 0:  # Not distinct
                return False
    return m == 1


def constructibility_table():
    """Print constructibility analysis for small n, showing the
    connection between field degrees and compass-and-straightedge construction."""
    print("=" * 70)
    print("APPLICATION 1: Constructible Regular Polygons")
    print("=" * 70)
    print(f"{'n':>4} {'φ(n)':>5} {'φ(n)/2':>6} {'power of 2?':>12} {'constructible?':>15}")
    print("-" * 45)
    for n in range(3, 25):
        phi = euler_totient(n)
        half_phi = phi // 2
        is_pow2 = half_phi > 0 and (half_phi & (half_phi - 1)) == 0
        constr = is_constructible(n)
        print(f"{n:4d} {phi:5d} {half_phi:6d} {'yes' if is_pow2 else 'no':>12} "
              f"{'✓' if constr else '✗':>15}")
    print()


# ──────────────────────────────────────────────────────────────
# APPLICATION 2: Discrete Cosine Transform connections
# ──────────────────────────────────────────────────────────────

def dct_connection(N: int):
    """Show how the real cyclotomic generators connect to DCT basis vectors.

    The DCT-II basis vectors are cos(π(2k+1)j/(2N)), which are
    algebraically related to 2cos(2π·m/n) for appropriate n.

    Args:
        N: Size of the DCT.
    """
    print(f"\n--- DCT-{N} Basis Connection ---")
    print(f"DCT basis vectors use cos(π(2k+1)j/{2*N})")
    print(f"These are evaluations of Chebyshev polynomials at")
    print(f"the real cyclotomic generators α_{{4N}} = 2cos(2π/{4*N})")
    print()
    n = 4 * N
    alpha = real_cyclotomic_generator(n)
    print(f"  α_{{{n}}} = 2cos(2π/{n}) = {alpha:.8f}")
    for j in range(min(N, 6)):
        for k in range(min(N, 6)):
            val = np.cos(np.pi * (2*k + 1) * j / (2 * N))
            cheb_val = chebyshev_power_sum(alpha, (2*k+1)*j) / 2
            if j < 3 and k < 3:
                print(f"  DCT[{j},{k}] = cos(π·{(2*k+1)*j}/{2*N}) = {val:+.6f}")


def dct_demo():
    """Demonstrate DCT connections."""
    print("=" * 70)
    print("APPLICATION 2: Discrete Cosine Transform & Cyclotomic Algebra")
    print("=" * 70)
    print("The DCT — backbone of JPEG, MP3, and video compression —")
    print("is built from the same algebraic objects as our real subfield theory.")
    print("The DCT basis vectors are Chebyshev polynomials evaluated at")
    print("real cyclotomic generators 2cos(2π/n).")
    dct_connection(8)
    print()


# ──────────────────────────────────────────────────────────────
# APPLICATION 3: Cryptographic Key Sizes
# ──────────────────────────────────────────────────────────────

def crypto_field_sizes():
    """Show how the tower ℚ(ζ+ζ⁻¹) ⊂ ℚ(ζ) relates to cryptographic
    parameters in cyclotomic-field-based lattice cryptography."""
    print("=" * 70)
    print("APPLICATION 3: Cyclotomic Fields in Lattice Cryptography")
    print("=" * 70)
    print("Ring-LWE and NTRU use cyclotomic rings ℤ[ζ_n].")
    print("The real subring ℤ[ζ+ζ⁻¹] captures 'half the information'.")
    print()
    print(f"{'n':>6} {'φ(n)':>6} {'dim(full)':>10} {'dim(real)':>10} {'ratio':>6}")
    print("-" * 40)
    for n in [256, 512, 1024, 2048, 4096]:
        # For power-of-2 cyclotomic, φ(n) = n/2
        phi = euler_totient(n) if n <= 100 else n // 2
        real_dim = phi // 2
        print(f"{n:6d} {phi:6d} {phi:10d} {real_dim:10d} {'1:2':>6}")
    print()
    print("In RLWE-based schemes, the real subfield gives a natural")
    print("'folding' that can reduce key sizes by factor 2.")
    print()


# ──────────────────────────────────────────────────────────────
# APPLICATION 4: Quasicrystal Symmetry
# ──────────────────────────────────────────────────────────────

def quasicrystal_demo():
    """Show how real cyclotomic generators relate to quasicrystal symmetry.

    Penrose tilings and other quasicrystals have symmetries described by
    real cyclotomic numbers — exactly the elements ζ + ζ⁻¹ from our theory.
    """
    print("=" * 70)
    print("APPLICATION 4: Quasicrystal Symmetry")
    print("=" * 70)
    print("Quasicrystals with n-fold symmetry live in the real cyclotomic field ℚ(ζ_n + ζ_n⁻¹).")
    print()

    cases = {
        5: "Penrose tilings / icosahedral quasicrystals",
        8: "Ammann-Beenker tilings / octagonal quasicrystals",
        10: "Decagonal quasicrystals (Al-Mn alloys)",
        12: "Dodecagonal quasicrystals",
    }

    for n, name in cases.items():
        alpha = real_cyclotomic_generator(n)
        phi = euler_totient(n)
        dim = phi // 2
        print(f"  n={n:2d}: {name}")
        print(f"        α = 2cos(2π/{n}) = {alpha:+.8f}")
        print(f"        Coordinate field ℚ(α) has degree {dim} over ℚ")
        print(f"        Full symmetry field ℚ(ζ_{n}) has degree {phi} over ℚ")
        print()


if __name__ == "__main__":
    constructibility_table()
    dct_demo()
    crypto_field_sizes()
    quasicrystal_demo()


#!/usr/bin/env python3
"""
Dihedral Symmetry in Cyclotomic Fields — Demonstrations

Concrete numerical examples illustrating the theorems proved in
Algebra/DihedralCyclotomic/Basic.lean.
"""

import numpy as np
from fractions import Fraction

def primitive_root(n: int) -> complex:
    """Return the canonical primitive n-th root of unity e^{2πi/n}."""
    return np.exp(2j * np.pi / n)


def demo_quadratic_relation():
    """
    Theorem: zeta_quadratic_relation
    For nonzero ζ in a field, ζ² - (ζ + ζ⁻¹)·ζ + 1 = 0.
    """
    print("=" * 60)
    print("DEMO 1: The Quadratic Relation  ζ² - (ζ + ζ⁻¹)·ζ + 1 = 0")
    print("=" * 60)
    for n in [3, 4, 5, 7, 8, 10, 12]:
        z = primitive_root(n)
        alpha = z + 1/z  # = 2·cos(2π/n)
        residual = z**2 - alpha * z + 1
        print(f"  n={n:2d}: ζ = e^(2πi/{n}), α = ζ+ζ⁻¹ = {alpha.real:+.6f}, "
              f"residual = {abs(residual):.2e}")
    print()


def demo_involution_fixed_point():
    """
    Theorem: map_zeta_add_inv_of_map_eq_inv
    The involution σ: ζ ↦ ζ⁻¹ fixes ζ + ζ⁻¹.
    """
    print("=" * 60)
    print("DEMO 2: The Involution ζ ↦ ζ⁻¹ Fixes ζ + ζ⁻¹")
    print("=" * 60)
    for n in [3, 5, 7, 11, 13]:
        z = primitive_root(n)
        alpha = z + 1/z
        # Apply σ: ζ ↦ ζ⁻¹
        sigma_alpha = (1/z) + z  # σ(ζ) + σ(ζ⁻¹) = ζ⁻¹ + ζ
        print(f"  n={n:2d}: α = {alpha.real:+.10f}, σ(α) = {sigma_alpha.real:+.10f}, "
              f"diff = {abs(alpha - sigma_alpha):.2e}")
    print()


def demo_real_subfield_generator():
    """
    Show that ζ + ζ⁻¹ = 2·cos(2π/n) generates the maximal real subfield.
    Display the algebraic degree and compare with φ(n)/2.
    """
    print("=" * 60)
    print("DEMO 3: Real Subfield Generator  ζ + ζ⁻¹ = 2·cos(2π/n)")
    print("=" * 60)

    from math import gcd

    def euler_totient(n):
        return sum(1 for k in range(1, n+1) if gcd(k, n) == 1)

    for n in [3, 4, 5, 6, 7, 8, 10, 12, 15, 20]:
        z = primitive_root(n)
        alpha = z + 1/z
        phi_n = euler_totient(n)
        real_degree = phi_n // 2
        print(f"  n={n:2d}: 2cos(2π/{n}) = {alpha.real:+.8f}, "
              f"φ({n})={phi_n}, [ℚ(ζ+ζ⁻¹):ℚ] = φ(n)/2 = {real_degree}")
    print()


def demo_tower_structure():
    """
    Demonstrate the field tower ℚ ⊂ ℚ(ζ+ζ⁻¹) ⊂ ℚ(ζ)
    with degree [ℚ(ζ):ℚ(ζ+ζ⁻¹)] = 2.
    """
    print("=" * 60)
    print("DEMO 4: Tower Structure  ℚ ⊂ ℚ(ζ+ζ⁻¹) ⊂ ℚ(ζ)")
    print("=" * 60)
    from math import gcd

    def euler_totient(n):
        return sum(1 for k in range(1, n+1) if gcd(k, n) == 1)

    for n in [3, 5, 7, 8, 11, 13]:
        phi_n = euler_totient(n)
        print(f"  n={n:2d}: [ℚ(ζ):ℚ] = φ({n}) = {phi_n}, "
              f"[ℚ(ζ+ζ⁻¹):ℚ] = {phi_n//2}, "
              f"[ℚ(ζ):ℚ(ζ+ζ⁻¹)] = 2")
    print()


def demo_primitive_root_nontriviality():
    """
    Theorem: primitiveRoot_ne_inv
    For n ≥ 3, a primitive n-th root ζ satisfies ζ ≠ ζ⁻¹.
    """
    print("=" * 60)
    print("DEMO 5: Nontriviality — ζ ≠ ζ⁻¹ for n ≥ 3")
    print("=" * 60)
    for n in range(1, 13):
        z = primitive_root(n)
        z_inv = 1/z
        diff = abs(z - z_inv)
        status = "ζ = ζ⁻¹" if diff < 1e-10 else "ζ ≠ ζ⁻¹"
        marker = "  ← trivial" if diff < 1e-10 else ""
        print(f"  n={n:2d}: |ζ - ζ⁻¹| = {diff:.8f}  ({status}){marker}")
    print()


def demo_dihedral_symmetry():
    """
    Illustrate dihedral symmetry: the Galois group of ℚ(ζₙ)/ℚ acts on
    the roots, with "rotation" (multiplication by ζ) and "reflection"
    (complex conjugation / inversion).
    """
    print("=" * 60)
    print("DEMO 6: Dihedral Symmetry of Cyclotomic Extensions")
    print("=" * 60)
    n = 7
    z = primitive_root(n)
    print(f"  n = {n}, primitive root ζ = e^(2πi/{n})")
    print(f"  Galois group (ℤ/{n}ℤ)× has order φ({n}) = 6")
    print()
    print("  Galois automorphisms σ_k: ζ ↦ ζ^k for k ∈ (ℤ/7ℤ)×:")
    for k in [1, 2, 3, 4, 5, 6]:
        zk = z**k
        alpha_k = zk + 1/zk
        print(f"    σ_{k}: ζ ↦ ζ^{k}, α ↦ ζ^{k}+ζ^{-k} = {alpha_k.real:+.6f}")
    print()
    print("  The involution σ₆: ζ ↦ ζ⁶ = ζ⁻¹ (complex conjugation)")
    print(f"    σ₆(α) = ζ⁻¹ + ζ = α = {(z+1/z).real:+.6f}  ✓ (fixed!)")
    print()
    print("  The fixed field of {id, σ₆} is ℚ(α) = ℚ(2cos(2π/7))")
    print(f"  [ℚ(ζ):ℚ(α)] = 2  — this is the dihedral reflection!")
    print()


if __name__ == "__main__":
    demo_quadratic_relation()
    demo_involution_fixed_point()
    demo_real_subfield_generator()
    demo_tower_structure()
    demo_primitive_root_nontriviality()
    demo_dihedral_symmetry()


#!/usr/bin/env python3
"""
Visualizations for Dihedral-Cyclotomic Theory

Generate publication-quality figures illustrating the mathematical
structures in the real cyclotomic subfield theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import gcd
import base64
import io


def euler_totient(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_roots_and_real_generator():
    """Visualize roots of unity and their real projections ζ + ζ⁻¹."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, n in enumerate([5, 7, 12]):
        ax = axes[idx]
        # Unit circle
        theta = np.linspace(0, 2*np.pi, 200)
        ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2, linewidth=0.5)

        # Roots of unity
        for k in range(n):
            z = np.exp(2j * np.pi * k / n)
            color = 'red' if gcd(k, n) == 1 else 'gray'
            marker = 'o' if gcd(k, n) == 1 else 'x'
            ax.plot(z.real, z.imag, marker, color=color, markersize=8)
            if gcd(k, n) == 1 and k <= n // 2:
                ax.annotate(f'ζ^{k}', (z.real, z.imag),
                           textcoords="offset points", xytext=(8, 5),
                           fontsize=7)

        # Highlight ζ and ζ⁻¹ pair
        z1 = np.exp(2j * np.pi / n)
        z_inv = np.exp(-2j * np.pi / n)
        alpha = z1.real + z_inv.real  # = 2cos(2π/n)

        # Draw the real projection
        ax.plot([z1.real, z1.real], [0, z1.imag], 'b--', alpha=0.5)
        ax.plot([z_inv.real, z_inv.real], [0, z_inv.imag], 'b--', alpha=0.5)
        ax.plot(alpha/2, 0, 's', color='blue', markersize=10,
               label=f'α/2 = cos(2π/{n})')

        # Axes
        ax.axhline(y=0, color='k', linewidth=0.5)
        ax.axvline(x=0, color='k', linewidth=0.5)
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.set_title(f'n = {n}, φ(n) = {euler_totient(n)}', fontsize=12)
        ax.legend(fontsize=8, loc='lower left')

    fig.suptitle('Roots of Unity and Real Cyclotomic Generators',
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_roots.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_field_tower():
    """Visualize the field tower degrees for various n."""
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = list(range(3, 31))
    phi_vals = [euler_totient(n) for n in ns]
    real_vals = [p // 2 for p in phi_vals]

    x = np.arange(len(ns))
    width = 0.35

    bars1 = ax.bar(x - width/2, phi_vals, width, label='[ℚ(ζ):ℚ] = φ(n)',
                   color='steelblue', alpha=0.8)
    bars2 = ax.bar(x + width/2, real_vals, width,
                   label='[ℚ(ζ+ζ⁻¹):ℚ] = φ(n)/2',
                   color='coral', alpha=0.8)

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Field Extension Degree', fontsize=12)
    ax.set_title('Cyclotomic vs. Real Subfield Degrees', fontsize=14,
                fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(ns, fontsize=8)
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3)

    # Annotate the ratio
    ax.text(0.95, 0.95, 'Index [ℚ(ζ):ℚ(ζ+ζ⁻¹)] = 2 always',
           transform=ax.transAxes, fontsize=10, ha='right', va='top',
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_tower.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_dihedral_symmetry():
    """Visualize the dihedral group action on a cyclotomic extension."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Galois orbits for n=7
    ax = axes[0]
    n = 7
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(theta), np.sin(theta), 'k-', alpha=0.2)

    colors = ['red', 'blue', 'green']
    orbit_pairs = [(1, 6), (2, 5), (3, 4)]
    for i, (k1, k2) in enumerate(orbit_pairs):
        z1 = np.exp(2j * np.pi * k1 / n)
        z2 = np.exp(2j * np.pi * k2 / n)
        ax.plot(z1.real, z1.imag, 'o', color=colors[i], markersize=10)
        ax.plot(z2.real, z2.imag, 'o', color=colors[i], markersize=10)
        # Draw arrow between paired roots
        ax.annotate('', xy=(z2.real, z2.imag),
                   xytext=(z1.real, z1.imag),
                   arrowprops=dict(arrowstyle='<->', color=colors[i],
                                  lw=1.5, alpha=0.6))
        mid = (z1 + z2) / 2
        ax.annotate(f'orbit {i+1}', (mid.real, mid.imag),
                   fontsize=8, ha='center')

    ax.plot(1, 0, 'ko', markersize=8)
    ax.annotate('1', (1, 0), textcoords="offset points", xytext=(8, 5))
    ax.axhline(y=0, color='k', linewidth=0.5, label='Real axis (fixed by conj)')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title('Inversion Orbits on 7th Roots\n(ζ ↔ ζ⁻¹ pairs)', fontsize=11)
    ax.legend(fontsize=8)

    # Right: The dihedral structure
    ax = axes[1]
    # Draw the lattice of subfields
    positions = {
        'ℚ(ζ₇)': (0.5, 1.0),
        'ℚ(ζ₇+ζ₇⁻¹)': (0.5, 0.5),
        'ℚ': (0.5, 0.0),
    }
    for label, (x, y) in positions.items():
        ax.text(x, y, label, fontsize=13, ha='center', va='center',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                        edgecolor='black'))

    # Arrows
    ax.annotate('', xy=(0.5, 0.88), xytext=(0.5, 0.62),
               arrowprops=dict(arrowstyle='-', lw=2))
    ax.text(0.62, 0.75, 'degree 2\n(quadratic)', fontsize=9,
           ha='left', color='red')

    ax.annotate('', xy=(0.5, 0.38), xytext=(0.5, 0.12),
               arrowprops=dict(arrowstyle='-', lw=2))
    ax.text(0.62, 0.25, 'degree 3\n= φ(7)/2', fontsize=9,
           ha='left', color='blue')

    ax.annotate('', xy=(0.35, 0.88), xytext=(0.35, 0.12),
               arrowprops=dict(arrowstyle='-', lw=2, linestyle='dashed'))
    ax.text(0.23, 0.5, 'degree 6\n= φ(7)', fontsize=9,
           ha='right', color='purple')

    ax.set_xlim(0, 1)
    ax.set_ylim(-0.15, 1.15)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Field Tower for n = 7', fontsize=12, fontweight='bold')

    fig.suptitle('Dihedral Symmetry in Cyclotomic Fields', fontsize=14,
                fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_dihedral.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


def viz_chebyshev_connection():
    """Visualize the Chebyshev polynomial connection."""
    fig, ax = plt.subplots(figsize=(10, 6))

    x = np.linspace(-2, 2, 1000)

    # Plot T_k(x) - the power-sum Chebyshev polynomials
    # T_0 = 2, T_1 = x, T_k = x·T_{k-1} - T_{k-2}
    def cheb_values(x_arr, k):
        if k == 0:
            return np.full_like(x_arr, 2.0)
        if k == 1:
            return x_arr.copy()
        t_prev2 = np.full_like(x_arr, 2.0)
        t_prev1 = x_arr.copy()
        for _ in range(2, k + 1):
            t_curr = x_arr * t_prev1 - t_prev2
            t_prev2 = t_prev1
            t_prev1 = t_curr
        return t_prev1

    colors_list = plt.cm.viridis(np.linspace(0.1, 0.9, 6))
    for k in range(1, 7):
        y = cheb_values(x, k)
        ax.plot(x, y, color=colors_list[k-1], linewidth=2,
               label=f'T_{k}(α) = ζ^{k}+ζ^{{-{k}}}')

    # Mark the real cyclotomic generators
    for n in [3, 4, 5, 7]:
        alpha_n = 2 * np.cos(2 * np.pi / n)
        ax.axvline(x=alpha_n, color='gray', linestyle=':', alpha=0.5)
        ax.text(alpha_n, ax.get_ylim()[1] * 0.9, f'α_{n}',
               fontsize=9, ha='center', color='gray')

    ax.set_xlabel('α = ζ + ζ⁻¹', fontsize=12)
    ax.set_ylabel('T_k(α) = ζ^k + ζ^{-k}', fontsize=12)
    ax.set_title('Chebyshev Power Sums: The Bridge Between\n'
                'Cyclotomic Arithmetic and Polynomial Dynamics',
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(alpha=0.3)
    ax.set_ylim(-4, 6)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/viz_chebyshev.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_roots = viz_roots_and_real_generator()
    print("  ✓ Roots of unity visualization")
    b64_tower = viz_field_tower()
    print("  ✓ Field tower degrees")
    b64_dihedral = viz_dihedral_symmetry()
    print("  ✓ Dihedral symmetry")
    b64_chebyshev = viz_chebyshev_connection()
    print("  ✓ Chebyshev connection")
    print("All visualizations saved to PNG files.")

    # Save base64 data for JSON package
    with open('/workspace/request-project/viz_data.txt', 'w') as f:
        f.write("ROOTS:\n")
        f.write(b64_roots + "\n")
        f.write("TOWER:\n")
        f.write(b64_tower + "\n")
        f.write("DIHEDRAL:\n")
        f.write(b64_dihedral + "\n")
        f.write("CHEBYSHEV:\n")
        f.write(b64_chebyshev + "\n")
