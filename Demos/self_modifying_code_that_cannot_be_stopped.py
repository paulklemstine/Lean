"""Numerical demonstrations for
"The Halting Problem for Self-Modifying Code: Undecidable, but Not Strictly Harder".

This self-contained script illustrates, with concrete finite objects, the core
results of the accompanying paper:

  1. Lawvere's fixed-point theorem and Cantor's diagonal argument (over Bool).
  2. The self-modifying machine (SMM) model and its "code becomes data"
     standard simulation.
  3. The Simulation Theorem: an SMM halts iff its standard simulation halts,
     step for step.
  4. Turing (many-one) equivalence of the two halting problems via explicit
     reduction maps.
  5. The self-referential halting theorem, the virus paradox, and the alignment
     obstruction, each realized as a concrete contradiction on a finite domain.

Everything is finite and fully computable, so every claim below is checked by
direct enumeration -- no external dependencies are required.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Generic, Optional, Tuple, TypeVar

P = TypeVar("P")  # program type
S = TypeVar("S")  # state type


# ---------------------------------------------------------------------------
# 1. The diagonalization engine: Lawvere and Cantor over Bool
# ---------------------------------------------------------------------------

def lawvere_fixed_point(
    domain: list,
    g: Callable[[object], Callable[[object], bool]],
    f: Callable[[bool], bool],
) -> Optional[bool]:
    """Lawvere's fixed-point theorem, constructive form.

    If ``g : A -> (A -> Bool)`` is surjective, then any ``f : Bool -> Bool``
    has a fixed point. The witness is ``g(a)(a)`` where ``g(a)`` names the
    diagonal map ``x |-> f(g(x)(x))``. We return the fixed value, or ``None``
    if ``g`` is *not* surjective (which is exactly Cantor's theorem in action).
    """
    diagonal: Callable[[object], bool] = lambda x: f(g(x)(x))
    for a in domain:
        if all(g(a)(x) == diagonal(x) for x in domain):
            b = g(a)(a)
            assert f(b) == b, "Lawvere witness must be a fixed point"
            return b
    return None


def demo_cantor() -> None:
    """No map g : A -> (A -> Bool) is surjective (Cantor, Boolean form).

    We enumerate a candidate g on a small finite A and exhibit the
    anti-diagonal predicate that g misses. Since Bool-negation is
    fixed-point-free, ``lawvere_fixed_point`` must return ``None``.
    """
    print("=" * 70)
    print("1. CANTOR / LAWVERE: no g : A -> (A -> Bool) is surjective")
    print("=" * 70)
    A = [0, 1, 2]

    # An arbitrary candidate 'enumeration' of predicates on A.
    table = {0: (True, False, True), 1: (False, False, True), 2: (True, True, False)}
    g = lambda a: (lambda x: table[a][x])

    # The anti-diagonal predicate q |-> not g(q)(q); no a in A can name it.
    anti = tuple(not g(a)(a) for a in A)
    named = {tuple(g(a)(x) for x in A) for a in A}
    print(f"  predicates named by g : {sorted(named)}")
    print(f"  anti-diagonal predicate: {anti}  in named? {anti in named}")

    result = lawvere_fixed_point(A, g, lambda b: not b)
    print(f"  fixed point of NOT via this g: {result}  (None => g not surjective)")
    assert anti not in named and result is None
    print("  => Cantor confirmed: the contrarian predicate is unrealizable.\n")


# ---------------------------------------------------------------------------
# 2-3. The SMM model, the standard simulation, and the Simulation Theorem
# ---------------------------------------------------------------------------

@dataclass
class SMM(Generic[P, S]):
    """A self-modifying machine: one step maps (program, state) to an optional
    new (program, state). ``None`` means halt. The program itself may change."""

    step: Callable[[P, S], Optional[Tuple[P, S]]]

    def run(self, cfg: Tuple[P, S], n: int) -> Optional[Tuple[P, S]]:
        """Run for n steps; return None if it halts within those n steps."""
        for _ in range(n):
            nxt = self.step(cfg[0], cfg[1])
            if nxt is None:
                return None
            cfg = nxt
        return cfg

    def halts_within(self, cfg: Tuple[P, S], budget: int) -> bool:
        return any(self.run(cfg, n) is None for n in range(budget + 1))

    def to_std(self) -> "Std[Tuple[P, S]]":
        """Code becomes data: absorb the program into the state, producing a
        fixed-program machine over the enlarged state P x S."""
        return Std(step=lambda ps: self.step(ps[0], ps[1]))


@dataclass
class Std(Generic[S]):
    """A standard (fixed-program) machine: one step maps state to optional
    new state. ``None`` means halt."""

    step: Callable[[S], Optional[S]]

    def run(self, s: S, n: int) -> Optional[S]:
        for _ in range(n):
            nxt = self.step(s)
            if nxt is None:
                return None
            s = nxt
        return s

    def halts_within(self, s: S, budget: int) -> bool:
        return any(self.run(s, n) is None for n in range(budget + 1))

    def emb(self) -> "SMM[None, S]":
        """Embed a standard machine as an SMM with a trivial one-point program."""
        def step(_: None, s: S) -> Optional[Tuple[None, S]]:
            nxt = self.step(s)
            return None if nxt is None else (None, nxt)

        return SMM(step=step)


def demo_simulation() -> None:
    """Simulation Theorem: an SMM halts iff its standard simulation halts.

    We build a genuinely self-modifying machine over programs {A, B} and state
    N: program A decrements the counter and rewrites itself to B; program B
    decrements and rewrites to A; either halts when the counter hits 0. We then
    check step-for-step agreement with the 'code becomes data' simulation.
    """
    print("=" * 70)
    print("2-3. SIMULATION THEOREM (self-modifying halts iff simulation halts)")
    print("=" * 70)

    def step(p: str, s: int) -> Optional[Tuple[str, int]]:
        if s <= 0:
            return None
        return ("B" if p == "A" else "A", s - 1)

    m: SMM[str, int] = SMM(step=step)
    std = m.to_std()

    for start in [("A", 0), ("A", 3), ("B", 5)]:
        budget = 20
        h_smm = m.halts_within(start, budget)
        h_std = std.halts_within(start, budget)
        # step-exact agreement of the runs (code-as-data identity):
        agree = all(
            (m.run(start, n) if m.run(start, n) is None else m.run(start, n))
            == std.run(start, n)
            for n in range(budget + 1)
        )
        print(f"  start {start!s:>8}: SMM halts={h_smm}, sim halts={h_std}, "
              f"runs agree step-for-step={agree}")
        assert h_smm == h_std and agree
    print("  => The self-modifying run and its flattened simulation coincide.\n")


# ---------------------------------------------------------------------------
# 4. Turing (many-one) equivalence of the two halting problems
# ---------------------------------------------------------------------------

def demo_equivalence() -> None:
    """Many-one equivalence: each halting problem reduces to the other.

    Forward: cfg |-> (prog, state) sends an SMM instance to a standard one.
    Backward: s |-> ((), s) embeds a standard machine as an SMM. We verify the
    reduction identities on concrete instances.
    """
    print("=" * 70)
    print("4. TURING EQUIVALENCE (self-modifying halting  <=>_m  standard)")
    print("=" * 70)

    # An SMM whose halting we reduce to standard halting.
    m: SMM[str, int] = SMM(
        step=lambda p, s: None if s <= 0 else (("B" if p == "A" else "A"), s - 1)
    )
    std = m.to_std()
    for cfg in [("A", 4), ("B", 0), ("A", 7)]:
        # reduction map is the identity (prog, state) here
        assert m.halts_within(cfg, 30) == std.halts_within(cfg, 30)
    print("  forward reduction cfg |-> (prog,state): halting preserved  [OK]")

    # A standard machine embedded back into an SMM.
    base: Std[int] = Std(step=lambda s: None if s <= 0 else s - 1)
    emb = base.emb()
    for s in [0, 1, 5, 9]:
        assert base.halts_within(s, 30) == emb.halts_within((None, s), 30)
    print("  backward reduction s |-> ((),s):        halting preserved  [OK]")
    print("  => Both reductions are total; the problems share one Turing degree.")
    print("  => CORRECTION to folklore: self-modification is NOT strictly harder.\n")


# ---------------------------------------------------------------------------
# 5. Self-reference: no correct decider, virus paradox, alignment obstruction
# ---------------------------------------------------------------------------

def demo_self_reference() -> None:
    """Self-referential halting theorem and its two corollaries.

    On a finite program domain we let the 'system' build, for any candidate
    predictor, the contrarian program d whose self-behavior is wired to
    contradict the predictor. We then verify that EVERY total predictor errs on
    d, realizing (a) the no-correct-decider theorem, (b) the virus paradox, and
    (c) the alignment obstruction, each as a concrete Boolean contradiction.
    """
    print("=" * 70)
    print("5. SELF-REFERENCE: contrarian defeats every total predictor")
    print("=" * 70)

    programs = ["p0", "p1", "d"]  # 'd' will play the contrarian role

    # (a) No correct decider. For each candidate H, we define Halts(d, .) so
    #     that Halts(d, q) <=> H(q, q) == False (the defining property of d).
    #     Then H is necessarily wrong about d on its own code.
    import itertools

    def make_H(bits: Tuple[bool, ...]) -> Callable[[str, str], bool]:
        idx = {q: i for i, q in enumerate(programs)}
        return lambda p, q: bits[idx[q]]  # H depends only on the input q here

    n = len(programs)
    all_wrong = True
    for bits in itertools.product([False, True], repeat=n):
        H = make_H(bits)
        # d's self-behavior is forced by construction:
        halts_d_on = {q: (H(q, q) is False) for q in programs}
        # Correctness at d would require H(d,d) <=> Halts(d,d):
        correct_at_d = (H("d", "d") is True) == halts_d_on["d"]
        all_wrong = all_wrong and (not correct_at_d)
    print(f"  every total predictor H errs on the contrarian d? {all_wrong}")
    assert all_wrong

    # (b) Virus paradox: a detector Detect(q) claiming to decide self-halting
    #     Halts(q,q) is refuted by the same contrarian.
    def virus_paradox(detect: Callable[[str], bool]) -> bool:
        halts_d_on = {q: (detect(q) is False) for q in programs}
        # Does Detect decide self-halting everywhere?
        return all((detect(q) is True) == halts_d_on[q] for q in programs)

    detectors_all_fail = not any(
        virus_paradox(lambda q, b=bits: {p: v for p, v in zip(programs, b)}[q])
        for bits in itertools.product([False, True], repeat=n)
    )
    print(f"  no total detector decides self-halting everywhere?    "
          f"{detectors_all_fail}")
    assert detectors_all_fail

    # (c) Alignment obstruction: a monitor M(q) certifying 'never halts on self'
    #     (not Halts(q,q)) is wrong on d, whose termination tracks M's verdict.
    def alignment_fails(M: Callable[[str], bool]) -> bool:
        # d built so that Halts(d, q) <=> M(q) == True
        halts_d_on = {q: (M(q) is True) for q in programs}
        # Correct certification at d requires M(d) <=> not Halts(d,d):
        return (M("d") is True) == (not halts_d_on["d"])

    monitors_all_wrong = not any(
        alignment_fails(lambda q, b=bits: {p: v for p, v in zip(programs, b)}[q])
        for bits in itertools.product([False, True], repeat=n)
    )
    print(f"  no total safety monitor certifies self-termination?   "
          f"{monitors_all_wrong}")
    assert monitors_all_wrong
    print("  => Self-reference, not self-modification, is the true obstruction.\n")


def main() -> None:
    demo_cantor()
    demo_simulation()
    demo_equivalence()
    demo_self_reference()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
