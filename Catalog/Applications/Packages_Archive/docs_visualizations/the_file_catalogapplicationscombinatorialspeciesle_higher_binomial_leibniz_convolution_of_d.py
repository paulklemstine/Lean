from fractions import Fraction
from math import comb, factorial
from typing import Callable, List


def derivative_fun(f: List[Fraction]) -> List[Fraction]:
    """Formal derivative d/dX on a truncated power series."""
    return [Fraction(n + 1) * f[n + 1] for n in range(len(f) - 1)]


def egf(a: List[Fraction]) -> List[Fraction]:
    """Exponential generating function: coeff_n = a_n / n!."""
    return [Fraction(a[n], factorial(n)) for n in range(len(a))]


def iterate(g: Callable[[List[Fraction]], List[Fraction]],
            k: int, x: List[Fraction]) -> List[Fraction]:
    for _ in range(k):
        x = g(x)
    return x


def maclaurin_extract(f: List[Fraction], k: int) -> Fraction:
    """Algorithm A: a_k = coeff_0(d^k/dX^k f).  Returns the un-normalised count."""
    return iterate(derivative_fun, k, f)[0]


def taylor_reconstruct(f: List[Fraction]) -> List[Fraction]:
    """Algorithm B: recover the counting sequence a with egf(a) == f.
    a_k = coeff_0(d^k/dX^k f) = k! * coeff_k(f)."""
    return [maclaurin_extract(f, k) for k in range(len(f))]


def higher_leibniz(f: List[Fraction], g: List[Fraction], k: int) -> List[Fraction]:
    """Algorithm C: (f*g)^(k) via the binomial sum  sum_i C(k,i) f^(i) g^(k-i)."""
    def cauchy(p: List[Fraction], q: List[Fraction]) -> List[Fraction]:
        m = min(len(p), len(q))
        return [sum((p[i] * q[n - i] for i in range(n + 1)), Fraction(0))
                for n in range(m)]
    n_terms = len(cauchy(f, g)) - k
    out = [Fraction(0)] * max(n_terms, 0)
    for i in range(k + 1):
        term = cauchy(iterate(derivative_fun, i, f),
                      iterate(derivative_fun, k - i, g))
        for m in range(min(len(out), len(term))):
            out[m] += Fraction(comb(k, i)) * term[m]
    return out
