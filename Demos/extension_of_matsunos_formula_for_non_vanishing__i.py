"""Numerical demonstrations of the additivity of Iwasawa invariants and the
Matsuno-type twist formula.

We model a characteristic element of the Iwasawa algebra by an integer
polynomial, represented as a list of coefficients ``[a0, a1, a2, ...]`` for
``a0 + a1*X + a2*X^2 + ...``.  For a fixed prime ``p`` we compute:

    mu(f)     = v_p(content(f))                    (the mu-invariant)
    lambda(f) = trailing degree of (primPart(f) mod p)   (the lambda-invariant)

and we verify:

    * mu and lambda are additive under polynomial multiplication;
    * the twist factor  twist_{c,k} = p^k * X^{c*k}  satisfies
      mu = k,  lambda = c*k = c*mu;
    * the Matsuno-type twist formula
          lambda(f * twist) = lambda(f) + c * mu(twist),
      with the correction term c*mu nonzero iff c != 0 and mu != 0.

The module is self-contained: run ``python demo.py``.
"""

from __future__ import annotations

from math import gcd
from functools import reduce as _reduce
from typing import List


# --------------------------------------------------------------------------- #
# Polynomial helpers (dense integer coefficient lists)
# --------------------------------------------------------------------------- #
def poly_trim(f: List[int]) -> List[int]:
    """Remove trailing (high-degree) zero coefficients; keep [0] for the zero poly."""
    g = list(f)
    while len(g) > 1 and g[-1] == 0:
        g.pop()
    return g


def poly_mul(f: List[int], g: List[int]) -> List[int]:
    """Multiply two integer polynomials given as coefficient lists."""
    if not f or not g:
        return [0]
    out = [0] * (len(f) + len(g) - 1)
    for i, a in enumerate(f):
        for j, b in enumerate(g):
            out[i + j] += a * b
    return poly_trim(out)


def poly_is_zero(f: List[int]) -> bool:
    return all(c == 0 for c in f)


# --------------------------------------------------------------------------- #
# p-adic valuation and content / primitive part
# --------------------------------------------------------------------------- #
def padic_val_int(p: int, n: int) -> int:
    """Exact power of the prime ``p`` dividing the nonzero integer ``n``."""
    if n == 0:
        raise ValueError("p-adic valuation of 0 is undefined here")
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def content(f: List[int]) -> int:
    """Content: the (nonnegative) gcd of the coefficients of a nonzero poly."""
    return _reduce(gcd, (abs(c) for c in f), 0)


def primitive_part(f: List[int]) -> List[int]:
    """Primitive part f / content(f)."""
    c = content(f)
    if c == 0:
        raise ValueError("primitive part of the zero polynomial is undefined")
    return [a // c for a in f]


# --------------------------------------------------------------------------- #
# The two Iwasawa invariants
# --------------------------------------------------------------------------- #
def mu_invariant(p: int, f: List[int]) -> int:
    """mu_p(f) = v_p(content(f))."""
    if poly_is_zero(f):
        raise ValueError("mu-invariant of the zero polynomial is undefined")
    return padic_val_int(p, content(f))


def lambda_invariant(p: int, f: List[int]) -> int:
    """lambda_p(f) = trailing degree of (primitive part of f) reduced mod p."""
    if poly_is_zero(f):
        raise ValueError("lambda-invariant of the zero polynomial is undefined")
    pp = primitive_part(f)
    for i, a in enumerate(pp):
        if a % p != 0:
            return i
    # Unreachable: a primitive polynomial cannot vanish identically mod p.
    raise RuntimeError("primitive part reduced to 0 mod p (should be impossible)")


# --------------------------------------------------------------------------- #
# The modelled quadratic-twist factor  twist_{c,k} = p^k * X^{c*k}
# --------------------------------------------------------------------------- #
def twist_factor(p: int, c: int, k: int) -> List[int]:
    """p^k * X^(c*k) as a coefficient list."""
    deg = c * k
    coeffs = [0] * (deg + 1)
    coeffs[deg] = p ** k
    return coeffs


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_additivity(p: int, f: List[int], g: List[int]) -> None:
    fg = poly_mul(f, g)
    mf, mg, mfg = mu_invariant(p, f), mu_invariant(p, g), mu_invariant(p, fg)
    lf, lg, lfg = lambda_invariant(p, f), lambda_invariant(p, g), lambda_invariant(p, fg)
    print(f"  f = {f},  g = {g}")
    print(f"  mu(f)={mf}, mu(g)={mg}, mu(f*g)={mfg}  ->  mf+mg={mf+mg}  "
          f"[{'OK' if mfg == mf + mg else 'FAIL'}]")
    print(f"  la(f)={lf}, la(g)={lg}, la(f*g)={lfg}  ->  lf+lg={lf+lg}  "
          f"[{'OK' if lfg == lf + lg else 'FAIL'}]")
    assert mfg == mf + mg and lfg == lf + lg


def demo_twist(p: int, f: List[int], c: int, k: int) -> None:
    tw = twist_factor(p, c, k)
    mu_tw = mu_invariant(p, tw)
    la_tw = lambda_invariant(p, tw)
    ftw = poly_mul(f, tw)
    lhs = lambda_invariant(p, ftw)
    rhs = lambda_invariant(p, f) + c * mu_tw
    correction = c * mu_tw
    print(f"  twist_(c={c},k={k}) = p^{k} * X^{c*k}:  mu={mu_tw}, lambda={la_tw} "
          f"(check lambda == c*mu: {la_tw == c * mu_tw})")
    print(f"  lambda(f*twist)={lhs},  lambda(f)+c*mu(twist)={rhs}  "
          f"[{'OK' if lhs == rhs else 'FAIL'}]")
    print(f"  correction term c*mu = {correction}  ->  nonzero: {correction != 0} "
          f"(expected {c != 0 and mu_tw != 0})")
    assert lhs == rhs
    assert (correction != 0) == (c != 0 and mu_tw != 0)


def main() -> None:
    p = 2  # good supersingular prime in the motivating setting
    print("=" * 64)
    print(f"Iwasawa invariants over Z[X], prime p = {p}")
    print("=" * 64)

    print("\n[1] Additivity of mu and lambda under multiplication")
    # f = 4 + 2X + 6X^2 (content 2), g = 3X + 3X^2 (content 3, trailing deg 1)
    demo_additivity(p, [4, 2, 6], [0, 3, 3])
    demo_additivity(p, [0, 0, 8, 4], [1, 0, 2])   # extra example
    demo_additivity(p, [2, 4, 2], [0, 1])         # multiply by X

    print("\n[2] Invariants of the twist factor and the Matsuno-type formula")
    f = [1, 0, 3, 5]  # primitive; mu=0, lambda=0
    print(f"  base f = {f}: mu={mu_invariant(p, f)}, lambda={lambda_invariant(p, f)}")
    print("  -- mu = 0 case: correction vanishes --")
    demo_twist(p, f, c=3, k=0)
    print("  -- mu != 0 case: correction is FORCED to appear --")
    demo_twist(p, f, c=3, k=2)
    demo_twist(p, f, c=1, k=4)
    demo_twist(p, f, c=5, k=1)

    print("\n[3] Non-vanishing summary (correction = c * k)")
    for c in range(0, 4):
        for k in range(0, 4):
            corr = c * k
            print(f"    c={c}, k=mu(twist)={k}: correction={corr:<3} "
                  f"nonzero={corr != 0} (c!=0 and mu!=0 = {c != 0 and k != 0})")

    print("\nAll checks passed.")


if __name__ == "__main__":
    main()
