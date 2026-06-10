#!/usr/bin/env python3
"""
Applications of Algorithmic Lattice-Reduced Diophantine Certification.

Demonstrates real-world applications of the tropical Diophantine framework:
1. Celestial mechanics: Certifying nonresonance of planetary frequency vectors
2. Lattice cryptography connection: Frequency vectors from lattice problems
3. Molecular dynamics: Vibrational mode certification
"""

import math
import random
import time


# ============================================================
# Core functions (self-contained)
# ============================================================

def l1_norm(k):
    return sum(abs(ki) for ki in k)

def lattice_inner(k, omega):
    return sum(ki * wi for ki, wi in zip(k, omega))

def enumerate_l1_box(n, K):
    import itertools
    for k in itertools.product(range(-K, K + 1), repeat=n):
        if l1_norm(k) <= K:
            yield k

def compute_min_gap(n, K, omega):
    min_gap = float('inf')
    min_k = None
    for k in enumerate_l1_box(n, K):
        if all(ki == 0 for ki in k):
            continue
        val = abs(lattice_inner(list(k), omega))
        if val < min_gap:
            min_gap = val
            min_k = k
    return min_gap, min_k

def brute_force_check(n, K, C, omega):
    for k in enumerate_l1_box(n, K):
        if all(ki == 0 for ki in k):
            continue
        if abs(lattice_inner(list(k), omega)) < C:
            return False, k
    return True, None


# ============================================================
# Application 1: Celestial Mechanics
# ============================================================

def app_celestial_mechanics():
    """
    Certify nonresonance of planetary frequency vectors.

    In the restricted three-body problem, the stability of Lagrange point
    orbits depends on the frequency ratios of libration and orbital motion.
    """
    print("=" * 70)
    print("APPLICATION 1: Celestial Mechanics — Lagrange Point Stability")
    print("=" * 70)

    # Approximate frequencies for Sun-Jupiter L4 point
    # Short-period libration, long-period libration, vertical oscillation
    # These are model values scaled to natural units
    mu = 0.000954  # Sun-Jupiter mass ratio
    omega_sp = math.sqrt(1 - mu)  # Short-period ≈ 1
    omega_lp = math.sqrt(27 * mu / 4)  # Long-period libration
    omega_vert = math.sqrt(1 - (27/4) * mu * (1 - mu))  # Vertical

    omega = [omega_sp, omega_lp, omega_vert]
    print(f"\nSun-Jupiter system (μ = {mu}):")
    print(f"  Short-period freq:  ω₁ = {omega[0]:.8f}")
    print(f"  Long-period freq:   ω₂ = {omega[1]:.8f}")
    print(f"  Vertical freq:      ω₃ = {omega[2]:.8f}")

    print(f"\nDiophantine certification at various scales:")
    print(f"{'K':>5} {'Min gap':>14} {'Min k':>25} {'Time':>10}")
    print("-" * 60)

    for K in [3, 5, 8, 10, 15]:
        t0 = time.time()
        gap, min_k = compute_min_gap(3, K, omega)
        t = time.time() - t0
        print(f"{K:5d} {gap:14.10f} {str(min_k):>25} {t:10.4f}s")

    # Perturbation analysis: how robust is the certificate?
    print(f"\nRobustness analysis (K=10):")
    K = 10
    gap, _ = compute_min_gap(3, K, omega)
    print(f"  Original gap: {gap:.10f}")
    max_eps = gap / K
    print(f"  Maximum tolerable ε: {max_eps:.10f}")
    print(f"  (Frequencies can shift by ±{max_eps:.2e} and remain certified)")

    # Vary mass ratio
    print(f"\nDiophantine gap vs mass ratio (K=8):")
    print(f"{'μ':>12} {'Gap':>14} {'Certified at C=1e-4':>20}")
    print("-" * 50)

    for mu_val in [0.0001, 0.0005, 0.001, 0.005, 0.01, 0.05]:
        omega_test = [
            math.sqrt(1 - mu_val),
            math.sqrt(27 * mu_val / 4),
            math.sqrt(max(0, 1 - (27/4) * mu_val * (1 - mu_val)))
        ]
        gap_test, _ = compute_min_gap(3, 8, omega_test)
        cert = "YES ✓" if gap_test >= 1e-4 else "NO ✗"
        print(f"{mu_val:12.4f} {gap_test:14.10f} {cert:>20}")


# ============================================================
# Application 2: Lattice Cryptography Connection
# ============================================================

def app_cryptography():
    """
    Demonstrate the structural parallel between Diophantine certification
    and lattice hardness in cryptography.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Lattice Cryptography — Hardness as Stability")
    print("=" * 70)

    print("""
The tropical Diophantine condition is structurally identical to a
shortest-vector lower bound in a lifted lattice:

  TropicalDiophantine(K, C, ω) ↔ λ₁(Λ_ω) ≥ threshold

where Λ_ω is a lattice encoding integer relations with ω.

In lattice cryptography, security relies on λ₁ being LARGE.
In celestial mechanics, stability relies on the same quantity.
""")

    # Generate "easy" frequency vectors (rational → short relations exist)
    print("Easy case: Rational frequencies (short relations exist)")
    omega_easy = [1.0, 0.5, 0.25]
    gap_easy, k_easy = compute_min_gap(3, 10, omega_easy)
    print(f"  ω = {omega_easy}")
    print(f"  Gap at K=10: {gap_easy:.10f} (essentially 0)")
    print(f"  Short relation: k = {k_easy}, ⟨k,ω⟩ = {lattice_inner(list(k_easy), omega_easy):.10f}")

    # Generate "hard" frequency vectors (irrational → no short relations)
    print(f"\nHard case: Algebraically independent frequencies")
    omega_hard = [math.sqrt(2), math.sqrt(3), math.sqrt(5)]
    gap_hard, k_hard = compute_min_gap(3, 10, omega_hard)
    print(f"  ω = (√2, √3, √5)")
    print(f"  Gap at K=10: {gap_hard:.10f}")
    print(f"  Shortest near-relation: k = {k_hard}")

    # Show how gap scales with K for different frequency types
    print(f"\nGap scaling comparison:")
    print(f"{'K':>5} {'Irrational gap':>16} {'Near-rational gap':>18}")
    print("-" * 45)

    omega_near_rat = [1.0 + 1e-3, 0.5 + 1e-4, 0.25 + 1e-5]
    for K in [3, 5, 8, 10, 15]:
        g1, _ = compute_min_gap(3, K, omega_hard)
        g2, _ = compute_min_gap(3, K, omega_near_rat)
        print(f"{K:5d} {g1:16.10f} {g2:18.10f}")


# ============================================================
# Application 3: Vibrational Mode Analysis
# ============================================================

def app_molecular_dynamics():
    """
    Certify nonresonance of vibrational frequencies in a model molecule.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Molecular Dynamics — Vibrational Mode Certification")
    print("=" * 70)

    print("""
In molecular dynamics, resonances between vibrational modes cause
energy to flow between different parts of a molecule. The Diophantine
condition certifies that modes are sufficiently nonresonant for
quasi-periodic behavior to persist.
""")

    # Model: 4 vibrational modes of a simple molecule
    # Frequencies chosen from typical molecular scales (in THz)
    random.seed(12345)
    base_freqs = [12.3, 18.7, 25.1, 31.4]  # Model vibrational frequencies
    omega = [f / base_freqs[0] for f in base_freqs]  # Normalize

    print(f"Model molecule with 4 vibrational modes:")
    for i, (f, w) in enumerate(zip(base_freqs, omega)):
        print(f"  Mode {i+1}: {f:.1f} THz (normalized: {w:.6f})")

    print(f"\nResonance certification:")
    print(f"{'K':>5} {'Min gap':>14} {'Near-resonance':>30}")
    print("-" * 55)

    for K in [2, 3, 4, 5, 6, 8]:
        gap, min_k = compute_min_gap(4, K, omega)
        print(f"{K:5d} {gap:14.10f} {str(min_k):>30}")

    # Check effect of isotope substitution (small frequency shift)
    print(f"\nIsotope substitution analysis (K=5):")
    print(f"Replacing hydrogen with deuterium shifts frequencies by ~2%")
    K = 5
    orig_gap, _ = compute_min_gap(4, K, omega)

    shifts = [0.02, 0.01, 0.005, 0.001]
    print(f"\n{'Shift %':>8} {'Original gap':>14} {'Perturbed gap':>14} {'Predicted (C-Kε)':>18} {'Stable':>8}")
    print("-" * 70)

    for shift in shifts:
        omega_shifted = [w * (1 + random.uniform(-shift, shift)) for w in omega]
        eps = max(abs(w1 - w2) for w1, w2 in zip(omega, omega_shifted))
        shifted_gap, _ = compute_min_gap(4, K, omega_shifted)
        predicted = orig_gap - K * eps
        stable = shifted_gap >= predicted
        print(f"{shift*100:7.1f}% {orig_gap:14.10f} {shifted_gap:14.10f} {predicted:18.10f} {'✓' if stable else '✗':>8}")


# ============================================================
# Application 4: Random Frequency Gap Distribution
# ============================================================

def app_gap_distribution():
    """
    Empirical study of the gap distribution for random frequencies.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Random Frequency Gap Distribution")
    print("=" * 70)

    print("""
For random ω ∈ [0,1]ⁿ, the minimum resonance gap over ‖k‖₁ ≤ K
is expected to scale as K^{-n} (up to logarithmic factors).
""")

    random.seed(42)
    n_samples = 200

    for n in [2, 3]:
        print(f"\nDimension n = {n}:")
        print(f"{'K':>5} {'Mean gap':>14} {'K^(-n)':>14} {'Ratio':>10}")
        print("-" * 48)

        for K in [3, 5, 8, 10]:
            gaps = []
            for _ in range(n_samples):
                omega = [random.random() for _ in range(n)]
                gap, _ = compute_min_gap(n, K, omega)
                gaps.append(gap)

            mean_gap = sum(gaps) / len(gaps)
            predicted = K ** (-n)
            ratio = mean_gap / predicted
            print(f"{K:5d} {mean_gap:14.8f} {predicted:14.8f} {ratio:10.4f}")


def main():
    """Run all application demonstrations."""
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     Applications of Lattice-Reduced Diophantine Certification  ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    app_celestial_mechanics()
    app_cryptography()
    app_molecular_dynamics()
    app_gap_distribution()

    print("\n" + "=" * 70)
    print("All applications complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of Algorithmic Lattice-Reduced Diophantine Certification.

This script demonstrates:
1. Brute-force certification of TropicalDiophantine(K, C, ω)
2. LLL-based heuristic certification
3. Comparison of runtimes
4. Perturbation stability experiments
5. Search space cardinality analysis
"""

import math
import time
import random
import sys


# ============================================================
# Core functions (self-contained, no local imports)
# ============================================================

def l1_norm(k):
    """ℓ¹ norm of an integer vector."""
    return sum(abs(ki) for ki in k)


def lattice_inner(k, omega):
    """Lattice inner product ⟨k, ω⟩."""
    return sum(ki * wi for ki, wi in zip(k, omega))


def enumerate_l1_box(n, K):
    """Enumerate all k ∈ ℤⁿ with ‖k‖₁ ≤ K."""
    import itertools
    for k in itertools.product(range(-K, K + 1), repeat=n):
        if l1_norm(k) <= K:
            yield k


def brute_force_check(n, K, C, omega):
    """Brute-force check of TropicalDiophantine(K, C, ω)."""
    for k in enumerate_l1_box(n, K):
        if all(ki == 0 for ki in k):
            continue
        if abs(lattice_inner(list(k), omega)) < C:
            return False, k
    return True, None


def compute_min_gap(n, K, omega):
    """Compute min |⟨k, ω⟩| over nonzero k with ‖k‖₁ ≤ K."""
    min_gap = float('inf')
    min_k = None
    for k in enumerate_l1_box(n, K):
        if all(ki == 0 for ki in k):
            continue
        val = abs(lattice_inner(list(k), omega))
        if val < min_gap:
            min_gap = val
            min_k = k
    return min_gap, min_k


def gram_schmidt(basis):
    """Gram-Schmidt orthogonalization."""
    n = len(basis)
    m = len(basis[0])
    ortho = [list(v) for v in basis]
    mu = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i):
            dot_ij = sum(ortho[i][k] * ortho[j][k] for k in range(m))
            dot_jj = sum(ortho[j][k] * ortho[j][k] for k in range(m))
            if dot_jj < 1e-15:
                mu[i][j] = 0.0
                continue
            mu[i][j] = dot_ij / dot_jj
            for k in range(m):
                ortho[i][k] -= mu[i][j] * ortho[j][k]
    return ortho, mu


def lll_reduce(basis, delta=0.75):
    """LLL lattice basis reduction."""
    n = len(basis)
    B = [list(v) for v in basis]
    m = len(B[0])

    def norm2(v):
        return sum(a * a for a in v)

    k = 1
    iters = 0
    max_iters = 10000
    while k < n and iters < max_iters:
        iters += 1
        ortho, mu = gram_schmidt(B)
        for j in range(k - 1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                for idx in range(m):
                    B[k][idx] -= r * B[j][idx]
                ortho, mu = gram_schmidt(B)
        n2_k = norm2(ortho[k])
        n2_km1 = norm2(ortho[k - 1])
        if n2_k >= (delta - mu[k][k - 1] ** 2) * n2_km1:
            k += 1
        else:
            B[k], B[k - 1] = B[k - 1], B[k]
            k = max(k - 1, 1)
    return B


def lattice_heuristic_gap(n, K, omega, scaling=1e6):
    """LLL-based heuristic: estimate min gap via lattice reduction."""
    dim = n + 1
    basis = []
    for i in range(n):
        row = [0.0] * dim
        row[i] = 1.0
        basis.append(row)
    last_row = [scaling * omega[i] for i in range(n)] + [scaling]
    basis.append(last_row)
    reduced = lll_reduce(basis)
    min_gap = float('inf')
    for vec in reduced:
        k_part = [round(vec[i]) for i in range(n)]
        if all(ki == 0 for ki in k_part):
            continue
        if l1_norm(k_part) <= K:
            val = abs(lattice_inner(k_part, omega))
            min_gap = min(min_gap, val)
    return min_gap


def count_l1_box(n, K):
    """Count |{k ∈ ℤⁿ : ‖k‖₁ ≤ K}| by dynamic programming."""
    dp = [[0] * (K + 1) for _ in range(n + 1)]
    dp[0][0] = 1
    for dim in range(1, n + 1):
        for norm in range(K + 1):
            for abs_v in range(norm + 1):
                mult = 1 if abs_v == 0 else 2
                dp[dim][norm] += mult * dp[dim - 1][norm - abs_v]
    return sum(dp[n][j] for j in range(K + 1))


# ============================================================
# Demonstrations
# ============================================================

def demo_basic_certification():
    """Demo 1: Basic brute-force certification."""
    print("=" * 70)
    print("DEMO 1: Basic Brute-Force Certification")
    print("=" * 70)

    omega = [math.sqrt(2), math.sqrt(3), math.sqrt(5)]
    print(f"\nFrequency vector: ω = (√2, √3, √5)")
    print(f"  ≈ ({omega[0]:.6f}, {omega[1]:.6f}, {omega[2]:.6f})")

    for K in [3, 5, 10, 15]:
        gap, min_k = compute_min_gap(3, K, omega)
        print(f"\n  K = {K}:")
        print(f"    Minimum gap: {gap:.8f}")
        print(f"    Minimizing k: {min_k}")
        print(f"    Certified at C = {gap/2:.8f}? ", end="")
        ok, _ = brute_force_check(3, K, gap / 2, omega)
        print("YES" if ok else "NO")


def demo_comparison():
    """Demo 2: Compare brute force vs LLL heuristic."""
    print("\n" + "=" * 70)
    print("DEMO 2: Brute Force vs LLL Heuristic")
    print("=" * 70)

    omega = [math.sqrt(2), math.sqrt(3), math.sqrt(5)]
    print(f"\nFrequency vector: ω = (√2, √3, √5)")
    print(f"\n{'K':>5} {'BF gap':>12} {'LLL gap':>12} {'BF time':>10} {'LLL time':>10} {'Vectors':>10}")
    print("-" * 65)

    for K in [3, 5, 8, 10, 12, 15]:
        t0 = time.time()
        bf_gap, _ = compute_min_gap(3, K, omega)
        t_bf = time.time() - t0

        t0 = time.time()
        lll_gap = lattice_heuristic_gap(3, K, omega)
        t_lll = time.time() - t0

        count = count_l1_box(3, K)
        print(f"{K:5d} {bf_gap:12.8f} {lll_gap:12.8f} {t_bf:10.4f}s {t_lll:10.4f}s {count:10d}")


def demo_perturbation():
    """Demo 3: Perturbation stability experiment."""
    print("\n" + "=" * 70)
    print("DEMO 3: Perturbation Stability (Theorem Validation)")
    print("=" * 70)

    omega = [math.sqrt(2), math.sqrt(3), math.sqrt(5)]
    K = 8
    print(f"\nBase frequency: ω = (√2, √3, √5)")
    print(f"Order: K = {K}")

    # Compute original gap
    orig_gap, _ = compute_min_gap(3, K, omega)
    print(f"Original gap: {orig_gap:.8f}")

    print(f"\n{'ε':>10} {'C+Kε':>10} {'Predicted C':>12} {'Actual gap':>12} {'Margin':>10} {'Valid':>6}")
    print("-" * 65)

    random.seed(42)
    for eps in [0.0001, 0.0005, 0.001, 0.002, 0.005]:
        # Perturb each coordinate by at most eps
        omega_perturbed = [w + random.uniform(-eps, eps) for w in omega]
        actual_gap, _ = compute_min_gap(3, K, omega_perturbed)

        # Theorem predicts: if gap(ω) ≥ C + K*eps, then gap(ω') ≥ C
        predicted_C = orig_gap - K * eps
        margin = actual_gap - predicted_C
        valid = actual_gap >= predicted_C

        print(f"{eps:10.4f} {orig_gap:10.6f} {predicted_C:12.8f} {actual_gap:12.8f} {margin:10.6f} {'✓' if valid else '✗':>6}")

    print("\nThe stability theorem guarantees: actual gap ≥ predicted C")
    print("All margins should be non-negative (✓)")


def demo_scaling():
    """Demo 4: Search space cardinality and scaling."""
    print("\n" + "=" * 70)
    print("DEMO 4: Search Space Cardinality")
    print("=" * 70)

    print(f"\n{'n':>3} {'K':>5} {'Exact count':>15} {'(2K+1)^n bound':>15} {'Ratio':>10}")
    print("-" * 55)

    for n in [2, 3, 4, 5]:
        for K in [3, 5, 10]:
            if n >= 5 and K >= 10:
                continue  # Too slow for counting
            exact = count_l1_box(n, K)
            bound = (2 * K + 1) ** n
            ratio = exact / bound
            print(f"{n:3d} {K:5d} {exact:15d} {bound:15d} {ratio:10.4f}")


def demo_monotonicity():
    """Demo 5: Certificate monotonicity."""
    print("\n" + "=" * 70)
    print("DEMO 5: Certificate Monotonicity (Theorem Validation)")
    print("=" * 70)

    omega = [math.sqrt(2), math.sqrt(3), math.sqrt(5)]
    print(f"\nFrequency vector: ω = (√2, √3, √5)")
    print(f"\nDemonstrating: K₁ ≤ K₂ and C₁ ≤ C₂ implies certificate transfer")

    print(f"\n{'K':>5} {'Gap(K)':>12}")
    print("-" * 20)

    gaps = {}
    for K in [3, 5, 8, 10, 12, 15, 20]:
        gap, _ = compute_min_gap(3, K, omega)
        gaps[K] = gap
        print(f"{K:5d} {gap:12.8f}")

    print(f"\nMonotonicity check (gap should decrease with K):")
    Ks = sorted(gaps.keys())
    all_mono = True
    for i in range(len(Ks) - 1):
        mono = gaps[Ks[i]] >= gaps[Ks[i+1]]
        if not mono:
            all_mono = False
        print(f"  gap({Ks[i]}) = {gaps[Ks[i]]:.8f} ≥ gap({Ks[i+1]}) = {gaps[Ks[i+1]]:.8f} ? {'✓' if mono else '✗'}")

    print(f"\nAll monotone: {'YES ✓' if all_mono else 'NO ✗'}")
    print("(This validates TropicalDiophantine.mono_order: larger K → potentially smaller gap)")


def demo_witness():
    """Demo 6: Witness-based certification."""
    print("\n" + "=" * 70)
    print("DEMO 6: Witness-Based Certification")
    print("=" * 70)

    omega = [math.sqrt(2), math.sqrt(3)]
    n, K = 2, 10
    print(f"\nFrequency vector: ω = (√2, √3), K = {K}")

    # Compute exact gap (this serves as the witness)
    gap, min_k = compute_min_gap(n, K, omega)
    print(f"Minimum gap: {gap:.10f} at k = {min_k}")

    # The witness certifies TropicalDiophantine(K, gap, ω)
    C = gap
    ok, _ = brute_force_check(n, K, C, omega)
    print(f"Witness certifies TropicalDiophantine({K}, {C:.10f}, ω): {'YES ✓' if ok else 'NO ✗'}")

    # By mono_threshold, also certifies for any C' ≤ C
    for frac in [0.5, 0.1, 0.01]:
        C_weak = C * frac
        ok2, _ = brute_force_check(n, K, C_weak, omega)
        print(f"  Also certifies C' = {C_weak:.10f}: {'YES ✓' if ok2 else 'NO ✗'}")


def main():
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Algorithmic Lattice-Reduced Diophantine Certification Demo    ║")
    print("║                                                                ║")
    print("║  Bridging Tropical KAM Theory and the Geometry of Numbers     ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_basic_certification()
    demo_comparison()
    demo_perturbation()
    demo_scaling()
    demo_monotonicity()
    demo_witness()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
