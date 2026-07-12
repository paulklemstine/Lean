"""
Alien Number Systems: numerical demonstrations.

Self-contained demonstrations of the main results:

  * Negabinary (base -2): every integer has a UNIQUE representation with
    digits {0, 1} and no sign symbol.
  * Phinary (base phi): the carry rule phi^n + phi^(n+1) = phi^(n+2), the
    no-consecutive-ones property, Fibonacci coordinates, the Lucas integer
    identity, coordinate uniqueness, and the expansion 3 = phi^2 + phi^-2.

Run with:  python demo.py
"""

from __future__ import annotations

from typing import List, Tuple
from math import sqrt

PHI: float = (1.0 + sqrt(5.0)) / 2.0
PSI: float = (1.0 - sqrt(5.0)) / 2.0


# --------------------------------------------------------------------------- #
# Negabinary (base -2)
# --------------------------------------------------------------------------- #
def negabinary_encode(n: int) -> List[int]:
    """Return the canonical base-(-2) digits of n, least-significant first.

    Repeatedly emit b = n mod 2 and update n <- (n - b) / (-2). Terminates
    because the interleaving measure mu strictly decreases (Lemma: Progress).
    """
    if n == 0:
        return []
    digits: List[int] = []
    while n != 0:
        b = n % 2                 # Python's % returns a nonnegative remainder
        digits.append(b)
        n = (n - b) // (-2)
    return digits


def negabinary_decode(digits: List[int]) -> int:
    """Evaluate a base-(-2) digit list (least-significant first) to an integer."""
    value = 0
    for i, b in enumerate(digits):
        value += b * ((-2) ** i)
    return value


def negabinary_string(n: int) -> str:
    """Human-readable most-significant-first digit string, e.g. -1 -> '11'."""
    digits = negabinary_encode(n)
    if not digits:
        return "0"
    return "".join(str(b) for b in reversed(digits))


def mu(n: int) -> int:
    """Interleaving measure mu: Z -> N realizing 0, -1, 1, -2, 2, ..."""
    return 2 * n if n >= 0 else -2 * n - 1


# --------------------------------------------------------------------------- #
# Fibonacci / Lucas
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """n-th Fibonacci number, F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lucas(n: int) -> int:
    """n-th Lucas number, L_0 = 2, L_1 = 1, via L_n = F_{n+1} + F_{n-1}."""
    return fib(n + 1) + fib(n - 1) if n >= 1 else 2


# --------------------------------------------------------------------------- #
# Phinary (base phi) helpers
# --------------------------------------------------------------------------- #
def phi_carry_check(n: int) -> Tuple[float, float]:
    """Return (phi^n + phi^(n+1), phi^(n+2)); the carry rule says they match."""
    return (PHI ** n + PHI ** (n + 1), PHI ** (n + 2))


def phi_sum_coordinates(S: List[int]) -> Tuple[int, int]:
    """Fibonacci coordinates of sum_{i in S} phi^(i+1) = a*phi + b.

    Returns (a, b) = (sum F_{i+1}, sum F_i).
    """
    a = sum(fib(i + 1) for i in S)
    b = sum(fib(i) for i in S)
    return (a, b)


def zeckendorf(n: int) -> List[int]:
    """Zeckendorf representation of n >= 0: indices k (>= 2) with F_k used,
    no two consecutive. This is the integer phinary expansion's engine."""
    if n < 0:
        raise ValueError("Zeckendorf is defined for non-negative integers.")
    if n == 0:
        return []
    fibs: List[Tuple[int, int]] = []
    k = 2
    while fib(k) <= n:
        fibs.append((k, fib(k)))
        k += 1
    used: List[int] = []
    for k, fk in reversed(fibs):
        if fk <= n:
            used.append(k)
            n -= fk
    return used


def has_no_consecutive(indices: List[int]) -> bool:
    """True iff the chosen Fibonacci indices contain no two consecutive."""
    s = sorted(indices)
    return all(s[i + 1] - s[i] >= 2 for i in range(len(s) - 1))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_negabinary_bijection(lo: int = -16, hi: int = 16) -> None:
    print("=" * 64)
    print("NEGABINARY (base -2): unique representation of every integer")
    print("=" * 64)
    seen = {}
    for n in range(lo, hi + 1):
        s = negabinary_string(n)
        back = negabinary_decode(negabinary_encode(n))
        assert back == n, f"round-trip failed for {n}"
        assert s not in seen, f"collision: {s} used for {seen.get(s)} and {n}"
        seen[s] = n
        print(f"  {n:>4}  =  {s:>8}(-2)     mu = {mu(n)}")
    print(f"  All {hi - lo + 1} integers in [{lo},{hi}] have distinct, "
          f"sign-free representations.\n")


def demo_phi_carry(nmax: int = 6) -> None:
    print("=" * 64)
    print("PHINARY carry rule:  phi^n + phi^(n+1) = phi^(n+2)   (011 = 100)")
    print("=" * 64)
    for n in range(nmax + 1):
        lhs, rhs = phi_carry_check(n)
        print(f"  n={n}:  {lhs:.10f} == {rhs:.10f}   diff={abs(lhs-rhs):.2e}")
    print()


def demo_phi_three() -> None:
    print("=" * 64)
    print("Classical expansion:  3 = phi^2 + phi^-2 = 100.01(phi)")
    print("=" * 64)
    val = PHI ** 2 + PHI ** (-2)
    print(f"  phi^2 = {PHI**2:.10f},  phi^-2 = {PHI**-2:.10f}")
    print(f"  sum   = {val:.10f}   (exactly 3)\n")


def demo_fibonacci_coordinates() -> None:
    print("=" * 64)
    print("Fibonacci coordinates:  sum phi^(i+1) = (sum F_{i+1}) phi + sum F_i")
    print("=" * 64)
    for S in ([0], [0, 1], [0, 2], [1, 3], [0, 2, 4]):
        a, b = phi_sum_coordinates(S)
        lhs = sum(PHI ** (i + 1) for i in S)
        rhs = a * PHI + b
        print(f"  S={S}: coords (a,b)=({a},{b})   "
              f"{lhs:.8f} == {rhs:.8f}")
    print()


def demo_lucas_identity(nmax: int = 8) -> None:
    print("=" * 64)
    print("Lucas identity:  phi^(n+1) + psi^(n+1) = F_{n+2} + F_n = L_{n+1}")
    print("=" * 64)
    for n in range(nmax + 1):
        lhs = PHI ** (n + 1) + PSI ** (n + 1)
        rhs = fib(n + 2) + fib(n)
        print(f"  n={n}:  {lhs:.6f} ~= {rhs}  (L_{n+1} = {lucas(n+1)})")
    print()


def demo_zeckendorf(nmax: int = 20) -> None:
    print("=" * 64)
    print("No-consecutive-ones (Zeckendorf) integer phinary expansions")
    print("=" * 64)
    for n in range(1, nmax + 1):
        idx = zeckendorf(n)
        ok = has_no_consecutive(idx)
        terms = " + ".join(f"F_{k}" for k in sorted(idx, reverse=True))
        check = sum(fib(k) for k in idx)
        assert check == n and ok
        print(f"  {n:>3} = {terms:<22}  no-adjacent: {ok}")
    print()


def demo_coordinate_uniqueness() -> None:
    print("=" * 64)
    print("Coordinate uniqueness over Q (fails over R)")
    print("=" * 64)
    from fractions import Fraction as Q
    # a*phi + b == c*phi + d with rationals forces a=c, b=d.
    a, b, c, d = Q(2, 3), Q(-1, 5), Q(2, 3), Q(-1, 5)
    print(f"  Rational coords ({a},{b}) and ({c},{d}) give the same value "
          f"=> must be equal: {a == c and b == d}")
    # Over R: same value, different coordinates -- infinitely many.
    x = 1.234
    for a_real in (0.0, 1.0, 2.5):
        b_real = x - a_real * PHI
        print(f"  Over R: {a_real}*phi + {b_real:.5f} = {a_real*PHI + b_real:.5f} = x")
    print()


def main() -> None:
    demo_negabinary_bijection()
    demo_phi_carry()
    demo_phi_three()
    demo_fibonacci_coordinates()
    demo_lucas_identity()
    demo_zeckendorf()
    demo_coordinate_uniqueness()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
