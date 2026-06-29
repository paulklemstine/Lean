"""
demo.py — The Observation Complexity Theorem
============================================

Numerical demonstrations of the exact query complexity of distinguishability.

Central result
--------------
To tell apart every one of the |A| elements of a finite set A using yes/no
observations (Boolean predicates), the minimal number of observations needed is

        d(A) = ceil(log2 |A|) = clog_2 |A|

where clog_2 is the "ceiling logarithm": the smallest k with |A| <= 2^k.

Two surprises are demonstrated here:

  1. The bound is *exact* — necessary AND sufficient — for every finite set,
     not just sets whose size is a power of two.

  2. *Adaptivity buys no speedup.* A clever decision tree, whose next question
     may depend on all previous answers, needs exactly the same number of
     questions as a fixed (static) list of predicates chosen in advance.

This file is fully self-contained: every routine is inlined, with type hints,
and depends only on the Python standard library.
"""

from __future__ import annotations

from typing import Callable, Dict, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. The ceiling logarithm clog_b, the heart of the complexity formula.
# ---------------------------------------------------------------------------
def clog(base: int, n: int) -> int:
    """Smallest k such that n <= base**k.

    This mirrors Mathlib's `Nat.clog`. Conventions:
      * clog(b, 0) = 0 and clog(b, 1) = 0  (nothing to distinguish)
      * clog(b, n) = 0 whenever base <= 1  (a unary alphabet cannot discriminate)
    """
    if base <= 1 or n <= 1:
        return 0
    k = 0
    power = 1
    while power < n:
        power *= base
        k += 1
    return k


def min_distinguishing_depth(card: int) -> int:
    """The exact number of Boolean observations needed to separate `card` elements."""
    return clog(2, card)


# ---------------------------------------------------------------------------
# 2. Static observation systems: a fixed family of Boolean predicates.
# ---------------------------------------------------------------------------
def bit_predicate(i: int) -> Callable[[int], bool]:
    """Predicate that reads bit `i` of the binary encoding of an element."""
    return lambda a: bool((a >> i) & 1)


def static_profile(preds: Sequence[Callable[[int], bool]], a: int) -> Tuple[bool, ...]:
    """The observation profile of element `a`: the tuple of all predicate answers."""
    return tuple(p(a) for p in preds)


def static_distinguishes(
    preds: Sequence[Callable[[int], bool]], elements: Sequence[int]
) -> bool:
    """True iff the predicate family separates every pair of distinct elements."""
    seen: Dict[Tuple[bool, ...], int] = {}
    for a in elements:
        prof = static_profile(preds, a)
        if prof in seen:
            return False
        seen[prof] = a
    return True


def optimal_static_system(card: int) -> List[Callable[[int], bool]]:
    """The optimal static system for {0, ..., card-1}: read the lowest d bits."""
    d = min_distinguishing_depth(card)
    return [bit_predicate(i) for i in range(d)]


# ---------------------------------------------------------------------------
# 3. Adaptive observation systems: binary decision trees.
# ---------------------------------------------------------------------------
class Leaf:
    """A leaf of a decision tree (depth-0 subtree)."""


class Node:
    """A decision-tree node: ask `query`, branch on the Boolean answer."""

    def __init__(
        self,
        query: Callable[[int], bool],
        if_false: "Node | Leaf",
        if_true: "Node | Leaf",
    ) -> None:
        self.query = query
        self.if_false = if_false
        self.if_true = if_true


def tree_depth(tree: "Node | Leaf") -> int:
    """Depth of a decision tree (number of questions on the longest path)."""
    if isinstance(tree, Leaf):
        return 0
    return 1 + max(tree_depth(tree.if_false), tree_depth(tree.if_true))


def transcript(tree: "Node | Leaf", a: int) -> Tuple[bool, ...]:
    """Run the tree on element `a`, returning the sequence of answers."""
    answers: List[bool] = []
    node = tree
    while isinstance(node, Node):
        ans = node.query(a)
        answers.append(ans)
        node = node.if_true if ans else node.if_false
    return tuple(answers)


def adaptive_distinguishes(tree: "Node | Leaf", elements: Sequence[int]) -> bool:
    """True iff the decision tree gives every element a unique transcript."""
    seen: Dict[Tuple[bool, ...], int] = {}
    for a in elements:
        t = transcript(tree, a)
        if t in seen:
            return False
        seen[t] = a
    return True


def static_to_adaptive(preds: Sequence[Callable[[int], bool]]) -> "Node | Leaf":
    """The bridge: turn a static family into a history-independent decision tree."""
    if not preds:
        return Leaf()
    sub = static_to_adaptive(preds[1:])
    return Node(preds[0], sub, sub)


# ---------------------------------------------------------------------------
# 4. The generalized (k-ary) lower bound.
# ---------------------------------------------------------------------------
def kary_min_depth(card: int, k: int) -> int:
    """Lower bound on the number of k-valued observations needed: clog_k |A|."""
    return clog(k, card)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_exact_complexity() -> None:
    print("=" * 70)
    print("1. EXACT COMPLEXITY:  d(A) = ceil(log2 |A|)")
    print("=" * 70)
    print(f"{'|A|':>6} | {'depth d':>8} | check: 2^(d-1) < |A| <= 2^d")
    print("-" * 70)
    for card in [1, 2, 3, 4, 5, 7, 8, 9, 16, 17, 31, 32, 100, 1000]:
        d = min_distinguishing_depth(card)
        lo = 2 ** (d - 1) if d > 0 else 0
        hi = 2 ** d
        ok = (lo < card <= hi) if card > 1 else (d == 0)
        print(f"{card:>6} | {d:>8} | {lo} < {card} <= {hi}   [{'OK' if ok else 'FAIL'}]")
    print()


def demo_upper_bound() -> None:
    print("=" * 70)
    print("2. UPPER BOUND (static): d bit-predicates separate {0,...,|A|-1}")
    print("=" * 70)
    for card in [3, 5, 16, 100]:
        preds = optimal_static_system(card)
        elements = list(range(card))
        ok = static_distinguishes(preds, elements)
        print(
            f"|A|={card:>4}: built {len(preds)} predicates "
            f"(= clog2 {card} = {min_distinguishing_depth(card)}), "
            f"separates all? {ok}"
        )
    print()


def demo_lower_bound() -> None:
    print("=" * 70)
    print("3. LOWER BOUND: fewer than d predicates MUST create a twin pair")
    print("=" * 70)
    for card in [5, 9, 100]:
        d = min_distinguishing_depth(card)
        elements = list(range(card))
        too_few = [bit_predicate(i) for i in range(d - 1)]
        ok = static_distinguishes(too_few, elements)
        print(
            f"|A|={card:>4}: with only d-1 = {d - 1} predicates, "
            f"all distinct? {ok}  (must be False -> twins forced)"
        )
    print()


def demo_no_speedup() -> None:
    print("=" * 70)
    print("4. ADAPTIVITY BUYS NO SPEEDUP")
    print("=" * 70)
    for card in [5, 16, 100]:
        d = min_distinguishing_depth(card)
        elements = list(range(card))
        preds = optimal_static_system(card)
        tree = static_to_adaptive(preds)
        static_ok = static_distinguishes(preds, elements)
        adaptive_ok = adaptive_distinguishes(tree, elements)
        print(
            f"|A|={card:>4}: static depth={len(preds)} works={static_ok}; "
            f"adaptive tree depth={tree_depth(tree)} works={adaptive_ok}; "
            f"both = clog2 {card} = {d}"
        )
    print()


def demo_fin100() -> None:
    print("=" * 70)
    print("5. CONCRETE COROLLARY: distinguishing 100 elements costs exactly 7")
    print("=" * 70)
    d = min_distinguishing_depth(100)
    print(f"min_distinguishing_depth(100) = {d}")
    print(f"2^6 = {2**6} < 100 <= {2**7} = 2^7   ->   ceil(log2 100) = 7")
    preds = optimal_static_system(100)
    print(f"7 bit-predicates separate Fin 100? {static_distinguishes(preds, range(100))}")
    print(f"6 bit-predicates separate Fin 100? {static_distinguishes(preds[:6], range(100))}")
    print()


def demo_kary() -> None:
    print("=" * 70)
    print("6. GENERALIZED k-ARY BOUND: need >= clog_k |A| observations")
    print("=" * 70)
    print(f"{'|A|':>6} | {'k=2':>5} | {'k=3':>5} | {'k=10':>5}")
    print("-" * 40)
    for card in [10, 100, 1000, 1000000]:
        print(
            f"{card:>6} | {kary_min_depth(card, 2):>5} | "
            f"{kary_min_depth(card, 3):>5} | {kary_min_depth(card, 10):>5}"
        )
    print("\n(A unary alphabet, k=1, gives clog_1 = 0: it cannot discriminate.)")
    print(f"kary_min_depth(100, 1) = {kary_min_depth(100, 1)}")
    print()


def main() -> None:
    demo_exact_complexity()
    demo_upper_bound()
    demo_lower_bound()
    demo_no_speedup()
    demo_fin100()
    demo_kary()


if __name__ == "__main__":
    main()
