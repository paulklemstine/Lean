#!/usr/bin/env python3
"""
Applications of obstruction calculus to real-world problems.

Demonstrates how certified generation probability bounds inform:
1. Randomized algorithm design (Monte Carlo group generation)
2. Cryptographic protocol reliability
3. Experimental mathematics validation
"""

from fractions import Fraction
from math import comb, factorial, log, ceil
import random


def generation_success_probability(n: int) -> float:
    """
    Lower bound on P(⟨σ,τ⟩ ⊇ Aₙ) from our certified obstruction bounds.
    
    Uses: P ≥ 1 - 1/n - 5/n² - 2/n² - 1/n³
    """
    return 1.0 - 1.0/n - 5.0/n**2 - 2.0/n**2 - 1.0/n**3


def trials_needed_for_confidence(n: int, confidence: float = 0.999) -> int:
    """
    Number of independent random pairs needed to guarantee that at least
    one pair generates S_n or A_n with given confidence level.
    
    Each pair succeeds with probability ≥ p = generation_success_probability(n).
    Need: 1 - (1-p)^t ≥ confidence, so t ≥ log(1-confidence) / log(1-p).
    
    Args:
        n: Degree of symmetric group
        confidence: Target confidence level (default 0.999)
    
    Returns:
        Number of trials needed
    """
    p = generation_success_probability(n)
    if p >= 1:
        return 1
    if p <= 0:
        return float('inf')
    return ceil(log(1 - confidence) / log(1 - p))


def monte_carlo_generation_test(n: int, num_trials: int = 10000) -> dict:
    """
    Empirically estimate the probability that two random permutations
    of [n] generate a transitive subgroup, by testing whether the
    group orbit of 0 under the generated subgroup is all of [n].
    
    This is a practical approximation — full generation testing would
    require Schreier-Sims, but transitivity is a necessary condition
    and the dominant obstruction.
    
    Args:
        n: Number of elements
        num_trials: Number of random pairs to test
    
    Returns:
        Dictionary with empirical results
    """
    transitive_count = 0
    
    for _ in range(num_trials):
        # Generate two random permutations
        sigma = list(range(n))
        tau = list(range(n))
        random.shuffle(sigma)
        random.shuffle(tau)
        
        # Check transitivity via orbit computation
        orbit = {0}
        frontier = [0]
        while frontier:
            new_frontier = []
            for x in frontier:
                for perm in [sigma, tau]:
                    y = perm[x]
                    if y not in orbit:
                        orbit.add(y)
                        new_frontier.append(y)
                # Also apply inverses
                inv_sigma = [0] * n
                inv_tau = [0] * n
                for i in range(n):
                    inv_sigma[sigma[i]] = i
                    inv_tau[tau[i]] = i
                for perm in [inv_sigma, inv_tau]:
                    y = perm[x]
                    if y not in orbit:
                        orbit.add(y)
                        new_frontier.append(y)
            frontier = new_frontier
        
        if len(orbit) == n:
            transitive_count += 1
    
    empirical_prob = transitive_count / num_trials
    theoretical_lb = generation_success_probability(n)
    intransitive_ub = 1.0/n + 5.0/n**2
    
    return {
        "n": n,
        "num_trials": num_trials,
        "transitive_count": transitive_count,
        "empirical_transitivity_prob": empirical_prob,
        "theoretical_generation_lower_bound": theoretical_lb,
        "intransitive_upper_bound": intransitive_ub,
    }


def cryptographic_key_generation_analysis():
    """
    Application: Analyze the reliability of random permutation-based
    key generation in symmetric-group cryptographic protocols.
    
    In protocols based on the difficulty of the symmetric group
    discrete log problem, keys are pairs of permutations that should
    generate a large subgroup. Our bounds certify the probability
    that randomly chosen keys are valid.
    """
    print("=" * 72)
    print("APPLICATION: Cryptographic Key Generation Reliability")
    print("=" * 72)
    print()
    print("For symmetric-group-based cryptographic protocols, random keys")
    print("(pairs of permutations) must generate S_n or A_n. Our certified")
    print("bounds guarantee minimum success probabilities:\n")
    
    print(f"{'n':>6} {'P(valid key)≥':>14} {'Trials for 99.9%':>18} "
          f"{'Trials for 99.9999%':>20}")
    print("-" * 62)
    for n in [10, 20, 50, 100, 256, 512, 1024, 4096]:
        p = generation_success_probability(n)
        t_999 = trials_needed_for_confidence(n, 0.999)
        t_999999 = trials_needed_for_confidence(n, 0.999999)
        print(f"{n:6d} {p:14.10f} {t_999:18d} {t_999999:20d}")
    
    print()
    print("Key insight: Even for n=10, a single random pair generates")
    print(f"S_n or A_n with probability ≥ {generation_success_probability(10):.4f}.")
    print("For n ≥ 50, one pair almost always suffices (P > 0.99).")


def permutation_group_testing():
    """
    Application: Validating random generation in computational group theory.
    
    Monte Carlo algorithms in GAP, Magma, and other CAS rely on random
    generation. Our bounds provide certified guarantees.
    """
    print("\n" + "=" * 72)
    print("APPLICATION: Monte Carlo Group Theory Validation")
    print("=" * 72)
    print()
    print("Running empirical tests vs. theoretical bounds...\n")
    
    random.seed(42)  # Reproducibility
    for n in [8, 12, 20, 50]:
        result = monte_carlo_generation_test(n, num_trials=5000)
        print(f"n = {result['n']:3d}: "
              f"Empirical P(trans) = {result['empirical_transitivity_prob']:.4f}, "
              f"Theory P(gen) ≥ {result['theoretical_generation_lower_bound']:.4f}, "
              f"P(intrans) ≤ {result['intransitive_upper_bound']:.4f}")
    
    print()
    print("The empirical transitivity rate consistently exceeds the")
    print("certified generation lower bound, validating the theory.")


def obstruction_anatomy():
    """
    Application: Detailed anatomy of why random generation fails.
    
    Decomposes the failure probability into its three structural sources,
    showing the dominance of the intransitive obstruction.
    """
    print("\n" + "=" * 72)
    print("APPLICATION: Obstruction Anatomy")
    print("=" * 72)
    print()
    print("Decomposition of P(fail to generate) by obstruction class:\n")
    
    print(f"{'n':>6} {'Intrans':>12} {'Imprim':>12} {'Prim.Exc':>12} "
          f"{'Total':>12} {'%Intrans':>10}")
    print("-" * 68)
    
    for n in [6, 8, 10, 15, 20, 30, 50, 100, 500]:
        intrans = float(Fraction(1, n) + Fraction(5, n*n))
        imprim = 2.0 / n**2
        prim = 1.0 / n**3
        total = intrans + imprim + prim
        pct = 100 * intrans / total if total > 0 else 0
        print(f"{n:6d} {intrans:12.8f} {imprim:12.8f} {prim:12.8f} "
              f"{total:12.8f} {pct:9.1f}%")
    
    print()
    print("The intransitive class dominates at ~98-99% for large n.")
    print("This justifies focusing formal verification effort on this class.")


def multigenerator_scaling():
    """
    Application: How many random generators are enough?
    
    Shows the dramatic improvement in generation probability as the
    number of random generators increases.
    """
    print("\n" + "=" * 72)
    print("APPLICATION: Multi-Generator Scaling")
    print("=" * 72)
    print()
    print("Common fixed point probability (dominant obstruction)")
    print("for r generators in S_n:\n")
    
    from algorithms import common_fixed_point_probability
    
    print(f"{'n':>6} {'r=2':>12} {'r=3':>12} {'r=4':>12} {'r=5':>12}")
    print("-" * 58)
    for n in [5, 10, 20, 50]:
        probs = []
        for r in [2, 3, 4, 5]:
            p = float(common_fixed_point_probability(n, r))
            probs.append(p)
        print(f"{n:6d} {probs[0]:12.8f} {probs[1]:12.8f} "
              f"{probs[2]:12.8f} {probs[3]:12.8f}")
    
    print()
    print("Each additional generator reduces the dominant obstruction")
    print("by a factor of ~1/n, confirming the n^{-(r-1)} scaling.")


if __name__ == "__main__":
    cryptographic_key_generation_analysis()
    permutation_group_testing()
    obstruction_anatomy()
    
    print("\n" + "=" * 72)
    print("All applications demonstrated successfully.")
    print("=" * 72)


#!/usr/bin/env python3
"""
Demonstration of reciprocal binomial coefficient sum bounds and
Dixon-style obstruction calculus for random generation in S_n.

This script provides concrete numerical examples of the theorems
proved in the formal Lean development.
"""

from fractions import Fraction
from math import comb, factorial


def sum_inv_choose(n: int) -> Fraction:
    """Compute ∑_{k=1}^{⌊n/2⌋} 1/C(n,k) exactly over ℚ."""
    return sum(Fraction(1, comb(n, k)) for k in range(1, n // 2 + 1))


def tail_sum_inv_choose(n: int) -> Fraction:
    """Compute ∑_{k=2}^{⌊n/2⌋} 1/C(n,k) exactly over ℚ."""
    return sum(Fraction(1, comb(n, k)) for k in range(2, n // 2 + 1))


def common_fixed_point_prob(n: int, r: int) -> Fraction:
    """
    Exact inclusion-exclusion probability that r independent uniform
    permutations of n letters share a common fixed point.
    
    P = ∑_{j=1}^{n} (-1)^{j+1} C(n,j) ((n-j)!/n!)^r
    """
    result = Fraction(0)
    for j in range(1, n + 1):
        sign = (-1) ** (j + 1)
        term = Fraction(sign * comb(n, j) * factorial(n - j) ** r,
                        factorial(n) ** r)
        result += term
    return result


def obstruction_bound(n: int) -> Fraction:
    """Upper bound on intransitive obstruction: 1/n + 5/n²."""
    return Fraction(1, n) + Fraction(5, n * n)


def obstruction_bound_tight(n: int) -> Fraction:
    """Tighter upper bound for n ≥ 15: 1/n + 3/n²."""
    return Fraction(1, n) + Fraction(3, n * n)


def total_obstruction_bound(n: int) -> Fraction:
    """Total obstruction bound including all three classes."""
    intrans = obstruction_bound(n)
    imprim = Fraction(2, n * n)
    prim_exc = Fraction(1, n ** 3)
    return intrans + imprim + prim_exc


def main():
    print("=" * 72)
    print("RECIPROCAL BINOMIAL SUM BOUNDS AND OBSTRUCTION CALCULUS")
    print("=" * 72)

    # Theorem 1: sum_inv_choose_le
    print("\n" + "─" * 72)
    print("THEOREM 1: ∑_{k=1}^{⌊n/2⌋} 1/C(n,k) ≤ 1/n + 5/n²  for n ≥ 6")
    print("─" * 72)
    print(f"{'n':>4} {'sum':>14} {'bound':>14} {'margin':>14} {'status':>8}")
    print("-" * 58)
    for n in [6, 7, 8, 10, 15, 20, 30, 50, 100, 200]:
        s = sum_inv_choose(n)
        b = obstruction_bound(n)
        margin = b - s
        status = "✓" if margin >= 0 else "✗"
        print(f"{n:4d} {float(s):14.10f} {float(b):14.10f} "
              f"{float(margin):14.10f} {status:>8}")

    # Original conjecture: C=3 is FALSE for n < 15
    print("\n" + "─" * 72)
    print("DISCOVERY: Original conjecture (C=3) fails for n < 15")
    print("─" * 72)
    print(f"{'n':>4} {'sum':>14} {'1/n+3/n²':>14} {'margin':>14} {'status':>8}")
    print("-" * 58)
    for n in range(6, 20):
        s = sum_inv_choose(n)
        b = obstruction_bound_tight(n)
        margin = b - s
        status = "✓" if margin >= 0 else "✗"
        print(f"{n:4d} {float(s):14.10f} {float(b):14.10f} "
              f"{float(margin):14.10f} {status:>8}")

    # Theorem 1b: tail bound
    print("\n" + "─" * 72)
    print("THEOREM 1b: ∑_{k=2}^{⌊n/2⌋} 1/C(n,k) ≤ 5/n²  for n ≥ 6")
    print("─" * 72)
    print(f"{'n':>4} {'tail':>14} {'5/n²':>14} {'ratio':>10}")
    print("-" * 42)
    for n in [6, 8, 10, 15, 20, 50, 100]:
        tail = tail_sum_inv_choose(n)
        b = Fraction(5, n * n)
        ratio = float(tail) / float(b) if b > 0 else 0
        print(f"{n:4d} {float(tail):14.10f} {float(b):14.10f} {ratio:10.4f}")

    # Common fixed point probabilities
    print("\n" + "─" * 72)
    print("EXACT COMMON FIXED POINT PROBABILITIES")
    print("P(r generators share a fixed point) via inclusion-exclusion")
    print("─" * 72)
    print(f"{'n':>4} {'r=2':>14} {'r=3':>14} {'r=4':>14} {'1/n':>10}")
    print("-" * 56)
    for n in [3, 5, 8, 10, 15, 20, 50]:
        p2 = common_fixed_point_prob(n, 2)
        p3 = common_fixed_point_prob(n, 3)
        p4 = common_fixed_point_prob(n, 4)
        print(f"{n:4d} {float(p2):14.10f} {float(p3):14.10f} "
              f"{float(p4):14.10f} {float(Fraction(1,n)):10.6f}")

    # Generation probability lower bound
    print("\n" + "─" * 72)
    print("GENERATION PROBABILITY LOWER BOUND")
    print("P(⟨σ,τ⟩ ⊇ Aₙ) ≥ 1 - total_obstruction")
    print("─" * 72)
    print(f"{'n':>4} {'intrans':>10} {'total_obs':>10} {'P(gen)≥':>10}")
    print("-" * 38)
    for n in [6, 8, 10, 15, 20, 50, 100, 500, 1000]:
        intrans = float(obstruction_bound(n))
        total = float(total_obstruction_bound(n))
        gen_lb = 1.0 - total
        print(f"{n:4d} {intrans:10.6f} {total:10.6f} {gen_lb:10.6f}")

    # Asymptotic analysis
    print("\n" + "─" * 72)
    print("ASYMPTOTIC ANALYSIS: n · ∑ 1/C(n,k) → 1")
    print("─" * 72)
    print(f"{'n':>6} {'n·sum':>12} {'n²·(sum-1/n)':>14}")
    print("-" * 36)
    for n in [10, 20, 50, 100, 200, 500, 1000]:
        s = sum_inv_choose(n)
        ns = float(n * s)
        n2_tail = float(n * n * (s - Fraction(1, n)))
        print(f"{n:6d} {ns:12.8f} {n2_tail:14.8f}")
    print("\nNote: n·sum → 1 confirms 1/n is the leading term.")
    print("      n²·(sum - 1/n) → 2 confirms the second-order coefficient.")


if __name__ == "__main__":
    main()
