#!/usr/bin/env python3
"""
Hypergraph Ramsey Theory: Numerical Demonstrations

Demonstrates key results from the formalization:
1. Tower function growth rates
2. Probabilistic lower bounds for R_3(k,k)
3. Stepping-up bound analysis
4. Growth rate comparison: graph vs hypergraph Ramsey numbers
"""

from math import comb, log2, factorial

def tower(b: int, k: int) -> int:
    """Tower function: iterated exponentiation. tower(b,0)=1, tower(b,k+1)=b^tower(b,k)."""
    if k == 0:
        return 1
    prev = tower(b, k - 1)
    if prev > 100000:  # Avoid computing astronomically large numbers
        return float('inf')
    return b ** prev

def tower_log2(k: int) -> str:
    """String representation of log2(tower(2,k))."""
    if k <= 4:
        return str(tower(2, k))
    return f"2^{tower_log2(k-1)}"

def stepping_up_bound(R: int) -> int:
    """Stepping-up bound: 2^(R-1) + 1."""
    return 2 ** (R - 1) + 1

def prob_bound_holds(n: int, k: int) -> bool:
    """Check if the probabilistic bound holds: 2*C(n,k) < 2^C(k,3)."""
    return 2 * comb(n, k) < 2 ** comb(k, 3)

def max_prob_bound(k: int) -> int:
    """Find the largest n such that prob_bound_holds(n, k) is True."""
    n = k
    while prob_bound_holds(n, k):
        n += 1
    return n - 1

def main():
    print("=" * 70)
    print("HYPERGRAPH RAMSEY THEORY: NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # 1. Tower function values
    print("\n1. TOWER FUNCTION VALUES (base 2)")
    print("-" * 40)
    for k in range(7):
        val = tower(2, k)
        if val != float('inf') and val < 10**100:
            print(f"  tower(2, {k}) = {val}")
        else:
            print(f"  tower(2, {k}) = {tower_log2(k)} (too large to write)")

    # 2. Probabilistic lower bounds
    print("\n2. PROBABILISTIC LOWER BOUNDS FOR R_3(k,k)")
    print("-" * 50)
    print(f"  {'k':>3} | {'C(k,3)':>8} | {'2^C(k,3)':>12} | {'max n':>6} | R_3(k,k) > n")
    print(f"  {'---':>3} | {'--------':>8} | {'------------':>12} | {'------':>6} | ------------")
    for k in range(3, 11):
        ck3 = comb(k, 3)
        power = 2 ** ck3
        max_n = max_prob_bound(k)
        print(f"  {k:>3} | {ck3:>8} | {power:>12} | {max_n:>6} | R_3({k},{k}) > {max_n}")

    # 3. Known Ramsey values and bounds
    print("\n3. KNOWN VALUES AND BOUNDS FOR R_3(k,k)")
    print("-" * 50)
    known = {
        3: (4, 4, "exact"),
        4: (13, 13, "exact"),
        5: (34, 55, "bounds"),
        6: (79, 330, "bounds"),
    }
    for k, (lo, hi, status) in known.items():
        prob = max_prob_bound(k)
        print(f"  R_3({k},{k}): [{lo}, {hi}] ({status}), prob bound gives > {prob}")

    # 4. Stepping-up analysis
    print("\n4. STEPPING-UP BOUND ANALYSIS")
    print("-" * 50)
    print("  R_2(k,k) → R_3(k+1,k+1) via stepping-up:")
    graph_ramsey = {3: 6, 4: 18, 5: 48, 6: 102}
    for k, R2 in graph_ramsey.items():
        R3_bound = stepping_up_bound(R2)
        print(f"  R_2({k},{k}) = {R2} → R_3({k+1},{k+1}) ≤ 2^{R2-1}+1 = {R3_bound}")

    # 5. Growth rate comparison
    print("\n5. GROWTH RATE COMPARISON")
    print("-" * 50)
    print(f"  {'k':>3} | {'4^k (graph)':>15} | {'tower(2,k)':>20} | {'ratio':>10}")
    print(f"  {'---':>3} | {'------------':>15} | {'-------------------':>20} | {'----------':>10}")
    for k in range(1, 6):
        graph = 4 ** k
        hyper = tower(2, k)
        if hyper == float('inf') or hyper > 10**15:
            print(f"  {k:>3} | {graph:>15} | {'(too large)':>20} | {'∞':>10}")
        else:
            ratio = hyper / graph if graph > 0 else float('inf')
            print(f"  {k:>3} | {graph:>15} | {hyper:>20} | {ratio:>10.1f}")

    # 6. Double exponential vs single exponential
    print("\n6. GROWTH GAP: SINGLE vs DOUBLE EXPONENTIAL")
    print("-" * 50)
    for k in range(3, 8):
        single = 2 ** (k * k // 6)  # approx probabilistic lower bound
        double = tower(2, k)  # tower function upper bound regime
        if double != float('inf') and double < 10**15:
            print(f"  k={k}: single-exp ~ 2^{k*k//6} = {single}, tower(2,{k}) = {double}")
        else:
            print(f"  k={k}: single-exp ~ 2^{k*k//6} = {single}, tower(2,{k}) = {tower_log2(k)} (too large)")

    print("\n" + "=" * 70)
    print("KEY INSIGHT: The gap between single and double exponential")
    print("growth rates is the central open problem in hypergraph Ramsey theory.")
    print("Our formalization proves the probabilistic lower bound (single exp)")
    print("and establishes the tower function hierarchy (double exp upper bound).")
    print("=" * 70)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Hypergraph Ramsey Number Growth Rates

Compares single exponential (probabilistic lower bound) with
double exponential (stepping-up upper bound) growth for R_3(k,k).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, log2

def tower(b, k):
    if k == 0:
        return 1
    return b ** tower(b, k - 1)

def prob_lower_bound(k):
    target = 2 ** comb(k, 3)
    n = k
    while 2 * comb(n, k) < target:
        n += 1
    return n - 1

def main():
    ks = list(range(3, 12))

    # Probabilistic lower bounds (log scale)
    prob_bounds = [prob_lower_bound(k) for k in ks]
    log_prob = [log2(max(b, 1)) for b in prob_bounds]

    # Known bounds
    known_lower = {3: 4, 4: 13, 5: 34, 6: 79}
    known_upper = {3: 4, 4: 13, 5: 55, 6: 330}

    # Single exponential reference: 2^(k^2/6)
    single_exp = [k**2 / 6 for k in ks]

    # Double exponential reference: 2^(2^k) (log_2 of log_2)
    # log2(tower(2,k)) = tower(2,k-1)
    double_exp_log = [tower(2, k-1) for k in ks if k <= 6]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Lower bounds comparison
    ax1 = axes[0]
    ax1.plot(ks, log_prob, 'bo-', label='Probabilistic bound (log₂)', linewidth=2, markersize=8)
    ax1.plot(ks, single_exp, 'r--', label='k²/6 (single exp exponent)', linewidth=2)

    known_ks = sorted(known_lower.keys())
    ax1.plot(known_ks, [log2(known_lower[k]) for k in known_ks],
             'g^-', label='Known lower bounds (log₂)', markersize=10, linewidth=2)
    ax1.plot(known_ks, [log2(known_upper[k]) for k in known_ks],
             'rv-', label='Known upper bounds (log₂)', markersize=10, linewidth=2)

    ax1.set_xlabel('Clique size k', fontsize=12)
    ax1.set_ylabel('log₂(R₃(k,k) bound)', fontsize=12)
    ax1.set_title('Hypergraph Ramsey Number Bounds\n(logarithmic scale)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Tower hierarchy
    ax2 = axes[1]
    tower_heights = list(range(1, 6))
    tower_vals = [tower(2, h) for h in tower_heights]
    log_tower = [log2(v) for v in tower_vals]

    graph_ramsey_approx = [4**k for k in tower_heights]
    log_graph = [k * log2(4) for k in tower_heights]

    ax2.semilogy(tower_heights, tower_vals, 'ro-', label='tower(2, k)',
                 linewidth=2, markersize=8)
    ax2.semilogy(tower_heights, graph_ramsey_approx, 'b^--',
                 label='4^k (graph Ramsey scale)', linewidth=2, markersize=8)

    ax2.set_xlabel('Height k / Uniformity level', fontsize=12)
    ax2.set_ylabel('Value (log scale)', fontsize=12)
    ax2.set_title('Tower Function vs Single Exponential\n(Exponential Separation)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hypergraph_ramsey_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hypergraph_ramsey_growth.png")

if __name__ == "__main__":
    main()
