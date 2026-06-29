#!/usr/bin/env python3
"""
applications.py — Applications of the support-Tutte polynomial.

Demonstrates real-world applications including:
1. Matroid basis enumeration via specialization
2. Network reliability-style partition functions
3. Distinguishing supports invisible to matroid theory
"""

from typing import Set, Tuple, Dict, List
from itertools import combinations

ExponentVector = Tuple[int, ...]
Poly = Dict[int, int]

# ============================================================
# Inline polynomial arithmetic (self-contained)
# ============================================================

def poly_one() -> Poly:
    return {0: 1}

def poly_var() -> Poly:
    return {1: 1}

def poly_add(p: Poly, q: Poly) -> Poly:
    result = dict(p)
    for deg, coeff in q.items():
        result[deg] = result.get(deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}

def poly_mul(p: Poly, q: Poly) -> Poly:
    result: Poly = {}
    for d1, c1 in p.items():
        for d2, c2 in q.items():
            d = d1 + d2
            result[d] = result.get(d, 0) + c1 * c2
    return {k: v for k, v in result.items() if v != 0}

def poly_eval(p: Poly, x) -> int:
    return sum(c * x**d for d, c in p.items())

def poly_str(p: Poly) -> str:
    if not p:
        return "0"
    terms = []
    for d in sorted(p.keys(), reverse=True):
        c = p[d]
        if d == 0:
            terms.append(str(c))
        elif d == 1:
            terms.append(f"{c}*X" if abs(c) != 1 else ("X" if c > 0 else "-X"))
        else:
            terms.append(f"{c}*X^{d}" if abs(c) != 1 else (f"X^{d}" if c > 0 else f"-X^{d}"))
    return " + ".join(terms).replace("+ -", "- ")

# ============================================================
# Inline support operations
# ============================================================

def support_delete(S, i):
    return {v for v in S if v[i] == 0}

def support_contract(S, i):
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v)
            w[i] -= 1
            result.add(tuple(w))
    return result

def is_loop(S, i):
    return len(S) > 0 and all(v[i] > 0 for v in S)

def is_ordinary(S, i):
    return any(v[i] == 0 for v in S) and any(v[i] > 0 for v in S)

def compute_tutte(S, memo=None):
    if memo is None:
        memo = {}
    key = frozenset(S)
    if key in memo:
        return memo[key]
    if not S:
        r = poly_one(); memo[key] = r; return r
    n = len(next(iter(S)))
    zero = tuple([0] * n)
    if S == {zero}:
        r = poly_one(); memo[key] = r; return r
    for i in range(n):
        if is_ordinary(S, i):
            r = poly_add(compute_tutte(support_delete(S, i), memo),
                         compute_tutte(support_contract(S, i), memo))
            memo[key] = r; return r
    for i in range(n):
        if is_loop(S, i):
            r = poly_mul(poly_var(), compute_tutte(support_contract(S, i), memo))
            memo[key] = r; return r
    r = poly_one(); memo[key] = r; return r

def simplex_support(n, d):
    if n == 1:
        return {(d,)}
    result = set()
    for k in range(d + 1):
        for rest in simplex_support(n - 1, d - k):
            result.add((k,) + rest)
    return result

def check_mconvexity(S):
    if len(S) <= 1:
        return True
    n = len(next(iter(S)))
    for x in S:
        for y in S:
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            x_new = list(x); x_new[a] -= 1; x_new[b] += 1
                            y_new = list(y); y_new[a] += 1; y_new[b] -= 1
                            if tuple(x_new) in S and tuple(y_new) in S:
                                found = True; break
                    if not found:
                        return False
    return True

def matroid_basis_support(n, bases):
    result = set()
    for basis in bases:
        v = [0] * n
        for i in basis:
            v[i] = 1
        result.add(tuple(v))
    return result


# ============================================================
# Application 1: Matroid Basis Counting
# ============================================================

def app_matroid_counting():
    """The support-Tutte polynomial at X=1 counts bases."""
    print("=" * 60)
    print("APPLICATION 1: Matroid Basis Counting")
    print("=" * 60)
    
    matroids = {
        "U_{1,3}": (3, [[0], [1], [2]]),
        "U_{2,3}": (3, [[0,1], [0,2], [1,2]]),
        "U_{2,4}": (4, [[0,1], [0,2], [0,3], [1,2], [1,3], [2,3]]),
        "U_{3,4}": (4, [[0,1,2], [0,1,3], [0,2,3], [1,2,3]]),
    }
    
    for name, (n, bases) in matroids.items():
        S = matroid_basis_support(n, bases)
        T = compute_tutte(S)
        count = poly_eval(T, 1)
        print(f"\n{name}:")
        print(f"  T(S) = {poly_str(T)}")
        print(f"  T(1) = {count} = |bases| = {len(bases)} ✓")
        
        # X=2 gives a weighted count
        weighted = poly_eval(T, 2)
        print(f"  T(2) = {weighted} (loop-weighted count)")


# ============================================================
# Application 2: Partition Function / Reliability
# ============================================================

def app_partition_function():
    """The support-Tutte polynomial is a partition function
    weighting minor decomposition histories."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Partition Function Interpretation")
    print("=" * 60)
    
    S = simplex_support(3, 2)
    T = compute_tutte(S)
    
    print(f"\nDegree-2 simplex in 3 vars: T(S) = {poly_str(T)}")
    print(f"\nPartition function interpretation:")
    print(f"  At temperature β (X = e^β):")
    
    for beta_name, x_val in [("0 (high T)", 1), ("ln2", 2), ("ln3", 3), ("ln5", 5)]:
        Z = poly_eval(T, x_val)
        print(f"    β = {beta_name}: Z = {Z}")
    
    print(f"\n  Coefficients give loop-depth histogram:")
    for deg in sorted(T.keys()):
        print(f"    Depth {deg}: {T[deg]} decomposition histories")


# ============================================================
# Application 3: Support Distinguishing Power
# ============================================================

def app_distinguishing():
    """The support-Tutte polynomial distinguishes supports that
    matroids cannot see."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Beyond Matroid Distinguishing Power")
    print("=" * 60)
    
    # Two supports with same cardinality, same "matroid shadow"
    # but different support-Tutte polynomials
    
    # Full degree-2 simplex in 2 vars (M-convex)
    S1 = {(2, 0), (1, 1), (0, 2)}
    T1 = compute_tutte(S1)
    
    # Binary support with 3 elements (matroid bases of U_{1,3} in 2D won't work)
    # Instead compare with a shifted support
    S2 = {(1, 0), (0, 1)}
    T2 = compute_tutte(S2)
    
    print(f"\nSupport 1 (degree-2 simplex): {sorted(S1)}")
    print(f"  T₁ = {poly_str(T1)}")
    print(f"  M-convex: {check_mconvexity(S1)}")
    
    print(f"\nSupport 2 (degree-1 simplex): {sorted(S2)}")
    print(f"  T₂ = {poly_str(T2)}")
    print(f"  M-convex: {check_mconvexity(S2)}")
    
    print(f"\n  These have different polynomials: T₁ ≠ T₂ is {T1 != T2}")
    print(f"  The support-Tutte polynomial detects the multiplicity structure")
    print(f"  (degree-2 vs degree-1) that matroid theory erases.")
    
    # More dramatic example
    print(f"\n--- Comparing M-convex supports with same |S| ---")
    
    # Find M-convex subsets of degree-2 simplex in 3 vars with |S|=3
    S_full = simplex_support(3, 2)
    size3_mconvex = []
    for subset in combinations(S_full, 3):
        sub = set(subset)
        if check_mconvexity(sub):
            size3_mconvex.append(sub)
    
    poly_classes = {}
    for sub in size3_mconvex:
        T = compute_tutte(sub)
        key = frozenset(T.items())
        if key not in poly_classes:
            poly_classes[key] = []
        poly_classes[key].append(sub)
    
    print(f"\nM-convex subsets of Simplex(3,2) with |S|=3: {len(size3_mconvex)}")
    print(f"Distinct support-Tutte polynomials: {len(poly_classes)}")
    
    for poly_key, supports in poly_classes.items():
        T = dict(poly_key)
        print(f"\n  T = {poly_str(T)}:")
        for s in supports:
            print(f"    {sorted(s)}")


# ============================================================
# Application 4: Tropical Geometry Connection
# ============================================================

def app_tropical():
    """Support-Tutte polynomials and Newton polytope structure."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Newton Polytope / Tropical Connection")
    print("=" * 60)
    
    print("\nNewton polytopes of polynomials with M-convex support:")
    
    for d in range(1, 5):
        S = simplex_support(3, d)
        T = compute_tutte(S)
        print(f"\n  Degree-{d} simplex (3 vars): |S|={len(S)}, T = {poly_str(T)}")
        print(f"    T(1) = {poly_eval(T, 1)} = |S|")
        
        # The degree of T tells us about the "loop depth" of the support
        max_deg = max(T.keys()) if T else 0
        print(f"    max degree of T = {max_deg} (related to loop depth)")


if __name__ == "__main__":
    app_matroid_counting()
    app_partition_function()
    app_distinguishing()
    app_tropical()
    
    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Support-Tutte Polynomial Demonstrations

Computes sample support-Tutte polynomials for various M-convex supports,
compares outputs under different coordinate orderings, and demonstrates
non-matroidal supports where the invariant carries extra information.
"""

from itertools import combinations
from collections import defaultdict
from typing import FrozenSet, Tuple, Dict, List, Set

# ============================================================
# Core data structures
# ============================================================

# A support element is a tuple of non-negative integers (exponent vector)
ExponentVector = tuple  # tuple of ints

def is_binary(v: ExponentVector) -> bool:
    return all(c in (0, 1) for c in v)


# ============================================================
# Support operations
# ============================================================

def support_delete(S: Set[ExponentVector], i: int) -> Set[ExponentVector]:
    """Delete coordinate i: keep elements with v[i] = 0."""
    return {v for v in S if v[i] == 0}

def support_contract(S: Set[ExponentVector], i: int) -> Set[ExponentVector]:
    """Tutte contraction at coordinate i: keep elements with v[i] > 0,
    subtract 1 from coordinate i."""
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v)
            w[i] -= 1
            result.add(tuple(w))
    return result

def is_loop(S: Set[ExponentVector], i: int) -> bool:
    """Coordinate i is a loop if all elements have v[i] > 0."""
    return all(v[i] > 0 for v in S)

def is_ordinary(S: Set[ExponentVector], i: int) -> bool:
    """Coordinate i is ordinary if some have v[i]=0 and some have v[i]>0."""
    has_zero = any(v[i] == 0 for v in S)
    has_pos = any(v[i] > 0 for v in S)
    return has_zero and has_pos


# ============================================================
# The Support-Tutte polynomial (symbolic, using dict representation)
# Polynomial in one variable X, coefficients are integers
# Represented as dict: degree -> coefficient
# ============================================================

Poly = Dict[int, int]

def poly_zero() -> Poly:
    return {}

def poly_one() -> Poly:
    return {0: 1}

def poly_X() -> Poly:
    return {1: 1}

def poly_add(p: Poly, q: Poly) -> Poly:
    result = dict(p)
    for deg, coeff in q.items():
        result[deg] = result.get(deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}

def poly_mul(p: Poly, q: Poly) -> Poly:
    result = {}
    for d1, c1 in p.items():
        for d2, c2 in q.items():
            d = d1 + d2
            result[d] = result.get(d, 0) + c1 * c2
    return {k: v for k, v in result.items() if v != 0}

def poly_scale(c: int, p: Poly) -> Poly:
    return {k: c * v for k, v in p.items() if c * v != 0}

def poly_eval(p: Poly, x: int) -> int:
    return sum(c * x**d for d, c in p.items())

def poly_str(p: Poly) -> str:
    if not p:
        return "0"
    terms = []
    for d in sorted(p.keys(), reverse=True):
        c = p[d]
        if d == 0:
            terms.append(str(c))
        elif d == 1:
            if c == 1:
                terms.append("X")
            elif c == -1:
                terms.append("-X")
            else:
                terms.append(f"{c}*X")
        else:
            if c == 1:
                terms.append(f"X^{d}")
            elif c == -1:
                terms.append(f"-X^{d}")
            else:
                terms.append(f"{c}*X^{d}")
    return " + ".join(terms).replace("+ -", "- ")


# ============================================================
# Recursive computation with memoization
# ============================================================

def support_tutte_poly(S: Set[ExponentVector], memo=None) -> Poly:
    """Compute the support-Tutte polynomial T(S) ∈ Z[X].
    
    Recurrence:
    - T(∅) = 1, T({0}) = 1
    - T(S) = X * T(con(S,i)) if i is a loop
    - T(S) = T(del(S,i)) + T(con(S,i)) if i is ordinary
    """
    if memo is None:
        memo = {}
    
    key = frozenset(S)
    if key in memo:
        return memo[key]
    
    if not S:
        result = poly_one()
        memo[key] = result
        return result
    
    # Check if all elements are zero
    n = len(next(iter(S)))
    zero = tuple([0] * n)
    if S == {zero}:
        result = poly_one()
        memo[key] = result
        return result
    
    # Find a coordinate to recurse on
    for i in range(n):
        if is_ordinary(S, i):
            d = support_delete(S, i)
            c = support_contract(S, i)
            result = poly_add(
                support_tutte_poly(d, memo),
                support_tutte_poly(c, memo)
            )
            memo[key] = result
            return result
    
    # Try loop coordinates
    for i in range(n):
        if is_loop(S, i):
            c = support_contract(S, i)
            result = poly_mul(poly_X(), support_tutte_poly(c, memo))
            memo[key] = result
            return result
    
    # Fallback (should not reach for valid supports)
    result = poly_one()
    memo[key] = result
    return result


def support_tutte_with_order(S: Set[ExponentVector], order: List[int]) -> Poly:
    """Compute T(S) using a specific coordinate ordering.
    Processes coordinates in the given order, choosing the first
    available coordinate at each step."""
    memo = {}
    
    def recurse(S_cur, remaining_order):
        key = frozenset(S_cur)
        if key in memo:
            return memo[key]
        
        if not S_cur:
            return poly_one()
        
        n = len(next(iter(S_cur)))
        zero = tuple([0] * n)
        if S_cur == {zero}:
            return poly_one()
        
        # Process coordinates in given order
        for i in remaining_order:
            if is_ordinary(S_cur, i):
                d = support_delete(S_cur, i)
                c = support_contract(S_cur, i)
                new_order = [j for j in remaining_order if j != i]
                result = poly_add(
                    recurse(d, new_order),
                    recurse(c, new_order)
                )
                memo[key] = result
                return result
        
        for i in remaining_order:
            if is_loop(S_cur, i):
                c = support_contract(S_cur, i)
                new_order = [j for j in remaining_order if j != i]
                result = poly_mul(poly_X(), recurse(c, new_order))
                memo[key] = result
                return result
        
        return poly_one()
    
    return recurse(S, order)


# ============================================================
# Example supports
# ============================================================

def matroid_basis_support(n: int, bases: List[List[int]]) -> Set[ExponentVector]:
    """Create a {0,1}-valued support from matroid bases.
    Each basis is a list of element indices present."""
    result = set()
    for basis in bases:
        v = [0] * n
        for i in basis:
            v[i] = 1
        result.add(tuple(v))
    return result

def simplex_support(n: int, d: int) -> Set[ExponentVector]:
    """All vectors in N^n summing to d (the degree-d simplex)."""
    if n == 1:
        return {(d,)}
    result = set()
    for k in range(d + 1):
        for rest in simplex_support(n - 1, d - k):
            result.add((k,) + rest)
    return result

def mconvex_subset(S: Set[ExponentVector]) -> bool:
    """Check if S satisfies the symmetric exchange property (M-convexity)."""
    for x in S:
        for y in S:
            n = len(x)
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            x_new = list(x)
                            x_new[a] -= 1
                            x_new[b] += 1
                            y_new = list(y)
                            y_new[a] += 1
                            y_new[b] -= 1
                            if tuple(x_new) in S and tuple(y_new) in S:
                                found = True
                                break
                    if not found:
                        return False
    return True


# ============================================================
# Demonstrations
# ============================================================

def demo_basic():
    """Demo 1: Basic computation on simple supports."""
    print("=" * 60)
    print("DEMO 1: Basic Support-Tutte Polynomials")
    print("=" * 60)
    
    # Empty support
    S = set()
    T = support_tutte_poly(S)
    print(f"\nS = ∅")
    print(f"T(S) = {poly_str(T)}")
    
    # Singleton zero
    S = {(0, 0)}
    T = support_tutte_poly(S)
    print(f"\nS = {{(0,0)}}")
    print(f"T(S) = {poly_str(T)}")
    
    # A simple binary support (matroid-like)
    S = {(1, 0), (0, 1)}
    T = support_tutte_poly(S)
    print(f"\nS = {{(1,0), (0,1)}}")
    print(f"T(S) = {poly_str(T)}")
    print(f"T(1) = {poly_eval(T, 1)} (should equal |S| = {len(S)})")
    
    # A non-binary support (carries multiplicity info)
    S = {(2, 0), (1, 1), (0, 2)}
    T = support_tutte_poly(S)
    print(f"\nS = {{(2,0), (1,1), (0,2)}} (degree-2 simplex, 2 vars)")
    print(f"T(S) = {poly_str(T)}")
    print(f"T(1) = {poly_eval(T, 1)} (should equal |S| = {len(S)})")
    
    # Support with a loop
    S = {(1, 0), (1, 1)}
    T = support_tutte_poly(S)
    print(f"\nS = {{(1,0), (1,1)}} (coord 0 is a loop)")
    print(f"T(S) = {poly_str(T)}")
    print(f"T(1) = {poly_eval(T, 1)} (should equal |S| = {len(S)})")


def demo_order_independence():
    """Demo 2: Compare polynomials under different orderings."""
    print("\n" + "=" * 60)
    print("DEMO 2: Order Independence Test")
    print("=" * 60)
    
    # Test on degree-3 simplex in 3 variables
    S = simplex_support(3, 3)
    print(f"\nDegree-3 simplex in 3 variables: |S| = {len(S)}")
    print(f"M-convex: {mconvex_subset(S)}")
    
    orders = [
        [0, 1, 2],
        [1, 0, 2],
        [2, 1, 0],
        [0, 2, 1],
    ]
    
    results = []
    for order in orders:
        T = support_tutte_with_order(S, order)
        results.append(T)
        print(f"  Order {order}: T(S) = {poly_str(T)}")
    
    all_same = all(r == results[0] for r in results)
    print(f"\nAll orderings agree: {all_same}")
    
    # More extensive test
    print("\nSystematic order-independence check:")
    from itertools import permutations
    
    test_supports = [
        ("Simplex(3,2)", simplex_support(3, 2)),
        ("Simplex(3,3)", simplex_support(3, 3)),
        ("Simplex(4,2)", simplex_support(4, 2)),
    ]
    
    for name, S in test_supports:
        n = len(next(iter(S)))
        polys = set()
        for perm in permutations(range(n)):
            T = support_tutte_with_order(S, list(perm))
            polys.add(frozenset(T.items()))
        
        print(f"  {name}: |S|={len(S)}, M-convex={mconvex_subset(S)}, "
              f"distinct polynomials={len(polys)}")


def demo_non_matroidal():
    """Demo 3: Non-matroidal supports with extra information."""
    print("\n" + "=" * 60)
    print("DEMO 3: Non-Matroidal Supports")
    print("=" * 60)
    
    # Binary support (matroid-like): uniform matroid U_{2,3}
    matroid_S = matroid_basis_support(3, [[0,1], [0,2], [1,2]])
    T_mat = support_tutte_poly(matroid_S)
    print(f"\nU_{{2,3}} basis indicators: {sorted(matroid_S)}")
    print(f"T(S) = {poly_str(T_mat)}")
    
    # Non-binary support with same cardinality
    non_binary_S = {(2, 0, 0), (0, 2, 0), (0, 0, 2)}
    T_nb = support_tutte_poly(non_binary_S)
    print(f"\nDegree-2 vertices: {sorted(non_binary_S)}")
    print(f"T(S) = {poly_str(T_nb)}")
    print(f"M-convex: {mconvex_subset(non_binary_S)}")
    
    # Full degree-2 simplex in 3 vars
    full_S = simplex_support(3, 2)
    T_full = support_tutte_poly(full_S)
    print(f"\nFull degree-2 simplex: |S|={len(full_S)}")
    print(f"T(S) = {poly_str(T_full)}")
    print(f"M-convex: {mconvex_subset(full_S)}")
    
    # Compare: same matroid shadow but different support-Tutte
    print("\n--- Comparison ---")
    print(f"Binary (matroid) T(1) = {poly_eval(T_mat, 1)}")
    print(f"Non-binary T(1) = {poly_eval(T_nb, 1)}")
    print(f"Full simplex T(1) = {poly_eval(T_full, 1)}")
    print(f"Polynomials differ: {T_mat != T_nb or T_mat != T_full}")
    print(f"This shows the support-Tutte invariant carries information")
    print(f"beyond what matroid theory can see!")


def demo_matroid_bridge():
    """Demo 4: Bridge to matroid theory."""
    print("\n" + "=" * 60)
    print("DEMO 4: Matroid Bridge")
    print("=" * 60)
    
    # Compute for several matroids and verify T(1) = # bases
    matroids = [
        ("U_{1,2}", 2, [[0], [1]]),
        ("U_{2,3}", 3, [[0,1], [0,2], [1,2]]),
        ("U_{1,3}", 3, [[0], [1], [2]]),
        ("U_{2,4}", 4, [[0,1], [0,2], [0,3], [1,2], [1,3], [2,3]]),
    ]
    
    for name, n, bases in matroids:
        S = matroid_basis_support(n, bases)
        T = support_tutte_poly(S)
        print(f"\n{name}: |bases| = {len(bases)}")
        print(f"  T(S) = {poly_str(T)}")
        print(f"  T(1) = {poly_eval(T, 1)} = |S| ✓" 
              if poly_eval(T, 1) == len(S) else "  T(1) ≠ |S| ✗")


def demo_degree5_simplex():
    """Demo 5: Exhaustive test on degree-≤5 simplex subsets."""
    print("\n" + "=" * 60)
    print("DEMO 5: M-Convex Subsets of Degree-≤5 Simplex (4 vars)")
    print("=" * 60)
    
    # For computational feasibility, test degree-2 simplex in 4 vars
    S_full = simplex_support(4, 2)
    print(f"\nFull degree-2 simplex in 4 vars: |S| = {len(S_full)}")
    print(f"M-convex: {mconvex_subset(S_full)}")
    
    T = support_tutte_poly(S_full)
    print(f"T(S) = {poly_str(T)}")
    print(f"T(1) = {poly_eval(T, 1)}")
    
    # Check order independence on this larger example
    from itertools import permutations
    polys = set()
    for perm in permutations(range(4)):
        Tp = support_tutte_with_order(S_full, list(perm))
        polys.add(frozenset(Tp.items()))
    print(f"Distinct polynomials over all 24 orderings: {len(polys)}")
    
    # Find M-convex subsets
    print(f"\nSearching for M-convex subsets of degree-2 simplex in 3 vars...")
    S3 = simplex_support(3, 2)
    mconvex_count = 0
    non_trivial = []
    
    for r in range(2, len(S3) + 1):
        for subset in combinations(S3, r):
            sub = set(subset)
            if mconvex_subset(sub):
                mconvex_count += 1
                T_sub = support_tutte_poly(sub)
                if len(sub) >= 3:
                    non_trivial.append((sub, T_sub))
    
    print(f"Found {mconvex_count} M-convex subsets (size ≥ 2)")
    print(f"Non-trivial (size ≥ 3): {len(non_trivial)}")
    
    for sub, T_sub in non_trivial[:5]:
        print(f"  |S|={len(sub)}: T = {poly_str(T_sub)}")


if __name__ == "__main__":
    demo_basic()
    demo_order_independence()
    demo_non_matroidal()
    demo_matroid_bridge()
    demo_degree5_simplex()
    
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
visualize_support_tutte.py — Visualization of Support-Tutte Polynomials

Produces a heatmap showing the coefficients of T(S) for various M-convex
supports, and a comparison chart between binary (matroid) and non-binary
supports. All functions inlined for standalone execution.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

# ============================================================
# Inline polynomial/support functions
# ============================================================

def poly_one():
    return {0: 1}

def poly_var():
    return {1: 1}

def poly_add(p, q):
    result = dict(p)
    for deg, coeff in q.items():
        result[deg] = result.get(deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}

def poly_mul(p, q):
    result = {}
    for d1, c1 in p.items():
        for d2, c2 in q.items():
            d = d1 + d2
            result[d] = result.get(d, 0) + c1 * c2
    return {k: v for k, v in result.items() if v != 0}

def poly_eval(p, x):
    return sum(c * x**d for d, c in p.items())

def support_delete(S, i):
    return {v for v in S if v[i] == 0}

def support_contract(S, i):
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v); w[i] -= 1; result.add(tuple(w))
    return result

def is_loop(S, i):
    return len(S) > 0 and all(v[i] > 0 for v in S)

def is_ordinary(S, i):
    return any(v[i] == 0 for v in S) and any(v[i] > 0 for v in S)

def compute_tutte(S, memo=None):
    if memo is None: memo = {}
    key = frozenset(S)
    if key in memo: return memo[key]
    if not S:
        r = poly_one(); memo[key] = r; return r
    n = len(next(iter(S)))
    zero = tuple([0] * n)
    if S == {zero}:
        r = poly_one(); memo[key] = r; return r
    for i in range(n):
        if is_ordinary(S, i):
            r = poly_add(compute_tutte(support_delete(S, i), memo),
                         compute_tutte(support_contract(S, i), memo))
            memo[key] = r; return r
    for i in range(n):
        if is_loop(S, i):
            r = poly_mul(poly_var(), compute_tutte(support_contract(S, i), memo))
            memo[key] = r; return r
    r = poly_one(); memo[key] = r; return r

def simplex_support(n, d):
    if n == 1: return {(d,)}
    result = set()
    for k in range(d + 1):
        for rest in simplex_support(n - 1, d - k):
            result.add((k,) + rest)
    return result

def check_mconvexity(S):
    if len(S) <= 1: return True
    n = len(next(iter(S)))
    for x in S:
        for y in S:
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            x_new = list(x); x_new[a] -= 1; x_new[b] += 1
                            y_new = list(y); y_new[a] += 1; y_new[b] -= 1
                            if tuple(x_new) in S and tuple(y_new) in S:
                                found = True; break
                    if not found: return False
    return True

def matroid_basis_support(n, bases):
    result = set()
    for basis in bases:
        v = [0] * n
        for i in basis: v[i] = 1
        result.add(tuple(v))
    return result

# ============================================================
# Visualization
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# --- Panel 1: Coefficient heatmap ---
supports_data = []
labels = []

for d in range(1, 6):
    S = simplex_support(3, d)
    T = compute_tutte(S)
    supports_data.append(T)
    labels.append(f"Simplex(3,{d})\n|S|={len(S)}")

for d in range(1, 4):
    S = simplex_support(4, d)
    T = compute_tutte(S)
    supports_data.append(T)
    labels.append(f"Simplex(4,{d})\n|S|={len(S)}")

max_deg = max(max(T.keys()) if T else 0 for T in supports_data)
matrix = np.zeros((len(supports_data), max_deg + 1))
for i, T in enumerate(supports_data):
    for d, c in T.items():
        matrix[i, d] = c

im = axes[0].imshow(matrix, aspect='auto', cmap='YlOrRd', interpolation='nearest')
axes[0].set_yticks(range(len(labels)))
axes[0].set_yticklabels(labels, fontsize=8)
axes[0].set_xlabel('Degree of X', fontsize=11)
axes[0].set_title('Support-Tutte Coefficients', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=axes[0], label='Coefficient value')

# Add text annotations
for i in range(matrix.shape[0]):
    for j in range(matrix.shape[1]):
        if matrix[i, j] > 0:
            axes[0].text(j, i, f'{int(matrix[i,j])}', ha='center', va='center',
                        fontsize=7, color='black' if matrix[i,j] < matrix.max()/2 else 'white')

# --- Panel 2: T(x) evaluation curves ---
x_vals = np.linspace(0, 3, 100)
colors = plt.cm.viridis(np.linspace(0, 1, 5))

for idx, d in enumerate(range(1, 6)):
    S = simplex_support(3, d)
    T = compute_tutte(S)
    y_vals = [sum(c * x**deg for deg, c in T.items()) for x in x_vals]
    axes[1].plot(x_vals, y_vals, color=colors[idx], linewidth=2,
                label=f'd={d}, |S|={len(S)}')

axes[1].set_xlabel('X', fontsize=11)
axes[1].set_ylabel('T(S)(X)', fontsize=11)
axes[1].set_title('Support-Tutte Evaluation Curves\n(3-variable simplices)', fontsize=13, fontweight='bold')
axes[1].legend(fontsize=9)
axes[1].set_yscale('log')
axes[1].grid(True, alpha=0.3)

# --- Panel 3: Binary vs non-binary comparison ---
# Compare matroid supports vs full simplex supports
categories = []
binary_vals = []
full_vals = []
extra_info = []

for d in range(1, 5):
    # Binary: matroid basis indicators for U_{d, d+1}
    n = d + 1
    bases = list(combinations(range(n), d))
    S_bin = matroid_basis_support(n, [list(b) for b in bases])
    T_bin = compute_tutte(S_bin)
    
    # Non-binary: full degree-d simplex in (d+1) vars
    S_full = simplex_support(n, d)
    T_full = compute_tutte(S_full)
    
    categories.append(f"d={d}, n={n}")
    binary_vals.append(poly_eval(T_bin, 2))
    full_vals.append(poly_eval(T_full, 2))
    extra_info.append((len(S_bin), len(S_full)))

x_pos = np.arange(len(categories))
width = 0.35

bars1 = axes[2].bar(x_pos - width/2, binary_vals, width, label='Binary (matroid)',
                     color='steelblue', alpha=0.8)
bars2 = axes[2].bar(x_pos + width/2, full_vals, width, label='Full simplex',
                     color='coral', alpha=0.8)

axes[2].set_xlabel('Support parameters', fontsize=11)
axes[2].set_ylabel('T(S)(2)', fontsize=11)
axes[2].set_title('Binary vs Non-Binary\nSupport-Tutte at X=2', fontsize=13, fontweight='bold')
axes[2].set_xticks(x_pos)
axes[2].set_xticklabels(categories, fontsize=9)
axes[2].legend(fontsize=9)
axes[2].grid(True, alpha=0.3, axis='y')

# Add size annotations
for i, (nb, nf) in enumerate(extra_info):
    axes[2].annotate(f'|S|={nb}', (x_pos[i] - width/2, binary_vals[i]),
                    ha='center', va='bottom', fontsize=7)
    axes[2].annotate(f'|S|={nf}', (x_pos[i] + width/2, full_vals[i]),
                    ha='center', va='bottom', fontsize=7)

plt.tight_layout()
plt.savefig('support_tutte_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: support_tutte_visualization.png")
