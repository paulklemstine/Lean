#!/usr/bin/env python3
"""
Numerical demonstrations for
"Which Marginals Feed the Machine? Second-Moment Union Bounds, Exact Collision
Marginals, and an Unconditional Converse for Random Hashing".

Everything here is self-contained: no third-party dependencies, no imports
beyond the standard library.  Each section verifies, by explicit enumeration or
exact rational arithmetic, one of the results of the paper.

Sections
--------
 1. Chung-Erdos inequality in exact counting form, on random set families.
 2. The abstract marginal-profile bound, its sharpness, and the failure of the
    Bonferroni-shaped conclusion on the extremal constant family.
 3. The exact failure law of a uniformly random codebook, by brute force.
 4. The four-term hierarchy  k/(2M) <= k/(M+k-1) <= P[fail] <= k/M.
 5. The component law for collision-pattern marginals, by brute force.
 6. Exact derandomisation versus the classical union-bound derandomisation.
"""

from __future__ import annotations

import itertools
import random
from fractions import Fraction
from typing import Dict, Iterable, Iterator, List, Sequence, Set, Tuple

# --------------------------------------------------------------------------- #
# Section 1.  The Chung-Erdos inequality in exact counting form.
#
#     (sum_i |A_i|)^2  <=  |union_i A_i| * sum_{i,j} |A_i cap A_j|
#
# Proof idea (double count): with f(w) = #{i : w in A_i} the multiplicity
# function on the union U, one has sum_i |A_i| = sum_{w in U} f(w) and
# sum_{i,j} |A_i cap A_j| = sum_{w in U} f(w)^2, so the statement is exactly
# Cauchy-Schwarz for f against the constant 1 on U.
# --------------------------------------------------------------------------- #


def chung_erdos_sides(family: Sequence[Set[int]]) -> Tuple[int, int]:
    """Return (LHS, RHS) of the Chung-Erdos counting inequality."""
    lhs = sum(len(a) for a in family) ** 2
    union: Set[int] = set().union(*family) if family else set()
    rhs = len(union) * sum(len(a & b) for a in family for b in family)
    return lhs, rhs


def multiplicity_identities(family: Sequence[Set[int]]) -> Tuple[bool, bool]:
    """Check the two double-counting identities behind the inequality."""
    union: Set[int] = set().union(*family) if family else set()
    mult: Dict[int, int] = {w: sum(1 for a in family if w in a) for w in union}
    first = sum(len(a) for a in family) == sum(mult.values())
    second = sum(len(a & b) for a in family for b in family) == sum(
        m * m for m in mult.values()
    )
    return first, second


def demo_chung_erdos(trials: int = 2000, seed: int = 20260822) -> None:
    print("=" * 74)
    print("1.  Chung-Erdos inequality in exact counting form")
    print("=" * 74)
    rng = random.Random(seed)
    worst_ratio = 0.0
    worst_case: Tuple[int, int] = (0, 0)
    for _ in range(trials):
        n = rng.randint(1, 12)          # universe size
        k = rng.randint(1, 6)           # number of sets
        family = [
            {w for w in range(n) if rng.random() < rng.choice([0.2, 0.5, 0.8])}
            for _ in range(k)
        ]
        if not any(family):
            continue
        lhs, rhs = chung_erdos_sides(family)
        assert lhs <= rhs, (family, lhs, rhs)
        f1, f2 = multiplicity_identities(family)
        assert f1 and f2, family
        if rhs and lhs / rhs > worst_ratio:
            worst_ratio, worst_case = lhs / rhs, (lhs, rhs)
    print(f"  {trials} random families tested; inequality held in every case.")
    print("  Both double-counting identities verified in every case.")
    print(f"  Tightest observed: LHS/RHS = {worst_ratio:.6f}  {worst_case}")
    # Equality case: a family of pairwise disjoint sets of equal size, k=1.
    single = [{0, 1, 2}]
    print(f"  Equality for a single set: {chung_erdos_sides(single)}")
    print()


# --------------------------------------------------------------------------- #
# Section 2.  The marginal-profile theorem.
#
#   first marginal exactly 1/m  (m |A_i| = N),
#   pairwise marginal at most 1/c  (c |A_i cap A_j| <= N for i != j)
#        ==>  c k N <= m |U| (c + m (k-1)),   with NO restriction on k.
#
# The constant family (k copies of one atom in a universe of size N = m = c)
# attains it with equality, and simultaneously refutes the Bonferroni-shaped
# conclusion |U| >= k N / (2 m).
# --------------------------------------------------------------------------- #


def marginal_profile(
    family: Sequence[Set[int]], universe_size: int
) -> Tuple[int, int] | None:
    """Return (m, c) if a uniform first marginal exists, else None.

    m is defined by m*|A_i| = N for all i (must be an exact common integer);
    c is the largest integer with c*|A_i cap A_j| <= N for all i != j.
    """
    sizes = {len(a) for a in family}
    if len(sizes) != 1:
        return None
    size = sizes.pop()
    if size == 0 or universe_size % size:
        return None
    m = universe_size // size
    pairs = [
        len(family[i] & family[j])
        for i in range(len(family))
        for j in range(len(family))
        if i != j
    ]
    if not pairs:
        return None
    worst = max(pairs)
    if worst == 0:
        return None
    c = universe_size // worst
    return m, c


def profile_bound_sides(
    m: int, c: int, k: int, n: int, union_size: int
) -> Tuple[int, int]:
    """Return (LHS, RHS) of  c k N <= m |U| (c + m(k-1))."""
    return c * k * n, m * union_size * (c + m * (k - 1))


def demo_marginal_profile(trials: int = 3000, seed: int = 11) -> None:
    print("=" * 74)
    print("2.  The marginal-profile theorem, its sharpness, and necessity")
    print("=" * 74)
    rng = random.Random(seed)
    checked = 0
    for _ in range(trials):
        n = rng.randint(2, 10)
        k = rng.randint(2, 6)
        size = rng.choice([d for d in range(1, n + 1) if n % d == 0])
        family = [set(rng.sample(range(n), size)) for _ in range(k)]
        prof = marginal_profile(family, n)
        if prof is None:
            continue
        m, c = prof
        union = set().union(*family)
        lhs, rhs = profile_bound_sides(m, c, k, n, len(union))
        assert lhs <= rhs, (family, m, c, k, n, len(union))
        checked += 1
    print(f"  {checked} random families with a uniform first marginal tested;")
    print("  the marginal-profile inequality held in every case.")

    # The extremal constant family: N = m = c = 2, k = 3, all sets = {0}.
    n, k = 2, 3
    family = [{0} for _ in range(k)]
    m, c = 2, 2
    union = set().union(*family)
    lhs, rhs = profile_bound_sides(m, c, k, n, len(union))
    print()
    print("  Extremal constant family:  N = 2, m = c = 2, k = 3, A_i = {0}")
    print(f"    marginal-profile bound:  c k N = {lhs}   vs   m|U|(c+m(k-1)) = {rhs}"
          f"   -> {'EQUALITY' if lhs == rhs else 'strict'}")
    prob_bound = Fraction(c * k, m * (c + m * (k - 1)))
    print(f"    predicted P[U] >= {prob_bound}   actual P[U] = "
          f"{Fraction(len(union), n)}   -> attained")
    bonf_lhs, bonf_rhs = 2 * m * len(union), k * n
    print(f"    Bonferroni-shaped claim 2m|U| >= kN :  {bonf_lhs} >= {bonf_rhs}  ->"
          f" {'holds' if bonf_lhs >= bonf_rhs else 'FALSE (pairwise input is load-bearing)'}")
    print()


# --------------------------------------------------------------------------- #
# Section 3.  The exact failure law, by brute force over all codebooks.
#
#   P[fail] = 1 - (1 - 1/M)^k,   k = number of competitors.
# --------------------------------------------------------------------------- #


def all_codebooks(n_messages: int, m_labels: int) -> Iterator[Tuple[int, ...]]:
    """Enumerate every function from n_messages messages to m_labels labels."""
    return itertools.product(range(m_labels), repeat=n_messages)


def failure_count_bruteforce(
    n_messages: int, m_labels: int, typical: Sequence[int], target: int
) -> int:
    """Count codebooks under which some other typical message collides with target."""
    competitors = [y for y in typical if y != target]
    return sum(
        1
        for h in all_codebooks(n_messages, m_labels)
        if any(h[y] == h[target] for y in competitors)
    )


def exact_failure_probability(m_labels: int, k: int) -> Fraction:
    """The exact law  1 - (1 - 1/M)^k  in exact rational arithmetic."""
    return 1 - Fraction(m_labels - 1, m_labels) ** k


def demo_exact_failure_law() -> None:
    print("=" * 74)
    print("3.  The exact failure law  P[fail] = 1 - (1 - 1/M)^k")
    print("=" * 74)
    print(f"  {'|alpha|':>8} {'M':>3} {'k':>3} {'brute force':>16} "
          f"{'exact law':>16}   match")
    for n_messages in (3, 4, 5):
        for m_labels in (2, 3, 4):
            typical = list(range(n_messages))
            target = 0
            k = len(typical) - 1
            count = failure_count_bruteforce(n_messages, m_labels, typical, target)
            empirical = Fraction(count, m_labels ** n_messages)
            predicted = exact_failure_probability(m_labels, k)
            ok = empirical == predicted
            print(f"  {n_messages:>8} {m_labels:>3} {k:>3} "
                  f"{str(empirical):>16} {str(predicted):>16}   {'OK' if ok else 'MISMATCH'}")
            assert ok
    print()
    print("  Reference cases quoted in the paper:")
    print(f"    |alpha|=3, M=2:  failures = "
          f"{failure_count_bruteforce(3, 2, [0, 1, 2], 0)} of 8   (= 8 - 1^2*2)")
    print(f"    |alpha|=4, M=3:  failures = "
          f"{failure_count_bruteforce(4, 3, [0, 1, 2, 3], 0)} of 81  (= 81 - 2^3*3)")
    print()


# --------------------------------------------------------------------------- #
# Section 4.  The hierarchy of bounds.
#
#   k/(2M)  <=  k/(M+k-1)  <=  P[fail] = 1-(1-1/M)^k  <=  k/M      (k <= M+1)
#
# and, unconditionally,  k/(M+k) <= P[fail] <= k/M, with P[fail] > 1/2 once
# k >= M -- the converse that the Bonferroni route cannot reach.
# --------------------------------------------------------------------------- #


def bonferroni_bound(m_labels: int, k: int) -> Fraction:
    return Fraction(k, 2 * m_labels)


def second_moment_bound(m_labels: int, k: int) -> Fraction:
    return Fraction(k, m_labels + k - 1) if m_labels + k - 1 > 0 else Fraction(0)


def harmonic_bound(m_labels: int, k: int) -> Fraction:
    return Fraction(k, m_labels + k)


def shannon_bound(m_labels: int, k: int) -> Fraction:
    return Fraction(k, m_labels)


def demo_hierarchy(m_labels: int = 16, k_max: int = 40) -> None:
    print("=" * 74)
    print(f"4.  The hierarchy of bounds (M = {m_labels})")
    print("=" * 74)
    print(f"  {'k':>3} {'k/(2M)':>10} {'k/(M+k-1)':>12} {'k/(M+k)':>10} "
          f"{'exact':>10} {'k/M':>10}  regime")
    for k in list(range(1, 9)) + [m_labels // 2, m_labels - 1, m_labels,
                                  m_labels + 1, 2 * m_labels, k_max]:
        exact = exact_failure_probability(m_labels, k)
        b_bonf = bonferroni_bound(m_labels, k)
        b_sm = second_moment_bound(m_labels, k)
        b_harm = harmonic_bound(m_labels, k)
        b_sh = shannon_bound(m_labels, k)
        in_regime = 2 * (k - 1) <= m_labels
        # unconditional facts
        assert b_sm <= exact <= b_sh
        assert b_harm <= exact
        if k <= m_labels + 1:
            assert b_bonf <= b_sm
        if k >= m_labels:
            assert exact > Fraction(1, 2)
        tag = "Bonferroni valid" if in_regime else "Bonferroni UNAVAILABLE"
        print(f"  {k:>3} {float(b_bonf):>10.4f} {float(b_sm):>12.4f} "
              f"{float(b_harm):>10.4f} {float(exact):>10.4f} {float(b_sh):>10.4f}"
              f"  {tag}")
    print()
    print("  Above the pigeonhole rate (k >= M) the exact law and the")
    print("  second-moment bound both exceed 1/2, while the Bonferroni")
    print("  expression k/(2M) is not even a valid bound there.")
    print()


# --------------------------------------------------------------------------- #
# Section 5.  The component law for collision-pattern marginals.
#
#   |{H : H(a) = H(b) for every edge (a,b) of P}| = M^{c(P)},
#   c(P) = number of connected components of P (isolated vertices included).
# --------------------------------------------------------------------------- #


def component_count(n_vertices: int, edges: Iterable[Tuple[int, int]]) -> int:
    """Number of connected components of a graph on {0,...,n-1}, by union-find."""
    parent = list(range(n_vertices))

    def find(a: int) -> int:
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    for u, v in edges:
        ru, rv = find(u), find(v)
        if ru != rv:
            parent[ru] = rv
    return len({find(a) for a in range(n_vertices)})


def pattern_event_count(
    n_vertices: int, m_labels: int, edges: Sequence[Tuple[int, int]]
) -> int:
    """Brute-force count of codebooks realising every collision of the pattern."""
    return sum(
        1
        for h in all_codebooks(n_vertices, m_labels)
        if all(h[u] == h[v] for u, v in edges)
    )


def demo_component_law(trials: int = 200, seed: int = 7) -> None:
    print("=" * 74)
    print("5.  The component law  |E(P)| = M^{c(P)}")
    print("=" * 74)
    rng = random.Random(seed)
    for _ in range(trials):
        n = rng.randint(1, 5)
        m = rng.randint(2, 3)
        possible = [(u, v) for u in range(n) for v in range(n) if u < v]
        edges = [e for e in possible if rng.random() < 0.4]
        brute = pattern_event_count(n, m, edges)
        law = m ** component_count(n, edges)
        assert brute == law, (n, m, edges, brute, law)
    print(f"  {trials} random patterns tested; the component law held exactly.")

    # Star patterns and the two catalogued marginals.
    n, m = 5, 3
    print()
    print(f"  Star marginals on |iota| = {n}, M = {m}:")
    for t in range(0, n):
        target = 0
        star = [(y, target) for y in range(1, t + 1)]
        brute = pattern_event_count(n, m, star)
        print(f"    |T| = {t}:  count = {brute:>5} = M^{{|iota|-|T|}} = "
              f"{m ** (n - t):>5},  probability = {Fraction(brute, m ** n)}"
              f" = 1/M^{t}")
        assert brute == m ** (n - t)

    # Vertex-sharing versus vertex-disjoint pairs of collisions: same marginal.
    shared = [(1, 0), (2, 0)]
    disjoint = [(0, 1), (2, 3)]
    cs = pattern_event_count(n, m, shared)
    cd = pattern_event_count(n, m, disjoint)
    print()
    print("  Two collisions through a shared vertex vs. on disjoint pairs:")
    print(f"    shared   {shared}:  count = {cs}, probability = {Fraction(cs, m**n)}")
    print(f"    disjoint {disjoint}:  count = {cd}, probability = {Fraction(cd, m**n)}")
    print("    -> identical: the marginal sees only the component count, not the shape.")
    assert cs == cd == m ** (n - 2)
    print()


# --------------------------------------------------------------------------- #
# Section 6.  Exact derandomisation versus the union-bound derandomisation.
#
#   exact:        some H with |bad(H)|/|S| <= 1 - (1-1/M)^{|S|-1}   (never >= 1)
#   union bound:  some H with |bad(H)|     <= |S|(|S|-1)/M          (vacuous for
#                                                        |S| - 1 >= M)
# --------------------------------------------------------------------------- #


def best_codebook_bad_count(
    n_messages: int, m_labels: int, typical: Sequence[int]
) -> Tuple[int, Tuple[int, ...]]:
    """Brute-force search for the codebook losing the fewest typical messages."""
    best = (len(typical) + 1, ())
    for h in all_codebooks(n_messages, m_labels):
        bad = sum(
            1
            for x in typical
            if any(h[y] == h[x] for y in typical if y != x)
        )
        if bad < best[0]:
            best = (bad, h)
    return best


def demo_derandomisation() -> None:
    print("=" * 74)
    print("6.  Exact derandomisation vs. the union-bound derandomisation")
    print("=" * 74)
    print(f"  {'|S|':>4} {'M':>3} {'best |bad(H)|':>14} {'exact bound':>14} "
          f"{'union bound':>14}  union vacuous?")
    for n_messages, m_labels in [(4, 2), (4, 3), (5, 2), (5, 3), (5, 4), (6, 3)]:
        typical = list(range(n_messages))
        s = len(typical)
        k = s - 1
        best, _ = best_codebook_bad_count(n_messages, m_labels, typical)
        exact_frac = 1 - Fraction(m_labels - 1, m_labels) ** k
        exact_bound = exact_frac * s
        union_bound = Fraction(s * (s - 1), m_labels)
        vacuous = union_bound >= s
        # The exact bound is a genuine bound on the best codebook.
        assert best <= exact_bound
        # The exact bound always implies the union bound (M^k-(M-1)^k <= k M^{k-1}).
        assert exact_bound <= union_bound
        print(f"  {s:>4} {m_labels:>3} {best:>14} {float(exact_bound):>14.4f} "
              f"{float(union_bound):>14.4f}  {'YES' if vacuous else 'no'}")
    print()
    print("  Integer inequality  M^k - (M-1)^k <= k M^{k-1}  (exact bound implies union bound):")
    for m_labels in range(1, 7):
        for k in range(0, 9):
            lhs = m_labels ** k - (m_labels - 1) ** k
            rhs = k * m_labels ** max(k - 1, 0) if k else 0
            assert lhs <= rhs + (1 if k == 0 else 0), (m_labels, k, lhs, rhs)
    print("    verified for 1 <= M <= 6, 0 <= k <= 8.")
    print()
    print("  Asymptotics: for |S| large the exact fraction tends to 1 but stays")
    print("  strictly below it, while |S|(|S|-1)/M exceeds |S| and says nothing.")
    for s in (10, 100, 1000):
        m_labels = 8
        frac = 1 - Fraction(m_labels - 1, m_labels) ** (s - 1)
        print(f"    |S| = {s:>5}, M = {m_labels}:  exact fraction = {float(frac):.10f}"
              f"   union bound fraction = {float(Fraction(s - 1, m_labels)):.4f}")
    print()


# --------------------------------------------------------------------------- #


def main() -> None:
    demo_chung_erdos()
    demo_marginal_profile()
    demo_exact_failure_law()
    demo_hierarchy()
    demo_component_law()
    demo_derandomisation()
    print("=" * 74)
    print("All demonstrations completed; every assertion held.")
    print("=" * 74)


if __name__ == "__main__":
    main()
