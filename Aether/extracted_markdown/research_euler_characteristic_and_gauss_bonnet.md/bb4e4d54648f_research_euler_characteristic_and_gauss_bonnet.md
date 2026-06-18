# Discrete Gauss–Bonnet, Poincaré–Hopf, and Euler Characteristic: A Formally Verified Framework

## Abstract

We present a formally verified framework in Lean 4 that unifies three classical results in geometry and topology through the Euler characteristic of finite cell complexes. Our main contributions are:

1. **Euler characteristic invariance** under four types of elementary subdivision moves (edge split, face split, stellar subdivision, vertex insertion), proved via explicit cardinality accounting.
2. **A discrete Gauss–Bonnet theorem** for closed triangulated surfaces: the total angle-defect curvature equals 2π times the Euler characteristic.
3. **A discrete Poincaré–Hopf theorem** via Forman discrete vector fields: the alternating sum of critical cell counts equals the Euler characteristic.
4. **Genus classification** and cross-domain consequences: the curvature-genus formula ∑K(v) = 2π(2−2g) and the curvature obstruction theorem for high-genus surfaces.

All theorems are machine-verified with no axioms beyond the standard foundations (propext, Classical.choice, Quot.sound). The framework provides a computationally executable bridge between combinatorial topology, discrete differential geometry, and dynamical systems.

## 1. Introduction

### 1.1 Motivation

The Gauss–Bonnet theorem is one of the central results of differential geometry, relating the integral of Gaussian curvature over a closed surface to its Euler characteristic. The Poincaré–Hopf theorem relates the total index of a vector field on a manifold to the same topological invariant. Together, these results form a bridge between geometry, topology, and dynamics.

Formalizing the classical smooth versions of these theorems requires substantial infrastructure: smooth manifolds, differential forms, integration theory, and vector bundles. While projects like Mathlib have made significant progress toward these foundations, a complete formalization of smooth Gauss–Bonnet remains out of reach.

We take a different approach: we formalize the **discrete** versions of these theorems, which apply to finite triangulated surfaces and cell complexes. These discrete theorems are:
- Mathematically rigorous and non-trivial
- Computationally executable
- Directly applicable to mesh processing, computational topology, and numerical physics
- Natural stepping stones toward the smooth theory

### 1.2 Related Work

**Discrete differential geometry.** The theory of discrete curvature via angle defects goes back to Descartes and was developed systematically by Regge (1961) for general relativity and by Banchoff (1967, 1970) for polyhedral surfaces. The modern framework of discrete exterior calculus was developed by Desbrun, Kanso, and Tong (2008).

**Discrete Morse theory.** Forman (1998, 2002) developed a combinatorial analogue of smooth Morse theory for CW complexes, proving that the alternating sum of critical cells equals the Euler characteristic.

**Formal verification in geometry.** The Mathlib library for Lean 4 contains extensive algebraic and analytic foundations but limited discrete geometry. Our work builds directly on Mathlib's Fintype, Finset, and real analysis libraries.

### 1.3 Contributions

Our formally verified results include:

| Theorem | Statement | Proof Method |
|---------|-----------|-------------|
| `eulerChar_edge_split_invariant` | χ invariant under edge split | Cardinality arithmetic |
| `eulerChar_stellar_invariant` | χ invariant under stellar subdivision | Cardinality arithmetic |
| `discrete_gauss_bonnet` | ∑K(v) = 2πχ | Double-counting + algebra |
| `discrete_poincare_hopf` | c₀ − c₁ + c₂ = χ | Algebraic cancellation |
| `eulerChar_eq_two_sub_two_mul_genus` | χ = 2 − 2g | Even integer arithmetic |
| `total_curvature_eq_genus` | ∑K(v) = 2π(2−2g) | Composition |
| `total_curvature_nonpos_high_genus` | g ≥ 1 ⟹ ∑K(v) ≤ 0 | Sign analysis |
| `critical_1_cells_dominate` | χ ≤ 0 ⟹ c₀ + c₂ ≤ c₁ | Poincaré–Hopf + inequality |
| `sphere_total_curvature` | ∑K(v) = 4π for S² | Gauss–Bonnet + genus |
| `torus_total_curvature_zero` | ∑K(v) = 0 for T² | Gauss–Bonnet + genus |

## 2. Definitions

### 2.1 Finite Cell Complexes

**Definition 2.1** (FinCellComplex2). A *finite 2-dimensional cell complex* consists of three finite types V (vertices), E (edges), and F (faces).

```
structure FinCellComplex2 where
  V : Type; E : Type; F : Type
  [fV : Fintype V]; [fE : Fintype E]; [fF : Fintype F]
```

**Definition 2.2** (Euler characteristic). The Euler characteristic of a finite 2-cell complex X is:

χ(X) = |V| − |E| + |F|

### 2.2 Subdivision Moves

We define four elementary subdivision operations:

| Move | ΔV | ΔE | ΔF | Δχ |
|------|----|----|----|----|
| Edge split | +1 | +1 | 0 | 0 |
| Face split | 0 | +1 | +1 | 0 |
| Stellar subdivision | +1 | +3 | +2 | 0 |
| Vertex insertion | +1 | +3 | +2 | 0 |

Each move preserves the Euler characteristic by construction.

### 2.3 Triangulated Surfaces

**Definition 2.3** (TriangulatedSurface). A *closed triangulated surface* consists of:
- Finite types V, E, F with decidable equality on V
- A face-vertex map `faceVerts : F → Fin 3 → V`
- An angle assignment `angle : F → Fin 3 → ℝ`
- Angle sum axiom: for each face f, ∑ᵢ angle(f, i) = π
- Closure condition: 3|F| = 2|E|

The closure condition encodes that each edge is shared by exactly two triangles. Together with the triangle structure, it ensures the surface is closed (no boundary).

**Definition 2.4** (Vertex curvature). The *angle-defect curvature* at vertex v is:

K(v) = 2π − ∑_{f,i : faceVerts(f,i)=v} angle(f, i)

This is the discrete analogue of Gaussian curvature, representing the angular deficit at each vertex.

### 2.4 Forman Discrete Vector Fields

**Definition 2.5** (FormanField). A *Forman discrete vector field* on a 2-cell complex X consists of:
- numVEPairs: number of (vertex, edge) pairings
- numEFPairs: number of (edge, face) pairings

Subject to the constraints:
- numVEPairs ≤ |V|
- numVEPairs + numEFPairs ≤ |E|
- numEFPairs ≤ |F|

The *critical cells* are unpaired cells: c₀ = |V| − numVEPairs, c₁ = |E| − numVEPairs − numEFPairs, c₂ = |F| − numEFPairs.

### 2.5 Genus

**Definition 2.6** (Orientable genus). For a surface with even Euler characteristic, the genus is g = (2 − χ)/2.

## 3. Main Results

### 3.1 Theorem 1: Euler Characteristic Invariance

**Theorem 3.1** (eulerChar_edge_split_invariant). If Y is obtained from X by an edge split, then χ(X) = χ(Y).

*Proof.* By definition, |V_Y| = |V_X| + 1, |E_Y| = |E_X| + 1, |F_Y| = |F_X|. Therefore χ(Y) = (|V_X|+1) − (|E_X|+1) + |F_X| = |V_X| − |E_X| + |F_X| = χ(X). □

The same argument applies to all four subdivision moves. The proof is formalized as a direct computation using `push_cast; ring`.

### 3.2 Theorem 2: Discrete Gauss–Bonnet

**Theorem 3.2** (discrete_gauss_bonnet). For any closed triangulated surface T:

∑_v K(v) = 2πχ(T)

*Proof sketch.* The proof proceeds by double-counting in four steps.

**Step 1: Expand the curvature sum.**
$$\sum_v K(v) = \sum_v \left(2\pi - \sum_{f,i} \mathbf{1}[\text{faceVerts}(f,i)=v] \cdot \text{angle}(f,i)\right)$$
$$= 2\pi|V| - \sum_v \sum_f \sum_i \mathbf{1}[\text{faceVerts}(f,i)=v] \cdot \text{angle}(f,i)$$

This uses linearity of finite summation (Finset.sum_sub_distrib) and the fact that ∑_v 2π = 2π|V|.

**Step 2: Swap summation order.**
$$\sum_v \sum_f \sum_i \mathbf{1}[\text{faceVerts}(f,i)=v] \cdot \text{angle}(f,i) = \sum_f \sum_i \sum_v \mathbf{1}[\text{faceVerts}(f,i)=v] \cdot \text{angle}(f,i)$$

This uses Finset.sum_comm. The key observation is that for fixed (f, i), the sum over v of the indicator function picks out exactly angle(f, i), since faceVerts(f, i) is a specific vertex. Formally, this uses Fintype.sum_ite_eq.

**Step 3: Apply the angle sum axiom.**
$$\sum_f \sum_i \text{angle}(f,i) = \sum_f \pi = \pi|F|$$

**Step 4: Algebraic simplification using 3|F| = 2|E|.**
$$2\pi|V| - \pi|F| = 2\pi(|V| - |E| + |F|)$$

This requires showing that −π|F| = −2π|E| + 2π|F|, equivalently 2|E| = 3|F|, which is exactly the closure hypothesis. The formal proof uses nlinarith with the cast of the integer hypothesis to ℝ and Real.pi_pos. □

### 3.3 Theorem 3: Discrete Poincaré–Hopf

**Theorem 3.3** (discrete_poincare_hopf). For any Forman field M on a cell complex X:

c₀ − c₁ + c₂ = χ(X)

*Proof.* By direct computation:
$$c_0 - c_1 + c_2 = (|V| - p) - (|E| - p - q) + (|F| - q) = |V| - |E| + |F| = \chi(X)$$

where p = numVEPairs and q = numEFPairs. The formal proof is `ring`. □

This is algebraically simple but conceptually significant: it shows that cell pairings preserve the alternating sum, which is the combinatorial essence of the Poincaré–Hopf theorem.

### 3.4 Theorem 4: Genus Classification

**Theorem 3.4** (eulerChar_eq_two_sub_two_mul_genus). For an orientable closed connected surface (i.e., one with even Euler characteristic):

χ = 2 − 2g

*Proof.* Since χ is even, write χ = 2k. Then g = (2 − 2k)/2 = 1 − k, and 2 − 2g = 2 − 2(1−k) = 2k = χ. The formal proof uses `grind` after unfolding definitions. □

### 3.5 Cross-Domain Results

**Theorem 3.5** (total_curvature_eq_genus). ∑_v K(v) = 2π(2 − 2g).

*Proof.* Immediate from Theorems 3.2 and 3.4. □

**Theorem 3.6** (total_curvature_nonpos_high_genus). For genus g ≥ 1: ∑_v K(v) ≤ 0.

*Proof.* From Theorem 3.4, χ = 2 − 2g ≤ 0. From Theorem 3.2, ∑K(v) = 2πχ. Since π > 0, the product 2πχ ≤ 0. □

**Theorem 3.7** (critical_1_cells_dominate). If χ ≤ 0, then c₀ + c₂ ≤ c₁.

*Proof.* From Theorem 3.3, c₀ − c₁ + c₂ = χ ≤ 0, so c₀ + c₂ ≤ c₁. □

## 4. Algorithms

### 4.1 Euler Characteristic Computation

**Algorithm 1: computeEulerChar(V, E, F)**
```
Input: Counts of vertices V, edges E, faces F
Output: Euler characteristic χ = V − E + F
Time: O(1)
Space: O(1)
```

We verify this against known polyhedra:
| Surface | V | E | F | χ | Genus |
|---------|---|---|---|---|-------|
| Tetrahedron | 4 | 6 | 4 | 2 | 0 |
| Octahedron | 6 | 12 | 8 | 2 | 0 |
| Icosahedron | 12 | 30 | 20 | 2 | 0 |
| Minimal torus | 7 | 21 | 14 | 0 | 1 |
| Genus-2 | 10 | 30 | 18 | −2 | 2 |

### 4.2 Angle-Defect Curvature Computation

**Algorithm 2: computeVertexCurvature(T, v)**
```
Input: Triangulated surface T, vertex v
Output: K(v) = 2π − ∑ angles at v
Time: O(deg(v)) where deg(v) is the vertex degree
Space: O(1)
```

**Algorithm 3: verifyGaussBonnet(T)**
```
Input: Triangulated surface T
Output: Boolean — whether ∑K(v) ≈ 2πχ(T)
Time: O(|V| + |F|)
Space: O(|V|)
```

### 4.3 Forman Field Analysis

**Algorithm 4: computeCriticalCells(X, M)**
```
Input: Cell complex X, Forman field M
Output: (c₀, c₁, c₂) critical cell counts
Time: O(1)
Space: O(1)
```

## 5. Computational Experiments

Our Python demonstrations (see `demo.py`) verify the theorems on concrete examples:

1. **Tetrahedron** (sphere): χ = 2, total curvature = 4π ≈ 12.566
2. **Regular octahedron** (sphere): χ = 2, total curvature = 4π ≈ 12.566
3. **Minimal torus triangulation**: χ = 0, total curvature = 0
4. **Cube triangulation** (sphere): χ = 2, total curvature = 4π ≈ 12.566
5. **Forman field on tetrahedron**: c₀ − c₁ + c₂ = 2 = χ

All experiments confirm the theorems to machine precision.

## 6. Discussion

### 6.1 Significance

Our framework provides the first machine-verified unification of discrete Gauss–Bonnet, discrete Poincaré–Hopf, and genus classification. The key insight is that the Euler characteristic serves simultaneously as:
- A combinatorial invariant (V − E + F)
- A geometric quantity (total curvature / 2π)
- A dynamical signature (alternating sum of critical cells)

### 6.2 Limitations

1. **No boundary case.** Our triangulated surfaces are closed. The Gauss–Bonnet theorem for surfaces with boundary includes a geodesic curvature term that we do not formalize.
2. **Abstract incidence.** Our TriangulatedSurface structure encodes the closure condition as 3|F| = 2|E| rather than through explicit edge-face incidence. This suffices for Gauss–Bonnet but limits our ability to state local topological properties.
3. **Genus definition.** We define genus from χ via g = (2−χ)/2, which is tautologically equivalent to χ = 2−2g. An independent definition through homology or the classification theorem would be more satisfying.
4. **Forman fields.** Our FormanField records only the counts of pairings, not the pairings themselves. This suffices for the index theorem but does not support gradient path analysis.

### 6.3 Comparison with Classical Theory

The discrete Gauss–Bonnet theorem is not merely an approximation to the smooth theorem. It is an exact result for piecewise-flat surfaces, first observed by Descartes in 1630 and rediscovered by Euler. The discrete and smooth theorems are related by approximation: as a triangulation of a smooth surface is refined, the angle-defect curvature converges to the Gaussian curvature times the area element. Our formalization does not prove this convergence, which would require the smooth theory, but it establishes the discrete theorem as a standalone result.

## 7. Future Work

1. **Surfaces with boundary.** Extend the Gauss–Bonnet theorem to surfaces with boundary edges, including the geodesic curvature boundary term.
2. **Higher dimensions.** Generalize to simplicial complexes of arbitrary dimension, with the Euler characteristic defined as the alternating sum of simplex counts.
3. **Explicit Forman fields.** Extend the FormanField structure to record actual cell pairings, enabling gradient path analysis and persistence homology.
4. **Convergence to smooth.** Prove that angle-defect curvature converges to Gaussian curvature as the mesh is refined.
5. **Regge calculus.** Formalize the connection to discrete general relativity.

## References

1. Banchoff, T. (1967). "Critical points and curvature for embedded polyhedra." *Journal of Differential Geometry*, 1(3-4), 245-256.
2. Desbrun, M., Kanso, E., & Tong, Y. (2008). "Discrete differential forms for computational modeling." In *Discrete Differential Geometry*, 287-324.
3. Euler, L. (1758). "Elementa doctrinae solidorum." *Novi Commentarii Academiae Scientiarum Petropolitanae*, 4, 109-140.
4. Forman, R. (1998). "Morse theory for cell complexes." *Advances in Mathematics*, 134(1), 90-145.
5. Gauss, C.F. (1828). *Disquisitiones generales circa superficies curvas.*
6. Poincaré, H. (1885). "Sur les courbes définies par les équations différentielles." *Journal de Mathématiques Pures et Appliquées*, 1, 167-244.
7. Regge, T. (1961). "General relativity without coordinates." *Il Nuovo Cimento*, 19(3), 558-571.
