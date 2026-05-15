#!/usr/bin/env python3
"""
Tropical Sieve Theory: Applications

Demonstrates real-world applications of the tropical sieve comparison theorems:
1. Cryptographic sieve pre-filtering for smoothness testing
2. Twin-prime candidate screening
3. Prime constellation search
"""

import numpy as np
from typing import List, Tuple
from sympy import isprime, factorint, primerange


# ============================================================
# Application 1: Cryptographic Smoothness Pre-filtering
# ============================================================

def smoothness_cost(n: int, factor_base: List[int]) -> float:
    """
    Classical smoothness cost: sum of p-adic valuations at primes outside factor base.
    Cost = 0 iff n is smooth with respect to factor_base.
    """
    if n <= 0:
        return float('inf')
    cost = 0.0
    temp = n
    for p in factor_base:
        while temp % p == 0:
            temp //= p
    # Remaining part is the "unsmooth" residual
    if temp > 1:
        cost = np.log(temp)
    return cost


def tropical_smoothness_prefilter(
    candidates: List[int],
    factor_base: List[int],
    threshold: float = 0.0
) -> Tuple[List[int], List[int]]:
    """
    Two-phase smoothness detection for quadratic sieve.

    Phase 1 (tropical): Quick check using min of residue costs.
    Phase 2 (classical): Full smoothness test on survivors.

    Returns (smooth_numbers, prefilter_survivors).
    """
    # Phase 1: Tropical pre-filter
    # A number is B-smooth iff ALL its prime factors are in the factor base.
    # Tropical score: min over factor base primes of (n mod p)
    # If tropical score > 0 for all p, n might not be smooth.
    prefilter_survivors = []
    for n in candidates:
        # Simple tropical heuristic: if n mod p = 0 for some p in base,
        # n has that factor, which is a positive signal.
        min_residue = min(abs(n % p) for p in factor_base) if factor_base else n
        if min_residue <= threshold:
            prefilter_survivors.append(n)

    # Phase 2: Full smoothness test
    smooth = [n for n in prefilter_survivors if smoothness_cost(n, factor_base) == 0.0]

    return smooth, prefilter_survivors


def demo_smoothness():
    """Demonstrate tropical pre-filtering for smoothness detection."""
    print("=" * 60)
    print("APPLICATION 1: Cryptographic Smoothness Pre-filtering")
    print("=" * 60)

    factor_base = list(primerange(2, 30))
    print(f"Factor base: {factor_base}")

    # Generate QS-style candidates: x² - N for some N
    N = 10007  # A semiprime-like number
    candidates = [x * x - N for x in range(101, 201) if x * x > N]

    smooth, prefiltered = tropical_smoothness_prefilter(
        candidates, factor_base, threshold=0
    )

    total = len(candidates)
    print(f"\nCandidates (x² - {N} for x in [101, 200]): {total}")
    print(f"Pre-filter survivors: {len(prefiltered)} ({100*len(prefiltered)/total:.1f}%)")
    print(f"Truly smooth: {len(smooth)} ({100*len(smooth)/total:.1f}%)")
    if prefiltered:
        print(f"Pre-filter elimination rate: {100*(total-len(prefiltered))/total:.1f}%")


# ============================================================
# Application 2: Twin-Prime Candidate Screening
# ============================================================

def screen_twin_candidates(X: int, sieve_primes: List[int]) -> Tuple[List[int], List[int]]:
    """
    Screen for twin-prime candidates using tropical pair-pattern scoring.

    Returns (actual_twins, tropical_candidates).
    """
    # Tropical pair-pattern: for each prime p, check if the pair (n, n+2)
    # avoids the "bad" residue class 0 mod p.
    def pair_survives(n: int) -> bool:
        for p in sieve_primes:
            if n % p != 0 and (n + 2) % p != 0:
                return True  # At least one prime doesn't eliminate either
        return False

    # More precise: the tropical version checks min over p of max(cost(n%p), cost((n+2)%p))
    def tropical_pair_score(n: int) -> float:
        c = lambda r: 0.0 if r != 0 else 1.0
        if not sieve_primes:
            return 0.0
        return min(max(c(n % p), c((n + 2) % p)) for p in sieve_primes)

    tropical_candidates = [n for n in range(2, X + 1) if tropical_pair_score(n) == 0.0]
    actual_twins = [n for n in range(2, X + 1) if isprime(n) and isprime(n + 2)]

    return actual_twins, tropical_candidates


def demo_twin_screening():
    """Demonstrate twin-prime candidate screening."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Twin-Prime Candidate Screening")
    print("=" * 60)

    sieve_primes = [3, 5, 7, 11, 13]
    print(f"Sieve primes: {sieve_primes}")

    for X in [100, 1000, 10000]:
        twins, candidates = screen_twin_candidates(X, sieve_primes)
        print(f"\nX = {X}:")
        print(f"  Tropical candidates: {len(candidates)}")
        print(f"  Actual twin primes: {len(twins)}")
        if candidates:
            precision = len(twins) / len(candidates) * 100
            print(f"  Precision: {precision:.1f}%")
        if twins:
            recall = len([t for t in twins if t in candidates]) / len(twins) * 100
            print(f"  Recall: {recall:.1f}%")


# ============================================================
# Application 3: Prime Constellation Search
# ============================================================

def constellation_score(
    n: int,
    pattern: List[int],
    sieve_primes: List[int]
) -> float:
    """
    Tropical score for a prime constellation pattern.

    pattern = [0, h1, h2, ...] means we're looking for
    (n, n+h1, n+h2, ...) all prime.

    Score = min over sieve primes p of max over shifts h of cost((n+h) mod p).
    """
    c = lambda r: 0.0 if r != 0 else 1.0
    if not sieve_primes:
        return 0.0
    return min(
        max(c((n + h) % p) for h in pattern)
        for p in sieve_primes
    )


def search_constellation(
    X: int,
    pattern: List[int],
    sieve_primes: List[int]
) -> Tuple[List[int], List[int]]:
    """
    Search for prime constellations up to X using tropical scoring.

    Returns (verified_constellations, tropical_candidates).
    """
    candidates = [
        n for n in range(2, X + 1)
        if constellation_score(n, pattern, sieve_primes) == 0.0
    ]

    verified = [
        n for n in candidates
        if all(isprime(n + h) for h in pattern)
    ]

    return verified, candidates


def demo_constellations():
    """Demonstrate prime constellation search."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Prime Constellation Search")
    print("=" * 60)

    patterns = {
        "Twin primes (p, p+2)": [0, 2],
        "Cousin primes (p, p+4)": [0, 4],
        "Sexy primes (p, p+6)": [0, 6],
        "Prime triplet (p, p+2, p+6)": [0, 2, 6],
        "Prime quadruplet (p, p+2, p+6, p+8)": [0, 2, 6, 8],
    }

    sieve_primes = [3, 5, 7, 11, 13]
    X = 10000

    print(f"Search range: [2, {X}]")
    print(f"Sieve primes: {sieve_primes}")

    for name, pattern in patterns.items():
        verified, candidates = search_constellation(X, pattern, sieve_primes)
        print(f"\n{name}:")
        print(f"  Pattern: {pattern}")
        print(f"  Tropical candidates: {len(candidates)}")
        print(f"  Verified constellations: {len(verified)}")
        if verified[:5]:
            print(f"  First few: {verified[:5]}")


if __name__ == "__main__":
    demo_smoothness()
    demo_twin_screening()
    demo_constellations()

    print("\n" + "=" * 60)
    print("All applications demonstrated.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Sieve Theory: Demonstration of Core Theorems

This module provides concrete numerical demonstrations of the comparison
theorems between tropical (min-plus) and classical (additive weighted) sieves.
"""

import numpy as np
from typing import List, Callable


def tropical_sieve_score(P: List[int], c: Callable[[int], float], n: int) -> float:
    """Tropical sieve score: min over primes p in P of c(n mod p)."""
    if not P:
        return 0.0
    return min(c(n % p) for p in P)


def classical_sieve_weight(P: List[int], w: Callable[[int], float], n: int) -> float:
    """Classical sieve weight: sum over primes p in P of w(n mod p)."""
    return sum(w(n % p) for p in P)


def tropical_survivors(A: List[int], P: List[int], c: Callable, t: float) -> List[int]:
    """Elements of A with tropical score ≤ t."""
    return [n for n in A if tropical_sieve_score(P, c, n) <= t]


def classical_survivors(A: List[int], P: List[int], w: Callable, t: float) -> List[int]:
    """Elements of A with classical weight ≤ t."""
    return [n for n in A if classical_sieve_weight(P, w, n) <= t]


def pair_pattern_score(P: List[int], c: Callable, n: int) -> float:
    """Pair-pattern score for twin-prime candidates."""
    if not P:
        return 0.0
    return min(max(c(n % p), c((n + 2) % p)) for p in P)


def twin_unsieved(X: int, P: List[int], c: Callable, t: float) -> List[int]:
    """Elements up to X with pair-pattern score ≤ t."""
    return [n for n in range(X + 1) if pair_pattern_score(P, c, n) <= t]


def infimal_convolution(f: Callable, g: Callable, n: int) -> float:
    """Min-plus convolution: min_{0 ≤ k ≤ n} [f(k) + g(n-k)]."""
    return min(f(k) + g(n - k) for k in range(n + 1))


# ============================================================
# Demo 1: Comparison Theorem (Tropical ≤ Classical)
# ============================================================
def demo_comparison():
    """Demonstrate that tropical score ≤ classical weight pointwise."""
    print("=" * 60)
    print("DEMO 1: Comparison Theorem (Tropical ≤ Classical)")
    print("=" * 60)

    P = [2, 3, 5, 7]
    c = lambda r: float(r)  # cost = residue value
    w = c  # same function for both

    print(f"\nPrime set P = {P}")
    print(f"Cost/weight function: c(r) = w(r) = r")
    print(f"\n{'n':>5} | {'Tropical (min)':>15} | {'Classical (sum)':>15} | {'Trop ≤ Class?':>14}")
    print("-" * 60)

    violations = 0
    for n in range(1, 31):
        trop = tropical_sieve_score(P, c, n)
        clas = classical_sieve_weight(P, w, n)
        ok = "✓" if trop <= clas else "✗"
        if trop > clas:
            violations += 1
        print(f"{n:5d} | {trop:15.1f} | {clas:15.1f} | {ok:>14}")

    print(f"\nViolations of trop ≤ class: {violations} (should be 0)")


# ============================================================
# Demo 2: Survivor Set Inclusion
# ============================================================
def demo_survivors():
    """Demonstrate classical survivors ⊆ tropical survivors."""
    print("\n" + "=" * 60)
    print("DEMO 2: Survivor Set Inclusion")
    print("=" * 60)

    P = [2, 3, 5]
    c = lambda r: float(r)
    A = list(range(1, 101))

    for t in [0.5, 1.0, 2.0, 3.0]:
        trop = set(tropical_survivors(A, P, c, t))
        clas = set(classical_survivors(A, P, c, t))
        subset = clas.issubset(trop)
        print(f"Threshold t={t:.1f}: "
              f"|tropical|={len(trop):3d}, "
              f"|classical|={len(clas):3d}, "
              f"classical ⊆ tropical: {subset}")


# ============================================================
# Demo 3: Singleton Coincidence
# ============================================================
def demo_singleton():
    """Demonstrate exact coincidence for singleton prime sets."""
    print("\n" + "=" * 60)
    print("DEMO 3: Singleton Coincidence (|P|=1)")
    print("=" * 60)

    for p in [2, 3, 5, 7, 11]:
        P = [p]
        c = lambda r, p=p: float(r)
        mismatches = 0
        for n in range(1, 1001):
            if tropical_sieve_score(P, c, n) != classical_sieve_weight(P, c, n):
                mismatches += 1
        print(f"P = {{{p}}}: mismatches in [1..1000] = {mismatches} (should be 0)")


# ============================================================
# Demo 4: Strict Separation for |P| ≥ 2
# ============================================================
def demo_strict_separation():
    """Demonstrate strict inequality when |P| ≥ 2."""
    print("\n" + "=" * 60)
    print("DEMO 4: Strict Separation (|P| ≥ 2)")
    print("=" * 60)

    P = [2, 3, 5]
    c = lambda r: max(float(r), 0.1)  # strictly positive costs

    strict_count = 0
    for n in range(1, 101):
        trop = tropical_sieve_score(P, c, n)
        clas = classical_sieve_weight(P, c, n)
        if trop < clas:
            strict_count += 1

    print(f"P = {P}, c(r) = max(r, 0.1)")
    print(f"Candidates with trop < class in [1..100]: {strict_count}/100")
    print(f"(Strict separation occurs for most candidates)")


# ============================================================
# Demo 5: Twin-Candidate Growth
# ============================================================
def demo_twin_growth():
    """Demonstrate linear growth of twin-unsieved candidates."""
    print("\n" + "=" * 60)
    print("DEMO 5: Twin-Candidate Unsieved Growth")
    print("=" * 60)

    P = [3, 5, 7]
    c = lambda r: 0.0 if r == 0 else 1.0
    t = 0.5

    print(f"P = {P}, c(r) = 0 if r=0, else 1, threshold t={t}")
    print(f"\n{'X':>8} | {'|U(X)|':>8} | {'X/|U(X)|':>10} | {'|U(X)|/X':>10}")
    print("-" * 45)

    for X in [100, 500, 1000, 5000, 10000]:
        U = twin_unsieved(X, P, c, t)
        count = len(U)
        ratio = X / count if count > 0 else float('inf')
        density = count / X if X > 0 else 0
        print(f"{X:8d} | {count:8d} | {ratio:10.3f} | {density:10.6f}")


# ============================================================
# Demo 6: Infimal Convolution
# ============================================================
def demo_infimal_convolution():
    """Demonstrate infimal convolution properties."""
    print("\n" + "=" * 60)
    print("DEMO 6: Infimal Convolution (Min-Plus Convolution)")
    print("=" * 60)

    f = lambda k: float(k ** 2)
    g = lambda k: float((k - 3) ** 2)

    print(f"f(k) = k², g(k) = (k-3)²")
    print(f"\n{'n':>5} | {'(f ⊞ g)(n)':>12} | {'Achieved at k':>14} | {'f(k)+g(n-k)':>12}")
    print("-" * 52)

    for n in range(10):
        val = infimal_convolution(f, g, n)
        # Find minimizer
        best_k = min(range(n + 1), key=lambda k: f(k) + g(n - k))
        print(f"{n:5d} | {val:12.1f} | {best_k:14d} | {f(best_k) + g(n - best_k):12.1f}")


# ============================================================
# Demo 7: Relaxation Gap vs. Number of Primes
# ============================================================
def demo_relaxation_gap():
    """Show how the tropical-classical gap grows with |P|."""
    print("\n" + "=" * 60)
    print("DEMO 7: Relaxation Gap vs. Sieve Depth")
    print("=" * 60)

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    c = lambda r: float(r)
    A = list(range(1, 1001))
    t = 2.0

    print(f"A = [1..1000], c(r) = r, threshold t = {t}")
    print(f"\n{'|P|':>5} | {'Trop surv':>10} | {'Class surv':>11} | {'Ratio':>7}")
    print("-" * 42)

    for k in range(1, len(primes) + 1):
        P = primes[:k]
        ts = len(tropical_survivors(A, P, c, t))
        cs = len(classical_survivors(A, P, c, t))
        ratio = ts / cs if cs > 0 else float('inf')
        print(f"{k:5d} | {ts:10d} | {cs:11d} | {ratio:7.2f}")


if __name__ == "__main__":
    demo_comparison()
    demo_survivors()
    demo_singleton()
    demo_strict_separation()
    demo_twin_growth()
    demo_infimal_convolution()
    demo_relaxation_gap()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json
import sys
sys.path.insert(0, '.')
from visualizations import generate_all

# Generate visualization base64 data
figs = generate_all()

# Read files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Tropical/TropicalSieveTheory.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

package = {
    "title": "Tropical Sieve Theory: Comparison Theorems and the Limits of Min-Plus Sieve Methods",
    "domain": "Algebra / Number Theory / Tropical Mathematics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical vs Classical Sieve Comparison",
            "code": demo_code
        },
        {
            "name": "Applications: Cryptography, Twin Primes, Constellations",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Sieve Score",
            "pseudocode": "Input: Prime set P, cost function c, candidate n\nOutput: min_{p in P} c(n mod p)\n\nscore ← +∞\nfor each p in P:\n    score ← min(score, c(n mod p))\nreturn score\n\nComplexity: O(|P|)",
            "code": algorithms_code
        },
        {
            "name": "Two-Phase Sieve (Tropical Pre-filter + Classical Refinement)",
            "pseudocode": "Phase 1: For each n in A, if min_p c(n mod p) > t, eliminate n\nPhase 2: For surviving n, if sum_p w(n mod p) > t, eliminate n\nCorrectness: Comparison theorem guarantees no false negatives\nComplexity: O(|A| · |P|)",
            "code": "# See algorithms.py two_phase_sieve function"
        }
    ],
    "visualizations": [
        {
            "name": "Tropical vs Classical Score Comparison",
            "data": figs['comparison']
        },
        {
            "name": "Relaxation Gap vs Sieve Depth",
            "data": figs['relaxation_gap']
        },
        {
            "name": "Survivor Count Comparison",
            "data": figs['survivors']
        },
        {
            "name": "Twin-Candidate Growth",
            "data": figs['twin_growth']
        },
        {
            "name": "Score Heatmap",
            "data": figs['heatmap']
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Tropical Sieve Theory: Visualizations

Generates publication-quality figures showing key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import base64
from io import BytesIO


def tropical_sieve_score(P, c, n):
    if not P:
        return 0.0
    return min(c(n % p) for p in P)


def classical_sieve_weight(P, w, n):
    return sum(w(n % p) for p in P)


def pair_pattern_score(P, c, n):
    if not P:
        return 0.0
    return min(max(c(n % p), c((n + 2) % p)) for p in P)


def save_fig_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# ============================================================
# Figure 1: Tropical vs Classical Scores
# ============================================================
def fig_comparison():
    P = [2, 3, 5, 7]
    c = lambda r: float(r)
    ns = list(range(1, 51))
    trop = [tropical_sieve_score(P, c, n) for n in ns]
    clas = [classical_sieve_weight(P, c, n) for n in ns]

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.bar(np.array(ns) - 0.2, trop, 0.4, label='Tropical (min)', color='#2196F3', alpha=0.8)
    ax.bar(np.array(ns) + 0.2, clas, 0.4, label='Classical (sum)', color='#FF5722', alpha=0.8)
    ax.set_xlabel('Candidate n', fontsize=12)
    ax.set_ylabel('Score', fontsize=12)
    ax.set_title('Tropical vs Classical Sieve Scores\n(P = {2,3,5,7}, c(r) = r)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 51)
    fig.tight_layout()
    fig.savefig('fig_comparison.png', dpi=150, bbox_inches='tight')
    return save_fig_base64(fig)


# ============================================================
# Figure 2: Relaxation Gap Growth
# ============================================================
def fig_relaxation_gap():
    primes_list = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    c = lambda r: float(r)
    A = list(range(1, 1001))

    depths = list(range(1, len(primes_list) + 1))
    mean_gaps = []
    max_gaps = []

    for k in depths:
        P = primes_list[:k]
        gaps = [classical_sieve_weight(P, c, n) - tropical_sieve_score(P, c, n) for n in A]
        mean_gaps.append(np.mean(gaps))
        max_gaps.append(np.max(gaps))

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(depths, mean_gaps, 'o-', color='#2196F3', linewidth=2, markersize=8, label='Mean gap')
    ax.plot(depths, max_gaps, 's-', color='#FF5722', linewidth=2, markersize=8, label='Max gap')
    ax.fill_between(depths, 0, mean_gaps, alpha=0.15, color='#2196F3')
    ax.set_xlabel('Number of sieve primes |P|', fontsize=12)
    ax.set_ylabel('Classical − Tropical score', fontsize=12)
    ax.set_title('Relaxation Gap: How Much Information\nTropicalization Loses', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('fig_relaxation_gap.png', dpi=150, bbox_inches='tight')
    return save_fig_base64(fig)


# ============================================================
# Figure 3: Survivor Count Comparison
# ============================================================
def fig_survivors():
    P = [2, 3, 5, 7, 11]
    c = lambda r: float(r)
    A = list(range(1, 501))

    thresholds = np.linspace(0, 10, 50)
    trop_counts = []
    clas_counts = []

    for t in thresholds:
        tc = sum(1 for n in A if tropical_sieve_score(P, c, n) <= t)
        cc = sum(1 for n in A if classical_sieve_weight(P, c, n) <= t)
        trop_counts.append(tc)
        clas_counts.append(cc)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(thresholds, trop_counts, '-', color='#2196F3', linewidth=2.5, label='Tropical survivors')
    ax.plot(thresholds, clas_counts, '-', color='#FF5722', linewidth=2.5, label='Classical survivors')
    ax.fill_between(thresholds, clas_counts, trop_counts, alpha=0.2, color='#9C27B0',
                     label='Gap (tropical − classical)')
    ax.set_xlabel('Threshold t', fontsize=12)
    ax.set_ylabel('Number of survivors', fontsize=12)
    ax.set_title('Survivor Counts vs Threshold\n(Tropical always ≥ Classical)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('fig_survivors.png', dpi=150, bbox_inches='tight')
    return save_fig_base64(fig)


# ============================================================
# Figure 4: Twin-Candidate Growth
# ============================================================
def fig_twin_growth():
    P = [3, 5, 7]
    c = lambda r: 0.0 if r == 0 else 1.0
    t = 0.5

    Xs = list(range(10, 5001, 50))
    counts = []
    for X in Xs:
        count = sum(1 for n in range(X + 1) if pair_pattern_score(P, c, n) <= t)
        counts.append(count)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(Xs, counts, '-', color='#4CAF50', linewidth=2)
    ax1.set_xlabel('X', fontsize=12)
    ax1.set_ylabel('|U(X)|', fontsize=12)
    ax1.set_title('Twin-Unsieved Count Growth', fontsize=14)
    ax1.grid(True, alpha=0.3)

    densities = [c / X if X > 0 else 0 for c, X in zip(counts, Xs)]
    ax2.plot(Xs, densities, '-', color='#FF9800', linewidth=2)
    ax2.set_xlabel('X', fontsize=12)
    ax2.set_ylabel('|U(X)| / X', fontsize=12)
    ax2.set_title('Twin-Unsieved Density', fontsize=14)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('fig_twin_growth.png', dpi=150, bbox_inches='tight')
    return save_fig_base64(fig)


# ============================================================
# Figure 5: Score Heatmap
# ============================================================
def fig_heatmap():
    primes = [2, 3, 5, 7, 11]
    c = lambda r: float(r)
    ns = list(range(1, 61))

    # Compute local costs for each (n, p)
    data = np.zeros((len(primes), len(ns)))
    for i, p in enumerate(primes):
        for j, n in enumerate(ns):
            data[i, j] = c(n % p)

    fig, axes = plt.subplots(3, 1, figsize=(12, 10), gridspec_kw={'height_ratios': [3, 1, 1]})

    # Heatmap of local costs
    im = axes[0].imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')
    axes[0].set_yticks(range(len(primes)))
    axes[0].set_yticklabels([f'p={p}' for p in primes])
    axes[0].set_xlabel('Candidate n')
    axes[0].set_title('Local Residue Costs c(n mod p)', fontsize=14)
    plt.colorbar(im, ax=axes[0], label='Cost')

    # Tropical score (row-wise min)
    trop = [tropical_sieve_score(primes, c, n) for n in ns]
    axes[1].bar(range(len(ns)), trop, color='#2196F3', alpha=0.8)
    axes[1].set_ylabel('Tropical\n(min)')
    axes[1].set_xlim(-0.5, len(ns) - 0.5)

    # Classical weight (column-wise sum)
    clas = [classical_sieve_weight(primes, c, n) for n in ns]
    axes[2].bar(range(len(ns)), clas, color='#FF5722', alpha=0.8)
    axes[2].set_ylabel('Classical\n(sum)')
    axes[2].set_xlabel('Candidate n')
    axes[2].set_xlim(-0.5, len(ns) - 0.5)

    fig.tight_layout()
    fig.savefig('fig_heatmap.png', dpi=150, bbox_inches='tight')
    return save_fig_base64(fig)


def generate_all():
    """Generate all figures and return base64 data."""
    print("Generating figures...")
    figs = {}
    figs['comparison'] = fig_comparison()
    print("  ✓ Comparison")
    figs['relaxation_gap'] = fig_relaxation_gap()
    print("  ✓ Relaxation gap")
    figs['survivors'] = fig_survivors()
    print("  ✓ Survivors")
    figs['twin_growth'] = fig_twin_growth()
    print("  ✓ Twin growth")
    figs['heatmap'] = fig_heatmap()
    print("  ✓ Heatmap")
    print("All figures generated.")
    return figs


if __name__ == "__main__":
    figs = generate_all()
    for name, data in figs.items():
        print(f"{name}: {len(data)} chars of base64")
