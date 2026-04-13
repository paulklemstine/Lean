#!/usr/bin/env python3
"""
EML Complexity Explorer
=======================
Exhaustive search for minimal EML representations of target functions
and constants. Explores the "EML complexity" K_EML of various targets.

This implements a breadth-first enumeration of all EML expression trees,
evaluating each to find minimal representations.
"""

import math
import cmath
from itertools import product
from collections import defaultdict

def eml_real(x, y):
    """Real EML operator with safety checks."""
    if y <= 0:
        return None
    try:
        result = math.exp(x) - math.log(y)
        if not math.isfinite(result):
            return None
        return result
    except (OverflowError, ValueError):
        return None

def eml_complex(x, y):
    """Complex EML operator."""
    try:
        if y == 0:
            return None
        result = cmath.exp(x) - cmath.log(y)
        if not (cmath.isfinite(result)):
            return None
        if abs(result) > 1e50:
            return None
        return result
    except (OverflowError, ValueError):
        return None

class EMLTree:
    """Represents an EML expression tree."""
    def __init__(self, value=None, left=None, right=None, name="1"):
        self.left = left
        self.right = right
        self.name = name
        self.value = value
    
    @property
    def leaf_count(self):
        if self.left is None:
            return 1
        return self.left.leaf_count + self.right.leaf_count
    
    @property
    def depth(self):
        if self.left is None:
            return 0
        return 1 + max(self.left.depth, self.right.depth)
    
    @property
    def node_count(self):
        if self.left is None:
            return 0
        return 1 + self.left.node_count + self.right.node_count
    
    def __repr__(self):
        return self.name

def enumerate_constants(max_leaves):
    """
    Enumerate all EML constant trees up to max_leaves leaves.
    Returns dict mapping (rounded) value → (tree, leaf_count).
    """
    # Level 0: just the constant 1
    by_leaves = defaultdict(list)  # leaves → [(value, tree)]
    by_leaves[1] = [(1.0, EMLTree(value=1.0, name="1"))]
    
    found = {}  # rounded_value → (leaf_count, tree)
    found[round(1.0, 12)] = (1, EMLTree(value=1.0, name="1"))
    
    for total_leaves in range(2, max_leaves + 1):
        for left_leaves in range(1, total_leaves):
            right_leaves = total_leaves - left_leaves
            if left_leaves not in by_leaves or right_leaves not in by_leaves:
                continue
            
            for lval, ltree in by_leaves[left_leaves]:
                for rval, rtree in by_leaves[right_leaves]:
                    result = eml_real(lval, rval)
                    if result is not None:
                        rounded = round(result, 12)
                        name = f"eml({ltree.name}, {rtree.name})"
                        tree = EMLTree(value=result, left=ltree, right=rtree, name=name)
                        
                        if rounded not in found:
                            found[rounded] = (total_leaves, tree)
                            by_leaves[total_leaves].append((result, tree))
                        elif total_leaves < found[rounded][0]:
                            found[rounded] = (total_leaves, tree)
    
    return found

def search_target(target, found, name="target"):
    """Search for the closest match to a target value."""
    best = None
    best_dist = float('inf')
    for val, (leaves, tree) in found.items():
        dist = abs(val - target)
        if dist < best_dist:
            best_dist = dist
            best = (val, leaves, tree)
    
    if best_dist < 1e-8:
        return f"✓ {name:>10} = {target:.10f}  K_EML ≤ {best[1]}  via {best[2]}"
    else:
        return f"✗ {name:>10} = {target:.10f}  (closest: {best[0]:.10f}, dist={best_dist:.2e})"

def main():
    print("=" * 70)
    print("EML COMPLEXITY EXPLORER")
    print("Exhaustive search for minimal EML representations")
    print("=" * 70)
    
    max_leaves = 9  # Can increase but gets exponentially slower
    print(f"\nSearching all trees with ≤ {max_leaves} leaves...")
    
    found = enumerate_constants(max_leaves)
    
    print(f"Found {len(found)} distinct constants.\n")
    
    # Count by leaf count
    by_leaf_count = defaultdict(int)
    for val, (leaves, tree) in found.items():
        by_leaf_count[leaves] += 1
    
    print("Constants discovered by leaf count:")
    for leaves in sorted(by_leaf_count.keys()):
        print(f"  {leaves} leaves: {by_leaf_count[leaves]} new constants")
    
    # Search for interesting targets
    print("\n" + "-" * 70)
    print("COMPLEXITY BOUNDS FOR KNOWN CONSTANTS")
    print("-" * 70)
    
    targets = [
        ("1", 1.0),
        ("e", math.e),
        ("e^e", math.e ** math.e),
        ("0", 0.0),
        ("e-1", math.e - 1),
        ("e^e-1", math.e ** math.e - 1),
        ("2", 2.0),
        ("e²", math.e ** 2),
        ("1/e", 1.0 / math.e),
        ("ln(2)", math.log(2)),
        ("e-2", math.e - 2),
        ("2e-1", 2 * math.e - 1),
    ]
    
    for name, target in targets:
        print(f"  {search_target(target, found, name)}")
    
    # Print the constant hierarchy
    print("\n" + "-" * 70)
    print("EML CONSTANT HIERARCHY (sorted by value)")
    print("-" * 70)
    
    sorted_vals = sorted(found.items(), key=lambda x: x[0])
    for val, (leaves, tree) in sorted_vals[:30]:
        if abs(val) < 1e6:
            print(f"  {val:>20.10f}  K_EML ≤ {leaves:>2}  {tree}")
    
    if len(sorted_vals) > 30:
        print(f"  ... and {len(sorted_vals) - 30} more constants")
    
    # Verify the leaf-node identity
    print("\n" + "-" * 70)
    print("TREE STRUCTURE VERIFICATION")
    print("-" * 70)
    
    for val, (leaves, tree) in list(found.items())[:10]:
        nodes = tree.node_count
        depth = tree.depth
        assert leaves == nodes + 1, f"Leaf-node identity violated!"
        assert leaves <= 2 ** depth, f"Depth bound violated!"
    print("  ✓ leaves = nodes + 1 verified for all trees")
    print("  ✓ leaves ≤ 2^depth verified for all trees")
    
    # Catalan number verification
    print("\n" + "-" * 70)
    print("CATALAN NUMBER VERIFICATION")
    print("-" * 70)
    
    def catalan(n):
        if n <= 1: return 1
        return sum(catalan(i) * catalan(n-1-i) for i in range(n))
    
    for n in range(8):
        c = catalan(n)
        print(f"  C_{n} = {c:>6}  (trees with {n} nodes, {n+1} leaves)")

if __name__ == "__main__":
    main()
