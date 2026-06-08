/-
  # Jones Polynomial

  The Jones polynomial is the Kauffman bracket normalized by writhe:
    V_D(A) = (-A)^(-3w(D)) · ⟨D⟩

  ## Main results
  - `jones_unknot`: V(unknot) = 1
  - `jones_RI_invariant`: V is invariant under Reidemeister I
  - `jones_RI_neg_invariant`: V is invariant under negative RI
  - `jones_RIII_invariant`: V is invariant under Reidemeister III
-/
import Mathlib
import Speculative.Knot.Defs
import Speculative.Knot.KauffmanBracket

namespace Knot

open LaurentPolynomial

/-- The writhe normalization factor: (-A)^(-3w) = (-1)^w · T(-3w).
    Since (-1)^(-3w) = (-1)^w (as (-1)³ = -1 and we work mod 2). -/
noncomputable def writheFactor {n : ℕ} (D : OrientedLinkDiagram n) :
    LaurentPolynomial ℤ :=
  (if Even (writhe D) then (1 : LaurentPolynomial ℤ) else -1) * T (-3 * writhe D)

/-- The Jones polynomial V_D = (-A)^(-3w(D)) · ⟨D⟩ -/
noncomputable def jones {n : ℕ} (D : OrientedLinkDiagram n) :
    LaurentPolynomial ℤ :=
  writheFactor D * bracket D.toLinkDiagram

/-- The Jones polynomial of the unknot is 1. -/
theorem jones_unknot : jones orientedUnknot = 1 := by
  simp [jones, writheFactor, orientedUnknot, writhe, bracket_unknot]

/-
The writhe of D₁ under positive RI is writhe D₂ + 1.
-/
theorem writhe_RI_pos {n : ℕ} {D₁ : OrientedLinkDiagram (n + 1)}
    {D₂ : OrientedLinkDiagram n} (h : ReidemeisterI D₁ D₂) :
    writhe D₁ = writhe D₂ + 1 := by
  cases h;
  unfold writhe;
  rw [ Fin.sum_univ_castSucc ];
  aesop

/-
The writhe of D₁ under negative RI is writhe D₂ - 1.
-/
theorem writhe_RI_neg {n : ℕ} {D₁ : OrientedLinkDiagram (n + 1)}
    {D₂ : OrientedLinkDiagram n} (h : ReidemeisterI_neg D₁ D₂) :
    writhe D₁ = writhe D₂ - 1 := by
  have h_split : ∑ i : Fin (n + 1), (D₁.sign i).toInt = ∑ i : Fin n, (D₁.sign (Fin.castSucc i)).toInt + (D₁.sign (Fin.last n)).toInt := by
    exact Fin.sum_univ_castSucc _;
  cases h ; aesop

/-
Jones polynomial is invariant under positive RI.
-/
theorem jones_RI_invariant {n : ℕ}
    {D₁ : OrientedLinkDiagram (n + 1)} {D₂ : OrientedLinkDiagram n}
    (h : ReidemeisterI D₁ D₂) :
    jones D₁ = jones D₂ := by
  have h_writhe : writhe D₁ = writhe D₂ + 1 := by
    exact?;
  -- Substitute the expressions for writheFactor and bracket into the goal.
  rw [jones, jones, writheFactor, writheFactor];
  rw [ h_writhe, bracket_RI_positive h ];
  split_ifs <;> simp_all +decide [ parity_simps ];
  · exact absurd ‹Even ( writhe D₂ ) › ( by simpa using ‹Odd ( writhe D₂ ) › );
  · exact Or.inl <| congr_arg _ <| by ring;
  · exact Or.inl <| congr_arg _ <| by ring;

/-
Jones polynomial is invariant under negative RI.
-/
theorem jones_RI_neg_invariant {n : ℕ}
    {D₁ : OrientedLinkDiagram (n + 1)} {D₂ : OrientedLinkDiagram n}
    (h : ReidemeisterI_neg D₁ D₂) :
    jones D₁ = jones D₂ := by
  unfold jones;
  rw [ Knot.bracket_RI_negative ];
  any_goals assumption;
  unfold writheFactor;
  rw [ show writhe D₁ = writhe D₂ - 1 from ?_ ];
  · split_ifs <;> simp_all +decide [ parity_simps ];
    · grind;
    · lia;
    · lia;
  · exact?

/-- Jones polynomial is invariant under RIII. -/
theorem jones_RIII_invariant {n : ℕ}
    {D₁ D₂ : OrientedLinkDiagram n}
    (h : OrientedReidemeisterIII D₁ D₂) :
    jones D₁ = jones D₂ := by
  simp only [jones]
  congr 1
  · simp only [writheFactor, h.writhe_eq]
  · exact bracket_reidemeister_III_invariant h.unoriented

end Knot