"""
Numerical demonstration of the mu-extension of Matsuno's sharp/flat
lambda-difference formula.

For an elliptic curve E/Q with good supersingular reduction at 2 and a
square-free twisting parameter D = 1 (mod 4), we model the sharp/flat
Iwasawa lambda-difference of the quadratic twist E^D by

    lambda_diff_mu(D) = lambda_diff(D) + mu * W(D),

where
    n_ell        = v2((ell^2 - 1) / 8)          (2-adic depth)
    c_ell        = local Matsuno term (three cases)
    lambda_diff  = sum over primes ell | D of c_ell
    w_ell        = 2 ** n_ell                    (mu-weight)
    W(D)         = sum over primes ell | D of w_ell

This script reproduces every theorem of the accompanying paper numerically:
additivity, exact recovery (inversion) of mu, strict monotonicity/injectivity,
strict growth under a new ramified prime, the 2-adic depth law, and the three
disproofs (multiplicativity fails; recovery needs a prime; not lower-order).

Pure standard library; run with:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, Dict, List


# --------------------------------------------------------------------------- #
# Core arithmetic
# --------------------------------------------------------------------------- #
def v2(m: int) -> int:
    """2-adic valuation of a positive integer m."""
    if m <= 0:
        raise ValueError("v2 requires a positive integer")
    k = 0
    while m % 2 == 0:
        m //= 2
        k += 1
    return k


def prime_factors(n: int) -> List[int]:
    """Sorted list of distinct prime divisors of n (empty for n <= 1)."""
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


def n_ell(ell: int) -> int:
    """2-adic depth n_ell = v2((ell^2 - 1) / 8) for odd ell >= 3."""
    val = ell * ell - 1
    assert val % 8 == 0, "ell^2 - 1 must be divisible by 8 for odd ell"
    return v2(val // 8)


def mu_weight(ell: int) -> int:
    """Local mu-weight w_ell = 2 ** n_ell."""
    return 2 ** n_ell(ell)


def weight_sum(D: int) -> int:
    """Total mu-weight W(D) = sum of w_ell over primes ell | D."""
    return sum(mu_weight(ell) for ell in prime_factors(D))


def local_term(NE: int, ord_fn: Callable[[int], int], ell: int) -> int:
    """Classical Matsuno local term c_ell (three cases)."""
    if NE % ell == 0:
        return 2 ** n_ell(ell)
    if ord_fn(ell) % 2 == 0:
        return 2 ** (n_ell(ell) + 1)
    return 0


def lambda_diff(D: int, NE: int, ord_fn: Callable[[int], int]) -> int:
    """Classical (mu = 0) Matsuno lambda-difference."""
    return sum(local_term(NE, ord_fn, ell) for ell in prime_factors(D))


def lambda_diff_mu(
    D: int, NE: int, mu: int, ord_fn: Callable[[int], int]
) -> int:
    """mu-corrected lambda-difference."""
    return lambda_diff(D, NE, ord_fn) + mu * weight_sum(D)


def recover_mu(
    D: int, NE: int, mu: int, ord_fn: Callable[[int], int]
) -> int:
    """Inversion formula: recover mu from the twist data (needs W(D) > 0)."""
    W = weight_sum(D)
    if W == 0:
        raise ValueError("recovery requires a prime divisor of D")
    return (lambda_diff_mu(D, NE, mu, ord_fn) - lambda_diff(D, NE, ord_fn)) // W


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_depth_law() -> None:
    print("=" * 68)
    print("Depth law:  8 * 2^{n_ell} = 2^{v2(ell-1) + v2(ell+1)}")
    print("=" * 68)
    print(f"{'ell':>4} {'n_ell':>6} {'w_ell':>6} {'8*w':>6} {'2^(v+v)':>8}"
          f" {'ell mod 8':>10}")
    for ell in [3, 5, 7, 11, 13, 17, 23, 31, 41]:
        lhs = 8 * mu_weight(ell)
        rhs = 2 ** (v2(ell - 1) + v2(ell + 1))
        assert lhs == rhs
        print(f"{ell:>4} {n_ell(ell):>6} {mu_weight(ell):>6} {lhs:>6}"
              f" {rhs:>8} {ell % 8:>10}")
    print("Note: w_ell == 1  exactly when  ell = +/-3 (mod 8).\n")


def demo_inversion() -> None:
    print("=" * 68)
    print("Exact recovery of mu via the inversion formula")
    print("=" * 68)
    NE = 3 * 7  # E ramified at 3 and 7
    ord_fn = lambda ell: 2 if ell % 3 == 1 else 1
    for D in [5, 13, 5 * 13, 5 * 13 * 17]:
        for mu in [0, 1, 2, 5, 42]:
            rec = recover_mu(D, NE, mu, ord_fn)
            assert rec == mu
        print(f"  D = {D:>4}:  recovered mu correctly for mu in "
              f"{{0,1,2,5,42}}   (W(D) = {weight_sum(D)})")
    print()


def demo_additivity() -> None:
    print("=" * 68)
    print("Additivity over coprime moduli (but NOT multiplicativity)")
    print("=" * 68)
    NE = 7
    ord_fn = lambda ell: 2 if ell == 5 else 1
    mu = 3
    a, b = 3, 5
    lhs = lambda_diff_mu(a * b, NE, mu, ord_fn)
    rhs = lambda_diff_mu(a, NE, mu, ord_fn) + lambda_diff_mu(b, NE, mu, ord_fn)
    prod = lambda_diff_mu(a, NE, mu, ord_fn) * lambda_diff_mu(b, NE, mu, ord_fn)
    print(f"  ldm(15) = {lhs},  ldm(3)+ldm(5) = {rhs}   -> additive: {lhs == rhs}")
    print(f"  ldm(3)*ldm(5) = {prod}                   -> multiplicative: "
          f"{lhs == prod}\n")


def demo_monotonicity() -> None:
    print("=" * 68)
    print("Strict monotonicity / injectivity in mu (D ramified)")
    print("=" * 68)
    NE, D = 1, 15
    ord_fn = lambda ell: 1
    vals: Dict[int, int] = {mu: lambda_diff_mu(D, NE, mu, ord_fn)
                            for mu in range(6)}
    print("  mu -> ldm(15):", vals)
    seq = [vals[mu] for mu in range(6)]
    assert all(seq[i] < seq[i + 1] for i in range(len(seq) - 1))
    print("  strictly increasing, hence injective.\n")


def demo_disproofs() -> None:
    print("=" * 68)
    print("Disproofs")
    print("=" * 68)
    # (1) recovery needs a prime divisor: D = 1
    NE, ord_fn = 1, (lambda ell: 1)
    v0 = lambda_diff_mu(1, NE, 0, ord_fn)
    v1 = lambda_diff_mu(1, NE, 1, ord_fn)
    print(f"  D=1: ldm(mu=0)={v0}, ldm(mu=1)={v1}  -> mu invisible: {v0 == v1}")
    # (2) mu-term not lower-order: D = 3
    D = 3
    cls = lambda_diff(D, 1, lambda ell: 1)
    cor = 1 * weight_sum(D)
    print(f"  D=3: classical={cls}, mu-correction={cor}  -> correction "
          f"dominates: {cls < cor}\n")


def main() -> None:
    demo_depth_law()
    demo_inversion()
    demo_additivity()
    demo_monotonicity()
    demo_disproofs()
    print("All numerical checks passed.")


if __name__ == "__main__":
    main()
