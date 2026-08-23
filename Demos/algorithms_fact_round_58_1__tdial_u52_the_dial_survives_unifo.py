#!/usr/bin/env python3
"""Reference implementations of the four algorithms of the tie-ceiling calculus."""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Optional, Sequence, Tuple

# ===== ALG1 =====
def tie_ceiling_exact(profile: Sequence[int]) -> Fraction:
    """Exact Spearman tie ceiling of a tie profile.

    Given the multiset of tie-class sizes ``profile = (m_1, ..., m_K)`` of a
    discrete statistic on ``n = sum_j m_j`` sample points, return the exact
    rational value

        rho^2_max = 1 - 12 * C(L) / (n^3 - n),
        C(L)      = sum_j (m_j^3 - m_j) / 12,

    i.e. the largest squared Spearman rank correlation the statistic can attain
    against any response whatsoever.  Equivalently

        rho^2_max = 1 - (S_3 - n) / (n^3 - n),   S_3 = sum_j m_j^3.

    Cost: O(K) big-integer cubings plus one exact rational division.  Exact
    arithmetic is mandatory: at n = 2^52 the numerator and denominator carry
    about 47 decimal digits and IEEE doubles annihilate the correction term.
    """
    if any(m < 1 for m in profile):
        raise ValueError("tie-class sizes must be positive")
    n = 0
    cube = 0
    for m in profile:
        n += m
        cube += m * m * m
    if n < 2:
        raise ValueError("total mass must be at least 2")
    return Fraction(1) - Fraction(cube - n, n**3 - n)


def tie_ceiling_rho(profile: Sequence[int]) -> float:
    """Tie ceiling on the correlation scale, ``sqrt(rho^2_max)``."""
    return float(tie_ceiling_exact(profile)) ** 0.5
# ===== /ALG1 =====


# ===== ALG2 =====
def dyadic_profile(bitlen: int) -> List[int]:
    """Tie profile of the trailing-zero (2-adic valuation) statistic.

    On the ``2^b`` residues modulo ``2^b``, exactly ``2^(b-1)`` are odd, ``2^(b-2)``
    have valuation 1, and so on, with the residue 0 alone in the last class:

        L_dyadic(b) = (2^(b-1), 2^(b-2), ..., 2, 1, 1),   |L| = b+1,  sum = 2^b.
    """
    if bitlen <= 0:
        return [1]
    return [1 << (bitlen - 1 - k) for k in range(bitlen)] + [1]


def binomial_profile(bitlen: int) -> List[int]:
    """Tie profile of the Hamming-weight statistic: one row of Pascal's triangle.

    Built by the multiplicative recurrence ``C(b,k+1) = C(b,k)*(b-k)//(k+1)``,
    which is exact at every step, in ``O(b)`` big-integer operations.
    """
    row: List[int] = []
    c = 1
    for k in range(bitlen + 1):
        row.append(c)
        c = c * (bitlen - k) // (k + 1)
    return row


def certify_closed_forms(bitlen: int) -> Dict[str, object]:
    """Verify the two closed-form ceiling laws at a given bit length.

    Checks, in exact arithmetic:
      * the dyadic ceiling equals ``(6/7)(1 + 1/(n(n+1)))`` with ``n = 2^b``;
      * the count ceiling is at least ``1 - 4/(3b+2)`` (even ``b``);
      * both profiles respect the resolution law ``1 - 1/K^2 + 1/n^2``;
      * the dyadic profile is half-mass, so its ceiling obeys the 0.936 cap.
    """
    n = 1 << bitlen
    dy = dyadic_profile(bitlen)
    bi = binomial_profile(bitlen)
    dy_c = tie_ceiling_exact(dy)
    bi_c = tie_ceiling_exact(bi)
    closed = Fraction(6, 7) * (Fraction(1) + Fraction(1, n * (n + 1)))
    resolution = lambda K: Fraction(1) - Fraction(1, K * K) + Fraction(1, n * n)
    report: Dict[str, object] = {
        "dyadic_ceiling": dy_c,
        "dyadic_closed_form_matches": dy_c == closed,
        "count_ceiling": bi_c,
        "count_lower_bound_holds":
            bitlen % 2 == 1 or bi_c >= Fraction(1) - Fraction(4, 3 * bitlen + 2),
        "dyadic_respects_resolution": dy_c <= resolution(len(dy)),
        "count_respects_resolution": bi_c <= resolution(len(bi)),
        "dyadic_is_half_mass": 2 * max(dy) >= n,
        "half_mass_cap_holds": float(dy_c) ** 0.5 <= 0.936,
        "inversion_holds": bi_c > dy_c,
    }
    return report
# ===== /ALG2 =====


# ===== ALG3 =====
def certify_envelope(
    profile: Sequence[int],
    reading: Fraction,
    band: Tuple[Fraction, Fraction],
    drift_budget: Fraction,
    lipschitz: Fraction = Fraction(41, 10),
) -> Tuple[bool, List[str]]:
    """Certified deployment-envelope check for a recorded rank correlation.

    Runs five independent certificates, each an exact-arithmetic comparison:

      1. *Own-ceiling*: the squared reading is strictly below the profile's
         tie ceiling.  A violation means the reading is impossible.
      2. *Half-mass cap*: if the modal class carries at least half the mass,
         the reading must not exceed 0.936 --- a distribution-free bound that
         holds under every draw law with a majority-modal sample.
      3. *Resolution law*: the ceiling must respect ``1 - 1/K^2 + 1/n^2``.
         A violation indicates an arithmetic error upstream.
      4. *Band admissibility*: the top of the validation band must lie below
         the ceiling, else the band could never be met.
      5. *Drift envelope*: after a worst-case draw-law shift of total variation
         ``drift_budget``, the ceiling is still at least
         ``ceiling - lipschitz * drift_budget``, and the top of the band must
         remain strictly beneath that.  This is the deployment guarantee.

    Returns ``(passed, messages)``.  Cost: O(K) exact operations; the entire
    check can be executed before any data is collected.
    """
    msgs: List[str] = []
    n = sum(profile)
    K = len(profile)
    c2 = tie_ceiling_exact(profile)
    lo, hi = band
    ok = True

    if reading**2 < c2:
        msgs.append(f"[1] own-ceiling OK: reading^2 = {float(reading**2):.6f} < "
                    f"{float(c2):.6f}")
    else:
        ok = False
        msgs.append(f"[1] FAIL: reading^2 = {float(reading**2):.6f} >= ceiling "
                    f"{float(c2):.6f} (impossible reading)")

    if 2 * max(profile) >= n:
        if reading <= Fraction(936, 1000):
            msgs.append("[2] half-mass cap OK: modal class carries >= n/2 and "
                        f"reading {float(reading):.3f} <= 0.936")
        else:
            ok = False
            msgs.append(f"[2] FAIL: reading {float(reading):.3f} exceeds the "
                        "distribution-free half-mass cap 0.936")
    else:
        msgs.append("[2] half-mass cap not applicable (no class carries half the mass)")

    res = Fraction(1) - Fraction(1, K * K) + Fraction(1, n * n)
    if c2 <= res:
        msgs.append(f"[3] resolution law OK: {float(c2):.6f} <= {float(res):.6f} "
                    f"(K = {K})")
    else:
        ok = False
        msgs.append("[3] FAIL: ceiling exceeds the resolution bound")

    if hi**2 < c2:
        msgs.append(f"[4] band admissible: band top^2 = {float(hi**2):.6f} < "
                    f"{float(c2):.6f}")
    else:
        ok = False
        msgs.append("[4] FAIL: the validation band reaches above the ceiling")

    guaranteed = c2 - lipschitz * drift_budget
    if hi**2 < guaranteed:
        msgs.append(f"[5] envelope OK: after drift tau = {float(drift_budget):.4f} the "
                    f"ceiling is still >= {float(guaranteed):.6f} > "
                    f"{float(hi**2):.6f}")
    else:
        ok = False
        tolerated = (c2 - hi**2) / lipschitz
        msgs.append(f"[5] FAIL: drift budget too large; the band survives only up to "
                    f"tau = {float(tolerated):.4f}")
    return ok, msgs
# ===== /ALG3 =====


# ===== ALG4 =====
def franel_numbers(upto: int) -> List[int]:
    """Franel numbers ``F(b) = sum_k C(b,k)^3`` by their three-term recurrence.

    The Franel sequence (A000172) is P-recursive:

        (n+1)^2 F(n+1) = (7n^2 + 7n + 2) F(n) + 8 n^2 F(n-1),
        F(0) = 1,  F(1) = 2.

    Evaluating this recurrence costs ``O(b)`` big-integer operations, versus the
    ``O(b)`` cubings of the naive definition, and --- more importantly --- it is
    the analytic handle for the asymptotics of ``F(b)/8^b``, which controls the
    exact rate at which the Hamming-weight tie ceiling approaches 1.

    The division by ``(n+1)^2`` is exact at every step.
    """
    if upto < 0:
        return []
    out = [1, 2][: upto + 1]
    for m in range(1, upto):
        nxt = ((7 * m * m + 7 * m + 2) * out[m] + 8 * m * m * out[m - 1]) // ((m + 1) ** 2)
        out.append(nxt)
    return out


def count_ceiling_from_franel(bitlen: int, franel_value: Optional[int] = None) -> Fraction:
    """Exact Hamming-weight tie ceiling ``1 - (F(b) - 2^b)/(8^b - 2^b)``."""
    f = franel_value if franel_value is not None else franel_numbers(bitlen)[bitlen]
    n = 1 << bitlen
    return Fraction(1) - Fraction(f - n, n**3 - n)
# ===== /ALG4 =====


if __name__ == "__main__":
    print("tie_ceiling_exact([4,3,2,1]) =", tie_ceiling_exact([4, 3, 2, 1]))
    for b in (4, 8, 52):
        print(f"\ncertify_closed_forms({b}):")
        for k, v in certify_closed_forms(b).items():
            print(f"   {k:<32} {v if not isinstance(v, Fraction) else float(v):.10}"
                  if isinstance(v, Fraction) else f"   {k:<32} {v}")

    print("\nFranel numbers F(0..8):", franel_numbers(8))
    naive = [sum(__import__("math").comb(b, k) ** 3 for k in range(b + 1)) for b in range(9)]
    print("naive definition       :", naive)
    print("recurrence matches     :", franel_numbers(8) == naive)
    print("F(52) via recurrence == naive:",
          franel_numbers(52)[52]
          == sum(__import__("math").comb(52, k) ** 3 for k in range(53)))
    print("count ceiling at b=52  :", float(count_ceiling_from_franel(52)))

    ok, msgs = certify_envelope(
        dyadic_profile(52),
        reading=Fraction(705, 1000),
        band=(Fraction(55, 100), Fraction(85, 100)),
        drift_budget=Fraction(1, 100),
    )
    print("\ncertify_envelope(dial at bitlen 52, reading 0.705, drift 1%):", ok)
    for m in msgs:
        print("   ", m)
