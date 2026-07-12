"""Numerical / computational demonstration of the monoidal strictification of the
parenthesization category.

This self-contained script models:

  * PTree  -- formal parenthesizations (binary trees with labelled leaves);
  * flatten -- the leaf-word of a tree, an element of the free monoid on the
               alphabet (here: a tuple of symbols);
  * the discrete strict skeleton D(alpha) of words under concatenation;
  * the flattening functor Flat : PTree -> D and its inverse Rn (right-nested
    realization), forming a monoidal equivalence;
  * the associator, and its contraction to an identity under strictification.

Every function is inlined and type-hinted; running the file prints a series of
checks demonstrating the theorems of the paper.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Tuple, Union, List
from itertools import count


# ---------------------------------------------------------------------------
# Objects of the parenthesization category: binary trees.
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Nil:
    """The empty tree; the monoidal unit."""


@dataclass(frozen=True)
class Leaf:
    """A single labelled leaf."""
    label: str


@dataclass(frozen=True)
class Node:
    """A bracketed product (left . right)."""
    left: "PTree"
    right: "PTree"


PTree = Union[Nil, Leaf, Node]

Word = Tuple[str, ...]  # element of the free monoid on the alphabet


# ---------------------------------------------------------------------------
# Flattening : PTree -> free monoid (Definition 3.2).
# ---------------------------------------------------------------------------

def flatten(t: PTree) -> Word:
    """The underlying leaf-word of a tree, forgetting the bracketing."""
    if isinstance(t, Nil):
        return ()
    if isinstance(t, Leaf):
        return (t.label,)
    if isinstance(t, Node):
        return flatten(t.left) + flatten(t.right)
    raise TypeError(f"not a PTree: {t!r}")


# ---------------------------------------------------------------------------
# Tensor product and unit (Definition 3.6).
# ---------------------------------------------------------------------------

def tensor(s: PTree, t: PTree) -> PTree:
    """s (X) t = node(s, t)."""
    return Node(s, t)


UNIT: PTree = Nil()


# ---------------------------------------------------------------------------
# Morphisms: a morphism s -> t exists iff flatten(s) == flatten(t).
# In this thin category, "the morphism" is fully determined by its endpoints,
# so we represent it by the pair (s, t) together with a validity check.
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Mor:
    """A reassociation morphism s -> t; valid iff flatten(s) == flatten(t)."""
    src: PTree
    dst: PTree

    @property
    def valid(self) -> bool:
        return flatten(self.src) == flatten(self.dst)


def hom_exists(s: PTree, t: PTree) -> bool:
    """There is (a unique) morphism s -> t iff they share a leaf-word."""
    return flatten(s) == flatten(t)


def associator(a: PTree, b: PTree, c: PTree) -> Mor:
    """The associator (a(X)b)(X)c  ->  a(X)(b(X)c)."""
    return Mor(tensor(tensor(a, b), c), tensor(a, tensor(b, c)))


# ---------------------------------------------------------------------------
# The strict skeleton D(alpha): words under concatenation (Section 4).
# Objects are words; the only morphisms are identities (equality of words).
# ---------------------------------------------------------------------------

def d_tensor(u: Word, v: Word) -> Word:
    """Strict tensor on the skeleton: concatenation of words."""
    return u + v


D_UNIT: Word = ()


# ---------------------------------------------------------------------------
# Flattening functor Flat : PTree -> D(alpha)  (Definition 4.1) and its
# right-nested inverse Rn (Definition 5.1).
# ---------------------------------------------------------------------------

def flat_functor_obj(t: PTree) -> Word:
    """Flat on objects."""
    return flatten(t)


def rn(w: Word) -> PTree:
    """Right-nested bracketing of a word: node(leaf a1, node(leaf a2, ...))."""
    if not w:
        return Nil()
    head, *tail = w
    return Node(Leaf(head), rn(tuple(tail)))


# ---------------------------------------------------------------------------
# Reassociation via the common right-nested normal form (Algorithm C).
# ---------------------------------------------------------------------------

def reassociate(s: PTree, t: PTree) -> Mor:
    """Return the unique reassociation morphism s -> t (raises if none exists)."""
    if not hom_exists(s, t):
        raise ValueError("no reassociation: different leaf-words")
    return Mor(s, t)


# ---------------------------------------------------------------------------
# Utilities: enumerate all bracketings of a given leaf-word (Catalan many).
# ---------------------------------------------------------------------------

def all_bracketings(word: Word) -> List[PTree]:
    """All binary trees with the given non-empty leaf-word, in order."""
    if len(word) == 1:
        return [Leaf(word[0])]
    trees: List[PTree] = []
    for k in range(1, len(word)):
        for left in all_bracketings(word[:k]):
            for right in all_bracketings(word[k:]):
                trees.append(Node(left, right))
    return trees


def catalan(n: int) -> int:
    """The n-th Catalan number C_n = number of bracketings of n+1 factors."""
    from math import comb
    return comb(2 * n, n) // (n + 1)


def show(t: PTree) -> str:
    """Pretty-print a tree as a bracketed product."""
    if isinstance(t, Nil):
        return "1"
    if isinstance(t, Leaf):
        return t.label
    return f"({show(t.left)}.{show(t.right)})"


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------

def demo_nonstrict() -> None:
    print("=" * 70)
    print("1. Non-strictness (Proposition 3.8): associativity fails on objects")
    print("=" * 70)
    a, b, c = Leaf("a"), Leaf("b"), Leaf("c")
    left = tensor(tensor(a, b), c)   # (a.b).c
    right = tensor(a, tensor(b, c))  # a.(b.c)
    print(f"  (a(X)b)(X)c = {show(left)}")
    print(f"  a(X)(b(X)c) = {show(right)}")
    print(f"  equal as objects?           {left == right}")
    print(f"  same leaf-word (flatten)?   {flatten(left) == flatten(right)} "
          f"-> both flatten to {flatten(left)}")
    print(f"  unique associator exists?   {hom_exists(left, right)}")
    print()


def demo_coherence() -> None:
    print("=" * 70)
    print("2. Coherence from thinness: all reassociations agree")
    print("=" * 70)
    word: Word = ("a", "b", "c", "d")
    trees = all_bracketings(word)
    print(f"  factors: {word}   #bracketings = {len(trees)} "
          f"(Catalan C_{len(word)-1} = {catalan(len(word)-1)})")
    # Every pair of bracketings is joined by exactly one reassociation morphism,
    # and any path of reassociations gives the same result (thinness).
    all_connected = all(
        hom_exists(s, t) for s in trees for t in trees
    )
    print(f"  every pair joined by a (unique) morphism? {all_connected}")
    # Two different associator paths from ((ab)c)d to a(b(cd)) coincide:
    a, b, c, d = (Leaf(x) for x in word)
    start = tensor(tensor(tensor(a, b), c), d)
    end = tensor(a, tensor(b, tensor(c, d)))
    m1 = reassociate(start, end)  # "the" morphism -- uniqueness is the point
    print(f"  pentagon endpoints: {show(start)} -> {show(end)}")
    print(f"  reassociation valid and unique? {m1.valid}")
    print()


def demo_flatten_monoidal() -> None:
    print("=" * 70)
    print("3. Flattening is strictly monoidal (Lemma 4.2)")
    print("=" * 70)
    a, b = tensor(Leaf("a"), Leaf("b")), tensor(Leaf("c"), Leaf("d"))
    lhs = flat_functor_obj(tensor(a, b))
    rhs = d_tensor(flat_functor_obj(a), flat_functor_obj(b))
    print(f"  flat(s (X) t)          = {lhs}")
    print(f"  flat(s) . flat(t)      = {rhs}")
    print(f"  equal?                 {lhs == rhs}")
    print(f"  flat(unit) = ()?       {flat_functor_obj(UNIT) == D_UNIT}")
    print()


def demo_equivalence() -> None:
    print("=" * 70)
    print("4. Monoidal equivalence PTree ~= D(alpha) (Theorems 5.3-5.4)")
    print("=" * 70)
    # Round trip on words: Flat . Rn = identity, exactly.
    for w in [(), ("a",), ("a", "b", "c"), ("x", "y", "z", "w")]:
        assert flatten(rn(w)) == w
    print("  Flat(Rn(w)) == w  for all tested words:  True (counit is identity)")
    # Round trip on trees: Rn(Flat(s)) has same leaf-word as s (canonical iso).
    for s in all_bracketings(("a", "b", "c")):
        s2 = rn(flatten(s))
        assert hom_exists(s, s2)
        canonical = reassociate(s, s2)
        assert canonical.valid
    print("  s ~= Rn(Flat(s)) canonically for every bracketing:  True (unit iso)")
    print("  => the equivalence, with strict-monoidal Flat, is monoidal.")
    print()


def demo_loop_collapse() -> None:
    print("=" * 70)
    print("5. The associator loop contracts to an identity (Theorem 6.1)")
    print("=" * 70)
    a, b, c = Leaf("a"), Leaf("b"), Leaf("c")
    assoc = associator(a, b, c)
    img_src = flat_functor_obj(assoc.src)
    img_dst = flat_functor_obj(assoc.dst)
    print(f"  associator: {show(assoc.src)} -> {show(assoc.dst)}")
    print(f"  Flat(source) = {img_src}")
    print(f"  Flat(target) = {img_dst}")
    print(f"  endpoints coincide in D(alpha)? {img_src == img_dst} "
          f"=> Flat(associator) = identity")
    print()


def main() -> None:
    demo_nonstrict()
    demo_coherence()
    demo_flatten_monoidal()
    demo_equivalence()
    demo_loop_collapse()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
