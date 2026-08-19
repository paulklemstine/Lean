"""
Transitivity partition functions of graded G-sets: numerical demonstrations.

This self-contained script illustrates, with exact integer and rational arithmetic,
the results on transitivity counts of graded G-sets:

  * t_r(Y) = #{ G-orbits on injective r-tuples of Y }, computed two ways
    (direct orbit enumeration and the fixed-point / Burnside average), and the
    criterion t_r(Y) = 1  <=>  G acts r-transitively on Y;

  * the finite-difference core:  [q^{n+s}]( (1-q)^s A(q) ) = (Delta^s a)_n,
    and the exact criterion "(1-q)^s A(q) is a polynomial  <=>  Delta^s a
    eventually vanishes";

  * the main theorem: for an eventually r-transitive graded G-set,
    Z_r(q) = sum_{n<N} t_r(Y_n) q^n + q^N/(1-q), a rational function whose only
    pole is the simple pole at q = 1;

  * sharpness: the trivial action on n labelled points has t_r = n^{underline r}
    and denominator exactly (1-q)^{r+1}; the binomial model C(n+r, r) has
    generating function exactly 1/(1-q)^{r+1};

  * the intermediate regime: Z translating Z/nZ is 1-transitive in every grade but
    has t_2(Z/nZ) = n - 1, hence denominator exactly (1-q)^2.

Only the Python standard library is used.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations
from math import comb, factorial
from typing import Callable, Dict, List, Sequence, Set, Tuple

Perm = Tuple[int, ...]  # a permutation of {0, ..., m-1} given by images


# --------------------------------------------------------------------------- #
# 1.  Group actions on finite sets, given as permutation groups                #
# --------------------------------------------------------------------------- #


def compose(p: Perm, q: Perm) -> Perm:
    """Composition (p . q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(q)))


def generated_group(generators: Sequence[Perm], degree: int) -> List[Perm]:
    """Closure of `generators` under composition, including the identity.

    Breadth-first closure; returns a sorted list of permutations of {0,...,degree-1}.
    """
    identity: Perm = tuple(range(degree))
    seen: Set[Perm] = {identity}
    frontier: List[Perm] = [identity]
    while frontier:
        new_frontier: List[Perm] = []
        for p in frontier:
            for g in generators:
                r = compose(g, p)
                if r not in seen:
                    seen.add(r)
                    new_frontier.append(r)
        frontier = new_frontier
    return sorted(seen)


def cyclic_group(n: int) -> List[Perm]:
    """The cyclic group Z/nZ acting on {0,...,n-1} by translation."""
    if n == 0:
        return [()]
    shift: Perm = tuple((i + 1) % n for i in range(n))
    return generated_group([shift], n)


def trivial_group(n: int) -> List[Perm]:
    """The trivial group acting on {0,...,n-1}: no symmetry at all."""
    return [tuple(range(n))]


def symmetric_group(n: int) -> List[Perm]:
    """The full symmetric group on {0,...,n-1}."""
    return [tuple(p) for p in permutations(range(n))]


def dihedral_group(n: int) -> List[Perm]:
    """The dihedral group of order 2n acting on the vertices of an n-gon."""
    if n == 0:
        return [()]
    shift: Perm = tuple((i + 1) % n for i in range(n))
    flip: Perm = tuple((-i) % n for i in range(n))
    return generated_group([shift, flip], n)


# --------------------------------------------------------------------------- #
# 2.  Transitivity counts                                                      #
# --------------------------------------------------------------------------- #


def desc_factorial(m: int, r: int) -> int:
    """The descending factorial m^{underline r} = m (m-1) ... (m-r+1)."""
    if r > m:
        return 0
    out = 1
    for i in range(r):
        out *= m - i
    return out


def trans_count_by_orbits(group: Sequence[Perm], degree: int, r: int) -> int:
    """t_r(Y): number of G-orbits on injective r-tuples, by direct enumeration.

    Exponential in r; used here only as an independent cross-check.
    """
    tuples: List[Tuple[int, ...]] = list(permutations(range(degree), r))
    index: Dict[Tuple[int, ...], int] = {t: i for i, t in enumerate(tuples)}
    parent: List[int] = list(range(len(tuples)))

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
        i = index[t]
        for g in group:
            union(i, index[tuple(g[x] for x in t)])
    return len({find(i) for i in range(len(tuples))})


def trans_count_by_burnside(group: Sequence[Perm], degree: int, r: int) -> int:
    """t_r(Y) = (1/|G|) * sum_g |Y^g|^{underline r}, the fixed-point formula.

    An injective r-tuple is fixed by g exactly when all of its entries are fixed
    points of g, so g contributes |Y^g|^{underline r} tuples.  Cost O(|G| * degree).
    """
    total = 0
    for g in group:
        fixed = sum(1 for i in range(degree) if g[i] == i)
        total += desc_factorial(fixed, r)
    quotient = Fraction(total, len(group))
    assert quotient.denominator == 1, "Burnside average must be an integer"
    return int(quotient)


def is_transitive_deg(group: Sequence[Perm], degree: int, r: int) -> bool:
    """G acts r-transitively on {0,...,degree-1}  <=>  t_r = 1."""
    if desc_factorial(degree, r) == 0:
        return False
    return trans_count_by_burnside(group, degree, r) == 1


# --------------------------------------------------------------------------- #
# 3.  Finite differences and denominator detection                             #
# --------------------------------------------------------------------------- #


def forward_difference(a: Sequence[int]) -> List[int]:
    """(Delta a)_n = a_{n+1} - a_n; the output is one term shorter."""
    return [a[n + 1] - a[n] for n in range(len(a) - 1)]


def difference_table(a: Sequence[int], depth: int) -> List[List[int]]:
    """Rows Delta^0 a, Delta^1 a, ..., Delta^depth a (each shorter by one)."""
    rows: List[List[int]] = [list(a)]
    for _ in range(depth):
        if len(rows[-1]) < 2:
            rows.append([])
        else:
            rows.append(forward_difference(rows[-1]))
    return rows


def series_times_one_minus_q_pow(a: Sequence[int], s: int) -> List[int]:
    """Coefficients of (1-q)^s * sum_n a_n q^n, truncated to the available data.

    Coefficient m of the product is sum_j (-1)^j C(s,j) a_{m-j}.
    """
    out: List[int] = []
    for m in range(len(a)):
        acc = 0
        for j in range(min(s, m) + 1):
            acc += (-1) ** j * comb(s, j) * a[m - j]
        out.append(acc)
    return out


def detect_pole_order(a: Sequence[int], max_order: int = 8, tail: int = 3) -> int:
    """Least s such that Delta^s a vanishes on the last `tail` available entries.

    By the exact criterion, for eventually polynomial data this s is the order of
    the pole of sum_n a_n q^n at q = 1.  Cost O(len(a) * max_order).
    """
    rows = difference_table(a, max_order)
    for s, row in enumerate(rows):
        if len(row) >= tail and all(x == 0 for x in row[-tail:]):
            return s
    return -1


def numerator_coefficients(a: Sequence[int], s: int) -> List[int]:
    """Numerator of sum_n a_n q^n over (1-q)^s, assuming the data suffice.

    Returns the coefficient list of (1-q)^s * A(q) with trailing zeros removed.
    """
    coeffs = series_times_one_minus_q_pow(a, s)
    while coeffs and coeffs[-1] == 0:
        coeffs.pop()
    return coeffs


def poly_to_string(coeffs: Sequence[int]) -> str:
    """Pretty-print a coefficient list as a polynomial in q."""
    if not coeffs:
        return "0"
    parts: List[str] = []
    for k, c in enumerate(coeffs):
        if c == 0:
            continue
        if k == 0:
            parts.append(f"{c}")
        elif k == 1:
            parts.append(f"{c}q" if abs(c) != 1 else ("q" if c == 1 else "-q"))
        else:
            body = f"q^{k}"
            parts.append(body if c == 1 else (f"-{body}" if c == -1 else f"{c}{body}"))
    out = " + ".join(parts).replace("+ -", "- ")
    return out if out else "0"


# --------------------------------------------------------------------------- #
# 4.  Evaluating the partition function analytically                           #
# --------------------------------------------------------------------------- #


def partial_sum(a: Sequence[int], q: Fraction, terms: int) -> Fraction:
    """Partial sum sum_{n < terms} a_n q^n in exact rational arithmetic."""
    total = Fraction(0)
    power = Fraction(1)
    for n in range(min(terms, len(a))):
        total += a[n] * power
        power *= q
    return total


def closed_form_eventually_constant(
    a: Sequence[int], N: int, c: int, q: Fraction
) -> Fraction:
    """sum_{n<N} a_n q^n + c q^N / (1-q):  the closed form for a_n = c, n >= N."""
    return partial_sum(a, q, N) + Fraction(c) * q**N / (1 - q)


# --------------------------------------------------------------------------- #
# 5.  Graded families                                                          #
# --------------------------------------------------------------------------- #


def graded_counts(
    group_of: Callable[[int], List[Perm]], r: int, grades: int
) -> List[int]:
    """t_r(Y_n) for n = 0, ..., grades-1, where Y_n = {0,...,n-1} with G = group_of(n)."""
    return [trans_count_by_burnside(group_of(n), n, r) for n in range(grades)]


# --------------------------------------------------------------------------- #
# 6.  Demonstrations                                                           #
# --------------------------------------------------------------------------- #


def demo_orbit_counts_agree() -> None:
    print("=" * 78)
    print("1.  Orbit enumeration and the fixed-point (Burnside) formula agree")
    print("=" * 78)
    print(f"{'group':>22} {'n':>3} {'r':>2} {'orbits':>8} {'Burnside':>9} {'r-trans?':>9}")
    families: List[Tuple[str, Callable[[int], List[Perm]]]] = [
        ("trivial", trivial_group),
        ("cyclic Z/nZ", cyclic_group),
        ("dihedral", dihedral_group),
        ("symmetric S_n", symmetric_group),
    ]
    for name, gof in families:
        for n in (5, 6):
            for r in (1, 2, 3):
                g = gof(n)
                by_orbit = trans_count_by_orbits(g, n, r)
                by_burn = trans_count_by_burnside(g, n, r)
                assert by_orbit == by_burn, (name, n, r, by_orbit, by_burn)
                flag = "yes" if by_burn == 1 else "no"
                print(f"{name:>22} {n:>3} {r:>2} {by_orbit:>8} {by_burn:>9} {flag:>9}")
    print("\nBoth methods agree in every case, and t_r = 1 exactly for the")
    print("r-transitive actions:  S_n is r-transitive for all r <= n, the cyclic")
    print("group only for r = 1, the trivial group only for r = 0.\n")


def demo_trivial_action_sharpness(r: int = 3, grades: int = 12) -> None:
    print("=" * 78)
    print(f"2.  Trivial action:  t_r(Y_n) = n^(underline {r}),  denominator exactly (1-q)^{r+1}")
    print("=" * 78)
    counts = [desc_factorial(n, r) for n in range(grades)]
    assert counts == graded_counts(trivial_group, r, grades)
    print(f"t_{r}(Y_n), n = 0..{grades-1}:  {counts}")
    rows = difference_table(counts, r + 2)
    for s, row in enumerate(rows):
        label = f"Delta^{s}"
        print(f"{label:>9}: {row}")
    print(f"\nThe {r}-th difference is the constant {factorial(r)} = {r}! and never vanishes,")
    print(f"so (1-q)^{r} does NOT clear the denominator; the ({r}+1)-st difference is zero,")
    print(f"so (1-q)^{r+1} does.  Detected pole order: {detect_pole_order(counts)}"
          f" (expected {r+1}).")
    num = numerator_coefficients(counts, r + 1)
    print(f"Numerator (1-q)^{r+1} A(q) = {poly_to_string(num)}\n")


def demo_binomial_model(r: int = 3, grades: int = 12) -> None:
    print("=" * 78)
    print(f"3.  The extremal model C(n+{r}, {r}):  A(q) = 1/(1-q)^{r+1} exactly")
    print("=" * 78)
    b = [comb(n + r, r) for n in range(grades)]
    print(f"b_n = C(n+{r},{r}):  {b}")
    for s in range(r + 2):
        prod = series_times_one_minus_q_pow(b, s)
        print(f"(1-q)^{s} A(q) coefficients: {prod}")
    print(f"\n(1-q)^{r} A(q) is the all-ones series -- not a polynomial;")
    print(f"(1-q)^{r+1} A(q) = 1.  The exponent {r+1} is optimal.\n")


def demo_cyclic_intermediate(grades: int = 12) -> None:
    print("=" * 78)
    print("4.  Translations of Z/nZ:  1-transitive in every grade, but t_2 = n - 1")
    print("=" * 78)
    t1 = [trans_count_by_burnside(cyclic_group(n), n, 1) for n in range(1, grades + 1)]
    t2 = [trans_count_by_burnside(cyclic_group(n), n, 2) for n in range(1, grades + 1)]
    print(f"grades n = 1..{grades}")
    print(f"t_1(Z/nZ) = {t1}   (all 1: every grade is 1-transitive)")
    print(f"t_2(Z/nZ) = {t2}   (= n - 1: linear growth)")
    assert all(x == 1 for x in t1)
    assert t2 == [n - 1 for n in range(1, grades + 1)]
    print(f"\nDifference table of t_2 (as a sequence in n, starting at n = 1):")
    for s, row in enumerate(difference_table(t2, 3)):
        print(f"{'Delta^' + str(s):>9}: {row}")
    print(f"Detected pole order for t_2: {detect_pole_order(t2)} (expected 2)")
    print(f"Detected pole order for t_1: {detect_pole_order(t1)} (expected 1)")
    print(f"Numerator over (1-q)^2:  {poly_to_string(numerator_coefficients(t2, 2))}")
    print("\nSo the second transitivity partition function has a genuine double pole:")
    print("strictly between the transitive regime (1-q) and the general bound (1-q)^3.\n")


def demo_eventually_transitive(grades: int = 14) -> None:
    print("=" * 78)
    print("5.  Main theorem:  an eventually r-transitive family and its closed form")
    print("=" * 78)
    # A graded G-set whose grade n is a set of n points carrying the symmetric group
    # S_n; we take r = 3.  S_n is 3-transitive exactly when n >= 3, so the low grades
    # form a genuine transient and the onset index is N = 3.
    r = 3
    # For n <= 7 we compute the count honestly by the fixed-point formula; for larger
    # n the symmetric group is r-transitive (r <= n), so the count is 1 by the
    # transitivity criterion and enumerating S_n is unnecessary.
    counts = [trans_count_by_burnside(symmetric_group(n), n, r) if n <= 7 else 1
              for n in range(grades)]
    print(f"t_{r}(Y_n) with Y_n = n points and G = S_n:  {counts}")
    onset = next(n for n in range(grades) if all(counts[m] == 1 for m in range(n, grades)))
    print(f"Onset index N (least index from which all grades are {r}-transitive): {onset}")
    print(f"Numerator over (1-q):  {poly_to_string(numerator_coefficients(counts, 1))}")
    print(f"Numerator over (1-q)^{r+1}: "
          f"{poly_to_string(numerator_coefficients(counts, r + 1))}")
    print("(Degree bound N + r =", onset + r, ", comfortably satisfied.)")

    print("\nAnalytic form, exact rational arithmetic on |q| < 1:")
    print(f"{'q':>10} {'partial sum (200 terms)':>26} {'closed form':>26} {'match':>7}")
    long_counts = counts + [1] * 300
    for q in (Fraction(1, 3), Fraction(1, 2), Fraction(-1, 2), Fraction(3, 4)):
        approx = partial_sum(long_counts, q, 200)
        exact = closed_form_eventually_constant(long_counts, onset, 1, q)
        ok = abs(float(approx - exact)) < 1e-12
        print(f"{str(q):>10} {float(approx):>26.15f} {float(exact):>26.15f} {str(ok):>7}")
    print("\nThe closed form  sum_{n<N} t_r(Y_n) q^n + q^N/(1-q)  reproduces the series")
    print("to machine precision: one simple pole at q = 1, nothing else.\n")


def demo_coefficient_formula(grades: int = 10) -> None:
    print("=" * 78)
    print("6.  The coefficient formula  [q^{n+s}]((1-q)^s A(q)) = (Delta^s a)_n")
    print("=" * 78)
    a = [3 * n**3 - 2 * n + 7 for n in range(grades)]
    print(f"test sequence a_n = 3n^3 - 2n + 7:  {a}")
    for s in range(5):
        prod = series_times_one_minus_q_pow(a, s)
        diffs = difference_table(a, s)[s]
        shifted = prod[s:]
        matched = shifted[: len(diffs)] == diffs[: len(shifted)]
        print(f"s = {s}:  [q^(n+s)] = {shifted[:5]} ...   Delta^{s} a = {diffs[:5]} ..."
              f"   match: {matched}")
        assert matched
    print("\nMultiplying by (1-q)^s really is differencing s times, with a shift by s.")
    print("The 4th difference of a cubic vanishes, so the denominator is (1-q)^4.\n")


def demo_total_partition_function(r: int = 3, grades: int = 12) -> None:
    print("=" * 78)
    print("7.  Descent and the total partition function  sum_{k <= r} t_k")
    print("=" * 78)
    print(f"{'n':>3} " + " ".join(f"t_{k}".rjust(6) for k in range(r + 1)) + "   total")
    totals: List[int] = []
    for n in range(grades):
        g = symmetric_group(n) if n <= 6 else None
        if g is None:
            # For n > 6 enumerate S_n is too big; S_n is k-transitive for k <= n,
            # so all counts are 1 whenever n >= r.
            row = [1] * (r + 1)
        else:
            row = [trans_count_by_burnside(g, n, k) for k in range(r + 1)]
        totals.append(sum(row))
        print(f"{n:>3} " + " ".join(str(x).rjust(6) for x in row) + f"   {sum(row):>5}")
    print(f"\nBy the descent theorem, r-transitivity forces k-transitivity for k <= r,")
    print(f"so the totals settle at r + 1 = {r+1}.  Detected pole order:"
          f" {detect_pole_order(totals)} (expected 1).")
    print(f"Numerator over (1-q): {poly_to_string(numerator_coefficients(totals, 1))}\n")


def demo_burnside_degeneracy() -> None:
    print("=" * 78)
    print("8.  Burnside degeneracy:  sum_g |Fix_r(g)| = |G| exactly at r-transitivity")
    print("=" * 78)
    print(f"{'group':>16} {'n':>3} {'r':>2} {'sum_g |Fix_r|':>14} {'|G|':>7} "
          f"{'t_r':>5} {'avg':>7}")
    for name, gof, n in (
        ("S_5", symmetric_group, 5),
        ("S_6", symmetric_group, 6),
        ("cyclic Z/6Z", cyclic_group, 6),
        ("dihedral D_6", dihedral_group, 6),
    ):
        g = gof(n)
        for r in (1, 2):
            total = sum(desc_factorial(sum(1 for i in range(n) if p[i] == i), r)
                        for p in g)
            t = trans_count_by_burnside(g, n, r)
            print(f"{name:>16} {n:>3} {r:>2} {total:>14} {len(g):>7} {t:>5} "
                  f"{total / len(g):>7.3f}")
    print("\nWhenever the action is r-transitive the total is exactly |G|: the average")
    print("number of fixed injective r-tuples per group element is 1.\n")


def main() -> None:
    demo_orbit_counts_agree()
    demo_coefficient_formula()
    demo_trivial_action_sharpness()
    demo_binomial_model()
    demo_cyclic_intermediate()
    demo_eventually_transitive()
    demo_total_partition_function()
    demo_burnside_degeneracy()
    print("=" * 78)
    print("All assertions passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
