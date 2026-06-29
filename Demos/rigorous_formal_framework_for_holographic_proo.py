"""
Holographic Verification of Tree-Structured Proofs — Numerical Demonstrations
============================================================================

This self-contained script demonstrates, with concrete numbers, the four core
results of the holographic proof-verification theory:

  1. Completeness        -- an honest authentication path reconstructs the root,
                            for ANY hash (here we even use addition).
  2. Soundness / binding -- under an injective hash, only the committed leaf
                            verifies; any forged leaf is rejected.
  3. Holographic bound   -- certificate length = tree depth = log2(numLeaves)
                            for a perfectly balanced proof; depth + 1 <= leaves.
  4. Composition         -- a k-fold sequential chain has certificate length
                            at most (sum of component depths) + k.

The data model mirrors the Lean development exactly:
    PTree := Leaf(value: int) | Node(left: PTree, right: PTree)
Paths are lists of booleans (False = go left, True = go right).

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List, Optional, Union
import math


# --------------------------------------------------------------------------
# Proof trees (PTree)
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class Leaf:
    """A leaf carrying a natural-number digest (fingerprint of an axiom)."""
    value: int


@dataclass(frozen=True)
class Node:
    """An internal step joining two subproofs."""
    left: "PTree"
    right: "PTree"


PTree = Union[Leaf, Node]
Hash = Callable[[int, int], int]


# --------------------------------------------------------------------------
# Basic tree statistics
# --------------------------------------------------------------------------

def depth(t: PTree) -> int:
    """depth(leaf) = 0 ; depth(node l r) = 1 + max(depth l, depth r)."""
    if isinstance(t, Leaf):
        return 0
    return 1 + max(depth(t.left), depth(t.right))


def num_leaves(t: PTree) -> int:
    """numLeaves(leaf) = 1 ; numLeaves(node l r) = numLeaves l + numLeaves r."""
    if isinstance(t, Leaf):
        return 1
    return num_leaves(t.left) + num_leaves(t.right)


# --------------------------------------------------------------------------
# Merkle commitment, certificate, verifier
# --------------------------------------------------------------------------

def root(h: Hash, t: PTree) -> int:
    """The Merkle root: root(leaf x) = x ; root(node l r) = h(root l, root r)."""
    if isinstance(t, Leaf):
        return t.value
    return h(root(h, t.left), root(h, t.right))


def valid(t: PTree, p: List[bool]) -> bool:
    """A path is valid iff it addresses a genuine leaf of t."""
    if isinstance(t, Leaf):
        return len(p) == 0
    if len(p) == 0:
        return False
    return valid(t.left, p[1:]) if p[0] is False else valid(t.right, p[1:])


def leaf_at(t: PTree, p: List[bool]) -> int:
    """The leaf value addressed by a valid path p."""
    if isinstance(t, Leaf):
        return t.value
    return leaf_at(t.left, p[1:]) if p[0] is False else leaf_at(t.right, p[1:])


def auth_path(h: Hash, t: PTree, p: List[bool]) -> List[int]:
    """
    The authentication path (certificate): the list of sibling roots along p.
        authPath (leaf) []           = []
        authPath (node l r) (F :: p) = root r :: authPath l p
        authPath (node l r) (T :: p) = root l :: authPath r p
    """
    if isinstance(t, Leaf):
        return []
    if p[0] is False:
        return [root(h, t.right)] + auth_path(h, t.left, p[1:])
    return [root(h, t.left)] + auth_path(h, t.right, p[1:])


def reconstruct(h: Hash, x: int, p: List[bool], cert: List[int]) -> int:
    """
    The verifier: fold the leaf value x and certificate back up to a root.
        reconstruct x []        []         = x
        reconstruct x (F :: p) (s :: cert) = h(reconstruct x p cert, s)
        reconstruct x (T :: p) (s :: cert) = h(s, reconstruct x p cert)
    """
    if len(p) == 0:
        return x
    sub = reconstruct(h, x, p[1:], cert[1:])
    return h(sub, cert[0]) if p[0] is False else h(cert[0], sub)


# --------------------------------------------------------------------------
# Perfect trees and composition
# --------------------------------------------------------------------------

def perfect(k: int, x: int = 0) -> PTree:
    """A perfectly balanced tree of height k: 2^k leaves, depth k."""
    if k == 0:
        return Leaf(x)
    child = perfect(k - 1, x)
    return Node(child, child)


def labelled_perfect(k: int, start: int = 0) -> PTree:
    """A perfect tree of height k with distinct leaf labels start, start+1, ..."""
    counter = [start]

    def build(level: int) -> PTree:
        if level == 0:
            v = counter[0]
            counter[0] += 1
            return Leaf(v)
        return Node(build(level - 1), build(level - 1))

    return build(k)


def compose(t1: PTree, t2: PTree) -> PTree:
    """Binary composition: a Merkle join of two proofs."""
    return Node(t1, t2)


def chain(ts: List[PTree]) -> PTree:
    """Right-leaning sequential composition; chain([]) = Leaf(0)."""
    if len(ts) == 0:
        return Leaf(0)
    if len(ts) == 1:
        return ts[0]
    return compose(ts[0], chain(ts[1:]))


# --------------------------------------------------------------------------
# A genuinely injective hash (collision-resistant idealization) and a
# deliberately non-injective one (plain addition) for contrast.
# --------------------------------------------------------------------------

def szudzik_pair(a: int, b: int) -> int:
    """Szudzik's elegant pairing -- an injective map N x N -> N."""
    return a * a + a + b if a >= b else a + b * b


def add_hash(a: int, b: int) -> int:
    """A NON-injective 'hash' (addition). Completeness still holds; binding fails."""
    return a + b


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_completeness() -> None:
    print("=" * 70)
    print("1. COMPLETENESS  (honest certificate -> true root, ANY hash)")
    print("=" * 70)
    t = Node(Node(Leaf(3), Leaf(5)), Node(Leaf(8), Node(Leaf(2), Leaf(7))))
    for h, name in [(szudzik_pair, "szudzik (injective)"), (add_hash, "addition")]:
        true_root = root(h, t)
        all_ok = True
        for p in _all_valid_paths(t):
            cert = auth_path(h, t, p)
            rec = reconstruct(h, leaf_at(t, p), p, cert)
            all_ok = all_ok and (rec == true_root)
        print(f"  hash = {name:22s}  root = {true_root:<8d}  "
              f"all leaves reconstruct root: {all_ok}")
    print("  => completeness holds with no assumption on the hash.\n")


def demo_binding() -> None:
    print("=" * 70)
    print("2. SOUNDNESS / BINDING  (injective hash -> only committed leaf passes)")
    print("=" * 70)
    t = labelled_perfect(3, start=10)  # 8 leaves: 10..17
    h = szudzik_pair
    true_root = root(h, t)
    p = [False, True, False]           # some leaf position
    committed = leaf_at(t, p)
    cert = auth_path(h, t, p)
    print(f"  committed leaf at path {p} = {committed}, root = {true_root}")
    print(f"  honest leaf {committed}: verifies = "
          f"{reconstruct(h, committed, p, cert) == true_root}")
    forgeries = [committed + 1, committed - 1, 999]
    for fake in forgeries:
        ok = reconstruct(h, fake, p, cert) == true_root
        print(f"  forged   leaf {fake:<4d}: verifies = {ok}")
    print("  => with an injective hash, every forgery is rejected.")

    print("\n  Contrast: a NON-injective hash (addition) is NOT binding --")
    print("  distinct trees collide to the same root, so a forged tree passes:")
    h2 = add_hash
    t_honest = Node(Leaf(2), Leaf(8))   # root = 10
    t_forged = Node(Leaf(5), Leaf(5))   # root = 10 as well -> collision
    print(f"     root(add, Node(2,8)) = {root(h2, t_honest)}, "
          f"root(add, Node(5,5)) = {root(h2, t_forged)}  -> collision")
    pp = [True]
    cert_h = auth_path(h2, t_honest, pp)
    forged_leaf = leaf_at(t_forged, pp)  # = 5, but commitment was to 8
    passes = reconstruct(h2, forged_leaf, pp, [root(h2, t_forged.left)]) == \
        root(h2, t_honest)
    print(f"     forged leaf {forged_leaf} verifies against honest root: {passes}")
    print("     => collision resistance (injectivity) is exactly what binding needs.")
    print()


def demo_holographic_bound() -> None:
    print("=" * 70)
    print("3. HOLOGRAPHIC BOUND  (cert length = depth = log2(numLeaves))")
    print("=" * 70)
    h = szudzik_pair
    print(f"  {'height k':>9} | {'numLeaves':>10} | {'depth':>6} | "
          f"{'cert len':>9} | {'log2(leaves)':>12} | depth+1<=leaves")
    print("  " + "-" * 74)
    for k in range(0, 13):
        t = perfect(k)
        n = num_leaves(t)
        d = depth(t)
        p = [False] * k
        clen = len(auth_path(h, t, p))
        log2n = int(math.log2(n))
        print(f"  {k:>9} | {n:>10} | {d:>6} | {clen:>9} | {log2n:>12} | "
              f"{d + 1 <= n}")
    print("  => certificate length equals log2(numLeaves): O(log n).\n")


def demo_composition() -> None:
    print("=" * 70)
    print("4. COMPOSITION SUBADDITIVITY  (cert length <= sum(depths) + k)")
    print("=" * 70)
    h = szudzik_pair
    for k, leaf_height in [(2, 3), (3, 2), (5, 2), (4, 4)]:
        comps = [perfect(leaf_height, x) for x in range(k)]
        c = chain(comps)
        bound = sum(depth(t) for t in comps) + k
        # worst-case path: go all the way down the right spine then into last comp
        p = _deepest_valid_path(c)
        clen = len(auth_path(h, c, p))
        print(f"  k={k} components of depth {leaf_height}:  "
              f"cert length = {clen:<3d}  <=  sum(depths)+k = {bound:<3d}  "
              f"[{clen <= bound}]")
    print("  => k-fold composition is holographic up to a +k overhead.\n")


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

def _all_valid_paths(t: PTree) -> List[List[bool]]:
    if isinstance(t, Leaf):
        return [[]]
    left = [[False] + p for p in _all_valid_paths(t.left)]
    right = [[True] + p for p in _all_valid_paths(t.right)]
    return left + right


def _deepest_valid_path(t: PTree) -> List[bool]:
    paths = _all_valid_paths(t)
    return max(paths, key=len)


def main() -> None:
    print("\nHOLOGRAPHIC VERIFICATION OF TREE-STRUCTURED PROOFS")
    print("Numerical demonstrations of the four core theorems.\n")
    demo_completeness()
    demo_binding()
    demo_holographic_bound()
    demo_composition()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
