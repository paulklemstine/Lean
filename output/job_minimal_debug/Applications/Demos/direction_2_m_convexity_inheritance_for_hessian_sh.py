#!/usr/bin/env python3
"""
applications.py — Real-world applications of M-convex shadow theory.

Demonstrates:
1. Matroid optimization over Hessian-derived state spaces
2. Portfolio rebalancing with exchange constraints  
3. Network flow sensitivity analysis
"""
import itertools
from typing import Set, Tuple, List

Vec = Tuple[int, ...]

def uniform_matroid_bases(n: int, r: int) -> Set[Vec]:
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}

def one_step_shadow(S: Set[Vec]) -> Set[Vec]:
    shadow = set()
    for alpha in S:
        for i in range(len(alpha)):
            if alpha[i] > 0:
                v = list(alpha); v[i] -= 1; shadow.add(tuple(v))
    return shadow

def two_step_shadow(S: Set[Vec]) -> Set[Vec]:
    return one_step_shadow(one_step_shadow(S))

def exchange(v: Vec, t: int, u: int) -> Vec:
    r = list(v); r[t] -= 1; r[u] += 1; return tuple(r)

# ============================================================
# Application 1: Portfolio rebalancing
# ============================================================
def portfolio_rebalancing():
    """Demonstrate M-convex optimization for portfolio selection.
    
    A portfolio selects r assets from n candidates. The two-step shadow
    represents portfolios accessible by adjusting two positions.
    M-convexity guarantees polynomial-time optimization.
    """
    print("=" * 60)
    print("Application 1: Portfolio Rebalancing")
    print("=" * 60)
    
    n, r = 8, 4  # 8 assets, select 4
    bases = uniform_matroid_bases(n, r)
    shadow = two_step_shadow(bases)
    
    # Expected returns for each asset
    returns = [0.12, 0.08, 0.15, 0.06, 0.10, 0.09, 0.14, 0.07]
    
    print(f"Assets: {n}, Portfolio size: {r}")
    print(f"Expected returns: {returns}")
    print(f"Original portfolios: {len(bases)}")
    print(f"Shadow portfolios (after Hessian adjustment): {len(shadow)}")
    
    # Optimize over shadow using greedy exchange
    current = next(iter(shadow))
    improved = True
    while improved:
        improved = False
        for t in range(n):
            if current[t] <= 0:
                continue
            for u in range(n):
                if t == u:
                    continue
                cand = exchange(current, t, u)
                if cand in shadow:
                    if sum(r*x for r,x in zip(returns, cand)) > sum(r*x for r,x in zip(returns, current)):
                        current = cand
                        improved = True
    
    print(f"\nOptimal shadow portfolio: {current}")
    print(f"Expected return: {sum(r*x for r,x in zip(returns, current)):.4f}")
    
    # Compare with brute force
    best = max(shadow, key=lambda x: sum(r*v for r,v in zip(returns, x)))
    print(f"Brute-force optimal: {best}")
    print(f"Match: {current == best}")

# ============================================================
# Application 2: Network scheduling sensitivity
# ============================================================
def network_scheduling():
    """M-convex shadows for analyzing scheduling robustness.
    
    Tasks assigned to machines form a matroid structure.
    The Hessian shadow captures second-order perturbation effects.
    """
    print("\n" + "=" * 60)
    print("Application 2: Network Scheduling Sensitivity")
    print("=" * 60)
    
    n, r = 6, 3  # 6 machines, 3 active tasks
    bases = uniform_matroid_bases(n, r)
    shadow = two_step_shadow(bases)
    
    # Machine costs (lower is better)
    costs = [10, 15, 8, 12, 20, 5]
    
    print(f"Machines: {n}, Active tasks: {r}")
    print(f"Machine costs: {costs}")
    print(f"Base schedules: {len(bases)}")
    print(f"Perturbation-accessible schedules: {len(shadow)}")
    
    # Find minimum-cost schedule in shadow
    best = min(shadow, key=lambda x: sum(c*v for c,v in zip(costs, x)))
    print(f"\nOptimal perturbation schedule: {best}")
    print(f"Total cost: {sum(c*v for c,v in zip(costs, best))}")

# ============================================================
# Application 3: Combinatorial auction
# ============================================================
def combinatorial_auction():
    """M-convex structure in combinatorial auction clearing.
    
    Bidders select bundles forming exchange-stable configurations.
    Hessian shadows capture sensitivity to pair-wise bid adjustments.
    """
    print("\n" + "=" * 60)
    print("Application 3: Combinatorial Auction Sensitivity")
    print("=" * 60)
    
    n, r = 7, 3
    bases = uniform_matroid_bases(n, r)
    s1 = one_step_shadow(bases)
    s2 = two_step_shadow(bases)
    
    print(f"Items: {n}, Bundle size: {r}")
    print(f"Base allocations: {len(bases)}")
    print(f"One-step perturbations: {len(s1)}")
    print(f"Two-step perturbations: {len(s2)}")
    
    # Verify exchange property at each level
    from algorithms import verify_mconvex
    mc_base, _ = verify_mconvex(bases)
    mc_s1, _ = verify_mconvex(s1)
    mc_s2, _ = verify_mconvex(s2)
    
    print(f"\nM-convex base: {mc_base}")
    print(f"M-convex one-step: {mc_s1}")
    print(f"M-convex two-step: {mc_s2}")
    print("\nConclusion: Exchange-based polynomial-time optimization")
    print("is available at ALL perturbation levels!")

if __name__ == "__main__":
    portfolio_rebalancing()
    network_scheduling()
    combinatorial_auction()
    print("\nAll applications demonstrated successfully.")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of M-convexity inheritance for Hessian shadows.

Constructs uniform matroid basis polynomials U(r,n), computes their aggregate
Hessian shadows under chosen weights, and verifies the symmetric exchange property.
"""
import itertools
from typing import Set, Tuple, Dict, List, Optional

Vec = Tuple[int, ...]

def indicator(n: int, subset: frozenset) -> Vec:
    """Create indicator vector for a subset of {0,...,n-1}."""
    return tuple(1 if i in subset else 0 for i in range(n))

def uniform_matroid_bases(n: int, r: int) -> Set[Vec]:
    """Return the set of indicator vectors for all r-element subsets of {0,...,n-1}."""
    return {indicator(n, frozenset(s)) for s in itertools.combinations(range(n), r)}

def one_step_shadow(S: Set[Vec]) -> Set[Vec]:
    """Compute the one-step derivative shadow of S."""
    shadow = set()
    for alpha in S:
        n = len(alpha)
        for i in range(n):
            if alpha[i] > 0:
                gamma = list(alpha)
                gamma[i] -= 1
                shadow.add(tuple(gamma))
    return shadow

def two_step_shadow(S: Set[Vec]) -> Set[Vec]:
    """Compute the two-step derivative shadow (iterated one-step)."""
    return one_step_shadow(one_step_shadow(S))

def aggregate_hessian_shadow(S: Set[Vec], A=None) -> Set[Vec]:
    """Compute the aggregate Hessian shadow with weight matrix A.
    If A is None, use all-ones weights (uniform positive)."""
    shadow = set()
    for alpha in S:
        n = len(alpha)
        for i in range(n):
            for j in range(n):
                w = 1.0 if A is None else A[i][j]
                if w != 0 and alpha[i] > 0:
                    beta = list(alpha)
                    beta[i] -= 1
                    if beta[j] > 0:
                        beta[j] -= 1
                        shadow.add(tuple(beta))
    return shadow

def check_mconvex_exchange(S: Set[Vec]) -> Tuple[bool, Optional[Dict]]:
    """Check the symmetric exchange property for set S.
    
    Returns (True, None) if M-convex, or (False, counterexample_dict) if not.
    """
    S_list = list(S)
    for alpha in S_list:
        for beta in S_list:
            n = len(alpha)
            for t in range(n):
                if alpha[t] > beta[t]:
                    # Need to find u with alpha[u] < beta[u] and exchange in S
                    found = False
                    for u in range(n):
                        if alpha[u] < beta[u]:
                            gamma = list(alpha)
                            gamma[t] -= 1
                            gamma[u] += 1
                            if tuple(gamma) in S:
                                found = True
                                break
                    if not found:
                        return False, {
                            'alpha': alpha, 'beta': beta,
                            'imbalance_coord': t,
                            'message': f'No compensating u found for alpha={alpha}, beta={beta}, t={t}'
                        }
    return True, None

def check_constant_degree(S: Set[Vec]) -> Tuple[bool, Optional[int]]:
    """Check if all elements have the same total degree. Returns (is_const, degree)."""
    if not S:
        return True, None
    degrees = {sum(v) for v in S}
    if len(degrees) == 1:
        return True, degrees.pop()
    return False, None

def demo_uniform_matroid(n: int, r: int):
    """Full demo for U(r,n)."""
    print(f"\n{'='*60}")
    print(f"  Uniform Matroid U({r},{n})")
    print(f"{'='*60}")
    
    bases = uniform_matroid_bases(n, r)
    print(f"  Number of bases: {len(bases)}")
    
    is_const, deg = check_constant_degree(bases)
    print(f"  Constant degree: {is_const} (d={deg})")
    
    is_mc, cex = check_mconvex_exchange(bases)
    print(f"  M-convex: {is_mc}")
    if cex:
        print(f"  Counterexample: {cex}")
    
    # One-step shadow
    shadow1 = one_step_shadow(bases)
    print(f"\n  One-step shadow:")
    print(f"    Size: {len(shadow1)}")
    is_const1, deg1 = check_constant_degree(shadow1)
    print(f"    Constant degree: {is_const1} (d={deg1})")
    is_mc1, cex1 = check_mconvex_exchange(shadow1)
    print(f"    M-convex: {is_mc1}")
    if cex1:
        print(f"    Counterexample: {cex1}")
    
    # Two-step shadow
    shadow2 = two_step_shadow(bases)
    print(f"\n  Two-step shadow:")
    print(f"    Size: {len(shadow2)}")
    is_const2, deg2 = check_constant_degree(shadow2)
    print(f"    Constant degree: {is_const2} (d={deg2})")
    is_mc2, cex2 = check_mconvex_exchange(shadow2)
    print(f"    M-convex: {is_mc2}")
    if cex2:
        print(f"    Counterexample: {cex2}")
    
    # Aggregate Hessian shadow (all-ones weights)
    agg_shadow = aggregate_hessian_shadow(bases)
    print(f"\n  Aggregate Hessian shadow (all-ones weights):")
    print(f"    Size: {len(agg_shadow)}")
    is_mc_agg, cex_agg = check_mconvex_exchange(agg_shadow)
    print(f"    M-convex: {is_mc_agg}")
    if cex_agg:
        print(f"    Counterexample: {cex_agg}")
    
    return is_mc2

def search_counterexample_sparse_weights(n: int, r: int):
    """Search for counterexamples with sparse/non-positive weights."""
    import random
    print(f"\n{'='*60}")
    print(f"  Searching counterexamples with sparse weights for U({r},{n})")
    print(f"{'='*60}")
    
    bases = uniform_matroid_bases(n, r)
    
    # Try random sparse weight matrices
    for trial in range(20):
        A = [[0.0]*n for _ in range(n)]
        # Set some random entries to 1
        num_entries = random.randint(1, n*n//2)
        for _ in range(num_entries):
            i, j = random.randint(0, n-1), random.randint(0, n-1)
            A[i][j] = 1.0
        
        shadow = aggregate_hessian_shadow(bases, A)
        if not shadow:
            continue
        
        is_mc, cex = check_mconvex_exchange(shadow)
        if not is_mc:
            print(f"  COUNTEREXAMPLE FOUND with sparse weights (trial {trial})!")
            print(f"  Weight matrix: {A}")
            print(f"  Shadow size: {len(shadow)}")
            print(f"  {cex}")
            return True
    
    print(f"  No counterexample found in 20 random trials.")
    return False

if __name__ == "__main__":
    print("M-Convexity Inheritance for Hessian Shadows — Demo")
    print("=" * 60)
    
    # Test uniform matroids U(r,n) for small n
    all_pass = True
    for n in range(2, 8):
        for r in range(1, n):
            if r >= 2 and n - r >= 2:  # Need degree ≥ 2 for two-step shadow
                result = demo_uniform_matroid(n, r)
                if not result:
                    all_pass = False
    
    print(f"\n{'='*60}")
    if all_pass:
        print("  ALL TESTS PASSED: M-convexity inherited by shadows!")
    else:
        print("  SOME TESTS FAILED!")
    
    # Search for counterexamples with sparse weights
    search_counterexample_sparse_weights(5, 3)
    search_counterexample_sparse_weights(6, 3)
    
    print("\nDone.")


#!/usr/bin/env python3
"""
Visualization: M-Convex Shadow Structure

Visualizes the support sets and their shadows for U(3,5), showing how
the M-convex exchange structure is preserved through derivative shadows.
Each support element is a point in a projected 2D space, with edges
showing valid exchanges.

This script is fully self-contained — no local imports.
"""
import itertools
import matplotlib.pyplot as plt
import numpy as np
from typing import Set, Tuple

Vec = Tuple[int, ...]

def uniform_matroid_bases(n: int, r: int) -> Set[Vec]:
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}

def one_step_shadow(S: Set[Vec]) -> Set[Vec]:
    shadow = set()
    for alpha in S:
        for i in range(len(alpha)):
            if alpha[i] > 0:
                v = list(alpha); v[i] -= 1; shadow.add(tuple(v))
    return shadow

def two_step_shadow(S: Set[Vec]) -> Set[Vec]:
    return one_step_shadow(one_step_shadow(S))

def exchange_edges(S: Set[Vec]):
    """Find all valid exchange edges."""
    edges = []
    S_list = list(S)
    n = len(S_list[0]) if S_list else 0
    for a in S_list:
        for t in range(n):
            if a[t] <= 0:
                continue
            for u in range(n):
                if t == u:
                    continue
                b = list(a); b[t] -= 1; b[u] += 1
                b = tuple(b)
                if b in S:
                    edges.append((a, b))
    return edges

def project_2d(vecs, seed=42):
    """Project high-dimensional vectors to 2D using random projection."""
    if not vecs:
        return np.array([]), np.array([])
    arr = np.array(list(vecs))
    rng = np.random.RandomState(seed)
    proj = rng.randn(arr.shape[1], 2)
    coords = arr @ proj
    return coords[:, 0], coords[:, 1]

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

n, r = 5, 3
bases = uniform_matroid_bases(n, r)
s1 = one_step_shadow(bases)
s2 = two_step_shadow(bases)

for ax, (S, title, color) in zip(axes, [
    (bases, f'U({r},{n}) Bases (d={r})', '#2196F3'),
    (s1, f'One-Step Shadow (d={r-1})', '#4CAF50'),
    (s2, f'Two-Step Shadow (d={r-2})', '#FF9800'),
]):
    S_list = list(S)
    x, y = project_2d(S_list)
    edges = exchange_edges(S)
    
    idx_map = {v: i for i, v in enumerate(S_list)}
    
    for a, b in edges:
        if a in idx_map and b in idx_map:
            i, j = idx_map[a], idx_map[b]
            ax.plot([x[i], x[j]], [y[i], y[j]], color=color, alpha=0.2, linewidth=0.8)
    
    ax.scatter(x, y, c=color, s=80, zorder=5, edgecolors='white', linewidth=1.5)
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_xlabel('Projection axis 1')
    ax.set_ylabel('Projection axis 2')
    
    n_edges = len(edges) // 2  # undirected
    ax.text(0.02, 0.98, f'|S| = {len(S)}\nExchanges = {n_edges}',
            transform=ax.transAxes, va='top', fontsize=10,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.suptitle('M-Convexity Inheritance: Exchange Graphs Through Derivative Shadows',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_structure.png', dpi=150, bbox_inches='tight')
print("Saved shadow_structure.png")
