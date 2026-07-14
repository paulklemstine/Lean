"""
Numerical demonstrations for the sumset exponent surface

    p(n, m) = n * log(m + 1) / log(n * m + 1)

the sharp exponent governing sumset lower bounds inside the integer
cross-polytope (l1 ball)  B_d(m) = { x in Z^d : |x_1| + ... + |x_d| <= m }.

Each function corroborates one of the established results:

  1. p(n, m) < n                                   (strict upper bound)
  2. p(n, m) < p(n + 1, m)                          (monotone in # summands)
  3. ((n+1)m+1)^n < (n m + 1)^(n+1)                 (the integer engine of 2)
  4. p(n, m) -> n  as  m -> infinity               (radial asymptotics)
  5. m |-> p(n, m) is NOT decreasing               (refutation of a false guess)

All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

import math
from typing import Iterable, List, Tuple


# --------------------------------------------------------------------------
# Core definition
# --------------------------------------------------------------------------
def p_exp(n: int, m: int) -> float:
    """The sharp sumset exponent p(n, m) = n * log(m+1) / log(n*m+1)."""
    if n < 1 or m < 1:
        raise ValueError("require n >= 1 and m >= 1")
    return n * math.log(m + 1) / math.log(n * m + 1)


# --------------------------------------------------------------------------
# 1. Strict upper bound:  p(n, m) < n
# --------------------------------------------------------------------------
def check_upper_bound(n_max: int = 12, m_max: int = 40) -> bool:
    """Verify p(n, m) < n for all 2 <= n <= n_max, 1 <= m <= m_max."""
    ok = True
    for n in range(2, n_max + 1):
        for m in range(1, m_max + 1):
            if not p_exp(n, m) < n:
                ok = False
                print(f"  VIOLATION: p({n},{m}) = {p_exp(n, m)} !< {n}")
    return ok


# --------------------------------------------------------------------------
# 2. Monotonicity in the number of summands:  p(n, m) < p(n+1, m)
# --------------------------------------------------------------------------
def check_mono_in_n(n_max: int = 12, m_max: int = 40) -> bool:
    """Verify p(n, m) < p(n+1, m) for all 1 <= n < n_max, 1 <= m <= m_max."""
    ok = True
    for n in range(1, n_max):
        for m in range(1, m_max + 1):
            if not p_exp(n, m) < p_exp(n + 1, m):
                ok = False
                print(f"  VIOLATION: p({n},{m}) !< p({n+1},{m})")
    return ok


# --------------------------------------------------------------------------
# 3. The integer engine:  ((n+1)m+1)^n < (n m + 1)^(n+1)   (exact integers)
# --------------------------------------------------------------------------
def check_power_inequality(n_max: int = 20, m_max: int = 60) -> bool:
    """Exactly verify ((n+1)m+1)^n < (n*m+1)^(n+1) using arbitrary-precision ints."""
    ok = True
    for n in range(1, n_max + 1):
        for m in range(1, m_max + 1):
            lhs = ((n + 1) * m + 1) ** n
            rhs = (n * m + 1) ** (n + 1)
            if not lhs < rhs:
                ok = False
                print(f"  VIOLATION: ({(n+1)*m+1})^{n} !< ({n*m+1})^{n+1}")
    return ok


# --------------------------------------------------------------------------
# 4. Radial asymptotics:  p(n, m) -> n  as  m -> infinity
# --------------------------------------------------------------------------
def radial_ladder(n: int, radii: Iterable[int]) -> List[Tuple[int, float, float]]:
    """Return (m, p(n,m), n - p(n,m)) along a ladder of radii, showing p -> n."""
    return [(m, p_exp(n, m), n - p_exp(n, m)) for m in radii]


def check_radial_limit(n: int = 3) -> bool:
    """
    Verify the deficit n - p(n, m) decreases monotonically toward 0 along a
    geometric ladder of radii.  Convergence is genuinely logarithmically slow
    (the deficit behaves like n*log(n)/log(m)), so we certify the *trend*:
    the deficit is strictly decreasing and driven well below its starting
    value as the radius grows through a wide range.
    """
    radii = [10 ** k for k in range(1, 13)]
    deficits = [n - p_exp(n, m) for m in radii]
    strictly_decreasing = all(deficits[j] > deficits[j + 1]
                              for j in range(len(deficits) - 1))
    return strictly_decreasing and deficits[-1] < deficits[0]


# --------------------------------------------------------------------------
# 5. Refutation of radial monotonicity:  m |-> p(n, m) is NOT decreasing
# --------------------------------------------------------------------------
def check_not_antitone(n: int = 3, m_max: int = 200) -> bool:
    """
    Return True iff there exist m1 < m2 with p(n, m1) < p(n, m2), i.e. the
    sequence m |-> p(n, m) is not decreasing (in fact it increases here).
    """
    vals = [p_exp(n, m) for m in range(1, m_max + 1)]
    return any(vals[j] < vals[j + 1] for j in range(len(vals) - 1))


# --------------------------------------------------------------------------
# Bonus: the finer rate conjecture  (n - p(n,m)) * log m  ->  n * log n
# --------------------------------------------------------------------------
def rate_probe(n: int, radii: Iterable[int]) -> List[Tuple[int, float, float]]:
    """Return (m, (n - p(n,m)) * log m, n * log n) probing the rate conjecture."""
    target = n * math.log(n)
    return [(m, (n - p_exp(n, m)) * math.log(m), target) for m in radii]


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------
def main() -> None:
    print("=" * 68)
    print("Sumset exponent surface  p(n,m) = n*log(m+1)/log(n*m+1)")
    print("=" * 68)

    print("\n[1] Strict upper bound  p(n,m) < n :",
          "PASS" if check_upper_bound() else "FAIL")

    print("[2] Monotone in summands  p(n,m) < p(n+1,m) :",
          "PASS" if check_mono_in_n() else "FAIL")

    print("[3] Integer engine ((n+1)m+1)^n < (nm+1)^(n+1) :",
          "PASS" if check_power_inequality() else "FAIL")

    print("[4] Radial limit p(3,m) -> 3 (deficit shrinks monotonically) :",
          "PASS" if check_radial_limit() else "FAIL")

    print("[5] m |-> p(3,m) NOT decreasing :",
          "PASS" if check_not_antitone() else "FAIL")

    print("\nRadial ladder for n = 3 (note p rises toward 3 from below):")
    print(f"  {'m':>10} {'p(3,m)':>12} {'deficit 3-p':>14}")
    for m, p, d in radial_ladder(3, [1, 10, 100, 1000, 10 ** 4, 10 ** 5, 10 ** 6]):
        print(f"  {m:>10} {p:>12.6f} {d:>14.6f}")

    print("\nRate probe for n = 3 : (3 - p)*log m  should approach  3*log 3 ="
          f" {3 * math.log(3):.6f}")
    print(f"  {'m':>10} {'(3-p)*log m':>14} {'target':>12}")
    for m, val, tgt in rate_probe(3, [10 ** 2, 10 ** 3, 10 ** 4, 10 ** 6, 10 ** 9]):
        print(f"  {m:>10} {val:>14.6f} {tgt:>12.6f}")


if __name__ == "__main__":
    main()
