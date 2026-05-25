"""
Compositional Rounding Certificates for Modular Hypergraphs
============================================================

Core algorithms for hypergraph transversal rounding and compositional
certificate construction.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass, field
from typing import List, Set, FrozenSet, Dict, Optional, Tuple


@dataclass
class Hypergraph:
    """A hypergraph with vertices and edges (each edge is a frozenset of vertices)."""
    vertices: Set[int]
    edges: List[FrozenSet[int]]

    def __post_init__(self):
        for e in self.edges:
            assert e.issubset(self.vertices), f"Edge {e} not subset of vertices"

    def max_edge_size(self) -> int:
        """Maximum cardinality of any edge."""
        return max((len(e) for e in self.edges), default=0)


@dataclass
class FractionalTransversal:
    """A fractional transversal: assignment x : V -> R with sum(x[v] for v in e) >= 1."""
    values: Dict[int, float]

    def cost(self, vertices: Set[int]) -> float:
        """Total fractional cost over the given vertex set."""
        return sum(self.values.get(v, 0.0) for v in vertices)

    def is_valid(self, H: Hypergraph, tol: float = 1e-9) -> bool:
        """Check if this is a valid fractional transversal of H."""
        for e in H.edges:
            if sum(self.values.get(v, 0.0) for v in e) < 1.0 - tol:
                return False
        return True

    def is_nonneg(self) -> bool:
        """Check nonnegativity."""
        return all(v >= -1e-12 for v in self.values.values())


@dataclass
class HypergraphGluing:
    """A decomposition of hypergraph H into H1 and H2 sharing a boundary."""
    H1: Hypergraph
    H2: Hypergraph
    H: Hypergraph
    boundary: Set[int]

    def __post_init__(self):
        # Verify boundary = V1 ∩ V2
        assert self.boundary == self.H1.vertices & self.H2.vertices, \
            "Boundary must equal V1 ∩ V2"
        # Verify edge covering
        e1_set = set(self.H1.edges)
        e2_set = set(self.H2.edges)
        for e in self.H.edges:
            assert e in e1_set or e in e2_set, \
                f"Edge {e} not covered by H1 or H2"


@dataclass
class RoundingCertificate:
    """A rounding certificate: fractional + integral transversals with cost bound."""
    hypergraph: Hypergraph
    fractional: FractionalTransversal
    integral: Set[int]
    degree: int
    cost: float
    fractional_cost: float


def agrees_on(x1: FractionalTransversal, x2: FractionalTransversal,
              boundary: Set[int], tol: float = 1e-9) -> bool:
    """Check if two fractional transversals agree on the boundary."""
    for v in boundary:
        if abs(x1.values.get(v, 0.0) - x2.values.get(v, 0.0)) > tol:
            return False
    return True


def glued_fn(x1: FractionalTransversal, x2: FractionalTransversal,
             V1: Set[int]) -> FractionalTransversal:
    """Construct the glued function: x1 on V1, x2 elsewhere."""
    values = {}
    all_vertices = set(x1.values.keys()) | set(x2.values.keys())
    for v in all_vertices:
        if v in V1:
            values[v] = x1.values.get(v, 0.0)
        else:
            values[v] = x2.values.get(v, 0.0)
    return FractionalTransversal(values)


def threshold_rounding(x: FractionalTransversal, vertices: Set[int],
                       d: int) -> Set[int]:
    """Threshold rounding: select vertices where x(v) >= 1/d.

    Args:
        x: Fractional transversal
        vertices: Vertex set to threshold over
        d: Degree parameter (max edge size)

    Returns:
        Set of selected vertices
    """
    assert d > 0, "Degree must be positive"
    threshold = 1.0 / d
    return {v for v in vertices if x.values.get(v, 0.0) >= threshold - 1e-12}


def compose_certificates(gluing: HypergraphGluing,
                         cert1: RoundingCertificate,
                         cert2: RoundingCertificate) -> RoundingCertificate:
    """Compose two rounding certificates along a hypergraph gluing.

    This implements the modular certification soundness theorem:
    given certificates for H1 and H2 whose fractional solutions agree
    on the boundary, produces a certificate for H.

    Args:
        gluing: The hypergraph gluing structure
        cert1: Certificate for H1
        cert2: Certificate for H2

    Returns:
        A rounding certificate for H with the compositional cost bound

    Raises:
        AssertionError: If fractional solutions don't agree on boundary
    """
    # Verify boundary agreement
    assert agrees_on(cert1.fractional, cert2.fractional, gluing.boundary), \
        "Fractional transversals must agree on boundary"

    # Construct glued function
    x = glued_fn(cert1.fractional, cert2.fractional, gluing.H1.vertices)

    # Verify glued function is a valid fractional transversal
    assert x.is_valid(gluing.H), \
        "Glued function should be valid (by Theorem 1)"

    # Compute degree and threshold set
    d = max(cert1.degree, cert2.degree)
    S = threshold_rounding(x, gluing.H.vertices, d)

    # Verify transversal property
    for e in gluing.H.edges:
        assert len(e & S) > 0, f"Edge {e} not hit by threshold set"

    # Compute costs
    frac_cost = cert1.fractional_cost + cert2.fractional_cost
    int_cost = float(len(S))

    return RoundingCertificate(
        hypergraph=gluing.H,
        fractional=x,
        integral=S,
        degree=d,
        cost=int_cost,
        fractional_cost=x.cost(gluing.H.vertices)
    )


def solve_fractional_transversal_lp(H: Hypergraph) -> FractionalTransversal:
    """Solve the LP relaxation of the minimum transversal problem.

    Minimize sum(x[v]) subject to:
      sum(x[v] for v in e) >= 1  for all edges e
      x[v] >= 0                  for all vertices v

    Args:
        H: Input hypergraph

    Returns:
        Optimal fractional transversal
    """
    from scipy.optimize import linprog

    vertices = sorted(H.vertices)
    v_idx = {v: i for i, v in enumerate(vertices)}
    n = len(vertices)

    # Objective: minimize sum(x[v])
    c = np.ones(n)

    # Constraints: sum(x[v] for v in e) >= 1, i.e., -sum(...) <= -1
    A_ub = []
    b_ub = []
    for e in H.edges:
        row = np.zeros(n)
        for v in e:
            row[v_idx[v]] = -1.0
        A_ub.append(row)
        b_ub.append(-1.0)

    A_ub = np.array(A_ub) if A_ub else np.zeros((0, n))
    b_ub = np.array(b_ub) if b_ub else np.zeros(0)

    bounds = [(0, None) for _ in range(n)]

    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')

    if result.success:
        values = {vertices[i]: max(0.0, result.x[i]) for i in range(n)}
        return FractionalTransversal(values)
    else:
        raise ValueError(f"LP solve failed: {result.message}")


def build_certificate(H: Hypergraph) -> RoundingCertificate:
    """Build a complete rounding certificate for a hypergraph.

    Solves the LP relaxation and applies threshold rounding.

    Args:
        H: Input hypergraph

    Returns:
        A rounding certificate with cost bound d * fractional_cost
    """
    x = solve_fractional_transversal_lp(H)
    d = H.max_edge_size()
    if d == 0:
        d = 1
    S = threshold_rounding(x, H.vertices, d)
    frac_cost = x.cost(H.vertices)

    return RoundingCertificate(
        hypergraph=H,
        fractional=x,
        integral=S,
        degree=d,
        cost=float(len(S)),
        fractional_cost=frac_cost
    )


if __name__ == "__main__":
    # Example: simple hypergraph
    H = Hypergraph(
        vertices={0, 1, 2, 3, 4},
        edges=[frozenset({0, 1, 2}), frozenset({2, 3}), frozenset({3, 4})]
    )

    cert = build_certificate(H)
    print(f"Hypergraph: {len(H.vertices)} vertices, {len(H.edges)} edges")
    print(f"Max edge size: {H.max_edge_size()}")
    print(f"Fractional cost: {cert.fractional_cost:.4f}")
    print(f"Integral cost: {cert.cost:.0f}")
    print(f"Integral transversal: {cert.integral}")
    print(f"Cost ratio: {cert.cost / cert.fractional_cost:.4f}")
