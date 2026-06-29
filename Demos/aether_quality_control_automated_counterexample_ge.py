#!/usr/bin/env python3
"""
Applications of Certified Refutation Layers

Demonstrates real-world applications of the stress-testing framework:
1. Number theory conjecture triage
2. Combinatorial identity verification
3. Graph property testing
4. Automated conjecture pipeline simulation
"""

from typing import Callable, Set, Dict, List, Optional, Tuple
from itertools import combinations
import random
import math

random.seed(42)


# ============================================================
# APPLICATION 1: Number Theory Conjecture Triage
# ============================================================

def number_theory_triage():
    """
    Stress-test number theory conjectures over bounded domains.
    Demonstrates how finite testing eliminates false conjectures
    before expensive proof attempts.
    """
    print("=" * 60)
    print("APPLICATION 1: Number Theory Conjecture Triage")
    print("=" * 60)
    print()

    domain = set(range(2, 100))

    def is_prime(n: int) -> bool:
        if n < 2: return False
        for d in range(2, int(n**0.5) + 1):
            if n % d == 0: return False
        return True

    # A family of number-theoretic conjectures (some true, some false)
    conjectures = {
        "All primes > 2 are odd":
            lambda n: not is_prime(n) or n == 2 or n % 2 == 1,
        "n² + n + 41 is always prime (Euler)":
            lambda n: is_prime(n*n + n + 41),
        "Every even n > 2 is sum of two primes (Goldbach, bounded)":
            lambda n: n % 2 != 0 or n <= 2 or any(
                is_prime(k) and is_prime(n - k) for k in range(2, n)),
        "2^n - 1 is prime whenever n is prime":
            lambda n: not is_prime(n) or is_prime(2**n - 1),
        "n! + 1 is never divisible by n+2":
            lambda n: (math.factorial(n) + 1) % (n + 2) != 0,
        "Sum of digits of n² < 50":
            lambda n: sum(int(d) for d in str(n*n)) < 50,
        "All primes are of form 6k±1 (except 2,3)":
            lambda n: not is_prime(n) or n <= 3 or n % 6 == 1 or n % 6 == 5,
        "n² mod 4 ∈ {0, 1}":
            lambda n: (n*n) % 4 in {0, 1},
    }

    test_sets = [
        ("Small", set(range(2, 10))),
        ("Medium", set(range(2, 30))),
        ("Large", set(range(2, 50))),
        ("Full", domain),
    ]

    for conj_name, pred in conjectures.items():
        print(f"  Conjecture: {conj_name}")
        for test_name, T in test_sets:
            cex = [x for x in T if not pred(x)]
            if cex:
                print(f"    [{test_name:6s}] REFUTED at x = {cex[0]}")
                break
        else:
            cex_full = [x for x in domain if not pred(x)]
            if cex_full:
                print(f"    [Full  ] REFUTED at x = {cex_full[0]} (needed full search)")
            else:
                print(f"    [Full  ] SURVIVES → candidate for proof")
        print()


# ============================================================
# APPLICATION 2: Combinatorial Identity Verification
# ============================================================

def combinatorial_verification():
    """
    Verify combinatorial identities by stress-testing on small values.
    """
    print("=" * 60)
    print("APPLICATION 2: Combinatorial Identity Stress Testing")
    print("=" * 60)
    print()

    def binom(n, k):
        if k < 0 or k > n: return 0
        return math.comb(n, k)

    # Conjectures about binomial coefficients
    identities = {
        "Vandermonde: C(m+n,r) = Σ C(m,k)C(n,r-k)":
            lambda args: (lambda m, n, r: binom(m+n, r) ==
                sum(binom(m, k) * binom(n, r-k) for k in range(r+1)))(*args),
        "Hockey stick: Σ_{i=0}^{r} C(n+i,i) = C(n+r+1,r)":
            lambda args: (lambda n, r, _: sum(binom(n+i, i) for i in range(r+1)) ==
                binom(n+r+1, r))(*args),
        "FALSE: C(n,k) = C(n,k+1) always":
            lambda args: (lambda n, k, _: binom(n, k) == binom(n, k+1))(*args),
        "Symmetry: C(n,k) = C(n,n-k)":
            lambda args: (lambda n, k, _: binom(n, k) == binom(n, n-k))(*args),
    }

    # Domain: triples (m, n, r) with 0 ≤ m,n,r ≤ 8
    domain = {(m, n, r) for m in range(9) for n in range(9) for r in range(9)}
    test_set = {(m, n, r) for m in range(5) for n in range(5) for r in range(5)}

    for name, pred in identities.items():
        cex_test = [x for x in test_set if not pred(x)]
        cex_full = [x for x in domain if not pred(x)]
        if cex_test:
            print(f"  {name}")
            print(f"    REFUTED by small test at {cex_test[0]}")
        elif cex_full:
            print(f"  {name}")
            print(f"    Passed small test but REFUTED at {cex_full[0]}")
        else:
            print(f"  {name}")
            print(f"    SURVIVES all {len(domain)} tests → candidate for proof")
        print()


# ============================================================
# APPLICATION 3: Graph Property Testing
# ============================================================

def graph_property_testing():
    """
    Test conjectures about small graphs using exhaustive search.
    """
    print("=" * 60)
    print("APPLICATION 3: Graph Property Testing")
    print("=" * 60)
    print()

    # Represent graphs on n=4 vertices as adjacency sets
    n = 4
    vertices = set(range(n))
    all_edges = [(i, j) for i in range(n) for j in range(i+1, n)]

    # Enumerate all graphs (2^6 = 64 for n=4)
    all_graphs = []
    for r in range(len(all_edges) + 1):
        for edges in combinations(all_edges, r):
            all_graphs.append(frozenset(edges))

    print(f"Domain: all graphs on {n} vertices ({len(all_graphs)} graphs)")

    def degree(graph, v):
        return sum(1 for e in graph if v in e)

    def is_connected(graph):
        if not graph:
            return n <= 1
        adj = {v: set() for v in vertices}
        for (u, v) in graph:
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        stack = [0]
        while stack:
            v = stack.pop()
            if v in visited: continue
            visited.add(v)
            stack.extend(adj[v] - visited)
        return len(visited) == n

    def num_edges(graph):
        return len(graph)

    # Conjectures
    conjectures = {
        "Connected graph has ≥ n-1 edges":
            lambda g: not is_connected(g) or num_edges(g) >= n - 1,
        "Sum of degrees = 2|E|":
            lambda g: sum(degree(g, v) for v in vertices) == 2 * num_edges(g),
        "Max degree < n":
            lambda g: all(degree(g, v) < n for v in vertices),
        "FALSE: Connected iff ≥ n edges":
            lambda g: is_connected(g) == (num_edges(g) >= n),
    }

    # Test with graphs having ≤ 3 edges first
    small_graphs = [g for g in all_graphs if len(g) <= 3]
    print(f"Small test set: graphs with ≤ 3 edges ({len(small_graphs)} graphs)")
    print()

    for name, pred in conjectures.items():
        cex_small = [g for g in small_graphs if not pred(g)]
        cex_all = [g for g in all_graphs if not pred(g)]

        if cex_small:
            print(f"  {name}")
            print(f"    REFUTED by small graph: edges = {set(cex_small[0])}")
        elif cex_all:
            print(f"  {name}")
            print(f"    Passed small test, REFUTED by: edges = {set(cex_all[0])}")
        else:
            print(f"  {name}")
            print(f"    SURVIVES all {len(all_graphs)} graphs → candidate for proof")
        print()


# ============================================================
# APPLICATION 4: Automated Pipeline Simulation
# ============================================================

def pipeline_simulation():
    """
    Simulate a full conjecture discovery pipeline with stress testing.
    Compare naive vs. stress-test-first approaches.
    """
    print("=" * 60)
    print("APPLICATION 4: Pipeline Simulation (1000 conjectures)")
    print("=" * 60)
    print()

    domain = set(range(50))
    n_conjectures = 1000

    # Generate random conjectures with varying "truth rates"
    conjectures = {}
    ground_truth = {}  # True if conjecture is universally true
    for i in range(n_conjectures):
        # ~30% of conjectures are true, 70% are false
        if random.random() < 0.3:
            conjectures[i] = lambda x: True
            ground_truth[i] = True
        else:
            # Random bad set of size 1-10
            bad = set(random.sample(range(50), random.randint(1, 10)))
            conjectures[i] = lambda x, b=bad: x not in b
            ground_truth[i] = False

    n_true = sum(1 for v in ground_truth.values() if v)
    n_false = n_conjectures - n_true
    print(f"Generated {n_conjectures} conjectures: {n_true} true, {n_false} false")

    # Simulate pipeline costs
    COST_TEST = 0.01  # Cost per (conjecture, test point) evaluation
    COST_PROOF = 10.0  # Cost per proof attempt
    COST_PROOF_SUCCESS = 5.0  # Additional cost for successful proof

    print(f"\nCost model: test={COST_TEST}/eval, proof_attempt={COST_PROOF}, proof_success={COST_PROOF_SUCCESS}")

    # Naive pipeline
    naive_total = n_conjectures * COST_PROOF + n_true * COST_PROOF_SUCCESS
    print(f"\nNaive pipeline:")
    print(f"  Proof attempts: {n_conjectures}")
    print(f"  Successful proofs: {n_true}")
    print(f"  Wasted attempts (on false conjectures): {n_false}")
    print(f"  Total cost: {naive_total:.0f}")

    # Stress-test pipeline with greedy test design
    print(f"\nStress-test pipeline:")
    for budget in [5, 10, 20, 30, 50]:
        # Pick test points (greedy: most-refuting first)
        point_kills = {}
        for x in domain:
            kills = sum(1 for i, pred in conjectures.items()
                       if not pred(x) and not ground_truth[i])
            point_kills[x] = kills

        T = set(sorted(point_kills, key=point_kills.get, reverse=True)[:budget])

        # Compute survivors
        survivors = []
        false_positives = 0
        for i, pred in conjectures.items():
            if all(pred(x) for x in T):
                survivors.append(i)
                if not ground_truth[i]:
                    false_positives += 1

        test_cost = n_conjectures * len(T) * COST_TEST
        proof_cost = len(survivors) * COST_PROOF + n_true * COST_PROOF_SUCCESS
        total = test_cost + proof_cost
        savings_pct = 100 * (naive_total - total) / naive_total

        print(f"  |T|={budget:2d}: survivors={len(survivors):4d} "
              f"(FP={false_positives:3d}), "
              f"cost={total:7.0f}, "
              f"savings={savings_pct:+5.1f}%")


# ============================================================
# Run all applications
# ============================================================

if __name__ == "__main__":
    number_theory_triage()
    print()
    combinatorial_verification()
    print()
    graph_property_testing()
    print()
    pipeline_simulation()

    print()
    print("=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Aether Stress Testing: Demonstrations of Certified Refutation Theory

This module demonstrates the core theorems of the certified refutation layer
with concrete numerical examples over finite domains.

Examples include:
1. Complete test set exactness (Theorem 1)
2. Maximal scored counterexample extraction (Theorem 2)
3. False-positive count monotonicity (Theorem 3)
4. Bounded counterexample detection (Theorem 4)
"""

from typing import Callable, Optional
from itertools import combinations


def survives_test(T: set, P: Callable, domain: set) -> bool:
    """Check if predicate P survives stress test T."""
    return all(P(x) for x in T)


def has_counterexample(P: Callable, domain: set) -> bool:
    """Check if P has any counterexample in domain."""
    return any(not P(x) for x in domain)


def counterexample_set(P: Callable, domain: set) -> set:
    """Return the set of all counterexamples to P in domain."""
    return {x for x in domain if not P(x)}


def false_positive_count(Q: dict, T: set, domain: set) -> int:
    """
    Count false positives: conjectures that are false but pass all tests in T.

    Q: dict mapping conjecture index -> predicate function
    T: test set
    domain: full domain
    """
    count = 0
    for idx, pred in Q.items():
        is_false = any(not pred(x) for x in domain)
        passes_test = all(pred(x) for x in T)
        if is_false and passes_test:
            count += 1
    return count


def find_max_scored_counterexample(
    P: Callable, score: Callable, domain: set
) -> Optional[tuple]:
    """Find the counterexample with maximum score, or None if P holds everywhere."""
    cex = counterexample_set(P, domain)
    if not cex:
        return None
    best = max(cex, key=score)
    return (best, score(best))


# ============================================================
# DEMO 1: Complete Test Set Exactness
# ============================================================
print("=" * 70)
print("DEMO 1: Complete Test Set Exactness (Theorem 1)")
print("=" * 70)
print()

domain = set(range(20))

# Conjecture: "all numbers less than 20 are less than 15"
P1 = lambda x: x < 15
counterexamples_P1 = counterexample_set(P1, domain)
print(f"Conjecture P1: 'x < 15' for x in {{0,...,19}}")
print(f"Counterexamples: {sorted(counterexamples_P1)}")

# Incomplete test set: {0, 1, 2, 3, 4}
T_incomplete = {0, 1, 2, 3, 4}
print(f"\nIncomplete test set T = {sorted(T_incomplete)}")
print(f"  Survives test: {survives_test(T_incomplete, P1, domain)}")
print(f"  But conjecture is FALSE (counterexamples exist outside T)")

# Complete test set: contains all counterexamples
T_complete = counterexamples_P1 | {0, 1, 2}
print(f"\nComplete test set T = {sorted(T_complete)}")
print(f"  Survives test: {survives_test(T_complete, P1, domain)}")
print(f"  Conjecture is correctly identified as FALSE")

# True conjecture
P2 = lambda x: x < 100
T_any = {5, 10, 15}
print(f"\nConjecture P2: 'x < 100' for x in {{0,...,19}}")
print(f"  Test set T = {sorted(T_any)}")
print(f"  Any test set is complete (no counterexamples exist)")
print(f"  Survives test: {survives_test(T_any, P2, domain)}")
print(f"  Conjecture is TRUE: {not has_counterexample(P2, domain)}")

# ============================================================
# DEMO 2: Maximal Scored Counterexample
# ============================================================
print()
print("=" * 70)
print("DEMO 2: Maximal Scored Counterexample (Theorem 2)")
print("=" * 70)
print()

domain_fin10 = set(range(10))

# Conjecture: "x is even"
P_even = lambda x: x % 2 == 0
score_fn = lambda x: x * x  # score = x^2 (harder = larger)

cex = counterexample_set(P_even, domain_fin10)
print(f"Conjecture: 'x is even' for x in {{0,...,9}}")
print(f"Counterexamples: {sorted(cex)}")
print(f"Score function: score(x) = x²")

result = find_max_scored_counterexample(P_even, score_fn, domain_fin10)
print(f"\nMaximal scored counterexample: x = {result[0]}, score = {result[1]}")
print(f"All counterexample scores: {[(x, score_fn(x)) for x in sorted(cex)]}")
print(f"Verified: {result[0]} has the highest score among all counterexamples")

# ============================================================
# DEMO 3: False-Positive Count Monotonicity
# ============================================================
print()
print("=" * 70)
print("DEMO 3: False-Positive Count Monotonicity (Theorem 3)")
print("=" * 70)
print()

domain_small = set(range(8))

# Family of 10 conjectures: Q_i(x) = (x + i) % 3 != 0
conjectures = {}
for i in range(10):
    conjectures[i] = lambda x, i=i: (x + i) % 3 != 0

print(f"Domain: {{0,...,7}}")
print(f"Conjecture family: Q_i(x) = '(x + i) mod 3 ≠ 0' for i = 0..9")
print()

# Progressively larger test sets
test_sets = [
    set(),
    {0},
    {0, 1},
    {0, 1, 2},
    {0, 1, 2, 3},
    {0, 1, 2, 3, 4},
    {0, 1, 2, 3, 4, 5},
    {0, 1, 2, 3, 4, 5, 6},
    {0, 1, 2, 3, 4, 5, 6, 7},
]

fp_counts = []
for T in test_sets:
    fp = false_positive_count(conjectures, T, domain_small)
    fp_counts.append(fp)
    print(f"  |T| = {len(T):2d}, T = {str(sorted(T)):<30s} → FP count = {fp}")

print()
print("Monotonicity verified:", all(fp_counts[i] >= fp_counts[i+1] for i in range(len(fp_counts)-1)))

# Show strict drop
for i in range(len(fp_counts) - 1):
    if fp_counts[i] > fp_counts[i+1]:
        print(f"  Strict drop at |T| = {len(test_sets[i])} → {len(test_sets[i+1])}: "
              f"FP {fp_counts[i]} → {fp_counts[i+1]}")

# ============================================================
# DEMO 4: Bounded Counterexample Detection
# ============================================================
print()
print("=" * 70)
print("DEMO 4: Bounded Counterexample Detection (Theorem 4)")
print("=" * 70)
print()

# Conjecture: "all primes less than 50 are odd"
def is_prime(n):
    if n < 2:
        return False
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            return False
    return True

domain_50 = set(range(50))
P_prime_odd = lambda x: not is_prime(x) or x % 2 != 0
complexity_fn = lambda x: x  # complexity = value itself

print("Conjecture: 'all primes are odd' over {0,...,49}")
cex_prime = counterexample_set(P_prime_odd, domain_50)
print(f"Counterexamples: {sorted(cex_prime)}")

for B in [1, 2, 3, 5, 10]:
    T_bounded = {x for x in domain_50 if complexity_fn(x) <= B}
    bounded_cex = {x for x in cex_prime if complexity_fn(x) <= B}
    detected = any(not P_prime_odd(x) for x in T_bounded)
    print(f"  B = {B:2d}: T covers complexity ≤ {B}, "
          f"bounded counterexamples = {sorted(bounded_cex)}, "
          f"detected = {detected}")

# ============================================================
# DEMO 5: Pipeline Cost Comparison
# ============================================================
print()
print("=" * 70)
print("DEMO 5: Pipeline Cost Comparison")
print("=" * 70)
print()

import random
random.seed(42)

n_conjectures = 100
domain_size = 20
domain_pipe = set(range(domain_size))

# Generate random conjectures (some true, some false)
def make_random_conjecture():
    """Make a random conjecture: 'x not in S' for random subset S."""
    bad_set = set(random.sample(range(domain_size), random.randint(0, 5)))
    return lambda x, bs=bad_set: x not in bs, len(bad_set) > 0

conj_list = [make_random_conjecture() for _ in range(n_conjectures)]
predicates = {i: c[0] for i, c in enumerate(conj_list)}
is_false = {i: c[1] for i, c in enumerate(conj_list)}

n_false = sum(1 for v in is_false.values() if v)
print(f"Generated {n_conjectures} random conjectures")
print(f"  True: {n_conjectures - n_false}, False: {n_false}")

cost_test_per_point = 1
cost_proof_attempt = 50

# Naive pipeline: attempt proof on all
naive_cost = n_conjectures * cost_proof_attempt
print(f"\nNaive pipeline (prove all): cost = {n_conjectures} × {cost_proof_attempt} = {naive_cost}")

# Stress-test pipeline with increasing test set sizes
for test_size in [1, 3, 5, 10, 15, 20]:
    T = set(random.sample(range(domain_size), min(test_size, domain_size)))
    fp = false_positive_count(predicates, T, domain_pipe)
    survivors = sum(1 for i in range(n_conjectures) if all(predicates[i](x) for x in T))
    test_cost = n_conjectures * test_size * cost_test_per_point
    proof_cost = survivors * cost_proof_attempt
    total_cost = test_cost + proof_cost
    savings = naive_cost - total_cost
    print(f"  |T| = {test_size:2d}: test cost = {test_cost:5d}, "
          f"survivors = {survivors:3d} (FP = {fp:2d}), "
          f"proof cost = {proof_cost:5d}, "
          f"total = {total_cost:5d}, savings = {savings:+5d}")


if __name__ == "__main__":
    print()
    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Certified Refutation Layer Theory

Generates publication-quality figures demonstrating:
1. False-positive count monotonicity
2. Pipeline cost comparison
3. Greedy test design effectiveness
4. Counterexample score distributions
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import base64
import io

random.seed(42)
np.random.seed(42)

# Style
plt.rcParams.update({
    'font.size': 12,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
    'figure.dpi': 150,
    'figure.facecolor': 'white',
})


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 string."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', bbox_inches='tight', dpi=150)
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


# ============================================================
# FIGURE 1: False-Positive Count Monotonicity
# ============================================================

def plot_fp_monotonicity():
    domain = set(range(20))

    conjectures = {}
    for i in range(30):
        bad = set(random.sample(range(20), random.randint(0, 5)))
        conjectures[i] = lambda x, b=bad: x not in b

    test_sizes = list(range(21))
    fp_counts = []

    # Build test sets incrementally using greedy approach
    T = set()
    remaining = set(domain)

    for size in test_sizes:
        fp = 0
        for idx, pred in conjectures.items():
            is_false = any(not pred(x) for x in domain)
            passes = all(pred(x) for x in T)
            if is_false and passes:
                fp += 1
        fp_counts.append(fp)
        if remaining:
            # Add the most-refuting point
            best = max(remaining, key=lambda x: sum(1 for pred in conjectures.values() if not pred(x)))
            T.add(best)
            remaining.discard(best)

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(test_sizes, fp_counts, 'b-o', markersize=6, linewidth=2, label='False Positives')
    ax.fill_between(test_sizes, fp_counts, alpha=0.15, color='blue')
    ax.set_xlabel('Test Set Size |T|')
    ax.set_ylabel('False-Positive Count FP(T)')
    ax.set_title('Theorem 3: False-Positive Count is Antitone in Test Set Size')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 20)
    ax.set_ylim(bottom=0)

    # Annotate strict drops
    for i in range(len(fp_counts) - 1):
        if fp_counts[i] > fp_counts[i+1]:
            ax.annotate(f'−{fp_counts[i]-fp_counts[i+1]}',
                       xy=(i+1, fp_counts[i+1]),
                       xytext=(i+1.5, fp_counts[i+1] + 1),
                       fontsize=8, color='red',
                       arrowprops=dict(arrowstyle='->', color='red', lw=0.5))

    fig.savefig('/workspace/request-project/fig_fp_monotonicity.png', bbox_inches='tight', dpi=150)
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# FIGURE 2: Pipeline Cost Comparison
# ============================================================

def plot_pipeline_cost():
    domain = set(range(50))
    n_conj = 200

    conjectures = {}
    ground_truth = {}
    for i in range(n_conj):
        if random.random() < 0.3:
            conjectures[i] = lambda x: True
            ground_truth[i] = True
        else:
            bad = set(random.sample(range(50), random.randint(1, 8)))
            conjectures[i] = lambda x, b=bad: x not in b
            ground_truth[i] = False

    COST_TEST = 0.5
    COST_PROOF = 50.0

    test_sizes = list(range(0, 51, 1))
    total_costs = []
    test_costs_list = []
    proof_costs_list = []
    naive_cost = n_conj * COST_PROOF

    for ts in test_sizes:
        if ts == 0:
            T = set()
        else:
            # Greedy selection
            point_kills = {x: sum(1 for i, pred in conjectures.items() if not pred(x)) for x in domain}
            T = set(sorted(point_kills, key=point_kills.get, reverse=True)[:ts])

        survivors = sum(1 for i, pred in conjectures.items() if all(pred(x) for x in T))
        tc = n_conj * ts * COST_TEST
        pc = survivors * COST_PROOF
        total_costs.append(tc + pc)
        test_costs_list.append(tc)
        proof_costs_list.append(pc)

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.plot(test_sizes, total_costs, 'b-', linewidth=2, label='Total Cost (test + proof)')
    ax.plot(test_sizes, test_costs_list, 'g--', linewidth=1.5, label='Test Cost')
    ax.plot(test_sizes, proof_costs_list, 'r--', linewidth=1.5, label='Proof Cost')
    ax.axhline(y=naive_cost, color='gray', linestyle=':', linewidth=1.5, label=f'Naive Cost ({naive_cost:.0f})')

    opt_idx = np.argmin(total_costs)
    ax.plot(test_sizes[opt_idx], total_costs[opt_idx], 'k*', markersize=15)
    ax.annotate(f'Optimal: |T|={test_sizes[opt_idx]}\nCost={total_costs[opt_idx]:.0f}',
               xy=(test_sizes[opt_idx], total_costs[opt_idx]),
               xytext=(test_sizes[opt_idx]+5, total_costs[opt_idx]+500),
               fontsize=10,
               arrowprops=dict(arrowstyle='->', color='black'))

    ax.set_xlabel('Test Set Size |T|')
    ax.set_ylabel('Cost')
    ax.set_title('Pipeline Cost: Stress Testing vs. Naive Proof-All')
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/fig_pipeline_cost.png', bbox_inches='tight', dpi=150)
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# FIGURE 3: Counterexample Score Distribution
# ============================================================

def plot_score_distribution():
    domain = set(range(100))

    # Conjecture: "x is not a perfect square"
    P = lambda x: int(x**0.5)**2 != x
    score = lambda x: x  # higher value = harder

    cex = sorted([x for x in domain if not P(x)])
    non_cex = sorted([x for x in domain if P(x)])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: score distribution
    ax1.bar([score(x) for x in cex], [1]*len(cex), color='red', alpha=0.7, label='Counterexamples')
    ax1.set_xlabel('Score (= value)')
    ax1.set_ylabel('Count')
    ax1.set_title('Counterexample Score Distribution')
    ax1.legend()
    ax1.set_xlim(-1, 100)

    # Highlight max-scored counterexample
    max_cex = max(cex, key=score)
    ax1.annotate(f'Max: x={max_cex}\nscore={score(max_cex)}',
                xy=(score(max_cex), 1),
                xytext=(score(max_cex)-20, 1.3),
                fontsize=10, color='darkred',
                arrowprops=dict(arrowstyle='->', color='darkred'))

    # Right: cumulative refutation
    bounded_cex_counts = []
    for B in range(101):
        bounded_cex_counts.append(len([x for x in cex if score(x) <= B]))

    ax2.plot(range(101), bounded_cex_counts, 'r-', linewidth=2)
    ax2.fill_between(range(101), bounded_cex_counts, alpha=0.15, color='red')
    ax2.set_xlabel('Complexity Bound B')
    ax2.set_ylabel('Counterexamples Found (complexity ≤ B)')
    ax2.set_title('Theorem 4: Bounded Detection Coverage')
    ax2.grid(True, alpha=0.3)

    # Mark where first counterexample is found
    first_B = next(B for B in range(101) if bounded_cex_counts[B] > 0)
    ax2.axvline(x=first_B, color='green', linestyle='--', alpha=0.7)
    ax2.annotate(f'First detection\nat B={first_B}',
                xy=(first_B, 0.5),
                xytext=(first_B+15, 2),
                fontsize=10, color='green',
                arrowprops=dict(arrowstyle='->', color='green'))

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_score_distribution.png', bbox_inches='tight', dpi=150)
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ============================================================
# FIGURE 4: Greedy vs Random Test Design
# ============================================================

def plot_greedy_vs_random():
    domain = set(range(30))
    n_conj = 50

    conjectures = {}
    for i in range(n_conj):
        bad = set(random.sample(range(30), random.randint(0, 6)))
        conjectures[i] = lambda x, b=bad: x not in b

    n_false = sum(1 for pred in conjectures.values() if any(not pred(x) for x in domain))

    def compute_fp(T):
        return sum(1 for pred in conjectures.values()
                  if any(not pred(x) for x in domain) and all(pred(x) for x in T))

    # Greedy test design
    greedy_fps = [compute_fp(set())]
    T_greedy = set()
    remaining = set(domain)
    for step in range(len(domain)):
        best = max(remaining, key=lambda x: sum(1 for pred in conjectures.values() if not pred(x)))
        T_greedy.add(best)
        remaining.discard(best)
        greedy_fps.append(compute_fp(T_greedy))

    # Random test design (average over 20 trials)
    n_trials = 20
    random_fps_all = []
    for trial in range(n_trials):
        perm = list(domain)
        random.shuffle(perm)
        T_rand = set()
        trial_fps = [compute_fp(set())]
        for x in perm:
            T_rand.add(x)
            trial_fps.append(compute_fp(T_rand))
        random_fps_all.append(trial_fps)

    random_fps_mean = np.mean(random_fps_all, axis=0)
    random_fps_std = np.std(random_fps_all, axis=0)

    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    sizes = list(range(len(domain) + 1))

    ax.fill_between(sizes,
                    random_fps_mean - random_fps_std,
                    random_fps_mean + random_fps_std,
                    alpha=0.15, color='orange')
    ax.plot(sizes, random_fps_mean, 'orange', linewidth=2, linestyle='--', label='Random (mean ± std)')
    ax.plot(sizes, greedy_fps, 'b-o', markersize=4, linewidth=2, label='Greedy (optimal)')

    ax.set_xlabel('Test Set Size |T|')
    ax.set_ylabel('False-Positive Count')
    ax.set_title('Greedy vs. Random Test Design')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 30)
    ax.set_ylim(bottom=0)

    fig.savefig('/workspace/request-project/fig_greedy_vs_random.png', bbox_inches='tight', dpi=150)
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_fp_monotonicity()
    print(f"  fig_fp_monotonicity.png generated ({len(b64_1)} chars base64)")
    b64_2 = plot_pipeline_cost()
    print(f"  fig_pipeline_cost.png generated ({len(b64_2)} chars base64)")
    b64_3 = plot_score_distribution()
    print(f"  fig_score_distribution.png generated ({len(b64_3)} chars base64)")
    b64_4 = plot_greedy_vs_random()
    print(f"  fig_greedy_vs_random.png generated ({len(b64_4)} chars base64)")
    print("All visualizations generated successfully.")

    # Save base64 strings for PACKAGE.json
    import json
    viz_data = {
        "fp_monotonicity": f"data:image/png;base64,{b64_1}",
        "pipeline_cost": f"data:image/png;base64,{b64_2}",
        "score_distribution": f"data:image/png;base64,{b64_3}",
        "greedy_vs_random": f"data:image/png;base64,{b64_4}",
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Saved base64 data to viz_data.json")
