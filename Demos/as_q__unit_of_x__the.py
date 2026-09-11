"""
Level-k Newton identities for pole-normalized Laurent products
==============================================================

Numerical demonstrations of the results of the paper
"Pole Order, Locality and Newton Recursions for Products of Normalized
q-Series".

Setting
-------
A *normalized* q-series is a formal Laurent series

    f(q) = q^{-1} + a_0 + a_1 q + a_2 q^2 + ...

i.e. a simple pole at q = 0 with residue 1 and no deeper pole.  Every such
series factors as f = q^{-1} u_f with u_f = 1 + a_0 q + a_1 q^2 + ... a unit
of the ring of formal power series.  Consequently a product of m normalized
series has a pole of order exactly m, and its Laurent coefficients

    c_k := [q^{k-m}] prod_{i=1..m} f_i        (k = 0, 1, 2, ...)

are called its *level-k* coefficients.

The results demonstrated here
-----------------------------
1.  Master formula (multi-Cauchy form)

        c_k = sum over nu with sum_i nu_i = k of prod_i [q^{nu_i - 1}] f_i,

    where the convention [q^{-1}] f_i = 1 makes unexcited factors neutral.

2.  Locality:  every surviving exponent vector has support of size <= k, so
    c_k is a universal polynomial in the tails of at most k of the m factors.
    Truncation: c_k depends only on the coefficients a_0, ..., a_{k-1}.

3.  Half locality:  if in addition every factor has vanishing constant term
    (a_0 = 0, the genuine McKay-Thompson normalization) then no exponent can
    equal 1, hence 2 * |support| <= k: at most k/2 factors interact.

4.  Newton recursion

        (k+1) c_{k+1} = sum_{j=0}^{k} c_j p_{k-j},
        p_r := [q^r] sum_i u_i' / u_i,        c_0 = 1.

5.  Specialization to f_i = q^{-1} + a_i recovers the elementary symmetric
    functions and the classical Newton identities
        (k+1) e_{k+1} = sum_{j<=k} (-1)^{k-j} e_j p_{k-j+1}.

6.  Rigidity: the power sums p_0, ..., p_{K-1} determine c_0, ..., c_K,
    independently of the number of factors.

7.  Integrality transfer: integral tails give integral Laurent coefficients.

All arithmetic is exact (fractions / integers).
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Dict, Iterator, List, Sequence, Tuple

Number = Fraction

# ----------------------------------------------------------------------
# Representation
# ----------------------------------------------------------------------
# A normalized series f = q^{-1} + a_0 + a_1 q + ... is stored as its *tail*
# [a_0, a_1, ..., a_{N-1}] (a finite truncation; deeper coefficients are
# irrelevant for the levels we compute, by the truncation theorem).

Tail = List[Number]


def coeff(tail: Tail, n: int) -> Number:
    """Laurent coefficient [q^n] of the normalized series with the given tail."""
    if n == -1:
        return Fraction(1)
    if n < -1:
        return Fraction(0)
    return tail[n] if n < len(tail) else Fraction(0)


def unit_part(tail: Tail, prec: int) -> List[Number]:
    """Power-series coefficients of u_f = q * f = 1 + a_0 q + a_1 q^2 + ...,
    truncated to degree < prec."""
    u = [Fraction(0)] * prec
    u[0] = Fraction(1)
    for n in range(1, prec):
        u[n] = coeff(tail, n - 1)
    return u


def ps_mul(a: Sequence[Number], b: Sequence[Number], prec: int) -> List[Number]:
    """Truncated product of two power series."""
    out = [Fraction(0)] * prec
    for i, ai in enumerate(a[:prec]):
        if ai == 0:
            continue
        for j, bj in enumerate(b[: prec - i]):
            out[i + j] += ai * bj
    return out


def ps_inv(a: Sequence[Number], prec: int) -> List[Number]:
    """Inverse of a power series with invertible constant term."""
    assert a[0] != 0, "constant term must be invertible"
    inv = [Fraction(0)] * prec
    inv[0] = Fraction(1) / a[0]
    for n in range(1, prec):
        acc = Fraction(0)
        for j in range(1, n + 1):
            aj = a[j] if j < len(a) else Fraction(0)
            acc += aj * inv[n - j]
        inv[n] = -acc / a[0]
    return inv


def ps_derivative(a: Sequence[Number]) -> List[Number]:
    """Formal derivative of a power series (degree drops by one)."""
    return [Fraction(n + 1) * a[n + 1] for n in range(len(a) - 1)]


def ps_log_derivative(a: Sequence[Number], prec: int) -> List[Number]:
    """Logarithmic derivative a'/a of a power series with a[0] != 0."""
    return ps_mul(ps_derivative(list(a) + [Fraction(0)]), ps_inv(a, prec), prec)


# ----------------------------------------------------------------------
# 0. Brute-force ground truth
# ----------------------------------------------------------------------

def product_coefficients(tails: Sequence[Tail], prec: int) -> List[Number]:
    """c_0, ..., c_{prec-1} where c_k = [q^{k-m}] prod f_i, computed by
    honest multiplication of the unit power series."""
    acc = [Fraction(1)] + [Fraction(0)] * (prec - 1)
    for t in tails:
        acc = ps_mul(acc, unit_part(t, prec), prec)
    return acc


# ----------------------------------------------------------------------
# 1. Master formula
# ----------------------------------------------------------------------

def compositions(m: int, k: int) -> Iterator[Tuple[int, ...]]:
    """All weak compositions of k into m nonnegative parts."""
    if m == 0:
        if k == 0:
            yield ()
        return
    for first in range(k + 1):
        for rest in compositions(m - 1, k - first):
            yield (first,) + rest


def level_coefficient_master(tails: Sequence[Tail], k: int) -> Number:
    """c_k via the multi-Cauchy master formula."""
    total = Fraction(0)
    for nu in compositions(len(tails), k):
        term = Fraction(1)
        for t, e in zip(tails, nu):
            term *= coeff(t, e - 1)
            if term == 0:
                break
        total += term
    return total


def level_coefficient_local(tails: Sequence[Tail], k: int) -> Number:
    """c_k via the locality decomposition: sum over subsets of size <= k of
    the factors, with all other factors unexcited."""
    m = len(tails)
    total = Fraction(0)
    for size in range(min(k, m) + 1):
        for subset in combinations(range(m), size):
            # exponent vectors supported exactly on `subset`
            for nu in compositions(size, k):
                if any(e == 0 for e in nu):
                    continue
                term = Fraction(1)
                for idx, e in zip(subset, nu):
                    term *= coeff(tails[idx], e - 1)
                    if term == 0:
                        break
                total += term
    return total


# ----------------------------------------------------------------------
# 2. Newton recursion
# ----------------------------------------------------------------------

def log_power_sums(tails: Sequence[Tail], prec: int) -> List[Number]:
    """p_r = [q^r] sum_i u_i'/u_i for r < prec."""
    out = [Fraction(0)] * prec
    for t in tails:
        ld = ps_log_derivative(unit_part(t, prec + 1), prec)
        for r in range(prec):
            out[r] += ld[r]
    return out


def level_coefficients_newton(power_sums: Sequence[Number], upto: int) -> List[Number]:
    """Solve (k+1) c_{k+1} = sum_{j<=k} c_j p_{k-j} with c_0 = 1."""
    c = [Fraction(1)]
    for k in range(upto):
        acc = Fraction(0)
        for j in range(k + 1):
            acc += c[j] * power_sums[k - j]
        c.append(acc / Fraction(k + 1))
    return c


# ----------------------------------------------------------------------
# 3. Symmetric functions
# ----------------------------------------------------------------------

def esymm(a: Sequence[Number], k: int) -> Number:
    return sum((_prod(a[i] for i in t) for t in combinations(range(len(a)), k)),
               Fraction(0))


def psum(a: Sequence[Number], r: int) -> Number:
    return sum((x ** r for x in a), Fraction(0))


def _prod(xs: Iterator[Number]) -> Number:
    out = Fraction(1)
    for x in xs:
        out *= x
    return out


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


def demo_master_formula() -> None:
    banner("1. Master formula versus honest multiplication")
    tails: List[Tail] = [
        [Fraction(2), Fraction(3), Fraction(-1), Fraction(5)],
        [Fraction(5), Fraction(7), Fraction(0), Fraction(-2)],
        [Fraction(-1), Fraction(1), Fraction(4), Fraction(0)],
    ]
    prec = 7
    truth = product_coefficients(tails, prec)
    print("m = 3 factors, pole of order 3.")
    print(f"{'k':>3} {'c_k (direct)':>16} {'master formula':>18} {'locality form':>18}")
    for k in range(prec):
        a = truth[k]
        b = level_coefficient_master(tails, k)
        c = level_coefficient_local(tails, k)
        assert a == b == c, (k, a, b, c)
        print(f"{k:>3} {str(a):>16} {str(b):>18} {str(c):>18}")
    print("All three agree.  c_0 = 1 is the pole coefficient.")


def demo_lab_note_29() -> None:
    banner("2. Worked example: (q^-1 + 2 + 3q)(q^-1 + 5 + 7q), level 3")
    f: Tail = [Fraction(2), Fraction(3)]
    g: Tail = [Fraction(5), Fraction(7)]
    terms = [(j, coeff(f, j - 1), coeff(g, 3 - j - 1)) for j in range(4)]
    for j, x, y in terms:
        print(f"  nu = ({j}, {3-j}):  [q^{j-1}]f * [q^{2-j}]g = {x} * {y} = {x*y}")
    value = level_coefficient_master([f, g], 3)
    print(f"  total = {value}   (this is the coefficient of q^{{3-2}} = q^1)")
    assert value == 29
    assert product_coefficients([f, g], 5)[3] == 29
    print("  Confirmed: the coefficient of q in the product is 29.")


def demo_locality() -> None:
    banner("3. Locality: only k of the m factors are excited")
    m, k = 8, 3
    tails: List[Tail] = [
        [Fraction(i + 1), Fraction(i * i % 5), Fraction(2 - i % 3), Fraction(1)]
        for i in range(m)
    ]
    exponents = list(compositions(m, k))
    surviving = [nu for nu in exponents if sum(1 for e in nu if e) <= k]
    print(f"m = {m}, k = {k}")
    print(f"  exponent vectors of weight {k}: {len(exponents)}")
    print(f"  of these, with support <= {k}: {len(surviving)}  (i.e. all of them)")
    assert len(exponents) == len(surviving)
    maxsupp = max(sum(1 for e in nu if e) for nu in exponents)
    print(f"  maximal support size actually attained: {maxsupp}")

    print("\n  Truncation: perturbing a_3, a_4, ... must not change c_3.")
    perturbed = [t[:k] + [Fraction(1000 + i)] * 3 for i, t in enumerate(tails)]
    lhs = product_coefficients(tails, k + 1)[k]
    rhs = product_coefficients(perturbed, k + 1)[k]
    print(f"  c_3 original = {lhs},  c_3 perturbed = {rhs}")
    assert lhs == rhs
    print("  Identical, as the truncation theorem predicts.")


def demo_half_locality() -> None:
    banner("4. Half locality for vanishing constant terms")
    # f = q^-1 + 0 + 3q + 4q^2,  g = q^-1 + 0 + 7q + 9q^2
    f: Tail = [Fraction(0), Fraction(3), Fraction(4)]
    g: Tail = [Fraction(0), Fraction(7), Fraction(9)]
    print("f = q^-1 + 3q + 4q^2,  g = q^-1 + 7q + 9q^2   (constant terms vanish)")
    for nu in compositions(2, 3):
        term = coeff(f, nu[0] - 1) * coeff(g, nu[1] - 1)
        flag = "  <- killed by a 1 in the exponent" if 1 in nu else ""
        print(f"  nu = {nu}: contribution {term}{flag}")
    value = level_coefficient_master([f, g], 3)
    print(f"  level-3 coefficient = {value}")
    assert value == 13
    print("  Only vectors with entries 0 or >= 2 survive, so 2*|support| <= 3,")
    print("  i.e. at most one of the two factors is excited at a time.")


def demo_newton_recursion() -> None:
    banner("5. Newton recursion via logarithmic derivatives")
    tails: List[Tail] = [
        [Fraction(1), Fraction(-2), Fraction(3), Fraction(0), Fraction(1)],
        [Fraction(4), Fraction(1), Fraction(-1), Fraction(2), Fraction(0)],
        [Fraction(0), Fraction(5), Fraction(0), Fraction(-3), Fraction(1)],
        [Fraction(-2), Fraction(0), Fraction(2), Fraction(1), Fraction(1)],
    ]
    prec = 6
    truth = product_coefficients(tails, prec)
    p = log_power_sums(tails, prec)
    rec = level_coefficients_newton(p, prec - 1)
    print("power sums p_r of the logarithmic derivatives:")
    print("  " + ", ".join(f"p_{r} = {p[r]}" for r in range(prec)))
    print(f"\n{'k':>3} {'c_k (direct)':>16} {'c_k (recursion)':>18}")
    for k in range(prec):
        assert truth[k] == rec[k], (k, truth[k], rec[k])
        print(f"{k:>3} {str(truth[k]):>16} {str(rec[k]):>18}")
    print("\nCheck p_0 = sum of the constant terms a_0:",
          p[0] == sum((t[0] for t in tails), Fraction(0)))
    print("Hence c_1 = p_0 = sum a_0, the level-1 identity.")


def demo_symmetric_functions() -> None:
    banner("6. The linear case: elementary symmetric functions and Newton")
    a = [Fraction(2), Fraction(-3), Fraction(5), Fraction(1), Fraction(-1)]
    tails: List[Tail] = [[x] for x in a]  # f_i = q^-1 + a_i
    prec = len(a) + 2
    truth = product_coefficients(tails, prec)
    print("a = " + ", ".join(str(x) for x in a))
    print(f"\n{'k':>3} {'c_k':>10} {'e_k':>10}")
    for k in range(prec):
        e = esymm(a, k)
        assert truth[k] == e, (k, truth[k], e)
        print(f"{k:>3} {str(truth[k]):>10} {str(e):>10}")
    print("\nThe Laurent coefficients ARE the elementary symmetric functions.")

    print("\nNewton's identity (k+1) e_{k+1} = sum_{j<=k} (-1)^{k-j} e_j p_{k-j+1}:")
    for k in range(len(a)):
        lhs = Fraction(k + 1) * esymm(a, k + 1)
        rhs = sum((Fraction(-1) ** (k - j) * esymm(a, j) * psum(a, k - j + 1)
                   for j in range(k + 1)), Fraction(0))
        assert lhs == rhs, (k, lhs, rhs)
        print(f"  k = {k}: {lhs} = {rhs}  OK")
    print("Also: the log-derivative power sums are p_r = (-1)^r * sum a_i^{r+1}:")
    lp = log_power_sums(tails, 5)
    for r in range(5):
        expect = Fraction(-1) ** r * psum(a, r + 1)
        assert lp[r] == expect
        print(f"  p_{r} = {lp[r]} = (-1)^{r} * p_{{{r+1}}}^{{classical}}")


def demo_rigidity() -> None:
    banner("7. Rigidity: power sums determine the head of the product")
    # Two families with DIFFERENT numbers of factors but equal power sums
    # p_0, ..., p_{K-1}.  Take the linear case: a = (1, -1), b = (i, -i) has
    # equal odd/even sums up to some order; we use an exact rational example.
    a = [Fraction(3)]
    b = [Fraction(1), Fraction(2)]
    K = 1
    tails_a: List[Tail] = [[x] for x in a]
    tails_b: List[Tail] = [[x] for x in b]
    pa = log_power_sums(tails_a, K)
    pb = log_power_sums(tails_b, K)
    print(f"family A = {[str(x) for x in a]} (1 factor)")
    print(f"family B = {[str(x) for x in b]} (2 factors)")
    print(f"  p_0(A) = {pa[0]},  p_0(B) = {pb[0]}  -> equal below degree K = {K}")
    assert pa[:K] == pb[:K]
    ca = product_coefficients(tails_a, K + 1)
    cb = product_coefficients(tails_b, K + 1)
    for j in range(K + 1):
        assert ca[j] == cb[j]
        print(f"  c_{j}(A) = {ca[j]} = c_{j}(B) = {cb[j]}")
    print("Equal power sums below K force equal coefficients up to level K,")
    print("even though the products have poles of different orders (1 vs 2).")
    print("\nSharpness: at the next level the power sums already differ.")
    pa2 = log_power_sums(tails_a, 2)
    pb2 = log_power_sums(tails_b, 2)
    print(f"  p_1(A) = {pa2[1]},  p_1(B) = {pb2[1]}")
    print(f"  c_2(A) = {product_coefficients(tails_a, 3)[2]}, "
          f"c_2(B) = {product_coefficients(tails_b, 3)[2]}")


def demo_integrality_and_monster() -> None:
    banner("8. Integrality transfer and a Monster-sized product")
    m = 194  # number of conjugacy classes of the Monster
    # Integral, vanishing-constant-term tails in the McKay-Thompson shape.
    tails: List[Tail] = [
        [Fraction(0), Fraction((7 * i + 3) % 11 - 5), Fraction((i * i) % 13 - 6),
         Fraction((5 * i + 1) % 7 - 3)]
        for i in range(m)
    ]
    prec = 5
    c = product_coefficients(tails, prec)
    print(f"m = {m} factors; the product has a pole of order exactly {m}.")
    for k in range(prec):
        assert c[k].denominator == 1
        print(f"  coefficient of q^{{{k}-{m}}} : {c[k]}   (an integer)")
    print("\nAll tails are integers, hence every Laurent coefficient is an integer.")
    print("Half locality at k = 3 says at most 1 of the 194 factors is excited;")
    direct = c[3]
    predicted = sum((t[2] for t in tails), Fraction(0))  # sum of a_2's
    print(f"  c_3 = {direct}, sum of the a_2 coefficients = {predicted}")
    assert direct == predicted
    print("  They agree: only single-factor excitations of weight 3 survive.")

    print("\nNewton recursion cross-check on the same 194-factor product:")
    p = log_power_sums(tails, prec)
    rec = level_coefficients_newton(p, prec - 1)
    for k in range(prec):
        assert rec[k] == c[k]
    print("  recursion reproduces c_0..c_4 exactly.")


def main() -> None:
    demo_master_formula()
    demo_lab_note_29()
    demo_locality()
    demo_half_locality()
    demo_newton_recursion()
    demo_symmetric_functions()
    demo_rigidity()
    demo_integrality_and_monster()
    print()
    print("=" * 72)
    print("All demonstrations completed successfully.")
    print("=" * 72)


if __name__ == "__main__":
    main()
