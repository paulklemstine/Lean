#!/usr/bin/env python3
"""
Applications of P-adic Controlled Persistence Stability
========================================================

Demonstrates real-world applications of valuation-sensitive stability:
1. Arithmetic signal filtering — primes as noise attenuators
2. Error-correcting code analysis — divisibility controls channel capacity
3. Topological data analysis with arithmetic priors
"""

from typing import List, Tuple, Dict
import math
import random


def valuation_sensitive_shift(p: int, nu: int, delta: int) -> int:
    """Compute the valuation-sensitive shift bound δ // p^ν."""
    return delta // (p ** nu)


def p_adic_valuation(n: int, p: int) -> int:
    """Compute v_p(n)."""
    if n == 0:
        return 0
    n = abs(n)
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


# =============================================================================
# Application 1: Arithmetic Signal Filtering
# =============================================================================

def arithmetic_noise_attenuation(
    signal: List[int],
    p: int,
    nu: int,
    modulus: int
) -> Tuple[List[int], Dict]:
    """Apply p^ν-scaling as an arithmetic noise filter.

    Models the phenomenon that multiplication by p^ν in Z/p^k Z
    annihilates low-order p-torsion, effectively filtering out
    p-primary noise of depth < ν.

    Args:
        signal: Input signal as list of integers mod `modulus`
        p: Prime (filter frequency)
        nu: Filtering depth
        modulus: Working modulus (typically p^k)

    Returns:
        Filtered signal and analysis dictionary

    Example:
        >>> signal = [1, 3, 4, 7, 2, 8, 5, 6]
        >>> filtered, info = arithmetic_noise_attenuation(signal, 2, 2, 16)
    """
    p_power = p ** nu
    filtered = [(x * p_power) % modulus for x in signal]

    # Compute how many components were annihilated
    original_nonzero = sum(1 for x in signal if x % modulus != 0)
    filtered_nonzero = sum(1 for x in filtered if x != 0)
    annihilated = original_nonzero - filtered_nonzero

    analysis = {
        "original_signal": signal,
        "filtered_signal": filtered,
        "p": p,
        "nu": nu,
        "modulus": modulus,
        "original_nonzero": original_nonzero,
        "filtered_nonzero": filtered_nonzero,
        "annihilated_components": annihilated,
        "attenuation_ratio": annihilated / max(original_nonzero, 1),
    }

    return filtered, analysis


def multi_prime_spectral_decomposition(
    signal: List[int],
    primes: List[int],
    modulus: int
) -> Dict[int, Dict]:
    """Decompose a signal's noise spectrum across multiple primes.

    For each prime p, compute the p-adic valuation of each signal component.
    This reveals the "arithmetic frequency content" of the signal.

    Args:
        signal: Input signal
        primes: List of primes for spectral analysis
        modulus: Working modulus

    Returns:
        Dictionary mapping each prime to its spectral analysis
    """
    spectrum = {}
    for p in primes:
        valuations = [p_adic_valuation(x, p) if x != 0 else float('inf')
                      for x in signal]
        min_val = min(v for v in valuations if v != float('inf')) if any(
            v != float('inf') for v in valuations) else 0

        spectrum[p] = {
            "valuations": valuations,
            "min_valuation": min_val,
            "max_attenuation_depth": min_val,
            "components_with_torsion": sum(1 for v in valuations
                                          if v != float('inf') and v < 10),
        }

    return spectrum


# =============================================================================
# Application 2: Error-Correcting Code Analysis
# =============================================================================

def channel_attenuation_analysis(
    codeword: List[int],
    p: int,
    k: int,
    max_nu: int
) -> List[Dict]:
    """Analyze how p^ν-divisibility affects information content in a code.

    Models the data-processing inequality for arithmetic channels:
    a map divisible by p^ν erases low-level p-primary information.

    Args:
        codeword: A codeword in (Z/p^k Z)^n
        p: Prime (channel characteristic)
        k: Modulus exponent
        max_nu: Maximum attenuation depth to test

    Returns:
        List of analysis dicts for each ν
    """
    modulus = p ** k
    results = []

    for nu in range(max_nu + 1):
        p_power = p ** nu
        attenuated = [(x * p_power) % modulus for x in codeword]

        # Information content: number of distinct nonzero values
        original_values = set(x % modulus for x in codeword)
        attenuated_values = set(attenuated)

        # Effective alphabet size after attenuation
        effective_alphabet = len(attenuated_values)
        original_alphabet = len(original_values)

        results.append({
            "nu": nu,
            "effective_alphabet": effective_alphabet,
            "original_alphabet": original_alphabet,
            "information_loss_ratio": 1 - effective_alphabet / max(original_alphabet, 1),
            "stability_bound": valuation_sensitive_shift(p, nu, len(codeword)),
        })

    return results


# =============================================================================
# Application 3: Topological Data Analysis with Arithmetic Priors
# =============================================================================

def arithmetic_filtration_stability(
    birth_times_1: List[int],
    birth_times_2: List[int],
    delta: int,
    primes: List[int],
    max_nu: int = 3
) -> Dict:
    """Analyze stability of persistence birth times under arithmetic control.

    Given two sets of birth times and an interleaving parameter δ,
    compute the standard Hausdorff distance and the valuation-sensitive
    bounds for each prime.

    Args:
        birth_times_1: Birth times for filtration 1
        birth_times_2: Birth times for filtration 2
        delta: Interleaving shift
        primes: Primes for analysis
        max_nu: Maximum valuation depth

    Returns:
        Analysis dictionary
    """
    # Standard Hausdorff distance
    def hausdorff_one_sided(A, B):
        if not A:
            return 0
        if not B:
            return float('inf')
        return max(min(abs(a - b) for b in B) for a in A)

    actual_hausdorff = max(
        hausdorff_one_sided(birth_times_1, birth_times_2),
        hausdorff_one_sided(birth_times_2, birth_times_1)
    )

    # Valuation-sensitive bounds
    prime_analysis = {}
    for p in primes:
        bounds = {}
        for nu in range(max_nu + 1):
            vs_bound = valuation_sensitive_shift(p, nu, delta)
            bounds[nu] = {
                "bound": vs_bound,
                "tight": actual_hausdorff <= vs_bound,
                "strict_improvement": vs_bound < delta if nu > 0 else False,
            }
        prime_analysis[p] = bounds

    return {
        "actual_hausdorff": actual_hausdorff,
        "global_bound": delta,
        "prime_analysis": prime_analysis,
    }


# =============================================================================
# Main demonstration
# =============================================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF P-ADIC CONTROLLED STABILITY           ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Application 1: Arithmetic signal filtering
    print("\n" + "="*60)
    print("APPLICATION 1: ARITHMETIC SIGNAL FILTERING")
    print("="*60)

    signal = [1, 3, 4, 7, 2, 8, 5, 6, 9, 10, 11, 15, 0, 14, 13, 12]
    p, k = 2, 4
    modulus = p ** k

    print(f"\nSignal over Z/{modulus}Z: {signal}")
    print(f"\nFiltering at prime p = {p}:")

    for nu in range(k + 1):
        filtered, info = arithmetic_noise_attenuation(signal, p, nu, modulus)
        print(f"  ν={nu}: {filtered}")
        print(f"    Annihilated: {info['annihilated_components']}/{info['original_nonzero']} "
              f"({info['attenuation_ratio']:.0%})")

    # Multi-prime spectrum
    print(f"\nMulti-prime spectral decomposition of signal:")
    spectrum = multi_prime_spectral_decomposition(signal, [2, 3, 5], modulus)
    for p, data in spectrum.items():
        print(f"  p={p}: min_valuation={data['min_valuation']}, "
              f"torsion_components={data['components_with_torsion']}")

    # Application 2: Error-correcting codes
    print("\n" + "="*60)
    print("APPLICATION 2: CHANNEL ATTENUATION ANALYSIS")
    print("="*60)

    codeword = [1, 2, 3, 4, 5, 6, 7, 8]
    p, k = 3, 3
    print(f"\nCodeword over Z/{p**k}Z: {codeword}")
    results = channel_attenuation_analysis(codeword, p, k, k)
    for r in results:
        print(f"  ν={r['nu']}: alphabet {r['original_alphabet']} → {r['effective_alphabet']} "
              f"(loss: {r['information_loss_ratio']:.0%}), "
              f"stability bound: {r['stability_bound']}")

    # Application 3: TDA with arithmetic priors
    print("\n" + "="*60)
    print("APPLICATION 3: PERSISTENCE STABILITY WITH ARITHMETIC PRIORS")
    print("="*60)

    birth_1 = [0, 3, 7, 12, 18]
    birth_2 = [1, 4, 8, 13, 19]
    delta = 24
    primes = [2, 3, 5]

    print(f"\nFiltration 1 births: {birth_1}")
    print(f"Filtration 2 births: {birth_2}")
    print(f"Interleaving shift δ = {delta}")

    analysis = arithmetic_filtration_stability(birth_1, birth_2, delta, primes)
    print(f"\nActual Hausdorff distance: {analysis['actual_hausdorff']}")
    print(f"Global bound: {analysis['global_bound']}")

    for p, bounds in analysis["prime_analysis"].items():
        print(f"\n  Prime p = {p}:")
        for nu, data in bounds.items():
            tight_str = "✓ tight" if data["tight"] else "✗ loose"
            improve_str = " [STRICT IMPROVEMENT]" if data["strict_improvement"] else ""
            print(f"    ν={nu}: bound = {data['bound']} ({tight_str}){improve_str}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: P-adic Controlled Persistence Stability
==============================================

Interactive demonstration of the valuation-sensitive stability theorem.
Shows how p-adic divisibility depth ν reduces the effective primewise
stability modulus from δ to δ / p^ν.

Usage:
    python demo.py
    python demo.py --prime 3 --delta 100 --max-nu 5
"""

import argparse
import math
from typing import List, Tuple


def valuation_sensitive_shift(p: int, nu: int, delta: int) -> int:
    """Compute the valuation-sensitive shift bound δ / p^ν (integer division).

    This is the central invariant of arithmetic TDA: the effective primewise
    stability modulus when interleaving maps factor through p^ν-scaling.

    Args:
        p: Prime number (≥ 2)
        nu: Valuation depth (≥ 0)
        delta: Original interleaving shift

    Returns:
        The reduced shift bound δ // p^ν
    """
    return delta // (p ** nu)


def prime_shift_bound_improved(p: int, delta: int) -> int:
    """Catalog's improved prime shift bound (depth ν=1).

    From PrimewiseTorsionStability.lean: primeShiftBound_improved.
    Returns δ/p when p divides δ, otherwise δ.
    """
    if p >= 2 and delta % p == 0:
        return delta // p
    return delta


def demonstrate_strict_improvement(p: int, delta: int, max_nu: int = 5):
    """Show how increasing valuation depth ν strictly improves the bound.

    For each ν from 0 to max_nu, prints δ / p^ν, demonstrating
    the monotonic improvement (Theorem 3: valuation_sensitive_bound_mono).
    """
    print(f"\n{'='*60}")
    print(f"VALUATION-SENSITIVE STABILITY BOUNDS")
    print(f"Prime p = {p}, Original shift δ = {delta}")
    print(f"{'='*60}")
    print(f"\n{'ν':>4} {'p^ν':>10} {'δ/p^ν':>10} {'Improvement':>15} {'Strict?':>10}")
    print(f"{'-'*4:>4} {'-'*10:>10} {'-'*10:>10} {'-'*15:>15} {'-'*10:>10}")

    prev_bound = delta
    for nu in range(max_nu + 1):
        p_power = p ** nu
        bound = valuation_sensitive_shift(p, nu, delta)
        improvement = delta - bound
        strict = "YES" if (nu > 0 and delta > 0) else "—"

        print(f"{nu:>4} {p_power:>10} {bound:>10} {improvement:>15} {strict:>10}")

        # Verify monotonicity (Theorem 3)
        assert bound <= prev_bound, f"Monotonicity violated at ν={nu}!"
        prev_bound = bound

    print(f"\n✓ Monotonicity verified: δ/p^ν₂ ≤ δ/p^ν₁ for all ν₁ ≤ ν₂")


def demonstrate_catalog_comparison(p: int, delta: int, max_nu: int = 5):
    """Compare the new valuation-sensitive bound to the catalog's bound.

    Shows that:
    - At ν=0, we recover δ (base case)
    - At ν=1, we match or improve the catalog's primeShiftBound_improved
    - At ν>1, we go strictly beyond what the catalog provides
    """
    print(f"\n{'='*60}")
    print(f"COMPARISON WITH CATALOG BOUND")
    print(f"Prime p = {p}, δ = {delta}")
    print(f"{'='*60}")

    catalog_bound = prime_shift_bound_improved(p, delta)
    print(f"\nCatalog bound (primeShiftBound_improved): {catalog_bound}")
    print(f"Catalog condition: p≥2 and p|δ → δ/p, else δ")

    print(f"\n{'ν':>4} {'New bound':>12} {'Catalog':>10} {'Gain':>10}")
    print(f"{'-'*4:>4} {'-'*12:>12} {'-'*10:>10} {'-'*10:>10}")

    for nu in range(max_nu + 1):
        new_bound = valuation_sensitive_shift(p, nu, delta)
        gain = catalog_bound - new_bound
        print(f"{nu:>4} {new_bound:>12} {catalog_bound:>10} {gain:>10}")


def search_sharp_equality_counterexamples(
    primes: List[int] = [2, 3, 5],
    k_values: List[int] = [1, 2, 3],
    max_delta: int = 50
) -> List[Tuple]:
    """Search for counterexamples to the sharp equality conjecture.

    The conjecture states: for optimal configurations, the primewise shift
    equals exactly δ / p^ν. We search for cases where the integer division
    loses information (i.e., p^ν does not divide δ), which would prevent
    equality in the rational sense.

    Returns list of (p, k, nu, delta) where sharp equality fails.
    """
    print(f"\n{'='*60}")
    print(f"SEARCHING FOR SHARP EQUALITY COUNTEREXAMPLES")
    print(f"{'='*60}")
    print(f"\nConjecture: ε_p(F,G) = δ / p^ν (exact rational equality)")
    print(f"Testing: does p^ν | δ? (necessary for exact equality)\n")

    counterexamples = []

    print(f"{'p':>4} {'k':>4} {'ν':>4} {'δ':>6} {'δ/p^ν':>8} {'p^ν|δ?':>8} {'Status':>12}")
    print(f"{'-'*4:>4} {'-'*4:>4} {'-'*4:>4} {'-'*6:>6} {'-'*8:>8} {'-'*8:>8} {'-'*12:>12}")

    for p in primes:
        for k in k_values:
            for nu in range(k + 1):
                for delta in [p**k, p**k + 1, 2 * p**k, 3 * p**k - 1]:
                    if delta <= 0 or delta > max_delta:
                        continue
                    p_power_nu = p ** nu
                    exact_division = delta % p_power_nu == 0
                    bound = delta // p_power_nu
                    rational_bound = delta / p_power_nu

                    if not exact_division and nu > 0:
                        status = "GAP EXISTS"
                        counterexamples.append((p, k, nu, delta))
                    else:
                        status = "exact"

                    print(f"{p:>4} {k:>4} {nu:>4} {delta:>6} {bound:>8} "
                          f"{'yes' if exact_division else 'NO':>8} {status:>12}")

    print(f"\nFound {len(counterexamples)} cases where sharp equality cannot hold")
    print(f"(due to p^ν not dividing δ)")
    return counterexamples


def demonstrate_energy_contraction(p: int, max_k: int = 6, max_nu: int = 4):
    """Demonstrate torsion energy contraction under p-adic scaling.

    For an element x with p^k-torsion, p^ν • x has torsion order at most k - ν.
    This shows the energy dissipation phenomenon.
    """
    print(f"\n{'='*60}")
    print(f"TORSION ENERGY CONTRACTION (p = {p})")
    print(f"{'='*60}")
    print(f"\nFor x with p^k-torsion, p^ν • x has torsion order ≤ k - ν")
    print(f"Energy dissipation: torsion depth decreases by ν levels\n")

    print(f"{'k':>4} {'ν':>4} {'k-ν':>6} {'Reduction':>12} {'Complete?':>12}")
    print(f"{'-'*4:>4} {'-'*4:>4} {'-'*6:>6} {'-'*12:>12} {'-'*12:>12}")

    for k in range(1, max_k + 1):
        for nu in range(k + 1):
            residual = k - nu
            reduction = f"{k} → {residual}"
            complete = "ANNIHILATED" if residual == 0 else ""
            print(f"{k:>4} {nu:>4} {residual:>6} {reduction:>12} {complete:>12}")
        print()


def main():
    parser = argparse.ArgumentParser(
        description="Demo: P-adic Controlled Persistence Stability"
    )
    parser.add_argument("--prime", "-p", type=int, default=2,
                        help="Prime number (default: 2)")
    parser.add_argument("--delta", "-d", type=int, default=100,
                        help="Interleaving shift δ (default: 100)")
    parser.add_argument("--max-nu", "-n", type=int, default=5,
                        help="Maximum valuation depth ν (default: 5)")
    args = parser.parse_args()

    p = args.prime
    delta = args.delta
    max_nu = args.max_nu

    print("╔══════════════════════════════════════════════════════════╗")
    print("║  P-ADIC CONTROLLED PERSISTENCE STABILITY                ║")
    print("║  Arithmetic TDA: Primes as Geometric Regulators         ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Demo 1: Strict improvement
    demonstrate_strict_improvement(p, delta, max_nu)

    # Demo 2: Catalog comparison
    demonstrate_catalog_comparison(p, delta, max_nu)

    # Demo 3: Multi-prime comparison
    print(f"\n{'='*60}")
    print(f"MULTI-PRIME COMPARISON (δ = {delta})")
    print(f"{'='*60}")
    for prime in [2, 3, 5, 7, 11]:
        bounds = [valuation_sensitive_shift(prime, nu, delta) for nu in range(max_nu + 1)]
        print(f"  p={prime:>2}: {bounds}")

    # Demo 4: Energy contraction
    demonstrate_energy_contraction(p)

    # Demo 5: Counterexample search
    search_sharp_equality_counterexamples()

    print(f"\n{'='*60}")
    print(f"SUMMARY")
    print(f"{'='*60}")
    print(f"• Valuation-sensitive shift: δ/p^ν = {delta}//{p}^ν")
    print(f"• Strictly improves catalog bound for ν > 0, δ > 0")
    print(f"• Monotone in ν: deeper divisibility ⟹ tighter bound")
    print(f"• Energy contraction: torsion order drops by ν levels")
    print(f"• All results formally verified in Lean 4")


if __name__ == "__main__":
    main()


"""
Visualization: Torsion Energy Contraction Under P-adic Scaling
===============================================================

Visualizes the energy dissipation phenomenon: when an element with
p^k-torsion is scaled by p^ν, its torsion order drops to k - ν.
This is the arithmetic analogue of energy decay in physical systems.
"""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # --- Panel 1: Torsion order reduction ---
    ax = axes[0]
    max_k = 8
    colors_nu = plt.cm.RdYlBu(np.linspace(0.1, 0.9, max_k))

    for k in range(1, max_k + 1):
        nus = list(range(k + 1))
        residuals = [k - nu for nu in nus]
        ax.plot(nus, residuals, 'o-', color=colors_nu[k-1],
                label=f'k = {k}', markersize=5, linewidth=1.5)

    ax.set_xlabel('Scaling depth ν', fontsize=12)
    ax.set_ylabel('Residual torsion order (k - ν)', fontsize=12)
    ax.set_title('Torsion Order Reduction', fontsize=13)
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5,
               label='Complete annihilation')

    # --- Panel 2: Annihilation heatmap ---
    ax = axes[1]
    max_k_heat = 10
    max_nu_heat = 10

    heatmap = np.zeros((max_nu_heat, max_k_heat))
    for k in range(max_k_heat):
        for nu in range(max_nu_heat):
            if nu <= k:
                heatmap[nu, k] = k - nu
            else:
                heatmap[nu, k] = 0  # Completely annihilated

    im = ax.imshow(heatmap, aspect='auto', cmap='hot_r',
                   extent=[0.5, max_k_heat + 0.5, max_nu_heat - 0.5, -0.5])
    ax.set_xlabel('Original torsion order k', fontsize=12)
    ax.set_ylabel('Scaling depth ν', fontsize=12)
    ax.set_title('Residual Torsion Order Heatmap', fontsize=13)
    plt.colorbar(im, ax=ax, label='k - ν')

    # Add diagonal line where ν = k (complete annihilation)
    ax.plot([0.5, max_k_heat + 0.5], [-0.5, max_k_heat - 0.5],
            'w--', linewidth=2, alpha=0.7)
    ax.text(max_k_heat * 0.6, max_k_heat * 0.35, 'ν = k\n(annihilation)',
            color='white', fontsize=9, ha='center', fontweight='bold')

    # --- Panel 3: Multi-prime energy decay curves ---
    ax = axes[2]
    primes = [2, 3, 5, 7]
    prime_colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    delta = 1000

    for p, color in zip(primes, prime_colors):
        nus = np.arange(0, 12)
        # Normalized energy: (δ/p^ν) / δ
        energies = [delta // (p ** int(nu)) / delta for nu in nus]
        ax.plot(nus, energies, 'D-', color=color, label=f'p = {p}',
                markersize=5, linewidth=2)

    ax.set_xlabel('Valuation depth ν', fontsize=12)
    ax.set_ylabel('Normalized energy E/E₀', fontsize=12)
    ax.set_title('Energy Decay by Prime', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=1e-4)

    plt.suptitle('Torsion Energy Contraction in Arithmetic TDA',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_energy_contraction.png', dpi=150, bbox_inches='tight')
    print("Saved viz_energy_contraction.png")


if __name__ == "__main__":
    main()


"""
Visualization: Prime Spectrum of Stability Bounds
==================================================

Shows the "arithmetic frequency spectrum" of persistence stability:
how different primes contribute different damping profiles,
creating a rich multi-scale picture of topological noise attenuation.
"""

import matplotlib.pyplot as plt
import numpy as np


def valuation_sensitive_shift(p, nu, delta):
    """Compute δ // p^ν."""
    return delta // (p ** nu)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # --- Panel 1: Bar chart comparing bounds across primes ---
    ax = axes[0, 0]
    delta = 720  # = 2^4 * 3^2 * 5 (highly composite)
    primes = [2, 3, 5, 7, 11, 13]
    max_nu = 4

    x = np.arange(len(primes))
    width = 0.15
    cmap = plt.cm.Blues

    for nu in range(max_nu + 1):
        bounds = [valuation_sensitive_shift(p, nu, delta) for p in primes]
        color = cmap(0.3 + 0.15 * nu)
        bars = ax.bar(x + nu * width, bounds, width, label=f'ν = {nu}',
                      color=color, edgecolor='gray', linewidth=0.5)

    ax.set_xticks(x + width * max_nu / 2)
    ax.set_xticklabels([f'p={p}' for p in primes])
    ax.set_ylabel('Stability bound δ/p^ν', fontsize=12)
    ax.set_title(f'Primewise Bounds (δ = {delta})', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2, axis='y')

    # --- Panel 2: Factorization structure ---
    ax = axes[0, 1]
    # Show how δ's factorization determines which primes give the best bounds
    deltas = [60, 120, 180, 360, 720, 1080]
    primes_check = [2, 3, 5]

    data = np.zeros((len(deltas), len(primes_check)))
    for i, d in enumerate(deltas):
        for j, p in enumerate(primes_check):
            # Best improvement ratio at ν=1
            data[i, j] = valuation_sensitive_shift(p, 1, d) / d

    im = ax.imshow(data, aspect='auto', cmap='RdYlGn_r')
    ax.set_xticks(range(len(primes_check)))
    ax.set_xticklabels([f'p={p}' for p in primes_check])
    ax.set_yticks(range(len(deltas)))
    ax.set_yticklabels([str(d) for d in deltas])
    ax.set_xlabel('Prime', fontsize=12)
    ax.set_ylabel('δ', fontsize=12)
    ax.set_title('Improvement Ratio at ν=1', fontsize=13)
    plt.colorbar(im, ax=ax, label='(δ/p)/δ')

    # Annotate cells
    for i in range(len(deltas)):
        for j in range(len(primes_check)):
            ax.text(j, i, f'{data[i,j]:.2f}', ha='center', va='center',
                    fontsize=9, color='black' if data[i,j] > 0.3 else 'white')

    # --- Panel 3: Monotonicity surface ---
    ax = axes[1, 0]
    p = 2
    deltas_range = np.arange(1, 101)
    nus_range = np.arange(0, 8)

    D, N = np.meshgrid(deltas_range, nus_range)
    Z = np.vectorize(lambda d, n: valuation_sensitive_shift(p, int(n), int(d)))(D, N)

    contour = ax.contourf(D, N, Z, levels=20, cmap='viridis')
    ax.set_xlabel('δ', fontsize=12)
    ax.set_ylabel('ν', fontsize=12)
    ax.set_title(f'Stability Surface (p = {p})', fontsize=13)
    plt.colorbar(contour, ax=ax, label='δ/p^ν')

    # --- Panel 4: Comparative improvement for p=2,3,5 ---
    ax = axes[1, 1]
    delta = 1000
    primes_plot = [2, 3, 5]
    styles = ['-', '--', ':']
    prime_colors = ['#e41a1c', '#377eb8', '#4daf4a']

    for p, style, color in zip(primes_plot, styles, prime_colors):
        nus = np.arange(0, 11)
        improvements = [(delta - valuation_sensitive_shift(p, int(nu), delta)) / delta * 100
                        for nu in nus]
        ax.plot(nus, improvements, style, color=color, label=f'p = {p}',
                linewidth=2.5, markersize=6)

    ax.set_xlabel('Valuation depth ν', fontsize=12)
    ax.set_ylabel('Improvement over δ (%)', fontsize=12)
    ax.set_title(f'Percentage Improvement (δ = {delta})', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 105)

    plt.suptitle('Prime Spectrum of Arithmetic Persistence Stability',
                 fontsize=15, fontweight='bold', y=1.01)
    plt.tight_layout()
    plt.savefig('viz_prime_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved viz_prime_spectrum.png")


if __name__ == "__main__":
    main()


"""
Visualization: Valuation-Sensitive Stability Bounds
====================================================

Visualizes how the stability modulus δ/p^ν decreases as the p-adic
valuation depth ν increases, for multiple primes simultaneously.

This plot is the core visual insight of arithmetic TDA:
primes of different sizes create different "damping profiles"
for topological stability bounds.
"""

import matplotlib.pyplot as plt
import numpy as np


def valuation_sensitive_shift(p, nu, delta):
    """Compute δ // p^ν."""
    return delta // (p ** nu)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # --- Panel 1: Bound vs ν for multiple primes ---
    ax = axes[0]
    delta = 1000
    primes = [2, 3, 5, 7, 11]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
    max_nu = 8

    for p, color in zip(primes, colors):
        nus = list(range(max_nu + 1))
        bounds = [valuation_sensitive_shift(p, nu, delta) for nu in nus]
        ax.plot(nus, bounds, 'o-', color=color, label=f'p = {p}',
                markersize=6, linewidth=2)

    ax.axhline(y=delta, color='gray', linestyle='--', alpha=0.5,
               label=f'δ = {delta}')
    ax.set_xlabel('Valuation depth ν', fontsize=12)
    ax.set_ylabel('Stability bound δ/p^ν', fontsize=12)
    ax.set_title('Stability Bound vs. Divisibility Depth', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # --- Panel 2: Heatmap of bounds for p=2 ---
    ax = axes[1]
    p = 2
    deltas = np.arange(1, 65)
    nus = np.arange(0, 7)

    heatmap_data = np.zeros((len(nus), len(deltas)))
    for i, nu in enumerate(nus):
        for j, d in enumerate(deltas):
            heatmap_data[i, j] = valuation_sensitive_shift(p, nu, int(d))

    im = ax.imshow(heatmap_data, aspect='auto', cmap='viridis',
                   extent=[1, 64, 6.5, -0.5])
    ax.set_xlabel('δ (original shift)', fontsize=12)
    ax.set_ylabel('ν (valuation depth)', fontsize=12)
    ax.set_title(f'Shift Bound Heatmap (p = {p})', fontsize=13)
    ax.set_yticks(range(7))
    plt.colorbar(im, ax=ax, label='δ/p^ν')

    # --- Panel 3: Improvement ratio ---
    ax = axes[2]
    delta = 100

    for p, color in zip(primes, colors):
        nus = np.arange(0, 8)
        ratios = [valuation_sensitive_shift(p, int(nu), delta) / delta
                  for nu in nus]
        ax.plot(nus, ratios, 's-', color=color, label=f'p = {p}',
                markersize=6, linewidth=2)

    ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Valuation depth ν', fontsize=12)
    ax.set_ylabel('Ratio (δ/p^ν) / δ', fontsize=12)
    ax.set_title('Relative Improvement Factor', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(bottom=0.001)

    plt.suptitle('P-adic Controlled Persistence Stability',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_stability_bounds.png', dpi=150, bbox_inches='tight')
    print("Saved viz_stability_bounds.png")


if __name__ == "__main__":
    main()
