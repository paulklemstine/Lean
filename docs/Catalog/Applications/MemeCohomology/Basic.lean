/-
# A finite-dimensional two-term model of meme sheaf cohomology

For a cellular sheaf on a finite graph, degree-zero and degree-one cochains form
a two-term complex `C⁰ → C¹`.  This file isolates the linear-algebraic content
needed to interpret virality claims without pretending that empirical virality
is itself a theorem.
-/

import Mathlib

open LinearMap

namespace MemeCohomology

noncomputable section

variable (𝕜 C0 C1 : Type*)
variable [Field 𝕜] [AddCommGroup C0] [Module 𝕜 C0]
variable [AddCommGroup C1] [Module 𝕜 C1]
variable [FiniteDimensional 𝕜 C0] [FiniteDimensional 𝕜 C1]

/-- A finite-dimensional cellular meme sheaf, represented by its coboundary. -/
structure MemeSheaf where
  coboundary : C0 →ₗ[𝕜] C1

namespace MemeSheaf

variable (M : MemeSheaf 𝕜 C0 C1)

/-- Global compatible interpretations (`H⁰`) are the kernel of the coboundary. -/
abbrev H0 := M.coboundary.ker

/-- Degree-one obstructions (`H¹`) are edge data modulo coboundaries. -/
abbrev H1 := C1 ⧸ M.coboundary.range

/-- The zeroth Betti number: dimension of globally compatible interpretations. -/
def b0 : ℕ := Module.finrank 𝕜 M.H0

/-- The first Betti number: dimension of consistency obstructions. -/
def b1 : ℕ := Module.finrank 𝕜 M.H1

/-
Rank-nullity gives the basic interpretation/rank tradeoff.
-/
omit [FiniteDimensional 𝕜 C1] in
theorem b0_add_rank :
    M.b0 + Module.finrank 𝕜 M.coboundary.range = Module.finrank 𝕜 C0 := by
  rw [ ← LinearMap.finrank_range_add_finrank_ker M.coboundary ];
  exact add_comm _ _

/-
Quotient dimension gives the obstruction/rank tradeoff.
-/
omit [FiniteDimensional 𝕜 C0] in
theorem b1_add_rank :
    M.b1 + Module.finrank 𝕜 M.coboundary.range = Module.finrank 𝕜 C1 := by
  convert Submodule.finrank_quotient_add_finrank _; all_goals infer_instance

/-
Increasing coboundary rank removes one dimension from both `H⁰` and `H¹`.
-/
theorem betti_tradeoff :
    M.b0 + M.b1 + 2 * Module.finrank 𝕜 M.coboundary.range =
      Module.finrank 𝕜 C0 + Module.finrank 𝕜 C1 := by
  linarith [ M.b0_add_rank, M.b1_add_rank ]

/-
There are no degree-one consistency obstructions exactly when every
edge-level datum is a coboundary.
-/
omit [FiniteDimensional 𝕜 C0] in
theorem b1_eq_zero_iff_surjective :
    M.b1 = 0 ↔ Function.Surjective M.coboundary := by
  constructor;
  · intro h;
    have h_range : Module.finrank 𝕜 M.coboundary.range = Module.finrank 𝕜 C1 := by
      linarith [ M.b1_add_rank ];
    exact LinearMap.range_eq_top.mp ( Submodule.eq_top_of_finrank_eq h_range );
  · intro h_surj;
    unfold b1;
    unfold H1;
    rw [ show M.coboundary.range = ⊤ by exact LinearMap.range_eq_top.mpr h_surj ];
    simp +decide [ Module.finrank ]

/-
The number of global interpretations is maximal exactly when the
coboundary vanishes.
-/
omit [FiniteDimensional 𝕜 C1] in
theorem b0_eq_max_iff_coboundary_eq_zero :
    M.b0 = Module.finrank 𝕜 C0 ↔ M.coboundary = 0 := by
  constructor <;> intro h;
  · contrapose! h;
    have := M.b0_add_rank;
    linarith [ show 0 < Module.finrank 𝕜 ( LinearMap.range M.coboundary ) from Nat.pos_of_ne_zero fun con => h <| LinearMap.range_eq_bot.mp <| Submodule.finrank_eq_zero.mp con ];
  · unfold b0;
    unfold H0;
    rw [ h, LinearMap.ker_zero ];
    rw [ finrank_top ]

/-
If `H⁰` is maximal, then all edge-level data survive in `H¹`.
Thus maximal interpretive freedom does not generally imply unobstructedness.
-/
theorem b1_eq_edge_dimension_of_b0_max
    (hmax : M.b0 = Module.finrank 𝕜 C0) :
    M.b1 = Module.finrank 𝕜 C1 := by
  convert M.b1_add_rank;
  convert M.b0_eq_max_iff_coboundary_eq_zero.mp hmax;
  simp +decide [ LinearMap.range_eq_bot ]

/-
The strongest form of the proposed combination—maximal `H⁰` and vanishing
`H¹`—forces the degree-one cochain space itself to have dimension zero.
-/
theorem maximal_b0_and_zero_b1_forces_no_edge_data
    (hmax : M.b0 = Module.finrank 𝕜 C0) (hzero : M.b1 = 0) :
    Module.finrank 𝕜 C1 = 0 := by
  calc
    Module.finrank 𝕜 C1 = M.b1 :=
      (b1_eq_edge_dimension_of_b0_max 𝕜 C0 C1 M hmax).symm
    _ = 0 := hzero

/-
Conversely, when there is no degree-one cochain space, the zero
coboundary realizes maximal `H⁰` together with vanishing `H¹`.
-/
theorem maximal_b0_and_zero_b1_iff_no_edge_data
    (hδ : M.coboundary = 0) :
    (M.b0 = Module.finrank 𝕜 C0 ∧ M.b1 = 0) ↔
      Module.finrank 𝕜 C1 = 0 := by
  constructor
  · rintro ⟨hmax, hzero⟩
    exact maximal_b0_and_zero_b1_forces_no_edge_data 𝕜 C0 C1 M hmax hzero
  · intro hedge
    have hmax : M.b0 = Module.finrank 𝕜 C0 :=
      M.b0_eq_max_iff_coboundary_eq_zero.mpr hδ
    refine ⟨hmax, ?_⟩
    rw [b1_eq_edge_dimension_of_b0_max 𝕜 C0 C1 M hmax, hedge]

end MemeSheaf

/-! ## A certified finite counterexample to the naive conjunction -/

/-- Two independent local interpretations and one edge datum, with no
compatibility constraint. -/
def twoInterpretationExample : MemeSheaf ℚ (Fin 2 → ℚ) ℚ where
  coboundary := 0

/-
In the example, `H⁰` has dimension two while `H¹` has dimension one.
It therefore has maximal interpretation dimension but is not unobstructed.
-/
theorem twoInterpretationExample_betti :
    MemeSheaf.b0 ℚ (Fin 2 → ℚ) ℚ twoInterpretationExample = 2 ∧
    MemeSheaf.b1 ℚ (Fin 2 → ℚ) ℚ twoInterpretationExample = 1 := by
  constructor;
  · convert Module.finrank_fin_fun ℚ;
    -- The kernel of the zero map is the entire space, so its dimension is the dimension of the domain.
    have h_ker : (twoInterpretationExample.coboundary : (Fin 2 → ℚ) →ₗ[ℚ] ℚ).ker = ⊤ := by
      exact LinearMap.ker_eq_top.mpr rfl;
    convert LinearEquiv.finrank_eq ( LinearEquiv.ofTop _ h_ker );
  · unfold MemeSheaf.b1;
    unfold twoInterpretationExample MemeSheaf.H1;
    rw [ LinearMap.range_zero ];
    rw [ @Submodule.finrank_quotient ] ; norm_num

end
end MemeCohomology