"""
The Bell defect, counted exactly
================================

Numerical demonstration of the block-graded theory of the Bell defect of a finite
group action.

Setting
-------
Let a finite group ``G`` act on a finite set ``X`` with ``|X| = n``.  For ``g in G``
let ``X^g`` be its fixed-point set, and let

    M_k(G, X) = sum_{g in G} |X^g|^k                       (the k-th trace moment)

By Burnside's lemma applied to the diagonal action on ``X^k``,
``M_k = |G| * #(X^k / G)``.

Every orbit of ``k``-tuples has a well-defined *kernel pattern*: the set partition of
``{0, ..., k-1}`` recording which coordinates carry equal entries.  When ``k <= n``
every pattern occurs, so ``#(X^k/G) >= B_k`` (the ``k``-th Bell number) and hence the
*Bell floor*

    M_k >= B_k * |G|.

The *Bell defect* is the excess

    D_k = M_k - B_k * |G| = |G| * sum_P (m_P - 1),

``m_P`` being the number of orbits with kernel pattern ``P``.  Two structural facts
drive everything:

  * Rank collapse:  m_P = t_r  whenever P has r blocks, where
        t_r = number of G-orbits of *injective* r-tuples of points.
  * Stirling expansion:
        #(X^k / G) = sum_{r<=k} S(k,r) * t_r,
        D_k        = |G| * sum_{r<=k} S(k,r) * (t_r - 1).

The script below verifies, on explicit permutation actions:

  1. the Bell floor and the exact defect formula;
  2. the rank collapse ``m_P = t_{rank P}`` pattern by pattern;
  3. the block-graded transitivity criterion (all rank-``j`` fibres are singletons
     iff the action is ``j``-transitive);
  4. monotonicity ``D_j <= D_k`` and the sharp propagation ``B_k * D_2 <= 2 * D_k``;
  5. the falling-factorial constraint ``t_1^{underline r} <= t_r``;
  6. the moment-spectrum equivalence and the failure of a *single* moment to separate
     two actions of a group of order 4.

Pure standard library; no dependencies.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, FrozenSet, Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]  # perm[i] = image of point i


# ----------------------------------------------------------------------------
# Combinatorial background: Stirling numbers of the second kind and Bell numbers
# ----------------------------------------------------------------------------
def stirling2(k: int, r: int) -> int:
    """Number of set partitions of a k-element set into exactly r blocks."""
    table: List[List[int]] = [[0] * (k + 1) for _ in range(k + 1)]
    table[0][0] = 1
    for i in range(1, k + 1):
        for j in range(1, i + 1):
            table[i][j] = j * table[i - 1][j] + table[i - 1][j - 1]
    return table[k][r] if 0 <= r <= k else 0


def bell(k: int) -> int:
    """The k-th Bell number: the number of set partitions of a k-element set."""
    return sum(stirling2(k, r) for r in range(k + 1))


def desc_factorial(n: int, r: int) -> int:
    """The falling factorial n^{underline r} = n(n-1)...(n-r+1)."""
    out = 1
    for i in range(r):
        out *= max(n - i, 0)
    return out


# ----------------------------------------------------------------------------
# Finite permutation groups, given by generators
# ----------------------------------------------------------------------------
def compose(p: Perm, q: Perm) -> Perm:
    """(p . q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(len(q)))


def generate_group(n: int, generators: Sequence[Perm]) -> List[Perm]:
    """Closure of the generators inside the symmetric group on n points."""
    identity: Perm = tuple(range(n))
    seen = {identity}
    frontier = [identity]
    while frontier:
        new_frontier: List[Perm] = []
        for element in frontier:
            for g in generators:
                candidate = compose(g, element)
                if candidate not in seen:
                    seen.add(candidate)
                    new_frontier.append(candidate)
        frontier = new_frontier
    return sorted(seen)


def fixed_points(p: Perm) -> int:
    return sum(1 for i, v in enumerate(p) if i == v)


def moment(group: Sequence[Perm], k: int) -> int:
    """M_k = sum_g |X^g|^k."""
    return sum(fixed_points(g) ** k for g in group)


# ----------------------------------------------------------------------------
# Orbits of tuples, kernel patterns, the fibre spectrum
# ----------------------------------------------------------------------------
def kernel_pattern(t: Sequence[int]) -> FrozenSet[FrozenSet[int]]:
    """The set partition of the index set recording which coordinates agree."""
    blocks: Dict[int, List[int]] = {}
    for i, v in enumerate(t):
        blocks.setdefault(v, []).append(i)
    return frozenset(frozenset(b) for b in blocks.values())


def tuple_orbits(group: Sequence[Perm], n: int, k: int) -> List[FrozenSet[Tuple[int, ...]]]:
    """All G-orbits on X^k, as frozensets of tuples."""
    orbits: List[FrozenSet[Tuple[int, ...]]] = []
    seen: set = set()
    for t in product(range(n), repeat=k):
        if t in seen:
            continue
        orbit = frozenset(tuple(g[x] for x in t) for g in group)
        seen |= set(orbit)
        orbits.append(orbit)
    return orbits


def inj_orbits(group: Sequence[Perm], n: int, r: int) -> int:
    """t_r: the number of G-orbits of injective r-tuples of points."""
    if r > n:
        return 0
    seen: set = set()
    count = 0
    for t in product(range(n), repeat=r):
        if len(set(t)) != r or t in seen:
            continue
        orbit = frozenset(tuple(g[x] for x in t) for g in group)
        seen |= set(orbit)
        count += 1
    return count


def pattern_multiplicities(group: Sequence[Perm], n: int,
                           k: int) -> Dict[FrozenSet[FrozenSet[int]], int]:
    """m_P: the number of orbits of k-tuples whose kernel pattern is P."""
    counts: Dict[FrozenSet[FrozenSet[int]], int] = {}
    for orbit in tuple_orbits(group, n, k):
        representative = next(iter(orbit))
        pattern = kernel_pattern(representative)
        counts[pattern] = counts.get(pattern, 0) + 1
    return counts


def bell_defect(group: Sequence[Perm], k: int) -> int:
    """D_k = M_k - B_k*|G|."""
    return moment(group, k) - bell(k) * len(group)


def spectrum(group: Sequence[Perm], n: int, k: int) -> List[int]:
    """(t_0, t_1, ..., t_k)."""
    return [inj_orbits(group, n, r) for r in range(k + 1)]


def is_k_transitive(group: Sequence[Perm], n: int, k: int) -> bool:
    return k <= n and inj_orbits(group, n, k) == 1


# ----------------------------------------------------------------------------
# Example actions
# ----------------------------------------------------------------------------
def cyclic(n: int) -> List[Perm]:
    return generate_group(n, [tuple((i + 1) % n for i in range(n))])


def symmetric(n: int) -> List[Perm]:
    transposition = tuple([1, 0] + list(range(2, n)))
    cycle = tuple((i + 1) % n for i in range(n))
    return generate_group(n, [transposition, cycle])


def alternating(n: int) -> List[Perm]:
    return [g for g in symmetric(n) if sign(g) == 1]


def sign(p: Perm) -> int:
    visited = [False] * len(p)
    parity = 1
    for i in range(len(p)):
        if visited[i]:
            continue
        length = 0
        j = i
        while not visited[j]:
            visited[j] = True
            j = p[j]
            length += 1
        if length % 2 == 0:
            parity = -parity
    return parity


def trivial_group_on(n: int) -> List[Perm]:
    """The trivial action of the trivial group; used with a padded order below."""
    return generate_group(n, [tuple(range(n))])


def klein_four_regular() -> List[Perm]:
    """The regular action of Z/2 x Z/2 on its four elements."""
    a = (1, 0, 3, 2)
    b = (2, 3, 0, 1)
    return generate_group(4, [a, b])


def cyclic4_regular() -> List[Perm]:
    """The regular action of Z/4 on its four elements."""
    return cyclic(4)


def cyclic4_trivial_on_two() -> List[Perm]:
    """The trivial action of Z/4 on a 2-element set: four copies of the identity."""
    return [(0, 1)] * 4  # a multiset of group elements, all acting trivially


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------
def show_pattern(pattern: FrozenSet[FrozenSet[int]]) -> str:
    blocks = sorted((sorted(b) for b in pattern), key=lambda b: b[0])
    return "|".join("".join(str(i) for i in b) for b in blocks)


def report(name: str, group: Sequence[Perm], n: int, kmax: int) -> None:
    order = len(group)
    print(f"\n=== {name}   (|G| = {order}, |X| = {n}) ===")
    spec = spectrum(group, n, kmax)
    print(f"  fibre spectrum (t_0..t_{kmax}) : {spec}")
    header = f"  {'k':>2} {'M_k':>10} {'B_k|G|':>10} {'D_k':>8} {'|G|*sum S(k,r)(t_r-1)':>24}"
    print(header)
    for k in range(1, kmax + 1):
        mk = moment(group, k)
        floor = bell(k) * order
        dk = mk - floor
        predicted = order * sum(stirling2(k, r) * (spec[r] - 1) for r in range(k + 1))
        flag = "ok" if dk == predicted else "MISMATCH"
        print(f"  {k:>2} {mk:>10} {floor:>10} {dk:>8} {predicted:>24}  [{flag}]")
        assert mk >= floor, "Bell floor violated"
        assert dk == predicted, "spectral formula for the defect failed"

    # rank collapse, pattern by pattern
    k = min(kmax, 3)
    mults = pattern_multiplicities(group, n, k)
    print(f"  pattern multiplicities at k = {k}:")
    for pattern, m in sorted(mults.items(), key=lambda kv: show_pattern(kv[0])):
        r = len(pattern)
        assert m == spec[r], "rank collapse failed"
        print(f"    P = {show_pattern(pattern):<10} rank {r}   m_P = {m} = t_{r}")

    # block-graded transitivity criterion
    for j in range(1, k + 1):
        all_singletons = all(m == 1 for P, m in mults.items() if len(P) == j)
        transitive = is_k_transitive(group, n, j)
        assert all_singletons == transitive, "graded criterion failed"
        print(f"    every rank-{j} fibre is a singleton: {all_singletons}"
              f"   <->   {j}-transitive: {transitive}")

    # monotonicity, propagation, falling factorial
    for k in range(2, kmax + 1):
        d2, dk = bell_defect(group, 2), bell_defect(group, k)
        assert bell_defect(group, k - 1) <= dk, "monotonicity failed"
        assert bell(k) * d2 <= 2 * dk, "sharp propagation failed"
    for r in range(1, kmax + 1):
        assert desc_factorial(spec[1], r) <= spec[r], "falling-factorial bound failed"
    print(f"  monotone defect, sharp propagation B_k*D_2 <= 2*D_k, and "
          f"t_1^(under r) <= t_r all verified up to k = {kmax}")


def separation_experiment() -> None:
    """A single moment does not separate actions; the spectrum does."""
    print("\n=== One moment is strictly coarser than the fibre spectrum ===")
    regular = cyclic4_regular()                # Z/4 acting on itself, |X| = 4
    trivial = cyclic4_trivial_on_two()         # Z/4 acting trivially on 2 points
    m2_reg = moment(regular, 2)
    m2_triv = moment(trivial, 2)
    print(f"  regular action of the cyclic group of order 4:  M_2 = {m2_reg}, "
          f"t_1 = {inj_orbits(regular, 4, 1)}")
    print(f"  trivial action of the same group on 2 points:   M_2 = {m2_triv}, "
          f"t_1 = {inj_orbits(trivial, 2, 1)}")
    assert m2_reg == m2_triv == 16
    assert inj_orbits(regular, 4, 1) != inj_orbits(trivial, 2, 1)
    print("  equal second moments, different spectra: the second moment alone is blind.")
    m1_reg, m1_triv = moment(regular, 1), moment(trivial, 1)
    print(f"  but the first moments already differ: {m1_reg} vs {m1_triv} "
          "-- the whole moment family sees the difference,")
    print("  exactly as the moment-spectrum equivalence predicts.")


def sharpness_experiment(kmax: int = 6) -> None:
    """The constant B_k/2 is optimal for the spectral relaxation."""
    print("\n=== The sharp propagation constant ===")
    print(f"  {'k':>2} {'B_k':>6} {'(B_k-1)/2':>12} {'B_k/2':>8}"
          f"   2*D_k/D_2 on the constant ray")
    for k in range(2, kmax + 1):
        bk = bell(k)
        # constant spectrum t_1 = ... = t_k = 1 + x, in units of |G| and of x:
        # D_2 = 2x, D_k = x * sum_{r=1..k} S(k,r) = x*B_k, so 2 D_k / D_2 = B_k.
        ratio = sum(stirling2(k, r) for r in range(1, k + 1))
        print(f"  {k:>2} {bk:>6} {(bk - 1) / 2:>12.2f} {bk / 2:>8.2f}   {ratio}")
        assert ratio == bk
    print("  equality on every constant spectrum; but for a genuine action with")
    print("  3 <= k <= |X| a constant spectrum forces D_2 = 0, so the extremal ray")
    print("  of the relaxation is never realized by an action with D_2 > 0.")


def order_bound_experiment() -> None:
    """|G| smaller than a falling factorial certifies a strictly positive defect."""
    print("\n=== The order bound: arithmetic certifies a strict defect ===")
    for name, group, n, k in [
        ("cyclic group of order 5 on 5 points", cyclic(5), 5, 2),
        ("cyclic group of order 4 on 4 points", cyclic(4), 4, 2),
        ("Klein four-group, regular", klein_four_regular(), 4, 2),
    ]:
        df = desc_factorial(n, k)
        order = len(group)
        tk = inj_orbits(group, n, k)
        print(f"  {name}: |G| = {order}, |X|^(under {k}) = {df}, t_{k} = {tk}")
        if order < df:
            assert tk >= 2
            assert moment(group, k) >= (bell(k) + 1) * order
            print(f"    |G| < |X|^(under k)  =>  t_k >= 2  and  M_k >= (B_k+1)|G| = "
                  f"{(bell(k) + 1) * order} (actual {moment(group, k)})")


def main() -> None:
    print("Stirling triangle S(k,r) and Bell numbers B_k")
    for k in range(1, 8):
        row = " ".join(f"{stirling2(k, r):>5}" for r in range(k + 1))
        print(f"  k={k}: {row}    B_k = {bell(k)}")
    print("  boundary values: S(k,0)=0, S(k,1)=1, S(k,k)=1, and "
          "sum_{r>=2} S(k,r) = B_k - 1")
    for k in range(1, 8):
        assert stirling2(k, 0) == 0 and stirling2(k, 1) == 1 and stirling2(k, k) == 1
        assert sum(stirling2(k, r) for r in range(2, k + 1)) == bell(k) - 1

    report("symmetric group on 4 points (4-transitive)", symmetric(4), 4, 4)
    report("alternating group on 4 points (2-transitive)", alternating(4), 4, 4)
    report("cyclic group of order 4, regular (1-transitive)", cyclic(4), 4, 4)
    report("Klein four-group, regular (1-transitive)", klein_four_regular(), 4, 4)
    report("trivial group on 3 points (0-transitive)", trivial_group_on(3), 3, 3)

    separation_experiment()
    sharpness_experiment()
    order_bound_experiment()
    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
