"""Numerical demonstration of the q-analogue of Kummer's theorem.

Everything in this file is self-contained: the q-integers, the q-factorial, the
Gaussian binomial coefficient defined by the q-Pascal recursion, the period /
offset data attached to a prime, and the exact valuation, congruence, counting
and extremal statements that the theory predicts.

Notation used throughout
------------------------
    [m]_q      = 1 + q + ... + q^(m-1)                 (a q-integer)
    [n]_q!     = [1]_q [2]_q ... [n]_q                 (the q-factorial)
    C_q(n,k)   = Gaussian binomial coefficient, defined by
                 C_q(n,0) = 1, C_q(0,k+1) = 0,
                 C_q(n+1,k+1) = C_q(n,k) + q^(k+1) C_q(n,k+1)
    D(q,l)     = multiplicative order of q mod l (mod 4 when l = 2)
    E(q,l)     = v_l([D]_q)

Main formula (the q-Kummer theorem).  For a prime l not dividing q >= 2 and
k <= n, writing c = 1 if k % D + (n-k) % D >= D and c = 0 otherwise,

    v_l(C_q(n,k)) = E*c + v_l(C(n//D, k//D)) + c * v_l((n-k)//D + 1).

Run with:  python3 demo.py
"""

from __future__ import annotations

from math import comb
from typing import Dict, List, Tuple

# ---------------------------------------------------------------------------
# q-arithmetic
# ---------------------------------------------------------------------------


def q_int(q: int, m: int) -> int:
    """The q-integer [m]_q = 1 + q + ... + q^(m-1)."""
    return sum(q ** i for i in range(m))


def q_factorial(q: int, n: int) -> int:
    """The q-factorial [n]_q! = [1]_q [2]_q ... [n]_q."""
    out = 1
    for m in range(1, n + 1):
        out *= q_int(q, m)
    return out


def q_binom(q: int, n: int, k: int) -> int:
    """Gaussian binomial coefficient via the q-Pascal recursion (exact integer)."""
    if k < 0 or k > n:
        return 0
    row: List[int] = [1] + [0] * n  # row 0 of the q-Pascal triangle
    for i in range(1, n + 1):
        new = [1] + [0] * n
        for j in range(1, i + 1):
            new[j] = row[j - 1] + (q ** j) * row[j]
        row = new
    return row[k]


def q_binom_by_division(q: int, n: int, k: int) -> int:
    """C_q(n,k) as the exact quotient [n]_q! / ([k]_q! [n-k]_q!)."""
    num = q_factorial(q, n)
    den = q_factorial(q, k) * q_factorial(q, n - k)
    assert num % den == 0, "the division is exact"
    return num // den


# ---------------------------------------------------------------------------
# valuations, orders, periods
# ---------------------------------------------------------------------------


def val(l: int, a: int) -> int:
    """l-adic valuation of a positive integer a."""
    assert a > 0
    e = 0
    while a % l == 0:
        a //= l
        e += 1
    return e


def mult_order(a: int, m: int) -> int:
    """Multiplicative order of a modulo m (requires gcd(a, m) = 1)."""
    a %= m
    d, x = 1, a % m
    while x != 1:
        x = (x * a) % m
        d += 1
    return d


def q_period(q: int, l: int) -> int:
    """The period D(q,l): order of q mod l, except mod 4 when l = 2."""
    return mult_order(q, 4) if l == 2 else mult_order(q, l)


def q_offset(q: int, l: int) -> int:
    """The offset E(q,l) = v_l([D]_q)."""
    return val(l, q_int(q, q_period(q, l)))


# ---------------------------------------------------------------------------
# the q-Kummer prediction
# ---------------------------------------------------------------------------


def q_kummer_prediction(q: int, l: int, n: int, k: int) -> int:
    """Predicted v_l(C_q(n,k)) from the q-Kummer formula."""
    D, E = q_period(q, l), q_offset(q, l)
    c = 1 if (k % D) + ((n - k) % D) >= D else 0
    out = E * c + val(l, comb(n // D, k // D))
    if c:
        out += val(l, (n - k) // D + 1)
    return out


def carries_base(a: int, b: int, base: int) -> int:
    """Number of carries when adding a and b in the given base."""
    carry, count = 0, 0
    while a > 0 or b > 0 or carry:
        s = a % base + b % base + carry
        carry = 1 if s >= base else 0
        count += carry
        a //= base
        b //= base
        if a == 0 and b == 0 and carry == 0:
            break
    return count


def q_kummer_carry_form(q: int, l: int, n: int, k: int) -> int:
    """Fully combinatorial form: base-D carry, then base-l carries."""
    D, E = q_period(q, l), q_offset(q, l)
    c = 1 if (k % D) + ((n - k) % D) >= D else 0
    out = E * c + carries_base(k // D, n // D - k // D, l)
    if c:
        out += val(l, (n - k) // D + 1)
    return out


# ---------------------------------------------------------------------------
# demonstrations
# ---------------------------------------------------------------------------


def demo_headline() -> None:
    print("=" * 72)
    print("1.  The headline instance:  C_2(6,3) = 1395 = 3^2 * 5 * 31")
    print("=" * 72)
    v = q_binom(2, 6, 3)
    print(f"    C_2(6,3)                       = {v}")
    print(f"    exact quotient of q-factorials = {q_binom_by_division(2, 6, 3)}")
    for l in (3, 5, 31):
        D, E = q_period(2, l), q_offset(2, l)
        print(
            f"    l = {l:2d}:  D = {D}, E = {E},"
            f"  predicted v_l = {q_kummer_prediction(2, l, 6, 3)},"
            f"  true v_l = {val(l, v)}"
        )
    print("    Note v_5 = 1: the base-4 addition 3 + 3 carries and contributes E = 1,")
    print("    while the block coefficient C(1,0) = 1 contributes nothing.")


def demo_valuation_sweep() -> None:
    print()
    print("=" * 72)
    print("2.  The q-Kummer formula against brute force")
    print("=" * 72)
    checked = 0
    for q in (2, 3, 4, 5, 7):
        for l in (2, 3, 5, 7, 11):
            if q % l == 0:
                continue
            for n in range(0, 17):
                for k in range(0, n + 1):
                    true = val(l, q_binom(q, n, k))
                    pred = q_kummer_prediction(q, l, n, k)
                    carr = q_kummer_carry_form(q, l, n, k)
                    assert true == pred == carr, (q, l, n, k, true, pred, carr)
                    checked += 1
    print(f"    {checked} instances verified: valuation = prediction = carry form.")
    print("    (q in {2,3,4,5,7}, l in {2,3,5,7,11}, n <= 16, all k.)")


def demo_two_adic() -> None:
    print()
    print("=" * 72)
    print("3.  The prime 2: why the order mod 2 must be replaced by the order mod 4")
    print("=" * 72)
    print(f"    q = 3:  [2]_3 = {q_int(3, 2)} = 2^2, so v_2([2]_3) = {val(2, q_int(3, 2))}")
    print("    The naive recipe D = ord_2(3) = 1 predicts v_2([m]_3) = v_2(m), i.e. 1.")
    print(f"    Correct period: ord_4(3) = {q_period(3, 2)}, offset E = {q_offset(3, 2)}.")
    print(
        f"    v_2(C_3(2,1)) = {val(2, q_binom(3, 2, 1))} "
        f"(naive prediction from C(2,1): {val(2, comb(2, 1))}); "
        f"repaired prediction = {q_kummer_prediction(3, 2, 2, 1)}"
    )


def demo_lucas() -> None:
    print()
    print("=" * 72)
    print("4.  The q-Lucas congruence  C_q(n,k) = C(n//D, k//D) * C_q(n%D, k%D)  (mod l)")
    print("=" * 72)
    for (q, l, n, k) in [(2, 5, 9, 5), (2, 5, 6, 3), (2, 3, 13, 6)]:
        D = mult_order(q, l)
        lhs = q_binom(q, n, k) % l
        rhs = (comb(n // D, k // D) * q_binom(q, n % D, k % D)) % l
        print(
            f"    q={q}, l={l}, D={D}, n={n}, k={k}:  "
            f"C_q(n,k) mod l = {lhs}, Lucas product mod l = {rhs}, "
            f"C_q(n,k) = {q_binom(q, n, k)}"
        )
        assert lhs == rhs
    bad = 0
    for q in (2, 3, 5):
        for l in (2, 3, 7, 11):
            if q % l == 0:
                continue
            D = mult_order(q, l)
            for n in range(0, 22):
                for k in range(0, n + 1):
                    lhs = q_binom(q, n, k) % l
                    rhs = (comb(n // D, k // D) * q_binom(q, n % D, k % D)) % l
                    bad += lhs != rhs
    print(f"    exhaustive re-check up to n = 21: {bad} discrepancies.")


def demo_row_counts() -> None:
    print()
    print("=" * 72)
    print("5.  Row counts:  #{k <= n : l does not divide C_q(n,k)}")
    print("=" * 72)
    q, l = 2, 5
    D = mult_order(q, l)
    print(f"    q = {q}, l = {l}, D = ord_l(q) = {D}")
    print("      n    actual   (n%D+1)*prod(digits+1)   full row?")
    for n in range(0, 25):
        actual = sum(1 for k in range(n + 1) if q_binom(q, n, k) % l != 0)
        N = n // D
        digits: List[int] = []
        M = N
        while M:
            digits.append(M % l)
            M //= l
        pred = (n % D + 1)
        for t in digits:
            pred *= t + 1
        full = actual == n + 1
        print(f"    {n:3d}    {actual:5d}         {pred:8d}              {full}")
        assert actual == pred
    print("    Full rows occur exactly when n+1 <= D or n+1 = D*c*l^t with 1 <= c <= l.")


def demo_total_count() -> None:
    print()
    print("=" * 72)
    print("6.  Self-similar total count over the first D*l^m rows")
    print("=" * 72)
    for (q, l, m) in [(2, 5, 1), (2, 3, 2), (3, 5, 1), (2, 7, 1)]:
        D = mult_order(q, l)
        total = 0
        for n in range(D * l ** m):
            total += sum(1 for k in range(n + 1) if q_binom(q, n, k) % l != 0)
        pred = (D * (D + 1) // 2) * (l * (l + 1) // 2) ** m
        print(
            f"    q={q}, l={l}, D={D}, m={m}: rows < {D * l ** m:4d}  "
            f"total = {total:8d}   (D(D+1)/2)(l(l+1)/2)^m = {pred:8d}"
        )
        assert total == pred


def demo_sharpness() -> None:
    print()
    print("=" * 72)
    print("7.  Sharpness:  v_l(C_q(D*l^s, D+1)) = E + s")
    print("=" * 72)
    for (q, l) in [(2, 5), (2, 3), (3, 7)]:
        D, E = q_period(q, l), q_offset(q, l)
        if D < 2:
            continue
        for s in (1, 2):
            n, k = D * l ** s, D + 1
            true = val(l, q_binom(q, n, k))
            print(
                f"    q={q}, l={l}, D={D}, E={E}, s={s}: "
                f"n={n:4d}, k={k}, v_l = {true}, E+s = {E + s}"
            )
            assert true == E + s


def demo_subspaces() -> None:
    print()
    print("=" * 72)
    print("8.  Counting subspaces of a finite vector space")
    print("=" * 72)
    q, n, k = 2, 6, 3
    prod_num = 1
    prod_den = 1
    for i in range(k):
        prod_num *= q ** n - q ** i
        prod_den *= q ** k - q ** i
    geometric = prod_num // prod_den
    print(f"    number of {k}-dimensional subspaces of F_{q}^{n} = {geometric}")
    print(f"    q-Pascal coefficient C_{q}({n},{k})                  = {q_binom(q, n, k)}")
    assert geometric == q_binom(q, n, k)
    for l in (3, 5, 31):
        print(
            f"    v_{l} of the subspace count = {val(l, geometric)}"
            f"  (q-Kummer prediction {q_kummer_prediction(q, l, n, k)})"
        )


def demo_triangle_picture() -> None:
    print()
    print("=" * 72)
    print("9.  The q-Pascal triangle mod l is a dilated classical triangle")
    print("=" * 72)
    q, l = 2, 5
    D = mult_order(q, l)
    print(f"    q = {q}, l = {l}, D = {D}.  '#' = not divisible by l, '.' = divisible")
    for n in range(0, 21):
        line = "".join(
            "#" if q_binom(q, n, k) % l != 0 else "." for k in range(n + 1)
        )
        print(f"    {n:3d} | {line}")
    print("    Each classical Sierpinski cell is inflated into a D x D triangular block.")


def main() -> None:
    demo_headline()
    demo_valuation_sweep()
    demo_two_adic()
    demo_lucas()
    demo_row_counts()
    demo_total_count()
    demo_sharpness()
    demo_subspaces()
    demo_triangle_picture()
    print()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
