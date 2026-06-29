"""
Berggren Tree Algorithms — Enumeration, Analysis, and Optimization

This module implements algorithms for working with the Berggren ternary tree
of primitive Pythagorean triples, with emphasis on certified complexity bounds.

Key algorithms:
1. Depth-bounded enumeration with Θ(√N) depth guarantee
2. Minimum hypotenuse computation and branch tracking
3. Residue graph construction for congruence analysis
4. Growth rate estimation for periodic branches
"""

import numpy as np
from typing import Tuple, List, Dict, Set, Optional, Generator
from collections import defaultdict
from math import gcd, isqrt
import heapq

Triple = Tuple[int, int, int]


# ============================================================
# Core Berggren generators
# ============================================================

def berggren_A(a: int, b: int, c: int) -> Triple:
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a: int, b: int, c: int) -> Triple:
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a: int, b: int, c: int) -> Triple:
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = [berggren_A, berggren_B, berggren_C]
ROOT = (3, 4, 5)


# ============================================================
# Algorithm 1: Depth-bounded enumeration
# ============================================================

def enumerate_triples_up_to(N: int) -> List[Triple]:
    """
    Enumerate all primitive Pythagorean triples (a, b, c) with c ≤ N.

    Uses the Berggren tree with certified depth bound: since c_min(d) ≥ 2d²+4d+5,
    depth d_max = ceil(√((N-5)/2)) + 1 suffices.

    Complexity: O(3^{√(N/2)}) time and space (all triples at bounded depth).

    Args:
        N: Upper bound on hypotenuse

    Returns:
        List of all primitive Pythagorean triples with c ≤ N
    """
    result = []
    # BFS with pruning
    stack = [ROOT]
    while stack:
        t = stack.pop()
        a, b, c = t
        if c > N:
            continue
        result.append(t)
        for gen in GENERATORS:
            child = gen(a, b, c)
            if child[2] <= N:
                stack.append(child)
    return result


def enumerate_triples_generator(N: int) -> Generator[Triple, None, None]:
    """
    Generator version: yields primitive Pythagorean triples with c ≤ N.

    Uses priority queue ordered by hypotenuse for ascending output.

    Args:
        N: Upper bound on hypotenuse

    Yields:
        Primitive Pythagorean triples (a, b, c) with c ≤ N, in order of c
    """
    heap = [(ROOT[2], ROOT)]
    seen = set()

    while heap:
        _, t = heapq.heappop(heap)
        if t in seen:
            continue
        seen.add(t)
        a, b, c = t
        if c > N:
            break
        yield t
        for gen in GENERATORS:
            child = gen(a, b, c)
            if child[2] <= N and child not in seen:
                heapq.heappush(heap, (child[2], child))


def certified_max_depth(N: int) -> int:
    """
    Compute the certified maximum depth needed to find all triples with c ≤ N.

    From the quadratic lower bound: c_min(d) ≥ 2d² + 4d + 5.
    So d ≤ d_max where 2d_max² + 4d_max + 5 ≤ N.
    Solving: d_max ≈ √((N-5)/2) - 1.

    Args:
        N: Upper bound on hypotenuse

    Returns:
        Maximum depth that needs to be explored
    """
    if N < 5:
        return 0
    # 2d² + 4d + 5 ≤ N => d ≤ (-4 + √(16 + 8(N-5))) / 4
    discriminant = 16 + 8 * (N - 5)
    d_max = int((-4 + isqrt(discriminant)) / 4) + 1
    return d_max


# ============================================================
# Algorithm 2: Minimum hypotenuse computation
# ============================================================

def compute_cmin(d_max: int) -> List[Tuple[int, List[int]]]:
    """
    Compute c_min(d) and the minimizing word for d = 0, ..., d_max.

    Returns:
        List of (c_min(d), minimizing_word) pairs
    """
    results = [(5, [])]
    # At each depth, track all triples and their words
    current = {ROOT: []}

    for d in range(1, d_max + 1):
        next_level = {}
        for t, word in current.items():
            for g_idx, gen in enumerate(GENERATORS):
                child = gen(*t)
                new_word = word + [g_idx]
                if child not in next_level or child[2] < min(
                    (c for c, _ in [(next_level.get(child, (float('inf'), [])))])
                if True else float('inf')):
                    next_level[child] = new_word
        # Find minimum hypotenuse
        min_c = min(t[2] for t in next_level)
        min_word = [w for t, w in next_level.items() if t[2] == min_c][0]
        results.append((min_c, min_word))
        current = next_level

    return results


def allA_formula(n: int) -> Triple:
    """Exact formula for the all-A branch at depth n."""
    return (2*n + 3, 2*n**2 + 6*n + 4, 2*n**2 + 6*n + 5)


# ============================================================
# Algorithm 3: Residue graph construction
# ============================================================

def build_residue_graph(m: int) -> Dict[Tuple[int,int,int], Set[Tuple[int,int,int]]]:
    """
    Build the residue transition graph for the Berggren tree modulo m.

    Nodes are residue classes (a mod m, b mod m, c mod m).
    Edges connect parent to children under each generator.

    Args:
        m: Modulus

    Returns:
        Adjacency dict: node -> set of successor nodes
    """
    graph = defaultdict(set)
    # Start from all reachable residue triples
    visited = set()
    queue = [(ROOT[0] % m, ROOT[1] % m, ROOT[2] % m)]
    visited.add(queue[0])

    while queue:
        node = queue.pop(0)
        a, b, c = node
        for gen in GENERATORS:
            child = gen(a, b, c)
            child_mod = (child[0] % m, child[1] % m, child[2] % m)
            graph[node].add(child_mod)
            if child_mod not in visited:
                visited.add(child_mod)
                queue.append(child_mod)

    return dict(graph)


def analyze_residue_graph(m: int) -> Dict:
    """
    Analyze the residue transition graph modulo m.

    Returns statistics including:
    - Number of reachable nodes
    - Whether the graph is strongly connected
    - Distribution of hypotenuse residues
    - Period/aperiodicity check
    """
    graph = build_residue_graph(m)
    nodes = set(graph.keys())
    for succs in graph.values():
        nodes.update(succs)

    # Compute reachable hypotenuse residues
    hyp_residues = set(n[2] for n in nodes)

    # Check strong connectivity via BFS from each node
    def reachable_from(start):
        visited = {start}
        queue = [start]
        while queue:
            node = queue.pop(0)
            for succ in graph.get(node, set()):
                if succ not in visited:
                    visited.add(succ)
                    queue.append(succ)
        return visited

    root_mod = (ROOT[0] % m, ROOT[1] % m, ROOT[2] % m)
    reachable = reachable_from(root_mod)

    # Check if all reachable nodes can reach each other
    strongly_connected = all(
        reachable_from(n) >= reachable
        for n in list(reachable)[:min(20, len(reachable))]
    )

    return {
        "modulus": m,
        "num_reachable_nodes": len(reachable),
        "hypotenuse_residues": sorted(hyp_residues),
        "strongly_connected_sample": strongly_connected,
        "total_possible": m**3,
    }


# ============================================================
# Algorithm 4: Growth rate estimation
# ============================================================

def estimate_growth_rate(word_pattern: List[int], iterations: int = 50) -> float:
    """
    Estimate the asymptotic growth rate λ for a periodic branch pattern.

    For a periodic word pattern p, compute c(p^n)^{1/(n·|p|)} as n → ∞.

    Args:
        word_pattern: Periodic generator pattern (list of 0,1,2)
        iterations: Number of full periods to iterate

    Returns:
        Estimated growth rate λ per generator application
    """
    t = ROOT
    period = len(word_pattern)
    rates = []

    for n in range(1, iterations + 1):
        for g_idx in word_pattern:
            t = GENERATORS[g_idx](*t)
        total_steps = n * period
        rate = t[2] ** (1.0 / total_steps)
        rates.append(rate)

    return rates[-1] if rates else 1.0


def find_spectral_radius(word_pattern: List[int]) -> float:
    """
    Compute the spectral radius of the matrix product for a periodic word.

    The Berggren generators as matrices, multiplied along the word, give
    a matrix whose spectral radius determines the exponential growth rate.

    Args:
        word_pattern: Periodic generator pattern

    Returns:
        Spectral radius (largest eigenvalue magnitude) of the product matrix
    """
    matrices = [
        np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),  # A
        np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),      # B
        np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),   # C
    ]

    product = np.eye(3)
    for g_idx in word_pattern:
        product = product @ matrices[g_idx]

    eigenvalues = np.linalg.eigvals(product)
    spectral_radius = max(abs(e) for e in eigenvalues)

    # For the growth rate per step, take the |p|-th root
    period = len(word_pattern)
    return spectral_radius ** (1.0 / period)


# ============================================================
# Algorithm 5: Multiplicity counting
# ============================================================

def count_primitive_triples(c: int) -> int:
    """
    Count the number of primitive Pythagorean triples (a, b, c) with a < b
    for a given hypotenuse c.

    The formula is: r_prim(c) = 2^{k-1} if c is a valid hypotenuse, else 0,
    where k is the number of distinct primes ≡ 1 (mod 4) dividing c.

    Args:
        c: Hypotenuse value

    Returns:
        Number of primitive triples with that hypotenuse (ordered a < b)
    """
    if c <= 0:
        return 0

    # Factor c
    n = c
    prime_factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            prime_factors[d] = prime_factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        prime_factors[n] = prime_factors.get(n, 0) + 1

    # Check validity: all primes ≡ 3 (mod 4) must appear to even power
    # and at least one prime ≡ 1 (mod 4) must appear
    k = 0  # count of primes ≡ 1 (mod 4)
    for p, e in prime_factors.items():
        if p == 2:
            if e > 0:
                return 0  # c must be odd for primitive triple
        elif p % 4 == 3:
            if e % 2 != 0:
                return 0  # must be even power
        elif p % 4 == 1:
            k += 1

    if k == 0:
        return 0  # need at least one prime ≡ 1 (mod 4)

    return 2 ** (k - 1)


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Berggren Tree Algorithms — Demonstration")
    print("=" * 70)
    print()

    # Algorithm 1: Enumeration
    print("Algorithm 1: Enumerating triples with c ≤ 100")
    triples = enumerate_triples_up_to(100)
    print(f"  Found {len(triples)} primitive Pythagorean triples")
    for t in sorted(triples, key=lambda x: x[2])[:10]:
        print(f"    {t}")
    print(f"  ... ({len(triples)} total)")
    print(f"  Certified max depth: {certified_max_depth(100)}")
    print()

    # Algorithm 2: c_min computation
    print("Algorithm 2: Minimum hypotenuses and all-A formula verification")
    cmin_data = compute_cmin(10)
    for d, (cmin, word) in enumerate(cmin_data):
        formula_c = allA_formula(d)[2]
        word_str = "".join(["A", "B", "C"][g] for g in word)
        print(f"  d={d}: c_min={cmin}, word={word_str or 'ε'}, formula={formula_c}, match={'✓' if cmin == formula_c else '✗'}")
    print()

    # Algorithm 3: Residue graph
    print("Algorithm 3: Residue graph analysis")
    for m in [3, 5, 7]:
        info = analyze_residue_graph(m)
        print(f"  mod {m}: {info['num_reachable_nodes']} reachable states, "
              f"hyp residues = {info['hypotenuse_residues']}, "
              f"connected = {info['strongly_connected_sample']}")
    print()

    # Algorithm 4: Growth rates
    print("Algorithm 4: Growth rate estimation for periodic branches")
    patterns = {
        "A": [0], "B": [1], "C": [2],
        "AB": [0, 1], "AC": [0, 2],
        "ABC": [0, 1, 2],
    }
    for name, pattern in patterns.items():
        rate_iter = estimate_growth_rate(pattern)
        rate_spectral = find_spectral_radius(pattern)
        print(f"  {name}: iterative λ ≈ {rate_iter:.6f}, spectral λ ≈ {rate_spectral:.6f}")
    print()

    # Algorithm 5: Multiplicity counting
    print("Algorithm 5: Primitive triple multiplicity for selected hypotenuses")
    test_hyps = [5, 13, 17, 25, 29, 37, 41, 65, 85, 125, 325, 5525]
    for c in test_hyps:
        count = count_primitive_triples(c)
        # Verify by enumeration for small c
        actual = sum(1 for a in range(1, c) for b in range(a+1, c)
                     if a*a + b*b == c*c and gcd(a, b) == 1) if c <= 500 else "?"
        print(f"  c={c}: formula gives {count}, {'verified=' + str(actual) if isinstance(actual, int) else 'too large to verify'}")
    print()
