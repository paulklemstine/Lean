"""
Numerical demonstration of the algebraic Iwasawa bridge and the sharp/flat
lambda-difference under quadratic twist as a mu-proportional correction.

An integer polynomial f = a_0 + a_1 X + a_2 X^2 + ... is represented as a list of
its integer coefficients, index = degree:  [a_0, a_1, a_2, ...].

We model the two Iwasawa invariants on Z[X]:

    mu_p(f)     = v_p(content(f))
                = p-adic valuation of the gcd of the coefficients

    lambda_p(f) = trailing degree of the mod-p reduction of the primitive part
                = index of the lowest-order coefficient of primPart(f) not
                  divisible by p

Both are additive under multiplication (Gauss's Lemma + additivity of v_p for mu;
additivity of trailing degree in F_p[X] for lambda), and this drives every
result below.

This script is self-contained: run `python demo.py`.
"""

from __future__ import annotations

from math import gcd
from functools import reduce as _reduce
from typing import List


# --------------------------------------------------------------------------- #
# Basic polynomial arithmetic on Z[X] (coefficient lists, index = degree)      #
# --------------------------------------------------------------------------- #

def poly_trim(f: List[int]) -> List[int]:
    """Remove trailing (high-degree) zero coefficients; [] represents 0."""
    g = list(f)
    while g and g[-1] == 0:
        g.pop()
    return g


def poly_mul(f: List[int], g: List[int]) -> List[int]:
    """Multiply two integer polynomials given as coefficient lists."""
    f, g = poly_trim(f), poly_trim(g)
    if not f or not g:
        return []
    out: List[int] = [0] * (len(f) + len(g) - 1)
    for i, a in enumerate(f):
        for j, b in enumerate(g):
            out[i + j] += a * b
    return poly_trim(out)


def C(a: int) -> List[int]:
    """Constant polynomial with value a."""
    return poly_trim([a])


def X_pow(n: int) -> List[int]:
    """The monomial X^n."""
    return [0] * n + [1]


# --------------------------------------------------------------------------- #
# Content, primitive part, valuation, reduction                                #
# --------------------------------------------------------------------------- #

def content(f: List[int]) -> int:
    """Nonnegative gcd of the coefficients of a nonzero polynomial f."""
    f = poly_trim(f)
    if not f:
        raise ValueError("content is undefined for the zero polynomial")
    return abs(_reduce(gcd, f, 0))


def prim_part(f: List[int]) -> List[int]:
    """Primitive part: f divided by its content (so gcd of coeffs becomes 1)."""
    c = content(f)
    return poly_trim([a // c for a in poly_trim(f)])


def padic_val_int(p: int, n: int) -> int:
    """p-adic valuation v_p(n) for a nonzero integer n."""
    if n == 0:
        raise ValueError("v_p(0) is undefined")
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def reduce_mod_p(p: int, f: List[int]) -> List[int]:
    """Coefficientwise reduction of f modulo p, as residues in {0,...,p-1}."""
    return poly_trim([a % p for a in poly_trim(f)])


def trailing_degree(g: List[int]) -> int:
    """Index of the lowest-order nonzero coefficient; 0 for the zero polynomial."""
    g = poly_trim(g)
    if not g:
        return 0
    for i, a in enumerate(g):
        if a != 0:
            return i
    return 0


# --------------------------------------------------------------------------- #
# The two Iwasawa invariants                                                    #
# --------------------------------------------------------------------------- #

def mu_inv(p: int, f: List[int]) -> int:
    """mu_p(f) = v_p(content(f))."""
    return padic_val_int(p, content(f))


def lambda_inv(p: int, f: List[int]) -> int:
    """lambda_p(f) = trailing degree of the mod-p reduction of primPart(f)."""
    return trailing_degree(reduce_mod_p(p, prim_part(f)))


# --------------------------------------------------------------------------- #
# Twist factors                                                                 #
# --------------------------------------------------------------------------- #

def g_twist(p: int, a: int, k: int) -> List[int]:
    """Generalized twist factor p^k * X^a; has (lambda, mu) = (a, k)."""
    return poly_mul(C(p ** k), X_pow(a))


def sharp_twist(p: int, cs: int, k: int) -> List[int]:
    """Sharp twist factor p^k * X^(cs*k)."""
    return g_twist(p, cs * k, k)


def flat_twist(p: int, cf: int, k: int) -> List[int]:
    """Flat twist factor p^k * X^(cf*k)."""
    return g_twist(p, cf * k, k)


# --------------------------------------------------------------------------- #
# Demonstrations                                                                #
# --------------------------------------------------------------------------- #

def demo_additivity() -> None:
    print("=== Additivity of both invariants (the bridge) ===")
    p = 3
    f = poly_mul(C(9), [1, 3, 0, 6])       # content divisible by 3, X-part present
    g = poly_mul(X_pow(2), [2, 0, 3])      # a monomial factor times something
    fg = poly_mul(f, g)
    print(f"  p = {p}")
    print(f"  mu(f)={mu_inv(p, f)}, mu(g)={mu_inv(p, g)}, "
          f"mu(f*g)={mu_inv(p, fg)}  (sum={mu_inv(p, f) + mu_inv(p, g)})")
    print(f"  lam(f)={lambda_inv(p, f)}, lam(g)={lambda_inv(p, g)}, "
          f"lam(f*g)={lambda_inv(p, fg)}  (sum={lambda_inv(p, f) + lambda_inv(p, g)})")
    assert mu_inv(p, fg) == mu_inv(p, f) + mu_inv(p, g)
    assert lambda_inv(p, fg) == lambda_inv(p, f) + lambda_inv(p, g)
    print("  OK: mu and lambda are additive under multiplication.\n")


def demo_building_blocks() -> None:
    print("=== Invariants of the elementary building blocks ===")
    p, k, n = 2, 4, 5
    print(f"  mu(C(p^{k})) = {mu_inv(p, C(p ** k))}  (expected {k})")
    print(f"  lam(C(p^{k})) = {lambda_inv(p, C(p ** k))}  (expected 0)")
    print(f"  mu(X^{n}) = {mu_inv(p, X_pow(n))}  (expected 0)")
    print(f"  lam(X^{n}) = {lambda_inv(p, X_pow(n))}  (expected {n})")
    a = 7
    print(f"  gTwist(a={a}, k={k}): mu={mu_inv(p, g_twist(p, a, k))} (={k}), "
          f"lam={lambda_inv(p, g_twist(p, a, k))} (={a})")
    assert mu_inv(p, C(p ** k)) == k and lambda_inv(p, C(p ** k)) == 0
    assert mu_inv(p, X_pow(n)) == 0 and lambda_inv(p, X_pow(n)) == n
    print("  OK.\n")


def demo_sharp_flat_twist() -> None:
    print("=== Sharp/flat twist: mu-symmetry and mu-proportional lambda-difference ===")
    p, k, cs, cf = 2, 3, 5, 2
    f = [1, 0, 4, 6]  # arbitrary nonzero characteristic element
    st, ft = sharp_twist(p, cs, k), flat_twist(p, cf, k)
    fs, ff = poly_mul(f, st), poly_mul(f, ft)

    mu_sharp, mu_flat = mu_inv(p, fs), mu_inv(p, ff)
    lam_sharp, lam_flat = lambda_inv(p, fs), lambda_inv(p, ff)
    mu_twist = mu_inv(p, st)

    print(f"  p={p}, k={k}, cs={cs}, cf={cf}, base f={f}")
    print(f"  mu(f*sharp)={mu_sharp}, mu(f*flat)={mu_flat}  -> mu-symmetric: "
          f"{mu_sharp == mu_flat}")
    print(f"  lam(f*sharp)={lam_sharp}, lam(f*flat)={lam_flat}")
    diff = lam_sharp - lam_flat
    predicted = (cs - cf) * mu_twist
    print(f"  lambda-difference = {diff}, predicted (cs-cf)*mu = "
          f"({cs}-{cf})*{mu_twist} = {predicted}")
    assert mu_sharp == mu_flat
    assert diff == predicted
    print("  OK: the sharp/flat lambda-difference is exactly (cs-cf)*mu.\n")


def demo_nonvanishing_and_boundary() -> None:
    print("=== Non-vanishing when mu != 0, and vanishing when mu = 0 ===")
    p, cs, cf = 2, 5, 2
    f = [3, 0, 7]
    for k in (0, 1, 2, 3):
        fs = poly_mul(f, sharp_twist(p, cs, k))
        ff = poly_mul(f, flat_twist(p, cf, k))
        diff = lambda_inv(p, fs) - lambda_inv(p, ff)
        status = "vanishes (mu=0)" if k == 0 else "nonzero (mu>0)"
        print(f"  k={k}: lambda-difference = {diff}   [{status}]")
        if k == 0:
            assert diff == 0
        else:
            assert diff != 0
    print("  OK: difference vanishes iff mu = 0 (given cs != cf).\n")


def demo_free_ratio() -> None:
    print("=== The lambda/mu ratio is a free parameter ===")
    p, k = 2, 3
    for a in (4, 7, 10):
        g = g_twist(p, a, k)
        print(f"  gTwist(a={a}, k={k}): (lambda, mu) = "
              f"({lambda_inv(p, g)}, {mu_inv(p, g)})")
    ga, gb = g_twist(p, 7, k), g_twist(p, 4, k)
    assert mu_inv(p, ga) == mu_inv(p, gb)
    assert lambda_inv(p, ga) != lambda_inv(p, gb)
    print("  OK: same mu, different lambda -- the ratio is unconstrained.\n")


def main() -> None:
    demo_additivity()
    demo_building_blocks()
    demo_sharp_flat_twist()
    demo_nonvanishing_and_boundary()
    demo_free_ratio()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
