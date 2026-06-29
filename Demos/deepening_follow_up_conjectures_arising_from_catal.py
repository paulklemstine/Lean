"""
Valuation-Depth -> Tropical Functor: numerical demonstrations.

This self-contained script demonstrates the main results of the paper
"Height Is the Only Cost". It implements combination trees, the unit-cost
(max-plus-one) depth carrier, the balanced / caterpillar / median-split
constructions, and verifies every theorem numerically:

  * Fundamental bound:   depth(eval t) <= maxLeafDepth(t) + height(t)
  * Height-leaf duality: ceil(log2 numLeaves) <= height <= numLeaves - 1
  * Optimality sandwich: balanced attains floor, caterpillar attains ceiling
  * Exponential gap:     balanced ~ log m, caterpillar ~ m, same leaf count
  * Median-split:        optimal height ceil(log2 m) for EVERY m >= 1
  * Cost-c scaling:      depth(eval t) <= maxLeafDepth + c * height
  * Witness sandwich:    maxLeafDepth <= eval <= maxLeafDepth + height
  * Hensel certificate:  k-fold doubling tree has depth k, precision 2^k

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from math import ceil, log2
from typing import Callable, List, Optional, Union


# --------------------------------------------------------------------------- #
# Combination trees
# --------------------------------------------------------------------------- #
@dataclass
class Leaf:
    """A leaf carrying a value."""
    value: int


@dataclass
class Node:
    """An internal node combining two subtrees."""
    left: "OpTree"
    right: "OpTree"


OpTree = Union[Leaf, Node]


def evaluate(add: Callable[[int, int], int], t: OpTree) -> int:
    """Evaluate a combination tree under a binary operation `add`."""
    if isinstance(t, Leaf):
        return t.value
    return add(evaluate(add, t.left), evaluate(add, t.right))


def height(t: OpTree) -> int:
    """Height of a tree (a leaf has height 0)."""
    if isinstance(t, Leaf):
        return 0
    return max(height(t.left), height(t.right)) + 1


def num_leaves(t: OpTree) -> int:
    """Number of leaves of a tree."""
    if isinstance(t, Leaf):
        return 1
    return num_leaves(t.left) + num_leaves(t.right)


def max_leaf_depth(depth: Callable[[int], int], t: OpTree) -> int:
    """Maximum leaf depth under a depth measure."""
    if isinstance(t, Leaf):
        return depth(t.value)
    return max(max_leaf_depth(depth, t.left), max_leaf_depth(depth, t.right))


# --------------------------------------------------------------------------- #
# The unit-cost (max-plus-one) carrier and cost-c carriers
# --------------------------------------------------------------------------- #
def unit_cost_add(x: int, y: int) -> int:
    """The canonical unit-cost operation: max(x, y) + 1."""
    return max(x, y) + 1


def cost_add(c: int) -> Callable[[int, int], int]:
    """The cost-c operation: max(x, y) + c."""
    return lambda x, y: max(x, y) + c


def identity_depth(v: int) -> int:
    """The witness carrier's depth: identity on N."""
    return v


# --------------------------------------------------------------------------- #
# Canonical tree constructions
# --------------------------------------------------------------------------- #
def balanced(k: int, n: int) -> OpTree:
    """Balanced (perfect) tree of height n: 2^n leaves, all valued k."""
    if n == 0:
        return Leaf(k)
    sub = balanced(k, n - 1)
    return Node(sub, sub)


def caterpillar(k: int, n: int) -> OpTree:
    """Left-spine caterpillar with n+1 leaves and height n."""
    if n == 0:
        return Leaf(k)
    return Node(caterpillar(k, n - 1), Leaf(k))


def mk_balanced(k: int, m: int) -> OpTree:
    """Median-split optimal tree with exactly m >= 1 leaves and height ceil(log2 m)."""
    if m <= 1:
        return Leaf(k)
    top = (m + 1) // 2      # ceil(m/2)
    bot = m // 2            # floor(m/2)
    return Node(mk_balanced(k, top), mk_balanced(k, bot))


def clog2(m: int) -> int:
    """Ceiling of log base 2 (Nat.clog 2), with clog2(0) = clog2(1) = 0."""
    if m <= 1:
        return 0
    return ceil(log2(m))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_fundamental_bound() -> None:
    print("=" * 70)
    print("Fundamental bound: depth(eval t) <= maxLeafDepth(t) + height(t)")
    print("=" * 70)
    trees = {
        "balanced(0,3)": balanced(0, 3),
        "caterpillar(0,5)": caterpillar(0, 5),
        "mk_balanced(0,7)": mk_balanced(0, 7),
    }
    for name, t in trees.items():
        ev = evaluate(unit_cost_add, t)
        bound = max_leaf_depth(identity_depth, t) + height(t)
        ok = ev <= bound
        print(f"  {name:18s}  eval={ev:3d}  <=  bound={bound:3d}   {'OK' if ok else 'FAIL'}")
    print()


def demo_height_leaf_duality() -> None:
    print("=" * 70)
    print("Height-leaf duality: ceil(log2 numLeaves) <= height <= numLeaves - 1")
    print("=" * 70)
    trees = [balanced(0, n) for n in range(5)] + [caterpillar(0, n) for n in range(5)] \
        + [mk_balanced(0, m) for m in (3, 5, 6, 7, 10, 13)]
    all_ok = True
    for t in trees:
        h, nl = height(t), num_leaves(t)
        lo, hi = clog2(nl), nl - 1
        ok = lo <= h <= hi
        all_ok &= ok
        print(f"  leaves={nl:3d}  height={h:2d}  [{lo:2d}, {hi:3d}]   {'OK' if ok else 'FAIL'}")
    print(f"  ALL SANDWICHES HOLD: {all_ok}\n")


def demo_optimality_sandwich() -> None:
    print("=" * 70)
    print("Optimality sandwich: balanced hits floor, caterpillar hits ceiling")
    print("=" * 70)
    for n in range(1, 6):
        b = balanced(0, n)
        c = caterpillar(0, n)
        print(f"  n={n}:  balanced height={height(b)} = clog2(leaves)={clog2(num_leaves(b))} ;"
              f"  caterpillar height={height(c)} = leaves-1={num_leaves(c) - 1}")
    print()


def demo_exponential_gap() -> None:
    print("=" * 70)
    print("Exponential reassociation gap (same leaf count 2^n)")
    print("=" * 70)
    print(f"  {'n':>3} {'leaves':>8} {'balanced':>10} {'caterpillar':>12} {'ratio':>10}")
    for n in range(2, 8):
        leaves = 2 ** n
        bal = evaluate(unit_cost_add, balanced(0, n))
        cat = evaluate(unit_cost_add, caterpillar(0, leaves - 1))
        print(f"  {n:>3} {leaves:>8} {bal:>10} {cat:>12} {cat / bal:>10.2f}")
    print()


def demo_mk_balanced_all_sizes() -> None:
    print("=" * 70)
    print("Median-split optimality: height = ceil(log2 m) for EVERY m >= 1")
    print("=" * 70)
    all_ok = True
    for m in range(1, 33):
        t = mk_balanced(0, m)
        ok = num_leaves(t) == m and height(t) == clog2(m)
        all_ok &= ok
        if m <= 16 or not ok:
            print(f"  m={m:2d}  leaves={num_leaves(t):2d}  height={height(t):2d}  "
                  f"clog2={clog2(m):2d}   {'OK' if ok else 'FAIL'}")
    print(f"  ALL m in [1,32] OPTIMAL: {all_ok}\n")


def demo_cost_scaling() -> None:
    print("=" * 70)
    print("Cost-c scaling: depth(eval t) <= maxLeafDepth + c * height")
    print("=" * 70)
    t = mk_balanced(0, 6)
    for c in range(0, 4):
        ev = evaluate(cost_add(c), t)
        bound = max_leaf_depth(identity_depth, t) + c * height(t)
        print(f"  c={c}:  eval={ev:3d}  <=  bound={bound:3d}   {'OK' if ev <= bound else 'FAIL'}")
    print()


def demo_witness_sandwich() -> None:
    print("=" * 70)
    print("Witness sandwich: maxLeafDepth <= eval <= maxLeafDepth + height")
    print("=" * 70)
    # Mixed leaf values so maxLeafDepth is nontrivial.
    t = Node(Node(Leaf(5), Leaf(2)), Node(Leaf(1), Leaf(3)))
    ev = evaluate(unit_cost_add, t)
    mld = max_leaf_depth(identity_depth, t)
    print(f"  maxLeafDepth={mld}  <=  eval={ev}  <=  maxLeafDepth+height={mld + height(t)}")
    print(f"  no leaf value lost: {mld <= ev}\n")


def demo_hensel_certificate() -> None:
    print("=" * 70)
    print("Hensel/Newton certificate: k-fold doubling tree -> depth k, precision 2^k")
    print("=" * 70)
    for k in range(0, 7):
        depth_val = evaluate(unit_cost_add, balanced(0, k))
        precision = 2 ** depth_val
        print(f"  k={k}:  depth={depth_val}=height  ;  p-adic precision 2^depth={precision}")
    print()


def main() -> None:
    demo_fundamental_bound()
    demo_height_leaf_duality()
    demo_optimality_sandwich()
    demo_exponential_gap()
    demo_mk_balanced_all_sizes()
    demo_cost_scaling()
    demo_witness_sandwich()
    demo_hensel_certificate()
    print("All numerical checks completed.")


if __name__ == "__main__":
    main()
