"""
Graded Lawvere Theory: Obstruction Spectra for Self-Applicative Presentations
=============================================================================

Numerical and combinatorial demonstrations of the main results.

A *self-applicative presentation* is a set A of codes, a set B of meanings, and
an evaluation table ev : A x A -> B allowing a code to be applied to a code -
in particular to itself.  A code c is a *diagonal code* for a semantic
endomorphism f : B -> B when

        ev(c, x) = f(ev(x, x))        for every code x.

Setting x = c yields ev(c, c) = f(ev(c, c)): a fixed point of f.

The results demonstrated below:

  1. Vacuity of universality.  A fully universal table (surjective onto all
     observations A -> B) forces B to have at most one element, because
     swap(b1, b2) is a definable fixed-point-free endomorphism whenever
     b1 != b2.

  2. Obstruction Spectrum Theorem.  A single table diagonally represents every
     member of a family F of endomorphisms iff every member of F has a fixed
     point.  Sufficiency is witnessed by the explicit "free graded model".

  3. Failure of monoid control.  On {0,1,2} the involutions (0 1) and (1 2)
     each have fixed points, hence are jointly representable, while the
     three-cycle they generate is representable by no table at all.

  4. Choice dependence.  Semantic uniqueness (e.g. contraction on the reals)
     forces every diagonal code, in every presentation, to share one value;
     without uniqueness two codes in one table can disagree.

  5. The pitch-class triad.  Formal, visual and contrapuntal syntaxes over
     Z/12Z, linked by evaluation-preserving equivalences, share the diagonal
     value 0 for inversion; transposition is representable nowhere.

  6. Counting.  Over n meanings exactly n^n - (n-1)^n endomorphisms are
     representable; the density tends to 1 - 1/e = 0.632120...

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Endo = Tuple[int, ...]  # an endomorphism of {0,...,n-1} as its value tuple


# ---------------------------------------------------------------------------
# Section 0.  Basic fixed-point utilities
# ---------------------------------------------------------------------------

def fixed_points(f: Endo) -> List[int]:
    """All b with f(b) = b, for f given as a value tuple on {0,...,n-1}."""
    return [b for b, fb in enumerate(f) if fb == b]


def has_fixed_point(f: Endo) -> bool:
    """Decide diagonal representability of f (Obstruction Spectrum Theorem).

    Time O(n), space O(1).
    """
    return any(fb == b for b, fb in enumerate(f))


def compose(f: Endo, g: Endo) -> Endo:
    """(f o g)(x) = f(g(x))."""
    return tuple(f[g[x]] for x in range(len(g)))


def swap_out(n: int, b1: int, b2: int) -> Endo:
    """The uniformly definable fixed-point-free map: b1 -> b2, everything -> b1.

    Requires b1 != b2.  This is the obstruction that makes full universality
    vacuous over any domain with two distinct meanings.
    """
    assert b1 != b2, "swap_out requires two distinct meanings"
    return tuple(b2 if x == b1 else b1 for x in range(n))


# ---------------------------------------------------------------------------
# Section 1.  Vacuity of full universality
# ---------------------------------------------------------------------------

def demo_vacuity(n_values: Sequence[int] = (2, 3, 4, 5)) -> None:
    print("=" * 74)
    print("1.  VACUITY OF FULL UNIVERSALITY")
    print("=" * 74)
    print("A universal table represents EVERY observation, so by the diagonal")
    print("argument every endomorphism of B has a fixed point.  But swap_out")
    print("never does, for any domain with two distinct meanings:\n")
    for n in n_values:
        f = swap_out(n, 0, 1)
        print(f"  |B| = {n}:  swap_out(0,1) = {f}   fixed points: "
              f"{fixed_points(f)}")
    print("\n  => no universal presentation exists over ANY nontrivial domain.")
    print("     (Boolean negation = swap_out on a two-element domain: (1, 0).)")
    print("     Over a one-point domain the constant table IS universal, so")
    print("     the dichotomy is sharp at the boundary between 1 and 2.\n")


# ---------------------------------------------------------------------------
# Section 2.  The free graded model  (converse of the graded Lawvere theorem)
# ---------------------------------------------------------------------------

class FreeGradedModel:
    """The table built from a family F of endomorphisms with fixed points.

    Codes are labels ('L', i) for the i-th member of F, plus literals ('b', b)
    for each meaning b.  The self-value of a label is a chosen fixed point of
    its endomorphism; the self-value of a literal is the literal.  Then

        ev(label_i, x) = F[i](selfval(x)),     ev(literal_b, x) = b,

    and one checks ev(x, x) = selfval(x), so every label is a diagonal code.
    """

    def __init__(self, n: int, family: Sequence[Endo]) -> None:
        for f in family:
            if not has_fixed_point(f):
                raise ValueError(f"{f} is fixed-point free: not representable")
        self.n: int = n
        self.family: List[Endo] = list(family)
        self.codes: List[Tuple[str, int]] = (
            [("L", i) for i in range(len(family))] + [("b", b) for b in range(n)]
        )
        self._selfval: Dict[Tuple[str, int], int] = {}
        for i, f in enumerate(family):
            self._selfval[("L", i)] = min(fixed_points(f))
        for b in range(n):
            self._selfval[("b", b)] = b

    def selfval(self, x: Tuple[str, int]) -> int:
        return self._selfval[x]

    def ev(self, a: Tuple[str, int], x: Tuple[str, int]) -> int:
        kind, idx = a
        if kind == "L":
            return self.family[idx][self.selfval(x)]
        return idx

    def diagonal_equals_selfval(self) -> bool:
        return all(self.ev(x, x) == self.selfval(x) for x in self.codes)

    def is_diagonal_code(self, a: Tuple[str, int], f: Endo) -> bool:
        return all(self.ev(a, x) == f[self.ev(x, x)] for x in self.codes)

    def verify(self) -> bool:
        """Check the diagonal law and that every label is a diagonal code."""
        if not self.diagonal_equals_selfval():
            return False
        return all(
            self.is_diagonal_code(("L", i), f)
            for i, f in enumerate(self.family)
        )


def demo_free_model() -> None:
    print("=" * 74)
    print("2.  THE FREE GRADED MODEL  (converse direction of the spectrum)")
    print("=" * 74)
    n = 4
    family: List[Endo] = [
        (0, 0, 0, 0),        # constant 0
        (1, 1, 3, 3),        # fixes 1 and 3
        (0, 2, 2, 1),        # fixes 0 and 2
    ]
    model = FreeGradedModel(n, family)
    print(f"  domain size n = {n}, family of {len(family)} endomorphisms")
    for i, f in enumerate(family):
        print(f"    f_{i} = {f}   fixed points {fixed_points(f)}   "
              f"chosen self-value {model.selfval(('L', i))}")
    print(f"\n  codes: {model.codes}")
    print(f"  diagonal law  ev(x,x) = selfval(x):  {model.diagonal_equals_selfval()}")
    for i in range(len(family)):
        c = ("L", i)
        print(f"  label {c} is a diagonal code for f_{i}: "
              f"{model.is_diagonal_code(c, family[i])};  "
              f"diagonal value ev(c,c) = {model.ev(c, c)}  "
              f"(a fixed point of f_{i})")
    print(f"\n  full verification: {model.verify()}\n")


# ---------------------------------------------------------------------------
# Section 3.  Representability is pointwise, not monoidal
# ---------------------------------------------------------------------------

def demo_monoid_failure() -> None:
    print("=" * 74)
    print("3.  REPRESENTABILITY IS POINTWISE, NOT MONOID-CONTROLLED")
    print("=" * 74)
    tA: Endo = (1, 0, 2)      # transposition (0 1)
    tB: Endo = (0, 2, 1)      # transposition (1 2)
    comp = compose(tA, tB)    # the three-cycle 0 -> 1 -> 2 -> 0
    print(f"  t_A = {tA}   fixed points {fixed_points(tA)}")
    print(f"  t_B = {tB}   fixed points {fixed_points(tB)}")
    print(f"  t_A o t_B = {comp}   fixed points {fixed_points(comp)}")
    model = FreeGradedModel(3, [tA, tB])
    print(f"\n  a single table represents BOTH t_A and t_B: {model.verify()}")
    print(f"  is t_A o t_B representable by any table at all? "
          f"{has_fixed_point(comp)}")
    print("\n  => the generated monoid contains an unrepresentable element while")
    print("     the generating family is representable.  The diagonal argument")
    print("     consumes f exactly once, so no closure is forced.\n")


def demo_richness_vs_closure() -> None:
    print("=" * 74)
    print("3b. RICHNESS OF THE REPRESENTED CLASS != DIAGONAL CLOSURE")
    print("=" * 74)
    # Boolean table ev(a, x) = a represents every constant observation.
    codes = [0, 1]
    ev: Callable[[int, int], int] = lambda a, x: a
    for b in codes:
        represented = all(ev(b, x) == b for x in codes)
        print(f"  constant observation with value {b} represented by code {b}: "
              f"{represented}")
    neg: Endo = (1, 0)
    print(f"  Boolean negation {neg} has fixed points {fixed_points(neg)}")
    print("  => no table over any code set diagonally represents negation,")
    print("     even though this table represents every constant.\n")


# ---------------------------------------------------------------------------
# Section 4.  Choice dependence and canonicity
# ---------------------------------------------------------------------------

def demo_choice_dependence() -> None:
    print("=" * 74)
    print("4.  CHOICE DEPENDENCE OF THE DIAGONAL VALUE")
    print("=" * 74)
    # Projection table on {0,1}: ev(a,x) = x.  Every code is a diagonal code
    # for the identity, and the two codes give different values.
    codes = [0, 1]
    ev: Callable[[int, int], int] = lambda a, x: x
    identity: Endo = (0, 1)
    for c in codes:
        is_code = all(ev(c, x) == identity[ev(x, x)] for x in codes)
        print(f"  projection table: code {c} is a diagonal code for the "
              f"identity: {is_code};  value ev(c,c) = {ev(c, c)}")
    print(f"  identity on two meanings has fixed points "
          f"{fixed_points(identity)} -> not unique -> values disagree.\n")

    print("  Contraction restores canonicity.  f(x) = 0.5*x + 3 is a")
    print("  contraction with K = 0.5 < 1, so it has AT MOST ONE fixed point;")
    print("  hence every diagonal code in every presentation shares its value.")
    f: Callable[[float], float] = lambda x: 0.5 * x + 3.0
    for start in (-100.0, 0.0, 7.5, 1000.0):
        x = start
        for _ in range(200):
            x = f(x)
        print(f"    iterating from x0 = {start:>8.1f}  ->  {x:.12f}")
    print(f"    exact fixed point: 3 / (1 - 0.5) = {3.0 / 0.5:.12f}")
    print("    the diagonal value is canonical and computable.\n")


# ---------------------------------------------------------------------------
# Section 5.  The pitch-class triad over Z/12Z
# ---------------------------------------------------------------------------

PITCH_NAMES = ["C", "C#", "D", "D#", "E", "F",
               "F#", "G", "G#", "A", "A#", "B"]


def inversion(x: int) -> int:
    """Musical inversion about C:  x -> -x  (mod 12)."""
    return (-x) % 12


def tritone_inversion(x: int) -> int:
    """Inversion about the tritone:  x -> 6 - x  (mod 12)."""
    return (6 - x) % 12


def transposition(x: int) -> int:
    """Transposition by a semitone:  x -> x + 1  (mod 12)."""
    return (x + 1) % 12


class SyntaxTable:
    """One of the three syntaxes of the triad.

    Codes are ('op1',), ('op2',) and ('lit', b).  Self-values are 0, 3, b.
    ev(op1, x) = inversion(selfval x);  ev(op2, x) = tritone_inversion(selfval x);
    ev(lit b, x) = b.
    """

    def __init__(self, name: str, op1: str, op2: str, lit: str) -> None:
        self.name = name
        self.op1, self.op2, self.lit = op1, op2, lit
        self.codes: List[Tuple[str, int]] = (
            [(op1, -1), (op2, -1)] + [(lit, b) for b in range(12)]
        )

    def selfval(self, x: Tuple[str, int]) -> int:
        kind, b = x
        if kind == self.op1:
            return 0
        if kind == self.op2:
            return 3
        return b

    def ev(self, a: Tuple[str, int], x: Tuple[str, int]) -> int:
        kind, b = a
        if kind == self.op1:
            return inversion(self.selfval(x))
        if kind == self.op2:
            return tritone_inversion(self.selfval(x))
        return b

    def diagonal_law(self) -> bool:
        return all(self.ev(x, x) == self.selfval(x) for x in self.codes)

    def is_diagonal_code(self, a: Tuple[str, int],
                         f: Callable[[int], int]) -> bool:
        return all(self.ev(a, x) == f(self.ev(x, x)) for x in self.codes)


def demo_triad() -> None:
    print("=" * 74)
    print("5.  THE FORMAL / VISUAL / CONTRAPUNTAL TRIAD OVER Z/12Z")
    print("=" * 74)
    formal = SyntaxTable("formal", "selfInvert", "selfTritone", "lit")
    visual = SyntaxTable("visual", "drawingHands", "mirrorHands", "frame")
    musical = SyntaxTable("contrapuntal", "crab", "crabTritone", "note")

    print("  semantic endomorphisms of pitch class:")
    print(f"    inversion        x -> -x     fixed points "
          f"{[b for b in range(12) if inversion(b) == b]}")
    print(f"    tritone inversion x -> 6-x   fixed points "
          f"{[b for b in range(12) if tritone_inversion(b) == b]}")
    print(f"    transposition    x -> x+1    fixed points "
          f"{[b for b in range(12) if transposition(b) == b]}")

    print("\n  diagonal law and inversion codes in each syntax:")
    for tab in (formal, visual, musical):
        code = (tab.op1, -1)
        val = tab.ev(code, code)
        print(f"    {tab.name:<13} diagonal law {tab.diagonal_law()};  "
              f"{tab.op1:<13} is a diagonal code for inversion: "
              f"{tab.is_diagonal_code(code, inversion)};  value = {val} "
              f"({PITCH_NAMES[val]})")

    # Evaluation-preserving equivalence formal <-> visual <-> contrapuntal.
    def phi(x: Tuple[str, int], src: SyntaxTable,
            dst: SyntaxTable) -> Tuple[str, int]:
        kind, b = x
        if kind == src.op1:
            return (dst.op1, -1)
        if kind == src.op2:
            return (dst.op2, -1)
        return (dst.lit, b)

    for dst in (visual, musical):
        ok = all(
            dst.ev(phi(a, formal, dst), phi(x, formal, dst)) == formal.ev(a, x)
            for a in formal.codes for x in formal.codes
        )
        print(f"  evaluation-preserving equivalence formal -> {dst.name}: {ok}")

    print("\n  second diagonal code (tritone inversion), same triad:")
    code2 = (formal.op2, -1)
    v2 = formal.ev(code2, code2)
    print(f"    {formal.op2} is a diagonal code for tritone inversion: "
          f"{formal.is_diagonal_code(code2, tritone_inversion)};  "
          f"value = {v2} ({PITCH_NAMES[v2]}) != 0")
    print("    => the diagonal value depends on the code when the semantic")
    print("       endomorphism has several fixed points.")

    print("\n  transposition: fixed points "
          f"{[b for b in range(12) if transposition(b) == b]} -> representable "
          "by NO syntax whatsoever.")
    print("    music can be about its own inversion; never about its own")
    print("    transposition.\n")


# ---------------------------------------------------------------------------
# Section 6.  Counting the obstruction spectrum
# ---------------------------------------------------------------------------

def enumerate_representable(n: int) -> int:
    """Brute force count of endomorphisms of {0,...,n-1} with a fixed point.

    Time Theta(n^(n+1)); feasible up to about n = 7.
    """
    return sum(
        1 for f in itertools.product(range(n), repeat=n) if has_fixed_point(f)
    )


def closed_form(n: int) -> int:
    """n^n - (n-1)^n, the exact size of the maximal representable family."""
    return n ** n - (n - 1) ** n


def demo_counting(max_brute: int = 6, max_table: int = 12) -> None:
    print("=" * 74)
    print("6.  THE SIZE AND DENSITY OF THE OBSTRUCTION SPECTRUM")
    print("=" * 74)
    print(f"  {'n':>3} {'n^n':>12} {'(n-1)^n':>12} {'brute':>10} "
          f"{'n^n-(n-1)^n':>13} {'density':>9}")
    for n in range(1, max_table + 1):
        cf = closed_form(n)
        brute = enumerate_representable(n) if n <= max_brute else None
        dens = cf / n ** n
        brute_s = f"{brute:>10}" if brute is not None else f"{'-':>10}"
        if brute is not None:
            assert brute == cf, f"closed form mismatch at n = {n}"
        print(f"  {n:>3} {n ** n:>12} {(n - 1) ** n:>12} {brute_s} "
              f"{cf:>13} {dens:>9.6f}")
    limit = 1.0 - math.exp(-1.0)
    print(f"\n  limiting density 1 - 1/e = {limit:.9f}")
    for n in (10, 100, 1000, 10 ** 5, 10 ** 7):
        d = 1.0 - (1.0 - 1.0 / n) ** n
        print(f"    n = {n:>9}:  density {d:.9f}   |error| = "
              f"{abs(d - limit):.3e}")
    print("\n  => a stable proportion 1/e = 36.79% of finite semantic dynamics")
    print("     is permanently beyond self-applicative syntax.\n")


# ---------------------------------------------------------------------------
# Section 7.  The coherence hierarchy of weak simulations
# ---------------------------------------------------------------------------

def demo_simulations() -> None:
    print("=" * 74)
    print("7.  THE COHERENCE HIERARCHY OF WEAK SIMULATIONS")
    print("=" * 74)

    identity2: Endo = (0, 1)

    # Level 3: embedding Unit -> Bool with evQ(a, x) = a.
    evP: Callable[[int, int], int] = lambda a, x: 1   # one code '0', value true
    evQ: Callable[[int, int], int] = lambda a, x: a
    iota: Callable[[int], int] = lambda a: 1
    preserves = evQ(iota(0), iota(0)) == evP(0, 0)
    p_code = all(evP(0, x) == identity2[evP(x, x)] for x in [0])
    q_code = all(evQ(iota(0), y) == identity2[evQ(y, y)] for y in [0, 1])
    print("  embedding (one-code table into a two-code table, evQ(a,x) = a):")
    print(f"    evaluation preserved on the image:      {preserves}")
    print(f"    source code is a diagonal code:         {p_code}")
    print(f"    image is still a diagonal code:         {q_code}   <-- FAILS")
    print(f"    but the diagonal VALUE is preserved:    "
          f"{evQ(iota(0), iota(0)) == evP(0, 0)}")
    print("    (the diagonal equation is quantified over ALL codes, and the")
    print("     embedding introduces a new code at which it breaks)")

    # Level 4: bisimulation for parity.
    valP, valQ = 0, 2
    print("\n  bisimulation (one-code tables valued in N, parity relation):")
    print(f"    diagonal values {valP} and {valQ}; both codes are diagonal")
    print(f"    codes for the identity;  parity agrees: "
          f"{valP % 2 == valQ % 2};  values equal: {valP == valQ}")
    print("\n  summary:")
    print("    equivalence        -> codes and values transport")
    print("    coherent retraction-> codes lift upward, values agree")
    print("    embedding          -> values only")
    print("    bisimulation       -> observations only\n")


# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 74)
    print("#  GRADED LAWVERE THEORY - NUMERICAL DEMONSTRATIONS".ljust(73) + "#")
    print("#" * 74)
    print()
    demo_vacuity()
    demo_free_model()
    demo_monoid_failure()
    demo_richness_vs_closure()
    demo_choice_dependence()
    demo_triad()
    demo_simulations()
    demo_counting()
    print("=" * 74)
    print("All demonstrations completed; every closed form checked against")
    print("brute-force enumeration where feasible.")
    print("=" * 74)


if __name__ == "__main__":
    main()
