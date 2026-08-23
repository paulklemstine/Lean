"""
The Burnside Moment Hierarchy — numerical demonstrations.

For a finite group G acting on a finite set X, write a(g) = |X^g| for the number of
points fixed by g, and

    S_k = sum_{g in G} a(g)^k        (the k-th moment of the fixed-point statistic)
    o_k = #(X^k / G)                 (orbits of the diagonal action on ordered k-tuples)

The organising identity of this work is

    S_k = o_k * |G|      for every k >= 0,

with k = 1 Burnside's lemma and k = 2 the rank of the permutation action.

This script:

  1. builds several concrete permutation groups by closing generators under composition;
  2. computes both sides of the identity independently — the left by summing powers of
     fixed-point counts, the right by explicitly enumerating orbits on k-tuples — and
     checks that they agree;
  3. verifies the structural theorems: monotonicity, log-convexity, superexponential
     growth, the sandwich bound, divisibility, and the Markov bound;
  4. verifies the rank splitting and the second-moment test for 2-transitivity;
  5. verifies the Poisson moment theorem for symmetric groups: S_k = P(k) * n! for
     k <= n, where P(k) is the k-th Bell number, and shows that it fails for k > n;
  6. verifies log-convexity of the Bell numbers as a corollary.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import permutations, product
from math import comb, factorial
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Perm = Tuple[int, ...]  # perm[i] = image of point i


# --------------------------------------------------------------------------------------
# Group construction
# --------------------------------------------------------------------------------------

def compose(p: Perm, q: Perm) -> Perm:
    """Return the permutation p . q, i.e. the map i |-> p(q(i))."""
    return tuple(p[q[i]] for i in range(len(q)))


def generate_group(generators: Sequence[Perm], degree: int) -> List[Perm]:
    """Close a set of generators under composition (finite closure = the group)."""
    identity: Perm = tuple(range(degree))
    elements: Set[Perm] = {identity}
    frontier: List[Perm] = [identity]
    while frontier:
        current = frontier.pop()
        for g in generators:
            new = compose(g, current)
            if new not in elements:
                elements.add(new)
                frontier.append(new)
    return sorted(elements)


def cyclic_group(n: int) -> List[Perm]:
    """The cyclic group C_n acting on n points by rotation."""
    rotation: Perm = tuple((i + 1) % n for i in range(n))
    return generate_group([rotation], n)


def dihedral_group(n: int) -> List[Perm]:
    """The dihedral group of order 2n acting on the n vertices of a regular n-gon."""
    rotation: Perm = tuple((i + 1) % n for i in range(n))
    reflection: Perm = tuple((-i) % n for i in range(n))
    return generate_group([rotation, reflection], n)


def symmetric_group(n: int) -> List[Perm]:
    """All n! permutations of n points."""
    return [tuple(p) for p in permutations(range(n))]


def regular_group(group: Sequence[Perm]) -> List[Perm]:
    """
    The left regular action of a group on itself, re-encoded as permutations of the
    index set {0, ..., |G|-1} via left multiplication in the Cayley table.
    """
    index: Dict[Perm, int] = {g: i for i, g in enumerate(group)}
    return [tuple(index[compose(g, h)] for h in group) for g in group]


# --------------------------------------------------------------------------------------
# Fixed points, moments, orbits
# --------------------------------------------------------------------------------------

def fixed_point_count(p: Perm) -> int:
    """|X^p|: the number of points left in place by the permutation p."""
    return sum(1 for i, image in enumerate(p) if image == i)


def fixed_point_profile(group: Sequence[Perm]) -> List[int]:
    """The multiset {|X^g| : g in G}, as a sorted list (descending)."""
    return sorted((fixed_point_count(g) for g in group), reverse=True)


def moment(group: Sequence[Perm], k: int) -> int:
    """S_k = sum_{g in G} |X^g|^k. The 'cheap side' of the moment identity."""
    return sum(fixed_point_count(g) ** k for g in group)


def orbit_count_on_tuples(group: Sequence[Perm], degree: int, k: int) -> int:
    """
    o_k = #(X^k / G), computed by brute-force orbit enumeration on ordered k-tuples.
    The 'expensive side' of the moment identity: cost Theta(|G| * degree^k).
    """
    seen: Set[Tuple[int, ...]] = set()
    orbits = 0
    for tup in product(range(degree), repeat=k):
        if tup in seen:
            continue
        orbits += 1
        for g in group:
            seen.add(tuple(g[x] for x in tup))
    return orbits


def orbit_count_on_set(group: Sequence[Perm], points: Iterable[Tuple[int, ...]]) -> int:
    """Number of orbits of G on an explicit G-invariant set of tuples."""
    remaining = set(points)
    orbits = 0
    while remaining:
        start = next(iter(remaining))
        orbits += 1
        for g in group:
            remaining.discard(tuple(g[x] for x in start))
    return orbits


# --------------------------------------------------------------------------------------
# Bell numbers and derangements
# --------------------------------------------------------------------------------------

def bell_numbers(kmax: int) -> List[int]:
    """P(0), ..., P(kmax) via the Bell triangle."""
    row: List[int] = [1]
    bells: List[int] = [1]
    for _ in range(kmax):
        new_row = [row[-1]]
        for value in row:
            new_row.append(new_row[-1] + value)
        row = new_row
        bells.append(row[0])
    return bells


def derangements(n: int) -> List[int]:
    """D(0), ..., D(n) with D(0) = 1, D(1) = 0, D(m) = (m-1)(D(m-1) + D(m-2))."""
    d = [1, 0]
    while len(d) <= n:
        m = len(d)
        d.append((m - 1) * (d[m - 1] + d[m - 2]))
    return d[: n + 1]


def symmetric_moment_closed_form(n: int, k: int) -> int:
    """
    S_k for the symmetric group on n points, without enumerating the n! permutations:
    the number of permutations with exactly m fixed points is C(n, m) * D(n - m).
    """
    d = derangements(n)
    return sum(comb(n, m) * d[n - m] * m ** k for m in range(n + 1))


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------

def demo_moment_identity(name: str, group: Sequence[Perm], degree: int, kmax: int) -> None:
    """Check S_k = o_k * |G| with both sides computed independently."""
    order = len(group)
    print(f"\n### {name}:  |G| = {order}, |X| = {degree}")
    print(f"    fixed-point profile  {fixed_point_profile(group)}")
    print(f"    {'k':>2} {'S_k':>10} {'S_k/|G|':>10} {'o_k (enumerated)':>18}   identity")
    for k in range(kmax + 1):
        s_k = moment(group, k)
        o_k = orbit_count_on_tuples(group, degree, k)
        ok = (s_k == o_k * order)
        print(f"    {k:>2} {s_k:>10} {s_k // order:>10} {o_k:>18}   {'OK' if ok else 'FAIL'}")
        assert ok, "moment identity violated"
        assert s_k % order == 0, "divisibility of the moment by |G| violated"


def demo_structural_inequalities(name: str, group: Sequence[Perm], degree: int,
                                 kmax: int) -> None:
    """Monotonicity, log-convexity, superexponential growth, and the sandwich."""
    order = len(group)
    o = [moment(group, k) // order for k in range(kmax + 1)]
    print(f"\n### Structure of the ladder for {name}:  o = {o}")
    for k in range(1, kmax):
        assert o[k] <= o[k + 1], "monotonicity violated"
    print("    monotone for k >= 1                                OK")
    for k in range(kmax - 1):
        assert o[k + 1] ** 2 <= o[k] * o[k + 2], "log-convexity violated"
    print("    log-convex: o_{k+1}^2 <= o_k o_{k+2}               OK")
    if degree > 0:
        for k in range(kmax + 1):
            assert o[1] ** k <= o[k], "superexponential growth violated"
        print("    superexponential: o_1^k <= o_k                     OK")
    for k in range(kmax + 1):
        assert degree ** k <= order * o[k] <= order * degree ** k, "sandwich violated"
    print("    sandwich: |X|^k <= |G| o_k <= |G| |X|^k            OK")


def demo_markov_bound(name: str, group: Sequence[Perm], degree: int, kmax: int) -> None:
    """#{g : |X^g| >= t} * t^k <= o_k * |G| for all t, k."""
    order = len(group)
    print(f"\n### Markov bound for {name}")
    for k in range(kmax + 1):
        rhs = moment(group, k)
        for t in range(degree + 1):
            heavy = sum(1 for g in group if fixed_point_count(g) >= t)
            assert heavy * t ** k <= rhs, "Markov bound violated"
    print("    #{g : |X^g| >= t} * t^k <= S_k  for all t, k       OK")
    k = kmax
    rhs = moment(group, k)
    for t in range(1, degree + 1):
        heavy = sum(1 for g in group if fixed_point_count(g) >= t)
        print(f"    t = {t}: heavy = {heavy:>3}, bound S_{k}/t^{k} = {rhs / t ** k:8.3f}")


def demo_rank_and_two_transitivity(name: str, group: Sequence[Perm], degree: int) -> None:
    """Rank splitting and the second-moment test for 2-transitivity."""
    order = len(group)
    s1, s2 = moment(group, 1), moment(group, 2)
    orbits_points = s1 // order
    rank = s2 // order
    off_diag = [(x, y) for x in range(degree) for y in range(degree) if x != y]
    off_orbits = orbit_count_on_set(group, off_diag)
    print(f"\n### Rank analysis for {name}")
    print(f"    orbits on points       #(X/G)          = {orbits_points}")
    print(f"    rank                   #((X x X)/G)    = {rank}")
    print(f"    orbits on distinct pairs                = {off_orbits}")
    assert rank == orbits_points + off_orbits, "rank splitting violated"
    print("    rank splitting  rank = #(X/G) + #(offDiag/G)       OK")
    transitive = (s1 == order)
    two_transitive = (s2 == 2 * order)
    print(f"    transitive (S_1 = |G|)                  : {transitive}")
    print(f"    2-transitive (S_2 = 2|G|)               : {two_transitive}")
    if degree >= 2:
        assert two_transitive == (transitive and off_orbits == 1)
        print("    second-moment test agrees with direct check       OK")
    # Suborbits: for a transitive action, rank = #(X / Stab(x_0)).
    if transitive:
        stabiliser = [g for g in group if g[0] == 0]
        suborbits = orbit_count_on_set(stabiliser, [(x,) for x in range(degree)])
        print(f"    suborbits of Stab(x_0) on X             = {suborbits}")
        assert suborbits == rank, "rank = number of suborbits violated"
        print("    rank equals the number of suborbits               OK")


def demo_poisson_moments(nmax: int) -> None:
    """S_k = P(k) * n! for k <= n, and the failure just past the range."""
    bells = bell_numbers(nmax + 3)
    print("\n### Poisson moment theorem for symmetric groups")
    print("    S_k / n! against the Bell numbers P(k) (bold range: k <= n)")
    header = "    n \\ k " + "".join(f"{k:>8}" for k in range(nmax + 3))
    print(header)
    print("    " + "-" * (len(header) - 4))
    for n in range(1, nmax + 1):
        row = f"    {n:>5} "
        for k in range(nmax + 3):
            value = symmetric_moment_closed_form(n, k) // factorial(n)
            marker = "*" if k <= n else " "
            row += f"{value:>7}{marker}"
            if k <= n:
                assert value == bells[k], "Poisson moment theorem violated"
        print(row)
    print(f"    Bell   " + "".join(f"{bells[k]:>8}" for k in range(nmax + 3)))
    print("    entries marked * satisfy S_k = P(k) * n!            OK")
    print("    unmarked entries (k > n) count partitions into <= n blocks")
    # Cross-check the closed form against brute-force enumeration for small n.
    for n in range(1, 6):
        group = symmetric_group(n)
        for k in range(0, n + 1):
            assert moment(group, k) == symmetric_moment_closed_form(n, k)
    print("    closed form agrees with brute-force enumeration     OK")


def demo_bell_log_convexity(kmax: int) -> None:
    """P(k+1)^2 <= P(k) P(k+2), a corollary of log-convexity of the hierarchy."""
    bells = bell_numbers(kmax + 2)
    print("\n### Log-convexity of the Bell numbers")
    print(f"    {'k':>3} {'P(k+1)^2':>14} {'P(k) P(k+2)':>16}")
    for k in range(kmax + 1):
        lhs = bells[k + 1] ** 2
        rhs = bells[k] * bells[k + 2]
        assert lhs <= rhs, "Bell log-convexity violated"
        print(f"    {k:>3} {lhs:>14} {rhs:>16}")
    print("    P(k+1)^2 <= P(k) P(k+2) throughout                  OK")


def demo_regular_action(n: int, kmax: int) -> None:
    """o_k(G, G) = |G|^(k-1) for k >= 1, the extreme case of the hierarchy."""
    group = regular_group(cyclic_group(n))
    order = len(group)
    print(f"\n### Regular action of a group of order {order} on itself")
    for k in range(1, kmax + 1):
        o_k = moment(group, k) // order
        expected = order ** (k - 1)
        assert o_k == expected, "regular-action formula violated"
        print(f"    k = {k}:  o_k = {o_k:>6}  =  |G|^(k-1) = {expected:>6}   OK")


def demo_bilinear_identity() -> None:
    """sum_g |X^g| |Y^g| = #((X x Y)/G) |G| for two different actions of one group."""
    n = 4
    group_x = dihedral_group(n)                     # on 4 vertices of a square
    # The same abstract group acting on the 4 vertices, paired with its action on the
    # 2-element set of diagonals {  {0,2}, {1,3} }.
    def diagonal_action(g: Perm) -> Perm:
        # vertex i lies on diagonal i mod 2
        return tuple(g[j] % 2 for j in range(2))
    group_y = [diagonal_action(g) for g in group_x]
    order = len(group_x)
    lhs = sum(fixed_point_count(gx) * fixed_point_count(gy)
              for gx, gy in zip(group_x, group_y))
    pairs = [(x, y) for x in range(n) for y in range(2)]
    remaining = set(pairs)
    orbits = 0
    while remaining:
        x0, y0 = next(iter(remaining))
        orbits += 1
        for gx, gy in zip(group_x, group_y):
            remaining.discard((gx[x0], gy[y0]))
    print("\n### Bilinear Burnside (inner product of two permutation characters)")
    print(f"    sum_g |X^g||Y^g|      = {lhs}")
    print(f"    #((X x Y)/G) * |G|    = {orbits} * {order} = {orbits * order}")
    assert lhs == orbits * order, "bilinear identity violated"
    print("    identity holds                                      OK")


def main() -> None:
    print("=" * 86)
    print("THE BURNSIDE MOMENT HIERARCHY:  sum_g |X^g|^k  =  #(X^k/G) * |G|")
    print("=" * 86)

    demo_moment_identity("Cyclic group C_4 on 4 points", cyclic_group(4), 4, 4)
    demo_moment_identity("Dihedral group of order 8 on the square", dihedral_group(4), 4, 4)
    demo_moment_identity("Symmetric group S_4 on 4 points", symmetric_group(4), 4, 4)

    demo_structural_inequalities("D_4 on the square", dihedral_group(4), 4, 6)
    demo_structural_inequalities("S_4 on 4 points", symmetric_group(4), 4, 6)

    demo_markov_bound("D_4 on the square", dihedral_group(4), 4, 4)

    demo_rank_and_two_transitivity("C_4 on 4 points", cyclic_group(4), 4)
    demo_rank_and_two_transitivity("D_4 on the square", dihedral_group(4), 4)
    demo_rank_and_two_transitivity("S_4 on 4 points", symmetric_group(4), 4)

    demo_regular_action(3, 4)
    demo_bilinear_identity()
    demo_poisson_moments(6)
    demo_bell_log_convexity(8)

    print("\n" + "=" * 86)
    print("All identities and inequalities verified numerically.")
    print("=" * 86)


if __name__ == "__main__":
    main()
