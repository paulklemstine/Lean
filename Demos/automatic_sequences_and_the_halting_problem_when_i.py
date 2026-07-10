"""
Decidability of Value-Occurrence Problems for Automatic Sequences
=================================================================

Self-contained numerical demonstration of the results:

  * Reachability bound        : L(M) != empty  <=>  exists x in L(M), |x| < s
  * Decidability of emptiness : the "zero-in-sequence" (halting) problem
  * Pumping dichotomy         : L(M) infinite   <=>  exists x in L(M), |x| >= s
  * Bounded infinitude window : witnessed by |x| in [s, 2s)
  * Thue-Morse automaton      : nonempty & infinite; recurrences t(2n), t(2n+1)
  * Folklore correction       : a nonempty DFA language can be finite (a single word)

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Callable, Dict, Hashable, Iterable, Iterator, List, Optional, Tuple

State = Hashable
Symbol = Hashable


# --------------------------------------------------------------------------- #
#  Deterministic finite automaton                                             #
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class DFA:
    """A deterministic finite automaton over a finite alphabet."""

    states: Tuple[State, ...]
    alphabet: Tuple[Symbol, ...]
    step: Callable[[State, Symbol], State]
    start: State
    accept: frozenset

    @property
    def num_states(self) -> int:
        return len(self.states)

    def eval(self, word: Iterable[Symbol]) -> State:
        """State reached from `start` after reading `word`."""
        s = self.start
        for a in word:
            s = self.step(s, a)
        return s

    def accepts(self, word: Iterable[Symbol]) -> bool:
        return self.eval(word) in self.accept


def words_of_length(alphabet: Tuple[Symbol, ...], length: int) -> Iterator[Tuple[Symbol, ...]]:
    """All words of the given exact length over the alphabet."""
    yield from product(alphabet, repeat=length)


def words_up_to_length(alphabet: Tuple[Symbol, ...], length: int) -> Iterator[Tuple[Symbol, ...]]:
    """All words of length 0, 1, ..., length-1."""
    for ell in range(length):
        yield from words_of_length(alphabet, ell)


# --------------------------------------------------------------------------- #
#  Algorithm A: decide nonemptiness (zero-in-sequence / halting)              #
# --------------------------------------------------------------------------- #
def decide_nonempty(dfa: DFA) -> Tuple[bool, Optional[Tuple[Symbol, ...]]]:
    """
    Decide whether L(M) is nonempty by the Reachability Bound: search all
    words of length < number of states.  Returns (answer, witness).
    """
    s = dfa.num_states
    for word in words_up_to_length(dfa.alphabet, s):
        if dfa.accepts(word):
            return True, word
    return False, None


# --------------------------------------------------------------------------- #
#  Algorithm B: decide infinitude (zero-infinitely-often)                     #
# --------------------------------------------------------------------------- #
def decide_infinite(dfa: DFA) -> Tuple[bool, Optional[Tuple[Symbol, ...]]]:
    """
    Decide whether L(M) is infinite by the Bounded Infinitude Criterion:
    search words with length in the window [s, 2s).  Returns (answer, witness).
    """
    s = dfa.num_states
    for length in range(s, 2 * s):
        for word in words_of_length(dfa.alphabet, length):
            if dfa.accepts(word):
                return True, word
    return False, None


# --------------------------------------------------------------------------- #
#  Cross-check by explicit graph reachability (independent of pumping search) #
# --------------------------------------------------------------------------- #
def reachable_states(dfa: DFA) -> frozenset:
    seen = {dfa.start}
    frontier = [dfa.start]
    while frontier:
        s = frontier.pop()
        for a in dfa.alphabet:
            t = dfa.step(s, a)
            if t not in seen:
                seen.add(t)
                frontier.append(t)
    return frozenset(seen)


def nonempty_by_reachability(dfa: DFA) -> bool:
    return bool(reachable_states(dfa) & dfa.accept)


def infinite_by_cycle(dfa: DFA) -> bool:
    """
    L(M) is infinite iff there is a cycle that is reachable from the start
    and from which an accepting state can be reached.  Detected by DFS on the
    subgraph induced by reachable & co-reachable-to-accept states.
    """
    reach = reachable_states(dfa)
    # co-reachable: states from which some accept state is reachable
    rev: Dict[State, List[State]] = {s: [] for s in dfa.states}
    for s in dfa.states:
        for a in dfa.alphabet:
            rev[dfa.step(s, a)].append(s)
    co = set(t for t in dfa.accept)
    frontier = list(co)
    while frontier:
        s = frontier.pop()
        for p in rev[s]:
            if p not in co:
                co.add(p)
                frontier.append(p)
    live = reach & frozenset(co)
    # cycle detection within `live`
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {s: WHITE for s in live}

    def dfs(u: State) -> bool:
        color[u] = GRAY
        for a in dfa.alphabet:
            v = dfa.step(u, a)
            if v in live:
                if color[v] == GRAY:
                    return True
                if color[v] == WHITE and dfs(v):
                    return True
        color[u] = BLACK
        return False

    return any(color[u] == WHITE and dfs(u) for u in live)


# --------------------------------------------------------------------------- #
#  Concrete automata                                                          #
# --------------------------------------------------------------------------- #
def parity_dfa() -> DFA:
    """Two-state Thue-Morse parity automaton over the binary alphabet."""
    return DFA(
        states=(0, 1),                       # 0 = even, 1 = odd
        alphabet=(0, 1),
        step=lambda s, a: s ^ a,             # XOR
        start=0,
        accept=frozenset({1}),               # accept odd digit-sum
    )


def single_word_dfa(word: Tuple[int, ...]) -> DFA:
    """
    A DFA over {0,1} accepting exactly the one word `word` (plus a dead state).
    Demonstrates: nonempty language that is FINITE (folklore correction).
    """
    n = len(word)
    dead = n + 1
    states = tuple(range(n + 2))             # 0..n are prefix positions, dead

    def step(s: State, a: Symbol) -> State:
        if s == dead:
            return dead
        if s < n and a == word[s]:
            return s + 1
        return dead

    return DFA(states=states, alphabet=(0, 1), step=step, start=0, accept=frozenset({n}))


def empty_dfa() -> DFA:
    """A DFA whose language is empty (no accepting state reachable)."""
    return DFA(states=(0,), alphabet=(0, 1), step=lambda s, a: 0, start=0, accept=frozenset())


# --------------------------------------------------------------------------- #
#  Thue-Morse sequence and its automatic recurrences                          #
# --------------------------------------------------------------------------- #
def thue_morse(n: int) -> int:
    """t(n) = parity of the number of 1s in the binary expansion of n."""
    return bin(n).count("1") % 2


def verify_tm_recurrences(bound: int = 2000) -> bool:
    """Check t(2n) = t(n) and t(2n+1) = t(n) + 1 (mod 2) for n < bound."""
    for n in range(bound):
        if thue_morse(2 * n) != thue_morse(n):
            return False
        if thue_morse(2 * n + 1) != (thue_morse(n) + 1) % 2:
            return False
        if thue_morse(2 * n) == thue_morse(2 * n + 1):
            return False
    return True


# --------------------------------------------------------------------------- #
#  Random-ish battery: 100 test automata, cross-validate the two methods      #
# --------------------------------------------------------------------------- #
def random_dfa(seed: int, max_states: int = 5) -> DFA:
    """Deterministic pseudo-random DFA generator (no external deps)."""
    rng = seed
    def nxt(mod: int) -> int:
        nonlocal rng
        rng = (1103515245 * rng + 12345) & 0x7FFFFFFF
        return rng % mod

    n = 1 + nxt(max_states)
    states = tuple(range(n))
    table = {(s, a): nxt(n) for s in states for a in (0, 1)}
    accept = frozenset(s for s in states if nxt(2) == 0)
    return DFA(states=states, alphabet=(0, 1),
               step=lambda s, a: table[(s, a)], start=0, accept=accept)


def battery(trials: int = 100) -> Tuple[int, int]:
    """
    Cross-validate pumping-search decisions against graph-reachability
    decisions on `trials` pseudo-random automata.  Returns (agreements_ne,
    agreements_inf); both should equal `trials`.
    """
    agree_ne = agree_inf = 0
    for seed in range(1, trials + 1):
        dfa = random_dfa(seed)
        ne_search, _ = decide_nonempty(dfa)
        ne_graph = nonempty_by_reachability(dfa)
        inf_search, _ = decide_infinite(dfa)
        inf_graph = infinite_by_cycle(dfa)
        agree_ne += (ne_search == ne_graph)
        agree_inf += (inf_search == inf_graph)
    return agree_ne, agree_inf


# --------------------------------------------------------------------------- #
#  Main                                                                       #
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print(" Automatic Sequences: Decidability of Value-Occurrence Problems")
    print("=" * 70)

    P = parity_dfa()
    print("\n[1] Thue-Morse parity automaton (2 states)")
    ne, w = decide_nonempty(P)
    print(f"    nonempty (zero/one-in-sequence)?  {ne}   witness = {w}")
    inf, w2 = decide_infinite(P)
    print(f"    infinite (one infinitely often)?  {inf}   witness = {w2}")
    print(f"    cross-check nonempty via reachability: {nonempty_by_reachability(P)}")
    print(f"    cross-check infinite via cycle:        {infinite_by_cycle(P)}")

    print("\n[2] First 16 Thue-Morse terms:")
    print("   ", [thue_morse(n) for n in range(16)])
    print(f"    recurrences t(2n)=t(n), t(2n+1)=t(n)+1 hold (n<2000)? "
          f"{verify_tm_recurrences()}")

    print("\n[3] Folklore correction: a nonempty language can be FINITE")
    S = single_word_dfa((1, 0, 1))
    ne, w = decide_nonempty(S)
    inf, _ = decide_infinite(S)
    print(f"    automaton accepting exactly [1,0,1]:")
    print(f"    nonempty? {ne}  (witness {w})   infinite? {inf}")
    print("    => 'accepts something' does NOT imply 'accepts infinitely many'")

    print("\n[4] Empty language automaton")
    E = empty_dfa()
    print(f"    nonempty? {decide_nonempty(E)[0]}   infinite? {decide_infinite(E)[0]}")

    print("\n[5] Battery of 100 pseudo-random automata")
    a_ne, a_inf = battery(100)
    print(f"    pumping-search vs graph-reachability agreement (nonempty): {a_ne}/100")
    print(f"    pumping-search vs graph-cycle       agreement (infinite):  {a_inf}/100")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
