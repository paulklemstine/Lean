"""
algorithm.py
================================================================================
Algorithm: Depth-bounded partition refinement for the behavior congruence.

Given an algebraic neural observation system N over a finite state sample, this
computes the behavior-congruence classes (equivalently: the kernel of the
observation pseudometric obsDist, equivalently: the proof-spectrum congruence
behaviorCongruence) by Hopcroft-style refinement.

Mathematical foundation
-----------------------
behaviorCongruence is the intersection of the depth filtration ~_k:
    x ~ y  <=>  for all k, x ~_k y.
The filtration is monotone (~_{k+1} refines ~_k), so iterating the one-step
refinement until the partition stabilizes yields the exact congruence on any
behaviorally-finite system. Because each layer is a semiring map, the resulting
partition is a *semiring congruence*, not merely an equivalence relation.

Complexity
----------
With |S| sampled states and |A| input symbols, one refinement round computes the
read-out signature of each state plus, per symbol, the class index of its
successor: O(|S| * |A|). The number of rounds is bounded by the number of final
classes, at most |S|. Total: O(|S|^2 * |A|) signature comparisons, matching
classical Moore/Hopcroft partition refinement.
"""

from __future__ import annotations

from typing import Callable, Dict, Hashable, List, Tuple, TypeVar

State = TypeVar("State", bound=Hashable)
Symbol = TypeVar("Symbol")
Output = Hashable


def partition_refine(
    states: List[State],
    symbols: List[Symbol],
    step: Callable[[State, Symbol], State],
    observe: Callable[[State], Output],
) -> Dict[State, int]:
    """
    Compute behavior-congruence class indices for each state.

    Returns a dict mapping each state to an integer class id; two states share an
    id iff they are behaviorally equivalent (obsDist = 0).
    """
    # Close the sample under `step` so successors are always classified
    # (refinement operates on the reachable sub-system).
    closure: List[State] = list(dict.fromkeys(states))
    seen = set(closure)
    frontier = list(closure)
    while frontier:
        nxt: List[State] = []
        for s in frontier:
            for a in symbols:
                t = step(s, a)
                if t not in seen:
                    seen.add(t)
                    closure.append(t)
                    nxt.append(t)
        frontier = nxt
    states = closure

    # Round 0: classify purely by the read-out (depth-0 distinguishability).
    cls: Dict[State, int] = {}
    sig0: Dict[Output, int] = {}
    for s in states:
        key = observe(s)
        if key not in sig0:
            sig0[key] = len(sig0)
        cls[s] = sig0[key]

    # Refine until the number of classes stabilizes.
    while True:
        signatures: Dict[Tuple, int] = {}
        new_cls: Dict[State, int] = {}
        for s in states:
            # Signature = own class plus the class of each one-step successor.
            sig: Tuple = (cls[s],) + tuple(cls[step(s, a)] for a in symbols)
            if sig not in signatures:
                signatures[sig] = len(signatures)
            new_cls[s] = signatures[sig]
        if len(signatures) == len(set(cls.values())):
            return new_cls  # stabilized: this is the behavior congruence
        cls = new_cls


def congruence_kernel(
    states: List[State],
    symbols: List[Symbol],
    step: Callable[[State, Symbol], State],
    observe: Callable[[State], Output],
) -> List[Tuple[State, State]]:
    """Return the set of congruent (distance-zero) ordered pairs."""
    cls = partition_refine(states, symbols, step, observe)
    return [(x, y) for x in states for y in states if cls[x] == cls[y]]


if __name__ == "__main__":
    # Shift-register algebraic neural system on Z^4, read-out = coordinate 0.
    def make_step():
        sel = {0: [1, 2, 3, 3], 1: [0, 1, 2, 3]}
        return lambda s, a: tuple(s[j] for j in sel[a])

    step_fn = make_step()
    observe_fn = lambda s: s[0]
    states = [(1, 1, 1, 1), (1, 1, 1, 2), (1, 1, 2, 2),
              (1, 2, 2, 2), (2, 2, 2, 2), (1, 2, 3, 4)]
    symbols = [0, 1]

    classes = partition_refine(states, symbols, step_fn, observe_fn)
    print("Behavior-congruence classes:")
    for s in states:
        print(f"  {s} -> class {classes[s]}")
    print(f"Number of classes: {len(set(classes.values()))}")
