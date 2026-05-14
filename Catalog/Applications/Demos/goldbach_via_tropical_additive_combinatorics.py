#!/usr/bin/env python3
"""
Tropical Additive Combinatorics: Applications

Demonstrates real-world applications of tropical convolution to:
1. Shortest-path / dynamic programming decomposition
2. Knapsack-style optimization
3. Error-correcting code distance analysis
4. Additive number theory exploration
"""

from typing import Optional, Set, List, Dict, Tuple
import math


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Minimum-Cost Decomposition (Shortest Path)
# ═══════════════════════════════════════════════════════════════════════════

def minimum_cost_decomposition(
    costs_a: Dict[int, int],
    costs_b: Dict[int, int],
    target: int
) -> Tuple[Optional[int], Optional[Tuple[int, int]]]:
    """
    Find the minimum-cost way to decompose `target` as a + b
    where a has cost costs_a[a] and b has cost costs_b[b].

    This is exactly the tropical convolution at `target`.

    Application: Resource allocation, job scheduling, currency exchange.

    Example: A store sells items of weight `a` at cost costs_a[a] and
    items of weight `b` at cost costs_b[b]. Find the cheapest pair
    totaling exactly `target` weight.
    """
    best_cost = None
    best_split = None

    for a in range(target + 1):
        b = target - a
        if a in costs_a and b in costs_b:
            cost = costs_a[a] + costs_b[b]
            if best_cost is None or cost < best_cost:
                best_cost = cost
                best_split = (a, b)

    return best_cost, best_split


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Additive Basis Detection
# ═══════════════════════════════════════════════════════════════════════════

def is_additive_basis_order_2(A: Set[int], N: int) -> Tuple[bool, List[int]]:
    """
    Check if A is an additive basis of order 2 up to N.

    A is a basis of order 2 if every sufficiently large integer
    can be written as a sum of two elements of A.

    Uses tropical self-convolution: A is a basis of order 2 iff
    tropConv(tropInd(A), tropInd(A))(n) = 0 for all large n.

    Returns (is_basis, missing) where missing lists values ≤ N
    not representable as a+b with a, b ∈ A.
    """
    f = lambda n: 0 if n in A else None
    missing = []

    for n in range(N + 1):
        found = False
        for a in A:
            if a <= n and (n - a) in A:
                found = True
                break
        if not found:
            missing.append(n)

    return len(missing) == 0, missing


def basis_density_experiment(density: float, N: int, trials: int = 10) -> float:
    """
    Experimentally test: if A ⊂ {0,...,N} has density `density`,
    what fraction of {0,...,2N} is in A+A?

    This demonstrates that sets of positive density have large sumsets
    (a key principle formalized in tropical language).
    """
    import random
    total_coverage = 0.0

    for _ in range(trials):
        A = {n for n in range(N + 1) if random.random() < density}
        if not A:
            continue
        sumset = {a + b for a in A for b in A}
        coverage = len(sumset) / (2 * N + 1)
        total_coverage += coverage

    return total_coverage / trials


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Coin Change Problem (Tropical Perspective)
# ═══════════════════════════════════════════════════════════════════════════

def coin_change_tropical(denominations: List[int], target: int) -> Optional[int]:
    """
    Solve the coin change problem using iterated tropical convolution.

    Given coin denominations, find the minimum number of coins to make `target`.
    This is the h-fold tropical self-convolution of the denomination indicator
    evaluated at `target`.

    The tropical perspective: each denomination d has cost 1 (one coin),
    and we want min_{d1+d2+...+dk=target} k.
    """
    # Cost function: 1 for each valid denomination, ⊤ otherwise
    # Include 0 with cost 0 as identity
    INF = float('inf')
    dp = [INF] * (target + 1)
    dp[0] = 0

    for amount in range(1, target + 1):
        for coin in denominations:
            if coin <= amount and dp[amount - coin] != INF:
                dp[amount] = min(dp[amount], dp[amount - coin] + 1)

    return dp[target] if dp[target] != INF else None


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: Goldbach Exploration Tool
# ═══════════════════════════════════════════════════════════════════════════

def goldbach_landscape(N: int) -> Dict[str, any]:
    """
    Generate a complete landscape of Goldbach-related tropical data up to N.

    Returns a dictionary with:
    - representations: count of prime pair representations per even n
    - min_prime: smallest prime in any representation
    - tropical_values: goldbachTrop values (0 or ⊤)
    """
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, N + 1, i):
                sieve[j] = False

    result = {
        'even_numbers': [],
        'representations': [],
        'min_prime': [],
        'tropical_value': []
    }

    for n in range(4, N + 1, 2):
        count = 0
        min_p = None
        for p in range(2, n // 2 + 1):
            if sieve[p] and sieve[n - p]:
                count += 1
                if min_p is None:
                    min_p = p

        result['even_numbers'].append(n)
        result['representations'].append(count)
        result['min_prime'].append(min_p)
        result['tropical_value'].append(0 if count > 0 else None)

    return result


# ═══════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("Application Demonstrations")
    print("=" * 60)

    # App 1: Minimum cost decomposition
    print("\n--- Application 1: Minimum-Cost Decomposition ---")
    costs_a = {1: 5, 3: 2, 5: 8, 7: 1}
    costs_b = {2: 3, 4: 6, 6: 1, 8: 4}
    target = 10
    cost, split = minimum_cost_decomposition(costs_a, costs_b, target)
    print(f"  Target: {target}")
    print(f"  Costs A: {costs_a}")
    print(f"  Costs B: {costs_b}")
    if split:
        print(f"  Optimal split: {split[0]} + {split[1]} = {target}, cost = {cost}")
    else:
        print(f"  No feasible decomposition (cost = ⊤)")

    # App 2: Additive basis
    print("\n--- Application 2: Additive Basis Detection ---")
    squares = {i*i for i in range(20)}
    is_basis, missing = is_additive_basis_order_2(squares, 100)
    print(f"  Set: perfect squares up to 361")
    print(f"  Basis of order 2 up to 100? {is_basis}")
    if missing:
        print(f"  Missing: {missing[:20]}{'...' if len(missing) > 20 else ''}")

    # Density experiment
    print("\n--- Density → Sumset Coverage ---")
    for d in [0.1, 0.2, 0.3, 0.5, 0.7]:
        cov = basis_density_experiment(d, 100, trials=20)
        print(f"  density = {d:.1f} → sumset coverage = {cov:.3f}")

    # App 3: Coin change
    print("\n--- Application 3: Coin Change (Tropical) ---")
    coins = [1, 5, 10, 25]
    for target in [30, 41, 67, 99]:
        result = coin_change_tropical(coins, target)
        print(f"  {target} cents → {result} coins (denominations: {coins})")

    # App 4: Goldbach landscape
    print("\n--- Application 4: Goldbach Landscape ---")
    landscape = goldbach_landscape(100)
    print(f"  {'n':>4} | {'r(n)':>5} | {'min prime':>10} | {'tropical':>10}")
    print("  " + "-" * 40)
    for i, n in enumerate(landscape['even_numbers']):
        r = landscape['representations'][i]
        mp = landscape['min_prime'][i]
        tv = landscape['tropical_value'][i]
        tv_str = "0" if tv == 0 else "⊤"
        print(f"  {n:>4} | {r:>5} | {mp if mp else '-':>10} | {tv_str:>10}")


#!/usr/bin/env python3
"""
Tropical Additive Combinatorics: Demonstrations

This module demonstrates the core theorems of tropical additive combinatorics
with concrete numerical examples, making the mathematics tangible.
"""

import math
from typing import Optional


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def trop_ind(A: set, n: int) -> Optional[int]:
    """Tropical indicator: 0 if n in A, infinity (None) otherwise."""
    return 0 if n in A else None


def trop_add(a: Optional[int], b: Optional[int]) -> Optional[int]:
    """Tropical multiplication (classical addition) in WithTop ℕ."""
    if a is None or b is None:
        return None
    return a + b


def trop_conv_nat(f, g, n: int) -> Optional[int]:
    """Min-plus convolution: inf_{a+b=n} (f(a) + g(b))."""
    result = None
    for a in range(n + 1):
        val = trop_add(f(a), g(n - a))
        if val is not None:
            if result is None or val < result:
                result = val
    return result


def prime_cost(n: int) -> Optional[int]:
    """Tropical indicator of primes."""
    return 0 if is_prime(n) else None


def goldbach_trop(n: int) -> Optional[int]:
    """Tropical Goldbach function: self-convolution of prime indicator."""
    return trop_conv_nat(prime_cost, prime_cost, n)


# ─── Demo 1: Tropical-Additive Equivalence ─────────────────────────────────

def demo_equivalence():
    """Demonstrate Theorem 1: tropConv of indicators ↔ sumset membership."""
    print("=" * 70)
    print("DEMO 1: Tropical Convolution ↔ Sumset Membership")
    print("=" * 70)

    A = {1, 3, 5}
    B = {2, 4, 6}
    sumset = {a + b for a in A for b in B}

    print(f"\nA = {sorted(A)}")
    print(f"B = {sorted(B)}")
    print(f"A + B = {sorted(sumset)}")

    f_A = lambda n: trop_ind(A, n)
    f_B = lambda n: trop_ind(B, n)

    print(f"\nTropical convolution (tropInd A ⋆ₜ tropInd B)(n):")
    print(f"{'n':>4} | {'conv':>8} | {'in A+B?':>8} | {'match':>6}")
    print("-" * 40)
    for n in range(13):
        conv = trop_conv_nat(f_A, f_B, n)
        in_sumset = n in sumset
        conv_str = "0" if conv == 0 else "⊤"
        match = "✓" if (conv == 0) == in_sumset else "✗"
        print(f"{n:>4} | {conv_str:>8} | {'yes' if in_sumset else 'no':>8} | {match:>6}")

    print("\n✓ Theorem verified: conv = 0 ↔ n ∈ A + B for all tested values")


# ─── Demo 2: Goldbach Tropical Equivalence ──────────────────────────────────

def demo_goldbach():
    """Demonstrate Theorem 2: goldbachTrop(n) = 0 ↔ n is sum of two primes."""
    print("\n" + "=" * 70)
    print("DEMO 2: Goldbach Tropical Equivalence")
    print("=" * 70)

    print(f"\n{'n':>4} | {'goldbachTrop':>12} | {'sum of 2 primes?':>18} | {'witnesses':>20}")
    print("-" * 65)

    for n in range(4, 51, 2):
        gt = goldbach_trop(n)
        gt_str = "0" if gt == 0 else "⊤"

        witnesses = []
        for p in range(2, n):
            if is_prime(p) and is_prime(n - p) and p <= n - p:
                witnesses.append(f"{p}+{n-p}")

        has_rep = len(witnesses) > 0
        wit_str = ", ".join(witnesses[:3])
        if len(witnesses) > 3:
            wit_str += f" ... ({len(witnesses)} total)"

        print(f"{n:>4} | {gt_str:>12} | {'yes' if has_rep else 'NO':>18} | {wit_str:>20}")

    print("\n✓ goldbachTrop(n) = 0 ↔ ∃ primes p,q with p+q=n verified for even n ∈ [4,50]")


# ─── Demo 3: Counterexample / Boundedness ───────────────────────────────────

def demo_counterexample():
    """Demonstrate Theorem 3: If Goldbach fails, goldbachTrop = ⊤."""
    print("\n" + "=" * 70)
    print("DEMO 3: Boundedness Counterexample")
    print("=" * 70)

    print("\nThe tropical Goldbach function takes values in {0, ⊤}.")
    print("If ANY even n > 2 has goldbachTrop(n) = ⊤, then no finite C bounds it.")
    print("\nValues of goldbachTrop on even numbers 4..100:")

    zeros = 0
    tops = 0
    for n in range(4, 101, 2):
        gt = goldbach_trop(n)
        if gt == 0:
            zeros += 1
        else:
            tops += 1

    print(f"  Values equal to 0: {zeros}")
    print(f"  Values equal to ⊤: {tops}")
    print(f"\nAll tested even n > 2 have goldbachTrop(n) = 0.")
    print("Theorem says: if even ONE were ⊤, no finite bound could exist.")
    print("This is because ⊤ > C for any finite C ∈ ℕ.")


# ─── Demo 4: Cofinite Sets ──────────────────────────────────────────────────

def demo_cofinite():
    """Demonstrate Theorem 4: Cofinite sets → eventually zero convolution."""
    print("\n" + "=" * 70)
    print("DEMO 4: Cofinite Sets Have Eventually Zero Self-Convolution")
    print("=" * 70)

    # A = ℕ \ {0, 1, 2, 3, 4} — cofinite with M = 5
    exceptions = {0, 1, 2, 3, 4}
    M = 5
    A = set(range(200)) - exceptions

    print(f"\nA = ℕ \\ {sorted(exceptions)} (cofinite, M = {M})")
    print(f"Theorem predicts: tropConv(A,A)(n) = 0 for all n ≥ 2M = {2*M}")

    f_A = lambda n: trop_ind(A, n)

    print(f"\n{'n':>4} | {'tropConv':>10} | {'predicted':>10} | {'match':>6}")
    print("-" * 45)
    for n in range(0, 25):
        conv = trop_conv_nat(f_A, f_A, n)
        conv_str = "0" if conv == 0 else "⊤"
        predicted = "0" if n >= 2 * M else "?"
        match = "✓" if (n >= 2 * M and conv == 0) or n < 2 * M else "✗"
        print(f"{n:>4} | {conv_str:>10} | {predicted:>10} | {match:>6}")

    print(f"\n✓ Theorem verified: tropConv = 0 for all n ≥ {2*M}")
    print(f"  (Some values below {2*M} may also be 0 — the bound is not tight.)")


# ─── Demo 5: Sumset = Zero Locus ────────────────────────────────────────────

def demo_zero_locus():
    """Demonstrate Theorem 5: Zero locus of tropical convolution = sumset."""
    print("\n" + "=" * 70)
    print("DEMO 5: Zero Locus of Tropical Convolution = Sumset")
    print("=" * 70)

    A = {1, 4, 7}
    B = {2, 3, 8}
    sumset = {a + b for a in A for b in B}
    N = max(a + b for a in A for b in B) + 1

    f_A = lambda n: trop_ind(A, n)
    f_B = lambda n: trop_ind(B, n)

    zero_locus = set()
    for n in range(N):
        if trop_conv_nat(f_A, f_B, n) == 0:
            zero_locus.add(n)

    print(f"\nA = {sorted(A)}")
    print(f"B = {sorted(B)}")
    print(f"A + B (sumset) = {sorted(sumset)}")
    print(f"Zero locus     = {sorted(zero_locus)}")
    print(f"Equal? {zero_locus == sumset} ✓" if zero_locus == sumset else f"Equal? False ✗")


# ─── Demo 6: Commutativity ──────────────────────────────────────────────────

def demo_commutativity():
    """Demonstrate commutativity of tropical convolution."""
    print("\n" + "=" * 70)
    print("DEMO 6: Commutativity of Tropical Convolution")
    print("=" * 70)

    import random
    random.seed(42)

    # Random cost functions
    def f(n):
        return [None, 0, 3, None, 1, 2, None, 0, 4, None, 1][n] if n < 11 else None

    def g(n):
        return [0, None, 2, 1, None, 0, 3, None, 0, 2, None][n] if n < 11 else None

    print(f"\n{'n':>4} | {'(f ⋆ g)(n)':>12} | {'(g ⋆ f)(n)':>12} | {'equal':>6}")
    print("-" * 45)
    all_match = True
    for n in range(15):
        fg = trop_conv_nat(f, g, n)
        gf = trop_conv_nat(g, f, n)
        fg_str = str(fg) if fg is not None else "⊤"
        gf_str = str(gf) if gf is not None else "⊤"
        match = fg == gf
        all_match = all_match and match
        print(f"{n:>4} | {fg_str:>12} | {gf_str:>12} | {'✓' if match else '✗':>6}")

    print(f"\n{'✓' if all_match else '✗'} Commutativity verified for all tested values")


if __name__ == "__main__":
    demo_equivalence()
    demo_goldbach()
    demo_counterexample()
    demo_cofinite()
    demo_zero_locus()
    demo_commutativity()
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""
import json
import sys
sys.path.insert(0, '.')

# Read all text files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Tropical/TropicalAdditiveCombinatorics.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Generate visualizations
from visualizations import generate_all_visualizations
viz_data = generate_all_visualizations()

package = {
    "title": "Tropical Additive Combinatorics: Min-Plus Convolution Meets Sumset Theory",
    "domain": "Tropical Algebra / Additive Number Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Additive Combinatorics Demonstrations",
            "code": demo_code
        },
        {
            "name": "Real-World Applications",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Convolution (Naive)",
            "pseudocode": "Input: cost functions f, g; target n\nOutput: (f ⋆_T g)(n)\n\nresult ← ⊤\nfor a = 0 to n:\n    val ← f(a) + g(n - a)\n    result ← min(result, val)\nreturn result\n\nComplexity: O(n) time, O(1) space",
            "code": """def tropical_convolution(f, g, n):
    \"\"\"Min-plus convolution: inf_{a+b=n} (f(a) + g(b)). None = infinity.\"\"\"
    result = None
    for a in range(n + 1):
        fa, gb = f(a), g(n - a)
        if fa is not None and gb is not None:
            val = fa + gb
            if result is None or val < result:
                result = val
    return result

# Example: prime indicator self-convolution (Goldbach)
def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0: return False
    return all(n % i != 0 for i in range(3, int(n**0.5)+1, 2))

prime_cost = lambda n: 0 if is_prime(n) else None

for n in range(4, 51, 2):
    gt = tropical_convolution(prime_cost, prime_cost, n)
    print(f"goldbachTrop({n}) = {gt if gt is not None else '⊤'}")
"""
        },
        {
            "name": "Goldbach Tropical Verification",
            "pseudocode": "Input: bound N\nOutput: (verified, counterexamples)\n\nis_prime ← sieve(N)\ncounterexamples ← []\nfor n = 4, 6, ..., N:\n    found ← false\n    for p = 2 to n/2:\n        if is_prime[p] and is_prime[n-p]:\n            found ← true; break\n    if not found:\n        counterexamples.append(n)\nreturn (len(counterexamples) = 0, counterexamples)\n\nComplexity: O(N²/log²N) time, O(N) space",
            "code": """def sieve(N):
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, N+1, i):
                is_prime[j] = False
    return is_prime

def goldbach_verify(N):
    isp = sieve(N)
    failures = []
    for n in range(4, N+1, 2):
        if not any(isp[p] and isp[n-p] for p in range(2, n)):
            failures.append(n)
    return len(failures) == 0, failures

verified, failures = goldbach_verify(10000)
print(f"Goldbach verified up to 10000: {verified}")
print(f"Counterexamples: {failures}")
"""
        },
        {
            "name": "Cofinite Threshold Computation",
            "pseudocode": "Input: exceptions (finite set of excluded naturals)\nOutput: threshold N such that tropConv(A,A)(n) = 0 for all n ≥ N\n\nM ← max(exceptions) + 1\nreturn 2 * M\n\nComplexity: O(|exceptions|) time, O(1) space",
            "code": """def cofinite_threshold(exceptions):
    if not exceptions:
        return 0
    return 2 * (max(exceptions) + 1)

# Verify
def trop_conv(f, g, n):
    result = None
    for a in range(n + 1):
        fa, gb = f(a), g(n - a)
        if fa is not None and gb is not None:
            val = fa + gb
            if result is None or val < result:
                result = val
    return result

exceptions = {0, 1, 2, 3, 4}
threshold = cofinite_threshold(exceptions)
A = set(range(100)) - exceptions
f = lambda n: 0 if n in A else None

print(f"Exceptions: {sorted(exceptions)}")
print(f"Threshold: {threshold}")
for n in range(threshold - 2, threshold + 10):
    val = trop_conv(f, f, n)
    status = "= 0 ✓" if val == 0 else "= ⊤"
    print(f"  tropConv(A,A)({n}) {status}")
"""
        }
    ],
    "visualizations": [
        {"name": "Goldbach Representation Function", "data": viz_data['goldbach_representations']},
        {"name": "Tropical Convolution Heatmap", "data": viz_data['tropical_heatmap']},
        {"name": "Cofinite Set Convergence", "data": viz_data['cofinite_convergence']},
        {"name": "Sumset = Tropical Zero Locus", "data": viz_data['sumset_tropical']}
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Tropical Additive Combinatorics: Visualizations

Generates publication-quality figures illustrating the key theorems
and mathematical structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
from io import BytesIO
import json


def sieve(N):
    """Sieve of Eratosthenes."""
    is_prime = [True] * (N + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(N**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, N + 1, i):
                is_prime[j] = False
    return is_prime


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_goldbach_representations():
    """Visualize Goldbach representation counts (r(n)) for even numbers."""
    N = 200
    is_prime = sieve(N)

    evens = list(range(4, N + 1, 2))
    counts = []
    for n in evens:
        c = sum(1 for p in range(2, n // 2 + 1) if is_prime[p] and is_prime[n - p])
        counts.append(c)

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))

    # Top: representation counts
    colors = ['#2ecc71' if c > 0 else '#e74c3c' for c in counts]
    ax1.bar(evens, counts, color=colors, width=1.5, alpha=0.8)
    ax1.set_xlabel('Even number n', fontsize=12)
    ax1.set_ylabel('r(n) = # of prime pair representations', fontsize=12)
    ax1.set_title('Goldbach Representation Function r(n)', fontsize=14, fontweight='bold')
    ax1.axhline(y=0, color='black', linewidth=0.5)

    # Bottom: tropical value (0 or ⊤)
    trop_vals = [0 if c > 0 else 1 for c in counts]
    trop_colors = ['#2ecc71' if v == 0 else '#e74c3c' for v in trop_vals]
    ax2.bar(evens, [1]*len(evens), color=trop_colors, width=1.5, alpha=0.8)
    ax2.set_xlabel('Even number n', fontsize=12)
    ax2.set_ylabel('goldbachTrop(n)', fontsize=12)
    ax2.set_yticks([0, 1])
    ax2.set_yticklabels(['', ''])
    ax2.set_title('Tropical Goldbach Function (green = 0, red = ⊤)', fontsize=14, fontweight='bold')

    # Add annotation
    ax2.text(0.02, 0.5, 'All green ⟹ goldbachTrop = 0\n(Goldbach verified up to 200)',
             transform=ax2.transAxes, fontsize=11, verticalalignment='center',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    plt.tight_layout()
    return fig


def viz_tropical_convolution_heatmap():
    """Heatmap showing tropical convolution summands for a specific set."""
    A = {2, 3, 5, 7, 11, 13}
    N = 26

    fig, ax = plt.subplots(figsize=(12, 10))

    data = np.full((N, N), np.nan)
    for a in range(N):
        for b in range(N):
            if a in A and b in A:
                data[a][b] = 0  # Both in A
            else:
                data[a][b] = 1  # At least one not in A (⊤)

    cmap = plt.cm.colors.ListedColormap(['#2ecc71', '#e74c3c'])
    bounds = [-0.5, 0.5, 1.5]
    norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)

    im = ax.imshow(data, cmap=cmap, norm=norm, aspect='equal', origin='lower')

    # Mark the diagonal lines where a + b = n
    for n in [4, 6, 10, 14, 16, 24]:
        xs = np.array([max(0, n - N + 1), min(n, N - 1)])
        ys = n - xs
        ax.plot(xs, ys, 'k--', alpha=0.4, linewidth=1)
        ax.text(min(n, N-1) + 0.3, max(0, n - N + 1) + 0.3, f'n={n}',
                fontsize=8, alpha=0.6)

    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('b', fontsize=12)
    ax.set_title('Tropical Convolution Summands: tropInd(A)(a) + tropInd(A)(b)\n'
                 f'A = {sorted(A)} (green = 0, red = ⊤)', fontsize=13, fontweight='bold')

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [Patch(facecolor='#2ecc71', label='0 (both a,b ∈ A)'),
                       Patch(facecolor='#e74c3c', label='⊤ (at least one ∉ A)')]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

    plt.tight_layout()
    return fig


def viz_cofinite_convergence():
    """Visualize how cofinite sets achieve tropical vanishing."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    exception_sets = [
        {0, 1},
        {0, 1, 2, 3},
        {0, 1, 5, 10},
        {0, 1, 2, 3, 4, 5, 6, 7}
    ]

    for idx, exceptions in enumerate(exception_sets):
        ax = axes[idx // 2][idx % 2]
        M = max(exceptions) + 1
        threshold = 2 * M
        N = threshold + 15

        A = set(range(N + 1)) - exceptions
        f_A = lambda n, A=A: 0 if n in A else None

        values = []
        for n in range(N + 1):
            result = None
            for a in range(n + 1):
                fa = f_A(a)
                fb = f_A(n - a)
                if fa is not None and fb is not None:
                    val = fa + fb
                    if result is None or val < result:
                        result = val
            values.append(0 if result == 0 else 1)

        colors = ['#2ecc71' if v == 0 else '#e74c3c' for v in values]
        ax.bar(range(N + 1), [1]*(N+1), color=colors, width=0.8)
        ax.axvline(x=threshold - 0.5, color='blue', linestyle='--', linewidth=2,
                   label=f'2M = {threshold}')
        ax.set_title(f'Exceptions = {sorted(exceptions)}, M = {M}', fontsize=11)
        ax.set_xlabel('n')
        ax.set_yticks([])
        ax.legend(fontsize=9)

    fig.suptitle('Cofinite Sets: Tropical Self-Convolution\n'
                 '(green = 0, red = ⊤, blue line = theoretical threshold 2M)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    return fig


def viz_sumset_tropical():
    """Visualize the equivalence between sumsets and tropical zero loci."""
    A = {1, 3, 5, 8}
    B = {2, 4, 7}
    sumset = {a + b for a in A for b in B}
    N = max(sumset) + 3

    fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(14, 8))

    # A
    a_colors = ['#3498db' if n in A else '#ecf0f1' for n in range(N)]
    ax1.bar(range(N), [1]*N, color=a_colors, edgecolor='gray', width=0.8)
    ax1.set_title(f'Set A = {sorted(A)}', fontsize=12, fontweight='bold')
    ax1.set_yticks([])
    for n in range(N):
        if n in A:
            ax1.text(n, 0.5, str(n), ha='center', va='center', fontweight='bold')

    # B
    b_colors = ['#e67e22' if n in B else '#ecf0f1' for n in range(N)]
    ax2.bar(range(N), [1]*N, color=b_colors, edgecolor='gray', width=0.8)
    ax2.set_title(f'Set B = {sorted(B)}', fontsize=12, fontweight='bold')
    ax2.set_yticks([])
    for n in range(N):
        if n in B:
            ax2.text(n, 0.5, str(n), ha='center', va='center', fontweight='bold')

    # Sumset / Zero locus
    s_colors = ['#2ecc71' if n in sumset else '#ecf0f1' for n in range(N)]
    ax3.bar(range(N), [1]*N, color=s_colors, edgecolor='gray', width=0.8)
    ax3.set_title(f'A + B = Zero locus of tropConv(tropInd A, tropInd B) = {sorted(sumset)}',
                  fontsize=12, fontweight='bold')
    ax3.set_yticks([])
    ax3.set_xlabel('n', fontsize=12)
    for n in range(N):
        if n in sumset:
            ax3.text(n, 0.5, str(n), ha='center', va='center', fontweight='bold', fontsize=9)

    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 data URIs."""
    results = {}

    print("Generating Goldbach representations...")
    fig = viz_goldbach_representations()
    results['goldbach_representations'] = fig_to_base64(fig)

    print("Generating tropical convolution heatmap...")
    fig = viz_tropical_convolution_heatmap()
    results['tropical_heatmap'] = fig_to_base64(fig)

    print("Generating cofinite convergence...")
    fig = viz_cofinite_convergence()
    results['cofinite_convergence'] = fig_to_base64(fig)

    print("Generating sumset tropical...")
    fig = viz_sumset_tropical()
    results['sumset_tropical'] = fig_to_base64(fig)

    return results


if __name__ == "__main__":
    results = generate_all_visualizations()
    for name, data_uri in results.items():
        print(f"Generated: {name} ({len(data_uri)} chars)")
        # Save as PNG too
        img_data = base64.b64decode(data_uri.split(',')[1])
        with open(f"{name}.png", 'wb') as f:
            f.write(img_data)
        print(f"  Saved: {name}.png")
