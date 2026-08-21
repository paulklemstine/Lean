"""
Emotional Chromatic Numbers: numerical demonstrations.
======================================================

Self-contained numerical verification of the results on the chromatic counting
function of social networks under the "emotional floor" (palettes of size >= 3).

For a finite simple graph G on n people:

    P_G(q)  = number of assignments c : V -> {0,...,q-1} with c(x) != c(y)
              for every friendship {x,y}                ("consistent assignments")

    chi_E(G) = min { q >= 3 : P_G(q) > 0 }               ("emotional chromatic number")

The script checks, by explicit computation:

  1. P_{K_n}(q) = q^{underline n}  and  P_{empty}(q) = q^n.
  2. Structure theorem            chi_E(G) = max(chi(G), 3).
  3. Antitonicity in edges, monotonicity in the palette.
  4. Universal floor              q^{underline n} <= P_G(q).
  5. Threshold law                for q >= 3:  P_G(q) > 0  <=>  chi_E(G) <= q.
  6. Sandwich theorem             max(omega,3) <= chi_E <= max(Delta+1,3),
     with the hub-and-circle (wheel W_5) witness making both sides strict.
  7. Greedy abundance             (q-d)^n <= P_G(q) when every degree <= d.
  8. Clique-with-bystanders closed form and the hundred-network census.
  9. Nordhaus-Gaddum conservation laws  n <= chi_E(G) * chi_E(complement G).
 10. The three folklore corrections.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Graph = Dict[int, Set[int]]  # adjacency map: vertex -> set of neighbours


# ----------------------------------------------------------------------------
# Graph constructors
# ----------------------------------------------------------------------------

def empty_graph(n: int) -> Graph:
    """The friendless population on n people (no edges)."""
    return {v: set() for v in range(n)}


def add_edge(g: Graph, u: int, v: int) -> None:
    """Record a friendship between u and v (symmetric, irreflexive)."""
    if u == v:
        return
    g[u].add(v)
    g[v].add(u)


def complete_graph(n: int) -> Graph:
    """K_n: everybody is friends with everybody."""
    g = empty_graph(n)
    for u, v in itertools.combinations(range(n), 2):
        add_edge(g, u, v)
    return g


def cycle_graph(n: int) -> Graph:
    """C_n: n people seated in a ring, each friends with their two neighbours."""
    g = empty_graph(n)
    for v in range(n):
        add_edge(g, v, (v + 1) % n)
    return g


def clique_below(n_people: int, k: int) -> Graph:
    """B_{N,k}: the first min(k,N) people are mutual friends; the rest are bystanders."""
    g = empty_graph(n_people)
    s = min(k, n_people)
    for u, v in itertools.combinations(range(s), 2):
        add_edge(g, u, v)
    return g


def wheel_hub_and_circle() -> Graph:
    """The hub-and-circle network W_5: a five-cycle 0..4 plus a hub 5 joined to all of them."""
    g = cycle_graph(5)
    g[5] = set()
    for v in range(5):
        add_edge(g, 5, v)
    return g


def complement_graph(g: Graph) -> Graph:
    """The stranger network: people are joined exactly when they are NOT friends."""
    vs = sorted(g)
    h = {v: set() for v in vs}
    for u, v in itertools.combinations(vs, 2):
        if v not in g[u]:
            add_edge(h, u, v)
    return h


def disjoint_union(g: Graph, h: Graph) -> Graph:
    """Two communities with no friendships between them."""
    shift = len(g)
    out: Graph = {v: set(nbrs) for v, nbrs in g.items()}
    for v, nbrs in h.items():
        out[v + shift] = {w + shift for w in nbrs}
    return out


def random_bounded_degree_graph(n: int, max_deg: int, seed: int) -> Graph:
    """A random network in which nobody exceeds max_deg friends."""
    rng = random.Random(seed)
    g = empty_graph(n)
    pairs = list(itertools.combinations(range(n), 2))
    rng.shuffle(pairs)
    for u, v in pairs:
        if len(g[u]) < max_deg and len(g[v]) < max_deg and rng.random() < 0.5:
            add_edge(g, u, v)
    return g


# ----------------------------------------------------------------------------
# Basic invariants
# ----------------------------------------------------------------------------

def edges(g: Graph) -> List[Tuple[int, int]]:
    return [(u, v) for u in sorted(g) for v in sorted(g[u]) if u < v]


def max_degree(g: Graph) -> int:
    return max((len(nbrs) for nbrs in g.values()), default=0)


def clique_number(g: Graph) -> int:
    """Largest set of pairwise friends (exhaustive; intended for small networks)."""
    vs = sorted(g)
    best = 0
    for size in range(len(vs), 0, -1):
        if size <= best:
            break
        for s in itertools.combinations(vs, size):
            if all(v in g[u] for u, v in itertools.combinations(s, 2)):
                return size
    return best


def descending_factorial(q: int, m: int) -> int:
    """q^{underline m} = q (q-1) ... (q-m+1); zero once m > q."""
    out = 1
    for i in range(m):
        out *= max(q - i, 0)
    return out


# ----------------------------------------------------------------------------
# The chromatic counting function
# ----------------------------------------------------------------------------

def chrom_val_bruteforce(g: Graph, q: int) -> int:
    """P_G(q) by exhaustive enumeration over q^n assignments (small n only)."""
    vs = sorted(g)
    es = edges(g)
    count = 0
    for assignment in itertools.product(range(q), repeat=len(vs)):
        c = dict(zip(vs, assignment))
        if all(c[u] != c[v] for u, v in es):
            count += 1
    return count


def chrom_val(g: Graph, q: int) -> int:
    """P_G(q) by deletion-contraction: P_G = P_{G-e} - P_{G/e}, base case q^n."""
    if q < 0:
        raise ValueError("palette size must be non-negative")
    es = edges(g)
    if not es:
        return q ** len(g)
    u, v = es[0]

    # deletion G - uv
    deleted: Graph = {w: set(nbrs) for w, nbrs in g.items()}
    deleted[u].discard(v)
    deleted[v].discard(u)

    # contraction G / uv : merge v into u
    contracted: Graph = {w: set(nbrs) for w, nbrs in g.items() if w != v}
    contracted[u] = {w for w in (g[u] | g[v]) if w not in (u, v)}
    for w in list(contracted):
        if w == u:
            continue
        contracted[w] = {u if x == v else x for x in contracted[w] if x != w}
    return chrom_val(deleted, q) - chrom_val(contracted, q)


def is_colorable(g: Graph, q: int) -> bool:
    """Backtracking search for a consistent q-assignment."""
    vs = sorted(g, key=lambda v: -len(g[v]))
    colors: Dict[int, int] = {}

    def rec(i: int) -> bool:
        if i == len(vs):
            return True
        v = vs[i]
        used = {colors[w] for w in g[v] if w in colors}
        for col in range(q):
            if col not in used:
                colors[v] = col
                if rec(i + 1):
                    return True
                del colors[v]
        return False

    return q > 0 if not g else rec(0)


def chromatic_number(g: Graph) -> int:
    """Least q with a consistent q-assignment."""
    for q in range(len(g) + 1):
        if is_colorable(g, q):
            return q
    return len(g)


def emotional_chromatic_number(g: Graph) -> int:
    """chi_E(G) = min { q >= 3 : P_G(q) > 0 }, found by threshold search."""
    q = 3
    while not is_colorable(g, q):
        q += 1
    return q


def greedy_coloring(g: Graph, order: Sequence[int] | None = None) -> Dict[int, int]:
    """Greedy: give each person the least emotion unused by already-served friends."""
    vs = list(order) if order is not None else sorted(g)
    colors: Dict[int, int] = {}
    for v in vs:
        used = {colors[w] for w in g[v] if w in colors}
        col = 0
        while col in used:
            col += 1
        colors[v] = col
    return colors


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, condition: bool) -> None:
    status = "OK " if condition else "FAIL"
    print(f"  [{status}] {label}")
    if not condition:
        raise AssertionError(label)


# ----------------------------------------------------------------------------
# 1. Anchors: cliques and friendless populations
# ----------------------------------------------------------------------------

def demo_anchors() -> None:
    banner("1. Anchors:  P_{K_n}(q) = q^{underline n}   and   P_{empty}(q) = q^n")
    for n in range(1, 6):
        for q in range(0, 7):
            kn = chrom_val(complete_graph(n), q)
            en = chrom_val(empty_graph(n), q)
            assert kn == descending_factorial(q, n), (n, q, kn)
            assert en == q ** n, (n, q, en)
        print(f"  n = {n}:  P_K(q) for q=0..6 -> "
              f"{[descending_factorial(q, n) for q in range(7)]}")
    check("falling-factorial law for cliques and power law for friendless groups", True)


# ----------------------------------------------------------------------------
# 2. Structure theorem and the two folklore corrections about thresholds
# ----------------------------------------------------------------------------

def demo_structure() -> None:
    banner("2. Structure theorem:  chi_E(G) = max(chi(G), 3)")
    samples: List[Tuple[str, Graph]] = [
        ("empty on 4", empty_graph(4)),
        ("one person, no friends", empty_graph(1)),
        ("C_4 (even circle)", cycle_graph(4)),
        ("C_5 (odd circle)", cycle_graph(5)),
        ("C_6", cycle_graph(6)),
        ("K_3", complete_graph(3)),
        ("K_5", complete_graph(5)),
        ("hub-and-circle W_5", wheel_hub_and_circle()),
        ("B_{8,4}", clique_below(8, 4)),
    ]
    print(f"  {'network':<28}{'chi':>6}{'chi_E':>8}{'max(chi,3)':>13}")
    for name, g in samples:
        chi = chromatic_number(g)
        emo = emotional_chromatic_number(g)
        print(f"  {name:<28}{chi:>6}{emo:>8}{max(chi, 3):>13}")
        assert emo == max(chi, 3)
    check("chi_E = max(chi, 3) on all samples", True)

    print("\n  Folklore correction (F1): bipartite networks and q = 2")
    for n in (4, 6, 8):
        g = cycle_graph(n)
        print(f"    C_{n} is bipartite: P(2) = {chrom_val(g, 2)}  (NOT a root), chi_E = "
              f"{emotional_chromatic_number(g)}")
        assert chrom_val(g, 2) == 2
    for n in (3, 5, 7):
        g = cycle_graph(n)
        print(f"    C_{n} is odd:       P(2) = {chrom_val(g, 2)}  (root at q = 2)")
        assert chrom_val(g, 2) == 0
    check("P_G(2) = 0 exactly for the non-bipartite circles", True)

    print("\n  Folklore correction (F2): parity is invisible to chi_E")
    for n in range(3, 10):
        g = cycle_graph(n)
        assert emotional_chromatic_number(g) == 3
    print("    chi_E(C_n) = 3 for every n = 3..9, even and odd alike;")
    print("    parity survives only in the counts, P_{C_n}(q) = (q-1)^n + (-1)^n (q-1):")
    for n in range(3, 8):
        p = chrom_val(cycle_graph(n), 6)
        closed = 5 ** n + (-1) ** n * 5
        print(f"    n = {n}:  P(6) = {p:>8}   (q-1)^n + (-1)^n (q-1) = {closed:>8}")
        assert p == closed
    check("cycle counts match (q-1)^n + (-1)^n (q-1)", True)


# ----------------------------------------------------------------------------
# 3-5. Monotonicity, the universal floor, the threshold law
# ----------------------------------------------------------------------------

def demo_order_laws() -> None:
    banner("3-5. Monotonicity laws, universal floor, threshold law")
    g = wheel_hub_and_circle()
    n = len(g)

    print("  Palette monotonicity for the hub-and-circle network:")
    values = [chrom_val(g, q) for q in range(0, 8)]
    print(f"    P(q), q = 0..7:  {values}")
    assert all(values[q] <= values[q + 1] for q in range(len(values) - 1))
    check("q -> P_G(q) is non-decreasing", True)

    print("\n  Edge antitonicity (subnetworks of the hub-and-circle network):")
    sub = cycle_graph(5)
    sub[5] = set()
    print(f"    P_{{five-cycle + isolated hub}}(4) = {chrom_val(sub, 4)}"
          f"  >=  P_{{W_5}}(4) = {chrom_val(g, 4)}")
    assert chrom_val(sub, 4) >= chrom_val(g, 4)
    check("adding friendships never increases the count", True)

    print("\n  Universal floor  q^{underline n} <= P_G(q):")
    for q in range(3, 9):
        lo, actual = descending_factorial(q, n), chrom_val(g, q)
        print(f"    q = {q}:  {lo:>7}  <=  {actual:>8}")
        assert lo <= actual
    check("universal floor holds", True)

    print("\n  Threshold law (q >= 3):  P_G(q) > 0  <=>  chi_E(G) <= q")
    emo = emotional_chromatic_number(g)
    for q in range(3, 9):
        assert (chrom_val(g, q) > 0) == (emo <= q)
    print(f"    chi_E(W_5) = {emo}; support above the floor is {{q : q >= {emo}}}")
    print(f"    at q = 2 the law fails for bipartite networks: "
          f"P_{{C_4}}(2) = {chrom_val(cycle_graph(4), 2)} > 0 but chi_E(C_4) = 3")
    check("threshold law verified, and its q >= 3 hypothesis shown necessary", True)


# ----------------------------------------------------------------------------
# 6. Sandwich theorem and its sharpness
# ----------------------------------------------------------------------------

def demo_sandwich() -> None:
    banner("6. Sandwich theorem:  max(omega,3) <= chi_E <= max(Delta+1,3)")
    star = empty_graph(6)
    for v in range(1, 6):
        add_edge(star, 0, v)
    samples: List[Tuple[str, Graph]] = [
        ("K_4", complete_graph(4)),
        ("C_4", cycle_graph(4)),
        ("C_7", cycle_graph(7)),
        ("star K_{1,5}", star),
        ("hub-and-circle W_5", wheel_hub_and_circle()),
        ("B_{10,6}", clique_below(10, 6)),
        ("random, Delta <= 4", random_bounded_degree_graph(9, 4, seed=7)),
    ]

    print(f"  {'network':<24}{'omega':>7}{'chi_E':>7}{'Delta+1':>9}   sandwich")
    for name, g in samples:
        w, emo, d = clique_number(g), emotional_chromatic_number(g), max_degree(g) + 1
        lo, hi = max(w, 3), max(d, 3)
        assert lo <= emo <= hi
        print(f"  {name:<24}{w:>7}{emo:>7}{d:>9}   {lo} <= {emo} <= {hi}")
    check("sandwich holds on every sample", True)

    print("\n  Sharpness witness: the hub-and-circle network W_5")
    g = wheel_hub_and_circle()
    p3, p4 = chrom_val(g, 3), chrom_val(g, 4)
    print(f"    P(3) = {p3}, P(4) = {p4}  (wheel polynomial q((q-2)^5-(q-2)) at q=4 "
          f"= {4 * ((4 - 2) ** 5 - (4 - 2))})")
    print(f"    omega = {clique_number(g)}, Delta = {max_degree(g)}, "
          f"chi_E = {emotional_chromatic_number(g)}")
    assert p3 == 0 and p4 == 120 and p4 == 4 * ((4 - 2) ** 5 - (4 - 2))
    assert clique_number(g) == 3 and max_degree(g) == 5
    assert emotional_chromatic_number(g) == 4
    check("both inequalities of the sandwich are strict:  3 < 4 < 6", True)

    print("\n  Brute-force cross-check of the counts:")
    assert chrom_val_bruteforce(g, 3) == 0 and chrom_val_bruteforce(g, 4) == 120
    check("deletion-contraction agrees with exhaustive enumeration", True)


# ----------------------------------------------------------------------------
# 7. Greedy abundance
# ----------------------------------------------------------------------------

def demo_abundance() -> None:
    banner("7. Greedy abundance:  (q - d)^n <= P_G(q) when every degree <= d")
    print(f"  {'network':<26}{'n':>4}{'d':>4}{'q':>4}{'(q-d)^n':>12}{'P_G(q)':>14}")
    tests: List[Tuple[str, Graph]] = [
        ("C_6", cycle_graph(6)),
        ("hub-and-circle W_5", wheel_hub_and_circle()),
        ("B_{8,4}", clique_below(8, 4)),
        ("random, Delta <= 3", random_bounded_degree_graph(8, 3, seed=11)),
        ("friendless on 6", empty_graph(6)),
    ]
    for name, g in tests:
        n, d = len(g), max_degree(g)
        for q in (d + 1, d + 3, 6):
            lo, actual = max(q - d, 0) ** n, chrom_val(g, q)
            assert lo <= actual
            print(f"  {name:<26}{n:>4}{d:>4}{q:>4}{lo:>12}{actual:>14}")
    check("abundance bound holds", True)

    print("\n  Sharpness on the friendless population (d = 0): bound = truth")
    for n in (3, 5, 6):
        assert chrom_val(empty_graph(n), 6) == 6 ** n
    print("    P_empty(6) = 6^n exactly, matching (6-0)^n")

    print("\n  Sparse-network corollary: 100 people, Delta <= 5, q = 10 emotions")
    bound = 5 ** 100
    print(f"    at least 5^100 = {bound}")
    print(f"           ~= {float(bound):.3e} consistent assignments")
    check("exponential abundance in sparse networks", bound > 10 ** 69)


# ----------------------------------------------------------------------------
# 8. Closed form and the census
# ----------------------------------------------------------------------------

def clique_below_count(n_people: int, k: int, q: int) -> int:
    """Closed form  P_{B_{N,k}}(q) = q^{underline s} * q^{N-s},  s = min(k,N)."""
    s = min(k, n_people)
    return descending_factorial(q, s) * q ** (n_people - s)


def census_load(i: int) -> int:
    """chi_E of the i-th census network: 50 friendship circles, then 50 clique networks."""
    return 3 if i < 50 else 3 + (i - 50) % 4


def demo_census() -> None:
    banner("8. Closed form for cliques with bystanders, and the hundred-network census")
    print("  Verifying  P_{B_{N,k}}(q) = q^{underline s} q^{N-s}  against enumeration:")
    for n_people, k, q in [(4, 2, 3), (4, 3, 4), (5, 5, 5), (6, 3, 4), (6, 6, 6)]:
        closed = clique_below_count(n_people, k, q)
        brute = chrom_val_bruteforce(clique_below(n_people, k), q)
        print(f"    N={n_people}, k={k}, q={q}:  closed form {closed:>8}  "
              f"enumeration {brute:>8}")
        assert closed == brute
    check("closed form matches exhaustive enumeration", True)

    print("\n  Ten-person clique networks, six emotions:")
    expected = {3: 33592320, 4: 16796160, 5: 5598720, 6: 933120}
    print(f"    {'clique size':<14}{'P(6)':>14}{'chi_E':>8}")
    prev = None
    for k in (3, 4, 5, 6):
        val = clique_below_count(10, k, 6)
        emo = max(min(k, 10), 3)
        print(f"    {k:<14}{val:>14,}{emo:>8}")
        assert val == expected[k]
        if prev is not None:
            assert val < prev
        prev = val
    check("six-emotion counts are exact and strictly decreasing in the clique size", True)
    print("    minimum over the family = 933,120, attained by the six-person clique")

    print("\n  The census: 50 friendship circles C_3..C_52, 50 clique networks B_{10,3+i%4}")
    loads = [census_load(i) for i in range(100)]
    total = sum(loads)
    dist = {v: loads.count(v) for v in (3, 4, 5, 6)}
    print(f"    total emotional load = {total}   (average {total / 100:.2f} emotions/network)")
    print(f"    distribution: {dist}")
    assert total == 373 and dist == {3: 63, 4: 13, 5: 12, 6: 12}
    assert all(3 <= L <= 6 for L in loads)
    check("census: window [3,6], total load 373, distribution 63/13/12/12", True)

    print("\n  Spot-check the census values against direct computation:")
    for i in (0, 1, 7, 12):
        g = cycle_graph(i + 3)
        assert emotional_chromatic_number(g) == 3
    for i in (0, 1, 2, 3, 9):
        g = clique_below(10, 3 + i % 4)
        assert emotional_chromatic_number(g) == 3 + i % 4
    check("spot checks agree with the closed-form census values", True)

    print("\n  Folklore correction (F3): the window is not universal")
    k7 = complete_graph(7)
    print(f"    K_7:  P(6) = {chrom_val(k7, 6)},  chi_E = {emotional_chromatic_number(k7)}")
    assert chrom_val(k7, 6) == 0 and emotional_chromatic_number(k7) == 7
    check("a seven-person clique breaks the six-emotion window", True)


# ----------------------------------------------------------------------------
# 9. Conservation laws
# ----------------------------------------------------------------------------

def demo_conservation() -> None:
    banner("9. Conservation laws:  n <= chi_E(G) * chi_E(complement G)")
    samples: List[Tuple[str, Graph]] = [
        ("K_5", complete_graph(5)),
        ("C_5 (self-complementary)", cycle_graph(5)),
        ("C_6", cycle_graph(6)),
        ("hub-and-circle W_5", wheel_hub_and_circle()),
        ("B_{8,4}", clique_below(8, 4)),
        ("random, Delta <= 3", random_bounded_degree_graph(8, 3, seed=5)),
    ]
    print(f"  {'network':<28}{'n':>4}{'chi_E(G)':>10}{'chi_E(Gbar)':>13}{'product':>9}")
    for name, g in samples:
        n = len(g)
        a, b = emotional_chromatic_number(g), emotional_chromatic_number(complement_graph(g))
        assert n <= a * b
        assert 4 * n <= (a + b) ** 2
        print(f"  {name:<28}{n:>4}{a:>10}{b:>13}{a * b:>9}")
    check("product law and sum law hold on all samples", True)

    print("\n  C_5 is self-complementary: chi_E(C_5) * chi_E(Cbar_5) = 3*3 = 9 > 5 "
          "(loose, as predicted)")
    print("  Emotional duality: 100 people with chi_E(G) <= 6 force chi_E(Gbar) >= 17,")
    print(f"    since 100 <= 6 * chi_E(Gbar)  =>  chi_E(Gbar) >= {math.ceil(100 / 6)}")
    print("  Sparse => dense complement: Delta(G) <= 5 on 100 people forces "
          "Delta(Gbar) >= 16.")
    check("emotional duality arithmetic", math.ceil(100 / 6) == 17)


# ----------------------------------------------------------------------------
# 10. Disjoint communities and the greedy algorithm
# ----------------------------------------------------------------------------

def demo_communities_and_greedy() -> None:
    banner("10. Disjoint communities and the greedy algorithm")
    g, h = complete_graph(4), cycle_graph(5)
    u = disjoint_union(g, h)
    a, b, c = (emotional_chromatic_number(x) for x in (g, h, u))
    print(f"  chi_E(K_4) = {a}, chi_E(C_5) = {b}, chi_E(K_4 union C_5) = {c} = max = {max(a, b)}")
    assert c == max(a, b)
    check("chi_E of a disjoint union is the maximum of the parts", True)

    print("\n  Greedy coloring never uses more than Delta + 1 emotions:")
    for name, graph in [("W_5", wheel_hub_and_circle()), ("C_7", cycle_graph(7)),
                        ("B_{10,6}", clique_below(10, 6)),
                        ("random Delta<=4", random_bounded_degree_graph(12, 4, seed=3))]:
        colors = greedy_coloring(graph)
        used = len(set(colors.values()))
        ok = all(colors[x] != colors[y] for x, y in edges(graph))
        print(f"    {name:<18} Delta = {max_degree(graph)},  greedy used {used} emotions, "
              f"proper: {ok}")
        assert ok and used <= max_degree(graph) + 1
    check("greedy is proper and within the Delta+1 budget", True)


# ----------------------------------------------------------------------------

def main() -> None:
    print("Emotional chromatic numbers: numerical demonstrations")
    demo_anchors()
    demo_structure()
    demo_order_laws()
    demo_sandwich()
    demo_abundance()
    demo_census()
    demo_conservation()
    demo_communities_and_greedy()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
