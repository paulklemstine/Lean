"""
Infinite Games Against Death: Immortality Strategies
=====================================================

A self-contained numerical demonstration of the survival-game results.

We work with ordinals below omega^omega, represented in Cantor Normal Form
(CNF) as a strictly-decreasing list of (exponent, coefficient) terms:

    alpha = omega^e_1 * c_1 + omega^e_2 * c_2 + ... ,   e_1 > e_2 > ... >= 0,
            c_i >= 1 finite.

This is enough to represent every ordinal that appears in the theory:
finite numbers, omega, omega * n, omega^2, and so on, and to compute
ordinal addition and multiplication exactly.

The survival game.  A game is given by the order type ("survival value") of
its set of reachable moments.  The Fundamental Theorem says

    Mortal forces round beta   <=>   beta <= value.

We reproduce, with exact ordinal arithmetic:

  * value(finite game)          = omega,        forces every n, forces omega, dies at omega
  * value(nondeterministic)     = omega^2,      forces every omega*n, dies at omega^2
  * refinement principle:  value(R(G)) = omega * value(G)
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import List, Tuple


# ---------------------------------------------------------------------------
# Ordinals below omega^omega in Cantor Normal Form
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class Ordinal:
    """An ordinal < omega^omega in Cantor Normal Form.

    terms is a list of (exponent, coefficient) with exponents strictly
    decreasing and coefficients >= 1.  The empty list denotes 0.
    """

    terms: Tuple[Tuple[int, int], ...]

    def __post_init__(self) -> None:
        exps = [e for e, _ in self.terms]
        assert exps == sorted(exps, reverse=True), "exponents must strictly decrease"
        assert len(set(exps)) == len(exps), "exponents must be distinct"
        assert all(c >= 1 for _, c in self.terms), "coefficients must be >= 1"

    # --- constructors -----------------------------------------------------
    @staticmethod
    def zero() -> "Ordinal":
        return Ordinal(())

    @staticmethod
    def finite(n: int) -> "Ordinal":
        assert n >= 0
        return Ordinal(((0, n),)) if n > 0 else Ordinal(())

    @staticmethod
    def omega_pow(e: int, coeff: int = 1) -> "Ordinal":
        """omega^e * coeff."""
        assert e >= 0 and coeff >= 1
        return Ordinal(((e, coeff),))

    # --- display ----------------------------------------------------------
    def __str__(self) -> str:
        if not self.terms:
            return "0"
        pieces: List[str] = []
        for e, c in self.terms:
            if e == 0:
                pieces.append(f"{c}")
            elif e == 1:
                pieces.append("w" if c == 1 else f"w*{c}")
            else:
                pieces.append(f"w^{e}" if c == 1 else f"w^{e}*{c}")
        return " + ".join(pieces)

    # --- comparison (lexicographic on CNF terms) --------------------------
    def _key(self) -> List[Tuple[int, int]]:
        return list(self.terms)

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Ordinal) and self.terms == other.terms

    def __lt__(self, other: "Ordinal") -> bool:
        a, b = self.terms, other.terms
        for (ea, ca), (eb, cb) in zip(a, b):
            if ea != eb:
                return ea < eb
            if ca != cb:
                return ca < cb
        return len(a) < len(b)

    def __le__(self, other: "Ordinal") -> bool:
        return self == other or self < other

    # --- ordinal addition -------------------------------------------------
    def __add__(self, other: "Ordinal") -> "Ordinal":
        if not other.terms:
            return self
        if not self.terms:
            return other
        lead_exp = other.terms[0][0]
        # In alpha + beta, all terms of alpha with exponent < lead_exp vanish.
        kept = [(e, c) for (e, c) in self.terms if e > lead_exp]
        # A term of alpha with exponent == lead_exp merges with beta's lead.
        merged = list(other.terms)
        for e, c in self.terms:
            if e == lead_exp:
                fe, fc = merged[0]
                merged[0] = (fe, fc + c)
                break
        return Ordinal(tuple(kept + merged))

    # --- ordinal multiplication -------------------------------------------
    def __mul__(self, other: "Ordinal") -> "Ordinal":
        # alpha * beta.  Distribute beta's terms on the left over alpha.
        if not self.terms or not other.terms:
            return Ordinal.zero()
        lead_exp_a, lead_coeff_a = self.terms[0]
        result = Ordinal.zero()
        for e_b, c_b in other.terms:
            if e_b == 0:
                # alpha * (finite c_b) = (lead term * c_b) + rest of alpha
                head = (lead_exp_a, lead_coeff_a * c_b)
                tail = list(self.terms[1:])
                result = result + Ordinal(tuple([head] + tail))
            else:
                # alpha * omega^e_b * c_b = omega^(lead_exp_a + e_b) * c_b
                result = result + Ordinal.omega_pow(lead_exp_a + e_b, c_b)
        return result


# convenient constants
ZERO = Ordinal.zero()
ONE = Ordinal.finite(1)
OMEGA = Ordinal.omega_pow(1)
OMEGA_SQ = Ordinal.omega_pow(2)


# ---------------------------------------------------------------------------
# The survival game
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class SurvivalGame:
    """A survival game is determined by the order type of its moments."""

    name: str
    value: Ordinal


def mortal_forces(game: SurvivalGame, beta: Ordinal) -> bool:
    """Fundamental Theorem:  Mortal forces round beta  <=>  beta <= value."""
    return beta <= game.value


def refine(game: SurvivalGame) -> SurvivalGame:
    """omega-refinement:  value(R(G)) = omega * value(G)."""
    return SurvivalGame(f"R({game.name})", OMEGA * game.value)


# the two canonical games
FINITE_GAME = SurvivalGame("finite", OMEGA)          # value = omega
NONDET_GAME = SurvivalGame("nondeterministic", OMEGA_SQ)  # value = omega^2


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_ordinal_arithmetic() -> None:
    print("=" * 68)
    print("Ordinal arithmetic sanity checks")
    print("=" * 68)
    print(f"  1 + w         = {ONE + OMEGA}          (absorbs: equals w)")
    print(f"  w + 1         = {OMEGA + ONE}")
    print(f"  w * 2         = {OMEGA * Ordinal.finite(2)}")
    print(f"  w * w         = {OMEGA * OMEGA}          (= omega^2)")
    print(f"  (w+1) * w     = {(OMEGA + ONE) * OMEGA}      (absorbs the +1)")
    print(f"  w^2 + w       = {OMEGA_SQ + OMEGA}")
    print(f"  compare w < w^2 : {OMEGA < OMEGA_SQ}")
    print()


def demo_fundamental_theorem() -> None:
    print("=" * 68)
    print("Fundamental Theorem:  forces(beta) <=> beta <= value")
    print("=" * 68)
    for game in (FINITE_GAME, NONDET_GAME):
        print(f"  Game '{game.name}':  value = {game.value}")
        for beta in (Ordinal.finite(3), OMEGA, OMEGA + ONE, OMEGA_SQ,
                     OMEGA_SQ + ONE):
            forced = mortal_forces(game, beta)
            verdict = "survives" if forced else "DIES    "
            print(f"      round {str(beta):8s} -> {verdict}")
        print()


def demo_finite_game() -> None:
    print("=" * 68)
    print("Finite deterministic Mortal: value = omega")
    print("=" * 68)
    print("  survives every finite round n:")
    print("     ", ", ".join(str(mortal_forces(FINITE_GAME, Ordinal.finite(n)))
                              for n in range(6)))
    print(f"  forces round omega        : {mortal_forces(FINITE_GAME, OMEGA)}")
    print(f"  forces round omega + 1    : {mortal_forces(FINITE_GAME, OMEGA + ONE)}"
          "   (omega is sharp: dies here)")
    print()


def demo_nondet_game() -> None:
    print("=" * 68)
    print("Bounded-nondeterministic Mortal: value = omega^2")
    print("=" * 68)
    print("  survives every round omega * n:")
    for n in range(6):
        beta = OMEGA * Ordinal.finite(n)
        print(f"      round w*{n} = {str(beta):8s} -> {mortal_forces(NONDET_GAME, beta)}")
    print(f"  forces round omega^2      : {mortal_forces(NONDET_GAME, OMEGA_SQ)}")
    print(f"  forces round omega^2 + 1  : {mortal_forces(NONDET_GAME, OMEGA_SQ + ONE)}"
          "   (omega^2 is sharp: dies here)")
    print(f"  nondeterminism strictly helps:  value(finite) < value(nondet) = "
          f"{FINITE_GAME.value < NONDET_GAME.value}")
    print()


def demo_refinement() -> None:
    print("=" * 68)
    print("Refinement principle:  value(R(G)) = omega * value(G)")
    print("=" * 68)
    g = FINITE_GAME
    print(f"  G_0 = finite           value = {g.value}")
    for k in range(1, 4):
        g = refine(g)
        print(f"  G_{k} = R(G_{k-1})        value = {g.value}")
    print("  (finite -> omega, one refinement -> omega^2, then omega^3, omega^4, ...)")
    print()


def main() -> None:
    demo_ordinal_arithmetic()
    demo_fundamental_theorem()
    demo_finite_game()
    demo_nondet_game()
    demo_refinement()


if __name__ == "__main__":
    main()
