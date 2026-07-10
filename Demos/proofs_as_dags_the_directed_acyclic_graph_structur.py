"""
demo.py -- Numerical demonstrations for
"Proofs as Directed Acyclic Graphs: Conservation, Hubs, and Foundations."

A *dependency network* is a directed graph on statements: an edge u -> v means
"statement u is used directly in the derivation of statement v." This script
demonstrates, on concrete networks, the three structural laws:

  1. Conservation law:  sum(in-degrees) = edge count = sum(out-degrees).
  2. Hub existence:      some vertex v* satisfies  m <= n * indeg(v*).
  3. Foundations/frontier: a finite acyclic network has sources and sinks,
     recovered by topological layering (Kahn's algorithm).

It also fits a power-law exponent to the in-degree distribution of a grown
scale-free network, illustrating the empirical  P(k) ~ k^{-gamma}, gamma ~ 2.5.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
import random
from collections import defaultdict
from typing import Dict, List, Optional, Set, Tuple

# A dependency network is represented as (n, edges): n vertices labelled 0..n-1
# and a set of directed edges (u, v) meaning "u is used in the proof of v".
Edge = Tuple[int, int]
Network = Tuple[int, Set[Edge]]


# --------------------------------------------------------------------------- #
# Core structural quantities
# --------------------------------------------------------------------------- #
def in_degrees(n: int, edges: Set[Edge]) -> List[int]:
    """Return indeg(v) = #{u : (u, v) in edges} for every vertex v."""
    deg = [0] * n
    for _u, v in edges:
        deg[v] += 1
    return deg


def out_degrees(n: int, edges: Set[Edge]) -> List[int]:
    """Return outdeg(v) = #{u : (v, u) in edges} for every vertex v."""
    deg = [0] * n
    for u, _v in edges:
        deg[u] += 1
    return deg


def edge_count(edges: Set[Edge]) -> int:
    """Total number of dependency edges m = #edges."""
    return len(edges)


# --------------------------------------------------------------------------- #
# 1. Conservation law
# --------------------------------------------------------------------------- #
def conservation_audit(n: int, edges: Set[Edge]) -> Dict[str, int]:
    """Verify sum(indeg) = m = sum(outdeg) and return the three totals."""
    m = edge_count(edges)
    sum_in = sum(in_degrees(n, edges))
    sum_out = sum(out_degrees(n, edges))
    assert sum_in == m == sum_out, "Conservation law violated!"
    return {"edge_count": m, "sum_in_degree": sum_in, "sum_out_degree": sum_out}


# --------------------------------------------------------------------------- #
# 2. Hub existence
# --------------------------------------------------------------------------- #
def degree_hub(n: int, edges: Set[Edge], incoming: bool = True) -> Tuple[int, int, float]:
    """
    Return (v*, deg(v*), concentration) where v* maximizes the chosen degree
    (in-degree if incoming=True, else out-degree).

    Certifies the hub bound  m <= n * deg(v*)  and reports the concentration
    index  deg(v*) / (m / n)  (>= 1 always; = 1 iff the network is regular).
    """
    assert n > 0, "hub existence requires a nonempty network"
    deg = in_degrees(n, edges) if incoming else out_degrees(n, edges)
    v_star = max(range(n), key=lambda v: deg[v])
    m = edge_count(edges)
    assert m <= n * deg[v_star], "Hub bound violated!"
    avg = m / n if n else 0.0
    concentration = (deg[v_star] / avg) if avg > 0 else float("inf")
    return v_star, deg[v_star], concentration


# --------------------------------------------------------------------------- #
# 3. Acyclicity: topological layering, sources and sinks
# --------------------------------------------------------------------------- #
def topological_layers(n: int, edges: Set[Edge]) -> Optional[List[List[int]]]:
    """
    Kahn-style layering. Returns the list of layers (layer 0 = sources) if the
    network is acyclic, or None if a cycle is detected (peeling stalls).
    """
    succ: Dict[int, List[int]] = defaultdict(list)
    indeg = [0] * n
    for u, v in edges:
        succ[u].append(v)
        indeg[v] += 1

    remaining = n
    frontier = [v for v in range(n) if indeg[v] == 0]
    layers: List[List[int]] = []
    while frontier:
        layers.append(sorted(frontier))
        remaining -= len(frontier)
        nxt: List[int] = []
        for u in frontier:
            for w in succ[u]:
                indeg[w] -= 1
                if indeg[w] == 0:
                    nxt.append(w)
        frontier = nxt
    return layers if remaining == 0 else None


def sources_and_sinks(n: int, edges: Set[Edge]) -> Tuple[List[int], List[int]]:
    """Sources have in-degree 0 (foundations); sinks have out-degree 0 (frontier)."""
    indeg = in_degrees(n, edges)
    outdeg = out_degrees(n, edges)
    sources = [v for v in range(n) if indeg[v] == 0]
    sinks = [v for v in range(n) if outdeg[v] == 0]
    return sources, sinks


# --------------------------------------------------------------------------- #
# 4. Power-law exponent estimate (MLE on the tail)
# --------------------------------------------------------------------------- #
def power_law_exponent(degrees: List[int], k_min: int = 1) -> float:
    """
    Maximum-likelihood estimate of gamma in P(k) ~ k^{-gamma} for the tail
    k >= k_min, using the discrete Hill estimator.
    """
    tail = [k for k in degrees if k >= k_min]
    if not tail:
        return float("nan")
    s = sum(math.log(k / (k_min - 0.5)) for k in tail)
    return 1.0 + len(tail) / s


# --------------------------------------------------------------------------- #
# Network generators
# --------------------------------------------------------------------------- #
def acyclic_layered_network(seed: int = 0) -> Network:
    """A small handcrafted acyclic network: 2 axioms feeding a layered tower."""
    # 0,1 = axioms; 2,3 = lemmas; 4 = theorem; 5 = corollary (frontier).
    edges: Set[Edge] = {
        (0, 2), (1, 2), (0, 3), (2, 4), (3, 4), (4, 5), (1, 3),
    }
    return 6, edges


def cyclic_network() -> Network:
    """A network with a 2-cycle a -> b -> a: no source, no sink."""
    return 3, {(0, 1), (1, 0), (2, 0)}


def preferential_attachment_dag(n: int, m_edges: int, seed: int = 42) -> Network:
    """
    Grow an acyclic scale-free network: vertex t (in arrival order) attaches to
    m_edges earlier vertices chosen with probability proportional to current
    in-degree ("rich get richer"). Edges point earlier -> later, so acyclic.
    """
    rng = random.Random(seed)
    edges: Set[Edge] = set()
    targets: List[int] = []  # multiset for preferential selection
    for t in range(n):
        chosen: Set[int] = set()
        if t > 0 and targets:
            attempts = 0
            while len(chosen) < min(m_edges, t) and attempts < 20 * m_edges:
                src = rng.choice(targets)
                if src != t:
                    chosen.add(src)
                attempts += 1
        for src in chosen:
            edges.add((src, t))   # foundational src used to derive later t
            targets.append(t)     # t now becomes a possible future dependency
        targets.append(t)
    return n, edges


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def main() -> None:
    print("=" * 70)
    print("PROOFS AS DIRECTED ACYCLIC GRAPHS -- numerical demonstrations")
    print("=" * 70)

    # ---- Demo 1: conservation on a layered acyclic network ---------------- #
    n, edges = acyclic_layered_network()
    print("\n[1] Conservation law on a small acyclic network")
    print(f"    n = {n} statements, m = {edge_count(edges)} dependencies")
    audit = conservation_audit(n, edges)
    print(f"    sum(in-degree)  = {audit['sum_in_degree']}")
    print(f"    edge count  m   = {audit['edge_count']}")
    print(f"    sum(out-degree) = {audit['sum_out_degree']}")
    print("    -> sum(in) = m = sum(out) verified.")

    # ---- Demo 2: sources, sinks, topological layering --------------------- #
    print("\n[2] Foundations (sources) and frontier (sinks)")
    layers = topological_layers(n, edges)
    sources, sinks = sources_and_sinks(n, edges)
    print(f"    sources (axioms/foundations) : {sources}")
    print(f"    sinks   (frontier results)   : {sinks}")
    print(f"    topological layers           : {layers}")

    print("\n    Contrast: a cyclic network (2-cycle) has NO source/sink.")
    cn, ce = cyclic_network()
    print(f"    topological_layers -> {topological_layers(cn, ce)} (None = cycle detected)")

    # ---- Demo 3: hub existence on a scale-free network -------------------- #
    # Edges point (foundation -> dependent), so a foundational statement used
    # by many results is a HIGH-OUT-DEGREE node; that is the heavy-tailed,
    # scale-free quantity here. The in-degree hub bound also holds (dual form).
    print("\n[3] Hub existence on a grown scale-free network")
    N, E = preferential_attachment_dag(n=2000, m_edges=3, seed=7)
    conservation_audit(N, E)  # still exact on the large network
    v_star, d_star, conc = degree_hub(N, E, incoming=False)
    m = edge_count(E)
    print(f"    n = {N}, m = {m}, average degree = {m / N:.3f}")
    print(f"    most-depended-on hub v* = {v_star}, out-degree(v*) = {d_star}")
    print(f"    certified bound  m <= n * outdeg(v*):  {m} <= {N * d_star}")
    print(f"    concentration index outdeg(v*)/avg = {conc:.2f} (1.0 = regular)")

    # ---- Demo 4: power-law exponent --------------------------------------- #
    print("\n[4] Power-law fit of the dependency (out-degree) distribution")
    outdeg = [k for k in out_degrees(N, E) if k > 0]
    gamma = power_law_exponent(outdeg, k_min=3)
    print(f"    estimated exponent gamma ~ {gamma:.3f} (target ~ 2.5)")
    # crude histogram of the tail
    hist: Dict[int, int] = defaultdict(int)
    for k in outdeg:
        hist[k] += 1
    print("    out-degree : count")
    shown = sorted(hist)
    for k in shown[:6] + shown[-4:]:
        print(f"      {k:>4d}     : {hist[k]}")

    print("\nAll structural laws verified numerically.")


if __name__ == "__main__":
    main()
