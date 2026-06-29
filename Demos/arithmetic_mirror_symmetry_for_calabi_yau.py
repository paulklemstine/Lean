"""Arithmetic Mirror Symmetry for Calabi-Yau threefolds: numerical demonstrations.

This self-contained script illustrates the combinatorial and arithmetic core of
mirror symmetry that was formalized in Lean:

  1. The Hodge-diamond involution  (h11, h21) -> (h21, h11)  and the Euler flip
     chi(Y) = -chi(X), with chi(X) = 2*(h11 - h21).
  2. The Euler-number histogram of a bounded family of Hodge diamonds is symmetric
     under e -> -e  (theorem `countEuler_neg`), witnessed by the swap bijection.
  3. The SYZ torus fiber T^n: palindromic Betti vector b_k = C(n,k) = b_{n-k},
     total Betti sum 2^n, vanishing Euler characteristic for n >= 1, and the
     even/odd Betti balance.
  4. The local zeta function of a Calabi-Yau 1-fold (elliptic curve) over F_p:
     its numerator P(T) = 1 - a_p T + p T^2 is p-reciprocal and its reciprocal
     roots have absolute value sqrt(p) (the Weil bound), both flowing from a*b = p.

Every routine is inlined and uses only the Python standard library.
"""

from __future__ import annotations

from math import comb, isqrt, gcd
from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# 1. Hodge data of a Calabi-Yau threefold and the mirror involution
# ---------------------------------------------------------------------------

def euler(h11: int, h21: int) -> int:
    """Topological Euler characteristic chi = 2*(h11 - h21), valued in Z."""
    return 2 * (h11 - h21)


def mirror(h11: int, h21: int) -> Tuple[int, int]:
    """The mirror Calabi-Yau: transpose the Hodge diamond, swapping h11 and h21."""
    return (h21, h11)


def picard_rank(h11: int, h21: int) -> int:
    """rk Pic X = h11."""
    return h11


def curve_moduli(h11: int, h21: int) -> int:
    """The complex-structure-moduli rank h21 governing rational-curve enumeration."""
    return h21


def demo_mirror_involution() -> None:
    """Demonstrate mirror_involutive, euler_mirror, picardRank_mirror."""
    print("=" * 70)
    print("1. Hodge mirror involution and the Euler-number flip")
    print("=" * 70)
    # The quintic threefold and its mirror are the textbook example.
    examples: List[Tuple[str, int, int]] = [
        ("quintic threefold", 1, 101),
        ("mirror quintic", 101, 1),
        ("a self-mirror diamond", 7, 7),
        ("generic example", 3, 243),
    ]
    for name, h11, h21 in examples:
        my11, my21 = mirror(h11, h21)
        chi = euler(h11, h21)
        chi_m = euler(my11, my21)
        assert mirror(my11, my21) == (h11, h21)          # mirror_involutive
        assert chi_m == -chi                              # euler_mirror
        assert picard_rank(my11, my21) == curve_moduli(h11, h21)  # picardRank_mirror
        selfmirror = (mirror(h11, h21) == (h11, h21))
        assert selfmirror == (chi == 0)                   # selfMirror_iff_euler_zero
        print(f"  {name:24s}: (h11,h21)=({h11:4d},{h21:4d})  "
              f"chi={chi:+5d}  mirror=({my11:4d},{my21:4d})  chi(mirror)={chi_m:+5d}")
    print("  All identities (involutive, euler flip, picard=curve, self<->chi=0) hold.\n")


# ---------------------------------------------------------------------------
# 2. Mirror symmetry of the Euler-number histogram (countEuler_neg)
# ---------------------------------------------------------------------------

def count_euler(e: int, bound: int) -> int:
    """Number of (h11, h21) with both entries in [0, bound] and 2*(h11-h21) = e."""
    total = 0
    for h11 in range(bound + 1):
        for h21 in range(bound + 1):
            if 2 * (h11 - h21) == e:
                total += 1
    return total


def demo_histogram_symmetry(bound: int = 6) -> None:
    """Verify countEuler(e, B) == countEuler(-e, B) for all relevant e."""
    print("=" * 70)
    print(f"2. Euler-number histogram symmetry  (bound B = {bound})")
    print("=" * 70)
    # Possible Euler numbers are even multiples in [-2B, 2B].
    histogram: Dict[int, int] = {}
    for e in range(-2 * bound, 2 * bound + 1, 2):
        histogram[e] = count_euler(e, bound)
    print("    e :  count(e)   count(-e)   symmetric?")
    for e in range(0, 2 * bound + 1, 2):
        c_pos = histogram[e]
        c_neg = histogram[-e]
        ok = (c_pos == c_neg)
        assert ok, f"symmetry failed at e={e}"
        print(f"  {e:+4d} :  {c_pos:6d}    {c_neg:7d}      {ok}")
    assert sum(histogram.values()) == (bound + 1) ** 2
    print(f"  Total diamonds counted: {sum(histogram.values())} = (B+1)^2 = {(bound+1)**2}")
    print("  The swap bijection (a,b) -> (b,a) makes the histogram a mirror image.\n")


# ---------------------------------------------------------------------------
# 3. The SYZ torus fiber  T^n
# ---------------------------------------------------------------------------

def betti_torus(n: int, k: int) -> int:
    """Betti number b_k(T^n) = C(n, k), the exterior algebra on n generators."""
    if k < 0 or k > n:
        return 0
    return comb(n, k)


def euler_torus(n: int) -> int:
    """Euler characteristic of T^n via the alternating sum of Betti numbers."""
    return sum((-1) ** k * betti_torus(n, k) for k in range(n + 1))


def even_betti(n: int) -> int:
    """Sum of even-degree Betti numbers of T^n."""
    return sum(betti_torus(n, k) for k in range(n + 1) if k % 2 == 0)


def odd_betti(n: int) -> int:
    """Sum of odd-degree Betti numbers of T^n."""
    return sum(betti_torus(n, k) for k in range(n + 1) if k % 2 == 1)


def demo_syz_fiber(max_n: int = 6) -> None:
    """Demonstrate bettiTorus_poincare, bettiTorus_total, eulerTorus_eq_zero,
    evenBetti_eq_oddBetti."""
    print("=" * 70)
    print("3. The SYZ torus fiber  T^n  under T-duality")
    print("=" * 70)
    print("   n |  Betti vector (b_0..b_n)          | sum  | chi | even | odd")
    print("  ---+-----------------------------------+------+-----+------+-----")
    for n in range(0, max_n + 1):
        betti = [betti_torus(n, k) for k in range(n + 1)]
        # Poincare duality / T-duality: palindrome b_k = b_{n-k}
        assert betti == betti[::-1]                        # bettiTorus_poincare
        total = sum(betti)
        assert total == 2 ** n                             # bettiTorus_total
        chi = euler_torus(n)
        if n >= 1:
            assert chi == 0                                # eulerTorus_eq_zero
            assert even_betti(n) == odd_betti(n)           # evenBetti_eq_oddBetti
        vec = " ".join(f"{b:2d}" for b in betti)
        print(f"  {n:2d} | {vec:33s} | {total:4d} | {chi:+3d} | "
              f"{even_betti(n):4d} | {odd_betti(n):3d}")
    print("  Palindromic Betti (T-duality), total 2^n, chi=0, even=odd for n>=1.\n")


# ---------------------------------------------------------------------------
# 4. Calabi-Yau 1-fold zeta numerators: reciprocity and the Weil bound
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    for d in range(2, isqrt(n) + 1):
        if n % d == 0:
            return False
    return True


def count_points_affine_weierstrass(a: int, b: int, p: int) -> int:
    """Affine point count of y^2 = x^3 + a x + b over F_p (no projective point)."""
    count = 0
    for x in range(p):
        rhs = (x * x * x + a * x + b) % p
        for y in range(p):
            if (y * y) % p == rhs:
                count += 1
    return count


def elliptic_trace(a: int, b: int, p: int) -> int:
    """The trace of Frobenius a_p = p + 1 - #E(F_p) for y^2 = x^3 + a x + b."""
    # #E(F_p) = (affine points) + 1 (the point at infinity).
    n_points = count_points_affine_weierstrass(a, b, p) + 1
    return p + 1 - n_points


def zeta_numerator_coeffs(a_p: int, p: int) -> Tuple[int, int, int]:
    """Coefficients (c0, c1, c2) of P(T) = 1 - a_p T + p T^2."""
    return (1, -a_p, p)


def is_p_reciprocal(coeffs: Tuple[int, int, int], p: int) -> bool:
    """Check the functional equation  p^g T^{2g} P(1/(pT)) = P(T)  for g = 1.

    For P(T) = c0 + c1 T + c2 T^2 this is equivalent to c2 = p*c0 and the
    palindromic relation c0*p = c2, c1 = c1 (middle fixed)."""
    c0, c1, c2 = coeffs
    # p * T^2 * P(1/(pT)) = p*T^2*(c0 + c1/(pT) + c2/(p^2 T^2))
    #                     = c0*p*T^2 + c1*T + c2/p
    # equals P(T) = c0 + c1 T + c2 T^2  iff  c0*p = c2 and c2/p = c0.
    return c2 == p * c0 and c0 == c2 // p if c2 % p == 0 else False


def weil_roots_satisfy_bound(a_p: int, p: int) -> bool:
    """Check that the reciprocal roots alpha, beta of P satisfy |alpha|=|beta|=sqrt(p).

    Roots of 1 - a_p T + p T^2 are 1/alpha, 1/beta where alpha*beta = p and
    alpha + beta = a_p.  The Weil bound |a_p| <= 2 sqrt(p) makes alpha, beta a
    complex-conjugate pair of modulus sqrt(p)."""
    return a_p * a_p <= 4 * p


def demo_zeta_modularity() -> None:
    """Demonstrate eulerFactor_funeq (reciprocity) and zeta_frobenius_weil."""
    print("=" * 70)
    print("4. Calabi-Yau 1-fold (elliptic curve) zeta numerators over F_p")
    print("=" * 70)
    curve_a, curve_b = -1, 1   # y^2 = x^3 - x + 1, a nonsingular elliptic curve
    print(f"   Curve: y^2 = x^3 + ({curve_a}) x + ({curve_b})")
    print("   p |  #E(F_p) | a_p | P(T)=1 - a_p T + p T^2 | recip? | Weil |a_p|<=2sqrt(p)")
    print("  ---+----------+-----+------------------------+--------+----------------------")
    for p in [5, 7, 11, 13, 17, 19, 23]:
        if not is_prime(p):
            continue
        # ensure nonsingular mod p: discriminant -16(4a^3+27b^2) != 0
        disc = -16 * (4 * curve_a ** 3 + 27 * curve_b ** 2)
        if disc % p == 0:
            continue
        a_p = elliptic_trace(curve_a, curve_b, p)
        n_pts = p + 1 - a_p
        coeffs = zeta_numerator_coeffs(a_p, p)
        recip = is_p_reciprocal(coeffs, p)
        weil = weil_roots_satisfy_bound(a_p, p)
        assert recip and weil
        c0, c1, c2 = coeffs
        poly = f"1 + ({c1})T + {c2}T^2"
        print(f"  {p:2d} | {n_pts:8d} | {a_p:+3d} | {poly:22s} | {str(recip):6s} | "
              f"{weil} ({abs(a_p)} <= {2*isqrt(p)+1}~2sqrt({p}))")
    print("  Each numerator is p-reciprocal (functional equation) and Weil-bounded;")
    print("  both spring from the single relation alpha*beta = p.\n")


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("\nArithmetic Mirror Symmetry for Calabi-Yau -- numerical demonstrations\n")
    demo_mirror_involution()
    demo_histogram_symmetry(bound=6)
    demo_syz_fiber(max_n=6)
    demo_zeta_modularity()
    print("All demonstrations completed; every assertion matched the formalized theorems.")


if __name__ == "__main__":
    main()
