#!/usr/bin/env python3
"""
Applications of M-Convex Support Shadow Compression

Demonstrates real-world applications:
  1. Fast Hessian certification for structured polynomials
  2. Newton polytope analysis for optimization
  3. Tropical face enumeration
  4. Matroid basis counting
"""

from itertools import combinations
from math import comb
from typing import Set, Tuple, List, Dict, FrozenSet
from collections import defaultdict

Exponent = Tuple[int, ...]


# ─── Application 1: Hessian Branch Certification ────────────────────

def certify_hessian_branches(support: Set[Exponent], d: int) -> Dict:
    """Certify which second-order derivative branches survive for a
    homogeneous polynomial with the given Newton support.

    For a polynomial p = Σ c_m x^m of degree d, the quadratic leaf set
    tells us exactly which monomials x^u (degree d-2) can appear as
    nonzero entries in the matrix of second partial derivatives.

    This is critical for:
    - Lorentzian polynomial recognition
    - SOS (sum-of-squares) decomposition
    - Convexity certification

    Returns a certificate with:
    - surviving_leaves: the quadratic leaf set
    - total_possible: the number of degree-(d-2) monomials in active vars
    - compression_ratio: how much the support structure compresses
    """
    if d < 2:
        return {"surviving_leaves": set(), "total_possible": 0, "compression_ratio": 1.0}

    k = d - 2

    # Compute active coordinates
    active = set()
    for m in support:
        for i, v in enumerate(m):
            if v > 0:
                active.add(i)
    omega = len(active)

    # Compute shadow
    shadow = set()
    n = len(next(iter(support)))
    for m in support:
        for u in _dominated_of_degree(m, k, n):
            shadow.add(u)

    # Check multiaffine bound
    multiaffine = all(all(v <= 1 for v in m) for m in support)
    bound = comb(omega, k) if multiaffine else comb(omega + k - 1, k)
    total_possible = comb(omega + k - 1, k)  # stars and bars

    return {
        "surviving_leaves": shadow,
        "leaf_count": len(shadow),
        "active_width": omega,
        "bound": bound,
        "total_possible": total_possible,
        "compression_ratio": len(shadow) / total_possible if total_possible > 0 else 0,
        "multiaffine": multiaffine,
        "bound_holds": len(shadow) <= bound
    }


def _dominated_of_degree(m, k, n):
    results = []
    _gen(m, k, n, 0, [], results)
    return results

def _gen(m, remaining, n, idx, current, results):
    if idx == n:
        if remaining == 0:
            results.append(tuple(current))
        return
    for v in range(min(m[idx], remaining) + 1):
        current.append(v)
        _gen(m, remaining - v, n, idx + 1, current, results)
        current.pop()


# ─── Application 2: Newton Polytope Optimization ────────────────────

def analyze_newton_polytope(support: Set[Exponent]) -> Dict:
    """Analyze the Newton polytope structure of a support for optimization.

    For polynomial optimization problems min p(x) over a domain,
    understanding the Newton polytope structure reveals:
    - Degree of the polynomial
    - Active variable count (effective dimension)
    - Shadow structure (derivative complexity)
    - Whether SOS relaxations can be efficiently computed
    """
    if not support:
        return {"error": "Empty support"}

    sample = next(iter(support))
    n = len(sample)
    d = sum(sample)

    active = set()
    for m in support:
        for i in range(n):
            if m[i] > 0:
                active.add(i)

    # Compute all shadow levels
    shadow_sizes = {}
    for k in range(d + 1):
        shadow = set()
        for m in support:
            for u in _dominated_of_degree(m, k, n):
                shadow.add(u)
        shadow_sizes[k] = len(shadow)

    return {
        "degree": d,
        "dimension": n,
        "effective_dimension": len(active),
        "support_size": len(support),
        "shadow_profile": shadow_sizes,
        "hessian_complexity": shadow_sizes.get(d - 2, 0) if d >= 2 else 0,
    }


# ─── Application 3: Tropical Face Enumeration ───────────────────────

def enumerate_tropical_faces(support: Set[Exponent],
                             weight_samples: List[Tuple[int, ...]]) -> Dict:
    """Enumerate tropical faces of a support polytope.

    Each weight vector w defines a tropical face = {m ∈ S : w·m is minimal}.
    The collection of faces forms the tropical variety structure.

    This is relevant for:
    - Tropical algebraic geometry
    - Regular subdivisions of Newton polytopes
    - Amoeba theory
    """
    n = len(next(iter(support)))
    faces = {}

    for w in weight_samples:
        # Find minimizers
        min_val = min(sum(w[i] * m[i] for i in range(n)) for m in support)
        face = frozenset(m for m in support
                         if sum(w[i] * m[i] for i in range(n)) == min_val)
        face_key = face
        if face_key not in faces:
            faces[face_key] = {"weight_example": w, "size": len(face)}

    return {
        "num_distinct_faces": len(faces),
        "face_sizes": [f["size"] for f in faces.values()],
        "faces": {str(sorted(k)): v for k, v in faces.items()}
    }


# ─── Application 4: Matroid Basis Counting ───────────────────────────

def matroid_independence_count(n: int, r: int, bases: Set[FrozenSet[int]]) -> Dict:
    """Count independent sets at each rank for a matroid.

    Given matroid bases (r-element subsets), compute the number of
    independent k-sets for each k. The Lorentzian polynomial connection
    ensures these counts satisfy log-concavity.
    """
    indep_counts = {}
    for k in range(r + 1):
        count = 0
        for subset in combinations(range(n), k):
            s = frozenset(subset)
            if any(s <= b for b in bases):
                count += 1
        indep_counts[k] = count

    # Check log-concavity
    log_concave = True
    for k in range(1, r):
        if indep_counts[k] ** 2 < indep_counts[k-1] * indep_counts[k+1]:
            log_concave = False
            break

    return {
        "independence_counts": indep_counts,
        "log_concave": log_concave,
        "total_independent_sets": sum(indep_counts.values()),
        "bases_count": len(bases),
    }


# ─── Demonstrations ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Hessian Branch Certification")
    print("=" * 60)

    # Example: quadratic polynomial x^2 + xy + y^2
    support_quad = {(2, 0), (1, 1), (0, 2)}
    cert = certify_hessian_branches(support_quad, 2)
    print(f"\nPolynomial: a·x² + b·xy + c·y² (degree 2)")
    print(f"  Leaf count: {cert['leaf_count']}")
    print(f"  Active width: {cert['active_width']}")
    print(f"  Compression ratio: {cert['compression_ratio']:.2f}")

    # Example: cubic on 4 variables (matroid-type)
    support_cubic = set()
    for subset in combinations(range(4), 3):
        vec = [0] * 4
        for i in subset:
            vec[i] = 1
        support_cubic.add(tuple(vec))
    cert = certify_hessian_branches(support_cubic, 3)
    print(f"\nMatroid basis polynomial on 4 vars (degree 3)")
    print(f"  Support size: {len(support_cubic)}")
    print(f"  Leaf count: {cert['leaf_count']}")
    print(f"  Bound C(ω, d-2): {cert['bound']}")
    print(f"  Bound holds: {cert['bound_holds']}")
    print(f"  Compression ratio: {cert['compression_ratio']:.2f}")

    print(f"\n{'=' * 60}")
    print("APPLICATION 2: Newton Polytope Analysis")
    print("=" * 60)

    # Schur polynomial support
    support_schur = {(2, 1, 0), (2, 0, 1), (1, 2, 0), (1, 0, 2),
                     (0, 2, 1), (0, 1, 2), (1, 1, 1)}
    analysis = analyze_newton_polytope(support_schur)
    print(f"\nSchur s_(2,1) support analysis:")
    for key, val in analysis.items():
        print(f"  {key}: {val}")

    print(f"\n{'=' * 60}")
    print("APPLICATION 3: Tropical Face Enumeration")
    print("=" * 60)

    weights = [(1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 1, 0),
               (1, 0, 1), (0, 1, 1), (1, 1, 1), (2, 1, 0),
               (1, 2, 0), (0, 1, 2)]
    faces = enumerate_tropical_faces(support_schur, weights)
    print(f"\nSchur s_(2,1) tropical faces (10 weight samples):")
    print(f"  Distinct faces found: {faces['num_distinct_faces']}")
    print(f"  Face sizes: {sorted(faces['face_sizes'])}")

    print(f"\n{'=' * 60}")
    print("APPLICATION 4: Matroid Independence Counting")
    print("=" * 60)

    # Fano matroid (7 points, rank 3)
    fano_bases = set()
    lines = [{0,1,2}, {0,3,4}, {0,5,6}, {1,3,5}, {1,4,6}, {2,3,6}, {2,4,5}]
    for subset in combinations(range(7), 3):
        s = frozenset(subset)
        if not any(line <= s for line in lines):
            fano_bases.add(s)

    counts = matroid_independence_count(7, 3, fano_bases)
    print(f"\nFano matroid F_7:")
    print(f"  Basis count: {counts['bases_count']}")
    print(f"  Independence counts: {counts['independence_counts']}")
    print(f"  Log-concave: {counts['log_concave']}")


#!/usr/bin/env python3
"""
Demo: M-Convex Support Shadow Compression

Demonstrates the degree-shadow cardinality bound for M-convex support families.
Shows that:
  - For multiaffine M-convex sets (matroid bases), |shadow_k| ≤ C(ω, k)
  - For general (non-multiaffine) M-convex sets, the bound can fail
  - Tropical initial supports preserve structure

Usage: python demo.py
"""

from itertools import combinations, product
from math import comb
from typing import List, Tuple, Set, Dict, FrozenSet


# ─── Core Types ─────────────────────────────────────────────────────

Exponent = Tuple[int, ...]  # exponent vector (e.g., (2, 1, 0))


def total_degree(m: Exponent) -> int:
    return sum(m)


def active_coords(s: Set[Exponent]) -> Set[int]:
    """Coordinates i such that m[i] > 0 for some m in s."""
    result = set()
    for m in s:
        for i, v in enumerate(m):
            if v > 0:
                result.add(i)
    return result


def degree_shadow(s: Set[Exponent], k: int) -> Set[Exponent]:
    """Degree-k shadow: all degree-k vectors dominated by some element of s."""
    n = len(next(iter(s)))  # dimension
    shadow = set()
    for m in s:
        # Generate all vectors u with u[i] <= m[i] and sum(u) = k
        for u in _dominated_of_degree(m, k):
            shadow.add(u)
    return shadow


def _dominated_of_degree(m: Exponent, k: int) -> List[Exponent]:
    """All vectors u with u <= m coordinatewise and total_degree(u) = k."""
    n = len(m)
    results = []
    _gen_dominated(m, k, n, 0, [], results)
    return results


def _gen_dominated(m, remaining, n, idx, current, results):
    if idx == n:
        if remaining == 0:
            results.append(tuple(current))
        return
    max_val = min(m[idx], remaining)
    for v in range(max_val + 1):
        current.append(v)
        _gen_dominated(m, remaining - v, n, idx + 1, current, results)
        current.pop()


def is_multiaffine(m: Exponent) -> bool:
    return all(v <= 1 for v in m)


def is_m_convex(s: Set[Exponent]) -> bool:
    """Check M-convex symmetric exchange property."""
    s_list = list(s)
    for alpha in s_list:
        for beta in s_list:
            for i in range(len(alpha)):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(len(alpha)):
                        if alpha[j] < beta[j]:
                            # Check alpha - e_i + e_j in S
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in s:
                                found = True
                                break
                    if not found:
                        return False
    return True


# ─── Example Generators ─────────────────────────────────────────────

def uniform_matroid_bases(n: int, r: int) -> Set[Exponent]:
    """U_{r,n}: all r-element subsets as indicator vectors."""
    bases = set()
    for subset in combinations(range(n), r):
        vec = [0] * n
        for i in subset:
            vec[i] = 1
        bases.add(tuple(vec))
    return bases


def all_degree_d_vectors(n: int, d: int) -> Set[Exponent]:
    """All vectors in Z_≥0^n with total degree d. (Full simplex slice.)"""
    vectors = set()
    _gen_dominated(tuple([d] * n), d, n, 0, [], vecs := [])
    return set(vecs)


def permutohedron_lattice_points(n: int, d: int) -> Set[Exponent]:
    """Integer points of the permutohedron: vectors with entries being
    permutations of some partition of d, plus their M-convex hull."""
    # Generate all degree-d vectors and filter to M-convex hull
    all_vecs = set()
    _gen_all_degree_d(n, d, all_vecs)
    # The permutohedron lattice points for degree d on n vars are
    # all vectors (a_1,...,a_n) with sum = d and for all subsets S,
    # sum_{i in S} a_i <= |S| * (d // n) + min(|S|, d mod n) (approximately)
    # For simplicity, generate all degree-d vectors and check M-convexity
    return all_vecs  # Full simplex is M-convex


def _gen_all_degree_d(n: int, d: int, result: Set[Exponent]):
    """Generate all degree-d vectors in Z_≥0^n."""
    vecs = []
    _gen_dominated(tuple([d] * n), d, n, 0, [], vecs)
    result.update(vecs)


def schur_support(partition: Tuple[int, ...], n: int) -> Set[Exponent]:
    """Newton support of the Schur polynomial s_λ(x_1,...,x_n).
    This equals the set of weight vectors of SSYT of shape λ with entries in [n].
    """
    lam = list(partition)
    d = sum(lam)

    # Generate all SSYT of shape λ with entries in {0,...,n-1}
    # A SSYT has rows weakly increasing, columns strictly increasing
    support = set()

    def fill_tableau(row, col, prev_row, current_tab):
        if row >= len(lam):
            # Compute weight vector
            weight = [0] * n
            for r in range(len(lam)):
                for c in range(lam[r]):
                    weight[current_tab[r][c]] += 1
            support.add(tuple(weight))
            return

        if col >= lam[row]:
            fill_tableau(row + 1, 0, current_tab[row] if row + 1 < len(lam) else None, current_tab)
            return

        # Determine valid entries
        min_val = current_tab[row][col - 1] if col > 0 else 0  # weakly increasing in row
        if prev_row is not None and col < len(prev_row):
            min_val = max(min_val, prev_row[col] + 1)  # strictly increasing in column

        for val in range(min_val, n):
            current_tab[row][col] = val
            fill_tableau(row, col + 1, prev_row, current_tab)

    tab = [[0] * lam[r] for r in range(len(lam))]
    fill_tableau(0, 0, None, tab)
    return support


def polymatroid_bases(n: int, rank_fn) -> Set[Exponent]:
    """Base polytope of a polymatroid defined by submodular rank function.
    Returns all integer points x with sum(x) = rank_fn(set(range(n)))
    and sum(x[i] for i in S) <= rank_fn(S) for all S.
    """
    d = rank_fn(frozenset(range(n)))
    all_vecs = []
    _gen_dominated(tuple([d] * n), d, n, 0, [], all_vecs)

    bases = set()
    for v in all_vecs:
        valid = True
        for size in range(1, n + 1):
            for subset in combinations(range(n), size):
                s = frozenset(subset)
                if sum(v[i] for i in s) > rank_fn(s):
                    valid = False
                    break
            if not valid:
                break
        if valid:
            bases.add(v)
    return bases


# ─── Tropical Functions ─────────────────────────────────────────────

def tropical_dot(w: Tuple[int, ...], m: Exponent) -> int:
    return sum(wi * mi for wi, mi in zip(w, m))


def initial_support(w: Tuple[int, ...], s: Set[Exponent]) -> Set[Exponent]:
    """Weight-minimizers in s under w."""
    min_val = min(tropical_dot(w, m) for m in s)
    return {m for m in s if tropical_dot(w, m) == min_val}


# ─── Demo Functions ─────────────────────────────────────────────────

def demo_shadow_bound():
    """Demonstrate the shadow bound for various M-convex families."""
    print("=" * 70)
    print("DEMO: Degree Shadow Cardinality Bounds for M-Convex Supports")
    print("=" * 70)

    examples = []

    # Example 1: Uniform matroid U_{3,5}
    s1 = uniform_matroid_bases(5, 3)
    examples.append(("U_{3,5} (uniform matroid)", s1, 3))

    # Example 2: Uniform matroid U_{4,6}
    s2 = uniform_matroid_bases(6, 4)
    examples.append(("U_{4,6} (uniform matroid)", s2, 4))

    # Example 3: Full simplex (all degree-3 on 3 vars) — non-matroid
    s3 = set()
    _gen_all_degree_d(3, 3, s3)
    examples.append(("Full degree-3 simplex on 3 vars", s3, 3))

    # Example 4: Full simplex (all degree-4 on 3 vars) — counterexample
    s4 = set()
    _gen_all_degree_d(3, 4, s4)
    examples.append(("Full degree-4 simplex on 3 vars [COUNTEREXAMPLE]", s4, 4))

    # Example 5: Schur support for partition (2,1)
    s5 = schur_support((2, 1), 3)
    examples.append(("Schur s_{(2,1)}(x_1,x_2,x_3)", s5, 3))

    # Example 6: Schur support for partition (3,1)
    s6 = schur_support((3, 1), 3)
    examples.append(("Schur s_{(3,1)}(x_1,x_2,x_3)", s6, 4))

    # Example 7: Polymatroid from submodular function
    def rank_fn(S):
        """Rank = min(|S|, 2) + (1 if 0 in S else 0)"""
        return min(len(S), 2) + (1 if 0 in S else 0)
    s7 = polymatroid_bases(3, rank_fn)
    examples.append(("Polymatroid (rank = min(|S|,2) + 1_{0∈S})", s7, rank_fn(frozenset(range(3)))))

    for name, s, d in examples:
        print(f"\n{'─' * 60}")
        print(f"Example: {name}")
        print(f"  Degree d = {d}")
        print(f"  |S| = {len(s)}")

        omega = len(active_coords(s))
        print(f"  Active width ω = {omega}")

        multiaffine = all(is_multiaffine(m) for m in s)
        print(f"  Multiaffine: {multiaffine}")

        m_convex = is_m_convex(s)
        print(f"  M-convex: {m_convex}")

        k = d - 2
        if k < 0:
            print(f"  k = d-2 = {k} < 0, skipping shadow computation")
            continue

        shadow = degree_shadow(s, k)
        bound = comb(omega, k)
        holds = len(shadow) <= bound

        print(f"  Degree-{k} shadow size: {len(shadow)}")
        print(f"  Binomial bound C({omega},{k}): {bound}")
        print(f"  Bound holds: {'✓' if holds else '✗ VIOLATED'}")

        if not holds and not multiaffine:
            print(f"  → Expected: bound fails for non-multiaffine M-convex sets")
        elif holds and multiaffine:
            print(f"  → Expected: bound holds for multiaffine (matroid) supports")

        # Also check other shadow levels
        print(f"\n  Full shadow profile:")
        for kk in range(d + 1):
            sh = degree_shadow(s, kk)
            bd = comb(omega, kk)
            flag = "✓" if len(sh) <= bd else "✗"
            print(f"    k={kk}: |shadow|={len(sh):4d}, C({omega},{kk})={bd:4d}  [{flag}]")


def demo_tropical():
    """Demonstrate tropical initial support structure."""
    print("\n" + "=" * 70)
    print("DEMO: Tropical Initial Supports of M-Convex Families")
    print("=" * 70)

    # Use Schur support for (2,1) on 3 variables
    s = schur_support((2, 1), 3)
    d = 3
    print(f"\nSchur s_(2,1)(x1,x2,x3), degree {d}")
    print(f"Support: {sorted(s)}")
    print(f"M-convex: {is_m_convex(s)}")

    # Try various weight vectors
    weight_vectors = [
        (1, 0, 0),
        (0, 1, 0),
        (1, 1, 0),
        (2, 1, 0),
        (1, 2, 3),
        (0, 0, 0),
    ]

    for w in weight_vectors:
        init = initial_support(w, s)
        print(f"\n  w = {w}")
        print(f"  Initial support (minimizers): {sorted(init)}")
        print(f"  |initial support| = {len(init)}")
        print(f"  Initial support M-convex: {is_m_convex(init)}")


def demo_exchange_graph():
    """Visualize the exchange graph of an M-convex set."""
    print("\n" + "=" * 70)
    print("DEMO: Exchange Graph Structure")
    print("=" * 70)

    s = schur_support((2, 1), 3)
    print(f"\nSchur s_(2,1)(x1,x2,x3)")
    print(f"Support elements: {sorted(s)}")

    print("\nExchange graph (edges = single-step exchanges α → α-e_i+e_j):")
    for alpha in sorted(s):
        exchanges = []
        for beta in sorted(s):
            if alpha == beta:
                continue
            for i in range(len(alpha)):
                if alpha[i] > beta[i]:
                    for j in range(len(alpha)):
                        if alpha[j] < beta[j]:
                            exchanged = list(alpha)
                            exchanged[i] -= 1
                            exchanged[j] += 1
                            if tuple(exchanged) in s:
                                exchanges.append((i, j, tuple(exchanged)))
        if exchanges:
            print(f"  {alpha}:")
            for i, j, result in exchanges:
                print(f"    → {result}  (i={i}, j={j})")


def demo_tight_examples():
    """Search for examples where the bound is tight."""
    print("\n" + "=" * 70)
    print("DEMO: Tight Examples (Equality in Shadow Bound)")
    print("=" * 70)

    for n in range(2, 7):
        for r in range(2, n + 1):
            s = uniform_matroid_bases(n, r)
            k = r - 2
            if k < 0:
                continue
            omega = len(active_coords(s))
            shadow = degree_shadow(s, k)
            bound = comb(omega, k)
            ratio = len(shadow) / bound if bound > 0 else 0
            tight = "TIGHT" if len(shadow) == bound else f"ratio={ratio:.3f}"
            print(f"  U_{{{r},{n}}}: |shadow_{{{k}}}|={len(shadow)}, "
                  f"C({omega},{k})={bound}, {tight}")


if __name__ == "__main__":
    demo_shadow_bound()
    demo_tropical()
    demo_exchange_graph()
    demo_tight_examples()


#!/usr/bin/env python3
"""
Visualization: Exchange Graph of M-Convex Supports

Shows the exchange graph structure of M-convex families, where nodes are
exponent vectors and edges represent single-step exchanges (α → α - eᵢ + eⱼ).
Highlights the connectivity pattern that underlies support compression.

The graph structure reveals why M-convex exchange controls shadow geometry:
exchange paths connect all elements, ensuring dominated vectors can be
"reached" through systematic coordinate redistribution.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from typing import Set, Tuple, Dict, List
from collections import defaultdict


Exponent = Tuple[int, ...]


def schur_support(partition, n):
    lam = list(partition)
    support = set()
    def fill(row, col, prev_row, tab):
        if row >= len(lam):
            weight = [0] * n
            for r in range(len(lam)):
                for c in range(lam[r]):
                    weight[tab[r][c]] += 1
            support.add(tuple(weight))
            return
        if col >= lam[row]:
            fill(row + 1, 0, tab[row] if row + 1 < len(lam) else None, tab)
            return
        min_val = tab[row][col - 1] if col > 0 else 0
        if prev_row is not None and col < len(prev_row):
            min_val = max(min_val, prev_row[col] + 1)
        for val in range(min_val, n):
            tab[row][col] = val
            fill(row, col + 1, prev_row, tab)
    tab = [[0] * lam[r] for r in range(len(lam))]
    fill(0, 0, None, tab)
    return support


def exchange_graph(s: Set[Exponent]) -> Dict[Exponent, List[Exponent]]:
    n = len(next(iter(s)))
    graph = defaultdict(list)
    for alpha in s:
        for i in range(n):
            if alpha[i] > 0:
                for j in range(n):
                    if i != j:
                        ex = list(alpha)
                        ex[i] -= 1
                        ex[j] += 1
                        t = tuple(ex)
                        if t in s:
                            graph[alpha].append(t)
    return dict(graph)


def _gen_dom(m, remaining, n, idx, current, results):
    if idx == n:
        if remaining == 0:
            results.append(tuple(current))
        return
    for v in range(min(m[idx], remaining) + 1):
        current.append(v)
        _gen_dom(m, remaining - v, n, idx + 1, current, results)
        current.pop()


def degree_shadow(s: Set[Exponent], k: int) -> Set[Exponent]:
    n = len(next(iter(s)))
    shadow = set()
    for m in s:
        results = []
        _gen_dom(m, k, n, 0, [], results)
        shadow.update(results)
    return shadow


# ─── Create visualization ───────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Exchange graph of Schur s_(2,1) on 3 variables
s = schur_support((2, 1), 3)
graph = exchange_graph(s)
nodes = sorted(s)
n_nodes = len(nodes)
node_idx = {v: i for i, v in enumerate(nodes)}

# Position nodes using barycentric coordinates (since 3 variables)
# Map (a, b, c) to 2D using a+b+c=3
positions = {}
for v in nodes:
    # Barycentric to Cartesian
    x = v[1] + 0.5 * v[2]
    y = v[2] * np.sqrt(3) / 2
    positions[v] = (x, y)

ax1 = axes[0]
ax1.set_title("Exchange Graph: Schur s₍₂,₁₎(x₁,x₂,x₃)\nDegree 3, 7 elements",
              fontsize=11, fontweight='bold')

# Draw edges
drawn_edges = set()
for alpha, neighbors in graph.items():
    for beta in neighbors:
        edge = frozenset([alpha, beta])
        if edge not in drawn_edges:
            drawn_edges.add(edge)
            x1, y1 = positions[alpha]
            x2, y2 = positions[beta]
            ax1.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

# Draw nodes
multiaffine_nodes = [v for v in nodes if all(c <= 1 for c in v)]
non_multiaffine_nodes = [v for v in nodes if any(c > 1 for c in v)]

for v in non_multiaffine_nodes:
    x, y = positions[v]
    ax1.scatter(x, y, s=200, c='coral', edgecolors='darkred',
               linewidth=1.5, zorder=5)
    ax1.annotate(str(v), (x, y), ha='center', va='bottom',
                fontsize=8, fontweight='bold', xytext=(0, 12),
                textcoords='offset points')

for v in multiaffine_nodes:
    x, y = positions[v]
    ax1.scatter(x, y, s=200, c='steelblue', edgecolors='darkblue',
               linewidth=1.5, zorder=5)
    ax1.annotate(str(v), (x, y), ha='center', va='bottom',
                fontsize=8, fontweight='bold', xytext=(0, 12),
                textcoords='offset points')

# Legend
blue_patch = mpatches.Patch(color='steelblue', label='Multiaffine (0/1)')
red_patch = mpatches.Patch(color='coral', label='Non-multiaffine')
ax1.legend(handles=[blue_patch, red_patch], loc='upper right', fontsize=9)
ax1.set_aspect('equal')
ax1.axis('off')

# Panel 2: Shadow decomposition showing domination
ax2 = axes[1]
ax2.set_title("Shadow Decomposition: Degree-1 Shadow\n"
              "Each leaf ← its dominating support elements",
              fontsize=11, fontweight='bold')

shadow_1 = degree_shadow(s, 1)
shadow_nodes = sorted(shadow_1)

# Layout: support elements on top, shadow on bottom
y_top = 2.0
y_bot = 0.0
support_x = np.linspace(0, 6, len(nodes))
shadow_x = np.linspace(1, 5, len(shadow_nodes))

support_pos = {v: (support_x[i], y_top) for i, v in enumerate(nodes)}
shadow_pos = {v: (shadow_x[i], y_bot) for i, v in enumerate(shadow_nodes)}

# Draw domination edges
for u in shadow_nodes:
    for m in nodes:
        if all(u[i] <= m[i] for i in range(3)):
            x1, y1 = support_pos[m]
            x2, y2 = shadow_pos[u]
            ax2.plot([x1, x2], [y1, y2], '-', color='gray', alpha=0.4, linewidth=0.8)

# Draw support nodes
for v in nodes:
    x, y = support_pos[v]
    color = 'steelblue' if all(c <= 1 for c in v) else 'coral'
    ax2.scatter(x, y, s=150, c=color, edgecolors='black', linewidth=1, zorder=5)
    ax2.annotate(str(v), (x, y), ha='center', va='bottom',
                fontsize=7, xytext=(0, 8), textcoords='offset points')

# Draw shadow nodes
for v in shadow_nodes:
    x, y = shadow_pos[v]
    ax2.scatter(x, y, s=150, c='gold', edgecolors='darkgoldenrod',
               linewidth=1.5, zorder=5)
    ax2.annotate(str(v), (x, y), ha='center', va='top',
                fontsize=8, fontweight='bold', xytext=(0, -12),
                textcoords='offset points')

# Labels
ax2.text(3, y_top + 0.4, f"Support S (degree 3, |S|={len(nodes)})",
         ha='center', fontsize=10, fontstyle='italic')
ax2.text(3, y_bot - 0.5, f"Shadow₁(S) (degree 1, |shadow|={len(shadow_nodes)}, "
         f"bound C(3,1)={3})",
         ha='center', fontsize=10, fontstyle='italic')

gold_patch = mpatches.Patch(color='gold', label='Shadow elements')
ax2.legend(handles=[blue_patch, red_patch, gold_patch],
          loc='center right', fontsize=8)
ax2.set_xlim(-0.5, 7)
ax2.set_ylim(-1, 3)
ax2.axis('off')

plt.tight_layout()
plt.savefig("exchange_graph_and_shadow.png", dpi=150, bbox_inches='tight')
print("Saved exchange_graph_and_shadow.png")


#!/usr/bin/env python3
"""
Visualization: Shadow Profile Comparison

Compares the degree-k shadow sizes against the binomial bound C(ω, k)
for various M-convex families. Shows where the multiaffine bound holds
(matroid bases) and where it fails (non-multiaffine M-convex sets).

This visualization illustrates the central theorem: exchange geometry
controls shadow compression, but the multiaffine constraint is essential
for the sharp binomial bound.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from math import comb
from typing import Set, Tuple, List


Exponent = Tuple[int, ...]


def _gen_all(n, remaining, idx, current, results):
    if idx == n:
        if remaining == 0:
            results.append(tuple(current))
        return
    for v in range(remaining + 1):
        current.append(v)
        _gen_all(n, remaining - v, idx + 1, current, results)
        current.pop()


def _gen_dom(m, remaining, n, idx, current, results):
    if idx == n:
        if remaining == 0:
            results.append(tuple(current))
        return
    for v in range(min(m[idx], remaining) + 1):
        current.append(v)
        _gen_dom(m, remaining - v, n, idx + 1, current, results)
        current.pop()


def degree_shadow(s: Set[Exponent], k: int) -> Set[Exponent]:
    n = len(next(iter(s)))
    shadow = set()
    for m in s:
        results = []
        _gen_dom(m, k, n, 0, [], results)
        shadow.update(results)
    return shadow


def active_width(s: Set[Exponent]) -> int:
    active = set()
    for m in s:
        for i, v in enumerate(m):
            if v > 0:
                active.add(i)
    return len(active)


def uniform_matroid_bases(n: int, r: int) -> Set[Exponent]:
    bases = set()
    for subset in combinations(range(n), r):
        vec = [0] * n
        for i in subset:
            vec[i] = 1
        bases.add(tuple(vec))
    return bases


def full_simplex(n: int, d: int) -> Set[Exponent]:
    results = []
    _gen_all(n, d, 0, [], results)
    return set(results)


def schur_support(partition, n):
    lam = list(partition)
    support = set()
    def fill(row, col, prev_row, tab):
        if row >= len(lam):
            weight = [0] * n
            for r in range(len(lam)):
                for c in range(lam[r]):
                    weight[tab[r][c]] += 1
            support.add(tuple(weight))
            return
        if col >= lam[row]:
            fill(row + 1, 0, tab[row] if row + 1 < len(lam) else None, tab)
            return
        min_val = tab[row][col - 1] if col > 0 else 0
        if prev_row is not None and col < len(prev_row):
            min_val = max(min_val, prev_row[col] + 1)
        for val in range(min_val, n):
            tab[row][col] = val
            fill(row, col + 1, prev_row, tab)
    tab = [[0] * lam[r] for r in range(len(lam))]
    fill(0, 0, None, tab)
    return support


# ─── Build data ──────────────────────────────────────────────────────

families = [
    ("U₃,₅ (matroid)", uniform_matroid_bases(5, 3), True),
    ("U₄,₆ (matroid)", uniform_matroid_bases(6, 4), True),
    ("Full Δ₃,₃ (non-matroid)", full_simplex(3, 3), False),
    ("Full Δ₃,₄ (non-matroid)", full_simplex(3, 4), False),
    ("Schur s₍₂,₁₎", schur_support((2, 1), 3), False),
    ("Schur s₍₃,₁₎", schur_support((3, 1), 3), False),
]

fig, axes = plt.subplots(2, 3, figsize=(15, 9))
fig.suptitle("Degree Shadow Profiles: M-Convex Families vs Binomial Bound",
             fontsize=14, fontweight='bold')

for idx, (name, s, is_matroid) in enumerate(families):
    ax = axes[idx // 3][idx % 3]
    d = sum(next(iter(s)))
    omega = active_width(s)

    ks = list(range(d + 1))
    shadow_sizes = [len(degree_shadow(s, k)) for k in ks]
    binomial_bound = [comb(omega, k) for k in ks]

    ax.bar(np.array(ks) - 0.15, shadow_sizes, 0.3, label='|Shadow_k|',
           color='steelblue', alpha=0.8)
    ax.bar(np.array(ks) + 0.15, binomial_bound, 0.3, label='C(ω, k)',
           color='coral', alpha=0.8)

    # Mark violations
    for ki, (ss, bb) in enumerate(zip(shadow_sizes, binomial_bound)):
        if ss > bb:
            ax.annotate('✗', (ki, ss), ha='center', va='bottom',
                       fontsize=14, color='red', fontweight='bold')

    ax.set_xlabel('Shadow degree k')
    ax.set_ylabel('Count')
    ax.set_title(f"{name}\nd={d}, ω={omega}, |S|={len(s)}",
                fontsize=10)
    ax.legend(fontsize=8)
    ax.set_xticks(ks)

plt.tight_layout()
plt.savefig("shadow_profile_comparison.png", dpi=150, bbox_inches='tight')
print("Saved shadow_profile_comparison.png")


#!/usr/bin/env python3
"""
Visualization: Tropical Initial Supports and Weight Stability

Shows how tropical weight vectors partition an M-convex support into
initial support faces, and how exchange structure is preserved within
equal-weight coordinate classes. This illustrates the bridge between
discrete convex analysis and tropical geometry.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import Set, Tuple


Exponent = Tuple[int, ...]


def schur_support(partition, n):
    lam = list(partition)
    support = set()
    def fill(row, col, prev_row, tab):
        if row >= len(lam):
            weight = [0] * n
            for r in range(len(lam)):
                for c in range(lam[r]):
                    weight[tab[r][c]] += 1
            support.add(tuple(weight))
            return
        if col >= lam[row]:
            fill(row + 1, 0, tab[row] if row + 1 < len(lam) else None, tab)
            return
        min_val = tab[row][col - 1] if col > 0 else 0
        if prev_row is not None and col < len(prev_row):
            min_val = max(min_val, prev_row[col] + 1)
        for val in range(min_val, n):
            tab[row][col] = val
            fill(row, col + 1, prev_row, tab)
    tab = [[0] * lam[r] for r in range(len(lam))]
    fill(0, 0, None, tab)
    return support


def is_m_convex(s):
    s_set = set(s)
    for alpha in s:
        for beta in s:
            for i in range(len(alpha)):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(len(alpha)):
                        if alpha[j] < beta[j]:
                            ex = list(alpha)
                            ex[i] -= 1
                            ex[j] += 1
                            if tuple(ex) in s_set:
                                found = True
                                break
                    if not found:
                        return False
    return True


def tropical_dot(w, m):
    return sum(wi * mi for wi, mi in zip(w, m))


def initial_support(w, s):
    min_val = min(tropical_dot(w, m) for m in s)
    return {m for m in s if tropical_dot(w, m) == min_val}


# ─── Generate data ──────────────────────────────────────────────────

s = schur_support((2, 1), 4)
nodes = sorted(s)

# Sample weight vectors on a grid
theta_vals = np.linspace(0, 2 * np.pi, 60, endpoint=False)
face_map = {}  # frozenset -> list of angles

for theta in theta_vals:
    # Weight vector in the plane w1 + w2 + w3 = 0
    w = (int(round(10 * np.cos(theta))),
         int(round(10 * np.sin(theta))),
         -int(round(10 * np.cos(theta))) - int(round(10 * np.sin(theta))))
    init = frozenset(initial_support(w, s))
    if init not in face_map:
        face_map[init] = []
    face_map[init].append(theta)

# ─── Create visualization ───────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Support in barycentric coordinates with tropical faces
ax1 = axes[0]
ax1.set_title("Schur s₍₂,₁₎(x₁,...,x₄): Support & Faces\n"
              "(projected to first 3 coordinates)", fontsize=10, fontweight='bold')

# Project 4D to 2D using first 3 coordinates (barycentric-ish)
def project(v):
    return (v[1] + 0.5 * v[2] + 0.3 * v[3],
            v[2] * np.sqrt(3)/2 + v[3] * 0.4)

pos = {v: project(v) for v in nodes}

# Color by number of faces containing each node
face_count = {v: 0 for v in nodes}
for face in face_map:
    for v in face:
        face_count[v] += 1

max_fc = max(face_count.values())
colors = [plt.cm.viridis(face_count[v] / max_fc) for v in nodes]

for i, v in enumerate(nodes):
    x, y = pos[v]
    ax1.scatter(x, y, s=120, c=[colors[i]], edgecolors='black',
               linewidth=1, zorder=5)

ax1.set_aspect('equal')
ax1.axis('off')

# Panel 2: Tropical face sizes
ax2 = axes[1]
ax2.set_title("Tropical Face Size Distribution\n"
              "(how weight vectors partition the support)", fontsize=10, fontweight='bold')

face_sizes = sorted([len(f) for f in face_map])
unique_sizes = sorted(set(face_sizes))
size_counts = {sz: face_sizes.count(sz) for sz in unique_sizes}

ax2.bar(unique_sizes, [size_counts[sz] for sz in unique_sizes],
        color='teal', alpha=0.8, edgecolor='black')
ax2.set_xlabel("Face size")
ax2.set_ylabel("Number of distinct faces")

# Panel 3: M-convexity preservation under tropicalization
ax3 = axes[2]
ax3.set_title("M-Convexity of Initial Supports\n"
              "(exchange stability under tropicalization)", fontsize=10, fontweight='bold')

# Check M-convexity of each face
mconvex_faces = 0
non_mconvex_faces = 0
face_data = []
for face, angles in face_map.items():
    if len(face) >= 2:
        mc = is_m_convex(face)
    else:
        mc = True  # singletons are trivially M-convex
    if mc:
        mconvex_faces += 1
    else:
        non_mconvex_faces += 1
    face_data.append((len(face), mc))

# Plot
sizes_mc = [sz for sz, mc in face_data if mc]
sizes_nmc = [sz for sz, mc in face_data if not mc]

ax3.hist([sizes_mc, sizes_nmc], bins=range(1, max(len(f) for f in face_map) + 2),
         label=['M-convex', 'Not M-convex'],
         color=['forestgreen', 'tomato'], alpha=0.8, edgecolor='black',
         stacked=True)
ax3.set_xlabel("Face size")
ax3.set_ylabel("Count")
ax3.legend(fontsize=9)

# Add summary text
total_faces = mconvex_faces + non_mconvex_faces
ax3.text(0.95, 0.95,
         f"Total faces: {total_faces}\n"
         f"M-convex: {mconvex_faces} ({100*mconvex_faces/total_faces:.0f}%)\n"
         f"Non-M-convex: {non_mconvex_faces}",
         transform=ax3.transAxes, ha='right', va='top',
         fontsize=9, bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig("tropical_faces_and_exchange.png", dpi=150, bbox_inches='tight')
print("Saved tropical_faces_and_exchange.png")
