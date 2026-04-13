#!/usr/bin/env python3
"""
EML Number Tower Explorer
=========================
Systematically enumerates all constants reachable from EML(x,y) = exp(x) - ln(y)
and the constant 1, up to a given tree depth. Discovers the EML constant hierarchy.

Key discoveries:
- Level 0: {1}
- Level 1: {e ≈ 2.718}
- Level 2: {e^e ≈ 15.154, e-1 ≈ 1.718, e^e - 1 ≈ 14.154}
- Level 3: {0, e^(e^e), ...} — first appearance of zero!
"""

import math
import sys
from itertools import product
from collections import OrderedDict

def eml(x, y):
    """The EML operator: eml(x,y) = exp(x) - ln(y)"""
    if y <= 0:
        return None  # ln(y) undefined for y ≤ 0
    try:
        result = math.exp(x) - math.log(y)
        if abs(result) > 1e300:
            return None  # overflow protection
        return result
    except (OverflowError, ValueError):
        return None

def explore_tower(max_level=4):
    """Explore the EML number tower level by level."""
    # Track values with their tree representations
    levels = {0: {1.0: "1"}}
    all_values = {1.0: "1"}
    
    print("=" * 70)
    print("EML NUMBER TOWER EXPLORER")
    print("eml(x, y) = exp(x) - ln(y)")
    print("=" * 70)
    
    print(f"\n{'Level 0':}")
    print(f"  1 = 1")
    
    for level in range(1, max_level + 1):
        new_values = {}
        
        # Try all combinations of values from previous levels
        for l1 in range(level):
            l2 = level - 1 - l1  # Ensure we use at least one value from the latest level
            
        # Actually, level n values are eml(a, b) where a and b are from levels < n
        # and at least one of a, b is from level n-1
        # Simpler: level n = all eml(a, b) where a, b are reachable from levels 0..n-1
        
        prev_values = {}
        for l in range(level):
            for v, name in levels.get(l, {}).items():
                prev_values[v] = name
        
        for v1, name1 in prev_values.items():
            for v2, name2 in prev_values.items():
                result = eml(v1, v2)
                if result is not None:
                    # Round to avoid floating point duplicates
                    rounded = round(result, 10)
                    if rounded not in all_values and rounded not in new_values:
                        tree_name = f"eml({name1}, {name2})"
                        new_values[rounded] = tree_name
        
        if new_values:
            levels[level] = new_values
            all_values.update(new_values)
            
            print(f"\n{'Level ' + str(level):}")
            # Sort by value for nice display
            for val in sorted(new_values.keys()):
                name = new_values[val]
                if abs(val) < 1e6:
                    print(f"  {val:>20.10f} = {name}")
                else:
                    print(f"  {val:>20.6e} = {name}")
    
    return levels, all_values

def find_special_constants(all_values):
    """Search for special mathematical constants in the EML tower."""
    print("\n" + "=" * 70)
    print("SPECIAL CONSTANTS SEARCH")
    print("=" * 70)
    
    targets = {
        "0": 0.0,
        "1": 1.0,
        "e": math.e,
        "e-1": math.e - 1,
        "e^e": math.e ** math.e,
        "e^e - 1": math.e ** math.e - 1,
        "e - e = 0": 0.0,
        "2": 2.0,
        "π": math.pi,
        "ln(2)": math.log(2),
        "1/e": 1/math.e,
    }
    
    for name, target in targets.items():
        best_match = None
        best_dist = float('inf')
        for val, tree in all_values.items():
            dist = abs(val - target)
            if dist < best_dist:
                best_dist = dist
                best_match = (val, tree)
        
        if best_dist < 1e-8:
            print(f"  ✓ {name:>10} = {target:.10f}  via  {best_match[1]}")
        else:
            print(f"  ✗ {name:>10} = {target:.10f}  (closest: {best_match[0]:.10f}, dist={best_dist:.2e})")

def catalan_numbers(n):
    """Generate Catalan numbers C_0, ..., C_n."""
    C = [0] * (n + 1)
    C[0] = 1
    for i in range(1, n + 1):
        C[i] = sum(C[j] * C[i-1-j] for j in range(i))
    return C

def count_pure_trees():
    """Count pure EML trees by number of internal nodes."""
    print("\n" + "=" * 70)
    print("EML TREE COUNTING (Catalan Numbers)")
    print("=" * 70)
    
    catalans = catalan_numbers(10)
    cumulative = 0
    
    print(f"\n  {'Nodes':>6} {'Leaves':>7} {'Trees (Cₙ)':>12} {'Cumulative':>12} {'Distinct values':>16}")
    print(f"  {'─'*6} {'─'*7} {'─'*12} {'─'*12} {'─'*16}")
    
    for n in range(11):
        cumulative += catalans[n]
        leaves = n + 1
        print(f"  {n:>6} {leaves:>7} {catalans[n]:>12} {cumulative:>12} {'≤ ' + str(cumulative):>16}")
    
    print(f"\n  Growth rate: Cₙ ~ 4ⁿ / (n^(3/2) · √π)")
    print(f"  C₁₀ = {catalans[10]} (16,796 distinct tree shapes with 10 EML nodes)")

def analyze_fixed_points():
    """Find fixed points of various EML iterations."""
    print("\n" + "=" * 70)
    print("EML FIXED POINT ANALYSIS")
    print("=" * 70)
    
    # Logarithmic iteration: g(z) = e - ln(z)
    print("\n  Logarithmic iteration: g(z) = e - ln(z)")
    z = 2.0
    print(f"  Starting from z₀ = {z}")
    for i in range(20):
        z_new = math.e - math.log(z)
        print(f"    z_{i+1:>2} = {z_new:.12f}")
        if abs(z_new - z) < 1e-14:
            print(f"  → Converged to z* ≈ {z_new:.15f}")
            print(f"    Verification: e - ln(z*) = {math.e - math.log(z_new):.15f}")
            print(f"    |g'(z*)| = |1/z*| = {1/z_new:.6f} < 1 ✓ (stable)")
            break
        z = z_new
    
    # Diagonal iteration: f(z) = exp(z) - ln(z)
    print(f"\n  Diagonal map: f(z) = exp(z) - ln(z)")
    print(f"  f(1) = e - 0 = {math.exp(1):.6f}")
    print(f"  f(2) = {math.exp(2) - math.log(2):.6f}")
    print(f"  f(0.5) = {math.exp(0.5) - math.log(0.5):.6f}")
    print(f"  → The diagonal map has no real fixed point (f(z) > z for all z > 0)")
    print(f"    Proof: exp(z) - ln(z) > z iff exp(z) > z + ln(z)")
    print(f"    By convexity: exp(z) ≥ 1 + z > z + ln(z) for z > 0")

def e_tower():
    """Compute the e-tower (tetration base e)."""
    print("\n" + "=" * 70)
    print("THE e-TOWER (TETRATION BASE e)")
    print("=" * 70)
    
    a = 1.0
    print(f"\n  a₀ = 1")
    for n in range(1, 8):
        try:
            a = math.exp(a)
            if a > 1e300:
                print(f"  a_{n} = overflow (> 10^300)")
                break
            print(f"  a_{n} = {a:.6f}  (= {'e' if n == 1 else 'e^' * n + '1'})")
        except OverflowError:
            print(f"  a_{n} = overflow")
            break
    
    print(f"\n  The e-tower grows faster than any fixed exponential tower.")
    print(f"  a₄ = e^(e^(e^e)) ≈ 10^(10^6), too large to represent.")

def gradient_analysis():
    """Analyze gradient magnitudes through EML trees."""
    print("\n" + "=" * 70)
    print("GRADIENT EXPLOSION IN EML TREES")
    print("=" * 70)
    
    print("\n  ∂eml/∂x = exp(x),  ∂eml/∂y = -1/y")
    print("\n  Gradient magnitude at x=1 through depth-d left-chains:")
    print(f"  (Each node applies eml(·, 1), so gradient = exp ∘ exp ∘ ... ∘ exp)")
    
    grad = 1.0
    val = 1.0
    for d in range(1, 8):
        grad *= math.exp(val)
        val = math.exp(val)
        if grad > 1e300 or val > 700:
            print(f"    Depth {d}: gradient = overflow (> 10^300)")
            break
        print(f"    Depth {d}: value = {val:>15.6f}, gradient = {grad:>15.6f}")
    
    print("\n  → Gradient explosion prevents naive gradient descent for depth > 3")
    print("  → Solution: gradient clipping, log-space parameterization")

if __name__ == "__main__":
    levels, all_values = explore_tower(max_level=3)
    find_special_constants(all_values)
    count_pure_trees()
    analyze_fixed_points()
    e_tower()
    gradient_analysis()
    
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"  Total distinct constants found (depth ≤ 3): {len(all_values)}")
    print(f"  Minimum value: {min(all_values.keys()):.10f}")
    print(f"  Maximum value: {max(v for v in all_values.keys() if v < 1e10):.10f}")
    print(f"  Contains 0: {'Yes ✓' if any(abs(v) < 1e-10 for v in all_values.keys()) else 'No'}")
    print(f"  Contains negative values: {'Yes' if any(v < 0 for v in all_values.keys()) else 'No'}")
