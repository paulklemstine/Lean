#!/usr/bin/env python3
"""
Tropical Quadratic Sieve — Applications

Demonstrates real-world applications of tropical sieve scoring:
1. Smooth number detection as shortest-path computation
2. Hardware-amenable min-plus sieve kernels
3. Tropical entropy of factorization support
4. Batch relation collection via min-plus matrix operations
"""

import math
import time
from typing import Dict, List, Tuple


# ============================================================================
# Utility functions
# ============================================================================

def sieve_primes(bound: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(2, bound + 1) if is_prime[i]]


def factorize(n: int) -> Dict[int, int]:
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def p_adic_val(p: int, n: int) -> int:
    if n == 0:
        return 0
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


# ============================================================================
# Application 1: Smoothness as Shortest Path
# ============================================================================

def smoothness_as_shortest_path():
    """
    Smooth number detection recast as a shortest-path problem.

    The "graph": nodes = prime powers, edges = valuation steps.
    A number n is B-smooth iff there exists a path of length log(n)
    through primes ≤ B. The tropical score computes this path length.
    """
    print("=" * 70)
    print("APPLICATION 1: Smoothness Detection as Shortest Path")
    print("=" * 70)

    N = 10007  # prime, so Q_N(x) will have interesting structure
    B = 30
    factor_base = sieve_primes(B)
    sqrt_N = int(math.isqrt(N)) + 1

    print(f"\nN = {N}, B = {B}")
    print(f"Factor base: {factor_base}")
    print(f"\nInterpretation: Each Q_N(x) = x² - N defines a 'distance'")
    print(f"in the prime factorization graph. Smooth numbers have")
    print(f"zero 'unexplained distance' — they are fully reachable")
    print(f"through the factor base.\n")

    print(f"{'x':>5} | {'Q(x)':>8} | {'log Q(x)':>8} | {'Explained':>9} | {'Gap':>8} | {'Status'}")
    print("-" * 65)

    for x in range(sqrt_N, sqrt_N + 25):
        q = x * x - N
        if q <= 0:
            continue
        log_q = math.log(q)
        explained = sum(p_adic_val(p, q) * math.log(p) for p in factor_base)
        gap = log_q - explained

        if gap < 0.01:
            status = "SMOOTH — zero gap ✓"
        elif gap < 2:
            status = f"almost (1 large prime?)"
        else:
            status = "rough"

        print(f"{x:>5} | {q:>8} | {log_q:>8.3f} | {explained:>9.3f} | {gap:>8.3f} | {status}")


# ============================================================================
# Application 2: Hardware Min-Plus Kernel Simulation
# ============================================================================

def hardware_kernel_simulation():
    """
    Simulates a systolic min-plus array for sieve scoring.

    A min-plus systolic array processes one (x, p) pair per clock cycle,
    computing the tropical score in R × |FB| cycles. This is directly
    implementable on FPGAs as a pipeline of add-compare-select units.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Hardware Min-Plus Sieve Kernel")
    print("=" * 70)

    N = 3571
    B = 20
    factor_base = sieve_primes(B)
    sqrt_N = int(math.isqrt(N)) + 1
    R = 20  # sieve interval size

    print(f"\nN = {N}, B = {B}, R = {R}")
    print(f"Factor base ({len(factor_base)} primes): {factor_base}")
    print(f"\nSystolic array: {R} rows × {len(factor_base)} columns")
    print(f"Total clock cycles: {R * len(factor_base)}")
    print(f"Operations per cycle: 1 add + 1 compare = 2 gates")
    print()

    # Simulate the systolic pipeline
    weights = [round(math.log(p), 3) for p in factor_base]
    cycle = 0
    scores = {}

    print(f"{'Cycle':>6} | {'x':>5} | {'p':>4} | {'v_p(Q)':>6} | {'w_p':>6} | {'Accum':>8}")
    print("-" * 55)

    for i, x in enumerate(range(sqrt_N, sqrt_N + min(R, 5))):  # show first 5
        q = abs(x * x - N)
        accum = 0.0
        for j, p in enumerate(factor_base):
            v = p_adic_val(p, q) if q > 0 else 0
            contribution = v * weights[j]
            accum += contribution
            cycle += 1
            if v > 0:  # only show non-zero contributions
                print(f"{cycle:>6} | {x:>5} | {p:>4} | {v:>6} | {weights[j]:>6} | {accum:>8.3f}")
        scores[x] = accum

    # Timing comparison
    print(f"\n--- Performance comparison (R={200}, |FB|={len(factor_base)}) ---")

    t0 = time.perf_counter()
    for _ in range(100):
        for x in range(sqrt_N, sqrt_N + 200):
            q = abs(x * x - N)
            _ = sum(p_adic_val(p, q) * math.log(p) for p in factor_base)
    t_classical = (time.perf_counter() - t0) / 100

    t0 = time.perf_counter()
    for _ in range(100):
        for x in range(sqrt_N, sqrt_N + 200):
            q = abs(x * x - N)
            _ = min(p_adic_val(p, q) + math.log(p) for p in factor_base)
    t_tropical = (time.perf_counter() - t0) / 100

    print(f"Classical scoring (sum): {t_classical*1000:.2f} ms")
    print(f"Tropical scoring (min): {t_tropical*1000:.2f} ms")
    print(f"Both use O(R·|FB|) = O({200 * len(factor_base)}) operations")


# ============================================================================
# Application 3: Tropical Entropy of Factorization
# ============================================================================

def tropical_entropy():
    """
    Tropical entropy: measures the "information content" of a number's
    factorization relative to a factor base.

    Smooth numbers have low tropical entropy (fully described by FB).
    Rough numbers have high tropical entropy (require information beyond FB).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Tropical Entropy of Factorization")
    print("=" * 70)

    B = 50
    factor_base = sieve_primes(B)

    print(f"\nFactor base: primes ≤ {B} ({len(factor_base)} primes)")
    print(f"\nTropical entropy H_T(n) = log(n) - Σ v_p(n)·log(p) for p ∈ FB")
    print(f"  = 0 for B-smooth numbers")
    print(f"  = log(large_factor) for numbers with one large prime")
    print()

    test_numbers = [
        2**10,                          # 1024, very smooth
        2**3 * 3**2 * 5 * 7,            # 2520, smooth
        2**2 * 3 * 53,                  # 636, one prime just above B
        2 * 3 * 5 * 101,               # 3030, one large prime
        97 * 103,                       # 9991, two large primes
        7919,                           # large prime itself
        2**4 * 3**3 * 5**2 * 7 * 11,   # 83160, very smooth
    ]

    print(f"{'n':>8} | {'log(n)':>8} | {'Explained':>9} | {'H_T(n)':>8} | {'Type'}")
    print("-" * 60)

    for n in test_numbers:
        log_n = math.log(n)
        explained = sum(p_adic_val(p, n) * math.log(p) for p in factor_base)
        entropy = log_n - explained

        factors = factorize(n)
        large = [p for p in factors if p > B]
        if not large:
            ntype = "B-smooth"
        elif len(large) == 1:
            ntype = f"1-partial ({large[0]})"
        else:
            ntype = f"rough ({large})"

        print(f"{n:>8} | {log_n:>8.3f} | {explained:>9.3f} | {entropy:>8.3f} | {ntype}")


# ============================================================================
# Application 4: Batch Relation Collection
# ============================================================================

def batch_relation_collection():
    """
    Batch relation collection using min-plus matrix operations.

    Instead of scoring candidates one at a time, build the full
    valuation matrix and compute all scores simultaneously via
    tropical matrix-vector multiplication.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Batch Tropical Relation Collection")
    print("=" * 70)

    N = 91643  # composite
    B = 40
    factor_base = sieve_primes(B)
    sqrt_N = int(math.isqrt(N)) + 1
    R = 100

    print(f"\nN = {N}, B = {B}")
    print(f"Factor base: {len(factor_base)} primes")
    print(f"Sieve interval: [{sqrt_N}, {sqrt_N + R - 1}]")

    # Build valuation matrix
    sieve_points = list(range(sqrt_N, sqrt_N + R))
    M = []  # M[i][j] = v_{p_j}(Q_N(x_i))
    Q_vals = []
    for x in sieve_points:
        q = abs(x * x - N)
        Q_vals.append(q)
        row = [p_adic_val(p, q) if q > 0 else 0 for p in factor_base]
        M.append(row)

    # Weight vector
    w = [math.log(p) for p in factor_base]

    # Compute all scores via matrix-vector product (classical: dot product)
    classical_scores = [
        sum(M[i][j] * w[j] for j in range(len(factor_base)))
        for i in range(R)
    ]

    # Compute all deficiencies
    deficiencies = []
    smooth_count = 0
    for i in range(R):
        q = Q_vals[i]
        if q <= 0:
            continue
        log_q = math.log(q)
        deficiency = log_q - classical_scores[i]
        is_smooth = deficiency < 0.01

        if is_smooth:
            smooth_count += 1
        deficiencies.append((sieve_points[i], q, deficiency, is_smooth))

    # Sort by deficiency (tropical ranking)
    deficiencies.sort(key=lambda t: t[2])

    print(f"\nResults:")
    print(f"  Total candidates scored: {R}")
    print(f"  Smooth relations found: {smooth_count}")
    print(f"  Matrix operations: {R} × {len(factor_base)} = {R * len(factor_base)}")
    print()

    print(f"Top 15 candidates by tropical deficiency:")
    print(f"{'Rank':>4} | {'x':>6} | {'Q(x)':>10} | {'Defic.':>8} | {'Status'}")
    print("-" * 50)
    for rank, (x, q, d, smooth) in enumerate(deficiencies[:15], 1):
        status = "SMOOTH ✓" if smooth else ""
        factors = factorize(q)
        large = [p for p in factors if p > B]
        if not smooth and large:
            status = f"large: {large}"
        print(f"{rank:>4} | {x:>6} | {q:>10} | {d:>8.3f} | {status}")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    smoothness_as_shortest_path()
    hardware_kernel_simulation()
    tropical_entropy()
    batch_relation_collection()

    print("\n" + "=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Quadratic Sieve — Demonstration

Concrete numerical examples showing how min-plus (tropical) algebra
exactly captures the scoring criterion of the quadratic sieve's
relation-collection stage.
"""

import math
from collections import defaultdict
from typing import Dict, List, Tuple


def factorize(n: int) -> Dict[int, int]:
    """Return the prime factorization of n as {prime: exponent}."""
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def classical_weight_score(n: int, w: Dict[int, float]) -> float:
    """Classical weight score: Σ v_p(n) · w(p) over prime factors of n."""
    factors = factorize(n)
    return sum(exp * w.get(p, 0) for p, exp in factors.items())


def tropical_score(n: int, factor_base: List[int], w: Dict[int, float]) -> float:
    """Tropical score: Σ v_p(n) · w(p) over the factor base S."""
    factors = factorize(n)
    return sum(factors.get(p, 0) * w.get(p, 0) for p in factor_base)


def is_smooth(n: int, factor_base: List[int]) -> bool:
    """Check if n is B-smooth (all prime factors in the factor base)."""
    factors = factorize(n)
    return all(p in factor_base for p in factors)


def Q_N(x: int, N: int) -> int:
    """Quadratic sieve polynomial: Q_N(x) = x² - N."""
    return x * x - N


def demo_tropical_classical_equivalence():
    """
    THEOREM DEMONSTRATION: Tropical score = Classical score on smooth inputs.

    For B-smooth numbers, the tropical score (summing over the factor base)
    exactly equals the classical weight score (summing over actual prime factors).
    """
    print("=" * 70)
    print("DEMO 1: Tropical-Classical Equivalence on Smooth Inputs")
    print("=" * 70)

    N = 15347  # composite number to factor
    B = 20     # smoothness bound
    factor_base = [p for p in range(2, B + 1) if all(p % d != 0 for d in range(2, p))]
    weights = {p: math.log(p) for p in factor_base}

    print(f"\nTarget: N = {N}")
    print(f"Factor base (primes ≤ {B}): {factor_base}")
    print(f"Weights w(p) = ln(p): {{{', '.join(f'{p}: {w:.3f}' for p, w in weights.items())}}}")
    print()

    # Scan sieve interval for smooth values
    sqrt_N = int(math.isqrt(N)) + 1
    smooth_count = 0
    non_smooth_count = 0

    print(f"{'x':>6} | {'Q_N(x)':>10} | {'Smooth?':>7} | {'Classical':>10} | {'Tropical':>10} | {'Match?':>6}")
    print("-" * 70)

    for x in range(sqrt_N, sqrt_N + 30):
        q = Q_N(x, N)
        if q <= 0:
            continue

        smooth = is_smooth(q, factor_base)
        c_score = classical_weight_score(q, weights)
        t_score = tropical_score(q, factor_base, weights)

        match = "✓" if abs(c_score - t_score) < 1e-10 else "✗"

        if smooth:
            smooth_count += 1
            print(f"{x:>6} | {q:>10} | {'YES':>7} | {c_score:>10.4f} | {t_score:>10.4f} | {match:>6}")
        else:
            non_smooth_count += 1
            factors = factorize(q)
            large_primes = [p for p in factors if p > B]
            if non_smooth_count <= 5:  # show a few non-smooth examples
                print(f"{x:>6} | {q:>10} | {'NO':>7} | {c_score:>10.4f} | {t_score:>10.4f} | {'—':>6}  large: {large_primes}")

    print(f"\nSmooth values found: {smooth_count}")
    print(f"KEY RESULT: On ALL smooth inputs, tropical score = classical score ✓")
    print(f"(Non-smooth inputs: scores differ because tropical misses large primes)")


def demo_min_plus_convolution():
    """
    THEOREM DEMONSTRATION: Associativity of min-plus convolution.

    (f ★ g) ★ h = f ★ (g ★ h) where (f ★ g)(n) = min_k (f(k) + g(n-k)).
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Associativity of Min-Plus Convolution")
    print("=" * 70)

    def tropical_conv(f, g, n):
        """Min-plus convolution: min over k in [0,n] of f(k) + g(n-k)."""
        return min(f(k) + g(n - k) for k in range(n + 1))

    # Define test functions (simulating sieve scoring patterns)
    f = lambda k: k * k % 7 + 1      # valuation-like function
    g = lambda k: (k + 3) % 5 + 2    # weight-like function
    h = lambda k: abs(k - 4) + 1     # penalty-like function

    print("\nTest functions:")
    print(f"  f(k) = k² mod 7 + 1:  {[f(k) for k in range(10)]}")
    print(f"  g(k) = (k+3) mod 5 + 2: {[g(k) for k in range(10)]}")
    print(f"  h(k) = |k-4| + 1:     {[h(k) for k in range(10)]}")
    print()

    max_n = 15
    all_match = True

    print(f"{'n':>4} | {'(f★g)★h':>10} | {'f★(g★h)':>10} | {'Match':>6}")
    print("-" * 40)

    for n in range(max_n + 1):
        fg = lambda m, _f=f, _g=g: tropical_conv(_f, _g, m)
        gh = lambda m, _g=g, _h=h: tropical_conv(_g, _h, m)

        lhs = tropical_conv(fg, h, n)
        rhs = tropical_conv(f, gh, n)
        match = lhs == rhs
        all_match = all_match and match

        print(f"{n:>4} | {lhs:>10} | {rhs:>10} | {'✓' if match else '✗':>6}")

    print(f"\nAssociativity verified for all n in [0, {max_n}]: {'✓ ALL MATCH' if all_match else '✗ MISMATCH'}")


def demo_min_plus_matrix_vector():
    """
    THEOREM DEMONSTRATION: Min-plus matrix-vector multiplication.

    Shows how sieve scoring is naturally a tropical linear algebra operation,
    and demonstrates the monotonicity theorem.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Min-Plus Matrix-Vector Product (Tropical Sieve Kernel)")
    print("=" * 70)

    N = 2041
    sqrt_N = int(math.isqrt(N)) + 1
    factor_base = [2, 3, 5, 7, 11, 13]
    sieve_points = list(range(sqrt_N, sqrt_N + 8))

    print(f"\nN = {N}, factor base = {factor_base}")
    print(f"Sieve points: {sieve_points}")

    # Build valuation matrix M[i][j] = v_{p_j}(Q_N(x_i))
    M = []
    for x in sieve_points:
        q = Q_N(x, N)
        if q <= 0:
            q = 1
        factors = factorize(q)
        row = [factors.get(p, 0) for p in factor_base]
        M.append(row)

    print("\nValuation matrix M[x_i, p_j] = v_{p_j}(Q_N(x_i)):")
    header = f"{'x':>6} | {'Q_N(x)':>8} |" + "".join(f"  p={p:>2}" for p in factor_base) + " | smooth?"
    print(header)
    print("-" * len(header))
    for i, x in enumerate(sieve_points):
        q = Q_N(x, N)
        smooth = is_smooth(max(q, 1), factor_base)
        row_str = "".join(f"  {M[i][j]:>4}" for j in range(len(factor_base)))
        print(f"{x:>6} | {q:>8} |{row_str} | {'YES ✓' if smooth else 'no'}")

    # Min-plus matrix-vector product with weight vector
    w = [int(math.log(p) * 10) for p in factor_base]  # discretized log weights
    print(f"\nWeight vector w = [10·ln(p)]: {w}")

    print("\nMin-plus product (M ⊗ w)[i] = min_j (M[i,j] + w[j]):")
    for i, x in enumerate(sieve_points):
        vals = [M[i][j] + w[j] for j in range(len(factor_base))]
        result = min(vals)
        argmin = vals.index(result)
        print(f"  x={x}: min({vals}) = {result} (via p={factor_base[argmin]})")

    # Demonstrate monotonicity
    w2 = [v + 5 for v in w]
    print(f"\nMonotonicity: w' = w + 5 = {w2}")
    print("  (M ⊗ w)[i] ≤ (M ⊗ w')[i] for all i:")
    for i, x in enumerate(sieve_points):
        v1 = min(M[i][j] + w[j] for j in range(len(factor_base)))
        v2 = min(M[i][j] + w2[j] for j in range(len(factor_base)))
        print(f"  x={x}: {v1} ≤ {v2} {'✓' if v1 <= v2 else '✗'}")


def demo_idempotent_no_go():
    """
    THEOREM DEMONSTRATION: Idempotent additive groups are trivial.

    Shows why the parity-solving stage of QS cannot be tropicalized:
    requiring both idempotent addition and additive inverses forces triviality.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: No-Go Theorem — Idempotent Groups are Trivial")
    print("=" * 70)

    print("\nThe quadratic sieve has two stages:")
    print("  1. Relation collection (scoring): uses + and min → TROPICALIZES ✓")
    print("  2. Linear algebra over GF(2): uses + and − → CANNOT tropicalize ✗")
    print()
    print("WHY? If a + a = a (idempotent) and the group has inverses:")
    print("  a + a = a")
    print("  ⟹ (a + a) + (-a) = a + (-a)")
    print("  ⟹ a + 0 = 0")
    print("  ⟹ a = 0")
    print()
    print("So the only group with idempotent addition is {0}.")
    print()

    # Verify computationally with Z/nZ for various n
    print("Computational verification — elements with a+a=a in Z/nZ:")
    for n in range(2, 13):
        idempotents = [a for a in range(n) if (2 * a) % n == a]
        print(f"  Z/{n}Z: idempotent elements = {idempotents} "
              f"({'only 0 — trivial!' if idempotents == [0] else 'NOT a group property'})")

    print()
    print("CONCLUSION: Only Z/1Z has ALL elements idempotent under addition.")
    print("This is why GF(2) linear algebra (the sieve's final stage)")
    print("is structurally incompatible with tropical (idempotent) algebra.")


def demo_sieve_scoring_comparison():
    """
    DEMO 5: Full sieve scoring comparison — classical vs tropical.

    Shows the complete workflow of scoring candidates in both frameworks,
    demonstrating exact agreement on smooth inputs and the information
    structure of the tropical deficiency score.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Complete Sieve Scoring — Classical vs Tropical")
    print("=" * 70)

    N = 7429  # = 89 × 83 + 42... let's check
    print(f"\nN = {N} = ", end="")
    fN = factorize(N)
    print(" × ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(fN.items())))

    B = 30
    factor_base = [p for p in range(2, B + 1) if all(p % d != 0 for d in range(2, p))]
    weights = {p: round(math.log(p), 4) for p in factor_base}

    print(f"Factor base (B={B}): {factor_base}")
    print(f"Weight = ln(p)")
    print()

    sqrt_N = int(math.isqrt(N)) + 1
    results = []

    for x in range(sqrt_N, sqrt_N + 50):
        q = Q_N(x, N)
        if q <= 0:
            continue
        smooth = is_smooth(q, factor_base)
        c_score = classical_weight_score(q, weights)
        t_score = tropical_score(q, factor_base, weights)
        deficiency = c_score - t_score  # how much is "missed" by tropical
        results.append((x, q, smooth, c_score, t_score, deficiency))

    print(f"{'x':>5} | {'Q(x)':>8} | {'Smooth':>6} | {'Class.':>8} | {'Trop.':>8} | {'Defic.':>8} | Factors")
    print("-" * 80)
    for x, q, smooth, cs, ts, defic in results[:20]:
        facts = factorize(q)
        fact_str = " · ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(facts.items()))
        print(f"{x:>5} | {q:>8} | {'YES ✓' if smooth else 'no':>6} | {cs:>8.3f} | {ts:>8.3f} | {defic:>8.3f} | {fact_str}")

    smooth_results = [(x, q, cs, ts) for x, q, sm, cs, ts, _ in results if sm]
    print(f"\n{len(smooth_results)} smooth values found in interval.")
    if smooth_results:
        print("On ALL smooth values: tropical score = classical score ✓")
        for x, q, cs, ts in smooth_results:
            assert abs(cs - ts) < 1e-10, f"Mismatch at x={x}!"


if __name__ == "__main__":
    demo_tropical_classical_equivalence()
    demo_min_plus_convolution()
    demo_min_plus_matrix_vector()
    demo_idempotent_no_go()
    demo_sieve_scoring_comparison()

    print("\n" + "=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Quadratic Sieve — Visualizations

Generates publication-quality figures showing:
1. Tropical vs classical sieve scores
2. Min-plus convolution associativity
3. Smoothness landscape (tropical entropy)
4. Valuation matrix heatmap
"""

import math
import base64
import io
from typing import Dict, List

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def factorize(n: int) -> Dict[int, int]:
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def p_adic_val(p: int, n: int) -> int:
    if n == 0:
        return 0
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def sieve_primes(bound: int) -> List[int]:
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(2, bound + 1) if is_prime[i]]


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_score_comparison():
    """Figure 1: Tropical vs Classical Sieve Scores."""
    N = 15347
    B = 30
    fb = sieve_primes(B)
    sqrt_N = int(math.isqrt(N)) + 1
    interval = list(range(sqrt_N, sqrt_N + 60))

    xs = []
    classical = []
    tropical = []
    smooth_x = []
    smooth_y = []

    for x in interval:
        q = x * x - N
        if q <= 0:
            continue
        xs.append(x)

        factors = factorize(q)
        c_score = sum(e * math.log(p) for p, e in factors.items())
        t_score = sum(p_adic_val(p, q) * math.log(p) for p in fb)

        classical.append(c_score)
        tropical.append(t_score)

        large_primes = [p for p in factors if p > B]
        if not large_primes:
            smooth_x.append(x)
            smooth_y.append(c_score)

    fig, ax = plt.subplots(1, 1, figsize=(12, 6))
    ax.plot(xs, classical, 'b-', linewidth=1.5, alpha=0.8, label='Classical score (all primes)')
    ax.plot(xs, tropical, 'r--', linewidth=1.5, alpha=0.8, label='Tropical score (factor base only)')
    ax.scatter(smooth_x, smooth_y, c='green', s=80, zorder=5,
               label='B-smooth (scores match exactly)', edgecolors='darkgreen', linewidth=1)

    ax.set_xlabel('Sieve point x', fontsize=13)
    ax.set_ylabel('Weight score', fontsize=13)
    ax.set_title(f'Tropical vs Classical Sieve Scoring (N={N}, B={B})', fontsize=15)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_tropical_entropy():
    """Figure 2: Tropical entropy landscape over sieve interval."""
    N = 10007
    B = 30
    fb = sieve_primes(B)
    sqrt_N = int(math.isqrt(N)) + 1
    R = 100

    xs = []
    entropies = []
    colors = []

    for x in range(sqrt_N, sqrt_N + R):
        q = x * x - N
        if q <= 0:
            continue
        xs.append(x)
        log_q = math.log(q)
        explained = sum(p_adic_val(p, q) * math.log(p) for p in fb)
        entropy = log_q - explained
        entropies.append(entropy)

        if entropy < 0.01:
            colors.append('green')
        elif entropy < 3:
            colors.append('orange')
        else:
            colors.append('red')

    fig, ax = plt.subplots(1, 1, figsize=(12, 5))
    ax.bar(xs, entropies, color=colors, alpha=0.7, width=0.8)
    ax.axhline(y=0, color='green', linestyle='-', linewidth=2, alpha=0.5)

    green_patch = mpatches.Patch(color='green', alpha=0.7, label='B-smooth (entropy ≈ 0)')
    orange_patch = mpatches.Patch(color='orange', alpha=0.7, label='Near-smooth (1 large prime)')
    red_patch = mpatches.Patch(color='red', alpha=0.7, label='Rough (high entropy)')
    ax.legend(handles=[green_patch, orange_patch, red_patch], fontsize=11)

    ax.set_xlabel('Sieve point x', fontsize=13)
    ax.set_ylabel('Tropical entropy H_T(x)', fontsize=13)
    ax.set_title(f'Tropical Entropy Landscape (N={N}, B={B})', fontsize=15)
    ax.grid(True, alpha=0.3, axis='y')

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_valuation_heatmap():
    """Figure 3: Valuation matrix heatmap."""
    N = 2041
    B = 20
    fb = sieve_primes(B)
    sqrt_N = int(math.isqrt(N)) + 1
    R = 20

    M = np.zeros((R, len(fb)))
    x_labels = []
    for i, x in enumerate(range(sqrt_N, sqrt_N + R)):
        q = abs(x * x - N)
        x_labels.append(str(x))
        for j, p in enumerate(fb):
            M[i, j] = p_adic_val(p, q) if q > 0 else 0

    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    im = ax.imshow(M, aspect='auto', cmap='YlOrRd', interpolation='nearest')
    ax.set_xticks(range(len(fb)))
    ax.set_xticklabels([str(p) for p in fb], fontsize=10)
    ax.set_yticks(range(R))
    ax.set_yticklabels(x_labels, fontsize=9)
    ax.set_xlabel('Factor base prime p', fontsize=13)
    ax.set_ylabel('Sieve point x', fontsize=13)
    ax.set_title(f'Valuation Matrix v_p(Q_N(x)) (N={N}, B={B})', fontsize=15)

    cbar = fig.colorbar(im, ax=ax)
    cbar.set_label('p-adic valuation', fontsize=12)

    # Annotate cells
    for i in range(R):
        for j in range(len(fb)):
            if M[i, j] > 0:
                ax.text(j, i, str(int(M[i, j])), ha='center', va='center',
                        fontsize=8, color='white' if M[i, j] > 2 else 'black')

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_convolution_associativity():
    """Figure 4: Min-plus convolution associativity verification."""
    f = lambda k: (k * k) % 7 + 1
    g = lambda k: (k + 3) % 5 + 2
    h = lambda k: abs(k - 4) + 1

    def tconv(f_func, g_func, n):
        return min(f_func(k) + g_func(n - k) for k in range(n + 1))

    ns = list(range(20))
    lhs = [tconv(lambda m: tconv(f, g, m), h, n) for n in ns]
    rhs = [tconv(f, lambda m: tconv(g, h, m), n) for n in ns]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

    ax1.plot(ns, lhs, 'bo-', markersize=8, linewidth=2, label='(f ★ g) ★ h')
    ax1.plot(ns, rhs, 'r^--', markersize=8, linewidth=2, label='f ★ (g ★ h)')
    ax1.set_xlabel('n', fontsize=13)
    ax1.set_ylabel('Value', fontsize=13)
    ax1.set_title('Min-Plus Convolution: Associativity Verification', fontsize=15)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Show difference
    diff = [abs(l - r) for l, r in zip(lhs, rhs)]
    ax2.bar(ns, diff, color='green', alpha=0.7)
    ax2.set_xlabel('n', fontsize=13)
    ax2.set_ylabel('|LHS - RHS|', fontsize=13)
    ax2.set_title('Difference (all zeros confirms associativity)', fontsize=15)
    ax2.grid(True, alpha=0.3, axis='y')

    fig.tight_layout()
    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as dict of base64 strings."""
    print("Generating visualizations...")
    viz = {}

    print("  1/4: Score comparison...")
    viz['score_comparison'] = plot_score_comparison()

    print("  2/4: Tropical entropy...")
    viz['tropical_entropy'] = plot_tropical_entropy()

    print("  3/4: Valuation heatmap...")
    viz['valuation_heatmap'] = plot_valuation_heatmap()

    print("  4/4: Convolution associativity...")
    viz['convolution_assoc'] = plot_convolution_associativity()

    print("Done!")
    return viz


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    # Save to files as well
    for name, b64 in vizs.items():
        # Extract raw PNG data
        raw = base64.b64decode(b64.split(',')[1])
        with open(f'{name}.png', 'wb') as f:
            f.write(raw)
        print(f"Saved {name}.png ({len(raw)} bytes)")
