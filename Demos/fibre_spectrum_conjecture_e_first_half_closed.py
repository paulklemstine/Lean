"""
The fibre spectrum of the orbit-pattern map: numerical demonstrations.

A finite group G acts on a finite set X of size n, and hence diagonally on the set
X^k of k-tuples.  Every tuple f = (f_1, ..., f_k) has a *coincidence pattern*: the
set partition of {0, ..., k-1} whose blocks are the sets of indices on which f takes
the same value.  The pattern is constant on G-orbits, so we get a map

    orbit-pattern map :  X^k / G  --->  {set partitions of {0, ..., k-1}} .

Its fibre over a pattern P has size m_P, the "pattern multiplicity".  This script
demonstrates, by direct enumeration on small groups, the following results.

  1. Rank collapse:        m_P = t_{rank P},  where t_r is the number of G-orbits of
                           injective r-tuples and rank P is the number of blocks of P.
  2. Stirling expansion:   #(X^k/G) = sum_r S(k,r) t_r,  S(k,r) = # patterns of rank r.
  3. Bell row sum:         B_k = sum_r S(k,r).
  4. Monotonicity:         t_0 <= t_1 <= ... <= t_n.
  5. Transitivity:         t_r = 1  iff  the action is r-transitive;
                           in particular a single fibre (the discrete one) decides it.
  6. Spectral inversion:   the sequence k |-> #(X^k/G) and the spectrum r |-> t_r
                           determine each other.
  7. Burnside moments:     sum_{g in G} |Fix(g)|^k = |G| * sum_r S(k,r) t_r,
                           with Bell defect |G| * sum_r S(k,r) (t_r - 1).
  8. Order bound:          k-transitive  ==>  n(n-1)...(n-k+1) divides |G|;
                           if |G| < n(n-1)...(n-k+1) then t_k >= 2 and
                           #(X^k/G) >= B_k + 1.
  9. Degeneration:         for the trivial group, n^k = sum_r S(k,r) * n^{underline r}.
 10. Stirling recurrence:  S(k+1,r+1) = S(k,r) + (r+1) S(k,r+1).

Pure standard library; no dependencies.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Dict, Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]          # a permutation of {0, ..., n-1} as an image tuple
Tuple_ = Tuple[int, ...]        # a k-tuple of points of X = {0, ..., n-1}
Pattern = Tuple[int, ...]       # canonical form of a set partition: i |-> min of its block


# --------------------------------------------------------------------------------------
# Groups of permutations
# --------------------------------------------------------------------------------------

def compose(p: Perm, q: Perm) -> Perm:
    """Composition (p . q)(x) = p(q(x))."""
    return tuple(p[q[x]] for x in range(len(q)))


def generate_group(generators: Sequence[Perm], degree: int) -> List[Perm]:
    """Closure of `generators` under composition: the generated subgroup of Sym(degree)."""
    identity: Perm = tuple(range(degree))
    elements = {identity}
    frontier = [identity]
    while frontier:
        current = frontier.pop()
        for g in generators:
            new = compose(g, current)
            if new not in elements:
                elements.add(new)
                frontier.append(new)
    return sorted(elements)


def symmetric_group(n: int) -> List[Perm]:
    return sorted(permutations(range(n)))


def alternating_group(n: int) -> List[Perm]:
    def sign(p: Perm) -> int:
        s = 1
        for i in range(len(p)):
            for j in range(i + 1, len(p)):
                if p[i] > p[j]:
                    s = -s
        return s
    return [p for p in symmetric_group(n) if sign(p) == 1]


def cyclic_group(n: int) -> List[Perm]:
    return generate_group([tuple((x + 1) % n for x in range(n))], n)


def dihedral_group(n: int) -> List[Perm]:
    rot: Perm = tuple((x + 1) % n for x in range(n))
    ref: Perm = tuple((-x) % n for x in range(n))
    return generate_group([rot, ref], n)


def trivial_group(n: int) -> List[Perm]:
    return [tuple(range(n))]


def klein_four_on_four() -> List[Perm]:
    """The regular Klein four-group inside S_4: {e, (01)(23), (02)(13), (03)(12)}."""
    return generate_group([(1, 0, 3, 2), (2, 3, 0, 1)], 4)


def affine_group_mod_5() -> List[Perm]:
    """AGL(1,5) = {x |-> a x + b, a in {1,2,3,4}, b in Z/5}: sharply 2-transitive of order 20."""
    elements = [tuple((a * x + b) % 5 for x in range(5)) for a in (1, 2, 3, 4) for b in range(5)]
    return sorted(elements)


# --------------------------------------------------------------------------------------
# Patterns (set partitions in canonical "minimum representative" form)
# --------------------------------------------------------------------------------------

def kernel_pattern(f: Sequence[int]) -> Pattern:
    """The coincidence pattern of a tuple: i |-> min { j : f_j = f_i }."""
    return tuple(min(j for j in range(len(f)) if f[j] == f[i]) for i in range(len(f)))


def all_patterns(k: int) -> List[Pattern]:
    """All canonical patterns of {0,...,k-1}: maps P with P(i) <= i and P(P(i)) = P(i)."""
    seen = set()
    if k == 0:
        return [()]
    for f in product(range(k), repeat=k):     # every tuple realises some pattern
        seen.add(kernel_pattern(f))
    return sorted(seen)


def rank(pattern: Pattern) -> int:
    """The number of blocks of the partition."""
    return len(set(pattern))


def stirling_by_patterns(k: int, r: int) -> int:
    """S(k,r) computed as the number of patterns of {0,...,k-1} of rank r."""
    return sum(1 for p in all_patterns(k) if rank(p) == r)


def stirling_by_recurrence(k: int, r: int) -> int:
    """S(k,r) from the classical recurrence S(k+1,r+1) = S(k,r) + (r+1) S(k,r+1)."""
    table = [[0] * (k + 2) for _ in range(k + 1)]
    table[0][0] = 1
    for a in range(k):
        for b in range(k + 1):
            table[a + 1][b + 1] = table[a][b] + (b + 1) * table[a][b + 1]
    return table[k][r] if r <= k else 0


def bell(k: int) -> int:
    """The Bell number B_k = number of set partitions of a k-element set."""
    return sum(stirling_by_recurrence(k, r) for r in range(k + 1))


def desc_factorial(n: int, k: int) -> int:
    """The falling factorial n(n-1)...(n-k+1)."""
    result = 1
    for i in range(k):
        result *= max(n - i, 0)
    return result


# --------------------------------------------------------------------------------------
# Orbits on tuples
# --------------------------------------------------------------------------------------

def act(g: Perm, f: Tuple_) -> Tuple_:
    """The diagonal action: (g . f)_i = g(f_i)."""
    return tuple(g[x] for x in f)


def orbit_representatives(group: Sequence[Perm], degree: int, k: int) -> List[Tuple_]:
    """One canonical representative (the lexicographic minimum) per orbit on k-tuples."""
    seen = set()
    reps: List[Tuple_] = []
    for f in product(range(degree), repeat=k):
        if f in seen:
            continue
        orbit = {act(g, f) for g in group}
        seen |= orbit
        reps.append(min(orbit))
    return sorted(reps)


def num_orbits(group: Sequence[Perm], degree: int, k: int) -> int:
    return len(orbit_representatives(group, degree, k))


def pattern_multiplicities(group: Sequence[Perm], degree: int, k: int) -> Dict[Pattern, int]:
    """m_P for every pattern P of {0,...,k-1}: the fibre sizes of the orbit-pattern map."""
    counts: Dict[Pattern, int] = {p: 0 for p in all_patterns(k)}
    for rep in orbit_representatives(group, degree, k):
        counts[kernel_pattern(rep)] += 1
    return counts


def inj_orbits(group: Sequence[Perm], degree: int, r: int) -> int:
    """t_r: the number of orbits of *injective* r-tuples."""
    return sum(1 for rep in orbit_representatives(group, degree, r)
               if len(set(rep)) == len(rep))


def spectrum(group: Sequence[Perm], degree: int, up_to: int | None = None) -> List[int]:
    """The fibre spectrum (t_0, t_1, ..., t_n)."""
    top = degree if up_to is None else up_to
    return [inj_orbits(group, degree, r) for r in range(top + 1)]


def is_k_transitive(group: Sequence[Perm], degree: int, k: int) -> bool:
    return inj_orbits(group, degree, k) == 1


def fixed_points(g: Perm) -> int:
    return sum(1 for x in range(len(g)) if g[x] == x)


def burnside_moment(group: Sequence[Perm], k: int) -> int:
    """The k-th moment sum_{g in G} |Fix(g)|^k of the fixed-point family."""
    return sum(fixed_points(g) ** k for g in group)


def spectrum_from_orbit_counts(counts: Sequence[int]) -> List[int]:
    """Invert the Stirling expansion: recover t_r from the numbers #(X^k/G), k = 0,1,2,...

    Uses triangularity S(k,k) = 1:  t_k = #(X^k/G) - sum_{r<k} S(k,r) t_r.
    """
    t: List[int] = []
    for k in range(len(counts)):
        partial = sum(stirling_by_recurrence(k, r) * t[r] for r in range(k))
        t.append(counts[k] - partial)
    return t


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------

def show_example(name: str, group: Sequence[Perm], degree: int, kmax: int) -> None:
    n = degree
    order = len(group)
    print("=" * 78)
    print(f"{name}:  |G| = {order},  |X| = {n}")
    print("=" * 78)

    spec = spectrum(group, n)
    print(f"  spectrum (t_0, ..., t_{n}) = {spec}")
    assert all(spec[i] <= spec[i + 1] for i in range(len(spec) - 1)), "monotonicity failed"
    print("  monotone t_0 <= t_1 <= ... <= t_n : OK")

    degree_of_transitivity = max((r for r in range(n + 1) if spec[r] == 1), default=0)
    print(f"  largest r with t_r = 1 (degree of transitivity) = {degree_of_transitivity}")

    counts: List[int] = []
    for k in range(kmax + 1):
        mult = pattern_multiplicities(group, n, k)

        # 1. rank collapse m_P = t_{rank P}
        for pattern, m in mult.items():
            expected = inj_orbits(group, n, rank(pattern))
            assert m == expected, (pattern, m, expected)

        # 2. sum of fibres = number of orbits, and Stirling expansion
        total = num_orbits(group, n, k)
        counts.append(total)
        assert sum(mult.values()) == total
        expansion = sum(stirling_by_patterns(k, r) * inj_orbits(group, n, r)
                        for r in range(k + 1))
        assert expansion == total, (k, expansion, total)

        # 3. Burnside moment identity and the Bell defect
        moment = burnside_moment(group, k)
        assert moment == total * order, (k, moment, total * order)
        defect = sum(stirling_by_patterns(k, r) * (inj_orbits(group, n, r) - 1)
                     for r in range(k + 1) if r <= n)
        tail = sum(stirling_by_patterns(k, r) * (inj_orbits(group, n, r) - 1)
                   for r in range(k + 1) if r > n)
        assert moment == (bell(k) + defect + tail) * order

        fibres = ", ".join(f"m_{''.join(map(str, p))}={m}" for p, m in sorted(mult.items()))
        print(f"  k={k}:  #(X^k/G) = {total:5d} = sum_r S({k},r) t_r,   B_{k} = {bell(k):3d},"
              f"   moment sum_g |Fix g|^{k} = {moment}")
        if k <= 3:
            print(f"          fibres: {fibres}")

    # 4. spectral inversion
    recovered = spectrum_from_orbit_counts(counts)
    assert recovered[: min(len(recovered), n + 1)] == spec[: min(len(recovered), n + 1)]
    print(f"  inversion from orbit counts {counts} recovers t = {recovered}: OK")

    # 5. order bound for the achieved degree of transitivity
    d = degree_of_transitivity
    fall = desc_factorial(n, d)
    assert order % fall == 0, (order, fall)
    print(f"  {d}-transitive  =>  n^(underline {d}) = {fall} divides |G| = {order}: OK")
    if d < n:
        fall_next = desc_factorial(n, d + 1)
        assert not (order >= fall_next and spec[d + 1] == 1) or order % fall_next == 0
        if order < fall_next:
            assert spec[d + 1] >= 2
            assert counts[d + 1] >= bell(d + 1) + 1 if d + 1 < len(counts) else True
            print(f"  |G| = {order} < n^(underline {d+1}) = {fall_next}"
                  f"  =>  t_{d+1} = {spec[d+1]} >= 2  (strict Bell defect): OK")
    print()


def check_degeneration(nmax: int = 6, kmax: int = 6) -> None:
    print("=" * 78)
    print("Degeneration to the trivial action:  n^k = sum_r S(k,r) * n^(underline r)")
    print("=" * 78)
    for n in range(nmax + 1):
        for k in range(kmax + 1):
            lhs = n ** k
            rhs = sum(stirling_by_recurrence(k, r) * desc_factorial(n, r) for r in range(k + 1))
            assert lhs == rhs, (n, k, lhs, rhs)
    print(f"  verified for 0 <= n <= {nmax}, 0 <= k <= {kmax}: OK")
    for k in range(5):
        terms = " + ".join(f"{stirling_by_recurrence(k, r)}*n^({r})" for r in range(k + 1))
        print(f"  n^{k} = {terms}")
    print()


def check_stirling_recurrence(kmax: int = 6) -> None:
    print("=" * 78)
    print("The Stirling triangle from patterns, and its recurrence")
    print("=" * 78)
    for k in range(kmax + 1):
        row = [stirling_by_recurrence(k, r) for r in range(k + 1)]
        if k <= 5:
            assert row == [stirling_by_patterns(k, r) for r in range(k + 1)]
        print(f"  S({k},.) = {row}    row sum = B_{k} = {sum(row)}")
    for k in range(kmax):
        for r in range(kmax):
            assert (stirling_by_recurrence(k + 1, r + 1)
                    == stirling_by_recurrence(k, r) + (r + 1) * stirling_by_recurrence(k, r + 1))
    print(f"  recurrence S(k+1,r+1) = S(k,r) + (r+1) S(k,r+1) verified up to k = {kmax}: OK")
    print()


def check_rigidity() -> None:
    print("=" * 78)
    print("Rigidity: equal spectra  <==>  equal orbit-count sequences")
    print("=" * 78)
    # The Klein four-group acting regularly on 4 points, and the cyclic group of
    # order 4 acting regularly on 4 points: both regular, hence both have spectrum
    # (1, 1, 1, 1, 1)? -- check.
    pairs: List[Tuple[str, List[Perm], int]] = [
        ("Klein four (regular on 4 points)", klein_four_on_four(), 4),
        ("Cyclic C_4 (regular on 4 points)", cyclic_group(4), 4),
    ]
    specs = []
    for name, grp, deg in pairs:
        s = spectrum(grp, deg)
        c = [num_orbits(grp, deg, k) for k in range(5)]
        specs.append((name, s, c))
        print(f"  {name}: t = {s}, orbit counts = {c}")
    (_, s1, c1), (_, s2, c2) = specs
    print(f"  spectra equal: {s1 == s2};  orbit counts equal: {c1 == c2}"
          "   (the two agree, as the rigidity theorem requires)")
    print()


def main() -> None:
    print(__doc__)
    check_stirling_recurrence()
    check_degeneration()
    show_example("Symmetric group S_4 on 4 points (4-transitive)", symmetric_group(4), 4, 4)
    show_example("Alternating group A_4 on 4 points (2-transitive, not 3)",
                 alternating_group(4), 4, 4)
    show_example("Dihedral group D_4 on the 4 vertices of a square",
                 dihedral_group(4), 4, 4)
    show_example("Cyclic group C_5 on 5 points (regular)", cyclic_group(5), 5, 3)
    show_example("Affine group AGL(1,5) on 5 points (sharply 2-transitive)",
                 affine_group_mod_5(), 5, 3)
    show_example("Trivial group on 3 points", trivial_group(3), 3, 4)
    check_rigidity()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
