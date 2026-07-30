/-
Copyright (c) 2026 Harmonic.
Released under Apache 2.0 license.

# Certified rank computation from a finite descent presentation

The unconditional computability of Mordell–Weil ranks over `ℚ` is not presently
known.  This file isolates and proves the finite linear-algebra endpoint used by
descent: once a descent supplies a rational presentation matrix for the free
part, its rank is computed by Gaussian elimination (`Matrix.rank`).
-/
import Mathlib

namespace BSD.RankComputability

/-- The candidate free rank associated with a presentation having `n` generators
and relation matrix `A`. -/
noncomputable def descentRank {m n : ℕ} (A : Matrix (Fin n) (Fin m) ℚ) : ℕ :=
  n - A.rank

/-- Matrix rank cannot exceed the number of generators in the presentation. -/
theorem matrixRank_le_generators {m n : ℕ} (A : Matrix (Fin n) (Fin m) ℚ) :
    A.rank ≤ n := by
  calc A.rank ≤ Finset.card (Finset.univ : Finset (Fin n)) := Matrix.rank_le_card_height A
    _ = n := Finset.card_fin n

/-- The computed free rank and relation rank add up to the number of generators. -/
theorem descentRank_add_matrixRank {m n : ℕ} (A : Matrix (Fin n) (Fin m) ℚ) :
    descentRank A + A.rank = n := by
  simp only [descentRank]
  exact Nat.sub_add_cancel (matrixRank_le_generators A)

/-- Rank–nullity for the cokernel of a finite rational presentation. -/
theorem quotientFinrank_add_matrixRank {m n : ℕ} (A : Matrix (Fin n) (Fin m) ℚ) :
    Module.finrank ℚ ((Fin n → ℚ) ⧸ Submodule.span ℚ (Set.range A.col)) + A.rank = n := by
  rw [Matrix.rank_eq_finrank_span_cols]
  simpa using (Submodule.finrank_quotient_add_finrank
    (R := ℚ) (M := Fin n → ℚ) (Submodule.span ℚ (Set.range A.col)))

/-- Correctness of `descentRank`: it is exactly the dimension of the presented
rational vector space. -/
theorem descentRank_eq_quotientFinrank {m n : ℕ} (A : Matrix (Fin n) (Fin m) ℚ) :
    descentRank A =
      Module.finrank ℚ ((Fin n → ℚ) ⧸ Submodule.span ℚ (Set.range A.col)) := by
  simp only [descentRank]
  have h := quotientFinrank_add_matrixRank A
  omega

/-- A certified finite descent presentation computes its asserted Mordell–Weil rank. -/
theorem rank_computable_from_descent_presentation
    {E : Type} (algebraicRank : E → ℕ) {m n : ℕ} (curve : E)
    (A : Matrix (Fin n) (Fin m) ℚ)
    (hpresentation : algebraicRank curve =
      Module.finrank ℚ ((Fin n → ℚ) ⧸ Submodule.span ℚ (Set.range A.col))) :
    algebraicRank curve = descentRank A := by
  rw [hpresentation]
  exact (descentRank_eq_quotientFinrank A).symm

/-- Parity is consequently decidable from the same certified presentation. -/
theorem rank_even_iff_descentRank_even
    {E : Type} (algebraicRank : E → ℕ) {m n : ℕ} (curve : E)
    (A : Matrix (Fin n) (Fin m) ℚ)
    (hpresentation : algebraicRank curve =
      Module.finrank ℚ ((Fin n → ℚ) ⧸ Submodule.span ℚ (Set.range A.col))) :
    Even (algebraicRank curve) ↔ Even (descentRank A) := by
  rw [rank_computable_from_descent_presentation algebraicRank curve A hpresentation]

/-- Combining a descent certificate with the parity conjecture identifies the root
number with the parity of the explicitly computed rank. -/
theorem rootNumber_eq_negOnePow_descentRank
    {E W : Type} (algebraicRank : E → ℕ) (rootNumber : E → W)
    (negOnePow : ℕ → W) {m n : ℕ} (curve : E)
    (A : Matrix (Fin n) (Fin m) ℚ)
    (hpresentation : algebraicRank curve =
      Module.finrank ℚ ((Fin n → ℚ) ⧸ Submodule.span ℚ (Set.range A.col)))
    (hparity : rootNumber curve = negOnePow (algebraicRank curve)) :
    rootNumber curve = negOnePow (descentRank A) := by
  rw [hparity]
  congr 1
  exact rank_computable_from_descent_presentation algebraicRank curve A hpresentation

end BSD.RankComputability