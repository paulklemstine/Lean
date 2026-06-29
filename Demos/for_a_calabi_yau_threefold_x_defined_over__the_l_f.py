"""
Numerical demonstrations of the ring-valued combinatorial skeleton of
arithmetic mirror symmetry.

This script reproduces, with concrete numbers, every theorem in the package:

  * euler_char                : chi(n, h) = sum_{p,q} (-1)^{p+q} h[p,q]
  * mirror / mirror2 / transp : the three diamond reflections
  * Mirror Euler relation     : chi(mirror h) = (-1)^n chi(h)
  * Second-index reflection   : chi(mirror2 h) = (-1)^n chi(h)
  * Transpose invariance      : chi(transpose h) = chi(h)
  * Double reflection trivial : chi(mirror (mirror2 h)) = chi(h)
  * Threefold sign flip       : chi(mirror_3 h) = -chi(h)
  * Hodge exchange            : (mirror_3 h)[1,1] = h[2,1]
  * Weil functional equation  : prod(q^{n-i}T - 1) = (-1)^{n+1} prod(1 - q^i T)
  * Sign bridge               : (-1)^{n+1} = -(-1)^n
  * Euler char of P^n         : chi(P^n) = n + 1
  * Point-count congruence    : #P^n(F_q) = n+1 (mod q-1)

Everything is exact integer arithmetic; no external dependencies.
"""

from __future__ import annotations

from typing import Callable, List, Dict, Tuple
from fractions import Fraction


# ---------------------------------------------------------------------------
# Core definitions (Definitions 2.2 and 2.3 of the paper)
# ---------------------------------------------------------------------------

Diamond = Callable[[int, int], Fraction]


def euler_char(n: int, h: Diamond) -> Fraction:
    """chi(n, h) = sum_{p=0}^{n} sum_{q=0}^{n} (-1)^{p+q} h(p, q)."""
    total = Fraction(0)
    for p in range(n + 1):
        for q in range(n + 1):
            total += Fraction((-1) ** (p + q)) * h(p, q)
    return total


def mirror(n: int, h: Diamond) -> Diamond:
    """First-index reflection: (mirror h)(p, q) = h(n - p, q)."""
    return lambda p, q: h(n - p, q)


def mirror2(n: int, h: Diamond) -> Diamond:
    """Second-index reflection: (mirror2 h)(p, q) = h(p, n - q)."""
    return lambda p, q: h(p, n - q)


def transpose(h: Diamond) -> Diamond:
    """Transpose: (transpose h)(p, q) = h(q, p)."""
    return lambda p, q: h(q, p)


def proj_hodge(n: int) -> Diamond:
    """Hodge diamond of P^n: 1 on the diagonal p = q <= n, else 0."""
    return lambda p, q: Fraction(1) if (p == q and p <= n) else Fraction(0)


def point_count(n: int, q: int) -> int:
    """Number of F_q-points of P^n: 1 + q + ... + q^n."""
    return sum(q ** i for i in range(n + 1))


# ---------------------------------------------------------------------------
# Helpers for building random-ish but reproducible test diamonds
# ---------------------------------------------------------------------------

def diamond_from_table(table: Dict[Tuple[int, int], int]) -> Diamond:
    """Build a diamond from an explicit {(p,q): value} table (default 0)."""
    return lambda p, q: Fraction(table.get((p, q), 0))


def quintic_threefold() -> Diamond:
    """The Hodge diamond of the quintic threefold X in P^4.

    Nonzero entries (Calabi-Yau threefold, n = 3):
      h^{0,0}=h^{3,3}=h^{0,3}=h^{3,0}=1   (the corners)
      h^{1,1}=h^{2,2}=1
      h^{2,1}=h^{1,2}=101
    Euler characteristic chi = 2(h^{1,1} - h^{2,1}) = 2(1 - 101) = -200.
    """
    table = {
        (0, 0): 1, (3, 3): 1, (0, 3): 1, (3, 0): 1,
        (1, 1): 1, (2, 2): 1,
        (2, 1): 101, (1, 2): 101,
    }
    return diamond_from_table(table)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_mirror_euler_relation() -> None:
    print("=" * 70)
    print("Mirror Euler relation:  chi(mirror h) = (-1)^n chi(h)")
    print("=" * 70)
    # A generic test diamond for several dimensions.
    table = {(p, q): (3 * p + 5 * q + 7) for p in range(6) for q in range(6)}
    h = diamond_from_table(table)
    for n in range(0, 6):
        lhs = euler_char(n, mirror(n, h))
        rhs = Fraction((-1) ** n) * euler_char(n, h)
        ok = "OK" if lhs == rhs else "FAIL"
        print(f"  n={n}:  chi(mirror h)={str(lhs):>8}   "
              f"(-1)^n chi(h)={str(rhs):>8}   [{ok}]")
    print()


def demo_all_reflections() -> None:
    print("=" * 70)
    print("All three reflections on a fixed diamond (n = 4)")
    print("=" * 70)
    n = 4
    table = {(p, q): (p * p - 2 * q + 11) for p in range(5) for q in range(5)}
    h = diamond_from_table(table)
    chi = euler_char(n, h)
    print(f"  chi(h)                  = {chi}")
    print(f"  chi(mirror h)           = {euler_char(n, mirror(n, h))}"
          f"   (expect (-1)^4 chi = {chi})")
    print(f"  chi(mirror2 h)          = {euler_char(n, mirror2(n, h))}"
          f"   (expect (-1)^4 chi = {chi})")
    print(f"  chi(transpose h)        = {euler_char(n, transpose(h))}"
          f"   (expect chi = {chi})")
    dbl = euler_char(n, mirror(n, mirror2(n, h)))
    print(f"  chi(mirror(mirror2 h))  = {dbl}   (expect chi = {chi})")
    print()


def demo_threefold_quintic() -> None:
    print("=" * 70)
    print("Calabi-Yau threefold: the quintic and its mirror")
    print("=" * 70)
    n = 3
    X = quintic_threefold()
    chiX = euler_char(n, X)
    Y = mirror(n, X)  # the mirror diamond
    chiY = euler_char(n, Y)
    print(f"  h^(1,1)(X) = {int(X(1,1))},  h^(2,1)(X) = {int(X(2,1))}")
    print(f"  chi(X) = {chiX}    (expect 2(h11 - h21) = -200)")
    print(f"  Hodge exchange: (mirror X)[1,1] = {int(Y(1,1))} = h^(2,1)(X) = {int(X(2,1))}")
    print(f"  chi(mirror X) = {chiY}    (expect -chi(X) = {-chiX})")
    ok = "OK" if chiY == -chiX else "FAIL"
    print(f"  Threefold sign flip chi(mirror X) = -chi(X):  [{ok}]")
    print()


def demo_weil_functional_equation() -> None:
    print("=" * 70)
    print("Weil functional equation for P^n (polynomial identity, exact)")
    print("=" * 70)

    def lhs(n: int, q: int, T: Fraction) -> Fraction:
        prod = Fraction(1)
        for i in range(n + 1):
            prod *= (Fraction(q) ** (n - i) * T - 1)
        return prod

    def rhs(n: int, q: int, T: Fraction) -> Fraction:
        prod = Fraction(1)
        for i in range(n + 1):
            prod *= (1 - Fraction(q) ** i * T)
        return Fraction((-1) ** (n + 1)) * prod

    for n in range(0, 5):
        for q in (2, 3, 5):
            T = Fraction(7, 3)
            L, R = lhs(n, q, T), rhs(n, q, T)
            ok = "OK" if L == R else "FAIL"
            print(f"  n={n}, q={q}, T=7/3:  LHS={L}   RHS={R}   [{ok}]")
    # Sign bridge
    print("  Sign bridge:  (-1)^(n+1) = -(-1)^n")
    for n in range(0, 6):
        a, b = (-1) ** (n + 1), -((-1) ** n)
        print(f"    n={n}:  (-1)^(n+1)={a:>3}   -(-1)^n={b:>3}   "
              f"[{'OK' if a == b else 'FAIL'}]")
    print()


def demo_point_count_congruence() -> None:
    print("=" * 70)
    print("Point count congruence:  #P^n(F_q) = chi(P^n) = n+1  (mod q-1)")
    print("=" * 70)
    for n in range(0, 6):
        chi = euler_char(n, proj_hodge(n))
        assert chi == n + 1, "Euler char of P^n must be n+1"
        for q in (2, 3, 4, 5, 8):
            N = point_count(n, q)
            residue = N % (q - 1)
            target = (n + 1) % (q - 1)
            ok = "OK" if residue == target else "FAIL"
            print(f"  n={n}, q={q}:  #P^n(F_q)={N:>7}   "
                  f"N mod (q-1)={residue}   (n+1) mod (q-1)={target}   [{ok}]")
    print()


def main() -> None:
    demo_mirror_euler_relation()
    demo_all_reflections()
    demo_threefold_quintic()
    demo_weil_functional_equation()
    demo_point_count_congruence()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
