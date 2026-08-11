"""
Numerical demonstrations for *The Refinement Hierarchy of Survival Games*.

This file is entirely self-contained: it implements exact arithmetic for the
countable ordinals below epsilon_0 in Cantor normal form, and then uses that
arithmetic to exhibit, concretely, every result of the paper:

  1. The refinement law             value(refine(G)) = omega * value(G),
     hence the k-fold refinement of the finite clock has value omega^(k+1).
  2. Strictness of the hierarchy    omega^(j+1) < omega^(k+1) for j < k.
  3. Bounded-depth clocks           the k-fold lexicographic natural-number
     clock has order type exactly omega^k, realised by the explicit reading
     map (n_1,...,n_k) |-> omega^(k-1) n_1 + ... + omega n_(k-1) + n_k.
  4. The limit clock                the key  <k,a> |-> omega^k + typein(a)
     is strictly increasing for the lexicographic order on the disjoint union
     of all finite-depth clocks, and takes all its values below omega^omega;
     therefore the limit clock has value exactly omega^omega.
  5. The fixed point                omega * omega^omega = omega^omega, so
     refinement does NOT always strictly help.
  6. Structure theory               1 + omega = omega but omega + 1 > omega
     (concatenation of lives is non-commutative), and omega^a is refinement
     stable exactly when omega <= a.
  7. The transfinite machine        a monotone transition system on the cells
     of the omega^2 clock whose closure ordinal is exactly omega^2.

Run with:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable, Iterator, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Exact ordinal arithmetic below epsilon_0, in Cantor normal form.
#
# An ordinal is a strictly decreasing list of (exponent, coefficient) pairs
#     omega^e_1 * c_1 + ... + omega^e_m * c_m ,   e_1 > ... > e_m,  c_i >= 1,
# where each exponent is itself an ordinal in the same representation.
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Ord:
    """A countable ordinal below epsilon_0, in Cantor normal form."""

    terms: Tuple[Tuple["Ord", int], ...] = ()

    # -- constructors -------------------------------------------------------

    @staticmethod
    def zero() -> "Ord":
        return Ord(())

    @staticmethod
    def finite(n: int) -> "Ord":
        if n < 0:
            raise ValueError("ordinals are non-negative")
        return Ord(()) if n == 0 else Ord(((Ord.zero(), n),))

    @staticmethod
    def omega_pow(exponent: "Ord", coeff: int = 1) -> "Ord":
        """omega^exponent * coeff."""
        if coeff == 0:
            return Ord.zero()
        return Ord(((exponent, coeff),))

    # -- basic predicates ---------------------------------------------------

    @property
    def is_zero(self) -> bool:
        return len(self.terms) == 0

    @property
    def is_finite(self) -> bool:
        return self.is_zero or (len(self.terms) == 1 and self.terms[0][0].is_zero)

    @property
    def finite_part(self) -> int:
        if self.terms and self.terms[-1][0].is_zero:
            return self.terms[-1][1]
        return 0

    # -- comparison ---------------------------------------------------------

    def cmp(self, other: "Ord") -> int:
        """Return -1, 0, +1 according as self <, =, > other."""
        for (e1, c1), (e2, c2) in zip(self.terms, other.terms):
            k = e1.cmp(e2)
            if k != 0:
                return k
            if c1 != c2:
                return -1 if c1 < c2 else 1
        if len(self.terms) == len(other.terms):
            return 0
        return -1 if len(self.terms) < len(other.terms) else 1

    def __lt__(self, other: "Ord") -> bool:
        return self.cmp(other) < 0

    def __le__(self, other: "Ord") -> bool:
        return self.cmp(other) <= 0

    def __eq__(self, other: object) -> bool:  # type: ignore[override]
        return isinstance(other, Ord) and self.cmp(other) == 0

    def __hash__(self) -> int:
        return hash(self.terms)

    # -- arithmetic ---------------------------------------------------------

    def __add__(self, other: "Ord") -> "Ord":
        """Ordinal addition (absorbs strictly smaller leading terms on the left)."""
        if other.is_zero:
            return self
        lead = other.terms[0][0]
        kept = [(e, c) for (e, c) in self.terms if lead < e]
        merged: List[Tuple[Ord, int]] = list(kept)
        tail = list(other.terms)
        # a term of self with exponent exactly `lead` merges coefficients
        same = [c for (e, c) in self.terms if e == lead]
        if same:
            e0, c0 = tail[0]
            tail[0] = (e0, c0 + same[0])
        return Ord(tuple(merged + tail))

    def __mul__(self, other: "Ord") -> "Ord":
        """Ordinal multiplication self * other (left factor applied `other` times)."""
        if self.is_zero or other.is_zero:
            return Ord.zero()
        lead_e, lead_c = self.terms[0]
        out = Ord.zero()
        for (e, c) in other.terms:
            if e.is_zero:
                # self * c  =  omega^lead_e * (lead_c * c) + (rest of self)
                head = Ord.omega_pow(lead_e, lead_c * c)
                rest = Ord(self.terms[1:])
                out = out + head + rest
            else:
                out = out + Ord.omega_pow(lead_e + e, c)
        return out

    def omega_times(self) -> "Ord":
        """omega * self."""
        return OMEGA * self

    # -- display ------------------------------------------------------------

    def __repr__(self) -> str:
        if self.is_zero:
            return "0"
        pieces: List[str] = []
        for (e, c) in self.terms:
            if e.is_zero:
                pieces.append(str(c))
            else:
                if e == ONE:
                    base = "w"
                elif e.is_finite:
                    base = f"w^{e}"
                else:
                    base = f"w^({e})"
                pieces.append(base if c == 1 else f"{base}*{c}")
        return " + ".join(pieces)


ZERO = Ord.zero()
ONE = Ord.finite(1)
OMEGA = Ord.omega_pow(ONE)
OMEGA_SQ = Ord.omega_pow(Ord.finite(2))
OMEGA_OMEGA = Ord.omega_pow(OMEGA)


def omega_pow_nat(k: int) -> Ord:
    """omega^k for a natural number k."""
    return ONE if k == 0 else Ord.omega_pow(Ord.finite(k))


# ---------------------------------------------------------------------------
# 1. The refinement law and the finite hierarchy
# ---------------------------------------------------------------------------


def refine_value(v: Ord) -> Ord:
    """Survival value after one omega-refinement:  omega * v."""
    return OMEGA * v


def iterated_refinement_value(k: int, base: Ord) -> Ord:
    """Survival value of the k-fold refinement of a game of value `base`."""
    v = base
    for _ in range(k):
        v = refine_value(v)
    return v


def demo_hierarchy(max_k: int = 5) -> None:
    print("=" * 74)
    print("1. THE FINITE REFINEMENT HIERARCHY")
    print("=" * 74)
    print("Refining a clock replaces each of its moments by a whole copy of the")
    print("finite clock; the survival value is multiplied on the left by omega.\n")
    for k in range(max_k + 1):
        got = iterated_refinement_value(k, OMEGA)          # finite clock has value omega
        want = omega_pow_nat(k + 1)
        flag = "OK" if got == want else "MISMATCH"
        print(f"  k = {k}:  value = {got!r:>12}   predicted omega^{k+1} = {want!r:>12}  [{flag}]")
    print("\n  Strictness (Conjecture 2): omega^(j+1) < omega^(k+1) whenever j < k.")
    ok = all(
        iterated_refinement_value(j, OMEGA) < iterated_refinement_value(k, OMEGA)
        for j in range(max_k + 1)
        for k in range(j + 1, max_k + 1)
    )
    print(f"  all pairs 0 <= j < k <= {max_k} strictly increasing: {ok}")
    print()


# ---------------------------------------------------------------------------
# 2. Bounded-depth clocks: the k-fold lexicographic natural-number clock
# ---------------------------------------------------------------------------

Moment = Tuple[int, ...]  # a moment of natClock(k) is a k-tuple of naturals


def clock_reading(m: Moment) -> Ord:
    """
    The order-theoretic position (the `typein`) of a moment of the k-fold
    lexicographic natural-number clock:

        (n_1, ..., n_k)  |-->  omega^(k-1) n_1 + ... + omega n_(k-1) + n_k.

    The most significant coordinate is the leftmost one.
    """
    k = len(m)
    out = ZERO
    for i, n in enumerate(m):
        if n:
            out = out + Ord.omega_pow(Ord.finite(k - 1 - i), n)
    return out


def lex_less(a: Moment, b: Moment) -> bool:
    """Lexicographic order on equal-length tuples, most significant first."""
    return a < b


def sample_moments(k: int, bound: int) -> Iterator[Moment]:
    yield from product(range(bound), repeat=k)


def demo_bounded_depth_clocks(max_k: int = 3, bound: int = 4) -> None:
    print("=" * 74)
    print("2. BOUNDED-DEPTH CLOCKS AND THE EMBEDDING CHARACTERISATION")
    print("=" * 74)
    print("The k-fold clock is N^k in lexicographic order; its reading map is an")
    print("order isomorphism onto the ordinals below omega^k.  A game is clocked")
    print("by it exactly when its survival value is at most omega^k.\n")
    for k in range(1, max_k + 1):
        moments = list(sample_moments(k, bound))
        readings = [clock_reading(m) for m in moments]
        mono = all(
            (clock_reading(a) < clock_reading(b)) == lex_less(a, b)
            for a in moments
            for b in moments
            if a != b
        )
        below = all(r < omega_pow_nat(k) for r in readings)
        print(f"  k = {k}: reading map order-faithful on {len(moments)} sampled moments: {mono}")
        print(f"         every reading below omega^{k}: {below}")
    print("\n  Sample readings in the 3-fold clock:")
    for m in [(0, 0, 0), (0, 0, 7), (0, 2, 5), (1, 0, 0), (4, 3, 2)]:
        print(f"    {str(m):>12}  ->  {clock_reading(m)!r}")
    print()


# ---------------------------------------------------------------------------
# 3. The limit clock and the key function
# ---------------------------------------------------------------------------

LimitMoment = Tuple[int, Moment]  # <k, a> with a a moment of natClock(k)


def limit_key(x: LimitMoment) -> Ord:
    """key<k, a> = omega^k + reading(a)."""
    k, a = x
    return omega_pow_nat(k) + clock_reading(a)


def limit_lex_less(x: LimitMoment, y: LimitMoment) -> bool:
    """Lexicographic order on the dependent sum: compare depth first."""
    if x[0] != y[0]:
        return x[0] < y[0]
    return lex_less(x[1], y[1])


def demo_limit_clock(max_k: int = 3, bound: int = 3) -> None:
    print("=" * 74)
    print("3. THE LIMIT CLOCK HAS VALUE EXACTLY omega^omega")
    print("=" * 74)
    print("Stack all finite-depth clocks lexicographically.  The key function")
    print("key<k, a> = omega^k + reading(a) is strictly increasing and lands")
    print("strictly below omega^omega, which bounds the value; the individual")
    print("depths are cofinal, which forces equality.\n")
    pts: List[LimitMoment] = []
    for k in range(1, max_k + 1):
        for a in sample_moments(k, bound):
            pts.append((k, a))
    mono = all(
        (limit_key(x) < limit_key(y)) == limit_lex_less(x, y)
        for x in pts
        for y in pts
        if x != y
    )
    below = all(limit_key(x) < OMEGA_OMEGA for x in pts)
    print(f"  key strictly monotone on {len(pts)} sampled moments: {mono}")
    print(f"  every key strictly below omega^omega:              {below}")
    print(f"  depths cofinal:  omega^k < omega^omega for all k:  "
          f"{all(omega_pow_nat(k) < OMEGA_OMEGA for k in range(12))}")
    print("\n  Sample keys:")
    for x in [(1, (0,)), (1, (5,)), (2, (0, 0)), (2, (3, 1)), (4, (1, 0, 0, 2))]:
        print(f"    <{x[0]}, {x[1]}>  ->  {limit_key(x)!r}")
    print("\n  Conclusion: limit clock value = omega^omega, and for every k")
    for k in range(4):
        print(f"    omega^{k+1} = {omega_pow_nat(k+1)!r:>8} < omega^omega "
              f"({omega_pow_nat(k + 1) < OMEGA_OMEGA})")
    print()


# ---------------------------------------------------------------------------
# 4. The fixed point: refinement does not always help
# ---------------------------------------------------------------------------


def demo_fixed_point() -> None:
    print("=" * 74)
    print("4. THE FIXED POINT: REFINEMENT IS NOT ALWAYS A GAIN")
    print("=" * 74)
    lhs = OMEGA * OMEGA_OMEGA
    print(f"  omega * omega^omega = {lhs!r}    equals omega^omega: {lhs == OMEGA_OMEGA}")
    print("  So refining the limit clock buys Mortal not one extra round: the")
    print("  naive claim `refinement always strictly increases survival' is FALSE.\n")
    print("  Refinement stability of omega^a  <=>  omega <= a:")
    for a, name in [(ZERO, "0"), (ONE, "1"), (Ord.finite(7), "7"), (OMEGA, "omega"),
                    (OMEGA + ONE, "omega+1"), (OMEGA_SQ, "omega^2")]:
        stable = (OMEGA * Ord.omega_pow(a)) == Ord.omega_pow(a)
        predicted = OMEGA <= a
        print(f"    a = {name:>8}:  omega*omega^a = omega^a ? {str(stable):>5}   "
              f"criterion (omega <= a): {str(predicted):>5}   "
              f"[{'OK' if stable == predicted else 'MISMATCH'}]")
    print()


# ---------------------------------------------------------------------------
# 5. Concatenation of lives is non-commutative
# ---------------------------------------------------------------------------


def demo_concatenation() -> None:
    print("=" * 74)
    print("5. CONCATENATION OF LIVES IS NON-COMMUTATIVE")
    print("=" * 74)
    a = OMEGA + ONE   # an omega-life followed by one extra moment
    b = ONE + OMEGA   # one moment, then an omega-life
    print(f"  omega + 1 = {a!r}")
    print(f"  1 + omega = {b!r}")
    print(f"  equal? {a == b};   omega + 1 > omega: {OMEGA < a};   1 + omega = omega: {b == OMEGA}")
    print("  A moment tacked on AFTER an endless life is a genuine gain;")
    print("  the same moment placed BEFORE it is invisible.\n")


# ---------------------------------------------------------------------------
# 6. The monotone transfinite machine with closure ordinal omega^2
# ---------------------------------------------------------------------------

Cell = Tuple[int, int]  # cell (m, n) has arrival time omega*m + n


def arrival(cell: Cell) -> Ord:
    m, n = cell
    return (OMEGA * Ord.finite(m)) + Ord.finite(n)


def decode_cell(alpha: Ord) -> Cell:
    """The unique cell whose arrival time is alpha, for alpha < omega^2."""
    if not alpha < OMEGA_SQ:
        raise ValueError("only cells below omega^2 exist")
    m = 0
    for (e, c) in alpha.terms:
        if e == ONE:
            m = c
    return (m, alpha.finite_part)


def stage_contains(alpha: Ord, cell: Cell) -> bool:
    """Closed form of the stages: cell is on at time alpha iff arrival <= alpha."""
    return arrival(cell) <= alpha


def step(on: Iterable[Cell], universe: Sequence[Cell]) -> List[Cell]:
    """One transition: a cell switches on once all strictly earlier cells are on."""
    on_set = set(on)
    out: List[Cell] = []
    for c in universe:
        if all(d in on_set for d in universe if arrival(d) < arrival(c)):
            out.append(c)
    return out


def demo_machine(rows: int = 3, cols: int = 6) -> None:
    print("=" * 74)
    print("6. A MONOTONE TRANSFINITE MACHINE WITH CLOSURE ORDINAL omega^2")
    print("=" * 74)
    print("Cells are the moments of the omega^2 clock: cell (m, n) has arrival")
    print("time omega*m + n.  A cell switches on once all strictly earlier cells")
    print("are on; at limit times the machine unions all earlier configurations.\n")
    universe = [(m, n) for m in range(rows) for n in range(cols)]
    universe.sort(key=lambda c: (c[0], c[1]))

    # verify the closed form against a direct simulation on finite initial times
    print("  Successor rule agrees with the closed form on finite times:")
    ok = True
    for t in range(cols):
        alpha = Ord.finite(t)
        closed = {c for c in universe if stage_contains(alpha, c)}
        simulated = set(step({c for c in universe if stage_contains(Ord.finite(t - 1), c)}
                             if t > 0 else set(), universe))
        # restrict the comparison to the finite window actually determined
        closed_w = {c for c in closed if c[0] == 0}
        simulated_w = {c for c in simulated if c[0] == 0}
        ok = ok and closed_w == simulated_w
    print(f"    {ok}\n")

    print("  Stages (rows = the omega-blocks m, columns = offsets n, '#' = on):")
    for label, alpha in [("t = 0", ZERO), ("t = 3", Ord.finite(3)),
                         ("t = omega", OMEGA), ("t = omega+2", OMEGA + Ord.finite(2)),
                         ("t = omega*2", OMEGA * Ord.finite(2))]:
        print(f"    {label:>12}: ", end="")
        for m in range(rows):
            row = "".join("#" if stage_contains(alpha, (m, n)) else "." for n in range(cols))
            print(f"[{row}]", end=" ")
        print()
    print()
    print("  No stage below omega^2 is terminal: for every alpha < omega^2 the")
    print("  cell with arrival time alpha+1 is off at alpha and on at alpha+1.")
    for alpha in [ZERO, Ord.finite(5), OMEGA, OMEGA * Ord.finite(3) + Ord.finite(2)]:
        succ = alpha + ONE
        witness = decode_cell(succ)
        appears = (not stage_contains(alpha, witness)) and stage_contains(succ, witness)
        print(f"    alpha = {alpha!r:>14}:  alpha+1 = {succ!r:>16} < omega^2: "
              f"{succ < OMEGA_SQ}   new cell {str(witness):>8} appears: {appears}")
    print("\n  At time omega^2 every cell is on, so the machine is terminal there;")
    print("  hence its closure ordinal is exactly omega^2, which is precisely the")
    print("  survival value of the bounded-nondeterministic game it realises.\n")


# ---------------------------------------------------------------------------
# 7. The general limit theorem: cofinal chains in additively principal ordinals
# ---------------------------------------------------------------------------


def demo_general_limit(max_k: int = 5) -> None:
    print("=" * 74)
    print("7. THE GENERAL LIMIT THEOREM")
    print("=" * 74)
    print("If the lives A_0, A_1, ... are played one after another and o is")
    print("additively principal (o = omega^a), with every value(A_k) < o and the")
    print("values cofinal in o, then the concatenated life has value exactly o.")
    print("We check the two hypotheses for A_k = the k-fold clock, o = omega^omega,")
    print("by following the running landmarks L_0 = 0, L_(k+1) = L_k + value(A_k).\n")
    landmark = ZERO
    for k in range(max_k + 1):
        val = omega_pow_nat(k)
        print(f"  landmark L_{k} = {landmark!r:<28} value(A_{k}) = omega^{k} = {val!r:<10} "
              f"L_{k} < omega^omega: {landmark < OMEGA_OMEGA}")
        landmark = landmark + val
    print("\n  Landmarks stay below omega^omega (additive principality), and")
    print("  omega^k is cofinal in omega^omega, so the total value is omega^omega.\n")


def main() -> None:
    demo_hierarchy()
    demo_bounded_depth_clocks()
    demo_limit_clock()
    demo_fixed_point()
    demo_concatenation()
    demo_machine()
    demo_general_limit()
    print("=" * 74)
    print("All demonstrations completed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
