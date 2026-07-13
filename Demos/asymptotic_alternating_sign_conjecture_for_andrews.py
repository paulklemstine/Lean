"""
Numerical demonstrations for:

    Asymptotic Alternating Signs of Andrews-type q-Series Coefficients

This self-contained script illustrates the amplitude-domination principle and
its three model series v2, v3, v4, together with the boundary (sharpness) series.

The amplitude-domination principle states: if a sequence decomposes as

        V(n) = (-1)^n * A(n) + E(n)

with a positive amplitude A(n) and an error E(n) satisfying |E(n)| < A(n) for
all n >= N, then the sign-corrected sequence (-1)^n * V(n) is strictly positive
for all n >= N; i.e. the signs of V(n) strictly alternate from N onward.

Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable


# --------------------------------------------------------------------------- #
# Model series (exact integer arithmetic throughout)                          #
# --------------------------------------------------------------------------- #

def sign_osc(n: int) -> int:
    """The oscillatory factor (-1)^n, returning +1 or -1."""
    return 1 if n % 2 == 0 else -1


def is_square(n: int) -> bool:
    """True iff the non-negative integer n is a perfect square."""
    if n < 0:
        return False
    r = math.isqrt(n)
    return r * r == n


def V2(n: int) -> int:
    """v2: exponential amplitude 2^n + 1, linear error n. Alternates for all n."""
    return sign_osc(n) * (2 ** n + 1) + n


def V3(n: int) -> int:
    """v3: amplitude n - 4, constant error 2. Alternates for n >= 7."""
    return sign_osc(n) * (n - 4) + 2


def E4(n: int) -> int:
    """Tuned error for v4: nonzero only on perfect squares, where it inverts."""
    if is_square(n):
        return -sign_osc(n) * (2 * (n + 1))
    return 0


def V4(n: int) -> int:
    """v4: amplitude n + 1; sign inverted exactly on the perfect squares."""
    return sign_osc(n) * (n + 1) + E4(n)


def W_boundary(n: int) -> int:
    """
    Boundary series at critical balance |E| = A.  Amplitude A(n) = n + 1;
    on odd n the error cancels the dominant term, forcing W(n) = 0 there.
    """
    A = n + 1
    if n % 2 == 1:
        # E(n) = -(-1)^n * A(n)  ->  W(n) = 0
        return sign_osc(n) * A - sign_osc(n) * A
    return sign_osc(n) * A


# --------------------------------------------------------------------------- #
# Generic verifier / counter                                                  #
# --------------------------------------------------------------------------- #

def corrected(V: Callable[[int], int], n: int) -> int:
    """The sign-corrected coefficient (-1)^n * V(n)."""
    return sign_osc(n) * V(n)


def exceptional_indices(V: Callable[[int], int], M: int, N: int = 0) -> list[int]:
    """Indices N <= n < M where alternation fails, i.e. (-1)^n V(n) <= 0."""
    return [n for n in range(N, M) if corrected(V, n) <= 0]


def excCount4(M: int) -> int:
    """Number of exceptional indices of v4 below M (the perfect squares)."""
    return sum(1 for n in range(M) if is_square(n))


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_v2(M: int = 12) -> None:
    print("=" * 68)
    print("v2:  V2(n) = (-1)^n (2^n + 1) + n   --- alternates for ALL n")
    print("=" * 68)
    print(f"{'n':>3} {'V2(n)':>10} {'(-1)^n V2(n)':>14}")
    for n in range(M):
        print(f"{n:>3} {V2(n):>10} {corrected(V2, n):>14}")
    exc = exceptional_indices(V2, M)
    print(f"exceptional indices in [0,{M}): {exc}  (expected: none)\n")


def demo_v3(M: int = 14) -> None:
    print("=" * 68)
    print("v3:  V3(n) = (-1)^n (n - 4) + 2     --- alternates for n >= 7")
    print("=" * 68)
    print(f"{'n':>3} {'V3(n)':>8} {'(-1)^n V3(n)':>14}")
    for n in range(M):
        flag = "" if corrected(V3, n) > 0 else "   <-- violation"
        print(f"{n:>3} {V3(n):>8} {corrected(V3, n):>14}{flag}")
    exc = exceptional_indices(V3, M)
    print(f"exceptional indices in [0,{M}): {exc}")
    exc_ge7 = exceptional_indices(V3, M, N=7)
    print(f"exceptional indices in [7,{M}): {exc_ge7}  (expected: none)\n")


def demo_v4(M: int = 26) -> None:
    print("=" * 68)
    print("v4:  V4(n) = (-1)^n (n + 1) + E4(n) --- fails exactly on squares")
    print("=" * 68)
    print(f"{'n':>3} {'square?':>8} {'V4(n)':>8} {'(-1)^n V4(n)':>14}")
    for n in range(M):
        sq = "yes" if is_square(n) else ""
        flag = "" if corrected(V4, n) > 0 else "   <-- violation"
        print(f"{n:>3} {sq:>8} {V4(n):>8} {corrected(V4, n):>14}{flag}")
    exc = exceptional_indices(V4, M)
    squares = [n for n in range(M) if is_square(n)]
    print(f"exceptional indices in [0,{M}): {exc}")
    print(f"perfect squares in [0,{M}):    {squares}  (should match)\n")


def demo_density(bounds: tuple[int, ...] = (100, 1000, 10000, 100000, 1000000)) -> None:
    print("=" * 68)
    print("v4 exceptional-set density -> 0   (counting bound floor(sqrt M)+1)")
    print("=" * 68)
    print(f"{'M':>9} {'exc(M)':>8} {'bound':>8} {'exc/M':>12} {'1/s+1/s^2':>12}")
    for M in bounds:
        c = excCount4(M)
        s = math.isqrt(M)
        bound = s + 1
        density = c / M
        analytic = 1 / s + 1 / (s * s)
        print(f"{M:>9} {c:>8} {bound:>8} {density:>12.6f} {analytic:>12.6f}")
    print("Both the empirical density and the analytic bound tend to 0.\n")


def demo_boundary(M: int = 12) -> None:
    print("=" * 68)
    print("Boundary series W at |E| = A --- alternation fails on ALL odd n")
    print("=" * 68)
    print(f"{'n':>3} {'W(n)':>8} {'(-1)^n W(n)':>14}")
    for n in range(M):
        flag = "" if corrected(W_boundary, n) > 0 else "   <-- violation (density 1/2)"
        print(f"{n:>3} {W_boundary(n):>8} {corrected(W_boundary, n):>14}{flag}")
    exc = exceptional_indices(W_boundary, M)
    print(f"exceptional indices in [0,{M}): {exc}  (all odd -> density 1/2)\n")


def main() -> None:
    demo_v2()
    demo_v3()
    demo_v4()
    demo_density()
    demo_boundary()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
