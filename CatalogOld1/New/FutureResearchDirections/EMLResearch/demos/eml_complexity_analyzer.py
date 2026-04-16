#!/usr/bin/env python3
"""
EML Complexity Analyzer

Analyzes the EML tree complexity of various mathematical expressions.
Includes brute-force search for optimal representations at small depths.
"""

import cmath
import math
import itertools
from typing import List, Tuple, Optional
from dataclasses import dataclass
import json

# ============================================================
# EML Tree Data Structure
# ============================================================

@dataclass
class Node:
    """A node in an EML expression tree."""
    kind: str       # 'one', 'var', 'eml'
    left: Optional['Node'] = None
    right: Optional['Node'] = None

    def eval(self, x: complex) -> complex:
        if self.kind == 'one':
            return complex(1)
        elif self.kind == 'var':
            return x
        elif self.kind == 'eml':
            a = self.left.eval(x)
            b = self.right.eval(x)
            try:
                return cmath.exp(a) - cmath.log(b)
            except (ValueError, OverflowError):
                return complex(float('nan'))
        raise ValueError(f"Unknown kind: {self.kind}")

    def depth(self) -> int:
        if self.kind in ('one', 'var'):
            return 0
        return 1 + max(self.left.depth(), self.right.depth())

    def leaf_count(self) -> int:
        if self.kind in ('one', 'var'):
            return 1
        return self.left.leaf_count() + self.right.leaf_count()

    def __repr__(self):
        if self.kind == 'one':
            return '1'
        elif self.kind == 'var':
            return 'x'
        return f'eml({self.left},{self.right})'


ONE = Node('one')
VAR = Node('var')

def EML(l, r):
    return Node('eml', l, r)


# ============================================================
# Tree Enumeration
# ============================================================

def enumerate_trees(max_depth: int, use_var: bool = True) -> List[Node]:
    """Enumerate all EML trees up to a given depth."""
    if max_depth == 0:
        trees = [ONE]
        if use_var:
            trees.append(VAR)
        return trees

    # Get trees at smaller depths
    smaller = enumerate_trees(max_depth - 1, use_var)

    # All trees at exactly max_depth
    new_trees = list(smaller)  # copy smaller trees
    for l in smaller:
        for r in smaller:
            t = EML(l, r)
            if t.depth() <= max_depth:
                new_trees.append(t)

    return new_trees


def find_best_tree(target_func, test_points: List[complex],
                   max_depth: int = 3, use_var: bool = True,
                   tolerance: float = 1e-8) -> Tuple[Optional[Node], float]:
    """Find the EML tree that best approximates a target function."""
    trees = enumerate_trees(max_depth, use_var)
    best_tree = None
    best_error = float('inf')

    for tree in trees:
        total_error = 0
        valid = True
        for x in test_points:
            try:
                val = tree.eval(x)
                target = target_func(x)
                if cmath.isnan(val) or cmath.isinf(val):
                    valid = False
                    break
                total_error += abs(val - target)
            except (ValueError, OverflowError, ZeroDivisionError):
                valid = False
                break

        if valid and total_error < best_error:
            best_error = total_error
            best_tree = tree

    return best_tree, best_error


# ============================================================
# Analysis
# ============================================================

def catalan(n: int) -> int:
    """Compute the n-th Catalan number."""
    if n <= 0:
        return 1
    return math.comb(2 * n, n) // (n + 1)


def analyze_tree_counts():
    """Count the number of possible EML trees at each depth."""
    print("=" * 70)
    print("EML TREE ENUMERATION")
    print("=" * 70)

    print(f"\n{'Depth':>6} {'Topologies':>12} {'Trees(k=2)':>12} "
          f"{'Trees(k=3)':>12} {'Leaves':>8}")
    print("-" * 60)

    for depth in range(7):
        n_internal = 2**depth - 1  # max internal nodes in complete binary tree
        # Number of topologies with exactly n internal nodes = C(n)
        # But trees can have variable depth, so count all trees up to depth d
        for k in [2, 3]:
            pass

        # Approximate: trees with n leaves
        n_leaves = 2**depth
        n_topo = catalan(n_leaves - 1)
        trees_k2 = n_topo * 2**n_leaves
        trees_k3 = n_topo * 3**n_leaves

        print(f"{depth:>6} {n_topo:>12,} {trees_k2:>12,} {trees_k3:>12,} {n_leaves:>8}")


def search_for_functions():
    """Search for EML representations of common functions."""
    print("\n" + "=" * 70)
    print("SEARCHING FOR EML REPRESENTATIONS")
    print("=" * 70)

    # Test points for function matching
    test_points = [complex(x) for x in [0.5, 1.0, 1.5, 2.0, 2.5]]

    targets = {
        'exp(x)':      lambda x: cmath.exp(x),
        'x²':          lambda x: x**2,
        'x + 1':       lambda x: x + 1,
        '2x':          lambda x: 2*x,
        'sqrt(x)':     lambda x: cmath.sqrt(x),
        '1/x':         lambda x: 1/x if x != 0 else complex(float('inf')),
    }

    for max_d in [1, 2]:
        print(f"\n--- Max depth = {max_d} ---")
        for name, func in targets.items():
            tree, error = find_best_tree(func, test_points, max_depth=max_d)
            status = "EXACT" if error < 1e-8 else f"err={error:.4e}"
            expr = str(tree) if tree else "none"
            leaves = tree.leaf_count() if tree else '-'
            print(f"  {name:12s}: {expr:30s} [{status}] leaves={leaves}")


def master_formula_analysis():
    """Analyze the EML master formula parameter counts."""
    print("\n" + "=" * 70)
    print("MASTER FORMULA ANALYSIS")
    print("=" * 70)

    print(f"\n{'Depth':>6} {'Params':>8} {'Leaves':>8} {'Growth':>8} "
          f"{'Params/Leaf':>12}")
    print("-" * 50)

    prev_params = 0
    for n in range(1, 10):
        params = 5 * 2**n - 6
        leaves = 2**n
        growth = f"{params/prev_params:.2f}x" if prev_params > 0 else "-"
        ratio = params / leaves
        print(f"{n:>6} {params:>8} {leaves:>8} {growth:>8} {ratio:>12.2f}")
        prev_params = params


def constant_free_analysis():
    """Explore the constant-free binary Sheffer problem."""
    print("\n" + "=" * 70)
    print("CONSTANT-FREE BINARY SHEFFER EXPLORATION")
    print("=" * 70)

    # For EML: eml(x, x) = exp(x) - ln(x)
    print("\nSelf-application eml(x, x) = exp(x) - ln(x):")
    for x_val in [0.5, 1.0, 2.0, math.e]:
        val = math.exp(x_val) - math.log(x_val)
        print(f"  eml({x_val:.4f}, {x_val:.4f}) = {val:.6f}")

    # Check if eml(x,x) has a fixed point: eml(a,a) = a
    # exp(a) - ln(a) = a
    # This is a transcendental equation
    print("\nFixed point search: eml(a, a) = a")
    print("  Need: exp(a) - ln(a) = a, i.e., exp(a) - a = ln(a)")
    try:
        from scipy.optimize import brentq
        f = lambda a: math.exp(a) - math.log(a) - a
        root = brentq(f, 0.01, 5)
        print(f"  Fixed point: a ≈ {root:.10f}")
        print(f"  Verify: eml({root:.6f}, {root:.6f}) = {math.exp(root) - math.log(root):.10f}")
    except ImportError:
        # Simple bisection fallback
        f = lambda a: math.exp(a) - math.log(a) - a
        lo, hi = 0.01, 0.5
        for _ in range(60):
            mid = (lo + hi) / 2
            if f(mid) > 0:
                lo = mid
            else:
                hi = mid
        print(f"  No fixed point exists in (0, 5): eml(a,a) > a for all a > 0")
        print(f"  (exp(a) - ln(a) grows much faster than a)")
    except Exception as e:
        print(f"  No fixed point found in [0.01, 5]: {e}")

    # Self-iterated: eml(eml(x,x), eml(x,x))
    print("\nIterated self-application:")
    x = 1.0
    v = complex(x)
    for i in range(5):
        try:
            v_new = cmath.exp(v) - cmath.log(v)
            print(f"  eml^{i+1}(1,1) = {v_new.real:.6e} + {v_new.imag:.6e}i")
            v = v_new
        except OverflowError:
            print(f"  eml^{i+1}(1,1) = OVERFLOW (exp grows super-exponentially!)")
            break


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║              EML COMPLEXITY ANALYZER                           ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    analyze_tree_counts()
    search_for_functions()
    master_formula_analysis()
    constant_free_analysis()

    print("\nAnalysis complete.")
