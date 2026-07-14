"""Numerical demonstration of the Möbius discriminant trichotomy.

For a positive sequence satisfying a first-order multiplicative recurrence

    (alpha * n + beta) * a(n+1) = (gamma * n + delta) * a(n),   alpha*n + beta > 0,

the *Möbius discriminant* is

    Delta = gamma * beta - alpha * delta.

Theorem (trichotomy):
    Delta > 0  =>  strictly log-convex   :  a(n+1)^2 < a(n) * a(n+2)
    Delta = 0  =>  log-linear            :  a(n+1)^2 = a(n) * a(n+2)
    Delta < 0  =>  strictly log-concave  :  a(n) * a(n+2) < a(n+1)^2

The mechanism: the consecutive ratio a(n+1)/a(n) equals the Möbius function
(gamma*n + delta)/(alpha*n + beta), whose forward difference has the
n-independent numerator Delta.

This script computes everything exactly over the rationals, so every
inequality reported is an exact mathematical fact, not a floating-point
approximation.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Tuple

# --------------------------------------------------------------------------- #
#  Core: discriminant, classification, and exact curvature witnesses          #
# --------------------------------------------------------------------------- #


def mobius_discriminant(alpha: int, beta: int, gamma: int, delta: int) -> int:
    """Return Delta = gamma*beta - alpha*delta for the recurrence coefficients."""
    return gamma * beta - alpha * delta


def classify(delta_disc: int) -> str:
    """Classify log-behavior from the sign of the Möbius discriminant."""
    if delta_disc > 0:
        return "strictly log-convex"
    if delta_disc == 0:
        return "log-linear"
    return "strictly log-concave"


def ratio(alpha: int, beta: int, gamma: int, delta: int, n: int) -> Fraction:
    """The exact consecutive ratio a(n+1)/a(n) = (gamma*n + delta)/(alpha*n + beta)."""
    return Fraction(gamma * n + delta, alpha * n + beta)


def build_sequence(
    a0: Fraction,
    alpha: int,
    beta: int,
    gamma: int,
    delta: int,
    length: int,
) -> List[Fraction]:
    """Generate the sequence exactly from a0 via the multiplicative recurrence."""
    seq: List[Fraction] = [a0]
    for n in range(length - 1):
        seq.append(seq[-1] * ratio(alpha, beta, gamma, delta, n))
    return seq


def curvature(seq: List[Fraction], n: int) -> Fraction:
    """Exact discrete log-curvature D(n) = a(n)*a(n+2) - a(n+1)^2.

    D(n) > 0 <=> log-convex at n; D(n) = 0 <=> log-linear; D(n) < 0 <=> log-concave.
    """
    return seq[n] * seq[n + 2] - seq[n + 1] ** 2


def sign(x: Fraction) -> int:
    """Return -1, 0, or +1, the sign of an exact rational."""
    return (x > 0) - (x < 0)


# --------------------------------------------------------------------------- #
#  Catalog of classical instances                                             #
# --------------------------------------------------------------------------- #

# Each entry: (name, a0, alpha, beta, gamma, delta)
INSTANCES: List[Tuple[str, Fraction, int, int, int, int]] = [
    ("2^n                    ", Fraction(1), 0, 1, 0, 2),
    ("Catalan C_n            ", Fraction(1), 1, 2, 4, 2),
    ("central binomial (2n,n)", Fraction(1), 1, 1, 4, 2),
    ("factorial n!           ", Fraction(1), 0, 1, 1, 1),
    ("reciprocal factorial 1/n!", Fraction(1), 1, 1, 0, 1),
]


def demo_discriminant_table() -> None:
    """Print each classical sequence, its discriminant, and predicted regime."""
    print("=" * 78)
    print("Möbius discriminant and predicted log-behavior")
    print("=" * 78)
    print(f"{'sequence':26s} {'(a,b,g,d)':16s} {'Delta':>6s}  regime")
    print("-" * 78)
    for name, _a0, alpha, beta, gamma, delta in INSTANCES:
        disc = mobius_discriminant(alpha, beta, gamma, delta)
        coeffs = f"({alpha},{beta},{gamma},{delta})"
        print(f"{name:26s} {coeffs:16s} {disc:6d}  {classify(disc)}")
    print()


def demo_curvature_matches_discriminant(length: int = 8) -> None:
    """Verify that every discrete curvature D(n) has the sign of Delta."""
    print("=" * 78)
    print("Exact curvature D(n) = a(n)*a(n+2) - a(n+1)^2 matches sign(Delta)")
    print("=" * 78)
    for name, a0, alpha, beta, gamma, delta in INSTANCES:
        disc = mobius_discriminant(alpha, beta, gamma, delta)
        seq = build_sequence(a0, alpha, beta, gamma, delta, length + 2)
        signs = [sign(curvature(seq, n)) for n in range(length)]
        ok = all(s == sign(Fraction(disc)) for s in signs)
        first_terms = [str(x) for x in seq[:6]]
        print(f"{name.strip():24s}  Delta={disc:>3d}  "
              f"sign(D(n))={signs}  consistent={ok}")
        print(f"    first terms: {', '.join(first_terms)} ...")
    print()


def demo_ratio_monotonicity(length: int = 6) -> None:
    """Show the consecutive ratios and confirm their monotonicity direction."""
    print("=" * 78)
    print("Consecutive ratios r(n) = a(n+1)/a(n) and their monotonicity")
    print("=" * 78)
    for name, _a0, alpha, beta, gamma, delta in INSTANCES:
        disc = mobius_discriminant(alpha, beta, gamma, delta)
        ratios = [ratio(alpha, beta, gamma, delta, n) for n in range(length)]
        diffs = [ratios[n + 1] - ratios[n] for n in range(length - 1)]
        direction = {1: "increasing", 0: "constant", -1: "decreasing"}[sign(Fraction(disc))]
        as_str = ", ".join(str(r) for r in ratios)
        all_match = all(sign(d) == sign(Fraction(disc)) for d in diffs)
        print(f"{name.strip():24s}  Delta={disc:>3d}  ratios {direction}: {as_str} ...")
        print(f"    every forward difference has sign(Delta): {all_match}")
    print()


def demo_catalan_identity(length: int = 6) -> None:
    """Confirm the classical Catalan three-term identity.

        (2n+1)(n+3) * C(n) * C(n+2) = (n+2)(2n+3) * C(n+1)^2

    and that the coefficient gap (n+2)(2n+3) - (2n+1)(n+3) = 3 is constant,
    the normalized shadow of the intrinsic discriminant Delta = 6.
    """
    print("=" * 78)
    print("Catalan three-term identity and the constant coefficient gap = 3")
    print("=" * 78)
    cat = build_sequence(Fraction(1), 1, 2, 4, 2, length + 2)
    for n in range(length):
        lhs = (2 * n + 1) * (n + 3) * cat[n] * cat[n + 2]
        rhs = (n + 2) * (2 * n + 3) * cat[n + 1] ** 2
        gap = (n + 2) * (2 * n + 3) - (2 * n + 1) * (n + 3)
        print(f"  n={n}: identity holds = {lhs == rhs}, coefficient gap = {gap}")
    print()


def main() -> None:
    demo_discriminant_table()
    demo_curvature_matches_discriminant()
    demo_ratio_monotonicity()
    demo_catalan_identity()
    print("All demonstrations computed exactly over the rationals.")


if __name__ == "__main__":
    main()
