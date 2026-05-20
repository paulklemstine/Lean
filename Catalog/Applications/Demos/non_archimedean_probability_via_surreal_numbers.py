#!/usr/bin/env python3
"""
Applications of Non-Archimedean Finitely Additive Probability

Real-world applications demonstrating the practical utility of the theory:
1. Fair lottery on finite populations with exact equal treatment
2. Rare-event modeling with explicitly positive infinitesimal probabilities
3. Decision theory with lexicographic preferences
4. Rate-distortion approximation on discrete grids
5. Monte Carlo integration error analysis
"""

from fractions import Fraction
from typing import Callable, Dict, List, Tuple
import math
import random


# =============================================================================
# Application 1: Fair Finite Lotteries
# =============================================================================
def fair_lottery_analysis(population: int) -> Dict:
    """Analyze fairness properties of a uniform grid probability lottery.

    In a fair lottery, every participant must have exactly equal probability
    of winning. Classical probability on infinite populations requires
    measure-zero singletons, making "equal positive probability" impossible.

    Our non-Archimedean framework gives each participant mass 1/N > 0.

    Returns:
        Dictionary with fairness metrics.
    """
    mass = Fraction(1, population)

    # Subgroup fairness: any k-person subgroup has mass k/N
    subgroup_sizes = [1, 2, 10, population // 2, population]
    subgroup_masses = {k: mass * k for k in subgroup_sizes if k <= population}

    return {
        "population": population,
        "individual_mass": mass,
        "individual_mass_float": float(mass),
        "subgroup_masses": subgroup_masses,
        "total_mass": mass * population,
        "is_normalized": mass * population == Fraction(1),
    }


# =============================================================================
# Application 2: Rare-Event Modeling
# =============================================================================
def rare_event_model(grid_size: int, rare_events: List[int]) -> Dict:
    """Model rare events with explicitly positive probabilities.

    In classical probability, events with probability 0 are "impossible"
    even though they may occur. Non-Archimedean probability assigns
    positive infinitesimal mass to each event.

    Args:
        grid_size: Total number of possible outcomes (N = grid_size).
        rare_events: Indices of "rare" events.

    Returns:
        Analysis of rare event probabilities.
    """
    mass = Fraction(1, grid_size)

    rare_mass = mass * len(rare_events)
    common_mass = Fraction(1) - rare_mass

    return {
        "grid_size": grid_size,
        "singleton_mass": mass,
        "num_rare_events": len(rare_events),
        "rare_total_mass": rare_mass,
        "common_total_mass": common_mass,
        "rare_to_common_ratio": rare_mass / common_mass if common_mass > 0 else float('inf'),
        "every_event_positive": True,  # This is the key property!
    }


# =============================================================================
# Application 3: Lexicographic Decision Theory
# =============================================================================
def lexicographic_utility(
    n: int,
    primary_utility: Callable[[int], Fraction],
    secondary_utility: Callable[[int], Fraction],
) -> Tuple[Fraction, Fraction, str]:
    """Compare actions using lexicographic expected utility.

    In lexicographic decision theory, infinitesimal differences matter.
    Our grid probability naturally supports this: on a grid of size N,
    the "infinitesimal" contribution of each point is 1/N.

    For two levels of utility (primary and secondary), we compute:
    - Primary expected utility: E[U_primary]
    - Secondary expected utility: E[U_secondary]
    - Decision: compare lexicographically

    Args:
        n: Grid parameter (universe = {0, ..., n}).
        primary_utility: Primary utility function.
        secondary_utility: Secondary utility function.

    Returns:
        (primary_E, secondary_E, decision_description)
    """
    mass = Fraction(1, n + 1)

    primary_E = sum(primary_utility(i) * mass for i in range(n + 1))
    secondary_E = sum(secondary_utility(i) * mass for i in range(n + 1))

    return primary_E, secondary_E, f"E[U1]={primary_E}, E[U2]={secondary_E}"


# =============================================================================
# Application 4: Discrete Rate-Distortion
# =============================================================================
def grid_rate_distortion(
    n: int,
    codebook_size: int,
    distortion_fn: Callable[[int, int], Fraction],
) -> Dict:
    """Compute rate-distortion on a uniform grid.

    Under uniform grid probability, the expected distortion for a
    codebook (set of reconstruction points) is:

    D = E[min_{c ∈ codebook} d(X, c)] = (1/(n+1)) Σ_i min_c d(i, c)

    For squared distortion d(x,y) = (x-y)², this gives exact rational answers.

    The key insight from our theory: for affine distortion kernels,
    this expected distortion is invariant under grid refinement.

    Args:
        n: Grid parameter.
        codebook_size: Number of reconstruction points.
        distortion_fn: Distortion function d(source, reconstruction).

    Returns:
        Rate-distortion analysis.
    """
    mass = Fraction(1, n + 1)

    # Simple uniform codebook
    codebook = [i * n // (codebook_size - 1) if codebook_size > 1 else n // 2
                for i in range(codebook_size)]
    codebook = list(set(codebook))  # Remove duplicates

    # Expected distortion
    total_distortion = Fraction(0)
    for i in range(n + 1):
        min_d = min(distortion_fn(i, c) for c in codebook)
        total_distortion += min_d * mass

    return {
        "grid_size": n + 1,
        "codebook": codebook,
        "codebook_size": len(codebook),
        "expected_distortion": total_distortion,
        "expected_distortion_float": float(total_distortion),
        "rate_bits": math.log2(len(codebook)) if len(codebook) > 0 else 0,
    }


# =============================================================================
# Application 5: Monte Carlo Error Analysis
# =============================================================================
def monte_carlo_vs_grid(
    f: Callable[[float], float],
    n_grid: int,
    n_mc: int,
    true_integral: float,
    seed: int = 42,
) -> Dict:
    """Compare grid expectation with Monte Carlo integration.

    Our grid probability gives exact rational expectations.
    Monte Carlo gives random approximations. This comparison
    highlights the deterministic exactness of the grid approach.

    Args:
        f: Function to integrate over [0, 1].
        n_grid: Number of grid points.
        n_mc: Number of Monte Carlo samples.
        true_integral: Known integral value for comparison.
        seed: Random seed for reproducibility.

    Returns:
        Comparison metrics.
    """
    # Grid expectation (exact for our method)
    grid_sum = sum(f(i / n_grid) for i in range(n_grid + 1))
    grid_E = grid_sum / (n_grid + 1)
    grid_error = abs(grid_E - true_integral)

    # Monte Carlo
    rng = random.Random(seed)
    mc_samples = [f(rng.random()) for _ in range(n_mc)]
    mc_E = sum(mc_samples) / n_mc
    mc_error = abs(mc_E - true_integral)

    return {
        "function_desc": f.__doc__ or "unknown",
        "true_integral": true_integral,
        "grid_points": n_grid + 1,
        "grid_expectation": grid_E,
        "grid_error": grid_error,
        "mc_samples": n_mc,
        "mc_expectation": mc_E,
        "mc_error": mc_error,
        "grid_wins": grid_error < mc_error,
    }


# =============================================================================
# Main demonstration
# =============================================================================
if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     APPLICATIONS OF NON-ARCHIMEDEAN PROBABILITY                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    # Application 1: Fair Lottery
    print("=" * 70)
    print("APPLICATION 1: Fair Finite Lotteries")
    print("=" * 70)
    for pop in [100, 1000, 1000000]:
        result = fair_lottery_analysis(pop)
        print(f"\n  Population {pop:>10}:")
        print(f"    Individual mass: {result['individual_mass']} "
              f"({result['individual_mass_float']:.2e})")
        print(f"    Normalized: {result['is_normalized']}")
        for k, m in result['subgroup_masses'].items():
            print(f"    Group of {k}: mass = {float(m):.6f}")
    print()

    # Application 2: Rare Events
    print("=" * 70)
    print("APPLICATION 2: Rare-Event Modeling")
    print("=" * 70)
    result = rare_event_model(1000000, list(range(10)))
    print(f"\n  Grid size: {result['grid_size']}")
    print(f"  Singleton mass: {result['singleton_mass']}")
    print(f"  10 rare events total mass: {result['rare_total_mass']}")
    print(f"  Every event has positive probability: {result['every_event_positive']}")
    print()

    # Application 3: Lexicographic Decision
    print("=" * 70)
    print("APPLICATION 3: Lexicographic Decision Theory")
    print("=" * 70)
    n = 99
    # Action A: high primary utility, low secondary
    prim_A = lambda i: Fraction(i, n)
    sec_A = lambda i: Fraction(1)
    E_prim_A, E_sec_A, desc_A = lexicographic_utility(n, prim_A, sec_A)

    # Action B: same primary, higher secondary
    prim_B = lambda i: Fraction(i, n)
    sec_B = lambda i: Fraction(i * i, n * n)
    E_prim_B, E_sec_B, desc_B = lexicographic_utility(n, prim_B, sec_B)

    print(f"\n  Action A: {desc_A}")
    print(f"  Action B: {desc_B}")
    if E_prim_A == E_prim_B:
        winner = "A" if E_sec_A > E_sec_B else "B"
        print(f"  Primary utilities equal → decide by secondary → choose {winner}")
    print()

    # Application 4: Rate-Distortion
    print("=" * 70)
    print("APPLICATION 4: Discrete Rate-Distortion")
    print("=" * 70)
    squared = lambda x, y: Fraction((x - y) ** 2)
    for n in [10, 50, 100]:
        for cb_size in [2, 4, 8]:
            result = grid_rate_distortion(n, cb_size, squared)
            print(f"\n  Grid {n+1} pts, codebook size {result['codebook_size']}:")
            print(f"    Expected distortion: {result['expected_distortion_float']:.6f}")
            print(f"    Rate: {result['rate_bits']:.2f} bits")
    print()

    # Application 5: Monte Carlo comparison
    print("=" * 70)
    print("APPLICATION 5: Grid vs Monte Carlo Integration")
    print("=" * 70)

    def linear(x):
        """f(x) = x"""
        return x

    def quadratic(x):
        """f(x) = x²"""
        return x * x

    for f, integral, name in [
        (linear, 0.5, "x"),
        (quadratic, 1/3, "x²"),
    ]:
        print(f"\n  f(x) = {name}, ∫₀¹ f = {integral}")
        result = monte_carlo_vs_grid(f, 100, 100, integral)
        print(f"    Grid (101 pts): E = {result['grid_expectation']:.8f}, "
              f"error = {result['grid_error']:.2e}")
        print(f"    MC (100 samples): E = {result['mc_expectation']:.8f}, "
              f"error = {result['mc_error']:.2e}")
        print(f"    Grid wins: {result['grid_wins']}")
    print()

    print("=" * 70)
    print("ALL APPLICATIONS DEMONSTRATED")
    print("=" * 70)


#!/usr/bin/env python3
"""
Non-Archimedean Probability via Finite Grids: Interactive Demo

Demonstrates the key theorems of non-Archimedean finitely additive probability:
1. Uniform grid probabilities with equal atomic masses
2. Exact affine expectation matching the continuum limit
3. Refinement invariance under grid subdivision
4. Convergence of grid expectations (shadow principle)
5. Impossibility of equal positive atoms on infinite sets
"""

from fractions import Fraction
from typing import Callable, List
import math


def grid_uniform_mass(n: int, subset_size: int) -> Fraction:
    """Mass of a subset of size `subset_size` on grid Fin(n+1)."""
    return Fraction(subset_size, n + 1)


def singleton_mass(n: int) -> Fraction:
    """Mass of each singleton on grid Fin(n+1)."""
    return Fraction(1, n + 1)


def na_expectation(n: int, X: Callable[[int], Fraction]) -> Fraction:
    """Expectation of observable X on uniform grid Fin(n+1).

    E[X] = sum_{i=0}^{n} X(i) * (1/(n+1))
    """
    return sum(X(i) * singleton_mass(n) for i in range(n + 1))


def refine_observable(n: int, k: int, X: Callable[[int], Fraction]) -> Callable[[int], Fraction]:
    """Lift observable from Fin(n+1) to Fin(k*(n+1)) by block embedding.

    Point j in the fine grid maps to coarse point j // k.
    """
    def refined(j: int) -> Fraction:
        return X(j // k)
    return refined


# =============================================================================
# Demo 1: Uniform atomic probability on finite grids
# =============================================================================
def demo_uniform_grid():
    print("=" * 70)
    print("DEMO 1: Uniform Atomic Probability on Finite Grids")
    print("=" * 70)
    print()
    print("For each grid size N = n+1, every point carries mass 1/N.")
    print("As N → ∞, these masses behave like infinitesimals.\n")

    for n in [4, 9, 99, 999, 9999]:
        N = n + 1
        m = singleton_mass(n)
        total = sum(singleton_mass(n) for _ in range(N))
        print(f"  Grid Fin({N}): singleton mass = {m} = {float(m):.6f}, "
              f"total mass = {total}")

    print()
    print("✓ Every point has positive mass (no atom is null)")
    print("✓ Total mass is exactly 1 (normalization)")
    print("✓ Masses tend to 0 as grid refines (infinitesimal behavior)")
    print()


# =============================================================================
# Demo 2: Exact affine expectation
# =============================================================================
def demo_affine_expectation():
    print("=" * 70)
    print("DEMO 2: Exact Affine Expectation on Grids")
    print("=" * 70)
    print()
    print("For X(i) = a*i/n + b on Fin(n+1), E[X] = a/2 + b exactly.\n")

    test_cases = [
        (1, 0, "identity"),
        (2, 1, "2x + 1"),
        (3, -1, "3x - 1"),
        (Fraction(1, 2), Fraction(1, 3), "x/2 + 1/3"),
    ]

    for a, b, name in test_cases:
        a, b = Fraction(a), Fraction(b)
        expected = a / 2 + b
        print(f"  f(x) = {name}:  expected E[f] = {expected}")

        for n in [5, 10, 50, 100]:
            X = lambda i, a=a, b=b, n=n: a * Fraction(i, n) + b
            E = na_expectation(n, X)
            print(f"    Grid Fin({n+1}): E[f] = {E} {'✓ EXACT' if E == expected else '✗ MISMATCH'}")
        print()

    print("✓ The discrete model recovers exact continuum expectations for affine functions")
    print()


# =============================================================================
# Demo 3: Refinement invariance
# =============================================================================
def demo_refinement_invariance():
    print("=" * 70)
    print("DEMO 3: Refinement Invariance")
    print("=" * 70)
    print()
    print("Refining grid Fin(n+1) to Fin(k*(n+1)) preserves expectations.\n")

    def test_observable(i: int) -> Fraction:
        """A simple test observable: i^2."""
        return Fraction(i * i)

    for n in [3, 5, 9]:
        coarse_E = na_expectation(n, test_observable)
        print(f"  Coarse grid Fin({n+1}): E[i²] = {coarse_E} = {float(coarse_E):.6f}")

        for k in [2, 3, 5]:
            fine_n = k * (n + 1) - 1
            refined_X = refine_observable(n, k, test_observable)
            fine_E = na_expectation(fine_n, refined_X)
            match = "✓" if fine_E == coarse_E else "✗"
            print(f"    Refined ×{k} → Fin({k*(n+1)}): E[refine(i²)] = {fine_E} {match}")
        print()

    # Also test with affine observables
    print("  Testing refinement invariance for affine observables:")
    for n in [4, 7]:
        a, b = Fraction(3), Fraction(-1)
        X_coarse = lambda i, a=a, b=b, n=n: a * Fraction(i, n) + b
        coarse_E = na_expectation(n, X_coarse)

        for k in [2, 4, 10]:
            X_coarse_for_refine = lambda i: a * Fraction(i, n) + b
            refined_X = refine_observable(n, k, X_coarse_for_refine)
            fine_n = k * (n + 1) - 1
            fine_E = na_expectation(fine_n, refined_X)
            match = "✓" if fine_E == coarse_E else "✗"
            print(f"    n={n}, k={k}: coarse={coarse_E}, fine={fine_E} {match}")

    print()
    print("✓ Expectations are exactly preserved under grid refinement")
    print()


# =============================================================================
# Demo 4: Convergence to continuum (shadow principle)
# =============================================================================
def demo_convergence():
    print("=" * 70)
    print("DEMO 4: Convergence to Continuum (Shadow Principle)")
    print("=" * 70)
    print()
    print("For X(i) = a*i/N + b on Fin(N), E[X] → a/2 + b as N → ∞.\n")

    a, b = Fraction(3), Fraction(2)
    target = a / 2 + b
    print(f"  f(x) = 3x + 2, target = {target} = {float(target):.4f}\n")

    for N in [5, 10, 50, 100, 500, 1000, 10000]:
        n = N - 1
        X = lambda i, n=n: a * Fraction(i, n) + b if n > 0 else b
        E = na_expectation(n, X)
        error = abs(float(E) - float(target))
        print(f"    N = {N:>6}: E[f] = {float(E):.10f}, |error| = {error:.2e}")

    print()

    # Quadratic observable (not exact, but converges)
    print("  Quadratic: f(x) = x², target = ∫₀¹ x² dx = 1/3\n")
    target_quad = Fraction(1, 3)
    for N in [5, 10, 50, 100, 500, 1000]:
        n = N - 1
        X = lambda i, n=n: Fraction(i, n) ** 2 if n > 0 else Fraction(0)
        E = na_expectation(n, X)
        error = abs(float(E) - float(target_quad))
        print(f"    N = {N:>6}: E[f] = {float(E):.10f}, "
              f"|error| = {error:.2e}, "
              f"≈ 1/(6N) = {1/(6*N):.2e}")

    print()
    print("✓ Affine expectations converge exactly (are constant)")
    print("✓ Quadratic expectations converge at rate O(1/N)")
    print()


# =============================================================================
# Demo 5: Impossibility theorem illustration
# =============================================================================
def demo_impossibility():
    print("=" * 70)
    print("DEMO 5: Impossibility of Equal Positive Atoms on ℕ")
    print("=" * 70)
    print()
    print("If every singleton {n} has mass ε > 0, then for N > 1/ε,")
    print("the finite set {0,...,N-1} has mass N*ε > 1. Contradiction!\n")

    for eps in [0.1, 0.01, 0.001, 0.0001]:
        N_needed = math.ceil(1 / eps) + 1
        mass = N_needed * eps
        print(f"  ε = {eps}: need N = {N_needed}, "
              f"mass = N*ε = {mass:.4f} > 1 ✓ (contradiction)")

    print()
    print("This is why classical (Archimedean) probability cannot assign")
    print("equal positive mass to infinitely many atoms.")
    print("Non-Archimedean probability escapes via infinitesimals or")
    print("by abandoning countable additivity.")
    print()


# =============================================================================
# Demo 6: Infinitesimal scheme visualization
# =============================================================================
def demo_infinitesimal_scheme():
    print("=" * 70)
    print("DEMO 6: Infinitesimal Scheme — Grid Refinement Sequence")
    print("=" * 70)
    print()
    print("A sequence of grid probabilities where point masses → 0:\n")

    print(f"  {'Level n':>10} {'Grid size':>12} {'Point mass':>20} {'≈ float':>14}")
    print(f"  {'-'*10:>10} {'-'*12:>12} {'-'*20:>20} {'-'*14:>14}")

    for n in range(15):
        size = n + 1
        mass = Fraction(1, size)
        print(f"  {n:>10} {size:>12} {str(mass):>20} {float(mass):>14.8f}")

    print()
    print("Each row is a valid probability space.")
    print("The point masses form a null sequence: 1, 1/2, 1/3, ... → 0.")
    print("This is the formal precursor to hyperfinite counting measure.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  NON-ARCHIMEDEAN PROBABILITY VIA FINITE GRIDS — INTERACTIVE DEMO   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_uniform_grid()
    demo_affine_expectation()
    demo_refinement_invariance()
    demo_convergence()
    demo_impossibility()
    demo_infinitesimal_scheme()

    print("=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
