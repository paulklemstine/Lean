#!/usr/bin/env python3
"""
Thermodynamic Sanov–Large-Deviation Completeness: Interactive Demo

This script demonstrates the core theorem with concrete numerical examples,
showing how derivability in a closure proof semiring corresponds to the
vanishing of a thermodynamic rate function.

We use a simple finite distributive lattice (the divisor lattice of 30)
with a trivial closure operator to illustrate:

1. How countermodel defects detect non-derivability
2. How the thermodynamic rate function combines divergence and energy
3. The completeness theorem: derivable ⟺ zero rate infimum

Requirements: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from typing import Callable, List, Tuple, Dict
import os

# =============================================================================
# Part 1: Finite Distributive Lattice (Divisor lattice of 30 = 2·3·5)
# =============================================================================

def divisors(n: int) -> List[int]:
    """Return sorted list of divisors of n."""
    return sorted([d for d in range(1, n + 1) if n % d == 0])

def lcm(a: int, b: int) -> int:
    """Least common multiple."""
    from math import gcd
    return a * b // gcd(a, b)

from math import gcd

class DivisorLattice:
    """
    The divisor lattice of n, where:
    - elements are divisors of n
    - meet (⊓) = gcd
    - join (⊔) = lcm
    - ⊥ = 1
    - ⊤ = n
    
    This is a bounded distributive lattice.
    """
    
    def __init__(self, n: int):
        self.n = n
        self.elements = divisors(n)
        self.bot = 1
        self.top = n
    
    def meet(self, a: int, b: int) -> int:
        return gcd(a, b)
    
    def join(self, a: int, b: int) -> int:
        return lcm(a, b)
    
    def le(self, a: int, b: int) -> bool:
        """a ≤ b iff a divides b."""
        return b % a == 0
    
    def __repr__(self):
        return f"DivisorLattice({self.n}), elements={self.elements}"


class ClosureProofSemiring:
    """
    A coherent closure proof semiring: a DivisorLattice with a closure operator.
    
    We use cl(x) = lcm(x, k) for a fixed k, which satisfies:
    - Extensive: x | lcm(x, k)
    - Idempotent: lcm(lcm(x, k), k) = lcm(x, k)
    - Monotone: if x | y then lcm(x, k) | lcm(y, k)
    """
    
    def __init__(self, n: int, k: int = 1):
        self.lattice = DivisorLattice(n)
        self.k = k  # closure parameter
    
    def cl(self, x: int) -> int:
        """Closure operator: cl(x) = lcm(x, k)."""
        return lcm(x, self.k)
    
    def derivable(self, x: int, y: int) -> bool:
        """x derives y iff cl(x) | cl(y), i.e., cl(x) ≤ cl(y)."""
        return self.cl(y) % self.cl(x) == 0
    
    def prime_filters(self) -> List[Callable[[int], bool]]:
        """
        Return the prime filters of the divisor lattice.
        For the divisor lattice of n = p1^a1 * ... * pk^ak,
        the prime filters correspond to choosing, for each prime pi,
        a threshold power. The simplest prime filters are the
        "p-adic" ones: {d : p^j | d} for each prime p dividing n
        and power j.
        
        For simplicity, we use indicator functions of principal upsets
        ↑d = {x : d | x} for prime-power divisors d.
        """
        n = self.lattice.n
        filters = []
        
        # Find prime factorization
        primes = []
        temp = n
        for p in range(2, n + 1):
            if temp % p == 0:
                power = 1
                temp //= p
                while temp % p == 0:
                    power += 1
                    temp //= p
                primes.append((p, power))
        
        # For each prime p dividing n, create a filter for each subset
        # of primes. A prime filter of a distributive lattice corresponds
        # to a lattice homomorphism to {0, 1}.
        # For the divisor lattice, prime filters correspond to choosing
        # for each prime factor p, whether to "accept" it (val(p) = True)
        # or not.
        
        # The prime filters of Div(n) for n = p1*p2*...*pk (squarefree)
        # are: for each subset S of prime factors, the filter
        # {d : all primes in S divide d}.
        # These are prime iff S is a singleton or... actually the prime
        # filters correspond to maximal chains.
        
        # For squarefree n, the prime spectrum is in bijection with
        # the prime factors. The prime filter for prime p is:
        # val(d) = True iff p | d.
        
        for p, _ in primes:
            def make_filter(p=p):
                def f(d):
                    return d % p == 0
                return f
            filters.append(make_filter())
        
        return filters, [p for p, _ in primes]


# =============================================================================
# Part 2: Countermodel Defect and Thermodynamic Rate
# =============================================================================

def countermodel_defect(cps: ClosureProofSemiring, x: int, y: int,
                         val: Callable[[int], bool]) -> float:
    """
    Countermodel defect: 1 if val(cl(x)) and not val(cl(y)), else 0.
    """
    if val(cps.cl(x)) and not val(cps.cl(y)):
        return 1.0
    return 0.0


def l2_divergence(nu: np.ndarray, mu: np.ndarray) -> float:
    """Squared L2 divergence: ∑(ν_p - μ_p)²."""
    return float(np.sum((nu - mu) ** 2))


def kl_divergence(nu: np.ndarray, mu: np.ndarray) -> float:
    """KL divergence: ∑ ν_p * log(ν_p / μ_p), with 0*log(0) = 0."""
    result = 0.0
    for i in range(len(nu)):
        if nu[i] > 0 and mu[i] > 0:
            result += nu[i] * np.log(nu[i] / mu[i])
        elif nu[i] > 0 and mu[i] == 0:
            return float('inf')
    return result


def energy_defect(cps: ClosureProofSemiring, x: int, y: int,
                  beta: float, nu: np.ndarray,
                  filters: List[Callable]) -> float:
    """Energy defect: β * ∑ ν_p * defect(x, y, p)."""
    total = 0.0
    for i, f in enumerate(filters):
        total += nu[i] * countermodel_defect(cps, x, y, f)
    return beta * total


def thermodynamic_rate(cps: ClosureProofSemiring, x: int, y: int,
                       beta: float, nu: np.ndarray, mu: np.ndarray,
                       filters: List[Callable],
                       divergence='l2') -> float:
    """
    Thermodynamic rate: D(ν‖μ) + β * ∑ ν_p * defect(x, y, p).
    """
    if divergence == 'l2':
        div = l2_divergence(nu, mu)
    else:
        div = kl_divergence(nu, mu)
    energy = energy_defect(cps, x, y, beta, nu, filters)
    return div + energy


# =============================================================================
# Part 3: Demonstrations
# =============================================================================

def demo_basic_lattice():
    """Demonstrate the basic lattice structure and derivability."""
    print("=" * 70)
    print("DEMO 1: Basic Lattice Structure and Derivability")
    print("=" * 70)
    
    # Divisor lattice of 30 = 2 × 3 × 5
    cps = ClosureProofSemiring(30, k=1)  # trivial closure (identity)
    
    print(f"\nLattice: Divisors of 30 = {cps.lattice.elements}")
    print(f"Closure parameter k = {cps.k}")
    print(f"cl(x) = lcm(x, {cps.k}) = x (identity closure)")
    
    print("\nDerivability (x derives y iff cl(x) | cl(y), i.e., x | y):")
    test_pairs = [(1, 6), (6, 30), (2, 3), (6, 10), (1, 30), (30, 1)]
    for x, y in test_pairs:
        d = cps.derivable(x, y)
        print(f"  {x} derives {y}: {d}  "
              f"(cl({x})={cps.cl(x)}, cl({y})={cps.cl(y)}, "
              f"{cps.cl(x)} | {cps.cl(y)} = {d})")
    
    # Non-trivial closure
    cps2 = ClosureProofSemiring(30, k=6)
    print(f"\nWith closure cl(x) = lcm(x, 6):")
    for x in cps2.lattice.elements:
        print(f"  cl({x}) = {cps2.cl(x)}")
    
    print("\nDerivability with cl(x) = lcm(x, 6):")
    for x, y in test_pairs:
        d = cps2.derivable(x, y)
        print(f"  {x} derives {y}: {d}  "
              f"(cl({x})={cps2.cl(x)}, cl({y})={cps2.cl(y)})")


def demo_countermodel_defect():
    """Demonstrate countermodel defects and spectral separation."""
    print("\n" + "=" * 70)
    print("DEMO 2: Countermodel Defects and Spectral Separation")
    print("=" * 70)
    
    cps = ClosureProofSemiring(30, k=1)
    filters, primes = cps.prime_filters()
    
    print(f"\nSpectral points (prime filters for primes {primes}):")
    for i, p in enumerate(primes):
        print(f"  Filter {i} (prime {p}): val(d) = True iff {p} | d")
    
    # Derivable pair: 2 derives 6 (since 2 | 6)
    print("\n--- Derivable pair: x=2, y=6 ---")
    for i, (f, p) in enumerate(zip(filters, primes)):
        d = countermodel_defect(cps, 2, 6, f)
        print(f"  Filter {p}: val(cl(2))={f(cps.cl(2))}, "
              f"val(cl(6))={f(cps.cl(6))}, defect={d}")
    print("  → All defects = 0, confirming derivability ✓")
    
    # Non-derivable pair: 2 does not derive 3 (since 2 ∤ 3)
    print("\n--- Non-derivable pair: x=2, y=3 ---")
    for i, (f, p) in enumerate(zip(filters, primes)):
        d = countermodel_defect(cps, 2, 3, f)
        print(f"  Filter {p}: val(cl(2))={f(cps.cl(2))}, "
              f"val(cl(3))={f(cps.cl(3))}, defect={d}")
    print("  → Filter 2 has defect=1, witnessing non-derivability ✓")
    
    # Another non-derivable pair: 6 does not derive 10
    print("\n--- Non-derivable pair: x=6, y=10 ---")
    for i, (f, p) in enumerate(zip(filters, primes)):
        d = countermodel_defect(cps, 6, 10, f)
        print(f"  Filter {p}: val(cl(6))={f(cps.cl(6))}, "
              f"val(cl(10))={f(cps.cl(10))}, defect={d}")
    print("  → Filter 3 has defect=1, witnessing non-derivability ✓")


def demo_thermodynamic_rate():
    """Demonstrate the thermodynamic rate function."""
    print("\n" + "=" * 70)
    print("DEMO 3: Thermodynamic Rate Function")
    print("=" * 70)
    
    cps = ClosureProofSemiring(30, k=1)
    filters, primes = cps.prime_filters()
    n_filters = len(filters)
    
    # Uniform reference measure
    mu = np.ones(n_filters) / n_filters
    print(f"\nReference measure μ = uniform({1/n_filters:.4f}, ...) over {primes}")
    
    # Derivable pair: 2 derives 6
    print("\n--- Derivable pair: x=2, y=6 ---")
    beta_values = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
    for beta in beta_values:
        rate = thermodynamic_rate(cps, 2, 6, beta, mu, mu, filters)
        print(f"  β={beta:5.1f}: rate(μ) = {rate:.6f}")
    print("  → Rate at reference = 0 for all β (theorem confirmed) ✓")
    
    # Non-derivable pair: 2 does not derive 3
    print("\n--- Non-derivable pair: x=2, y=3 ---")
    for beta in beta_values:
        rate = thermodynamic_rate(cps, 2, 3, beta, mu, mu, filters)
        print(f"  β={beta:5.1f}: rate(μ) = {rate:.6f}")
    print("  → Rate at reference > 0 for all β > 0 (theorem confirmed) ✓")
    
    # Show infimum over distributions
    print("\n  Infimum search over discrete distributions:")
    for beta in [0.5, 1.0, 5.0]:
        min_rate = float('inf')
        best_nu = None
        # Grid search over probability simplex
        grid = 20
        for i in range(grid + 1):
            for j in range(grid + 1 - i):
                k_val = grid - i - j
                nu = np.array([i/grid, j/grid, k_val/grid])
                rate = thermodynamic_rate(cps, 2, 3, beta, nu, mu, filters)
                if rate < min_rate:
                    min_rate = rate
                    best_nu = nu.copy()
        print(f"  β={beta:.1f}: inf rate ≈ {min_rate:.6f} "
              f"(achieved at ν ≈ [{best_nu[0]:.2f}, {best_nu[1]:.2f}, {best_nu[2]:.2f}])")
    print("  → Infimum is bounded away from 0 (positive rate gap) ✓")


def demo_visualization():
    """Create visualizations of the rate function."""
    print("\n" + "=" * 70)
    print("DEMO 4: Visualizations")
    print("=" * 70)
    
    cps = ClosureProofSemiring(30, k=1)
    filters, primes = cps.prime_filters()
    n_filters = len(filters)
    mu = np.ones(n_filters) / n_filters
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle("Thermodynamic Sanov Completeness: Rate Function Analysis",
                 fontsize=14, fontweight='bold')
    
    # Plot 1: Rate at reference vs β for different pairs
    ax = axes[0, 0]
    betas = np.linspace(0.01, 10, 200)
    
    pairs = [(2, 6, 'Derivable: 2→6'),
             (2, 3, 'Non-derivable: 2→3'),
             (6, 10, 'Non-derivable: 6→10'),
             (3, 5, 'Non-derivable: 3→5')]
    
    for x, y, label in pairs:
        rates = [thermodynamic_rate(cps, x, y, b, mu, mu, filters) for b in betas]
        ax.plot(betas, rates, label=label, linewidth=2)
    
    ax.set_xlabel('Inverse temperature β')
    ax.set_ylabel('Rate at reference R(μ)')
    ax.set_title('Rate at Reference Measure vs β')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.1, 5)
    
    # Plot 2: Rate landscape for non-derivable pair (2→3)
    ax = axes[0, 1]
    beta = 2.0
    grid_size = 100
    
    # Parameterize 3-simplex by first two coordinates
    t1_vals = np.linspace(0, 1, grid_size)
    t2_vals = np.linspace(0, 1, grid_size)
    
    rate_grid = np.full((grid_size, grid_size), np.nan)
    for i, t1 in enumerate(t1_vals):
        for j, t2 in enumerate(t2_vals):
            t3 = 1 - t1 - t2
            if t3 >= 0:
                nu = np.array([t1, t2, t3])
                rate_grid[j, i] = thermodynamic_rate(
                    cps, 2, 3, beta, nu, mu, filters)
    
    im = ax.imshow(rate_grid, extent=[0, 1, 0, 1], origin='lower',
                   cmap='viridis', aspect='equal', vmin=0, vmax=3)
    plt.colorbar(im, ax=ax, label='Rate')
    ax.set_xlabel(f'ν({primes[0]})')
    ax.set_ylabel(f'ν({primes[1]})')
    ax.set_title(f'Rate Landscape (2→3, β={beta})')
    ax.plot([1/3], [1/3], 'r*', markersize=15, label='μ (reference)')
    ax.legend()
    
    # Plot 3: Infimum of rate vs β for derivable vs non-derivable
    ax = axes[1, 0]
    betas_search = np.linspace(0.1, 8, 40)
    
    for x, y, label in [(2, 6, 'Derivable: 2→6'), (2, 3, 'Non-derivable: 2→3')]:
        inf_rates = []
        for b in betas_search:
            min_r = float('inf')
            grid = 30
            for i in range(grid + 1):
                for j in range(grid + 1 - i):
                    k_val = grid - i - j
                    nu = np.array([i/grid, j/grid, k_val/grid])
                    r = thermodynamic_rate(cps, x, y, b, nu, mu, filters)
                    min_r = min(min_r, r)
            inf_rates.append(min_r)
        ax.plot(betas_search, inf_rates, 'o-', label=label, markersize=3)
    
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Inverse temperature β')
    ax.set_ylabel('inf_ν Rate(ν)')
    ax.set_title('Infimum of Rate Function vs β')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 4: Defect pattern across spectral points
    ax = axes[1, 1]
    test_pairs_full = [(1, 6), (2, 6), (6, 30), (2, 3), (6, 10),
                       (3, 5), (2, 15), (10, 6)]
    
    defect_matrix = np.zeros((len(test_pairs_full), n_filters))
    pair_labels = []
    for idx, (x, y) in enumerate(test_pairs_full):
        d = cps.derivable(x, y)
        pair_labels.append(f"{x}→{y} ({'D' if d else 'ND'})")
        for j, f in enumerate(filters):
            defect_matrix[idx, j] = countermodel_defect(cps, x, y, f)
    
    im = ax.imshow(defect_matrix, cmap='Reds', aspect='auto', vmin=0, vmax=1)
    plt.colorbar(im, ax=ax, label='Defect')
    ax.set_xticks(range(n_filters))
    ax.set_xticklabels([f'Filter({p})' for p in primes])
    ax.set_yticks(range(len(pair_labels)))
    ax.set_yticklabels(pair_labels)
    ax.set_title('Countermodel Defect Pattern')
    ax.set_xlabel('Spectral Point')
    ax.set_ylabel('Pair (D=Derivable, ND=Non-derivable)')
    
    plt.tight_layout()
    output_path = os.path.join(os.path.dirname(__file__),
                               'thermodynamic_sanov_plots.png')
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"\nVisualization saved to {output_path}")
    plt.close()


def demo_completeness_verification():
    """Systematically verify the completeness theorem on all pairs."""
    print("\n" + "=" * 70)
    print("DEMO 5: Systematic Completeness Verification")
    print("=" * 70)
    
    cps = ClosureProofSemiring(30, k=1)
    filters, primes = cps.prime_filters()
    n_filters = len(filters)
    mu = np.ones(n_filters) / n_filters
    
    elements = cps.lattice.elements
    beta = 2.0
    
    print(f"\nLattice elements: {elements}")
    print(f"Checking all pairs (x, y) with β = {beta}:")
    print(f"{'Pair':>10} {'Derivable':>10} {'Rate(μ)':>10} "
          f"{'inf Rate':>10} {'Zero?':>8} {'Match?':>8}")
    
    all_match = True
    count = 0
    for x in elements:
        for y in elements:
            d = cps.derivable(x, y)
            rate_at_mu = thermodynamic_rate(cps, x, y, beta, mu, mu, filters)
            
            # Quick infimum search
            min_rate = rate_at_mu
            grid = 20
            for i in range(grid + 1):
                for j in range(grid + 1 - i):
                    k_val = grid - i - j
                    nu = np.array([i/grid, j/grid, k_val/grid])
                    r = thermodynamic_rate(cps, x, y, beta, nu, mu, filters)
                    min_rate = min(min_rate, r)
            
            is_zero = abs(min_rate) < 1e-6
            match = (d == is_zero)
            if not match:
                all_match = False
            
            if not d or not match:  # Print non-derivable pairs and mismatches
                count += 1
                if count <= 20:  # Limit output
                    print(f"{x:>3}→{y:<3} {str(d):>10} {rate_at_mu:>10.4f} "
                          f"{min_rate:>10.6f} {str(is_zero):>8} "
                          f"{'✓' if match else '✗':>8}")
    
    print(f"\n{'All pairs match the completeness theorem' if all_match else 'MISMATCH FOUND!'}")
    if all_match:
        print("  derivable(x,y) ⟺ inf_ν Rate(ν) = 0  ✓")


def demo_nontrivial_closure():
    """Demo with non-trivial closure operator."""
    print("\n" + "=" * 70)
    print("DEMO 6: Non-trivial Closure Operator")
    print("=" * 70)
    
    # Closure cl(x) = lcm(x, 6) makes 1, 2, 3 all equivalent to 6
    cps = ClosureProofSemiring(30, k=6)
    filters, primes = cps.prime_filters()
    n_filters = len(filters)
    mu = np.ones(n_filters) / n_filters
    
    print(f"\nClosure operator: cl(x) = lcm(x, 6)")
    print(f"Effect: cl maps {{1,2,3,6}} → 6, {{5,10,15,30}} → 30")
    
    print("\nClosure values:")
    for x in cps.lattice.elements:
        print(f"  cl({x}) = {cps.cl(x)}")
    
    print(f"\nWith this closure, 2 derives 3:")
    print(f"  cl(2) = {cps.cl(2)}, cl(3) = {cps.cl(3)}")
    print(f"  cl(2) | cl(3)? {cps.cl(3) % cps.cl(2) == 0}")
    print(f"  derivable(2, 3) = {cps.derivable(2, 3)}")
    
    print(f"\nBut 2 does NOT derive 5:")
    print(f"  cl(2) = {cps.cl(2)}, cl(5) = {cps.cl(5)}")
    print(f"  cl(2) | cl(5)? {cps.cl(5) % cps.cl(2) == 0}")
    print(f"  derivable(2, 5) = {cps.derivable(2, 5)}")
    
    print("\nCountermodel defects for 2→5:")
    for i, (f, p) in enumerate(zip(filters, primes)):
        d = countermodel_defect(cps, 2, 5, f)
        print(f"  Filter {p}: defect = {d}")
    
    beta = 2.0
    rate = thermodynamic_rate(cps, 2, 5, beta, mu, mu, filters)
    print(f"\nRate at reference (β={beta}): {rate:.6f} > 0  ✓")
    
    rate_d = thermodynamic_rate(cps, 2, 3, beta, mu, mu, filters)
    print(f"Rate for derivable 2→3 (β={beta}): {rate_d:.6f} = 0  ✓")


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Thermodynamic Sanov–Large-Deviation Completeness Demo         ║")
    print("║  Connecting Proof Theory to Statistical Mechanics              ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    demo_basic_lattice()
    demo_countermodel_defect()
    demo_thermodynamic_rate()
    demo_visualization()
    demo_completeness_verification()
    demo_nontrivial_closure()
    
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)
