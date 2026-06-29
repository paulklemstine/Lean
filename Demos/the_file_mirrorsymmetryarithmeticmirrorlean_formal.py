"""
Arithmetic Mirror Symmetry — numerical demonstrations.

A self-contained, dependency-free illustration of the combinatorial skeleton of
mirror symmetry proved in the accompanying formalization.  Every function is
inlined and uses only the Python standard library, so the script runs anywhere
with `python3 demo.py`.

The results demonstrated:

  1. eulerChar_mirror          : chi(mirror h) = (-1)^n * chi(h)
  2. eulerChar_mirror2         : second-index reflection scales chi by (-1)^n
  3. eulerChar_transpose       : chi is invariant under h^{p,q} -> h^{q,p}
  4. eulerChar_double_reflection: both reflections compose to identity on chi
  5. eulerChar_mirror_threefold: chi(Y) = -chi(X) for n = 3
  6. mirror_swaps_hodge_threefold: mirror swaps h^{1,1} and h^{2,1}
  7. projectiveSpace_zeta_functional_equation:
        prod_i (q^{n-i} T - 1) = (-1)^{n+1} prod_i (1 - q^i T)
  8. functional_equation_sign_vs_euler_sign: (-1)^{n+1} = -(-1)^n
  9. projHodge_eulerChar       : chi(P^n) = n + 1
 10. pointCount_congr_eulerChar: #P^n(F_q) = chi(P^n) (mod q - 1)
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List


# --------------------------------------------------------------------------- #
# Core definitions (mirroring the Lean definitions, over an arbitrary ring)    #
# --------------------------------------------------------------------------- #

Diamond = Callable[[int, int], object]  # h : (p, q) -> ring element


def euler_char(n: int, h: Diamond) -> object:
    """Alternating double sum chi_n(h) = sum_{p,q in 0..n} (-1)^(p+q) h(p,q)."""
    total = 0
    for p in range(n + 1):
        for q in range(n + 1):
            total = total + ((-1) ** (p + q)) * h(p, q)
    return total


def mirror(n: int, h: Diamond) -> Diamond:
    """First-index mirror: (p, q) -> h(n - p, q)."""
    return lambda p, q: h(n - p, q)


def mirror2(n: int, h: Diamond) -> Diamond:
    """Second-index reflection: (p, q) -> h(p, n - q)."""
    return lambda p, q: h(p, n - q)


def transpose(h: Diamond) -> Diamond:
    """Transpose / conjugation: (p, q) -> h(q, p)."""
    return lambda p, q: h(q, p)


def proj_hodge(p: int, q: int) -> int:
    """Hodge diamond of P^n: 1 on the diagonal, 0 off it."""
    return 1 if p == q else 0


def point_count(q: int, n: int) -> int:
    """#P^n(F_q) = 1 + q + ... + q^n."""
    return sum(q ** i for i in range(n + 1))


# --------------------------------------------------------------------------- #
# Functional equation factors                                                 #
# --------------------------------------------------------------------------- #

def fe_lhs(q: int, n: int, T) -> object:
    """Left-hand side of the Weil FE: prod_{i=0}^n (q^(n-i) T - 1)."""
    out = 1
    for i in range(n + 1):
        out = out * (q ** (n - i) * T - 1)
    return out


def fe_rhs(q: int, n: int, T) -> object:
    """Right-hand side: (-1)^(n+1) * prod_{i=0}^n (1 - q^i T)."""
    out = 1
    for i in range(n + 1):
        out = out * (1 - q ** i * T)
    return ((-1) ** (n + 1)) * out


# --------------------------------------------------------------------------- #
# A few sample Hodge diamonds                                                  #
# --------------------------------------------------------------------------- #

def quintic_threefold(p: int, q: int) -> int:
    """
    Hodge diamond of the quintic threefold X in P^4 (a Calabi-Yau threefold):
    h^{0,0}=h^{3,3}=h^{0,3}=h^{3,0}=1, h^{1,1}=h^{2,2}=1, h^{2,1}=h^{1,2}=101,
    all other entries 0.  chi(X) = -200.
    """
    table = {
        (0, 0): 1, (3, 3): 1, (0, 3): 1, (3, 0): 1,
        (1, 1): 1, (2, 2): 1,
        (2, 1): 101, (1, 2): 101,
    }
    return table.get((p, q), 0)


def rational_stringy_example(p: int, q: int):
    """A Q-valued (stringy) diamond to show ring-valued portability (n = 2)."""
    table = {
        (0, 0): Fraction(1), (2, 2): Fraction(1),
        (1, 1): Fraction(20, 3),
        (0, 2): Fraction(1), (2, 0): Fraction(1),
    }
    return table.get((p, q), Fraction(0))


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_euler_reflections() -> None:
    print("=" * 70)
    print("1-5. Euler characteristic under the diamond reflections")
    print("=" * 70)
    for name, n, h in [
        ("quintic threefold (n=3)", 3, quintic_threefold),
        ("rational stringy (n=2)", 2, rational_stringy_example),
    ]:
        chi = euler_char(n, h)
        chi_m = euler_char(n, mirror(n, h))
        chi_m2 = euler_char(n, mirror2(n, h))
        chi_t = euler_char(n, transpose(h))
        chi_dd = euler_char(n, mirror(n, mirror2(n, h)))
        sign = (-1) ** n
        print(f"\n  {name}:")
        print(f"    chi(h)                      = {chi}")
        print(f"    chi(mirror h)               = {chi_m}   (expect (-1)^n chi = {sign * chi})")
        print(f"    chi(mirror2 h)              = {chi_m2}   (expect {sign * chi})")
        print(f"    chi(transpose h)            = {chi_t}   (expect chi = {chi})")
        print(f"    chi(mirror(mirror2 h))      = {chi_dd}   (expect chi = {chi})")
        assert chi_m == sign * chi
        assert chi_m2 == sign * chi
        assert chi_t == chi
        assert chi_dd == chi
    # Threefold special case chi(Y) = -chi(X)
    chiX = euler_char(3, quintic_threefold)
    chiY = euler_char(3, mirror(3, quintic_threefold))
    print(f"\n  Threefold mirror relation: chi(Y) = {chiY} = -chi(X) = {-chiX}")
    assert chiY == -chiX
    print("  [OK] all Euler-reflection identities verified.")


def demo_hodge_swap() -> None:
    print("\n" + "=" * 70)
    print("6. Mirror swaps h^{1,1} and h^{2,1}  (curves <-> Picard rank)")
    print("=" * 70)
    h = quintic_threefold
    m = mirror(3, h)
    print(f"    h^(1,1) = {h(1, 1)},  h^(2,1) = {h(2, 1)}")
    print(f"    mirror h at (1,1) = {m(1, 1)}  == h^(2,1) = {h(2, 1)}")
    assert m(1, 1) == h(2, 1)
    print("    The quintic has h^(1,1)=1, h^(2,1)=101; its mirror swaps them.")
    print("  [OK] Hodge-number exchange verified.")


def demo_functional_equation() -> None:
    print("\n" + "=" * 70)
    print("7-8. Weil functional equation for P^n and the sign bridge")
    print("=" * 70)
    for q in (2, 3, 5):
        for n in range(0, 6):
            for T in (Fraction(1, 7), Fraction(-3, 2), Fraction(4)):
                lhs = fe_lhs(q, n, T)
                rhs = fe_rhs(q, n, T)
                assert lhs == rhs, (q, n, T, lhs, rhs)
    print("    Verified prod_i (q^(n-i) T - 1) = (-1)^(n+1) prod_i (1 - q^i T)")
    print("    for q in {2,3,5}, n in 0..5, several rational T.  [OK]")
    print("\n    Sign bridge (-1)^(n+1) = -(-1)^n:")
    for n in range(6):
        a, b = (-1) ** (n + 1), -((-1) ** n)
        print(f"      n={n}: (-1)^(n+1)={a:+d}  -(-1)^n={b:+d}")
        assert a == b
    print("  [OK] functional-equation sign equals minus the Euler sign.")


def demo_arithmetic_topology() -> None:
    print("\n" + "=" * 70)
    print("9-10. chi(P^n)=n+1 and #P^n(F_q) = chi(P^n) (mod q-1)")
    print("=" * 70)
    for n in range(0, 7):
        chi = euler_char(n, proj_hodge)
        assert chi == n + 1
    print("    chi(P^n) = n+1 verified for n = 0..6.")
    print("\n    Point-count congruence #P^n(F_q) = n+1 (mod q-1):")
    for q in (2, 3, 4, 5, 7, 8, 9):
        for n in range(0, 6):
            N = point_count(q, n)
            lhs = N % (q - 1)
            rhs = (n + 1) % (q - 1)
            assert lhs == rhs, (q, n, N)
            assert (q - 1) * N == q ** (n + 1) - 1  # geometric-series identity
        print(f"      q={q}: #P^n(F_q) mod {q - 1} matches (n+1) mod {q - 1} for n=0..5")
    print("  [OK] arithmetic-topology congruence verified.")


def main() -> None:
    print("\nARITHMETIC MIRROR SYMMETRY — NUMERICAL DEMONSTRATIONS\n")
    demo_euler_reflections()
    demo_hodge_swap()
    demo_functional_equation()
    demo_arithmetic_topology()
    print("\n" + "=" * 70)
    print("All demonstrations passed.")
    print("=" * 70)


if __name__ == "__main__":
    main()
