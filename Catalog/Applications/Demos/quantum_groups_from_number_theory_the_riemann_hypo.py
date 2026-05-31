#!/usr/bin/env python3
"""
Demo: Quantum Group Casimir Spectra and the Zeta Quantum Group Conjecture.

Demonstrates the key mathematical structures and runs the GUE statistics test.
"""

import math
import cmath
from algorithms import (
    q_number, q_number_complex, classical_casimir, q_casimir,
    q_casimir_complex, spectral_count, spectral_gap, spectral_zeta_partial,
    casimir_inverse, is_casimir_value, casimir_interaction,
    normalized_spacings, spacing_variance, compute_gue_test
)


def demo_classical_casimir():
    """Demonstrate properties of the classical Casimir spectrum."""
    print("=" * 60)
    print("CLASSICAL CASIMIR SPECTRUM: C(n) = n(n+1)")
    print("=" * 60)

    print("\nFirst 15 Casimir eigenvalues:")
    for n in range(15):
        c = classical_casimir(n)
        gap = spectral_gap(n)
        print(f"  C({n:2d}) = {c:4d}    gap to next = {gap:3d}    even? {c % 2 == 0}")

    print("\nSpectral counting function N(T):")
    for T in [10, 20, 50, 100, 200, 500, 1000]:
        count = spectral_count(T)
        sqrt_bound = int(math.isqrt(T)) + 1
        print(f"  N({T:4d}) = {count:3d}    bound √T+1 = {sqrt_bound:3d}")

    print("\nInverse function (recovering n from C(n)):")
    for n in range(10):
        c = classical_casimir(n)
        recovered = casimir_inverse(c)
        print(f"  sqrt_floor(C({n})) = sqrt_floor({c}) = {recovered}  ✓" if recovered == n else f"  FAIL")


def demo_non_squareness():
    """Demonstrate that n(n+1) is never a perfect square for n >= 1."""
    print("\n" + "=" * 60)
    print("NON-SQUARENESS: n(n+1) is never a perfect square for n ≥ 1")
    print("=" * 60)

    print("\nChecking first 1000 values:")
    for n in range(1, 1001):
        c = classical_casimir(n)
        sqrt_c = int(math.isqrt(c))
        if sqrt_c * sqrt_c == c:
            print(f"  COUNTEREXAMPLE: C({n}) = {c} = {sqrt_c}²")
            return
    print("  All verified: no perfect squares found (as proved in Lean).")


def demo_interaction():
    """Demonstrate the super-additivity and interaction decomposition."""
    print("\n" + "=" * 60)
    print("CASIMIR INTERACTION: C(n+m) = C(n) + C(m) + 2nm")
    print("=" * 60)

    pairs = [(1, 1), (2, 3), (5, 7), (10, 10), (3, 4)]
    for n, m in pairs:
        cn = classical_casimir(n)
        cm = classical_casimir(m)
        cnm = classical_casimir(n + m)
        interaction = casimir_interaction(n, m)
        print(f"  C({n}+{m}) = C({n+m}) = {cnm} = C({n}) + C({m}) + 2·{n}·{m} = {cn} + {cm} + {interaction} = {cn + cm + interaction}")


def demo_spectral_zeta():
    """Demonstrate the telescoping spectral zeta sum."""
    print("\n" + "=" * 60)
    print("SPECTRAL ZETA: Σ 1/(k(k+1)) = N/(N+1)")
    print("=" * 60)

    for N in [1, 5, 10, 50, 100, 1000, 10000]:
        computed = spectral_zeta_partial(N)
        exact = N / (N + 1)
        print(f"  N={N:5d}: computed = {computed:.10f}  exact = {exact:.10f}  error = {abs(computed - exact):.2e}")


def demo_q_numbers():
    """Demonstrate q-number deformation."""
    print("\n" + "=" * 60)
    print("Q-NUMBERS: [n]_q = (q^n - q^{-n}) / (q - q^{-1})")
    print("=" * 60)

    print("\nq = 2:")
    for n in range(8):
        print(f"  [{n}]_2 = {q_number(2.0, n):.4f}  (classical: {n})")

    print("\nq → 1 (q = 1.001):")
    for n in range(8):
        print(f"  [{n}]_1.001 = {q_number(1.001, n):.4f}  (classical: {n})")


def demo_gue_conjecture():
    """Run the GUE statistics test for the zeta quantum group."""
    print("\n" + "=" * 60)
    print("ZETA QUANTUM GROUP CONJECTURE TEST")
    print("=" * 60)

    # First Riemann zero
    gamma1 = 14.134725141734693

    # q = e^{2πi·γ₁}
    q = cmath.exp(2j * cmath.pi * gamma1)
    print(f"\nγ₁ = {gamma1}")
    print(f"q = e^(2πi·γ₁) = {q}")
    print(f"|q| = {abs(q):.10f}")

    # Classical case first
    N = 500
    classical_eigenvalues = [float(classical_casimir(n)) for n in range(N)]
    classical_var = spacing_variance(classical_eigenvalues)
    print(f"\nClassical spectrum (q=1, N={N}):")
    print(f"  Spacing variance = {classical_var:.6f}  (expected: ~0 for rigid spectrum)")

    # q-deformed case
    print(f"\nq-Casimir spectrum (q = e^(2πiγ₁), N={N}):")
    q_eigenvalues = []
    for n in range(N):
        val = q_casimir_complex(q, n)
        q_eigenvalues.append(abs(val))
    q_eigenvalues.sort()

    q_var = spacing_variance(q_eigenvalues)
    print(f"  Spacing variance = {q_var:.6f}")
    print(f"  GUE prediction: ~0.286")
    print(f"  Poisson prediction: ~1.0")

    if q_var < 0.1:
        print("  → Result: RIGID (like classical) — conjecture needs modification")
    elif q_var < 0.35:
        print("  → Result: NEAR GUE — conjecture is supported!")
    elif q_var < 0.5:
        print("  → Result: INTERMEDIATE — inconclusive")
    else:
        print("  → Result: NEAR POISSON — conjecture is falsified at this level")

    # Also test with different q values
    print("\nVariance scan over different q values:")
    for q_real in [0.5, 0.9, 1.1, 2.0, 3.0, math.e]:
        eigs = sorted([q_casimir(q_real, n) for n in range(N)])
        var = spacing_variance(eigs)
        print(f"  q = {q_real:.2f}: variance = {var:.6f}")


def demo_level_repulsion():
    """Demonstrate level repulsion properties."""
    print("\n" + "=" * 60)
    print("LEVEL REPULSION: min |C(a) - C(b)| for a ≠ b")
    print("=" * 60)

    N = 50
    casimir_values = [classical_casimir(n) for n in range(N)]

    min_gap = float('inf')
    for i in range(N):
        for j in range(i + 1, N):
            gap = abs(casimir_values[i] - casimir_values[j])
            if gap < min_gap:
                min_gap = gap

    print(f"  Minimum gap among first {N} Casimir values: {min_gap}")
    print(f"  (Proved lower bound: 2)")

    # Check no unit gaps
    has_unit_gap = False
    for i in range(N):
        for j in range(i + 1, N):
            if abs(casimir_values[i] - casimir_values[j]) == 1:
                has_unit_gap = True
                break
    print(f"  Any unit gaps? {'YES ✗' if has_unit_gap else 'NO ✓ (as proved)'}")


if __name__ == "__main__":
    demo_classical_casimir()
    demo_non_squareness()
    demo_interaction()
    demo_spectral_zeta()
    demo_q_numbers()
    demo_level_repulsion()
    demo_gue_conjecture()
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Classical Casimir Spectrum and Spectral Gaps.
Self-contained matplotlib script.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def classical_casimir(n: int) -> int:
    return n * (n + 1)


def spectral_count(T: int) -> int:
    count = 0
    n = 0
    while n * (n + 1) <= T:
        count += 1
        n += 1
    return count


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Classical Casimir Spectrum: C(n) = n(n+1)', fontsize=16)

    # Plot 1: Casimir eigenvalues
    ax = axes[0, 0]
    N = 30
    ns = list(range(N))
    casimirs = [classical_casimir(n) for n in ns]
    ax.plot(ns, casimirs, 'bo-', markersize=4, label='C(n) = n(n+1)')
    ax.plot(ns, [n**2 for n in ns], 'r--', alpha=0.7, label='n²')
    ax.plot(ns, [(n+1)**2 for n in ns], 'g--', alpha=0.7, label='(n+1)²')
    ax.set_xlabel('n')
    ax.set_ylabel('C(n)')
    ax.set_title('Casimir Eigenvalues')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Spectral gaps
    ax = axes[0, 1]
    gaps = [2 * (n + 1) for n in ns[:-1]]
    ax.bar(ns[:-1], gaps, color='steelblue', alpha=0.7)
    ax.set_xlabel('n')
    ax.set_ylabel('Gap = 2(n+1)')
    ax.set_title('Spectral Gaps (Linearly Growing)')
    ax.grid(True, alpha=0.3)

    # Plot 3: Spectral counting function
    ax = axes[1, 0]
    T_values = list(range(1, 201))
    counts = [spectral_count(T) for T in T_values]
    sqrt_bounds = [int(math.isqrt(T)) + 1 for T in T_values]
    ax.plot(T_values, counts, 'b-', label='N(T)', linewidth=2)
    ax.plot(T_values, sqrt_bounds, 'r--', label='√T + 1 (upper bound)', linewidth=1.5)
    ax.plot(T_values, [math.sqrt(T) for T in T_values], 'g--', label='√T', linewidth=1.5)
    ax.set_xlabel('T')
    ax.set_ylabel('Count')
    ax.set_title('Spectral Counting Function (Weyl\'s Law)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Normalized spacings (constant = 1 for rigid spectrum)
    ax = axes[1, 1]
    N_large = 100
    eigenvalues = [float(classical_casimir(n)) for n in range(N_large)]
    spacings = [eigenvalues[i+1] - eigenvalues[i] for i in range(len(eigenvalues)-1)]
    mean_spacing = sum(spacings) / len(spacings)
    normalized = [s / mean_spacing for s in spacings]
    ax.plot(range(len(normalized)), normalized, 'b-', linewidth=1.5)
    ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.7, label='Mean = 1')
    ax.set_xlabel('Level index')
    ax.set_ylabel('Normalized spacing')
    ax.set_title('Normalized Spacings (Rigid: always > 0)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('casimir_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved casimir_spectrum.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: GUE Statistics Test for the Zeta Quantum Group.
Self-contained matplotlib script.
"""

import math
import cmath
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def q_number_complex(q: complex, n: int) -> complex:
    if abs(q - 1.0) < 1e-15:
        return complex(n)
    if abs(q) < 1e-15:
        return complex(0)
    qn = q ** n
    qinv_n = (1.0 / q) ** n
    return (qn - qinv_n) / (q - 1.0 / q)


def q_casimir_complex(q: complex, n: int) -> complex:
    return q_number_complex(q, n) * q_number_complex(q, n + 1)


def normalized_spacings(eigenvalues):
    if len(eigenvalues) < 2:
        return []
    spacings = [eigenvalues[i + 1] - eigenvalues[i] for i in range(len(eigenvalues) - 1)]
    mean_spacing = sum(spacings) / len(spacings)
    if mean_spacing == 0:
        return spacings
    return [s / mean_spacing for s in spacings]


def wigner_surmise(s):
    return (math.pi / 2) * s * math.exp(-math.pi * s ** 2 / 4)


def main():
    gamma1 = 14.134725141734693
    q = cmath.exp(2j * cmath.pi * gamma1)
    N = 500

    # Compute q-Casimir spectrum
    q_eigenvalues = sorted([abs(q_casimir_complex(q, n)) for n in range(N)])

    # Classical Casimir spectrum
    classical_eigenvalues = [float(n * (n + 1)) for n in range(N)]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle(f'Zeta Quantum Group: q = exp(2πiγ₁), γ₁ ≈ {gamma1:.4f}', fontsize=14)

    # Plot 1: Classical vs q-deformed spectrum
    ax = axes[0, 0]
    ax.plot(range(min(50, N)), classical_eigenvalues[:50], 'b-', label='Classical C(n)', linewidth=2)
    ax.plot(range(min(50, N)), q_eigenvalues[:50], 'r-', label='|C_q(n)| (sorted)', linewidth=2, alpha=0.7)
    ax.set_xlabel('Index')
    ax.set_ylabel('Eigenvalue')
    ax.set_title('Classical vs q-Deformed Casimir Spectrum')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Spacing distribution comparison
    ax = axes[0, 1]
    q_spacings = normalized_spacings(q_eigenvalues)
    classical_spacings = normalized_spacings(classical_eigenvalues)

    if q_spacings:
        ax.hist(q_spacings, bins=40, density=True, alpha=0.6, color='red', label='q-Casimir')
    if classical_spacings:
        ax.hist(classical_spacings, bins=40, density=True, alpha=0.4, color='blue', label='Classical')

    # Theoretical curves
    s_range = np.linspace(0, 4, 200)
    wigner = [(math.pi / 2) * s * math.exp(-math.pi * s ** 2 / 4) for s in s_range]
    poisson = [math.exp(-s) for s in s_range]
    ax.plot(s_range, wigner, 'k-', linewidth=2, label='GUE (Wigner)')
    ax.plot(s_range, poisson, 'g--', linewidth=2, label='Poisson')
    ax.set_xlabel('Normalized spacing s')
    ax.set_ylabel('P(s)')
    ax.set_title('Nearest-Neighbor Spacing Distribution')
    ax.legend()
    ax.set_xlim(0, 4)
    ax.grid(True, alpha=0.3)

    # Plot 3: Variance scan over q values
    ax = axes[1, 0]
    q_values = np.linspace(0.1, 5.0, 50)
    variances = []
    for q_real in q_values:
        eigs = sorted([q_real ** n * (q_real ** n - 1) / (q_real - 1) *
                        q_real ** (n + 1) * (q_real ** (n + 1) - 1) / (q_real - 1)
                        if q_real != 1.0 else float(n * (n + 1))
                        for n in range(200)])
        ns = normalized_spacings(eigs)
        if ns:
            mean = sum(ns) / len(ns)
            var = sum((s - mean) ** 2 for s in ns) / len(ns)
        else:
            var = 0.0
        variances.append(var)

    ax.plot(q_values, variances, 'b-', linewidth=2)
    ax.axhline(y=0.286, color='r', linestyle='--', label='GUE (0.286)')
    ax.axhline(y=1.0, color='g', linestyle='--', label='Poisson (1.0)')
    ax.axhline(y=0.0, color='purple', linestyle='--', label='Rigid (0.0)')
    ax.set_xlabel('q (real)')
    ax.set_ylabel('Spacing Variance')
    ax.set_title('Spacing Variance vs Deformation Parameter')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Spectral zeta partial sums
    ax = axes[1, 1]
    Ns = list(range(1, 101))
    partial_sums = [sum(1.0 / ((k + 1) * (k + 2)) for k in range(n)) for n in Ns]
    exact = [n / (n + 1) for n in Ns]
    ax.plot(Ns, partial_sums, 'b-', linewidth=2, label='Computed')
    ax.plot(Ns, exact, 'r--', linewidth=1.5, label='N/(N+1)')
    ax.axhline(y=1.0, color='green', linestyle=':', label='Limit = 1')
    ax.set_xlabel('N')
    ax.set_ylabel('Σ 1/(k(k+1))')
    ax.set_title('Spectral Zeta Partial Sums (Telescoping)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('gue_test.png', dpi=150, bbox_inches='tight')
    print("Saved gue_test.png")

    # Print summary statistics
    q_var = 0.0
    if q_spacings:
        mean = sum(q_spacings) / len(q_spacings)
        q_var = sum((s - mean) ** 2 for s in q_spacings) / len(q_spacings)
    print(f"\nq-Casimir spacing variance: {q_var:.6f}")
    print(f"GUE prediction: 0.286")
    print(f"Result: {'NEAR GUE' if 0.2 < q_var < 0.35 else 'NOT GUE'}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Level Repulsion in the Casimir Spectrum.
Self-contained matplotlib script.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def classical_casimir(n: int) -> int:
    return n * (n + 1)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle('Level Repulsion in the Casimir Spectrum', fontsize=14)

    N = 40

    # Plot 1: Casimir values on number line showing gaps
    ax = axes[0]
    casimirs = [classical_casimir(n) for n in range(N)]
    for i, c in enumerate(casimirs):
        ax.plot(c, 0, 'b|', markersize=20, markeredgewidth=2)
        if i < 15:
            ax.annotate(f'{c}', (c, 0.02), ha='center', fontsize=7, rotation=45)
    ax.set_xlim(-5, casimirs[20])
    ax.set_ylim(-0.1, 0.15)
    ax.set_xlabel('Eigenvalue')
    ax.set_title('Casimir Eigenvalues on Number Line')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_yticks([])

    # Plot 2: Gap distribution (all pairwise)
    ax = axes[1]
    N_small = 25
    casimirs_small = [classical_casimir(n) for n in range(N_small)]
    all_gaps = []
    for i in range(N_small):
        for j in range(i + 1, N_small):
            all_gaps.append(abs(casimirs_small[i] - casimirs_small[j]))

    ax.hist(all_gaps, bins=50, color='steelblue', alpha=0.7, edgecolor='black')
    ax.axvline(x=2, color='red', linewidth=2, linestyle='--', label='Min gap = 2 (proved)')
    ax.axvline(x=1, color='orange', linewidth=2, linestyle=':', label='Gap = 1 (impossible, proved)')
    ax.set_xlabel('|C(a) - C(b)|')
    ax.set_ylabel('Count')
    ax.set_title('Pairwise Gap Distribution')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 3: Consecutive gaps showing 2(n+1) growth
    ax = axes[2]
    ns_plot = list(range(30))
    consecutive_gaps = [classical_casimir(n + 1) - classical_casimir(n) for n in ns_plot]
    ax.bar(ns_plot, consecutive_gaps, color='coral', alpha=0.7, edgecolor='black')
    ax.plot(ns_plot, [2 * (n + 1) for n in ns_plot], 'k-', linewidth=2, label='2(n+1)')
    ax.axhline(y=2, color='green', linewidth=1, linestyle='--', label='Minimum gap = 2')
    ax.set_xlabel('Level n')
    ax.set_ylabel('Gap C(n+1) - C(n)')
    ax.set_title('Consecutive Gaps = 2(n+1)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('level_repulsion.png', dpi=150, bbox_inches='tight')
    print("Saved level_repulsion.png")


if __name__ == "__main__":
    main()
