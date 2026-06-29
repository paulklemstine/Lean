"""
Numerical demonstrations of the two-term basis principle for Fibonacci numbers
and the verified identities it produces.

This script is self-contained (standard library only) and uses type hints
throughout. Every helper is inlined. Running it prints a verification report for:

  * the two-term basis principle           (fib_two_basis)
  * single-base linear shift identities     (fib_shift_five / six / seven)
  * single-base polynomial identities       (fib_square_shift, fib_mixed_shift)
  * Cassini's identity, both orientations   (cassini, cassini')
  * index-doubling formulas                 (fib_two_mul_add_one, fib_two_mul)
  * convolution identities                  (d'Ocagne, Catalan, unifying form)
  * the fast-doubling algorithm for F_N

Each check asserts the identity over a range of indices, so a clean run is a
numerical confirmation that the identities hold (not a proof, but strong
evidence consistent with the verified theorems).
"""

from __future__ import annotations

from functools import lru_cache
from typing import Tuple


# ---------------------------------------------------------------------------
# Core: the Fibonacci function F_0 = 0, F_1 = 1, F_{n+2} = F_{n+1} + F_n.
# ---------------------------------------------------------------------------
@lru_cache(maxsize=None)
def fib(n: int) -> int:
    """Return the n-th Fibonacci number (n >= 0)."""
    if n < 0:
        raise ValueError("fib is defined here for n >= 0")
    if n < 2:
        return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


# ---------------------------------------------------------------------------
# The two-term basis principle:  F_{n+(k+1)} = F_k * F_n + F_{k+1} * F_{n+1}.
# ---------------------------------------------------------------------------
def two_basis_lhs(n: int, k: int) -> int:
    """Left-hand side F_{n+(k+1)}."""
    return fib(n + k + 1)


def two_basis_rhs(n: int, k: int) -> int:
    """Right-hand side F_k * F_n + F_{k+1} * F_{n+1}."""
    return fib(k) * fib(n) + fib(k + 1) * fib(n + 1)


# ---------------------------------------------------------------------------
# Single-base shift identities (decided by the expander `fib_ring`).
# ---------------------------------------------------------------------------
def shift_five(n: int) -> Tuple[int, int]:
    """fib_shift_five:  F_{n+5} = 3 F_n + 5 F_{n+1}."""
    return fib(n + 5), 3 * fib(n) + 5 * fib(n + 1)


def shift_six(n: int) -> Tuple[int, int]:
    """fib_shift_six:  F_{n+6} = 5 F_n + 8 F_{n+1}."""
    return fib(n + 6), 5 * fib(n) + 8 * fib(n + 1)


def shift_seven(n: int) -> Tuple[int, int]:
    """fib_shift_seven:  F_{n+7} = 8 F_n + 13 F_{n+1}."""
    return fib(n + 7), 8 * fib(n) + 13 * fib(n + 1)


def square_shift(n: int) -> Tuple[int, int]:
    """fib_square_shift:  F_{n+2}^2 = F_n^2 + 2 F_n F_{n+1} + F_{n+1}^2."""
    lhs = fib(n + 2) * fib(n + 2)
    rhs = fib(n) ** 2 + 2 * fib(n) * fib(n + 1) + fib(n + 1) ** 2
    return lhs, rhs


def mixed_shift(n: int) -> Tuple[int, int]:
    """fib_mixed_shift:  F_{n+2}^2 = F_{n+1}^2 + F_n F_{n+3}."""
    lhs = fib(n + 2) ** 2
    rhs = fib(n + 1) ** 2 + fib(n) * fib(n + 3)
    return lhs, rhs


# ---------------------------------------------------------------------------
# Parity identities (Cassini), proved by one induction step.
# ---------------------------------------------------------------------------
def cassini(n: int) -> Tuple[int, int]:
    """cassini:  F_{n+2} F_n - F_{n+1}^2 = (-1)^{n+1}."""
    lhs = fib(n + 2) * fib(n) - fib(n + 1) ** 2
    rhs = (-1) ** (n + 1)
    return lhs, rhs


def cassini_prime(n: int) -> Tuple[int, int]:
    """cassini':  F_{n+1}^2 - F_n F_{n+2} = (-1)^n."""
    lhs = fib(n + 1) ** 2 - fib(n) * fib(n + 2)
    rhs = (-1) ** n
    return lhs, rhs


# ---------------------------------------------------------------------------
# Index-doubling formulas (basis of fast doubling).
# ---------------------------------------------------------------------------
def double_odd(n: int) -> Tuple[int, int]:
    """fib_two_mul_add_one:  F_{2n+1} = F_{n+1}^2 + F_n^2."""
    return fib(2 * n + 1), fib(n + 1) ** 2 + fib(n) ** 2


def double_even(n: int) -> Tuple[int, int]:
    """fib_two_mul:  F_{2n} = F_n (2 F_{n+1} - F_n)."""
    return fib(2 * n), fib(n) * (2 * fib(n + 1) - fib(n))


# ---------------------------------------------------------------------------
# Two-base convolution identities (reduced to Cassini).
# ---------------------------------------------------------------------------
def docagne(n: int, k: int) -> Tuple[int, int]:
    """d'Ocagne:  F_{n+k} F_{n+1} - F_{n+k+1} F_n = (-1)^n F_k."""
    lhs = fib(n + k) * fib(n + 1) - fib(n + k + 1) * fib(n)
    rhs = (-1) ** n * fib(k)
    return lhs, rhs


def catalan(n: int, r: int) -> Tuple[int, int]:
    """Catalan:  F_{n+r}^2 - F_n F_{n+2r} = (-1)^n F_r^2."""
    lhs = fib(n + r) ** 2 - fib(n) * fib(n + 2 * r)
    rhs = (-1) ** n * fib(r) ** 2
    return lhs, rhs


def unifying_convolution(n: int, a: int, b: int) -> Tuple[int, int]:
    """Unifying form:  F_{n+a} F_{n+b} - F_n F_{n+a+b} = (-1)^n F_a F_b."""
    lhs = fib(n + a) * fib(n + b) - fib(n) * fib(n + a + b)
    rhs = (-1) ** n * fib(a) * fib(b)
    return lhs, rhs


# ---------------------------------------------------------------------------
# Fast-doubling algorithm:  computes (F_n, F_{n+1}) in O(log n) steps using
# the doubling formulas above.
# ---------------------------------------------------------------------------
def fib_fast_doubling(n: int) -> int:
    """Return F_n in O(log n) big-integer multiplications via fast doubling."""

    def _pair(m: int) -> Tuple[int, int]:
        # Returns (F_m, F_{m+1}).
        if m == 0:
            return (0, 1)
        a, b = _pair(m >> 1)          # a = F_k, b = F_{k+1}, k = m // 2
        c = a * (2 * b - a)           # F_{2k}   = F_k (2 F_{k+1} - F_k)
        d = a * a + b * b             # F_{2k+1} = F_k^2 + F_{k+1}^2
        if m & 1:
            return (d, c + d)         # odd:  (F_{2k+1}, F_{2k+2})
        return (c, d)                 # even: (F_{2k},   F_{2k+1})

    return _pair(n)[0]


# ---------------------------------------------------------------------------
# Verification driver.
# ---------------------------------------------------------------------------
def _report(name: str, ok: bool) -> None:
    status = "OK " if ok else "FAIL"
    print(f"  [{status}] {name}")


def main() -> None:
    print("Two-term basis principle and verified Fibonacci identities")
    print("=" * 64)

    print("\nFirst 15 Fibonacci numbers:")
    print("  " + ", ".join(str(fib(i)) for i in range(15)))

    print("\nTwo-term basis principle  F_{n+(k+1)} = F_k F_n + F_{k+1} F_{n+1}:")
    ok = all(
        two_basis_lhs(n, k) == two_basis_rhs(n, k)
        for n in range(0, 25)
        for k in range(0, 25)
    )
    _report("fib_two_basis  (n,k in 0..24)", ok)

    print("\nSingle-base shift identities (expander `fib_ring`):")
    _report("fib_shift_five", all(a == b for a, b in (shift_five(n) for n in range(40))))
    _report("fib_shift_six", all(a == b for a, b in (shift_six(n) for n in range(40))))
    _report("fib_shift_seven", all(a == b for a, b in (shift_seven(n) for n in range(40))))
    _report("fib_square_shift", all(a == b for a, b in (square_shift(n) for n in range(40))))
    _report("fib_mixed_shift", all(a == b for a, b in (mixed_shift(n) for n in range(40))))

    print("\nParity identities (Cassini, via one induction step):")
    _report("cassini", all(a == b for a, b in (cassini(n) for n in range(60))))
    _report("cassini'", all(a == b for a, b in (cassini_prime(n) for n in range(60))))
    print("    sample signs (cassini', n=0..9):",
          [cassini_prime(n)[0] for n in range(10)])

    print("\nIndex-doubling formulas:")
    _report("fib_two_mul_add_one", all(a == b for a, b in (double_odd(n) for n in range(40))))
    _report("fib_two_mul", all(a == b for a, b in (double_even(n) for n in range(40))))

    print("\nTwo-base convolution identities (reduced to Cassini):")
    _report("d'Ocagne", all(
        docagne(n, k)[0] == docagne(n, k)[1]
        for n in range(30) for k in range(1, 30)))
    _report("Catalan", all(
        catalan(n, r)[0] == catalan(n, r)[1]
        for n in range(30) for r in range(1, 30)))
    _report("unifying convolution", all(
        unifying_convolution(n, a, b)[0] == unifying_convolution(n, a, b)[1]
        for n in range(20) for a in range(20) for b in range(20)))

    print("\nFast-doubling algorithm vs. iterative fib:")
    ok = all(fib_fast_doubling(n) == fib(n) for n in range(0, 200))
    _report("fib_fast_doubling agrees on n=0..199", ok)
    big = 1000
    print(f"    F_{big} has {len(str(fib_fast_doubling(big)))} decimal digits;"
          f" leading digits {str(fib_fast_doubling(big))[:12]}...")

    print("\nDone.")


if __name__ == "__main__":
    main()
