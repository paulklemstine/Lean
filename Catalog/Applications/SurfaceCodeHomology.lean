import Mathlib

/-!
# Topological Quantum Codes from Cellular Homology

This file develops the homological theory of Calderbank–Shor–Steane (CSS) quantum
error-correcting codes over the binary field `𝔽₂ = ZMod 2`.

A CSS code is packaged as a length-three chain complex

  `C₂ --∂₂--> C₁ --∂₁--> C₀`

of finite-dimensional `𝔽₂`-vector spaces satisfying `∂₁ ∘ ∂₂ = 0`.  The physical
qubits live on the middle space `C₁`; the `Z`-type stabilizers are the rows of
`∂₁` and the `X`-type stabilizers are the rows of `∂₂ᵀ`.  The number of encoded
*logical* qubits equals the dimension of the first homology group

  `H₁ = ker ∂₁ / im ∂₂`,

which is the *first Betti number* of the underlying cellular space.  This realises
the slogan "logical qubits = homology" for surface and color codes.

## Main results

* `CSSCode.logical_dimension_formula` : the CSS dimension identity
  `k + rank ∂₁ + rank ∂₂ = n`, i.e. the number of logical qubits equals the number
  of physical qubits minus the ranks of the two stabilizer matrices.
* `CSSCode.hasLogical_iff_homology_nontrivial` : the code stores information
  (`k ≥ 1`) exactly when the first homology group is nontrivial (`im ∂₂ < ker ∂₁`).
* `surfaceComplex` and `surface_logical_qubits` : the minimal cellular chain
  complex of a closed orientable genus-`g` surface has `H₁` of dimension `2g`,
  reproducing the fact that the genus-`g` surface code encodes `2g` logical qubits.
* `surface_euler_characteristic` : the alternating sum of Betti numbers of the
  genus-`g` surface equals `2 - 2g`.

-/

namespace TQEC

/-- The binary field on which all quantum codes in this file are built. -/
abbrev F2 := ZMod 2

open Module

/-- A binary CSS quantum code, presented as a length-three chain complex
`(Fin n2 → 𝔽₂) --d2--> (Fin n1 → 𝔽₂) --d1--> (Fin n0 → 𝔽₂)` with `d1 ∘ d2 = 0`.
The `n1` coordinates of the middle space are the physical qubits. -/
structure CSSCode where
  /-- number of `Z`-checks (vertices / `0`-cells). -/
  n0 : ℕ
  /-- number of physical qubits (edges / `1`-cells). -/
  n1 : ℕ
  /-- number of `X`-checks (faces / `2`-cells). -/
  n2 : ℕ
  /-- the boundary map `∂₁` whose rows are the `Z`-stabilizers. -/
  d1 : (Fin n1 → F2) →ₗ[F2] (Fin n0 → F2)
  /-- the coboundary map `∂₂` whose columns are the `X`-stabilizers. -/
  d2 : (Fin n2 → F2) →ₗ[F2] (Fin n1 → F2)
  /-- the defining chain-complex condition `∂₁ ∘ ∂₂ = 0`. -/
  boundary : d1.comp d2 = 0

namespace CSSCode

variable (Q : CSSCode)

/-- The space of `Z`-cycles, `ker ∂₁`. -/
def cycles : Submodule F2 (Fin Q.n1 → F2) := LinearMap.ker Q.d1

/-- The space of `Z`-boundaries, `im ∂₂`. -/
def boundaries : Submodule F2 (Fin Q.n1 → F2) := LinearMap.range Q.d2

/-
Boundaries are cycles: `im ∂₂ ⊆ ker ∂₁`.
-/
theorem boundaries_le_cycles : Q.boundaries ≤ Q.cycles := by
  exact LinearMap.range_le_ker_iff.mpr Q.boundary

/-- The number of logical qubits, `k = dim H₁ = dim(ker ∂₁) - dim(im ∂₂)`. -/
noncomputable def logicalQubits : ℕ := finrank F2 Q.cycles - finrank F2 Q.boundaries

/-- The rank of the `Z`-stabilizer matrix `∂₁`. -/
noncomputable def rankZ : ℕ := finrank F2 (LinearMap.range Q.d1)

/-- The rank of the `X`-stabilizer matrix `∂₂`. -/
noncomputable def rankX : ℕ := finrank F2 Q.boundaries

/-
**CSS dimension formula.**  The number of logical qubits plus the two
stabilizer ranks equals the number of physical qubits:
`k + rank ∂₁ + rank ∂₂ = n`.
-/
theorem logical_dimension_formula :
    Q.logicalQubits + Q.rankZ + Q.rankX = Q.n1 := by
      unfold CSSCode.logicalQubits CSSCode.rankZ CSSCode.rankX CSSCode.cycles CSSCode.boundaries;
      rw [ tsub_add_eq_add_tsub, tsub_add_cancel_of_le ];
      · rw [ add_comm, LinearMap.finrank_range_add_finrank_ker ];
        norm_num;
      · refine' le_add_right _;
        refine' Submodule.finrank_mono _;
        exact fun x hx => by rcases hx with ⟨ y, rfl ⟩ ; exact LinearMap.congr_fun Q.boundary y;
      · exact Submodule.finrank_mono <| Q.boundaries_le_cycles

/-- The number of logical qubits equals the first Betti number `dim H₁`. -/
theorem logicalQubits_eq :
    Q.logicalQubits = finrank F2 Q.cycles - finrank F2 Q.boundaries := rfl

/-
**Homological information criterion.**  A CSS code encodes at least one
logical qubit iff its first homology group is nontrivial, i.e. iff there is a
`Z`-cycle that is not a `Z`-boundary.
-/
theorem hasLogical_iff_homology_nontrivial :
    1 ≤ Q.logicalQubits ↔ Q.boundaries < Q.cycles := by
      rw [ @lt_iff_le_and_ne ];
      constructor <;> intro h;
      · refine' ⟨ boundaries_le_cycles _, fun h' => _ ⟩;
        unfold CSSCode.logicalQubits at h;
        rw [ h' ] at h ; norm_num at h;
      · refine' Nat.sub_pos_of_lt _;
        exact Submodule.finrank_lt_finrank_of_lt ( lt_of_le_of_ne h.1 h.2 )

end CSSCode

/-! ## The genus-`g` surface code

The minimal CW decomposition of a closed orientable surface of genus `g` has one
`0`-cell, `2g` `1`-cells, and one `2`-cell.  The unique face is attached along the
product of commutators `∏ᵢ [aᵢ, bᵢ]`; over `𝔽₂` every generator occurs an even
number of times, so the boundary map `∂₂` is the zero map.  Every `1`-cell is a
loop at the single vertex, so `∂₁` is the zero map as well.  Hence
`H₁ = (𝔽₂)^{2g}` has dimension `2g`. -/

/-- The minimal cellular chain complex of the closed orientable genus-`g`
surface, as a CSS code with one vertex, `2g` edges and one face. -/
def surfaceComplex (g : ℕ) : CSSCode where
  n0 := 1
  n1 := 2 * g
  n2 := 1
  d1 := 0
  d2 := 0
  boundary := by simp

/-
**Genus-`g` surface code encodes `2g` logical qubits.**  The first Betti
number of the closed orientable genus-`g` surface is `2g`.
-/
theorem surface_logical_qubits (g : ℕ) :
    (surfaceComplex g).logicalQubits = 2 * g := by
      unfold CSSCode.logicalQubits surfaceComplex;
      simp +decide [ CSSCode.cycles, CSSCode.boundaries ];
      rw [ LinearMap.ker_zero, LinearMap.range_zero ];
      norm_num

/-
**Euler characteristic of the genus-`g` surface.**  With `b₀ = 1`,
`b₁ = 2g`, `b₂ = 1`, the alternating sum of Betti numbers is `2 - 2g`,
recovering the classical value `χ = 2 - 2g`.
-/
theorem surface_euler_characteristic (g : ℕ) :
    (1 : ℤ) - (surfaceComplex g).logicalQubits + 1 = 2 - 2 * g := by
      rw [ surface_logical_qubits, Nat.cast_mul, Nat.cast_ofNat ] ; ring

end TQEC
/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer).
  Topological quantum error-correcting codes are homological objects: the logical
  degrees of freedom of a code are precisely the first homology group `H₁` of a
  cellular space, and the count of logical qubits is the first Betti number. In
  particular the closed orientable genus-`g` surface should yield a code with
  exactly `2g` logical qubits, matching the rank of `H₁` of that surface.

Experiment (Experimenter).
  We packaged a CSS code as a length-three chain complex over `𝔽₂` and defined
  `logicalQubits = dim(ker ∂₁) - dim(im ∂₂)`. Rank–nullity yielded the exact CSS
  dimension identity `k + rank ∂₁ + rank ∂₂ = n` (`logical_dimension_formula`).
  Instantiating the minimal CW decomposition of the genus-`g` surface (one vertex,
  `2g` edges, one face, with both boundary maps zero because every generator
  occurs twice in the attaching word `∏[aᵢ,bᵢ]`) gave `k = 2g`
  (`surface_logical_qubits`) and Euler characteristic `2 - 2g`.

Analysis (Analyst).
  Survived: the dimension formula and the genus law, both as exact identities
  rather than asymptotics. The homological information criterion
  (`hasLogical_iff_homology_nontrivial`) cleanly characterises when a code stores
  information: precisely when `im ∂₂ < ker ∂₁`, i.e. `H₁ ≠ 0`. The zero-map
  structure of the minimal surface complex is faithful, not a shortcut: over `𝔽₂`
  the single face genuinely bounds trivially.

Critique (Critic).
  The dimension formula is not vacuous: it is driven by rank–nullity and the
  boundary condition `im ∂₂ ⊆ ker ∂₁`, not by definitional unfolding. The genus
  law relies on the chosen minimal complex; a different cellulation gives the same
  `H₁` dimension but larger `n`, which is exactly the distance/rate trade-off
  explored in the companion distance file. No hidden nonemptiness assumptions are
  needed because all spaces are finite-dimensional.

Synthesis (Principal Investigator).
  "Logical qubits = first Betti number" is now an exact theorem, and the genus-`g`
  surface code's `2g` logical qubits follows as a special case. This is the
  algebra/topology bridge underpinning surface and color codes.
-/