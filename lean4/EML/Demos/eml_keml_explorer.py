#!/usr/bin/env python3
"""
EML Kolmogorov Complexity Explorer (K_EML)

Exhaustively searches for the minimum EML tree size to compute
various mathematical constants from the single constant 1.

K_EML(x) = minimum number of EML nodes in a tree with only 1 at leaves
            that evaluates to x.

Known results:
  K_EML(1) = 0   (leaf)
  K_EML(e) = 1   (eml(1,1) = exp(1) - ln(1) = e)
  K_EML(e^e) = 2
  K_EML(0) = 3
  K_EML(e-1) = 2

This script discovers these and searches for K_EML of algebraic numbers
like 2, sqrt(2), golden ratio, pi approximations.
"""

import math
import itertools
from collections import defaultdict

def eml(a, b):
    """EML(a,b) = exp(a) - ln(b), for b > 0."""
    if b <= 0:
        return None
    try:
        result = math.exp(a) - math.log(b)
        if math.isnan(result) or math.isinf(result):
            return None
        if abs(result) > 1e100:
            return None
        return result
    except (OverflowError, ValueError):
        return None

def generate_eml_values(max_depth):
    """
    Generate all values reachable from constant 1 using EML trees
    up to a given depth. Returns dict: depth -> set of (value, expression_string).
    """
    # depth 0: just the constant 1
    values_by_depth = {}
    values_by_depth[0] = {(1.0, "1")}
    
    all_values = dict()  # value -> (depth, expr)
    all_values[1.0] = (0, "1")
    
    for d in range(1, max_depth + 1):
        new_values = set()
        # Combine any pair from depths < d where max(d1, d2) + 1 = d
        # i.e., at least one operand must be from depth d-1
        all_prev = []
        for dd in range(d):
            if dd in values_by_depth:
                all_prev.extend(values_by_depth[dd])
        
        depth_d_minus_1 = list(values_by_depth.get(d-1, set()))
        all_prev_list = list(set(all_prev))
        
        # Pairs where at least one is from depth d-1
        pairs = set()
        for v1 in depth_d_minus_1:
            for v2 in all_prev_list:
                pairs.add((v1, v2))
                pairs.add((v2, v1))
        
        for (val_a, expr_a), (val_b, expr_b) in pairs:
            result = eml(val_a, val_b)
            if result is not None:
                # Check if we already found this value at a lower depth
                found = False
                for existing_val in all_values:
                    if abs(existing_val - result) < 1e-12:
                        found = True
                        break
                if not found:
                    new_values.add((result, f"eml({expr_a}, {expr_b})"))
                    all_values[result] = (d, f"eml({expr_a}, {expr_b})")
        
        values_by_depth[d] = new_values
        print(f"Depth {d}: {len(new_values)} new values (total: {len(all_values)})")
    
    return all_values

def find_keml(target, all_values, tolerance=1e-10):
    """Find K_EML for a target constant."""
    best = None
    best_expr = None
    for val, (depth, expr) in all_values.items():
        if abs(val - target) < tolerance:
            if best is None or depth < best:
                best = depth
                best_expr = expr
    return best, best_expr

def main():
    print("=" * 70)
    print("EML KOLMOGOROV COMPLEXITY EXPLORER")
    print("K_EML(x) = minimum EML tree depth to compute x from constant 1")
    print("=" * 70)
    
    max_depth = 4
    print(f"\nGenerating all EML values up to depth {max_depth}...")
    all_values = generate_eml_values(max_depth)
    
    print(f"\nTotal unique values discovered: {len(all_values)}")
    
    # Search for specific constants
    targets = {
        "1": 1.0,
        "e": math.e,
        "e^e": math.e ** math.e,
        "0": 0.0,
        "e-1": math.e - 1,
        "2": 2.0,
        "e^(e^e)": math.exp(math.exp(math.e)),
        "1/e": 1/math.e,
        "e^2": math.e**2,
        "e+1": math.e + 1,
        "2e": 2*math.e,
        "e^e - e": math.e**math.e - math.e,
        "ln(2)": math.log(2),
    }
    
    print("\n" + "=" * 70)
    print(f"{'Constant':<20} {'Value':<20} {'K_EML':<8} {'Expression'}")
    print("-" * 70)
    
    for name, target in targets.items():
        depth, expr = find_keml(target, all_values)
        if depth is not None:
            print(f"{name:<20} {target:<20.10f} {depth:<8} {expr}")
        else:
            print(f"{name:<20} {target:<20.10f} {'> ' + str(max_depth):<8} not found")
    
    # Distribution analysis
    print("\n" + "=" * 70)
    print("DISTRIBUTION OF EML VALUES BY DEPTH")
    print("-" * 70)
    
    depth_counts = defaultdict(int)
    for val, (depth, expr) in all_values.items():
        depth_counts[depth] += 1
    
    for d in sorted(depth_counts.keys()):
        print(f"  Depth {d}: {depth_counts[d]} values")
    
    # Show all values at low depths
    print("\n" + "=" * 70)
    print("ALL VALUES AT DEPTH ≤ 3")
    print("-" * 70)
    for val, (depth, expr) in sorted(all_values.items(), key=lambda x: (x[1][0], x[0])):
        if depth <= 3:
            print(f"  Depth {depth}: {val:>20.10f}  =  {expr}")
    
    # Density analysis: how many values in [a, b]?
    print("\n" + "=" * 70)
    print("DENSITY ANALYSIS: Values in unit intervals")
    print("-" * 70)
    all_vals_list = sorted(all_values.keys())
    lo = int(min(all_vals_list)) - 1
    hi = int(max(min(max(all_vals_list), 20), lo + 1)) + 1
    for a in range(lo, hi):
        count = sum(1 for v in all_vals_list if a <= v < a + 1)
        bar = "#" * min(count, 50)
        print(f"  [{a:>4}, {a+1:>4}): {count:>5}  {bar}")
    
    # Search for near-integers
    print("\n" + "=" * 70)
    print("NEAR-INTEGER EML VALUES (|x - round(x)| < 0.001)")
    print("-" * 70)
    for val, (depth, expr) in sorted(all_values.items(), key=lambda x: x[1][0]):
        nearest_int = round(val)
        if abs(val - nearest_int) < 0.001 and abs(val) < 100:
            print(f"  Depth {depth}: {val:>20.15f} ≈ {nearest_int}  =  {expr}")

if __name__ == "__main__":
    main()
