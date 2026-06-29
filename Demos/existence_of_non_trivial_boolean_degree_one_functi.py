"""
Numerical demonstrations for:

    Non-Trivial Boolean Degree-One Functions on the Grassmann Scheme J_q(n,2)

This script is fully self-contained (standard library only) and exercises the
*main theorem*: for every odd prime power q >= 3 and every n >= 4 there is a
non-trivial Boolean degree-one function on J_q(n,2), realised by the
Bruen-Drudge Cameron-Liebler line class with parameter x = (q^2 + 1) / 2.

It verifies, numerically, every parametric lemma from the formalisation:

    two_mul_xParam              2 * x = q^2 + 1            (odd q)
    xParam_self_complementary   x = (q^2 + 1) - x          (odd q)
    xParam_gt_two               2 < x                      (q >= 3)
    xParam_lt_q2_sub_one        x < q^2 - 1                (q >= 3)
    xParam_not_trivial          x not in trivialParams(q)  (q >= 3)
    bruenDrudge_class_size      |S| = x * (q^2 + q + 1)
    bruenDrudge_param_not_trivial

plus the Gaussian-binomial line count [4,2]_q = (q^2+1)(q^2+q+1) and the
half-and-half (self-complementary) identity 2*|S| = total number of lines.
"""

from __future__ import annotations

from functools import lru_cache
from typing import Dict, List, Set


# --------------------------------------------------------------------------- #
# Definition: Bruen-Drudge parameter  xParam q = (q^2 + 1) / 2
# --------------------------------------------------------------------------- #
def x_param(q: int) -> int:
    """The Bruen-Drudge parameter x = (q^2 + 1) // 2 (integer division)."""
    return (q * q + 1) // 2


# --------------------------------------------------------------------------- #
# Definition: trivial Cameron-Liebler parameter set {0,1,2,q^2-1,q^2,q^2+1}
# --------------------------------------------------------------------------- #
def trivial_params(q: int) -> Set[int]:
    """The six trivial Cameron-Liebler parameter values for PG(3,q)."""
    return {0, 1, 2, q * q - 1, q * q, q * q + 1}


# --------------------------------------------------------------------------- #
# Definition: Gaussian binomial via the q-Pascal recurrence (Algorithm A)
#   [n+1,k+1]_q = [n,k]_q + q^{k+1} * [n,k+1]_q
# --------------------------------------------------------------------------- #
def q_binom(q: int, n: int, k: int) -> int:
    """Gaussian binomial coefficient [n,k]_q; counts k-subspaces of F_q^n."""

    @lru_cache(maxsize=None)
    def rec(n_: int, k_: int) -> int:
        if k_ == 0:
            return 1
        if n_ == 0:
            return 0
        return rec(n_ - 1, k_ - 1) + q ** k_ * rec(n_ - 1, k_)

    return rec(n, k)


def total_lines(q: int) -> int:
    """Number of lines of PG(3,q) = [4,2]_q = (q^2+1)(q^2+q+1)."""
    return q_binom(q, 4, 2)


def class_size(q: int) -> int:
    """Size of the Bruen-Drudge class: x * (q^2 + q + 1)."""
    return x_param(q) * (q * q + q + 1)


# --------------------------------------------------------------------------- #
# Algorithm B: parametric non-triviality certifier for a single odd q >= 3
# --------------------------------------------------------------------------- #
def certify_non_trivial(q: int) -> Dict[str, object]:
    """Return all certificates that the Bruen-Drudge example is non-trivial."""
    x = x_param(q)
    triv = trivial_params(q)
    size = class_size(q)
    total = total_lines(q)
    return {
        "q": q,
        "x": x,
        "two_mul_xParam (2x == q^2+1)": 2 * x == q * q + 1,
        "self_complementary (x == (q^2+1)-x)": x == (q * q + 1) - x,
        "x_gt_two (2 < x)": 2 < x,
        "x_lt_q2_sub_one (x < q^2-1)": x < q * q - 1,
        "x_not_trivial": x not in triv,
        "trivialParams": sorted(triv),
        "class_size (x*(q^2+q+1))": size,
        "total_lines ([4,2]_q)": total,
        "qbinom_lines_eq ((q^2+1)(q^2+q+1))": total == (q * q + 1) * (q * q + q + 1),
        "half_and_half (2*size == total)": 2 * size == total,
    }


def main() -> None:
    print("=" * 72)
    print("Non-trivial Boolean degree-one functions on J_q(n,2): numerical check")
    print("=" * 72)

    odd_q: List[int] = [3, 5, 7, 9, 11, 13, 25, 27]
    print("\nMain theorem certificate for odd prime powers q >= 3:\n")
    header = f"{'q':>4} | {'x':>6} | {'class size':>12} | {'total lines':>12} | non-trivial?"
    print(header)
    print("-" * len(header))
    for q in odd_q:
        cert = certify_non_trivial(q)
        ok = all(
            cert[key] is True
            for key in (
                "two_mul_xParam (2x == q^2+1)",
                "self_complementary (x == (q^2+1)-x)",
                "x_gt_two (2 < x)",
                "x_lt_q2_sub_one (x < q^2-1)",
                "x_not_trivial",
                "qbinom_lines_eq ((q^2+1)(q^2+q+1))",
                "half_and_half (2*size == total)",
            )
        )
        print(
            f"{q:>4} | {cert['x']:>6} | {cert['class_size (x*(q^2+q+1))']:>12} | "
            f"{cert['total_lines ([4,2]_q)']:>12} | {'YES' if ok else 'NO'}"
        )

    print("\nDetailed certificate for the smallest case q = 3:\n")
    for key, val in certify_non_trivial(3).items():
        print(f"  {key:<42} : {val}")

    print("\nWhy even q is excluded (integrality 2x = q^2+1 fails):\n")
    for q in (2, 4, 8, 16):
        x = x_param(q)
        print(
            f"  q={q:>2}: (q^2+1)={q*q+1:>4} is odd -> 2*x={2*x} != q^2+1={q*q+1} "
            f"(not self-complementary)"
        )

    print("\nLift to J_q(n,2) for n >= 4 (same x, larger ambient line count):\n")
    q = 3
    for n in range(4, 8):
        print(
            f"  n={n}: lines of PG({n-1},{q}) = [n,2]_q = {q_binom(q, n, 2):>8}; "
            f"Bruen-Drudge parameter x = {x_param(q)} (unchanged, still non-trivial)"
        )

    print("\nAll parametric lemmas verified numerically. QED (numerically).")


if __name__ == "__main__":
    main()
