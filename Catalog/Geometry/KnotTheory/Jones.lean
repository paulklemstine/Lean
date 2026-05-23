/-
  # Jones Polynomial

  The Jones polynomial V_D(A) = (-A)^(-3w(D)) · ⟨D⟩ is the
  writhe-normalized Kauffman bracket. It is a knot invariant:
  invariant under all three Reidemeister moves.

  ## Main results
  - `jones_unknot`: V(unknot) = 1
  - `jones_RI_invariant`: Jones polynomial is invariant under R1+
  - `jones_RI_neg_invariant`: Jones polynomial is invariant under R1-
  - `jones_RII_invariant`: Jones polynomial is invariant under R2
  - `jones_RIII_invariant`: Jones polynomial is invariant under R3
-/
import Mathlib
import Geometry.KnotTheory.Defs
import Geometry.KnotTheory.KauffmanBracket

namespace Knot

open LaurentPolynomial

/-- The writhe normalization factor: (-A)^(-3w) = (-1)^w · T(-3w).
    This uses (-1)^(-3w) = (-1)^w since (-1)³ = -1. -/
noncomputable def writheFactor {n : ℕ} (D : OrientedLinkDiagram n) :
    LaurentPolynomial ℤ :=
  (if Even (writhe D) then (1 : LaurentPolynomial ℤ) else -1) * T (-3 * writhe D)

/-- The Jones polynomial V_D = (-A)^(-3w(D)) · ⟨D⟩ -/
noncomputable def jones {n : ℕ} (D : OrientedLinkDiagram n) :
    LaurentPolynomial ℤ :=
  writheFactor D * bracket D.toLinkDiagram

/-! ## Unknot -/

/-- The Jones polynomial of the unknot is 1. -/
theorem jones_unknot : jones orientedUnknot = 1 := by
  simp [jones, writheFactor, orientedUnknot, writhe, bracket_unknot]

/-! ## Writhe computations -/

/-
The writhe of D₁ under positive RI is writhe D₂ + 1.
-/
theorem writhe_RI_pos {n : ℕ} {D₁ : OrientedLinkDiagram (n + 1)}
    {D₂ : OrientedLinkDiagram n} (h : ReidemeisterI D₁ D₂) :
    writhe D₁ = writhe D₂ + 1 := by
  unfold writhe;
  rw [ Fin.sum_univ_castSucc ];
  rw [ Finset.sum_congr rfl fun i _ => by rw [ h.sign_agree i ] ] ; simp +decide [ h.kink_sign ]

/-
The writhe of D₁ under negative RI is writhe D₂ - 1.
-/
theorem writhe_RI_neg {n : ℕ} {D₁ : OrientedLinkDiagram (n + 1)}
    {D₂ : OrientedLinkDiagram n} (h : ReidemeisterI_neg D₁ D₂) :
    writhe D₁ = writhe D₂ - 1 := by
  unfold writhe;
  rw [ Fin.sum_univ_castSucc ];
  rw [ Finset.sum_congr rfl fun i hi => by rw [ h.sign_agree i ] ] ; norm_num [ h.kink_sign ];
  ring

/-! ## Invariance theorems -/

/-
Jones polynomial is invariant under positive Reidemeister I.
-/
theorem jones_RI_invariant {n : ℕ}
    {D₁ : OrientedLinkDiagram (n + 1)} {D₂ : OrientedLinkDiagram n}
    (h : ReidemeisterI D₁ D₂) :
    jones D₁ = jones D₂ := by
  simp +decide [ jones, bracket_RI_positive h, writhe_RI_pos h ];
  unfold writheFactor; simp +decide [ writhe_RI_pos h ] ; ring;
  grind

/-
Jones polynomial is invariant under negative Reidemeister I.
-/
theorem jones_RI_neg_invariant {n : ℕ}
    {D₁ : OrientedLinkDiagram (n + 1)} {D₂ : OrientedLinkDiagram n}
    (h : ReidemeisterI_neg D₁ D₂) :
    jones D₁ = jones D₂ := by
  convert congr_arg _ ( bracket_RI_negative h ) using 1;
  unfold jones writheFactor;
  rw [ show writhe D₁ = writhe D₂ - 1 from writhe_RI_neg h ] ; split_ifs <;> simp_all +decide [ parity_simps ] ; ring;
  · grind +locals;
  · grind +qlia;
  · exact Or.inl ( by ring )

/-
Jones polynomial is invariant under Reidemeister III.
-/
theorem jones_RIII_invariant {n : ℕ}
    {D₁ D₂ : OrientedLinkDiagram n}
    (h : OrientedReidemeisterIII D₁ D₂) :
    jones D₁ = jones D₂ := by
  nontriviality;
  convert congr_arg₂ ( · * · ) _ ( bracket_RIII_invariant h.unoriented ) using 1;
  unfold writheFactor;
  rw [ h.writhe_eq ]

end Knot