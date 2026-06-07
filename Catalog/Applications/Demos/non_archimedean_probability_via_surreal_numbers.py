#!/usr/bin/env python3
"""
Non-Archimedean Probability Space — Numerical Demonstrations

Demonstrates the key concepts from our formalization:
1. Uniform NA probability spaces
2. Bayes' theorem with infinitesimal-like probabilities
3. Conditioning on singleton events
4. Comparison of real vs non-Archimedean probability
"""

from fractions import Fraction
from typing import Dict, List, Set, Tuple


def demo_uniform_naprobspace():
    """Demonstrate a uniform NAProbSpace on a finite set."""
    print("=" * 60)
    print("Demo 1: Uniform NAProbSpace on {1, 2, ..., N}")
    print("=" * 60)

    N = 1000000  # A "large" finite set
    prob = Fraction(1, N)

    print(f"\nSample space Ω = {{1, 2, ..., {N}}}")
    print(f"Point probability: P({{ω}}) = 1/{N} = {float(prob):.2e}")
    print(f"Regularity: P({{ω}}) > 0 ✓ (= {prob})")
    print(f"Normalization: Σ P({{ω}}) = {N} × {prob} = {N * prob}")

    # Event probability
    A = set(range(1, 101))  # First 100 elements
    pA = Fraction(len(A), N)
    print(f"\nEvent A = {{1, ..., 100}}")
    print(f"P(A) = {len(A)}/{N} = {float(pA):.6f}")

    B = set(range(51, 201))  # Elements 51 to 200
    pB = Fraction(len(B), N)
    print(f"Event B = {{51, ..., 200}}")
    print(f"P(B) = {len(B)}/{N} = {float(pB):.6f}")

    # Inclusion-exclusion
    pAB = Fraction(len(A & B), N)
    pAuB = Fraction(len(A | B), N)
    print(f"\nInclusion-Exclusion:")
    print(f"P(A ∩ B) = {len(A & B)}/{N} = {float(pAB):.6f}")
    print(f"P(A ∪ B) = {len(A | B)}/{N} = {float(pAuB):.6f}")
    print(f"P(A) + P(B) - P(A ∩ B) = {float(pA + pB - pAB):.6f}")
    print(f"Verified: {pAuB == pA + pB - pAB} ✓")


def demo_bayes_theorem():
    """Demonstrate Bayes' theorem in NAProbSpace."""
    print("\n" + "=" * 60)
    print("Demo 2: Bayes' Theorem (Always Well-Defined)")
    print("=" * 60)

    # Medical test example with a rare disease
    N = 1000000
    disease = set(range(1, 11))  # 10 people have the disease
    healthy = set(range(11, N + 1))

    # Test: 95% true positive, 1% false positive
    test_pos = set()
    for i in disease:
        if i <= 9:  # 9/10 = 90% sensitivity
            test_pos.add(i)
    for i in healthy:
        if i % 100 == 0:  # 1% false positive
            test_pos.add(i)

    pD = Fraction(len(disease), N)
    pT = Fraction(len(test_pos), N)
    pTD = Fraction(len(test_pos & disease), N)
    pDT = Fraction(len(disease & test_pos), N)

    # P(D|T) = P(D ∩ T) / P(T)
    pD_given_T = pDT / pT if pT > 0 else Fraction(0)
    # P(T|D) = P(T ∩ D) / P(D)
    pT_given_D = pTD / pD if pD > 0 else Fraction(0)

    print(f"\nMedical Test Scenario (N = {N}):")
    print(f"  Disease prevalence: P(D) = {pD} = {float(pD):.6f}")
    print(f"  Test positive rate: P(T+) = {pT} ≈ {float(pT):.6f}")
    print(f"  P(D|T+) = {float(pD_given_T):.6f}")
    print(f"  P(T+|D) = {float(pT_given_D):.6f}")

    # Verify Bayes: P(D|T) * P(T) = P(T|D) * P(D)
    lhs = pD_given_T * pT
    rhs = pT_given_D * pD
    print(f"\nBayes verification:")
    print(f"  P(D|T) · P(T) = {float(lhs):.10f}")
    print(f"  P(T|D) · P(D) = {float(rhs):.10f}")
    print(f"  Equal: {lhs == rhs} ✓")


def demo_singleton_conditioning():
    """Demonstrate that singleton conditioning is always well-defined."""
    print("\n" + "=" * 60)
    print("Demo 3: Singleton Conditioning (Borel Paradox Resolution)")
    print("=" * 60)

    N = 100
    # Non-uniform distribution
    probs = {}
    total = sum(range(1, N + 1))
    for i in range(1, N + 1):
        probs[i] = Fraction(i, total)

    print(f"\nNon-uniform NAProbSpace on {{1, ..., {N}}}")
    print(f"P({{k}}) = k / {total}")
    print(f"Min probability: P({{1}}) = {probs[1]} = {float(probs[1]):.6f}")
    print(f"Max probability: P({{{N}}}) = {probs[N]} = {float(probs[N]):.4f}")

    # All singletons have positive probability
    print(f"\nRegularity check: all P({{ω}}) > 0? {all(p > 0 for p in probs.values())} ✓")
    print(f"Normalization: Σ P({{ω}}) = {sum(probs.values())}")

    # Condition on singleton {50}
    omega = 50
    A = set(range(1, 76))  # {1, ..., 75}
    pA = sum(probs[i] for i in A)
    p_omega = probs[omega]
    p_A_inter_omega = probs[omega] if omega in A else Fraction(0)
    p_A_given_omega = p_A_inter_omega / p_omega

    print(f"\nConditioning on singleton {{ω}} = {{{omega}}}:")
    print(f"  P({{{omega}}}) = {p_omega} = {float(p_omega):.6f} > 0 ✓")
    print(f"  P(A | {{{omega}}}) = {p_A_given_omega}")
    print(f"  (A = {{1,...,75}}, {omega} ∈ A, so P(A|{{{omega}}}) = 1)")
    print()
    print("  In standard measure theory on [0,1], P({x}) = 0 for all x,")
    print("  making P(A|{x}) = 0/0 — undefined!")
    print("  In NAProbSpace, this is always well-defined. ✓")


def demo_infinitesimal_scaling():
    """Show how probabilities scale as N grows (approaching infinitesimal)."""
    print("\n" + "=" * 60)
    print("Demo 4: Infinitesimal Scaling — P({ω}) → 0 as N → ∞")
    print("=" * 60)

    print("\n  N          P({ω})           N·P({ω})    Infinitesimal?")
    print("  " + "-" * 55)
    for k in range(1, 13):
        N = 10 ** k
        p = Fraction(1, N)
        np = N * p
        is_inf = "approaching" if k >= 6 else "standard"
        print(f"  10^{k:<6}   {float(p):<17.2e}  {float(np):<10}  {is_inf}")

    print("\n  In a non-Archimedean field with infinitesimal ε:")
    print("  Setting N ~ 1/ε gives P({ω}) = ε (truly infinitesimal)")
    print("  Yet Σ P({ω}) = N · ε = 1 (normalization holds)")


def demo_total_probability():
    """Demonstrate the Law of Total Probability."""
    print("\n" + "=" * 60)
    print("Demo 5: Law of Total Probability")
    print("=" * 60)

    N = 20
    probs = {i: Fraction(1, N) for i in range(1, N + 1)}

    A = {1, 2, 3, 4, 5, 6, 7, 8}
    B = {3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
    Bc = set(range(1, N + 1)) - B

    pA = sum(probs[i] for i in A)
    pB = sum(probs[i] for i in B)
    pBc = sum(probs[i] for i in Bc)
    pAB = sum(probs[i] for i in A & B)
    pABc = sum(probs[i] for i in A & Bc)

    pA_given_B = pAB / pB
    pA_given_Bc = pABc / pBc

    total = pA_given_B * pB + pA_given_Bc * pBc

    print(f"\nΩ = {{1, ..., {N}}}, uniform distribution")
    print(f"A = {sorted(A)}")
    print(f"B = {sorted(B)}")
    print(f"\nP(A) = {pA} = {float(pA):.4f}")
    print(f"P(B) = {pB} = {float(pB):.4f}")
    print(f"P(A|B) = {pA_given_B} = {float(pA_given_B):.4f}")
    print(f"P(A|Bᶜ) = {pA_given_Bc} = {float(pA_given_Bc):.4f}")
    print(f"\nP(A|B)·P(B) + P(A|Bᶜ)·P(Bᶜ) = {total} = {float(total):.4f}")
    print(f"P(A) = {pA} = {float(pA):.4f}")
    print(f"Law of Total Probability verified: {total == pA} ✓")


if __name__ == "__main__":
    demo_uniform_naprobspace()
    demo_bayes_theorem()
    demo_singleton_conditioning()
    demo_infinitesimal_scaling()
    demo_total_probability()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Probability Landscape

Shows how point probabilities scale as the sample space grows,
illustrating the transition from standard to infinitesimal regime.
"""

import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np


def plot_probability_scaling():
    """Plot how uniform point probability scales with N."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Log-log plot of P({ω}) vs N
    ax1 = axes[0]
    Ns = np.logspace(0, 12, 100)
    probs = 1.0 / Ns
    ax1.loglog(Ns, probs, 'b-', linewidth=2)
    ax1.fill_between(Ns, probs, 1e-15, alpha=0.1, color='blue')
    ax1.axhline(y=1e-6, color='red', linestyle='--', alpha=0.5, label='ε ~ 10⁻⁶')
    ax1.axhline(y=1e-9, color='orange', linestyle='--', alpha=0.5, label='ε ~ 10⁻⁹')
    ax1.set_xlabel('Sample Space Size N', fontsize=12)
    ax1.set_ylabel('P({ω}) = 1/N', fontsize=12)
    ax1.set_title('Point Probability Scaling', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Inclusion-exclusion verification
    ax2 = axes[1]
    N = 1000
    sizes_A = np.arange(10, 500, 10)
    sizes_B = 300
    pa_vals = sizes_A / N
    pb = sizes_B / N
    # A ∩ B size varies
    pab_vals = np.maximum(0, sizes_A + sizes_B - N) / N
    paub_vals = pa_vals + pb - pab_vals
    paub_direct = np.minimum(sizes_A + sizes_B, N) / N

    ax2.plot(sizes_A, pa_vals, 'b-', linewidth=2, label='P(A)')
    ax2.plot(sizes_A, paub_vals, 'r-', linewidth=2, label='P(A∪B) [I-E]')
    ax2.plot(sizes_A, paub_direct, 'g--', linewidth=2, label='P(A∪B) [direct]', alpha=0.7)
    ax2.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
    ax2.set_xlabel('|A|', fontsize=12)
    ax2.set_ylabel('Probability', fontsize=12)
    ax2.set_title(f'Inclusion-Exclusion (N={N}, |B|={sizes_B})', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Panel 3: Bayes' theorem visualization
    ax3 = axes[2]
    # Disease prevalence vs PPV (positive predictive value)
    prevalences = np.linspace(0.0001, 0.1, 200)
    sensitivity = 0.95
    specificity = 0.99

    # P(D|T+) = sens * prev / (sens * prev + (1-spec) * (1-prev))
    ppv = (sensitivity * prevalences) / (
        sensitivity * prevalences + (1 - specificity) * (1 - prevalences)
    )

    ax3.plot(prevalences * 100, ppv * 100, 'b-', linewidth=2)
    ax3.fill_between(prevalences * 100, ppv * 100, alpha=0.1, color='blue')
    ax3.set_xlabel('Disease Prevalence (%)', fontsize=12)
    ax3.set_ylabel('Positive Predictive Value (%)', fontsize=12)
    ax3.set_title("Bayes' Theorem: PPV vs Prevalence", fontsize=13)
    ax3.grid(True, alpha=0.3)
    ax3.annotate('Even with 95% sensitivity\nand 99% specificity,\nrare diseases → low PPV',
                 xy=(1, 50), fontsize=9, style='italic',
                 bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    plt.savefig('probability_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: probability_landscape.png")


def plot_regularity_comparison():
    """Compare regular (NAProbSpace) vs standard probability."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel 1: Standard probability on [0,1] - singletons have measure 0
    ax1 = axes[0]
    x = np.linspace(0, 1, 1000)
    density = np.ones_like(x)  # Uniform density
    ax1.fill_between(x, density, alpha=0.3, color='blue', label='Density = 1')
    ax1.plot(x, density, 'b-', linewidth=2)

    # Show that P({x}) = 0
    points = [0.2, 0.5, 0.8]
    for p in points:
        ax1.plot(p, 0, 'ro', markersize=8, zorder=5)
        ax1.annotate(f'P({{{p}}}) = 0', xy=(p, 0), xytext=(p, 0.3),
                     fontsize=9, ha='center',
                     arrowprops=dict(arrowstyle='->', color='red'))

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('Probability', fontsize=12)
    ax1.set_title('Standard: P({x}) = 0 (No Regularity)', fontsize=13)
    ax1.set_ylim(-0.1, 1.5)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Panel 2: NAProbSpace - every point has positive probability
    ax2 = axes[1]
    N = 50
    xs = np.arange(1, N + 1)
    probs = np.ones(N) / N

    ax2.bar(xs, probs, color='green', alpha=0.5, edgecolor='green', linewidth=0.5)
    ax2.axhline(y=1/N, color='green', linestyle='--', alpha=0.7,
                label=f'P({{ω}}) = 1/{N} = ε > 0')

    # Highlight a singleton
    ax2.bar([25], [1/N], color='red', alpha=0.7, edgecolor='red')
    ax2.annotate(f'P({{25}}) = 1/{N} > 0\nConditioning defined!',
                 xy=(25, 1/N), xytext=(35, 0.04),
                 fontsize=9, ha='center',
                 arrowprops=dict(arrowstyle='->', color='red'),
                 bbox=dict(boxstyle='round', facecolor='lightyellow'))

    ax2.set_xlabel('ω', fontsize=12)
    ax2.set_ylabel('P({ω})', fontsize=12)
    ax2.set_title(f'NAProbSpace: P({{ω}}) = ε > 0 (Regular)', fontsize=13)
    ax2.legend(fontsize=10, loc='upper right')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('regularity_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: regularity_comparison.png")


if __name__ == "__main__":
    plot_probability_scaling()
    plot_regularity_comparison()
    print("\nAll visualizations generated successfully!")
