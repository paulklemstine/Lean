#!/usr/bin/env python3
"""
Demonstration of the Surveillance-Privacy Information-Theoretic Framework.

Runs numerical examples illustrating the key theorems:
1. Privacy-Surveillance Conservation Law
2. Surveillance-Privacy Exclusion Theorem
3. Deterministic Data Processing Inequality (Privacy Amplification)
4. Dynamic Codebook Exponential Growth
5. Privacy Spectrum Analysis
"""

from algorithms import (
    privacy_index,
    surveillance_index,
    verify_conservation_law,
    privacy_spectrum,
    optimal_balanced_partition,
    privacy_amplification_demo,
    dynamic_codebook_bound,
    check_exclusion_theorem,
    tradeoff_curve,
)


def demo_conservation_law():
    """Demonstrate the Privacy-Surveillance Conservation Law."""
    print("=" * 60)
    print("1. PRIVACY-SURVEILLANCE CONSERVATION LAW")
    print("   π(f) + σ(f) = n(n-1)")
    print("=" * 60)

    examples = [
        ("Injective (identity)", {0: 0, 1: 1, 2: 2, 3: 3}),
        ("Constant", {0: 'x', 1: 'x', 2: 'x', 3: 'x'}),
        ("Two fibers (2+2)", {0: 'a', 1: 'a', 2: 'b', 3: 'b'}),
        ("Three fibers (2+1+1)", {0: 'a', 1: 'a', 2: 'b', 3: 'c'}),
        ("Unbalanced (3+1)", {0: 'a', 1: 'a', 2: 'a', 3: 'b'}),
    ]

    for name, f in examples:
        n = len(f)
        pi = privacy_index(f)
        sigma = surveillance_index(f)
        conserved = verify_conservation_law(f)
        print(f"\n  {name}:")
        print(f"    n = {n}, π = {pi}, σ = {sigma}")
        print(f"    π + σ = {pi + sigma} = {n}×{n-1} = {n*(n-1)} ✓" if conserved else "    FAILED!")


def demo_exclusion_theorem():
    """Demonstrate the Surveillance-Privacy Exclusion Theorem."""
    print("\n" + "=" * 60)
    print("2. SURVEILLANCE-PRIVACY EXCLUSION THEOREM")
    print("   Cannot have π = 0 AND σ = 0 when n ≥ 2")
    print("=" * 60)

    examples = [
        ("Injective", {0: 0, 1: 1, 2: 2}),
        ("Constant", {0: 'x', 1: 'x', 2: 'x'}),
        ("Partial", {0: 'a', 1: 'a', 2: 'b'}),
    ]

    for name, f in examples:
        result = check_exclusion_theorem(f)
        print(f"\n  {name}:")
        print(f"    Injective: {result['is_injective']}, Constant: {result['is_constant']}")
        print(f"    Privacy: {result['privacy_fraction']:.1%}, Surveillance: {result['surveillance_fraction']:.1%}")
        print(f"    Exclusion satisfied: {result['exclusion_satisfied']} ✓")


def demo_data_processing_inequality():
    """Demonstrate the Deterministic Data Processing Inequality."""
    print("\n" + "=" * 60)
    print("3. DETERMINISTIC DATA PROCESSING INEQUALITY")
    print("   Post-processing can only increase privacy")
    print("=" * 60)

    # Original: 5 states, 3 observations
    f = {0: 'a', 1: 'b', 2: 'c', 3: 'a', 4: 'b'}
    print(f"\n  Original f: {f}")
    print(f"  π(f) = {privacy_index(f)}")

    # Post-processing: merge 'b' and 'c'
    g1 = {'a': 'A', 'b': 'X', 'c': 'X'}
    pi_f, pi_gf, strict = privacy_amplification_demo(f, g1)
    print(f"\n  Post-process g1 (merge b,c): {g1}")
    print(f"  π(f) = {pi_f}, π(g∘f) = {pi_gf}")
    print(f"  Strict increase: {strict} ✓")

    # Post-processing: merge all
    g2 = {'a': 'Z', 'b': 'Z', 'c': 'Z'}
    pi_f, pi_gf, strict = privacy_amplification_demo(f, g2)
    print(f"\n  Post-process g2 (merge all): {g2}")
    print(f"  π(f) = {pi_f}, π(g∘f) = {pi_gf}")
    print(f"  Strict increase: {strict} ✓")

    # Identity post-processing (no change)
    g3 = {'a': 'a', 'b': 'b', 'c': 'c'}
    pi_f, pi_gf, strict = privacy_amplification_demo(f, g3)
    print(f"\n  Post-process g3 (identity): {g3}")
    print(f"  π(f) = {pi_f}, π(g∘f) = {pi_gf}")
    print(f"  No change (as expected)")


def demo_dynamic_codebook():
    """Demonstrate the Dynamic Codebook Exponential Growth."""
    print("\n" + "=" * 60)
    print("4. DYNAMIC CODEBOOK EXPONENTIAL GROWTH")
    print("   Perfect T-step surveillance requires codebook ≥ |S|^T")
    print("=" * 60)

    for n in [2, 3, 5, 10]:
        print(f"\n  State space |S| = {n}:")
        for t in [1, 2, 3, 5, 10]:
            bound = dynamic_codebook_bound(n, t)
            print(f"    T = {t:2d}: codebook ≥ {bound:>15,}")


def demo_privacy_spectrum():
    """Demonstrate the Privacy Spectrum."""
    print("\n" + "=" * 60)
    print("5. PRIVACY SPECTRUM ANALYSIS")
    print("   Ψ_f(k) = number of states in fibers of size ≥ k")
    print("=" * 60)

    examples = [
        ("Injective (1,1,1,1)", {0: 0, 1: 1, 2: 2, 3: 3}),
        ("Balanced 2+2", {0: 'a', 1: 'a', 2: 'b', 3: 'b'}),
        ("Unbalanced 3+1", {0: 'a', 1: 'a', 2: 'a', 3: 'b'}),
        ("Constant (4)", {0: 'x', 1: 'x', 2: 'x', 3: 'x'}),
    ]

    for name, f in examples:
        spec = privacy_spectrum(f)
        print(f"\n  {name}:")
        for k, v in enumerate(spec):
            bar = "█" * v
            print(f"    Ψ({k}) = {v}  {bar}")


def demo_tradeoff_curve():
    """Demonstrate the Privacy-Surveillance Tradeoff Curve."""
    print("\n" + "=" * 60)
    print("6. OPTIMAL TRADEOFF CURVE (n = 12)")
    print("   Balanced partition maximizes privacy for each codebook size")
    print("=" * 60)

    n = 12
    curve = tradeoff_curve(n)

    print(f"\n  {'k':>4s}  {'Partition':>20s}  {'π':>6s}  {'σ':>6s}  {'π/(n(n-1))':>10s}")
    print("  " + "-" * 52)

    total = n * (n - 1)
    for k, pi, sigma in curve:
        sizes, _ = optimal_balanced_partition(n, k)
        part_str = "+".join(str(s) for s in sizes[:6])
        if len(sizes) > 6:
            part_str += f"+...({len(sizes)} groups)"
        print(f"  {k:4d}  {part_str:>20s}  {pi:6d}  {sigma:6d}  {pi/total:10.3f}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  SURVEILLANCE-PRIVACY INFORMATION-THEORETIC FRAMEWORK   ║")
    print("║  Numerical Demonstrations                               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_conservation_law()
    demo_exclusion_theorem()
    demo_data_processing_inequality()
    demo_dynamic_codebook()
    demo_privacy_spectrum()
    demo_tradeoff_curve()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Privacy Spectrum Comparison.

Compares the privacy spectra of different observation functions on the same
state space, illustrating how the spectrum captures fine-grained privacy structure.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def privacy_spectrum(fiber_sizes, max_k=None):
    n = sum(fiber_sizes)
    if max_k is None:
        max_k = max(fiber_sizes) if fiber_sizes else 0
    spectrum = []
    for k in range(max_k + 1):
        count = sum(s for s in fiber_sizes if s >= k)
        spectrum.append(count)
    return spectrum


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Example 1: n=12, different partitions with same privacy index
    n = 12
    partitions = [
        ([6, 6], "Two equal groups (6+6)"),
        ([4, 4, 4], "Three equal groups (4+4+4)"),
        ([3, 3, 3, 3], "Four equal groups (3+3+3+3)"),
        ([12], "One group (12)"),
        ([1] * 12, "All singletons (1×12)"),
        ([6, 3, 2, 1], "Unbalanced (6+3+2+1)"),
    ]

    ax = axes[0]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(partitions)))
    for (fibers, label), color in zip(partitions, colors):
        spec = privacy_spectrum(fibers, max_k=13)
        ax.step(range(len(spec)), spec, where='post', linewidth=2,
                label=label, color=color)

    ax.set_xlabel('Level k', fontsize=12)
    ax.set_ylabel('Ψ_f(k)', fontsize=12)
    ax.set_title(f'Privacy Spectra (n = {n})', fontsize=14)
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 13)

    # Example 2: Spectrum encodes k-anonymity
    ax = axes[1]
    k_anon_levels = [2, 3, 4, 6]
    for k_target in k_anon_levels:
        group_size = n // k_target
        fibers = [group_size] * k_target
        spec = privacy_spectrum(fibers, max_k=13)
        # Highlight k-anonymity level
        ax.fill_between(range(len(spec)), spec, alpha=0.15)
        ax.step(range(len(spec)), spec, where='post', linewidth=2,
                label=f'{k_target}-anonymous (groups of {group_size})')
        ax.axvline(x=group_size, linestyle=':', alpha=0.3)

    ax.set_xlabel('Level k', fontsize=12)
    ax.set_ylabel('Ψ_f(k)', fontsize=12)
    ax.set_title('Privacy Spectrum & k-Anonymity', fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Example 3: Dynamic codebook growth
    ax = axes[2]
    state_sizes = [2, 3, 5, 10]
    T_max = 10
    Ts = np.arange(1, T_max + 1)

    for s in state_sizes:
        codebook = [s ** t for t in Ts]
        ax.semilogy(Ts, codebook, 'o-', markersize=5, linewidth=2,
                    label=f'|S| = {s}')

    ax.set_xlabel('Time Steps T', fontsize=12)
    ax.set_ylabel('Minimum Codebook Size |S|^T', fontsize=12)
    ax.set_title('Dynamic Codebook Growth', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, which='both')

    plt.tight_layout()
    plt.savefig('viz_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_spectrum.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Privacy-Surveillance Tradeoff Curve.

Plots the optimal privacy-surveillance tradeoff for various state space sizes,
showing how balanced partitions trace out the Pareto frontier.
"""

import matplotlib.pyplot as plt
import numpy as np


def optimal_balanced_partition(n: int, k: int):
    if k <= 0 or n <= 0 or k > n:
        return 0
    q, r = divmod(n, k)
    return r * (q + 1) * q + (k - r) * q * (q - 1)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Tradeoff curves for different n
    ax = axes[0]
    for n in [6, 10, 20, 50]:
        total = n * (n - 1)
        ks = list(range(1, n + 1))
        pis = [optimal_balanced_partition(n, k) for k in ks]
        sigmas = [total - pi for pi in pis]

        # Normalize
        pi_norm = [pi / total for pi in pis]
        sigma_norm = [s / total for s in sigmas]

        ax.plot(sigma_norm, pi_norm, 'o-', markersize=3, label=f'n = {n}')

    ax.plot([0, 1], [1, 0], 'k--', alpha=0.3, label='π + σ = 1')
    ax.set_xlabel('Normalized Surveillance σ/(n(n-1))', fontsize=12)
    ax.set_ylabel('Normalized Privacy π/(n(n-1))', fontsize=12)
    ax.set_title('Privacy-Surveillance Tradeoff Frontier', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    # Right: Privacy index vs codebook size for n=20
    ax = axes[1]
    n = 20
    total = n * (n - 1)
    ks = list(range(1, n + 1))
    pis = [optimal_balanced_partition(n, k) for k in ks]

    ax.bar(ks, pis, color='steelblue', alpha=0.7, edgecolor='navy')
    ax.set_xlabel('Codebook Size k', fontsize=12)
    ax.set_ylabel('Maximum Privacy Index π(f)', fontsize=12)
    ax.set_title(f'Optimal Privacy vs Codebook Size (n = {n})', fontsize=14)
    ax.axhline(y=total, color='red', linestyle='--', alpha=0.5, label=f'Maximum = {total}')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('viz_tradeoff.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_tradeoff.png")


if __name__ == "__main__":
    main()
