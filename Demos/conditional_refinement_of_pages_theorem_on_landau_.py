"""
Numerical demonstrations for:

    A Conditional Refinement of Page's Theorem on Landau-Siegel Zeros

This self-contained script illustrates, with concrete numbers, the three
mathematical pillars behind the refinement:

  1. Enumeration of primitive real quadratic characters via fundamental
     discriminants (the Kronecker-symbol correspondence).
  2. The asymptotic engine  q^{-eps} * log q -> 0,  which certifies an
     effective threshold Q0 beyond which the polynomially-thin interval
     [1 - q^{-eps}, 1) nests inside the refined danger zone (1 - C/log q, 1).
  3. The subsingleton / "at most one" conclusion produced by pairwise
     zero-repulsion (Deuring-Heilbronn).

No external dependencies are required (standard library only).
"""

from __future__ import annotations

import math
from typing import Iterable


# ---------------------------------------------------------------------------
# Stage 2 : enumeration of primitive real quadratic characters
# ---------------------------------------------------------------------------

def is_squarefree(n: int) -> bool:
    """Return True iff |n| is squarefree (has no repeated prime factor)."""
    n = abs(n)
    if n == 0:
        return False
    if n == 1:
        return True
    d = 2
    while d * d <= n:
        if n % (d * d) == 0:
            return False
        if n % d == 0:
            n //= d
        else:
            d += 1
    return True


def is_fundamental_discriminant(D: int) -> bool:
    """
    Test whether the integer D is a fundamental discriminant, i.e. the
    discriminant of a quadratic field. These are in bijection with the
    primitive real quadratic Dirichlet characters (via Kronecker symbols).

    D is fundamental iff either
      * D == 1 (mod 4), D != 1, and D squarefree, or
      * D == 4 e with e == 2 or 3 (mod 4) and e squarefree.
    """
    if D == 0:
        return False
    if D % 4 == 1:
        return D != 1 and is_squarefree(D)
    if D % 4 == 0:
        e = D // 4
        return (e % 4 in (2, 3)) and is_squarefree(e)
    return False


def enumerate_quadratic_characters(Q0: int) -> list[int]:
    """
    Enumerate the fundamental discriminants D with |D| <= Q0.  Each such D
    names a primitive real quadratic character of conductor q = |D|.
    """
    found: list[int] = []
    for n in range(Q0 + 1):
        for D in (n, -n):
            if is_fundamental_discriminant(D):
                found.append(D)
    return sorted(set(found), key=lambda d: (abs(d), d))


# ---------------------------------------------------------------------------
# Stage 1 : the asymptotic engine and the effective threshold
# ---------------------------------------------------------------------------

def log_over_rpow(eps: float, m: float) -> float:
    """log(m) / m^eps  =  m^{-eps} * log(m)  (the quantity that -> 0)."""
    return math.log(m) / (m ** eps)


def effective_threshold(eps: float, C: float, search_limit: int = 100_000_000) -> int:
    """
    Smallest Q0 such that for all integers m >= Q0 we have
        m^{-eps} * log m <= C.
    Because the function is eventually decreasing, we scan upward until the
    bound first holds and then remains stable over a safety margin.
    """
    m = 2
    while m < search_limit:
        if log_over_rpow(eps, m) <= C:
            # confirm it stays below C for a margin (function is decreasing here)
            if all(log_over_rpow(eps, k) <= C for k in range(m, m + 50)):
                return m
        m += 1
    raise RuntimeError("threshold not found within search_limit")


def interval_nested(eps: float, C: float, q: float) -> bool:
    """
    Check that the thin interval [1 - q^{-eps}, 1) is contained in the
    refined danger zone (1 - C/log q, 1), i.e. q^{-eps} <= C / log q.
    """
    return q ** (-eps) <= C / math.log(q)


# ---------------------------------------------------------------------------
# Stage 5 : the subsingleton ("at most one") conclusion under repulsion
# ---------------------------------------------------------------------------

def exceptional_set_is_subsingleton(
    exceptional_characters: Iterable[int],
    repulsion_forbids_pair: bool = True,
) -> bool:
    """
    Model of the final conclusion.  Given the set of characters flagged as
    possessing an exceptional real zero, and the Deuring-Heilbronn repulsion
    principle (which forbids any two distinct such characters), the set has
    at most one element.
    """
    chars = list(exceptional_characters)
    if not repulsion_forbids_pair:
        return len(chars) <= 1
    # Repulsion collapses any two distinct exceptional characters.
    return len(set(chars)) <= 1


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("Conditional Refinement of Page's Theorem on Landau-Siegel Zeros")
    print("=" * 70)

    # --- Stage 2 : enumeration ------------------------------------------------
    Q0 = 20
    chars = enumerate_quadratic_characters(Q0)
    print(f"\n[Stage 2] Fundamental discriminants with |D| <= {Q0}:")
    print(f"          {chars}")
    print(f"          count = {len(chars)}")

    # --- Stage 1 : asymptotic engine -----------------------------------------
    # Illustrative parameters giving a modest, human-scale threshold.
    # (For very small eps and C the threshold is astronomically large, since
    #  log q / q^eps decays extremely slowly; the theorem only needs its
    #  existence, which the asymptotic guarantees for every eps, C > 0.)
    eps = 0.5
    C = 0.5
    print(f"\n[Stage 1] Asymptotic engine  log(q)/q^eps -> 0  (eps = {eps})")
    for q in (10, 100, 10_000, 10**8, 10**12):
        print(f"          q = {q:>14}:  log(q)/q^eps = {log_over_rpow(eps, q):.6e}")

    Q0_thresh = effective_threshold(eps, C)
    print(f"\n          Effective threshold Q0 with m^(-eps) log m <= C={C}:")
    print(f"          Q0 = {Q0_thresh}")

    print("\n          Containment  [1 - q^-eps, 1)  ⊆  (1 - C/log q, 1):")
    for q in (5, 50, Q0_thresh, Q0_thresh * 10):
        ok = interval_nested(eps, C, q)
        print(f"          q = {q:>10}:  nested = {ok}")

    # --- Stage 5 : subsingleton conclusion -----------------------------------
    print("\n[Stage 5] 'At most one' under Deuring-Heilbronn repulsion:")
    for candidate in ([], [5], [5, -3]):
        ok = exceptional_set_is_subsingleton(candidate, repulsion_forbids_pair=True)
        print(f"          exceptional set {candidate!s:>10} -> subsingleton = {ok}")
    print("          (a two-element flagged set can never survive repulsion:")
    print("           the pair is forbidden, so at most one truly persists.)")

    print("\nDone.")


if __name__ == "__main__":
    main()
