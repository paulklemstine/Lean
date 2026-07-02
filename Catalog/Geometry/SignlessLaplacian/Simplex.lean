/-
  Sharpness of the signless Laplacian spectral bound: the simplex
  ===============================================================

  The Cauchy–Schwarz bound `specRad ≤ s·D` of `Core.lean` is *sharp*.  The
  extremal configuration is a single facet — an `r`-simplex — modelled here
  by one facet `Fin 1 → Finset (Fin n)` whose unique facet is all of the `n`
  ridges.  Then every ridge has degree `1`, the facet has `n` ridges, the
  Core bound gives `specRad ≤ n·1 = n`, and the all-ones vector attains it,
  so `specRad = n`.

  This is the base case of the conjectured equality characterization
  (equality is achieved by joins of simplices); it certifies that the bound
  in `Core.lean` is not vacuous.

  -- !-- Lab Notes -- !--
  Hypothesis: the bound `s·D` is attained by the complete/simplex
    configuration (the higher analogue of `K_n` attaining `q = 2(n-1)`).
  Experiment: compute `slQuad`, `degree`, and the Rayleigh quotient of the
    all-ones vector for the single-facet structure.
  Analysis: the all-ones vector `x ≡ 1` gives Rayleigh quotient
    `(∑ 1)² / (∑ 1²) = n²/n = n`, matching the upper bound `n·1`.
  Critique: handles `n = 0` (both sides `0`, `sSup ∅ = 0`) — no hidden
    nonemptiness assumption.
  Synthesis: confirms sharpness; equality for general joins is left to
    `FUTURE_DIRECTIONS.md`.
-/
import Geometry.SignlessLaplacian.Core

open Finset BigOperators

namespace SignlessLaplacian

/-- The single-facet ("simplex") incidence structure on `n` ridges. -/
def simplexFacet (n : ℕ) : Fin 1 → Finset (Fin n) := fun _ => Finset.univ

/-
In the simplex, the unique facet contains all `n` ridges.
-/
theorem simplex_facet_card (n : ℕ) (f : Fin 1) :
    (simplexFacet n f).card = n := by
  simp +decide [ simplexFacet ]

/-
In the simplex, every ridge has degree `1`.
-/
theorem simplex_degree (n : ℕ) (r : Fin n) :
    degree (simplexFacet n) r = 1 := by
  unfold degree simplexFacet; simp +decide ;

/-
The quadratic form of the simplex is `(∑ r, x r)²`.
-/
theorem simplex_slQuad (n : ℕ) (x : Fin n → ℝ) :
    slQuad (simplexFacet n) x = (∑ r, x r) ^ 2 := by
  unfold slQuad; aesop;

/-
Sharpness: the signless Laplacian spectral radius of the `n`-ridge
    simplex equals `n`, matching the Core bound `s·D = n·1`.
-/
theorem simplex_specRad (n : ℕ) :
    specRad (simplexFacet n) = (n : ℝ) := by
  refine' le_antisymm ( _ : _ ≤ ↑n ) _;
  · convert specRad_le ( simplexFacet n ) n 1 _ _ using 1 <;> norm_num [ simplex_facet_card, simplex_degree ];
  · by_cases hn : n = 0;
    · convert specRad_nonneg ( simplexFacet n );
      norm_num [ hn ];
    · refine' le_csSup _ _;
      · refine' ⟨ n, Set.forall_mem_image.2 fun x hx => _ ⟩;
        refine' div_le_of_le_mul₀ _ _ _;
        · exact Finset.sum_nonneg fun _ _ => sq_nonneg _;
        · positivity;
        · convert slQuad_le ( simplexFacet n ) x n 1 _ _ using 1 <;> norm_num [ simplex_facet_card, simplex_degree ];
      · refine' ⟨ fun _ => 1, _, _ ⟩ <;> norm_num [ hn ];
        simp +decide [ slQuad, simplexFacet ];
        rw [ sq, mul_div_cancel_left₀ _ ( by positivity ) ]

end SignlessLaplacian