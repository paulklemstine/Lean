"""
Numerical demonstrations of the repulsion-to-uniqueness principle underlying a
conditional refinement of Page's theorem on Landau-Siegel zeros.

Setting.  A "character datum" is a pair (conductor q, putative real zero beta).
It is EPS-EXCEPTIONAL if  beta >= 1 - q^(-eps).  Two DISTINCT data satisfy the
REPULSION PRINCIPLE with constant C if

        min(beta, beta') <= 1 - C / log(q * q').

Main theorem (pairwise form).  If eps > 0, integers 2 <= Q0 <= M, and

        C > 2 * Q0^(-eps) * log(M)            (the compatibility threshold)

then any two valid (in-window, eps-exceptional) data obeying repulsion coincide;
hence at most one exceptional character exists in the window [Q0, M].

This script demonstrates:
  1. the compatibility threshold and when it forces uniqueness,
  2. the squeeze argument (floor from exceptionality vs ceiling from repulsion),
  3. that the threshold is load-bearing (coexistence below it),
  4. the asymptotic shrinking of the required C as Q0 -> infinity.

Self-contained; requires only the standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import log
from itertools import combinations


@dataclass(frozen=True)
class CharacterDatum:
    """A primitive quadratic character datum: conductor and putative real zero."""
    conductor: int
    real_zero: float


def exceptionality_margin(conductor: int, eps: float) -> float:
    """The margin q^(-eps); an eps-exceptional zero lies within it of 1."""
    return float(conductor) ** (-eps)


def is_exceptional(chi: CharacterDatum, eps: float) -> bool:
    """True iff beta >= 1 - q^(-eps)."""
    return chi.real_zero >= 1.0 - exceptionality_margin(chi.conductor, eps)


def in_window(chi: CharacterDatum, q0: int, m: int) -> bool:
    """True iff Q0 <= conductor <= M."""
    return q0 <= chi.conductor <= m


def is_valid(chi: CharacterDatum, eps: float, q0: int, m: int) -> bool:
    """True iff in-window and eps-exceptional."""
    return in_window(chi, q0, m) and is_exceptional(chi, eps)


def compatibility_threshold(eps: float, q0: int, m: int) -> float:
    """The threshold 2 * Q0^(-eps) * log(M)."""
    return 2.0 * (float(q0) ** (-eps)) * log(float(m))


def uniqueness_guaranteed(eps: float, c: float, q0: int, m: int) -> bool:
    """True iff C exceeds the compatibility threshold (Theorem A hypothesis)."""
    return c > compatibility_threshold(eps, q0, m)


def repulsion_ceiling(chi: CharacterDatum, chi2: CharacterDatum, c: float) -> float:
    """The repulsion ceiling 1 - C / log(q * q')."""
    return 1.0 - c / log(float(chi.conductor) * float(chi2.conductor))


def repulsion_respected(chi: CharacterDatum, chi2: CharacterDatum, c: float) -> bool:
    """True iff min(beta, beta') <= repulsion ceiling (distinct data)."""
    return min(chi.real_zero, chi2.real_zero) <= repulsion_ceiling(chi, chi2, c)


def certify_uniqueness(
    data: list[CharacterDatum], eps: float, c: float, q0: int, m: int
) -> tuple[str, object]:
    """
    Certified pairwise checker (Algorithm 5.2 of the paper).

    Returns ("unique", V) if at most one valid datum exists; ("coexisting pair",
    (chi, chi')) if two distinct valid data violate repulsion; ("consistent", V)
    otherwise.
    """
    valid = [chi for chi in data if is_valid(chi, eps, q0, m)]
    if len(valid) <= 1:
        return "unique", valid
    for chi, chi2 in combinations(valid, 2):
        if not repulsion_respected(chi, chi2, c):
            return "coexisting pair", (chi, chi2)
    return "consistent", valid


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_threshold() -> None:
    print("=" * 70)
    print("DEMO 1  --  The compatibility threshold C > 2 * Q0^(-eps) * log(M)")
    print("=" * 70)
    eps, q0, m = 0.25, 10, 1000
    tau = compatibility_threshold(eps, q0, m)
    print(f"eps = {eps},  Q0 = {q0},  M = {m}")
    print(f"threshold tau = 2 * Q0^(-eps) * log(M) = {tau:.6f}")
    for c in (0.5 * tau, tau, 1.5 * tau):
        ok = uniqueness_guaranteed(eps, c, q0, m)
        print(f"  C = {c:8.4f}  ->  uniqueness guaranteed: {ok}")
    print()


def demo_squeeze() -> None:
    print("=" * 70)
    print("DEMO 2  --  The squeeze: floor (exceptionality) vs ceiling (repulsion)")
    print("=" * 70)
    eps, q0, m = 0.25, 10, 1000
    c = 1.5 * compatibility_threshold(eps, q0, m)
    floor = 1.0 - exceptionality_margin(q0, eps)          # 1 - Q0^(-eps)
    chi1 = CharacterDatum(37, 1.0 - exceptionality_margin(37, eps))
    chi2 = CharacterDatum(211, 1.0 - exceptionality_margin(211, eps))
    ceiling = repulsion_ceiling(chi1, chi2, c)
    mn = min(chi1.real_zero, chi2.real_zero)
    print(f"C = {c:.4f}  (above threshold)")
    print(f"floor   1 - Q0^(-eps)              = {floor:.6f}   (from exceptionality)")
    print(f"actual  min(beta1, beta2)          = {mn:.6f}")
    print(f"ceiling 1 - C/log(q1 q2)           = {ceiling:.6f}   (from repulsion)")
    print("Distinct exceptional data would need floor <= min <= ceiling, but")
    print(f"floor ({floor:.6f}) > ceiling ({ceiling:.6f}): impossible => must coincide.")
    print()


def demo_load_bearing() -> None:
    print("=" * 70)
    print("DEMO 3  --  The threshold is load-bearing: coexistence for small C")
    print("=" * 70)
    eps, q0, m = 0.25, 10, 20
    # Two distinct genuinely valid data, each exactly at its own boundary
    # beta = 1 - q^(-eps), with conductors inside the (small) window.
    chi1 = CharacterDatum(10, 1.0 - exceptionality_margin(10, eps))
    chi2 = CharacterDatum(20, 1.0 - exceptionality_margin(20, eps))
    assert is_valid(chi1, eps, q0, m) and is_valid(chi2, eps, q0, m)
    tau = compatibility_threshold(eps, q0, m)
    print(f"eps = {eps},  Q0 = {q0},  M = {m},  threshold tau = {tau:.4f}")
    for label, c in (("weak repulsion   C < tau", 0.5 * tau),
                     ("strong repulsion C > tau", 1.5 * tau)):
        respected = repulsion_respected(chi1, chi2, c)
        if respected:
            verdict = "repulsion HOLDS for the distinct pair -> they COEXIST"
        else:
            verdict = "repulsion FAILS for the distinct pair -> uniqueness forced"
        print(f"  {label}:  C = {c:6.4f}  ->  {verdict}")
    print("  (Below the threshold two distinct exceptional characters coexist;")
    print("   above it they cannot -- the threshold cannot be dropped.)")
    print()


def demo_asymptotics() -> None:
    print("=" * 70)
    print("DEMO 4  --  Required C shrinks like Q0^(-eps) log(Q0) as Q0 -> infinity")
    print("=" * 70)
    eps = 0.25
    print(f"eps = {eps},  window M = Q0")
    for q0 in (10, 100, 1000, 10_000, 100_000):
        tau = compatibility_threshold(eps, q0, q0)
        print(f"  Q0 = M = {q0:8d}  ->  required C > {tau:.6f}")
    print("  The barrier weakens with conductor: larger conductors are more repelled.")
    print()


if __name__ == "__main__":
    demo_threshold()
    demo_squeeze()
    demo_load_bearing()
    demo_asymptotics()
