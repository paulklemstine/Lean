#!/usr/bin/env python3
"""
applications.py — Real-world applications of shadow complexity theory.

Demonstrates how support-geometric lower bounds apply to:
1. Automatic differentiation optimization
2. Sparse polynomial multiplication
3. Newton polytope analysis
4. Symbolic computation planning
"""

from itertools import product as cartesian_product
from typing import Set, Tuple, Dict, List
import math

ExponentVector = Tuple[int, ...]


# ─── Inline core functions ───────────────────────────────────────────

def subtract_pair_basis(alpha: ExponentVector, i: int, j: int):
    lst = list(alpha)
    if lst[i] < 1:
        return None
    lst[i] -= 1
    if lst[j] < 1:
        return None
    lst[j] -= 1
    return tuple(lst)

def second_shadow(S: Set[ExponentVector], n: int) -> Set[ExponentVector]:
    shadow = set()
    for alpha in S:
        for i in range(n):
            for j in range(n):
                beta = subtract_pair_basis(alpha, i, j)
                if beta is not None:
                    shadow.add(beta)
    return shadow

def hessian_channel_support(S, n, i, j):
    ch = set()
    for alpha in S:
        beta = subtract_pair_basis(alpha, i, j)
        if beta is not None:
            ch.add(beta)
    return ch

def simplex_support(d, m):
    if d == 0:
        return {()} if m == 0 else set()
    if d == 1:
        return {(m,)}
    result = set()
    for first in range(m + 1):
        for rest in simplex_support(d - 1, m - first):
            result.add((first,) + rest)
    return result


# ═══════════════════════════════════════════════════════════════════
# Application 1: Automatic Differentiation Cost Estimation
# ═══════════════════════════════════════════════════════════════════

def autodiff_cost_estimate(support: Set[ExponentVector], n: int) -> Dict:
    """
    Estimate the minimum cost of computing all second partial derivatives
    (the full Hessian) of a polynomial with given exponent support.
    
    The shadow complexity lower bound tells us:
        min_gates ≥ |Sh₂(S)| / n²
    
    This is useful for automatic differentiation systems that need
    to decide between forward-mode and reverse-mode AD strategies.
    
    Returns cost estimates and recommendations.
    """
    sh = second_shadow(support, n)
    shadow_size = len(sh)
    lower_bound = shadow_size / (n ** 2) if n > 0 else 0
    
    # Naive cost: compute each ∂ᵢ∂ⱼf independently
    naive_cost = 0
    for i in range(n):
        for j in range(i, n):  # symmetric Hessian
            ch = hessian_channel_support(support, n, i, j)
            naive_cost += len(ch)
    
    # Sharing-aware cost: use common subexpressions
    all_needed = set()
    channel_specific = {}
    for i in range(n):
        for j in range(n):
            ch = hessian_channel_support(support, n, i, j)
            channel_specific[(i, j)] = ch
            all_needed.update(ch)
    sharing_cost = len(all_needed)
    
    # Sharing ratio
    sharing_ratio = naive_cost / sharing_cost if sharing_cost > 0 else 1.0
    
    return {
        "support_size": len(support),
        "dimension": n,
        "shadow_size": shadow_size,
        "lower_bound": lower_bound,
        "naive_cost": naive_cost,
        "sharing_cost": sharing_cost,
        "sharing_ratio": sharing_ratio,
        "recommendation": "reverse-mode" if n > 5 else "forward-mode",
    }


# ═══════════════════════════════════════════════════════════════════
# Application 2: Sparse Polynomial Hessian Planning
# ═══════════════════════════════════════════════════════════════════

def plan_hessian_computation(support: Set[ExponentVector], n: int) -> Dict:
    """
    Plan the computation of a sparse polynomial's Hessian.
    
    Identifies which channels share the most exponents,
    suggesting an optimal computation order.
    """
    channels = {}
    for i in range(n):
        for j in range(n):
            ch = hessian_channel_support(support, n, i, j)
            if ch:
                channels[(i, j)] = ch
    
    # Find channel pairs with maximum overlap
    max_overlap = 0
    best_pair = None
    channel_list = list(channels.keys())
    
    for idx1 in range(len(channel_list)):
        for idx2 in range(idx1 + 1, len(channel_list)):
            c1, c2 = channel_list[idx1], channel_list[idx2]
            overlap = len(channels[c1] & channels[c2])
            if overlap > max_overlap:
                max_overlap = overlap
                best_pair = (c1, c2)
    
    # Compute channel ordering by greedy coverage
    remaining = set()
    for ch in channels.values():
        remaining.update(ch)
    
    order = []
    covered = set()
    while remaining:
        best_ch = None
        best_new = 0
        for ch_key, ch_set in channels.items():
            if ch_key in [o[0] for o in order]:
                continue
            new_coverage = len(ch_set - covered)
            if new_coverage > best_new:
                best_new = new_coverage
                best_ch = ch_key
        if best_ch is None:
            break
        order.append((best_ch, best_new))
        covered.update(channels[best_ch])
        remaining -= channels[best_ch]
    
    return {
        "num_active_channels": len(channels),
        "max_channel_size": max(len(v) for v in channels.values()) if channels else 0,
        "max_overlap": max_overlap,
        "best_sharing_pair": best_pair,
        "computation_order": order[:5],  # top 5
        "total_unique_outputs": len(second_shadow(support, n)),
    }


# ═══════════════════════════════════════════════════════════════════
# Application 3: Newton Polytope Erosion Analysis
# ═══════════════════════════════════════════════════════════════════

def newton_polytope_analysis(support: Set[ExponentVector], n: int) -> Dict:
    """
    Analyze the Newton polytope erosion properties of a support set.
    
    The second shadow = discrete erosion by the degree-2 simplex.
    This connects to:
    - Mixed volumes in algebraic geometry
    - Tropical geometry
    - Bernstein-Kushnirenko theorem applications
    """
    sh = second_shadow(support, n)
    
    # Compute convex hull vertices (approximate)
    # For each coordinate direction, find min and max
    bounds = []
    sh_bounds = []
    for k in range(n):
        coords = [alpha[k] for alpha in support]
        sh_coords = [beta[k] for beta in sh] if sh else [0]
        bounds.append((min(coords), max(coords)))
        sh_bounds.append((min(sh_coords), max(sh_coords)))
    
    # Erosion shrinkage per coordinate
    shrinkage = []
    for k in range(n):
        original_range = bounds[k][1] - bounds[k][0]
        eroded_range = sh_bounds[k][1] - sh_bounds[k][0] if sh else 0
        shrinkage.append(original_range - eroded_range)
    
    # Volume ratio estimate (lattice point count ratio)
    volume_ratio = len(sh) / len(support) if len(support) > 0 else 0
    
    return {
        "support_size": len(support),
        "shadow_size": len(sh),
        "coordinate_bounds": bounds,
        "shadow_bounds": sh_bounds,
        "coordinate_shrinkage": shrinkage,
        "volume_ratio": volume_ratio,
        "dimension": n,
    }


# ═══════════════════════════════════════════════════════════════════
# Application 4: Complexity Comparison Across Families
# ═══════════════════════════════════════════════════════════════════

def compare_families(max_dim: int = 4, max_degree: int = 8) -> List[Dict]:
    """
    Compare shadow complexity across different polynomial families.
    Useful for identifying which polynomial structures are
    "hardest" for Hessian computation.
    """
    results = []
    
    for d in range(2, max_dim + 1):
        for m in range(3, max_degree + 1):
            S = simplex_support(d, m)
            if len(S) > 10000:
                continue
            sh = second_shadow(S, d)
            lb = len(sh) / (d ** 2) if d > 0 else 0
            
            results.append({
                "family": f"Simplex({d},{m})",
                "n": d,
                "support_size": len(S),
                "shadow_size": len(sh),
                "lower_bound": lb,
                "ratio": len(sh) / len(S) if len(S) > 0 else 0,
            })
    
    return results


# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Shadow Complexity — Applications")
    print("=" * 60)
    
    # Application 1: AD cost estimation
    print("\n1. AUTOMATIC DIFFERENTIATION COST ESTIMATION")
    print("-" * 50)
    for d, m in [(3, 5), (4, 4), (2, 8)]:
        S = simplex_support(d, m)
        result = autodiff_cost_estimate(S, d)
        print(f"  Simplex({d},{m}): |S|={result['support_size']}, "
              f"|Sh₂|={result['shadow_size']}, "
              f"LB={result['lower_bound']:.1f}, "
              f"naive={result['naive_cost']}, "
              f"shared={result['sharing_cost']}, "
              f"ratio={result['sharing_ratio']:.2f}")
    
    # Application 2: Hessian planning
    print("\n2. HESSIAN COMPUTATION PLANNING")
    print("-" * 50)
    S = simplex_support(3, 6)
    plan = plan_hessian_computation(S, 3)
    print(f"  Simplex(3,6): {plan['num_active_channels']} active channels, "
          f"max overlap={plan['max_overlap']}, "
          f"total outputs={plan['total_unique_outputs']}")
    print(f"  Best sharing pair: {plan['best_sharing_pair']}")
    print(f"  Top computation order:")
    for ch, new_cov in plan['computation_order']:
        print(f"    Channel {ch}: {new_cov} new exponents")
    
    # Application 3: Newton polytope erosion
    print("\n3. NEWTON POLYTOPE EROSION")
    print("-" * 50)
    for d, m in [(2, 6), (3, 5), (4, 4)]:
        S = simplex_support(d, m)
        analysis = newton_polytope_analysis(S, d)
        print(f"  Simplex({d},{m}): |S|={analysis['support_size']}, "
              f"|Sh₂|={analysis['shadow_size']}, "
              f"vol_ratio={analysis['volume_ratio']:.3f}, "
              f"shrinkage={analysis['coordinate_shrinkage']}")
    
    # Application 4: Family comparison
    print("\n4. FAMILY COMPARISON")
    print("-" * 50)
    results = compare_families()
    print(f"  {'Family':>15} {'n':>3} {'|S|':>6} {'|Sh₂|':>6} {'LB':>8} {'|Sh₂|/|S|':>10}")
    for r in results[:15]:
        print(f"  {r['family']:>15} {r['n']:>3} {r['support_size']:>6} "
              f"{r['shadow_size']:>6} {r['lower_bound']:>8.1f} "
              f"{r['ratio']:>10.3f}")


#!/usr/bin/env python3
"""
Shadow Complexity Demo — Interactive exploration of second shadows
and arithmetic circuit lower bounds for Hessian computation.

Demonstrates:
1. Computing second shadows of exponent support sets
2. Computing per-channel Hessian supports
3. Estimating the lower bound |Sh₂(S)| / n²
4. Comparing with heuristic Hessian-sharing constructions
5. Exploring simplex support families
"""

from itertools import product
from typing import Set, Tuple, Dict, FrozenSet, List
import math


# ─── Core Definitions ────────────────────────────────────────────────

ExponentVector = Tuple[int, ...]

def second_shadow(S: Set[ExponentVector], n: int) -> Set[ExponentVector]:
    """
    Compute the second shadow Sh₂(S) of a support set S ⊆ ℕⁿ.
    
    β ∈ Sh₂(S) iff ∃ α ∈ S, ∃ i,j ∈ {0,...,n-1}: 
        α = β + eᵢ + eⱼ (coordinatewise)
    
    Equivalently, β is obtained from some α ∈ S by subtracting
    two basis vectors (possibly the same).
    """
    shadow = set()
    for alpha in S:
        for i in range(n):
            for j in range(n):
                # Check if subtraction is valid
                if i == j:
                    if alpha[i] >= 2:
                        beta = list(alpha)
                        beta[i] -= 2
                        shadow.add(tuple(beta))
                else:
                    if alpha[i] >= 1 and alpha[j] >= 1:
                        beta = list(alpha)
                        beta[i] -= 1
                        beta[j] -= 1
                        shadow.add(tuple(beta))
    return shadow


def hessian_channel_support(S: Set[ExponentVector], n: int, i: int, j: int) -> Set[ExponentVector]:
    """
    Compute the (i,j)-channel Hessian support: exponent vectors
    appearing in ∂ᵢ∂ⱼf for polynomials with support S.
    """
    channel = set()
    for alpha in S:
        if i == j:
            if alpha[i] >= 2:
                beta = list(alpha)
                beta[i] -= 2
                channel.add(tuple(beta))
        else:
            if alpha[i] >= 1 and alpha[j] >= 1:
                beta = list(alpha)
                beta[i] -= 1
                beta[j] -= 1
                channel.add(tuple(beta))
    return channel


def hessian_support_family(S: Set[ExponentVector], n: int) -> Set[Tuple[Tuple[int, int], ExponentVector]]:
    """
    Compute the full Hessian support family:
    {((i,j), β) : β appears in ∂ᵢ∂ⱼf for support S}
    """
    family = set()
    for i in range(n):
        for j in range(n):
            for beta in hessian_channel_support(S, n, i, j):
                family.add(((i, j), beta))
    return family


def lower_bound(S: Set[ExponentVector], n: int) -> float:
    """
    Compute the shadow-geometric lower bound on circuit size:
    |Sh₂(S)| / n²
    """
    if n == 0:
        return 0.0
    sh = second_shadow(S, n)
    return len(sh) / (n ** 2)


# ─── Support Families ────────────────────────────────────────────────

def simplex_support(d: int, m: int) -> Set[ExponentVector]:
    """
    Simplex support: all α ∈ ℕᵈ with ∑αᵢ = m.
    These are monomials of a homogeneous polynomial of degree m.
    """
    if d == 0:
        return {()} if m == 0 else set()
    if d == 1:
        return {(m,)}
    result = set()
    for first in range(m + 1):
        for rest in simplex_support(d - 1, m - first):
            result.add((first,) + rest)
    return result


def product_support(dims: List[int], degrees: List[int]) -> Set[ExponentVector]:
    """
    Product support: Cartesian product of simplex supports.
    E.g., product_support([2, 2], [m, m]) gives all (a,b,c,d)
    with a+b=m, c+d=m.
    """
    pieces = []
    for d, m in zip(dims, degrees):
        pieces.append(simplex_support(d, m))
    result = set()
    for combo in product(*pieces):
        vec = ()
        for part in combo:
            vec = vec + part
        result.add(vec)
    return result


def cube_support(n: int, m: int) -> Set[ExponentVector]:
    """
    Cube support: all α ∈ {0,...,m}ⁿ.
    """
    return set(product(range(m + 1), repeat=n))


def staircase_support(n: int, m: int) -> Set[ExponentVector]:
    """
    Staircase support: all α ∈ ℕⁿ with max(αᵢ) ≤ m and αᵢ ≥ αᵢ₊₁.
    """
    if n == 0:
        return {()}
    result = set()
    for first in range(m + 1):
        for rest in staircase_support(n - 1, first):
            result.add((first,) + rest)
    return result


# ─── Heuristic Circuit Construction ──────────────────────────────────

def greedy_shared_circuit(S: Set[ExponentVector], n: int) -> int:
    """
    Heuristic: greedily build a circuit for Hessian support computation.
    
    Strategy: maintain a set of "available" exponent vectors.
    For each channel (i,j), check which required exponents are not
    yet available. Add them as new gates. Each gate can serve
    multiple channels.
    
    Returns the estimated circuit size (number of gates).
    """
    available = set()
    gates = 0
    
    for i in range(n):
        for j in range(n):
            needed = hessian_channel_support(S, n, i, j)
            new_needed = needed - available
            gates += len(new_needed)
            available.update(new_needed)
    
    return gates


# ─── Interactive Demo ─────────────────────────────────────────────────

def demo_simplex_family():
    """Demonstrate shadow complexity for simplex support families."""
    print("=" * 70)
    print("SIMPLEX SUPPORT FAMILIES: S = {α ∈ ℕᵈ : Σαᵢ = m}")
    print("=" * 70)
    print()
    print(f"{'d':>4} {'m':>4} {'|S|':>8} {'|Sh₂(S)|':>10} {'LB=|Sh₂|/d²':>14} {'Greedy':>8} {'Ratio':>8}")
    print("-" * 70)
    
    for d in [2, 3, 4]:
        for m in [3, 5, 8, 12]:
            S = simplex_support(d, m)
            if len(S) > 50000:
                continue
            n = d
            sh = second_shadow(S, n)
            lb = lower_bound(S, n)
            greedy = greedy_shared_circuit(S, n)
            ratio = greedy / lb if lb > 0 else float('inf')
            print(f"{d:>4} {m:>4} {len(S):>8} {len(sh):>10} {lb:>14.2f} {greedy:>8} {ratio:>8.2f}")
    print()


def demo_product_family():
    """Demonstrate shadow complexity for product support families."""
    print("=" * 70)
    print("PRODUCT SUPPORT: S = {(a,b,c,d) : a+b=m, c+d=m}")
    print("=" * 70)
    print()
    print(f"{'m':>4} {'|S|':>8} {'|Sh₂(S)|':>10} {'n':>4} {'LB=|Sh₂|/n²':>14} {'Greedy':>8}")
    print("-" * 60)
    
    for m in [2, 3, 5, 8, 12, 15]:
        S = product_support([2, 2], [m, m])
        n = 4
        sh = second_shadow(S, n)
        lb = lower_bound(S, n)
        greedy = greedy_shared_circuit(S, n)
        print(f"{m:>4} {len(S):>8} {len(sh):>10} {n:>4} {lb:>14.2f} {greedy:>8}")
    print()


def demo_cube_family():
    """Demonstrate shadow complexity for cube support families."""
    print("=" * 70)
    print("CUBE SUPPORT: S = {0,...,m}ⁿ")
    print("=" * 70)
    print()
    print(f"{'n':>4} {'m':>4} {'|S|':>8} {'|Sh₂(S)|':>10} {'LB=|Sh₂|/n²':>14} {'Greedy':>8}")
    print("-" * 60)
    
    for n_val in [2, 3, 4]:
        for m in [2, 4, 6, 8]:
            S = cube_support(n_val, m)
            if len(S) > 50000:
                continue
            sh = second_shadow(S, n_val)
            lb = lower_bound(S, n_val)
            greedy = greedy_shared_circuit(S, n_val)
            print(f"{n_val:>4} {m:>4} {len(S):>8} {len(sh):>10} {lb:>14.2f} {greedy:>8}")
    print()


def demo_shadow_coverage():
    """Verify the shadow coverage theorem on concrete examples."""
    print("=" * 70)
    print("SHADOW COVERAGE VERIFICATION")
    print("Checking: β ∈ Sh₂(S) ⟺ ∃ (i,j) channel containing β")
    print("=" * 70)
    print()
    
    for name, S, n in [
        ("Triangle d=2, m=4", simplex_support(2, 4), 2),
        ("Cube n=2, m=3", cube_support(2, 3), 2),
        ("Product m=3", product_support([2, 2], [3, 3]), 4),
    ]:
        sh = second_shadow(S, n)
        # Verify each shadow element has a channel
        all_channeled = True
        for beta in sh:
            found = False
            for i in range(n):
                for j in range(n):
                    ch = hessian_channel_support(S, n, i, j)
                    if beta in ch:
                        found = True
                        break
                if found:
                    break
            if not found:
                all_channeled = False
                break
        
        # Verify no channel element is outside shadow
        all_in_shadow = True
        for i in range(n):
            for j in range(n):
                ch = hessian_channel_support(S, n, i, j)
                if not ch.issubset(sh):
                    all_in_shadow = False
                    break
        
        status = "✓" if (all_channeled and all_in_shadow) else "✗"
        print(f"  {status} {name}: |S|={len(S)}, |Sh₂|={len(sh)}, "
              f"coverage={'PASS' if all_channeled else 'FAIL'}, "
              f"containment={'PASS' if all_in_shadow else 'FAIL'}")
    print()


def demo_simplex_shadow_equality():
    """Verify Sh₂(simplex(d,m)) = simplex(d,m-2) for various d,m."""
    print("=" * 70)
    print("SIMPLEX SHADOW EQUALITY: Sh₂(Simplex(d,m)) = Simplex(d,m-2)")
    print("=" * 70)
    print()
    
    for d in [1, 2, 3, 4, 5]:
        for m in [2, 3, 5, 8]:
            S = simplex_support(d, m)
            if len(S) > 100000:
                continue
            sh = second_shadow(S, d)
            target = simplex_support(d, m - 2)
            match = sh == target
            binom_s = math.comb(m + d - 1, d - 1) if d >= 1 else 0
            binom_sh = math.comb(m - 2 + d - 1, d - 1) if d >= 1 and m >= 2 else 0
            print(f"  d={d}, m={m}: |S|={len(S)} (C({m+d-1},{d-1})={binom_s}), "
                  f"|Sh₂|={len(sh)} (C({m-2+d-1},{d-1})={binom_sh}), "
                  f"equality={'✓' if match else '✗'}")
    print()


def demo_lower_bound_tightness():
    """Examine how tight the n² factor is in the lower bound."""
    print("=" * 70)
    print("LOWER BOUND TIGHTNESS ANALYSIS")
    print("|Sh₂(S)| ≤ n² · circuit_size  →  circuit_size ≥ |Sh₂(S)|/n²")
    print("=" * 70)
    print()
    
    print(f"{'Family':>25} {'n':>4} {'|Sh₂|':>8} {'LB':>10} {'Greedy':>8} {'Gap':>6}")
    print("-" * 70)
    
    families = [
        ("Simplex(3,6)", simplex_support(3, 6), 3),
        ("Simplex(4,5)", simplex_support(4, 5), 4),
        ("Cube(2,5)", cube_support(2, 5), 2),
        ("Cube(3,3)", cube_support(3, 3), 3),
        ("Product(2+2, 4+4)", product_support([2, 2], [4, 4]), 4),
    ]
    
    for name, S, n in families:
        sh = second_shadow(S, n)
        lb = max(1, len(sh) // (n ** 2))
        greedy = greedy_shared_circuit(S, n)
        gap = greedy / lb if lb > 0 else float('inf')
        print(f"{name:>25} {n:>4} {len(sh):>8} {lb:>10} {greedy:>8} {gap:>6.1f}x")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  SHADOW COMPLEXITY: Support-Geometric Lower Bounds for Hessians    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_shadow_coverage()
    demo_simplex_shadow_equality()
    demo_simplex_family()
    demo_product_family()
    demo_cube_family()
    demo_lower_bound_tightness()
    
    print("=" * 70)
    print("KEY INSIGHT: The second shadow |Sh₂(S)| provides a certified")
    print("lower bound on any support circuit computing Hessian entries.")
    print("The bound circuit_size ≥ |Sh₂(S)|/n² is sharp up to constants.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization 3: Polytope Erosion Geometry
Visualizes how the second shadow corresponds to discrete polytope erosion,
connecting arithmetic complexity to convex geometry.

Shows the Newton polytope of a support set and its erosion by the
degree-2 simplex, illustrating the cross-domain theorem.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Set, Tuple
from itertools import product as cartesian_product

ExponentVector = Tuple[int, ...]

def subtract_pair_basis(alpha, i, j):
    lst = list(alpha)
    if lst[i] < 1: return None
    lst[i] -= 1
    if lst[j] < 1: return None
    lst[j] -= 1
    return tuple(lst)

def second_shadow(S, n):
    shadow = set()
    for alpha in S:
        for i in range(n):
            for j in range(n):
                beta = subtract_pair_basis(alpha, i, j)
                if beta is not None:
                    shadow.add(beta)
    return shadow

def simplex_support(d, m):
    if d == 0: return {()} if m == 0 else set()
    if d == 1: return {(m,)}
    result = set()
    for first in range(m + 1):
        for rest in simplex_support(d - 1, m - first):
            result.add((first,) + rest)
    return result

# ─── Create figure ────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Different support shapes to demonstrate erosion
examples = [
    ("Simplex(2,7)", simplex_support(2, 7), 2,
     "Triangle → Smaller Triangle"),
    ("Square {0..4}²",
     set(cartesian_product(range(5), repeat=2)), 2,
     "Square → Smaller Square"),
    ("L-shape",
     {(a, b) for a in range(6) for b in range(6) if a <= 3 or b <= 2}, 2,
     "L-shape → Eroded L"),
]

for col, (name, S, n, description) in enumerate(examples):
    sh = second_shadow(S, n)
    
    max_c = max(max(v) for v in S) + 1
    
    # Top: Original support (Newton polytope lattice points)
    ax_top = axes[0, col]
    
    # Draw grid
    for x in range(max_c + 1):
        for y in range(max_c + 1):
            ax_top.plot(x, y, '.', color='#ddd', markersize=3)
    
    # Draw support
    sx = [p[0] for p in S]
    sy = [p[1] for p in S]
    ax_top.scatter(sx, sy, c='#2c3e50', s=40, zorder=5, label='Support S')
    
    # Draw convex hull outline
    from matplotlib.path import Path
    points = np.array(list(S))
    if len(points) >= 3:
        from scipy.spatial import ConvexHull
        try:
            hull = ConvexHull(points)
            hull_pts = points[hull.vertices]
            hull_pts = np.vstack([hull_pts, hull_pts[0]])
            ax_top.plot(hull_pts[:, 0], hull_pts[:, 1], 'k-', linewidth=1.5, alpha=0.5)
        except Exception:
            pass
    
    ax_top.set_xlim(-0.5, max_c + 0.5)
    ax_top.set_ylim(-0.5, max_c + 0.5)
    ax_top.set_aspect('equal')
    ax_top.set_title(f"{name}\n|S| = {len(S)}", fontsize=11, fontweight='bold')
    ax_top.set_xlabel("x₁")
    ax_top.set_ylabel("x₂")
    ax_top.grid(True, alpha=0.15)
    
    # Bottom: Erosion (= second shadow)
    ax_bot = axes[1, col]
    
    # Draw grid
    for x in range(max_c + 1):
        for y in range(max_c + 1):
            ax_bot.plot(x, y, '.', color='#ddd', markersize=3)
    
    # Draw original support faintly
    ax_bot.scatter(sx, sy, c='#bdc3c7', s=20, zorder=3, alpha=0.5, label='Original S')
    
    # Draw shadow
    if sh:
        shx = [p[0] for p in sh]
        shy = [p[1] for p in sh]
        ax_bot.scatter(shx, shy, c='#e74c3c', s=40, zorder=5, marker='s',
                      label=f'Sh₂(S) = Erosion')
        
        # Shadow convex hull
        sh_points = np.array(list(sh))
        if len(sh_points) >= 3:
            try:
                hull_sh = ConvexHull(sh_points)
                hull_sh_pts = sh_points[hull_sh.vertices]
                hull_sh_pts = np.vstack([hull_sh_pts, hull_sh_pts[0]])
                ax_bot.plot(hull_sh_pts[:, 0], hull_sh_pts[:, 1], 'r-',
                           linewidth=1.5, alpha=0.5)
            except Exception:
                pass
    
    ax_bot.set_xlim(-0.5, max_c + 0.5)
    ax_bot.set_ylim(-0.5, max_c + 0.5)
    ax_bot.set_aspect('equal')
    ax_bot.set_title(f"Erosion by Δ₂\n|Sh₂| = {len(sh)}, {description}", fontsize=10)
    ax_bot.set_xlabel("x₁")
    ax_bot.set_ylabel("x₂")
    ax_bot.legend(fontsize=8, loc='upper right')
    ax_bot.grid(True, alpha=0.15)

fig.suptitle("Newton Polytope Erosion = Second Shadow\n"
             "The shadow operation 'shrinks' the Newton polytope by the degree-2 simplex",
             fontsize=14, fontweight='bold', y=1.03)

plt.tight_layout()
plt.savefig("erosion_geometry.png", dpi=150, bbox_inches='tight')
print("Saved erosion_geometry.png")


#!/usr/bin/env python3
"""
Visualization 2: Lower Bound Scaling
Shows how the shadow complexity lower bound |Sh₂(S)|/n² scales across
different polynomial families and dimensions.

Demonstrates that the bound grows meaningfully with problem size,
establishing the practical relevance of the shadow-geometric approach.
"""

import matplotlib.pyplot as plt
import numpy as np
import math
from typing import Set, Tuple

ExponentVector = Tuple[int, ...]

def subtract_pair_basis(alpha, i, j):
    lst = list(alpha)
    if lst[i] < 1: return None
    lst[i] -= 1
    if lst[j] < 1: return None
    lst[j] -= 1
    return tuple(lst)

def second_shadow(S, n):
    shadow = set()
    for alpha in S:
        for i in range(n):
            for j in range(n):
                beta = subtract_pair_basis(alpha, i, j)
                if beta is not None:
                    shadow.add(beta)
    return shadow

def simplex_support(d, m):
    if d == 0: return {()} if m == 0 else set()
    if d == 1: return {(m,)}
    result = set()
    for first in range(m + 1):
        for rest in simplex_support(d - 1, m - first):
            result.add((first,) + rest)
    return result

def greedy_circuit(S, n):
    available = set()
    gates = 0
    for i in range(n):
        for j in range(n):
            needed = set()
            for alpha in S:
                beta = subtract_pair_basis(alpha, i, j)
                if beta is not None:
                    needed.add(beta)
            new = needed - available
            gates += len(new)
            available.update(new)
    return gates

# ─── Compute data ────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Shadow size vs support size for simplex families
ax1 = axes[0]
for d in [2, 3, 4, 5]:
    ms = list(range(2, 16))
    support_sizes = []
    shadow_sizes = []
    for m in ms:
        ss = math.comb(m + d - 1, d - 1)
        sh = math.comb(m + d - 3, d - 1)
        if ss > 50000:
            break
        support_sizes.append(ss)
        shadow_sizes.append(sh)
    ax1.plot(support_sizes, shadow_sizes, 'o-', label=f'd={d}', markersize=5)

ax1.set_xlabel('Support size |S|', fontsize=12)
ax1.set_ylabel('Shadow size |Sh₂(S)|', fontsize=12)
ax1.set_title('Shadow Growth for Simplex Families', fontsize=13)
ax1.legend(fontsize=10)
ax1.set_xscale('log')
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Lower bound vs degree for fixed dimensions
ax2 = axes[1]
for d in [2, 3, 4]:
    ms = list(range(2, 20))
    lbs = []
    degs = []
    for m in ms:
        sh_size = math.comb(m + d - 3, d - 1)
        lb = sh_size / (d ** 2)
        if math.comb(m + d - 1, d - 1) > 100000:
            break
        degs.append(m)
        lbs.append(lb)
    ax2.plot(degs, lbs, 's-', label=f'd={d}', markersize=5)

ax2.set_xlabel('Degree m', fontsize=12)
ax2.set_ylabel('Lower bound |Sh₂|/d²', fontsize=12)
ax2.set_title('Circuit Lower Bound vs Degree', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Greedy circuit vs lower bound (computed)
ax3 = axes[2]
dims = [2, 3]
for d in dims:
    ms = list(range(3, 12))
    lbs_actual = []
    greedys = []
    for m in ms:
        S = simplex_support(d, m)
        if len(S) > 5000:
            break
        sh = second_shadow(S, d)
        lb = len(sh) / (d ** 2)
        gc = greedy_circuit(S, d)
        lbs_actual.append(lb)
        greedys.append(gc)
    if lbs_actual:
        ax3.plot(lbs_actual, greedys, 'D-', label=f'd={d}', markersize=5)

# Plot y=x reference line
max_val = max(max(lbs_actual), max(greedys)) if lbs_actual else 10
ax3.plot([0, max_val * 1.1], [0, max_val * 1.1], 'k--', alpha=0.5, label='y = x')
ax3.set_xlabel('Lower bound |Sh₂|/d²', fontsize=12)
ax3.set_ylabel('Greedy circuit size', fontsize=12)
ax3.set_title('Greedy vs Lower Bound', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

fig.suptitle("Shadow Complexity Lower Bounds for Arithmetic Circuits",
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig("lower_bound_scaling.png", dpi=150, bbox_inches='tight')
print("Saved lower_bound_scaling.png")


#!/usr/bin/env python3
"""
Visualization 1: Shadow Heatmap
Visualizes the second shadow of a 2D polynomial support set as a heatmap,
showing which exponent vectors survive the shadow operation and how
different Hessian channels cover them.

This makes the core mathematical concept tangible: the "shape" of exponents
constrains what derivatives can produce.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Set, Tuple

ExponentVector = Tuple[int, ...]

def subtract_pair_basis(alpha, i, j):
    lst = list(alpha)
    if lst[i] < 1: return None
    lst[i] -= 1
    if lst[j] < 1: return None
    lst[j] -= 1
    return tuple(lst)

def second_shadow(S, n):
    shadow = set()
    for alpha in S:
        for i in range(n):
            for j in range(n):
                beta = subtract_pair_basis(alpha, i, j)
                if beta is not None:
                    shadow.add(beta)
    return shadow

def hessian_channel_support(S, n, i, j):
    ch = set()
    for alpha in S:
        beta = subtract_pair_basis(alpha, i, j)
        if beta is not None:
            ch.add(beta)
    return ch

def simplex_support(d, m):
    if d == 0: return {()} if m == 0 else set()
    if d == 1: return {(m,)}
    result = set()
    for first in range(m + 1):
        for rest in simplex_support(d - 1, m - first):
            result.add((first,) + rest)
    return result

# ─── Create figure ────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Support families to visualize
families = [
    ("Simplex(2,6)", simplex_support(2, 6), 2),
    ("Simplex(2,8)", simplex_support(2, 8), 2),
    ("Cube(2,4)", set((a, b) for a in range(5) for b in range(5)), 2),
]

for col, (name, S, n) in enumerate(families):
    sh = second_shadow(S, n)
    
    # Top row: Support and Shadow overlay
    ax = axes[0, col]
    max_coord = max(max(v) for v in S) + 1
    
    # Plot shadow points (background)
    for beta in sh:
        ax.add_patch(plt.Rectangle((beta[0] - 0.4, beta[1] - 0.4), 0.8, 0.8,
                                    color='#3498db', alpha=0.3))
    
    # Plot support points (foreground)
    for alpha in S:
        ax.plot(alpha[0], alpha[1], 'ko', markersize=8, zorder=5)
    
    # Plot shadow-only points
    shadow_only = sh - S
    for beta in shadow_only:
        ax.plot(beta[0], beta[1], 's', color='#3498db', markersize=6, zorder=4)
    
    ax.set_xlim(-0.5, max_coord + 0.5)
    ax.set_ylim(-0.5, max_coord + 0.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.set_title(f"{name}\n|S|={len(S)}, |Sh₂|={len(sh)}", fontsize=11)
    ax.set_xlabel("x₁ exponent")
    ax.set_ylabel("x₂ exponent")
    
    # Bottom row: Channel heatmap
    ax2 = axes[1, col]
    max_coord_sh = max(max(v) for v in sh) + 1 if sh else 1
    grid = np.zeros((max_coord_sh + 1, max_coord_sh + 1))
    
    for i in range(n):
        for j in range(n):
            ch = hessian_channel_support(S, n, i, j)
            for beta in ch:
                if beta[0] <= max_coord_sh and beta[1] <= max_coord_sh:
                    grid[beta[1], beta[0]] += 1  # count channels covering this point
    
    im = ax2.imshow(grid, origin='lower', cmap='YlOrRd', aspect='equal',
                     extent=(-0.5, max_coord_sh + 0.5, -0.5, max_coord_sh + 0.5))
    plt.colorbar(im, ax=ax2, label='# channels covering')
    ax2.set_title(f"Channel coverage density\nLB = |Sh₂|/n² = {len(sh)/n**2:.1f}", fontsize=11)
    ax2.set_xlabel("x₁ exponent")
    ax2.set_ylabel("x₂ exponent")

# Legend
support_patch = mpatches.Patch(color='black', label='Support S')
shadow_patch = mpatches.Patch(color='#3498db', alpha=0.5, label='Shadow Sh₂(S)')
fig.legend(handles=[support_patch, shadow_patch], loc='upper center',
           ncol=2, fontsize=12, bbox_to_anchor=(0.5, 1.02))

fig.suptitle("Second Shadow and Hessian Channel Coverage\n"
             "The shadow determines which exponents appear in second derivatives",
             fontsize=14, fontweight='bold', y=1.06)
plt.tight_layout()
plt.savefig("shadow_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")
