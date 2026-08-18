"""
Multiplicity calculus for finite families: numerical demonstration.
==================================================================

This self-contained script verifies, on explicit finite families, every result
of the theory of coverage multiplicity:

  * the two moment identities
        sum_{x in U} d(x)   = sum_i |A_i|                        (first)
        sum_{x in U} d(x)^2 = sum_{i,j} |A_i cap A_j|            (second)
  * the off-diagonal identity
        sum_{i != j} |A_i cap A_j| = sum_{x in U} d(x)(d(x)-1)
  * the Bonferroni defect identity
        S1 + sum_x (d-1)^2 = |U| + S2
  * the sharp Bonferroni defect identity
        2 S1 + sum_x (d-1)(d-2) = 2|U| + S2
  * the double-collision bound   2|D| <= S2
  * the Cauchy-Schwarz bound     S1^2 <= |U| * S2tot
  * the three rigidity theorems (tight iff disjoint / iff d<=2 / iff regular)
  * the stability theorem        (d(x)-d(y))^2 <= g
  * Corradi's inequality         k m^2 <= |U| (m + (k-1) t)   and its tightness
  * second-order indeterminacy   (triangle vs sunflower)
  * the marginal-order threshold (plain vs parity families, all k)

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Family = Sequence[Set[int]]


# ---------------------------------------------------------------------------
# Core multiplicity calculus
# ---------------------------------------------------------------------------

def multiplicity(family: Family) -> Dict[int, int]:
    """Return {x: d(x)} for every covered point x, where d(x) counts the
    members of the family containing x."""
    d: Dict[int, int] = {}
    for member in family:
        for x in member:
            d[x] = d.get(x, 0) + 1
    return d


def cover(family: Family) -> Set[int]:
    """The union of the family."""
    out: Set[int] = set()
    for member in family:
        out |= member
    return out


def double_collision(family: Family) -> Set[int]:
    """Points covered at least twice."""
    return {x for x, dx in multiplicity(family).items() if dx >= 2}


def sigma1(family: Family) -> int:
    """Sum of the first marginals, sum_i |A_i|."""
    return sum(len(member) for member in family)


def sigma2_offdiag(family: Family) -> int:
    """Off-diagonal pairwise-overlap mass, sum_{i != j} |A_i cap A_j|."""
    k = len(family)
    return sum(len(family[i] & family[j])
               for i in range(k) for j in range(k) if i != j)


def sigma2_total(family: Family) -> int:
    """Total ordered pairwise-overlap mass, sum_{i,j} |A_i cap A_j|."""
    k = len(family)
    return sum(len(family[i] & family[j]) for i in range(k) for j in range(k))


def bonferroni_defect(family: Family) -> int:
    """Irregularity functional sum_{x in U} (d(x) - 1)^2."""
    return sum((dx - 1) ** 2 for dx in multiplicity(family).values())


def sharp_defect(family: Family) -> int:
    """Sharp Bonferroni defect sum_{x in U} (d(x) - 1)(d(x) - 2)."""
    return sum((dx - 1) * (dx - 2) for dx in multiplicity(family).values())


def cs_gap(family: Family) -> int:
    """Cauchy-Schwarz gap g = |U| * S2tot - S1^2 (a nonnegative integer)."""
    return len(cover(family)) * sigma2_total(family) - sigma1(family) ** 2


def is_regular(family: Family) -> bool:
    """True iff the multiplicity is constant on the cover."""
    values = set(multiplicity(family).values())
    return len(values) <= 1


def is_pairwise_disjoint(family: Family) -> bool:
    k = len(family)
    return all(not (family[i] & family[j])
               for i in range(k) for j in range(k) if i != j)


def max_multiplicity(family: Family) -> int:
    d = multiplicity(family)
    return max(d.values()) if d else 0


def joint_marginal(family: Family, T: Iterable[int]) -> int:
    """|intersection over i in T of A_i|; the empty T is not used here."""
    idx = list(T)
    if not idx:
        raise ValueError("joint_marginal requires a nonempty subfamily")
    out = set(family[idx[0]])
    for i in idx[1:]:
        out &= family[i]
    return len(out)


def inclusion_exclusion_union(family: Family) -> int:
    """|U| recomputed from all joint marginals via inclusion-exclusion."""
    k = len(family)
    total = 0
    for r in range(1, k + 1):
        for T in itertools.combinations(range(k), r):
            total += (-1) ** (r + 1) * joint_marginal(family, T)
    return total


# ---------------------------------------------------------------------------
# Reporting helpers
# ---------------------------------------------------------------------------

def check(label: str, condition: bool, detail: str = "") -> None:
    mark = "OK " if condition else "FAIL"
    line = f"  [{mark}] {label}"
    if detail:
        line += f"   {detail}"
    print(line)
    if not condition:
        raise AssertionError(label)


def report(name: str, family: Family) -> None:
    """Print the full second-order dossier of a family and verify every
    identity and inequality of the theory on it."""
    U = cover(family)
    d = multiplicity(family)
    S1 = sigma1(family)
    S2 = sigma2_offdiag(family)
    S2t = sigma2_total(family)
    D = double_collision(family)
    g = cs_gap(family)
    profile = sorted((d[x] for x in U), reverse=True)

    print(f"\n=== {name} ===")
    print(f"  members            : {[sorted(m) for m in family]}")
    print(f"  |A_i|              : {[len(m) for m in family]}")
    print(f"  cover U            : {sorted(U)}   |U| = {len(U)}")
    print(f"  multiplicity profile: {profile}")
    print(f"  S1 = sum |A_i|     : {S1}")
    print(f"  S2 = offdiag mass  : {S2}")
    print(f"  S2tot (with diag)  : {S2t}")
    print(f"  |D| (double coll.) : {len(D)}  -> D = {sorted(D)}")
    print(f"  Bonferroni defect  : {bonferroni_defect(family)}")
    print(f"  sharp defect       : {sharp_defect(family)}")
    print(f"  Cauchy-Schwarz gap : {g}")

    # ---- moment identities
    check("first moment identity  sum_U d = S1",
          sum(d[x] for x in U) == S1,
          f"{sum(d[x] for x in U)} = {S1}")
    check("second moment identity sum_U d^2 = S2tot",
          sum(d[x] ** 2 for x in U) == S2t,
          f"{sum(d[x] ** 2 for x in U)} = {S2t}")
    check("off-diagonal identity  S2 = sum_U d(d-1)",
          sum(d[x] * (d[x] - 1) for x in U) == S2,
          f"{sum(d[x] * (d[x] - 1) for x in U)} = {S2}")

    # ---- defect identities
    check("Bonferroni defect identity  S1 + Irr = |U| + S2",
          S1 + bonferroni_defect(family) == len(U) + S2,
          f"{S1} + {bonferroni_defect(family)} = {len(U)} + {S2}")
    check("sharp defect identity  2 S1 + sharpIrr = 2|U| + S2",
          2 * S1 + sharp_defect(family) == 2 * len(U) + S2,
          f"{2 * S1} + {sharp_defect(family)} = {2 * len(U)} + {S2}")

    # ---- inequalities
    check("second Bonferroni  S1 <= |U| + S2", S1 <= len(U) + S2,
          f"{S1} <= {len(U) + S2}")
    check("sharp Bonferroni   2 S1 <= 2|U| + S2", 2 * S1 <= 2 * len(U) + S2,
          f"{2 * S1} <= {2 * len(U) + S2}")
    check("double collision   2|D| <= S2", 2 * len(D) <= S2,
          f"{2 * len(D)} <= {S2}")
    check("Cauchy-Schwarz     S1^2 <= |U| S2tot", S1 ** 2 <= len(U) * S2t,
          f"{S1 ** 2} <= {len(U) * S2t}")
    check("gap nonnegative", g >= 0, f"g = {g}")

    # ---- rigidity
    check("rigidity I:  Bonferroni tight  <=>  pairwise disjoint",
          (S1 == len(U) + S2) == is_pairwise_disjoint(family))
    check("rigidity II: sharp tight  <=>  double-collision tight  <=>  d <= 2",
          (2 * S1 == 2 * len(U) + S2)
          == (2 * len(D) == S2)
          == (max_multiplicity(family) <= 2))
    check("rigidity III: Cauchy-Schwarz tight  <=>  regular cover",
          (S1 ** 2 == len(U) * S2t) == is_regular(family))

    # ---- stability
    if U:
        worst = max((d[x] - d[y]) ** 2 for x in U for y in U)
        check("stability: max (d(x)-d(y))^2 <= g", worst <= g,
              f"{worst} <= {g}")
        check("integrality: g < 1  =>  regular", (g >= 1) or is_regular(family))
        if S1 == len(U):
            check("defect-gap link: |U| * Irr = g  (average multiplicity 1)",
                  len(U) * bonferroni_defect(family) == g)

    # ---- inclusion-exclusion consistency
    check("inclusion-exclusion reproduces |U|",
          inclusion_exclusion_union(family) == len(U),
          f"{inclusion_exclusion_union(family)} = {len(U)}")


# ---------------------------------------------------------------------------
# Corradi's inequality
# ---------------------------------------------------------------------------

def corradi_data(family: Family) -> Tuple[int, int, int, int]:
    """Return (k, m, t, |U|) with m the min first marginal and t the max
    off-diagonal second marginal."""
    k = len(family)
    m = min(len(member) for member in family) if k else 0
    t = max((len(family[i] & family[j])
             for i in range(k) for j in range(k) if i != j), default=0)
    return k, m, t, len(cover(family))


def corradi_check(name: str, family: Family) -> None:
    k, m, t, N = corradi_data(family)
    lhs = k * m * m
    rhs = N * (m + (k - 1) * t)
    status = "TIGHT" if lhs == rhs else "strict"
    bound = lhs / (m + (k - 1) * t) if (m + (k - 1) * t) else float("inf")
    print(f"  {name:<26} k={k} m={m} t={t} |U|={N}: "
          f"{lhs} <= {rhs}  [{status}]   |U| >= {bound:.4f}")
    assert lhs <= rhs, name


# ---------------------------------------------------------------------------
# The two three-set witnesses
# ---------------------------------------------------------------------------

TRIANGLE: List[Set[int]] = [{0, 1}, {1, 2}, {2, 0}]
SUNFLOWER: List[Set[int]] = [{0, 1}, {0, 2}, {0, 3}]


def demo_indeterminacy() -> None:
    print("\n" + "=" * 74)
    print("SECOND-ORDER MARGINALS DO NOT DETERMINE THE UNION")
    print("=" * 74)

    first_tri = [len(m) for m in TRIANGLE]
    first_sun = [len(m) for m in SUNFLOWER]
    second_tri = {(i, j): len(TRIANGLE[i] & TRIANGLE[j])
                  for i in range(3) for j in range(3)}
    second_sun = {(i, j): len(SUNFLOWER[i] & SUNFLOWER[j])
                  for i in range(3) for j in range(3)}

    print(f"  first marginals   triangle {first_tri}   sunflower {first_sun}")
    print(f"  second marginals identical: {second_tri == second_sun}")
    print(f"  |U| triangle  = {len(cover(TRIANGLE))}")
    print(f"  |U| sunflower = {len(cover(SUNFLOWER))}")
    check("identical first marginals", first_tri == first_sun)
    check("identical second marginals", second_tri == second_sun)
    check("different unions",
          len(cover(TRIANGLE)) != len(cover(SUNFLOWER)))
    print("  => no function of first- and second-order marginals can return |U|.")

    tri3 = joint_marginal(TRIANGLE, (0, 1, 2))
    sun3 = joint_marginal(SUNFLOWER, (0, 1, 2))
    print(f"  third-order marginals DO differ: {tri3} vs {sun3}")
    check("third-order marginals differ", tri3 != sun3)


# ---------------------------------------------------------------------------
# The parity construction: order < k is never enough
# ---------------------------------------------------------------------------

def parity_construction(k: int) -> Tuple[List[Set[int]], List[Set[int]]]:
    """Build the plain and parity families of k sets on the ground set
    P({0,...,k-1}) x {0,1}, encoded as integers.

    Ground point (S, b) is encoded as the integer 2 * bitmask(S) + b.
    plain_i  = {(S, 0) : i in S}
    parity_i = {(S, b) : i in S, |S| = k (mod 2)}
    """
    plain: List[Set[int]] = [set() for _ in range(k)]
    parity: List[Set[int]] = [set() for _ in range(k)]
    for mask in range(1 << k):
        size = bin(mask).count("1")
        right_parity = (size + k) % 2 == 0
        for i in range(k):
            if mask >> i & 1:
                plain[i].add(2 * mask)
                if right_parity:
                    parity[i].add(2 * mask)
                    parity[i].add(2 * mask + 1)
    return plain, parity


def demo_marginal_threshold(kmax: int = 6) -> None:
    print("\n" + "=" * 74)
    print("MARGINAL-ORDER THRESHOLD: ORDER < k NEVER DETERMINES THE UNION")
    print("=" * 74)
    print(f"  {'k':>2} {'|U| plain':>10} {'|U| parity':>11} "
          f"{'orders <k agree':>16} {'top order':>18}")
    for k in range(1, kmax + 1):
        plain, parity = parity_construction(k)
        agree = True
        for r in range(1, k):
            for T in itertools.combinations(range(k), r):
                if joint_marginal(plain, T) != joint_marginal(parity, T):
                    agree = False
        top_p = joint_marginal(plain, range(k))
        top_q = joint_marginal(parity, range(k))
        up, uq = len(cover(plain)), len(cover(parity))
        print(f"  {k:>2} {up:>10} {uq:>11} {str(agree):>16} "
              f"{f'{top_p} vs {top_q}':>18}")
        check(f"k={k}: all marginals of order < k agree", agree)
        check(f"k={k}: top-order marginals differ", top_p != top_q)
        check(f"k={k}: unions differ", up != uq)
        check(f"k={k}: plain cover is 2^k - 1", up == (1 << k) - 1)
        check(f"k={k}: parity cover is even", uq % 2 == 0)


# ---------------------------------------------------------------------------
# Corradi tightness at both ends of the correlation scale
# ---------------------------------------------------------------------------

def demo_corradi() -> None:
    print("\n" + "=" * 74)
    print("CORRADI'S INEQUALITY  k m^2 <= |U| (m + (k-1) t)")
    print("=" * 74)

    # t = 0 : pairwise disjoint m-sets  -> TIGHT
    k, m = 4, 3
    disjoint = [set(range(i * m, (i + 1) * m)) for i in range(k)]
    corradi_check("disjoint (t = 0)", disjoint)

    # t = m : all members equal        -> TIGHT
    identical = [set(range(m)) for _ in range(k)]
    corradi_check("identical (t = m)", identical)

    # interior tight example: the triangle (a regular cover)
    corradi_check("triangle (regular)", TRIANGLE)

    # interior strict example: the sunflower, SAME (k, m, t)
    corradi_check("sunflower (irregular)", SUNFLOWER)

    print("  Triangle and sunflower share (k,m,t) = (3,2,1); the regular one is")
    print("  tight and the irregular one is strict -- exactly as rigidity predicts.")

    print("\n  Fisher-type bound  k (m^2 - N t) <= N (m - t)  in the design regime:")
    for fam, label in ((disjoint, "disjoint"), (TRIANGLE, "triangle")):
        k, m, t, N = corradi_data(fam)
        if t <= m and N * t < m * m:
            lhs = k * (m * m - N * t)
            rhs = N * (m - t)
            print(f"    {label:<10} k={k} m={m} t={t} N={N}: {lhs} <= {rhs}")
            assert lhs <= rhs
        else:
            print(f"    {label:<10} k={k} m={m} t={t} N={N}: "
                  f"outside the design regime (N t = {N * t} >= m^2 = {m * m})")


# ---------------------------------------------------------------------------
# Randomised stress test
# ---------------------------------------------------------------------------

def random_family(rng: random.Random, k: int, n: int) -> List[Set[int]]:
    return [set(x for x in range(n) if rng.random() < 0.4) for _ in range(k)]


def demo_random_stress(trials: int = 3000, seed: int = 20260818) -> None:
    print("\n" + "=" * 74)
    print(f"RANDOMISED STRESS TEST ({trials} random families)")
    print("=" * 74)
    rng = random.Random(seed)
    tight_bonf = tight_sharp = tight_cs = 0
    worst_spread_ratio = 0.0
    for _ in range(trials):
        k = rng.randint(1, 5)
        n = rng.randint(1, 8)
        fam = random_family(rng, k, n)
        U = cover(fam)
        d = multiplicity(fam)
        S1, S2, S2t = sigma1(fam), sigma2_offdiag(fam), sigma2_total(fam)
        g = cs_gap(fam)

        assert S1 + bonferroni_defect(fam) == len(U) + S2
        assert 2 * S1 + sharp_defect(fam) == 2 * len(U) + S2
        assert 2 * len(double_collision(fam)) <= S2
        assert S1 ** 2 <= len(U) * S2t
        assert g >= 0
        assert inclusion_exclusion_union(fam) == len(U)
        assert (S1 == len(U) + S2) == is_pairwise_disjoint(fam)
        assert ((2 * S1 == 2 * len(U) + S2)
                == (max_multiplicity(fam) <= 2))
        assert (S1 ** 2 == len(U) * S2t) == is_regular(fam)
        for x in U:
            for y in U:
                assert (d[x] - d[y]) ** 2 <= g
        if g < 1:
            assert is_regular(fam)

        if U:
            spread = max(d.values()) - min(d.values())
            if g > 0:
                worst_spread_ratio = max(worst_spread_ratio,
                                         spread / math.sqrt(g))
        tight_bonf += S1 == len(U) + S2
        tight_sharp += 2 * S1 == 2 * len(U) + S2
        tight_cs += S1 ** 2 == len(U) * S2t

    print("  all identities, inequalities, rigidity and stability claims hold.")
    print(f"  Bonferroni-tight (disjoint)      : {tight_bonf}/{trials}")
    print(f"  sharp-tight (multiplicity <= 2)  : {tight_sharp}/{trials}")
    print(f"  Cauchy-Schwarz-tight (regular)   : {tight_cs}/{trials}")
    print(f"  worst observed spread / sqrt(g)  : {worst_spread_ratio:.4f}  (<= 1)")
    assert worst_spread_ratio <= 1.0 + 1e-12


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 74)
    print("MULTIPLICITY CALCULUS FOR FINITE FAMILIES -- NUMERICAL DEMONSTRATION")
    print("=" * 74)

    report("Triangle  A0={0,1}, A1={1,2}, A2={2,0}", TRIANGLE)
    report("Sunflower B0={0,1}, B1={0,2}, B2={0,3}", SUNFLOWER)
    report("Partition {0,1,2}, {3,4}, {5}",
           [{0, 1, 2}, {3, 4}, {5}])
    report("Mixed-multiplicity quad  (profile 3,1,3,1,3,1)",
           [{0, 1, 2}, {2, 3, 4}, {4, 5, 0}, {0, 2, 4}])
    report("Three identical sets {0,1,2}",
           [{0, 1, 2}, {0, 1, 2}, {0, 1, 2}])

    demo_indeterminacy()
    demo_corradi()
    demo_marginal_threshold(kmax=6)
    demo_random_stress()

    print("\n" + "=" * 74)
    print("ALL CHECKS PASSED")
    print("=" * 74)


if __name__ == "__main__":
    main()
