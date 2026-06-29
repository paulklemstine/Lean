"""
The Exponential-Convolution Ring of Counting Sequences
======================================================

Numerical demonstrations of the species--EGF bridge, using exact rational
arithmetic so that every identity is verified *exactly* (no floating point).

Key facts demonstrated
-----------------------
  1. egf(a)            = sum_n (a_n / n!) X^n                       (Definition 2.1)
  2. (a * b)_n         = sum_{i+j=n} C(n,i) a_i b_j                 (binomial convolution)
  3. egf(a * b)        = egf(a) . egf(b)   (Cauchy product)        (Theorem 2.4)
  4. egf is a bijection: seqOf(egf(a)) = a,  egf(seqOf(f)) = f     (Theorem 3.2)
  5. * is commutative, associative, has unit (1,0,0,...)          (Theorems 5.1-5.3)
  6. egf(a^*k) = (egf a)^k                                         (Theorem 6.2)
  7. species of sets E  -> exp;  linear orders L -> 1/(1-X)        (Theorems 6.3-6.4)
  8. derivative species F'[n]=F[n+1] -> d/dX                       (Theorem 7.2)
  9. structural Leibniz: (a*b)' = a'*b + a*b'                      (Theorem 7.5)

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, factorial
from typing import Callable, List


# --------------------------------------------------------------------------
# Core operations on truncated counting sequences / power series
# --------------------------------------------------------------------------

Seq = List[Fraction]  # a truncated counting sequence a_0, a_1, ..., a_N


def egf(a: Seq) -> Seq:
    """EGF coefficients: [a_0/0!, a_1/1!, ...].  (Algorithm 8.1)"""
    return [a[n] / factorial(n) for n in range(len(a))]


def seq_of(f: Seq) -> Seq:
    """Inverse of egf: recover a_n = n! * [X^n] f.  (Definition 3.1)"""
    return [factorial(n) * f[n] for n in range(len(f))]


def bin_conv(a: Seq, b: Seq) -> Seq:
    """Binomial (exponential) convolution (a*b)_n = sum_{i+j=n} C(n,i) a_i b_j.

    (Definition 2.2, Algorithm 8.2)"""
    n_max = min(len(a), len(b))
    return [
        sum((Fraction(comb(n, i)) * a[i] * b[n - i] for i in range(n + 1)),
            Fraction(0))
        for n in range(n_max)
    ]


def cauchy(f: Seq, g: Seq) -> Seq:
    """Ordinary Cauchy product of power-series coefficient lists."""
    n_max = min(len(f), len(g))
    return [sum((f[i] * g[n - i] for i in range(n + 1)), Fraction(0))
            for n in range(n_max)]


def pointwise_add(a: Seq, b: Seq) -> Seq:
    return [x + y for x, y in zip(a, b)]


def bin_conv_one(n_terms: int) -> Seq:
    """The convolution unit (1, 0, 0, ...)."""
    return [Fraction(1) if n == 0 else Fraction(0) for n in range(n_terms)]


def bin_conv_pow(a: Seq, k: int) -> Seq:
    """k-fold binomial convolution a^*k.  (Definition 6.1, Algorithm 8.4)"""
    result = bin_conv_one(len(a))
    for _ in range(k):
        result = bin_conv(result, a)
    return result


def seq_deriv(a: Seq) -> Seq:
    """Derivative species sequence (seqDeriv a)_n = a_{n+1}.  (Definition 7.1)"""
    return a[1:]


def series_deriv(f: Seq) -> Seq:
    """Formal derivative of a power series: [X^n] f' = (n+1) [X^{n+1}] f."""
    return [(n + 1) * f[n + 1] for n in range(len(f) - 1)]


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

N = 9


def show(title: str) -> None:
    print("\n" + "=" * 70 + f"\n{title}\n" + "=" * 70)


def assert_eq(lhs: Seq, rhs: Seq, label: str) -> None:
    m = min(len(lhs), len(rhs))
    ok = all(lhs[i] == rhs[i] for i in range(m))
    print(f"  [{'OK ' if ok else 'FAIL'}] {label}")
    assert ok, f"{label}: {lhs[:m]} != {rhs[:m]}"


def demo_product_law() -> None:
    show("Theorem 2.4  --  egf(a * b) = egf(a) . egf(b)")
    a: Seq = [Fraction(factorial(n)) for n in range(N)]    # linear orders, a_n = n!
    b: Seq = [Fraction(1) for _ in range(N)]               # sets, b_n = 1
    lhs = egf(bin_conv(a, b))
    rhs = cauchy(egf(a), egf(b))
    print(f"  a_n = n!  (linear orders),   b_n = 1  (sets)")
    print(f"  egf(a*b) = {[str(x) for x in lhs]}")
    print(f"  egf a.egf b = {[str(x) for x in rhs]}")
    assert_eq(lhs, rhs, "binomial convolution  <->  Cauchy product")


def demo_bijection() -> None:
    show("Theorem 3.2  --  egf is a bijection (seqOf is its inverse)")
    a: Seq = [Fraction(n * n + 1) for n in range(N)]
    assert_eq(seq_of(egf(a)), a, "seqOf(egf a) = a")
    f: Seq = [Fraction(1, n + 1) for n in range(N)]
    assert_eq(egf(seq_of(f)), f, "egf(seqOf f) = f")


def demo_ring_axioms() -> None:
    show("Theorems 5.1-5.3  --  the exponential-convolution semiring axioms")
    a: Seq = [Fraction(n + 1) for n in range(N)]
    b: Seq = [Fraction(2 ** n) for n in range(N)]
    c: Seq = [Fraction(factorial(n)) for n in range(N)]
    assert_eq(bin_conv(a, b), bin_conv(b, a), "commutativity  a*b = b*a")
    assert_eq(bin_conv(bin_conv(a, b), c), bin_conv(a, bin_conv(b, c)),
              "associativity  (a*b)*c = a*(b*c)")
    one = bin_conv_one(N)
    assert_eq(bin_conv(one, a), a, "left unit   1 * a = a")
    assert_eq(bin_conv(a, one), a, "right unit  a * 1 = a")
    assert_eq(bin_conv(a, pointwise_add(b, c)),
              pointwise_add(bin_conv(a, b), bin_conv(a, c)),
              "distributivity  a*(b+c) = a*b + a*c")


def demo_power_law() -> None:
    show("Theorem 6.2  --  egf(a^*k) = (egf a)^k")
    a: Seq = [Fraction(1) for _ in range(N)]   # the set species E
    k = 3
    lhs = egf(bin_conv_pow(a, k))
    rhs: Seq = bin_conv_one(N)
    rhs = egf(a)
    acc = bin_conv_one(N)            # build (egf a)^k via Cauchy products
    acc = [Fraction(1) if n == 0 else Fraction(0) for n in range(N)]
    for _ in range(k):
        acc = cauchy(acc, egf(a))
    assert_eq(lhs, acc, f"egf(E^*{k}) = (egf E)^{k}")
    # E^*k counts ordered set-partitions into k labelled blocks; check counts:
    counts = seq_of(lhs)
    print(f"  (E^*{k})_n = number of functions [n] -> {{1..{k}}} = {k}^n:")
    print(f"     {[str(int(x)) for x in counts]}  vs  {[k**n for n in range(N)]}")


def demo_canonical_egfs() -> None:
    show("Theorems 6.3-6.4  --  E -> exp,   L -> 1/(1-X)")
    # Sets: a_n = 1  =>  egf = exp,  coefficients 1/n!
    sets: Seq = [Fraction(1) for _ in range(N)]
    exp_coeffs = [Fraction(1, factorial(n)) for n in range(N)]
    assert_eq(egf(sets), exp_coeffs, "egf(E) = exp = sum X^n/n!")
    # Linear orders: a_n = n!  =>  egf = sum X^n = 1/(1-X)
    lin: Seq = [Fraction(factorial(n)) for n in range(N)]
    geom = [Fraction(1) for _ in range(N)]
    assert_eq(egf(lin), geom, "egf(L) = sum X^n = 1/(1-X)")
    # check (1 - X) . egf(L) = 1
    one_minus_x = [Fraction(1), Fraction(-1)] + [Fraction(0)] * (N - 2)
    prod = cauchy(one_minus_x, egf(lin))
    assert_eq(prod, bin_conv_one(N), "(1 - X) . egf(L) = 1")


def demo_differential() -> None:
    show("Theorems 7.2 & 7.5  --  derivative species and the Leibniz rule")
    a: Seq = [Fraction(factorial(n)) for n in range(N)]
    b: Seq = [Fraction(n + 1) for n in range(N)]
    # Derivative law: egf(seqDeriv a) = d/dX egf(a)
    assert_eq(egf(seq_deriv(a)), series_deriv(egf(a)),
              "egf(F') = d/dX egf(F)")
    # Structural Leibniz: (a*b)' = a'*b + a*b'
    lhs = seq_deriv(bin_conv(a, b))
    rhs = pointwise_add(bin_conv(seq_deriv(a), b),
                        bin_conv(a, seq_deriv(b)))
    assert_eq(lhs, rhs, "(a*b)' = a'*b + a*b'")


def main() -> None:
    print(__doc__)
    demo_product_law()
    demo_bijection()
    demo_ring_axioms()
    demo_power_law()
    demo_canonical_egfs()
    demo_differential()
    print("\nAll identities verified exactly over the rationals.\n")


if __name__ == "__main__":
    main()
