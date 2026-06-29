"""
The Adaptive Observation Gap — numerical demonstrations.

This self-contained script illustrates, with concrete numbers, the main results
of the static and adaptive observation theory:

  * Observation Pigeonhole (static):  |alpha| > 2**n  =>  a twin pair exists.
  * Quotient Bound:                   #classes <= 2**n.
  * Sufficiency Boundary:             |alpha| = 2**n  =>  full separation by bit
                                      extraction.
  * Adaptive model (decision trees):  transcripts live in {0,1}**n, so the SAME
                                      2**n ceiling holds for adaptive systems.
  * The bridge:                       a static system equals the "lazy" decision
                                      tree that ignores its answers.

Every function is inlined; the script has no third-party dependencies and runs
under any standard Python 3 interpreter:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, List, Optional, Tuple, Union

# ---------------------------------------------------------------------------
# Static observation systems
# ---------------------------------------------------------------------------

Predicate = Callable[[int], bool]          # a Boolean test on a state (an int)
Profile = Tuple[bool, ...]                  # length-n tuple of answers


def profile(preds: List[Predicate], state: int) -> Profile:
    """The observation profile of `state`: the tuple of all predicate values."""
    return tuple(p(state) for p in preds)


def find_twin_pair(
    preds: List[Predicate], states: List[int]
) -> Optional[Tuple[int, int]]:
    """Return a pair of distinct states with identical profiles, or None.

    By the Observation Pigeonhole Theorem, when len(states) > 2**len(preds)
    such a pair is *guaranteed* to exist.
    """
    seen: Dict[Profile, int] = {}
    for s in states:
        sig = profile(preds, s)
        if sig in seen and seen[sig] != s:
            return (seen[sig], s)
        seen.setdefault(sig, s)
    return None


def quotient_size(preds: List[Predicate], states: List[int]) -> int:
    """Number of observational equivalence classes (distinct profiles)."""
    return len({profile(preds, s) for s in states})


def bit_extraction_system(n: int) -> List[Predicate]:
    """The optimal separator on Fin(2**n): predicate i asks 'is bit i set?'."""
    return [(lambda i: (lambda a: bool((a >> i) & 1)))(i) for i in range(n)]


# ---------------------------------------------------------------------------
# Adaptive observation systems (binary decision trees)
# ---------------------------------------------------------------------------

@dataclass
class Nil:
    """The empty interrogation: depth-0 adaptive system."""


@dataclass
class Node:
    """Ask `pred`; continue with `if_false` or `if_true` based on the answer."""
    pred: Predicate
    if_false: "AdaptiveObs"
    if_true: "AdaptiveObs"


AdaptiveObs = Union[Nil, Node]


def transcript(tree: AdaptiveObs, state: int) -> Profile:
    """Run `tree` on `state`, returning the length-n answer transcript.

    The transcript ALWAYS has length = depth of the tree and lies in {0,1}**n,
    regardless of how the tree branches -- this is why adaptivity cannot beat
    the 2**n ceiling.
    """
    answers: List[bool] = []
    node = tree
    while isinstance(node, Node):
        b = node.pred(state)
        answers.append(b)
        node = node.if_true if b else node.if_false
    return tuple(answers)


def of_preds(preds: List[Predicate]) -> AdaptiveObs:
    """The 'lazy' decision tree from a static predicate family.

    It asks preds[0], preds[1], ... in order, ignoring every answer.  Theorem
    (transcript preservation): transcript(of_preds(P), a) == profile(P, a).
    """
    if not preds:
        return Nil()
    head, tail = preds[0], preds[1:]
    sub = of_preds(tail)
    return Node(pred=head, if_false=sub, if_true=sub)


def balanced_tree(depth: int) -> AdaptiveObs:
    """Adaptive bit-extraction tree separating all 2**depth states."""
    return of_preds(bit_extraction_system(depth))


def adaptive_quotient_size(tree: AdaptiveObs, states: List[int]) -> int:
    """Number of adaptive equivalence classes (distinct transcripts)."""
    return len({transcript(tree, s) for s in states})


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_pigeonhole() -> None:
    print("=" * 68)
    print("DEMO 1  Observation Pigeonhole: more than 2**n states force twins")
    print("=" * 68)
    n = 3                      # 3 predicates  ->  ceiling 2**3 = 8
    states = list(range(9))    # 9 > 8, so a twin pair is GUARANTEED
    # Three arbitrary predicates (not the optimal separator):
    preds: List[Predicate] = [
        lambda a: a % 2 == 0,
        lambda a: a % 3 == 0,
        lambda a: a >= 5,
    ]
    print(f"  states = {states}   (|alpha| = {len(states)})")
    print(f"  n = {n} predicates  ->  ceiling 2**n = {2 ** n}")
    pair = find_twin_pair(preds, states)
    print(f"  twin pair found: {pair}")
    if pair is not None:
        a, b = pair
        print(f"  profile({a}) = {profile(preds, a)}")
        print(f"  profile({b}) = {profile(preds, b)}  ->  indistinguishable")
    print()


def demo_quotient_bound() -> None:
    print("=" * 68)
    print("DEMO 2  Quotient Bound: #classes <= 2**n always")
    print("=" * 68)
    n = 3
    states = list(range(20))
    preds: List[Predicate] = [
        lambda a: a % 2 == 0,
        lambda a: a % 3 == 0,
        lambda a: a >= 5,
    ]
    q = quotient_size(preds, states)
    print(f"  |alpha| = {len(states)}, n = {n}, ceiling 2**n = {2 ** n}")
    print(f"  distinguishable classes = {q}   (<= {2 ** n}: "
          f"{q <= 2 ** n})")
    print()


def demo_sufficiency() -> None:
    print("=" * 68)
    print("DEMO 3  Sufficiency Boundary: |alpha| = 2**n is fully separable")
    print("=" * 68)
    n = 4
    size = 2 ** n
    states = list(range(size))
    preds = bit_extraction_system(n)
    q = quotient_size(preds, states)
    print(f"  alpha = Fin({size}),  n = {n} bit-extraction predicates")
    print(f"  distinct profiles = {q}  (== |alpha| = {size}: {q == size})")
    print(f"  every state separated: {q == size}")
    # show that profiles are exactly the binary expansions
    sample = [profile(preds, s) for s in range(4)]
    for s, sig in enumerate(sample):
        bits = "".join("1" if b else "0" for b in sig)
        print(f"    state {s}: profile bits (LSB first) = {bits}")
    print()


def demo_adaptive_equals_static() -> None:
    print("=" * 68)
    print("DEMO 4  Adaptivity buys nothing: same 2**n ceiling")
    print("=" * 68)
    n = 3
    states = list(range(9))    # 9 > 8 again
    # A genuinely ADAPTIVE tree: the second/third questions depend on answers.
    tree = Node(
        pred=lambda a: a >= 4,
        if_false=Node(                       # branch for "small" states
            pred=lambda a: a % 2 == 0,
            if_false=Node(lambda a: a == 1, Nil(), Nil()),
            if_true=Node(lambda a: a == 0, Nil(), Nil()),
        ),
        if_true=Node(                        # branch for "large" states
            pred=lambda a: a % 2 == 0,
            if_false=Node(lambda a: a == 5, Nil(), Nil()),
            if_true=Node(lambda a: a == 4, Nil(), Nil()),
        ),
    )
    transcripts = {s: transcript(tree, s) for s in states}
    classes = len(set(transcripts.values()))
    # find an adaptive twin pair
    seen: Dict[Profile, int] = {}
    twin: Optional[Tuple[int, int]] = None
    for s in states:
        t = transcripts[s]
        if t in seen:
            twin = (seen[t], s)
            break
        seen[t] = s
    print(f"  adaptive depth n = {n}, |alpha| = {len(states)} > 2**n = {2**n}")
    print(f"  distinct transcripts = {classes}  (<= {2 ** n}: "
          f"{classes <= 2 ** n})")
    print(f"  adaptive twin pair: {twin}")
    if twin is not None:
        a, b = twin
        print(f"    transcript({a}) = {transcripts[a]}")
        print(f"    transcript({b}) = {transcripts[b]}  ->  indistinguishable")
    print()


def demo_bridge() -> None:
    print("=" * 68)
    print("DEMO 5  The bridge: static profile == lazy-tree transcript")
    print("=" * 68)
    n = 4
    preds = bit_extraction_system(n)
    lazy = of_preds(preds)
    states = list(range(2 ** n))
    ok = all(profile(preds, s) == transcript(lazy, s) for s in states)
    print(f"  for all {len(states)} states: profile == transcript ?  {ok}")
    # adaptive separation matches static separation at the boundary
    qa = adaptive_quotient_size(balanced_tree(n), states)
    print(f"  balanced adaptive tree separates all {2 ** n} states: "
          f"{qa == 2 ** n}")
    print()


def demo_complexity_table() -> None:
    print("=" * 68)
    print("DEMO 6  Observation complexity = ceil(log2 |alpha|)")
    print("=" * 68)
    print("  |alpha|  minimal n (static = adaptive)")
    for size in [1, 2, 3, 4, 5, 8, 9, 16, 17, 100, 1000]:
        # smallest n with 2**n >= size
        n = 0
        while 2 ** n < size:
            n += 1
        print(f"  {size:>6}   {n}")
    print()


def main() -> None:
    demo_pigeonhole()
    demo_quotient_bound()
    demo_sufficiency()
    demo_adaptive_equals_static()
    demo_bridge()
    demo_complexity_table()
    print("All demonstrations complete: adaptivity never beats the 2**n ceiling.")


if __name__ == "__main__":
    main()
