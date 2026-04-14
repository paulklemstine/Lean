#!/usr/bin/env python3
"""
Tropical EML Explorer

Explores the tropicalization of the EML operator:
  trop_eml(x, y) = max(x, -y)

This is the "shadow" of EML in tropical geometry, where:
  exp(x) → x  (tropical exponential = identity)
  ln(y) → y   (tropical logarithm = identity)
  a - b → max(a, -b)  (tropical subtraction = max with negation)

We explore whether tropical EML has universality properties
in tropical mathematics.
"""

import math
from typing import List, Tuple

def trop_eml(x: float, y: float) -> float:
    """Tropical EML: max(x, -y)."""
    return max(x, -y)

def trop_add(x: float, y: float) -> float:
    """Tropical addition: max(x, y)."""
    return max(x, y)

def trop_mul(x: float, y: float) -> float:
    """Tropical multiplication: x + y."""
    return x + y

# ============================================================
# Recovery of Tropical Operations via Tropical EML
# ============================================================

def demo_tropical_operations():
    """Show how tropical operations are recovered from trop_eml."""
    print("=" * 60)
    print("RECOVERING TROPICAL OPERATIONS FROM TROP_EML")
    print("=" * 60)

    print("\nDefinition: trop_eml(x, y) = max(x, -y)")
    print("\n1. Tropical max (= tropical addition):")
    print("   trop_eml(x, -y) = max(x, y)")
    test_pairs = [(1, 2), (3, 1), (-1, 4), (0, 0), (-2, -3)]
    for x, y in test_pairs:
        result = trop_eml(x, -y)
        expected = max(x, y)
        print(f"   trop_eml({x:3d}, {-y:3d}) = max({x}, {y}) = {result:.0f} {'✓' if result == expected else '✗'}")

    print("\n2. Tropical negation:")
    print("   -x = trop_eml(0, x) when x ≥ 0 (gives max(0, -x) = 0 ≠ -x)")
    print("   Note: tropical negation doesn't directly follow from trop_eml!")
    print("   This is a key difference from the classical EML operator.")

    print("\n3. Tropical identity element:")
    print("   trop_eml(x, ∞) = max(x, -∞) = x (right 'identity' at ∞)")
    for x in [-3, 0, 5]:
        result = trop_eml(x, float('inf'))
        print(f"   trop_eml({x}, ∞) = {result:.0f} {'✓' if result == x else '✗'}")

    print("\n4. Tropical zero generation:")
    print("   trop_eml(x, x) = max(x, -x) = |x| (absolute value!)")
    for x in [-3, -1, 0, 1, 3]:
        result = trop_eml(x, x)
        print(f"   trop_eml({x:2d}, {x:2d}) = max({x}, {-x}) = {result:.0f} (= |{x}|)")

# ============================================================
# Tropical EML Trees
# ============================================================

class TropTree:
    """Tree for tropical EML evaluation."""
    pass

class TropLeaf(TropTree):
    def __init__(self, val: float):
        self.val = val
    def eval(self) -> float:
        return self.val
    def __repr__(self):
        return str(self.val)

class TropNode(TropTree):
    def __init__(self, left: TropTree, right: TropTree):
        self.left = left
        self.right = right
    def eval(self) -> float:
        return trop_eml(self.left.eval(), self.right.eval())
    def __repr__(self):
        return f"trop({self.left}, {self.right})"

def tropical_tree_enumeration():
    """Enumerate small tropical EML trees and their values."""
    print("\n" + "=" * 60)
    print("TROPICAL EML TREE ENUMERATION (leaf value = 1)")
    print("=" * 60)

    # Generate trees with leaf = 1
    one = TropLeaf(1)

    # 1 node
    t1 = TropNode(one, one)
    print(f"\n1 node: trop_eml(1, 1) = max(1, -1) = {t1.eval()}")

    # 2 nodes
    trees2 = [
        TropNode(t1, one),
        TropNode(one, t1),
    ]
    print(f"\n2 nodes:")
    for t in trees2:
        print(f"  {t} = {t.eval()}")

    # 3 nodes
    trees3 = [
        TropNode(TropNode(t1, one), one),
        TropNode(one, TropNode(t1, one)),
        TropNode(TropNode(one, t1), one),
        TropNode(one, TropNode(one, t1)),
        TropNode(t1, t1),
    ]
    print(f"\n3 nodes:")
    for t in trees3:
        print(f"  {t} = {t.eval()}")

    # Count distinct values
    vals = set()
    for depth in range(5):
        # Simple enumeration
        leaves = [TropLeaf(1)]
        current_level = list(leaves)
        for d in range(depth):
            next_level = []
            for l in current_level:
                for r in current_level:
                    next_level.append(TropNode(l, r))
            current_level = next_level

        for t in current_level:
            vals.add(t.eval())

    vals_list = sorted(vals)
    print(f"\nAll distinct values from depth ≤ 4 trees: {vals_list}")
    print(f"Count: {len(vals_list)}")
    print("\nKey observation: tropical EML with leaf=1 generates only")
    print("finitely many values (bounded by tree depth), unlike classical EML")
    print("which generates infinitely many distinct transcendental constants!")

# ============================================================
# Comparison: Classical vs Tropical
# ============================================================

def comparison():
    """Compare classical and tropical EML side by side."""
    print("\n" + "=" * 60)
    print("CLASSICAL EML vs TROPICAL EML")
    print("=" * 60)

    headers = f"{'x':>6s} {'y':>6s} {'eml(x,y)':>14s} {'trop(x,y)':>14s} {'Ratio':>10s}"
    print(f"\n{headers}")
    print("-" * 55)

    test_pairs = [
        (0, 1), (1, 1), (2, 1), (0, 2), (1, 2),
        (-1, 1), (1, 0.5), (0, 0.1), (3, 1), (0.5, 0.5),
    ]

    for x, y in test_pairs:
        try:
            classical = math.exp(x) - math.log(y)
            tropical = max(x, -y)
            ratio = classical / tropical if abs(tropical) > 1e-10 else float('inf')
            print(f"{x:6.1f} {y:6.1f} {classical:14.4f} {tropical:14.4f} {ratio:10.4f}")
        except (ValueError, ZeroDivisionError):
            print(f"{x:6.1f} {y:6.1f} {'N/A':>14s} {max(x,-y):14.4f} {'N/A':>10s}")

    print("\nKey differences:")
    print("• Classical EML: exp(x) dominates for large x → exponential growth")
    print("• Tropical EML: max(x,-y) → piecewise linear, bounded growth")
    print("• Classical: generates all elementary functions")
    print("• Tropical: generates max and absolute value (tropical semiring ops)")
    print("• Tropicalization loses the 'generative power' of the exponential")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   TROPICAL EML EXPLORER                                 ║")
    print("║   trop_eml(x,y) = max(x, -y)                           ║")
    print("║   The tropical shadow of the continuous Sheffer stroke  ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_tropical_operations()
    tropical_tree_enumeration()
    comparison()

    print("\n" + "=" * 60)
    print("CONCLUSIONS")
    print("=" * 60)
    print("""
1. Tropical EML recovers max (tropical addition) via trop_eml(x, -y) = max(x, y)
2. Tropical EML does NOT recover tropical multiplication (ordinary +)
   This means tropical EML is NOT a tropical Sheffer operator!
3. The tropical diagonal map trop_eml(z, z) = |z| has a fixed point at z = 0
   (unlike classical EML where d(z) > z for all z)
4. Tropical EML trees with leaf=1 generate only finitely many values
5. This suggests the universality of EML critically depends on
   the transcendental nature of exp and ln — their tropical
   shadows lose the key generative property.
""")
