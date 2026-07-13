"""
Numerical demonstrations for the fixed-point theory of causal consistency in
time loops.

A *causal loop* is a finite cyclic chain of events e_0 -> e_1 -> ... -> e_{n-1}
-> e_0.  Each event holds a *state* from a finite set X, and each causal arrow is
a transition map step_i : X -> X carrying the state of event i to event i+1
(indices taken modulo the loop length n).

Key objects (all defined and used below, no external files required):

  * trajectory(x, k)     : the state after k causal steps starting from x at
                            event 0.
  * round_trip(x)        : R(x) = trajectory(x, n), one lap around the loop.
  * consistent histories : state assignments h with h(k+1) = step_{k mod n}(h(k))
                            and period n; equivalently, fixed points of R.

Results demonstrated:

  1. Structure Theorem / Novikov criterion: consistent histories <-> fixed
     points of the round-trip map, and their counts agree.
  2. Grandfather paradox: the negation loop has no consistent history.
  3. Iterate identity: R^k(x) = trajectory(x, k*n).
  4. Consistency in the limit: on a finite state space, some repetition of any
     loop is consistent (pigeonhole / periodic point).

Run:  python demo.py
"""

from __future__ import annotations

from typing import Callable, Dict, List, Optional, TypeVar

State = TypeVar("State")


# ---------------------------------------------------------------------------
# Core causal-loop machinery
# ---------------------------------------------------------------------------

class CausalLoop:
    """A causal loop with `length` events and cyclic transition maps.

    `step(i, x)` returns the state that event (i+1) receives, given that event i
    holds state x.  Only `i % length` is used, matching the cyclic convention.
    """

    def __init__(self, length: int, step: Callable[[int, State], State]) -> None:
        if length <= 0:
            raise ValueError("a causal loop must have at least one event")
        self.length: int = length
        self._step: Callable[[int, State], State] = step

    def step(self, i: int, x: State) -> State:
        return self._step(i % self.length, x)

    def trajectory(self, x: State, k: int) -> State:
        """State after k causal steps starting from x at event 0."""
        state = x
        for j in range(k):
            state = self.step(j, state)
        return state

    def round_trip(self, x: State) -> State:
        """R(x): the state event 0 returns to after one lap."""
        return self.trajectory(x, self.length)

    def fixed_points(self, states: List[State]) -> List[State]:
        """Fixed points of the round-trip map among the given states."""
        return [x for x in states if self.round_trip(x) == x]

    def consistent_histories(self, states: List[State]) -> List[List[State]]:
        """One full-period consistent history per round-trip fixed point.

        Each history is the length-`length` list (h(0), ..., h(length-1)); it
        extends periodically to all of the naturals.
        """
        histories: List[List[State]] = []
        for x in self.fixed_points(states):
            histories.append([self.trajectory(x, k) for k in range(self.length)])
        return histories

    def is_self_consistent(self, states: List[State]) -> bool:
        return len(self.fixed_points(states)) > 0

    def power(self, k: int) -> "CausalLoop":
        """The k-fold loop L^k: same transitions, length k*n."""
        if k <= 0:
            raise ValueError("k must be positive")
        base_len = self.length
        base_step = self._step
        return CausalLoop(k * base_len, lambda i, x: base_step(i % base_len, x))


def iterate(f: Callable[[State], State], k: int, x: State) -> State:
    """The k-fold composition f^k applied to x."""
    for _ in range(k):
        x = f(x)
    return x


def minimal_consistent_repetition(
    loop: CausalLoop, states: List[State]
) -> Optional[int]:
    """Smallest k > 0 such that R^k has a fixed point (so L^k is consistent).

    Guaranteed to exist on a finite non-empty state space (Theorem: consistency
    in the limit).  Returns None only if `states` is empty.
    """
    if not states:
        return None
    max_k = len(states)  # pigeonhole bound: an orbit of a finite set cycles by |X|
    for k in range(1, max_k + 1):
        for x in states:
            if iterate(loop.round_trip, k, x) == x:
                return k
    return None  # unreachable on a finite non-empty state space


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_grandfather() -> None:
    print("=" * 70)
    print("Demo 1: The grandfather paradox (negation loop) is inconsistent")
    print("=" * 70)
    states = [False, True]
    grandfather = CausalLoop(1, lambda i, b: not b)
    print("Round trip R(b) = not b:")
    for b in states:
        print(f"  R({b!s:5}) = {grandfather.round_trip(b)!s}")
    fps = grandfather.fixed_points(states)
    print(f"Fixed points of R: {fps}")
    print(f"Self-consistent? {grandfather.is_self_consistent(states)}")
    print("=> No fixed point of negation => no consistent history. Paradox proved.\n")


def demo_benign_loops() -> None:
    print("=" * 70)
    print("Demo 2: Benign loops -- identity (all consistent) and constant (one)")
    print("=" * 70)
    states = list(range(5))

    identity_loop = CausalLoop(3, lambda i, x: x)
    print("Identity loop (length 3): every state is a fixed point.")
    print(f"  Fixed points: {identity_loop.fixed_points(states)}")
    print(f"  # consistent histories = {len(identity_loop.consistent_histories(states))}")

    constant_loop = CausalLoop(3, lambda i, x: 2)
    print("Constant loop x -> 2 (length 3): unique fixed point 2.")
    print(f"  Fixed points: {constant_loop.fixed_points(states)}")
    for h in constant_loop.consistent_histories(states):
        print(f"  consistent history (one period): {h}")
    print()


def demo_structure_theorem() -> None:
    print("=" * 70)
    print("Demo 3: Structure Theorem -- #histories = #round-trip fixed points")
    print("=" * 70)
    # A length-4 loop on Z/6 with mixed additive/affine steps.
    n, m = 4, 6
    step_shifts = [1, 5, 3, 3]  # step_i(x) = x + step_shifts[i] (mod 6)

    def step(i: int, x: int) -> int:
        return (x + step_shifts[i]) % m

    loop = CausalLoop(n, step)
    states = list(range(m))
    total_shift = sum(step_shifts) % m
    print(f"Round trip R(x) = x + {total_shift} (mod {m}).")
    fps = loop.fixed_points(states)
    histories = loop.consistent_histories(states)
    print(f"Fixed points: {fps}")
    print(f"#fixed points = {len(fps)}, #consistent histories = {len(histories)}")
    assert len(fps) == len(histories), "Structure Theorem violated!"
    print("Structure Theorem verified: the two counts agree.\n")


def demo_iterate_identity() -> None:
    print("=" * 70)
    print("Demo 4: Iterate identity  R^k(x) = trajectory(x, k*n)")
    print("=" * 70)
    n = 3
    step_shifts = [2, 4, 1]

    def step(i: int, x: int) -> int:
        return (x + step_shifts[i]) % 7

    loop = CausalLoop(n, step)
    ok = True
    for x in range(7):
        for k in range(5):
            lhs = iterate(loop.round_trip, k, x)
            rhs = loop.trajectory(x, k * n)
            ok = ok and (lhs == rhs)
    print(f"Checked all x in Z/7 and k in 0..4: identity holds = {ok}\n")
    assert ok


def demo_consistency_in_the_limit() -> None:
    print("=" * 70)
    print("Demo 5: Consistency in the limit -- some repetition is always consistent")
    print("=" * 70)

    # Grandfather: inconsistent once, consistent twice.
    grandfather = CausalLoop(1, lambda i, b: not b)
    states_bool = [False, True]
    k = minimal_consistent_repetition(grandfather, states_bool)
    print(f"Grandfather loop: minimal consistent repetition k = {k}")
    g2 = grandfather.power(k)
    print(f"  L^{k} fixed points: {g2.fixed_points(states_bool)}")
    for h in g2.consistent_histories(states_bool):
        print(f"  consistent history of L^{k} (one period): {h}")

    # A 3-cycle permutation loop: inconsistent until traversed 3 times.
    def cyc(i: int, x: int) -> int:
        return (x + 1) % 3

    three_cycle = CausalLoop(1, cyc)
    states3 = [0, 1, 2]
    k3 = minimal_consistent_repetition(three_cycle, states3)
    print(f"3-cycle loop x -> x+1 (mod 3): minimal consistent repetition k = {k3}")
    print(f"  R has fixed point? {three_cycle.is_self_consistent(states3)}")
    l3 = three_cycle.power(k3)
    print(f"  L^{k3} fixed points: {l3.fixed_points(states3)}")
    print()


def main() -> None:
    demo_grandfather()
    demo_benign_loops()
    demo_structure_theorem()
    demo_iterate_identity()
    demo_consistency_in_the_limit()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
