"""
Moonshine beyond the j-function: numerical demonstrations.

Self-contained Python (standard library only) illustrating, on explicit finite
group actions and explicit formal Laurent series:

  1. The moment hierarchy      sum_g |X^g|^k = |G| * #(X^k / G).
  2. Bell numbers as counts of restricted growth functions (kernel patterns).
  3. The universal Bell floor  B_k * |G| <= sum_g |X^g|^k   (for k <= |X|),
     with equality exactly for k-transitive actions.
  4. The exact Bell defect     sum_g |X^g|^k - B_k |G| = |G| * sum_P (m_P - 1),
     where m_P is the number of orbits of k-tuples with kernel pattern P.
  5. Moment inversion: the first N+1 power sums of a function bounded by N
     determine its value multiset (exact Vandermonde solve), and the range is
     sharp.
  6. The Klein four-group blind spot: two non-isomorphic actions with identical
     trace distributions and identical orbit counts on k-tuples for all k.
  7. Laurent normalization: a product of m series of order -1 has order -m
     (a 194-fold "Monster-sized" product has a pole of order 194), the
     renormalized product q^m * prod f_i realizes exactly the order-0 series,
     and no permutation-invariant aggregate of m >= 2 series is injective,
     while the interleaving aggregate is.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, permutations, product
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]  # perm[i] = image of point i


# --------------------------------------------------------------------------
# 1. Finite permutation groups given as explicit lists of permutations
# --------------------------------------------------------------------------

def symmetric_group(n: int) -> List[Perm]:
    """All n! permutations of {0, ..., n-1}."""
    return [tuple(p) for p in permutations(range(n))]


def cyclic_group(n: int) -> List[Perm]:
    """The n rotations of a cycle on {0, ..., n-1}."""
    return [tuple((i + s) % n for i in range(n)) for s in range(n)]


def dihedral_group(n: int) -> List[Perm]:
    """The 2n symmetries of a regular n-gon acting on its vertices."""
    rots = [tuple((i + s) % n for i in range(n)) for s in range(n)]
    refs = [tuple((s - i) % n for i in range(n)) for s in range(n)]
    return rots + refs


def alternating_group(n: int) -> List[Perm]:
    """The even permutations of {0, ..., n-1}."""
    def sign(p: Perm) -> int:
        s = 1
        for i, j in combinations(range(len(p)), 2):
            if p[i] > p[j]:
                s = -s
        return s
    return [p for p in symmetric_group(n) if sign(p) == 1]


def affine_group(p: int) -> List[Perm]:
    """AGL(1, p) = {x -> a x + b : a != 0} acting on Z/p; sharply 2-transitive."""
    return [tuple((a * x + b) % p for x in range(p))
            for a in range(1, p) for b in range(p)]


def klein_first_factor() -> List[Perm]:
    """Klein four-group S_2 x S_2 acting on 2 points through the FIRST factor."""
    ident: Perm = (0, 1)
    swap: Perm = (1, 0)
    return [ident, swap, ident, swap]  # (g1, g2) |-> action of g1


def klein_second_factor() -> List[Perm]:
    """Klein four-group S_2 x S_2 acting on 2 points through the SECOND factor.

    The group elements are listed in the same order (g1, g2) as above:
    (1,1), (swap,1), (1,swap), (swap,swap).
    """
    ident: Perm = (0, 1)
    swap: Perm = (1, 0)
    return [ident, ident, swap, swap]


# --------------------------------------------------------------------------
# 2. Fixed points, moments, orbits
# --------------------------------------------------------------------------

def fixed_point_count(g: Perm) -> int:
    """|X^g|: the number of points left alone by g."""
    return sum(1 for i, gi in enumerate(g) if gi == i)


def moment(group: Sequence[Perm], k: int) -> int:
    """The k-th moment sum_{g in G} |X^g|^k of the fixed-point (trace) function."""
    return sum(fixed_point_count(g) ** k for g in group)


def orbits_on_tuples(group: Sequence[Perm], n: int, k: int) -> List[List[Tuple[int, ...]]]:
    """All orbits of the diagonal action of G on the set of k-tuples from {0..n-1}."""
    seen: Dict[Tuple[int, ...], bool] = {}
    orbits: List[List[Tuple[int, ...]]] = []
    for t in product(range(n), repeat=k):
        if t in seen:
            continue
        orbit = sorted({tuple(g[x] for x in t) for g in group})
        for s in orbit:
            seen[s] = True
        orbits.append(orbit)
    return orbits


def orbit_count_on_tuples(group: Sequence[Perm], n: int, k: int) -> int:
    """#(X^k / G), computed by brute-force orbit enumeration."""
    return len(orbits_on_tuples(group, n, k))


# --------------------------------------------------------------------------
# 3. Patterns (restricted growth functions) and Bell numbers
# --------------------------------------------------------------------------

def kernel_pattern(t: Sequence[int]) -> Tuple[int, ...]:
    """Kernel pattern of a tuple: index i |-> least j with t[j] == t[i]."""
    return tuple(min(j for j in range(len(t)) if t[j] == t[i]) for i in range(len(t)))


def is_pattern(p: Sequence[int]) -> bool:
    """A restricted growth function: p(i) <= i and p(p(i)) = p(i)."""
    return all(p[i] <= i for i in range(len(p))) and all(p[p[i]] == p[i] for i in range(len(p)))


def all_patterns(k: int) -> List[Tuple[int, ...]]:
    """Every restricted growth function on {0, ..., k-1}; there are B_k of them."""
    return [p for p in product(range(max(k, 1)), repeat=k) if is_pattern(p)]


def bell(k: int) -> int:
    """The k-th Bell number, as the number of patterns on a k-element set."""
    return len(all_patterns(k))


def bell_recurrence(k: int) -> int:
    """B_k via B_{m+1} = sum_j C(m, j) B_j -- an independent cross-check."""
    from math import comb
    b: List[int] = [1]
    for m in range(k):
        b.append(sum(comb(m, j) * b[j] for j in range(m + 1)))
    return b[k]


def pattern_multiplicities(group: Sequence[Perm], n: int, k: int) -> Dict[Tuple[int, ...], int]:
    """m_P: the number of orbits of k-tuples whose kernel pattern is P."""
    counts: Dict[Tuple[int, ...], int] = {p: 0 for p in all_patterns(k)}
    for orbit in orbits_on_tuples(group, n, k):
        counts[kernel_pattern(orbit[0])] += 1
    return counts


def is_k_transitive(group: Sequence[Perm], n: int, k: int) -> bool:
    """Direct test: can every injective k-tuple be carried to every other?"""
    injective = [t for t in product(range(n), repeat=k) if len(set(t)) == k]
    if not injective:
        return True
    base = injective[0]
    reachable = {tuple(g[x] for x in base) for g in group}
    return all(t in reachable for t in injective)


# --------------------------------------------------------------------------
# 4. Moment inversion (exact Vandermonde solve over the rationals)
# --------------------------------------------------------------------------

def power_sums(values: Sequence[int], n_max: int) -> List[int]:
    """The power sums s_k = sum_i values[i]^k for 0 <= k <= n_max."""
    return [sum(v ** k for v in values) for k in range(n_max + 1)]


def solve_exact(matrix: List[List[Fraction]], rhs: List[Fraction]) -> List[Fraction]:
    """Exact Gaussian elimination over the rationals."""
    size = len(rhs)
    aug: List[List[Fraction]] = [row[:] + [rhs[i]] for i, row in enumerate(matrix)]
    for col in range(size):
        pivot = next(r for r in range(col, size) if aug[r][col] != 0)
        aug[col], aug[pivot] = aug[pivot], aug[col]
        inv = Fraction(1, 1) / aug[col][col]
        aug[col] = [entry * inv for entry in aug[col]]
        for r in range(size):
            if r != col and aug[r][col] != 0:
                factor = aug[r][col]
                aug[r] = [a - factor * b for a, b in zip(aug[r], aug[col])]
    return [aug[r][size] for r in range(size)]


def recover_distribution(sums: Sequence[int], n_max: int) -> List[int]:
    """Recover the counting vector (c_0, ..., c_N) from the power sums s_0..s_N.

    The system is sum_v v^k c_v = s_k, a transposed Vandermonde system with the
    distinct nodes 0, 1, ..., N; it is invertible, and the solution is integral.
    """
    mat = [[Fraction(v ** k) for v in range(n_max + 1)] for k in range(n_max + 1)]
    sol = solve_exact(mat, [Fraction(s) for s in sums])
    assert all(x.denominator == 1 for x in sol), "counting vector must be integral"
    return [int(x) for x in sol]


# --------------------------------------------------------------------------
# 5. Formal Laurent series with integer exponents
# --------------------------------------------------------------------------

Series = Dict[int, int]  # exponent -> coefficient (nonzero entries only)


def series_clean(f: Series) -> Series:
    return {n: c for n, c in f.items() if c != 0}


def series_order(f: Series) -> float:
    """Order at the cusp: the least exponent with a nonzero coefficient."""
    g = series_clean(f)
    return min(g) if g else float("inf")


def series_mul(f: Series, g: Series, truncate: int = 40) -> Series:
    """Product of two Laurent series, truncated above exponent `truncate`."""
    out: Series = {}
    for a, ca in f.items():
        for b, cb in g.items():
            if a + b <= truncate:
                out[a + b] = out.get(a + b, 0) + ca * cb
    return series_clean(out)


def series_shift(f: Series, m: int) -> Series:
    """Multiply by q^m."""
    return {n + m: c for n, c in f.items()}


def interleave(family: Sequence[Series], m: int) -> Series:
    """The label-remembering aggregate: coefficient c^(i)_n goes to exponent m*n + i."""
    out: Series = {}
    for i, f in enumerate(family):
        for n, c in f.items():
            out[m * n + i] = out.get(m * n + i, 0) + c
    return series_clean(out)


def de_interleave(agg: Series, m: int, i: int) -> Series:
    """Read the i-th member back out of the interleaved aggregate."""
    return series_clean({(n - i) // m: c for n, c in agg.items() if (n - i) % m == 0})


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def banner(text: str) -> None:
    print("\n" + "=" * 78)
    print(text)
    print("=" * 78)


def demo_moment_hierarchy() -> None:
    banner("1. MOMENT HIERARCHY:  sum_g |X^g|^k  =  |G| * #(X^k / G)")
    cases: List[Tuple[str, List[Perm], int]] = [
        ("S_4 on 4 points", symmetric_group(4), 4),
        ("A_4 on 4 points", alternating_group(4), 4),
        ("C_5 on 5 points", cyclic_group(5), 5),
        ("D_4 on 4 vertices", dihedral_group(4), 4),
        ("AGL(1,5) on 5 points", affine_group(5), 5),
    ]
    for name, grp, n in cases:
        print(f"\n{name}   |G| = {len(grp)}")
        print("   k |   sum_g |X^g|^k | #(X^k/G) | |G|*#(X^k/G) | identity holds")
        for k in range(0, 5):
            lhs = moment(grp, k)
            orb = orbit_count_on_tuples(grp, n, k)
            print(f"   {k} | {lhs:15d} | {orb:8d} | {len(grp) * orb:12d} |"
                  f" {'yes' if lhs == len(grp) * orb else 'NO':>5}")
            assert lhs == len(grp) * orb


def demo_bell_numbers() -> None:
    banner("2. BELL NUMBERS AS KERNEL PATTERNS (restricted growth functions)")
    print("   k | #patterns | recurrence | example patterns")
    for k in range(0, 7):
        pats = all_patterns(k)
        sample = ", ".join("".join(map(str, p)) for p in pats[:4])
        print(f"   {k} | {len(pats):9d} | {bell_recurrence(k):10d} | {sample}")
        assert len(pats) == bell_recurrence(k)
    print("\n   Kernel patterns of some 4-tuples:")
    for t in [(7, 7, 3, 7), (1, 2, 3, 4), (5, 5, 5, 5), (2, 9, 9, 2)]:
        print(f"      {t} -> {''.join(map(str, kernel_pattern(t)))}")


def demo_bell_floor_and_transitivity() -> None:
    banner("3. BELL FLOOR AND THE k-TRANSITIVITY CRITERION")
    print("   sum_g |X^g|^k >= B_k |G|, with equality iff the action is k-transitive.\n")
    cases: List[Tuple[str, List[Perm], int]] = [
        ("S_5 on 5 points", symmetric_group(5), 5),
        ("A_5 on 5 points", alternating_group(5), 5),
        ("AGL(1,5) on 5 points", affine_group(5), 5),
        ("D_5 on 5 vertices", dihedral_group(5), 5),
        ("C_5 on 5 points", cyclic_group(5), 5),
    ]
    for name, grp, n in cases:
        print(f"{name}  (|G| = {len(grp)})")
        print("   k | B_k |    B_k*|G| |  k-th moment | equality | k-transitive?")
        for k in range(1, min(n, 5) + 1):
            mom = moment(grp, k)
            floor = bell(k) * len(grp)
            trans = is_k_transitive(grp, n, k)
            assert mom >= floor
            assert (mom == floor) == trans
            print(f"   {k} | {bell(k):3d} | {floor:10d} | {mom:12d} |"
                  f" {'yes' if mom == floor else 'no':>8} | {'yes' if trans else 'no'}")
        print()


def demo_bell_defect() -> None:
    banner("4. THE EXACT BELL DEFECT:  D_k = |G| * sum_P (m_P - 1)")
    cases: List[Tuple[str, List[Perm], int]] = [
        ("C_4 on 4 points", cyclic_group(4), 4),
        ("D_4 on 4 vertices", dihedral_group(4), 4),
        ("A_4 on 4 points", alternating_group(4), 4),
        ("C_6 on 6 points", cyclic_group(6), 6),
    ]
    for name, grp, n in cases:
        print(f"\n{name}  (|G| = {len(grp)})")
        for k in (2, 3):
            mult = pattern_multiplicities(grp, n, k)
            defect = moment(grp, k) - bell(k) * len(grp)
            predicted = len(grp) * sum(m - 1 for m in mult.values())
            spectrum = {"".join(map(str, p)): m for p, m in sorted(mult.items())}
            print(f"   k = {k}:  fibre spectrum (m_P) = {spectrum}")
            print(f"            D_k = {defect}   |G| * sum (m_P - 1) = {predicted}")
            assert defect == predicted
            assert all(m >= 1 for m in mult.values())


def demo_moment_inversion() -> None:
    banner("5. MOMENTS DETERMINE THE TRACE DISTRIBUTION (Vandermonde inversion)")
    grp, n = dihedral_group(6), 6
    values = [fixed_point_count(g) for g in grp]
    n_max = n
    sums = power_sums(values, n_max)
    counts = recover_distribution(sums, n_max)
    print(f"D_6 on 6 vertices: fixed-point values = {sorted(values, reverse=True)}")
    print(f"power sums s_0..s_{n_max} = {sums}")
    print("recovered counting vector c_v = #{g : |X^g| = v}:")
    for v, c in enumerate(counts):
        if c:
            print(f"   v = {v}:  {c} group elements")
    true_counts = [sum(1 for v in values if v == w) for w in range(n_max + 1)]
    assert counts == true_counts
    print("recovery matches the true distribution:", counts == true_counts)

    print("\nSharpness: the range k <= N cannot be shortened.")
    a, b = [0, 2], [1, 1]
    print(f"   a = {a}, b = {b}, both bounded by N = 2")
    for k in range(0, 3):
        print(f"   k = {k}:  sum a^k = {sum(x ** k for x in a)},"
              f"  sum b^k = {sum(x ** k for x in b)}")
    assert sum(a) == sum(b) and sorted(a) != sorted(b)
    print("   equal for k <= 1, different distributions: the top moment is needed.")


def demo_klein_blind_spot() -> None:
    banner("6. THE BLIND SPOT: EQUAL TRACE DATA, NON-ISOMORPHIC ACTIONS")
    first, second = klein_first_factor(), klein_second_factor()
    tf = sorted((fixed_point_count(g) for g in first), reverse=True)
    ts = sorted((fixed_point_count(g) for g in second), reverse=True)
    print(f"Klein four-group V = S_2 x S_2 acting on two points.")
    print(f"   trace distribution through 1st factor: {tf}")
    print(f"   trace distribution through 2nd factor: {ts}")
    assert tf == ts
    print("   k | #(X^k/V) | #(Y^k/V)")
    for k in range(1, 6):
        ox = orbit_count_on_tuples(first, 2, k)
        oy = orbit_count_on_tuples(second, 2, k)
        print(f"   {k} | {ox:8d} | {oy:8d}")
        assert ox == oy
    # No equivariant bijection: element index 1 is (swap, 1).
    witness = 1
    print(f"\nYet no equivariant bijection exists: group element #{witness} = (swap, 1)")
    print(f"   moves every point of the first action  (|X^g| = {fixed_point_count(first[witness])})")
    print(f"   fixes every point of the second action (|Y^g| = {fixed_point_count(second[witness])})")
    assert fixed_point_count(first[witness]) != fixed_point_count(second[witness])
    print("   so the two G-sets are not isomorphic, though all their moments agree.")


def demo_laurent_products() -> None:
    banner("7. POLE ORDERS, RENORMALIZATION, AND AGGREGATION")
    q_inv: Series = {-1: 1}
    print(f"order(q^-1) = {series_order(q_inv)}")

    m = 194  # number of Monster conjugacy classes
    order_product = sum(-1 for _ in range(m))
    print(f"\nA product of m = {m} normalized series (each of order -1):")
    print(f"   order of the product      = {order_product}")
    print(f"   order after multiplying by q^{m} = {order_product + m}")
    # verified concretely on a small product
    small = 5
    prod: Series = {0: 1}
    for i in range(small):
        prod = series_mul(prod, {-1: 1, 0: i + 1})
    print(f"   concrete check with m = {small}: order = {series_order(prod)}"
          f", after renormalizing = {series_order(series_shift(prod, small))}")
    assert series_order(prod) == -small
    assert series_order(series_shift(prod, small)) == 0

    print("\nEvery order-0 series is a renormalized product: take f_1 = q^-1 F, f_i = q^-1.")
    target: Series = {0: 1, 1: -3, 2: 7, 3: 11}
    mm = 4
    family: List[Series] = [series_mul({-1: 1}, target)] + [{-1: 1}] * (mm - 1)
    rebuilt: Series = {0: 1}
    for f in family:
        rebuilt = series_mul(rebuilt, f)
    rebuilt = series_shift(rebuilt, mm)
    print(f"   F              = {dict(sorted(target.items()))}")
    print(f"   q^m * prod f_i = {dict(sorted(rebuilt.items()))}")
    print(f"   all factors normalized: {all(series_order(f) == -1 for f in family)}")
    assert rebuilt == series_clean(target)

    print("\nNon-uniqueness: flipping the sign of two factors gives the same product.")
    f1, f2 = {-1: 1, 0: 2}, {-1: 3, 1: -1}
    p1 = series_mul(f1, f2)
    p2 = series_mul({n: -c for n, c in f1.items()}, {n: -c for n, c in f2.items()})
    print(f"   f1*f2 == (-f1)*(-f2): {p1 == p2}")
    assert p1 == p2

    print("\nNo permutation-invariant aggregate is injective (m >= 2):")
    fam_a: List[Series] = [{-1: 1}, {-1: 2}]
    fam_b: List[Series] = [{-1: 2}, {-1: 1}]
    prod_a = series_mul(fam_a[0], fam_a[1])
    prod_b = series_mul(fam_b[0], fam_b[1])
    print(f"   family A = {fam_a}\n   family B = {fam_b}  (a transposition of A)")
    print(f"   products equal: {prod_a == prod_b}   families equal: {fam_a == fam_b}")
    assert prod_a == prod_b and fam_a != fam_b

    print("\nThe interleaving aggregate is injective (hence not symmetric):")
    agg_a = interleave(fam_a, 2)
    agg_b = interleave(fam_b, 2)
    print(f"   Int(A) = {dict(sorted(agg_a.items()))}")
    print(f"   Int(B) = {dict(sorted(agg_b.items()))}")
    print(f"   distinct aggregates: {agg_a != agg_b}")
    assert agg_a != agg_b
    for i, f in enumerate(fam_a):
        assert de_interleave(agg_a, 2, i) == series_clean(f)
    print("   each member is recovered exactly from Int(A) by reading one residue class.")


def demo_symmetric_group_bell_moments() -> None:
    banner("8. MOMENTS OF FIXED POINTS OF A RANDOM PERMUTATION:  sum_sigma |fix|^k = B_k n!")
    print("   n |  k |   sum_sigma |fix(sigma)|^k |      B_k * n!")
    for n in range(2, 8):
        grp = symmetric_group(n)
        for k in range(1, n + 1):
            lhs = moment(grp, k)
            rhs = bell_recurrence(k) * len(grp)
            assert lhs == rhs
            print(f"   {n} | {k:2d} | {lhs:26d} | {rhs:14d}")
        print()


def main() -> None:
    demo_moment_hierarchy()
    demo_bell_numbers()
    demo_bell_floor_and_transitivity()
    demo_bell_defect()
    demo_moment_inversion()
    demo_klein_blind_spot()
    demo_laurent_products()
    demo_symmetric_group_bell_moments()
    banner("ALL DEMONSTRATIONS COMPLETED — every asserted identity verified.")


if __name__ == "__main__":
    main()
