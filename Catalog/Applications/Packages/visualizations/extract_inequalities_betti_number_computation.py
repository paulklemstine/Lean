#!/usr/bin/env python3
"""
Algorithms for chain complex analysis and discrete Morse theory.

Implements:
1. Betti number computation via rank-nullity
2. Weak Morse inequality verification
3. Discrete Morse reduction (greedy acyclic matching)
4. Euler characteristic computation
"""

import numpy as np
from typing import Tuple, List, Dict, Optional, Set
from dataclasses import dataclass


@dataclass
class ChainComplex:
    """A three-term chain complex C₂ →d₂ C₁ →d₁ C₀."""
    d1: np.ndarray  # shape (dim_C0, dim_C1)
    d2: np.ndarray  # shape (dim_C1, dim_C2)

    @property
    def dim_C0(self) -> int:
        return self.d1.shape[0]

    @property
    def dim_C1(self) -> int:
        return self.d1.shape[1]

    @property
    def dim_C2(self) -> int:
        return self.d2.shape[1]

    def verify_chain_condition(self, tol: float = 1e-10) -> bool:
        """Verify d₁ ∘ d₂ = 0."""
        return np.allclose(self.d1 @ self.d2, 0, atol=tol)


def compute_betti_numbers(cc: ChainComplex) -> Tuple[int, int, int]:
    """
    Compute Betti numbers of a three-term chain complex.

    Uses the formula:
        β₀ = dim C₀ - rank(d₁)
        β₁ = dim C₁ - rank(d₁) - rank(d₂)
        β₂ = dim C₂ - rank(d₂)

    Time complexity: O(max(n₀·n₁², n₁·n₂²)) for SVD-based rank computation.

    Parameters
    ----------
    cc : ChainComplex
        The chain complex to analyze.

    Returns
    -------
    Tuple[int, int, int]
        Betti numbers (β₀, β₁, β₂).

    Raises
    ------
    ValueError
        If the chain condition d₁∘d₂ = 0 is not satisfied.
    """
    if not cc.verify_chain_condition():
        raise ValueError("Chain condition d₁∘d₂ = 0 is not satisfied")

    rank_d1 = int(np.linalg.matrix_rank(cc.d1))
    rank_d2 = int(np.linalg.matrix_rank(cc.d2))

    beta0 = cc.dim_C0 - rank_d1
    beta1 = cc.dim_C1 - rank_d1 - rank_d2
    beta2 = cc.dim_C2 - rank_d2

    assert beta0 >= 0 and beta1 >= 0 and beta2 >= 0, \
        f"Negative Betti number: ({beta0}, {beta1}, {beta2})"

    return beta0, beta1, beta2


def euler_characteristic(cc: ChainComplex) -> int:
    """
    Compute the Euler characteristic χ = dim C₀ - dim C₁ + dim C₂.

    By the Euler characteristic theorem, this equals β₀ - β₁ + β₂.

    Parameters
    ----------
    cc : ChainComplex
        The chain complex.

    Returns
    -------
    int
        The Euler characteristic.
    """
    return cc.dim_C0 - cc.dim_C1 + cc.dim_C2


def verify_weak_morse_inequalities(cc: ChainComplex) -> Dict[str, bool]:
    """
    Verify all three weak Morse inequalities for a chain complex.

    Parameters
    ----------
    cc : ChainComplex
        The chain complex to verify.

    Returns
    -------
    Dict[str, bool]
        Dictionary with keys 'deg0', 'deg1', 'euler' indicating
        whether each inequality/equality holds.
    """
    beta0, beta1, beta2 = compute_betti_numbers(cc)

    return {
        'deg0': beta0 <= cc.dim_C0,
        'deg1': (beta1 - beta0) <= (cc.dim_C1 - cc.dim_C0),
        'euler': (beta2 - beta1 + beta0) == (cc.dim_C2 - cc.dim_C1 + cc.dim_C0),
    }


def master_decomposition(cc: ChainComplex) -> Dict[str, int]:
    """
    Compute the master decomposition:
        dim Cₖ = βₖ + dim Bₖ₋₁ + dim Bₖ

    Parameters
    ----------
    cc : ChainComplex
        The chain complex.

    Returns
    -------
    Dict[str, int]
        Dictionary with β₀, β₁, β₂, dim_B0, dim_B1.
    """
    beta0, beta1, beta2 = compute_betti_numbers(cc)
    dim_B0 = int(np.linalg.matrix_rank(cc.d1))
    dim_B1 = int(np.linalg.matrix_rank(cc.d2))

    return {
        'beta0': beta0, 'beta1': beta1, 'beta2': beta2,
        'dim_B0': dim_B0, 'dim_B1': dim_B1,
    }


@dataclass
class CellComplex:
    """A finite 2D cell complex with explicit cell sets and incidence."""
    num_vertices: int
    num_edges: int
    num_faces: int
    edge_vertices: List[Tuple[int, int]]  # (source, target) for each edge
    face_edges: List[List[Tuple[int, int]]]  # [(edge_idx, sign)] for each face

    def to_chain_complex(self) -> ChainComplex:
        """Convert to a chain complex over ℚ (represented as float)."""
        d1 = np.zeros((self.num_vertices, self.num_edges))
        for e_idx, (src, tgt) in enumerate(self.edge_vertices):
            d1[src, e_idx] = -1
            d1[tgt, e_idx] = 1

        d2 = np.zeros((self.num_edges, self.num_faces))
        for f_idx, edges in enumerate(self.face_edges):
            for e_idx, sign in edges:
                d2[e_idx, f_idx] = sign

        return ChainComplex(d1=d1, d2=d2)


@dataclass
class DiscreteMorseResult:
    """Result of a discrete Morse reduction."""
    critical_vertices: List[int]
    critical_edges: List[int]
    critical_faces: List[int]
    num_crit0: int
    num_crit1: int
    num_crit2: int
    original_betti: Tuple[int, int, int]
    pairings: List[Tuple[str, int, str, int]]  # (cell_type, cell_idx, ...)


def greedy_discrete_morse(cell_complex: CellComplex) -> DiscreteMorseResult:
    """
    Perform a discrete Morse reduction using spanning-tree-based pairing.

    The algorithm builds a spanning forest (one tree per connected component)
    and pairs each non-root vertex with the spanning-tree edge leading to it.
    Then pairs faces with edges not in the spanning tree.

    This guarantees an acyclic matching and βₖ ≤ cₖ.

    Parameters
    ----------
    cell_complex : CellComplex
        The cell complex to reduce.

    Returns
    -------
    DiscreteMorseResult
        The result of the reduction, including critical cells.
    """
    cc = cell_complex.to_chain_complex()
    betti = compute_betti_numbers(cc)

    nV = cell_complex.num_vertices
    nE = cell_complex.num_edges
    nF = cell_complex.num_faces

    # Build adjacency
    adj: dict = {i: [] for i in range(nV)}
    for e_idx, (src, tgt) in enumerate(cell_complex.edge_vertices):
        adj[src].append((tgt, e_idx))
        adj[tgt].append((src, e_idx))

    # Phase 1: Build spanning forest, pair non-root vertices with tree edges
    visited = [False] * nV
    paired_vertices: Set[int] = set()
    paired_edges: Set[int] = set()
    paired_faces: Set[int] = set()
    pairings: List[Tuple[str, int, str, int]] = []

    for root in range(nV):
        if visited[root]:
            continue
        # BFS spanning tree from root
        queue = [root]
        visited[root] = True
        while queue:
            v = queue.pop(0)
            for (w, e_idx) in adj[v]:
                if not visited[w]:
                    visited[w] = True
                    queue.append(w)
                    # Pair vertex w with edge e_idx
                    paired_vertices.add(w)
                    paired_edges.add(e_idx)
                    pairings.append(("vertex", w, "edge", e_idx))

    # Phase 2: Pair faces with non-tree edges
    for f_idx, edges in enumerate(cell_complex.face_edges):
        for e_idx, _ in edges:
            if e_idx not in paired_edges and f_idx not in paired_faces:
                paired_edges.add(e_idx)
                paired_faces.add(f_idx)
                pairings.append(("edge", e_idx, "face", f_idx))
                break

    crit_v = [i for i in range(nV) if i not in paired_vertices]
    crit_e = [i for i in range(nE) if i not in paired_edges]
    crit_f = [i for i in range(nF) if i not in paired_faces]

    return DiscreteMorseResult(
        critical_vertices=crit_v,
        critical_edges=crit_e,
        critical_faces=crit_f,
        num_crit0=len(crit_v),
        num_crit1=len(crit_e),
        num_crit2=len(crit_f),
        original_betti=betti,
        pairings=pairings,
    )


def verify_morse_critical_bounds(result: DiscreteMorseResult) -> Dict[str, bool]:
    """
    Verify βₖ ≤ cₖ for all degrees.

    Parameters
    ----------
    result : DiscreteMorseResult

    Returns
    -------
    Dict[str, bool]
    """
    b0, b1, b2 = result.original_betti
    return {
        'beta0_le_c0': b0 <= result.num_crit0,
        'beta1_le_c1': b1 <= result.num_crit1,
        'beta2_le_c2': b2 <= result.num_crit2,
        'euler': (result.num_crit0 - result.num_crit1 + result.num_crit2
                  == b0 - b1 + b2),
    }


# ── Example usage ──

def make_triangle_boundary() -> CellComplex:
    """Triangle boundary (circle S¹)."""
    return CellComplex(
        num_vertices=3, num_edges=3, num_faces=0,
        edge_vertices=[(0, 1), (1, 2), (0, 2)],
        face_edges=[],
    )


def make_filled_triangle() -> CellComplex:
    """Filled triangle (disk D²)."""
    return CellComplex(
        num_vertices=3, num_edges=3, num_faces=1,
        edge_vertices=[(0, 1), (1, 2), (0, 2)],
        face_edges=[[(0, 1), (1, 1), (2, -1)]],  # ∂f = e₀₁ + e₁₂ - e₀₂
    )


def make_tetrahedron_boundary() -> CellComplex:
    """Boundary of tetrahedron (S²), with 4 vertices, 6 edges, 4 faces."""
    return CellComplex(
        num_vertices=4, num_edges=6, num_faces=4,
        edge_vertices=[
            (0, 1), (0, 2), (0, 3),  # edges from vertex 0
            (1, 2), (1, 3),          # edges from vertex 1
            (2, 3),                   # edge from vertex 2
        ],
        face_edges=[
            [(0, 1), (3, 1), (1, -1)],   # face 012: e01 + e12 - e02
            [(0, 1), (4, 1), (2, -1)],   # face 013: e01 + e13 - e03
            [(1, 1), (5, 1), (2, -1)],   # face 023: e02 + e23 - e03
            [(3, 1), (5, 1), (4, -1)],   # face 123: e12 + e23 - e13
        ],
    )


if __name__ == "__main__":
    print("Algorithms for Chain Complex Analysis")
    print("=" * 50)

    # Test on triangle boundary
    tri = make_triangle_boundary()
    cc = tri.to_chain_complex()
    print(f"\nTriangle boundary: V={tri.num_vertices}, E={tri.num_edges}, F={tri.num_faces}")
    print(f"  Chain condition: {cc.verify_chain_condition()}")
    print(f"  Betti numbers: {compute_betti_numbers(cc)}")
    print(f"  Euler characteristic: {euler_characteristic(cc)}")
    print(f"  Morse inequalities: {verify_weak_morse_inequalities(cc)}")

    # Discrete Morse reduction
    morse = greedy_discrete_morse(tri)
    print(f"  Discrete Morse: c=({morse.num_crit0}, {morse.num_crit1}, {morse.num_crit2})")
    print(f"  Critical bounds: {verify_morse_critical_bounds(morse)}")

    # Test on filled triangle
    filled = make_filled_triangle()
    cc2 = filled.to_chain_complex()
    print(f"\nFilled triangle: V={filled.num_vertices}, E={filled.num_edges}, F={filled.num_faces}")
    print(f"  Chain condition: {cc2.verify_chain_condition()}")
    print(f"  Betti numbers: {compute_betti_numbers(cc2)}")
    morse2 = greedy_discrete_morse(filled)
    print(f"  Discrete Morse: c=({morse2.num_crit0}, {morse2.num_crit1}, {morse2.num_crit2})")
    print(f"  Critical bounds: {verify_morse_critical_bounds(morse2)}")

    # Test on tetrahedron boundary (S²)
    tet = make_tetrahedron_boundary()
    cc3 = tet.to_chain_complex()
    print(f"\nTetrahedron boundary (S²): V={tet.num_vertices}, E={tet.num_edges}, F={tet.num_faces}")
    print(f"  Chain condition: {cc3.verify_chain_condition()}")
    print(f"  Betti numbers: {compute_betti_numbers(cc3)}")
    print(f"  Euler characteristic: {euler_characteristic(cc3)}")
    morse3 = greedy_discrete_morse(tet)
    print(f"  Discrete Morse: c=({morse3.num_crit0}, {morse3.num_crit1}, {morse3.num_crit2})")
    print(f"  Critical bounds: {verify_morse_critical_bounds(morse3)}")
