"""
Certified Adversarial Robustness as a Cohomological Invariant of a Cover
=========================================================================

Self-contained numerical demonstration of the results:

  1. Overlap compatibility: certification forces signs to agree on overlaps.
  2. Gluing theorem: on a connected nerve, local L-infinity certificates
     assemble into one global certificate over the union of the balls.
  3. Holonomy obstruction: a sign flip along a walk yields, by the
     intermediate value theorem, an explicit decision-boundary point within
     the overlap scale of a named anchor -- capping the certified radius.
  4. Betti number law: dim H^1 = |E| - |V| + k for a nerve with k components;
     zero exactly for forests.
  5. Loop cohomology and the defect theorem: minimal uniform certificate
     mismatch on a cycle of n+1 regions equals |sum g| / (n+1), attained.
  6. Discrete torus: two independent holonomies, dim H^1 = 2.
  7. Z/2 parity obstruction and nonabelian (permutation) monodromy.
  8. Certified radius transfer: r_j >= r_i0 - D * eps.

Run:  python demo.py          (no third-party dependencies)
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

Vector = Tuple[float, ...]
Score = Callable[[Vector], float]
Edge = Tuple[int, int]


# ---------------------------------------------------------------------------
# Basic geometry
# ---------------------------------------------------------------------------

def linf_norm(v: Vector) -> float:
    """Sup norm of a vector."""
    return max(abs(c) for c in v) if v else 0.0


def linf_dist(a: Vector, b: Vector) -> float:
    """L-infinity distance between two points."""
    return linf_norm(tuple(x - y for x, y in zip(a, b)))


def lerp(u: Vector, v: Vector, t: float) -> Vector:
    """Point u + t (v - u) on the segment joining u to v."""
    return tuple(a + t * (b - a) for a, b in zip(u, v))


# ---------------------------------------------------------------------------
# 1. Local sections of the decision sheaf: sign certificates
# ---------------------------------------------------------------------------

def sign_certified(
    score: Score,
    anchor: Vector,
    radius: float,
    sigma: int,
    samples: int = 4000,
    seed: int = 0,
) -> bool:
    """Empirical test of SC(s, x, rho, sigma): sigma * s(y) > 0 for all y in the
    closed sup-norm ball of radius `radius` around `anchor`.

    This is a Monte-Carlo *falsifier*: it returns False as soon as a violating
    sample is found, and True if no violation is seen.  It stands in for a real
    certifier (interval propagation, randomised smoothing, ...) in this demo.
    """
    rng = _Lcg(seed)
    if sigma * score(anchor) <= 0:
        return False
    d = len(anchor)
    for _ in range(samples):
        y = tuple(anchor[k] + radius * (2.0 * rng.next() - 1.0) for k in range(d))
        if sigma * score(y) <= 0:
            return False
    return True


class _Lcg:
    """Tiny deterministic linear congruential generator (keeps demo dependency-free)."""

    def __init__(self, seed: int = 0) -> None:
        self.state = (seed * 6364136223846793005 + 1442695040888963407) % (2 ** 64)

    def next(self) -> float:
        self.state = (self.state * 6364136223846793005 + 1442695040888963407) % (2 ** 64)
        return (self.state >> 11) / float(1 << 53)


# ---------------------------------------------------------------------------
# 2. The nerve of a cover
# ---------------------------------------------------------------------------

def build_nerve(anchors: Sequence[Vector], delta: float, tol: float = 1e-9) -> List[Edge]:
    """Edges {i,j} of the nerve: anchors within L-infinity distance `delta`
    (up to a floating-point tolerance)."""
    return [
        (i, j)
        for i in range(len(anchors))
        for j in range(i + 1, len(anchors))
        if linf_dist(anchors[i], anchors[j]) <= delta + tol
    ]


def adjacency(n_vertices: int, edges: Iterable[Edge]) -> Dict[int, List[int]]:
    adj: Dict[int, List[int]] = {i: [] for i in range(n_vertices)}
    for (i, j) in edges:
        adj[i].append(j)
        adj[j].append(i)
    return adj


def connected_components(n_vertices: int, edges: Sequence[Edge]) -> List[List[int]]:
    """Union-find components of the nerve graph."""
    parent = list(range(n_vertices))

    def find(a: int) -> int:
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    for (i, j) in edges:
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[ri] = rj

    buckets: Dict[int, List[int]] = {}
    for v in range(n_vertices):
        buckets.setdefault(find(v), []).append(v)
    return list(buckets.values())


def first_betti_number(n_vertices: int, edges: Sequence[Edge]) -> int:
    """dim H^1 = |E| - |V| + k  (Betti Number Law)."""
    k = len(connected_components(n_vertices, edges))
    return len(edges) - n_vertices + k


def is_forest(n_vertices: int, edges: Sequence[Edge]) -> bool:
    return first_betti_number(n_vertices, edges) == 0


def walk_between(n_vertices: int, edges: Sequence[Edge], src: int, dst: int
                 ) -> Optional[List[int]]:
    """A vertex path src -> ... -> dst in the nerve, or None if unreachable."""
    adj = adjacency(n_vertices, edges)
    prev: Dict[int, int] = {src: src}
    frontier = [src]
    while frontier:
        nxt: List[int] = []
        for u in frontier:
            for w in adj[u]:
                if w not in prev:
                    prev[w] = u
                    nxt.append(w)
        frontier = nxt
    if dst not in prev:
        return None
    path = [dst]
    while path[-1] != src:
        path.append(prev[path[-1]])
    return list(reversed(path))


def nerve_eccentricity(n_vertices: int, edges: Sequence[Edge], base: int) -> int:
    """Maximal graph distance from `base` (the D of the radius-transfer theorem)."""
    adj = adjacency(n_vertices, edges)
    dist = {base: 0}
    frontier = [base]
    while frontier:
        nxt = []
        for u in frontier:
            for w in adj[u]:
                if w not in dist:
                    dist[w] = dist[u] + 1
                    nxt.append(w)
        frontier = nxt
    return max(dist.values())


# ---------------------------------------------------------------------------
# 3. Holonomy of a real 1-cochain, fundamental cycles
# ---------------------------------------------------------------------------

def holonomy_along(cochain: Dict[Edge, float], path: Sequence[int]) -> float:
    """Sum of the antisymmetric discrepancy c along a vertex path."""
    total = 0.0
    for u, v in zip(path, path[1:]):
        if (u, v) in cochain:
            total += cochain[(u, v)]
        elif (v, u) in cochain:
            total -= cochain[(v, u)]
        else:
            raise KeyError(f"edge {(u, v)} not in the nerve")
    return total


def spanning_forest(n_vertices: int, edges: Sequence[Edge]) -> Tuple[List[Edge], List[Edge]]:
    """Split the edges into (tree edges, non-tree edges)."""
    parent = list(range(n_vertices))

    def find(a: int) -> int:
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    tree: List[Edge] = []
    extra: List[Edge] = []
    for e in edges:
        ri, rj = find(e[0]), find(e[1])
        if ri == rj:
            extra.append(e)
        else:
            parent[ri] = rj
            tree.append(e)
    return tree, extra


def fundamental_cycles(n_vertices: int, edges: Sequence[Edge]) -> List[List[int]]:
    """One closed walk per independent cycle: a basis of the cycle space.
    Their number equals the first Betti number."""
    tree, extra = spanning_forest(n_vertices, edges)
    cycles: List[List[int]] = []
    for (u, v) in extra:
        path = walk_between(n_vertices, tree, v, u)
        if path is not None:
            cycles.append([u] + path)  # u -> v -> ... -> u
    return cycles


def is_coboundary(n_vertices: int, edges: Sequence[Edge],
                  cochain: Dict[Edge, float], tol: float = 1e-9) -> bool:
    """Discrete Poincare lemma: c glues iff all fundamental cycles have zero
    holonomy (which implies zero holonomy on *every* closed walk)."""
    return all(abs(holonomy_along(cochain, cyc)) <= tol
               for cyc in fundamental_cycles(n_vertices, edges))


def potential_from_cochain(n_vertices: int, edges: Sequence[Edge],
                           cochain: Dict[Edge, float], base: int = 0
                           ) -> Dict[int, float]:
    """Global potential f with c_ij = f_j - f_i, built by integrating along a
    spanning tree from `base` (valid when the holonomy vanishes)."""
    tree, _ = spanning_forest(n_vertices, edges)
    adj = adjacency(n_vertices, tree)
    f: Dict[int, float] = {base: 0.0}
    frontier = [base]
    while frontier:
        nxt = []
        for u in frontier:
            for w in adj[u]:
                if w not in f:
                    f[w] = f[u] + holonomy_along(cochain, [u, w])
                    nxt.append(w)
        frontier = nxt
    return f


# ---------------------------------------------------------------------------
# 4. Adversarial witness: locate the flip, then bisect
# ---------------------------------------------------------------------------

def find_sign_flip_edge(score: Score, anchors: Sequence[Vector],
                        path: Sequence[int]) -> Optional[Edge]:
    """Along a walk with s(start) > 0 and s(end) <= 0, return the single overlap
    across which positivity is lost."""
    for u, v in zip(path, path[1:]):
        if score(anchors[u]) > 0 >= score(anchors[v]):
            return (u, v)
    return None


def boundary_point_by_bisection(score: Score, u: Vector, v: Vector,
                                iters: int = 60) -> Vector:
    """Intermediate value witness: a point z on [u,v] with s(z) ~ 0, given
    s(u) > 0 >= s(v).  Distance to u is at most ||v - u||."""
    lo, hi = 0.0, 1.0  # s(lerp(lo)) > 0 >= s(lerp(hi))
    for _ in range(iters):
        mid = 0.5 * (lo + hi)
        if score(lerp(u, v, mid)) > 0:
            lo = mid
        else:
            hi = mid
    return lerp(u, v, hi)


# ---------------------------------------------------------------------------
# 5. Loop nerve: cohomology and the defect theorem
# ---------------------------------------------------------------------------

def loop_holonomy(g: Sequence[float]) -> float:
    return sum(g)


def loop_is_coboundary(g: Sequence[float], tol: float = 1e-9) -> bool:
    return abs(loop_holonomy(g)) <= tol


def loop_minimal_defect(g: Sequence[float]) -> float:
    """Defect theorem: min over potentials f of max_i |(f_{i+1}-f_i) - g_i|
    equals |sum g| / (n+1)."""
    return abs(sum(g)) / len(g)


def harmonic_representative(g: Sequence[float]) -> List[float]:
    """g minus its mean: the unique constant-defect (harmonic) representative."""
    h = sum(g) / len(g)
    return [gi - h for gi in g]


def loop_potential(g: Sequence[float]) -> List[float]:
    """Discrete primitive f_k = sum_{j<k} g_j (a genuine potential iff sum g = 0)."""
    f = [0.0]
    for gi in g[:-1]:
        f.append(f[-1] + gi)
    return f


def loop_defect_numeric(g: Sequence[float], iters: int = 40000) -> float:
    """Independent numerical check of the defect theorem: minimise the convex,
    piecewise-linear objective  F(f) = max_i |(f_{i+1} - f_i) - g_i|  over all
    potentials f (with f_0 pinned to 0), by smoothed gradient descent with an
    annealed log-sum-exp temperature.  Converges to |sum g| / (n+1)."""
    n = len(g)
    f = [0.0] * n

    def defect(fv: Sequence[float]) -> float:
        return max(abs((fv[(i + 1) % n] - fv[i]) - g[i]) for i in range(n))

    best = defect(f)
    for t in range(iters):
        beta = 5.0 + 300.0 * t / iters
        step = 0.2 / (1.0 + 0.01 * t)
        d = [(f[(i + 1) % n] - f[i]) - g[i] for i in range(n)]
        peak = max(abs(x) for x in d)
        weights = [math.exp(beta * (abs(x) - peak)) for x in d]
        total = sum(weights)
        grad = [0.0] * n
        for i in range(n):
            coeff = (weights[i] / total) * (1.0 if d[i] >= 0 else -1.0)
            grad[(i + 1) % n] += coeff
            grad[i] -= coeff
        f = [f[k] - step * grad[k] if k > 0 else 0.0 for k in range(n)]
        best = min(best, defect(f))
    return best


# ---------------------------------------------------------------------------
# 6. Discrete torus nerve
# ---------------------------------------------------------------------------

def torus_is_flat(h: List[List[float]], v: List[List[float]], tol: float = 1e-9) -> bool:
    """Plaquette condition h[a][b] + v[a+1][b] = v[a][b] + h[a][b+1]."""
    m, n = len(h), len(h[0])
    return all(
        abs(h[a][b] + v[(a + 1) % m][b] - v[a][b] - h[a][(b + 1) % n]) <= tol
        for a in range(m) for b in range(n)
    )


def torus_row_holonomy(h: List[List[float]], b: int) -> float:
    return sum(h[a][b] for a in range(len(h)))


def torus_col_holonomy(v: List[List[float]], a: int) -> float:
    return sum(v[a][b] for b in range(len(v[0])))


def torus_potential(h: List[List[float]], v: List[List[float]]) -> List[List[float]]:
    """f(a,b) = sum_{a'<a} h(a',0) + sum_{b'<b} v(a,b'); a genuine potential iff
    the cochain is flat and both holonomies vanish."""
    m, n = len(h), len(h[0])
    f = [[0.0] * n for _ in range(m)]
    for a in range(m):
        base = sum(h[ap][0] for ap in range(a))
        for b in range(n):
            f[a][b] = base + sum(v[a][bp] for bp in range(b))
    return f


# ---------------------------------------------------------------------------
# 7. Z/2 parity and nonabelian permutation monodromy
# ---------------------------------------------------------------------------

def parity_obstruction(flips: Sequence[int]) -> bool:
    """True iff the loop of label flips admits NO globally consistent labelling."""
    return sum(flips) % 2 == 1


Perm = Tuple[int, ...]


def perm_compose(p: Perm, q: Perm) -> Perm:
    """(p then q): apply p first."""
    return tuple(q[p[i]] for i in range(len(p)))


def perm_inverse(p: Perm) -> Perm:
    inv = [0] * len(p)
    for i, pi in enumerate(p):
        inv[pi] = i
    return tuple(inv)


def perm_monodromy(transitions: Dict[Edge, Perm], cycle: Sequence[int], k: int) -> Perm:
    """Ordered product of relabellings around a closed walk."""
    out: Perm = tuple(range(k))
    for u, v in zip(cycle, cycle[1:]):
        if (u, v) in transitions:
            step = transitions[(u, v)]
        elif (v, u) in transitions:
            step = perm_inverse(transitions[(v, u)])
        else:
            raise KeyError(f"no transition on {(u, v)}")
        out = perm_compose(out, step)
    return out


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_gluing() -> None:
    banner("1. GLUING THEOREM: local L-infinity certificates -> one global certificate")

    # A score whose positive region comfortably contains all anchors.
    def score(y: Vector) -> float:
        return 3.0 - (y[0] ** 2 + y[1] ** 2)          # positive inside radius sqrt(3)

    anchors: List[Vector] = [(0.0, 0.0), (0.4, 0.0), (0.8, 0.0), (0.8, 0.4), (0.4, 0.4)]
    rho = 0.4
    edges = build_nerve(anchors, rho)
    comps = connected_components(len(anchors), edges)

    signs = [1 if score(a) > 0 else -1 for a in anchors]
    certified = [sign_certified(score, a, rho, s, seed=i)
                 for i, (a, s) in enumerate(zip(anchors, signs))]

    print(f"anchors        : {anchors}")
    print(f"radius rho     : {rho}")
    print(f"nerve edges    : {edges}")
    print(f"connected      : {len(comps) == 1}")
    print(f"local signs    : {signs}")
    print(f"all certified  : {all(certified)}")
    print(f"signs constant : {len(set(signs)) == 1}   (Overlap Compatibility)")

    # Global certificate check on the union of the balls.
    rng = _Lcg(7)
    tau = signs[0]
    violations = 0
    for i, a in enumerate(anchors):
        for _ in range(3000):
            y = tuple(a[k] + rho * (2 * rng.next() - 1) for k in range(2))
            if tau * score(y) <= 0:
                violations += 1
    print(f"global certificate holds on the union of all balls: {violations == 0}")
    print("  => every point within L-inf distance 0.4 of ANY anchor gets verdict "
          f"{'+' if tau > 0 else '-'}")


def demo_holonomy_obstruction() -> None:
    banner("2. HOLONOMY OBSTRUCTION: sign flip -> explicit boundary point within delta")

    def score(y: Vector) -> float:
        return 0.7 - y[0]              # boundary is the hyperplane x = 0.7

    anchors: List[Vector] = [(0.0, 0.0), (0.3, 0.0), (0.6, 0.0), (0.9, 0.0), (1.2, 0.0)]
    delta = 0.3
    edges = build_nerve(anchors, delta)
    path = walk_between(len(anchors), edges, 0, 4)
    assert path is not None

    print(f"score          : s(y) = 0.7 - y0    (boundary at y0 = 0.7)")
    print(f"anchors        : {anchors}")
    print(f"overlap scale  : {delta}")
    print(f"walk           : {path}")
    print(f"s at anchors   : {[round(score(a), 3) for a in anchors]}")

    flip = find_sign_flip_edge(score, anchors, path)
    print(f"flip edge      : {flip}   (Lemma: locating the flip)")
    assert flip is not None
    u, v = anchors[flip[0]], anchors[flip[1]]
    z = boundary_point_by_bisection(score, u, v)
    print(f"boundary point : z = {tuple(round(c, 6) for c in z)},  s(z) = {score(z):.2e}")
    print(f"||z - x_u||_inf = {linf_dist(z, u):.6f} <= delta = {delta}   "
          f"({linf_dist(z, u) <= delta + 1e-9})")
    print("  => NO sign certifies anchor "
          f"{flip[0]} at radius {delta}: the uniform certified radius is capped.")

    # Confirm directly that the certifier refutes the anchor at radius delta.
    for tau in (+1, -1):
        ok = sign_certified(score, u, delta, tau, seed=3)
        print(f"     SignCertified(anchor {flip[0]}, delta, sigma={tau:+d}) = {ok}")


def demo_betti() -> None:
    banner("3. BETTI NUMBER LAW: dim H^1 = |E| - |V| + k")

    examples: List[Tuple[str, int, List[Edge]]] = [
        ("path  P4",      4, [(0, 1), (1, 2), (2, 3)]),
        ("cycle C4",      4, [(0, 1), (1, 2), (2, 3), (0, 3)]),
        ("theta graph",   4, [(0, 1), (1, 2), (2, 3), (0, 3), (0, 2)]),
        ("K4",            4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]),
        ("two triangles", 6, [(0, 1), (1, 2), (0, 2), (3, 4), (4, 5), (3, 5)]),
    ]
    print(f"{'graph':<15}{'|V|':>5}{'|E|':>5}{'k':>4}{'dim H^1':>9}{'#cycles':>9}  tree?")
    for name, nv, es in examples:
        k = len(connected_components(nv, es))
        b1 = first_betti_number(nv, es)
        cycles = fundamental_cycles(nv, es)
        print(f"{name:<15}{nv:>5}{len(es):>5}{k:>4}{b1:>9}{len(cycles):>9}  "
              f"{is_forest(nv, es)}")
    print("\n  dim H^1 = 0 exactly for forests: local data ALWAYS glues on a tree cover.")


def demo_poincare_lemma() -> None:
    banner("4. DISCRETE POINCARE LEMMA: coboundary  <=>  zero holonomy on every cycle")

    nv = 4
    edges: List[Edge] = [(0, 1), (1, 2), (2, 3), (0, 3)]     # a 4-cycle

    glueable: Dict[Edge, float] = {(0, 1): 1.0, (1, 2): 2.0, (2, 3): -0.5, (0, 3): 2.5}
    # holonomy 0 -> 1 -> 2 -> 3 -> 0 = 1 + 2 - 0.5 - 2.5 = 0
    obstructed: Dict[Edge, float] = dict(glueable)
    obstructed[(0, 3)] = 1.9                                  # holonomy now +0.6

    for name, c in (("glueable", glueable), ("obstructed", obstructed)):
        cycles = fundamental_cycles(nv, edges)
        hols = [holonomy_along(c, cyc) for cyc in cycles]
        cob = is_coboundary(nv, edges, c)
        print(f"\ncochain '{name}': {c}")
        print(f"  fundamental cycles : {cycles}")
        print(f"  holonomies         : {[round(h, 6) for h in hols]}")
        print(f"  is a coboundary    : {cob}")
        if cob:
            f = potential_from_cochain(nv, edges, c)
            residual = max(abs(holonomy_along(c, [i, j]) - (f[j] - f[i]))
                           for (i, j) in edges)
            print(f"  reconstructed potential f = "
                  f"{{{', '.join(f'{k}: {v:+.2f}' for k, v in sorted(f.items()))}}}")
            print(f"  max |c_ij - (f_j - f_i)| over edges = {residual:.2e}")
        else:
            print("  => no global certificate exists (cohomological obstruction).")


def demo_defect_theorem() -> None:
    banner("5. DEFECT THEOREM: minimal uniform mismatch on a loop = |H| / (n+1)")

    tests: List[List[float]] = [
        [1.0, -1.0, 0.5, -0.5],           # holonomy 0
        [1.0, 1.0, 1.0, 1.0],             # holonomy 4
        [0.3, -1.2, 2.0, 0.4, -0.1],      # holonomy 1.4
    ]
    print(f"{'g':<32}{'n+1':>5}{'holonomy':>11}{'|H|/(n+1)':>12}{'numeric min':>14}")
    for g in tests:
        H = loop_holonomy(g)
        predicted = loop_minimal_defect(g)
        numeric = loop_defect_numeric(g)
        print(f"{str(g):<32}{len(g):>5}{H:>11.4f}{predicted:>12.6f}{numeric:>14.6f}")

    g = [0.3, -1.2, 2.0, 0.4, -0.1]
    hrep = harmonic_representative(g)
    f = loop_potential(hrep)
    n = len(g)
    mismatches = [abs((f[(i + 1) % n] - f[i]) - g[i]) for i in range(n)]
    print(f"\nharmonic representative of g = {[round(x, 4) for x in hrep]}"
          f"   (sum = {sum(hrep):.1e})")
    print(f"per-overlap mismatch of the optimal potential = "
          f"{[round(m, 6) for m in mismatches]}")
    print("  => the mismatch is the SAME constant at every overlap: the extremal "
          "cochain is constant.")


def demo_torus() -> None:
    banner("6. DISCRETE TORUS NERVE: two independent holonomies, dim H^1 = 2")

    m, n = 3, 4
    r_target, c_target = 1.5, -2.0
    h = [[r_target / m for _ in range(n)] for _ in range(m)]
    v = [[c_target / n for _ in range(n)] for _ in range(m)]

    print(f"grid {m} x {n} with wrap-around in both directions")
    print(f"flat (plaquette condition holds) : {torus_is_flat(h, v)}")
    print(f"row holonomies (per row)         : "
          f"{[round(torus_row_holonomy(h, b), 6) for b in range(n)]}")
    print(f"col holonomies (per column)      : "
          f"{[round(torus_col_holonomy(v, a), 6) for a in range(m)]}")
    print("  => both are independent of the row / column, as the theory predicts.")
    print(f"prescribed pair (r, c) = ({r_target}, {c_target}) is realised: "
          f"{math.isclose(torus_row_holonomy(h, 0), r_target)} / "
          f"{math.isclose(torus_col_holonomy(v, 0), c_target)}")

    # A coboundary: both holonomies vanish and the potential reproduces (h, v).
    f0 = [[math.sin(a) + 0.5 * math.cos(b) for b in range(n)] for a in range(m)]
    hc = [[f0[(a + 1) % m][b] - f0[a][b] for b in range(n)] for a in range(m)]
    vc = [[f0[a][(b + 1) % n] - f0[a][b] for b in range(n)] for a in range(m)]
    print(f"\ncoboundary test: flat = {torus_is_flat(hc, vc)}, "
          f"row hol = {torus_row_holonomy(hc, 0):.2e}, "
          f"col hol = {torus_col_holonomy(vc, 0):.2e}")
    g = torus_potential(hc, vc)
    err_h = max(abs(g[(a + 1) % m][b] - g[a][b] - hc[a][b])
                for a in range(m) for b in range(n))
    err_v = max(abs(g[a][(b + 1) % n] - g[a][b] - vc[a][b])
                for a in range(m) for b in range(n))
    print(f"reconstructed potential reproduces the cochain: "
          f"max errors {err_h:.2e} (horizontal), {err_v:.2e} (vertical)")


def demo_parity_and_monodromy() -> None:
    banner("7. Z/2 PARITY AND NONABELIAN MONODROMY")

    for flips in ([0, 0, 0, 0], [1, 0, 0, 0], [1, 1, 0, 0], [1, 1, 1, 0]):
        print(f"flip pattern {flips}: sum = {sum(flips) % 2} in Z/2, "
              f"global labelling impossible = {parity_obstruction(flips)}")

    print("\nThree-class classifier on three mutually overlapping regions.")
    k = 3
    swap01: Perm = (1, 0, 2)
    transitions: Dict[Edge, Perm] = {(0, 1): swap01, (1, 2): swap01, (0, 2): swap01}
    mono = perm_monodromy(transitions, [0, 1, 2, 0], k)
    identity: Perm = tuple(range(k))
    print(f"transition on each 'upward' overlap : swap(0,1) = {swap01}")
    print(f"monodromy around 0 -> 1 -> 2 -> 0   : {mono}")
    print(f"nontrivial                          : {mono != identity}")
    print("  => every PAIRWISE overlap is consistent, yet no global labelling exists.")

    # Exhaustive confirmation: no global relabelling f exists.
    perms: List[Perm] = list(itertools.permutations(range(k)))
    found = None
    for f0 in perms:
        for f1 in perms:
            for f2 in perms:
                f = (f0, f1, f2)
                ok = all(
                    perm_compose(perm_inverse(f[u]), f[v]) == transitions[(u, v)]
                    for (u, v) in transitions
                )
                if ok:
                    found = f
    print(f"exhaustive search over all {len(perms) ** 3} labellings found a global "
          f"section: {found is not None}")


def demo_radius_transfer() -> None:
    banner("8. CERTIFIED RADIUS TRANSFER: r_j >= r_i0 - D * eps")

    nv = 6
    edges: List[Edge] = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)]   # a path
    radii = {0: 1.00, 1: 0.93, 2: 0.88, 3: 0.80, 4: 0.75, 5: 0.71}
    cochain = {(i, j): radii[j] - radii[i] for (i, j) in edges}
    eps = max(abs(x) for x in cochain.values())
    base = 0
    D = nerve_eccentricity(nv, edges, base)
    bound = radii[base] - D * eps

    print(f"local certified radii : {radii}")
    print(f"overlap discrepancies : "
          f"{{{', '.join(f'{k}: {v:+.3f}' for k, v in cochain.items())}}}")
    print(f"eps = max |c|         : {eps:.4f}")
    print(f"nerve eccentricity D  : {D}")
    print(f"guaranteed lower bound r_base - D*eps = {bound:.4f}")
    print(f"actual minimum radius                 = {min(radii.values()):.4f}")
    print(f"bound valid for every region          : "
          f"{all(r >= bound - 1e-12 for r in radii.values())}")


def main() -> None:
    print(__doc__)
    demo_gluing()
    demo_holonomy_obstruction()
    demo_betti()
    demo_poincare_lemma()
    demo_defect_theorem()
    demo_torus()
    demo_parity_and_monodromy()
    demo_radius_transfer()
    banner("ALL DEMONSTRATIONS COMPLETE")


if __name__ == "__main__":
    main()
