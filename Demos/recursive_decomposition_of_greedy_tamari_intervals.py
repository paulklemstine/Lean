"""
demo.py — Numerical demonstration of the bridge between
plane trees, binary trees, and Dyck paths.

This self-contained script:
  1. Enumerates plane forests, plane trees, binary trees, and Dyck paths
     by size.
  2. Implements the left-child / right-sibling (Knuth) transform and its
     inverse, and verifies they are mutually inverse and size-preserving.
  3. Checks that all four families are counted by the Catalan numbers.

All data types are represented with plain Python tuples so the whole demo
runs with the standard library only.

Representations
---------------
Plane tree  : ("node", (child_1, ..., child_k))   -- each child a plane tree
Plane forest: a tuple of plane trees
Binary tree : None (empty) | ("bin", left, right)
Dyck path   : a tuple of +1 / -1 steps
"""

from __future__ import annotations

from functools import lru_cache
from math import comb
from typing import Iterator, Optional, Tuple

# ---------------------------------------------------------------------------
# Type aliases
# ---------------------------------------------------------------------------
PlaneTree = Tuple[str, Tuple]          # ("node", (children...))
Forest = Tuple[PlaneTree, ...]
BinTree = Optional[Tuple[str, "BinTree", "BinTree"]]  # None | ("bin", l, r)
Dyck = Tuple[int, ...]


# ---------------------------------------------------------------------------
# Catalan numbers
# ---------------------------------------------------------------------------
def catalan(n: int) -> int:
    """The n-th Catalan number C_n = (1/(n+1)) * binom(2n, n)."""
    return comb(2 * n, n) // (n + 1)


# ---------------------------------------------------------------------------
# Node counts
# ---------------------------------------------------------------------------
def num_nodes(t: PlaneTree) -> int:
    """Number of nodes of a plane tree (root included)."""
    _, children = t
    return 1 + sum(num_nodes(c) for c in children)


def forest_nodes(f: Forest) -> int:
    """Total number of nodes across a plane forest."""
    return sum(num_nodes(t) for t in f)


def bin_internal(b: BinTree) -> int:
    """Number of internal nodes of a binary tree."""
    if b is None:
        return 0
    _, l, r = b
    return 1 + bin_internal(l) + bin_internal(r)


# ---------------------------------------------------------------------------
# The Knuth transform: plane forest <-> binary tree
# ---------------------------------------------------------------------------
def forest_to_bin(f: Forest) -> BinTree:
    """Encode a plane forest as a binary tree (left = first tree's children,
    right = the remaining forest)."""
    if not f:
        return None
    first, *rest = f
    _, children = first
    return ("bin", forest_to_bin(tuple(children)), forest_to_bin(tuple(rest)))


def bin_to_forest(b: BinTree) -> Forest:
    """Decode a binary tree back into a plane forest."""
    if b is None:
        return ()
    _, l, r = b
    return (("node", bin_to_forest(l)),) + bin_to_forest(r)


# ---------------------------------------------------------------------------
# Enumeration
# ---------------------------------------------------------------------------
@lru_cache(maxsize=None)
def forests_with_nodes(n: int) -> Tuple[Forest, ...]:
    """All plane forests with exactly n nodes."""
    if n == 0:
        return ((),)
    result = []
    # First tree has k nodes (1 <= k <= n); it is node(g) with |g| = k-1.
    for k in range(1, n + 1):
        for g in forests_with_nodes(k - 1):
            first = ("node", g)
            for rest in forests_with_nodes(n - k):
                result.append((first,) + rest)
    return tuple(result)


def trees_with_nodes(n: int) -> Tuple[PlaneTree, ...]:
    """All plane trees with exactly n nodes (n >= 1)."""
    return tuple(("node", g) for g in forests_with_nodes(n - 1))


@lru_cache(maxsize=None)
def bin_trees(n: int) -> Tuple[BinTree, ...]:
    """All binary trees with exactly n internal nodes."""
    if n == 0:
        return (None,)
    result = []
    for i in range(n):
        for l in bin_trees(i):
            for r in bin_trees(n - 1 - i):
                result.append(("bin", l, r))
    return tuple(result)


def dyck_paths(n: int) -> Iterator[Dyck]:
    """All Dyck paths of semilength n (as tuples of +/-1 steps)."""
    def rec(prefix: Tuple[int, ...], up: int, down: int, height: int):
        if up == n and down == n:
            yield prefix
            return
        if up < n:
            yield from rec(prefix + (1,), up + 1, down, height + 1)
        if down < up:
            yield from rec(prefix + (-1,), up, down + 1, height - 1)
    yield from rec((), 0, 0, 0)


# ---------------------------------------------------------------------------
# Verification routines
# ---------------------------------------------------------------------------
def check_bijection(max_nodes: int) -> None:
    """Verify the Knuth transform is a size-preserving involution pair."""
    print("Verifying the Knuth transform (forest <-> binary tree):")
    for n in range(max_nodes + 1):
        for f in forests_with_nodes(n):
            b = forest_to_bin(f)
            assert bin_to_forest(b) == f, "decode(encode) failed"
            assert bin_internal(b) == forest_nodes(f), "size not preserved"
        for b in bin_trees(n):
            f = bin_to_forest(b)
            assert forest_to_bin(f) == b, "encode(decode) failed"
        print(f"  n={n}: all {len(forests_with_nodes(n))} forests round-trip, "
              f"sizes preserved  [OK]")


def check_counts(max_n: int) -> None:
    """Verify all four families are counted by the Catalan numbers."""
    print("\nCatalan enumeration across the four families:")
    header = f"{'n':>3} | {'planeTree(n+1)':>14} | {'forest(n)':>10} | " \
             f"{'binTree(n)':>10} | {'dyck(n)':>8} | {'C_n':>6}"
    print(header)
    print("-" * len(header))
    for n in range(max_n + 1):
        pt = len(trees_with_nodes(n + 1))
        fo = len(forests_with_nodes(n))
        bt = len(bin_trees(n))
        dy = sum(1 for _ in dyck_paths(n))
        cn = catalan(n)
        assert pt == fo == bt == dy == cn, f"count mismatch at n={n}"
        print(f"{n:>3} | {pt:>14} | {fo:>10} | {bt:>10} | {dy:>8} | {cn:>6}")


def show_example() -> None:
    """Print one worked example of the transform."""
    print("\nWorked example (a plane tree with 4 nodes):")
    # root with two children: first a leaf, second a node with one leaf child
    t: PlaneTree = ("node", (("node", ()), ("node", (("node", ()),))))
    print(f"  plane tree              : {t}")
    print(f"  numNodes                : {num_nodes(t)}")
    f: Forest = t[1]
    b = forest_to_bin(f)
    print(f"  children as forest      : {f}")
    print(f"  encoded binary tree     : {b}")
    print(f"  internal nodes of image : {bin_internal(b)}")
    print(f"  decoded back            : {bin_to_forest(b)}")
    assert bin_to_forest(b) == f


def main() -> None:
    print("=" * 70)
    print("Plane trees  <->  Binary trees  <->  Dyck paths")
    print("=" * 70)
    check_bijection(max_nodes=6)
    check_counts(max_n=8)
    show_example()
    print("\nAll checks passed.")


if __name__ == "__main__":
    main()
