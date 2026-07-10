"""
Transfinite Game Values in Infinite Chess
=========================================

A self-contained numerical/symbolic demonstration of the ordinal game-value
hierarchy for infinite chess.

We model winning game trees with three node types:

    * ``mate``      -- checkmate delivered (value 0),
    * ``step g``    -- a WINNER (White) node with a single forced continuation g
                       (value = value(g) + 1),
    * ``bsup f``    -- a LOSER (Black) node offering a countable family of
                       continuations (value = sup_n (value(f(n)) + 1)).

To compute values exactly we represent ordinals below omega^omega in Cantor
normal form (CNF) as strictly-descending lists of (exponent, coefficient) terms:

    omega^{e_1} * c_1 + omega^{e_2} * c_2 + ...   with e_1 > e_2 > ... >= 0.

For example:
    0            -> []
    1            -> [(0, 1)]
    omega        -> [(1, 1)]
    omega^2 * 3 + omega * 5 + 7 -> [(2, 3), (1, 5), (0, 7)]

Suprema of the monotone families that arise here are limits: the leading
Cantor term grows, so the supremum of ``omega^n * k + 1`` over k is ``omega^{n+1}``
and the supremum of ``omega^n + 1`` over n is ``omega^omega`` (written here as the
formal top element).

This script builds the positions of value omega, omega^n, and omega^omega, and
verifies their values against the closed forms, plus the strict hierarchy.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List, Tuple, Union


# --------------------------------------------------------------------------- #
# Ordinals below omega^omega in Cantor normal form, plus a formal top omega^omega
# --------------------------------------------------------------------------- #

# A CNF ordinal is a list of (exponent, coefficient) pairs, exponents strictly
# decreasing, coefficients positive integers.
CNF = List[Tuple[int, int]]


@dataclass(frozen=True)
class Ordinal:
    """An ordinal < omega^omega (finite CNF) or the formal top omega^omega."""
    cnf: Tuple[Tuple[int, int], ...]
    is_omega_omega: bool = False

    # ---- constructors -------------------------------------------------- #
    @staticmethod
    def zero() -> "Ordinal":
        return Ordinal(cnf=())

    @staticmethod
    def nat(n: int) -> "Ordinal":
        return Ordinal(cnf=() if n == 0 else ((0, n),))

    @staticmethod
    def omega_pow(e: int) -> "Ordinal":
        """omega ** e for a natural number e."""
        return Ordinal(cnf=((e, 1),))

    @staticmethod
    def omega_omega() -> "Ordinal":
        return Ordinal(cnf=(), is_omega_omega=True)

    # ---- display ------------------------------------------------------- #
    def __str__(self) -> str:
        if self.is_omega_omega:
            return "omega^omega"
        if not self.cnf:
            return "0"
        parts: List[str] = []
        for e, c in self.cnf:
            if e == 0:
                parts.append(str(c))
            elif e == 1:
                term = "omega"
                parts.append(term if c == 1 else f"omega*{c}")
            else:
                term = f"omega^{e}"
                parts.append(term if c == 1 else f"omega^{e}*{c}")
        return " + ".join(parts)

    # ---- comparison ---------------------------------------------------- #
    def _key(self) -> Tuple[int, Tuple[Tuple[int, int], ...]]:
        # omega^omega dominates everything below it.
        return (1, ()) if self.is_omega_omega else (0, self.cnf)

    def __lt__(self, other: "Ordinal") -> bool:
        if self.is_omega_omega or other.is_omega_omega:
            return (not self.is_omega_omega) and other.is_omega_omega
        # Lexicographic on (exponent, coefficient) with padding.
        a, b = list(self.cnf), list(other.cnf)
        for (ea, ca), (eb, cb) in zip(a, b):
            if ea != eb:
                return ea < eb
            if ca != cb:
                return ca < cb
        return len(a) < len(b)

    def __eq__(self, other: object) -> bool:  # type: ignore[override]
        return isinstance(other, Ordinal) and self._key() == other._key()


def ord_add(a: Ordinal, b: Ordinal) -> Ordinal:
    """Ordinal addition a + b (order matters!). Below omega^omega only."""
    if a.is_omega_omega or b.is_omega_omega:
        return Ordinal.omega_omega()
    if not b.cnf:
        return a
    if not a.cnf:
        return b
    lead_b = b.cnf[0][0]
    # Every term of a with exponent < lead_b is absorbed (left summand rule).
    kept = [(e, c) for (e, c) in a.cnf if e > lead_b]
    # Terms of a with exponent == lead_b merge with b's leading term.
    same = [c for (e, c) in a.cnf if e == lead_b]
    result: CNF = list(kept)
    if same:
        e = lead_b
        merged_coeff = same[0] + b.cnf[0][1]
        result.append((e, merged_coeff))
        result.extend(b.cnf[1:])
    else:
        result.extend(b.cnf)
    return Ordinal(cnf=tuple(result))


def ord_succ(a: Ordinal) -> Ordinal:
    """a + 1."""
    return ord_add(a, Ordinal.nat(1))


def _coeff_of(a: Ordinal, e: int) -> int:
    """Coefficient of omega^e in the CNF of ``a`` (0 if absent)."""
    for (ee, cc) in a.cnf:
        if ee == e:
            return cc
    return 0


def _below(a: Ordinal, e: int) -> Ordinal:
    """The part of ``a`` strictly below omega^e."""
    return Ordinal(cnf=tuple((ee, cc) for (ee, cc) in a.cnf if ee < e))


def ord_sup(values: List[Ordinal]) -> Ordinal:
    """Exact supremum (limit) of a monotone increasing family of ordinals,
    inferred from finitely many samples.

    Algorithm (recursion on the leading exponent):
      * if the leading exponent grows across the tail -> omega^omega;
      * else, at the stable leading exponent e, if the coefficient of omega^e
        grows unboundedly -> omega^(e+1);
      * else the leading term omega^e * c is fixed: peel it off and recurse on
        the strictly-lower remainder.
    """
    if not values:
        return Ordinal.zero()
    if any(v.is_omega_omega for v in values):
        return Ordinal.omega_omega()
    # Deduplicate consecutive repeats while preserving order.
    seq: List[Ordinal] = []
    for v in values:
        if not seq or seq[-1] != v:
            seq.append(v)
    if len(seq) == 1:
        return seq[0]  # eventually constant
    a, b = seq[-2], seq[-1]  # last two distinct terms reveal the growth mode
    ea = a.cnf[0][0] if a.cnf else -1
    eb = b.cnf[0][0] if b.cnf else -1
    if eb > ea:
        return Ordinal.omega_omega()
    e = eb
    if _coeff_of(b, e) > _coeff_of(a, e):
        return Ordinal.omega_pow(e + 1)
    c = _coeff_of(b, e)
    head = Ordinal(cnf=((e, c),))
    return ord_add(head, ord_sup([_below(v, e) for v in seq]))


# --------------------------------------------------------------------------- #
# Game trees
# --------------------------------------------------------------------------- #

# Every constructed game is pinned in this registry so its ``id`` stays stable
# for the duration of a run; this makes the identity-keyed value memo sound
# (otherwise transient nodes could be garbage-collected and their ids reused).
_REGISTRY: List[object] = []


@dataclass
class Mate:
    def __post_init__(self) -> None:
        _REGISTRY.append(self)


@dataclass
class Step:
    child: "Game"

    def __post_init__(self) -> None:
        _REGISTRY.append(self)


@dataclass
class Bsup:
    # A countable family; we carry an explicit generator and a truncation bound
    # sufficient to detect the limit for the monotone families we build.
    family: Callable[[int], "Game"]
    bound: int

    def __post_init__(self) -> None:
        _REGISTRY.append(self)


@dataclass
class Graft:
    """Lazy sequential composition: play ``a`` then ``b``. Its value is computed
    via the additivity theorem value(graft a b) = value(b) + value(a), which is
    verified structurally against ``graft_materialize`` on small trees below."""
    a: "Game"
    b: "Game"

    def __post_init__(self) -> None:
        _REGISTRY.append(self)


Game = Union[Mate, Step, Bsup, Graft]


def value(g: Game) -> Ordinal:
    """Ordinal game value of a game tree (exact for the constructions here).

    Uses a per-call memo keyed by object identity, so shared subtrees (e.g. the
    repeated copies inside an iterated graft) are evaluated only once.
    """
    return _value(g, {})


def _value(g: Game, memo: dict) -> Ordinal:
    key = id(g)
    cached = memo.get(key)
    if cached is not None:
        return cached
    if isinstance(g, Mate):
        res: Ordinal = Ordinal.zero()
    elif isinstance(g, Step):
        res = ord_succ(_value(g.child, memo))
    elif isinstance(g, Graft):
        # Additivity under sequential composition (outer game on the right).
        res = ord_add(_value(g.b, memo), _value(g.a, memo))
    elif isinstance(g, Bsup):
        vals = [ord_succ(_value(g.family(n), memo)) for n in range(g.bound)]
        # The families we build are monotone; ord_sup returns the exact limit.
        res = ord_sup(vals)
    else:
        raise TypeError(f"unknown game node: {g!r}")
    memo[key] = res
    return res


# --------------------------------------------------------------------------- #
# Constructions
# --------------------------------------------------------------------------- #

def graft(a: Game, b: Game) -> Game:
    """Sequential composition as a lazy node (fast; value via additivity)."""
    return Graft(a, b)


def graft_materialize(a: Game, b: Game) -> Game:
    """The honest structural definition: replace every mate leaf of ``a`` with a
    fresh copy of ``b``. Used to verify additivity on small trees."""
    if isinstance(a, Mate):
        return b
    if isinstance(a, Step):
        return Step(graft_materialize(a.child, b))
    if isinstance(a, Bsup):
        fam = a.family
        return Bsup(lambda n, fam=fam: graft_materialize(fam(n), b), a.bound)
    if isinstance(a, Graft):
        return graft_materialize(materialize(a), b)
    raise TypeError


def materialize(g: Game) -> Game:
    """Turn lazy Graft nodes into explicit trees (for small trees only)."""
    if isinstance(g, Graft):
        return graft_materialize(materialize(g.a), materialize(g.b))
    if isinstance(g, Step):
        return Step(materialize(g.child))
    if isinstance(g, Bsup):
        fam = g.family
        return Bsup(lambda n, fam=fam: materialize(fam(n)), g.bound)
    return g


def step_n(n: int, g: Game) -> Game:
    for _ in range(n):
        g = Step(g)
    return g


def fin_game(n: int) -> Game:
    """A forced win in exactly n moves (value n)."""
    return step_n(n, Mate())


def graft_n(k: int, a: Game) -> Game:
    """k sequential copies of a (value = value(a) * k)."""
    g: Game = Mate()
    for _ in range(k):
        g = graft(a, g)
    return g


BSUP_BOUND = 6  # enough terms to reveal each limit


def omega_game() -> Game:
    """Black picks n; White mates in n forced moves. Value = omega."""
    return Bsup(fin_game, BSUP_BOUND)


def opow_game(n: int) -> Game:
    """Explicit position of value omega^n."""
    if n == 0:
        return Step(Mate())
    prev = opow_game(n - 1)
    return Bsup(lambda k, prev=prev: graft_n(k, prev), BSUP_BOUND)


def omega_omega_game() -> Game:
    """Diagonal position of value omega^omega."""
    return Bsup(opow_game, BSUP_BOUND)


# --------------------------------------------------------------------------- #
# Demonstration
# --------------------------------------------------------------------------- #

def main() -> None:
    print("=" * 70)
    print("TRANSFINITE GAME VALUES IN INFINITE CHESS")
    print("=" * 70)

    print("\n[1] Grafting realises ordinal addition: value(graft A B) = v(B) + v(A)")
    print("    (verified structurally: the materialized tree has the same value)")
    examples = [(fin_game(3), fin_game(2)), (omega_game(), fin_game(4)),
                (fin_game(5), omega_game()), (omega_game(), omega_game())]
    for a, b in examples:
        lazy = value(graft(a, b))
        material = value(materialize(graft(a, b)))
        rhs = ord_add(value(b), value(a))
        print(f"    v(A)={str(value(a)):<8} v(B)={str(value(b)):<8} "
              f"->  v(graft A B) = {str(lazy):<10} = v(B)+v(A) = {rhs}")
        assert lazy == rhs == material

    print("\n[2] Mate-in-omega: value(omegaGame) = omega, and no finite bound.")
    v_omega = value(omega_game())
    print(f"    v(omegaGame) = {v_omega}")
    assert v_omega == Ordinal.omega_pow(1)
    assert all(v_omega != Ordinal.nat(n) for n in range(100))
    print("    verified: differs from every finite ordinal 0..99")

    print("\n[3] The power hierarchy: value(opowGame n) = omega^n")
    for n in range(6):
        vn = value(opow_game(n))
        expected = Ordinal.nat(1) if n == 0 else Ordinal.omega_pow(n)
        print(f"    n={n}:  value = {str(vn):<14}  expected = {expected}")
        assert vn == expected

    print("\n[4] Strict monotonicity of the hierarchy:")
    vals = [value(opow_game(n)) for n in range(6)]
    for i in range(len(vals) - 1):
        assert vals[i] < vals[i + 1]
    print("    " + "  <  ".join(str(v) for v in vals))

    print("\n[5] Diagonal position: value(omegaOmegaGame) = omega^omega")
    v_oo = value(omega_omega_game())
    print(f"    v(omegaOmegaGame) = {v_oo}")
    assert v_oo == Ordinal.omega_omega()

    print("\n[6] Strict domination: omega^n < omega^omega for all sampled n")
    for n in range(8):
        assert value(opow_game(n)) < v_oo
    print("    verified for n = 0..7")

    print("\n" + "=" * 70)
    print("ALL CHECKS PASSED")
    print("Hierarchy:  1 < omega < omega^2 < omega^3 < ... < omega^omega")
    print("=" * 70)


if __name__ == "__main__":
    main()
