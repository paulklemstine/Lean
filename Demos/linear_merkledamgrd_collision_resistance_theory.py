"""
Numerical demonstrations for:

    Collision Resistance as Joint Injectivity:
    A Unified Theory of Merkle-Damgard Chains and Merkle Trees

Everything here is self-contained and probability-free, mirroring the formal
development. The "compression gadget" used in the examples is the standard
injective Cantor-style pairing on the naturals (`nat_pair`), exactly the gadget
that drives the cross-shape counterexample in the theory.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Generic, List, Optional, Tuple, TypeVar, Union

A = TypeVar("A")
B = TypeVar("B")
G = TypeVar("G")


# ---------------------------------------------------------------------------
# The injective compression gadget: Lean's `Nat.pair` and its inverse.
# ---------------------------------------------------------------------------
def nat_pair(a: int, b: int) -> int:
    """Injective pairing of two naturals into one (matches Lean's Nat.pair)."""
    return b * b + a if a < b else a * a + a + b


def nat_unpair(n: int) -> Tuple[int, int]:
    """Inverse of nat_pair, witnessing injectivity."""
    s = 0
    while (s + 1) * (s + 1) <= n:
        s += 1
    # s = floor(sqrt(n))
    if n - s * s < s:
        return (n - s * s, s)
    return (s, n - s * s - s)


# ---------------------------------------------------------------------------
# 1. Merkle-Damgard chain hash = left fold.
# ---------------------------------------------------------------------------
def merkle_damgard(f: Callable[[A, B], A], iv: A, msg: List[B]) -> A:
    """merkleDamgard f iv msg = msg.foldl f iv."""
    acc = iv
    for block in msg:
        acc = f(acc, block)
    return acc


def md_append_law(
    f: Callable[[A, B], A], iv: A, m1: List[B], m2: List[B]
) -> bool:
    """Lemma 4.3 / Theorem 6.1: H(m1 ++ m2) = H_{H(m1)}(m2)."""
    lhs = merkle_damgard(f, iv, m1 + m2)
    rhs = merkle_damgard(f, merkle_damgard(f, iv, m1), m2)
    return lhs == rhs


# ---------------------------------------------------------------------------
# 2. Binary trees and the Merkle tree hash.
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class Leaf(Generic[G]):
    value: G


@dataclass(frozen=True)
class Node(Generic[G]):
    left: "BTree[G]"
    right: "BTree[G]"


BTree = Union[Leaf, Node]


def tree_hash(g: Callable[[G], A], h: Callable[[A, A], A], t: BTree) -> A:
    """treeHash g h: leaves via g, nodes combine children with h."""
    if isinstance(t, Leaf):
        return g(t.value)
    return h(tree_hash(g, h, t.left), tree_hash(g, h, t.right))


def same_shape(t1: BTree, t2: BTree) -> bool:
    """SameShape: agree as trees, ignoring leaf labels."""
    if isinstance(t1, Leaf) and isinstance(t2, Leaf):
        return True
    if isinstance(t1, Node) and isinstance(t2, Node):
        return same_shape(t1.left, t2.left) and same_shape(t1.right, t2.right)
    return False


# ---------------------------------------------------------------------------
# 3. The bridge: a left-comb tree hashes to the chain.
# ---------------------------------------------------------------------------
def left_comb(a: A, bs: List[A]) -> BTree:
    """leftComb a bs: caterpillar tree, each block grafted as a right child."""
    t: BTree = Leaf(a)
    for b in bs:
        t = Node(t, Leaf(b))
    return t


def bridge_holds(h: Callable[[A, A], A], a: A, bs: List[A]) -> bool:
    """Theorem 9.3: treeHash id h (leftComb a bs) = merkleDamgard h a bs."""
    lhs = tree_hash(lambda x: x, h, left_comb(a, bs))
    rhs = merkle_damgard(h, a, bs)
    return lhs == rhs


# ---------------------------------------------------------------------------
# 4. Constructive convergence: locate a collision (Theorem 5.1).
# ---------------------------------------------------------------------------
def locate_collision(
    f: Callable[[A, B], A], a1: A, a2: A, msg: List[B]
) -> Optional[Tuple[A, A, B]]:
    """If distinct seeds converge under msg, return (s1, s2, b) with
    s1 != s2 and f(s1, b) = f(s2, b)."""
    s1, s2 = a1, a2
    for b in msg:
        if s1 != s2 and f(s1, b) == f(s2, b):
            return (s1, s2, b)
        s1, s2 = f(s1, b), f(s2, b)
    return None


# ---------------------------------------------------------------------------
# 5. Domain separation by a one-bit parity tag (Section 8).
# ---------------------------------------------------------------------------
def tagged_leaf(g: Callable[[G], int]) -> Callable[[G], int]:
    """Leaf outputs become even: 2 * g(x)."""
    return lambda x: 2 * g(x)


def tagged_node(h: Callable[[int, int], int]) -> Callable[[int, int], int]:
    """Node outputs become odd: 2 * h(l, r) + 1."""
    return lambda l, r: 2 * h(l, r) + 1


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_chain() -> None:
    print("=" * 70)
    print("1. Merkle-Damgard chain (foldl), append law, and security reduction")
    print("=" * 70)
    f = nat_pair
    iv = 7
    msg = [1, 2, 3, 4]
    print(f"  merkle_damgard(nat_pair, {iv}, {msg}) = {merkle_damgard(f, iv, msg)}")
    print(f"  append law holds for split [1,2]++[3,4]: "
          f"{md_append_law(f, iv, [1, 2], [3, 4])}")

    # Equal-length injectivity (Theorem 4.1): no two distinct equal-length
    # messages collide because nat_pair is injective.
    seen = {}
    collision = None
    for x in range(8):
        for y in range(8):
            for z in range(8):
                m = [x, y, z]
                hsh = merkle_damgard(f, iv, m)
                if hsh in seen and seen[hsh] != m:
                    collision = (seen[hsh], m)
                seen[hsh] = m
    print(f"  exhaustive search over 8^3 length-3 messages -> "
          f"collision found: {collision is not None}  (expected: False)")


def demo_tree_and_bridge() -> None:
    print("=" * 70)
    print("2. Merkle tree hash, same-shape injectivity, and the bridge")
    print("=" * 70)
    g = lambda x: x
    h = nat_pair
    t = Node(Node(Leaf(1), Leaf(2)), Leaf(3))
    print(f"  tree_hash of node(node(1,2),3) = {tree_hash(g, h, t)}")

    a, bs = 5, [1, 2, 3, 4]
    print(f"  bridge: treeHash(leftComb) == merkleDamgard ? {bridge_holds(h, a, bs)}")
    print(f"    leftComb({a}, {bs}) hash = "
          f"{tree_hash(g, h, left_comb(a, bs))}")
    print(f"    merkleDamgard({a}, {bs})  = {merkle_damgard(h, a, bs)}")


def demo_cross_shape_attack() -> None:
    print("=" * 70)
    print("3. Cross-shape collision (Theorem 8.1) and its cure by tagging")
    print("=" * 70)
    g = lambda x: x
    h = nat_pair
    t1: BTree = Node(Leaf(0), Leaf(1))      # a fork
    t2: BTree = Leaf(nat_pair(0, 1))        # a twig
    print(f"  t1 = node(leaf 0, leaf 1), t2 = leaf(nat_pair 0 1)")
    print(f"  same shape? {same_shape(t1, t2)}  (False: shapes differ)")
    print(f"  tree_hash(t1) = {tree_hash(g, h, t1)}, "
          f"tree_hash(t2) = {tree_hash(g, h, t2)}")
    print(f"  COLLISION across shapes: "
          f"{tree_hash(g, h, t1) == tree_hash(g, h, t2)}  (expected: True)")

    gt = tagged_leaf(g)
    ht = tagged_node(h)
    print("  -- apply one-bit parity tag (leaves even, nodes odd) --")
    print(f"  tagged tree_hash(t1) = {tree_hash(gt, ht, t1)}, "
          f"tagged tree_hash(t2) = {tree_hash(gt, ht, t2)}")
    print(f"  collision after tagging: "
          f"{tree_hash(gt, ht, t1) == tree_hash(gt, ht, t2)}  (expected: False)")


def demo_located_collision() -> None:
    print("=" * 70)
    print("4. Constructive convergence: locating a compression collision")
    print("=" * 70)
    # Use a deliberately NON-injective compression so two seeds can converge.
    f = lambda acc, b: (acc + b) % 5  # collides mod 5
    a1, a2 = 0, 5  # distinct integers, but f sees them mod 5 ...
    msg = [3, 1, 4]
    # 0 and 5 differ; first step: f(0,3)=3, f(5,3)=3 -> located collision.
    result = locate_collision(f, a1, a2, msg)
    print(f"  seeds {a1} != {a2}, msg {msg}")
    print(f"  converge? {merkle_damgard(f, a1, msg) == merkle_damgard(f, a2, msg)}")
    print(f"  located collision (s1, s2, b) = {result}")
    if result is not None:
        s1, s2, b = result
        print(f"  check: s1 != s2 is {s1 != s2}; f(s1,b)={f(s1, b)} == "
              f"f(s2,b)={f(s2, b)} -> {f(s1, b) == f(s2, b)}")


def demo_pairing_injectivity() -> None:
    print("=" * 70)
    print("5. Sanity: nat_pair is injective (the gadget hypothesis)")
    print("=" * 70)
    ok = all(nat_unpair(nat_pair(a, b)) == (a, b)
             for a in range(20) for b in range(20))
    print(f"  nat_unpair . nat_pair == id on [0,20)^2 : {ok}")


if __name__ == "__main__":
    demo_chain()
    demo_tree_and_bridge()
    demo_cross_shape_attack()
    demo_located_collision()
    demo_pairing_injectivity()
    print("\nAll demonstrations completed.")
