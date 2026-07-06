"""
Numerical demonstration of the finite core of the Rogers-Ramanujan identities.

We work with polynomials in the formal variable q over the integers, represented
as coefficient lists (index = exponent). We implement:

  * Gaussian binomial coefficients  [n choose k]_q   (q-Pascal recurrence)
  * the second q-Pascal rule (as a consistency check)
  * the Schur / Rogers-Ramanujan polynomials  D_n  (q-Fibonacci recurrence)
  * the sum side  S_n = sum_k q^{k^2} [n-k choose k]_q

and verify the finite Rogers-Ramanujan identity  D_n = S_n,  its recurrence, the
Fibonacci specialization  D_n(1) = F_{n+1},  and the diagonal-of-Pascal identity
  sum_k C(n-k, k) = F_{n+1}.

Run:  python3 demo.py
"""

from __future__ import annotations

from typing import List

Poly = List[int]  # coefficient list; index i holds the coefficient of q^i


# ---------------------------------------------------------------------------
# Minimal integer-polynomial arithmetic
# ---------------------------------------------------------------------------

def poly_trim(p: Poly) -> Poly:
    """Remove trailing zero coefficients (keep [] for the zero polynomial)."""
    q = list(p)
    while q and q[-1] == 0:
        q.pop()
    return q


def poly_add(a: Poly, b: Poly) -> Poly:
    """Add two polynomials."""
    n = max(len(a), len(b))
    out = [0] * n
    for i, c in enumerate(a):
        out[i] += c
    for i, c in enumerate(b):
        out[i] += c
    return poly_trim(out)


def poly_shift(p: Poly, e: int) -> Poly:
    """Multiply a polynomial by q^e."""
    if not p:
        return []
    return [0] * e + list(p)


def poly_eval(p: Poly, x: int) -> int:
    """Evaluate a polynomial at an integer point (Horner's method)."""
    acc = 0
    for c in reversed(p):
        acc = acc * x + c
    return acc


def poly_eq(a: Poly, b: Poly) -> bool:
    """Structural equality of polynomials up to trailing zeros."""
    return poly_trim(a) == poly_trim(b)


# ---------------------------------------------------------------------------
# Gaussian binomial coefficients  [n choose k]_q  via the q-Pascal recurrence
# ---------------------------------------------------------------------------

def gauss(n: int, k: int) -> Poly:
    """
    Gaussian binomial coefficient [n choose k]_q as an integer polynomial.

    Defined by:  [n,0] = 1,  [0,k+1] = 0,
                 [n+1,k+1] = [n,k] + q^{k+1} [n,k+1].
    """
    if k == 0:
        return [1]
    if n == 0:
        return []  # zero polynomial
    lower = gauss(n - 1, k - 1)
    upper = poly_shift(gauss(n - 1, k), k)  # q^k * [n-1, k]  (here k = (k-1)+1)
    return poly_add(lower, upper)


# ---------------------------------------------------------------------------
# Schur / Rogers-Ramanujan polynomials  D_n  (q-Fibonacci recurrence)
# ---------------------------------------------------------------------------

def rr_poly(n: int) -> Poly:
    """Schur polynomial D_n:  D_0 = D_1 = 1,  D_{n+2} = D_{n+1} + q^{n+1} D_n."""
    d_prev, d_cur = [1], [1]  # D_0, D_1
    if n == 0:
        return d_prev
    if n == 1:
        return d_cur
    for i in range(n - 1):
        d_next = poly_add(d_cur, poly_shift(d_prev, i + 1))  # D_{i+2}
        d_prev, d_cur = d_cur, d_next
    return d_cur


def rr_sum(n: int) -> Poly:
    """Sum side  S_n = sum_{k=0}^{n} q^{k^2} [n-k choose k]_q."""
    acc: Poly = []
    for k in range(n + 1):
        acc = poly_add(acc, poly_shift(gauss(n - k, k), k * k))
    return acc


# ---------------------------------------------------------------------------
# Fibonacci and ordinary binomials (for the q = 1 shadow)
# ---------------------------------------------------------------------------

def fib(m: int) -> int:
    """Fibonacci numbers with F_1 = F_2 = 1."""
    a, b = 0, 1
    for _ in range(m):
        a, b = b, a + b
    return a  # returns F_m


def binom(n: int, k: int) -> int:
    """Ordinary binomial coefficient C(n, k); 0 if k < 0 or k > n."""
    if k < 0 or k > n:
        return 0
    num = 1
    for i in range(k):
        num = num * (n - i) // (i + 1)
    return num


def poly_str(p: Poly) -> str:
    """Human-readable rendering of a polynomial in q."""
    p = poly_trim(p)
    if not p:
        return "0"
    terms = []
    for i, c in enumerate(p):
        if c == 0:
            continue
        if i == 0:
            terms.append(f"{c}")
        elif i == 1:
            terms.append(f"{c}q" if c != 1 else "q")
        else:
            terms.append(f"{c}q^{i}" if c != 1 else f"q^{i}")
    return " + ".join(terms)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_polynomials(n_max: int = 8) -> None:
    print("=" * 68)
    print("Schur polynomials D_n and the sum side S_n")
    print("=" * 68)
    for n in range(n_max + 1):
        d, s = rr_poly(n), rr_sum(n)
        flag = "OK" if poly_eq(d, s) else "MISMATCH!"
        print(f"  D_{n:<2} = {poly_str(d):<40} [{flag}]")


def demo_finite_identity(n_max: int = 13,
                         points: List[int] = (-3, -2, -1, 0, 2, 3, 5, 7)) -> None:
    print("\n" + "=" * 68)
    print("Finite Rogers-Ramanujan identity  D_n = sum_k q^{k^2} [n-k,k]_q")
    print("checked as polynomials and at integer evaluation points")
    print("=" * 68)
    discrepancies = 0
    for n in range(n_max + 1):
        d, s = rr_poly(n), rr_sum(n)
        if not poly_eq(d, s):
            discrepancies += 1
        for x in points:
            if poly_eval(d, x) != poly_eval(s, x):
                discrepancies += 1
    print(f"  n = 0..{n_max}, q in {list(points)}")
    print(f"  total discrepancies: {discrepancies}")
    assert discrepancies == 0


def demo_second_pascal(n_max: int = 10) -> None:
    print("\n" + "=" * 68)
    print("Second q-Pascal rule  [n+1,k+1] = [n,k+1] + q^{n-k} [n,k]")
    print("=" * 68)
    bad = 0
    for n in range(n_max + 1):
        for k in range(n_max + 1):
            lhs = gauss(n + 1, k + 1)
            rhs = poly_add(gauss(n, k + 1), poly_shift(gauss(n, k), n - k))
            if not poly_eq(lhs, rhs):
                bad += 1
    print(f"  verified for 0 <= n,k <= {n_max}; discrepancies: {bad}")
    assert bad == 0


def demo_fibonacci_bridge(n_max: int = 12) -> None:
    print("\n" + "=" * 68)
    print("Fibonacci bridge:  D_n(1) = F_{n+1}  and  sum_k C(n-k,k) = F_{n+1}")
    print("=" * 68)
    for n in range(n_max + 1):
        d1 = poly_eval(rr_poly(n), 1)
        diag = sum(binom(n - k, k) for k in range(n + 1))
        f = fib(n + 1)
        flag = "OK" if d1 == f == diag else "MISMATCH!"
        print(f"  n = {n:<2}:  D_n(1) = {d1:<4}  diag-sum = {diag:<4}  "
              f"F_{n+1} = {f:<4} [{flag}]")
        assert d1 == f == diag


def main() -> None:
    demo_polynomials()
    demo_finite_identity()
    demo_second_pascal()
    demo_fibonacci_bridge()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
