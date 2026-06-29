"""
Numerical demonstrations for:

    Finite-State Output Machines: Reachability, Decidability,
    and the Limits of Automatic Sequences

Every routine below mirrors a result from the formal development:

    * DFAO / run / eval                  -> Definitions 1-2
    * reachable_states (BFS expand/reach)-> Section 3 (reach, expand, reachSet)
    * stabilizes_within_card_Q           -> Theorem 10 (exists_reach_stable)
    * range_is_finite                    -> Theorem 13 (range_finite)
    * occurrence_is_decidable            -> Theorem 14 (decidableOccurs)
    * unary_eventual_period              -> Theorem 15 (eventuallyPeriodic)
    * identity_breaks_finiteness         -> Corollary 16 (not_isKAutomatic_id)

This file is self-contained: run `python demo.py`.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, Hashable, List, Set, Tuple, TypeVar

Q = TypeVar("Q", bound=Hashable)   # state type
A = TypeVar("A")                   # output type


# ---------------------------------------------------------------------------
# Definitions 1-2 : a deterministic finite automaton with output (DFAO)
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class DFAO:
    """A DFAO over the alphabet {0, ..., k-1}.

    states : the full (finite) state space Q.
    q0     : the initial state.
    step   : transition  step(q, c) for a symbol c in {0,...,k-1}.
    out    : output label out(q).
    """
    k: int
    states: Tuple[Hashable, ...]
    q0: Hashable
    step: Callable[[Hashable, int], Hashable]
    out: Callable[[Hashable], object]

    def run(self, word: List[int]) -> Hashable:
        """run(w) = foldl step q0 w  (Definition 2)."""
        q = self.q0
        for c in word:
            assert 0 <= c < self.k, "symbol out of alphabet"
            q = self.step(q, c)
        return q

    def eval(self, word: List[int]) -> object:
        """eval(w) = out(run(w))  (Definition 2)."""
        return self.out(self.run(word))


# ---------------------------------------------------------------------------
# Section 3 : breadth-first reachable-state computation (expand / reach)
# ---------------------------------------------------------------------------
def expand(M: DFAO, S: Set[Hashable]) -> Set[Hashable]:
    """One BFS round: S together with every one-step successor (Definition 5)."""
    out: Set[Hashable] = set(S)
    for q in S:
        for c in range(M.k):
            out.add(M.step(q, c))
    return out


def reach_layers(M: DFAO) -> List[Set[Hashable]]:
    """Return the layers reach(0), reach(1), ... up to the guaranteed
    fixed point reach(|Q|) = reachSet (Theorem 10 + Definition 11)."""
    layers: List[Set[Hashable]] = [{M.q0}]
    for _ in range(len(M.states)):          # at most |Q| rounds suffice
        nxt = expand(M, layers[-1])
        layers.append(nxt)
        if nxt == layers[-2]:               # reach_stable: stop at fixed point
            break
    return layers


def reach_set(M: DFAO) -> Set[Hashable]:
    """reachSet(M): exactly the reachable states (Definition 11)."""
    return reach_layers(M)[-1]


def stabilizes_within_card_Q(M: DFAO) -> Tuple[bool, int, int]:
    """Theorem 10: the first index n with reach(n+1) == reach(n) satisfies
    n <= |Q|. Returns (holds, n, |Q|)."""
    layers = reach_layers(M)
    # layers stop the first time a round repeats; that index is n+1.
    n = len(layers) - 2 if layers[-1] == layers[-2] else len(layers) - 1
    return (n <= len(M.states), n, len(M.states))


# ---------------------------------------------------------------------------
# Theorem 13 : range of an automatic sequence is finite
# ---------------------------------------------------------------------------
def range_is_finite(M: DFAO, encode: Callable[[int], List[int]],
                    upto: int) -> Set[object]:
    """Sample f(n) = eval(encode(n)) for n < upto; every value lies in
    out(reachSet), which is finite (Theorem 13)."""
    sampled = {M.eval(encode(n)) for n in range(upto)}
    label_universe = {M.out(q) for q in reach_set(M)}
    assert sampled <= label_universe, "range escaped the output labels!"
    return sampled


# ---------------------------------------------------------------------------
# Theorem 14 : occurrence of a target output is decidable
# ---------------------------------------------------------------------------
def occurrence_is_decidable(M: DFAO, target: object) -> bool:
    """Decide  ∃ w. eval(w) == target  by a finite scan of reachSet
    (Theorem 14)."""
    return any(M.out(q) == target for q in reach_set(M))


# ---------------------------------------------------------------------------
# Theorem 15 : a unary (k = 1) automaton's output is eventually periodic
# ---------------------------------------------------------------------------
def unary_eventual_period(M: DFAO) -> Tuple[int, int]:
    """For k == 1, find (preperiod n0, period p) of n |-> out(next^[n](q0))
    via finite-orbit detection (Theorem 15). Returns (n0, p)."""
    assert M.k == 1, "eventual periodicity here is the unary statement"
    seen: Dict[Hashable, int] = {}
    q = M.q0
    n = 0
    while q not in seen:
        seen[q] = n
        q = M.step(q, 0)
        n += 1
    n0 = seen[q]            # first index whose state recurs
    p = n - n0              # cycle length
    return n0, p


# ---------------------------------------------------------------------------
# Corollary 16 : the identity sequence has infinite range, so is not automatic
# ---------------------------------------------------------------------------
def identity_breaks_finiteness(upto: int) -> int:
    """The identity n |-> n yields `upto` distinct values, growing without
    bound; contrast with the finite output universe of any DFAO (Cor. 16)."""
    return len({n for n in range(upto)})


# ---------------------------------------------------------------------------
# Concrete machines used by the demonstrations
# ---------------------------------------------------------------------------
def thue_morse_dfao() -> DFAO:
    """2-state, 2-automatic Thue-Morse machine: state = parity of #(1-bits).
    out(state) = state in {0, 1}."""
    return DFAO(
        k=2,
        states=(0, 1),
        q0=0,
        step=lambda q, c: q ^ c,          # XOR: a '1' flips parity
        out=lambda q: q,
    )


def binary_digits(n: int) -> List[int]:
    """Base-2 digit expansion (most-significant first); [] for n = 0."""
    if n == 0:
        return []
    bits: List[int] = []
    while n > 0:
        bits.append(n & 1)
        n >>= 1
    return list(reversed(bits))


def mod7_dfao() -> DFAO:
    """7-state machine: track n mod 7 from binary digits, output the residue.
    Reading bit b updates residue r -> (2r + b) mod 7."""
    return DFAO(
        k=2,
        states=tuple(range(7)),
        q0=0,
        step=lambda r, b: (2 * r + b) % 7,
        out=lambda r: r,
    )


def unary_lasso_dfao() -> DFAO:
    """Unary (k = 1) machine with a 'rho' (lasso) shape: a tail 0->1->2 then a
    3-cycle 2->3->4->2. Output = state, so the value stream is eventually
    periodic with preperiod 2 and period 3."""
    nxt = {0: 1, 1: 2, 2: 3, 3: 4, 4: 2}
    return DFAO(
        k=1,
        states=(0, 1, 2, 3, 4),
        q0=0,
        step=lambda q, _c: nxt[q],
        out=lambda q: q,
    )


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("Finite-State Output Machines -- numerical demonstrations")
    print("=" * 70)

    # --- Thue-Morse: a genuine 2-automatic sequence -----------------------
    tm = thue_morse_dfao()
    seq = [tm.eval(binary_digits(n)) for n in range(16)]
    popcount = [bin(n).count("1") % 2 for n in range(16)]
    print("\n[Def 1-2] Thue-Morse via 2-state DFAO, n = 0..15:")
    print("   DFAO output :", seq)
    print("   parity(#1s) :", popcount)
    assert seq == popcount, "DFAO must reproduce Thue-Morse exactly"
    print("   match: OK")

    # --- Theorem 13: finite range -----------------------------------------
    rng = range_is_finite(tm, binary_digits, upto=5000)
    print("\n[Thm 13 range_finite] distinct values among n=0..4999:", sorted(rng))
    print("   |range| =", len(rng), "(finite, inside out(reachSet))")

    # --- Section 3 / Theorem 10: reachability terminates within |Q| -------
    m7 = mod7_dfao()
    holds, n_star, cardQ = stabilizes_within_card_Q(m7)
    print("\n[Thm 10 exists_reach_stable] mod-7 machine:")
    print(f"   stabilizes at round n = {n_star}, |Q| = {cardQ}, n <= |Q|: {holds}")
    print("   reachSet =", sorted(reach_set(m7)))

    # --- Theorem 14: decidable occurrence ---------------------------------
    print("\n[Thm 14 decidableOccurs] mod-7 machine, 'does output v occur?':")
    for v in [3, 6, 7, 99]:
        print(f"   output {v:>3} reachable? {occurrence_is_decidable(m7, v)}")

    # a machine whose state 1 is unreachable, to show the scan is exact
    isolated = DFAO(k=1, states=(0, 1), q0=0,
                    step=lambda q, _c: q, out=lambda q: q)
    print("   isolated machine, output 1 reachable? "
          f"{occurrence_is_decidable(isolated, 1)} (state 1 is unreachable)")

    # --- Theorem 15: unary eventual periodicity ---------------------------
    lasso = unary_lasso_dfao()
    n0, p = unary_eventual_period(lasso)
    stream = [lasso.eval([0] * n) for n in range(12)]
    print("\n[Thm 15 eventuallyPeriodic] unary lasso machine:")
    print("   output stream n=0..11:", stream)
    print(f"   preperiod n0 = {n0}, period p = {p}")
    assert all(stream[n + p] == stream[n] for n in range(n0, 12 - p))
    print("   periodicity verified for n >= n0: OK")

    # --- Corollary 16: identity is not automatic --------------------------
    print("\n[Cor 16 not_isKAutomatic_id] identity n|->n :")
    for upto in [10, 100, 1000]:
        print(f"   distinct values in 0..{upto-1}: {identity_breaks_finiteness(upto)}"
              " (grows without bound -> infinite range -> not automatic)")

    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
