import Mathlib

/-!
# Homological quantum codes: distance, systoles, and a genus-only obstruction

This file isolates the finite algebraic core of a homological CSS code.  A code
is a three-term chain complex over `𝔽₂`; logical `Z` operators are cycles outside
the boundary subspace.  Their Hamming weights form both the operational distance
spectrum and the combinatorial systolic spectrum.

The positive result is exact: whenever first homology is nonzero, the minimum is
attained, is positive, and code distance equals homological systole.

The contrarian result concerns the frequently over-strong slogan that genus alone
forces square-root distance.  An abstract first-homology space does not remember
a metric or cellulation.  We exhibit weight models on the same `2g`-dimensional
binary homology having any prescribed positive distance.  Thus neither an upper
nor a lower genus-only distance bound can follow from homology rank alone.
-/

namespace TopologicalQEC

abbrev F₂ := ZMod 2

/-- A finite binary cellular chain complex `C₂ → C₁ → C₀`. -/
structure CellularCode where
  n₀ : ℕ
  n₁ : ℕ
  n₂ : ℕ
  d₁ : (Fin n₁ → F₂) →ₗ[F₂] (Fin n₀ → F₂)
  d₂ : (Fin n₂ → F₂) →ₗ[F₂] (Fin n₁ → F₂)
  chain_condition : d₁.comp d₂ = 0

namespace CellularCode

variable (C : CellularCode)

/-- Cellular one-cycles. -/
def cycles : Submodule F₂ (Fin C.n₁ → F₂) := LinearMap.ker C.d₁

/-- Cellular one-boundaries. -/
def boundaries : Submodule F₂ (Fin C.n₁ → F₂) := LinearMap.range C.d₂

/-
Every boundary is a cycle.
-/
theorem boundaries_le_cycles : C.boundaries ≤ C.cycles := by
  exact fun x hx => by rcases hx with ⟨ y, rfl ⟩ ; exact LinearMap.mem_ker.2 ( by simpa using DFunLike.congr_fun C.chain_condition y ) ;

/-- The Hamming weights of representatives of nonzero first-homology classes. -/
def logicalWeights : Set ℕ :=
  {w | ∃ z : Fin C.n₁ → F₂,
    z ∈ C.cycles ∧ z ∉ C.boundaries ∧ hammingNorm z = w}

/-- Operational code distance: minimum weight of an undetectable, non-stabilizer
`Z` error. -/
noncomputable def distance : ℕ := sInf C.logicalWeights

/-- Length spectrum of noncontractible cellular loops.  This is deliberately
presented independently from `logicalWeights`, making the coding/topology bridge
an extensional theorem rather than a definitional equality. -/
def systolicLengths : Set ℕ :=
  {ℓ | ∃ loop : Fin C.n₁ → F₂,
    C.d₁ loop = 0 ∧ (¬ ∃ face, C.d₂ face = loop) ∧ hammingNorm loop = ℓ}

/-- Combinatorial one-systole of the cellulation. -/
noncomputable def systole : ℕ := sInf C.systolicLengths

/-
The operational and topological spectra coincide.
-/
theorem logicalWeights_eq_systolicLengths :
    C.logicalWeights = C.systolicLengths := by
  grind

/-
**Distance equals systole** for every finite binary cellular code.
-/
theorem distance_eq_systole : C.distance = C.systole := by
  unfold CellularCode.distance CellularCode.systole;
  grind

/-
A nontrivial homology class cannot have weight zero.
-/
theorem logical_weight_positive {z : Fin C.n₁ → F₂}
    (hz : z ∉ C.boundaries) : 0 < hammingNorm z := by
  contrapose! hz; simp_all +decide [ hammingNorm_eq_zero ] ;

/-
If `H₁` is nonzero, a shortest logical operator actually exists.
-/
theorem distance_attained
    (hne : ∃ z : Fin C.n₁ → F₂, z ∈ C.cycles ∧ z ∉ C.boundaries) :
    ∃ z : Fin C.n₁ → F₂,
      z ∈ C.cycles ∧ z ∉ C.boundaries ∧ hammingNorm z = C.distance := by
  obtain ⟨ z, hz₁, hz₂ ⟩ := hne;
  obtain ⟨ z, hz₁, hz₂ ⟩ := Nat.sInf_mem ( show C.logicalWeights.Nonempty from ⟨ _, ⟨ z, hz₁, hz₂, rfl ⟩ ⟩ ) ; use z; aesop;

/-
Exact minimum characterization of distance.
-/
theorem distance_characterization
    (hne : ∃ z : Fin C.n₁ → F₂, z ∈ C.cycles ∧ z ∉ C.boundaries) :
    0 < C.distance ∧
    (∃ z : Fin C.n₁ → F₂,
      z ∈ C.cycles ∧ z ∉ C.boundaries ∧ hammingNorm z = C.distance) ∧
    (∀ z : Fin C.n₁ → F₂,
      z ∈ C.cycles → z ∉ C.boundaries → C.distance ≤ hammingNorm z) := by
  obtain ⟨ z, hz₁, hz₂ ⟩ := hne;
  obtain ⟨ z, hz₁, hz₂, hz₃ ⟩ := distance_attained C ⟨ z, hz₁, hz₂ ⟩;
  exact ⟨ hz₃ ▸ logical_weight_positive _ hz₂, ⟨ z, hz₁, hz₂, hz₃ ⟩, fun z hz₁ hz₂ => Nat.sInf_le ⟨ z, hz₁, hz₂, rfl ⟩ ⟩

/-- First Betti number, computed as `dim ker d₁ - dim im d₂`. -/
noncomputable def homologyRank : ℕ :=
  Module.finrank F₂ C.cycles - Module.finrank F₂ C.boundaries

/-- Minimal cellular chain complex of the closed orientable genus-`g` surface:
one vertex, `2g` loop edges, and one face.  Over `𝔽₂` both cellular boundary
maps vanish. -/
def surfaceComplex (g : ℕ) : CellularCode where
  n₀ := 1
  n₁ := 2 * g
  n₂ := 1
  d₁ := 0
  d₂ := 0
  chain_condition := by simp

/-
The first binary homology of the genus-`g` surface has rank `2g`.
-/
theorem surface_homology_rank (g : ℕ) :
    (surfaceComplex g).homologyRank = 2 * g := by
  unfold CellularCode.homologyRank;
  unfold CellularCode.cycles CellularCode.boundaries;
  erw [ LinearMap.ker_zero, LinearMap.range_zero ] ; norm_num;
  rfl

/-
In particular, the torus surface code is supported by a rank-two first
homology space.
-/
theorem torus_homology_rank :
    (surfaceComplex 1).homologyRank = 2 := by
  convert surface_homology_rank 1 using 1

end CellularCode

/-! ## What homology rank alone cannot predict

A metric on first homology is additional structure.  The following finite model
retains the binary vector space of logical classes and the two indispensable
weight axioms, while intentionally forgetting a cellulation.  It is therefore
the right setting for testing claims asserted to follow from homology alone.
-/

/-- A binary homology space equipped with a logical-operator weight. -/
structure WeightedHomology where
  rank : ℕ
  weight : (Fin rank → F₂) → ℕ
  weight_zero : weight 0 = 0
  weight_pos : ∀ x, x ≠ 0 → 0 < weight x

namespace WeightedHomology

/-- The nonzero logical weight spectrum. -/
def spectrum (H : WeightedHomology) : Set ℕ :=
  {w | ∃ x : Fin H.rank → F₂, x ≠ 0 ∧ H.weight x = w}

/-- Minimum nonzero logical weight. -/
noncomputable def distance (H : WeightedHomology) : ℕ := sInf H.spectrum

/-- Put the same positive weight `d` on every nonzero homology class. -/
def uniform (rank d : ℕ) (hd : 0 < d) : WeightedHomology where
  rank := rank
  weight := fun x => if x = 0 then 0 else d
  weight_zero := by simp
  weight_pos := by
    intro x hx
    simp [hx, hd]

/-
A uniform nonzero weight is exactly the code distance when homology is
nonzero.
-/
theorem uniform_distance {rank d : ℕ} (hrank : 0 < rank) (hd : 0 < d) :
    (uniform rank d hd).distance = d := by
  refine' le_antisymm ( csInf_le _ _ ) ( le_csInf _ _ );
  · exact ⟨ 0, fun x hx => Nat.zero_le _ ⟩;
  · exact ⟨ fun _ => 1, fun h => by simpa using congr_fun h ⟨ 0, hrank ⟩, if_neg fun h => by simpa using congr_fun h ⟨ 0, hrank ⟩ ⟩;
  · exact ⟨ _, ⟨ fun _ => 1, fun h => by simpa using congr_fun h ⟨ 0, hrank ⟩, rfl ⟩ ⟩;
  · rintro _ ⟨ x, hx, rfl ⟩ ; unfold WeightedHomology.uniform at *; aesop;

/-- The minimal CW model of a genus-`g` surface, with ordinary coordinate
Hamming weight on `H₁ ≅ 𝔽₂^(2g)`. -/
def minimalSurface (g : ℕ) : WeightedHomology where
  rank := 2 * g
  weight := hammingNorm
  weight_zero := hammingNorm_zero
  weight_pos := fun _ hx => hammingNorm_pos_iff.mpr hx

/-
The minimal genus model has distance one whenever `g > 0`.
-/
theorem minimalSurface_distance {g : ℕ} (hg : 0 < g) :
    (minimalSurface g).distance = 1 := by
  refine' le_antisymm _ _;
  · refine' csInf_le _ _ <;> norm_num [ minimalSurface ];
    refine' ⟨ fun i => if i = ⟨ 0, by linarith ⟩ then 1 else 0, _, _ ⟩ <;> simp +decide [ hammingNorm ];
    · exact fun h => by simpa using congr_fun h ⟨ 0, by linarith ⟩ ;
    · exact Finset.card_eq_one.mpr ⟨ ⟨ 0, by linarith ⟩, by aesop ⟩;
  · refine' le_csInf _ _ <;> norm_num [ minimalSurface ];
    · exact ⟨ _, ⟨ fun _ => 1, fun h => by simpa using congr_fun h ⟨ 0, by linarith ⟩, rfl ⟩ ⟩;
    · rintro _ ⟨ x, hx, rfl ⟩ ; exact hammingNorm_pos_iff.mpr hx;

/-
**Disproof of genus-only upper bounds.**  For every proposed bound `B` and
every positive genus, the same `2g`-dimensional homology supports a valid weight
model of distance strictly greater than `B`.
-/
theorem no_genus_only_upper_bound (g B : ℕ) (hg : 0 < g) :
    ∃ H : WeightedHomology, H.rank = 2 * g ∧ B < H.distance := by
  refine' ⟨ _, _, _ ⟩;
  exact WeightedHomology.uniform ( 2 * g ) ( B + 1 ) ( Nat.succ_pos _ );
  · rfl;
  · rw [ uniform_distance ] <;> linarith

/-
**Disproof of genus-forced growth.**  Arbitrarily large positive genus still
admits distance one; in particular, genus alone gives no growing lower bound.
-/
theorem no_genus_forced_distance (g : ℕ) (hg : 0 < g) :
    ∃ H : WeightedHomology, H.rank = 2 * g ∧ H.distance = 1 := by
  exact ⟨ minimalSurface g, rfl, minimalSurface_distance hg ⟩

/-
Same first-homology rank, different distances.  Hence distance is not an
invariant of the abstract homology group; the cellulation/metric is essential.
-/
theorem distance_not_determined_by_homology_rank (g : ℕ) (hg : 0 < g) (d : ℕ)
    (hd : 1 < d) :
    ∃ H₁ H₂ : WeightedHomology,
      H₁.rank = 2 * g ∧ H₂.rank = 2 * g ∧
      H₁.distance = 1 ∧ H₂.distance = d := by
  refine' ⟨ minimalSurface g, WeightedHomology.uniform ( 2 * g ) d ( by linarith ), rfl, rfl, _, _ ⟩;
  · convert minimalSurface_distance hg using 1;
  · exact WeightedHomology.uniform_distance ( by linarith ) ( by linarith )

end WeightedHomology

end TopologicalQEC