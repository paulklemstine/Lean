#!/usr/bin/env python3
"""
Distinguishing experiments for deterministic Moore machines
===========================================================

Numerical demonstrations of the following results.

  * Product bound.  Behaviourally inequivalent initial states of Moore machines with
    state sets S and T are separated by an input word of length < |S| * |T|.

  * Moore bound.  In fact they are separated by a word of length <= |S| + |T| - 2.

  * Extremality.  For every pair of sizes (n, m) there are one-letter machines with
    n and m states whose shortest separating word has length exactly n + m - 2
    (a saturating "tail" raced against a pure "cycle").

  * Complete finite test suite.  Equivalence is exactly agreement on all words of
    length <= |S| + |T| - 2, a set of at most (|A| + 1)^(|S| + |T| - 2) words.

  * No finite test suite for arbitrary behaviours.  For any finite set W of test
    words there are two behaviours that agree on all of W yet differ somewhere.

Everything is self-contained: no imports beyond the standard library.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import random
from collections import deque
from dataclasses import dataclass
from typing import Callable, Dict, Hashable, Iterable, List, Optional, Sequence, Tuple

State = Hashable
Symbol = Hashable
Word = Tuple[Symbol, ...]


# ---------------------------------------------------------------------------
# The model
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Machine:
    """A deterministic Moore machine.

    states   : the (finite) state set
    alphabet : the (finite) input alphabet
    step     : transition function (state, symbol) -> state
    out      : output function state -> observation
    """

    states: Tuple[State, ...]
    alphabet: Tuple[Symbol, ...]
    step: Callable[[State, Symbol], State]
    out: Callable[[State], Hashable]

    def run(self, s: State, w: Sequence[Symbol]) -> State:
        """Run the machine from state `s` along the word `w`."""
        for a in w:
            s = self.step(s, a)
        return s

    def obs(self, s: State, w: Sequence[Symbol]) -> Hashable:
        """The observation produced by running from `s` along `w`."""
        return self.out(self.run(s, w))


# ---------------------------------------------------------------------------
# Algorithms
# ---------------------------------------------------------------------------


def words_up_to(alphabet: Sequence[Symbol], k: int) -> List[Word]:
    """All words of length at most k. Cardinality is bounded by (|A| + 1)^k."""
    out: List[Word] = []
    for length in range(k + 1):
        out.extend(itertools.product(alphabet, repeat=length))
    return out


def agree_up_to(m: Machine, n: Machine, k: int, s: State, t: State) -> bool:
    """Decide `agreement on all words of length <= k` by the backward recursion

        E_0(s,t)     <=>  out_M(s) = out_N(t)
        E_{k+1}(s,t) <=>  out_M(s) = out_N(t) and for all a, E_k(step(s,a), step(t,a)).

    This is the direct, memo-free reading of the bounded-agreement recursion; it is
    exponential in k but uses no space beyond the recursion stack.
    """
    if m.out(s) != n.out(t):
        return False
    if k == 0:
        return True
    return all(
        agree_up_to(m, n, k - 1, m.step(s, a), n.step(t, a)) for a in m.alphabet
    )


def shortest_distinguishing_word(
    m: Machine, n: Machine, s: State, t: State
) -> Optional[Word]:
    """Return a shortest separating word, or None if the states are equivalent.

    Breadth-first search in the product graph on (state of M) x (state of N).
    The first reached pair with differing outputs is reached along a shortest path,
    so the reconstructed word is a shortest separating word.
    Complexity: O(|A| * |S| * |T|).
    """
    start = (s, t)
    parent: Dict[Tuple[State, State], Optional[Tuple[Tuple[State, State], Symbol]]] = {
        start: None
    }
    queue: deque = deque([start])
    while queue:
        x, y = queue.popleft()
        if m.out(x) != n.out(y):
            # reconstruct
            word: List[Symbol] = []
            cur: Tuple[State, State] = (x, y)
            while parent[cur] is not None:
                prev, sym = parent[cur]  # type: ignore[misc]
                word.append(sym)
                cur = prev
            return tuple(reversed(word))
        for a in m.alphabet:
            nxt = (m.step(x, a), n.step(y, a))
            if nxt not in parent:
                parent[nxt] = ((x, y), a)
                queue.append(nxt)
    return None


def distinguishability_levels(
    m: Machine, n: Machine
) -> List[Dict[Tuple[State, State], bool]]:
    """The increasing chain D_0 <= D_1 <= ... of `distinguishable within k steps`
    relations on the product state set, computed until it stabilises.

    Returns the list of levels [D_0, D_1, ..., D_K] where D_K = D_{K-1}.
    By the saturation lemma the chain is frozen from D_{K-1} onward, and by the
    product bound K - 1 < |S| * |T|.
    """
    pairs = [(x, y) for x in m.states for y in n.states]
    level: Dict[Tuple[State, State], bool] = {
        p: m.out(p[0]) != n.out(p[1]) for p in pairs
    }
    chain = [dict(level)]
    while True:
        nxt = {
            p: level[p]
            or any(level[(m.step(p[0], a), n.step(p[1], a))] for a in m.alphabet)
            for p in pairs
        }
        chain.append(dict(nxt))
        if nxt == level:
            return chain
        level = nxt


def equivalent_by_suite(m: Machine, n: Machine, s: State, t: State) -> bool:
    """Decide equivalence by running the canonical finite test suite: all words of
    length at most |S| + |T| - 2."""
    k = max(0, len(m.states) + len(n.states) - 2)
    return all(m.obs(s, w) == n.obs(t, w) for w in words_up_to(m.alphabet, k))


# ---------------------------------------------------------------------------
# Concrete machine families
# ---------------------------------------------------------------------------


def counter_machine(n: int) -> Machine:
    """Saturating counter on {0, ..., n} over a one-letter alphabet; the output is
    True exactly in the top state n."""
    return Machine(
        states=tuple(range(n + 1)),
        alphabet=("*",),
        step=lambda i, _a: min(i + 1, n),
        out=lambda i: i == n,
    )


def sink_machine() -> Machine:
    """The one-state machine that always outputs False."""
    return Machine(states=(0,), alphabet=("*",), step=lambda _s, _a: 0, out=lambda _s: False)


def residue(n_prime: int, m_prime: int) -> int:
    """The residue at which the extremal cycle machine fires."""
    return (n_prime + m_prime) % (m_prime + 1)


def tail_machine(n_prime: int, m_prime: int) -> Machine:
    """Saturating chain of n' + 1 states; below the top it copies the cycle's output,
    at the top state it outputs False."""
    r = residue(n_prime, m_prime)
    return Machine(
        states=tuple(range(n_prime + 1)),
        alphabet=("*",),
        step=lambda i, _a: min(i + 1, n_prime),
        out=lambda i: i < n_prime and i % (m_prime + 1) == r,
    )


def cycle_machine(n_prime: int, m_prime: int) -> Machine:
    """Cycle of m' + 1 states outputting True exactly at the residue r."""
    r = residue(n_prime, m_prime)
    return Machine(
        states=tuple(range(m_prime + 1)),
        alphabet=("*",),
        step=lambda j, _a: (j + 1) % (m_prime + 1),
        out=lambda j: j == r,
    )


def random_machine(num_states: int, alphabet: Sequence[Symbol], rng: random.Random) -> Machine:
    """A uniformly random Moore machine with Boolean outputs."""
    table = {
        (i, a): rng.randrange(num_states) for i in range(num_states) for a in alphabet
    }
    outputs = {i: rng.random() < 0.5 for i in range(num_states)}
    return Machine(
        states=tuple(range(num_states)),
        alphabet=tuple(alphabet),
        step=lambda i, a: table[(i, a)],
        out=lambda i: outputs[i],
    )


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_counter_family() -> None:
    banner("1.  The saturating counter: both bounds are attained")
    print(f"{'n':>3} {'|S|':>4} {'|T|':>4} {'shortest':>9} {'|S|+|T|-2':>10} {'|S|*|T|-1':>10}")
    for n in range(0, 8):
        m = counter_machine(n)
        sink = sink_machine()
        w = shortest_distinguishing_word(m, sink, 0, 0)
        assert w is not None
        s_card, t_card = len(m.states), len(sink.states)
        moore = s_card + t_card - 2
        prod = s_card * t_card - 1
        assert len(w) == moore == prod == n
        print(f"{n:>3} {s_card:>4} {t_card:>4} {len(w):>9} {moore:>10} {prod:>10}")
    print("The shortest experiment has length exactly n for every n: no bound that is")
    print("independent of the state counts can exist.")


def demo_extremal_family() -> None:
    banner("2.  The extremal tail-vs-cycle family: |S| + |T| - 2 for every pair of sizes")
    print(f"{'|S|':>4} {'|T|':>4} {'r':>3} {'shortest':>9} {'bound':>6}  behaviour prefix")
    for n_prime in range(0, 5):
        for m_prime in range(0, 5):
            tail = tail_machine(n_prime, m_prime)
            cyc = cycle_machine(n_prime, m_prime)
            w = shortest_distinguishing_word(tail, cyc, 0, 0)
            assert w is not None
            n, m = len(tail.states), len(cyc.states)
            bound = n + m - 2
            assert len(w) == bound, (n, m, len(w), bound)
            prefix = "".join(
                "1" if tail.obs(0, ("*",) * l) else "0" for l in range(bound + 2)
            )
            prefix2 = "".join(
                "1" if cyc.obs(0, ("*",) * l) else "0" for l in range(bound + 2)
            )
            print(
                f"{n:>4} {m:>4} {residue(n_prime, m_prime):>3} {len(w):>9} {bound:>6}"
                f"  tail={prefix}  cycle={prefix2}"
            )
    print("The two behaviour prefixes agree up to position |S|+|T|-3 and first differ")
    print("at position |S|+|T|-2 (0-indexed), exactly as predicted.")


def demo_levels() -> None:
    banner("3.  The distinguishability chain saturates")
    tail, cyc = tail_machine(3, 2), cycle_machine(3, 2)
    chain = distinguishability_levels(tail, cyc)
    print(f"|S| = {len(tail.states)}, |T| = {len(cyc.states)}, "
          f"product size = {len(tail.states) * len(cyc.states)}")
    for k, level in enumerate(chain):
        marked = sorted(p for p, v in level.items() if v)
        print(f"  D_{k}: {len(marked):>2} distinguishable pairs  {marked}")
    print("Once a level repeats, the chain is frozen forever (saturation), so the")
    print("index at which it freezes bounds every shortest separating word.")


def demo_test_suite() -> None:
    banner("4.  The canonical finite test suite is complete")
    alphabet = ("a", "b")
    k = 3 + 3 - 2  # |S| + |T| - 2 for two 3-state machines
    suite = words_up_to(alphabet, k)
    print(f"alphabet size {len(alphabet)}, k = |S|+|T|-2 = {k}: |W_k| = {len(suite)} "
          f"<= (|A|+1)^k = {(len(alphabet) + 1) ** k}")
    rng = random.Random(20260821)
    agreements = 0
    trials = 400
    for _ in range(trials):
        m = random_machine(3, alphabet, rng)
        n = random_machine(3, alphabet, rng)
        by_suite = equivalent_by_suite(m, n, 0, 0)
        by_bfs = shortest_distinguishing_word(m, n, 0, 0) is None
        assert by_suite == by_bfs
        agreements += 1
    print(f"{agreements}/{trials} random 3-state pairs: the finite suite and the exact")
    print("product-BFS decision procedure always agree.")


def demo_random_bound_check() -> None:
    banner("5.  Random machines never exceed the Moore bound")
    rng = random.Random(1729)
    alphabets = [("a",), ("a", "b"), ("a", "b", "c")]
    print(f"{'|A|':>4} {'|S|':>4} {'|T|':>4} {'trials':>7} {'max len':>8} {'bound':>6} "
          f"{'prod bound':>11}")
    for alphabet in alphabets:
        for ns in (2, 3, 4, 5):
            for nt in (2, 3, 4, 5):
                worst = -1
                trials = 300
                for _ in range(trials):
                    m = random_machine(ns, alphabet, rng)
                    n = random_machine(nt, alphabet, rng)
                    w = shortest_distinguishing_word(m, n, 0, 0)
                    if w is not None:
                        worst = max(worst, len(w))
                bound = ns + nt - 2
                assert worst <= bound
                print(f"{len(alphabet):>4} {ns:>4} {nt:>4} {trials:>7} {worst:>8} "
                      f"{bound:>6} {ns * nt - 1:>11}")
    print("Every observed shortest separating word obeys |w| <= |S| + |T| - 2, which is")
    print("itself strictly below the product bound |S| * |T|.")


def demo_recursion_matches_bfs() -> None:
    banner("6.  Bounded-agreement recursion agrees with the product search")
    alphabet = ("a", "b")
    rng = random.Random(31337)
    checked = 0
    for _ in range(150):
        m = random_machine(3, alphabet, rng)
        n = random_machine(2, alphabet, rng)
        w = shortest_distinguishing_word(m, n, 0, 0)
        bound = len(m.states) + len(n.states) - 2
        for k in range(bound + 1):
            expected = (w is None) or (len(w) > k)
            assert agree_up_to(m, n, k, 0, 0) == expected
            checked += 1
    print(f"{checked} independent checks passed: the recursion")
    print("  E_0 = 'outputs equal',  E_{k+1} = E_0 and (for all a) E_k at the successors")
    print("computes exactly 'no separating word of length <= k'.")


def demo_no_finite_test() -> None:
    banner("7.  No finite test suite works for arbitrary behaviours")
    alphabet = ("a", "b")
    for k in range(0, 4):
        suite = words_up_to(alphabet, k)
        longest = max((len(w) for w in suite), default=0)
        u = ("a",) * (longest + 1)
        f: Callable[[Word], bool] = lambda _w: False
        g: Callable[[Word], bool] = lambda w, u=u: w == u  # type: ignore[misc]
        assert all(f(w) == g(w) for w in suite)
        assert f(u) != g(u)
        print(
            f"  suite of all words with |w| <= {k} ({len(suite):>2} tests): "
            f"defeated by the behaviour that fires only at {''.join(u)!r}"
        )
    print("For every finite suite there are two behaviours passing every test yet")
    print("differing somewhere: finiteness of the state set is exactly what rescues")
    print("the positive result.")


def demo_suite_size() -> None:
    banner("8.  Size of the canonical test suite")
    print(f"{'|A|':>4} {'|S|':>4} {'|T|':>4} {'k=|S|+|T|-2':>12} {'|W_k|':>9} "
          f"{'(|A|+1)^k':>12}")
    for a in (1, 2, 3):
        for ns, nt in ((2, 2), (3, 2), (3, 3), (4, 3), (5, 4)):
            k = ns + nt - 2
            alphabet = tuple("abc"[:a])
            exact = sum(a ** length for length in range(k + 1))
            print(f"{a:>4} {ns:>4} {nt:>4} {k:>12} {exact:>9} {(a + 1) ** k:>12}")
    print("The suite is exponential in the state counts but explicit, structure-")
    print("independent, and provably complete for the whole size class.")


def main() -> None:
    print(__doc__)
    demo_counter_family()
    demo_extremal_family()
    demo_levels()
    demo_test_suite()
    demo_random_bound_check()
    demo_recursion_matches_bfs()
    demo_no_finite_test()
    demo_suite_size()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
