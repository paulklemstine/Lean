"""
Rational Hilbert series of graded G-sets: numerical demonstrations.

This self-contained script demonstrates, by direct computation on integer
sequences and truncated formal power series, the results of the accompanying
paper:

  * t_r(Y) = 1  <=>  the action is r-transitive (one orbit of injective
    r-tuples), verified by brute-force orbit enumeration for small grades;

  * eventual r-transitivity  =>  (1-q) H_r(q) is a polynomial, with the
    numerator evaluating to 1 at q = 1 (the residue theorem);

  * the symmetric-group family Y_n = {0,...,n-1}, G_n = S_n realises
    H_r(q) = q^r / (1-q)  --  a simple pole;

  * the trivial-group family on the SAME grades realises
    H_r(q) = r! q^r / (1-q)^{r+1}  --  a pole of order exactly r+1,
    so the exponent r+1 is sharp without transitivity;

  * sum_n C(n,r) q^n = q^r / (1-q)^{r+1}, from Pascal's rule alone;

  * Newton's forward difference formula reconstructs an eventually
    polynomial sequence from its difference table;

  * Burnside's orbit-counting lemma computes t_r as the average number of
    fixed injective r-tuples.

Everything uses exact arithmetic (Fraction / int); no external dependencies.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations
from math import comb, factorial
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Seq = List[Fraction]
Poly = List[Fraction]  # coefficient list, index = degree


# ---------------------------------------------------------------------------
# 1. Finite differences
# ---------------------------------------------------------------------------

def forward_difference(a: Sequence[Fraction]) -> Seq:
    """(Delta a)(n) = a(n+1) - a(n).  Loses one term."""
    return [a[n + 1] - a[n] for n in range(len(a) - 1)]


def difference_table(a: Sequence[Fraction], depth: int) -> List[Seq]:
    """Rows 0..depth of the forward difference table of `a`."""
    rows: List[Seq] = [list(a)]
    for _ in range(depth):
        rows.append(forward_difference(rows[-1]))
    return rows


def minimal_clearing_exponent(a: Sequence[Fraction], max_k: int,
                              window: int = 4) -> int | None:
    """Smallest k <= max_k such that the last `window` entries of Delta^k a
    vanish.  By the classification theorem this is one more than the eventual
    polynomial degree of `a`."""
    rows = difference_table(a, max_k)
    for k, row in enumerate(rows):
        if len(row) >= window and all(x == 0 for x in row[-window:]):
            return k
    return None


# ---------------------------------------------------------------------------
# 2. Truncated formal power series over Q
# ---------------------------------------------------------------------------

def series_mul(f: Sequence[Fraction], g: Sequence[Fraction], prec: int) -> Seq:
    """Cauchy product truncated at q^prec (exclusive)."""
    out = [Fraction(0)] * prec
    for i, fi in enumerate(f[:prec]):
        if fi == 0:
            continue
        for j, gj in enumerate(g[: prec - i]):
            out[i + j] += fi * gj
    return out


def one_minus_q_pow(k: int, prec: int) -> Seq:
    """Coefficients of (1-q)^k, truncated."""
    out = [Fraction(0)] * prec
    for i in range(min(k, prec - 1) + 1):
        out[i] = Fraction((-1) ** i * comb(k, i))
    return out


def numerator(a: Sequence[Fraction], k: int) -> Seq:
    """Coefficients of (1-q)^k * sum a_n q^n, truncated to len(a)."""
    return series_mul(one_minus_q_pow(k, len(a)), a, len(a))


def poly_eval_at_one(p: Sequence[Fraction]) -> Fraction:
    return sum(p, Fraction(0))


def trim(p: Sequence[Fraction]) -> Poly:
    q = list(p)
    while q and q[-1] == 0:
        q.pop()
    return q


def poly_str(p: Sequence[Fraction], var: str = "q") -> str:
    p = trim(p)
    if not p:
        return "0"
    out = ""
    for i, c in enumerate(p):
        if c == 0:
            continue
        sign = "-" if c < 0 else "+"
        m = abs(c)
        if i == 0:
            body = f"{m}"
        elif i == 1:
            body = f"{var}" if m == 1 else f"{m}*{var}"
        else:
            body = f"{var}^{i}" if m == 1 else f"{m}*{var}^{i}"
        if out:
            out += f" {sign} {body}"
        else:
            out = body if sign == "+" else f"-{body}"
    return out


# ---------------------------------------------------------------------------
# 3. Brute-force orbit counting on injective r-tuples
# ---------------------------------------------------------------------------

Perm = Tuple[int, ...]  # perm[i] = image of i


def symmetric_group(n: int) -> List[Perm]:
    return list(permutations(range(n)))


def trivial_group(n: int) -> List[Perm]:
    return [tuple(range(n))]


def cyclic_group(n: int) -> List[Perm]:
    return [tuple((i + s) % n for i in range(n)) for s in range(n)]


def injective_tuples(n: int, r: int) -> List[Tuple[int, ...]]:
    """All injective maps {0,...,r-1} -> {0,...,n-1}, as tuples."""
    return list(permutations(range(n), r))


def act(g: Perm, t: Tuple[int, ...]) -> Tuple[int, ...]:
    return tuple(g[x] for x in t)


def torbits(group: Sequence[Perm], n: int, r: int) -> int:
    """t_r(Y): number of orbits of the group on injective r-tuples of
    {0,...,n-1}, computed by union-find over the group action."""
    tuples = injective_tuples(n, r)
    index: Dict[Tuple[int, ...], int] = {t: i for i, t in enumerate(tuples)}
    parent = list(range(len(tuples)))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[rx] = ry

    for t in tuples:
        for g in group:
            union(index[t], index[act(g, t)])
    return len({find(i) for i in range(len(tuples))})


def torbits_burnside(group: Sequence[Perm], n: int, r: int) -> Fraction:
    """t_r(Y) computed as the average number of fixed injective r-tuples."""
    tuples = injective_tuples(n, r)
    total = 0
    for g in group:
        total += sum(1 for t in tuples if act(g, t) == t)
    return Fraction(total, len(group))


def is_r_transitive(group: Sequence[Perm], n: int, r: int) -> bool:
    """r-transitive == exactly one orbit of injective r-tuples."""
    return torbits(group, n, r) == 1


# ---------------------------------------------------------------------------
# 4. Newton's forward difference formula
# ---------------------------------------------------------------------------

def newton_coefficients(a: Sequence[Fraction], base: int, k: int) -> Seq:
    """(Delta^j a)(base) for j = 0..k-1."""
    rows = difference_table(a, k)
    return [rows[j][base] for j in range(k)]


def newton_evaluate(coeffs: Sequence[Fraction], base: int, n: int) -> Fraction:
    """sum_{j<k} coeffs[j] * C(n - base, j), valid for n >= base."""
    return sum((coeffs[j] * comb(n - base, j) for j in range(len(coeffs))),
               Fraction(0))


# ---------------------------------------------------------------------------
# 5. The demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_transitivity_is_one_orbit() -> None:
    banner("1. r-transitivity is exactly t_r = 1 (brute force)")
    print(f"{'n':>3} {'r':>3} | {'S_n':>18} | {'trivial':>18} | {'cyclic C_n':>18}")
    print("-" * 74)
    for n in range(1, 6):
        for r in range(1, min(n, 3) + 1):
            s = torbits(symmetric_group(n), n, r)
            t = torbits(trivial_group(n), n, r)
            c = torbits(cyclic_group(n), n, r)
            def tag(v: int) -> str:
                return f"{v} {'(transitive)' if v == 1 else '            '}"
            print(f"{n:>3} {r:>3} | {tag(s):>18} | {tag(t):>18} | {tag(c):>18}")
    print()
    print("S_n is r-transitive for every r <= n: exactly one orbit.")
    print("The trivial group has as many orbits as injective tuples: n!/(n-r)!.")
    print("The cyclic group is 1-transitive but (for n > 2) not 2-transitive.")


def demo_symmetric_family(r: int = 3, prec: int = 12) -> None:
    banner(f"2. Symmetric-group family, r = {r}:  H_r(q) = q^{r}/(1-q)")
    a: Seq = []
    for n in range(prec):
        if n < r:
            a.append(Fraction(0))          # no injective r-tuple: t_r = 0
        else:
            a.append(Fraction(torbits(symmetric_group(n), n, r)) if n <= 6
                     else Fraction(1))     # brute force where feasible
    print("t_r(Y_n) for n = 0..:", [int(x) for x in a])
    P = numerator(a, 1)
    print("(1-q) * H(q)        =", poly_str(P))
    print("P(1)                =", poly_eval_at_one(P), " (residue theorem: 1)")
    expected = [Fraction(1) if i == r else Fraction(0) for i in range(prec)]
    print("equals q^r?         ", trim(P) == trim(expected))
    print("minimal clearing k  =", minimal_clearing_exponent(a, 6))


def demo_trivial_family_sharpness(r: int = 3, prec: int = 12) -> None:
    banner(f"3. Trivial-group family, r = {r}: pole of order exactly r+1 = {r+1}")
    a: Seq = []
    for n in range(prec):
        # t_r = number of injective r-tuples = falling factorial = r! C(n,r)
        a.append(Fraction(factorial(r) * comb(n, r)))
    # cross-check by brute force where feasible
    for n in range(min(prec, 7)):
        assert torbits(trivial_group(n), n, r) == a[n], "brute-force mismatch"
    print("t_r(Y_n) = r! C(n,r):", [int(x) for x in a])
    rows = difference_table(a, r + 1)
    for j, row in enumerate(rows):
        print(f"  Delta^{j}: {[int(x) for x in row[:8]]}")
    print()
    print(f"Delta^{r} is the nonzero constant {int(rows[r][0])} = {r}!,"
          f" so (1-q)^{r} does NOT clear the series.")
    Pk = numerator(a, r + 1)
    Pk_short = numerator(a, r)
    print(f"(1-q)^{r+1} * H(q)   =", poly_str(Pk))
    print(f"(1-q)^{r}   * H(q)   =", poly_str(Pk_short)[:60], "...  (never terminates)")
    print("minimal clearing k  =", minimal_clearing_exponent(a, r + 3),
          f"   (predicted r+1 = {r+1})")


def demo_binomial_generating_function(rmax: int = 4, prec: int = 14) -> None:
    banner("4. Binomial generating function:  sum C(n,r) q^n = q^r/(1-q)^{r+1}")
    for r in range(rmax + 1):
        a = [Fraction(comb(n, r)) for n in range(prec)]
        P = numerator(a, r + 1)
        target = [Fraction(1) if i == r else Fraction(0) for i in range(prec)]
        ok = trim(P) == trim(target)
        print(f"  r = {r}:  (1-q)^{r+1} * sum C(n,{r}) q^n = {poly_str(P):<10}"
              f"  == q^{r}?  {ok}")
    print()
    print("Proved from Pascal's rule alone: Delta C(.,r+1) = C(.,r).")
    for r in range(1, rmax + 1):
        a1 = [Fraction(comb(n, r)) for n in range(prec)]
        a0 = [Fraction(comb(n, r - 1)) for n in range(prec)]
        assert forward_difference(a1) == a0[:-1]
    print("Pascal difference identity verified for r = 1..", rmax)


def demo_defect_region_numerator() -> None:
    banner("5. The numerator records the defect region;  P(1) = 1 always")
    # Grades r-transitive from N = 5 on, arbitrary low-grade orbit counts.
    low = [0, 3, 2, 7, 4]
    N = len(low)
    a = [Fraction(x) for x in low] + [Fraction(1)] * 15
    P = numerator(a, 1)
    print("orbit counts        :", [int(x) for x in a[:10]], "...")
    print("(1-q) * H(q)        =", poly_str(P))
    print("P(1)                =", poly_eval_at_one(P))
    assert poly_eval_at_one(P) == 1
    print("=> the numerator's coefficients always sum to 1 (simple pole,")
    print("   residue -1), however irregular the low grades are.")
    # Clean case: no injective tuple below the threshold.
    b = [Fraction(0)] * N + [Fraction(1)] * 15
    Q = numerator(b, 1)
    print()
    print(f"clean case (no injective r-tuple below N = {N}):")
    print("(1-q) * H(q)        =", poly_str(Q), f"   == q^{N}")


def demo_newton_reconstruction() -> None:
    banner("6. Newton's forward difference formula")
    # An eventually-quadratic orbit count.
    def rule(n: int) -> int:
        return n * n - 3 * n + 4 if n >= 2 else (11 if n == 0 else 5)
    a = [Fraction(rule(n)) for n in range(14)]
    base = 2
    k = 3  # r + 1 with r = 2
    coeffs = newton_coefficients(a, base, k)
    print("sequence            :", [int(x) for x in a])
    print(f"Newton coefficients at N = {base}: {[str(c) for c in coeffs]}")
    print("reconstruction check:")
    for n in range(base, 12):
        val = newton_evaluate(coeffs, base, n)
        print(f"   n = {n:2d}:  a(n) = {int(a[n]):5d}   Newton = {int(val):5d}"
              f"   {'OK' if val == a[n] else 'MISMATCH'}")
        assert val == a[n]
    print()
    print("minimal clearing k  =", minimal_clearing_exponent(a, 6),
          "  (eventual degree 2, so k = 3)")


def demo_burnside() -> None:
    banner("7. Burnside's orbit-counting lemma for injective r-tuples")
    print(f"{'group':>12} {'n':>3} {'r':>3} | {'sum |Fix(g)|':>13}"
          f" {'|G|':>5} {'average':>9} {'t_r (union-find)':>18}")
    print("-" * 74)
    families: List[Tuple[str, Callable[[int], List[Perm]]]] = [
        ("S_n", symmetric_group),
        ("trivial", trivial_group),
        ("C_n", cyclic_group),
    ]
    for name, mk in families:
        for n in (4, 5):
            for r in (1, 2):
                G = mk(n)
                tuples = injective_tuples(n, r)
                total = sum(sum(1 for t in tuples if act(g, t) == t) for g in G)
                avg = torbits_burnside(G, n, r)
                direct = torbits(G, n, r)
                assert avg == direct
                print(f"{name:>12} {n:>3} {r:>3} | {total:>13} {len(G):>5}"
                      f" {str(avg):>9} {direct:>18}")
    print()
    print("Burnside: sum_g |Fix(g)| = t_r * |G|.  When each fixed-point count")
    print("grows polynomially of degree <= r in the grade, averaging makes t_r")
    print("eventually polynomial of degree <= r, hence denominator (1-q)^{r+1}")
    print("-- with no transitivity hypothesis at all.")


def demo_closure_under_products() -> None:
    banner("8. Poles add: Cauchy product of two Hilbert series")
    prec = 16
    r, s = 2, 3
    A = [Fraction(1) if n >= r else Fraction(0) for n in range(prec)]  # q^r/(1-q)
    B = [Fraction(1) if n >= s else Fraction(0) for n in range(prec)]  # q^s/(1-q)
    C = series_mul(A, B, prec)
    print("H_r coefficients    :", [int(x) for x in A])
    print("H_s coefficients    :", [int(x) for x in B])
    print("Cauchy product      :", [int(x) for x in C])
    P2 = numerator(C, 2)
    print("(1-q)^2 * product   =", poly_str(P2), f"   == q^{r+s}")
    print("minimal clearing k  =", minimal_clearing_exponent(C, 5),
          "  (pole order 2 = 1 + 1)")


def demo_profile() -> None:
    banner("9. The whole transitivity profile is rational")
    rmax, prec = 4, 12
    print("Symmetric-group family: t_s(Y_n) = [n >= s], numerator q^s, P(1) = 1")
    for s in range(rmax + 1):
        a = [Fraction(1) if n >= s else Fraction(0) for n in range(prec)]
        P = numerator(a, 1)
        print(f"  s = {s}:  (1-q) H_s(q) = {poly_str(P):<8}"
              f"  P(1) = {poly_eval_at_one(P)}")
    print()
    print("r-transitivity is downward closed, so eventual r-transitivity makes")
    print("all of H_0, ..., H_r rational with a simple pole at q = 1.")


def main() -> None:
    print(__doc__)
    demo_transitivity_is_one_orbit()
    demo_symmetric_family()
    demo_trivial_family_sharpness()
    demo_binomial_generating_function()
    demo_defect_region_numerator()
    demo_newton_reconstruction()
    demo_burnside()
    demo_closure_under_products()
    demo_profile()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
