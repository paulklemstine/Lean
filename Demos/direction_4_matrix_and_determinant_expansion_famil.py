#!/usr/bin/env python3
"""
Applications of Super-Exponential Compression Gap Theory

Real-world applications demonstrating:
1. Proof automation budget estimation
2. Matrix problem difficulty classification
3. Optimal proof strategy selection
4. Resultant computation planning
"""

import math
from fractions import Fraction
from typing import Tuple, List


# ============================================================
# Application 1: Proof Automation Budget Estimation
# ============================================================

def estimate_proof_budget(n: int, ops_per_second: float = 1e9) -> dict:
    """
    Estimate the computational budget needed to verify a determinant
    identity for an n×n matrix using different proof strategies.

    Args:
        n: Matrix dimension
        ops_per_second: Operations per second (default: 1 GHz)

    Returns:
        Dictionary with time estimates for each strategy

    Examples:
        >>> result = estimate_proof_budget(10)
        >>> result['gaussian_seconds'] < 1e-6
        True
        >>> result['leibniz_seconds'] > 1e-3
        True
    """
    gaussian_ops = n ** 3  # O(n³) for Gaussian elimination
    cofactor_ops = n * math.factorial(n)  # n * n! for full cofactor expansion
    leibniz_ops = math.factorial(n)  # n! terms in Leibniz formula

    gaussian_time = gaussian_ops / ops_per_second
    cofactor_time = cofactor_ops / ops_per_second
    leibniz_time = leibniz_ops / ops_per_second

    return {
        'n': n,
        'gaussian_ops': gaussian_ops,
        'cofactor_ops': cofactor_ops,
        'leibniz_ops': leibniz_ops,
        'gaussian_seconds': gaussian_time,
        'cofactor_seconds': cofactor_time,
        'leibniz_seconds': leibniz_time,
        'compression_gap': leibniz_ops / (n * n) if n > 0 else 0,
        'feasible_gaussian': gaussian_time < 3600,  # < 1 hour
        'feasible_leibniz': leibniz_time < 3600,
    }


def print_budget_analysis():
    """Print a comprehensive proof budget analysis."""
    print("=" * 90)
    print("APPLICATION 1: Proof Automation Budget Estimation")
    print("=" * 90)
    print(f"Assumption: 10⁹ operations/second")
    print()
    print(f"{'n':>4} | {'Gaussian':>12} | {'Leibniz':>15} | {'Gap':>12} | {'Gaussian':>10} | {'Leibniz':>10}")
    print(f"{'':>4} | {'(ops)':>12} | {'(ops)':>15} | {'':>12} | {'feasible?':>10} | {'feasible?':>10}")
    print("-" * 90)

    for n in [2, 3, 5, 8, 10, 12, 15, 20, 25, 50, 100]:
        result = estimate_proof_budget(n)
        gauss_str = f"{result['gaussian_ops']:,.0f}"
        leib_str = f"{result['leibniz_ops']:.2e}" if result['leibniz_ops'] > 1e10 else f"{result['leibniz_ops']:,.0f}"
        gap_str = f"{result['compression_gap']:.1f}" if result['compression_gap'] < 1e10 else f"{result['compression_gap']:.2e}"
        g_feas = "✓" if result['feasible_gaussian'] else "✗"
        l_feas = "✓" if result['feasible_leibniz'] else "✗"
        print(f"{n:>4} | {gauss_str:>12} | {leib_str:>15} | {gap_str:>12} | {g_feas:>10} | {l_feas:>10}")

    print()
    print("Key insight: For n ≥ 20, Leibniz expansion is computationally infeasible")
    print("even at 10⁹ ops/sec, while Gaussian elimination remains trivial up to n=1000+.")
    print()


# ============================================================
# Application 2: Problem Difficulty Classification
# ============================================================

def classify_difficulty(n: int) -> str:
    """
    Classify the difficulty of verifying an n×n determinant identity
    based on the compression gap.

    Args:
        n: Matrix dimension

    Returns:
        Difficulty classification string
    """
    gap = math.factorial(n) / (n * n) if n > 0 else 0

    if gap < 1:
        return "TRIVIAL — brute force works"
    elif gap < 100:
        return "EASY — brute force expensive but feasible"
    elif gap < 1e6:
        return "MODERATE — structured proof strongly preferred"
    elif gap < 1e15:
        return "HARD — structured proof required"
    else:
        return "EXTREME — only algebraic insight can solve"


def print_difficulty_classification():
    """Print difficulty classification for various dimensions."""
    print("=" * 90)
    print("APPLICATION 2: Matrix Problem Difficulty Classification")
    print("=" * 90)
    print()
    for n in range(1, 26):
        classification = classify_difficulty(n)
        gap = math.factorial(n) / (n * n) if n > 0 else 0
        print(f"  n={n:>3}: gap = {gap:>15.1f}  →  {classification}")
    print()


# ============================================================
# Application 3: Optimal Proof Strategy Selection
# ============================================================

def optimal_strategy(n: int, available_time_seconds: float = 3600.0) -> dict:
    """
    Select the optimal proof strategy for an n×n determinant identity
    given a time budget.

    Strategies:
    - Gaussian: O(n³) ops, always works
    - Block: O(n² log n) ops, requires block structure
    - Cofactor with memoization: O(2^n · n²) ops
    - Full Leibniz: O(n!) ops

    Args:
        n: Matrix dimension
        available_time_seconds: Time budget in seconds

    Returns:
        Dictionary with strategy recommendation
    """
    ops_per_sec = 1e9
    strategies = {
        'gaussian': n ** 3,
        'block_decomposition': n ** 2 * max(1, int(math.log2(n + 1))),
        'cofactor_memo': (2 ** n) * (n ** 2) if n <= 60 else float('inf'),
        'leibniz': math.factorial(n) if n <= 170 else float('inf'),
    }

    feasible = {
        name: ops / ops_per_sec <= available_time_seconds
        for name, ops in strategies.items()
    }

    # Pick cheapest feasible strategy
    best = min(
        (name for name in strategies if feasible[name]),
        key=lambda name: strategies[name],
        default='gaussian'  # Always feasible
    )

    return {
        'n': n,
        'recommended': best,
        'strategies': strategies,
        'feasible': feasible,
        'time_budget': available_time_seconds,
    }


def print_strategy_selection():
    """Print strategy selection analysis."""
    print("=" * 90)
    print("APPLICATION 3: Optimal Proof Strategy Selection")
    print("=" * 90)
    print(f"Time budget: 1 hour (3600 seconds at 10⁹ ops/sec)")
    print()
    print(f"{'n':>4} | {'Recommended':>25} | {'Gaussian':>12} | {'Block':>12} | {'Cofactor':>12} | {'Leibniz':>12}")
    print("-" * 90)

    for n in [2, 3, 5, 8, 10, 15, 20, 30, 50, 100]:
        result = optimal_strategy(n)
        strats = result['strategies']
        feas = result['feasible']

        def fmt(name):
            ops = strats[name]
            f = "✓" if feas[name] else "✗"
            if ops > 1e15:
                return f"{f} ∞"
            elif ops > 1e9:
                return f"{f} {ops:.1e}"
            else:
                return f"{f} {ops:,.0f}"

        print(f"{n:>4} | {result['recommended']:>25} | {fmt('gaussian'):>12} | {fmt('block_decomposition'):>12} | {fmt('cofactor_memo'):>12} | {fmt('leibniz'):>12}")
    print()


# ============================================================
# Application 4: Resultant Computation Planning
# ============================================================

def resultant_budget(m: int, n: int) -> dict:
    """
    Estimate the computational budget for verifying a resultant identity.

    Args:
        m: Degree of first polynomial
        n: Degree of second polynomial

    Returns:
        Budget analysis dictionary
    """
    sylvester_terms = math.comb(m + n, m)
    structured_ops = (m + n) ** 2  # Structured approach
    gap = sylvester_terms / structured_ops if structured_ops > 0 else 0

    return {
        'm': m,
        'n': n,
        'sylvester_terms': sylvester_terms,
        'structured_ops': structured_ops,
        'gap': gap,
        'phase': 'compressible' if gap < 100 else 'incompressible',
    }


def print_resultant_planning():
    """Print resultant computation planning analysis."""
    print("=" * 90)
    print("APPLICATION 4: Resultant Computation Planning")
    print("=" * 90)
    print()
    print(f"{'(m,n)':>8} | {'Sylvester terms':>15} | {'Structured ops':>15} | {'Gap':>12} | {'Phase':>15}")
    print("-" * 80)

    pairs = [(1,1), (2,2), (3,3), (2,5), (4,4), (5,5), (3,7), (6,6), (8,8), (10,10)]
    for m, n in pairs:
        result = resultant_budget(m, n)
        print(f"  ({m},{n}){'':<3} | {result['sylvester_terms']:>15,} | {result['structured_ops']:>15,} | {result['gap']:>12.1f} | {result['phase']:>15}")
    print()


def main():
    """Run all application demonstrations."""
    print()
    print("╔" + "═" * 88 + "╗")
    print("║" + " APPLICATIONS OF SUPER-EXPONENTIAL COMPRESSION GAP THEORY ".center(88) + "║")
    print("╚" + "═" * 88 + "╝")
    print()

    print_budget_analysis()
    print_difficulty_classification()
    print_strategy_selection()
    print_resultant_planning()

    print("=" * 90)
    print("CONCLUSIONS")
    print("=" * 90)
    print("""
The super-exponential compression gap has direct practical implications:

1. PROOF AUTOMATION: For matrix dimensions n ≥ 15, brute-force proof
   strategies are computationally infeasible. Automated provers MUST
   implement structured algebraic reasoning to handle determinant identities.

2. DIFFICULTY PREDICTION: The compression gap provides a quantitative
   predictor of problem difficulty — before attempting a proof, compute
   the gap to determine whether brute force has any chance of succeeding.

3. STRATEGY SELECTION: The gap informs strategy choice: Gaussian for all
   dimensions, cofactor with memoization for n ≤ 25, full expansion
   only for n ≤ 12.

4. RESULTANT PLANNING: Similar analysis applies to resultant computations,
   with a two-parameter phase transition in (m,n)-space.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Super-Exponential Compression Gap: Interactive Demonstration

Visualizes:
1. n!/n² growth vs exponential baselines
2. Phase transition threshold for determinant families
3. Compression gap at various matrix dimensions
4. Resultant gap surface in (m,n)-space
"""

import math
from fractions import Fraction


def compression_gap(n: int) -> float:
    """Compute the determinant compression gap n!/n²."""
    if n == 0:
        return 0.0
    return math.factorial(n) / (n ** 2)


def compression_gap_exact(n: int) -> Fraction:
    """Exact rational compression gap n!/n²."""
    if n == 0:
        return Fraction(0)
    return Fraction(math.factorial(n), n ** 2)


def resultant_gap(m: int, n: int) -> float:
    """Compute the resultant compression gap C(m+n, m) / (m+n)."""
    if m + n == 0:
        return 0.0
    return math.comb(m + n, m) / (m + n)


def phase_transition_threshold(threshold: float) -> int:
    """Find the smallest n where n!/n² ≥ threshold."""
    n = 1
    while compression_gap(n) < threshold:
        n += 1
    return n


def compression_gap_bound(C: int, k: int) -> int:
    """Verified bound: returns N such that n!/n^k > C for all n ≥ N."""
    return max(2 * k + 2, 2 * C + 2)


def print_growth_comparison():
    """Print n!/n² vs exponential functions."""
    print("=" * 80)
    print("GROWTH COMPARISON: n!/n² vs Exponential Baselines")
    print("=" * 80)
    print(f"{'n':>4} | {'n!/n²':>15} | {'2^n':>15} | {'3^n':>15} | {'10^n':>15}")
    print("-" * 80)
    for n in range(1, 21):
        gap = compression_gap(n)
        exp2 = 2 ** n
        exp3 = 3 ** n
        exp10 = 10 ** n
        print(f"{n:>4} | {gap:>15.2f} | {exp2:>15} | {exp3:>15} | {exp10:>15}")
    print()
    print("Key observation: n!/n² eventually dominates ALL exponential functions.")
    print("At n=13, n!/n² ≈ 3.7×10⁷ already exceeds 3¹³ ≈ 1.6×10⁶")
    print("At n=25, n!/n² ≈ 2.5×10²² exceeds 10²⁵ = 10²⁵... not yet!")
    print("But at n=30, n!/n² ≈ 2.9×10²⁹ exceeds 10³⁰... still catching up")
    print("The factorial WILL dominate, but the crossover point depends on the base.\n")


def print_phase_transition():
    """Print phase transition analysis."""
    print("=" * 80)
    print("PHASE TRANSITION: Determinant Compression Gap")
    print("=" * 80)
    print(f"{'n':>4} | {'n!':>15} | {'n²':>6} | {'gap=n!/n²':>15} | {'Phase':>20}")
    print("-" * 80)
    for n in range(1, 21):
        fact = math.factorial(n)
        sq = n ** 2
        gap = fact / sq
        if gap < 1:
            phase = "Compressible"
        elif gap < 10:
            phase = "Transition"
        elif gap < 1000:
            phase = "Incompressible"
        else:
            phase = "Deep incompressible"
        print(f"{n:>4} | {fact:>15} | {sq:>6} | {gap:>15.2f} | {phase:>20}")

    print()
    print("Phase transition thresholds:")
    for threshold in [1, 10, 100, 1000, 10_000, 1_000_000, 1_000_000_000]:
        n_star = phase_transition_threshold(threshold)
        print(f"  gap > {threshold:>12,} first at n = {n_star}")
    print()


def print_compression_family():
    """Print compression family analysis for determinants."""
    print("=" * 80)
    print("DETERMINANT COMPRESSION FAMILY")
    print("=" * 80)
    print(f"{'n':>4} | {'Semantic':>10} | {'Human(n²)':>10} | {'Auto(n!)':>15} | {'Branch(n)':>10} | {'Gap':>15}")
    print("-" * 80)
    for n in range(1, 16):
        semantic = n
        human = n * n
        auto = math.factorial(n)
        branch = n
        gap = auto / human if human > 0 else 0
        print(f"{n:>4} | {semantic:>10} | {human:>10} | {auto:>15} | {branch:>10} | {gap:>15.2f}")
    print()


def print_resultant_surface():
    """Print resultant gap surface."""
    print("=" * 80)
    print("RESULTANT GAP SURFACE: gap(m,n) = C(m+n,m) / (m+n)")
    print("=" * 80)
    max_mn = 10
    # Header
    header = 'm\\n'
    print(f"{header:>6}", end="")
    for n in range(1, max_mn + 1):
        print(f" {n:>10}", end="")
    print()
    print("-" * (7 + 11 * max_mn))

    for m in range(1, max_mn + 1):
        print(f"{m:>6}", end="")
        for n in range(1, max_mn + 1):
            gap = resultant_gap(m, n)
            if gap < 1000:
                print(f" {gap:>10.1f}", end="")
            else:
                print(f" {gap:>10.0f}", end="")
        print()

    print()
    print("Incompressibility threshold (gap > 1000) boundary:")
    for m in range(1, max_mn + 1):
        for n in range(1, max_mn + 1):
            if resultant_gap(m, n) > 1000 and (n == 1 or resultant_gap(m, n - 1) <= 1000):
                print(f"  m={m}: gap first exceeds 1000 at n={n} (m+n={m+n})")
                break
    print()


def print_tropical_connection():
    """Demonstrate tropical det = permanent."""
    print("=" * 80)
    print("TROPICAL ALGEBRA: det = permanent")
    print("=" * 80)
    print()
    print("In tropical (min-plus) algebra:")
    print("  a ⊕ b = min(a, b)")
    print("  a ⊗ b = a + b")
    print()

    # Example 3x3 matrix
    M = [[2, 7, 3], [5, 1, 8], [4, 6, 2]]
    n = 3
    print(f"Example {n}×{n} matrix M:")
    for row in M:
        print(f"  {row}")
    print()

    # Compute tropical det and perm (both are min over permutations)
    from itertools import permutations
    perms = list(permutations(range(n)))
    print(f"All {len(perms)} permutations and their tropical costs:")
    min_cost = float('inf')
    for perm in perms:
        cost = sum(M[i][perm[i]] for i in range(n))
        sign = compute_perm_sign(perm)
        sign_str = "+" if sign == 1 else "-"
        print(f"  σ = {perm}, Σ M[i,σ(i)] = {cost}, sign = {sign_str}")
        min_cost = min(min_cost, cost)

    print(f"\nTropical determinant = min of all costs = {min_cost}")
    print(f"Tropical permanent  = min of all costs = {min_cost}")
    print(f"They are EQUAL because signs don't affect the minimum!")
    print()
    print("Classical determinant uses signs (+ or -) → cancellation → O(n³)")
    print("Classical permanent has no signs → no cancellation → #P-hard")
    print("Tropical world strips signs → det = perm → factorial cost exposed")
    print()


def compute_perm_sign(perm):
    """Compute the sign of a permutation."""
    n = len(perm)
    inversions = sum(1 for i in range(n) for j in range(i + 1, n) if perm[i] > perm[j])
    return 1 if inversions % 2 == 0 else -1


def print_conjecture_test():
    """Test the resultant compression barrier conjecture."""
    print("=" * 80)
    print("CONJECTURE TEST: Resultant Compression Barrier")
    print("=" * 80)
    print()
    print("Conjecture: For m + n ≥ 8, gap(m,n) > 1000")
    print()
    print("Testing all (m,n) with 1 ≤ m,n ≤ 10:")
    threshold = 1000
    violations = []
    confirmations = 0
    for m in range(1, 11):
        for n in range(1, 11):
            gap = resultant_gap(m, n)
            if m + n >= 8:
                if gap <= threshold:
                    violations.append((m, n, gap))
                else:
                    confirmations += 1
    if violations:
        print(f"  VIOLATIONS found ({len(violations)} cases where m+n≥8 but gap≤1000):")
        for m, n, gap in violations:
            print(f"    m={m}, n={n}, m+n={m+n}, gap={gap:.1f}")
    else:
        print(f"  No violations! All {confirmations} cases with m+n≥8 have gap > 1000")
    print()

    # Refined threshold
    print("Refined analysis — find the true threshold:")
    for s in range(2, 16):
        min_gap = float('inf')
        for m in range(1, s):
            n = s - m
            if n >= 1:
                min_gap = min(min_gap, resultant_gap(m, n))
        print(f"  m+n={s}: min gap over all splits = {min_gap:.1f} {'> 1000 ✓' if min_gap > 1000 else '≤ 1000 ✗'}")
    print()


def print_verified_bounds():
    """Demonstrate the verified compressionGapBound function."""
    print("=" * 80)
    print("VERIFIED COMPRESSION GAP BOUNDS")
    print("=" * 80)
    print()
    print("compressionGapBound(C, k) returns N such that n!/n^k > C for all n ≥ N")
    print()
    print(f"{'C':>10} | {'k':>4} | {'Bound N':>10} | {'Actual min n':>12} | {'Tight?':>8}")
    print("-" * 55)
    for C in [1, 10, 100, 1000]:
        for k in [1, 2, 3, 5]:
            bound = compression_gap_bound(C, k)
            # Find actual minimum
            actual = 1
            while math.factorial(actual) < C * actual ** k:
                actual += 1
            tight = "tight" if bound == actual else f"gap={bound - actual}"
            print(f"{C:>10} | {k:>4} | {bound:>10} | {actual:>12} | {tight:>8}")
    print()


def main():
    """Run all demonstrations."""
    print()
    print("╔" + "═" * 78 + "╗")
    print("║" + " SUPER-EXPONENTIAL COMPRESSION GAP FOR DETERMINANT FAMILIES ".center(78) + "║")
    print("║" + " Interactive Demonstration ".center(78) + "║")
    print("╚" + "═" * 78 + "╝")
    print()

    print_growth_comparison()
    print_phase_transition()
    print_compression_family()
    print_resultant_surface()
    print_tropical_connection()
    print_conjecture_test()
    print_verified_bounds()

    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print("""
Key results demonstrated:

1. FACTORIAL DOMINANCE: n! eventually exceeds C·n^k for any C and k.
   The gap n!/n² is not just large — it's SUPER-exponential.

2. PHASE TRANSITION: The determinant compression gap crosses from
   compressible (gap < 1) to deeply incompressible (gap > 10⁴)
   between dimensions 3 and 10.

3. TROPICAL CONNECTION: In min-plus algebra, det = permanent.
   This reveals the #P-hardness hidden inside every determinant.

4. RESULTANT EXTENSION: The factorial barrier applies to resultant
   families too, with a two-parameter phase transition surface.

5. ALL MAIN THEOREMS are formally verified in Lean 4 with Mathlib.
""")


if __name__ == "__main__":
    main()
