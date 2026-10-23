#!/usr/bin/env python3
"""
q-Factorials, Gaussian binomials and their cyclotomic carry factorisation.

A self-contained numerical companion (pure Python, no third-party packages).

Polynomials in q with integer coefficients are represented as lists of ints,
lowest degree first:  [1, 1, 1]  ==  1 + q + q^2.

What is demonstrated
--------------------
1. The division-free q-factorial product formula
       [k]_q! * [n-k]_q! * binom(n,k)_q  =  [n]_q!         (0 <= k <= n)
   where the Gaussian binomial is defined *only* by the q-Pascal recursion.
2. Specialisation q = 1 gives  k! (n-k)! C(n,k) = n!.
3. [n]_q! is monic of degree C(n,2); (q;q)_n = (1-q)^n [n]_q!.
4. Uniqueness: exact division of [n]_q! by [k]_q![n-k]_q! returns binom(n,k)_q.
5. Cyclotomic factorisation  [n]_q! = prod_{d=2}^n Phi_d(q)^{floor(n/d)}.
6. Carry factorisation  binom(n,k)_q = prod_{2<=d<=n, carry at d} Phi_d(q),
   with every exponent 0 or 1 (squarefree), and Phi_n | binom(n,k)_q for 0<k<n.
7. The q = 1 shadows: a Legendre-type product for n! and a Kummer-type product
   for C(n,k); plus a numerical check of Kummer's theorem (stated as an open
   direction in the paper -- here only tested, not proved).
"""

from __future__ import annotations

from functools import lru_cache
from math import comb, factorial
from typing import Dict, List, Tuple

Poly = List[int]


# ----------------------------------------------------------------------------
# Basic integer-polynomial arithmetic
# ----------------------------------------------------------------------------

def trim(p: Poly) -> Poly:
    """Remove trailing zero coefficients (the zero polynomial is [])."""
    p = list(p)
    while p and p[-1] == 0:
        p.pop()
    return p


def add(p: Poly, r: Poly) -> Poly:
    n = max(len(p), len(r))
    return trim([(p[i] if i < len(p) else 0) + (r[i] if i < len(r) else 0) for i in range(n)])


def mul(p: Poly, r: Poly) -> Poly:
    if not p or not r:
        return []
    out = [0] * (len(p) + len(r) - 1)
    for i, a in enumerate(p):
        if a:
            for j, b in enumerate(r):
                out[i + j] += a * b
    return trim(out)


def shift(p: Poly, s: int) -> Poly:
    """Multiply by q^s."""
    return trim([0] * s + list(p)) if p else []


def power(p: Poly, e: int) -> Poly:
    out: Poly = [1]
    for _ in range(e):
        out = mul(out, p)
    return out


def divmod_poly(p: Poly, d: Poly) -> Tuple[Poly, Poly]:
    """Long division by a monic polynomial d (exact over the integers)."""
    p, d = trim(p), trim(d)
    assert d and d[-1] == 1, "divisor must be monic"
    rem = list(p)
    quo = [0] * max(len(p) - len(d) + 1, 1)
    for i in range(len(p) - len(d), -1, -1):
        c = rem[i + len(d) - 1]
        quo[i] = c
        if c:
            for j, b in enumerate(d):
                rem[i + j] -= c * b
    return trim(quo), trim(rem)


def evaluate(p: Poly, x: int) -> int:
    acc = 0
    for c in reversed(p):
        acc = acc * x + c
    return acc


def fmt(p: Poly) -> str:
    if not p:
        return "0"
    terms = []
    for i, c in enumerate(p):
        if c == 0:
            continue
        mono = "" if i == 0 else ("q" if i == 1 else f"q^{i}")
        coef = str(c) if (c != 1 or i == 0) else ""
        if c == -1 and i > 0:
            coef = "-"
        terms.append(f"{coef}{mono}")
    return " + ".join(terms).replace("+ -", "- ")


# ----------------------------------------------------------------------------
# q-integers, q-factorials, Gaussian binomials
# ----------------------------------------------------------------------------

def q_int(n: int) -> Poly:
    """[n]_q = 1 + q + ... + q^{n-1}  ([0]_q = 0)."""
    return [1] * n


def q_factorial(n: int) -> Poly:
    """[n]_q! = [1]_q [2]_q ... [n]_q."""
    out: Poly = [1]
    for i in range(1, n + 1):
        out = mul(out, q_int(i))
    return out


@lru_cache(maxsize=None)
def _q_binom(n: int, k: int) -> Tuple[int, ...]:
    """Gaussian binomial via the q-Pascal recursion ONLY (no division):
       binom(n,0) = 1, binom(0,k+1) = 0,
       binom(n+1,k+1) = binom(n,k) + q^{k+1} binom(n,k+1)."""
    if k == 0:
        return (1,)
    if n == 0:
        return ()
    return tuple(add(list(_q_binom(n - 1, k - 1)), shift(list(_q_binom(n - 1, k)), k)))


def q_binom(n: int, k: int) -> Poly:
    return list(_q_binom(n, k))


# ----------------------------------------------------------------------------
# Cyclotomic polynomials and carries
# ----------------------------------------------------------------------------

@lru_cache(maxsize=None)
def _cyclotomic(d: int) -> Tuple[int, ...]:
    """Phi_d via  q^d - 1 = prod_{e | d} Phi_e(q)."""
    num: Poly = [-1] + [0] * (d - 1) + [1]
    for e in range(1, d):
        if d % e == 0:
            num, r = divmod_poly(num, list(_cyclotomic(e)))
            assert not r
    return tuple(num)


def cyclotomic(d: int) -> Poly:
    return list(_cyclotomic(d))


def carry(n: int, k: int, d: int) -> bool:
    """Does adding k and n-k in base d carry out of the units digit?"""
    return k % d + (n - k) % d >= d


def carry_set(n: int, k: int) -> List[int]:
    return [d for d in range(2, n + 1) if carry(n, k, d)]


def factorial_exponents(n: int) -> Dict[int, int]:
    """Exponent of Phi_d in [n]_q!  is floor(n/d)."""
    return {d: n // d for d in range(2, n + 1) if n // d}


def legendre_valuation(n: int, k: int, p: int) -> int:
    """p-adic valuation of C(n,k), computed directly."""
    c, v = comb(n, k), 0
    while c % p == 0:
        c //= p
        v += 1
    return v


def is_prime(p: int) -> bool:
    return p >= 2 and all(p % i for i in range(2, int(p ** 0.5) + 1))


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_product_formula(N: int = 14) -> None:
    print("1. Division-free product formula  [k]! [n-k]! binom(n,k) = [n]!")
    checked = 0
    for n in range(N + 1):
        for k in range(n + 1):
            lhs = mul(mul(q_factorial(k), q_factorial(n - k)), q_binom(n, k))
            assert lhs == q_factorial(n), (n, k)
            checked += 1
    print(f"   verified for all {checked} pairs 0 <= k <= n <= {N}")
    print(f"   e.g. binom(4,2)_q = {fmt(q_binom(4, 2))}")
    print(f"        [2]! [2]! binom(4,2) = {fmt(mul(mul(q_factorial(2), q_factorial(2)), q_binom(4, 2)))}")
    print(f"        [4]!                 = {fmt(q_factorial(4))}\n")


def demo_q_equals_one(N: int = 14) -> None:
    print("2. At q = 1 the formula becomes k!(n-k)!C(n,k) = n!")
    for n in range(N + 1):
        assert evaluate(q_factorial(n), 1) == factorial(n)
        for k in range(n + 1):
            assert evaluate(q_binom(n, k), 1) == comb(n, k)
    print(f"   [n]_1! = n! and binom(n,k)_1 = C(n,k) for n <= {N}\n")


def demo_degree_and_pochhammer(N: int = 12) -> None:
    print("3. [n]_q! is monic of degree C(n,2);  (q;q)_n = (1-q)^n [n]_q!")
    for n in range(N + 1):
        f = q_factorial(n)
        assert f[-1] == 1 and len(f) - 1 == comb(n, 2)
        poch: Poly = [1]
        for i in range(1, n + 1):
            poch = mul(poch, add([1], shift([-1], i)))   # (1 - q^i)
        assert poch == mul(power([1, -1], n), f)
    print("   n : degree of [n]!   (Mahonian row = coefficients)")
    for n in range(1, 6):
        print(f"   {n} : {comb(n, 2):3d}   {q_factorial(n)}")
    print()


def demo_uniqueness(N: int = 12) -> None:
    print("4. Uniqueness: [n]! / ([k]! [n-k]!) is exact and equals binom(n,k)")
    for n in range(N + 1):
        for k in range(n + 1):
            quo, rem = divmod_poly(q_factorial(n), mul(q_factorial(k), q_factorial(n - k)))
            assert not rem and quo == q_binom(n, k)
    print(f"   exact division reproduces the recursive binom for n <= {N}\n")


def demo_cyclotomic_factorial(N: int = 14) -> None:
    print("5. [n]_q! = prod_{d=2}^n Phi_d(q)^floor(n/d)")
    for n in range(N + 1):
        prod: Poly = [1]
        for d, e in factorial_exponents(n).items():
            prod = mul(prod, power(cyclotomic(d), e))
        assert prod == q_factorial(n)
    n = 6
    print("   [6]_q! = " + " * ".join(f"Phi_{d}^{e}" if e > 1 else f"Phi_{d}"
                                     for d, e in factorial_exponents(n).items()))
    for d in range(2, 7):
        print(f"      Phi_{d} = {fmt(cyclotomic(d))}")
    print()


def demo_carry_factorisation(N: int = 16) -> None:
    print("6. binom(n,k)_q = product of Phi_d over carry moduli d (squarefree)")
    for n in range(N + 1):
        for k in range(n + 1):
            prod: Poly = [1]
            for d in carry_set(n, k):
                prod = mul(prod, cyclotomic(d))
            assert prod == q_binom(n, k), (n, k)
            for d in range(2, n + 1):
                e = n // d - k // d - (n - k) // d
                assert e == (1 if carry(n, k, d) else 0)
            if 0 < k < n:
                _, rem = divmod_poly(q_binom(n, k), cyclotomic(n))
                assert not rem
    for (n, k) in [(6, 2), (8, 3), (10, 4), (12, 6)]:
        cs = carry_set(n, k)
        print(f"   binom({n},{k})_q = " + " * ".join(f"Phi_{d}" for d in cs)
              + f"    (carry moduli {cs})")
    print(f"   verified for all 0 <= k <= n <= {N}; Phi_n divides every interior binom(n,k)\n")


def demo_integer_shadows(N: int = 40) -> None:
    print("7. q = 1 shadows: Phi_d(1) = p if d = p^a, else 1")
    for n in range(N + 1):
        prod = 1
        for d in range(2, n + 1):
            prod *= evaluate(cyclotomic(d), 1) ** (n // d)
        assert prod == factorial(n)
        for k in range(n + 1):
            pk = 1
            for d in carry_set(n, k):
                pk *= evaluate(cyclotomic(d), 1)
            assert pk == comb(n, k)
    print(f"   n! = prod Phi_d(1)^floor(n/d) and C(n,k) = prod_carry Phi_d(1) for n <= {N}")
    n, k = 10, 4
    factors = [(d, evaluate(cyclotomic(d), 1)) for d in carry_set(n, k)]
    print(f"   C(10,4) = 210 = " + " * ".join(f"Phi_{d}(1)={v}" for d, v in factors))
    # Kummer's theorem (open direction): numerical test only.
    for n in range(N + 1):
        for k in range(n + 1):
            for p in [2, 3, 5, 7]:
                count = sum(1 for d in carry_set(n, k)
                            if any(p ** a == d for a in range(1, 8)))
                assert count == legendre_valuation(n, k, p)
    print(f"   Kummer: v_p(C(n,k)) = #carry moduli that are powers of p "
          f"(tested n <= {N}, p in 2,3,5,7)\n")


def main() -> None:
    demo_product_formula()
    demo_q_equals_one()
    demo_degree_and_pochhammer()
    demo_uniqueness()
    demo_cyclotomic_factorial()
    demo_carry_factorisation()
    demo_integer_shadows()
    print("All checks passed.")


if __name__ == "__main__":
    main()
