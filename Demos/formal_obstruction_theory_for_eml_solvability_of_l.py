#!/usr/bin/env python3
"""
Numerical demonstrations of CSS codes from chain complexes.

Demonstrates the key results from the formal development:
1. Homological Dimension Theorem: logical qubits = β₁
2. CSS Dimension Formula: β₁ + dim(boundaries) = dim(cycles)
3. Rank-Nullity for Chain Complexes: dim(cycles) + dim(im ∂₁) = n
4. Logical Qubit Additivity (Third Isomorphism Theorem)
5. Self-Duality Collapse: C_X = C_Z → 0 logical qubits
6. Hypercube Betti Numbers: β₁(Q₂) = 1, β₁(Q_n) > 1 for n ≥ 3
7. Hamming Weight Properties: triangle inequality
"""

from __future__ import annotations

import numpy as np
from typing import NamedTuple


class ChainComplex3:
    """A 3-term chain complex V₂ →[d2] V₁ →[d1] V₀ over the rationals."""

    def __init__(self, d2: np.ndarray, d1: np.ndarray) -> None:
        """
        Args:
            d2: Matrix of ∂₂ (columns = basis of V₂, rows = basis of V₁)
            d1: Matrix of ∂₁ (columns = basis of V₁, rows = basis of V₀)
        """
        self.d2 = d2.astype(float)
        self.d1 = d1.astype(float)
        self.n = d1.shape[1]  # dimension of V₁
        # Verify chain condition
        product = d1 @ d2
        assert np.allclose(product, 0, atol=1e-10), (
            f"Chain condition violated: ∂₁ ∘ ∂₂ ≠ 0\n{product}"
        )

    def dim_cycles(self) -> int:
        """dim(ker ∂₁) = dim(Z₁)"""
        return self.n - int(np.linalg.matrix_rank(self.d1))

    def dim_boundaries(self) -> int:
        """dim(im ∂₂) = dim(B₁)"""
        return int(np.linalg.matrix_rank(self.d2))

    def dim_image_d1(self) -> int:
        """dim(im ∂₁)"""
        return int(np.linalg.matrix_rank(self.d1))

    def betti1(self) -> int:
        """β₁ = dim(H₁) = dim(Z₁) - dim(B₁) = logical qubits"""
        return self.dim_cycles() - self.dim_boundaries()


class CSSCode(NamedTuple):
    """A CSS code with parameters [n, k]."""
    n: int
    k: int  # logical qubits
    dim_CX: int
    dim_CZ: int


def css_from_complex(K: ChainComplex3) -> CSSCode:
    """Construct a CSS code from a chain complex (Theorem 1)."""
    return CSSCode(
        n=K.n,
        k=K.betti1(),
        dim_CX=K.dim_cycles(),
        dim_CZ=K.dim_boundaries(),
    )


def hamming_weight(v: np.ndarray) -> int:
    """Hamming weight: number of nonzero entries."""
    return int(np.count_nonzero(v))


def hypercube_betti1(n: int) -> int:
    """β₁(Q_n) = n * 2^(n-1) - 2^n + 1 for n ≥ 1."""
    if n == 0:
        return 0
    return n * (2 ** (n - 1)) - (2 ** n) + 1


# ─── Demo 1: Square Graph (Q₂) ─────────────────────────────────────────────

def demo_square_graph() -> None:
    """
    The square graph Q₂ has vertices {00, 01, 10, 11} and edges
    {00-01, 00-10, 01-11, 10-11}.

    Chain complex: ℝ⁰ → ℝ⁴ (edges) → ℝ⁴ (vertices)
    ∂₁ maps each edge to its boundary (head - tail).
    """
    print("=" * 60)
    print("DEMO 1: Square Graph Q₂")
    print("=" * 60)

    # Incidence matrix: ∂₁ maps edges → vertices
    # Edges: e1=00-01, e2=00-10, e3=01-11, e4=10-11
    # Vertices: v1=00, v2=01, v3=10, v4=11
    d1 = np.array([
        [-1,  -1,   0,   0],  # vertex 00
        [ 1,   0,  -1,   0],  # vertex 01
        [ 0,   1,   0,  -1],  # vertex 10
        [ 0,   0,   1,   1],  # vertex 11
    ], dtype=float)

    # No 2-cells, so ∂₂ = 0 (zero map from ℝ⁰ to ℝ⁴)
    d2 = np.zeros((4, 0), dtype=float)

    K = ChainComplex3(d2, d1)
    code = css_from_complex(K)

    print(f"  Ambient dimension n = {code.n}")
    print(f"  dim(cycles) = dim(C_X) = {code.dim_CX}")
    print(f"  dim(boundaries) = dim(C_Z) = {code.dim_CZ}")
    print(f"  Logical qubits k = β₁ = {code.k}")
    print()

    # Verify CSS dimension formula: β₁ + dim(B₁) = dim(Z₁)
    assert code.k + code.dim_CZ == code.dim_CX, "CSS Dimension Formula violated!"
    print(f"  ✓ CSS Dimension Formula: {code.k} + {code.dim_CZ} = {code.dim_CX}")

    # Verify rank-nullity: dim(Z₁) + dim(im ∂₁) = n
    dim_im = K.dim_image_d1()
    assert code.dim_CX + dim_im == code.n, "Rank-Nullity violated!"
    print(f"  ✓ Rank-Nullity: {code.dim_CX} + {dim_im} = {code.n}")

    # Verify hypercube formula
    assert code.k == hypercube_betti1(2) == 1
    print(f"  ✓ β₁(Q₂) = {hypercube_betti1(2)} (matches formula)")
    print()


# ─── Demo 2: Cube Graph (Q₃) ───────────────────────────────────────────────

def demo_cube_graph() -> None:
    """
    The cube Q₃ has 8 vertices and 12 edges.
    β₁ = 12 - 8 + 1 = 5 (five independent cycles).
    """
    print("=" * 60)
    print("DEMO 2: Cube Graph Q₃")
    print("=" * 60)

    # Vertices: 000, 001, 010, 011, 100, 101, 110, 111
    # Edges connect vertices differing in exactly one bit
    edges = [
        (0, 1), (0, 2), (0, 4),   # from 000
        (1, 3), (1, 5),            # from 001
        (2, 3), (2, 6),            # from 010
        (3, 7),                    # from 011
        (4, 5), (4, 6),            # from 100
        (5, 7),                    # from 101
        (6, 7),                    # from 110
    ]

    n_vertices = 8
    n_edges = len(edges)

    # Build incidence matrix
    d1 = np.zeros((n_vertices, n_edges), dtype=float)
    for j, (u, v) in enumerate(edges):
        d1[u, j] = -1
        d1[v, j] = 1

    d2 = np.zeros((n_edges, 0), dtype=float)

    K = ChainComplex3(d2, d1)
    code = css_from_complex(K)

    print(f"  Vertices = {n_vertices}, Edges = {n_edges}")
    print(f"  Logical qubits k = β₁ = {code.k}")
    print(f"  ✓ Formula gives β₁(Q₃) = {hypercube_betti1(3)}")

    assert code.k == 5, f"Expected 5, got {code.k}"
    assert code.k > 1, "Theorem: β₁(Q_n) > 1 for n ≥ 3"
    print(f"  ✓ β₁(Q₃) = {code.k} > 1 (multi-qubit code)")
    print()


# ─── Demo 3: Torus (Surface Code) ──────────────────────────────────────────

def demo_torus() -> None:
    """
    A 3×3 torus (identified square grid). The torus has β₁ = 2,
    encoding 2 logical qubits — this is Kitaev's toric code.
    """
    print("=" * 60)
    print("DEMO 3: Torus (3×3 grid with periodic boundaries)")
    print("=" * 60)

    L = 3
    n_vertices = L * L
    n_edges = 2 * L * L  # horizontal + vertical, with wrapping

    def vid(r: int, c: int) -> int:
        return (r % L) * L + (c % L)

    # Build edges: horizontal and vertical with periodic BC
    edges: list[tuple[int, int]] = []
    for r in range(L):
        for c in range(L):
            edges.append((vid(r, c), vid(r, c + 1)))  # horizontal
            edges.append((vid(r, c), vid(r + 1, c)))  # vertical

    # Build ∂₁ (incidence matrix: edges → vertices)
    d1 = np.zeros((n_vertices, n_edges), dtype=float)
    for j, (u, v) in enumerate(edges):
        d1[u, j] = -1
        d1[v, j] = 1

    # Build ∂₂ (faces → edges): each face is a square plaquette
    n_faces = L * L
    d2 = np.zeros((n_edges, n_faces), dtype=float)
    face_idx = 0
    for r in range(L):
        for c in range(L):
            # Face (r,c) has edges: right, down from (r,c), left from (r+1,c), up from (r,c+1)
            # Edge indices: horizontal edge at (r,c) is 2*(r*L + c)
            #               vertical edge at (r,c) is 2*(r*L + c) + 1
            def eidx_h(rr: int, cc: int) -> int:
                return 2 * ((rr % L) * L + (cc % L))

            def eidx_v(rr: int, cc: int) -> int:
                return 2 * ((rr % L) * L + (cc % L)) + 1

            # Boundary of face (r,c): right(r,c) + down(r,c+1) - right(r+1,c) - down(r,c)
            d2[eidx_h(r, c), face_idx] = 1
            d2[eidx_v(r, c + 1), face_idx] = 1
            d2[eidx_h(r + 1, c), face_idx] = -1
            d2[eidx_v(r, c), face_idx] = -1
            face_idx += 1

    K = ChainComplex3(d2, d1)
    code = css_from_complex(K)

    print(f"  Vertices = {n_vertices}, Edges = {n_edges}, Faces = {n_faces}")
    print(f"  dim(cycles) = {K.dim_cycles()}")
    print(f"  dim(boundaries) = {K.dim_boundaries()}")
    print(f"  Logical qubits k = β₁ = {code.k}")

    assert code.k == 2, f"Torus should have β₁ = 2, got {code.k}"
    print(f"  ✓ Toric code encodes k = 2 logical qubits")
    print()


# ─── Demo 4: Self-Duality Collapse ─────────────────────────────────────────

def demo_self_duality() -> None:
    """When C_X = C_Z, the code encodes 0 logical qubits."""
    print("=" * 60)
    print("DEMO 4: Self-Duality Collapse")
    print("=" * 60)

    # Complete graph K₃: 3 vertices, 3 edges
    # With all faces filled in, boundaries = cycles, so β₁ = 0
    d1 = np.array([
        [-1, -1,  0],
        [ 1,  0, -1],
        [ 0,  1,  1],
    ], dtype=float)

    # One face: the triangle itself
    d2 = np.array([
        [ 1],
        [-1],
        [ 1],
    ], dtype=float)

    K = ChainComplex3(d2, d1)
    code = css_from_complex(K)

    print(f"  Complete graph K₃ with filled triangle")
    print(f"  dim(cycles) = {K.dim_cycles()}, dim(boundaries) = {K.dim_boundaries()}")
    print(f"  Logical qubits k = {code.k}")

    # dim(cycles) = dim(boundaries) → self-dual → 0 qubits
    if code.dim_CX == code.dim_CZ:
        print(f"  ✓ C_X = C_Z (self-dual): k = 0 logical qubits")
    print()


# ─── Demo 5: Logical Qubit Additivity ──────────────────────────────────────

def demo_additivity() -> None:
    """
    For C_Z ≤ C_mid ≤ C_X:
    dim(C_X/C_Z) = dim(C_X/C_mid) + dim(C_mid/C_Z)
    """
    print("=" * 60)
    print("DEMO 5: Logical Qubit Additivity")
    print("=" * 60)

    n = 6
    # C_Z: 1-dimensional subspace
    CZ_basis = np.array([[1, 0, 0, 0, 0, 0]], dtype=float)
    # C_mid: 3-dimensional subspace containing C_Z
    Cmid_basis = np.array([
        [1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0],
    ], dtype=float)
    # C_X: 5-dimensional subspace containing C_mid
    CX_basis = np.array([
        [1, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0],
        [0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 1, 0],
    ], dtype=float)

    dim_CX = int(np.linalg.matrix_rank(CX_basis))
    dim_Cmid = int(np.linalg.matrix_rank(Cmid_basis))
    dim_CZ = int(np.linalg.matrix_rank(CZ_basis))

    dim_CX_CZ = dim_CX - dim_CZ
    dim_CX_Cmid = dim_CX - dim_Cmid
    dim_Cmid_CZ = dim_Cmid - dim_CZ

    print(f"  dim(C_X) = {dim_CX}, dim(C_mid) = {dim_Cmid}, dim(C_Z) = {dim_CZ}")
    print(f"  dim(C_X / C_Z)   = {dim_CX_CZ}")
    print(f"  dim(C_X / C_mid) = {dim_CX_Cmid}")
    print(f"  dim(C_mid / C_Z) = {dim_Cmid_CZ}")
    print(f"  {dim_CX_CZ} = {dim_CX_Cmid} + {dim_Cmid_CZ}")

    assert dim_CX_CZ == dim_CX_Cmid + dim_Cmid_CZ
    print(f"  ✓ Additivity verified!")
    print()


# ─── Demo 6: Hamming Weight ────────────────────────────────────────────────

def demo_hamming_weight() -> None:
    """Hamming weight properties: zero characterization and triangle inequality."""
    print("=" * 60)
    print("DEMO 6: Hamming Weight Properties")
    print("=" * 60)

    # Zero characterization
    v_zero = np.array([0, 0, 0, 0, 0])
    v_nonzero = np.array([1, 0, 3, 0, 2])
    print(f"  wt({v_zero}) = {hamming_weight(v_zero)} (is zero: {hamming_weight(v_zero) == 0})")
    print(f"  wt({v_nonzero}) = {hamming_weight(v_nonzero)} (is zero: {hamming_weight(v_nonzero) == 0})")

    assert hamming_weight(v_zero) == 0
    assert hamming_weight(v_nonzero) != 0
    print(f"  ✓ wt(v) = 0 iff v = 0")
    print()

    # Triangle inequality
    np.random.seed(42)
    violations = 0
    trials = 10000
    for _ in range(trials):
        v = np.random.randint(-3, 4, size=10)
        w = np.random.randint(-3, 4, size=10)
        if hamming_weight(v + w) > hamming_weight(v) + hamming_weight(w):
            violations += 1

    print(f"  Triangle inequality test: {trials} random trials, {violations} violations")
    assert violations == 0
    print(f"  ✓ wt(v + w) ≤ wt(v) + wt(w) holds for all tested cases")
    print()


# ─── Demo 7: Hypercube Betti Numbers ───────────────────────────────────────

def demo_hypercube_betti() -> None:
    """Tabulate hypercube Betti numbers and verify key theorems."""
    print("=" * 60)
    print("DEMO 7: Hypercube Betti Numbers β₁(Q_n)")
    print("=" * 60)

    print(f"  {'n':>3} | {'Vertices':>10} | {'Edges':>10} | {'β₁':>10} | {'> 1?':>5}")
    print(f"  {'-'*3}-+-{'-'*10}-+-{'-'*10}-+-{'-'*10}-+-{'-'*5}")

    for n in range(1, 11):
        vertices = 2 ** n
        edges = n * 2 ** (n - 1)
        b1 = hypercube_betti1(n)
        gt1 = "yes" if b1 > 1 else "no"
        print(f"  {n:>3} | {vertices:>10} | {edges:>10} | {b1:>10} | {gt1:>5}")

    # Verify specific theorems
    assert hypercube_betti1(2) == 1, "Theorem: β₁(Q₂) = 1"
    print(f"\n  ✓ β₁(Q₂) = 1")

    for n in range(3, 11):
        assert hypercube_betti1(n) > 1, f"Theorem: β₁(Q_{n}) > 1"
    print(f"  ✓ β₁(Q_n) > 1 for all n ∈ {{3, ..., 10}}")
    print()


# ─── Main ───────────────────────────────────────────────────────────────────

def main() -> None:
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  CSS Codes as Cohomology: Numerical Demonstrations      ║")
    print("╠══════════════════════════════════════════════════════════╣")
    print("║  Demonstrating the bridge between homological algebra   ║")
    print("║  and quantum error correction.                          ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_square_graph()
    demo_cube_graph()
    demo_torus()
    demo_self_duality()
    demo_additivity()
    demo_hamming_weight()
    demo_hypercube_betti()

    print("=" * 60)
    print("All demonstrations passed successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()
