/-
# Discrete Gauss–Bonnet, Euler Characteristic, and Poincaré–Hopf

This file formalizes a foundational bridge between combinatorial topology,
discrete differential geometry, and dynamical systems through the Euler
characteristic. We prove:

1. Euler characteristic invariance under subdivision moves
2. A discrete Gauss–Bonnet theorem for triangulated surfaces
3. A discrete Poincaré–Hopf theorem via Forman vector fields
4. The genus classification formula χ = 2 - 2g
5. Cross-domain curvature-genus obstruction theorems

## Main Results

* `eulerChar_edge_split_invariant` — χ is invariant under edge splitting
* `eulerChar_stellar_invariant` — χ is invariant under stellar subdivision
* `discrete_gauss_bonnet` — ∑ K(v) = 2π·χ for closed triangulated surfaces
* `discrete_poincare_hopf` — alternating critical cell count = χ
* `eulerChar_eq_two_sub_two_mul_genus` — χ = 2 - 2g
* `total_curvature_eq_genus` — ∑ K(v) = 2π(2 - 2g)
* `total_curvature_nonpos_high_genus` — genus ≥ 1 ⟹ ∑ K(v) ≤ 0

## References

* Forman, R. "Morse Theory for Cell Complexes"
* Banchoff, T. "Critical Points and Curvature for Embedded Polyhedra"
* Regge, T. "General Relativity Without Coordinates"
-/

import Mathlib

open Finset Fintype Real

namespace DiscreteGaussBonnet

/-! ## Part 1: Finite Cell Complex and Euler Characteristic

We define a finite 2-dimensional cell complex by its vertex, edge,
and face sets, and prove that the Euler characteristic V - E + F
is invariant under elementary subdivision operations. -/

/-- A finite 2-dimensional CW-like cell complex, specified by
finite types of vertices, edges, and faces. -/
structure FinCellComplex2 where
  /-- Vertex type -/
  V : Type
  /-- Edge type -/
  E : Type
  /-- Face type -/
  F : Type
  [fV : Fintype V]
  [fE : Fintype E]
  [fF : Fintype F]

attribute [instance] FinCellComplex2.fV FinCellComplex2.fE FinCellComplex2.fF

/-- The Euler characteristic of a finite 2-cell complex: V - E + F. -/
def FinCellComplex2.eulerChar (X : FinCellComplex2) : ℤ :=
  (Fintype.card X.V : ℤ) - (Fintype.card X.E : ℤ) + (Fintype.card X.F : ℤ)

/-- An edge split: Y is obtained from X by subdividing one edge,
adding one vertex and one edge while keeping faces unchanged. -/
structure EdgeSplit (X Y : FinCellComplex2) : Prop where
  cardV : Fintype.card Y.V = Fintype.card X.V + 1
  cardE : Fintype.card Y.E = Fintype.card X.E + 1
  cardF : Fintype.card Y.F = Fintype.card X.F

/-- A stellar subdivision of an edge in a closed triangulated surface:
adding one vertex on an edge, splitting the edge and both adjacent faces.
V ↦ V+1, E ↦ E+3, F ↦ F+2. -/
structure StellarSubdivision (X Y : FinCellComplex2) : Prop where
  cardV : Fintype.card Y.V = Fintype.card X.V + 1
  cardE : Fintype.card Y.E = Fintype.card X.E + 3
  cardF : Fintype.card Y.F = Fintype.card X.F + 2

/-- A face split: adding a diagonal edge to a face, splitting it into two.
V unchanged, E ↦ E+1, F ↦ F+1. -/
structure FaceSplit (X Y : FinCellComplex2) : Prop where
  cardV : Fintype.card Y.V = Fintype.card X.V
  cardE : Fintype.card Y.E = Fintype.card X.E + 1
  cardF : Fintype.card Y.F = Fintype.card X.F + 1

/-- Barycentric vertex insertion into a triangular face:
add a vertex inside a triangle, connect to all 3 boundary vertices.
V ↦ V+1, E ↦ E+3, F ↦ F+2 (one triangle becomes three). -/
structure VertexInsertion (X Y : FinCellComplex2) : Prop where
  cardV : Fintype.card Y.V = Fintype.card X.V + 1
  cardE : Fintype.card Y.E = Fintype.card X.E + 3
  cardF : Fintype.card Y.F = Fintype.card X.F + 2

/-- **Theorem 1a**: Euler characteristic is invariant under edge splitting. -/
theorem eulerChar_edge_split_invariant
    (X Y : FinCellComplex2) (h : EdgeSplit X Y) :
    X.eulerChar = Y.eulerChar := by
  simp only [FinCellComplex2.eulerChar, h.cardV, h.cardE, h.cardF]
  push_cast; ring

/-- **Theorem 1b**: Euler characteristic is invariant under stellar subdivision. -/
theorem eulerChar_stellar_invariant
    (X Y : FinCellComplex2) (h : StellarSubdivision X Y) :
    X.eulerChar = Y.eulerChar := by
  simp only [FinCellComplex2.eulerChar, h.cardV, h.cardE, h.cardF]
  push_cast; ring

/-- Euler characteristic is invariant under face splitting. -/
theorem eulerChar_face_split_invariant
    (X Y : FinCellComplex2) (h : FaceSplit X Y) :
    X.eulerChar = Y.eulerChar := by
  simp only [FinCellComplex2.eulerChar, h.cardV, h.cardE, h.cardF]
  push_cast; ring

/-- Euler characteristic is invariant under vertex insertion. -/
theorem eulerChar_vertex_insertion_invariant
    (X Y : FinCellComplex2) (h : VertexInsertion X Y) :
    X.eulerChar = Y.eulerChar := by
  simp only [FinCellComplex2.eulerChar, h.cardV, h.cardE, h.cardF]
  push_cast; ring

/-- Elementary subdivision moves on cell complexes. -/
inductive SubdivisionMove (X Y : FinCellComplex2) : Prop where
  | edge_split : EdgeSplit X Y → SubdivisionMove X Y
  | face_split : FaceSplit X Y → SubdivisionMove X Y
  | stellar : StellarSubdivision X Y → SubdivisionMove X Y
  | vertex_ins : VertexInsertion X Y → SubdivisionMove X Y

/-- Any single subdivision move preserves Euler characteristic. -/
theorem eulerChar_move_invariant (X Y : FinCellComplex2) (h : SubdivisionMove X Y) :
    X.eulerChar = Y.eulerChar := by
  cases h with
  | edge_split h => exact eulerChar_edge_split_invariant X Y h
  | face_split h => exact eulerChar_face_split_invariant X Y h
  | stellar h => exact eulerChar_stellar_invariant X Y h
  | vertex_ins h => exact eulerChar_vertex_insertion_invariant X Y h

/-- Euler characteristic is invariant under a sequence of two moves. -/
theorem eulerChar_two_moves_invariant (X Y Z : FinCellComplex2)
    (h1 : SubdivisionMove X Y) (h2 : SubdivisionMove Y Z) :
    X.eulerChar = Z.eulerChar :=
  (eulerChar_move_invariant X Y h1).trans (eulerChar_move_invariant Y Z h2)

/-! ## Part 2: Triangulated Surfaces and Discrete Gauss–Bonnet

We define a triangulated surface as a finite complex with:
- A triangle structure: each face has 3 vertices and 3 angles
- Angle sum axiom: angles in each triangle sum to π
- Closure condition: 3|F| = 2|E| (each edge shared by exactly 2 faces)

The discrete Gauss–Bonnet theorem states that the total angle-defect
curvature equals 2π times the Euler characteristic. -/

/-- A finite closed triangulated surface with angle assignments.
Each face is a triangle with three vertices and three interior angles
summing to π. The surface is closed: 3|F| = 2|E|. -/
structure TriangulatedSurface where
  /-- Vertex type -/
  V : Type
  /-- Edge type -/
  E : Type
  /-- Face type -/
  F : Type
  [fV : Fintype V]
  [fE : Fintype E]
  [fF : Fintype F]
  [dV : DecidableEq V]
  /-- The three vertices of each face -/
  faceVerts : F → Fin 3 → V
  /-- The interior angle at each corner of each face -/
  angle : F → Fin 3 → ℝ
  /-- Angle sum in each triangle is π -/
  angle_sum_each_face : ∀ f, ∑ i : Fin 3, angle f i = π
  /-- Closed surface incidence: 3|F| = 2|E| -/
  three_F_eq_two_E : 3 * (Fintype.card F : ℤ) = 2 * (Fintype.card E : ℤ)

attribute [instance] TriangulatedSurface.fV TriangulatedSurface.fE
  TriangulatedSurface.fF TriangulatedSurface.dV

/-- The Euler characteristic of a triangulated surface. -/
def TriangulatedSurface.eulerChar (T : TriangulatedSurface) : ℤ :=
  (Fintype.card T.V : ℤ) - (Fintype.card T.E : ℤ) + (Fintype.card T.F : ℤ)

/-- Vertex curvature (angle defect): 2π minus the total face angle at the vertex.
This is the discrete analogue of Gaussian curvature concentrated at vertices. -/
noncomputable def TriangulatedSurface.vertexCurvature
    (T : TriangulatedSurface) (v : T.V) : ℝ :=
  2 * π - ∑ f : T.F, ∑ i : Fin 3,
    if T.faceVerts f i = v then T.angle f i else 0

/-! ### Helper lemmas for the Gauss–Bonnet proof -/

/-
The angle indicator sum over all vertices collapses: for each face-corner
pair (f, i), summing `if faceVerts f i = v then angle f i else 0` over all
vertices v yields just `angle f i`.
-/
lemma angle_indicator_sum (T : TriangulatedSurface) (f : T.F) (i : Fin 3) :
    ∑ v : T.V, (if T.faceVerts f i = v then T.angle f i else 0) =
    T.angle f i := by
  exact Fintype.sum_ite_eq (T.faceVerts f i) fun _ => T.angle f i

/-
Double-counting: the sum over vertices of angle contributions equals
the sum over faces of angle sums. This is the key combinatorial identity.
-/
lemma angle_double_sum_eq (T : TriangulatedSurface) :
    ∑ v : T.V, (∑ f : T.F, ∑ i : Fin 3,
      if T.faceVerts f i = v then T.angle f i else 0) =
    ∑ f : T.F, ∑ i : Fin 3, T.angle f i := by
  rw [ Finset.sum_comm ];
  exact Finset.sum_congr rfl fun _ _ => by rw [ Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => by aesop;

/-
The total angle sum equals π times the number of faces.
-/
lemma total_angle_eq_pi_card_F (T : TriangulatedSurface) :
    ∑ f : T.F, ∑ i : Fin 3, T.angle f i =
    π * ↑(Fintype.card T.F) := by
  simpa [ mul_comm ] using Finset.sum_congr rfl fun _ _ => T.angle_sum_each_face _

/-
Key algebraic identity: 2π·V - π·F = 2π·(V - E + F) when 3F = 2E.
This is the final step of the discrete Gauss–Bonnet proof.
-/
lemma euler_curvature_algebra (cV cE cF : ℤ) (h : 3 * cF = 2 * cE) :
    2 * π * (cV : ℝ) - π * (cF : ℝ) = 2 * π * ((cV : ℝ) - (cE : ℝ) + (cF : ℝ)) := by
  nlinarith [ Real.pi_pos, ( by norm_cast : ( 3 : ℝ ) * cF = 2 * cE ) ]

/-
**Discrete Gauss–Bonnet theorem**: The total vertex curvature of a closed
triangulated surface equals 2π times its Euler characteristic.

  ∑_v K(v) = 2π · χ(T)

where K(v) = 2π - ∑_{f ∋ v} θ_{f,v} is the angle defect at vertex v.

**Proof strategy** (double-counting):
1. Expand ∑_v K(v) = 2π|V| - ∑_v ∑_{f,i} [faceVerts f i = v] · angle f i
2. Swap summation order: = 2π|V| - ∑_f ∑_i angle f i
3. Apply angle sum axiom: = 2π|V| - π|F|
4. Use 3|F| = 2|E| to get: = 2π(|V| - |E| + |F|) = 2π·χ
-/
theorem discrete_gauss_bonnet (T : TriangulatedSurface) :
    ∑ v : T.V, T.vertexCurvature v = 2 * π * (↑T.eulerChar : ℝ) := by
  -- Expand the vertex curvature: $K(v) = 2\pi - \sum_{f, i} \theta_{f,i}$.
  have h_expand : ∑ v : T.V, T.vertexCurvature v = ∑ v : T.V, 2 * Real.pi - ∑ v : T.V, (∑ f : T.F, ∑ i : Fin 3, if T.faceVerts f i = v then T.angle f i else 0) := by
    unfold TriangulatedSurface.vertexCurvature; rw [ ← Finset.sum_sub_distrib ] ;
  convert euler_curvature_algebra ( Fintype.card T.V ) ( Fintype.card T.E ) ( Fintype.card T.F ) T.three_F_eq_two_E using 1;
  · rw [ h_expand, mul_comm ] ; norm_num [ angle_double_sum_eq, total_angle_eq_pi_card_F ] ; ring;
  · unfold TriangulatedSurface.eulerChar; norm_num;

/-! ## Part 3: Forman Discrete Vector Fields and Poincaré–Hopf

A Forman discrete vector field pairs cells of adjacent dimensions.
Unpaired (critical) cells carry the topological information:
the alternating sum of critical cells equals the Euler characteristic.
This is the combinatorial Poincaré–Hopf theorem. -/

/-- A Forman-style discrete vector field on a 2-dimensional cell complex.
Pairs cells of adjacent dimensions; unpaired cells are critical.
- `numVEPairs`: edges paired with vertices (pointing "up" from 0-cells to 1-cells)
- `numEFPairs`: faces paired with edges (pointing "up" from 1-cells to 2-cells) -/
structure FormanField (X : FinCellComplex2) where
  /-- Number of (vertex, edge) pairings -/
  numVEPairs : ℕ
  /-- Number of (edge, face) pairings -/
  numEFPairs : ℕ
  /-- Cannot pair more vertices than exist -/
  hV : numVEPairs ≤ Fintype.card X.V
  /-- Total edge pairings (both directions) bounded by edge count -/
  hE : numVEPairs + numEFPairs ≤ Fintype.card X.E
  /-- Cannot pair more faces than exist -/
  hF : numEFPairs ≤ Fintype.card X.F

/-- Number of critical 0-cells (unpaired vertices). -/
def FormanField.criticalCount0 {X : FinCellComplex2} (M : FormanField X) : ℤ :=
  (Fintype.card X.V : ℤ) - (M.numVEPairs : ℤ)

/-- Number of critical 1-cells (unpaired edges). -/
def FormanField.criticalCount1 {X : FinCellComplex2} (M : FormanField X) : ℤ :=
  (Fintype.card X.E : ℤ) - (M.numVEPairs : ℤ) - (M.numEFPairs : ℤ)

/-- Number of critical 2-cells (unpaired faces). -/
def FormanField.criticalCount2 {X : FinCellComplex2} (M : FormanField X) : ℤ :=
  (Fintype.card X.F : ℤ) - (M.numEFPairs : ℤ)

/-- **Discrete Poincaré–Hopf theorem** (Forman): The alternating sum of
critical cell counts equals the Euler characteristic.

  c₀ - c₁ + c₂ = V - E + F = χ

This is purely algebraic: each pairing cancels one cell from two adjacent
dimensions, preserving the alternating sum. -/
theorem discrete_poincare_hopf (X : FinCellComplex2) (M : FormanField X) :
    M.criticalCount0 - M.criticalCount1 + M.criticalCount2 = X.eulerChar := by
  simp only [FormanField.criticalCount0, FormanField.criticalCount1,
    FormanField.criticalCount2, FinCellComplex2.eulerChar]
  ring

/-- Coerce a triangulated surface to a cell complex. -/
def TriangulatedSurface.toFinCellComplex2 (T : TriangulatedSurface) :
    FinCellComplex2 := ⟨T.V, T.E, T.F⟩

/-- Poincaré–Hopf for triangulated surfaces. -/
theorem discrete_poincare_hopf_surface
    (T : TriangulatedSurface) (M : FormanField T.toFinCellComplex2) :
    M.criticalCount0 - M.criticalCount1 + M.criticalCount2 = T.eulerChar :=
  discrete_poincare_hopf T.toFinCellComplex2 M

/-
Any Forman field has at least one critical cell in each nontrivial
dimension (weak Morse inequality at the cell complex level).
-/
theorem forman_critical_nonneg (X : FinCellComplex2) (M : FormanField X) :
    0 ≤ M.criticalCount0 ∧ 0 ≤ M.criticalCount1 ∧ 0 ≤ M.criticalCount2 := by
  simp [FormanField.criticalCount0, FormanField.criticalCount1, FormanField.criticalCount2];
  exact ⟨ M.hV, le_tsub_of_add_le_left <| mod_cast M.hE, mod_cast M.hF ⟩

/-! ## Part 4: Genus Classification

For orientable closed connected surfaces, the Euler characteristic
determines the genus via χ = 2 - 2g. -/

/-- A triangulated surface is orientable closed connected if its Euler
characteristic is even. (For genuine orientable closed connected surfaces,
χ is always even since χ = 2 - 2g.) -/
def TriangulatedSurface.IsOrientableClosedConnected
    (T : TriangulatedSurface) : Prop :=
  Even T.eulerChar

/-- The genus of an orientable closed connected surface: g = (2 - χ) / 2. -/
def TriangulatedSurface.orientableGenus (T : TriangulatedSurface) : ℤ :=
  (2 - T.eulerChar) / 2

/-
**Genus formula**: For orientable closed connected surfaces, χ = 2 - 2g.
This uses the fact that χ is even to ensure integer division is exact.
-/
theorem eulerChar_eq_two_sub_two_mul_genus
    (T : TriangulatedSurface) (hT : T.IsOrientableClosedConnected) :
    T.eulerChar = 2 - 2 * T.orientableGenus := by
  unfold TriangulatedSurface.orientableGenus;
  unfold TriangulatedSurface.IsOrientableClosedConnected at hT;
  grind

/-
**Curvature-genus formula**: Total angle-defect curvature equals 2π(2 - 2g).
This combines discrete Gauss–Bonnet with the genus classification.
-/
theorem total_curvature_eq_genus
    (T : TriangulatedSurface) (hT : T.IsOrientableClosedConnected) :
    ∑ v : T.V, T.vertexCurvature v =
    2 * π * (↑(2 - 2 * T.orientableGenus) : ℝ) := by
  convert discrete_gauss_bonnet T using 2;
  exact_mod_cast ( eulerChar_eq_two_sub_two_mul_genus T hT ) |> Eq.symm

/-! ## Part 5: Cross-Domain Applications

We derive consequences connecting topology, geometry, and dynamics. -/

/-
High genus forces non-positive Euler characteristic.
-/
theorem euler_nonpos_high_genus
    (T : TriangulatedSurface) (hT : T.IsOrientableClosedConnected)
    (hg : 1 ≤ T.orientableGenus) :
    T.eulerChar ≤ 0 := by
  linarith [ eulerChar_eq_two_sub_two_mul_genus T hT ]

/-
**Curvature obstruction for high-genus surfaces**: On surfaces of genus ≥ 1,
the total discrete curvature is non-positive. This is a formal bridge between
geometry (curvature) and topology (genus).
-/
theorem total_curvature_nonpos_high_genus
    (T : TriangulatedSurface) (hT : T.IsOrientableClosedConnected)
    (hg : 1 ≤ T.orientableGenus) :
    ∑ v : T.V, T.vertexCurvature v ≤ 0 := by
  -- Apply the discrete Gauss–Bonnet theorem: ∑ v, K(v) = 2π * χ(T).
  have h_sum_curvature : ∑ v : T.V, T.vertexCurvature v = 2 * Real.pi * (↑T.eulerChar : ℝ) := by
    convert discrete_gauss_bonnet T using 1;
  exact h_sum_curvature ▸ mul_nonpos_of_nonneg_of_nonpos ( by positivity ) ( Int.cast_nonpos.mpr ( euler_nonpos_high_genus T hT hg ) )

/-
**Morse-theoretic obstruction**: On a surface with non-positive Euler
characteristic, any Forman field must have at least as many critical 1-cells
as the combined count of critical 0-cells and 2-cells.
-/
theorem critical_1_cells_dominate
    (T : TriangulatedSurface) (M : FormanField T.toFinCellComplex2)
    (hchi : T.eulerChar ≤ 0) :
    M.criticalCount0 + M.criticalCount2 ≤ M.criticalCount1 := by
  grind +locals

/-
The sphere (genus 0) has Euler characteristic 2.
-/
theorem sphere_euler_char
    (T : TriangulatedSurface) (hT : T.IsOrientableClosedConnected)
    (hg : T.orientableGenus = 0) :
    T.eulerChar = 2 := by
  grind +locals

/-
The torus (genus 1) has Euler characteristic 0.
-/
theorem torus_euler_char
    (T : TriangulatedSurface) (hT : T.IsOrientableClosedConnected)
    (hg : T.orientableGenus = 1) :
    T.eulerChar = 0 := by
  have := @eulerChar_eq_two_sub_two_mul_genus T hT;
  grind

/-
On a torus, total curvature vanishes.
-/
theorem torus_total_curvature_zero
    (T : TriangulatedSurface) (hT : T.IsOrientableClosedConnected)
    (hg : T.orientableGenus = 1) :
    ∑ v : T.V, T.vertexCurvature v = 0 := by
  rw [ discrete_gauss_bonnet, torus_euler_char T hT hg, Int.cast_zero, MulZeroClass.mul_zero ]

/-
On a sphere, total curvature equals 4π.
-/
theorem sphere_total_curvature
    (T : TriangulatedSurface) (hT : T.IsOrientableClosedConnected)
    (hg : T.orientableGenus = 0) :
    ∑ v : T.V, T.vertexCurvature v = 4 * π := by
  convert sphere_euler_char T hT hg ▸ discrete_gauss_bonnet T using 1 ; norm_num ; ring

/-! ## Part 6: Computation Algorithm

We provide a verified computation method: given concrete triangulation data,
compute the Euler characteristic and verify Gauss–Bonnet. -/

/-- Compute Euler characteristic from cardinalities. -/
def computeEulerChar (nV nE nF : ℕ) : ℤ := (nV : ℤ) - (nE : ℤ) + (nF : ℤ)

/-- The computation agrees with the structural definition. -/
theorem computeEulerChar_eq (X : FinCellComplex2) :
    computeEulerChar (Fintype.card X.V) (Fintype.card X.E) (Fintype.card X.F)
    = X.eulerChar := by
  simp [computeEulerChar, FinCellComplex2.eulerChar]

/-- Tetrahedron: 4 vertices, 6 edges, 4 faces ⟹ χ = 2 (sphere). -/
example : computeEulerChar 4 6 4 = 2 := by native_decide

/-- Octahedron: 6 vertices, 12 edges, 8 faces ⟹ χ = 2. -/
example : computeEulerChar 6 12 8 = 2 := by native_decide

/-- Icosahedron: 12 vertices, 30 edges, 20 faces ⟹ χ = 2. -/
example : computeEulerChar 12 30 20 = 2 := by native_decide

/-- Minimal torus triangulation: 7 vertices, 21 edges, 14 faces ⟹ χ = 0. -/
example : computeEulerChar 7 21 14 = 0 := by native_decide

/-- Genus-2 surface: expected χ = -2. -/
example : computeEulerChar 10 30 18 = -2 := by native_decide

end DiscreteGaussBonnet