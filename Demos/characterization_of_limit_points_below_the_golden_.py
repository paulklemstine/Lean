"""
Numerical demonstrations for:

    Limit Points of Largest Matching Roots Below the Golden-Ratio Threshold

Central objects
---------------
* Path matching polynomials mu(P_n), defined by the edge-deletion recurrence
      mu(P_0) = 1,  mu(P_1) = x,  mu(P_{n+2}) = x * mu(P_{n+1}) - mu(P_n).
  (These are Chebyshev polynomials of the second kind U_n(x/2).)

* Largest matching root of P_n:   mu(P_n) = 2 cos(pi / (n + 1)).

* Golden ratio       tau = (1 + sqrt 5) / 2
  Golden threshold   T   = sqrt(2 + sqrt 5) = sqrt(tau) + 1/sqrt(tau) ~ 2.058.

Results demonstrated
--------------------
1. The recurrence reproduces the closed-form roots 2 cos(k pi/(n+1)).
2. The trigonometric identity mu(P_n)(2 cos t) sin t = sin((n+1) t).
3. The staircase of largest roots strictly increases to 2, staying below T.
4. mu(P_4) = tau exactly; T = sqrt(tau) + 1/sqrt(tau); 2 < T.

Pure standard library (math only). Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import List


# ---------------------------------------------------------------------------
# Path matching polynomial via the edge-deletion recurrence.
# Coefficients are stored highest-degree-first: [a_n, ..., a_1, a_0].
# ---------------------------------------------------------------------------
def path_matching_poly(n: int) -> List[float]:
    """Return the coefficients of mu(P_n), degree n, highest degree first."""
    if n == 0:
        return [1.0]
    if n == 1:
        return [1.0, 0.0]
    prev2: List[float] = [1.0]        # mu(P_0)
    prev1: List[float] = [1.0, 0.0]   # mu(P_1)
    for _ in range(2, n + 1):
        # x * prev1  == shift prev1 up by one degree (append a 0)
        x_prev1 = prev1 + [0.0]
        # subtract prev2 (aligned to the constant end)
        cur = list(x_prev1)
        offset = len(cur) - len(prev2)
        for i, c in enumerate(prev2):
            cur[offset + i] -= c
        prev2, prev1 = prev1, cur
    return prev1


def poly_eval(coeffs: List[float], x: float) -> float:
    """Horner evaluation of a highest-degree-first coefficient list."""
    acc = 0.0
    for c in coeffs:
        acc = acc * x + c
    return acc


# ---------------------------------------------------------------------------
# Closed forms.
# ---------------------------------------------------------------------------
def largest_matching_root(n: int) -> float:
    """Largest matching root of P_n = 2 cos(pi/(n+1)) for n >= 1."""
    return 2.0 * math.cos(math.pi / (n + 1))


def all_matching_roots(n: int) -> List[float]:
    """All roots 2 cos(k pi/(n+1)), k = 1..n, largest first."""
    return [2.0 * math.cos(k * math.pi / (n + 1)) for k in range(1, n + 1)]


TAU = (1.0 + math.sqrt(5.0)) / 2.0
GOLDEN_THRESHOLD = math.sqrt(2.0 + math.sqrt(5.0))


# ---------------------------------------------------------------------------
# Independent numerical root isolation (bisection) as a cross-check.
# ---------------------------------------------------------------------------
def largest_root_bisection(n: int, tol: float = 1e-13) -> float:
    """Isolate the largest root of mu(P_n) in [1, 2) by bisection."""
    coeffs = path_matching_poly(n)
    lo, hi = largest_matching_root(n) - 0.05, 2.0 - 1e-15
    f_hi = poly_eval(coeffs, hi)  # positive (value at 2 is n+1 > 0)
    # ensure a sign change: value just below the true root is negative
    lo = max(lo, 0.0)
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if poly_eval(coeffs, mid) * f_hi > 0:
            hi = mid
        else:
            lo = mid
    return 0.5 * (lo + hi)


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------
def demo_polynomials() -> None:
    print("=" * 70)
    print("1. Path matching polynomials mu(P_n) (Chebyshev U_n(x/2))")
    print("=" * 70)
    names = {2: "x^2 - 1", 3: "x^3 - 2x", 4: "x^4 - 3x^2 + 1", 5: "x^5 - 4x^3 + 3x"}
    for n in range(0, 6):
        coeffs = path_matching_poly(n)
        pretty = "  ".join(f"{c:+.0f}" for c in coeffs)
        extra = f"   = {names[n]}" if n in names else ""
        print(f"  mu(P_{n}): [{pretty}]{extra}")
        assert abs(poly_eval(coeffs, 2.0) - (n + 1)) < 1e-9, "value at 2 must be n+1"
    print("  Check: mu(P_n)(2) = n+1 for all n above.  OK")


def demo_trig_identity() -> None:
    print("\n" + "=" * 70)
    print("2. Trigonometric identity  mu(P_n)(2 cos t) sin t = sin((n+1) t)")
    print("=" * 70)
    for n in (3, 7, 12):
        coeffs = path_matching_poly(n)
        max_err = 0.0
        for j in range(1, 20):
            t = j * math.pi / 21.0
            lhs = poly_eval(coeffs, 2.0 * math.cos(t)) * math.sin(t)
            rhs = math.sin((n + 1) * t)
            max_err = max(max_err, abs(lhs - rhs))
        print(f"  n={n:2d}: max |LHS - RHS| over sampled t = {max_err:.2e}")


def demo_roots() -> None:
    print("\n" + "=" * 70)
    print("3. Roots are exactly 2 cos(k pi/(n+1)); largest matches bisection")
    print("=" * 70)
    for n in (4, 6, 10):
        closed = all_matching_roots(n)
        num = largest_root_bisection(n)
        print(f"  n={n:2d}: roots (largest first) = "
              + ", ".join(f"{r:+.4f}" for r in closed))
        print(f"        largest closed-form = {closed[0]:.10f}")
        print(f"        largest bisection   = {num:.10f}   "
              f"(|diff| = {abs(num - closed[0]):.2e})")


def demo_staircase() -> None:
    print("\n" + "=" * 70)
    print("4. Staircase of largest matching roots -> 2, strictly below T")
    print("=" * 70)
    print(f"  golden ratio tau           = {TAU:.10f}")
    print(f"  golden threshold T         = {GOLDEN_THRESHOLD:.10f}")
    print(f"  sqrt(tau) + 1/sqrt(tau)    = "
          f"{math.sqrt(TAU) + 1.0 / math.sqrt(TAU):.10f}   (== T)")
    print(f"  2 < T ?                    = {2.0 < GOLDEN_THRESHOLD}")
    print()
    prev = -1.0
    for n in (2, 3, 4, 5, 6, 12, 102, 1002):
        mu = largest_matching_root(n)
        assert mu > prev, "sequence must strictly increase"
        assert mu < 2.0 < GOLDEN_THRESHOLD, "must stay below 2 < T"
        tag = "   <-- P_4: exactly tau" if n == 4 else ""
        print(f"  P_{n:<5d} largest root = {mu:.12f}{tag}")
        prev = mu
    print()
    print(f"  mu(P_4) - tau = {largest_matching_root(4) - TAU:.2e}  (exact equality)")


def main() -> None:
    demo_polynomials()
    demo_trig_identity()
    demo_roots()
    demo_staircase()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
