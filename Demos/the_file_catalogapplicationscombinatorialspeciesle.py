"""
Numerical demonstrations of the Taylor calculus of combinatorial species.

Every identity proved in the formal development is reproduced here over EXACT
rationals (Python's ``fractions.Fraction``) on truncated power series.  A power
series ``f`` is represented as a list ``c`` of coefficients with
``c[n] = coeff_n(f)`` (the coefficient of ``X**n``).  A counting sequence
``a`` is represented as a list with ``a[n] = F[n]``, the number of structures
on ``n`` labels.

The dictionary, with every helper inlined and type-hinted:

    egf(a)_n              = a_n / n!                         (exponential GF)
    seqOf(f)_n            = n! * coeff_n(f)                  (inverse transform)
    derivativeFun(f)_n    = (n+1) * coeff_{n+1}(f)           (formal d/dX)
    pointing weights a_n  -> n^k * a_n                       (iterated pointing)
    binConv(a,b)_n        = sum_{i+j=n} C(n,i) a_i b_j       (Day-convolution count)

Theorems demonstrated:

    * Maclaurin extraction   coeff_0(d^k/dX^k egf(a)) == a_k
    * Taylor reconstruction  egf(k -> coeff_0(d^k/dX^k f)) == f
    * Iterated pointing      (pointed^k F)[n] == n^k * F[n]
    * Higher Leibniz rule    (f*g)^(k) == sum_i C(k,i) f^(i) g^(k-i)
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, factorial
from typing import Callable, List


# --------------------------------------------------------------------------- #
#  Core operations on truncated power series and counting sequences
# --------------------------------------------------------------------------- #
def egf(a: List[Fraction], n_terms: int) -> List[Fraction]:
    """EGF of a counting sequence: coeff_n = a_n / n!."""
    return [Fraction(a[n], factorial(n)) for n in range(n_terms)]


def seq_of(f: List[Fraction]) -> List[Fraction]:
    """Inverse transform: a_n = n! * coeff_n(f)."""
    return [Fraction(factorial(n)) * f[n] for n in range(len(f))]


def derivative_fun(f: List[Fraction]) -> List[Fraction]:
    """Formal derivative d/dX: coeff_n = (n+1) * coeff_{n+1}(f)."""
    return [Fraction(n + 1) * f[n + 1] for n in range(len(f) - 1)]


def iterate(g: Callable[[List[Fraction]], List[Fraction]],
            k: int, x: List[Fraction]) -> List[Fraction]:
    """Apply ``g`` exactly ``k`` times to ``x``."""
    for _ in range(k):
        x = g(x)
    return x


def coeff0(f: List[Fraction]) -> Fraction:
    """Constant term coeff_0(f)."""
    return f[0] if f else Fraction(0)


def euler_operator(f: List[Fraction]) -> List[Fraction]:
    """Euler operator theta = X * d/dX:  coeff_n = n * coeff_n(f)."""
    return [Fraction(n) * f[n] for n in range(len(f))]


def bin_conv(a: List[Fraction], b: List[Fraction], n_terms: int) -> List[Fraction]:
    """Binomial (exponential) convolution (a * b)_n = sum_{i+j=n} C(n,i) a_i b_j."""
    out: List[Fraction] = []
    for n in range(n_terms):
        out.append(sum((Fraction(comb(n, i)) * a[i] * b[n - i] for i in range(n + 1)),
                       Fraction(0)))
    return out


def cauchy_mul(f: List[Fraction], g: List[Fraction]) -> List[Fraction]:
    """Ordinary (Cauchy) product of two truncated power series."""
    n_terms = min(len(f), len(g))
    return [sum((f[i] * g[n - i] for i in range(n + 1)), Fraction(0))
            for n in range(n_terms)]


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #
def demo_maclaurin(a: List[Fraction]) -> None:
    """Theorem 4.5 / 5.1:  coeff_0(d^k/dX^k egf(a)) == a_k."""
    print("== Species Maclaurin extraction:  coeff_0(d^k/dX^k egf(a)) == a_k ==")
    n = len(a)
    f = egf(a, n)
    for k in range(n):
        extracted = coeff0(iterate(derivative_fun, k, f))
        assert extracted == a[k], (k, extracted, a[k])
        print(f"  k={k}:  extracted={extracted}   a_k={a[k]}   OK")
    print()


def demo_reconstruction(f: List[Fraction]) -> None:
    """Theorem 5.2:  egf(k -> coeff_0(d^k/dX^k f)) == f."""
    print("== Taylor reconstruction:  egf(k -> coeff_0(d^k/dX^k f)) == f ==")
    n = len(f)
    a_rebuilt = [coeff0(iterate(derivative_fun, k, f)) for k in range(n)]
    f_rebuilt = egf(a_rebuilt, n)
    assert f_rebuilt == f
    assert a_rebuilt == seq_of(f)   # the reconstructed sequence is exactly seqOf(f)
    print(f"  recovered counting sequence = {[str(x) for x in a_rebuilt]}")
    print(f"  egf(recovered) == f ?  {f_rebuilt == f}")
    print()


def demo_iterated_pointing(a: List[Fraction], k_max: int) -> None:
    """Theorem 6.1:  (pointed^k F)[n] == n^k * F[n]."""
    print("== Iterated pointing weights counts by n^k ==")
    n = len(a)
    for k in range(k_max + 1):
        pointed_k = [Fraction(n_idx) ** k * a[n_idx] for n_idx in range(n)]
        # cross-check via the Euler operator on the EGF
        euler_k = iterate(euler_operator, k, egf(a, n))
        for n_idx in range(n):
            assert euler_k[n_idx] == Fraction(pointed_k[n_idx], factorial(n_idx))
        print(f"  k={k}:  (pointed^{k})[n] = {[str(x) for x in pointed_k]}")
    print()


def demo_higher_leibniz(f: List[Fraction], g: List[Fraction], k_max: int) -> None:
    """Theorem 7.1:  (f*g)^(k) == sum_i C(k,i) f^(i) g^(k-i)."""
    print("== Higher (binomial) Leibniz rule on power series ==")
    for k in range(k_max + 1):
        lhs = iterate(derivative_fun, k, cauchy_mul(f, g))
        n_terms = len(lhs)
        rhs = [Fraction(0)] * n_terms
        for i in range(k + 1):
            fi = iterate(derivative_fun, i, f)
            gj = iterate(derivative_fun, k - i, g)
            term = cauchy_mul(fi, gj)
            for m in range(min(n_terms, len(term))):
                rhs[m] += Fraction(comb(k, i)) * term[m]
        assert lhs == rhs[:n_terms], (k, lhs, rhs)
        print(f"  k={k}:  (f*g)^({k}) matches binomial sum   OK")
    print()


def main() -> None:
    N = 8

    # Species of sets E:  E[n] = 1,  EGF = e^X.
    sets_seq = [Fraction(1)] * N
    # Species of linear orders L:  L[n] = n!,  EGF = 1/(1-X).
    orders_seq = [Fraction(factorial(n)) for n in range(N)]
    # Derangements D:  1,0,1,2,9,44,265,1854,...  EGF = e^{-X}/(1-X).
    derangements = [Fraction(x) for x in (1, 0, 1, 2, 9, 44, 265, 1854)]

    print("###  E = species of sets  (counts all 1, EGF = e^X)  ###\n")
    demo_maclaurin(sets_seq)
    demo_reconstruction(egf(sets_seq, N))
    demo_iterated_pointing(sets_seq, k_max=3)

    print("###  L = species of linear orders  (counts n!, EGF = 1/(1-X))  ###\n")
    demo_maclaurin(orders_seq)
    demo_reconstruction(egf(orders_seq, N))

    print("###  D = derangements  (subfactorials, EGF = e^{-X}/(1-X))  ###\n")
    demo_maclaurin(derangements)
    demo_reconstruction(egf(derangements, len(derangements)))

    print("###  Higher Leibniz on  f = g = e^X  (so f*g = e^{2X})  ###\n")
    e_to_x = egf(sets_seq, N)
    demo_higher_leibniz(e_to_x, e_to_x, k_max=4)

    print("All identities verified over exact rationals.")


if __name__ == "__main__":
    main()
