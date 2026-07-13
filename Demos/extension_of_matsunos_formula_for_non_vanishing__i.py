"""
demo.py — Numerical demonstrations for the μ-corrected Matsuno formula.

This self-contained script illustrates the main results on the extension of
Matsuno's formula for the sharp/flat Iwasawa λ-invariants of quadratic twists
of an elliptic curve with good supersingular reduction at 2, in the presence of
a non-vanishing μ-invariant.

All mathematical objects are re-implemented here directly from their
definitions so the file stands alone.  Everything is exact integer arithmetic.

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, Dict, List, Tuple


# --------------------------------------------------------------------------- #
#  Basic 2-adic arithmetic
# --------------------------------------------------------------------------- #
def padic_val(p: int, n: int) -> int:
    """The p-adic valuation v_p(n): the exponent of p in n (v_p(0) := 0)."""
    if n == 0:
        return 0
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def prime_factors(n: int) -> List[int]:
    """The sorted list of distinct prime divisors of n (n >= 1)."""
    factors: List[int] = []
    d = 2
    m = n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        factors.append(m)
    return factors


# --------------------------------------------------------------------------- #
#  Part I.  The μ-corrected Matsuno λ-difference
# --------------------------------------------------------------------------- #
def n_ell(ell: int) -> int:
    """The 2-adic depth  n_ell = v_2( (ell^2 - 1) / 8 )."""
    return padic_val(2, (ell ** 2 - 1) // 8)


def local_term(conductor: int, ord_map: Callable[[int], int], ell: int) -> int:
    """Classical (μ = 0) local contribution δ(ℓ) of a prime ℓ.

    2^{n_ℓ}       if ℓ divides the conductor N_E,
    2^{n_ℓ + 1}   else if the reduction order ord(ℓ) is even,
    0             otherwise.
    """
    if conductor % ell == 0:
        return 2 ** n_ell(ell)
    if ord_map(ell) % 2 == 0:
        return 2 ** (n_ell(ell) + 1)
    return 0


def lambda_diff(D: int, conductor: int, ord_map: Callable[[int], int]) -> int:
    """Classical Matsuno sharp/flat λ-difference of the twist E^D (μ = 0)."""
    return sum(local_term(conductor, ord_map, ell) for ell in prime_factors(D))


def mu_weight(ell: int) -> int:
    """The local μ-weight 2^{n_ℓ} carried by each prime divisor of D."""
    return 2 ** n_ell(ell)


def mu_term(D: int, mu: int) -> int:
    """The μ-correction:  μ · Σ_{ℓ | D} 2^{n_ℓ}."""
    return mu * sum(mu_weight(ell) for ell in prime_factors(D))


def lambda_diff_mu(
    D: int, conductor: int, mu: int, ord_map: Callable[[int], int]
) -> int:
    """The μ-corrected sharp/flat λ-difference of the twist E^D."""
    return lambda_diff(D, conductor, ord_map) + mu_term(D, mu)


# --------------------------------------------------------------------------- #
#  Part II.  Sharp/flat degree sequences (Pollack–Kobayashi type) at p = 2
# --------------------------------------------------------------------------- #
def flat_deg(n: int) -> int:
    """Flat degree  Σ_{i<n} 4^i = (4^n - 1)/3."""
    return sum(4 ** i for i in range(n))


def sharp_deg(n: int) -> int:
    """Sharp degree  Σ_{i<n} 2·4^i = 2·flat_deg(n)."""
    return sum(2 * 4 ** i for i in range(n))


def jacobsthal(n: int) -> int:
    """Jacobsthal number  J_n:  J_0 = 0, J_1 = 1, J_{n+2} = J_{n+1} + 2 J_n."""
    a, b = 0, 1
    if n == 0:
        return a
    for _ in range(n - 1):
        a, b = b, b + 2 * a
    return b


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_depths() -> None:
    print("=" * 68)
    print("  2-adic depths  n_ℓ = v_2((ℓ²-1)/8)  and μ-weights 2^{n_ℓ}")
    print("=" * 68)
    print(f"{'ℓ':>5} | {'ℓ²-1':>8} | {'(ℓ²-1)/8':>10} | {'n_ℓ':>4} | {'2^{n_ℓ}':>8} |"
          f" {'v2(ℓ-1)+v2(ℓ+1)':>16}")
    print("-" * 68)
    for ell in [3, 5, 7, 11, 13, 17, 31, 127]:
        v = padic_val(2, ell - 1) + padic_val(2, ell + 1)
        print(f"{ell:>5} | {ell**2-1:>8} | {(ell**2-1)//8:>10} | {n_ell(ell):>4} |"
              f" {2**n_ell(ell):>8} | {v:>16}")
    print("\nDepth law check:  8 · 2^{n_ℓ} = 2^{v2(ℓ-1)+v2(ℓ+1)} for odd ℓ ≥ 3")
    for ell in [3, 5, 7, 11, 13, 17, 31, 127]:
        lhs = 8 * mu_weight(ell)
        rhs = 2 ** (padic_val(2, ell - 1) + padic_val(2, ell + 1))
        assert lhs == rhs, (ell, lhs, rhs)
    print("  verified for all sampled ℓ.\n")


def demo_conservativity_and_mu() -> None:
    print("=" * 68)
    print("  Conservativity and the μ-contribution")
    print("=" * 68)
    # A toy model: conductor N_E = 15, reduction order ord(ℓ) = ℓ - 1.
    conductor = 15
    ord_map: Callable[[int], int] = lambda ell: ell - 1
    for D in [5, 13, 65, 5 * 13 * 17]:
        base = lambda_diff(D, conductor, ord_map)
        print(f"D = {D:>4}:  classical λ-difference = {base}")
        for mu in [0, 1, 2, 3]:
            total = lambda_diff_mu(D, conductor, mu, ord_map)
            print(f"           μ = {mu}:  corrected = {total:>4}"
                  f"   (extra = {total - base})")
        assert lambda_diff_mu(D, conductor, 0, ord_map) == base
    print()


def demo_additivity() -> None:
    print("=" * 68)
    print("  Complete additivity over coprime moduli")
    print("=" * 68)
    conductor = 15
    ord_map: Callable[[int], int] = lambda ell: ell - 1
    mu = 2
    pairs: List[Tuple[int, int]] = [(5, 13), (17, 29), (5 * 13, 17)]
    for a, b in pairs:
        left = lambda_diff_mu(a * b, conductor, mu, ord_map)
        right = (lambda_diff_mu(a, conductor, mu, ord_map)
                 + lambda_diff_mu(b, conductor, mu, ord_map))
        status = "OK" if left == right else "FAIL"
        print(f"  a={a:>3}, b={b:>3}:  Λ(ab)={left:>4}   Λ(a)+Λ(b)={right:>4}   [{status}]")
        assert left == right
    print()


def demo_sharp_flat() -> None:
    print("=" * 68)
    print("  Sharp/flat degree sequences and the Jacobsthal law (p = 2)")
    print("=" * 68)
    print(f"{'n':>3} | {'flatDeg':>8} | {'sharpDeg':>9} | {'4^n':>8} |"
          f" {'J_{2n}':>8} | {'3·flat+1':>9}")
    print("-" * 60)
    for n in range(0, 9):
        f = flat_deg(n)
        s = sharp_deg(n)
        j = jacobsthal(2 * n)
        print(f"{n:>3} | {f:>8} | {s:>9} | {4**n:>8} | {j:>8} | {3*f+1:>9}")
        assert s == 2 * f                      # sharp = 2·flat
        assert s + f + 1 == 4 ** n             # sharp + flat + 1 = 4^n
        assert 3 * f + 1 == 4 ** n             # 3·flat + 1 = 4^n
        assert j == f                          # J_{2n} = flatDeg(n)
    print("\nJacobsthal closed form  3·J_n = 2^n - (-1)^n:")
    for n in range(0, 10):
        assert 3 * jacobsthal(n) == 2 ** n - (-1) ** n
    print("  verified for n = 0..9.")
    print("Consecutive sum  J_n + J_{n+1} = 2^n:")
    for n in range(0, 10):
        assert jacobsthal(n) + jacobsthal(n + 1) == 2 ** n
    print("  verified for n = 0..9.\n")


def main() -> None:
    demo_depths()
    demo_conservativity_and_mu()
    demo_additivity()
    demo_sharp_flat()
    print("All demonstrations completed and all identities verified.")


if __name__ == "__main__":
    main()
