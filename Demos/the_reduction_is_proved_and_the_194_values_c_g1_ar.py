"""
Numerical demonstrations for
"Rigidity of the Monstrous-Moonshine Head Product".

Everything is exact integer arithmetic; no external dependencies.

The script demonstrates, in order:

  1. Formal power-series arithmetic over Z: E4 = 1 + 240 sum sigma_3(n) q^n,
     the eta product D_m = prod_{k<=m} (1-q^k)^24, and the unique integral
     solution f of D_m * f = E4^3 -- i.e. the q-expansion of q*j.  This
     *derives* the identity-class head entry c_{1A}(1) = 196884.
  2. Truncation stability of the eta product and unit-ness (invertibility).
  3. Ramanujan tau values, Hecke relations, Ramanujan's congruence mod 691,
     and the McKay decompositions of the j-coefficients.
  4. The head product P(t) = prod_g (q^{-1} + t_g q) as an explicit Laurent
     polynomial, and the Vieta theorem
         [q^{2k-194}] P(t) = e_k(t).
  5. The reduction: [q^{-192}] P(t) = sum_g t_g, checked against the direct
     Laurent expansion.
  6. Rigidity: permuting a table leaves P unchanged; changing the multiset
     changes P (and where the first difference appears).
  7. The a priori bound |sum_g c_g(1) - 194| <= 194 * 196883.
  8. Newton / Maclaurin log-concavity of the symmetric-function spectrum.

Run with:  python3 demo.py
"""

from __future__ import annotations

import random
from typing import Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# 1. Truncated formal power series over Z, represented as coefficient lists
# ---------------------------------------------------------------------------


def ps_mul(a: Sequence[int], b: Sequence[int], n_terms: int) -> List[int]:
    """Cauchy convolution of two truncated series, kept to `n_terms` terms."""
    out: List[int] = [0] * n_terms
    for i in range(min(len(a), n_terms)):
        ai = a[i]
        if ai == 0:
            continue
        for jj in range(min(len(b), n_terms - i)):
            out[i + jj] += ai * b[jj]
    return out


def ps_pow(a: Sequence[int], e: int, n_terms: int) -> List[int]:
    """Power of a truncated series by repeated squaring."""
    result: List[int] = [0] * n_terms
    result[0] = 1
    base: List[int] = list(a[:n_terms]) + [0] * max(0, n_terms - len(a))
    while e > 0:
        if e & 1:
            result = ps_mul(result, base, n_terms)
        base = ps_mul(base, base, n_terms)
        e >>= 1
    return result


def ps_inv(a: Sequence[int], n_terms: int) -> List[int]:
    """Inverse of a truncated series with constant term 1 (a unit of Z[[q]])."""
    assert a[0] == 1, "only unit series with constant term 1 are inverted here"
    inv: List[int] = [0] * n_terms
    inv[0] = 1
    for n in range(1, n_terms):
        s = 0
        for k in range(1, n + 1):
            if k < len(a):
                s += a[k] * inv[n - k]
        inv[n] = -s
    return inv


def sigma(k: int, n: int) -> int:
    """Divisor power sum sigma_k(n) = sum_{d | n} d^k."""
    total = 0
    d = 1
    while d * d <= n:
        if n % d == 0:
            total += d ** k
            other = n // d
            if other != d:
                total += other ** k
        d += 1
    return total


def eisenstein_E4(n_terms: int) -> List[int]:
    """E4 = 1 + 240 * sum_{n>=1} sigma_3(n) q^n, truncated."""
    return [1] + [240 * sigma(3, n) for n in range(1, n_terms)]


def eta_product(m: int, n_terms: int) -> List[int]:
    """D_m = prod_{k=1}^{m} (1 - q^k)^24, truncated to `n_terms` terms."""
    out: List[int] = [0] * n_terms
    out[0] = 1
    for k in range(1, m + 1):
        factor: List[int] = [0] * n_terms
        factor[0] = 1
        if k < n_terms:
            factor[k] = -1
        out = ps_mul(out, ps_pow(factor, 24, n_terms), n_terms)
    return out


def j_expansion(n_terms: int) -> List[int]:
    """Coefficients of q*j = E4^3 / D_infty, i.e. [1, 744, 196884, ...]."""
    e4 = eisenstein_E4(n_terms)
    e4cubed = ps_mul(ps_mul(e4, e4, n_terms), e4, n_terms)
    delta = eta_product(max(n_terms - 1, 1), n_terms)
    return ps_mul(e4cubed, ps_inv(delta, n_terms), n_terms)


# ---------------------------------------------------------------------------
# 2. Head tables, symmetric invariants, and the head product
# ---------------------------------------------------------------------------

MONSTER_CLASS_COUNT: int = 194


def elementary_symmetric(t: Sequence[int]) -> List[int]:
    """All elementary symmetric functions e_0, ..., e_n of a list of integers.

    Incremental recursion: multiply the generating polynomial by (1 + t_i Y).
    """
    e: List[int] = [0] * (len(t) + 1)
    e[0] = 1
    for i, ti in enumerate(t, start=1):
        for k in range(i, 0, -1):
            e[k] += ti * e[k - 1]
    return e


def head_product_laurent(t: Sequence[int]) -> Dict[int, int]:
    """The head product prod_i (q^{-1} + t_i q) as {exponent: coefficient}.

    Computed by honest Laurent multiplication, factor by factor -- deliberately
    NOT via the Vieta formula, so that it can be used to test the theorem.
    """
    poly: Dict[int, int] = {0: 1}
    for ti in t:
        new: Dict[int, int] = {}
        for exp, coeff in poly.items():
            new[exp - 1] = new.get(exp - 1, 0) + coeff
            if ti != 0:
                new[exp + 1] = new.get(exp + 1, 0) + coeff * ti
        poly = {e_: c for e_, c in new.items() if c != 0}
    return poly


def head_check(t: Sequence[int]) -> int:
    """The finite arithmetic check: the sum of the head table."""
    return sum(t)


def multiset_key(t: Sequence[int]) -> Tuple[int, ...]:
    """Canonical form of a head table up to relabelling."""
    return tuple(sorted(t))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_j_expansion() -> None:
    print("=" * 74)
    print("1. The q-expansion of j = E4^3 / Delta, derived over Z")
    print("=" * 74)
    n = 12
    coeffs = j_expansion(n)
    expected = [1, 744, 196884, 21493760, 864299970, 20245856256,
                333202640600, 4252023300096, 44656994071935, 401490886656000,
                3176440229784420, 22567393309593600]
    assert coeffs == expected, coeffs
    print("  q*j = " + " + ".join(f"{c}q^{i}" for i, c in enumerate(coeffs[:5])) + " + ...")
    print(f"  j   = q^-1 + {coeffs[1]} + {coeffs[2]}q + {coeffs[3]}q^2 + ...")
    print(f"  identity-class head entry c_1A(1) = {coeffs[2]}")
    print(f"  McKay: 196884 = 1 + 196883 ?  {coeffs[2] == 1 + 196883}")
    print()

    print("  Truncation stability of the eta product (coefficients below q^12):")
    d11 = eta_product(11, 12)
    for m in (11, 15, 25):
        assert eta_product(m, 12) == d11
    print("    D_11 = D_15 = D_25 (mod q^12):  True")

    e4 = eisenstein_E4(12)
    e4cubed = ps_mul(ps_mul(e4, e4, 12), e4, 12)
    assert ps_mul(d11, expected, 12) == e4cubed
    print("    E4^3 = D_11 * (1 + 744q + 196884q^2 + ...)  (mod q^12):  True")
    print("    D_11 is a unit of Z[[q]] (constant term 1):  "
          f"{d11[0] == 1}")
    print()


def demo_tau() -> None:
    print("=" * 74)
    print("2. Ramanujan tau, Hecke relations, congruences")
    print("=" * 74)
    tau_list = eta_product(11, 12)          # tau(n) = [q^{n-1}] D_m
    tau = {n: tau_list[n - 1] for n in range(1, 13)}
    print("  tau(1..12) =", [tau[n] for n in range(1, 13)])
    checks = [
        ("tau(2)tau(3) = tau(6)", tau[2] * tau[3] == tau[6]),
        ("tau(2)tau(5) = tau(10)", tau[2] * tau[5] == tau[10]),
        ("tau(3)tau(4) = tau(12)", tau[3] * tau[4] == tau[12]),
        ("tau(4) = tau(2)^2 - 2^11", tau[4] == tau[2] ** 2 - 2 ** 11),
        ("tau(9) = tau(3)^2 - 3^11", tau[9] == tau[3] ** 2 - 3 ** 11),
        ("tau(8) = tau(2)tau(4) - 2^11 tau(2)",
         tau[8] == tau[2] * tau[4] - 2 ** 11 * tau[2]),
    ]
    for name, ok in checks:
        print(f"    {name:38s} {ok}")
    cong = all((tau[n] - sigma(11, n)) % 691 == 0 for n in range(1, 13))
    print(f"    tau(n) = sigma_11(n) mod 691, n <= 12   {cong}")
    print(f"    tau(n) != 0 for n <= 12 (Lehmer window)  "
          f"{all(tau[n] != 0 for n in range(1, 13))}")
    print()

    print("  McKay decompositions of the derived j-coefficients:")
    c = j_expansion(8)                      # c[n+1] = coefficient of q^n in j-744
    d1, d2, d3 = 1, 196883, 21296876
    d4, d5, d6 = 842609326, 19360062527, 293553734298
    rows = [
        ("c(1)", c[2], d1 + d2, "d1 + d2"),
        ("c(2)", c[3], d1 + d2 + d3, "d1 + d2 + d3"),
        ("c(3)", c[4], 2 * d1 + 2 * d2 + d3 + d4, "2d1 + 2d2 + d3 + d4"),
        ("c(4)", c[5], 2 * d1 + 3 * d2 + 2 * d3 + d4 + d5,
         "2d1 + 3d2 + 2d3 + d4 + d5"),
        ("c(5)", c[6], 3 * d1 + 5 * d2 + 4 * d3 + d4 + 2 * d5 + d6,
         "3d1 + 5d2 + 4d3 + d4 + 2d5 + d6"),
    ]
    for name, lhs, rhs, expr in rows:
        print(f"    {name} = {lhs:>14d} = {expr:<32s} {lhs == rhs}")
    print()


def demo_vieta_small() -> None:
    print("=" * 74)
    print("3. Vieta on a small product: [q^{2k-n}] prod (q^-1 + t_i q) = e_k(t)")
    print("=" * 74)
    t = [3, -1, 5, 2]
    n = len(t)
    poly = head_product_laurent(t)
    e = elementary_symmetric(t)
    print(f"  table t = {t}")
    terms = " + ".join(f"({poly[x]})q^{x}" for x in sorted(poly))
    print(f"  product = {terms}")
    for k in range(n + 1):
        deg = 2 * k - n
        print(f"    k={k}: [q^{deg:>3d}] = {poly.get(deg, 0):>6d}   e_{k} = {e[k]:>6d}"
              f"   {poly.get(deg, 0) == e[k]}")
        assert poly.get(deg, 0) == e[k]
    print()


def demo_reduction_194() -> None:
    print("=" * 74)
    print("4. The reduction at Monster size: [q^-192] P(t) = sum_g c_g(1)")
    print("=" * 74)
    # Illustrative table: derived identity-class entry, placeholder 1 elsewhere.
    table: List[int] = [j_expansion(3)[2]] + [1] * (MONSTER_CLASS_COUNT - 1)
    e = elementary_symmetric(table)
    print(f"  entries: {MONSTER_CLASS_COUNT}, first entry (class 1A) = {table[0]}")
    print(f"  e_0 = {e[0]}  -> [q^-194] P(t) : pole of order exactly 194, monic")
    print(f"  e_1 = {e[1]}  -> [q^-192] P(t) = sum of the head table")
    print(f"  finite check sum_g c_g(1) = {head_check(table)}")
    print(f"  equality of the Laurent statement and the arithmetic one: "
          f"{e[1] == head_check(table)}")
    print(f"  e_2 = {e[2]}  -> [q^-190] P(t)")
    print(f"  e_194 = prod_g c_g(1) = {e[194]}")
    print()

    # Direct Laurent multiplication on a smaller but nontrivial slice, to show
    # the Vieta identity is not an artefact of the recursion.
    small = table[:12]
    poly = head_product_laurent(small)
    es = elementary_symmetric(small)
    ok = all(poly.get(2 * k - len(small), 0) == es[k] for k in range(len(small) + 1))
    print(f"  direct Laurent expansion of the first 12 factors matches Vieta: {ok}")
    print()


def demo_rigidity() -> None:
    print("=" * 74)
    print("5. Rigidity: the product is a complete invariant of the table")
    print("=" * 74)
    rng = random.Random(20260825)
    base: List[int] = [rng.randint(-40, 40) for _ in range(MONSTER_CLASS_COUNT)]

    shuffled = base[:]
    rng.shuffle(shuffled)
    same = elementary_symmetric(base) == elementary_symmetric(shuffled)
    print(f"  (a) permuted table gives the identical product:            {same}")
    print(f"      multisets agree: {multiset_key(base) == multiset_key(shuffled)}")

    # (b) perturb one entry: the sum changes, so the FIRST coefficient separates.
    bumped = base[:]
    bumped[57] += 1
    e_base, e_bump = elementary_symmetric(base), elementary_symmetric(bumped)
    first_diff = next(k for k in range(len(e_base)) if e_base[k] != e_bump[k])
    print(f"  (b) one entry increased by 1: sums differ "
          f"({sum(base)} vs {sum(bumped)}),")
    print(f"      first differing symmetric invariant is e_{first_diff} "
          f"-> Laurent degree {2*first_diff - MONSTER_CLASS_COUNT}")

    # (c) sum-preserving perturbation: the head check passes, higher e_k catch it.
    sneaky = base[:]
    sneaky[3] += 7
    sneaky[100] -= 7
    e_sneaky = elementary_symmetric(sneaky)
    first_diff2 = next(k for k in range(len(e_base)) if e_base[k] != e_sneaky[k])
    print(f"  (c) sum-preserving perturbation: sums agree "
          f"({sum(base)} = {sum(sneaky)}),")
    print(f"      so the degree -192 check alone does NOT separate them;")
    print(f"      the first differing invariant is e_{first_diff2} "
          f"-> Laurent degree {2*first_diff2 - MONSTER_CLASS_COUNT}")
    print(f"      multisets differ: "
          f"{multiset_key(base) != multiset_key(sneaky)}  =>  products differ")

    # (d) decidability: comparing products = comparing sorted tables
    print("  (d) deciding P(t) = P(u): sort and compare, O(n log n)")
    print(f"      P(base) == P(shuffled): {multiset_key(base) == multiset_key(shuffled)}")
    print(f"      P(base) == P(sneaky)  : {multiset_key(base) == multiset_key(sneaky)}")
    print()


def demo_bound() -> None:
    print("=" * 74)
    print("6. A priori bound on the finite check")
    print("=" * 74)
    b = 196883
    lo, hi = 194 - MONSTER_CLASS_COUNT * b, 194 + MONSTER_CLASS_COUNT * b
    print(f"  |c_g(1) - 1| = |chi_196883(g)| <= {b} for every class g")
    print(f"  => |sum_g c_g(1) - 194| <= 194 * {b} = {MONSTER_CLASS_COUNT * b}")
    print(f"  => the check must lie in [{lo}, {hi}]")
    entry_1A = j_expansion(3)[2]
    print(f"  identity class: |c_1A(1) - 1| = {abs(entry_1A - 1)} "
          f"= {b} (extremal, as a character at the identity must be)")
    print()


def demo_log_concavity() -> None:
    print("=" * 74)
    print("7. Newton / Maclaurin: log-concavity of the symmetric spectrum")
    print("=" * 74)
    # Newton's inequalities hold for any real-rooted polynomial; the generating
    # polynomial prod (X + t_i) is real-rooted by construction.
    rng = random.Random(7)
    t = [rng.randint(1, 500) for _ in range(MONSTER_CLASS_COUNT)]
    e = elementary_symmetric(t)
    n = len(t)

    def binom(n_: int, k_: int) -> int:
        num, den = 1, 1
        for i in range(k_):
            num *= n_ - i
            den *= i + 1
        return num // den

    # Exact rational comparison of e_k / C(n,k), cleared of denominators.
    ok = True
    for k in range(1, n):
        lhs = e[k - 1] * e[k + 1] * binom(n, k) * binom(n, k)
        rhs = e[k] * e[k] * binom(n, k - 1) * binom(n, k + 1)
        if lhs > rhs:
            ok = False
            break
    print(f"  random positive table of {n} entries")
    print(f"  Newton's inequality  p_{{k-1}} p_{{k+1}} <= p_k^2  "
          f"(p_k = e_k / C(n,k)) holds for all k: {ok}")
    print("  consequence: the Laurent coefficients of the moonshine product in")
    print("  degrees -194, -192, ..., 194 form a log-concave spectrum after")
    print("  binomial normalization.")
    print()


def main() -> None:
    demo_j_expansion()
    demo_tau()
    demo_vieta_small()
    demo_reduction_194()
    demo_rigidity()
    demo_bound()
    demo_log_concavity()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
