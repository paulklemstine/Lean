#!/usr/bin/env python3
"""
EML Constant Density Explorer
==============================
Explores how EML-generated constants (from pure trees with only the leaf 1)
are distributed on the real line. Answers questions about:
- How many distinct constants are produced by trees of size ≤ n?
- Are there "EML deserts" — intervals with no EML constants?
- What is the growth rate of the constant count?
- Are EML constants dense in any interval?
"""

import math
from collections import defaultdict

def eml(x, y):
    """Compute eml(x,y) = exp(x) - ln(y), returning None if undefined."""
    if y <= 0:
        return None
    try:
        result = math.exp(x) - math.log(y)
        if math.isnan(result) or math.isinf(result):
            return None
        if abs(result) > 1e100:
            return None
        return result
    except (OverflowError, ValueError):
        return None

def enumerate_pure_trees_values(max_nodes):
    """
    Enumerate all values of pure EML trees with up to max_nodes internal nodes.
    A pure tree has only 1 at the leaves.
    Trees with n internal nodes have n+1 leaves (all equal to 1).
    
    Returns dict: n_nodes -> set of values
    """
    # values_by_nodes[n] = set of values achievable with exactly n internal nodes
    values_by_nodes = defaultdict(set)
    values_by_nodes[0] = {1.0}  # leaf = 1
    
    for n in range(1, max_nodes + 1):
        # A tree with n nodes = eml(left, right) where left has k nodes and right has n-1-k
        for k in range(n):
            left_nodes = k
            right_nodes = n - 1 - k
            for lv in values_by_nodes[left_nodes]:
                for rv in values_by_nodes[right_nodes]:
                    val = eml(lv, rv)
                    if val is not None:
                        values_by_nodes[n].add(round(val, 12))
    
    return values_by_nodes

def analyze_density(values_by_nodes, max_nodes):
    """Analyze the density and distribution of EML constants."""
    print("=" * 65)
    print("EML CONSTANT DENSITY ANALYSIS")
    print("=" * 65)
    
    cumulative = set()
    catalan = [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796]
    
    for n in range(max_nodes + 1):
        new = values_by_nodes[n] - cumulative
        cumulative |= values_by_nodes[n]
        cat = catalan[n] if n < len(catalan) else "?"
        print(f"\n  Nodes = {n}: {len(values_by_nodes[n]):6d} distinct values "
              f"(Catalan C_{n} = {cat})")
        print(f"    New constants: {len(new)}")
        print(f"    Cumulative: {len(cumulative)}")
        
        # Show some values
        sorted_vals = sorted(values_by_nodes[n])
        if len(sorted_vals) <= 8:
            for v in sorted_vals:
                name = identify_constant(v)
                print(f"      {v:20.12f}  {name}")
        else:
            for v in sorted_vals[:4]:
                name = identify_constant(v)
                print(f"      {v:20.12f}  {name}")
            print(f"      ... ({len(sorted_vals) - 8} more) ...")
            for v in sorted_vals[-4:]:
                name = identify_constant(v)
                print(f"      {v:20.12f}  {name}")
    
    return cumulative

def identify_constant(val):
    """Try to identify a constant by name."""
    e = math.e
    known = {
        0.0: "= 0",
        1.0: "= 1",
        e: "= e",
        e - 1: "= e - 1",
        e**e: "= e^e",
        1 - e: "= 1 - e",
        e**e - 1: "= e^e - 1",
        e**e - e: "= e^e - e",
        math.exp(e - 1): "= exp(e-1)",
        math.exp(e - 1) - 1: "= exp(e-1) - 1",
        e - math.log(e - 1): "= e - ln(e-1)",
        2*e - 1: "= 2e - 1",
    }
    
    for known_val, name in known.items():
        if abs(val - known_val) < 1e-9:
            return name
    return ""

def find_deserts(constants, min_gap=0.1):
    """Find intervals with no EML constants ('EML deserts')."""
    print("\n" + "=" * 65)
    print("EML DESERT ANALYSIS")
    print("=" * 65)
    
    sorted_c = sorted(constants)
    
    # Only look at constants in a reasonable range
    filtered = [c for c in sorted_c if -10 < c < 50]
    
    print(f"\n  Constants in range (-10, 50): {len(filtered)}")
    
    gaps = []
    for i in range(len(filtered) - 1):
        gap = filtered[i + 1] - filtered[i]
        if gap > min_gap:
            gaps.append((filtered[i], filtered[i + 1], gap))
    
    gaps.sort(key=lambda x: -x[2])
    
    print(f"\n  Largest gaps (potential 'deserts'):")
    for start, end, gap in gaps[:15]:
        print(f"    ({start:12.6f}, {end:12.6f})  width = {gap:.6f}")
    
    return gaps

def analyze_rationality(constants):
    """Check which EML constants appear to be rational."""
    print("\n" + "=" * 65)
    print("RATIONALITY ANALYSIS")
    print("=" * 65)
    
    rational_candidates = []
    
    for c in sorted(constants):
        if abs(c) > 100:
            continue
        # Check if c is close to a rational p/q for small q
        for q in range(1, 20):
            p = round(c * q)
            if abs(c - p/q) < 1e-10:
                rational_candidates.append((c, p, q))
                break
    
    print(f"\n  Constants close to rationals p/q (q ≤ 19):")
    seen = set()
    for c, p, q in rational_candidates:
        key = (p, q)
        if key not in seen:
            seen.add(key)
            print(f"    {c:15.10f} ≈ {p}/{q} = {p/q:.10f}  (error: {abs(c - p/q):.2e})")
    
    print(f"\n  Conjecture: The only rational EML constants are 0 and 1.")
    print(f"  (All others involve exp(1) = e, which is transcendental)")

def main():
    print("╔═════════════════════════════════════════════════════════════╗")
    print("║     EML CONSTANT DENSITY EXPLORER                          ║")
    print("║     Distribution of eml-generated constants on ℝ           ║")
    print("╚═════════════════════════════════════════════════════════════╝")
    
    max_nodes = 6
    print(f"\nEnumerating pure EML trees up to {max_nodes} internal nodes...")
    
    values_by_nodes = enumerate_pure_trees_values(max_nodes)
    
    all_constants = analyze_density(values_by_nodes, max_nodes)
    
    find_deserts(all_constants, min_gap=0.05)
    
    analyze_rationality(all_constants)
    
    # Summary statistics
    print("\n" + "=" * 65)
    print("SUMMARY")
    print("=" * 65)
    sorted_all = sorted(all_constants)
    print(f"\n  Total distinct EML constants found: {len(all_constants)}")
    print(f"  Range: [{sorted_all[0]:.6f}, {sorted_all[-1]:.6f}]")
    print(f"  Constants in [0, 1]: {sum(1 for c in all_constants if 0 <= c <= 1)}")
    print(f"  Negative constants: {sum(1 for c in all_constants if c < 0)}")
    print(f"  Constants > 100: {sum(1 for c in all_constants if c > 100)}")
    
    # Growth rate
    print(f"\n  Growth rate of cumulative constant count:")
    cumul = set()
    for n in range(max_nodes + 1):
        cumul |= values_by_nodes[n]
        print(f"    After level {n}: {len(cumul)} constants")

if __name__ == "__main__":
    main()
