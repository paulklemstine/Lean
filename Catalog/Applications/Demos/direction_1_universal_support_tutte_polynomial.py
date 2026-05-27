#!/usr/bin/env python3
"""
applications.py — Applications of the Universal Support-Tutte Polynomial

Demonstrates real-world applications:
1. Reliability polynomials for network support systems
2. Statistical mechanics partition functions
3. Matroid basis counting via specialization
4. Tropical geometry: Newton polytope analysis
"""

from typing import FrozenSet, Tuple, Dict, List, Set
from collections import defaultdict
import itertools

Element = Tuple[int, ...]
Support = FrozenSet[Element]
Polynomial = Dict[int, int]


def poly_add(p: Polynomial, q: Polynomial) -> Polynomial:
    result = dict(p)
    for k, v in q.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}


def poly_mul_x(p: Polynomial) -> Polynomial:
    return {k + 1: v for k, v in p.items()}


def poly_eval(p: Polynomial, x: float) -> float:
    return sum(coeff * x**deg for deg, coeff in p.items())


def poly_str(p: Polynomial) -> str:
    if not p:
        return "0"
    terms = []
    for deg in sorted(p.keys(), reverse=True):
        coeff = p[deg]
        if coeff == 0:
            continue
        if deg == 0:
            terms.append(str(coeff))
        elif deg == 1:
            terms.append(f"{coeff}X" if coeff != 1 else "X")
        else:
            terms.append(f"{coeff}X^{deg}" if coeff != 1 else f"X^{deg}")
    return " + ".join(terms) if terms else "0"


def support_tutte(S: Support, n: int, memo=None) -> Polynomial:
    if memo is None:
        memo = {}
    if S in memo:
        return memo[S]
    
    if len(S) == 0:
        result = {0: 1}
    elif S == frozenset({tuple(0 for _ in range(n))}):
        result = {0: 1}
    else:
        result = None
        for i in range(n):
            has_zero = any(m[i] == 0 for m in S)
            has_pos = any(m[i] > 0 for m in S)
            if has_zero and has_pos:
                d = support_tutte(frozenset(m for m in S if m[i] == 0), n, memo)
                contracted = set()
                for m in S:
                    if m[i] > 0:
                        new_m = list(m)
                        new_m[i] -= 1
                        contracted.add(tuple(new_m))
                c = support_tutte(frozenset(contracted), n, memo)
                result = poly_add(d, c)
                break
        
        if result is None:
            for i in range(n):
                if all(m[i] > 0 for m in S):
                    contracted = set()
                    for m in S:
                        new_m = list(m)
                        new_m[i] -= 1
                        contracted.add(tuple(new_m))
                    c = support_tutte(frozenset(contracted), n, memo)
                    result = poly_mul_x(c)
                    break
        
        if result is None:
            result = {0: 1}
    
    memo[S] = result
    return result


# ============== APPLICATION 1: RELIABILITY POLYNOMIAL ==============

def reliability_analysis():
    """
    Application: Network reliability via support-Tutte evaluation.
    
    Model a system with n components, each with failure probability q.
    The support encodes which configurations are operational.
    The support-Tutte polynomial evaluated at X = q/(1-q) gives
    weighted reliability information.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Reliability Analysis")
    print("=" * 60)
    
    # Example: 3-component system with redundancy
    # Operational configs: at least 2 of 3 components working
    # Encode: m[i] = 1 if component i is failed
    operational = frozenset({
        (0, 0, 0),  # all working
        (1, 0, 0),  # component 0 failed
        (0, 1, 0),  # component 1 failed  
        (0, 0, 1),  # component 2 failed
    })
    
    T = support_tutte(operational, 3)
    print(f"\n  2-of-3 redundancy system:")
    print(f"  Operational configurations: {sorted(operational)}")
    print(f"  Support-Tutte polynomial: T(X) = {poly_str(T)}")
    
    # Evaluate at different failure weights
    for q_ratio in [0.0, 0.1, 0.5, 1.0, 2.0]:
        val = poly_eval(T, q_ratio)
        print(f"  T({q_ratio}) = {val:.4f}")
    
    # Compare with a simpler system
    simple = frozenset({(0, 0), (1, 0), (0, 1)})
    T_simple = support_tutte(simple, 2)
    print(f"\n  Simple 2-component system: T(X) = {poly_str(T_simple)}")


# ============== APPLICATION 2: PARTITION FUNCTION ==============

def partition_function():
    """
    Application: Statistical mechanics partition function.
    
    The support-Tutte polynomial is a partition function:
    Z(β) = T(e^{-β}) counts weighted minor histories.
    Each loop coordinate contributes a Boltzmann factor.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Statistical Mechanics Partition Function")
    print("=" * 60)
    
    import math
    
    # Support representing energy levels of a discrete system
    energy_support = frozenset({
        (0, 0),  # ground state
        (1, 0),  # excited in mode 1
        (0, 1),  # excited in mode 2  
        (1, 1),  # doubly excited
    })
    
    T = support_tutte(energy_support, 2)
    print(f"\n  Energy level support: {sorted(energy_support)}")
    print(f"  Support-Tutte polynomial: T(X) = {poly_str(T)}")
    
    print("\n  Partition function Z(β) = T(e^{-β}):")
    for beta in [0.0, 0.5, 1.0, 2.0, 5.0]:
        x = math.exp(-beta)
        Z = poly_eval(T, x)
        print(f"    β = {beta:.1f}: Z = {Z:.4f}, "
              f"e^{{-β}} = {x:.4f}")
    
    # Non-binary energy levels (higher multiplicities)
    higher_energy = frozenset({
        (0, 0),  # ground
        (2, 0),  # doubly excited in mode 1
        (0, 2),  # doubly excited in mode 2
    })
    
    T2 = support_tutte(higher_energy, 2)
    print(f"\n  Higher-energy support: {sorted(higher_energy)}")
    print(f"  Support-Tutte polynomial: T(X) = {poly_str(T2)}")
    print("  (Note: non-matroidal — Tutte polynomial of matroids cannot see this)")


# ============== APPLICATION 3: MATROID BRIDGE ==============

def matroid_bridge():
    """
    Application: Matroid basis counting.
    
    For binary supports (0/1-valued, constant column sum),
    the support-Tutte polynomial specializes to matroid invariants.
    T(1) always equals the number of support elements (= number of bases).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Matroid Theory Bridge")
    print("=" * 60)
    
    matroids = {
        "U_{1,3} (rank 1, 3 elements)": frozenset({
            (1, 0, 0), (0, 1, 0), (0, 0, 1)
        }),
        "U_{2,3} (rank 2, 3 elements)": frozenset({
            (1, 1, 0), (1, 0, 1), (0, 1, 1)
        }),
        "U_{2,4} (rank 2, 4 elements)": frozenset({
            (1, 1, 0, 0), (1, 0, 1, 0), (1, 0, 0, 1),
            (0, 1, 1, 0), (0, 1, 0, 1), (0, 0, 1, 1)
        }),
    }
    
    for name, bases in matroids.items():
        n = len(next(iter(bases)))
        T = support_tutte(bases, n)
        print(f"\n  {name}:")
        print(f"    Bases: {len(bases)}")
        print(f"    T(S) = {poly_str(T)}")
        print(f"    T(1) = {poly_eval(T, 1)} (= number of bases ✓)" 
              if poly_eval(T, 1) == len(bases) else "    MISMATCH!")
    
    # Show how non-binary support differs
    print("\n  Comparison: matroidal vs non-matroidal with same shadow:")
    binary = frozenset({(0, 0), (1, 0)})
    nonbinary = frozenset({(0, 0), (2, 0)})
    T_bin = support_tutte(binary, 2)
    T_nonbin = support_tutte(nonbinary, 2)
    print(f"    Binary {{(0,0), (1,0)}}: T = {poly_str(T_bin)}")
    print(f"    Non-binary {{(0,0), (2,0)}}: T = {poly_str(T_nonbin)}")
    print(f"    Support-Tutte distinguishes them: {T_bin != T_nonbin}")


# ============== APPLICATION 4: TROPICAL GEOMETRY ==============

def tropical_geometry():
    """
    Application: Newton polytope and tropical analysis.
    
    The support of a polynomial determines its Newton polytope.
    The support-Tutte polynomial encodes combinatorial information
    about how the Newton polytope decomposes under coordinate projections.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Tropical Geometry / Newton Polytopes")
    print("=" * 60)
    
    # Newton polytope of x^2 + xy + y^2 + x + y + 1
    newton_support = frozenset({
        (2, 0), (1, 1), (0, 2), (1, 0), (0, 1), (0, 0)
    })
    
    T = support_tutte(newton_support, 2)
    print(f"\n  Newton support of x²+xy+y²+x+y+1:")
    print(f"    Support = {sorted(newton_support)}")
    print(f"    T(S) = {poly_str(T)}")
    print(f"    T(1) = {poly_eval(T, 1)} = |S| = {len(newton_support)}")
    
    # Subdivision: compare with sub-polytopes
    lower_tri = frozenset({(0, 0), (1, 0), (0, 1), (1, 1)})
    T_lower = support_tutte(lower_tri, 2)
    print(f"\n  Lower triangle support {{(0,0),(1,0),(0,1),(1,1)}}:")
    print(f"    T(S) = {poly_str(T_lower)}")
    
    # The degree of T encodes the "loop depth" — how many layers
    # of contraction are needed before the support becomes loop-free
    for S_name, S_set in [
        ("Triangle", frozenset({(0,0), (1,0), (0,1)})),
        ("Square", frozenset({(0,0), (1,0), (0,1), (1,1)})),
        ("Line segment", frozenset({(0,), (1,), (2,), (3,)})),
    ]:
        n = len(next(iter(S_set)))
        T = support_tutte(S_set, n)
        max_deg = max(T.keys()) if T else 0
        print(f"\n  {S_name}: T = {poly_str(T)}, max degree = {max_deg}")


if __name__ == "__main__":
    reliability_analysis()
    partition_function()
    matroid_bridge()
    tropical_geometry()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Demonstration of the Universal Support-Tutte Polynomial

Computes the support-Tutte polynomial T(S) for various M-convex support sets,
demonstrates order-independence by comparing different coordinate orderings,
and shows how non-matroidal supports carry extra information.

The support-Tutte polynomial is defined by:
  T(∅) = 1
  T({0}) = 1
  T(S) = T(del S i) + T(con S i)   for ordinary coordinates i
  T(S) = X * T(con S i)            for loop coordinates i

where:
  del S i = {m ∈ S : m(i) = 0}
  con S i = {m - e_i : m ∈ S, m(i) > 0}
"""

from typing import FrozenSet, Tuple, Dict
from collections import defaultdict
import itertools

# Represent support elements as tuples of non-negative integers
Element = Tuple[int, ...]
Support = FrozenSet[Element]


def support_delete(S: Support, i: int) -> Support:
    """Delete coordinate i: retain elements with m[i] = 0."""
    return frozenset(m for m in S if m[i] == 0)


def support_contract(S: Support, i: int) -> Support:
    """Tutte contraction at coordinate i: retain m[i] > 0, subtract 1."""
    result = set()
    for m in S:
        if m[i] > 0:
            new = list(m)
            new[i] -= 1
            result.add(tuple(new))
    return frozenset(result)


def is_loop(S: Support, i: int) -> bool:
    """Coordinate i is a loop if all elements have m[i] > 0."""
    return all(m[i] > 0 for m in S) and len(S) > 0


def is_ordinary(S: Support, i: int) -> bool:
    """Coordinate i is ordinary if some m[i] = 0 and some m[i] > 0."""
    has_zero = any(m[i] == 0 for m in S)
    has_pos = any(m[i] > 0 for m in S)
    return has_zero and has_pos


def support_tutte_poly(S: Support, n_coords: int, memo: Dict = None) -> Dict[int, int]:
    """
    Compute the support-Tutte polynomial T(S) as a dict {power: coefficient}.
    
    Returns a polynomial in X represented as {degree: coefficient}.
    E.g., X^2 + 3X + 1 is {2: 1, 1: 3, 0: 1}.
    """
    if memo is None:
        memo = {}
    
    key = S
    if key in memo:
        return memo[key]
    
    # Base cases
    if len(S) == 0:
        result = {0: 1}
        memo[key] = result
        return result
    
    zero = tuple(0 for _ in range(n_coords))
    if S == frozenset({zero}):
        result = {0: 1}
        memo[key] = result
        return result
    
    # Find an ordinary or loop coordinate
    for i in range(n_coords):
        if is_ordinary(S, i):
            d = support_tutte_poly(support_delete(S, i), n_coords, memo)
            c = support_tutte_poly(support_contract(S, i), n_coords, memo)
            result = poly_add(d, c)
            memo[key] = result
            return result
    
    for i in range(n_coords):
        if is_loop(S, i):
            c = support_tutte_poly(support_contract(S, i), n_coords, memo)
            result = poly_mul_x(c)
            memo[key] = result
            return result
    
    # Fallback (should not happen for valid supports)
    result = {0: 1}
    memo[key] = result
    return result


def poly_add(p: Dict[int, int], q: Dict[int, int]) -> Dict[int, int]:
    """Add two polynomials."""
    result = dict(p)
    for k, v in q.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}


def poly_mul_x(p: Dict[int, int]) -> Dict[int, int]:
    """Multiply polynomial by X."""
    return {k + 1: v for k, v in p.items()}


def poly_eval(p: Dict[int, int], x: int) -> int:
    """Evaluate polynomial at x."""
    return sum(coeff * x**deg for deg, coeff in p.items())


def poly_str(p: Dict[int, int]) -> str:
    """Pretty-print polynomial."""
    if not p:
        return "0"
    terms = []
    for deg in sorted(p.keys(), reverse=True):
        coeff = p[deg]
        if coeff == 0:
            continue
        if deg == 0:
            terms.append(str(coeff))
        elif deg == 1:
            terms.append(f"{coeff}X" if coeff != 1 else "X")
        else:
            terms.append(f"{coeff}X^{deg}" if coeff != 1 else f"X^{deg}")
    return " + ".join(terms) if terms else "0"


def support_tutte_with_order(S: Support, n_coords: int, order: list) -> Dict[int, int]:
    """
    Compute T(S) using a specific coordinate ordering.
    At each step, prefer the first coordinate in 'order' that is ordinary/loop.
    """
    memo = {}
    
    def compute(S):
        key = S
        if key in memo:
            return memo[key]
        
        if len(S) == 0:
            result = {0: 1}
            memo[key] = result
            return result
        
        zero = tuple(0 for _ in range(n_coords))
        if S == frozenset({zero}):
            result = {0: 1}
            memo[key] = result
            return result
        
        for i in order:
            if is_ordinary(S, i):
                d = compute(support_delete(S, i))
                c = compute(support_contract(S, i))
                result = poly_add(d, c)
                memo[key] = result
                return result
        
        for i in order:
            if is_loop(S, i):
                c = compute(support_contract(S, i))
                result = poly_mul_x(c)
                memo[key] = result
                return result
        
        result = {0: 1}
        memo[key] = result
        return result
    
    return compute(S)


def check_exchange(S: Support, n_coords: int) -> bool:
    """Check if S satisfies the symmetric exchange property (M-convexity)."""
    for x in S:
        for y in S:
            for a in range(n_coords):
                if x[a] > y[a]:
                    found = False
                    for b in range(n_coords):
                        if y[b] > x[b]:
                            new_x = list(x)
                            new_x[a] -= 1
                            new_x[b] += 1
                            new_y = list(y)
                            new_y[a] += 1
                            new_y[b] -= 1
                            if tuple(new_x) in S and tuple(new_y) in S:
                                found = True
                                break
                    if not found:
                        return False
    return True


def enumerate_simplex_subsets(n_vars: int, max_deg: int):
    """
    Enumerate all subsets of the degree-≤max_deg simplex in n_vars variables
    that satisfy the exchange property.
    """
    # Generate all points in the simplex
    points = []
    for combo in itertools.product(range(max_deg + 1), repeat=n_vars):
        if sum(combo) <= max_deg:
            points.append(combo)
    
    m_convex_sets = []
    # Check subsets of reasonable size
    for size in range(1, min(len(points) + 1, 8)):
        for subset in itertools.combinations(points, size):
            S = frozenset(subset)
            if check_exchange(S, n_vars):
                m_convex_sets.append(S)
    
    return m_convex_sets


# ============== DEMONSTRATIONS ==============

print("=" * 70)
print("UNIVERSAL SUPPORT-TUTTE POLYNOMIAL — DEMONSTRATIONS")
print("=" * 70)

# Demo 1: Simple examples
print("\n--- Demo 1: Simple support-Tutte polynomials ---")

examples = [
    ("Empty set", frozenset(), 2),
    ("Singleton {(0,0)}", frozenset({(0, 0)}), 2),
    ("Binary {(0,0), (1,0)}", frozenset({(0, 0), (1, 0)}), 2),
    ("Binary {(0,1), (1,0)}", frozenset({(0, 1), (1, 0)}), 2),
    ("Non-binary {(0,0), (2,0)}", frozenset({(0, 0), (2, 0)}), 2),
    ("Loop {(1,)}", frozenset({(1,)}), 1),
    ("Loop {(2,)}", frozenset({(2,)}), 1),
    ("Three elements {(0), (1), (2)}", frozenset({(0,), (1,), (2,)}), 1),
    ("U_{1,3} indicators", frozenset({(0, 0, 1), (0, 1, 0), (1, 0, 0)}), 3),
]

for name, S, n in examples:
    T = support_tutte_poly(S, n)
    val_at_1 = poly_eval(T, 1)
    print(f"  {name}: T(S) = {poly_str(T)}, T(1) = {val_at_1}, |S| = {len(S)}")

# Demo 2: Order independence
print("\n--- Demo 2: Order independence comparison ---")

test_supports = [
    ("3-element binary", frozenset({(0, 0, 1), (0, 1, 0), (1, 0, 0)}), 3),
    ("Mixed {(0,0), (1,1), (0,1)}", frozenset({(0, 0), (1, 1), (0, 1)}), 2),
    ("{(0,0,0), (1,0,0), (0,1,0), (0,0,1)}", 
     frozenset({(0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1)}), 3),
]

for name, S, n in test_supports:
    orders = list(itertools.permutations(range(n)))
    results = set()
    for order in orders:
        T = support_tutte_with_order(S, n, list(order))
        results.add(frozenset(T.items()))
    
    T_default = support_tutte_poly(S, n)
    all_same = len(results) == 1
    print(f"  {name}:")
    print(f"    T(S) = {poly_str(T_default)}")
    print(f"    Tested {len(orders)} orderings: {'ALL AGREE ✓' if all_same else 'DIFFER ✗'}")

# Demo 3: Non-matroidal supports
print("\n--- Demo 3: Non-matroidal supports (multiplicities > 1) ---")

# These supports have coordinate values > 1, so they are NOT matroidal
non_matroidal = [
    ("{(0,0), (2,0)}", frozenset({(0, 0), (2, 0)}), 2),
    ("{(0,0), (0,2)}", frozenset({(0, 0), (0, 2)}), 2),
    ("{(0,0), (1,1)}", frozenset({(0, 0), (1, 1)}), 2),
    ("{(0,0), (2,0), (0,2)}", frozenset({(0, 0), (2, 0), (0, 2)}), 2),
    ("{(0,0), (1,0), (2,0)}", frozenset({(0, 0), (1, 0), (2, 0)}), 1),
]

print("  Comparing with matroidal shadow (values clamped to {0,1}):")
for name, S, n in non_matroidal:
    T = support_tutte_poly(S, n)
    
    # Create matroidal shadow (clamp to 0/1)
    shadow = frozenset(
        tuple(min(v, 1) for v in m) for m in S
    )
    T_shadow = support_tutte_poly(shadow, n)
    
    same = (T == T_shadow)
    print(f"  {name}: T = {poly_str(T)}")
    print(f"    Shadow: T = {poly_str(T_shadow)}")
    print(f"    Same? {'Yes' if same else 'No — support-Tutte sees extra structure!'}")

# Demo 4: Cardinality verification
print("\n--- Demo 4: T(1) = |S| verification (cardinality theorem) ---")

test_sets = [
    frozenset({(0, 0), (1, 0)}),
    frozenset({(0, 0), (1, 0), (0, 1)}),
    frozenset({(0, 0), (2, 0)}),
    frozenset({(1,), (2,), (3,)}),
    frozenset({(0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1)}),
]

all_pass = True
for S in test_sets:
    n = len(next(iter(S)))
    T = support_tutte_poly(S, n)
    val = poly_eval(T, 1)
    ok = val == len(S)
    if not ok:
        all_pass = False
    print(f"  |S| = {len(S)}, T(1) = {val} {'✓' if ok else '✗'}")

print(f"  All cardinality checks: {'PASSED ✓' if all_pass else 'FAILED ✗'}")

# Demo 5: M-convex subsets enumeration
print("\n--- Demo 5: M-convex supports in degree-≤3 simplex (2 variables) ---")

m_convex = enumerate_simplex_subsets(2, 3)
print(f"  Found {len(m_convex)} M-convex subsets")

# Show some interesting ones
for S in sorted(m_convex, key=lambda s: (len(s), sorted(s)))[:10]:
    T = support_tutte_poly(S, 2)
    print(f"    S = {sorted(S)}: T = {poly_str(T)}")

print(f"  ... ({len(m_convex)} total)")

# Demo 6: Statistics
print("\n--- Demo 6: Polynomial statistics ---")
degree_counts = defaultdict(int)
for S in m_convex:
    T = support_tutte_poly(S, 2)
    max_deg = max(T.keys()) if T else 0
    degree_counts[max_deg] += 1

print("  Distribution of max polynomial degree:")
for deg in sorted(degree_counts):
    print(f"    degree {deg}: {degree_counts[deg]} supports")

print("\n" + "=" * 70)
print("All demonstrations complete.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Deletion-Contraction Recursion Tree

Shows the recursive structure of the support-Tutte polynomial computation,
illustrating how deletion and contraction decompose a support into smaller
pieces. Each node shows the support and its polynomial value.

This visualizes the core mathematical idea: a universal recursion scheme
that assigns polynomial invariants to discrete convex structures.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# ===== Inline all needed functions =====

def poly_add(p, q):
    result = dict(p)
    for k, v in q.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_mul_x(p):
    return {k + 1: v for k, v in p.items()}

def poly_str(p):
    if not p:
        return "0"
    terms = []
    for deg in sorted(p.keys(), reverse=True):
        coeff = p[deg]
        if coeff == 0:
            continue
        if deg == 0:
            terms.append(str(coeff))
        elif deg == 1:
            terms.append(f"{coeff}X" if coeff != 1 else "X")
        else:
            terms.append(f"{coeff}X^{deg}" if coeff != 1 else f"X^{deg}")
    return " + ".join(terms) if terms else "0"

def support_str(S):
    if len(S) == 0:
        return "∅"
    return "{" + ", ".join(str(m) for m in sorted(S)) + "}"

def support_tutte_tree(S, n, depth=0):
    """Compute T(S) and return the recursion tree."""
    zero = tuple(0 for _ in range(n))
    
    if len(S) == 0:
        return {'S': S, 'T': {0: 1}, 'type': 'empty', 'children': []}
    
    if S == frozenset({zero}):
        return {'S': S, 'T': {0: 1}, 'type': 'zero', 'children': []}
    
    for i in range(n):
        has_zero = any(m[i] == 0 for m in S)
        has_pos = any(m[i] > 0 for m in S)
        if has_zero and has_pos:
            del_S = frozenset(m for m in S if m[i] == 0)
            contracted = set()
            for m in S:
                if m[i] > 0:
                    new_m = list(m)
                    new_m[i] -= 1
                    contracted.add(tuple(new_m))
            con_S = frozenset(contracted)
            
            left = support_tutte_tree(del_S, n, depth + 1)
            right = support_tutte_tree(con_S, n, depth + 1)
            T = poly_add(left['T'], right['T'])
            
            return {
                'S': S, 'T': T, 'type': 'ordinary',
                'coord': i,
                'children': [left, right]
            }
    
    for i in range(n):
        if all(m[i] > 0 for m in S):
            contracted = set()
            for m in S:
                new_m = list(m)
                new_m[i] -= 1
                contracted.add(tuple(new_m))
            con_S = frozenset(contracted)
            
            child = support_tutte_tree(con_S, n, depth + 1)
            T = poly_mul_x(child['T'])
            
            return {
                'S': S, 'T': T, 'type': 'loop',
                'coord': i,
                'children': [child]
            }
    
    return {'S': S, 'T': {0: 1}, 'type': 'fallback', 'children': []}


def draw_tree(ax, node, x, y, dx, dy, level=0):
    """Draw the recursion tree on a matplotlib axis."""
    # Node colors
    colors = {
        'empty': '#e8e8e8',
        'zero': '#d4edda', 
        'ordinary': '#cce5ff',
        'loop': '#fff3cd',
        'fallback': '#e8e8e8'
    }
    
    color = colors.get(node['type'], '#ffffff')
    
    # Draw node box
    box_w, box_h = 2.0, 0.9
    rect = patches.FancyBboxPatch(
        (x - box_w/2, y - box_h/2), box_w, box_h,
        boxstyle="round,pad=0.1", facecolor=color,
        edgecolor='black', linewidth=1.2
    )
    ax.add_patch(rect)
    
    # Node text
    s_str = support_str(node['S'])
    t_str = poly_str(node['T'])
    if len(s_str) > 25:
        s_str = s_str[:22] + "..."
    
    ax.text(x, y + 0.15, s_str, ha='center', va='center', fontsize=6, fontweight='bold')
    ax.text(x, y - 0.2, f"T = {t_str}", ha='center', va='center', fontsize=6, color='navy')
    
    # Label for operation type
    if node['type'] == 'ordinary':
        ax.text(x, y + 0.35, f"ord(i={node['coord']})", ha='center', va='center',
                fontsize=5, color='gray')
    elif node['type'] == 'loop':
        ax.text(x, y + 0.35, f"loop(i={node['coord']})", ha='center', va='center',
                fontsize=5, color='orange')
    
    # Draw children
    children = node['children']
    if len(children) == 2:
        labels = ['del', 'con']
        for idx, (child, label) in enumerate(zip(children, labels)):
            cx = x + (idx - 0.5) * dx
            cy = y + dy
            ax.plot([x, cx], [y - box_h/2, cy + box_h/2], 
                    'k-', linewidth=0.8)
            ax.text((x + cx)/2, (y - box_h/2 + cy + box_h/2)/2 + 0.15,
                    label, fontsize=6, color='red', ha='center')
            draw_tree(ax, child, cx, cy, dx * 0.5, dy, level + 1)
    elif len(children) == 1:
        cx, cy = x, y + dy
        ax.plot([x, cx], [y - box_h/2, cy + box_h/2], 
                'k-', linewidth=0.8)
        ax.text(x + 0.15, (y - box_h/2 + cy + box_h/2)/2 + 0.15,
                '×X', fontsize=7, color='orange', ha='center', fontweight='bold')
        draw_tree(ax, children[0], cx, cy, dx * 0.7, dy, level + 1)


# ===== Create visualization =====

# Example: S = {(0,0), (1,0), (0,1)} — basis indicators of U_{1,2}
S = frozenset({(0, 0), (1, 0), (0, 1)})
tree = support_tutte_tree(S, 2)

fig, ax = plt.subplots(1, 1, figsize=(14, 8))
ax.set_xlim(-8, 8)
ax.set_ylim(-7, 1.5)
ax.set_aspect('equal')
ax.axis('off')

ax.set_title(
    'Deletion-Contraction Recursion Tree\n'
    f'Support: {support_str(S)} → T(S) = {poly_str(tree["T"])}',
    fontsize=13, fontweight='bold', pad=15
)

draw_tree(ax, tree, 0, 0.5, 4, -2.2)

# Legend
legend_items = [
    ('Ordinary (del + con)', '#cce5ff'),
    ('Loop (× X)', '#fff3cd'),
    ('Base case', '#d4edda'),
]
for idx, (label, color) in enumerate(legend_items):
    rect = patches.Rectangle((4.5, -5.5 + idx * 0.6), 0.4, 0.35,
                             facecolor=color, edgecolor='black')
    ax.add_patch(rect)
    ax.text(5.1, -5.5 + idx * 0.6 + 0.17, label, fontsize=8, va='center')

plt.tight_layout()
plt.savefig('recursion_tree.png', dpi=150, bbox_inches='tight')
print("Saved recursion tree visualization")


#!/usr/bin/env python3
"""
Visualization: Support-Tutte Polynomial Landscape

Visualizes how the support-Tutte polynomial varies across different M-convex
supports in the degree-≤4 simplex with 2 variables. Shows the polynomial
degree and coefficient structure as a heatmap.

This reveals the "arithmetic landscape" of support invariants — structure
that classical matroid Tutte theory cannot see.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
import itertools

# ===== Inline all needed functions =====

def poly_add(p, q):
    result = dict(p)
    for k, v in q.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_mul_x(p):
    return {k + 1: v for k, v in p.items()}

def poly_eval(p, x):
    return sum(coeff * x**deg for deg, coeff in p.items())

def poly_str(p):
    if not p:
        return "0"
    terms = []
    for deg in sorted(p.keys(), reverse=True):
        coeff = p[deg]
        if coeff == 0:
            continue
        if deg == 0:
            terms.append(str(coeff))
        elif deg == 1:
            terms.append(f"{coeff}X" if coeff != 1 else "X")
        else:
            terms.append(f"{coeff}X^{deg}" if coeff != 1 else f"X^{deg}")
    return " + ".join(terms) if terms else "0"

def support_tutte(S, n, memo=None):
    if memo is None:
        memo = {}
    if S in memo:
        return memo[S]
    if len(S) == 0:
        result = {0: 1}
    elif S == frozenset({tuple(0 for _ in range(n))}):
        result = {0: 1}
    else:
        result = None
        for i in range(n):
            has_zero = any(m[i] == 0 for m in S)
            has_pos = any(m[i] > 0 for m in S)
            if has_zero and has_pos:
                d = support_tutte(frozenset(m for m in S if m[i] == 0), n, memo)
                contracted = set()
                for m in S:
                    if m[i] > 0:
                        new_m = list(m)
                        new_m[i] -= 1
                        contracted.add(tuple(new_m))
                c = support_tutte(frozenset(contracted), n, memo)
                result = poly_add(d, c)
                break
        if result is None:
            for i in range(n):
                if all(m[i] > 0 for m in S):
                    contracted = set()
                    for m in S:
                        new_m = list(m)
                        new_m[i] -= 1
                        contracted.add(tuple(new_m))
                    c = support_tutte(frozenset(contracted), n, memo)
                    result = poly_mul_x(c)
                    break
        if result is None:
            result = {0: 1}
    memo[S] = result
    return result

def check_exchange(S, n):
    for x in S:
        for y in S:
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            nx = list(x); nx[a] -= 1; nx[b] += 1
                            ny = list(y); ny[a] += 1; ny[b] -= 1
                            if tuple(nx) in S and tuple(ny) in S:
                                found = True; break
                    if not found:
                        return False
    return True

# ===== Generate data =====

max_deg = 4
n_vars = 2

# Generate all simplex points
points = []
for combo in itertools.product(range(max_deg + 1), repeat=n_vars):
    if sum(combo) <= max_deg:
        points.append(combo)

# Find M-convex subsets and compute polynomials
data = []
for size in range(1, min(len(points) + 1, 7)):
    for subset in itertools.combinations(points, size):
        S = frozenset(subset)
        if check_exchange(S, n_vars):
            T = support_tutte(S, n_vars)
            max_power = max(T.keys()) if T else 0
            leading_coeff = T.get(max_power, 0)
            eval_2 = poly_eval(T, 2)
            data.append({
                'S': S, 'T': T, 'size': len(S),
                'max_deg': max_power, 'leading': leading_coeff,
                'eval_2': eval_2, 'poly_str': poly_str(T)
            })

# ===== Create figure =====

fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Universal Support-Tutte Polynomial Landscape\n'
             f'M-convex supports in degree-≤{max_deg} simplex ({n_vars} variables)',
             fontsize=14, fontweight='bold')

# Plot 1: Size vs Max Degree scatter
ax1 = axes[0, 0]
sizes = [d['size'] for d in data]
degs = [d['max_deg'] for d in data]
colors = [d['eval_2'] for d in data]
scatter = ax1.scatter(sizes, degs, c=colors, cmap='viridis', 
                      alpha=0.7, edgecolors='black', linewidths=0.5, s=60)
ax1.set_xlabel('Support size |S|')
ax1.set_ylabel('Max polynomial degree')
ax1.set_title('Polynomial Degree vs Support Size')
plt.colorbar(scatter, ax=ax1, label='T(2)')

# Plot 2: Distribution of polynomial degrees
ax2 = axes[0, 1]
deg_counts = defaultdict(int)
for d in data:
    deg_counts[d['max_deg']] += 1
deg_keys = sorted(deg_counts.keys())
ax2.bar(deg_keys, [deg_counts[k] for k in deg_keys], 
        color='steelblue', edgecolor='black')
ax2.set_xlabel('Max polynomial degree')
ax2.set_ylabel('Number of M-convex supports')
ax2.set_title('Distribution of Polynomial Degrees')

# Plot 3: Evaluation curve for select supports
ax3 = axes[1, 0]
x_vals = np.linspace(0, 3, 100)
interesting = sorted(data, key=lambda d: d['max_deg'], reverse=True)[:6]
for d in interesting:
    y_vals = [poly_eval(d['T'], x) for x in x_vals]
    ax3.plot(x_vals, y_vals, label=f"|S|={d['size']}, T={d['poly_str']}", 
             linewidth=1.5)
ax3.set_xlabel('X')
ax3.set_ylabel('T(X)')
ax3.set_title('Support-Tutte Polynomial Evaluation Curves')
ax3.legend(fontsize=7, loc='upper left')
ax3.set_ylim(0, max(50, max(poly_eval(d['T'], 3) for d in interesting)))

# Plot 4: Binary vs non-binary comparison
ax4 = axes[1, 1]
binary = [d for d in data if all(all(v <= 1 for v in m) for m in d['S'])]
nonbinary = [d for d in data if any(any(v > 1 for v in m) for m in d['S'])]
bins_deg_b = defaultdict(int)
bins_deg_nb = defaultdict(int)
for d in binary:
    bins_deg_b[d['max_deg']] += 1
for d in nonbinary:
    bins_deg_nb[d['max_deg']] += 1
all_degs = sorted(set(list(bins_deg_b.keys()) + list(bins_deg_nb.keys())))
width = 0.35
x_pos = np.arange(len(all_degs))
ax4.bar(x_pos - width/2, [bins_deg_b.get(k, 0) for k in all_degs],
        width, label='Binary (matroidal)', color='cornflowerblue', edgecolor='black')
ax4.bar(x_pos + width/2, [bins_deg_nb.get(k, 0) for k in all_degs],
        width, label='Non-binary', color='salmon', edgecolor='black')
ax4.set_xticks(x_pos)
ax4.set_xticklabels(all_degs)
ax4.set_xlabel('Max polynomial degree')
ax4.set_ylabel('Count')
ax4.set_title('Binary vs Non-binary Supports')
ax4.legend()

plt.tight_layout()
plt.savefig('tutte_landscape.png', dpi=150, bbox_inches='tight')
print(f"Saved visualization with {len(data)} M-convex supports")
