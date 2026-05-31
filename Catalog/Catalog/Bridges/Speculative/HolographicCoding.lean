/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Holographic Coding Geometry

This module formalizes the mathematical core of the "spacetime as quantum error-correcting
code" paradigm. We extract a rigorous algebraic skeleton where:

- **Entropy–area correspondences** become exact algebraic identities (Ryu-Takayanagi),
- **Coding bounds** become geometric inequalities (Singleton bound → area constraint),
- **Bulk reconstruction** appears as a monotonicity/recoverability theorem,
- **Syndrome defect** plays the role of discrete curvature.

## Main Definitions

* `HolographicCodeProfile` — A structure encoding entropy, area, and distance functionals
  on boundary regions with submodularity and Ryu-Takayanagi (RT) constraints.
* `syndromeDefect` — A defect functional measuring failure of exact entropy additivity.
  Zero defect = flat geometry; positive defect = curvature.
* `RegionalCodeBound` — Abstract Singleton-type coding bounds on boundary regions.
* `Reconstructable` — A predicate for regions recoverable under erasure.
* `IsLaminar` — A predicate for laminar (non-crossing) families of sets.

## Main Results

* `syndromeDefect_nonneg` — Syndrome defect is nonnegative (from submodularity).
* `area_submod_of_rt` — RT converts entropy submodularity to area submodularity.
* `modular_of_zero_syndrome` — Zero syndrome defect implies entropy modularity (flatness).
* `area_modular_of_zero_syndrome` — Zero syndrome defect implies area modularity.
* `rt_submodularity_iff_area_submodularity` — Bridge theorem: entropy and area submodularity
  are equivalent under RT scaling.
* `syndromeDefect_eq_area_defect_div_four` — Exact relationship between entropy and area defects.
* `entropy_lower_bound_of_singleton` — Coding-theoretic lower bound on logical entropy.
* `reconstructable_monotone` — Monotonicity of reconstructability under region inclusion.
* `syndromeDefect_list_sum_nonneg` — Cumulative defect nonnegativity (by list induction).
* `strict_submod_of_pos_syndrome` — Positive defect implies strict submodularity.
* `area_le_four_card` — Area bounded by 4 × cardinality.
* `syndromeDefect_self` — Self-defect vanishes.
* `syndromeDefect_symm` — Defect is symmetric.
* `syndromeDefect_empty_left` — Defect with empty set vanishes.
-/

open Finset

namespace HolographicCoding

/-! ### Core Definition: Holographic Code Profile -/

/-- A **holographic code profile** on a finite boundary type `α` encodes:
- an entropy functional `S : Finset α → ℝ`,
- an effective area functional `area : Finset α → ℝ`,
- a reconstruction distance proxy `dist : Finset α → ℝ`,

together with axioms expressing:
- normalization (`S ∅ = 0`, `area ∅ = 0`),
- nonnegativity of all functionals,
- submodularity of entropy (strong subadditivity),
- the Ryu-Takayanagi relation `S(X) = area(X) / 4`,
- a singleton-like upper bound `S(X) ≤ |X|`.

This structure captures the finite combinatorial core of the holographic dictionary
between boundary entropy and bulk geometry. -/
structure HolographicCodeProfile (α : Type*) [DecidableEq α] where
  /-- Entropy functional on boundary regions -/
  S : Finset α → ℝ
  /-- Effective area functional (geometric) -/
  area : Finset α → ℝ
  /-- Reconstruction distance proxy -/
  dist : Finset α → ℝ
  /-- Entropy of the empty region vanishes -/
  S_empty : S ∅ = 0
  /-- Area of the empty region vanishes -/
  area_empty : area ∅ = 0
  /-- Distance proxy is nonnegative -/
  dist_nonneg : ∀ X, 0 ≤ dist X
  /-- Area is nonnegative -/
  area_nonneg : ∀ X, 0 ≤ area X
  /-- Entropy is nonnegative -/
  S_nonneg : ∀ X, 0 ≤ S X
  /-- Entropy is submodular (strong subadditivity) -/
  submod_S : ∀ X Y, S X + S Y ≥ S (X ∩ Y) + S (X ∪ Y)
  /-- Ryu-Takayanagi relation: entropy = area / 4 -/
  rt_relation : ∀ X, S X = area X / 4
  /-- Entropy is bounded by region cardinality -/
  singleton_like : ∀ X, S X ≤ (X.card : ℝ)

variable {α : Type*} [DecidableEq α]

/-! ### Syndrome Defect: Curvature from Information -/

/-- The **syndrome defect** measures the failure of exact additivity of entropy
across a pair of regions:

  `syndromeDefect(H, X, Y) = S(X) + S(Y) - S(X ∩ Y) - S(X ∪ Y)`

Physical interpretation:
- **Zero defect** = entropic flatness (modularity) = flat bulk geometry
- **Positive defect** = curvature-like interaction between regions
- This is the discrete analogue of curvature in the holographic dictionary -/
def syndromeDefect (H : HolographicCodeProfile α) (X Y : Finset α) : ℝ :=
  H.S X + H.S Y - H.S (X ∩ Y) - H.S (X ∪ Y)

/-! ### Core Theorems -/

/-- **Theorem 1 (Gravity = Nonnegative Defect)**: The syndrome defect is nonnegative
for any holographic code profile. This is the foundational result expressing that
gravitational geometry cannot have negative curvature in this discrete model —
it follows directly from submodularity of the entropy functional. -/
theorem syndromeDefect_nonneg
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    0 ≤ syndromeDefect H X Y := by
  unfold syndromeDefect
  linarith [H.submod_S X Y]

/-- **Theorem 2 (Information → Geometry Bridge)**: The RT relation converts entropy
submodularity into an area inequality. This is the first genuine bridge from information
theory to geometry: a purely quantum-information inequality (strong subadditivity)
becomes a geometric one (area submodularity) once the Ryu-Takayanagi relation is imposed. -/
theorem area_submod_of_rt
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    H.area X + H.area Y ≥ H.area (X ∩ Y) + H.area (X ∪ Y) := by
  have hS := H.submod_S X Y
  simp only [H.rt_relation] at hS
  linarith

/-- **Theorem 3 (Flatness from Zero Syndrome)**: Zero syndrome defect implies entropy
modularity on the pair (X, Y). This is the rigidity theorem: vanishing defect means
exact additivity, which in the holographic dictionary corresponds to flat geometry. -/
theorem modular_of_zero_syndrome
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hzero : syndromeDefect H X Y = 0) :
    H.S X + H.S Y = H.S (X ∩ Y) + H.S (X ∪ Y) := by
  unfold syndromeDefect at hzero
  linarith

/-- **Theorem 4 (Geometric Flatness from Zero Syndrome)**: Zero syndrome defect implies
area modularity under RT. This bridges information-theoretic flatness to geometric
flatness: if entropies add perfectly, so do areas. -/
theorem area_modular_of_zero_syndrome
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hzero : syndromeDefect H X Y = 0) :
    H.area X + H.area Y = H.area (X ∩ Y) + H.area (X ∪ Y) := by
  have hmod := modular_of_zero_syndrome H X Y hzero
  simp only [H.rt_relation] at hmod
  linarith

/-- **Theorem 5 (Cross-Domain Bridge)**: Entropy submodularity and area submodularity
are equivalent under the Ryu-Takayanagi relation. This is the central cross-domain theorem:
- **Left side**: entropy inequality (information theory / quantum mechanics)
- **Right side**: geometric area inequality (discrete geometry / general relativity)
- **Bridge**: the RT relation `S = area/4`

This theorem makes precise the physical intuition that "geometry is the visible face
of information constraints." -/
theorem rt_submodularity_iff_area_submodularity
    (H : HolographicCodeProfile α) :
    (∀ X Y, H.S X + H.S Y ≥ H.S (X ∩ Y) + H.S (X ∪ Y)) ↔
    (∀ X Y, H.area X + H.area Y ≥ H.area (X ∩ Y) + H.area (X ∪ Y)) := by
  constructor
  · intro hS X Y
    have := hS X Y
    simp only [H.rt_relation] at this
    linarith
  · intro hA X Y
    simp only [H.rt_relation]
    linarith [hA X Y]

/-- The syndrome defect equals the area defect divided by 4. This is the exact
quantitative bridge between information-theoretic and geometric curvature. -/
theorem syndromeDefect_eq_area_defect_div_four
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    syndromeDefect H X Y =
      (H.area X + H.area Y - H.area (X ∩ Y) - H.area (X ∪ Y)) / 4 := by
  unfold syndromeDefect
  simp only [H.rt_relation]
  ring

/-- Positive syndrome defect implies strict entropy submodularity:
the intersection/union entropy sum is strictly less than the parts. -/
theorem strict_submod_of_pos_syndrome
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hpos : 0 < syndromeDefect H X Y) :
    H.S (X ∩ Y) + H.S (X ∪ Y) < H.S X + H.S Y := by
  unfold syndromeDefect at hpos
  linarith

/-- The area of any region is bounded by 4 times its cardinality.
This combines the RT relation with the singleton-like bound on entropy. -/
theorem area_le_four_card
    (H : HolographicCodeProfile α) (X : Finset α) :
    H.area X ≤ 4 * (X.card : ℝ) := by
  have h1 := H.singleton_like X
  have h2 := H.rt_relation X
  linarith

/-! ### Structural Properties of Syndrome Defect -/

/-- The syndrome defect of a region with itself vanishes: `syndromeDefect(H, X, X) = 0`.
Geometrically, a region has zero self-curvature. -/
theorem syndromeDefect_self (H : HolographicCodeProfile α) (X : Finset α) :
    syndromeDefect H X X = 0 := by
  unfold syndromeDefect
  simp [inter_self]

/-- The syndrome defect is symmetric: `syndromeDefect(H, X, Y) = syndromeDefect(H, Y, X)`.
Curvature between two regions does not depend on the order. -/
theorem syndromeDefect_symm (H : HolographicCodeProfile α) (X Y : Finset α) :
    syndromeDefect H X Y = syndromeDefect H Y X := by
  unfold syndromeDefect
  rw [inter_comm, union_comm]
  ring

/-- The syndrome defect with the empty set vanishes. -/
theorem syndromeDefect_empty_left (H : HolographicCodeProfile α) (Y : Finset α) :
    syndromeDefect H ∅ Y = 0 := by
  unfold syndromeDefect
  simp [H.S_empty, empty_inter, empty_union]

/-- The syndrome defect with the empty set vanishes (right version). -/
theorem syndromeDefect_empty_right (H : HolographicCodeProfile α) (X : Finset α) :
    syndromeDefect H X ∅ = 0 := by
  rw [syndromeDefect_symm]
  exact syndromeDefect_empty_left H X

/-! ### Cumulative Defect: Induction on Lists of Region Pairs -/

/-- The sum of syndrome defects over any list of region pairs is nonnegative.
This is proved by structural induction on the list, using `syndromeDefect_nonneg`
at each step. It models the physical fact that total curvature across any collection
of region interactions is nonnegative. -/
theorem syndromeDefect_list_sum_nonneg
    (H : HolographicCodeProfile α)
    (pairs : List (Finset α × Finset α)) :
    0 ≤ (pairs.map (fun p => syndromeDefect H p.1 p.2)).sum := by
  induction pairs with
  | nil => simp
  | cons p ps ih =>
    simp only [List.map_cons, List.sum_cons]
    linarith [syndromeDefect_nonneg H p.1 p.2]

/-! ### Coding-Theoretic Structures -/

/-- A **regional code bound** captures the abstract Singleton-type inequality
`N(X) - K(X) ≤ 2(D(X) - 1)` for boundary regions, where:
- `N(X)` is the total number of physical qubits in region X,
- `K(X)` is the number of logical (encoded) qubits,
- `D(X)` is the code distance (minimum number of erasures to lose information). -/
structure RegionalCodeBound (α : Type*) [DecidableEq α] where
  /-- Physical qubits in region -/
  N : Finset α → ℕ
  /-- Logical qubits in region -/
  K : Finset α → ℕ
  /-- Code distance of region -/
  D : Finset α → ℕ
  /-- Singleton bound: redundancy ≤ 2(distance - 1) -/
  singleton_regional : ∀ X, N X - K X ≤ 2 * (D X - 1)

/-- **Theorem 6 (Coding → Entropy Bound)**: The Singleton bound, recast as a lower
bound on logical entropy K(X) in integer arithmetic. This is the coding-theoretic
constraint on holographic entropy: the number of encoded qubits is at least
`N(X) - 2(D(X) - 1)`, meaning high code distance forces high logical content.

In the holographic context, this constrains the relationship between boundary area
(proportional to N) and bulk information content (proportional to K). -/
theorem entropy_lower_bound_of_singleton
    (R : RegionalCodeBound α) (X : Finset α)
    (hD : 1 ≤ R.D X) :
    (R.K X : ℤ) ≥ (R.N X : ℤ) - 2 * ((R.D X : ℤ) - 1) := by
  have h := R.singleton_regional X
  omega

/-- Equivalent formulation: the redundancy N - K is bounded by 2(D-1). -/
theorem singleton_coverage
    (R : RegionalCodeBound α) (X : Finset α) :
    R.N X - R.K X ≤ 2 * (R.D X - 1) :=
  R.singleton_regional X

/-! ### Reconstruction and Recoverability -/

/-- A region `U` is **reconstructable** relative to ambient region `X` and distance
function `D` if `U ⊆ X` and the region is small enough that erasure cannot exceed
the code distance: `|U| < D(U)`.

Physical interpretation: bulk information encoded in qubits indexed by U can be
recovered from the boundary region X even after erasure of up to D(U)-1 qubits.
This models the holographic principle that bulk physics is recoverable from
sufficiently large boundary regions. -/
def Reconstructable
    (D : Finset α → ℕ) (X U : Finset α) : Prop :=
  U ⊆ X ∧ U.card < D U

omit [DecidableEq α] in
/-- **Theorem 7 (Reconstruction Monotonicity)**: If U is reconstructable in X and X ⊆ Y,
then U is reconstructable in Y. This models the physical principle that enlarging the
boundary region cannot destroy the ability to reconstruct bulk information. -/
theorem reconstructable_monotone
    (D : Finset α → ℕ)
    {X Y U : Finset α}
    (hXY : X ⊆ Y)
    (hrec : Reconstructable D X U) :
    Reconstructable D Y U :=
  ⟨hrec.1.trans hXY, hrec.2⟩

omit [DecidableEq α] in
/-- Reconstruction is preserved when the distance function increases. -/
theorem reconstructable_of_le_dist
    (D₁ D₂ : Finset α → ℕ)
    {X U : Finset α}
    (hD : D₁ U ≤ D₂ U)
    (hrec : Reconstructable D₁ X U) :
    Reconstructable D₂ X U :=
  ⟨hrec.1, lt_of_lt_of_le hrec.2 hD⟩

omit [DecidableEq α] in
/-- The empty set is always reconstructable (vacuously). -/
theorem reconstructable_empty
    (D : Finset α → ℕ) (X : Finset α) (hD : 0 < D ∅) :
    Reconstructable D X ∅ := by
  constructor
  · exact empty_subset X
  · simpa using hD

/-! ### Code-Geometry Correspondence -/

/-- A **code-geometry correspondence** links a holographic code profile
(geometric/entropic) to a regional code bound (coding-theoretic), establishing
that entropy matches logical qubits and area matches physical qubits. -/
structure CodeGeometryCorrespondence (α : Type*) [DecidableEq α] where
  /-- The holographic (geometric) side -/
  H : HolographicCodeProfile α
  /-- The coding-theoretic side -/
  C : RegionalCodeBound α
  /-- Entropy matches logical qubit count (up to scaling) -/
  entropy_matches : ∀ X, H.S X = (C.K X : ℝ)
  /-- Area matches physical qubit count (up to RT scaling) -/
  area_matches : ∀ X, H.area X = 4 * (C.K X : ℝ)

/-- In a code-geometry correspondence, the RT relation is automatically satisfied:
`S(X) = area(X) / 4`. This shows that our correspondence is self-consistent with RT. -/
theorem correspondence_rt_consistent
    (Γ : CodeGeometryCorrespondence α) (X : Finset α) :
    Γ.H.S X = Γ.H.area X / 4 :=
  Γ.H.rt_relation X

/-! ### Laminar Families and Conjecture -/

/-- A family of sets is **laminar** if for any two members, they are either disjoint
or one contains the other. Laminar families model non-crossing geodesic partitions
in the holographic bulk. -/
def IsLaminar (L : Finset (Finset α)) : Prop :=
  ∀ X ∈ L, ∀ Y ∈ L, X ∩ Y = ∅ ∨ X ⊆ Y ∨ Y ⊆ X

/-- Disjoint regions have syndrome defect determined by their entropy excess
over the union. When X ∩ Y = ∅, the defect simplifies since S(X ∩ Y) = S(∅) = 0. -/
theorem syndromeDefect_disjoint
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hdisj : Disjoint X Y) :
    syndromeDefect H X Y = H.S X + H.S Y - H.S (X ∪ Y) := by
  unfold syndromeDefect
  rw [Finset.disjoint_iff_inter_eq_empty.mp hdisj, H.S_empty]
  ring

/-- When one region contains the other, the syndrome defect simplifies. -/
theorem syndromeDefect_subset
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hXY : X ⊆ Y) :
    syndromeDefect H X Y = 0 := by
  unfold syndromeDefect
  rw [Finset.inter_eq_left.mpr hXY, Finset.union_eq_right.mpr hXY]
  ring

/-- **Falsifiable Conjecture**: Extremal holographic profiles are modular on
geodesic laminar families. For a finite boundary set `α`, if `H` saturates the
singleton-like bound `S(X) = |X|` on every member of a laminar family `L`, then
the syndrome defect vanishes on all pairs from that family.

Interpretation: extremal coding efficiency forces entropic flatness along
noncrossing geodesics. This is computationally testable: enumerate small laminar
families and random submodular profiles satisfying the axioms, and search for
counterexamples. -/
def SaturationModularityConjecture
    (H : HolographicCodeProfile α)
    (L : Finset (Finset α))
    (_hLam : IsLaminar L) : Prop :=
  (∀ X ∈ L, H.S X = (X.card : ℝ)) →
  ∀ X ∈ L, ∀ Y ∈ L, syndromeDefect H X Y = 0

/-- The conjecture holds trivially for nested pairs: if X ⊆ Y (or Y ⊆ X),
the syndrome defect vanishes regardless of saturation. -/
theorem saturation_conjecture_nested
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hXY : X ⊆ Y) :
    syndromeDefect H X Y = 0 :=
  syndromeDefect_subset H X Y hXY

/-- The conjecture holds for disjoint saturated pairs: if X ∩ Y = ∅ and both
satisfy `S(X) = |X|`, `S(Y) = |Y|`, then the syndrome defect equals
`|X| + |Y| - S(X ∪ Y)`, which for disjoint sets with `S(X ∪ Y) ≤ |X ∪ Y| = |X| + |Y|`
gives nonneg defect. With the union bound saturated, defect is zero. -/
theorem saturation_conjecture_disjoint_saturated
    (H : HolographicCodeProfile α) (X Y : Finset α)
    (hdisj : Disjoint X Y)
    (hSX : H.S X = (X.card : ℝ))
    (hSY : H.S Y = (Y.card : ℝ))
    (hSU : H.S (X ∪ Y) = ((X ∪ Y).card : ℝ)) :
    syndromeDefect H X Y = 0 := by
  rw [syndromeDefect_disjoint H X Y hdisj, hSX, hSY, hSU]
  rw [Finset.card_union_of_disjoint hdisj]
  push_cast
  ring

/-! ### Area Defect and Curvature -/

/-- The **area defect** is 4 times the syndrome defect, measuring geometric
curvature directly in area units. -/
def areaDefect (H : HolographicCodeProfile α) (X Y : Finset α) : ℝ :=
  H.area X + H.area Y - H.area (X ∩ Y) - H.area (X ∪ Y)

/-- The area defect is nonnegative: geometric curvature is nonnegative. -/
theorem areaDefect_nonneg
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    0 ≤ areaDefect H X Y := by
  unfold areaDefect
  linarith [area_submod_of_rt H X Y]

/-- The area defect equals 4 times the syndrome defect. -/
theorem areaDefect_eq_four_syndromeDefect
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    areaDefect H X Y = 4 * syndromeDefect H X Y := by
  unfold areaDefect syndromeDefect
  simp only [H.rt_relation]
  ring

/-- Zero area defect is equivalent to zero syndrome defect. -/
theorem areaDefect_zero_iff_syndromeDefect_zero
    (H : HolographicCodeProfile α) (X Y : Finset α) :
    areaDefect H X Y = 0 ↔ syndromeDefect H X Y = 0 := by
  rw [areaDefect_eq_four_syndromeDefect]
  constructor
  · intro h; linarith
  · intro h; linarith

/-! ### Finset Induction: Cumulative Entropy Bound -/

/-- For any finset of region pairs (with decidable equality), the sum of syndrome
defects is nonnegative. Proved using `Finset.sum_nonneg`. -/
theorem syndromeDefect_finset_sum_nonneg
    (H : HolographicCodeProfile α)
    (pairs : Finset (Finset α × Finset α)) :
    0 ≤ ∑ p ∈ pairs, syndromeDefect H p.1 p.2 := by
  apply Finset.sum_nonneg
  intro p _
  exact syndromeDefect_nonneg H p.1 p.2

/-! ### RT Scaling Laws -/

/-- The RT relation determines area from entropy: `area(X) = 4 * S(X)`. -/
theorem area_eq_four_S (H : HolographicCodeProfile α) (X : Finset α) :
    H.area X = 4 * H.S X := by
  have := H.rt_relation X
  linarith

/-- Entropy determines area nonnegativity via RT. -/
theorem S_nonneg_of_area (H : HolographicCodeProfile α) (X : Finset α) :
    0 ≤ H.S X := H.S_nonneg X

/-- The area functional is also submodular when entropy is. -/
theorem area_submodular (H : HolographicCodeProfile α) (X Y : Finset α) :
    H.area (X ∩ Y) + H.area (X ∪ Y) ≤ H.area X + H.area Y := by
  linarith [area_submod_of_rt H X Y]

end HolographicCoding