#!/usr/bin/env python3
"""
applications.py — Applications of Adelic Coordinate Independence

Demonstrates real-world applications of the coordinate independence theorem
for restricted products of finite groups.

Applications:
1. Arithmetic density computations (e.g., square-free integers)
2. Chinese Remainder Theorem as a probabilistic identity
3. Euler product decomposition of multiplicative densities
4. Random number theory: distribution of residues at multiple primes
"""

import math
import random
from fractions import Fraction
from itertools import product as cartesian_product
from collections import Counter
from typing import List, Dict, Set


# ============================================================================
# Application 1: Natural density via local independence
# ============================================================================

def squarefree_density_local(primes: List[int]) -> Fraction:
    """
    Compute the density of square-free integers using local independence.
    
    An integer is square-free iff it is not divisible by p^2 for any prime p.
    The "probability" of not being divisible by p^2 is (1 - 1/p^2).
    By independence of local conditions, the density is:
    
        ∏_p (1 - 1/p^2) → 6/π^2 as we include all primes.
    
    This is the Euler product for 1/ζ(2), and coordinate independence
    is precisely what justifies the product formula.
    
    >>> primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    >>> d = squarefree_density_local(primes)
    >>> abs(float(d) - 6/math.pi**2) < 0.02
    True
    """
    density = Fraction(1, 1)
    for p in primes:
        density *= Fraction(p**2 - 1, p**2)
    return density


def squarefree_density_empirical(N: int) -> Fraction:
    """
    Compute the empirical density of square-free integers up to N.
    
    >>> d = squarefree_density_empirical(10000)
    >>> abs(float(d) - 6/math.pi**2) < 0.01
    True
    """
    count = sum(1 for n in range(1, N + 1) if is_squarefree(n))
    return Fraction(count, N)


def is_squarefree(n: int) -> bool:
    """Check if n is square-free."""
    if n <= 0:
        return False
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        d += 1
    return True


def demo_squarefree():
    """Demonstrate square-free density via local independence."""
    print("=" * 65)
    print("APPLICATION 1: Square-free Density via Local Independence")
    print("=" * 65)
    print()
    print("The density of square-free integers = ∏_p (1 - 1/p²) = 6/π²")
    print("This product formula IS coordinate independence!")
    print()
    
    primes_lists = [
        [2, 3],
        [2, 3, 5],
        [2, 3, 5, 7, 11],
        [2, 3, 5, 7, 11, 13, 17, 19, 23, 29],
        [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47],
    ]
    
    target = 6 / math.pi**2
    print(f"Target: 6/π² ≈ {target:.8f}")
    print()
    
    for primes in primes_lists:
        d = squarefree_density_local(primes)
        err = abs(float(d) - target)
        print(f"  {len(primes):2d} primes → density = {float(d):.8f}  "
              f"(error = {err:.2e})")
    
    # Empirical check
    N = 100000
    emp = squarefree_density_empirical(N)
    print(f"\n  Empirical (N={N}): {float(emp):.8f}")
    print()


# ============================================================================
# Application 2: Chinese Remainder Theorem as Probabilistic Identity
# ============================================================================

def crt_independence_demo():
    """
    The Chinese Remainder Theorem is secretly a statement about independence.
    
    For coprime moduli m₁, m₂, ..., mₖ, the residue of a random integer
    modulo each mᵢ is independent. The CRT isomorphism
    
        Z/(m₁m₂...mₖ)Z ≅ Z/m₁Z × Z/m₂Z × ... × Z/mₖZ
    
    is exactly the statement that the product space equals the joint space.
    """
    print("=" * 65)
    print("APPLICATION 2: Chinese Remainder Theorem as Independence")
    print("=" * 65)
    print()
    
    moduli = [4, 9, 25, 49]  # p^2 for p = 2, 3, 5, 7
    M = math.prod(moduli)
    
    print(f"Moduli: {moduli}")
    print(f"Product M = {M}")
    print()
    
    # Pick random subsets of residues
    random.seed(123)
    num_trials = 500
    successes = 0
    
    for _ in range(num_trials):
        # Random subsets of residues
        subsets = {}
        for m in moduli:
            k = random.randint(1, m)
            subsets[m] = set(random.sample(range(m), k))
        
        # Joint: count n ∈ {0,...,M-1} with n mod mᵢ ∈ subsets[mᵢ] for all i
        joint_count = sum(
            1 for n in range(M)
            if all(n % m in subsets[m] for m in moduli)
        )
        joint_prob = Fraction(joint_count, M)
        
        # Product of marginals
        product_prob = Fraction(1)
        for m in moduli:
            product_prob *= Fraction(len(subsets[m]), m)
        
        if joint_prob == product_prob:
            successes += 1
    
    print(f"Verified CRT independence: {successes}/{num_trials} trials")
    if successes == num_trials:
        print("✓ Perfect agreement — CRT = coordinate independence!")
    print()


# ============================================================================
# Application 3: Euler Product Decomposition
# ============================================================================

def euler_product_demo():
    """
    Euler products as probability factorizations.
    
    For a multiplicative arithmetic function f,
        Σ_{n=1}^∞ f(n)/n^s = ∏_p (Σ_{k=0}^∞ f(p^k)/p^{ks})
    
    The product structure follows from independence of p-adic valuations.
    We demonstrate this with the Euler product for ζ(s) and 1/ζ(s).
    """
    print("=" * 65)
    print("APPLICATION 3: Euler Products as Probability Factorizations")
    print("=" * 65)
    print()
    
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    
    for s in [2, 3, 4]:
        # Euler product for ζ(s)
        euler_prod = 1.0
        for p in primes:
            euler_prod *= 1 / (1 - p**(-s))
        
        # Direct partial sum
        N = 10000
        partial_sum = sum(1.0 / n**s for n in range(1, N + 1))
        
        print(f"ζ({s}): Euler product ({len(primes)} primes) = {euler_prod:.8f}, "
              f"partial sum (N={N}) = {partial_sum:.8f}")
    
    print()
    
    # Euler product for 1/ζ(s) = ∏_p (1 - 1/p^s)
    # This is the probability that a random integer is s-free
    for s in [2, 3]:
        euler_prod = 1.0
        for p in primes:
            euler_prod *= (1 - p**(-s))
        
        # Count s-free numbers
        N = 50000
        count = sum(1 for n in range(1, N + 1) if is_kfree(n, s))
        empirical = count / N
        
        print(f"1/ζ({s}): Euler product = {euler_prod:.8f}, "
              f"empirical ({s}-free, N={N}) = {empirical:.8f}")
    
    print()
    print("The Euler product identity IS the independence of local coordinates!")
    print()


def is_kfree(n: int, k: int) -> bool:
    """Check if n is k-free (not divisible by any p^k)."""
    d = 2
    while d**k <= n:
        if n % d**k == 0:
            return False
        d += 1
    return True


# ============================================================================
# Application 4: Distribution of Residue Patterns
# ============================================================================

def residue_pattern_demo():
    """
    Compute the probability of specific residue patterns at multiple primes.
    
    Example: What fraction of integers are simultaneously:
    - odd (not ≡ 0 mod 2)
    - not divisible by 3
    - ≡ 1 mod 5
    
    By independence: P = (1/2) × (2/3) × (1/5) = 2/30 = 1/15
    """
    print("=" * 65)
    print("APPLICATION 4: Residue Pattern Probabilities")
    print("=" * 65)
    print()
    
    # Pattern: odd AND not div by 3 AND ≡ 1 mod 5
    print("Pattern: odd AND not divisible by 3 AND ≡ 1 (mod 5)")
    
    p_odd = Fraction(1, 2)
    p_not3 = Fraction(2, 3)
    p_1mod5 = Fraction(1, 5)
    
    predicted = p_odd * p_not3 * p_1mod5
    print(f"  Predicted (by independence): {p_odd} × {p_not3} × {p_1mod5} = {predicted}")
    
    # Empirical check
    N = 100000
    count = sum(1 for n in range(1, N + 1)
                if n % 2 != 0 and n % 3 != 0 and n % 5 == 1)
    empirical = Fraction(count, N)
    
    print(f"  Empirical (N={N}): {count}/{N} = {float(empirical):.6f}")
    print(f"  Predicted: {float(predicted):.6f}")
    print()
    
    # More complex pattern
    print("Pattern: ≡ 1 (mod 4) AND ≡ 2 (mod 9) AND coprime to 7")
    
    # Local probabilities
    p_1mod4 = Fraction(1, 4)
    p_2mod9 = Fraction(1, 9)
    p_cop7 = Fraction(6, 7)
    
    predicted = p_1mod4 * p_2mod9 * p_cop7
    print(f"  Predicted: {p_1mod4} × {p_2mod9} × {p_cop7} = {predicted} ≈ {float(predicted):.6f}")
    
    # CRT-based exact count over one period
    M = 4 * 9 * 7  # = 252
    exact_count = sum(1 for n in range(M)
                      if n % 4 == 1 and n % 9 == 2 and math.gcd(n, 7) == 1)
    exact_density = Fraction(exact_count, M)
    print(f"  Exact (mod {M}): {exact_count}/{M} = {float(exact_density):.6f}")
    print(f"  Match: {'✓' if exact_density == predicted else '✗'}")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   Applications of Adelic Coordinate Independence               ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_squarefree()
    crt_independence_demo()
    euler_product_demo()
    residue_pattern_demo()
    
    print("=" * 65)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 65)


#!/usr/bin/env python3
"""
demo.py — Coordinate Independence on the Maximal Compact of Restricted Products

Demonstrates that coordinate projections are independent random variables
on the maximal compact of a restricted product of finite groups.

Uses finite models: G_p = (Z/p^2 Z)* (units mod p^2) for small primes.
"""

import random
import math
from itertools import product as cartesian_product
from fractions import Fraction
from collections import Counter

# --------------------------------------------------------------------------
# Finite group models: units modulo p^2
# --------------------------------------------------------------------------

def units_mod_n(n):
    """Return the set of units modulo n (integers coprime to n in {1,...,n-1})."""
    return [k for k in range(1, n) if math.gcd(k, n) == 1]

def build_local_groups(primes):
    """Build G_p = (Z/p^2 Z)* for each prime p."""
    return {p: units_mod_n(p**2) for p in primes}

# --------------------------------------------------------------------------
# Maximal compact and coordinate events
# --------------------------------------------------------------------------

def maximal_compact(groups):
    """
    The maximal compact: all tuples (x_p)_p with x_p in G_p.
    Returns list of tuples (as dicts prime -> element).
    """
    primes = sorted(groups.keys())
    elements_list = [groups[p] for p in primes]
    result = []
    for combo in cartesian_product(*elements_list):
        result.append(dict(zip(primes, combo)))
    return result

def coord_event(compact, primes_subset, local_sets):
    """
    The finite coordinate event: elements x in compact such that
    x[p] in local_sets[p] for all p in primes_subset.
    """
    return [x for x in compact if all(x[p] in local_sets[p] for p in primes_subset)]

# --------------------------------------------------------------------------
# Demo 1: Independence verification (1000 random trials)
# --------------------------------------------------------------------------

def demo_independence(num_trials=1000):
    """
    For random subsets S of primes and random local subsets A_p ⊆ G_p,
    verify that:
        |{x in compact : x_p in A_p for p in S}| / |compact|
        = prod_{p in S} |A_p| / |G_p|
    """
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    groups = build_local_groups(primes)
    
    # For computational feasibility, use fewer primes at a time
    # (full product over 10 primes would be huge)
    test_primes = [2, 3, 5, 7]  # manageable size
    test_groups = {p: groups[p] for p in test_primes}
    compact = maximal_compact(test_groups)
    compact_size = len(compact)
    
    print("=" * 70)
    print("DEMO 1: Coordinate Independence Verification")
    print("=" * 70)
    print(f"Local groups: G_p = (Z/p^2 Z)* for primes {test_primes}")
    print(f"Group sizes: {[len(test_groups[p]) for p in test_primes]}")
    print(f"Maximal compact size: {compact_size}")
    print(f"Expected: product of local sizes = {math.prod(len(test_groups[p]) for p in test_primes)}")
    print(f"Running {num_trials} random trials...")
    print()
    
    successes = 0
    for trial in range(num_trials):
        # Random subset of primes
        k = random.randint(1, len(test_primes))
        S = random.sample(test_primes, k)
        
        # Random local subsets A_p ⊆ G_p for p in S
        local_sets = {}
        for p in S:
            gp = test_groups[p]
            subset_size = random.randint(1, len(gp))
            local_sets[p] = set(random.sample(gp, subset_size))
        
        # Joint probability by enumeration
        event = coord_event(compact, S, local_sets)
        joint_prob = Fraction(len(event), compact_size)
        
        # Product of marginals
        product_prob = Fraction(1, 1)
        for p in S:
            product_prob *= Fraction(len(local_sets[p]), len(test_groups[p]))
        
        if joint_prob == product_prob:
            successes += 1
        else:
            print(f"  MISMATCH at trial {trial}: S={S}")
            print(f"    joint = {joint_prob}, product = {product_prob}")
    
    print(f"Result: {successes}/{num_trials} trials passed (exact rational equality)")
    if successes == num_trials:
        print("✓ ALL TRIALS PASSED — coordinate independence confirmed!")
    print()

# --------------------------------------------------------------------------
# Demo 2: Marginal distributions
# --------------------------------------------------------------------------

def demo_marginals():
    """
    Verify that the marginal distribution of each coordinate is uniform on G_p.
    """
    primes = [2, 3, 5, 7]
    groups = build_local_groups(primes)
    compact = maximal_compact(groups)
    compact_size = len(compact)
    
    print("=" * 70)
    print("DEMO 2: Marginal Distributions")
    print("=" * 70)
    
    for p in primes:
        gp = groups[p]
        coord_values = [x[p] for x in compact]
        counts = Counter(coord_values)
        expected_count = compact_size // len(gp)
        
        print(f"\nPrime p = {p}, |G_p| = {len(gp)}")
        print(f"  Expected uniform count per element: {expected_count}")
        all_uniform = all(counts[g] == expected_count for g in gp)
        print(f"  Actual counts uniform: {'✓ YES' if all_uniform else '✗ NO'}")
        
        # Show a few elements
        sample = list(gp)[:5]
        for g in sample:
            frac = Fraction(counts[g], compact_size)
            print(f"    P(π_{p} = {g}) = {counts[g]}/{compact_size} = {float(frac):.6f}")

# --------------------------------------------------------------------------
# Demo 3: Pairwise independence and zero covariance
# --------------------------------------------------------------------------

def demo_covariance():
    """
    For distinct primes p ≠ q, compute the covariance of f(π_p) and g(π_q)
    for random functions f, g. Should be exactly 0.
    """
    primes = [2, 3, 5, 7, 11]
    groups = build_local_groups(primes)
    
    # Use 4 primes for feasibility
    test_primes = [2, 3, 5, 7]
    test_groups = {p: groups[p] for p in test_primes}
    compact = maximal_compact(test_groups)
    compact_size = len(compact)
    
    print("=" * 70)
    print("DEMO 3: Zero Covariance Between Distinct Coordinates")
    print("=" * 70)
    print(f"Primes: {test_primes}, compact size: {compact_size}")
    print()
    
    num_trials = 200
    max_cov = Fraction(0)
    
    for trial in range(num_trials):
        # Pick two distinct primes
        p, q = random.sample(test_primes, 2)
        
        # Random real-valued functions
        f_vals = {g: Fraction(random.randint(-10, 10)) for g in test_groups[p]}
        g_vals = {g: Fraction(random.randint(-10, 10)) for g in test_groups[q]}
        
        # Compute expectations and covariance on compact
        E_f = sum(f_vals[x[p]] for x in compact) / compact_size
        E_g = sum(g_vals[x[q]] for x in compact) / compact_size
        E_fg = sum(f_vals[x[p]] * g_vals[x[q]] for x in compact) / compact_size
        
        cov = E_fg - E_f * E_g
        if abs(cov) > max_cov:
            max_cov = abs(cov)
        
        if cov != 0:
            print(f"  NONZERO covariance at trial {trial}: p={p}, q={q}, Cov={cov}")
    
    print(f"Result: max |Cov| over {num_trials} trials = {max_cov}")
    if max_cov == 0:
        print("✓ ALL COVARIANCES EXACTLY ZERO — independence confirmed!")
    print()

# --------------------------------------------------------------------------
# Demo 4: Entropy additivity
# --------------------------------------------------------------------------

def entropy(distribution):
    """Shannon entropy of a probability distribution (dict value -> probability)."""
    h = 0.0
    for p in distribution.values():
        if p > 0:
            h -= p * math.log2(p)
    return h

def demo_entropy():
    """
    Verify H((π_i)_{i∈S}) = Σ_{i∈S} H(π_i) for random subsets S.
    This is equivalent to zero mutual information / independence.
    """
    primes = [2, 3, 5]
    groups = build_local_groups(primes)
    compact = maximal_compact(groups)
    compact_size = len(compact)
    
    print("=" * 70)
    print("DEMO 4: Entropy Additivity (Independence ⟹ H(joint) = Σ H(marginal))")
    print("=" * 70)
    print(f"Primes: {primes}, compact size: {compact_size}")
    print()
    
    for S in [[2], [3], [2, 3], [2, 5], [3, 5], [2, 3, 5]]:
        # Joint distribution over coordinates in S
        joint_counts = Counter()
        for x in compact:
            key = tuple(x[p] for p in S)
            joint_counts[key] += 1
        joint_dist = {k: v / compact_size for k, v in joint_counts.items()}
        H_joint = entropy(joint_dist)
        
        # Sum of marginal entropies
        H_sum = 0.0
        for p in S:
            marginal_counts = Counter(x[p] for x in compact)
            marginal_dist = {k: v / compact_size for k, v in marginal_counts.items()}
            H_sum += entropy(marginal_dist)
        
        diff = abs(H_joint - H_sum)
        status = "✓" if diff < 1e-10 else "✗"
        print(f"  S = {str(S):15s}: H(joint) = {H_joint:.6f}, Σ H(marginal) = {H_sum:.6f}, "
              f"diff = {diff:.2e} {status}")
    
    print()
    print("When coordinates are independent, joint entropy = sum of marginals.")
    print("Any deviation would indicate dependence (mutual information > 0).")

# --------------------------------------------------------------------------
# Demo 5: Product formula for expectations
# --------------------------------------------------------------------------

def demo_expectation_factorization():
    """
    Verify E[∏_{i∈S} f_i(π_i)] = ∏_{i∈S} E[f_i(π_i)] for random functions.
    """
    primes = [2, 3, 5, 7]
    groups = build_local_groups(primes)
    compact = maximal_compact(groups)
    compact_size = len(compact)
    
    print("=" * 70)
    print("DEMO 5: Expectation Factorization")
    print("=" * 70)
    print(f"E[∏ f_i(π_i)] = ∏ E[f_i(π_i)] for independent coordinates")
    print()
    
    num_trials = 500
    successes = 0
    
    for trial in range(num_trials):
        k = random.randint(1, len(primes))
        S = random.sample(primes, k)
        
        # Random functions f_p : G_p -> Q
        funcs = {}
        for p in S:
            funcs[p] = {g: Fraction(random.randint(-5, 5)) for g in groups[p]}
        
        # Joint expectation
        E_product = sum(
            math.prod(funcs[p][x[p]] for p in S)
            for x in compact
        ) / compact_size
        
        # Product of marginal expectations
        prod_E = Fraction(1)
        for p in S:
            E_f = sum(funcs[p][x[p]] for x in compact) / compact_size
            prod_E *= E_f
        
        if E_product == prod_E:
            successes += 1
    
    print(f"Result: {successes}/{num_trials} trials passed (exact rational equality)")
    if successes == num_trials:
        print("✓ ALL TRIALS PASSED — expectation factorization confirmed!")
    print()

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║   Adelic Coordinate Independence — Computational Demonstration     ║")
    print("║                                                                     ║")
    print("║   'A random integral adele has independent local coordinates'       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    random.seed(42)
    
    demo_independence(num_trials=1000)
    demo_marginals()
    demo_covariance()
    demo_entropy()
    demo_expectation_factorization()
    
    print("=" * 70)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 70)
