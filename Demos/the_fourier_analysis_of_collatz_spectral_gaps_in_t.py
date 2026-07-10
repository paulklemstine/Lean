"""
The Fourier Analysis of Collatz: Spectral Gaps in the 3n+1 Map
==============================================================

Self-contained numerical demonstrations of the results in the accompanying
paper.  We illustrate, using only the Python standard library:

  1. The spectral dichotomy of the geometric character sum
         S_N(w) = sum_{n<N} e(w)^n,      e(w) = exp(2*pi*i*w),
     comparing full resonance at integer frequencies (S_N = N) with the
     N-independent spectral gap |S_N(w)| <= 1/|sin(pi w)| at non-integer w.

  2. The half-angle modulus identity  |e(w) - 1| = 2|sin(pi w)|.

  3. The Nyquist bridge:  (e(1/2))^n = (-1)^n selects the Collatz branch, so
         T(n) = n/2 if (e(1/2))^n == 1 else 3n+1.

  4. The parity split of the Collatz Fourier transform
         F_N(w) = sum_{n<N} e(w * T(n)).

  5. The exact stopping time of powers of two:  T^[k](2^k) = 1.

Run:  python demo.py
"""

from __future__ import annotations

import cmath
import math
from typing import Callable


# --------------------------------------------------------------------------
# Fourier primitives
# --------------------------------------------------------------------------

def e(x: float) -> complex:
    """The additive character e(x) = exp(2*pi*i*x); a point on the unit circle."""
    return cmath.exp(2.0 * math.pi * 1j * x)


def character_sum(omega: float, N: int) -> complex:
    """Geometric character sum S_N(omega) = sum_{n<N} e(omega)^n."""
    base = e(omega)
    total = 0.0 + 0.0j
    power = 1.0 + 0.0j
    for _ in range(N):
        total += power
        power *= base
    return total


def spectral_gap_bound(omega: float) -> float:
    """The N-independent ceiling 1/|sin(pi*omega)| for non-integer omega."""
    s = abs(math.sin(math.pi * omega))
    return math.inf if s == 0.0 else 1.0 / s


# --------------------------------------------------------------------------
# Collatz primitives
# --------------------------------------------------------------------------

def collatz(n: int) -> int:
    """One step of the Collatz map: n/2 if even, else 3n+1."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_fourier(n: int) -> int:
    """Collatz step written purely via the Nyquist character e(1/2)^n."""
    # (e(1/2))^n = (-1)^n, which is +1 exactly when n is even.
    nyquist_power = e(0.5) ** n
    is_even_branch = abs(nyquist_power - 1.0) < 1e-9
    return n // 2 if is_even_branch else 3 * n + 1


def iterate(f: Callable[[int], int], n: int, k: int) -> int:
    """Apply f to n exactly k times."""
    for _ in range(k):
        n = f(n)
    return n


def stopping_time(n: int, cap: int = 100000) -> int:
    """Number of Collatz steps for n to first reach 1."""
    steps = 0
    while n != 1 and steps < cap:
        n = collatz(n)
        steps += 1
    return steps


def collatz_fourier_transform(omega: float, N: int) -> complex:
    """F_N(omega) = sum_{n<N} e(omega * T(n))."""
    return sum((e(omega * collatz(n)) for n in range(N)), 0.0 + 0.0j)


def collatz_fourier_transform_split(omega: float, N: int) -> complex:
    """Parity split of F_N(omega): even (halving) branch + odd (3n+1) branch."""
    even_branch = sum(
        (e(omega * (n // 2)) for n in range(N) if n % 2 == 0), 0.0 + 0.0j
    )
    odd_branch = sum(
        (e(omega * (3 * n + 1)) for n in range(N) if n % 2 != 0), 0.0 + 0.0j
    )
    return even_branch + odd_branch


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_dichotomy() -> None:
    print("=" * 70)
    print("1. Spectral dichotomy of the geometric character sum S_N(omega)")
    print("=" * 70)
    print("\n  Full resonance at integer frequencies (|S_N| should equal N):")
    for m in (0, 1, 2, 3):
        for N in (10, 100, 1000):
            s = character_sum(float(m), N)
            print(f"    omega={m}, N={N:5d}:  |S_N| = {abs(s):10.4f}  (N = {N})")
    print("\n  Spectral gap at non-integer frequencies (|S_N| <= 1/|sin(pi w)|,")
    print("  a ceiling independent of N):")
    for omega in (0.5, 1.0 / 3.0, math.sqrt(2) - 1, 0.1):
        bound = spectral_gap_bound(omega)
        print(f"    omega = {omega:.6f},  bound = {bound:10.4f}")
        for N in (10, 100, 10000):
            s = character_sum(omega, N)
            ok = "OK" if abs(s) <= bound + 1e-6 else "VIOLATION"
            print(f"        N={N:6d}:  |S_N| = {abs(s):10.4f}   [{ok}]")


def demo_half_angle() -> None:
    print("\n" + "=" * 70)
    print("2. Half-angle modulus identity  |e(w) - 1| = 2|sin(pi w)|")
    print("=" * 70)
    for omega in (0.1, 0.25, 0.5, 1.0 / 3.0, 0.9):
        lhs = abs(e(omega) - 1.0)
        rhs = 2.0 * abs(math.sin(math.pi * omega))
        print(f"    w={omega:.5f}:  |e(w)-1| = {lhs:.8f}   2|sin(pi w)| = {rhs:.8f}")


def demo_bridge() -> None:
    print("\n" + "=" * 70)
    print("3. The Nyquist bridge:  T(n) via the character e(1/2)^n = (-1)^n")
    print("=" * 70)
    print(f"    e(1/2) = {e(0.5):.4f}  (equals -1)")
    mismatches = 0
    for n in range(0, 30):
        if collatz(n) != collatz_fourier(n):
            mismatches += 1
    print(f"    collatz(n) vs Fourier-branch form agree on 0..29: "
          f"{'YES' if mismatches == 0 else f'NO ({mismatches} diffs)'}")
    for n in (6, 7, 8, 27):
        print(f"      n={n:3d}:  parity T = {collatz(n):4d},  "
              f"Fourier T = {collatz_fourier(n):4d}")


def demo_parity_split() -> None:
    print("\n" + "=" * 70)
    print("4. Parity split of the Collatz Fourier transform F_N(omega)")
    print("=" * 70)
    for omega in (0.3, 1.0 / 7.0, math.sqrt(3) - 1):
        for N in (50, 500):
            direct = collatz_fourier_transform(omega, N)
            split = collatz_fourier_transform_split(omega, N)
            err = abs(direct - split)
            print(f"    omega={omega:.5f}, N={N:4d}:  |F_N| = {abs(direct):10.4f}"
                  f"   split error = {err:.2e}")


def demo_powers_of_two() -> None:
    print("\n" + "=" * 70)
    print("5. Exact stopping time of powers of two:  T^[k](2^k) = 1")
    print("=" * 70)
    for k in range(0, 12):
        result = iterate(collatz, 2 ** k, k)
        st = stopping_time(2 ** k)
        print(f"    k={k:2d}:  2^k = {2**k:5d},  T^[k](2^k) = {result},  "
              f"stopping time = {st}  (= k = log2(2^k))")


def main() -> None:
    demo_dichotomy()
    demo_half_angle()
    demo_bridge()
    demo_parity_split()
    demo_powers_of_two()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
