"""
Emergent Spacetime from Quantum Entanglement
============================================

Numerical demonstrations of the combinatorial ER = EPR theory.

A *geometry* on n cells is a symmetric, nonnegative matrix w of "areas".
A *region* is a subset of cells, encoded as a bitmask.  Its area is the total
weight of the walls separating it from its complement:

    area(f) = sum_{x in f} sum_{y not in f} w[x][y]

A *holographic model* additionally marks a set of boundary cells.  The entropy
of a boundary region A is the minimal area over all regions agreeing with A on
the boundary (the discrete Ryu-Takayanagi prescription), and the mutual
information is I(A:B) = S(A) + S(B) - S(A u B).

The *throat capacity* E(A,B) is the minimal area over all regions containing A
and missing B -- the cross-section of the Einstein-Rosen bridge joining them.
The *emergent distance* is d(u,v) = exp(-E({u},{v})).

Everything is computed by exhaustive enumeration over the 2^n regions, which is
exact and fast for the small examples used here.

Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Iterable, List, Sequence, Tuple

Matrix = List[List[float]]
Region = int  # bitmask over cells


# ---------------------------------------------------------------------------
# Core combinatorics
# ---------------------------------------------------------------------------

def make_geometry(n: int, edges: Dict[Tuple[int, int], float]) -> Matrix:
    """Build a symmetric nonnegative area matrix from a dict of edge weights."""
    w: Matrix = [[0.0] * n for _ in range(n)]
    for (x, y), val in edges.items():
        if val < 0.0:
            raise ValueError("areas must be nonnegative")
        w[x][y] = float(val)
        w[y][x] = float(val)
    return w


def in_region(f: Region, x: int) -> bool:
    """Is cell x inside region f?"""
    return (f >> x) & 1 == 1


def region_of(cells: Iterable[int]) -> Region:
    """Bitmask of a collection of cells."""
    f = 0
    for x in cells:
        f |= 1 << x
    return f


def area(w: Matrix, f: Region) -> float:
    """Area of the surface bounding the region f (the cut weight)."""
    n = len(w)
    total = 0.0
    for x in range(n):
        if not in_region(f, x):
            continue
        for y in range(n):
            if not in_region(f, y):
                total += w[x][y]
    return total


def all_regions(n: int) -> Iterable[Region]:
    """Every one of the 2^n regions."""
    return range(1 << n)


def entropy(w: Matrix, boundary: Region, a: Region) -> float:
    """Ryu-Takayanagi entropy: minimal area over regions agreeing with A on the boundary."""
    n = len(w)
    best = math.inf
    for f in all_regions(n):
        if (f & boundary) == (a & boundary):
            best = min(best, area(w, f))
    return best


def mutual_information(w: Matrix, boundary: Region, a: Region, b: Region) -> float:
    """I(A:B) = S(A) + S(B) - S(A u B)."""
    return (entropy(w, boundary, a)
            + entropy(w, boundary, b)
            - entropy(w, boundary, a | b))


def throat(w: Matrix, a: Region, b: Region) -> float:
    """Throat capacity E(A,B): minimal area over regions containing A and missing B."""
    n = len(w)
    best = math.inf
    for f in all_regions(n):
        if (f & a) == a and (f & b) == 0:
            best = min(best, area(w, f))
    return 0.0 if best is math.inf else best


def cap(w: Matrix, u: int, v: int) -> float:
    """Bridge capacity between two single cells."""
    return throat(w, 1 << u, 1 << v)


def bridge_distance(w: Matrix, u: int, v: int) -> float:
    """Emergent distance d(u,v) = exp(-cap(u,v)), and 0 on the diagonal."""
    if u == v:
        return 0.0
    return math.exp(-cap(w, u, v))


def connected(w: Matrix, u: int, v: int) -> bool:
    """Is there a bulk path of positive-area edges from u to v?"""
    n = len(w)
    seen = {u}
    stack = [u]
    while stack:
        x = stack.pop()
        for y in range(n):
            if y not in seen and w[x][y] > 0.0:
                seen.add(y)
                stack.append(y)
    return v in seen


# ---------------------------------------------------------------------------
# Bit threads
# ---------------------------------------------------------------------------

def thread_divergence(flow: Matrix, x: int) -> float:
    """Net flux emanating from a cell."""
    return sum(flow[x])


def thread_value(flow: Matrix, source: Region) -> float:
    """Total flux emitted by the source region."""
    n = len(flow)
    return sum(thread_divergence(flow, x) for x in range(n) if in_region(source, x))


def is_valid_thread(flow: Matrix, w: Matrix, tol: float = 1e-9) -> bool:
    """Antisymmetric and capacity-respecting?"""
    n = len(w)
    for x in range(n):
        for y in range(n):
            if abs(flow[x][y] + flow[y][x]) > tol:
                return False
            if flow[x][y] > w[x][y] + tol:
                return False
    return True


def is_conserved(flow: Matrix, source: Region, sink: Region, tol: float = 1e-9) -> bool:
    """Divergence-free away from sources and sinks?"""
    n = len(flow)
    for v in range(n):
        if in_region(source, v) or in_region(sink, v):
            continue
        if abs(thread_divergence(flow, v)) > tol:
            return False
    return True


def max_flow(w: Matrix, s: int, t: int) -> Tuple[float, Matrix]:
    """Edmonds-Karp maximum flow on the undirected capacity graph; returns value and flow."""
    n = len(w)
    residual: Matrix = [row[:] for row in w]
    flow: Matrix = [[0.0] * n for _ in range(n)]
    total = 0.0
    while True:
        parent = [-1] * n
        parent[s] = s
        queue = [s]
        while queue and parent[t] == -1:
            x = queue.pop(0)
            for y in range(n):
                if parent[y] == -1 and residual[x][y] > 1e-12:
                    parent[y] = x
                    queue.append(y)
        if parent[t] == -1:
            break
        bottleneck = math.inf
        y = t
        while y != s:
            x = parent[y]
            bottleneck = min(bottleneck, residual[x][y])
            y = x
        y = t
        while y != s:
            x = parent[y]
            residual[x][y] -= bottleneck
            residual[y][x] += bottleneck
            flow[x][y] += bottleneck
            flow[y][x] -= bottleneck
            y = x
        total += bottleneck
    return total, flow


# ---------------------------------------------------------------------------
# Coarse-graining
# ---------------------------------------------------------------------------

def push_geometry(pi: Sequence[int], w: Matrix) -> Matrix:
    """Pushforward geometry: merge cells along pi, summing the areas between fibres."""
    m = max(pi) + 1
    out: Matrix = [[0.0] * m for _ in range(m)]
    for x in range(len(w)):
        for y in range(len(w)):
            if pi[x] != pi[y]:
                out[pi[x]][pi[y]] += w[x][y]
    return out


# ---------------------------------------------------------------------------
# Reporting helpers
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def check(label: str, ok: bool, detail: str = "") -> None:
    mark = "OK  " if ok else "FAIL"
    print(f"  [{mark}] {label}" + (f"   {detail}" if detail else ""))


# ---------------------------------------------------------------------------
# Demonstration 1: the elementary wormhole
# ---------------------------------------------------------------------------

def demo_elementary_wormhole() -> None:
    banner("1.  The elementary wormhole:  E = w,  I = 2w,  max-flow = min-cut")
    for wgt in (0.0, 0.5, 1.0, 2.5, 7.0):
        w = make_geometry(2, {(0, 1): wgt})
        boundary = region_of([0, 1])
        s0 = entropy(w, boundary, region_of([0]))
        info = mutual_information(w, boundary, region_of([0]), region_of([1]))
        thr = cap(w, 0, 1)
        val, flow = max_flow(w, 0, 1)
        print(f"  w = {wgt:5.2f} :  S({{0}}) = {s0:5.2f}   I(0:1) = {info:5.2f} "
              f"  E(0,1) = {thr:5.2f}   max-flow = {val:5.2f}   d(0,1) = {math.exp(-thr):6.4f}")
        check("throat equals the wall area", abs(thr - wgt) < 1e-9)
        check("mutual information is exactly twice the throat", abs(info - 2 * thr) < 1e-9)
        check("max-flow saturates min-cut", abs(val - thr) < 1e-9)
        check("flow is a legal thread configuration", is_valid_thread(flow, w))
        check("flow is conserved", is_conserved(flow, region_of([0]), region_of([1])))


# ---------------------------------------------------------------------------
# Demonstration 2: the ER = EPR sandwich on random geometries
# ---------------------------------------------------------------------------

def random_geometry(n: int, rng: random.Random, density: float = 0.6,
                    scale: float = 3.0) -> Matrix:
    """A random symmetric nonnegative area matrix with the given edge density."""
    w: Matrix = [[0.0] * n for _ in range(n)]
    for x in range(n):
        for y in range(x + 1, n):
            if rng.random() < density:
                val = round(rng.uniform(0.2, scale), 2)
                w[x][y] = val
                w[y][x] = val
    return w


def demo_sandwich() -> None:
    banner("2.  The ER = EPR sandwich:  I(A:B)/2  <=  E(A,B)  <=  min(S(A), S(B))")
    rng = random.Random(20260819)
    n = 6
    boundary = (1 << n) - 1  # no hidden bulk
    worst_gap_left = math.inf
    worst_gap_right = math.inf
    trials = 40
    for _ in range(trials):
        w = random_geometry(n, rng)
        for u, v in itertools.combinations(range(n), 2):
            a, b = 1 << u, 1 << v
            info = mutual_information(w, boundary, a, b)
            thr = throat(w, a, b)
            sa = entropy(w, boundary, a)
            sb = entropy(w, boundary, b)
            assert info / 2 <= thr + 1e-9, (info, thr)
            assert thr <= min(sa, sb) + 1e-9, (thr, sa, sb)
            worst_gap_left = min(worst_gap_left, thr - info / 2)
            worst_gap_right = min(worst_gap_right, min(sa, sb) - thr)
            # bridge detection
            assert (thr > 1e-9) == connected(w, u, v)
    print(f"  {trials} random 6-cell geometries, all {trials * 15} cell pairs tested.")
    check("I(A:B)/2 <= E(A,B) always", True,
          f"tightest slack {worst_gap_left:.3f}")
    check("E(A,B) <= min(S(A), S(B)) always", True,
          f"tightest slack {worst_gap_right:.3f}")
    check("E(u,v) > 0  <=>  a bulk path joins u and v", True)


# ---------------------------------------------------------------------------
# Demonstration 3: the emergent metric is an ultrametric and 0-hyperbolic
# ---------------------------------------------------------------------------

def demo_ultrametric() -> None:
    banner("3.  The emergent distance is an ultrametric and 0-hyperbolic")
    rng = random.Random(31415)
    n = 6
    trials = 30
    max_ultra_violation = 0.0
    max_fourpoint_violation = 0.0
    max_triangle_slack = 0.0
    for _ in range(trials):
        w = random_geometry(n, rng)
        d = [[bridge_distance(w, u, v) for v in range(n)] for u in range(n)]
        for u, v, z in itertools.product(range(n), repeat=3):
            max_ultra_violation = max(max_ultra_violation,
                                      d[u][z] - max(d[u][v], d[v][z]))
            max_triangle_slack = max(max_triangle_slack,
                                     d[u][z] - (d[u][v] + d[v][z]))
        for x, y, z, t in itertools.product(range(n), repeat=4):
            lhs = d[x][y] + d[z][t]
            rhs = max(d[x][z] + d[y][t], d[x][t] + d[y][z])
            max_fourpoint_violation = max(max_fourpoint_violation, lhs - rhs)
    print(f"  {trials} random 6-cell geometries; all triples and quadruples tested.")
    check("strong triangle inequality  d(u,w) <= max(d(u,v), d(v,w))",
          max_ultra_violation <= 1e-9,
          f"max violation {max_ultra_violation:.2e}")
    check("ordinary triangle inequality", max_triangle_slack <= 1e-9,
          f"max violation {max_triangle_slack:.2e}")
    check("Gromov four-point condition with delta = 0",
          max_fourpoint_violation <= 1e-9,
          f"max violation {max_fourpoint_violation:.2e}")

    # A concrete ultrametric distance table.
    w = make_geometry(5, {(0, 1): 4.0, (1, 2): 1.0, (2, 3): 3.0, (3, 4): 3.0, (2, 4): 0.5})
    print("\n  Capacity table cap(u,v) for a 5-cell chain with a thin waist:")
    for u in range(5):
        row = "  ".join(f"{cap(w, u, v):5.2f}" for v in range(5))
        print(f"    {u}: {row}")
    print("  Emergent distances d(u,v) = exp(-cap(u,v)):")
    for u in range(5):
        row = "  ".join(f"{bridge_distance(w, u, v):5.3f}" for v in range(5))
        print(f"    {u}: {row}")
    print("  Isosceles law: of any three capacities, the two smallest coincide.")
    worst = 0.0
    for u, v, z in itertools.combinations(range(5), 3):
        trio = sorted([cap(w, u, v), cap(w, v, z), cap(w, u, z)])
        worst = max(worst, abs(trio[0] - trio[1]))
    check("every capacity triangle is isosceles at the bottom", worst < 1e-9,
          f"max discrepancy {worst:.2e}")


# ---------------------------------------------------------------------------
# Demonstration 4: distance decays exponentially in entanglement
# ---------------------------------------------------------------------------

def demo_van_raamsdonk() -> None:
    banner("4.  Van Raamsdonk:  d(u,v) <= exp(-I(u:v)/2), and disentangling tears space")
    print("   A three-cell chain 0 - 1 - 2; we dial the entanglement of the 0-1 wall.")
    print("   wall w(0,1)   I(0:1)   E(0,1)     d(0,1)   exp(-I/2)   d(0,2)")
    for wgt in (0.0, 0.25, 0.5, 1.0, 2.0, 4.0):
        w = make_geometry(3, {(0, 1): wgt, (1, 2): 2.0})
        boundary = region_of([0, 1, 2])
        info = mutual_information(w, boundary, region_of([0]), region_of([1]))
        thr = cap(w, 0, 1)
        d01 = bridge_distance(w, 0, 1)
        d02 = bridge_distance(w, 0, 2)
        print(f"     {wgt:6.2f}    {info:6.2f}   {thr:6.2f}    {d01:7.4f}    "
              f"{math.exp(-info / 2):7.4f}    {d02:7.4f}")
        assert d01 <= math.exp(-info / 2) + 1e-9
        assert (d01 < 1.0 - 1e-12) == connected(w, 0, 1)
    check("d(u,v) <= exp(-I(u:v)/2) throughout", True)
    check("d(u,v) = 1 exactly when no bridge joins u and v", True)
    print("   With w(0,1) = 0 the cell 0 is severed: d(0,1) = d(0,2) = 1, the maximum.")


# ---------------------------------------------------------------------------
# Demonstration 5: monogamy -- a wormhole has exactly two mouths
# ---------------------------------------------------------------------------

def demo_monogamy() -> None:
    banner("5.  Monogamy:  maximal entanglement leaves a cell with exactly one neighbour")
    n = 4
    boundary = (1 << n) - 1  # no hidden bulk
    print("   Cell 0 is joined to 1 with area 3 and to 2 with area eps.")
    print("     eps     I(0:1)   2*S({0})   saturated?   I(0:2)")
    for eps in (1.0, 0.5, 0.1, 0.0):
        w = make_geometry(n, {(0, 1): 3.0, (0, 2): eps, (2, 3): 1.0})
        i01 = mutual_information(w, boundary, region_of([0]), region_of([1]))
        s0 = entropy(w, boundary, region_of([0]))
        i02 = mutual_information(w, boundary, region_of([0]), region_of([2]))
        sat = abs(i01 - 2 * s0) < 1e-9
        print(f"    {eps:5.2f}    {i01:6.2f}   {2 * s0:8.2f}   {str(sat):>10}   {i02:6.2f}")
        if sat:
            for z in (2, 3):
                assert abs(w[0][z]) < 1e-9
                assert abs(mutual_information(w, boundary, region_of([0]),
                                              region_of([z]))) < 1e-9
    check("saturation I(0:1) = 2 S({0}) forces every other wall at 0 to vanish", True)
    check("and forces I(0:z) = 0 for every other cell z", True)


# ---------------------------------------------------------------------------
# Demonstration 6: bit threads and weak duality
# ---------------------------------------------------------------------------

def demo_bit_threads() -> None:
    banner("6.  Bit threads:  every conserved flow is bounded by every separating surface")
    rng = random.Random(2718)
    n = 6
    violations = 0
    saturations = 0
    trials = 25
    for _ in range(trials):
        w = random_geometry(n, rng)
        for u, v in itertools.combinations(range(n), 2):
            thr = cap(w, u, v)
            val, flow = max_flow(w, u, v)
            assert is_valid_thread(flow, w)
            assert is_conserved(flow, 1 << u, 1 << v)
            if val > thr + 1e-9:
                violations += 1
            if abs(val - thr) < 1e-9:
                saturations += 1
    total = trials * 15
    print(f"  {total} source-sink pairs on random 6-cell geometries.")
    check("weak duality: no conserved flow exceeds the throat capacity",
          violations == 0, f"{violations} violations")
    print(f"  Empirically the bound is attained in {saturations}/{total} cases "
          f"({100.0 * saturations / total:.1f}%), consistent with the conjectured")
    print("  strong duality (max-flow = min-cut in general), which is proved here only")
    print("  for the elementary one-throat wormhole.")

    print("\n  A concrete thread configuration on the path 0 - 1 - 2 with areas 4 and 2:")
    w = make_geometry(3, {(0, 1): 4.0, (1, 2): 2.0})
    val, flow = max_flow(w, 0, 2)
    for x in range(3):
        print("    flow[{}] = [{}]".format(
            x, ", ".join(f"{flow[x][y]:5.2f}" for y in range(3))))
    print(f"    value = {val:.2f},  throat capacity E(0,2) = {cap(w, 0, 2):.2f}")
    print("    Only the narrow wall of area 2 is saturated: it is the min cut.")


# ---------------------------------------------------------------------------
# Demonstration 7: renormalisation -- coarse-graining strictly contracts space
# ---------------------------------------------------------------------------

def demo_renormalisation() -> None:
    banner("7.  Renormalisation:  merging cells widens throats and contracts distances")
    w = make_geometry(4, {(0, 1): 5.0, (1, 2): 1.0, (2, 3): 5.0})
    pi = [0, 1, 1, 2]  # merge the two waist cells 1 and 2
    wc = push_geometry(pi, w)
    fine_cap = cap(w, 0, 3)
    coarse_cap = cap(wc, pi[0], pi[3])
    print("   Fine geometry: path 0 - 1 - 2 - 3 with areas 5, 1, 5.")
    print(f"     cap(0,3) = {fine_cap:.2f}   (the thin waist is the cheap surface)")
    print("   Coarse geometry after merging cells 1 and 2:")
    for a in range(3):
        print("     " + "  ".join(f"{wc[a][b]:5.2f}" for b in range(3)))
    print(f"     cap(pi0, pi3) = {coarse_cap:.2f}   (the waist is now invisible)")
    print(f"     d fine   = {bridge_distance(w, 0, 3):.6f}")
    print(f"     d coarse = {bridge_distance(wc, pi[0], pi[3]):.6f}")
    check("coarse-graining widens the throat", coarse_cap > fine_cap + 1e-9)
    check("coarse-graining contracts the emergent distance strictly",
          bridge_distance(wc, pi[0], pi[3]) < bridge_distance(w, 0, 3) - 1e-9)

    # The pullback identity, and 1-Lipschitzness on every pair.
    ok_pullback = True
    for sigma in all_regions(3):
        pulled = region_of([x for x in range(4) if in_region(sigma, pi[x])])
        if abs(area(wc, sigma) - area(w, pulled)) > 1e-9:
            ok_pullback = False
    check("every coarse surface pulls back to a fine surface of equal area", ok_pullback)
    ok_lip = all(bridge_distance(wc, pi[u], pi[v]) <= bridge_distance(w, u, v) + 1e-9
                 for u in range(4) for v in range(4))
    check("the merging map is 1-Lipschitz on the emergent metric", ok_lip)

    # Functoriality: merge again and compare with the composite.
    rho = [0, 0, 1]
    composite = [rho[pi[x]] for x in range(4)]
    left = push_geometry(rho, wc)
    right = push_geometry(composite, w)
    check("coarse-graining is functorial",
          all(abs(left[a][b] - right[a][b]) < 1e-9 for a in range(2) for b in range(2)))


# ---------------------------------------------------------------------------
# Demonstration 8: n Bell pairs -- a shattered spacetime
# ---------------------------------------------------------------------------

def demo_bell_pairs() -> None:
    banner("8.  The emergent space of n Bell pairs is exactly n wormholes")
    weights = [2.0, 1.0, 0.5]
    n_pairs = len(weights)
    n = 2 * n_pairs
    edges: Dict[Tuple[int, int], float] = {}
    for i, wi in enumerate(weights):
        edges[(2 * i, 2 * i + 1)] = wi
    w = make_geometry(n, edges)
    boundary = (1 << n) - 1
    print("   Pair weights:", weights)
    print("   pair   I/2      E     min(S,S)    d inside    d across")
    for i, wi in enumerate(weights):
        u, v = 2 * i, 2 * i + 1
        info = mutual_information(w, boundary, 1 << u, 1 << v)
        thr = cap(w, u, v)
        su = entropy(w, boundary, 1 << u)
        sv = entropy(w, boundary, 1 << v)
        other = (u + 2) % n
        print(f"    {i}   {info / 2:6.2f}  {thr:6.2f}   {min(su, sv):8.2f}"
              f"    {bridge_distance(w, u, v):8.4f}  {bridge_distance(w, u, other):9.4f}")
        assert abs(info / 2 - thr) < 1e-9 and abs(thr - min(su, sv)) < 1e-9
    check("the sandwich collapses: I/2 = E = min(S,S) = w_i for every pair", True)

    r_low = max(math.exp(-wi) for wi in weights)
    r = 0.5 * (r_low + 1.0)
    print(f"\n   Clustering at scale r = {r:.4f}  (window [{r_low:.4f}, 1) )")
    clusters: List[List[int]] = []
    for x in range(n):
        placed = False
        for c in clusters:
            if bridge_distance(w, x, c[0]) <= r:
                c.append(x)
                placed = True
                break
        if not placed:
            clusters.append([x])
    print("   clusters:", clusters)
    expected = [[2 * i, 2 * i + 1] for i in range(n_pairs)]
    check("the clusters of the emergent ultrametric are exactly the Bell pairs",
          clusters == expected)
    print("   Below the window the space shatters into points; above it, everything merges.")


# ---------------------------------------------------------------------------
# Demonstration 9: reconstruction from the entanglement table
# ---------------------------------------------------------------------------

def demo_reconstruction() -> None:
    banner("9.  Reconstruction:  the entanglement table determines the whole geometry")
    n = 5
    boundary = (1 << n) - 1  # no hidden bulk
    w = make_geometry(n, {(0, 1): 2.0, (1, 2): 1.5, (2, 3): 0.75, (3, 4): 2.25, (0, 4): 0.5})
    table = [[0.0 if u == v else mutual_information(w, boundary, 1 << u, 1 << v)
              for v in range(n)] for u in range(n)]
    print("   Two-point mutual informations I(u:v):")
    for u in range(n):
        print("     " + "  ".join(f"{table[u][v]:5.2f}" for v in range(n)))
    # Rebuild the geometry from the table alone, using I(u:v) = 2 w(u,v).
    rebuilt = make_geometry(n, {(u, v): table[u][v] / 2.0
                                for u in range(n) for v in range(u + 1, n)})
    same_weights = all(abs(w[u][v] - rebuilt[u][v]) < 1e-9
                       for u in range(n) for v in range(n))
    same_metric = all(abs(bridge_distance(w, u, v) - bridge_distance(rebuilt, u, v)) < 1e-9
                      for u in range(n) for v in range(n))
    check("the areas are recovered as w(u,v) = I(u:v)/2", same_weights)
    check("hence the emergent metric spaces are isometric", same_metric)
    print("   Emergent distance matrix reconstructed from entanglement alone:")
    for u in range(n):
        print("     " + "  ".join(f"{bridge_distance(rebuilt, u, v):6.4f}" for v in range(n)))


# ---------------------------------------------------------------------------

def main() -> None:
    print(__doc__.strip().split("Run with:")[0].strip())
    demo_elementary_wormhole()
    demo_sandwich()
    demo_ultrametric()
    demo_van_raamsdonk()
    demo_monogamy()
    demo_bit_threads()
    demo_renormalisation()
    demo_bell_pairs()
    demo_reconstruction()
    banner("All demonstrations completed.")


if __name__ == "__main__":
    main()
