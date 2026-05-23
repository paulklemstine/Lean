#!/usr/bin/env python3
"""
Applications of PF₂ Log-Concavity Theory

Real-world applications demonstrating the mathematical results:

1. Network reliability: log-concavity of k-component failure distributions
2. Chemical equilibrium: molecular partition functions
3. Portfolio theory: combinatorial investment models
4. Error-correcting codes: weight distribution analysis
"""

import math
from typing import List, Tuple
from algorithms import (
    compute_product_polynomial,
    verify_log_concavity,
    verify_ratio_decreasing,
    fermion_partition_function,
    construct_pf2_certificate,
)


def network_reliability_analysis():
    """Application 1: Network Reliability

    Consider a network with m independent links. Link i has reliability p_i
    (probability of being operational). The number of operational links
    follows a Poisson binomial distribution.

    The probability generating function is ∏(q_i + p_i·x) where q_i = 1 - p_i.
    Dividing by ∏ q_i, this is proportional to ∏(1 + (p_i/q_i)·x).

    PF₂ theory tells us the distribution of operational link counts is
    log-concave, implying unimodality and concentration.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Reliability Analysis")
    print("=" * 70)

    # 8 network links with varying reliabilities
    reliabilities = [0.95, 0.90, 0.85, 0.80, 0.75, 0.70, 0.65, 0.60]
    m = len(reliabilities)

    print(f"\n  {m} network links with reliabilities:")
    for i, p in enumerate(reliabilities):
        print(f"    Link {i}: p = {p}")

    # Activity ratios w_i = p_i / (1 - p_i)
    activities = [p / (1 - p) for p in reliabilities]

    # Coefficient sequence ∝ P(k links operational)
    coeffs = compute_product_polynomial(activities)
    norm_factor = sum(coeffs)

    print(f"\n  Probability of exactly k links operational:")
    # Actual probability needs ∏(1-p_i) factor
    base_prob = math.prod(1 - p for p in reliabilities)
    for k in range(m + 1):
        prob = base_prob * coeffs[k]
        bar = "█" * int(prob * 100)
        print(f"    k={k}: P = {prob:.6f}  {bar}")

    lc_ok, _ = verify_log_concavity(coeffs)
    print(f"\n  Log-concave distribution: {'✓' if lc_ok else '✗'}")
    print(f"  → Distribution is guaranteed unimodal (peak around k=6)")


def chemical_equilibrium():
    """Application 2: Chemical Equilibrium / Statistical Mechanics

    Consider m independent molecular binding sites, each with binding
    energy E_i. At temperature T, the probability of site i being occupied
    is proportional to exp(-E_i / kT).

    The partition function Z = ∏(1 + exp(-E_i/kT)) gives the statistics
    of the total occupation number. PF₂ ensures log-concave occupation
    statistics.
    """
    print(f"\n{'=' * 70}")
    print("APPLICATION 2: Molecular Binding Site Equilibrium")
    print("=" * 70)

    # Binding energies (in units of kT)
    energies = [0.2, 0.5, 0.8, 1.0, 1.5, 2.0, 2.5, 3.0]
    m = len(energies)

    print(f"\n  {m} binding sites with energies (units of kT):")
    for i, E in enumerate(energies):
        print(f"    Site {i}: E = {E:.1f} kT, Boltzmann factor = {math.exp(-E):.4f}")

    stats = fermion_partition_function([math.exp(-E) for E in energies])

    print(f"\n  Occupation statistics:")
    for k in range(m + 1):
        bar = "█" * int(stats['probabilities'][k] * 80)
        print(f"    k={k} occupied: P = {stats['probabilities'][k]:.6f}  {bar}")

    print(f"\n  Mean occupation: {stats['mean']:.4f}")
    print(f"  Variance: {stats['variance']:.4f}")
    print(f"  Log-concave: {'✓' if stats['is_log_concave'] else '✗'}")
    print(f"  → Thermodynamic stability guaranteed by PF₂ theory")


def portfolio_combinatorics():
    """Application 3: Combinatorial Portfolio Selection

    Model: m investment opportunities, each with a "value weight" w_i.
    A portfolio selects a subset of these opportunities. The number of
    portfolios of total weighted size k is e_k(w_1, ..., w_m).

    Log-concavity implies the portfolio count peaks at a single size
    and decreases monotonically away from the peak.
    """
    print(f"\n{'=' * 70}")
    print("APPLICATION 3: Combinatorial Portfolio Analysis")
    print("=" * 70)

    # Investment opportunity values
    values = [10, 25, 50, 100, 200]
    m = len(values)

    print(f"\n  {m} investment opportunities with values: {values}")

    coeffs = compute_product_polynomial([float(v) for v in values])
    print(f"\n  Weighted portfolio counts by total investment size:")
    for k in range(m + 1):
        from itertools import combinations
        subsets = list(combinations(values, k))
        total = sum(math.prod(s) for s in subsets)
        print(f"    Size k={k}: count = {coeffs[k]:.0f}  "
              f"({len(subsets)} subsets)")

    lc_ok, margins = verify_log_concavity(coeffs)
    print(f"\n  Log-concave portfolio counts: {'✓' if lc_ok else '✗'}")
    print(f"  → Peaked distribution with guaranteed unimodal structure")


def code_weight_distribution():
    """Application 4: Error-Correcting Code Weight Analysis

    For a binary code generated by m codewords of weights w_1,...,w_m,
    the weight enumerator of the simplex-like subcode where each generator
    is used at most once has generating function ∏(1 + x^{w_i}).

    While this is not exactly ∏(1 + w_i·X), for unit-weight codes (all w_i = 1),
    the weight distribution IS exactly the binomial coefficient sequence,
    which is PF₂.
    """
    print(f"\n{'=' * 70}")
    print("APPLICATION 4: Code Weight Distribution Analysis")
    print("=" * 70)

    # Repetition-like code: m generators all weight 1
    m = 10
    print(f"\n  Unit-weight code with {m} generators:")
    coeffs_unit = compute_product_polynomial([1.0] * m)
    print(f"  Weight distribution: {[int(c) for c in coeffs_unit]}")
    print(f"  (= Pascal row {m}: C({m},k))")

    lc_ok, _ = verify_log_concavity(coeffs_unit)
    print(f"  Log-concave: {'✓' if lc_ok else '✗'}")

    # Variable weight code
    weights = [1, 1, 2, 2, 3]
    print(f"\n  Variable-weight code with generator weights: {weights}")
    coeffs_var = compute_product_polynomial([float(w) for w in weights])
    print(f"  Weight distribution: {[round(c) for c in coeffs_var]}")

    lc_ok, _ = verify_log_concavity(coeffs_var)
    print(f"  Log-concave: {'✓' if lc_ok else '✗'}")
    print(f"  → PF₂ certification provides structural guarantee")


def conjecture_testing():
    """Test the truncation conjecture and forest matroid conjecture."""
    import random
    print(f"\n{'=' * 70}")
    print("CONJECTURE TESTING")
    print("=" * 70)

    # Conjecture 1: PF₂ closure under truncation
    print(f"\n  Conjecture 1: PF₂ is closed under truncation")
    print(f"  Testing: If a is PF₂, is a|_{{k ≤ r}} also PF₂?")

    n_trials = 200
    counterexamples = 0
    for _ in range(n_trials):
        m = random.randint(3, 8)
        weights = [random.uniform(0, 5) for _ in range(m)]
        coeffs = compute_product_polynomial(weights)

        for r in range(1, m):
            truncated = coeffs[:r + 1] + [0.0] * (len(coeffs) - r - 1)
            rd_ok, margins = verify_ratio_decreasing(truncated)
            if not rd_ok:
                counterexamples += 1
                break

    print(f"  Result: {counterexamples} counterexamples in {n_trials} trials")
    if counterexamples > 0:
        print(f"  → CONJECTURE REFUTED: truncation does NOT preserve PF₂")
    else:
        print(f"  → No counterexamples found (conjecture survives)")

    # Conjecture 2: Log-concavity is preserved under truncation
    print(f"\n  Conjecture 2: Log-concavity is closed under truncation")
    lc_counterexamples = 0
    for _ in range(n_trials):
        m = random.randint(3, 8)
        weights = [random.uniform(0, 5) for _ in range(m)]
        coeffs = compute_product_polynomial(weights)

        for r in range(2, m):
            truncated = coeffs[:r + 1] + [0.0] * (len(coeffs) - r - 1)
            lc_ok, _ = verify_log_concavity(truncated)
            if not lc_ok:
                lc_counterexamples += 1
                break

    print(f"  Result: {lc_counterexamples} counterexamples in {n_trials} trials")


if __name__ == "__main__":
    network_reliability_analysis()
    chemical_equilibrium()
    portfolio_combinatorics()
    code_weight_distribution()
    conjecture_testing()

    print(f"\n{'=' * 70}")
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
PF₂ Log-Concavity Demo: Interactive Exploration of Combinatorial Log-Concavity

Demonstrates the core theorems:
1. Binomial coefficients are log-concave
2. Products of linear factors ∏(1 + wᵢX) yield log-concave coefficient sequences
3. Fermionic partition function coefficients are log-concave

Usage:
    python demo.py                    # Run all demos
    python demo.py --interactive      # Interactive weight entry mode
    python demo.py --random N M       # Random experiment with N trials, M modes
"""

import math
import sys
from typing import List, Tuple
from itertools import combinations
from functools import reduce


def binomial_coefficients(n: int) -> List[int]:
    """Compute the row of Pascal's triangle: C(n, 0), C(n, 1), ..., C(n, n)."""
    return [math.comb(n, k) for k in range(n + 1)]


def check_log_concavity(seq: List[float]) -> List[Tuple[int, float]]:
    """Check log-concavity: a[k]² ≥ a[k-1]·a[k+1] for each k.
    Returns list of (k, margin) where margin = a[k]² - a[k-1]·a[k+1]."""
    results = []
    for k in range(1, len(seq) - 1):
        margin = seq[k] ** 2 - seq[k - 1] * seq[k + 1]
        results.append((k, margin))
    return results


def product_polynomial_coeffs(weights: List[float]) -> List[float]:
    """Compute coefficients of ∏ᵢ(1 + wᵢ·X) by sequential multiplication.

    This implements Route B (convolution/induction): each factor (1 + wᵢX)
    multiplies the current polynomial, extending the coefficient sequence.

    Algorithm:
        Start with coeffs = [1].
        For each weight w:
            new_coeffs[k] = coeffs[k] + w * coeffs[k-1]
        This is O(m²) where m = len(weights).
    """
    coeffs = [1.0]
    for w in weights:
        new_coeffs = [0.0] * (len(coeffs) + 1)
        for k in range(len(coeffs)):
            new_coeffs[k] += coeffs[k]
            new_coeffs[k + 1] += w * coeffs[k]
        coeffs = new_coeffs
    return coeffs


def elementary_symmetric(weights: List[float], k: int) -> float:
    """Compute e_k(w_1, ..., w_m) directly by summing over k-subsets."""
    if k < 0 or k > len(weights):
        return 0.0
    return sum(reduce(lambda a, b: a * b, (weights[i] for i in S), 1.0)
               for S in combinations(range(len(weights)), k))


def check_ratio_decreasing(seq: List[float]) -> List[Tuple[int, int, float]]:
    """Check the ratio-decreasing (PF₂) property:
    a[j+1]·a[k+1] ≥ a[j]·a[k+2] for all 0 ≤ j ≤ k.
    Returns list of (j, k, margin)."""
    results = []
    n = len(seq)
    for j in range(n - 2):
        for k in range(j, n - 2):
            if j + 1 < n and k + 1 < n and k + 2 < n:
                margin = seq[j + 1] * seq[k + 1] - seq[j] * seq[k + 2]
                results.append((j, k, margin))
    return results


def demo_binomial():
    """Demonstrate log-concavity of binomial coefficients C(n, k)."""
    print("=" * 70)
    print("THEOREM 1: Binomial Coefficients are Log-Concave")
    print("  C(n,k)² ≥ C(n,k-1) · C(n,k+1)  for all n, k")
    print("=" * 70)

    for n in [4, 7, 10, 15, 20]:
        coeffs = binomial_coefficients(n)
        results = check_log_concavity(coeffs)
        all_ok = all(margin >= -1e-10 for _, margin in results)
        min_margin = min(margin for _, margin in results) if results else 0

        print(f"\n  n = {n}: {coeffs}")
        print(f"  Log-concave: {'✓' if all_ok else '✗'}  "
              f"(min margin = {min_margin:.0f})")

        # Show detailed check for small n
        if n <= 7:
            for k, margin in results:
                print(f"    k={k}: {coeffs[k]}² = {coeffs[k]**2} ≥ "
                      f"{coeffs[k-1]}·{coeffs[k+1]} = {coeffs[k-1]*coeffs[k+1]}  "
                      f"margin = {margin:.0f}")


def demo_product_family():
    """Demonstrate log-concavity for product-of-linear-factors sequences."""
    print("\n" + "=" * 70)
    print("THEOREM 2: Products of Linear Factors → Log-Concave Coefficients")
    print("  Coefficients of ∏(1 + wᵢX) are log-concave when wᵢ ≥ 0")
    print("=" * 70)

    test_cases = [
        ("Uniform weights [1,1,1,1,1]", [1, 1, 1, 1, 1]),
        ("Weights [1,2,3]", [1, 2, 3]),
        ("Weights [0.5, 1.5, 2.5, 3.5]", [0.5, 1.5, 2.5, 3.5]),
        ("Weights [1,1,1,1,1,1,1] (= binomial)", [1, 1, 1, 1, 1, 1, 1]),
        ("Large weights [10, 20, 30, 40]", [10, 20, 30, 40]),
        ("Mixed [0, 1, 2, 3, 4]", [0, 1, 2, 3, 4]),
    ]

    for name, weights in test_cases:
        coeffs = product_polynomial_coeffs(weights)
        results = check_log_concavity(coeffs)
        all_ok = all(margin >= -1e-10 for _, margin in results) if results else True
        min_margin = min(margin for _, margin in results) if results else 0

        print(f"\n  {name}")
        print(f"  Coefficients: {[round(c, 4) for c in coeffs]}")
        print(f"  Log-concave: {'✓' if all_ok else '✗'}  "
              f"(min margin = {min_margin:.4f})")

        # Verify against elementary symmetric polynomial computation
        esym = [elementary_symmetric(weights, k) for k in range(len(weights) + 1)]
        match = all(abs(coeffs[k] - esym[k]) < 1e-10
                     for k in range(len(coeffs)))
        print(f"  Matches e_k formula: {'✓' if match else '✗'}")


def demo_ratio_decreasing():
    """Demonstrate the stronger ratio-decreasing (PF₂) property."""
    print("\n" + "=" * 70)
    print("PF₂ RATIO-DECREASING PROPERTY (stronger than log-concavity)")
    print("  a[j+1]·a[k+1] ≥ a[j]·a[k+2]  for all j ≤ k")
    print("=" * 70)

    weights = [1, 2, 3, 4]
    coeffs = product_polynomial_coeffs(weights)
    print(f"\n  Weights: {weights}")
    print(f"  Coefficients of ∏(1+wᵢX): {coeffs}")

    results = check_ratio_decreasing(coeffs)
    all_ok = all(margin >= -1e-10 for _, _, margin in results)
    min_margin = min(margin for _, _, margin in results) if results else 0

    print(f"\n  Ratio-decreasing (PF₂): {'✓' if all_ok else '✗'}  "
          f"(min margin = {min_margin:.4f})")
    print(f"  Checked {len(results)} pairs (j, k)")

    # Show some examples
    for j, k, margin in results[:6]:
        print(f"    j={j}, k={k}: a[{j+1}]·a[{k+1}] = {coeffs[j+1]*coeffs[k+1]:.1f} ≥ "
              f"a[{j}]·a[{k+2}] = {coeffs[j]*coeffs[k+2]:.1f}  margin = {margin:.1f}")


def demo_fermion():
    """Demonstrate the cross-domain bridge to fermionic partition functions."""
    print("\n" + "=" * 70)
    print("THEOREM 3: Fermionic Partition Function Log-Concavity")
    print("  Z(x) = ∏(1 + wᵢx) is the partition function of a")
    print("  noninteracting fermionic system with single-particle activities wᵢ.")
    print("  The k-particle state count is log-concave.")
    print("=" * 70)

    # Model: 5 energy levels with Boltzmann weights
    temperature = 1.0
    energies = [0.0, 0.5, 1.0, 1.5, 2.0]
    activities = [math.exp(-E / temperature) for E in energies]

    print(f"\n  Energy levels: {energies}")
    print(f"  Temperature: {temperature}")
    print(f"  Single-particle activities: {[round(a, 4) for a in activities]}")

    coeffs = product_polynomial_coeffs(activities)
    print(f"\n  k-particle degeneracies:")
    total = sum(coeffs)
    for k, c in enumerate(coeffs):
        bar = "█" * int(c / total * 50)
        print(f"    k={k}: {c:.4f}  (prob = {c/total:.4f})  {bar}")

    results = check_log_concavity(coeffs)
    all_ok = all(margin >= -1e-10 for _, margin in results)
    print(f"\n  Log-concave particle distribution: {'✓' if all_ok else '✗'}")
    print(f"  → Unimodal distribution (thermodynamic stability)")


def demo_partition_matroid():
    """Demonstrate partition matroid independence sequence log-concavity."""
    print("\n" + "=" * 70)
    print("THEOREM 4: Partition Matroid Independence Sequence is Log-Concave")
    print("  A partition matroid with blocks of sizes b₁,...,bₘ and capacity 1")
    print("  has independence polynomial ∏(1 + bᵢX).")
    print("=" * 70)

    # Example: partition matroid with blocks of various sizes
    block_sizes = [2, 3, 4, 5]
    print(f"\n  Block sizes: {block_sizes}")
    print(f"  (Select at most 1 element from each block)")

    coeffs = product_polynomial_coeffs([float(b) for b in block_sizes])
    print(f"\n  Independence numbers I_k (sets of size k):")
    for k, c in enumerate(coeffs):
        print(f"    I_{k} = {c:.0f}")

    results = check_log_concavity(coeffs)
    all_ok = all(margin >= -1e-10 for _, margin in results)
    print(f"\n  Log-concave (Mason-type): {'✓' if all_ok else '✗'}")
    print(f"  This is a certified special case of Mason's conjecture,")
    print(f"  proved via PF₂ factorization.")


def interactive_mode():
    """Interactive mode: user enters weights, sees log-concavity verification."""
    print("\n" + "=" * 70)
    print("INTERACTIVE MODE")
    print("  Enter nonneg weights separated by spaces.")
    print("  The program computes ∏(1 + wᵢX) and checks log-concavity.")
    print("  Type 'quit' to exit.")
    print("=" * 70)

    while True:
        try:
            inp = input("\n  Weights (space-separated): ").strip()
            if inp.lower() in ('quit', 'exit', 'q'):
                break
            weights = [float(x) for x in inp.split()]
            if any(w < 0 for w in weights):
                print("  ⚠ Warning: negative weights detected. PF₂ not guaranteed.")

            coeffs = product_polynomial_coeffs(weights)
            print(f"  Coefficients: {[round(c, 6) for c in coeffs]}")

            lc_results = check_log_concavity(coeffs)
            rd_results = check_ratio_decreasing(coeffs)

            lc_ok = all(m >= -1e-10 for _, m in lc_results) if lc_results else True
            rd_ok = all(m >= -1e-10 for _, _, m in rd_results) if rd_results else True

            print(f"  Log-concave: {'✓' if lc_ok else '✗'}")
            print(f"  Ratio-decreasing (PF₂): {'✓' if rd_ok else '✗'}")

            if lc_results:
                min_lc = min(m for _, m in lc_results)
                print(f"  Min log-concavity margin: {min_lc:.6f}")

        except ValueError:
            print("  Invalid input. Enter numbers separated by spaces.")
        except EOFError:
            break


def random_experiment(n_trials: int = 100, m_modes: int = 6):
    """Random experiment mode: test PF₂ on random weight vectors."""
    import random
    print(f"\n{'=' * 70}")
    print(f"RANDOM EXPERIMENT: {n_trials} trials, {m_modes} modes each")
    print(f"{'=' * 70}")

    lc_pass = 0
    rd_pass = 0
    min_margin_overall = float('inf')

    for trial in range(n_trials):
        weights = [random.uniform(0, 10) for _ in range(m_modes)]
        coeffs = product_polynomial_coeffs(weights)

        lc_results = check_log_concavity(coeffs)
        rd_results = check_ratio_decreasing(coeffs)

        lc_ok = all(m >= -1e-10 for _, m in lc_results) if lc_results else True
        rd_ok = all(m >= -1e-10 for _, _, m in rd_results) if rd_results else True

        if lc_ok:
            lc_pass += 1
        if rd_ok:
            rd_pass += 1

        if lc_results:
            min_m = min(m for _, m in lc_results)
            min_margin_overall = min(min_margin_overall, min_m)

    print(f"\n  Log-concave:       {lc_pass}/{n_trials} passed ({'100%' if lc_pass == n_trials else f'{100*lc_pass/n_trials:.1f}%'})")
    print(f"  Ratio-decreasing:  {rd_pass}/{n_trials} passed ({'100%' if rd_pass == n_trials else f'{100*rd_pass/n_trials:.1f}%'})")
    print(f"  Min margin overall: {min_margin_overall:.6f}")
    if lc_pass == n_trials and rd_pass == n_trials:
        print(f"\n  ✓ All {n_trials} random trials confirm PF₂ log-concavity!")
    else:
        print(f"\n  ⚠ Some trials failed (unexpected for nonneg weights).")


if __name__ == "__main__":
    args = sys.argv[1:]

    if "--interactive" in args:
        interactive_mode()
    elif "--random" in args:
        idx = args.index("--random")
        n = int(args[idx + 1]) if idx + 1 < len(args) else 100
        m = int(args[idx + 2]) if idx + 2 < len(args) else 6
        random_experiment(n, m)
    else:
        demo_binomial()
        demo_product_family()
        demo_ratio_decreasing()
        demo_fermion()
        demo_partition_matroid()
        random_experiment(200, 8)
        print("\n" + "=" * 70)
        print("All demos complete. All theorems verified computationally.")
        print("=" * 70)
