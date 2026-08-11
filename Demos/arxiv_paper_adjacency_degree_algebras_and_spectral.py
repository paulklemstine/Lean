"""
Adjacency-degree algebras and moment rigidity of graphs
=======================================================

Self-contained numerical demonstration of the results:

  * word moments  m_G(w) = 1^T w(A, D) 1  are isomorphism invariants;
  * the caterpillar expansion
        1^T D^{a_0} A D^{a_1} A ... A D^{a_n} 1
          = sum over walks p_0 ~ ... ~ p_n of  prod_i deg(p_i)^{a_i};
  * moment equality implies equality of the degree distribution and of the
    joint degree distribution N_{a,b};
  * moments equal decorated caterpillar walk counts in strength;
  * the cyclic module M_G = <I, A, D> 1 sits inside the orbit module U_G,
    and dim M_G = 1 exactly for regular graphs;
  * regular blindness:  m_G(w) = k^{|w|} n  for every k-regular graph;
  * the quotient formula on an equitable colouring, and the connected
    non-regular six-vertex pair H1, H2 that it certifies as
    moment-equivalent but non-isomorphic.

Pure Python + standard library only (fractions used for exact arithmetic).
Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, permutations, product
from typing import Dict, Iterable, List, Sequence, Tuple

Graph = List[List[int]]  # adjacency matrix as a list of rows of 0/1
Word = str  # a string over the alphabet {"A", "D"}


# ----------------------------------------------------------------------
# Graph construction helpers
# ----------------------------------------------------------------------


def graph_from_edges(n: int, edges: Iterable[Tuple[int, int]]) -> Graph:
    """Build the n-vertex adjacency matrix of a simple graph from an edge list."""
    adj: Graph = [[0] * n for _ in range(n)]
    for u, v in edges:
        if u == v:
            raise ValueError("simple graphs have no loops")
        adj[u][v] = 1
        adj[v][u] = 1
    return adj


def degrees(adj: Graph) -> List[int]:
    """Degree sequence, indexed by vertex."""
    return [sum(row) for row in adj]


def edge_list(adj: Graph) -> List[Tuple[int, int]]:
    """Undirected edges as sorted pairs."""
    n = len(adj)
    return [(u, v) for u in range(n) for v in range(u + 1, n) if adj[u][v]]


def is_connected(adj: Graph) -> bool:
    """Breadth-first reachability from vertex 0."""
    n = len(adj)
    if n == 0:
        return True
    seen = {0}
    stack = [0]
    while stack:
        u = stack.pop()
        for v in range(n):
            if adj[u][v] and v not in seen:
                seen.add(v)
                stack.append(v)
    return len(seen) == n


def triangle_count(adj: Graph) -> int:
    """Number of unordered triangles."""
    n = len(adj)
    return sum(
        1
        for a, b, c in combinations(range(n), 3)
        if adj[a][b] and adj[b][c] and adj[a][c]
    )


def is_isomorphic(g1: Graph, g2: Graph) -> bool:
    """Brute-force isomorphism test (only used on tiny graphs)."""
    n = len(g1)
    if n != len(g2) or sorted(degrees(g1)) != sorted(degrees(g2)):
        return False
    for perm in permutations(range(n)):
        if all(g1[u][v] == g2[perm[u]][perm[v]] for u in range(n) for v in range(n)):
            return True
    return False


# ----------------------------------------------------------------------
# Word moments
# ----------------------------------------------------------------------


def apply_letter(adj: Graph, deg: Sequence[int], letter: str,
                 x: Sequence[Fraction]) -> List[Fraction]:
    """Apply A (hopping) or D (degree potential) to a vector, in O(n^2)/O(n)."""
    n = len(adj)
    if letter == "A":
        return [sum(x[v] for v in range(n) if adj[u][v]) for u in range(n)]
    if letter == "D":
        return [Fraction(deg[u]) * x[u] for u in range(n)]
    raise ValueError(f"unknown letter {letter!r}")


def word_moment(adj: Graph, word: Word) -> Fraction:
    """m_G(w) = 1^T w(A, D) 1, computed by right-to-left vector propagation."""
    n = len(adj)
    deg = degrees(adj)
    x: List[Fraction] = [Fraction(1)] * n
    for letter in reversed(word):
        x = apply_letter(adj, deg, letter, x)
    return sum(x, Fraction(0))


def all_words(max_len: int) -> List[Word]:
    """All words over {A, D} of length at most max_len, shortest first."""
    words: List[Word] = [""]
    for length in range(1, max_len + 1):
        words.extend("".join(t) for t in product("AD", repeat=length))
    return words


def moment_vector(adj: Graph, max_len: int) -> Dict[Word, Fraction]:
    """The full moment table up to a given word length."""
    return {w: word_moment(adj, w) for w in all_words(max_len)}


def moment_equivalent(g1: Graph, g2: Graph, max_len: int = 6) -> bool:
    """Test moment equality for all words up to a given length."""
    return moment_vector(g1, max_len) == moment_vector(g2, max_len)


# ----------------------------------------------------------------------
# Caterpillar expansion: moments as decorated walk sums
# ----------------------------------------------------------------------


def caterpillar_word(exponents: Sequence[int]) -> Word:
    """D^{a_0} A D^{a_1} A ... A D^{a_n} as a word over {A, D}."""
    return "A".join("D" * a for a in exponents)


def decorated_walk_sum(adj: Graph, exponents: Sequence[int]) -> Fraction:
    """Sum over all walks p_0 ~ ... ~ p_n of prod_i deg(p_i)^{a_i}, by brute force."""
    n_hops = len(exponents) - 1
    n = len(adj)
    deg = degrees(adj)
    total = Fraction(0)
    for walk in product(range(n), repeat=n_hops + 1):
        if all(adj[walk[i]][walk[i + 1]] for i in range(n_hops)):
            weight = Fraction(1)
            for i, a in enumerate(exponents):
                weight *= Fraction(deg[walk[i]]) ** a
            total += weight
    return total


def decorated_walk_count(adj: Graph, pattern: Sequence[int]) -> int:
    """c_G(n; b): number of walks whose degree sequence is exactly `pattern`."""
    n_hops = len(pattern) - 1
    n = len(adj)
    deg = degrees(adj)
    count = 0
    for walk in product(range(n), repeat=n_hops + 1):
        if all(adj[walk[i]][walk[i + 1]] for i in range(n_hops)) and all(
            deg[walk[i]] == pattern[i] for i in range(n_hops + 1)
        ):
            count += 1
    return count


def all_decorated_walk_counts(adj: Graph, n_hops: int) -> Dict[Tuple[int, ...], int]:
    """All nonzero decorated walk counts of a given length."""
    n = len(adj)
    deg = degrees(adj)
    counts: Dict[Tuple[int, ...], int] = {}
    for walk in product(range(n), repeat=n_hops + 1):
        if all(adj[walk[i]][walk[i + 1]] for i in range(n_hops)):
            key = tuple(deg[v] for v in walk)
            counts[key] = counts.get(key, 0) + 1
    return counts


# ----------------------------------------------------------------------
# Degree and joint-degree statistics
# ----------------------------------------------------------------------


def degree_distribution(adj: Graph) -> Dict[int, int]:
    """Number of vertices of each degree."""
    dist: Dict[int, int] = {}
    for d in degrees(adj):
        dist[d] = dist.get(d, 0) + 1
    return dist


def joint_degree_counts(adj: Graph) -> Dict[Tuple[int, int], int]:
    """N_{a,b}: ordered adjacent pairs (u, v) with deg u = a, deg v = b."""
    n = len(adj)
    deg = degrees(adj)
    counts: Dict[Tuple[int, int], int] = {}
    for u in range(n):
        for v in range(n):
            if adj[u][v]:
                key = (deg[u], deg[v])
                counts[key] = counts.get(key, 0) + 1
    return counts


def lagrange_basis(nodes: Sequence[int], target: int) -> List[Fraction]:
    """Coefficients of the Lagrange basis polynomial that is 1 at `target`, 0 elsewhere."""
    coeffs = [Fraction(1)]
    for node in nodes:
        if node == target:
            continue
        # multiply by (x - node) / (target - node)
        scale = Fraction(1, target - node)
        new = [Fraction(0)] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new[i + 1] += c * scale
            new[i] -= c * node * scale
        coeffs = new
    return coeffs


def degree_distribution_from_moments(moments: Dict[Word, Fraction], n: int) -> Dict[int, int]:
    """Recover the degree distribution from the pure-degree moments 1^T D^k 1."""
    power_sums = [moments["D" * k] for k in range(n)]
    nodes = list(range(n))
    dist: Dict[int, int] = {}
    for d in nodes:
        coeffs = lagrange_basis(nodes, d)
        value = sum(c * power_sums[i] for i, c in enumerate(coeffs))
        if value != 0:
            dist[d] = int(value)
    return dist


def joint_degree_from_moments(adj: Graph, n: int) -> Dict[Tuple[int, int], int]:
    """Recover N_{a,b} from the moments 1^T D^i A D^j 1 by double interpolation."""
    raw = {
        (i, j): word_moment(adj, "D" * i + "A" + "D" * j)
        for i in range(n)
        for j in range(n)
    }
    nodes = list(range(n))
    out: Dict[Tuple[int, int], int] = {}
    for a in nodes:
        ca = lagrange_basis(nodes, a)
        for b in nodes:
            cb = lagrange_basis(nodes, b)
            value = sum(
                ca[i] * cb[j] * raw[(i, j)]
                for i in range(len(ca))
                for j in range(len(cb))
            )
            if value != 0:
                out[(a, b)] = int(value)
    return out


# ----------------------------------------------------------------------
# The cyclic module M_G and the orbit module U_G
# ----------------------------------------------------------------------


def rref_rank(rows: List[List[Fraction]]) -> int:
    """Rank of a matrix over the rationals by Gaussian elimination."""
    mat = [row[:] for row in rows]
    rank = 0
    ncols = len(mat[0]) if mat else 0
    for col in range(ncols):
        pivot = next((r for r in range(rank, len(mat)) if mat[r][col] != 0), None)
        if pivot is None:
            continue
        mat[rank], mat[pivot] = mat[pivot], mat[rank]
        inv = Fraction(1) / mat[rank][col]
        mat[rank] = [x * inv for x in mat[rank]]
        for r in range(len(mat)):
            if r != rank and mat[r][col] != 0:
                factor = mat[r][col]
                mat[r] = [x - factor * y for x, y in zip(mat[r], mat[rank])]
        rank += 1
    return rank


def cyclic_module_basis(adj: Graph, max_len: int = 8) -> List[List[Fraction]]:
    """Vectors w(A, D) 1 for all words w up to a given length (a spanning set of M_G)."""
    n = len(adj)
    deg = degrees(adj)
    vectors: List[List[Fraction]] = []
    for word in all_words(max_len):
        x: List[Fraction] = [Fraction(1)] * n
        for letter in reversed(word):
            x = apply_letter(adj, deg, letter, x)
        vectors.append(x)
    return vectors


def cyclic_module_dimension(adj: Graph, max_len: int = 8) -> int:
    """dim M_G, computed from a spanning set (stabilises well before max_len)."""
    return rref_rank(cyclic_module_basis(adj, max_len))


def automorphisms(adj: Graph) -> List[Tuple[int, ...]]:
    """All automorphisms, by brute force (tiny graphs only)."""
    n = len(adj)
    return [
        perm
        for perm in permutations(range(n))
        if all(adj[u][v] == adj[perm[u]][perm[v]] for u in range(n) for v in range(n))
    ]


def orbit_partition(adj: Graph) -> List[List[int]]:
    """Orbits of the automorphism group on vertices."""
    n = len(adj)
    auts = automorphisms(adj)
    seen = [False] * n
    orbits: List[List[int]] = []
    for v in range(n):
        if seen[v]:
            continue
        orbit = sorted({perm[v] for perm in auts})
        for u in orbit:
            seen[u] = True
        orbits.append(orbit)
    return orbits


def orbit_module_dimension(adj: Graph) -> int:
    """dim U_G = number of automorphism orbits."""
    return len(orbit_partition(adj))


# ----------------------------------------------------------------------
# Colour refinement and the quotient formula
# ----------------------------------------------------------------------


def colour_refinement(adj: Graph) -> List[int]:
    """Stable colouring (1-WL): returns a canonical integer colour per vertex."""
    n = len(adj)
    colours = [0] * n
    while True:
        signature = [
            (colours[u], tuple(sorted(colours[v] for v in range(n) if adj[u][v])))
            for u in range(n)
        ]
        order = {sig: i for i, sig in enumerate(sorted(set(signature)))}
        new = [order[sig] for sig in signature]
        if new == colours:
            return colours
        colours = new


def is_equitable(adj: Graph, colouring: Sequence[int]) -> bool:
    """Check the equitable-partition condition directly."""
    n = len(adj)
    palette = sorted(set(colouring))
    for u in range(n):
        for v in range(n):
            if colouring[u] != colouring[v]:
                continue
            for kappa in palette:
                cu = sum(1 for w in range(n) if adj[u][w] and colouring[w] == kappa)
                cv = sum(1 for w in range(n) if adj[v][w] and colouring[w] == kappa)
                if cu != cv:
                    return False
    return True


def quotient_data(adj: Graph, colouring: Sequence[int]):
    """Class sizes, quotient matrix B, and class degrees Delta of an equitable colouring."""
    n = len(adj)
    palette = sorted(set(colouring))
    sizes = [sum(1 for v in range(n) if colouring[v] == kappa) for kappa in palette]
    reps = [next(v for v in range(n) if colouring[v] == kappa) for kappa in palette]
    deg = degrees(adj)
    quot = [
        [sum(1 for w in range(n) if adj[r][w] and colouring[w] == lam) for lam in palette]
        for r in reps
    ]
    class_deg = [deg[r] for r in reps]
    return sizes, quot, class_deg


def quotient_moment(sizes: Sequence[int], quot: Sequence[Sequence[int]],
                    class_deg: Sequence[int], word: Word) -> Fraction:
    """sum_kappa |kappa| * (w(B, Delta) 1)_kappa -- the quotient formula's right-hand side."""
    c = len(sizes)
    x: List[Fraction] = [Fraction(1)] * c
    for letter in reversed(word):
        if letter == "A":
            x = [sum(Fraction(quot[k][l]) * x[l] for l in range(c)) for k in range(c)]
        else:
            x = [Fraction(class_deg[k]) * x[k] for k in range(c)]
    return sum(Fraction(sizes[k]) * x[k] for k in range(c))


# ----------------------------------------------------------------------
# Named graphs
# ----------------------------------------------------------------------


def star(n_leaves: int) -> Graph:
    """K_{1,n}: centre 0 joined to n leaves."""
    return graph_from_edges(n_leaves + 1, [(0, i) for i in range(1, n_leaves + 1)])


def path(n: int) -> Graph:
    """The path on n vertices."""
    return graph_from_edges(n, [(i, i + 1) for i in range(n - 1)])


def cycle(n: int) -> Graph:
    """The cycle C_n."""
    return graph_from_edges(n, [(i, (i + 1) % n) for i in range(n)])


def two_triangles() -> Graph:
    """2K_3: two disjoint triangles on six vertices."""
    return graph_from_edges(6, [(0, 1), (1, 2), (0, 2), (3, 4), (4, 5), (3, 5)])


HEX1_EDGES = [(0, 3), (0, 4), (0, 5), (1, 3), (1, 5), (2, 3), (2, 4)]
HEX2_EDGES = [(0, 1), (0, 2), (0, 5), (1, 5), (2, 3), (2, 4), (3, 4)]


def hex1() -> Graph:
    """H1: the triangle-free (bipartite) six-vertex witness."""
    return graph_from_edges(6, HEX1_EDGES)


def hex2() -> Graph:
    """H2: the six-vertex witness containing a triangle."""
    return graph_from_edges(6, HEX2_EDGES)


def relabel(adj: Graph, perm: Sequence[int]) -> Graph:
    """Relabel vertices: new vertex perm[u] plays the role of old vertex u."""
    n = len(adj)
    out: Graph = [[0] * n for _ in range(n)]
    for u in range(n):
        for v in range(n):
            out[perm[u]][perm[v]] = adj[u][v]
    return out


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 72)
    print(title)
    print("=" * 72)


def demo_basic_moments() -> None:
    banner("1. Basic moments: order, size, degree power sums, decorated edges")
    g = path(5)
    n = len(g)
    print(f"Graph: path on {n} vertices, degrees {degrees(g)}")
    print(f"  m(empty)  = {word_moment(g, '')}        (= number of vertices {n})")
    print(f"  m(A)      = {word_moment(g, 'A')}        (= 2|E| = {2 * len(edge_list(g))})")
    for k in range(1, 4):
        lhs = word_moment(g, "D" * k)
        rhs = sum(d ** k for d in degrees(g))
        print(f"  m(D^{k})    = {lhs}       (= sum of d^{k} = {rhs})  match: {lhs == rhs}")
    deg = degrees(g)
    rhs = sum(2 * deg[u] * deg[v] for u, v in edge_list(g))
    print(f"  m(DAD)    = {word_moment(g, 'DAD')}      (= 2 * sum_{{uv in E}} d_u d_v = {rhs})")


def demo_isomorphism_invariance() -> None:
    banner("2. Word moments are isomorphism invariants")
    g = hex1()
    perm = (3, 1, 5, 0, 2, 4)
    h = relabel(g, perm)
    same = moment_equivalent(g, h, max_len=5)
    print(f"Relabelling H1 by the permutation {perm}.")
    print(f"  All moments of words of length <= 5 agree: {same}")
    print(f"  Sample: m(ADDA) = {word_moment(g, 'ADDA')} vs {word_moment(h, 'ADDA')}")


def demo_caterpillar_expansion() -> None:
    banner("3. Caterpillar expansion: moments are decorated walk sums")
    g = hex1()
    print("Checking  m(D^{a0} A D^{a1} A ... ) = sum over walks of prod deg(p_i)^{a_i}")
    for exps in [(0, 0), (1, 0), (1, 1), (2, 1), (0, 1, 0), (1, 0, 2), (2, 2, 1)]:
        word = caterpillar_word(exps)
        lhs = word_moment(g, word)
        rhs = decorated_walk_sum(g, exps)
        label = word if word else "(empty)"
        print(f"  a = {str(exps):12s} word = {label:12s} moment = {str(lhs):>8s} "
              f"walk sum = {str(rhs):>8s}  match: {lhs == rhs}")


def demo_degree_recovery() -> None:
    banner("4. Recovering the degree and joint degree distributions from moments")
    g = hex2()
    n = len(g)
    moments = moment_vector(g, max_len=n)
    recovered = degree_distribution_from_moments(moments, n)
    actual = degree_distribution(g)
    print(f"Graph H2, degrees {degrees(g)}")
    print(f"  degree distribution, direct      : {dict(sorted(actual.items()))}")
    print(f"  recovered by interpolation from moments 1^T D^k 1: "
          f"{dict(sorted(recovered.items()))}")
    print(f"  match: {actual == recovered}")
    joint_direct = joint_degree_counts(g)
    joint_moment = joint_degree_from_moments(g, n)
    print(f"  joint degrees N_(a,b), direct    : {dict(sorted(joint_direct.items()))}")
    print(f"  recovered from moments D^i A D^j : {dict(sorted(joint_moment.items()))}")
    print(f"  match: {joint_direct == joint_moment}")


def demo_modules() -> None:
    banner("5. The cyclic module M_G, the orbit module U_G, and regularity")
    examples = [
        ("path P_5", path(5)),
        ("star K_{1,4}", star(4)),
        ("cycle C_6 (2-regular)", cycle(6)),
        ("2K_3 (2-regular)", two_triangles()),
        ("H1", hex1()),
        ("H2", hex2()),
    ]
    print(f"{'graph':<24}{'dim M_G':>9}{'dim U_G':>9}{'regular':>10}")
    for name, g in examples:
        dm = cyclic_module_dimension(g)
        du = orbit_module_dimension(g)
        reg = len(set(degrees(g))) == 1
        print(f"{name:<24}{dm:>9}{du:>9}{str(reg):>10}")
    print()
    print("  Ceiling  M_G <= U_G  is visible as dim M_G <= dim U_G in every row.")
    print("  Floor    dim M_G = 1 occurs exactly in the regular rows.")
    print("  Stars attain the ceiling: dim M = dim U.")


def demo_regular_blindness() -> None:
    banner("6. Regular blindness: k-regular graphs of the same order are moment-equal")
    g1, g2 = cycle(6), two_triangles()
    print("C_6 versus 2K_3, both 2-regular on 6 vertices.")
    print(f"{'word':<10}{'m(C_6)':>10}{'m(2K_3)':>10}{'2^|w| * 6':>12}")
    for word in ["", "A", "D", "AD", "DA", "ADD", "DADA"]:
        predicted = 2 ** len(word) * 6
        print(f"{(word or '(empty)'):<10}{str(word_moment(g1, word)):>10}"
              f"{str(word_moment(g2, word)):>10}{predicted:>12}")
    print(f"  moment-equivalent (length <= 6): {moment_equivalent(g1, g2, 6)}")
    print(f"  isomorphic                     : {is_isomorphic(g1, g2)}")
    print(f"  triangles: C_6 has {triangle_count(g1)}, 2K_3 has {triangle_count(g2)}")


def demo_six_vertex_witness() -> None:
    banner("7. The connected non-regular six-vertex witness H1 vs H2")
    g1, g2 = hex1(), hex2()
    print(f"H1 edges: {HEX1_EDGES}")
    print(f"H2 edges: {HEX2_EDGES}")
    print(f"  degrees        : {degrees(g1)}  and  {degrees(g2)}")
    print(f"  connected      : {is_connected(g1)}  and  {is_connected(g2)}")
    print(f"  regular        : {len(set(degrees(g1))) == 1}  and  "
          f"{len(set(degrees(g2))) == 1}")
    print(f"  triangles      : {triangle_count(g1)}  and  {triangle_count(g2)}")
    print(f"  isomorphic     : {is_isomorphic(g1, g2)}")
    print(f"  moment-equal (words of length <= 7): {moment_equivalent(g1, g2, 7)}")
    print()
    print("  Quotient certificate (colour refinement):")
    for name, g in [("H1", g1), ("H2", g2)]:
        colouring = colour_refinement(g)
        sizes, quot, class_deg = quotient_data(g, colouring)
        print(f"    {name}: colouring {colouring}, equitable {is_equitable(g, colouring)}")
        print(f"        class sizes {sizes}, class degrees {class_deg}, B = {quot}")
    print()
    print("  Quotient formula check (moment = size-weighted quotient moment):")
    colouring1 = colour_refinement(g1)
    sizes, quot, class_deg = quotient_data(g1, colouring1)
    for word in ["", "A", "DA", "ADAD", "DDADA"]:
        lhs = word_moment(g1, word)
        rhs = quotient_moment(sizes, quot, class_deg, word)
        print(f"    w = {(word or '(empty)'):<8s} m(H1) = {str(lhs):>10s} "
              f"quotient = {str(rhs):>10s}  match: {lhs == rhs}")
    print()
    print("  Equal decorated walk counts (same invariant, combinatorial form):")
    for n_hops in range(4):
        c1 = all_decorated_walk_counts(g1, n_hops)
        c2 = all_decorated_walk_counts(g2, n_hops)
        print(f"    length {n_hops}: {len(c1)} nonzero patterns, identical: {c1 == c2}")


def demo_equivalence() -> None:
    banner("8. Moments and decorated walk counts have the same strength")
    g = hex1()
    print("Regrouping identity  m(W(a)) = sum_b c(n;b) * prod_i b_i^{a_i}  on H1:")
    for exps in [(1, 0), (2, 1), (1, 1, 1), (0, 2, 1)]:
        word = caterpillar_word(exps)
        lhs = word_moment(g, word)
        counts = all_decorated_walk_counts(g, len(exps) - 1)
        rhs = sum(
            Fraction(count) * Fraction(
                int(eval_pattern(pattern, exps))
            )
            for pattern, count in counts.items()
        )
        print(f"  a = {str(exps):12s} moment = {str(lhs):>10s} "
              f"regrouped = {str(rhs):>10s}  match: {lhs == rhs}")


def eval_pattern(pattern: Sequence[int], exponents: Sequence[int]) -> int:
    """prod_i pattern_i ^ exponents_i."""
    out = 1
    for b, a in zip(pattern, exponents):
        out *= b ** a
    return out


def demo_stars() -> None:
    banner("9. Stars are determined by their moments, and attain M_G = U_G")
    print(f"{'star':<12}{'dim M':>7}{'dim U':>7}{'m(empty)':>10}{'m(A)':>8}{'m(DAD)':>9}")
    for k in range(1, 6):
        g = star(k)
        print(f"{'K_{1,' + str(k) + '}':<12}{cyclic_module_dimension(g):>7}"
              f"{orbit_module_dimension(g):>7}{str(word_moment(g, '')):>10}"
              f"{str(word_moment(g, 'A')):>8}{str(word_moment(g, 'DAD')):>9}")
    print()
    print("  Distinct stars already differ in the empty-word moment (their order),")
    print("  so moment equality inside the star family forces isomorphism.")


def rooted_canonical(adj: Graph, root: int, parent: int) -> str:
    """AHU canonical string of the subtree rooted at `root`."""
    children = sorted(
        rooted_canonical(adj, v, root)
        for v in range(len(adj))
        if adj[root][v] and v != parent
    )
    return "(" + "".join(children) + ")"


def tree_centroids(adj: Graph) -> List[int]:
    """The one or two centroid vertices of a tree."""
    n = len(adj)

    def subtree_sizes(root: int, parent: int) -> int:
        size = 1
        for v in range(n):
            if adj[root][v] and v != parent:
                size += subtree_sizes(v, root)
        sizes[root] = size
        return size

    sizes = [0] * n
    subtree_sizes(0, -1)

    best: List[int] = []
    best_value = n + 1
    for u in range(n):
        pieces = [sizes[v] for v in range(n) if adj[u][v] and sizes[v] < sizes[u]]
        pieces.append(n - 1 - sum(pieces))
        value = max(pieces) if pieces else 0
        if value < best_value:
            best_value, best = value, [u]
        elif value == best_value:
            best.append(u)
    return best


def tree_canonical(adj: Graph) -> str:
    """Canonical form of a free tree: minimal AHU string over its centroids."""
    if len(adj) == 1:
        return "()"
    return min(rooted_canonical(adj, c, -1) for c in tree_centroids(adj))


def generate_trees(n: int) -> List[Graph]:
    """All non-isomorphic trees on n vertices, by leaf extension with canonical dedup."""
    trees: List[Graph] = [graph_from_edges(1, [])]
    for size in range(2, n + 1):
        seen: Dict[str, Graph] = {}
        for t in trees:
            for attach in range(size - 1):
                edges = edge_list(t) + [(attach, size - 1)]
                g = graph_from_edges(size, edges)
                seen.setdefault(tree_canonical(g), g)
        trees = list(seen.values())
    return trees


def demo_trees() -> None:
    banner("10. Moments separate all small trees (evidence for the tree conjecture)")
    print("  For each n, group the non-isomorphic trees by their moment signature")
    print("  (caterpillar words with spine length <= 5 and exponents in {0, 1});")
    print("  a collision would be a counterexample to the tree conjecture.")
    words = [
        caterpillar_word(exps)
        for hops in range(6)
        for exps in product(range(2), repeat=hops + 1)
    ]
    for n in range(2, 12):
        trees = generate_trees(n)
        signatures: Dict[Tuple, List[Graph]] = {}
        for t in trees:
            key = tuple(word_moment(t, w) for w in words)
            signatures.setdefault(key, []).append(t)
        collisions = sum(len(group) - 1 for group in signatures.values())
        print(f"  n = {n}: {len(trees):3d} non-isomorphic trees, "
              f"{len(signatures):3d} distinct moment signatures, "
              f"collisions: {collisions}")


def main() -> None:
    print(__doc__)
    demo_basic_moments()
    demo_isomorphism_invariance()
    demo_caterpillar_expansion()
    demo_degree_recovery()
    demo_modules()
    demo_regular_blindness()
    demo_six_vertex_witness()
    demo_equivalence()
    demo_stars()
    demo_trees()
    banner("Done")


if __name__ == "__main__":
    main()
