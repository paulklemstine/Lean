"""
demo.py — Numerical demonstrations of the exact theory of empirical Rademacher
complexity for finite function classes.

This script is fully self-contained (standard library only). It mirrors the
definitions and theorems developed in the accompanying article and research
paper:

  Definitions
    radSign  : the +/-1 sign of a Boolean sign vector at a coordinate
    radSum   : the Rademacher correlation  sum_i radSign(sigma, i) * f(i)
    emp_rad  : the empirical Rademacher complexity, an exact average over all
               2^m sign vectors of the best-correlating class member

  Theorems verified numerically
    Thm 3.1  Cancellation:        sum_sigma radSign(sigma, i) = 0
    Thm 4.1  Zero mean:           sum_sigma radSum(f, sigma) = 0
    Thm 4.2  Oddness:             radSum(-f, sigma) = -radSum(f, sigma)
    Thm 4.3  Singletons free:     emp_rad({f}) = 0
    Thm 4.4  Monotonicity:        F subset G  =>  emp_rad(F) <= emp_rad(G)
    Thm 4.5  Nonnegativity:       0 in F  =>  emp_rad(F) >= 0
    Thm 5.1  Symmetric pair:      emp_rad({f,-f}) = (1/m)(1/2^m) sum_sigma |radSum(f,sigma)|
    Cor 5.2  Pair nonnegativity:  emp_rad({f,-f}) >= 0
"""

from __future__ import annotations

import itertools
import random
from typing import Iterable, List, Sequence, Tuple

Vector = Sequence[float]


# --------------------------------------------------------------------------- #
# Core definitions                                                            #
# --------------------------------------------------------------------------- #
def rad_sign(sigma: Sequence[bool], i: int) -> float:
    """The +/-1 Rademacher sign of sign vector `sigma` at coordinate `i`."""
    return 1.0 if sigma[i] else -1.0


def rad_sum(f: Vector, sigma: Sequence[bool]) -> float:
    """Rademacher correlation  sum_i radSign(sigma, i) * f(i)."""
    return sum(rad_sign(sigma, i) * f[i] for i in range(len(f)))


def all_sign_vectors(m: int) -> Iterable[Tuple[bool, ...]]:
    """Enumerate all 2^m Boolean sign vectors of length m."""
    return itertools.product([False, True], repeat=m)


def emp_rad(classF: Sequence[Vector]) -> float:
    """
    Exact empirical Rademacher complexity of a finite, nonempty class `classF`,
    each member an m-vector. Computed by brute-force enumeration of all 2^m
    sign vectors.  Complexity: O(2^m * |F| * m).
    """
    if not classF:
        raise ValueError("Function class must be nonempty.")
    m = len(classF[0])
    if any(len(f) != m for f in classF):
        raise ValueError("All members of the class must have the same length.")
    total = 0.0
    for sigma in all_sign_vectors(m):
        total += max(rad_sum(f, sigma) for f in classF)
    return (1.0 / m) * (1.0 / (2.0 ** m)) * total


def emp_rad_symmetric_pair_closed_form(f: Vector) -> float:
    """
    Closed form for emp_rad({f, -f}) via Theorem 5.1:
        (1/m)(1/2^m) sum_sigma |radSum(f, sigma)|.
    Complexity: O(2^m * m).
    """
    m = len(f)
    total = sum(abs(rad_sum(f, sigma)) for sigma in all_sign_vectors(m))
    return (1.0 / m) * (1.0 / (2.0 ** m)) * total


def neg(f: Vector) -> List[float]:
    """Coordinatewise negation of a vector."""
    return [-x for x in f]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
EPS = 1e-9


def demo_cancellation(m: int = 4) -> None:
    """Theorem 3.1: sum over all sign vectors of radSign at coordinate i is 0."""
    print(f"[Thm 3.1] Cancellation (m={m}):")
    for i in range(m):
        s = sum(rad_sign(sigma, i) for sigma in all_sign_vectors(m))
        print(f"    coordinate {i}: sum radSign = {s:+.1f}")
        assert abs(s) < EPS
    print("    OK: all coordinate sign-sums vanish.\n")


def demo_zero_mean(m: int = 4, trials: int = 5) -> None:
    """Theorem 4.1: sum over sign vectors of radSum(f, .) is 0 for any fixed f."""
    print(f"[Thm 4.1] Zero mean of a fixed function (m={m}):")
    for _ in range(trials):
        f = [random.uniform(-3, 3) for _ in range(m)]
        s = sum(rad_sum(f, sigma) for sigma in all_sign_vectors(m))
        assert abs(s) < EPS
    print(f"    OK: sum_sigma radSum(f, sigma) = 0 over {trials} random f.\n")


def demo_oddness(m: int = 4, trials: int = 5) -> None:
    """Theorem 4.2: radSum(-f, sigma) = -radSum(f, sigma)."""
    print(f"[Thm 4.2] Oddness (m={m}):")
    for _ in range(trials):
        f = [random.uniform(-3, 3) for _ in range(m)]
        for sigma in all_sign_vectors(m):
            assert abs(rad_sum(neg(f), sigma) + rad_sum(f, sigma)) < EPS
    print(f"    OK: radSum(-f) = -radSum(f) over {trials} random f.\n")


def demo_singleton() -> None:
    """Theorem 4.3: emp_rad({f}) = 0."""
    print("[Thm 4.3] Singletons have zero complexity:")
    f = [1.0, -2.0, 0.5, 3.0]
    val = emp_rad([f])
    print(f"    emp_rad({{f}}) = {val:.2e}")
    assert abs(val) < EPS
    print("    OK.\n")


def demo_symmetric_pair() -> None:
    """Theorem 5.1 and Corollary 5.2 for {f, -f}."""
    print("[Thm 5.1] Symmetric-pair exact formula:")
    f = [1.0, -2.0, 0.5]
    brute = emp_rad([list(f), neg(f)])
    closed = emp_rad_symmetric_pair_closed_form(f)
    print(f"    f = {f}")
    print(f"    brute-force emp_rad({{f,-f}}) = {brute:.10f}")
    print(f"    closed-form  (avg |radSum|)  = {closed:.10f}")
    assert abs(brute - closed) < EPS
    assert brute >= -EPS  # Corollary 5.2
    print("    OK: brute force matches closed form; value is nonnegative.\n")


def demo_monotonicity(m: int = 4, trials: int = 20) -> None:
    """Theorem 4.4: F subset G => emp_rad(F) <= emp_rad(G)."""
    print(f"[Thm 4.4] Monotonicity (m={m}):")
    for _ in range(trials):
        base = [[random.uniform(-2, 2) for _ in range(m)] for _ in range(2)]
        extra = [random.uniform(-2, 2) for _ in range(m)]
        smaller = base
        larger = base + [extra]
        assert emp_rad(smaller) <= emp_rad(larger) + EPS
    print(f"    OK: enlarging the class never decreases complexity ({trials} trials).\n")


def demo_nonnegativity(m: int = 4, trials: int = 20) -> None:
    """Theorem 4.5: 0 in F => emp_rad(F) >= 0."""
    print(f"[Thm 4.5] Nonnegativity for classes containing 0 (m={m}):")
    zero = [0.0] * m
    for _ in range(trials):
        members = [[random.uniform(-2, 2) for _ in range(m)]
                   for _ in range(random.randint(1, 4))]
        classF = [zero] + members
        assert emp_rad(classF) >= -EPS
    print(f"    OK: complexity nonnegative when 0 is present ({trials} trials).\n")


def main() -> None:
    random.seed(20260611)
    print("=" * 70)
    print("Empirical Rademacher Complexity — Numerical Demonstrations")
    print("=" * 70 + "\n")
    demo_cancellation()
    demo_zero_mean()
    demo_oddness()
    demo_singleton()
    demo_symmetric_pair()
    demo_monotonicity()
    demo_nonnegativity()
    print("All demonstrations passed: the exact identities hold numerically.")


if __name__ == "__main__":
    main()
