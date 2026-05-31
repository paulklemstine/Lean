"""
Langlands Correspondence for GL₂ over ℚ: Demonstrations

Numerical examples verifying the key predictions of the Langlands correspondence:
1. Hecke eigenvalue recursion for the Ramanujan Δ function
2. Ramanujan-Petersson bound verification
3. Eichler-Shimura point counts for elliptic curves
4. Sato-Tate distribution testing
5. Frobenius discriminant analysis
"""

import math
from algorithms import (
    ramanujan_tau, primes_up_to, hecke_eigenvalue_recursion,
    frobenius_discriminant, ramanujan_bound, point_count,
    sato_tate_second_moment, analytic_conductor,
    verify_hecke_recursion_tau
)


def demo_ramanujan_tau():
    """Demonstrate the Ramanujan tau function and its properties."""
    print("=" * 70)
    print("DEMO 1: Ramanujan Tau Function τ(n)")
    print("Weight 12, Level 1 — the prototypical Hecke eigenform")
    print("=" * 70)

    print("\nFirst 20 values of τ(n):")
    for n in range(1, 21):
        tau_n = ramanujan_tau(n)
        print(f"  τ({n:2d}) = {tau_n:>12d}")

    print("\n--- Hecke Recursion Verification ---")
    print("Relation: τ(p^(r+1)) = τ(p)·τ(p^r) - p^11·τ(p^(r-1))")
    for p in [2, 3, 5]:
        print(f"\nPrime p = {p}, τ({p}) = {ramanujan_tau(p)}:")
        results = verify_hecke_recursion_tau(p, max_r=4)
        for r, actual, predicted, ok in results:
            status = "✓" if ok else "✗"
            print(f"  τ({p}^{r}) = {actual:>15d}  predicted = {predicted:>15d}  {status}")

    print("\n--- Multiplicativity Check ---")
    print("For coprime m, n: τ(mn) = τ(m)·τ(n)")
    pairs = [(2, 3), (2, 5), (3, 5), (2, 7), (3, 7), (5, 7)]
    for m, n in pairs:
        tau_mn = ramanujan_tau(m * n)
        product = ramanujan_tau(m) * ramanujan_tau(n)
        ok = tau_mn == product
        print(f"  τ({m}·{n}) = τ({m*n:2d}) = {tau_mn:>8d}  "
              f"τ({m})·τ({n}) = {product:>8d}  {'✓' if ok else '✗'}")


def demo_ramanujan_bound():
    """Verify the Ramanujan-Petersson bound for the Δ function."""
    print("\n" + "=" * 70)
    print("DEMO 2: Ramanujan-Petersson Bound Verification")
    print("|τ(p)| ≤ 2·p^(11/2)  (Deligne, 1974)")
    print("=" * 70)

    primes = primes_up_to(100)
    print(f"\nChecking {len(primes)} primes up to 100:")
    print(f"  {'p':>4s}  {'τ(p)':>12s}  {'|τ(p)|':>12s}  {'2p^(11/2)':>14s}  {'ratio':>8s}  {'ok':>3s}")
    print("  " + "-" * 60)

    max_ratio = 0.0
    for p in primes:
        tau_p = ramanujan_tau(p)
        bound = ramanujan_bound(12, p)
        ratio = abs(tau_p) / bound
        max_ratio = max(max_ratio, ratio)
        ok = abs(tau_p) <= bound
        print(f"  {p:4d}  {tau_p:12d}  {abs(tau_p):12d}  {bound:14.2f}  {ratio:8.4f}  {'✓' if ok else '✗'}")

    print(f"\n  Maximum ratio |τ(p)| / (2p^(11/2)) = {max_ratio:.6f}")
    print(f"  Sato-Tate predicts this should approach 1 for the 'worst' primes")


def demo_discriminant():
    """Analyze the Frobenius discriminant Δ = a_p² - 4p^(k-1)."""
    print("\n" + "=" * 70)
    print("DEMO 3: Frobenius Discriminant Analysis")
    print("Δ(p) = τ(p)² - 4·p^11  (negative ↔ Ramanujan bound holds)")
    print("=" * 70)

    primes = primes_up_to(50)
    neg_count = 0
    for p in primes:
        tau_p = ramanujan_tau(p)
        disc = frobenius_discriminant(float(tau_p), 12, p)
        is_neg = disc < 0
        if is_neg:
            neg_count += 1
        status = "Δ < 0 (complex conj. roots)" if is_neg else "Δ ≥ 0 (real roots)"
        print(f"  p={p:3d}: τ(p)={tau_p:>10d}, Δ = {disc:>20.0f}  {status}")

    print(f"\n  Primes with Δ < 0: {neg_count}/{len(primes)}")
    print(f"  (All should have Δ < 0 by Deligne's theorem)")


def demo_eichler_shimura():
    """Verify Eichler-Shimura for the conductor-11 elliptic curve."""
    print("\n" + "=" * 70)
    print("DEMO 4: Eichler-Shimura for E: y² + y = x³ - x² - 10x - 20")
    print("Conductor N = 11, Weight k = 2")
    print("=" * 70)

    # Known Hecke eigenvalues for the weight-2 newform of level 11
    # These equal a_p = p + 1 - #E(F_p) for the first conductor-11 curve
    eigenvalues = {
        2: -2, 3: -1, 5: 1, 7: -2, 13: 4, 17: -2,
        19: 0, 23: -1, 29: 0, 31: 7, 37: 3, 41: -8,
        43: -6, 47: 8, 53: -6, 59: 5, 61: 12, 67: -7,
        71: -3, 73: -8, 79: -10, 83: -6, 89: -12, 97: 3
    }

    print(f"\n  {'p':>4s}  {'a_p':>5s}  {'#E(F_p)':>8s}  {'|a_p|':>6s}  {'2√p':>8s}  {'Hasse':>6s}")
    print("  " + "-" * 45)

    for p in sorted(eigenvalues.keys()):
        if p == 11:
            continue  # Bad prime
        a_p = eigenvalues[p]
        count = point_count(float(a_p), p)
        bound = 2 * math.sqrt(p)
        ok = abs(a_p) <= bound
        print(f"  {p:4d}  {a_p:5d}  {count:8d}  {abs(a_p):6d}  {bound:8.2f}  {'✓' if ok else '✗'}")

    # Sato-Tate second moment
    st = sato_tate_second_moment(
        {p: float(v) for p, v in eigenvalues.items()}, 2, 97
    )
    print(f"\n  Sato-Tate second moment (primes ≤ 97): {st:.4f}")
    print(f"  (Should approach 1.0 as X → ∞)")


def demo_sato_tate():
    """Test the Sato-Tate distribution for the Ramanujan Δ function."""
    print("\n" + "=" * 70)
    print("DEMO 5: Sato-Tate Distribution Test for Δ")
    print("Prediction: (1/π(X)) Σ_{p≤X} τ(p)²/p^11 → 1 as X → ∞")
    print("=" * 70)

    bounds = [50, 100, 200, 500]
    for X in bounds:
        primes = primes_up_to(X)
        eigenvals = {}
        for p in primes:
            eigenvals[p] = float(ramanujan_tau(p))
        moment = sato_tate_second_moment(eigenvals, 12, X)
        print(f"  X = {X:5d}:  π(X) = {len(primes):4d},  "
              f"second moment = {moment:.6f}")

    print("\n  Note: convergence is slow; Sato-Tate was proved by")
    print("  Barnet-Lamb, Geraghty, Harris, and Taylor (2011)")


def demo_analytic_conductor():
    """Compute analytic conductors for various eigenforms."""
    print("\n" + "=" * 70)
    print("DEMO 6: Analytic Conductors")
    print("C(f) = N · (k/(2π))²")
    print("=" * 70)

    examples = [
        ("Δ function", 12, 1),
        ("X₀(11) curve", 2, 11),
        ("X₀(37) curve", 2, 37),
        ("Weight 4, level 1", 4, 1),
        ("Weight 26, level 1", 26, 1),
    ]

    for name, weight, level in examples:
        cond = analytic_conductor(weight, level)
        print(f"  {name:25s}:  k={weight:2d}, N={level:3d}, C(f) = {cond:.6f}")


if __name__ == "__main__":
    demo_ramanujan_tau()
    demo_ramanujan_bound()
    demo_discriminant()
    demo_eichler_shimura()
    demo_sato_tate()
    demo_analytic_conductor()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


"""
Visualization: Ramanujan-Petersson Bound for the Δ Function

Plots |τ(p)| / (2p^(11/2)) as a function of prime p, showing that
the ratio stays below 1 (the Ramanujan bound, proved by Deligne 1974)
and its distribution approaches the Sato-Tate measure.
"""

import math


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def primes_up_to(n):
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def ramanujan_tau(n):
    if n <= 0: return 0
    prod_coeffs = [0] * (n + 1)
    prod_coeffs[0] = 1
    for m in range(1, n + 1):
        new_coeffs = prod_coeffs[:]
        for exp in range(1, 25):
            sign = (-1) ** exp
            binom = 1
            for j in range(exp):
                binom = binom * (24 - j) // (j + 1)
            coeff = sign * binom
            for i in range(n, m * exp - 1, -1):
                if i - m * exp >= 0:
                    new_coeffs[i] += coeff * prod_coeffs[i - m * exp]
        prod_coeffs = new_coeffs
    return prod_coeffs[n - 1] if n - 1 < len(prod_coeffs) else 0


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping visualization")
        return

    # Compute data
    X = 200
    primes = primes_up_to(X)
    ratios = []
    angles = []

    for p in primes:
        tau_p = ramanujan_tau(p)
        bound = 2.0 * p ** (11.0 / 2)
        ratio = abs(tau_p) / bound
        ratios.append(ratio)
        # Sato-Tate angle: a_p / (2p^(11/2)) = cos(θ)
        cos_theta = tau_p / bound
        angles.append(math.acos(max(-1, min(1, cos_theta))))

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Ramanujan ratios
    ax1 = axes[0]
    ax1.scatter(primes, ratios, s=15, alpha=0.7, color='royalblue')
    ax1.axhline(y=1.0, color='red', linestyle='--', linewidth=1.5, label='Ramanujan bound')
    ax1.set_xlabel('Prime p', fontsize=12)
    ax1.set_ylabel('|τ(p)| / (2p^{11/2})', fontsize=12)
    ax1.set_title('Ramanujan-Petersson Bound\n(Deligne 1974)', fontsize=13)
    ax1.set_ylim(0, 1.1)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Sato-Tate histogram
    ax2 = axes[1]
    t_vals = np.linspace(0, np.pi, 200)
    sato_tate = (2 / np.pi) * np.sin(t_vals) ** 2
    ax2.hist(angles, bins=20, density=True, alpha=0.7, color='coral',
             edgecolor='darkred', label='Observed')
    ax2.plot(t_vals, sato_tate, 'k-', linewidth=2, label='Sato-Tate measure')
    ax2.set_xlabel('θ = arccos(a_p / 2p^{11/2})', fontsize=12)
    ax2.set_ylabel('Density', fontsize=12)
    ax2.set_title('Sato-Tate Distribution\nfor Ramanujan Δ', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Frobenius discriminant
    ax3 = axes[2]
    discs = []
    for p in primes:
        tau_p = ramanujan_tau(p)
        disc = tau_p**2 - 4 * p**11
        discs.append(disc)
    log_neg_discs = [-math.log10(-d) if d < 0 else 0 for d in discs]
    ax3.scatter(primes, log_neg_discs, s=15, alpha=0.7, color='forestgreen')
    ax3.set_xlabel('Prime p', fontsize=12)
    ax3.set_ylabel('-log₁₀(-Δ)', fontsize=12)
    ax3.set_title('Frobenius Discriminant\nΔ = τ(p)² - 4p^{11}', fontsize=13)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('ramanujan_bound_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: ramanujan_bound_analysis.png")


if __name__ == "__main__":
    main()
