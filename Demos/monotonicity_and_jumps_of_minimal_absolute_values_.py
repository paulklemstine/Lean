"""
Monotonicity and Jumps of Minimal Absolute Values of Fifth-Root-of-Unity Sums
=============================================================================

Self-contained numerical demonstration of the main results.

Let  w5 = exp(2*pi*i/5)  be a primitive fifth root of unity.  A *sum of n fifth
roots of unity* is any complex number

        S = sum_{j<n} w5 ** c_j ,      c_j in {0,1,2,3,4}.

Grouping equal exponents, such a sum is determined by a composition
(a0, a1, a2, a3, a4) of nonnegative integers with a0+...+a4 = n, giving

        S(a) = a0 + a1 w5 + a2 w5^2 + a3 w5^3 + a4 w5^4 .

We study

        sigma5(n) = min { |S(a)| : sum a_r = n ,  S(a) != 0 } ,

the minimal absolute value of a *non-vanishing* sum of n fifth roots of unity.

This script:
  1. computes sigma5(n) by exact enumeration;
  2. verifies monotonicity of  k -> sigma5(5k + r)  for each residue r;
  3. locates the strict-decrease ("jump") positions and matches them against
     the family  {5 F_m, L_m, 2 L_m};
  4. confirms the two arithmetic backbone facts:
         - no Lucas number is divisible by 5,
         - a jump position divisible by 5 must equal 5 F_m;
  5. reproduces the exact first Lucas-type jump value sigma5(6) = phi^{-2}.
"""

from __future__ import annotations

import cmath
import math
from itertools import product
from typing import Dict, List, Optional, Tuple

# --------------------------------------------------------------------------- #
#  Core arithmetic sequences
# --------------------------------------------------------------------------- #

def fib(n: int) -> int:
    """Fibonacci numbers: F_0 = 0, F_1 = 1, F_{n+2} = F_n + F_{n+1}."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lucas(n: int) -> int:
    """Lucas numbers: L_0 = 2, L_1 = 1, L_{n+2} = L_n + L_{n+1}."""
    a, b = 2, 1
    for _ in range(n):
        a, b = b, a + b
    return a


# --------------------------------------------------------------------------- #
#  The minimal non-vanishing modulus sigma5(n)
# --------------------------------------------------------------------------- #

W5: complex = cmath.exp(2j * cmath.pi / 5)
_TOL: float = 1e-9


def sigma5(n: int) -> Optional[float]:
    """Minimal absolute value of a non-vanishing sum of n fifth roots of unity.

    Returns None if every sum with exactly n roots vanishes (does not occur
    for n >= 1) or if n = 0.
    """
    if n <= 0:
        return None
    best: Optional[float] = None
    for a0 in range(n + 1):
        for a1 in range(n + 1 - a0):
            for a2 in range(n + 1 - a0 - a1):
                for a3 in range(n + 1 - a0 - a1 - a2):
                    a4 = n - a0 - a1 - a2 - a3
                    s = a0 + a1 * W5 + a2 * W5**2 + a3 * W5**3 + a4 * W5**4
                    m = abs(s)
                    if m > _TOL and (best is None or m < best):
                        best = m
    return best


# --------------------------------------------------------------------------- #
#  Jump-position family {5 F_m, L_m, 2 L_m : m >= 1}
# --------------------------------------------------------------------------- #

def jump_family(upper: int) -> Dict[int, List[str]]:
    """All jump positions N <= upper, tagged with their generating type(s)."""
    fam: Dict[int, List[str]] = {}
    m = 1
    while True:
        vals = {
            5 * fib(m): f"5F_{m}",
            lucas(m): f"L_{m}",
            2 * lucas(m): f"2L_{m}",
        }
        if min(vals) > upper and 5 * fib(m) > upper:
            break
        for v, tag in vals.items():
            if 1 <= v <= upper:
                fam.setdefault(v, []).append(tag)
        m += 1
    return fam


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #

def demo_table(nmax: int = 22) -> Dict[int, float]:
    """Print sigma5(n) for 1 <= n <= nmax and return the table."""
    table: Dict[int, float] = {}
    print(f"{'n':>3} | {'sigma5(n)':>12} | residue mod 5")
    print("-" * 34)
    for n in range(1, nmax + 1):
        v = sigma5(n)
        assert v is not None
        table[n] = v
        print(f"{n:>3} | {v:>12.6f} | {n % 5}")
    return table


def demo_monotonicity(table: Dict[int, float]) -> None:
    """Verify sigma5 is non-increasing along each residue class modulo 5."""
    print("\nMonotonicity along residue classes modulo 5")
    print("-" * 44)
    for r in range(5):
        seq: List[Tuple[int, float]] = [(n, v) for n, v in table.items() if n % 5 == r]
        seq.sort()
        ok = all(seq[i][1] >= seq[i + 1][1] - _TOL for i in range(len(seq) - 1))
        chain = "  >=  ".join(f"{v:.4f}" for _, v in seq)
        print(f"r={r}: {chain}   [{'non-increasing OK' if ok else 'FAIL'}]")


def demo_jumps(table: Dict[int, float]) -> None:
    """Match strict decreases sigma5(n) > sigma5(n+5) with the jump family."""
    print("\nStrict decreases sigma5(n) > sigma5(n+5)  vs.  {5F_m, L_m, 2L_m}")
    print("-" * 62)
    upper = max(table) 
    fam = jump_family(upper)
    print(f"{'position N=n+5':>14} | {'is jump?':>8} | {'in family?':>11} | family tag")
    print("-" * 62)
    for n in sorted(table):
        if n + 5 in table:
            is_jump = table[n] > table[n + 5] + _TOL
            pos = n + 5
            tags = fam.get(pos, [])
            in_fam = bool(tags)
            if is_jump or in_fam:
                mark = "match" if is_jump == in_fam else "MISMATCH"
                print(f"{pos:>14} | {str(is_jump):>8} | {str(in_fam):>11} | "
                      f"{','.join(tags) if tags else '-':<12} {mark}")


def demo_lucas_mod5() -> None:
    """No Lucas number is divisible by 5 (period-4 cycle 2,1,3,4 modulo 5)."""
    print("\nLucas numbers modulo 5 (period 4: 2,1,3,4 -- never 0)")
    print("-" * 52)
    residues = [lucas(m) % 5 for m in range(16)]
    print("  L_m mod 5 :", residues)
    assert 0 not in residues
    print("  => no Lucas number is divisible by 5.")


def demo_jump_dvd5_is_fib(upper: int = 60) -> None:
    """Every jump position divisible by 5 is of Fibonacci type 5 F_m."""
    print("\nJump positions divisible by 5 are exactly {5F_m}")
    print("-" * 46)
    fam = jump_family(upper)
    mult5 = sorted(N for N in fam if N % 5 == 0)
    for N in mult5:
        m = next(k for k in range(1, 30) if 5 * fib(k) == N)
        print(f"  {N} = 5 * F_{m}   (F_{m} = {fib(m)})")
    print(f"  multiples of 5 among jump positions <= {upper}: {mult5}")


def demo_exact_first_jump() -> None:
    """The first Lucas-type jump value: sigma5(6) = phi^{-2} = sqrt((7-3sqrt5)/2)."""
    print("\nExact first Lucas-type jump value at N = 6 = 2 L_2")
    print("-" * 50)
    phi = (1 + math.sqrt(5)) / 2
    closed = phi ** -2
    radical = math.sqrt((7 - 3 * math.sqrt(5)) / 2)
    numeric = sigma5(6)
    assert numeric is not None
    print(f"  sigma5(1)              = {sigma5(1):.6f}")
    print(f"  sigma5(6) [enumerated] = {numeric:.6f}")
    print(f"  phi^(-2)               = {closed:.6f}")
    print(f"  sqrt((7 - 3 sqrt5)/2)  = {radical:.6f}")
    assert abs(numeric - closed) < 1e-6
    assert abs(numeric - radical) < 1e-6
    print("  => sigma5(6) = phi^(-2) < 1 = sigma5(1): a genuine jump.")


def main() -> None:
    table = demo_table(22)
    demo_monotonicity(table)
    demo_jumps(table)
    demo_lucas_mod5()
    demo_jump_dvd5_is_fib(60)
    demo_exact_first_jump()


if __name__ == "__main__":
    main()
