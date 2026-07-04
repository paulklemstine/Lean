"""
Numerical demonstration of the residue-class monotonicity of the minimal modulus
of sums of fifth roots of unity.

Let zeta = exp(2*pi*i/5) be the primitive fifth root of unity.  For a budget n,
    sigma5(n) = min over all (a0, a1, a2, a3, a4) in N^5 with sum a_r = n
                of  |a0 + a1*zeta + a2*zeta^2 + a3*zeta^3 + a4*zeta^4|.

This script:
  1. computes sigma5(n) by exhaustive canonical-form search;
  2. verifies residue-class monotonicity  sigma5(5(k+1)+r) <= sigma5(5k+r);
  3. verifies the zero-block identity 1 + zeta + zeta^2 + zeta^3 + zeta^4 = 0;
  4. identifies the exact algebraic values in the golden field Q(sqrt 5).

Self-contained: standard library only.
"""

from __future__ import annotations

import cmath
import math
from typing import Iterator, Tuple, List

ZETA: complex = cmath.exp(2j * math.pi / 5)
PHI: float = (1.0 + math.sqrt(5.0)) / 2.0


def compositions(n: int, parts: int) -> Iterator[Tuple[int, ...]]:
    """Yield every tuple of `parts` nonnegative integers summing to `n`."""
    if parts == 1:
        yield (n,)
        return
    for first in range(n + 1):
        for rest in compositions(n - first, parts - 1):
            yield (first,) + rest


def sum_value(coeffs: Tuple[int, ...]) -> complex:
    """Value a0 + a1*zeta + ... + a4*zeta^4 of a canonical configuration."""
    return sum(a * ZETA ** r for r, a in enumerate(coeffs))


def sigma5(n: int) -> float:
    """Minimal modulus of a sum of n fifth roots of unity (exhaustive search)."""
    best = math.inf
    for coeffs in compositions(n, 5):
        val = abs(sum_value(coeffs))
        if val < best:
            best = val
    return best


def sigma5_witness(n: int) -> Tuple[float, Tuple[int, ...]]:
    """Return (sigma5(n), minimizing configuration)."""
    best = math.inf
    arg: Tuple[int, ...] = (n, 0, 0, 0, 0)
    for coeffs in compositions(n, 5):
        val = abs(sum_value(coeffs))
        if val < best:
            best, arg = val, coeffs
    return best, arg


def identify(value: float) -> str:
    """Name a numerical value as a known element of Q(sqrt 5) when possible."""
    known = {
        0.0: "0",
        1.0: "1",
        1.0 / PHI: "phi^{-1} = (sqrt5 - 1)/2",
        1.0 / PHI ** 2: "phi^{-2} = (3 - sqrt5)/2",
        math.sqrt(5.0) - 2.0: "sqrt5 - 2",
        1.0 / PHI ** 4: "phi^{-4} = (7 - 3 sqrt5)/2",
    }
    for target, name in known.items():
        if abs(value - target) < 1e-9:
            return name
    return "(unrecognized)"


def demo_zero_block() -> None:
    print("=" * 68)
    print("1. The complete root sum vanishes")
    print("=" * 68)
    total = sum(ZETA ** i for i in range(5))
    print(f"   1 + zeta + zeta^2 + zeta^3 + zeta^4 = {total:.2e}")
    print(f"   |sum| = {abs(total):.2e}  (numerically zero)\n")


def demo_table(nmax: int = 15) -> List[float]:
    print("=" * 68)
    print("2. Values of sigma5(n)")
    print("=" * 68)
    print(f"   {'n':>3} {'sigma5(n)':>12}   exact value")
    print("   " + "-" * 60)
    values = []
    for n in range(nmax + 1):
        v, w = sigma5_witness(n)
        values.append(v)
        print(f"   {n:>3} {v:>12.6f}   {identify(v):<28} witness={w}")
    print()
    return values


def demo_monotonicity(values: List[float]) -> None:
    print("=" * 68)
    print("3. Residue-class monotonicity  sigma5(5(k+1)+r) <= sigma5(5k+r)")
    print("=" * 68)
    nmax = len(values) - 1
    all_ok = True
    for r in range(5):
        row = [values[5 * k + r] for k in range(0, (nmax - r) // 5 + 1)]
        pretty = "  ".join(f"{x:.6f}" for x in row)
        mono = all(row[i + 1] <= row[i] + 1e-12 for i in range(len(row) - 1))
        all_ok = all_ok and mono
        flag = "non-increasing OK" if mono else "VIOLATION"
        print(f"   r={r}:  {pretty}    [{flag}]")
    print()
    print("   All residue classes non-increasing:", all_ok)
    print()


def main() -> None:
    demo_zero_block()
    values = demo_table(15)
    demo_monotonicity(values)


if __name__ == "__main__":
    main()
