"""
Numerical demonstrations for:

    A Constructive Bridge Between Three Faces of Ordinal Analysis
    (Well-Ordering, Termination, and the Fast-Growing Hierarchy)

This module is fully self-contained (standard library only) and illustrates,
with concrete computation, the results of the package:

  * Ordinals below epsilon-0 in Cantor normal form (CNF), with exact comparison.
  * The well-ordering property: descending chains always reach 0 (no infinite
    descent).
  * The termination engine `terminates_of_measure` (Theorem 2) and its
    self-descent specialisation (Theorem 3).
  * The fast-growing hierarchy F_a, the certified values F1(3)=6, F2(2)=8, and
    the slow-level closed forms F1(n)=2n, F2(n)=n*2^n.
  * Goodstein sequences as an epsilon-0 monovariant instance (Direction 1).
  * The Kirby-Paris Hydra as the same engine (Direction 2).

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from functools import total_ordering
from typing import Callable, List, Tuple, TypeVar


# ---------------------------------------------------------------------------
# 1. Ordinals below epsilon-0 in Cantor normal form
# ---------------------------------------------------------------------------
#
# An ordinal alpha < epsilon_0 is represented as a list of terms
#     [(e_1, c_1), (e_2, c_2), ..., (e_k, c_k)]
# meaning  omega^(e_1)*c_1 + ... + omega^(e_k)*c_k,
# where each e_i is itself an `Ordinal` (a smaller CNF), the c_i are positive
# ints, and the exponents are strictly decreasing.  The empty list is 0.


@total_ordering
@dataclass(frozen=True)
class Ordinal:
    """An ordinal below epsilon-0 in Cantor normal form.

    `terms` is a tuple of (exponent, coefficient) pairs in strictly decreasing
    order of exponent. The empty tuple denotes the ordinal 0.
    """

    terms: Tuple[Tuple["Ordinal", int], ...]

    # --- constructors -----------------------------------------------------
    @staticmethod
    def zero() -> "Ordinal":
        return Ordinal(())

    @staticmethod
    def from_nat(n: int) -> "Ordinal":
        """The finite ordinal n = omega^0 * n."""
        if n == 0:
            return Ordinal.zero()
        return Ordinal(((Ordinal.zero(), n),))

    @staticmethod
    def omega() -> "Ordinal":
        """omega = omega^1 * 1."""
        return Ordinal(((Ordinal.from_nat(1), 1),))

    @staticmethod
    def omega_pow(exp: "Ordinal", coeff: int = 1) -> "Ordinal":
        """omega^exp * coeff for coeff >= 1."""
        return Ordinal(((exp, coeff),))

    # --- predicates -------------------------------------------------------
    def is_zero(self) -> bool:
        return len(self.terms) == 0

    # --- comparison (the order whose well-foundedness drives everything) --
    def __eq__(self, other: object) -> bool:
        return isinstance(other, Ordinal) and self.terms == other.terms

    def __lt__(self, other: "Ordinal") -> bool:
        return _cmp(self, other) < 0

    def __hash__(self) -> int:
        return hash(self.terms)

    # --- arithmetic used by the demos ------------------------------------
    def __add__(self, other: "Ordinal") -> "Ordinal":
        return _add(self, other)

    def __repr__(self) -> str:
        return _show(self)


def _cmp(a: Ordinal, b: Ordinal) -> int:
    """Lexicographic comparison of CNFs: returns -1, 0, or +1."""
    ta, tb = a.terms, b.terms
    i = 0
    while i < len(ta) and i < len(tb):
        (ea, ca), (eb, cb) = ta[i], tb[i]
        c = _cmp(ea, eb)
        if c != 0:
            return c
        if ca != cb:
            return -1 if ca < cb else 1
        i += 1
    if len(ta) == len(tb):
        return 0
    return -1 if len(ta) < len(tb) else 1


def _add(a: Ordinal, b: Ordinal) -> Ordinal:
    """Ordinal (non-commutative) addition in CNF."""
    if a.is_zero():
        return b
    if b.is_zero():
        return a
    # The leading exponent of b absorbs all smaller-or-equal leading terms of a.
    lead_b_exp = b.terms[0][0]
    kept = [(e, c) for (e, c) in a.terms if _cmp(e, lead_b_exp) > 0]
    # If a has a term with the SAME leading exponent as b, coefficients add.
    same = [(e, c) for (e, c) in a.terms if _cmp(e, lead_b_exp) == 0]
    new_terms = list(kept)
    if same:
        merged_coeff = same[0][1] + b.terms[0][1]
        new_terms.append((lead_b_exp, merged_coeff))
        new_terms.extend(b.terms[1:])
    else:
        new_terms.extend(b.terms)
    return Ordinal(tuple(new_terms))


def _show(a: Ordinal) -> str:
    if a.is_zero():
        return "0"
    parts: List[str] = []
    for (e, c) in a.terms:
        if e.is_zero():
            parts.append(str(c))
        elif e == Ordinal.from_nat(1):
            parts.append("w" if c == 1 else f"w*{c}")
        else:
            base = f"w^({_show(e)})"
            parts.append(base if c == 1 else f"{base}*{c}")
    return " + ".join(parts)


# ---------------------------------------------------------------------------
# 2. Well-ordering: any descending chain reaches 0 (Theorem 1 / Theorem 3)
# ---------------------------------------------------------------------------

T = TypeVar("T")


def terminates_of_measure(
    step: Callable[[T], T],
    mu: Callable[[T], Ordinal],
    x0: T,
    max_steps: int = 10_000_000,
) -> Tuple[int, T]:
    """Theorem 2 (Termination by ordinal measure), executable form.

    Iterate `step` until the ordinal measure `mu` hits 0, returning the number
    of steps and the final state.  The theory guarantees this loop terminates
    whenever `mu(x) != 0 => mu(step x) < mu(x)`; we additionally guard each
    step with an assertion that the measure strictly decreased.
    """
    x = x0
    n = 0
    while not mu(x).is_zero():
        nxt = step(x)
        assert mu(nxt) < mu(x), "monovariant failed to strictly decrease!"
        x = nxt
        n += 1
        if n > max_steps:
            raise RuntimeError("exceeded max_steps (should be impossible)")
    return n, x


def terminates_of_self_descent(
    step: Callable[[Ordinal], Ordinal],
    x0: Ordinal,
    max_steps: int = 10_000_000,
) -> int:
    """Theorem 3: the mu = identity specialisation on the notation system."""
    n, _ = terminates_of_measure(step, lambda o: o, x0, max_steps)
    return n


# ---------------------------------------------------------------------------
# 3. The fast-growing hierarchy F_a : N -> N  (finite levels)
# ---------------------------------------------------------------------------
#
# F_0(n) = n + 1
# F_{k+1}(n) = F_k^[n](n)   (iterate F_k n times, starting at n)


def fast_growing(level: int, n: int) -> int:
    """F_level(n) for finite (natural-number) level >= 0."""
    if level == 0:
        return n + 1
    value = n
    for _ in range(n):  # iterate F_{level-1} exactly n times
        value = fast_growing(level - 1, value)
    return value


def fast_growing_F1_closed(n: int) -> int:
    """Closed form, Proposition 5:  F_1(n) = 2n."""
    return 2 * n


def fast_growing_F2_closed(n: int) -> int:
    """Closed form, Proposition 6:  F_2(n) = n * 2^n."""
    return n * (2 ** n)


# ---------------------------------------------------------------------------
# 4. Goodstein sequences as an epsilon-0 monovariant (Direction 1)
# ---------------------------------------------------------------------------


def hereditary_base(n: int, base: int) -> Ordinal:
    """Map n, written in hereditary base `base`, to the ordinal obtained by
    replacing every occurrence of `base` with omega.  This is the Goodstein
    ordinal assignment mu."""
    if n == 0:
        return Ordinal.zero()
    terms: List[Tuple[Ordinal, int]] = []
    # write n in base `base`: n = sum digit_i * base^i
    digits: List[int] = []
    m = n
    while m > 0:
        digits.append(m % base)
        m //= base
    # build CNF from high power to low; exponent is hereditary-base of the power i
    for i in range(len(digits) - 1, -1, -1):
        d = digits[i]
        if d != 0:
            exp = hereditary_base(i, base)  # exponent itself hereditarily expanded
            terms.append((exp, d))
    return Ordinal(tuple(terms))


def goodstein_sequence(start: int, length: int) -> List[Tuple[int, int, Ordinal]]:
    """Return up to `length` entries (base, value, ordinal) of the Goodstein
    sequence starting from `start`.  Stops early at 0."""
    out: List[Tuple[int, int, Ordinal]] = []
    value = start
    base = 2
    for _ in range(length):
        ordv = hereditary_base(value, base)
        out.append((base, value, ordv))
        if value == 0:
            break
        # Goodstein step: bump base, then subtract 1, written in hereditary base.
        value = _bump_base(value, base, base + 1) - 1
        base += 1
    return out


def _bump_base(n: int, old: int, new: int) -> int:
    """Rewrite n in hereditary base `old`, then read it in base `new`."""
    if n == 0:
        return 0
    digits: List[int] = []
    m = n
    while m > 0:
        digits.append(m % old)
        m //= old
    total = 0
    for i in range(len(digits) - 1, -1, -1):
        d = digits[i]
        if d != 0:
            total += d * (new ** _bump_base(i, old, new))
    return total


# ---------------------------------------------------------------------------
# 5. The Kirby-Paris Hydra as the same engine (Direction 2)
# ---------------------------------------------------------------------------
#
# A hydra is a finite rooted tree.  We represent it as a (possibly empty) list
# of child hydras.  Its ordinal rank is omega^(rank child_1) + ... (children in
# decreasing rank order).


@dataclass(frozen=True)
class Hydra:
    children: Tuple["Hydra", ...] = ()

    @staticmethod
    def leaf() -> "Hydra":
        return Hydra(())

    def is_leaf(self) -> bool:
        return len(self.children) == 0


def hydra_rank(h: Hydra) -> Ordinal:
    """Recursive ordinal rank of a hydra (the descent measure)."""
    if h.is_leaf():
        return Ordinal.zero()
    child_ranks = sorted((hydra_rank(c) for c in h.children), reverse=True)
    acc = Ordinal.zero()
    for r in child_ranks:
        acc = acc + Ordinal.omega_pow(r, 1)
    return acc


def hydra_chop(h: Hydra, stage: int) -> Hydra:
    """Hercules chops the left-most top head; the grandparent regrows `stage`
    copies of the affected subtree.  Returns the new hydra.  (A simplified but
    faithful chop-and-regrow rule sufficient to demonstrate ordinal descent.)"""
    new, _ = _chop(h, stage)
    return new


def _chop(h: Hydra, stage: int) -> Tuple[Hydra, bool]:
    # Find a node that has at least one leaf child (a top head to chop).
    leaf_idx = next((i for i, c in enumerate(h.children) if c.is_leaf()), None)
    if leaf_idx is not None:
        # Chop one leaf child of h.
        remaining = list(h.children)
        del remaining[leaf_idx]
        # Regrow: `stage` copies of the remaining node `h` (without that head)
        # are NOT added at the root for the root case; for a non-root node the
        # caller handles regrowth.  Here we just remove the head.
        return Hydra(tuple(remaining)), True
    # Otherwise recurse into a child; on success, regrow `stage` copies of the
    # *modified* child at this level.
    for i, c in enumerate(h.children):
        new_c, did = _chop(c, stage)
        if did:
            kids = list(h.children)
            kids[i] = new_c
            # regrow `stage - 1` extra copies of new_c next to it
            for _ in range(max(stage - 1, 0)):
                kids.append(new_c)
            return Hydra(tuple(kids)), True
    return h, False


def hydra_battle(h: Hydra, max_rounds: int = 100000) -> int:
    """Hercules vs Hydra: chop until only the root (a single leaf) remains.
    Returns the number of rounds.  Terminates by ordinal descent of the rank."""
    stage = 1
    rounds = 0
    while not h.is_leaf():
        before = hydra_rank(h)
        h = hydra_chop(h, stage)
        after = hydra_rank(h)
        assert after < before, "hydra rank failed to strictly decrease!"
        stage += 1
        rounds += 1
        if rounds > max_rounds:
            raise RuntimeError("hydra battle ran too long")
    return rounds


# ---------------------------------------------------------------------------
# 6. Demonstrations
# ---------------------------------------------------------------------------


def demo_certified_values() -> None:
    print("=" * 70)
    print("Fast-growing hierarchy: certified values and closed forms")
    print("=" * 70)
    print(f"  F_0(n) = n + 1     ->  F_0(5)  = {fast_growing(0, 5)}")
    print(f"  F_1(3) = 6 ?        ->  {fast_growing(1, 3)}   (Theorem 7)")
    print(f"  F_2(2) = 8 ?        ->  {fast_growing(2, 2)}   (Theorem 7)")
    print("  Closed form F_1(n) = 2n :")
    for n in range(6):
        assert fast_growing(1, n) == fast_growing_F1_closed(n)
        print(f"     F_1({n}) = {fast_growing(1, n):>3}  = 2*{n}")
    print("  Closed form F_2(n) = n*2^n :")
    for n in range(6):
        assert fast_growing(2, n) == fast_growing_F2_closed(n)
        print(f"     F_2({n}) = {fast_growing(2, n):>5}  = {n}*2^{n}")
    print(f"  A glimpse of the explosion: F_3(2) = {fast_growing(3, 2)}")
    print("     (F_3 is tower-type growth; F_omega is Ackermann-class.)")
    print()


def is_successor(o: Ordinal) -> bool:
    """True iff o > 0 and its smallest term is finite (omega^0)."""
    return (not o.is_zero()) and o.terms[-1][0].is_zero()


def predecessor(o: Ordinal) -> Ordinal:
    """For a successor ordinal, subtract one."""
    terms = list(o.terms)
    e, c = terms[-1]
    assert e.is_zero()
    if c > 1:
        terms[-1] = (e, c - 1)
    else:
        terms.pop()
    return Ordinal(tuple(terms))


def fundamental_sequence(o: Ordinal, n: int) -> Ordinal:
    """The n-th element of the canonical fundamental sequence of a LIMIT ordinal
    o < epsilon_0.  It is strictly below o and increases with n, with supremum o.
    """
    assert not o.is_zero() and not is_successor(o), "fundamental_sequence: not a limit"
    terms = list(o.terms)
    head = terms[:-1]
    e, c = terms[-1]  # smallest term omega^e * c, with e > 0
    if is_successor(e):
        # omega^(e) = omega^(e-1) * omega; n-th element multiplies by n.
        e_pred = predecessor(e)
        tail = [(e, c - 1)] if c > 1 else []
        if n > 0:
            tail.append((e_pred, n))
        return Ordinal(tuple(head + tail))
    else:
        # e is a limit: descend in the exponent.
        e_seq = fundamental_sequence(e, n)
        tail = [(e, c - 1)] if c > 1 else []
        tail.append((e_seq, 1))
        return Ordinal(tuple(head + tail))


def demo_self_descent() -> None:
    print("=" * 70)
    print("Termination by self-descent (Theorem 3): a Hardy-style descent")
    print("=" * 70)
    # State carries the ordinal AND the unfolding index n (it climbs as we go).
    start_ord = Ordinal.omega_pow(Ordinal.from_nat(1), 2) + Ordinal.from_nat(2)
    print(f"  start ordinal: {start_ord}")

    State = Tuple[Ordinal, int]

    def mu(s: State) -> Ordinal:
        return s[0]

    def step(s: State) -> State:
        o, k = s
        if o.is_zero():
            return s
        if is_successor(o):
            return (predecessor(o), k)
        return (fundamental_sequence(o, k), k + 1)

    n, _ = terminates_of_measure(step, mu, (start_ord, 2))
    print(f"  reached 0 after {n} steps -- exactly as Theorem 3/2 guarantees.")
    print("  (Each step either takes a predecessor or unfolds a limit ordinal")
    print("   via its fundamental sequence; the ordinal strictly descends.)")
    print()


def demo_no_infinite_descent() -> None:
    print("=" * 70)
    print("Well-ordering: a generic measure-driven process halts (Theorem 2)")
    print("=" * 70)
    # State = pair (a, b) of naturals; measure mu(a,b) = w*a + b.
    State = Tuple[int, int]

    def mu(s: State) -> Ordinal:
        a, b = s
        return Ordinal.omega_pow(Ordinal.from_nat(1), a) + Ordinal.from_nat(b) \
            if a > 0 else Ordinal.from_nat(b)

    def step(s: State) -> State:
        a, b = s
        if b > 0:
            return (a, b - 1)        # decrease b
        return (a - 1, 5)            # b hit 0: drop a, reset b to 5 (still smaller!)

    n, final = terminates_of_measure(step, mu, (3, 4))
    print("  state = (a,b), measure mu(a,b) = w*a + b")
    print(f"  start (3,4) -> halts at {final} after {n} steps.")
    print("  Note b RESETS upward to 5 each time a drops; the natural-number")
    print("  view sees growth, yet the ordinal measure strictly descends.")
    print()


def demo_goodstein() -> None:
    print("=" * 70)
    print("Goodstein sequence from 4: numbers explode, the ordinal descends")
    print("=" * 70)
    seq = goodstein_sequence(4, 8)
    print(f"  {'base':>4}  {'value':>12}  ordinal (mu)")
    prev = None
    for (base, value, ordv) in seq:
        flag = ""
        if prev is not None:
            flag = "  (mu decreased)" if ordv < prev else "  (mu NOT down!)"
        print(f"  {base:>4}  {value:>12}  {ordv}{flag}")
        prev = ordv
    print("  The raw value rockets upward; mu (the omega-form) strictly falls,")
    print("  so by Theorem 2 the sequence must eventually reach 0.")
    print()


def demo_hydra() -> None:
    print("=" * 70)
    print("Kirby-Paris Hydra: Hercules always wins (Direction 2)")
    print("=" * 70)
    # A small hydra: root with two children, one of which is a small subtree.
    h = Hydra((
        Hydra((Hydra.leaf(), Hydra.leaf())),
        Hydra.leaf(),
    ))
    print(f"  initial hydra rank: {hydra_rank(h)}")
    rounds = hydra_battle(h)
    print(f"  Hercules wins after {rounds} rounds; the rank strictly fell each")
    print("  round, so by the ordinal engine victory is guaranteed.")
    print()


def main() -> None:
    demo_certified_values()
    demo_self_descent()
    demo_no_infinite_descent()
    demo_goodstein()
    demo_hydra()
    print("All demonstrations completed: ordinal descent certifies termination.")


if __name__ == "__main__":
    main()
