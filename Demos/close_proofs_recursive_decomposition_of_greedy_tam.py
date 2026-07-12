"""
Numerical demonstrations for:

    Fuss-Catalan Numbers, Dyck Paths, and the Recursive Decomposition
    Underlying Greedy m-Tamari Intervals

This self-contained script verifies, by direct computation and by exhaustive
enumeration of small objects, every result in the accompanying paper:

  * The Fuss-Catalan number  FC(m, n) = C((m+1)n, n) / (m*n + 1).
  * Universal base cases  FC(m, 0) = FC(m, 1) = 1  for all m.
  * Base layer  FC(1, n) = Catalan(n).
  * Exact integrality  (n+1) * C_n = C(2n, n).
  * Positivity, monotonicity, and the lower bound  C_n >= 1.
  * The Catalan convolution  C_{n+1} = sum_{i=0}^{n} C_i * C_{n-i}.
  * The triple bijection:  #Dyck(n) = #BinaryTrees(n) = #PlaneTrees(n+1) = C_n,
    checked by brute-force enumeration for small n.
  * The Knuth left-child / right-sibling bijection between plane forests and
    binary trees, checked to be size-preserving and a genuine bijection.

Run with:  python3 demo.py
"""

from __future__ import annotations

from math import comb
from functools import lru_cache
from typing import List, Tuple, Iterator


# ---------------------------------------------------------------------------
# 1. Fuss-Catalan and Catalan arithmetic
# ---------------------------------------------------------------------------

def fuss_catalan(m: int, n: int) -> int:
    """FC(m, n) = C((m+1)*n, n) / (m*n + 1), computed in the integers."""
    return comb((m + 1) * n, n) // (m * n + 1)


def central_binom(n: int) -> int:
    """The central binomial coefficient C(2n, n)."""
    return comb(2 * n, n)


@lru_cache(maxsize=None)
def catalan(n: int) -> int:
    """Catalan number via the convolution recurrence C_{n+1} = sum C_i C_{n-i}."""
    if n == 0:
        return 1
    return sum(catalan(i) * catalan(n - 1 - i) for i in range(n))


def demo_arithmetic(max_n: int = 12) -> None:
    print("=" * 70)
    print("ARITHMETIC CHAIN")
    print("=" * 70)

    # Universal base cases for several arities.
    for m in range(0, 5):
        assert fuss_catalan(m, 0) == 1
        assert fuss_catalan(m, 1) == 1
    print("FC(m,0) = FC(m,1) = 1  verified for m = 0..4")

    print("\n n :   FC(1,n)   catalan(n)   (n+1)*C_n   C(2n,n)")
    for n in range(max_n + 1):
        fc = fuss_catalan(1, n)
        cat = catalan(n)
        assert fc == cat, "base layer FC(1,n) = catalan(n) failed"
        assert (n + 1) * cat == central_binom(n), "integrality failed"
        assert cat >= 1, "lower bound failed"
        if n > 0:
            assert catalan(n - 1) <= cat, "monotonicity failed"
        print(f"{n:2d} : {fc:9d}   {cat:9d}   {(n+1)*cat:9d}   {central_binom(n):9d}")

    # Recursive decomposition (Catalan convolution).
    print("\nRecursive decomposition  C_{n+1} = sum_i C_i * C_{n-i}:")
    for n in range(max_n):
        conv = sum(catalan(i) * catalan(n - i) for i in range(n + 1))
        assert conv == catalan(n + 1), "convolution failed"
        print(f"  C_{n+1} = {catalan(n+1):6d}  =  sum = {conv:6d}   OK")

    # A table of Fuss-Catalan numbers for higher arities.
    print("\nFuss-Catalan table  FC(m,n):")
    header = "  m\\n " + "".join(f"{n:8d}" for n in range(8))
    print(header)
    for m in range(1, 5):
        row = "".join(f"{fuss_catalan(m, n):8d}" for n in range(8))
        print(f"  {m:3d} {row}")


# ---------------------------------------------------------------------------
# 2. Enumeration of Dyck paths
# ---------------------------------------------------------------------------

def dyck_paths(n: int) -> List[Tuple[int, ...]]:
    """All Dyck paths of semilength n as tuples of +1 (up) / -1 (down)."""
    results: List[Tuple[int, ...]] = []

    def build(prefix: Tuple[int, ...], height: int, ups: int, downs: int) -> None:
        if ups == n and downs == n:
            results.append(prefix)
            return
        if ups < n:
            build(prefix + (1,), height + 1, ups + 1, downs)
        if downs < ups:  # a down keeps height >= 0
            build(prefix + (-1,), height - 1, ups, downs + 1)

    build((), 0, 0, 0)
    return results


# ---------------------------------------------------------------------------
# 3. Binary trees and plane trees
# ---------------------------------------------------------------------------

# A binary tree is either None (empty) or a pair (left, right).
BinTree = object  # None | Tuple['BinTree', 'BinTree']


def binary_trees(n: int) -> List[BinTree]:
    """All binary trees with exactly n internal nodes."""
    if n == 0:
        return [None]
    trees: List[BinTree] = []
    for i in range(n):  # i internal nodes on the left, n-1-i on the right
        for left in binary_trees(i):
            for right in binary_trees(n - 1 - i):
                trees.append((left, right))
    return trees


def bin_internal_nodes(t: BinTree) -> int:
    if t is None:
        return 0
    left, right = t  # type: ignore[misc]
    return 1 + bin_internal_nodes(left) + bin_internal_nodes(right)


# A plane tree is a tuple of its children (each a plane tree); () is a leaf.
PlaneTree = Tuple  # Tuple['PlaneTree', ...]


def plane_forests(n: int) -> List[Tuple[PlaneTree, ...]]:
    """All plane forests whose trees have n nodes in total."""
    if n == 0:
        return [()]
    forests: List[Tuple[PlaneTree, ...]] = []
    # First tree has k nodes (k >= 1): 1 root + a child-forest of k-1 nodes.
    for k in range(1, n + 1):
        for child_forest in plane_forests(k - 1):
            head: PlaneTree = child_forest  # a plane tree = tuple of children
            for rest in plane_forests(n - k):
                forests.append((head,) + rest)
    return forests


def plane_trees(nodes: int) -> List[PlaneTree]:
    """All plane trees with exactly `nodes` nodes (root included)."""
    return [f for f in plane_forests(nodes) if len(f) == 1]  # not used directly


def plane_tree_nodes(t: PlaneTree) -> int:
    return 1 + sum(plane_tree_nodes(c) for c in t)


def plane_trees_with_nodes(nodes: int) -> List[PlaneTree]:
    """A plane tree with `nodes` nodes = a root + child-forest of nodes-1 nodes."""
    if nodes == 0:
        return []
    return [tuple(cf) for cf in plane_forests(nodes - 1)]


# ---------------------------------------------------------------------------
# 4. The Knuth left-child / right-sibling bijection
# ---------------------------------------------------------------------------

def forest_to_bin(forest: Tuple[PlaneTree, ...]) -> BinTree:
    """Knuth transform: children -> left subtree, next sibling -> right subtree."""
    if not forest:
        return None
    head, *rest = forest
    return (forest_to_bin(head), forest_to_bin(tuple(rest)))


def bin_to_forest(t: BinTree) -> Tuple[PlaneTree, ...]:
    """Inverse Knuth transform."""
    if t is None:
        return ()
    left, right = t  # type: ignore[misc]
    return (bin_to_forest(left),) + bin_to_forest(right)


def demo_bijections(max_n: int = 6) -> None:
    print("\n" + "=" * 70)
    print("COMBINATORIAL IDENTITIES (by exhaustive enumeration)")
    print("=" * 70)
    print("\n n :  C_n   #Dyck(n)  #BinTree(n)  #PlaneTree(n+1)")
    for n in range(max_n + 1):
        c = catalan(n)
        d = len(dyck_paths(n))
        b = len(binary_trees(n))
        p = len(plane_trees_with_nodes(n + 1))
        assert c == d == b == p, f"count mismatch at n={n}: {c},{d},{b},{p}"
        print(f"{n:2d} : {c:4d}   {d:6d}   {b:9d}   {p:12d}")

    print("\nKnuth bijection check (plane forests <-> binary trees):")
    for n in range(max_n + 1):
        forests = plane_forests(n)
        images = set()
        for f in forests:
            b = forest_to_bin(f)
            # round-trip and size preservation
            assert bin_to_forest(b) == f, "Knuth not invertible"
            assert bin_internal_nodes(b) == n, "Knuth not size preserving"
            images.add(repr(b))
        # injective and onto the binary trees of the right size
        assert len(images) == len(forests), "Knuth not injective"
        assert len(images) == len(binary_trees(n)), "Knuth not onto"
        print(f"  n = {n}:  {len(forests):4d} forests  <->  "
              f"{len(binary_trees(n)):4d} binary trees   bijection OK")


# ---------------------------------------------------------------------------
# 5. Main
# ---------------------------------------------------------------------------

def main() -> None:
    demo_arithmetic(max_n=12)
    demo_bijections(max_n=6)
    print("\nAll checks passed.")


if __name__ == "__main__":
    main()
