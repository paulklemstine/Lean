"""
demo.py — Automatic Sequences and the Zero-in-Sequence Problem
==============================================================

Self-contained numerical demonstrations of the verified results on
deterministic finite automata with output (DFAOs) and automatic sequences:

  * DFAO model with `run` and `eval`.
  * Breadth-first reachable-state computation that stabilizes within |Q| rounds.
  * Decidability of the occurrence / zero-in-sequence problem.
  * The finite-range obstruction (a_n = n is not automatic).
  * Eventual periodicity of unary automatic sequences.

All functions are inlined with type hints; no third-party dependencies.

Run:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Callable, Dict, List, Optional, Set, Tuple, TypeVar, Hashable

Q = TypeVar("Q", bound=Hashable)
A = TypeVar("A", bound=Hashable)


# ----------------------------------------------------------------------------
# 1. The DFAO model
# ----------------------------------------------------------------------------
@dataclass
class DFAO:
    """A deterministic finite automaton with output over alphabet {0, ..., k-1}.

    Attributes:
        k:     alphabet size (input symbols are 0, 1, ..., k-1).
        q0:    initial state.
        step:  transition function (state, symbol) -> state.
        out:   output labelling state -> output value.
        states: the full (finite) state space.
    """

    k: int
    q0: Hashable
    step: Callable[[Hashable, int], Hashable]
    out: Callable[[Hashable], Hashable]
    states: Set[Hashable] = field(default_factory=set)

    def run(self, word: List[int]) -> Hashable:
        """State reached after reading `word` from q0 (left fold of step)."""
        q = self.q0
        for c in word:
            q = self.step(q, c)
        return q

    def eval(self, word: List[int]) -> Hashable:
        """Output produced by reading `word`."""
        return self.out(self.run(word))


# ----------------------------------------------------------------------------
# 2. Breadth-first reachable set (stabilizes within |Q| rounds)
# ----------------------------------------------------------------------------
def expand(m: DFAO, s: Set[Hashable]) -> Set[Hashable]:
    """One expansion round: add every state one transition away from `s`."""
    out: Set[Hashable] = set(s)
    for q in s:
        for c in range(m.k):
            out.add(m.step(q, c))
    return out


def reachable_set(m: DFAO) -> Tuple[Set[Hashable], int]:
    """Compute the reachable state set and the number of rounds to stabilize.

    Returns (reachable_states, rounds). By Theorem 3.8, rounds <= |Q|.
    """
    current: Set[Hashable] = {m.q0}
    rounds = 0
    while True:
        nxt = expand(m, current)
        rounds += 1
        if nxt == current:
            return current, rounds - 1
        current = nxt


# ----------------------------------------------------------------------------
# 3. Decidability of occurrence / zero-in-sequence
# ----------------------------------------------------------------------------
def occurs(m: DFAO, target: Hashable) -> bool:
    """Decide whether some input word produces output `target`."""
    reach, _ = reachable_set(m)
    return any(m.out(q) == target for q in reach)


def zero_in_sequence(m: DFAO) -> bool:
    """Decide the zero-in-sequence problem: does the DFAO ever output 0?"""
    return occurs(m, 0)


def occurrence_witness(m: DFAO, target: Hashable,
                       max_len: Optional[int] = None) -> Optional[List[int]]:
    """Return a shortest word producing `target`, or None if impossible.

    By the dichotomy of Remark 4.4 it suffices to search words of length
    < |Q|, so `max_len` defaults to |reachable states|.
    """
    reach, _ = reachable_set(m)
    if max_len is None:
        max_len = len(reach)
    frontier: List[List[int]] = [[]]
    seen: Set[Hashable] = set()
    for _ in range(max_len + 1):
        nxt: List[List[int]] = []
        for w in frontier:
            q = m.run(w)
            if m.out(q) == target:
                return w
            if q in seen:
                continue
            seen.add(q)
            for c in range(m.k):
                nxt.append(w + [c])
        frontier = nxt
    return None


# ----------------------------------------------------------------------------
# 4. Sequence generation from a base-k encoder
# ----------------------------------------------------------------------------
def base_k_digits(n: int, k: int) -> List[int]:
    """Most-significant-first base-k digits of n (empty list for n = 0... or [0])."""
    if n == 0:
        return [0]
    ds: List[int] = []
    while n > 0:
        ds.append(n % k)
        n //= k
    return list(reversed(ds))


def automatic_sequence(m: DFAO, length: int) -> List[Hashable]:
    """First `length` terms of the k-automatic sequence n -> eval(base_k(n))."""
    return [m.eval(base_k_digits(n, m.k)) for n in range(length)]


def finite_range(seq: List[Hashable]) -> Set[Hashable]:
    """The set of distinct values taken by a sequence (illustrates finite range)."""
    return set(seq)


# ----------------------------------------------------------------------------
# 5. Eventual periodicity for unary automata
# ----------------------------------------------------------------------------
def unary_sequence(next_fn: Callable[[Hashable], Hashable],
                   out: Callable[[Hashable], Hashable],
                   q0: Hashable, length: int) -> List[Hashable]:
    """u(n) = out(next^n q0) for n in [0, length)."""
    seq: List[Hashable] = []
    q = q0
    for _ in range(length):
        seq.append(out(q))
        q = next_fn(q)
    return seq


def detect_period(next_fn: Callable[[Hashable], Hashable],
                  q0: Hashable) -> Tuple[int, int]:
    """Find (pre_period m, period p) of the orbit of q0 under next_fn.

    Returns m and p with next^[n] = next^[n+p] for all n >= m.
    """
    seen: Dict[Hashable, int] = {}
    q = q0
    i = 0
    while q not in seen:
        seen[q] = i
        q = next_fn(q)
        i += 1
    m = seen[q]
    p = i - m
    return m, p


# ----------------------------------------------------------------------------
# Concrete automata
# ----------------------------------------------------------------------------
def thue_morse() -> DFAO:
    """2-automatic Thue-Morse: parity of number of 1-bits. States: 0, 1."""
    return DFAO(
        k=2, q0=0,
        step=lambda q, c: q ^ c,        # XOR running parity with the bit
        out=lambda q: q,
        states={0, 1},
    )


def rudin_shapiro() -> DFAO:
    """2-automatic Rudin-Shapiro: (parity of '11' factors).

    State (last_bit, parity). Output is the parity component mapped to +/-1
    conceptually; here we output 0/1 for the parity of overlapping '11's.
    """
    def step(q: Tuple[int, int], c: int) -> Tuple[int, int]:
        last, par = q
        new_par = par ^ (1 if last == 1 and c == 1 else 0)
        return (c, new_par)
    states = {(a, b) for a in (0, 1) for b in (0, 1)}
    return DFAO(k=2, q0=(0, 0), step=step, out=lambda q: q[1], states=states)


def mod3_residue() -> DFAO:
    """2-automatic: n mod 3 read from binary digits (Horner: q -> 2q + c).

    Output is the residue class of n modulo 3.  Reads MSB-first.
    """
    return DFAO(
        k=2, q0=0,
        step=lambda q, c: (2 * q + c) % 3,
        out=lambda q: q,
        states={0, 1, 2},
    )


def all_zero() -> DFAO:
    """A 2-automatic sequence that is identically 0 (single state)."""
    return DFAO(k=2, q0=0, step=lambda q, c: 0, out=lambda q: 0, states={0})


def never_zero() -> DFAO:
    """A 2-automatic sequence whose output is always 1 (never hits 0)."""
    return DFAO(k=2, q0=0, step=lambda q, c: 0, out=lambda q: 1, states={0})


# ----------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print(" Automatic Sequences and the Zero-in-Sequence Problem")
    print("=" * 70)

    tm = thue_morse()
    print("\n[1] Thue-Morse (2-automatic), first 32 terms:")
    print("   ", "".join(str(x) for x in automatic_sequence(tm, 32)))
    reach, rounds = reachable_set(tm)
    print(f"    reachable states = {sorted(reach)}; "
          f"stabilized in {rounds} rounds (|Q| = {len(tm.states)})")
    print(f"    finite range     = {sorted(finite_range(automatic_sequence(tm, 1000)))}")

    rs = rudin_shapiro()
    print("\n[2] Rudin-Shapiro (2-automatic), first 32 parity terms:")
    print("   ", "".join(str(x) for x in automatic_sequence(rs, 32)))
    print(f"    finite range     = "
          f"{sorted(finite_range(automatic_sequence(rs, 1000)))}")

    m3 = mod3_residue()
    print("\n[3] n mod 3 (2-automatic, Horner), first 24 terms:")
    print("   ", automatic_sequence(m3, 24))
    print(f"    matches n%3      = "
          f"{automatic_sequence(m3, 24) == [n % 3 for n in range(24)]}")

    print("\n[4] Zero-in-sequence decisions:")
    for name, m in [("Thue-Morse", tm), ("n mod 3", m3),
                    ("all-zero", all_zero()), ("never-zero", never_zero())]:
        present = zero_in_sequence(m)
        w = occurrence_witness(m, 0)
        ws = "".join(map(str, w)) if w is not None else "(none)"
        print(f"    {name:12s}: contains 0? {present!s:5s}  witness word = {ws}")

    print("\n[5] Finite-range obstruction: a_n = n is NOT automatic.")
    ident = list(range(20))
    print(f"    range of a_n=n over [0,20) has {len(finite_range(ident))} values "
          f"(grows without bound) -> not finite-state.")

    print("\n[6] Eventual periodicity of a unary automaton:")
    # next: 0->1->2->3->3 (absorbing), output = state mod 2
    nxt = lambda q: min(q + 1, 3)
    out = lambda q: q % 2
    seq = unary_sequence(nxt, out, 0, 12)
    m_pre, p = detect_period(nxt, 0)
    print(f"    u(n) = {seq}")
    print(f"    pre-period m = {m_pre}, period p = {p}")

    # A genuinely periodic cycle: 0->1->2->0
    cyc = lambda q: (q + 1) % 3
    seqc = unary_sequence(cyc, lambda q: q, 0, 12)
    mc, pc = detect_period(cyc, 0)
    print(f"    cyclic u(n) = {seqc}; pre-period {mc}, period {pc}")

    print("\n[7] Batch validation over 100 random small DFAOs:")
    _validate_batch(100)

    print("\nDone.")


def _validate_batch(n: int) -> None:
    """Cross-check the reachable-set decision against brute-force word search."""
    import random
    random.seed(2026)
    ok = 0
    for _ in range(n):
        k = random.randint(1, 3)
        nstates = random.randint(1, 6)
        table = {(q, c): random.randrange(nstates)
                 for q in range(nstates) for c in range(k)}
        labels = {q: random.randrange(3) for q in range(nstates)}
        m = DFAO(k=k, q0=0,
                 step=lambda q, c, t=table: t[(q, c)],
                 out=lambda q, l=labels: l[q],
                 states=set(range(nstates)))
        for target in range(3):
            decided = occurs(m, target)
            brute = _brute_occurs(m, target, max_len=nstates + 2)
            assert decided == brute, (k, nstates, table, labels, target)
        ok += 1
    print(f"    {ok}/{n} random DFAOs: decision procedure matches brute force.")


def _brute_occurs(m: DFAO, target: Hashable, max_len: int) -> bool:
    """Brute-force occurrence by enumerating all words up to max_len."""
    from itertools import product
    for length in range(max_len + 1):
        for w in product(range(m.k), repeat=length):
            if m.eval(list(w)) == target:
                return True
    return False


if __name__ == "__main__":
    main()
