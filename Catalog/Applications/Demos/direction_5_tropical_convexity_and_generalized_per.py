#!/usr/bin/env python3
"""
Applications of M-Convex Sets and Generalized Permutohedra

Demonstrates real-world connections:
1. Matroid theory and scheduling optimization
2. Pythagorean triples and lattice geometry
3. Tropical valuations and p-adic structure
4. Discrete convex optimization
"""

import math
import itertools
from typing import List, Tuple, Set, Dict, FrozenSet
from collections import defaultdict


# ──────────────────────────────────────────────────────────────────
# Application 1: Scheduling via Generalized Permutohedra
# ──────────────────────────────────────────────────────────────────

def scheduling_permutohedron(tasks: List[int], machines: int) -> Dict:
    """Model a machine scheduling problem as optimization over a generalized permutohedron.

    Given task durations and number of machines, the feasible load vectors
    form a generalized permutohedron (the base polytope of a partition matroid).

    The optimal schedule minimizes the makespan (maximum load).

    Args:
        tasks: List of task durations
        machines: Number of machines

    Returns:
        Dictionary with optimal schedule and analysis
    """
    n = len(tasks)
    total = sum(tasks)

    # Generate all feasible assignments
    # Each assignment maps tasks to machines
    best_makespan = float('inf')
    best_assignment = None
    all_loads = set()

    for assignment in itertools.product(range(machines), repeat=n):
        loads = [0] * machines
        for task_idx, machine in enumerate(assignment):
            loads[machine] += tasks[task_idx]
        loads_tuple = tuple(sorted(loads, reverse=True))
        all_loads.add(loads_tuple)

        makespan = max(loads)
        if makespan < best_makespan:
            best_makespan = makespan
            best_assignment = assignment

    return {
        "tasks": tasks,
        "machines": machines,
        "total_work": total,
        "optimal_makespan": best_makespan,
        "optimal_assignment": best_assignment,
        "num_feasible_loads": len(all_loads),
        "ideal_makespan": math.ceil(total / machines),
    }


# ──────────────────────────────────────────────────────────────────
# Application 2: Pythagorean Lattice Geometry
# ──────────────────────────────────────────────────────────────────

def pythagorean_lattice_structure(N: int) -> Dict:
    """Analyze the M-convex structure of Pythagorean triples.

    For each hypotenuse c, the set of (a², b²) pairs forms a
    1-dimensional structure with constant sum c².

    Args:
        N: Maximum hypotenuse

    Returns:
        Analysis of Pythagorean lattice structure
    """
    triples_by_c = defaultdict(list)

    for c in range(5, N + 1):
        for a in range(1, c):
            b_sq = c * c - a * a
            b = int(math.isqrt(b_sq))
            if b > 0 and b * b == b_sq and a <= b:
                triples_by_c[c].append((a, b, c))

    results = {}
    for c in sorted(triples_by_c.keys()):
        triples = triples_by_c[c]
        squared_vecs = [(a**2, b**2, c**2) for a, b, _ in triples]

        # Verify constant sum property: a² + b² + c² = 2c²
        sums = [v[0] + v[1] + v[2] for v in squared_vecs]
        constant_sum = len(set(sums)) <= 1

        results[c] = {
            "triples": triples,
            "squared_vectors": squared_vecs,
            "constant_sum": constant_sum,
            "sum_value": sums[0] if sums else None,
            "expected_2c2": 2 * c * c,
            "count": len(triples),
        }

    return results


# ──────────────────────────────────────────────────────────────────
# Application 3: Tropical Valuation Analysis
# ──────────────────────────────────────────────────────────────────

def padic_valuation(n: int, p: int) -> int:
    """Compute the p-adic valuation v_p(n)."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def tropical_pythagorean_map(a: int, b: int, c: int, p: int) -> Tuple[int, int, int]:
    """Map a Pythagorean triple to its tropical (p-adic valuation) image.

    The tropical Pythagorean relation:
    min(2·v_p(a), 2·v_p(b)) = 2·v_p(c) when a²+b²=c² (for most p).
    """
    return (padic_valuation(a, p), padic_valuation(b, p), padic_valuation(c, p))


def analyze_tropical_pythagorean(N: int, primes: List[int]) -> Dict:
    """Analyze tropical structure of Pythagorean triples under p-adic valuations.

    Args:
        N: Maximum hypotenuse
        primes: List of primes to analyze

    Returns:
        Tropical analysis results
    """
    triples = []
    for c in range(5, N + 1):
        for a in range(3, c):
            b_sq = c * c - a * a
            b = int(math.isqrt(b_sq))
            if b > 0 and b * b == b_sq and a < b:
                if math.gcd(a, math.gcd(b, c)) == 1:
                    triples.append((a, b, c))

    results = {}
    for p in primes:
        tropical_images = []
        for a, b, c in triples:
            trop = tropical_pythagorean_map(a, b, c, p)
            tropical_images.append({
                "triple": (a, b, c),
                "tropical": trop,
                "min_relation": min(2 * trop[0], 2 * trop[1]),
                "double_val_c": 2 * trop[2],
            })

        # Check tropical min-plus relation
        satisfies_tropical = sum(
            1 for img in tropical_images
            if img["min_relation"] >= img["double_val_c"]
        )

        results[p] = {
            "total_triples": len(triples),
            "tropical_images": tropical_images[:5],  # First 5 for display
            "satisfies_tropical_relation": satisfies_tropical,
        }

    return results


# ──────────────────────────────────────────────────────────────────
# Application 4: Discrete Convex Optimization
# ──────────────────────────────────────────────────────────────────

def mconvex_optimization(S: Set[Tuple[int, ...]], objective: callable, n: int) -> Dict:
    """Optimize a linear objective over an M-convex set using steepest descent.

    The key property of M-convex sets is that local optimality implies
    global optimality for linear objectives. This gives an efficient
    O(|S| · n) algorithm.

    Args:
        S: M-convex set
        objective: Linear objective function
        n: Dimension

    Returns:
        Optimization result
    """
    # Start from an arbitrary point
    current = next(iter(S))
    current_val = objective(current)
    iterations = 0

    while True:
        iterations += 1
        improved = False

        # Try all exchange steps
        for i in range(n):
            for j in range(n):
                if i != j and current[i] > 0:
                    neighbor = list(current)
                    neighbor[i] -= 1
                    neighbor[j] += 1
                    t = tuple(neighbor)
                    if t in S:
                        val = objective(t)
                        if val > current_val:
                            current = t
                            current_val = val
                            improved = True
                            break
            if improved:
                break

        if not improved:
            break

    # Verify by brute force
    best = max(S, key=objective)
    best_val = objective(best)

    return {
        "optimal_point": current,
        "optimal_value": current_val,
        "iterations": iterations,
        "verified_optimal": current_val == best_val,
        "brute_force_optimal": best,
    }


# ──────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("APPLICATIONS OF M-CONVEX SETS AND GENERALIZED PERMUTOHEDRA")
    print("=" * 70)

    # Application 1: Scheduling
    print("\n─── Application 1: Machine Scheduling ───")
    result = scheduling_permutohedron([3, 4, 5, 2, 1], 3)
    print(f"  Tasks: {result['tasks']}")
    print(f"  Machines: {result['machines']}")
    print(f"  Optimal makespan: {result['optimal_makespan']}")
    print(f"  Ideal makespan: {result['ideal_makespan']}")
    print(f"  Feasible load vectors: {result['num_feasible_loads']}")

    # Application 2: Pythagorean lattice
    print("\n─── Application 2: Pythagorean Lattice Structure ───")
    lattice = pythagorean_lattice_structure(50)
    for c in sorted(lattice.keys())[:6]:
        info = lattice[c]
        print(f"  c={c}: {info['count']} triples, "
              f"constant sum={info['constant_sum']}, "
              f"sum={info['sum_value']} = 2·{c}²={info['expected_2c2']}")

    # Application 3: Tropical valuations
    print("\n─── Application 3: Tropical Pythagorean Map ───")
    trop = analyze_tropical_pythagorean(30, [2, 3, 5])
    for p in [2, 3, 5]:
        info = trop[p]
        print(f"  p={p}: {info['satisfies_tropical_relation']}/{info['total_triples']} "
              f"satisfy tropical relation")
        for img in info['tropical_images'][:3]:
            print(f"    {img['triple']} → v_{p} = {img['tropical']}")

    # Application 4: Discrete optimization
    print("\n─── Application 4: Discrete Convex Optimization ───")
    n, d = 4, 3
    S = set()
    for combo in itertools.product(range(d + 1), repeat=n):
        if sum(combo) == d:
            S.add(combo)

    objective = lambda x: 3 * x[0] + 5 * x[1] + 2 * x[2] + 4 * x[3]
    result = mconvex_optimization(S, objective, n)
    print(f"  Objective: 3x₀ + 5x₁ + 2x₂ + 4x₃ over simplex(4,3)")
    print(f"  Optimal: {result['optimal_point']} with value {result['optimal_value']}")
    print(f"  Iterations: {result['iterations']}")
    print(f"  Verified: {result['verified_optimal']}")

    print("\n" + "=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: M-Convex Sets, Generalized Permutohedra, and the Exchange Property

This script demonstrates:
1. Constructing M-convex sets and verifying the exchange property
2. Checking edge direction constraints for generalized permutohedra
3. Connecting Pythagorean triples to submodular/M-convex structures
4. Visualizing generalized permutohedra in 3D
"""

import itertools
import math
from typing import List, Tuple, Set, Dict, Optional
from collections import defaultdict


# ──────────────────────────────────────────────────────────────────
# 1. M-Convex Sets and Exchange Property
# ──────────────────────────────────────────────────────────────────

def check_exchange_property(S: Set[Tuple[int, ...]], n: int) -> bool:
    """Check if a set S ⊂ ℤⁿ satisfies the M-convex exchange property.

    For all α, β ∈ S and all i with α_i > β_i, there exists j with
    α_j < β_j such that α - e_i + e_j ∈ S.
    """
    for alpha in S:
        for beta in S:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            # Construct α - e_i + e_j
                            new_vec = list(alpha)
                            new_vec[i] -= 1
                            new_vec[j] += 1
                            if tuple(new_vec) in S:
                                found = True
                                break
                    if not found:
                        return False
    return True


def generate_simplex(n: int, d: int) -> Set[Tuple[int, ...]]:
    """Generate the full simplex {x ∈ ℕⁿ : ∑xᵢ = d}."""
    if n == 1:
        return {(d,)}
    result = set()
    for first in range(d + 1):
        for rest in generate_simplex(n - 1, d - first):
            result.add((first,) + rest)
    return result


def edge_direction(n: int, i: int, j: int) -> Tuple[int, ...]:
    """Compute the edge direction e_i - e_j."""
    vec = [0] * n
    vec[i] = 1
    vec[j] = -1
    return tuple(vec)


def check_edge_directions(S: Set[Tuple[int, ...]], n: int) -> bool:
    """Check if all pairwise differences in S are combinations of e_i - e_j."""
    for alpha in S:
        for beta in S:
            if alpha == beta:
                continue
            diff = tuple(beta[k] - alpha[k] for k in range(n))
            # Check that diff sums to 0 (necessary for e_i - e_j combinations)
            if sum(diff) != 0:
                return False
    return True


# ──────────────────────────────────────────────────────────────────
# 2. Submodularity
# ──────────────────────────────────────────────────────────────────

def check_submodular(f, n: int) -> bool:
    """Check if f: 2^[n] → ℤ is submodular."""
    elements = list(range(n))
    for r1 in range(n + 1):
        for A in itertools.combinations(elements, r1):
            A_set = frozenset(A)
            for r2 in range(n + 1):
                for B in itertools.combinations(elements, r2):
                    B_set = frozenset(B)
                    if f(A_set | B_set) + f(A_set & B_set) > f(A_set) + f(B_set):
                        return False
    return True


def weighted_sum_function(weights: List[int]):
    """Return a submodular function f(S) = ∑_{i∈S} w_i."""
    def f(S: frozenset) -> int:
        return sum(weights[i] for i in S)
    return f


def rank_function(ground_set: frozenset):
    """Return the rank/indicator function f(T) = |T ∩ S|."""
    def f(T: frozenset) -> int:
        return len(T & ground_set)
    return f


# ──────────────────────────────────────────────────────────────────
# 3. Pythagorean Connection
# ──────────────────────────────────────────────────────────────────

def pythagorean_triples(N: int) -> List[Tuple[int, int, int]]:
    """Generate all primitive Pythagorean triples with hypotenuse ≤ N."""
    triples = []
    for c in range(5, N + 1):
        for a in range(3, c):
            b_sq = c * c - a * a
            b = int(math.isqrt(b_sq))
            if b > 0 and b * b == b_sq and a < b:
                if math.gcd(a, math.gcd(b, c)) == 1:
                    triples.append((a, b, c))
    return triples


def pythagorean_squared_sum_check(a: int, b: int, c: int) -> bool:
    """Verify a² + b² + c² = 2c² when a² + b² = c²."""
    if a**2 + b**2 != c**2:
        return False
    return a**2 + b**2 + c**2 == 2 * c**2


# ──────────────────────────────────────────────────────────────────
# 4. M-Convex Cardinality Conjecture Test
# ──────────────────────────────────────────────────────────────────

def test_cardinality_conjecture(n: int, d: int) -> Dict:
    """Test the M-convex cardinality conjecture for given n, d.

    Conjecture: |S| ≤ C(n+d-1, d) for any M-convex S ⊂ {x ∈ ℕⁿ : ∑xᵢ = d}.
    """
    full_simplex = generate_simplex(n, d)
    bound = math.comb(n + d - 1, d)

    # The full simplex should be M-convex and achieve the bound
    is_mconvex = check_exchange_property(full_simplex, n)

    return {
        "n": n,
        "d": d,
        "simplex_size": len(full_simplex),
        "bound": bound,
        "simplex_is_mconvex": is_mconvex,
        "bound_achieved": len(full_simplex) == bound,
    }


# ──────────────────────────────────────────────────────────────────
# Main Demo
# ──────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("M-CONVEX SETS AND GENERALIZED PERMUTOHEDRA — DEMO")
    print("=" * 70)

    # Demo 1: Exchange Property
    print("\n─── Demo 1: M-Convex Exchange Property ───")
    for n, d in [(3, 2), (3, 3), (4, 2)]:
        S = generate_simplex(n, d)
        is_mc = check_exchange_property(S, n)
        print(f"  Simplex(n={n}, d={d}): |S| = {len(S)}, M-convex: {is_mc}")

    # Demo 2: Edge Directions
    print("\n─── Demo 2: Edge Direction Check ───")
    S = generate_simplex(3, 2)
    has_good_edges = check_edge_directions(S, 3)
    print(f"  Simplex(3,2) edge directions sum to 0: {has_good_edges}")
    print(f"  Edge e_0 - e_1 = {edge_direction(3, 0, 1)}")
    print(f"  Edge e_1 - e_2 = {edge_direction(3, 1, 2)}")
    print(f"  Sum of e_0 - e_1: {sum(edge_direction(3, 0, 1))}")

    # Demo 3: Submodularity
    print("\n─── Demo 3: Submodularity ───")
    weights = [3, 4, 5]  # Pythagorean triple!
    f = weighted_sum_function(weights)
    print(f"  Weighted sum f(S) with weights {weights}: submodular = {check_submodular(f, 3)}")

    ground = frozenset({0, 2})
    g = rank_function(ground)
    print(f"  Rank function with ground set {{0,2}}: submodular = {check_submodular(g, 3)}")

    # Demo 4: Pythagorean Connection
    print("\n─── Demo 4: Pythagorean Triple Structure ───")
    triples = pythagorean_triples(50)
    print(f"  Primitive triples with c ≤ 50: {len(triples)}")
    for a, b, c in triples[:5]:
        check = pythagorean_squared_sum_check(a, b, c)
        print(f"    ({a}, {b}, {c}): a²+b²+c² = {a**2+b**2+c**2} = 2c² = {2*c**2}, check: {check}")

    # Demo 5: Cardinality Conjecture
    print("\n─── Demo 5: M-Convex Cardinality Conjecture ───")
    for n, d in [(3, 2), (3, 3), (4, 2), (4, 3), (3, 4)]:
        result = test_cardinality_conjecture(n, d)
        print(f"  n={n}, d={d}: |simplex|={result['simplex_size']}, "
              f"bound=C({n+d-1},{d})={result['bound']}, "
              f"M-convex={result['simplex_is_mconvex']}, "
              f"achieves bound={result['bound_achieved']}")

    # Demo 6: Non-M-convex example
    print("\n─── Demo 6: Non-M-convex Example ───")
    # Remove a point from the simplex to break M-convexity
    S = generate_simplex(3, 2)
    S_broken = S - {(1, 1, 0)}
    is_mc = check_exchange_property(S_broken, 3)
    print(f"  Simplex(3,2) minus (1,1,0): |S| = {len(S_broken)}, M-convex: {is_mc}")

    # A carefully chosen subset that IS M-convex
    S_sub = {(2, 0, 0), (1, 1, 0), (1, 0, 1), (0, 1, 1), (0, 0, 2)}
    is_mc2 = check_exchange_property(S_sub, 3)
    print(f"  Subset {{(2,0,0),(1,1,0),(1,0,1),(0,1,1),(0,0,2)}}: M-convex: {is_mc2}")

    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


if __name__ == "__main__":
    main()
