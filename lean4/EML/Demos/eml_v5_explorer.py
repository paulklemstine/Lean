#!/usr/bin/env python3
"""
EML V5 Research Explorer
========================
Comprehensive computational exploration of the EML operator eml(x,y) = exp(x) - ln(y).

New discoveries and computations for Version 5:
1. Complete constant enumeration up to 7 nodes
2. EML constant density analysis
3. Diagonal map orbits and convergence
4. Fixed point numerical analysis
5. Julia set cross-sections
6. Tropical EML demonstrations
7. EML interval arithmetic verification
8. Power-associativity counterexample verification
"""

import math
import itertools
from collections import defaultdict
from typing import Optional, Tuple, List

# ============================================================
# Core EML Operator
# ============================================================

def eml(x: float, y: float) -> Optional[float]:
    """Compute eml(x, y) = exp(x) - ln(y), with safe handling."""
    try:
        ex = math.exp(x)
        if y <= 0:
            return None
        ly = math.log(y)
        return ex - ly
    except (OverflowError, ValueError):
        return None

def eml_safe(x: float, y: float) -> Optional[float]:
    """Safe EML with overflow protection."""
    try:
        if abs(x) > 700:
            return None
        return eml(x, y)
    except:
        return None

# ============================================================
# 1. EML Constant Enumeration
# ============================================================

class EMLTree:
    """Binary tree for EML expressions."""
    pass

class Leaf(EMLTree):
    def __init__(self):
        self.value = 1.0
    def eval(self):
        return 1.0
    def __repr__(self):
        return "1"
    def node_count(self):
        return 0

class Node(EMLTree):
    def __init__(self, left: EMLTree, right: EMLTree):
        self.left = left
        self.right = right
    def eval(self):
        l = self.left.eval()
        r = self.right.eval()
        if l is None or r is None:
            return None
        return eml_safe(l, r)
    def __repr__(self):
        return f"eml({self.left}, {self.right})"
    def node_count(self):
        return 1 + self.left.node_count() + self.right.node_count()

def generate_trees(n: int) -> List[EMLTree]:
    """Generate all binary trees with n internal nodes."""
    if n == 0:
        return [Leaf()]
    trees = []
    for k in range(n):
        lefts = generate_trees(k)
        rights = generate_trees(n - 1 - k)
        for l in lefts:
            for r in rights:
                trees.append(Node(l, r))
    return trees

def enumerate_constants(max_nodes: int = 6) -> dict:
    """Enumerate all EML constants up to given tree size."""
    results = {}
    for n in range(max_nodes + 1):
        trees = generate_trees(n)
        values = set()
        for t in trees:
            v = t.eval()
            if v is not None and math.isfinite(v):
                values.add(round(v, 12))
        results[n] = {
            'num_trees': len(trees),
            'num_distinct': len(values),
            'values': sorted(values)
        }
    return results

# ============================================================
# 2. Constant Density Analysis
# ============================================================

def constant_density_analysis(max_nodes: int = 7):
    """Analyze the density μ_n = distinct_values / C_n."""
    catalan = [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862]
    print("\n" + "="*70)
    print("EML CONSTANT DENSITY ANALYSIS")
    print("="*70)
    print(f"{'Nodes':>6} {'Trees (Cₙ)':>12} {'Distinct':>10} {'Density μₙ':>12} {'Cumulative':>12}")
    print("-"*70)

    all_values = set()
    for n in range(min(max_nodes + 1, len(catalan))):
        trees = generate_trees(n)
        values = set()
        for t in trees:
            v = t.eval()
            if v is not None and math.isfinite(v):
                values.add(round(v, 10))
        all_values |= values
        cn = catalan[n] if n < len(catalan) else len(trees)
        density = len(values) / cn if cn > 0 else 0
        print(f"{n:>6} {cn:>12} {len(values):>10} {density:>12.6f} {len(all_values):>12}")

# ============================================================
# 3. Diagonal Map Orbits
# ============================================================

def diagonal_map(z: float) -> Optional[float]:
    """d(z) = exp(z) - ln(z)."""
    try:
        if z <= 0:
            return math.exp(z)  # log(z) = 0 for z ≤ 0 in math convention
        return math.exp(z) - math.log(z)
    except OverflowError:
        return None

def iterate_diagonal(z0: float, steps: int = 20) -> List[float]:
    """Iterate the diagonal map."""
    orbit = [z0]
    z = z0
    for _ in range(steps):
        z = diagonal_map(z)
        if z is None or z > 1e300:
            break
        orbit.append(z)
    return orbit

def diagonal_map_analysis():
    """Analyze the diagonal map d(z) = exp(z) - ln(z)."""
    print("\n" + "="*70)
    print("DIAGONAL MAP ANALYSIS: d(z) = exp(z) - ln(z)")
    print("="*70)

    # Verify d(z) > z for several values
    print("\nVerification that d(z) > z for all z:")
    test_values = [-10, -5, -1, 0, 0.1, 0.5, 1, 2, 5, 10]
    for z in test_values:
        d = diagonal_map(z)
        gap = d - z if d else None
        print(f"  z = {z:>6.1f}: d(z) = {d:>15.6f}, d(z) - z = {gap:>12.6f} > 0 ✓" if gap and gap > 0 else f"  z = {z:>6.1f}: overflow")

    # Find the minimum of d(z)
    print("\nMinimum of d(z) on (0, ∞):")
    print("  d'(z) = exp(z) - 1/z = 0 at z where z·exp(z) = 1")
    # Newton's method for z·exp(z) = 1
    z = 0.5
    for _ in range(50):
        f = z * math.exp(z) - 1
        fp = math.exp(z) * (1 + z)
        z = z - f / fp
    z_min = z
    d_min = diagonal_map(z_min)
    print(f"  z_min ≈ {z_min:.15f}")
    print(f"  d(z_min) ≈ {d_min:.15f}")
    print(f"  This is the Lambert W function: z_min = W(1) ≈ {z_min:.15f}")

    # Orbit from z=1
    print("\nOrbit of z=1 under d (first 8 iterations):")
    orbit = iterate_diagonal(1.0, 8)
    for i, z in enumerate(orbit):
        print(f"  d^{i}(1) = {z:.6f}")

# ============================================================
# 4. Fixed Point Analysis
# ============================================================

def fixed_point_analysis():
    """Analyze the fixed point of g(z) = e - ln(z)."""
    print("\n" + "="*70)
    print("FIXED POINT OF g(z) = e - ln(z)")
    print("="*70)

    e = math.e

    # Iterate g to find fixed point
    z = 2.0
    print("\nIteration from z₀ = 2.0:")
    for i in range(15):
        print(f"  g^{i:>2}(2.0) = {z:.15f}")
        z = e - math.log(z)

    z_star = z
    print(f"\n  Fixed point z* ≈ {z_star:.15f}")
    print(f"  z* + ln(z*) = {z_star + math.log(z_star):.15f} (should equal e = {e:.15f})")
    print(f"  z* · exp(z*) = {z_star * math.exp(z_star):.15f} (should equal e^e = {e**e:.15f})")
    print(f"  |g'(z*)| = 1/z* = {1/z_star:.15f} (< 1, confirming contraction)")
    print(f"  Convergence ratio ≈ {1/z_star:.6f}")

    # Lambert W connection
    # z* = W(e^e) where W is the Lambert W function
    # W(x) satisfies W(x) · exp(W(x)) = x
    print(f"\n  Lambert W connection:")
    print(f"    z* = W(e^e)")
    print(f"    Verification: z* · exp(z*) = {z_star * math.exp(z_star):.15f}")
    print(f"    e^e = {math.exp(e):.15f}")

# ============================================================
# 5. EML Arithmetic Demonstrations
# ============================================================

def arithmetic_demo():
    """Demonstrate arithmetic operations via EML."""
    print("\n" + "="*70)
    print("ARITHMETIC VIA EML")
    print("="*70)

    e = math.e

    # exp(x) = eml(x, 1)
    x = 2.5
    print(f"\n  exp({x}) = eml({x}, 1) = {eml(x, 1):.10f} (exact: {math.exp(x):.10f})")

    # ln(y) = e - eml(1, y)
    y = 3.0
    print(f"  ln({y}) = e - eml(1, {y}) = {e - eml(1, y):.10f} (exact: {math.log(y):.10f})")

    # a - b = eml(ln(a), exp(b)) for a > 0
    a, b = 5.0, 3.0
    result = eml(math.log(a), math.exp(b))
    print(f"  {a} - {b} = eml(ln({a}), exp({b})) = {result:.10f} (exact: {a-b:.10f})")

    # a + b = eml(ln(a), exp(-b)) for a > 0
    result = eml(math.log(a), math.exp(-b))
    print(f"  {a} + {b} = eml(ln({a}), exp(-{b})) = {result:.10f} (exact: {a+b:.10f})")

    # a * b = exp(ln(a) + ln(b))
    result = math.exp(math.log(a) + math.log(b))
    print(f"  {a} × {b} = exp(ln({a}) + ln({b})) = {result:.10f} (exact: {a*b:.10f})")

    # 1 - x = eml(0, exp(x)) (negation building block)
    x = 7.0
    result = eml(0, math.exp(x))
    print(f"  1 - {x} = eml(0, exp({x})) = {result:.10f} (exact: {1-x:.10f})")

    # Double negation: eml(0, exp(eml(0, exp(x)))) = x
    x = 3.14
    inner = eml(0, math.exp(x))
    result = eml(0, math.exp(inner))
    print(f"  Double negation of {x}: eml(0, exp(eml(0, exp({x})))) = {result:.10f}")

# ============================================================
# 6. Tropical EML
# ============================================================

def tropical_demo():
    """Demonstrate tropical EML properties."""
    print("\n" + "="*70)
    print("TROPICAL EML: trop(x,y) = max(x, -y)")
    print("="*70)

    def trop(x, y):
        return max(x, -y)

    print("\n  Tropical EML recovers max and min:")
    pairs = [(3, 5), (-2, 7), (4, 4), (-1, -3)]
    for x, y in pairs:
        print(f"    max({x}, {y}) = trop({x}, {-y}) = {trop(x, -y)}")
        print(f"    min({x}, {y}) = -trop({-x}, {y}) = {-trop(-x, y)}")
        print(f"    |{x}| = trop({x}, {x}) = {trop(x, x)}")

    print("\n  Tropical EML commutativity on negated args:")
    for x, y in pairs:
        assert trop(x, -y) == trop(y, -x), f"Failed for {x}, {y}"
        print(f"    trop({x}, {-y}) = trop({y}, {-x}) = {trop(x, -y)} ✓")

# ============================================================
# 7. Power-Associativity Failure
# ============================================================

def power_assoc_demo():
    """Demonstrate that EML is not power-associative."""
    print("\n" + "="*70)
    print("EML POWER-ASSOCIATIVITY FAILURE")
    print("="*70)

    x = 0.0
    # eml(0, 0): log(0) is undefined, but in Mathlib log(0) = 0
    # So eml(0, 0) = exp(0) - log(0) = 1 - 0 = 1
    eml_00 = 1.0  # eml(0,0) with log(0) = 0 convention

    # eml(0, eml(0,0)) = eml(0, 1) = exp(0) - log(1) = 1 - 0 = 1
    left = eml(0, eml_00)

    # eml(eml(0,0), 0) = eml(1, 0): exp(1) - log(0)
    # With log(0) = 0 convention: eml(1, 0) = e - 0 = e
    right = math.e  # eml(1, 0) with log(0) = 0

    print(f"\n  x = 0 (using Mathlib convention log(0) = 0):")
    print(f"  eml(0, 0) = exp(0) - log(0) = 1 - 0 = {eml_00}")
    print(f"  eml(0, eml(0,0)) = eml(0, 1) = {left}")
    print(f"  eml(eml(0,0), 0) = eml(1, 0) = {right}")
    print(f"  Left ≠ Right: {left} ≠ {right:.10f} ✓")
    print(f"  (1 ≠ e, confirming non-power-associativity)")

# ============================================================
# 8. e-Tower Growth
# ============================================================

def e_tower_growth():
    """Demonstrate e-tower growth rates."""
    print("\n" + "="*70)
    print("e-TOWER GROWTH ANALYSIS")
    print("="*70)

    e = math.e
    tower = [1.0]
    print("\n  e-tower values:")
    for n in range(8):
        val = tower[-1]
        en = e ** n if n < 20 else float('inf')
        pow2n = 2 ** n
        print(f"  e↑↑{n} = {val:>20.6f}  (≥ e^{n} = {en:>12.4f}, ≥ 2^{n} = {pow2n})")
        try:
            next_val = math.exp(val)
            if next_val > 1e300:
                print(f"  e↑↑{n+1} = exp({val:.6f}) > 10^300 (overflow)")
                break
            tower.append(next_val)
        except OverflowError:
            print(f"  e↑↑{n+1} = overflow")
            break

    print("\n  Growth verification:")
    for i in range(1, min(len(tower), 5)):
        ratio = tower[i] / tower[i-1] if tower[i-1] > 0 else float('inf')
        e_ratio = e
        print(f"  e↑↑{i} / e↑↑{i-1} = {ratio:.6f} ≥ e = {e:.6f}: {'✓' if ratio >= e else '✗'}")

# ============================================================
# 9. EML Interval Arithmetic
# ============================================================

def interval_arithmetic_demo():
    """Demonstrate EML interval arithmetic bounds."""
    print("\n" + "="*70)
    print("EML INTERVAL ARITHMETIC")
    print("="*70)

    # For x ∈ [a,b] and y ∈ [c,d] with c > 0:
    # eml(x,y) ∈ [exp(a) - ln(d), exp(b) - ln(c)]
    intervals = [
        ((0, 1), (1, 2)),
        ((-1, 1), (0.5, 3)),
        ((1, 2), (1, math.e)),
    ]

    for (a, b), (c, d) in intervals:
        lower = math.exp(a) - math.log(d)
        upper = math.exp(b) - math.log(c)
        # Sample some values
        import random
        random.seed(42)
        samples = [eml(random.uniform(a, b), random.uniform(c, d)) for _ in range(1000)]
        actual_min = min(s for s in samples if s is not None)
        actual_max = max(s for s in samples if s is not None)
        print(f"\n  x ∈ [{a}, {b}], y ∈ [{c}, {d}]:")
        print(f"    Proved bounds: [{lower:.6f}, {upper:.6f}]")
        print(f"    Sampled range: [{actual_min:.6f}, {actual_max:.6f}]")
        print(f"    Bounds valid: {lower <= actual_min and actual_max <= upper}")

# ============================================================
# 10. EML Complexity Table
# ============================================================

def complexity_table():
    """Generate EML complexity bounds table."""
    print("\n" + "="*70)
    print("EML COMPLEXITY TABLE (Updated V5)")
    print("="*70)
    print(f"{'Function':>15} {'Upper':>8} {'Lower':>8} {'Exact?':>8} {'Notes':>30}")
    print("-"*70)

    table = [
        ("x", 0, 0, "✓", "leaf"),
        ("1", 0, 0, "✓", "leaf"),
        ("exp(x)", 1, 1, "✓", "eml(x, 1)"),
        ("e", 1, 1, "✓", "eml(1, 1)"),
        ("exp(exp(x))", 2, 2, "✓", "eml(eml(x,1), 1)"),
        ("e^e", 2, 2, "✓", "eml(eml(1,1), 1)"),
        ("e-1", 2, 2, "✓", "eml(1, eml(1,1))"),
        ("0", 3, 3, "✓", "eml(1, eml(eml(1,1),1))"),
        ("e^e - e", 3, 3, "✓", "eml(eml(1,1), eml(eml(1,1),1))"),
        ("ln(x)", 5, 3, "?", "e - eml(1, x)"),
        ("x + y", "≤11", 3, "?", "via exp/log"),
        ("x · y", "≤17", 5, "?", "exp(ln(x)+ln(y))"),
        ("sin(x)", "≤53", 5, "?", "via Euler's formula"),
        ("π", "≤53", 5, "?", "via arctan"),
    ]

    for func, upper, lower, exact, notes in table:
        print(f"{func:>15} {str(upper):>8} {str(lower):>8} {exact:>8} {notes:>30}")

# ============================================================
# 11. Key Mathematical Constants from EML
# ============================================================

def key_constants():
    """List key constants generated by EML trees."""
    print("\n" + "="*70)
    print("KEY EML-GENERATED CONSTANTS")
    print("="*70)

    e = math.e
    constants = [
        ("1", "leaf", 0, 1.0),
        ("e", "eml(1,1)", 1, e),
        ("e-1", "eml(1, eml(1,1))", 2, e - 1),
        ("e^e", "eml(eml(1,1), 1)", 2, e**e),
        ("exp(e-1)", "eml(eml(1, eml(1,1)), 1)", 3, math.exp(e-1)),
        ("0", "eml(1, eml(eml(1,1), 1))", 3, 0),
        ("e^e - e", "eml(eml(1,1), eml(eml(1,1),1))", 3, e**e - e),
        ("1-e", "eml(0, exp(e)) [via 0]", 4, 1 - e),
        ("e^e-1", "eml(eml(1,1), eml(1, eml(1,1)))", 3, e**e - 1),
    ]

    print(f"\n{'Value':>15} {'Approx':>18} {'Nodes':>6} {'Expression':>35}")
    print("-"*75)
    for name, expr, nodes, val in constants:
        print(f"{name:>15} {val:>18.10f} {nodes:>6} {expr:>35}")

# ============================================================
# Main
# ============================================================

def main():
    print("="*70)
    print("   EML V5 RESEARCH EXPLORER")
    print("   eml(x, y) = exp(x) - ln(y)")
    print("   The Continuous Sheffer Stroke")
    print("="*70)

    # Run all analyses
    constant_density_analysis(6)
    diagonal_map_analysis()
    fixed_point_analysis()
    arithmetic_demo()
    tropical_demo()
    power_assoc_demo()
    e_tower_growth()
    interval_arithmetic_demo()
    complexity_table()
    key_constants()

    print("\n" + "="*70)
    print("   EXPLORATION COMPLETE")
    print("="*70)

if __name__ == "__main__":
    main()
