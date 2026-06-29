"""
Cumulative weight thresholds and the tropical convolution law for binary linear codes
=====================================================================================

This self-contained script demonstrates, with concrete numbers, the central results of
the package "Functor from finite linear codes to tropical valuation objects via
weight-threshold counting":

    * the cumulative weight-threshold count   wcount(C, t) = #{ c in C : wt(c) <= t },
      the discrete CDF of the Hamming weight;
    * the exact *sliding-threshold* convolution law under direct sum (concatenation):
          wcount(C (+) D, t) = sum_{a in C, wt(a) <= t} wcount(D, t - wt(a));
    * the *supermultiplicative* (tropical) inequality:
          wcount(C, s) * wcount(D, r) <= wcount(C (+) D, s + r);
    * the strict gap on the extended Hamming [8,4,4] code:
          15 * 15 = 225  <  227 = wcount(hamming (+) hamming, 8),
      the two extra codewords being the (8,0) and (0,8) weight blocks invisible to the
      rectangle {wt <= 4} x {wt <= 4}.

Everything is built from first principles over GF(2); only the Python standard library
is used.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Binary vectors over GF(2) = ZMod 2, represented as tuples of 0/1 ints.
# ---------------------------------------------------------------------------

BinVec = Tuple[int, ...]
Code = List[BinVec]


def wt(v: Sequence[int]) -> int:
    """Hamming weight: number of nonzero coordinates."""
    return sum(1 for x in v if x % 2 == 1)


def append(a: Sequence[int], b: Sequence[int]) -> BinVec:
    """Coordinate concatenation a ++ b, the codeword side of the direct sum."""
    return tuple(a) + tuple(b)


def direct_sum(C: Code, D: Code) -> Code:
    """Direct sum (concatenation) of two codes: all a ++ b with a in C, b in D."""
    return [append(a, b) for a in C for b in D]


# ---------------------------------------------------------------------------
# The two threshold invariants.
# ---------------------------------------------------------------------------

def wcount(C: Code, t: int) -> int:
    """Cumulative weight-threshold count: #{ c in C : wt(c) <= t }."""
    return sum(1 for c in C if wt(c) <= t)


def wexact(C: Code, t: int) -> int:
    """Weight distribution (PMF): #{ c in C : wt(c) == t }."""
    return sum(1 for c in C if wt(c) == t)


# ---------------------------------------------------------------------------
# The extended Hamming [8,4,4] code = Reed-Muller RM(1,3), the mod-2 shadow of E8.
# ---------------------------------------------------------------------------

HAMMING_GEN: List[BinVec] = [
    (1, 1, 1, 1, 1, 1, 1, 1),
    (0, 0, 0, 0, 1, 1, 1, 1),
    (0, 0, 1, 1, 0, 0, 1, 1),
    (0, 1, 0, 1, 0, 1, 0, 1),
]


def build_hamming() -> Code:
    """Generate all 16 codewords of the extended Hamming [8,4,4] code."""
    codewords: Code = []
    for coeffs in product((0, 1), repeat=4):
        word = tuple(
            sum(coeffs[i] * HAMMING_GEN[i][j] for i in range(4)) % 2
            for j in range(8)
        )
        codewords.append(word)
    return codewords


# ---------------------------------------------------------------------------
# Verification routines mirroring the formal theorems.
# ---------------------------------------------------------------------------

def verify_exact_convolution(C: Code, D: Code, m: int, n: int) -> None:
    """Check wcount(C (+) D, t) = sum_{a in C, wt(a) <= t} wcount(D, t - wt(a))."""
    CD = direct_sum(C, D)
    print("Exact sliding-threshold convolution  wcount_append")
    print("  t :   LHS   RHS")
    for t in range(0, m + n + 1):
        lhs = wcount(CD, t)
        rhs = sum(wcount(D, t - wt(a)) for a in C if wt(a) <= t)
        flag = "ok" if lhs == rhs else "MISMATCH"
        print(f"  {t:2d}: {lhs:5d} {rhs:5d}   {flag}")
        assert lhs == rhs
    print()


def verify_supermultiplicative(C: Code, D: Code, m: int, n: int) -> None:
    """Check wcount(C,s) * wcount(D,r) <= wcount(C (+) D, s+r) for all s, r."""
    CD = direct_sum(C, D)
    print("Supermultiplicative (tropical) bound  wcount_append_ge")
    print("   s  r :  prod  <=  wcount(C(+)D, s+r)    gap")
    worst = None
    for s in range(0, m + 1):
        for r in range(0, n + 1):
            prod = wcount(C, s) * wcount(D, r)
            big = wcount(CD, s + r)
            gap = big - prod
            assert prod <= big
            if gap > 0 and (worst is None or gap > worst[2]):
                worst = (s, r, gap)
            if (s, r) in {(4, 4), (8, 8), (0, 0), (8, 0), (0, 8)}:
                print(f"  {s:2d} {r:2d} : {prod:5d}  <= {big:5d}             {gap:+d}")
    print(f"  largest strict gap at (s,r,gap) = {worst}")
    print()


def verify_cauchy_convolution(C: Code, D: Code, m: int, n: int) -> None:
    """Check wexact(C (+) D, t) = sum_{s} wexact(C, s) * wexact(D, t - s)."""
    CD = direct_sum(C, D)
    print("Exact Cauchy convolution of the weight distribution  wexact_append")
    print("  t :   LHS   RHS")
    for t in range(0, m + n + 1):
        lhs = wexact(CD, t)
        rhs = sum(wexact(C, s) * wexact(D, t - s) for s in range(0, t + 1))
        flag = "ok" if lhs == rhs else "MISMATCH"
        if lhs or rhs:
            print(f"  {t:2d}: {lhs:5d} {rhs:5d}   {flag}")
        assert lhs == rhs
    print()


def main() -> None:
    hamming = build_hamming()
    assert len(hamming) == 16

    print("=" * 70)
    print("Extended Hamming [8,4,4] code  (RM(1,3), mod-2 shadow of E8)")
    print("=" * 70)
    spectrum: Dict[int, int] = {w: wexact(hamming, w) for w in range(0, 9)}
    print("  weight spectrum  :", {w: c for w, c in spectrum.items() if c})
    print("  classical enumerator : 1 + 14 x^4 + x^8")
    print("  cumulative CDF wcount(hamming, t):")
    for t in range(0, 9):
        print(f"      wcount(hamming, {t}) = {wcount(hamming, t)}")
    print()

    # Headline strict gap.
    h4 = wcount(hamming, 4)
    hh8 = wcount(direct_sum(hamming, hamming), 8)
    print("-" * 70)
    print("HEADLINE: convolution, not product")
    print("-" * 70)
    print(f"  wcount(hamming, 4)              = {h4}")
    print(f"  wcount(hamming, 4)^2           = {h4 * h4}   (rectangle lower bound)")
    print(f"  wcount(hamming (+) hamming, 8) = {hh8}   (actual count)")
    print(f"  strict gap                     = {hh8 - h4 * h4}"
          "   <- the (8,0) and (0,8) cross-strata blocks")
    print()
    assert h4 == 15 and hh8 == 227 and h4 * h4 == 225

    print("=" * 70)
    print("Verifications (all assertions pass)")
    print("=" * 70)
    verify_exact_convolution(hamming, hamming, 8, 8)
    verify_supermultiplicative(hamming, hamming, 8, 8)
    verify_cauchy_convolution(hamming, hamming, 8, 8)

    # Cross-strata decomposition of the gap (Conjecture 2 illustration).
    CD = direct_sum(hamming, hamming)
    s, r = 4, 4
    in_simplex_not_rect = sum(
        1
        for a in hamming
        for b in hamming
        if wt(a) + wt(b) <= s + r and not (wt(a) <= s and wt(b) <= r)
    )
    print("Cross-strata decomposition of the gap (Conjecture 2)")
    print(f"  #{{(a,b): wt a + wt b <= 8, not(wt a <=4 and wt b <=4)}} = "
          f"{in_simplex_not_rect}")
    print(f"  matches strict gap 227 - 225 = {hh8 - h4 * h4}")
    assert in_simplex_not_rect == hh8 - h4 * h4
    print()
    print("All checks passed.")


if __name__ == "__main__":
    main()
