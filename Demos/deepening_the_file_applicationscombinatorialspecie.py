"""
demo.py — The Exponential-Convolution Ring of Counting Sequences
=================================================================

Numerical demonstrations of the theory developed in the accompanying article and
research paper: the exponential generating function (EGF) is an *isomorphism of
commutative rings* between counting sequences (under pointwise addition and the
binomial/exponential convolution) and formal power series over the rationals.

We use exact rational arithmetic (`fractions.Fraction`) throughout so that every
identity is verified *exactly*, not merely to floating-point tolerance.

Counting-sequence conventions
-----------------------------
A counting sequence is represented by a finite prefix ``a = [a0, a1, ..., aN]``
with ``a[n]`` the number of labelled structures of size ``n``.

Key objects:
    egf(a)[n]            = a[n] / n!                       (forward transform)
    seq_of(c)[n]         = n! * c[n]                       (inverse transform)
    bin_conv(a, b)[n]    = sum_{i+j=n} C(n,i) a[i] b[j]    (ring multiplication)
    delta                = [1, 0, 0, ...]                  (ring unit)

Run ``python demo.py`` to execute all demonstrations.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, factorial
from typing import Callable, List, Sequence


# ---------------------------------------------------------------------------
# Core transforms and the ring operations
# ---------------------------------------------------------------------------

Seq = List[Fraction]


def to_seq(values: Sequence[int | Fraction]) -> Seq:
    """Coerce a list of ints/Fractions into a rational counting sequence."""
    return [Fraction(v) for v in values]


def egf(a: Sequence[Fraction], length: int | None = None) -> Seq:
    """Forward EGF transform: coefficient sequence ``a[n]/n!``."""
    n = len(a) if length is None else length
    return [Fraction(a[k]) / factorial(k) for k in range(n)]


def seq_of(coeffs: Sequence[Fraction], length: int | None = None) -> Seq:
    """Inverse EGF transform: recover counts via ``n! * coeffs[n]``."""
    n = len(coeffs) if length is None else length
    return [factorial(k) * Fraction(coeffs[k]) for k in range(n)]


def bin_conv(a: Sequence[Fraction], b: Sequence[Fraction]) -> Seq:
    """Binomial (exponential) convolution ``(a * b)[n] = sum C(n,i) a[i] b[n-i]``."""
    n = min(len(a), len(b))
    out: Seq = []
    for m in range(n):
        s = Fraction(0)
        for i in range(m + 1):
            s += comb(m, i) * Fraction(a[i]) * Fraction(b[m - i])
        out.append(s)
    return out


def pointwise_add(a: Sequence[Fraction], b: Sequence[Fraction]) -> Seq:
    """Pointwise addition (the ring addition)."""
    n = min(len(a), len(b))
    return [Fraction(a[k]) + Fraction(b[k]) for k in range(n)]


def delta(n: int) -> Seq:
    """The Kronecker unit sequence (1, 0, 0, ...) of length ``n``."""
    return [Fraction(1) if k == 0 else Fraction(0) for k in range(n)]


def bin_conv_pow(a: Sequence[Fraction], k: int) -> Seq:
    """k-fold convolution power ``a^{*k}`` (a^{*0} = delta)."""
    result = delta(len(a))
    for _ in range(k):
        result = bin_conv(result, a)
    return result


# ---------------------------------------------------------------------------
# Power-series helpers (truncated polynomials in X over Q)
# ---------------------------------------------------------------------------

def ps_mul(f: Sequence[Fraction], g: Sequence[Fraction]) -> Seq:
    """Cauchy product of two power series, truncated to common length."""
    n = min(len(f), len(g))
    out: Seq = []
    for m in range(n):
        s = Fraction(0)
        for i in range(m + 1):
            s += Fraction(f[i]) * Fraction(g[m - i])
        out.append(s)
    return out


def ps_add(f: Sequence[Fraction], g: Sequence[Fraction]) -> Seq:
    return pointwise_add(f, g)


def ps_derivative(f: Sequence[Fraction]) -> Seq:
    """Formal derivative d/dX: ``[X^n] f' = (n+1) [X^{n+1}] f``."""
    return [(n + 1) * Fraction(f[n + 1]) for n in range(len(f) - 1)]


def ps_exp(n: int) -> Seq:
    """The power series exp(X) = sum X^n/n!, truncated to length n."""
    return [Fraction(1, factorial(k)) for k in range(n)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_inversion() -> None:
    banner("1. The EGF transform is a bijection (Theorem: Inversion)")
    a = to_seq([1, 1, 2, 6, 24, 120, 720])  # n!  (linear orders)
    c = egf(a)
    back = seq_of(c)
    print(f"  counts a            = {[int(x) for x in a]}")
    print(f"  egf(a) coefficients = {[str(x) for x in c]}")
    print(f"  seq_of(egf(a))      = {[int(x) for x in back]}")
    assert back == a, "inversion failed"
    print("  seq_of . egf = id   ✓  (no information lost)")


def demo_product_law() -> None:
    banner("2. Product law: egf(a * b) = egf(a) . egf(b)")
    a = to_seq([1, 2, 1, 3, 5])
    b = to_seq([0, 1, 4, 1, 2])
    lhs = egf(bin_conv(a, b))
    rhs = ps_mul(egf(a), egf(b))
    print(f"  egf(a * b)          = {[str(x) for x in lhs]}")
    print(f"  egf(a) . egf(b)     = {[str(x) for x in rhs]}")
    assert lhs == rhs, "product law failed"
    print("  binomial convolution  <->  power-series product   ✓")


def demo_ring_axioms() -> None:
    banner("3. Convolution semiring axioms (free consequences of the ring iso)")
    a = to_seq([1, 1, 2, 5, 14])
    b = to_seq([0, 1, 1, 2, 3])
    c = to_seq([2, 0, 1, 1, 4])
    u = delta(len(a))

    assert bin_conv(a, b) == bin_conv(b, a)
    print("  commutativity  a * b = b * a                         ✓")

    left = bin_conv(bin_conv(a, b), c)
    right = bin_conv(a, bin_conv(b, c))
    assert left == right
    print("  associativity  (a * b) * c = a * (b * c)             ✓")

    assert bin_conv(u, a) == a and bin_conv(a, u) == a
    print("  unit laws      delta * a = a = a * delta             ✓")

    dist = bin_conv(a, pointwise_add(b, c))
    expanded = pointwise_add(bin_conv(a, b), bin_conv(a, c))
    assert dist == expanded
    print("  distributivity a * (b + c) = a * b + a * c           ✓")


def demo_power_law() -> None:
    banner("4. Power law: egf(a^{*k}) = (egf a)^k  (composition engine)")
    a = to_seq([0, 1, 1, 1, 1, 1, 1])  # no constant term
    base = egf(a)
    for k in (0, 1, 2, 3):
        lhs = egf(bin_conv_pow(a, k))
        # (egf a)^k by repeated power-series multiplication, starting from "1"
        acc = [Fraction(1) if i == 0 else Fraction(0) for i in range(len(a))]
        for _ in range(k):
            acc = ps_mul(acc, base)
        assert lhs == acc, f"power law failed at k={k}"
        print(f"  k={k}:  egf(a^*{k}) = (egf a)^{k}   ✓")


def demo_named_series() -> None:
    banner("5. Named species: sets <-> exp,  linear orders <-> 1/(1-X)")
    N = 8
    sets = to_seq([1] * N)  # species of sets: one structure per size
    assert egf(sets) == ps_exp(N)
    print("  egf(1,1,1,...) = exp(X)                              ✓")

    linord = to_seq([factorial(k) for k in range(N)])  # n! linear orders
    one_minus_x = [Fraction(1)] + [Fraction(-1)] + [Fraction(0)] * (N - 2)
    prod = ps_mul(one_minus_x, egf(linord))
    expected_one = [Fraction(1)] + [Fraction(0)] * (N - 2)
    assert prod[: N - 1] == expected_one
    print("  (1 - X) . egf(n!) = 1   =>  egf = 1/(1-X)            ✓")


def demo_calculus() -> None:
    banner("6. Species calculus: derivative, pointing, and Leibniz")
    a = to_seq([1, 1, 2, 6, 24, 120, 720])
    b = to_seq([0, 1, 1, 2, 5, 14, 42])

    # Derivative law: egf(shift a) = d/dX egf(a)
    shift_a = a[1:]
    lhs = egf(shift_a)
    rhs = ps_derivative(egf(a))
    assert lhs == rhs[: len(lhs)]
    print("  derivative law  egf(a_{n+1}) = d/dX egf(a)           ✓")

    # Pointing law: egf(n * a_n) = X * d/dX egf(a)
    point_a = [Fraction(n) * a[n] for n in range(len(a))]
    lhs = egf(point_a)
    deriv = ps_derivative(egf(a))
    x_times = [Fraction(0)] + deriv  # multiply by X
    assert lhs[: len(deriv)] == x_times[: len(deriv)]
    print("  pointing law    egf(n*a_n) = X * d/dX egf(a)         ✓")

    # Leibniz: (a * b)' = a' * b + a * b'
    ab_deriv = bin_conv(a, b)[1:]
    a1, b1 = a[1:], b[1:]
    leib = pointwise_add(bin_conv(a1, b), bin_conv(a, b1))
    m = min(len(ab_deriv), len(leib))
    assert ab_deriv[:m] == leib[:m]
    print("  Leibniz rule    (a * b)' = a' * b + a * b'           ✓")


def main() -> None:
    print("EXPONENTIAL-CONVOLUTION RING — NUMERICAL DEMONSTRATIONS")
    print("All identities verified exactly over the rationals.")
    demo_inversion()
    demo_product_law()
    demo_ring_axioms()
    demo_power_law()
    demo_named_series()
    demo_calculus()
    banner("ALL DEMONSTRATIONS PASSED")


if __name__ == "__main__":
    main()
