#!/usr/bin/env python3
"""
Demo: Learning with Errors — Hardness Reduction Parameters

Demonstrates the parameter relationships in Regev's LWE reduction:
- Error width αq and its effect on security
- Approximation factor γ = n/(αq) for the lattice problem
- Noise flooding ratio and statistical distance
- BKZ attack cost estimates
"""

import math


def lwe_approx_factor(n: int, alpha: float, q: int) -> float:
    """Compute the approximation factor γ = n/(αq)."""
    return n / (alpha * q)


def regev_modulus_check(n: int) -> tuple[int, bool]:
    """Check if q = n² satisfies Regev's modulus condition q ≥ 2√n."""
    q = n * n
    threshold = 2 * math.sqrt(n)
    return q, q >= threshold


def noise_flooding_ratio(signal_bound: float, noise_width: float) -> float:
    """Compute the flooding ratio s/B."""
    return noise_width / signal_bound


def statistical_distance_bound(signal_bound: float, noise_width: float) -> float:
    """Upper bound on statistical distance: B/s."""
    return signal_bound / noise_width


def bkz_attack_cost(n: int, q: int, alpha: float) -> float:
    """Estimate BKZ attack cost in log2 operations.

    Uses the standard estimate: cost ≈ 2^(0.292 * β) where
    β ≈ n * log(q) / (log(q) - log(alpha * q)) for optimal blocksize.
    """
    if alpha * q <= 1:
        return float('inf')
    log_q = math.log2(q)
    log_aq = math.log2(alpha * q)
    if log_q <= log_aq:
        return float('inf')
    beta = n * log_q / (log_q - log_aq)
    return 0.292 * beta


def hybrid_advantage_bound(n: int, per_column_eps: float) -> float:
    """Total distinguishing advantage ≤ n * ε."""
    return n * per_column_eps


def print_section(title: str):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


def main():
    print("Learning with Errors: Hardness Reduction Parameter Analysis")
    print("=" * 60)

    # Section 1: Parameter survey
    print_section("1. LWE Parameters and Approximation Factors")
    print(f"{'n':>4} {'q':>8} {'α':>10} {'αq':>10} {'γ=n/(αq)':>12} {'2√n':>8} {'q≥2√n':>6}")
    print("-" * 60)

    params = [
        (64, 64**2, 1.0 / (64 * math.sqrt(64))),
        (128, 128**2, 1.0 / (128 * math.sqrt(128))),
        (256, 256**2, 1.0 / (256 * math.sqrt(256))),
        (512, 512**2, 1.0 / (512 * math.sqrt(512))),
        (1024, 1024**2, 1.0 / (1024 * math.sqrt(1024))),
    ]

    for n, q, alpha in params:
        gamma = lwe_approx_factor(n, alpha, q)
        two_sqrt_n = 2 * math.sqrt(n)
        check = "✓" if q >= two_sqrt_n else "✗"
        print(f"{n:4d} {q:8d} {alpha:10.6f} {alpha*q:10.4f} {gamma:12.4f} {two_sqrt_n:8.2f} {check:>6}")

    # Section 2: Noise flooding
    print_section("2. Noise Flooding Analysis")
    print(f"{'B':>8} {'s':>8} {'s/B':>8} {'B/s':>10} {'1/ε':>8} {'ε':>10}")
    print("-" * 54)

    for B in [1.0, 10.0, 100.0]:
        for ratio in [10, 100, 1000]:
            s = B * ratio
            flood = noise_flooding_ratio(B, s)
            stat_dist = statistical_distance_bound(B, s)
            epsilon = 1.0 / ratio
            print(f"{B:8.1f} {s:8.1f} {flood:8.1f} {stat_dist:10.6f} {ratio:8d} {epsilon:10.6f}")

    # Section 3: BKZ attack costs
    print_section("3. BKZ Attack Cost Estimates (log₂ operations)")
    print(f"{'n':>4} {'q':>8} {'α':>10} {'cost':>10} {'NIST level':>12}")
    print("-" * 48)

    nist_levels = {128: "I", 192: "III", 256: "V"}

    for n in [256, 512, 768, 1024]:
        q = n * n
        alpha = 1.0 / (n * math.sqrt(n))
        cost = bkz_attack_cost(n, q, alpha)
        level = "—"
        for threshold, name in sorted(nist_levels.items()):
            if cost >= threshold:
                level = name
        print(f"{n:4d} {q:8d} {alpha:10.6f} {cost:10.1f} {level:>12}")

    # Section 4: Hybrid argument
    print_section("4. Hybrid Argument: Advantage Accumulation")
    print(f"{'n':>4} {'ε/column':>12} {'n·ε':>12} {'negligible?':>12}")
    print("-" * 44)

    for n in [64, 128, 256, 512, 1024]:
        eps = 2.0 ** (-n)  # negligible per-column advantage
        total = hybrid_advantage_bound(n, eps)
        negl = "yes" if total < 2**(-40) else "no"
        print(f"{n:4d} {eps:12.2e} {total:12.2e} {negl:>12}")

    # Section 5: Regev modulus condition
    print_section("5. Regev Modulus Condition: q = n² ≥ 2√n")
    for n in range(1, 20):
        q, satisfied = regev_modulus_check(n)
        status = "✓" if satisfied else "✗"
        print(f"  n={n:2d}: q={q:4d}, 2√n={2*math.sqrt(n):.2f}, {status}")

    # Section 6: Quantum vs Classical gap
    print_section("6. Quantum vs Classical Reduction Gap")
    print(f"{'n':>4} {'γ_quantum':>12} {'γ_classical':>14} {'ratio':>8}")
    print("-" * 42)

    for n in [64, 128, 256, 512, 1024]:
        alpha = 1.0 / math.sqrt(n)
        gamma_q = n / alpha  # Regev: γ = Õ(n/α)
        gamma_c = n**2 / alpha  # Peikert classical: γ = Õ(n²/α)
        print(f"{n:4d} {gamma_q:12.1f} {gamma_c:14.1f} {gamma_c/gamma_q:8.1f}")

    # Section 7: Conjecture test
    print_section("7. Noise Threshold Conjecture Test")
    print("Testing if α* · q / √(ln n) → constant")
    print(f"{'n':>4} {'q=n²':>8} {'√(ln n)':>10} {'C₁·√lnn/q':>12} {'C₂·√lnn/q':>12}")
    print("-" * 50)

    for n in [4, 8, 16, 32, 64, 128, 256]:
        q = n * n
        sqrt_log_n = math.sqrt(math.log(n))
        c1_val = 1.0 * sqrt_log_n / q
        c2_val = 2.0 * sqrt_log_n / q
        print(f"{n:4d} {q:8d} {sqrt_log_n:10.4f} {c1_val:12.6f} {c2_val:12.6f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: LWE Security Landscape

Plots the relationship between LWE dimension, modulus, error rate,
and the resulting security level and approximation factor.
"""

import math

def compute_security_data():
    """Compute security parameters for various LWE dimensions."""
    dimensions = list(range(64, 1025, 32))
    results = []
    for n in dimensions:
        q = n * n
        alpha = 1.0 / (n * math.sqrt(n))
        alpha_q = alpha * q
        gamma = n / alpha_q
        # BKZ cost estimate
        if alpha_q > 1:
            log_q = math.log2(q)
            log_aq = math.log2(alpha_q)
            if log_q > log_aq:
                beta = n * log_q / (log_q - log_aq)
                cost = 0.292 * beta
            else:
                cost = float('inf')
        else:
            cost = float('inf')
        results.append({
            'n': n, 'q': q, 'alpha': alpha, 'alpha_q': alpha_q,
            'gamma': gamma, 'cost': cost
        })
    return results

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, printing data instead")
        data = compute_security_data()
        for d in data:
            print(f"n={d['n']:4d} gamma={d['gamma']:.2f} cost={d['cost']:.1f}")
        return

    data = compute_security_data()
    ns = [d['n'] for d in data]
    gammas = [d['gamma'] for d in data]
    costs = [d['cost'] for d in data]
    alpha_qs = [d['alpha_q'] for d in data]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('LWE Security Landscape: Regev Parameters', fontsize=16, fontweight='bold')

    # Plot 1: Security cost vs dimension
    ax1 = axes[0, 0]
    ax1.plot(ns, costs, 'b-o', markersize=3, linewidth=1.5)
    ax1.axhline(y=128, color='r', linestyle='--', alpha=0.7, label='NIST Level I (128)')
    ax1.axhline(y=192, color='orange', linestyle='--', alpha=0.7, label='NIST Level III (192)')
    ax1.axhline(y=256, color='g', linestyle='--', alpha=0.7, label='NIST Level V (256)')
    ax1.set_xlabel('Dimension n')
    ax1.set_ylabel('Security (log₂ operations)')
    ax1.set_title('BKZ Attack Cost vs Dimension')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Approximation factor vs dimension
    ax2 = axes[0, 1]
    sqrt_ns = [math.sqrt(n) for n in ns]
    ax2.plot(ns, gammas, 'r-o', markersize=3, linewidth=1.5, label='γ = n/(αq)')
    ax2.plot(ns, sqrt_ns, 'g--', linewidth=1.5, label='√n (theoretical)')
    ax2.set_xlabel('Dimension n')
    ax2.set_ylabel('Approximation Factor γ')
    ax2.set_title('Lattice Approximation Factor')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Plot 3: Error width αq vs dimension
    ax3 = axes[1, 0]
    ax3.plot(ns, alpha_qs, 'g-o', markersize=3, linewidth=1.5, label='αq')
    two_sqrt_ns = [2 * math.sqrt(n) for n in ns]
    ax3.plot(ns, two_sqrt_ns, 'r--', linewidth=1.5, label='2√n (minimum)')
    ax3.set_xlabel('Dimension n')
    ax3.set_ylabel('Error Width αq')
    ax3.set_title("Error Width vs Regev's Threshold")
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # Plot 4: Noise flooding - statistical distance vs flood ratio
    ax4 = axes[1, 1]
    ratios = list(range(1, 101))
    stat_dists = [1.0 / r for r in ratios]
    ax4.semilogy(ratios, stat_dists, 'purple', linewidth=2)
    ax4.axhline(y=2**(-40), color='r', linestyle='--', alpha=0.7, label='2⁻⁴⁰ (negligible)')
    ax4.axhline(y=2**(-80), color='orange', linestyle='--', alpha=0.7, label='2⁻⁸⁰')
    ax4.set_xlabel('Flood Ratio s/B')
    ax4.set_ylabel('Statistical Distance ε')
    ax4.set_title('Noise Flooding: Distance vs Ratio')
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Catalog/Cryptography/LWE/security_landscape.png',
                dpi=150, bbox_inches='tight')
    print("Saved security_landscape.png")

if __name__ == "__main__":
    main()
