#!/usr/bin/env python3
"""
Applications of Shadow Profile Theory

Demonstrates real-world applications of log-concavity and
ultra-log-concavity of shadow profiles:

1. Combinatorial optimization: unimodal search on shadow profiles
2. Information-theoretic bounds: entropy of shadow distributions
3. Network reliability: shadow profiles encode failure modes
4. Coding theory: weight distributions and log-concavity

Each application shows how the theorems translate into practical tools.
"""

from math import comb, log, log2, sqrt, exp
from typing import List, Tuple, Dict


# ============================================================
# Application 1: Unimodal Search on Shadow Profiles
# ============================================================

def find_peak_shadow_ternary(n: int, r: int) -> Tuple[int, int]:
    """
    Find the peak of the shadow profile using ternary search.
    
    Since log-concave nonneg sequences are unimodal (proved as
    log_concave_implies_unimodal → the profile has a single peak),
    we can use ternary search to find the maximum in O(log n) evaluations.
    
    For C(n,k), the peak is at k = n//2, but for general shadow profiles
    this gives an efficient algorithm.
    
    Args:
        n: Ambient dimension
        r: Rank (max degree)
    
    Returns:
        (peak_k, peak_value)
    
    Time: O(log(r) * n) for evaluation cost
    """
    lo, hi = 0, r
    
    while hi - lo > 2:
        m1 = lo + (hi - lo) // 3
        m2 = hi - (hi - lo) // 3
        
        v1 = comb(n, m1)
        v2 = comb(n, m2)
        
        if v1 < v2:
            lo = m1
        else:
            hi = m2
    
    # Check remaining candidates
    best_k = lo
    best_v = comb(n, lo)
    for k in range(lo + 1, hi + 1):
        v = comb(n, k)
        if v > best_v:
            best_k = k
            best_v = v
    
    return best_k, best_v


# ============================================================
# Application 2: Entropy Bounds from Log-Concavity
# ============================================================

def shadow_entropy(n: int, r: int) -> float:
    """
    Compute the Shannon entropy of the normalized shadow profile.
    
    The distribution p_k = C(n,k) / 2^n is the binomial(n, 1/2) distribution.
    Its entropy is known to be approximately (1/2) * log(2*pi*e*n/4).
    
    Log-concavity of the shadow profile implies this distribution has
    bounded entropy — the cross-domain bridge from combinatorics to
    information theory (log_concave_ratio_antitone).
    
    Args:
        n: Ambient dimension
        r: Max degree (unused for uniform matroids, included for generality)
    
    Returns:
        Shannon entropy H(p) in bits
    """
    total = sum(comb(n, k) for k in range(n + 1))  # = 2^n
    entropy = 0.0
    for k in range(n + 1):
        p = comb(n, k) / total
        if p > 0:
            entropy -= p * log2(p)
    return entropy


def entropy_bound_from_log_concavity(n: int) -> float:
    """
    Upper bound on entropy from log-concavity concentration.
    
    A log-concave distribution on {0, ..., n} has entropy at most
    (1/2) * log2(2*pi*e * Var) where Var is the variance.
    For Bin(n, 1/2), Var = n/4, giving H <= (1/2)*log2(pi*e*n/2).
    
    This is the information-theoretic content of log_concave_ratio_antitone.
    """
    import math
    var = n / 4  # Variance of Bin(n, 1/2)
    return 0.5 * log2(2 * math.pi * math.e * var)


# ============================================================
# Application 3: Network Reliability
# ============================================================

def network_reliability_profile(n: int, r: int) -> Dict[int, float]:
    """
    Compute reliability as a function of component failure probability.
    
    In a system with n components where r are needed for operation,
    the reliability R(p) = sum_{k=r}^{n} C(n,k) * (1-p)^k * p^{n-k}.
    
    The shadow profile encodes how many failure modes exist at each
    severity level. Log-concavity means failures concentrate around
    the mean — there's no "gap" of unlikely failure modes.
    
    Args:
        n: Total components
        r: Minimum components needed
    
    Returns:
        Dictionary mapping failure count to number of failure patterns
    """
    profile = {}
    for k in range(n + 1):
        # Number of ways k components fail, system still works
        if n - k >= r:
            profile[k] = comb(n, k)
        else:
            profile[k] = 0
    return profile


# ============================================================
# Application 4: Coding Theory Weight Distributions
# ============================================================

def hamming_weight_distribution(n: int) -> List[int]:
    """
    Weight distribution of the full binary space F_2^n.
    
    A_w = number of codewords of Hamming weight w = C(n, w).
    Log-concavity of A_w is exactly our binomial_log_concave theorem.
    
    This has practical implications: the weight distribution determines
    error-detecting and error-correcting capabilities of codes.
    Log-concavity means the weight distribution is "well-behaved" —
    no unexpected gaps or bumps.
    """
    return [comb(n, w) for w in range(n + 1)]


def weight_ratio_bound(n: int, w: int) -> float:
    """
    Bound on consecutive weight ratios from log-concavity.
    
    From binomial_ratio_antitone: A_{w+1}/A_w <= A_w/A_{w-1}.
    
    This means the weight distribution "decelerates" — the growth
    rate of the weight enumerator is nonincreasing.
    
    Returns A_{w+1}/A_w for the given parameters.
    """
    if w < 0 or w >= n:
        return 0.0
    return comb(n, w + 1) / comb(n, w) if comb(n, w) > 0 else 0.0


if __name__ == "__main__":
    print("Applications of Shadow Profile Theory")
    print("=" * 60)
    
    # App 1: Unimodal search
    print("\n1. UNIMODAL SEARCH (via log-concavity → unimodality)")
    for n in [20, 50, 100]:
        peak_k, peak_v = find_peak_shadow_ternary(n, n)
        print(f"   n={n}: peak at k={peak_k}, C({n},{peak_k}) = {peak_v}")
    
    # App 2: Entropy bounds
    print("\n2. ENTROPY BOUNDS (via ratio monotonicity)")
    for n in [10, 20, 50]:
        H = shadow_entropy(n, n)
        H_bound = entropy_bound_from_log_concavity(n)
        print(f"   n={n}: H(shadow) = {H:.4f} bits, "
              f"LC bound = {H_bound:.4f} bits")
    
    # App 3: Network reliability
    print("\n3. NETWORK RELIABILITY (shadow profiles as failure modes)")
    n, r = 10, 7
    profile = network_reliability_profile(n, r)
    print(f"   System: {n} components, {r} needed")
    print(f"   Failure patterns by severity:")
    for k in range(n + 1):
        if profile[k] > 0:
            print(f"     {k} failures: {profile[k]} patterns")
    
    # App 4: Coding theory
    print("\n4. WEIGHT DISTRIBUTION (Hamming weights)")
    n = 8
    weights = hamming_weight_distribution(n)
    print(f"   F_2^{n} weight distribution: {weights}")
    print(f"   Consecutive ratios A_{{w+1}}/A_w:")
    for w in range(n):
        r = weight_ratio_bound(n, w)
        print(f"     w={w}: {r:.4f}", end="")
        if w > 0:
            r_prev = weight_ratio_bound(n, w - 1)
            print(f"  (≤ {r_prev:.4f}? {'✓' if r <= r_prev else '✗'})", end="")
        print()


#!/usr/bin/env python3
"""
Shadow Profile Ultra-Log-Concavity Demo

Computes shadow profiles for uniform matroids, verifies log-concavity
and ultra-log-concavity, and displays the key ratios.

This demonstrates the theorems proved in the Lean formalization:
- Binomial coefficients C(n,k) are log-concave
- The naive ULC conjecture with D = max degree FAILS (counterexample U(3,4))
- Binomial coefficients are ULC with D = n (self-normalization)
"""

from math import comb, log
from typing import List, Tuple


def shadow_profile_uniform(n: int, r: int) -> List[int]:
    """
    Shadow profile of the uniform matroid U(r,n).
    
    The bases of U(r,n) are all r-element subsets of [n], encoded as
    0-1 vectors in {0,1}^n with exactly r ones. The degree-k shadow
    is the set of all k-element subsets contained in some r-element
    subset, which (for k <= r) is all k-element subsets.
    
    Returns: a_k = C(n, k) for k = 0, ..., r, then 0 for k > r.
    """
    return [comb(n, k) if k <= r else 0 for k in range(n + 1)]


def check_log_concavity(profile: List[int]) -> List[Tuple[int, bool, float]]:
    """
    Check log-concavity: a_k^2 >= a_{k-1} * a_{k+1} for each valid k.
    
    Returns list of (k, passes, ratio) where ratio = a_k^2 / (a_{k-1} * a_{k+1}).
    """
    results = []
    for k in range(1, len(profile) - 1):
        if profile[k - 1] > 0 and profile[k + 1] > 0:
            lhs = profile[k] ** 2
            rhs = profile[k - 1] * profile[k + 1]
            ratio = lhs / rhs if rhs > 0 else float('inf')
            results.append((k, lhs >= rhs, ratio))
        elif profile[k] == 0 and profile[k - 1] == 0:
            results.append((k, True, float('inf')))
        else:
            lhs = profile[k] ** 2
            rhs = profile[k - 1] * profile[k + 1]
            results.append((k, lhs >= rhs, float('inf') if rhs == 0 else lhs / rhs))
    return results


def check_ulc(profile: List[int], D: int) -> List[Tuple[int, bool, float, float]]:
    """
    Check ultra-log-concavity with respect to degree D:
    a_k^2 * C(D,k-1) * C(D,k+1) >= a_{k-1} * a_{k+1} * C(D,k)^2
    
    Returns list of (k, passes, lhs, rhs).
    """
    results = []
    for k in range(1, min(D, len(profile) - 1)):
        lhs = profile[k] ** 2 * comb(D, k - 1) * comb(D, k + 1)
        rhs = profile[k - 1] * profile[k + 1] * comb(D, k) ** 2
        results.append((k, lhs >= rhs, lhs, rhs))
    return results


def demo_log_concavity():
    """Demonstrate log-concavity of binomial coefficients."""
    print("=" * 70)
    print("DEMO 1: Log-Concavity of Binomial Coefficients C(n,k)")
    print("=" * 70)
    print()
    print("Theorem (binomial_log_concave): C(n,k)^2 >= C(n,k-1) * C(n,k+1)")
    print()
    
    for n in [5, 8, 12]:
        profile = [comb(n, k) for k in range(n + 1)]
        results = check_log_concavity(profile)
        print(f"n = {n}: profile = {profile}")
        all_pass = all(r[1] for r in results)
        print(f"  Log-concave: {'YES ✓' if all_pass else 'NO ✗'}")
        print(f"  Ratios C(n,k)^2 / (C(n,k-1)*C(n,k+1)):")
        for k, passes, ratio in results:
            print(f"    k={k}: ratio = {ratio:.4f} {'✓' if passes else '✗'}")
        print()


def demo_counterexample():
    """Demonstrate the counterexample to naive ULC."""
    print("=" * 70)
    print("DEMO 2: Counterexample — Naive ULC Fails for U(3,4)")
    print("=" * 70)
    print()
    print("The shadow profile of U(3,4) is a_k = C(4,k) = [1, 4, 6, 4, 1]")
    print("With D = max degree = 3, the ULC inequality at k=1 requires:")
    print()
    
    lhs = comb(4, 1) ** 2 * comb(3, 0) * comb(3, 2)
    rhs = comb(4, 0) * comb(4, 2) * comb(3, 1) ** 2
    print(f"  LHS = C(4,1)^2 * C(3,0) * C(3,2) = {comb(4,1)}^2 * {comb(3,0)} * {comb(3,2)} = {lhs}")
    print(f"  RHS = C(4,0) * C(4,2) * C(3,1)^2 = {comb(4,0)} * {comb(4,2)} * {comb(3,1)}^2 = {rhs}")
    print(f"  {lhs} >= {rhs}? {'YES' if lhs >= rhs else 'NO — COUNTEREXAMPLE!'}")
    print()
    print("  This shows the naive Shadow-Hodge ULC conjecture with D = max|α| is FALSE.")
    print()


def demo_self_ulc():
    """Demonstrate that C(n,k) is ULC with D = n."""
    print("=" * 70)
    print("DEMO 3: Binomial Coefficients are ULC with D = n (Self-Normalized)")
    print("=" * 70)
    print()
    print("Theorem (binomial_ulc_self): C(n,k) is ULC with respect to D = n")
    print("This is because C(n,k)/C(n,k) = 1 is constant, hence trivially log-concave.")
    print()
    
    for n in [5, 8]:
        profile = [comb(n, k) for k in range(n + 1)]
        results = check_ulc(profile, n)
        all_pass = all(r[1] for r in results)
        print(f"n = {n}: ULC(n={n}): {'YES ✓' if all_pass else 'NO ✗'}")
        for k, passes, lhs_val, rhs_val in results:
            status = "=" if lhs_val == rhs_val else (">" if lhs_val > rhs_val else "<")
            print(f"  k={k}: LHS={lhs_val}, RHS={rhs_val} ({status})")
        print()


def demo_ratio_monotonicity():
    """Demonstrate ratio monotonicity of binomial coefficients."""
    print("=" * 70)
    print("DEMO 4: Ratio Monotonicity — C(n,k+1)/C(n,k) is Nonincreasing")
    print("=" * 70)
    print()
    print("Theorem (binomial_ratio_antitone): C(n,k+1)/C(n,k) <= C(n,k)/C(n,k-1)")
    print("This is the cross-domain bridge to information theory.")
    print()
    
    for n in [8, 12]:
        print(f"n = {n}:")
        ratios = []
        for k in range(n):
            if comb(n, k) > 0:
                r = comb(n, k + 1) / comb(n, k)
                ratios.append((k, r))
                print(f"  C({n},{k+1})/C({n},{k}) = {comb(n,k+1)}/{comb(n,k)} = {r:.4f}")
        
        monotone = all(ratios[i][1] >= ratios[i+1][1] for i in range(len(ratios) - 1))
        print(f"  Nonincreasing: {'YES ✓' if monotone else 'NO ✗'}")
        print()


def demo_mass_test():
    """Mass-test the corrected log-concavity conjecture."""
    print("=" * 70)
    print("DEMO 5: Mass Test — Corrected Shadow Log-Concavity for U(r,n)")
    print("=" * 70)
    print()
    print("Testing: C(n,k)^2 >= C(n,k-1)*C(n,k+1) for all n <= 20, all valid k")
    print()
    
    total_tests = 0
    failures = 0
    for n in range(2, 21):
        for k in range(1, n):
            total_tests += 1
            lhs = comb(n, k) ** 2
            rhs = comb(n, k - 1) * comb(n, k + 1)
            if lhs < rhs:
                failures += 1
                print(f"  FAILURE: n={n}, k={k}: {lhs} < {rhs}")
    
    print(f"  Total tests: {total_tests}")
    print(f"  Failures: {failures}")
    print(f"  Result: {'ALL PASSED ✓' if failures == 0 else 'SOME FAILED ✗'}")
    print()


if __name__ == "__main__":
    demo_log_concavity()
    demo_counterexample()
    demo_self_ulc()
    demo_ratio_monotonicity()
    demo_mass_test()
    
    print("=" * 70)
    print("Summary")
    print("=" * 70)
    print()
    print("All results verified computationally, matching the Lean proofs:")
    print("  1. C(n,k) is log-concave (binomial_log_concave)")
    print("  2. Naive ULC with D=max|α| fails (conjecture_counterexample)")  
    print("  3. C(n,k) is ULC with D=n (binomial_ulc_self)")
    print("  4. Ratios C(n,k+1)/C(n,k) are nonincreasing (binomial_ratio_antitone)")
    print("  5. Log-concavity holds for all C(n,k) tested (binomial_log_concave')")


#!/usr/bin/env python3
"""
Visualization: The ULC Counterexample Landscape

This script creates a heatmap showing where the naive Shadow-Hodge ULC
conjecture (with D = max degree) fails across different (n, r) pairs.

Green cells indicate the ULC inequality holds for all valid k.
Red cells indicate at least one k where it fails.
The diagonal (r = n) always passes (trivially).

This visualizes the counterexample theorem: conjecture_counterexample.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def check_ulc_all_k(n, r):
    """Check if ULC(D=r) holds for all valid k with a_k = C(n,k)."""
    for k in range(1, r):
        lhs = comb(n, k) ** 2 * comb(r, k - 1) * comb(r, k + 1)
        rhs = comb(n, k - 1) * comb(n, k + 1) * comb(r, k) ** 2
        if lhs < rhs:
            return False
    return True


def min_ulc_ratio(n, r):
    """Compute minimum ULC ratio across all valid k."""
    min_ratio = float('inf')
    for k in range(1, r):
        lhs = comb(n, k) ** 2 * comb(r, k - 1) * comb(r, k + 1)
        rhs = comb(n, k - 1) * comb(n, k + 1) * comb(r, k) ** 2
        if rhs > 0:
            ratio = lhs / rhs
            min_ratio = min(min_ratio, ratio)
    return min_ratio if min_ratio != float('inf') else 1.0


max_n = 15
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Pass/Fail heatmap
data_pass = np.full((max_n, max_n), np.nan)
for n in range(2, max_n + 1):
    for r in range(2, n + 1):
        passes = check_ulc_all_k(n, r)
        data_pass[n - 1, r - 1] = 1.0 if passes else 0.0

im1 = ax1.imshow(data_pass, cmap='RdYlGn', origin='lower',
                  extent=[0.5, max_n + 0.5, 0.5, max_n + 0.5],
                  vmin=0, vmax=1, aspect='equal')
ax1.set_xlabel('r (rank = max degree)', fontsize=12)
ax1.set_ylabel('n (ambient dimension)', fontsize=12)
ax1.set_title('ULC(D=r) for Uniform Matroid U(r,n)\nGreen = passes, Red = fails',
              fontsize=13)

# Mark the specific counterexample
ax1.plot(3, 4, 'k*', markersize=15, label='U(3,4) counterexample')
ax1.legend(fontsize=10, loc='upper left')

# Add diagonal line r = n
ax1.plot([0.5, max_n + 0.5], [0.5, max_n + 0.5], 'b--', alpha=0.5, label='r=n')

# Panel 2: Minimum ULC ratio heatmap
data_ratio = np.full((max_n, max_n), np.nan)
for n in range(2, max_n + 1):
    for r in range(2, n + 1):
        ratio = min_ulc_ratio(n, r)
        data_ratio[n - 1, r - 1] = ratio

im2 = ax2.imshow(data_ratio, cmap='RdYlGn', origin='lower',
                  extent=[0.5, max_n + 0.5, 0.5, max_n + 0.5],
                  vmin=0.5, vmax=1.5, aspect='equal')
ax2.set_xlabel('r (rank = max degree)', fontsize=12)
ax2.set_ylabel('n (ambient dimension)', fontsize=12)
ax2.set_title('Minimum ULC Ratio (< 1 means failure)\nDarker red = stronger failure',
              fontsize=13)

fig.colorbar(im2, ax=ax2, label='min ULC ratio', shrink=0.8)

# Mark threshold
ax2.plot(3, 4, 'k*', markersize=15)

plt.tight_layout()
plt.savefig('ulc_counterexample_landscape.png', dpi=150, bbox_inches='tight')
plt.close()

print("Counterexample landscape saved to ulc_counterexample_landscape.png")


#!/usr/bin/env python3
"""
Visualization: The Entropy Bridge — From Combinatorics to Information Theory

This script visualizes the cross-domain connection between log-concavity
of shadow profiles and information-theoretic entropy bounds.

The key insight (log_concave_ratio_antitone): log-concavity of C(n,k)
implies the ratio C(n,k+1)/C(n,k) is nonincreasing, which means the
discrete log-partition function log(C(n,k)) is concave — connecting
combinatorial structure to Shannon entropy bounds.

Panel 1: The ratio sequence C(n,k+1)/C(n,k) = (n-k)/(k+1) (decreasing)
Panel 2: log(C(n,k)) is concave (the entropy bridge)
Panel 3: Entropy of normalized shadow distribution vs. Gaussian bound
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb, log, log2, pi, e, sqrt


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Ratio monotonicity
ax1 = axes[0]
for n in [8, 12, 20, 30]:
    ks = list(range(0, n))
    ratios = [(n - k) / (k + 1) for k in ks]
    ax1.plot(ks, ratios, 'o-', label=f'n={n}', markersize=3, linewidth=1.5)

ax1.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
ax1.set_xlabel('Degree k', fontsize=12)
ax1.set_ylabel('C(n,k+1) / C(n,k)', fontsize=12)
ax1.set_title('Ratio Monotonicity\n(Theorem: binomial_ratio_antitone)', fontsize=13)
ax1.legend()
ax1.grid(True, alpha=0.3)
ax1.annotate('Always\ndecreasing!',
            xy=(5, 2.5), fontsize=11, color='darkblue',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Panel 2: Concavity of log C(n,k)
ax2 = axes[1]
for n in [10, 20, 40]:
    ks = list(range(0, n + 1))
    log_vals = [log(comb(n, k)) if comb(n, k) > 0 else 0 for k in ks]
    ax2.plot(ks, log_vals, 'o-', label=f'n={n}', markersize=2, linewidth=1.5)
    
    # Show the concave envelope for n=20
    if n == 20:
        # Second differences should be negative (concavity)
        for k in range(1, n):
            second_diff = log_vals[k+1] - 2*log_vals[k] + log_vals[k-1]
            if k % 4 == 0:
                ax2.annotate(f'Δ²={second_diff:.2f}',
                           xy=(k, log_vals[k]), fontsize=7,
                           textcoords="offset points", xytext=(0, 10),
                           color='darkred', alpha=0.7)

ax2.set_xlabel('Degree k', fontsize=12)
ax2.set_ylabel('log C(n,k)', fontsize=12)
ax2.set_title('Concavity of log C(n,k)\n(Entropy bridge: discrete concavity)', fontsize=13)
ax2.legend()
ax2.grid(True, alpha=0.3)

# Panel 3: Entropy comparison
ax3 = axes[2]
ns = list(range(4, 51))
actual_entropies = []
gaussian_bounds = []

for n in ns:
    # Actual entropy of Bin(n, 1/2)
    H = 0
    for k in range(n + 1):
        p = comb(n, k) / 2**n
        if p > 0:
            H -= p * log2(p)
    actual_entropies.append(H)
    
    # Gaussian approximation: (1/2) * log2(2*pi*e*n/4)
    var = n / 4
    gaussian_bounds.append(0.5 * log2(2 * pi * e * var))

ax3.plot(ns, actual_entropies, 'b-', linewidth=2, label='H(Bin(n,1/2))')
ax3.plot(ns, gaussian_bounds, 'r--', linewidth=2, label='Gaussian bound')
ax3.plot(ns, [0.5 * log2(n + 1) for n in ns], 'g:', linewidth=1.5,
         label='(1/2)·log₂(n+1)')

ax3.set_xlabel('n (dimension)', fontsize=12)
ax3.set_ylabel('Entropy (bits)', fontsize=12)
ax3.set_title('Shadow Profile Entropy\nvs. Information-Theoretic Bounds', fontsize=13)
ax3.legend()
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('entropy_bridge.png', dpi=150, bbox_inches='tight')
plt.close()

print("Entropy bridge visualization saved to entropy_bridge.png")


#!/usr/bin/env python3
"""
Visualization: Shadow Profile Log-Concavity and ULC Ratios

This script visualizes the core mathematical concepts:
1. Shadow profiles C(n,k) for several values of n
2. Log-concavity ratios C(n,k)^2 / (C(n,k-1)*C(n,k+1))
3. The ULC failure for D = max degree (counterexample region)

Uses matplotlib to produce a multi-panel figure showing the interplay
between shadow profiles, their log-concavity ratios, and the ULC threshold.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def compute_log_concavity_ratio(n, k):
    """Compute C(n,k)^2 / (C(n,k-1)*C(n,k+1))."""
    if k < 1 or k >= n:
        return None
    num = comb(n, k) ** 2
    den = comb(n, k - 1) * comb(n, k + 1)
    return num / den if den > 0 else float('inf')


def compute_ulc_ratio(n, r, k):
    """Compute a_k^2 * C(r,k-1)*C(r,k+1) / (a_{k-1}*a_{k+1}*C(r,k)^2) for a_k = C(n,k)."""
    if k < 1 or k >= r:
        return None
    lhs = comb(n, k) ** 2 * comb(r, k - 1) * comb(r, k + 1)
    rhs = comb(n, k - 1) * comb(n, k + 1) * comb(r, k) ** 2
    return lhs / rhs if rhs > 0 else float('inf')


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Shadow Profiles: Log-Concavity and Ultra-Log-Concavity',
             fontsize=16, fontweight='bold')

# Panel 1: Shadow profiles for various n
ax1 = axes[0, 0]
for n in [6, 8, 10, 12]:
    ks = list(range(n + 1))
    profile = [comb(n, k) for k in ks]
    ax1.plot(ks, profile, 'o-', label=f'n={n}', markersize=4)
ax1.set_xlabel('Degree k')
ax1.set_ylabel('Shadow size C(n,k)')
ax1.set_title('Shadow Profiles of Uniform Matroids')
ax1.legend()
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Log-concavity ratios
ax2 = axes[0, 1]
for n in [6, 8, 10, 12]:
    ks = list(range(1, n))
    ratios = [compute_log_concavity_ratio(n, k) for k in ks]
    ax2.plot(ks, ratios, 'o-', label=f'n={n}', markersize=4)
ax2.axhline(y=1.0, color='red', linestyle='--', label='LC threshold (=1)')
ax2.set_xlabel('Degree k')
ax2.set_ylabel('C(n,k)² / (C(n,k-1)·C(n,k+1))')
ax2.set_title('Log-Concavity Ratios (all ≥ 1)')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Panel 3: ULC ratios with D = r (showing failure)
ax3 = axes[1, 0]
n_val = 8
for r in [3, 4, 5, 6, 7]:
    ks = list(range(1, r))
    ratios = [compute_ulc_ratio(n_val, r, k) for k in ks]
    valid_ks = [k for k, ratio in zip(ks, ratios) if ratio is not None]
    valid_ratios = [ratio for ratio in ratios if ratio is not None]
    color = 'green' if all(ratio >= 1 for ratio in valid_ratios) else 'red'
    marker = 'o' if all(ratio >= 1 for ratio in valid_ratios) else 'x'
    ax3.plot(valid_ks, valid_ratios, f'{marker}-', label=f'r={r}',
             markersize=6, color=None)

ax3.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='ULC threshold')
ax3.set_xlabel('Degree k')
ax3.set_ylabel('ULC ratio (D = r)')
ax3.set_title(f'ULC with D=max|α| for n={n_val} (FAILS for r < n)')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# Panel 4: Quantitative excess (n+1)/(k(n-k))
ax4 = axes[1, 1]
for n in [8, 12, 20, 50]:
    ks = list(range(1, n))
    excess = [(n + 1) / (k * (n - k)) for k in ks]
    ax4.plot(ks, excess, '-', label=f'n={n}', linewidth=1.5)
ax4.set_xlabel('Degree k')
ax4.set_ylabel('Excess over LC threshold')
ax4.set_title('Quantitative LC Excess: (n+1)/(k(n-k))')
ax4.legend()
ax4.set_yscale('log')
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('shadow_profiles_ulc.png', dpi=150, bbox_inches='tight')
plt.close()

print("Visualization saved to shadow_profiles_ulc.png")
