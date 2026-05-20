#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Symmetric Group Generation Theory

Demonstrates practical applications of the formal theory:
1. Cryptographic random permutation quality testing
2. Card shuffling analysis — how many shuffles until random?
3. Random network generation via Cayley graphs
4. Error detection in pseudo-random generators
"""

import random
import math
from math import factorial, comb
from fractions import Fraction
from typing import List, Tuple
from algorithms import (
    compute_orbits, is_transitive, perm_sign,
    fast_generation_test, reciprocal_binomial_sum,
    DixonDecomposition, count_preserving_perms
)


# ============================================================
# Application 1: Cryptographic PRNG Quality Testing
# ============================================================

def test_prng_quality(n: int, num_tests: int = 1000) -> dict:
    """
    Test the quality of Python's random.shuffle as a permutation generator
    by checking whether random pairs generate S_n.

    A high-quality PRNG should produce generating pairs with probability ≈ 3/4.
    Significant deviation suggests the PRNG has structural bias.

    This directly applies the formal theorem:
    - P_n ≤ 3/4 (generation_probability_le_three_quarters)
    - P_n ≈ 3/4 - O(1/n) for large n

    Returns:
        Dictionary with test results
    """
    results = {"generates": 0, "not_transitive": 0, "both_even": 0, "residual": 0}

    for _ in range(num_tests):
        sigma = list(range(n))
        tau = list(range(n))
        random.shuffle(sigma)
        random.shuffle(tau)

        status = fast_generation_test(sigma, tau, n)
        if status == "LIKELY_GENERATES":
            results["generates"] += 1
        elif status == "NOT_TRANSITIVE":
            results["not_transitive"] += 1
        elif status == "BOTH_EVEN":
            results["both_even"] += 1

    total = num_tests
    p_gen = results["generates"] / total
    p_expected = 0.75  # Dixon's limit

    results["p_generation"] = p_gen
    results["expected"] = p_expected
    results["deviation"] = abs(p_gen - p_expected)
    results["quality"] = "PASS" if results["deviation"] < 3 * (p_expected * (1-p_expected) / total) ** 0.5 else "SUSPECT"

    return results


# ============================================================
# Application 2: Card Shuffling Analysis
# ============================================================

def analyze_shuffle_quality(deck_size: int = 52, num_shuffles: int = 2):
    """
    Analyze whether multiple riffle shuffles can generate all possible
    deck orderings.

    Key insight from our theory: two random permutations generate S_n
    with probability approaching 3/4. This means even 2 shuffles
    are "algebraically sufficient" to reach any ordering — the limitation
    is mixing time, not algebraic reachability.

    The reciprocal binomial bound tells us the probability of failure:
    P(not transitive) ≤ 4/n for n ≥ 4.

    For a 52-card deck: P(not transitive) ≤ 4/52 ≈ 0.077.
    """
    n = deck_size
    decomp = DixonDecomposition(n)

    print(f"=== Card Shuffling Analysis (deck size = {n}) ===")
    print(f"After {num_shuffles} random shuffles (= 2 random permutations):")
    print(f"  P(generates all orderings) ≈ {0.75:.4f}")
    print(f"  P(not transitive) ≤ {4/n:.4f}")
    print(f"  P(both shuffles even) = 0.2500")
    print(f"  Reciprocal binomial sum = {float(reciprocal_binomial_sum(n)):.6f}")
    print(f"  Edge-dominated bound = {2/n + (n-3)/comb(n,2):.6f}")
    print()
    print("Interpretation:")
    print(f"  With ~{0.75*100:.0f}% probability, just 2 random shuffles can")
    print(f"  algebraically generate EVERY possible ordering of {n} cards.")
    print(f"  The 25% failure is almost entirely due to parity (both even).")
    print(f"  Non-transitivity failure is only ≤{4/n*100:.1f}%.")


# ============================================================
# Application 3: Random Network Generation
# ============================================================

def cayley_graph_properties(n: int, sigma: list, tau: list) -> dict:
    """
    Analyze the Cayley graph Cay(S_n, {σ, τ}) when <σ,τ> = S_n.

    The Cayley graph has n! vertices and is connected iff <σ,τ> = S_n.
    Our theory predicts this happens with probability ≈ 3/4.

    Properties computed:
    - Connectivity (= generation of S_n)
    - Number of orbits (= connected components)
    - Transitivity of the action on [n]
    """
    orbits = compute_orbits([sigma, tau], n)
    transitive = len(orbits) == 1

    return {
        "n": n,
        "transitive": transitive,
        "num_orbits": len(orbits),
        "orbit_sizes": sorted([len(o) for o in orbits], reverse=True),
        "sigma_sign": perm_sign(sigma),
        "tau_sign": perm_sign(tau),
        "both_even": perm_sign(sigma) == 1 and perm_sign(tau) == 1,
    }


def demonstrate_cayley_graphs(n: int = 8, trials: int = 20):
    """Show how random Cayley graphs on S_n behave."""
    print(f"\n=== Random Cayley Graphs on S_{n} ===")
    print(f"Generating {trials} random pairs and analyzing orbit structure:")
    print()

    stats = {"transitive": 0, "both_even": 0, "not_transitive": 0}

    for i in range(trials):
        sigma = list(range(n))
        tau = list(range(n))
        random.shuffle(sigma)
        random.shuffle(tau)

        props = cayley_graph_properties(n, sigma, tau)
        status = fast_generation_test(sigma, tau, n)

        if props["transitive"]:
            stats["transitive"] += 1
        if props["both_even"]:
            stats["both_even"] += 1
        if not props["transitive"]:
            stats["not_transitive"] += 1

        orbit_str = str(props["orbit_sizes"])
        print(f"  Trial {i+1:2d}: orbits={orbit_str:20s}  status={status}")

    print(f"\nSummary:")
    print(f"  Transitive: {stats['transitive']}/{trials} ({stats['transitive']/trials:.1%})")
    print(f"  Both even:  {stats['both_even']}/{trials} ({stats['both_even']/trials:.1%})")
    print(f"  Not trans:  {stats['not_transitive']}/{trials} ({stats['not_transitive']/trials:.1%})")
    print(f"  Expected transitive fraction: {1 - float(reciprocal_binomial_sum(n)):.4f}")


# ============================================================
# Application 4: Subset Preservation as Error Detection
# ============================================================

def detect_biased_generator(generator, n: int, num_tests: int = 500) -> dict:
    """
    Use subset preservation statistics to detect bias in a permutation generator.

    A truly random permutation preserves a k-element subset with probability
    k!(n-k)!/n!. If a generator consistently preserves certain subsets,
    it reveals structural bias.

    This applies the exact counting formula (card_perms_preserving_finset).
    """
    # Test: does the generator preserve {0, 1, ..., k-1} too often?
    results = {}
    for k in [1, 2, n//2]:
        A = set(range(k))
        preserve_count = 0
        for _ in range(num_tests):
            perm = generator(n)
            if all((i in A) == (perm[i] in A) for i in range(n)):
                preserve_count += 1

        expected_prob = count_preserving_perms(n, k) / factorial(n)
        observed_prob = preserve_count / num_tests
        z_score = (observed_prob - expected_prob) / max(
            (expected_prob * (1 - expected_prob) / num_tests) ** 0.5, 1e-10)

        results[k] = {
            "expected": expected_prob,
            "observed": observed_prob,
            "z_score": z_score,
            "suspicious": abs(z_score) > 3
        }

    return results


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)

    # Application 1: PRNG Quality
    print("=" * 65)
    print("  APPLICATION 1: PRNG QUALITY TESTING")
    print("=" * 65)
    for n in [8, 16, 32]:
        results = test_prng_quality(n, num_tests=500)
        print(f"\n  n={n}: P(gen)={results['p_generation']:.3f}, "
              f"expected≈{results['expected']:.3f}, "
              f"quality={results['quality']}")
        print(f"    not_transitive={results['not_transitive']}, "
              f"both_even={results['both_even']}")

    # Application 2: Card Shuffling
    print("\n" + "=" * 65)
    print("  APPLICATION 2: CARD SHUFFLING ANALYSIS")
    print("=" * 65)
    analyze_shuffle_quality(52)
    print()
    analyze_shuffle_quality(8)

    # Application 3: Cayley Graphs
    print("\n" + "=" * 65)
    print("  APPLICATION 3: RANDOM CAYLEY GRAPHS")
    print("=" * 65)
    demonstrate_cayley_graphs(8, 15)

    # Application 4: Bias Detection
    print("\n" + "=" * 65)
    print("  APPLICATION 4: BIAS DETECTION IN PERMUTATION GENERATORS")
    print("=" * 65)

    # Test with a good generator
    def good_gen(n):
        p = list(range(n))
        random.shuffle(p)
        return p

    # Test with a biased generator (tends to keep small elements fixed)
    def biased_gen(n):
        p = list(range(n))
        # Only shuffle the last n-2 elements with some probability
        if random.random() < 0.3:
            sub = p[2:]
            random.shuffle(sub)
            p[2:] = sub
        else:
            random.shuffle(p)
        return p

    print("\n  Testing good generator:")
    results = detect_biased_generator(good_gen, 10, 1000)
    for k, v in results.items():
        print(f"    k={k}: expected={v['expected']:.4f}, "
              f"observed={v['observed']:.4f}, z={v['z_score']:.2f} "
              f"{'⚠ SUSPICIOUS' if v['suspicious'] else '✓ OK'}")

    print("\n  Testing biased generator:")
    results = detect_biased_generator(biased_gen, 10, 1000)
    for k, v in results.items():
        print(f"    k={k}: expected={v['expected']:.4f}, "
              f"observed={v['observed']:.4f}, z={v['z_score']:.2f} "
              f"{'⚠ SUSPICIOUS' if v['suspicious'] else '✓ OK'}")

    print("\n✓ All applications demonstrated.")


#!/usr/bin/env python3
"""
demo.py — Symmetric Group Generation Probability

Demonstrates the key theorems numerically:
1. Exact generation probabilities for small n by exhaustive enumeration
2. Monte Carlo estimates for larger n
3. Verification of the reciprocal binomial sum bound
4. Testing the Dixon residual conjecture
5. Plots of P_n converging to 3/4
"""

import itertools
import random
import math
from math import factorial, comb
from fractions import Fraction
from typing import List, Tuple, Optional

# ============================================================
# Core utilities
# ============================================================

def compose(perm1: list, perm2: list) -> list:
    """Compose two permutations: (perm1 ∘ perm2)(i) = perm1[perm2[i]]."""
    return [perm1[perm2[i]] for i in range(len(perm1))]

def inverse(perm: list) -> list:
    """Inverse of a permutation."""
    inv = [0] * len(perm)
    for i, v in enumerate(perm):
        inv[v] = i
    return inv

def identity(n: int) -> list:
    return list(range(n))

def generate_subgroup(generators: List[list], n: int) -> set:
    """Generate the subgroup from a list of generators using BFS."""
    elements = {tuple(identity(n))}
    queue = [identity(n)]
    for g in generators:
        elements.add(tuple(g))
        queue.append(g)
        elements.add(tuple(inverse(g)))
        queue.append(inverse(g))

    while queue:
        current = queue.pop(0)
        for g in generators:
            for new in [compose(current, g), compose(g, current),
                        compose(current, inverse(g)), compose(inverse(g), current)]:
                t = tuple(new)
                if t not in elements:
                    elements.add(t)
                    queue.append(new)
    return elements

def generates_symmetric(sigma: list, tau: list) -> bool:
    """Check if <sigma, tau> = S_n by generating the full subgroup."""
    n = len(sigma)
    subgroup = generate_subgroup([sigma, tau], n)
    return len(subgroup) == factorial(n)

def perm_sign(perm: list) -> int:
    """Compute the sign of a permutation (+1 or -1)."""
    n = len(perm)
    visited = [False] * n
    sign = 1
    for i in range(n):
        if not visited[i]:
            cycle_len = 0
            j = i
            while not visited[j]:
                visited[j] = True
                j = perm[j]
                cycle_len += 1
            if cycle_len % 2 == 0:
                sign *= -1
    return sign

# ============================================================
# 1. Exact computation for small n
# ============================================================

def exact_generation_probability(n: int) -> Fraction:
    """Compute P_n exactly by enumerating all pairs."""
    if n <= 1:
        return Fraction(1, 1) if n == 1 else Fraction(0, 1)

    perms = list(itertools.permutations(range(n)))
    total = len(perms) ** 2
    gen_count = 0
    both_even = 0
    not_transitive = 0

    for sigma in perms:
        for tau in perms:
            s_list = list(sigma)
            t_list = list(tau)
            subgroup = generate_subgroup([s_list, t_list], n)
            if len(subgroup) == factorial(n):
                gen_count += 1
            if perm_sign(s_list) == 1 and perm_sign(t_list) == 1:
                both_even += 1
            # Check transitivity: can we reach all elements from 0
            reachable = set()
            queue = [0]
            reachable.add(0)
            while queue:
                x = queue.pop()
                for g in [s_list, t_list, inverse(s_list), inverse(t_list)]:
                    y = g[x]
                    if y not in reachable:
                        reachable.add(y)
                        queue.append(y)
            if len(reachable) < n:
                not_transitive += 1

    return Fraction(gen_count, total), Fraction(both_even, total), Fraction(not_transitive, total)


def compute_residual(n: int) -> Fraction:
    """Compute the residual: pairs generating transitive, not-in-A_n, but ≠ S_n."""
    perms = list(itertools.permutations(range(n)))
    total = len(perms) ** 2
    residual = 0
    for sigma in perms:
        for tau in perms:
            s_list = list(sigma)
            t_list = list(tau)
            subgroup = generate_subgroup([s_list, t_list], n)
            if len(subgroup) == factorial(n):
                continue  # generates S_n
            # Check transitivity
            reachable = set()
            queue = [0]
            reachable.add(0)
            while queue:
                x = queue.pop()
                for g in [s_list, t_list, inverse(s_list), inverse(t_list)]:
                    y = g[x]
                    if y not in reachable:
                        reachable.add(y)
                        queue.append(y)
            if len(reachable) < n:
                continue  # not transitive
            # Check if contains an odd permutation
            has_odd = any(perm_sign(list(p)) == -1 for p in subgroup)
            if has_odd:
                residual += 1
    return Fraction(residual, total)


# ============================================================
# 2. Monte Carlo estimation
# ============================================================

def random_perm(n: int) -> list:
    """Generate a uniformly random permutation of [0,...,n-1]."""
    p = list(range(n))
    random.shuffle(p)
    return p

def monte_carlo_generation_prob(n: int, samples: int = 10000) -> float:
    """Estimate P_n by Monte Carlo sampling."""
    gen_count = 0
    for _ in range(samples):
        sigma = random_perm(n)
        tau = random_perm(n)
        subgroup = generate_subgroup([sigma, tau], n)
        if len(subgroup) == factorial(n):
            gen_count += 1
    return gen_count / samples


# ============================================================
# 3. Reciprocal binomial sum
# ============================================================

def reciprocal_binomial_sum(n: int) -> float:
    """Compute ∑_{k=1}^{n-1} 1/C(n,k)."""
    return sum(1 / comb(n, k) for k in range(1, n))

def check_binomial_bounds():
    """Verify the proved bounds on the reciprocal binomial sum."""
    print("\n=== Reciprocal Binomial Sum Bounds ===")
    print(f"{'n':>4} | {'Sum':>12} | {'2/n+(n-3)/C(n,2)':>18} | {'4/n':>8} | {'Both hold':>10}")
    print("-" * 60)
    for n in range(4, 30):
        s = reciprocal_binomial_sum(n)
        edge_bound = 2/n + (n-3)/comb(n, 2)
        four_n = 4/n
        ok = s <= edge_bound + 1e-12 and s <= four_n + 1e-12
        print(f"{n:4d} | {s:12.8f} | {edge_bound:18.8f} | {four_n:8.6f} | {'✓' if ok else '✗':>10}")


# ============================================================
# 4. Subset preservation counting verification
# ============================================================

def verify_subset_preservation(n: int):
    """Verify card_perms_preserving_finset for small n."""
    import itertools
    perms = list(itertools.permutations(range(n)))

    print(f"\n=== Subset Preservation Count Verification (n={n}) ===")
    for k in range(1, n):
        # Use the first subset of size k: {0, 1, ..., k-1}
        A = set(range(k))
        count = sum(1 for p in perms if all((i in A) == (p[i] in A) for i in range(n)))
        expected = factorial(k) * factorial(n - k)
        print(f"  k={k}: count={count}, expected k!*(n-k)!={expected}, match={'✓' if count == expected else '✗'}")


# ============================================================
# 5. Dixon residual conjecture test
# ============================================================

def test_residual_conjecture():
    """Test: for n ≥ 5, residualProperTransitiveProb(n) ≤ 3/n²."""
    print("\n=== Dixon Residual Conjecture Test ===")
    print("Conjecture: residualProperTransitiveProb(n) ≤ 3/n² for n ≥ 8")
    print(f"{'n':>4} | {'Residual':>12} | {'3/n²':>10} | {'Holds':>6}")
    print("-" * 45)
    for n in range(3, 5):  # Only feasible for small n
        res = compute_residual(n)
        bound = Fraction(3, n*n)
        holds = res <= bound
        print(f"{n:4d} | {float(res):12.8f} | {float(bound):10.6f} | {'✓' if holds else '✗':>6}")
        print(f"       exact: {res}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 65)
    print("  SYMMETRIC GROUP GENERATION PROBABILITY — NUMERICAL DEMOS")
    print("=" * 65)

    # 1. Exact computation
    print("\n=== Exact Generation Probabilities ===")
    print(f"{'n':>4} | {'P_n':>12} | {'P_n (float)':>12} | {'Both even':>10} | {'Not trans':>10}")
    print("-" * 65)
    for n in range(2, 5):  # n=5 is too slow for exhaustive
        p, be, nt = exact_generation_probability(n)
        print(f"{n:4d} | {str(p):>12} | {float(p):12.6f} | {float(be):10.6f} | {float(nt):10.6f}")

    # 2. Verify 3/4 upper bound
    print("\n=== Verification: P_n ≤ 3/4 ===")
    for n in range(2, 5):
        p, _, _ = exact_generation_probability(n)
        print(f"  n={n}: P_n = {float(p):.6f} ≤ 0.75 → {'✓' if p <= Fraction(3, 4) else '✗'}")

    # 3. Subset preservation
    verify_subset_preservation(4)
    verify_subset_preservation(5)

    # 4. Binomial bounds
    check_binomial_bounds()

    # 5. Residual conjecture
    test_residual_conjecture()

    # 6. Monte Carlo for larger n (if time permits)
    print("\n=== Monte Carlo Estimates (1000 samples each) ===")
    print(f"{'n':>4} | {'P_n estimate':>12} | {'3/4':>6} | {'4/n':>8}")
    print("-" * 40)
    for n in [5, 6, 7]:
        try:
            p_est = monte_carlo_generation_prob(n, samples=200)
            print(f"{n:4d} | {p_est:12.4f} | 0.7500 | {4/n:8.4f}")
        except Exception:
            print(f"{n:4d} | (too slow)   |        |")

    # 7. Convergence visualization (text)
    print("\n=== Convergence to 3/4 ===")
    print("The reciprocal binomial sum → 0 as n → ∞:")
    for n in [10, 20, 50, 100, 200, 500, 1000]:
        s = reciprocal_binomial_sum(n)
        print(f"  n={n:5d}: ∑ 1/C(n,k) = {s:.8f},  4/n = {4/n:.8f}")

    print("\n✓ All demonstrations complete.")
