#!/usr/bin/env python3
"""
Expansion Certificate Algebra: Numerical Demonstrations

This script demonstrates the key results from the expansion certificate
lattice theory with concrete numerical examples.
"""

import math
from algorithms import (
    tensor_gap, k_fold_tensor_gap, amplification_steps_needed,
    gap_saturation_bound, code_distance_bound, classify_gap,
    mixing_time, amplification_trajectory, verify_saturation_conjecture,
    ExpansionCertificate
)


def demo_tensor_composition():
    """Demonstrate tensor product gap composition."""
    print("=" * 60)
    print("DEMO 1: Tensor Product Gap Composition")
    print("=" * 60)

    pairs = [(0.3, 0.4), (0.5, 0.5), (0.1, 0.9), (0.5, 0.7)]
    for e1, e2 in pairs:
        tg = tensor_gap(e1, e2)
        print(f"  tensor_gap({e1}, {e2}) = {tg:.6f}")
        print(f"    Exceeds both: {tg >= e1} (≥ {e1}), {tg >= e2} (≥ {e2})")
        print(f"    Deficiency product: {(1-e1)*(1-e2):.6f}")
    print()


def demo_amplification():
    """Demonstrate gap amplification via iterated tensor products."""
    print("=" * 60)
    print("DEMO 2: Gap Amplification")
    print("=" * 60)

    eps = 0.3
    print(f"\n  Base gap: {eps}")
    print(f"  {'k':>4}  {'Gap':>10}  {'Deficiency':>12}  {'Regime':>10}")
    print(f"  {'-'*4}  {'-'*10}  {'-'*12}  {'-'*10}")

    trajectory = amplification_trajectory(eps, 20)
    for k, gap, deficiency, regime in trajectory:
        print(f"  {k:4d}  {gap:10.6f}  {deficiency:12.8f}  {regime:>10}")

    # Steps needed for target gaps
    print(f"\n  Steps to reach gap ≥ 0.9: {amplification_steps_needed(eps, 0.9)}")
    print(f"  Steps to reach gap ≥ 0.99: {amplification_steps_needed(eps, 0.99)}")
    print(f"  Steps to reach gap ≥ 0.999: {amplification_steps_needed(eps, 0.999)}")
    print()


def demo_saturation_conjecture():
    """Verify the Gap Saturation Conjecture numerically."""
    print("=" * 60)
    print("DEMO 3: Gap Saturation Conjecture Verification")
    print("=" * 60)

    eps_values = [0.1, 0.3, 0.5, 0.7, 0.9]
    max_k = 10

    print(f"\n  {'ε':>5}  {'k':>3}  {'(1-ε)^k':>12}  {'e^(-kε)':>12}  {'Ratio':>8}  {'OK':>4}")
    print(f"  {'-'*5}  {'-'*3}  {'-'*12}  {'-'*12}  {'-'*8}  {'-'*4}")

    results = verify_saturation_conjecture(eps_values, max_k)
    for eps, k, actual, bound, ok in results:
        if k in [0, 1, 5, 10]:  # Show selected rows
            ratio = actual / bound if bound > 1e-15 else 0.0
            print(f"  {eps:5.1f}  {k:3d}  {actual:12.8f}  {bound:12.8f}  {ratio:8.4f}  {'✓' if ok else '✗':>4}")

    all_ok = all(ok for _, _, _, _, ok in results)
    print(f"\n  All checks passed: {'✓ YES' if all_ok else '✗ NO'}")
    print()


def demo_code_distance():
    """Demonstrate the code distance pipeline."""
    print("=" * 60)
    print("DEMO 4: Code Distance from Expansion")
    print("=" * 60)

    inner_dist = 0.4
    block_length = 1000
    print(f"\n  Inner code distance: {inner_dist}")
    print(f"  Block length: {block_length}")

    print(f"\n  {'Gap':>8}  {'Deficiency':>12}  {'In Regime':>10}  {'Dist Bound':>12}")
    print(f"  {'-'*8}  {'-'*12}  {'-'*10}  {'-'*12}")

    for gap in [0.1, 0.3, 0.5, 0.7, 0.8, 0.9, 0.95]:
        deficiency = 1 - gap
        in_regime = deficiency < inner_dist
        dist = code_distance_bound(gap, inner_dist, block_length)
        print(f"  {gap:8.2f}  {deficiency:12.4f}  {'YES' if in_regime else 'NO':>10}  {dist:12.1f}")

    # Amplification to reach expansion regime
    print(f"\n  Starting from gap = 0.1:")
    steps = 0
    gap = 0.1
    while 1 - k_fold_tensor_gap(gap, steps) >= inner_dist:
        steps += 1
    print(f"  Steps to enter expansion regime: {steps}")
    final_gap = k_fold_tensor_gap(gap, steps)
    final_dist = code_distance_bound(final_gap, inner_dist, block_length)
    print(f"  Final gap: {final_gap:.6f}")
    print(f"  Final distance bound: {final_dist:.1f}")
    print()


def demo_entropy():
    """Demonstrate expansion entropy."""
    print("=" * 60)
    print("DEMO 5: Expansion Entropy")
    print("=" * 60)

    print(f"\n  {'Gap':>8}  {'Deficiency':>12}  {'Entropy':>10}  {'Mix Time (ε=0.01)':>20}")
    print(f"  {'-'*8}  {'-'*12}  {'-'*10}  {'-'*20}")

    for gap in [0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 0.95, 0.99]:
        cert = ExpansionCertificate(gap=gap, size=100, degree=4)
        entropy = cert.expansion_entropy
        mt = mixing_time(gap, 0.01)
        print(f"  {gap:8.2f}  {cert.deficiency:12.4f}  {entropy:10.4f}  {mt:20d}")
    print()


def demo_certificate_chain():
    """Demonstrate certificate chains."""
    print("=" * 60)
    print("DEMO 6: Certificate Chain (Sp₂ₙ family)")
    print("=" * 60)

    # Model: gap = 1 - 2/q for Sp₄(F_q)
    C = 2.0
    print(f"\n  Character ratio constant C = {C}")
    print(f"\n  {'q':>6}  {'Gap':>10}  {'Entropy':>10}  {'Regime':>10}  {'Mix Time':>10}")
    print(f"  {'-'*6}  {'-'*10}  {'-'*10}  {'-'*10}  {'-'*10}")

    for q in [3, 5, 7, 11, 13, 17, 23, 31, 47, 71, 101, 1009]:
        gap = 1.0 - C / q
        if gap <= 0:
            continue
        cert = ExpansionCertificate(gap=gap, size=q**4, degree=4)
        regime = classify_gap(gap)
        mt = mixing_time(gap, 0.01)
        print(f"  {q:6d}  {gap:10.6f}  {cert.expansion_entropy:10.4f}  {regime:>10}  {mt:10d}")
    print()


def main():
    print("\n" + "=" * 60)
    print("  EXPANSION CERTIFICATE ALGEBRA: NUMERICAL DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_tensor_composition()
    demo_amplification()
    demo_saturation_conjecture()
    demo_code_distance()
    demo_entropy()
    demo_certificate_chain()

    print("All demonstrations completed successfully.\n")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Gap Amplification Trajectories

Standalone matplotlib script showing how different base gaps
amplify through iterated tensor products.
"""

import math

def k_fold_tensor_gap(eps, k):
    return 1.0 - (1.0 - eps) ** k

def gap_saturation_bound(eps, k):
    return math.exp(-k * eps)

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Amplification trajectories
    ax1 = axes[0]
    base_gaps = [0.1, 0.2, 0.3, 0.5, 0.7]
    ks = list(range(21))
    for eps in base_gaps:
        gaps = [k_fold_tensor_gap(eps, k) for k in ks]
        ax1.plot(ks, gaps, 'o-', label=f'ε₀ = {eps}', markersize=3)
    ax1.axhline(y=2/3, color='gray', linestyle='--', alpha=0.5, label='Strong regime')
    ax1.set_xlabel('Tensor steps k')
    ax1.set_ylabel('Gap = 1 - (1-ε₀)^k')
    ax1.set_title('Gap Amplification Trajectories')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Gap saturation conjecture
    ax2 = axes[1]
    eps_vals = [0.1, 0.3, 0.5, 0.7]
    ks2 = list(range(16))
    for eps in eps_vals:
        actual = [(1.0 - eps) ** k for k in ks2]
        bound = [gap_saturation_bound(eps, k) for k in ks2]
        ax2.semilogy(ks2, actual, 'o-', label=f'(1-{eps})^k', markersize=3)
        ax2.semilogy(ks2, bound, 's--', label=f'e^(-k·{eps})', markersize=3, alpha=0.5)
    ax2.set_xlabel('k')
    ax2.set_ylabel('Deficiency (log scale)')
    ax2.set_title('Gap Saturation Conjecture')
    ax2.legend(fontsize=7, ncol=2)
    ax2.grid(True, alpha=0.3)

    # Panel 3: Code distance from expansion
    ax3 = axes[2]
    inner_dists = [0.2, 0.3, 0.4, 0.5]
    gaps_range = [i/100 for i in range(5, 100)]
    block_length = 1000
    for d in inner_dists:
        dists = [(d - (1.0 - g)) * block_length for g in gaps_range]
        ax3.plot(gaps_range, dists, label=f'δ_inner = {d}')
    ax3.axhline(y=0, color='red', linestyle='-', alpha=0.3)
    ax3.set_xlabel('Spectral Gap')
    ax3.set_ylabel('Distance Bound')
    ax3.set_title(f'Code Distance (n={block_length})')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)
    ax3.set_ylim(-200, 500)

    plt.tight_layout()
    plt.savefig('amplification_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved amplification_visualization.png")

if __name__ == "__main__":
    main()
