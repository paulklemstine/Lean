"""
The Bonferroni Machinery and the Marginal Selection Principle
=============================================================

Numerical demonstration of the results:

  * the Fubini identity for the multiplicity function and the first three moments;
  * the second Bonferroni inequality, its equality case (pairwise disjoint families),
    the double-collision bound and Corradi's Cauchy-Schwarz strengthening;
  * the Sidon marginal: distinct translates of a Sidon set meet in at most one point;
  * the master inequality  |S| |A|^2 <= |G| (|A| + |S| - 1)  over all shift sets S,
    and the strict ordering of its two extreme instances S = A and S = G;
  * Reiman's bound for graphs with no two vertices having two common neighbours,
    tested on incidence graphs of projective planes;
  * the third-order (triple-correlation) identity and collision bound.

Self-contained: standard library only.  Run with `python3 demo.py`.
"""

from __future__ import annotations

import itertools
import random
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Family = Sequence[Set[int]]


# ---------------------------------------------------------------------------
# 1.  The machinery: multiplicity, moments, and the universal inequalities
# ---------------------------------------------------------------------------


def multiplicity(family: Family) -> Dict[int, int]:
    """m(x) = number of members of the family containing x, for x in the support."""
    mult: Dict[int, int] = {}
    for member in family:
        for x in member:
            mult[x] = mult.get(x, 0) + 1
    return mult


def support(family: Family) -> Set[int]:
    """The union of the family."""
    out: Set[int] = set()
    for member in family:
        out |= member
    return out


def total_size(family: Family) -> int:
    """First moment: sum of |A_i|."""
    return sum(len(member) for member in family)


def pair_sum(family: Family) -> int:
    """Off-diagonal pair-correlation sum P(A) = sum_{i != j} |A_i cap A_j|."""
    k = len(family)
    return sum(
        len(family[i] & family[j]) for i in range(k) for j in range(k) if i != j
    )


def full_pair_sum(family: Family) -> int:
    """Second moment: sum over ALL ordered pairs (i, j), diagonal included."""
    k = len(family)
    return sum(len(family[i] & family[j]) for i in range(k) for j in range(k))


def full_triple_sum(family: Family) -> int:
    """Third moment: sum over all ordered triples of |A_i cap A_j cap A_k|."""
    k = len(family)
    return sum(
        len(family[i] & family[j] & family[l])
        for i in range(k)
        for j in range(k)
        for l in range(k)
    )


def double_collisions(family: Family) -> int:
    """Number of points of multiplicity at least 2."""
    return sum(1 for v in multiplicity(family).values() if v >= 2)


def triple_collisions(family: Family) -> int:
    """Number of points of multiplicity at least 3."""
    return sum(1 for v in multiplicity(family).values() if v >= 3)


def check_machinery(family: Family) -> Dict[str, bool]:
    """Verify every universal statement of the machinery on a single family."""
    mult = multiplicity(family)
    supp = support(family)
    total = total_size(family)
    pairs = pair_sum(family)

    first_moment = sum(mult.values())
    second_moment = sum(m * m for m in mult.values())
    third_moment = sum(m ** 3 for m in mult.values())

    pairwise_disjoint = all(
        not (family[i] & family[j])
        for i in range(len(family))
        for j in range(len(family))
        if i != j
    )

    return {
        "first moment  sum|A_i| = sum m(x)": total == first_moment,
        "second moment sum_{i,j}|AiAj| = sum m(x)^2": full_pair_sum(family)
        == second_moment,
        "collision census P = sum m(m-1)": pairs
        == sum(m * (m - 1) for m in mult.values()),
        "Bonferroni  sum|A_i| <= |U| + P": total <= len(supp) + pairs,
        "equality iff pairwise disjoint": (total == len(supp) + pairs)
        == pairwise_disjoint,
        "double collisions  2|D| <= P": 2 * double_collisions(family) <= pairs,
        "Corradi  (sum|A_i|)^2 <= |U|(sum|A_i| + P)": total ** 2
        <= len(supp) * (total + pairs),
        "third moment sum_{i,j,k} = sum m(x)^3": full_triple_sum(family)
        == third_moment,
        "third-order identity": (
            sum(m * (m - 1) * (m - 2) for m in mult.values())
            + 3 * full_pair_sum(family)
            == full_triple_sum(family) + 2 * total
        ),
        "triple collisions 6|T| <= sum m(m-1)(m-2)": 6 * triple_collisions(family)
        <= sum(m * (m - 1) * (m - 2) for m in mult.values()),
    }


def random_family(
    num_sets: int, ground: int, max_size: int, rng: random.Random
) -> List[Set[int]]:
    """A random family of subsets of {0, ..., ground-1}."""
    return [
        set(rng.sample(range(ground), rng.randint(0, max_size)))
        for _ in range(num_sets)
    ]


def demo_machinery(trials: int = 400, seed: int = 20260820) -> None:
    print("=" * 78)
    print("1.  THE UNIVERSAL MACHINERY  (random families, no structure whatsoever)")
    print("=" * 78)
    rng = random.Random(seed)
    tally: Dict[str, int] = {}
    for _ in range(trials):
        fam = random_family(rng.randint(1, 6), 12, 7, rng)
        for name, ok in check_machinery(fam).items():
            tally[name] = tally.get(name, 0) + int(ok)
    width = max(len(n) for n in tally)
    for name, count in tally.items():
        status = "OK" if count == trials else "FAILED"
        print(f"  {name:<{width}}  {count:4d}/{trials}  {status}")

    print("\n  Sharpness data:")
    sharp: List[Set[int]] = [{0}, {0}]
    print(
        f"    A0 = A1 = {{0}}:  P = {pair_sum(sharp)},  |D| = {double_collisions(sharp)}"
        f"   ->  2|D| = P  (double-collision bound attained)"
    )
    print(
        f"    same family:     sum|A_i| = {total_size(sharp)} < "
        f"{len(support(sharp)) + pair_sum(sharp)} = |U| + P   (Bonferroni strict)"
    )
    print()


# ---------------------------------------------------------------------------
# 2.  Uniform marginals
# ---------------------------------------------------------------------------


def uniform_marginal_outputs(k: int, m: int, t: int, union_size: int) -> Tuple[bool, bool]:
    """Return whether the linear and the quadratic uniform-marginal bounds hold."""
    linear = k * m <= union_size + k * (k - 1) * t
    quadratic = k * m * m <= union_size * (m + (k - 1) * t)
    return linear, quadratic


# ---------------------------------------------------------------------------
# 3.  Sidon sets in Z_N and the marginal selection principle
# ---------------------------------------------------------------------------


def is_sidon(a: Sequence[int], n: int) -> bool:
    """True iff all nonzero differences of `a` modulo n are distinct."""
    seen: Set[int] = set()
    for x, y in itertools.permutations(a, 2):
        d = (x - y) % n
        if d in seen:
            return False
        seen.add(d)
    return True


def greedy_sidon(n: int) -> List[int]:
    """Greedy Sidon set in Z_n: add the next residue whenever it stays Sidon."""
    chosen: List[int] = []
    used: Set[int] = set()
    for x in range(n):
        diffs: Set[int] = set()
        ok = True
        for y in chosen:
            for d in ((x - y) % n, (y - x) % n):
                if d in used or d in diffs:
                    ok = False
                    break
                diffs.add(d)
            if not ok:
                break
        if ok:
            chosen.append(x)
            used |= diffs
    return chosen


def nsub(a: int, b: int) -> int:
    """Truncated (natural-number) subtraction: max(a - b, 0)."""
    return a - b if a >= b else 0


def translate(a: Iterable[int], g: int, n: int) -> Set[int]:
    return {(x + g) % n for x in a}


def demo_sidon(seed: int = 7) -> None:
    print("=" * 78)
    print("2.  THE SIDON MARGINAL AND THE MASTER INEQUALITY")
    print("=" * 78)
    rng = random.Random(seed)

    for n in (31, 57, 100, 133):
        a = greedy_sidon(n)
        assert is_sidon(a, n), "greedy construction failed"
        m = len(a)

        # The Sidon marginal: distinct translates meet in at most one point.
        worst = max(
            len(translate(a, g, n) & translate(a, h, n))
            for g in range(n)
            for h in range(n)
            if g != h
        )

        # Master inequality across all shift set sizes (random shift sets per size).
        master_ok = True
        for size in range(1, n + 1):
            s = rng.sample(range(n), size)
            fam = [translate(a, g, n) for g in s]
            if total_size(fam) ** 2 > len(support(fam)) * (
                total_size(fam) + pair_sum(fam)
            ):
                master_ok = False
            if size * m * m > n * (m + size - 1):
                master_ok = False

        et = m * (m - 1) <= n - 1                    # S = G
        self_t = m ** 3 <= (2 * m - 1) * n           # S = A
        print(f"  Z_{n}:  greedy Sidon set of size {m}")
        print(f"    max |(A+g) cap (A+h)| over g != h            = {worst}  (must be <= 1)")
        print(f"    master inequality |S||A|^2 <= |G|(|A|+|S|-1)  : "
              f"{'holds for every tested S' if master_ok else 'VIOLATED'}")
        print(f"    all-translate output   m(m-1) = {m*(m-1):5d} <= {n-1:5d} = N-1     : {et}")
        print(f"    self-translate output  m^3    = {m**3:5d} <= "
              f"{(2*m-1)*n:5d} = (2m-1)N : {self_t}")
        # Largest m each output would allow:
        m_all = max(mm for mm in range(1, n + 2) if mm * (mm - 1) <= n - 1)
        m_self = max(mm for mm in range(1, 4 * n) if mm ** 3 <= (2 * mm - 1) * n)
        print(f"    largest size NOT excluded:  all-translate {m_all},  "
              f"self-translate {m_self}   (ratio {m_self/m_all:.3f} ~ sqrt2 = 1.414)")
    print()


def demo_marginal_selection(n_max: int = 400) -> None:
    print("=" * 78)
    print("3.  THE TWO MARGINAL CHOICES ARE STRICTLY ORDERED")
    print("=" * 78)

    # Domination: m(m-1) <= N-1  implies  m^3 <= (2m-1)N, for all m, N >= 1.
    dom_ok = all(
        (not (m * nsub(m, 1) <= nsub(n, 1))) or (m ** 3 <= nsub(2 * m, 1) * n)
        for n in range(1, n_max + 1)
        for m in range(0, 60)
    )
    print(f"  Domination  m(m-1) <= N-1  =>  m^3 <= (2m-1)N   for all N <= {n_max},"
          f" m < 60 : {dom_ok}")

    # Strictness: an explicit witness.
    n, m = 100, 13
    print(f"  Witness N = {n}, m = {m}:")
    print(f"    self-translate  m^3    = {m**3} <= {(2*m-1)*n} = (2m-1)N   -> not excluded")
    print(f"    all-translate   m(m-1) = {m*(m-1)}  > {n-1}     = N-1      -> excluded")
    print("    => the weaker marginal cannot rule out a size-13 Sidon set in a group")
    print("       of order 100, while the all-translate marginal can.")

    # How often does the gap occur?
    gaps = [
        (n, m)
        for n in range(1, n_max + 1)
        for m in range(1, 60)
        if m ** 3 <= nsub(2 * m, 1) * n and not (m * nsub(m, 1) <= nsub(n, 1))
    ]
    print(f"  Number of (N, m) pairs with N <= {n_max}, m < 60 in the gap: {len(gaps)}")
    print(f"  Smallest such pair: {min(gaps)}")
    print()


# ---------------------------------------------------------------------------
# 4.  Cross-domain: C_4-free graphs and Reiman's bound
# ---------------------------------------------------------------------------


def projective_plane_incidence_graph(q: int) -> Tuple[int, List[Tuple[int, int]]]:
    """Incidence graph (bipartite, C_4-free) of PG(2, q) for prime q.

    Points and lines are the 1-dimensional subspaces of F_q^3, represented by
    normalised triples.  A point p is adjacent to a line l when p . l = 0.
    """
    def normalise(v: Tuple[int, int, int]) -> Tuple[int, int, int]:
        for i in range(3):
            if v[i] % q:
                inv = pow(v[i] % q, q - 2, q)
                return tuple((c * inv) % q for c in v)  # type: ignore[return-value]
        raise ValueError("zero vector")

    reps: List[Tuple[int, int, int]] = sorted(
        {
            normalise((a, b, c))
            for a in range(q)
            for b in range(q)
            for c in range(q)
            if (a, b, c) != (0, 0, 0)
        }
    )
    npts = len(reps)                      # q^2 + q + 1
    edges: List[Tuple[int, int]] = []
    for i, p in enumerate(reps):
        for j, l in enumerate(reps):
            if sum(x * y for x, y in zip(p, l)) % q == 0:
                edges.append((i, npts + j))   # point i  --  line j
    return 2 * npts, edges


def graph_stats(num_vertices: int, edges: Sequence[Tuple[int, int]]) -> Tuple[int, int, int]:
    """Return (|V|, |E|, max common neighbours over distinct vertex pairs)."""
    nbr: List[Set[int]] = [set() for _ in range(num_vertices)]
    for u, v in edges:
        nbr[u].add(v)
        nbr[v].add(u)
    worst = 0
    for u in range(num_vertices):
        for v in range(u + 1, num_vertices):
            worst = max(worst, len(nbr[u] & nbr[v]))
    return num_vertices, len(edges), worst


def demo_c4_free() -> None:
    print("=" * 78)
    print("4.  THE SAME MACHINERY IN GRAPH THEORY: REIMAN'S BOUND")
    print("=" * 78)
    for q in (2, 3, 5, 7):
        nv, edges = projective_plane_incidence_graph(q)
        v, e, worst = graph_stats(nv, edges)
        lhs = (2 * e) ** 2
        rhs = v * (2 * e + v * (v - 1))
        limit = 0.25 * (v + v * (4 * v - 3) ** 0.5)
        print(f"  PG(2,{q}) incidence graph:  |V| = {v:4d}, |E| = {e:5d}, "
              f"max common neighbours = {worst}")
        print(f"    (2|E|)^2 = {lhs:9d}  <=  {rhs:9d} = |V|(2|E| + |V|(|V|-1))  "
              f": {lhs <= rhs}")
        print(f"    Reiman ceiling on |E|: {limit:9.1f}   attained fraction "
              f"{e/limit:.3f}")
    print()


# ---------------------------------------------------------------------------
# 5.  Uniform marginals in action
# ---------------------------------------------------------------------------


def demo_uniform_marginals(seed: int = 11) -> None:
    print("=" * 78)
    print("5.  UNIFORM MARGINALS:  k m^2 <= |U| (m + (k-1) t)")
    print("=" * 78)
    rng = random.Random(seed)
    print(f"  {'k':>3} {'m':>3} {'t':>3} {'|U|':>5} {'k m^2':>8} "
          f"{'|U|(m+(k-1)t)':>15}  ok")
    for _ in range(8):
        ground = rng.randint(10, 25)
        m = rng.randint(2, 6)
        k = rng.randint(2, 6)
        fam = [set(rng.sample(range(ground), m)) for _ in range(k)]
        t = max(
            len(fam[i] & fam[j]) for i in range(k) for j in range(k) if i != j
        )
        u = len(support(fam))
        lin, quad = uniform_marginal_outputs(k, m, t, u)
        print(f"  {k:3d} {m:3d} {t:3d} {u:5d} {k*m*m:8d} {u*(m+(k-1)*t):15d}  "
              f"{'yes' if (lin and quad) else 'NO'}")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    demo_machinery()
    demo_uniform_marginals()
    demo_sidon()
    demo_marginal_selection()
    demo_c4_free()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
