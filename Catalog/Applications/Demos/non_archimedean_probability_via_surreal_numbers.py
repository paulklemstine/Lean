#!/usr/bin/env python3
"""
Surreal Probability: Numerical Demonstrations

Demonstrates the key results of the surreal probability theory:
1. Infinitesimal perturbation of uniform measures
2. Dual impossibility theorem (numerical illustration)
3. Product measures
4. Bayesian update with near-infinitesimal priors
5. Information ordering
"""

from fractions import Fraction
from typing import List, Dict, Tuple
import math


def uniform_measure(n: int) -> List[Fraction]:
    """Uniform probability measure on n elements."""
    return [Fraction(1, n)] * n


def perturbed_measure(n: int, weights: List[int], eps: Fraction) -> List[Fraction]:
    """
    Infinitesimally perturbed uniform measure.
    
    Each element i gets probability 1/n + weights[i] * eps.
    Weights must sum to 0.
    """
    assert len(weights) == n, f"Need {n} weights, got {len(weights)}"
    assert sum(weights) == 0, f"Weights must sum to 0, got {sum(weights)}"
    base = Fraction(1, n)
    return [base + w * eps for w in weights]


def is_valid_pmf(pmf: List[Fraction]) -> bool:
    """Check if a pmf is valid: non-negative and sums to 1."""
    return all(p >= 0 for p in pmf) and sum(pmf) == 1


def is_fully_discriminating(pmf: List[Fraction]) -> bool:
    """Check if all probabilities are distinct."""
    return len(set(pmf)) == len(pmf)


def product_measure(mu: List[Fraction], nu: List[Fraction]) -> Dict[Tuple[int, int], Fraction]:
    """Product of two probability measures."""
    result = {}
    for i, p in enumerate(mu):
        for j, q in enumerate(nu):
            result[(i, j)] = p * q
    return result


def conditional_prob(pmf: List[Fraction], event: List[int]) -> Dict[int, Fraction]:
    """Conditional probability given an event (list of indices)."""
    total = sum(pmf[i] for i in event)
    assert total > 0, "Cannot condition on zero-probability event"
    result = {}
    for i in range(len(pmf)):
        if i in event:
            result[i] = pmf[i] / total
        else:
            result[i] = Fraction(0)
    return result


def bayesian_update(prior: List[Fraction], likelihood: List[Fraction]) -> List[Fraction]:
    """Bayesian update: posterior ∝ likelihood * prior."""
    evidence = sum(l * p for l, p in zip(likelihood, prior))
    assert evidence > 0, "Evidence must be positive"
    return [(l * p) / evidence for l, p in zip(likelihood, prior)]


def refines(mu: List[Fraction], nu: List[Fraction]) -> bool:
    """Check if mu refines nu (preserves all distinctions)."""
    n = len(mu)
    for i in range(n):
        for j in range(i + 1, n):
            if nu[i] != nu[j] and mu[i] == mu[j]:
                return False
    return True


def demo_perturbation():
    """Demonstrate infinitesimal perturbation."""
    print("=" * 60)
    print("DEMO 1: Infinitesimal Perturbation")
    print("=" * 60)
    
    n = 5
    # Use eps = 1/10000 as a "near-infinitesimal"
    eps = Fraction(1, 10000)
    weights = [-2, -1, 0, 1, 2]  # Sum = 0
    
    uniform = uniform_measure(n)
    perturbed = perturbed_measure(n, weights, eps)
    
    print(f"\nUniform measure on {n} elements:")
    for i, p in enumerate(uniform):
        print(f"  P({i}) = {p} = {float(p):.6f}")
    print(f"  Valid: {is_valid_pmf(uniform)}")
    print(f"  Fully discriminating: {is_fully_discriminating(uniform)}")
    
    print(f"\nPerturbed measure (ε = {eps}, weights = {weights}):")
    for i, p in enumerate(perturbed):
        print(f"  P({i}) = {p} = {float(p):.10f}")
    print(f"  Valid: {is_valid_pmf(perturbed)}")
    print(f"  Fully discriminating: {is_fully_discriminating(perturbed)}")
    print(f"  Sum = {sum(perturbed)}")


def demo_dual_impossibility():
    """Demonstrate the dual impossibility theorem numerically."""
    print("\n" + "=" * 60)
    print("DEMO 2: Dual Impossibility Theorem")
    print("=" * 60)
    
    # Archimedean direction: eps = 0.01, sums diverge
    eps_arch = 0.01
    print(f"\nArchimedean direction (ε = {eps_arch}):")
    print("  Partial sums of uniform ε-probability on ℕ:")
    for n in [10, 50, 100, 500, 1000]:
        s = n * eps_arch
        print(f"  Sum over {n:4d} elements: {s:8.2f} {'> 1 ✗' if s > 1 else '≤ 1 ✓'}")
    
    # Non-Archimedean direction: eps "infinitesimal" → eps < 1/(n+1)
    print(f"\nNon-Archimedean direction (ε < 1/(n+1) for all n):")
    print("  For any finite set of size n, sum = n·ε < n/(n+1) < 1:")
    for n in [10, 100, 1000, 10000]:
        bound = Fraction(n, n + 1)
        print(f"  n = {n:5d}: n·ε < {bound} = {float(bound):.10f} < 1 ✓")


def demo_product():
    """Demonstrate product measures."""
    print("\n" + "=" * 60)
    print("DEMO 3: Product Measure")
    print("=" * 60)
    
    eps = Fraction(1, 10000)
    mu = perturbed_measure(3, [-1, 0, 1], eps)
    nu = perturbed_measure(2, [-1, 1], eps)
    
    print(f"\nMeasure μ on {{0,1,2}}:")
    for i, p in enumerate(mu):
        print(f"  μ({i}) = {float(p):.8f}")
    
    print(f"\nMeasure ν on {{0,1}}:")
    for i, p in enumerate(nu):
        print(f"  ν({i}) = {float(p):.8f}")
    
    prod = product_measure(mu, nu)
    print(f"\nProduct measure μ×ν on {{0,1,2}}×{{0,1}}:")
    for (i, j), p in sorted(prod.items()):
        print(f"  (μ×ν)({i},{j}) = {float(p):.12f}")
    print(f"  Sum = {sum(prod.values())}")
    print(f"  Valid: {sum(prod.values()) == 1}")


def demo_conditional():
    """Demonstrate conditional probability."""
    print("\n" + "=" * 60)
    print("DEMO 4: Conditional Probability")
    print("=" * 60)
    
    eps = Fraction(1, 10000)
    pmf = perturbed_measure(4, [-3, -1, 1, 3], eps)
    
    print(f"\nMeasure on {{0,1,2,3}}:")
    for i, p in enumerate(pmf):
        print(f"  P({i}) = {float(p):.10f}")
    
    event = [0, 1]
    cond = conditional_prob(pmf, event)
    print(f"\nConditional on event {{{', '.join(map(str, event))}}}:")
    for i, p in cond.items():
        print(f"  P({i}|event) = {float(p):.10f}")
    print(f"  Sum over event = {sum(cond[i] for i in event)}")


def demo_bayesian():
    """Demonstrate Bayesian update with near-infinitesimal prior."""
    print("\n" + "=" * 60)
    print("DEMO 5: Bayesian Update")
    print("=" * 60)
    
    eps = Fraction(1, 10000)
    prior = perturbed_measure(3, [-1, 0, 1], eps)
    likelihood = [Fraction(9, 10), Fraction(1, 10), Fraction(5, 10)]
    
    posterior = bayesian_update(prior, likelihood)
    
    print(f"\nPrior (perturbed uniform, ε = {eps}):")
    for i, p in enumerate(prior):
        print(f"  P(H{i}) = {float(p):.10f}")
    
    print(f"\nLikelihood P(D|Hᵢ):")
    for i, l in enumerate(likelihood):
        print(f"  P(D|H{i}) = {float(l):.4f}")
    
    print(f"\nPosterior P(Hᵢ|D):")
    for i, p in enumerate(posterior):
        print(f"  P(H{i}|D) = {float(p):.10f}")
    print(f"  Sum = {sum(posterior)}")


def demo_information():
    """Demonstrate information ordering."""
    print("\n" + "=" * 60)
    print("DEMO 6: Information Ordering")
    print("=" * 60)
    
    eps = Fraction(1, 10000)
    uniform = uniform_measure(4)
    perturbed1 = perturbed_measure(4, [-3, -1, 1, 3], eps)
    perturbed2 = perturbed_measure(4, [-1, 0, 0, 1], eps)  # Not injective!
    
    print(f"\nUniform: {[float(p) for p in uniform]}")
    print(f"Perturbed1 (injective weights): {[float(p) for p in perturbed1]}")
    print(f"Perturbed2 (non-injective weights): {[float(p) for p in perturbed2]}")
    
    print(f"\nPerturbed1 refines uniform: {refines(perturbed1, uniform)}")
    print(f"Perturbed2 refines uniform: {refines(perturbed2, uniform)}")
    print(f"Uniform refines perturbed1: {refines(uniform, perturbed1)}")
    print(f"Perturbed1 fully discriminating: {is_fully_discriminating(perturbed1)}")
    print(f"Perturbed2 fully discriminating: {is_fully_discriminating(perturbed2)}")


if __name__ == "__main__":
    demo_perturbation()
    demo_dual_impossibility()
    demo_product()
    demo_conditional()
    demo_bayesian()
    demo_information()


#!/usr/bin/env python3
"""
Visualization: Dual Impossibility Theorem for Surreal Probability

Shows both directions of the impossibility:
1. Archimedean: partial sums of ε diverge (left panel)
2. Non-Archimedean: partial sums of infinitesimal ε are trapped below 1 (right panel)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_dual_impossibility():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Dual Impossibility Theorem for Surreal Probability",
                 fontsize=16, fontweight='bold', y=0.98)
    
    # Panel 1: Archimedean direction
    epsilons = [0.1, 0.05, 0.01, 0.005, 0.001]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(epsilons)))
    
    for eps, color in zip(epsilons, colors):
        n_vals = np.arange(1, int(2.0 / eps) + 10)
        sums = n_vals * eps
        ax1.plot(n_vals, sums, color=color, linewidth=2,
                label=f"ε = {eps}")
    
    ax1.axhline(y=1, color='red', linestyle='--', linewidth=2, alpha=0.7,
               label='Target: sum = 1')
    ax1.set_xlabel("Number of elements (n)", fontsize=12)
    ax1.set_ylabel("Partial sum: n · ε", fontsize=12)
    ax1.set_title("Archimedean Direction\n(ε fixed, n grows → sum diverges)", fontsize=13)
    ax1.legend(fontsize=9, loc='upper left')
    ax1.set_ylim(0, 3)
    ax1.set_xlim(0, 500)
    ax1.fill_between([0, 500], 1, 3, alpha=0.1, color='red')
    ax1.text(250, 2.5, "Sum exceeds 1\n(impossible region)",
            ha='center', fontsize=11, color='darkred', style='italic')
    ax1.grid(True, alpha=0.3)
    
    # Panel 2: Non-Archimedean direction
    n_vals = np.arange(1, 101)
    bounds = n_vals / (n_vals + 1)
    
    ax2.fill_between(n_vals, bounds, 1, alpha=0.15, color='blue',
                    label='Gap: 1 - n/(n+1)')
    ax2.plot(n_vals, bounds, 'b-', linewidth=2.5,
            label='Upper bound: n/(n+1)')
    ax2.axhline(y=1, color='red', linestyle='--', linewidth=2, alpha=0.7,
               label='Target: sum = 1')
    
    # Show specific points
    for n in [5, 10, 25, 50, 100]:
        if n <= 100:
            b = n / (n + 1)
            ax2.plot(n, b, 'ko', markersize=6, zorder=5)
            ax2.annotate(f'n={n}: {b:.4f}', (n, b),
                        textcoords="offset points",
                        xytext=(10, -15 if n % 2 == 0 else 10),
                        fontsize=8, color='navy')
    
    ax2.set_xlabel("Number of elements (n)", fontsize=12)
    ax2.set_ylabel("Upper bound on partial sum", fontsize=12)
    ax2.set_title("Non-Archimedean Direction\n(ε infinitesimal → sum trapped below 1)", fontsize=13)
    ax2.legend(fontsize=10, loc='lower right')
    ax2.set_ylim(0, 1.1)
    ax2.set_xlim(0, 105)
    ax2.grid(True, alpha=0.3)
    ax2.text(50, 0.3, "Sum ≤ n/(n+1) < 1\nfor ALL finite n",
            ha='center', fontsize=12, color='navy', style='italic',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightblue', alpha=0.5))
    
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig("dual_impossibility.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dual_impossibility.png")


def plot_discrimination_power():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Discrimination Power of Surreal Probability Measures",
                 fontsize=16, fontweight='bold', y=0.98)
    
    # Panel 1: Uniform vs Perturbed
    n = 6
    eps = 0.005
    weights = [-5, -3, -1, 1, 3, 5]
    
    uniform = [1/n] * n
    perturbed = [1/n + w * eps for w in weights]
    
    x = np.arange(n)
    width = 0.35
    
    bars1 = ax1.bar(x - width/2, uniform, width, label='Uniform',
                   color='steelblue', alpha=0.8, edgecolor='navy')
    bars2 = ax1.bar(x + width/2, perturbed, width, label='Perturbed (ε-shifted)',
                   color='coral', alpha=0.8, edgecolor='darkred')
    
    ax1.set_xlabel("Element index", fontsize=12)
    ax1.set_ylabel("Probability", fontsize=12)
    ax1.set_title("Uniform vs Perturbed Measure\n(6 elements)", fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_xticks(x)
    ax1.set_xticklabels([f'a{i}' for i in range(n)])
    ax1.grid(True, alpha=0.3, axis='y')
    ax1.set_ylim(0, max(perturbed) * 1.3)
    
    # Annotate the infinitesimal differences
    for i in range(n):
        diff = perturbed[i] - uniform[i]
        sign = '+' if diff >= 0 else ''
        ax1.annotate(f'{sign}{diff:.3f}',
                    (x[i] + width/2, perturbed[i]),
                    textcoords="offset points", xytext=(0, 5),
                    fontsize=8, ha='center', color='darkred')
    
    # Panel 2: Information content vs epsilon
    n = 5
    weights = [-2, -1, 0, 1, 2]
    epsilons = np.logspace(-6, -1, 50)
    
    spreads = [max(1/n + w * e for w in weights) - min(1/n + w * e for w in weights)
              for e in epsilons]
    
    ax2.semilogx(epsilons, spreads, 'b-', linewidth=2.5)
    ax2.fill_between(epsilons, 0, spreads, alpha=0.2, color='blue')
    ax2.set_xlabel("ε (infinitesimal parameter)", fontsize=12)
    ax2.set_ylabel("Spread: max(μ) - min(μ)", fontsize=12)
    ax2.set_title("Discrimination Spread vs ε\n(grows linearly with ε)", fontsize=13)
    ax2.grid(True, alpha=0.3)
    
    # Mark key points
    for e in [1e-5, 1e-3, 1e-1]:
        s = max(1/n + w * e for w in weights) - min(1/n + w * e for w in weights)
        ax2.plot(e, s, 'ro', markersize=8, zorder=5)
        ax2.annotate(f'ε={e:.0e}\nspread={s:.4f}',
                    (e, s), textcoords="offset points",
                    xytext=(15, 5), fontsize=9,
                    arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig("discrimination_power.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: discrimination_power.png")


if __name__ == "__main__":
    plot_dual_impossibility()
    plot_discrimination_power()
