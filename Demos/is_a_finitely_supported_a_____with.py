"""
Numerical demonstration of the head-coefficient theory of normalised eta quotients.

Setting
-------
Let ``a : N -> Z`` be a finitely supported exponent vector and

    eta_a(tau) = prod_k eta(k tau)^{a_k},      eta(tau) = q^{1/24} prod_n (1 - q^n).

The vector is *admissible* when  sum_k k * a_k = 24; then

    eta_a = q * prod_m (1 - q^m)^{b_m},        b_m = sum_{k | m} a_k,

so the normalised quotient

    F_a(q) = q / eta_a = prod_m (1 - q^m)^{-b_m} = sum_{n >= 0} A_n q^n

has A_0 = 1, and in the Hauptmodul normal form 1/eta_a = q^{-1} + c(0) + c(1) q + ...
one has c(n-1) = A_n.

Results demonstrated
--------------------
1.  Head coefficient       c(1) = a_1 (a_1 + 3) / 2 + a_2
2.  Constant term          c(0) = a_1
3.  Second coefficient     c(2) = a_1(a_1+1)(a_1+2)/6 + a_1(a_1+a_2) + a_1 + a_3
4.  Stability              [q^n] F^{(N)} independent of the truncation N >= n
5.  Heisenberg cocycle     c(1)(a+a') = c(1)(a) + c(1)(a') + a_1 a'_1
    and the matrix bridge  M(a + a') = M(a) M(a') into the Heisenberg group
6.  Recursion              n A_n = sum_{i<n} A_i sigma_b(n-i),  sigma_b(j) = sum_{m|j} m b_m
7.  Positivity             b >= 0 and b_1 >= 1  =>  A_n >= 1  for all n
8.  Congruence             d | b_m for all m and gcd(d,n) = 1  =>  d | A_n
                           (for 1/Delta: 24 | A_n whenever gcd(n,24) = 1, and
                            A_2 = 324 shows the coprimality cannot be dropped)
9.  Diophantine test       c is a pure (a_2 = 0) head coefficient  <=>  8c + 9 is a square
10. Surjectivity           every integer is the head coefficient of an admissible vector

Run with:  python3 demo.py
"""

from __future__ import annotations

from math import comb, gcd, isqrt
from typing import Dict, List, Tuple

Vector = Dict[int, int]  # sparse exponent vector a : index k -> a_k (k >= 1)


# ---------------------------------------------------------------------------
# Basic data attached to an exponent vector
# ---------------------------------------------------------------------------

def a_of(a: Vector, k: int) -> int:
    """The exponent a_k (zero outside the support)."""
    return a.get(k, 0)


def weight(a: Vector) -> int:
    """The admissibility weight  sum_k k * a_k  (equals 24 for admissible vectors)."""
    return sum(k * v for k, v in a.items())


def b_coeff(a: Vector, m: int) -> int:
    """Divisor data  b_m = sum_{k | m} a_k."""
    return sum(a_of(a, k) for k in range(1, m + 1) if m % k == 0)


def b_vector(a: Vector, n: int) -> List[int]:
    """[b_0 (unused), b_1, ..., b_n], computed by a sieve over multiples: O(n log n)."""
    b = [0] * (n + 1)
    for k, v in a.items():
        if v == 0 or k < 1:
            continue
        for m in range(k, n + 1, k):
            b[m] += v
    return b


def sigma_b(a: Vector, j: int) -> int:
    """Twisted divisor sum  sigma_b(j) = sum_{m | j} m * b_m."""
    return sum(m * b_coeff(a, m) for m in range(1, j + 1) if j % m == 0)


# ---------------------------------------------------------------------------
# Closed forms proved in the paper
# ---------------------------------------------------------------------------

def head_coeff(a: Vector) -> int:
    """c(1) = a_1 (a_1 + 3) / 2 + a_2.  Exact: n(n+3) is always even."""
    a1, a2 = a_of(a, 1), a_of(a, 2)
    return (a1 * (a1 + 3)) // 2 + a2


def constant_coeff(a: Vector) -> int:
    """c(0) = a_1."""
    return a_of(a, 1)


def second_coeff(a: Vector) -> int:
    """c(2) = a_1(a_1+1)(a_1+2)/6 + a_1(a_1 + a_2) + a_1 + a_3."""
    a1, a2, a3 = a_of(a, 1), a_of(a, 2), a_of(a, 3)
    return (a1 * (a1 + 1) * (a1 + 2)) // 6 + a1 * (a1 + a2) + a1 + a3


def head_matrix(a: Vector) -> Tuple[Tuple[int, int, int], ...]:
    """The unipotent 3x3 matrix M(a) = [[1, a_1, c(1)], [0, 1, a_1], [0, 0, 1]]."""
    a1, h = a_of(a, 1), head_coeff(a)
    return ((1, a1, h), (0, 1, a1), (0, 0, 1))


def mat_mul(
    x: Tuple[Tuple[int, int, int], ...], y: Tuple[Tuple[int, int, int], ...]
) -> Tuple[Tuple[int, int, int], ...]:
    """Ordinary 3x3 integer matrix product."""
    return tuple(
        tuple(sum(x[i][k] * y[k][j] for k in range(3)) for j in range(3)) for i in range(3)
    )


# ---------------------------------------------------------------------------
# Two independent coefficient engines
# ---------------------------------------------------------------------------

def coeffs_by_product(a: Vector, n_max: int, trunc: int | None = None) -> List[int]:
    """
    Coefficients A_0, ..., A_{n_max} of the truncated product
    F^{(N)} = prod_{m=1}^{N} (1 - q^m)^{-b_m}, expanded factor by factor.

    Uses (1-q^m)^{-b} = sum_j C(b+j-1, j) q^{mj} for b >= 0 and the finite
    binomial expansion (1-q^m)^{|b|} for b < 0.  Complexity O(N * n_max) terms.
    """
    n = n_max
    N = n if trunc is None else trunc
    b = b_vector(a, max(N, n))
    poly = [0] * (n + 1)
    poly[0] = 1
    for m in range(1, N + 1):
        e = b[m] if m < len(b) else 0
        if e == 0:
            continue
        # coefficients of (1 - q^m)^{-e} up to degree n, as a list indexed by j
        factor: List[int] = [0] * (n + 1)
        j = 0
        while m * j <= n:
            if e > 0:
                factor[m * j] = comb(e + j - 1, j)
            else:
                factor[m * j] = (-1) ** j * comb(-e, j) if j <= -e else 0
            j += 1
        out = [0] * (n + 1)
        for i, ci in enumerate(poly):
            if ci == 0:
                continue
            for d in range(0, n - i + 1):
                if factor[d]:
                    out[i + d] += ci * factor[d]
        poly = out
    return poly


def coeffs_by_recursion(a: Vector, n_max: int) -> List[int]:
    """
    Coefficients A_0, ..., A_{n_max} from the logarithmic-derivative recursion

        A_0 = 1,     n A_n = sum_{i<n} A_i sigma_b(n-i).

    Sieve the divisor data and the twisted divisor sums (O(n log n)), then run the
    convolution (O(n^2)).  All divisions are exact, so everything stays in Z.
    """
    n = n_max
    b = b_vector(a, n)
    sig = [0] * (n + 1)
    for m in range(1, n + 1):
        if b[m] == 0:
            continue
        for j in range(m, n + 1, m):
            sig[j] += m * b[m]
    A = [0] * (n + 1)
    A[0] = 1
    for k in range(1, n + 1):
        total = sum(A[i] * sig[k - i] for i in range(k))
        assert total % k == 0, "recursion must divide exactly"
        A[k] = total // k
    return A


# ---------------------------------------------------------------------------
# Arithmetic of the head coefficient
# ---------------------------------------------------------------------------

def is_pure_head_coeff(c: int) -> bool:
    """A pure (a_2 = 0) head coefficient is characterised by: 8c + 9 is a square."""
    t = 8 * c + 9
    if t < 0:
        return False
    r = isqrt(t)
    return r * r == t


def admissible_vector_with_head(c: int) -> Vector:
    """a_2 = c, a_3 = 2c - 24, a_4 = 24 - 2c: admissible with head coefficient c."""
    return {2: c, 3: 2 * c - 24, 4: 24 - 2 * c}


# ---------------------------------------------------------------------------
# Demonstration
# ---------------------------------------------------------------------------

DELTA: Vector = {1: 24}          # Delta = eta(tau)^24
ETA2_12: Vector = {2: 12}        # eta(2 tau)^12
MIXED: Vector = {1: 8, 2: 4, 4: 2}   # 1*8 + 2*4 + 4*2 = 24, admissible


def rule(title: str) -> None:
    print("\n" + "=" * 72)
    print(title)
    print("=" * 72)


def demo_head_coefficients() -> None:
    rule("1. Head coefficient  c(1) = a_1(a_1+3)/2 + a_2,  checked against expansion")
    for name, a in [("Delta = eta^24", DELTA), ("eta(2t)^12", ETA2_12),
                    ("eta^8 eta(2t)^4 eta(4t)^2", MIXED)]:
        A = coeffs_by_product(a, 4)
        print(f"  {name:<28} weight = {weight(a):>3}   "
              f"b_1..b_4 = {b_vector(a, 4)[1:]}")
        print(f"      1/eta_a = q^-1 + {A[1]} + {A[2]} q + {A[3]} q^2 + {A[4]} q^3 + ...")
        print(f"      closed forms:   c(0) = {constant_coeff(a)},  "
              f"c(1) = {head_coeff(a)},  c(2) = {second_coeff(a)}")
        assert A[1] == constant_coeff(a)
        assert A[2] == head_coeff(a)
        assert A[3] == second_coeff(a)
        print("      closed forms agree with the expansion.  OK")


def demo_stability() -> None:
    rule("2. Stability: the coefficient of q^n does not depend on the truncation N >= n")
    a = MIXED
    n = 6
    rows = []
    for N in range(n, n + 5):
        rows.append(coeffs_by_product(a, n, trunc=N))
    for N, row in zip(range(n, n + 5), rows):
        print(f"  N = {N:>2}:  A_0..A_{n} = {row}")
    assert all(row == rows[0] for row in rows)
    print("  All truncations of length >= n agree in degrees <= n.  OK")


def demo_cocycle() -> None:
    rule("3. Heisenberg cocycle:  c(1)(a+a') = c(1)(a) + c(1)(a') + a_1 a'_1")
    pairs = [(DELTA, ETA2_12), (MIXED, DELTA), ({1: -3, 2: 5}, {1: 7, 2: -2})]
    for a, ap in pairs:
        s: Vector = {}
        for k in set(a) | set(ap):
            s[k] = a_of(a, k) + a_of(ap, k)
        lhs = head_coeff(s)
        rhs = head_coeff(a) + head_coeff(ap) + a_of(a, 1) * a_of(ap, 1)
        print(f"  a_1 = {a_of(a,1):>4}, a'_1 = {a_of(ap,1):>4}:   "
              f"c(1)(a+a') = {lhs:>6}   =   {head_coeff(a)} + {head_coeff(ap)} "
              f"+ {a_of(a,1)*a_of(ap,1)} = {rhs}")
        assert lhs == rhs
        assert head_matrix(s) == mat_mul(head_matrix(a), head_matrix(ap))
    print("  Cocycle holds, and M(a+a') = M(a) M(a') in the Heisenberg group.  OK")
    print("  (Note the failure of additivity is exactly the bilinear term a_1 a'_1.)")


def demo_recursion() -> None:
    rule("4. Recursion  n A_n = sum_{i<n} A_i sigma_b(n-i)  vs. direct expansion")
    for name, a in [("Delta", DELTA), ("mixed", MIXED)]:
        n = 12
        rec = coeffs_by_recursion(a, n)
        prod = coeffs_by_product(a, n)
        print(f"  {name}:")
        print(f"    sigma_b(1..6) = {[sigma_b(a, j) for j in range(1, 7)]}")
        print(f"    recursion : {rec}")
        print(f"    expansion : {prod}")
        assert rec == prod
    print("  The two independent engines agree in every degree computed.  OK")


def demo_positivity() -> None:
    rule("5. Positivity: b >= 0 and b_1 >= 1 forces every coefficient to be >= 1")
    n = 14
    A = coeffs_by_recursion(DELTA, n)
    b = b_vector(DELTA, n)[1:]
    print(f"  q/Delta has divisor data b_m = {b[0]} for every m (b_1..b_{n} = {b})")
    print(f"  coefficients A_0..A_{n}:")
    for i in range(0, n + 1, 5):
        print("     " + "  ".join(f"A_{j} = {A[j]}" for j in range(i, min(i + 5, n + 1))))
    assert all(x >= 1 for x in A)
    print("  All coefficients are >= 1, as the recursion predicts.  OK")


def demo_congruence() -> None:
    rule("6. Congruence: 24 | A_n whenever gcd(n, 24) = 1 (and not in general)")
    n = 26
    A = coeffs_by_recursion(DELTA, n)
    print(f"  {'n':>3} {'A_n':>16} {'gcd(n,24)':>10} {'24 | A_n':>10}")
    for k in range(1, n + 1):
        g = gcd(k, 24)
        div = (A[k] % 24 == 0)
        flag = "  <-- coprime, divisibility guaranteed" if g == 1 else ""
        print(f"  {k:>3} {A[k]:>16} {g:>10} {str(div):>10}{flag}")
        if g == 1:
            assert div, "theorem violated"
    non_div = [k for k in range(1, n + 1) if A[k] % 24 != 0]
    print(f"  Indices with 24 not dividing A_n: {non_div}")
    print("  Every such index shares a factor with 24, e.g. A_2 = 324 = 24*13 + 12.")
    print("  So the coprimality hypothesis is necessary, not decorative.  OK")
    print("  Combined with positivity: for gcd(n,24) = 1, A_n is a positive multiple")
    print("  of 24, hence A_n >= 24.")


def demo_diophantine() -> None:
    rule("7. Which integers are head coefficients?")
    print("  Pure powers (a_2 = 0): c = n(n+3)/2 for n = -6..8")
    vals = {n: (n * (n + 3)) // 2 for n in range(-6, 9)}
    print("    " + ", ".join(f"n={n}: {v}" for n, v in vals.items()))
    print("  Reflection symmetry n <-> -3-n:")
    for n in range(-6, 3):
        assert vals[n] == vals[-3 - n] if -3 - n in vals else True
    print("    e.g. n = 1 and n = -4 both give c = 2;  n = -1 and n = -2 both give -1.")
    print(f"  Integer minimum is {min(vals.values())} (the real minimum -9/8 is unattainable).")
    attainable = [c for c in range(-3, 20) if is_pure_head_coeff(c)]
    print(f"  Pure head coefficients in [-3, 19]: {attainable}")
    print("    (c is attainable exactly when 8c+9 is a perfect square; c=1 fails: 17.)")
    print("  Allowing a_2 != 0 restores surjectivity, even under admissibility:")
    for c in (-5, 0, 1, 7, 324):
        a = admissible_vector_with_head(c)
        assert weight(a) == 24 and head_coeff(a) == c
        print(f"    c = {c:>4}:  a_2 = {a[2]}, a_3 = {a[3]}, a_4 = {a[4]}   "
              f"(weight {weight(a)}, head coefficient {head_coeff(a)})")
    print("  OK")


def demo_tropical() -> None:
    rule("8. The tropical layer is blind to the head coefficient")
    print("  The q-adic order of F_a is 0 for every a, since F_a has constant term 1;")
    print("  tropically (multiplication = addition of orders) that is the unit.")
    print("    ord F_Delta = 0,  ord F_0 = 0   (identical tropical shadows)")
    print(f"    c(1)(Delta) = {head_coeff(DELTA)},  c(1)(0) = {head_coeff({})}   "
          f"gap = {head_coeff(DELTA) - head_coeff({})}")
    assert head_coeff(DELTA) - head_coeff({}) == 324
    print("  Two exponent vectors, same valuation-theoretic invariant, head coefficients")
    print("  differing by 324.  The tropical layer is strictly coarser.  OK")


def main() -> None:
    print("Head coefficients of normalised eta quotients -- numerical demonstration")
    demo_head_coefficients()
    demo_stability()
    demo_cocycle()
    demo_recursion()
    demo_positivity()
    demo_congruence()
    demo_diophantine()
    demo_tropical()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
