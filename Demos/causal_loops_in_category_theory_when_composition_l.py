"""
Causal Loops in Category Theory: a concrete non-strict monoidal category.

This self-contained script demonstrates, numerically and constructively, the main
results of the accompanying paper on the *parenthesization category*:

  * Objects are binary trees with labelled leaves (formal parenthesizations).
  * `flatten` forgets the bracketing, returning the underlying leaf-word.
  * A morphism  s -> t  exists iff  flatten(s) == flatten(t), and is then unique
    (the category is THIN) and invertible (it is a GROUPOID).
  * The tensor product is  s (x) t := node(s, t), with unit the empty tree.
  * Associativity FAILS on the nose: (a(x)b)(x)c  and  a(x)(b(x)c)  are distinct
    trees, joined by a canonical, unique ASSOCIATOR isomorphism.
  * STRICTIFICATION: every tree is (uniquely) isomorphic to its right-nested
    normal form, and the whole category is equivalent to the discrete category
    of words.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from math import comb
from typing import List, Optional, Tuple, Union


# ----------------------------------------------------------------------------
# Parenthesization trees
# ----------------------------------------------------------------------------

@dataclass(frozen=True)
class Nil:
    """The empty tree; the monoidal unit."""


@dataclass(frozen=True)
class Leaf:
    """A single labelled leaf."""
    label: str


@dataclass(frozen=True)
class Node:
    """A binary node: the formal bracketed product (left . right)."""
    left: "PTree"
    right: "PTree"


PTree = Union[Nil, Leaf, Node]


def flatten(t: PTree) -> List[str]:
    """The underlying leaf-word of a tree, forgetting the bracketing."""
    if isinstance(t, Nil):
        return []
    if isinstance(t, Leaf):
        return [t.label]
    return flatten(t.left) + flatten(t.right)


def size(t: PTree) -> int:
    """Total number of constructors in the tree (used for the non-strictness proof)."""
    if isinstance(t, Nil):
        return 1
    if isinstance(t, Leaf):
        return 1
    return size(t.left) + size(t.right) + 1


def show(t: PTree) -> str:
    """Human-readable bracketing, e.g. Node(Leaf a, Node(Leaf b, Leaf c)) -> (a(bc))."""
    if isinstance(t, Nil):
        return "e"
    if isinstance(t, Leaf):
        return t.label
    return "(" + show(t.left) + show(t.right) + ")"


# The tensor product on objects and the unit.
def tensor(s: PTree, t: PTree) -> PTree:
    return Node(s, t)


UNIT: PTree = Nil()


# ----------------------------------------------------------------------------
# Morphisms: a morphism s -> t is *witnessed* by flatten(s) == flatten(t).
# In this thin groupoid a morphism carries no data beyond existence, so we model
# "the morphism" as a boolean (exists?) plus the shared word.
# ----------------------------------------------------------------------------

def hom_exists(s: PTree, t: PTree) -> bool:
    """Is there a morphism s -> t? (Equivalently: are s, t isomorphic?)"""
    return flatten(s) == flatten(t)


def are_isomorphic(s: PTree, t: PTree) -> bool:
    """Isomorphism criterion: s ~= t  iff  flatten(s) == flatten(t)."""
    return hom_exists(s, t)


# The associator witnesses  (a(x)b)(x)c  ~=  a(x)(b(x)c).
def associator_source(a: PTree, b: PTree, c: PTree) -> PTree:
    return tensor(tensor(a, b), c)


def associator_target(a: PTree, b: PTree, c: PTree) -> PTree:
    return tensor(a, tensor(b, c))


# ----------------------------------------------------------------------------
# Normal form (right-nested tree) and strictification
# ----------------------------------------------------------------------------

def of_list(word: List[str]) -> PTree:
    """The canonical right-nested tree of a word: a(b(c...))."""
    result: PTree = Nil()
    for label in reversed(word):
        result = Node(Leaf(label), result)
    return result


def normalize(t: PTree) -> PTree:
    """The normal form of t; t is (uniquely) isomorphic to normalize(t)."""
    return of_list(flatten(t))


# ----------------------------------------------------------------------------
# Enumeration of all bracketings and Catalan counts
# ----------------------------------------------------------------------------

def all_bracketings(word: List[str]) -> List[PTree]:
    """All parenthesization trees whose leaf-word is exactly `word` (word nonempty)."""
    if len(word) == 1:
        return [Leaf(word[0])]
    out: List[PTree] = []
    for i in range(1, len(word)):
        for left in all_bracketings(word[:i]):
            for right in all_bracketings(word[i:]):
                out.append(Node(left, right))
    return out


@lru_cache(maxsize=None)
def catalan(m: int) -> int:
    """The m-th Catalan number C_m = binom(2m, m)/(m+1)."""
    return comb(2 * m, m) // (m + 1)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_non_strictness() -> None:
    print("=" * 70)
    print("1. ASSOCIATIVITY FAILS ON THE NOSE (but flattens equal)")
    print("=" * 70)
    a, b, c = Leaf("a"), Leaf("b"), Leaf("c")
    lhs = associator_source(a, b, c)
    rhs = associator_target(a, b, c)
    print(f"  (a(x)b)(x)c = {show(lhs)}   size = {size(lhs)}")
    print(f"  a(x)(b(x)c) = {show(rhs)}   size = {size(rhs)}")
    print(f"  distinct objects?         {lhs != rhs}")
    print(f"  same underlying word?     {flatten(lhs) == flatten(rhs)}  "
          f"(both {''.join(flatten(lhs))})")
    print(f"  associator exists (iso)?  {are_isomorphic(lhs, rhs)}")
    print()


def demo_thin_unique_associator() -> None:
    print("=" * 70)
    print("2. THIN GROUPOID: the associator is the UNIQUE isomorphism")
    print("=" * 70)
    a, b, c = Leaf("a"), Leaf("b"), Leaf("c")
    lhs, rhs = associator_source(a, b, c), associator_target(a, b, c)
    # In a thin category there is at most one morphism; count = 0 or 1.
    n_morphisms = 1 if hom_exists(lhs, rhs) else 0
    print(f"  number of morphisms (a(x)b)(x)c -> a(x)(b(x)c): {n_morphisms}")
    print(f"  invertible (groupoid)?  {hom_exists(rhs, lhs)}")
    print(f"  => the associator carries no data beyond existence.")
    print()


def demo_catalan_and_iso_class() -> None:
    print("=" * 70)
    print("3. BRACKETINGS PER WORD = CATALAN NUMBERS; all mutually isomorphic")
    print("=" * 70)
    for n in range(1, 7):
        word = [chr(ord("a") + i) for i in range(n)]
        trees = all_bracketings(word)
        # verify all bracketings of a fixed word are mutually isomorphic
        all_iso = all(are_isomorphic(trees[0], t) for t in trees)
        print(f"  |word| = {n}:  #bracketings = {len(trees):3d}  "
              f"= C_{n-1} = {catalan(n - 1):3d}   all isomorphic? {all_iso}")
    print()


def demo_strictification() -> None:
    print("=" * 70)
    print("4. STRICTIFICATION: every tree ~= its right-nested normal form")
    print("=" * 70)
    word = ["a", "b", "c", "d"]
    for t in all_bracketings(word):
        nf = normalize(t)
        ok = are_isomorphic(t, nf) and flatten(nf) == flatten(t)
        print(f"  {show(t):12s} ~=  {show(nf):12s}   iso & word-preserving? {ok}")
    print(f"  normal form is the same for all bracketings of {''.join(word)}: "
          f"{show(of_list(word))}")
    print("  => flatten is an equivalence onto the discrete category of words.")
    print()


def demo_pentagon() -> None:
    print("=" * 70)
    print("5. PENTAGON: two associator routes agree on the flattened data")
    print("=" * 70)
    w, x, y, z = Leaf("w"), Leaf("x"), Leaf("y"), Leaf("z")
    start = tensor(tensor(tensor(w, x), y), z)          # ((wx)y)z
    end = tensor(w, tensor(x, tensor(y, z)))            # w(x(yz))
    # long route waypoints
    long_route = [
        start,
        tensor(tensor(w, tensor(x, y)), z),             # (w(xy))z
        tensor(w, tensor(tensor(x, y), z)),             # w((xy)z)
        end,
    ]
    # short route waypoints
    short_route = [
        start,
        tensor(tensor(w, x), tensor(y, z)),             # (wx)(yz)
        end,
    ]
    long_ok = all(are_isomorphic(long_route[i], long_route[i + 1])
                  for i in range(len(long_route) - 1))
    short_ok = all(are_isomorphic(short_route[i], short_route[i + 1])
                   for i in range(len(short_route) - 1))
    print(f"  start = {show(start)}")
    print(f"  end   = {show(end)}")
    print(f"  long route  (3 associators) all iso?  {long_ok}")
    print(f"  short route (2 associators) all iso?  {short_ok}")
    print(f"  both routes reach the same object with the same word?  "
          f"{are_isomorphic(start, end)}")
    print("  => the causal loop closes to the identity (pentagon holds).")
    print()


def main() -> None:
    demo_non_strictness()
    demo_thin_unique_associator()
    demo_catalan_and_iso_class()
    demo_strictification()
    demo_pentagon()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
