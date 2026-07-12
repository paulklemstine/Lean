"""
demo.py — Numerical demonstrations for

    "Strictification of the Reassociation Groupoid:
     The Free Monoid as the Skeleton of Coherent Bracketing"

This self-contained script illustrates the key results:

  * Parenthesization trees (formal bracketings) over an alphabet.
  * Flattening a tree to its underlying word (forgetting the bracketing).
  * Right-nested normalization: the canonical bracketing of a word.
  * "Coherence is connectedness": two bracketings are isomorphic iff they
    flatten to the same word.
  * The strictification round-trip: flatten then normalize returns a tree
    isomorphic to the original; normalize then flatten is the identity on words.
  * The tensor (tree join) becomes list concatenation under flattening.
  * The Catalan census of bracketings and the Segner convolution recurrence,
    cross-checked against an explicit enumeration of all bracketings.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import comb
from typing import Iterator, List, Optional, Union


# ----------------------------------------------------------------------------
# 1. Parenthesization trees
# ----------------------------------------------------------------------------

@dataclass(frozen=True)
class Nil:
    """The empty tree."""


@dataclass(frozen=True)
class Leaf:
    """A single labelled leaf."""
    label: str


@dataclass(frozen=True)
class Node:
    """A formal bracketed product (s . t)."""
    left: "PTree"
    right: "PTree"


PTree = Union[Nil, Leaf, Node]


def flatten(t: PTree) -> List[str]:
    """Underlying word of a tree, forgetting the bracketing (post-order leaves)."""
    if isinstance(t, Nil):
        return []
    if isinstance(t, Leaf):
        return [t.label]
    if isinstance(t, Node):
        return flatten(t.left) + flatten(t.right)
    raise TypeError(f"not a PTree: {t!r}")


def of_list(word: List[str]) -> PTree:
    """Right-nested canonical bracketing a1 . (a2 . ( ... . (an . nil)))."""
    if not word:
        return Nil()
    head, *tail = word
    return Node(Leaf(head), of_list(tail))


def show(t: PTree) -> str:
    """Human-readable bracketing string."""
    if isinstance(t, Nil):
        return "-"
    if isinstance(t, Leaf):
        return t.label
    if isinstance(t, Node):
        return f"({show(t.left)}.{show(t.right)})"
    raise TypeError(f"not a PTree: {t!r}")


# ----------------------------------------------------------------------------
# 2. Morphisms: coherence is connectedness
# ----------------------------------------------------------------------------

def iso(s: PTree, t: PTree) -> bool:
    """Two bracketings are isomorphic iff they flatten to the same word."""
    return flatten(s) == flatten(t)


def canonical(t: PTree) -> PTree:
    """Canonical representative of the isomorphism class of t (skeleton map)."""
    return of_list(flatten(t))


# ----------------------------------------------------------------------------
# 3. Enumeration of bracketings and the Catalan census
# ----------------------------------------------------------------------------

def bracketings(word: List[str]) -> List[PTree]:
    """All binary-tree bracketings of a nonempty word (splitting at every position)."""
    if len(word) == 1:
        return [Leaf(word[0])]
    result: List[PTree] = []
    for i in range(1, len(word)):
        for l, r in product(bracketings(word[:i]), bracketings(word[i:])):
            result.append(Node(l, r))
    return result


def catalan(n: int) -> int:
    """Closed form C_n = binom(2n, n) / (n + 1)."""
    return comb(2 * n, n) // (n + 1)


def catalan_segner(n: int) -> int:
    """C_n via the Segner convolution recurrence C_{k+1} = sum_i C_i C_{k-i}."""
    c: List[int] = [1]
    for k in range(n):
        c.append(sum(c[i] * c[k - i] for i in range(k + 1)))
    return c[n]


# ----------------------------------------------------------------------------
# 4. Demonstrations
# ----------------------------------------------------------------------------

def demo_associativity() -> None:
    a, b, c = Leaf("a"), Leaf("b"), Leaf("c")
    left = Node(Node(a, b), c)     # (a.b).c
    right = Node(a, Node(b, c))    # a.(b.c)
    print("== Associativity fails on the nose, but bracketings are isomorphic ==")
    print(f"  left  = {show(left)}   flatten = {flatten(left)}")
    print(f"  right = {show(right)}   flatten = {flatten(right)}")
    print(f"  equal as trees?      {left == right}")
    print(f"  isomorphic (iso)?    {iso(left, right)}")
    print()


def demo_strictification() -> None:
    print("== Strictification round-trips ==")
    word = ["a", "b", "c", "d"]
    for t in bracketings(word):
        # flatten then normalize returns an isomorphic (canonical) tree
        assert iso(t, canonical(t))
        # normalize then flatten is the identity on words
        assert flatten(canonical(t)) == word
    print(f"  Every bracketing of {word} normalizes to {show(of_list(word))}")
    print("  flatten(normalize(word)) == word for all bracketings  [OK]")
    print("  normalize is a canonical representative of each iso class [OK]")
    print()


def demo_tensor_is_concatenation() -> None:
    print("== Tensor (tree join) becomes list concatenation under flattening ==")
    s = Node(Leaf("a"), Leaf("b"))
    t = Node(Leaf("c"), Node(Leaf("d"), Leaf("e")))
    lhs = flatten(Node(s, t))
    rhs = flatten(s) + flatten(t)
    print(f"  flatten(node(s,t)) = {lhs}")
    print(f"  flatten(s) ++ flatten(t) = {rhs}")
    print(f"  equal? {lhs == rhs}")
    print()


def demo_catalan_census() -> None:
    print("== Catalan census of bracketings ==")
    print("  n+1 factors | #bracketings | C_n (closed) | C_n (Segner)")
    for n in range(0, 8):
        word = [chr(ord("a") + i) for i in range(n + 1)]
        counted = len(bracketings(word))
        assert counted == catalan(n) == catalan_segner(n)
        print(f"      {n + 1:>2}      |     {counted:>5}    |    {catalan(n):>5}     |    "
              f"{catalan_segner(n):>5}")
    print("  enumeration == closed form == Segner recurrence  [OK]")
    print()


def demo_equinumerous_isomorphic() -> None:
    print("== Equinumerous bracketings of a common word are all isomorphic ==")
    word = ["x", "y", "z"]
    trees = bracketings(word)
    all_iso = all(iso(trees[0], t) for t in trees)
    print(f"  {len(trees)} bracketings of {word}: {[show(t) for t in trees]}")
    print(f"  all mutually isomorphic? {all_iso}")
    print()


def main() -> None:
    demo_associativity()
    demo_strictification()
    demo_tensor_is_concatenation()
    demo_catalan_census()
    demo_equinumerous_isomorphic()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
