import Tropical.StableKneser.Packing

/-!
# The canonical upper coloring of stable Kneser families

This file formalizes the elementary upper-bound half of Meunier's predicted
chromatic-number formula.  If `n = r + s*(k-1)`, color a stable `k`-set by the
smaller of its least element and `r-1`. Equal-colored sets necessarily meet.
Thus this is a proper coloring of the disjointness graph with `r = n-sk+s`
colors (cyclic stability is stronger than the linear stability used here).
-/

namespace StableKneser

/-- The canonical color: all sets whose minimum is beyond the ordinary colors
are collected into the final color. -/
def canonicalColor (r : ℕ) (A : Finset ℕ) (hA : A.Nonempty) : ℕ :=
  min (A.min' hA) (r - 1)

/-
The canonical color is one of the `r` colors.
-/
theorem canonicalColor_lt (r : ℕ) (hr : 0 < r) (A : Finset ℕ) (hA : A.Nonempty) :
    canonicalColor r A hA < r := by
  exact lt_of_le_of_lt ( min_le_right _ _ ) ( Nat.pred_lt hr.ne' )

/-
**Canonical stable-Kneser coloring theorem.**

For `n = r + s(k-1)`, any two linearly `s`-stable `k`-subsets of `[0,n)`
receiving the same canonical color intersect. This directly supplies the
upper bound `χ ≤ r = n-sk+s` for the corresponding disjointness graph.
-/
theorem canonicalColor_fiber_intersect
    (s k r n : ℕ) (hs : 0 < s) (hk : 0 < k) (hr : 0 < r)
    (hn : n = r + s * (k - 1))
    (A B : Finset ℕ) (hA : A.Nonempty) (hB : B.Nonempty)
    (hcardA : A.card = k) (hcardB : B.card = k)
    (hstableA : LinearStable s A) (hstableB : LinearStable s B)
    (hboundA : ∀ x ∈ A, x < n) (hboundB : ∀ x ∈ B, x < n)
    (hcolor : canonicalColor r A hA = canonicalColor r B hB) :
    (A ∩ B).Nonempty := by
  by_cases hcase : A.min' hA < r - 1 ∧ B.min' hB < r - 1;
  · exact ⟨ A.min' hA, Finset.mem_inter.mpr ⟨ Finset.min'_mem _ hA, by rw [ show A.min' hA = B.min' hB by unfold canonicalColor at hcolor; omega ] ; exact Finset.min'_mem _ hB ⟩ ⟩;
  · by_cases hcase : A.min' hA ≥ r - 1 ∧ B.min' hB ≥ r - 1;
    · apply linearStable_extremal_intersect s k (r - 1) hs hk A B hcardA hcardB hstableA hstableB (fun x hx => Finset.mem_Icc.mpr ⟨by
      exact le_trans hcase.1 ( Finset.min'_le _ _ hx ), by
        grind +qlia⟩) (fun x hx => Finset.mem_Icc.mpr ⟨by
      exact le_trans hcase.2 ( Finset.min'_le _ _ hx ), by
        grind +splitImp⟩);
    · unfold canonicalColor at hcolor; cases min_cases ( Finset.min' A hA ) ( r - 1 ) <;> cases min_cases ( Finset.min' B hB ) ( r - 1 ) <;> omega;

/-
Contrapositive graph-theoretic form: disjoint stable sets get distinct
canonical colors.
-/
theorem canonicalColor_ne_of_disjoint
    (s k r n : ℕ) (hs : 0 < s) (hk : 0 < k) (hr : 0 < r)
    (hn : n = r + s * (k - 1))
    (A B : Finset ℕ) (hA : A.Nonempty) (hB : B.Nonempty)
    (hcardA : A.card = k) (hcardB : B.card = k)
    (hstableA : LinearStable s A) (hstableB : LinearStable s B)
    (hboundA : ∀ x ∈ A, x < n) (hboundB : ∀ x ∈ B, x < n)
    (hdisjoint : Disjoint A B) :
    canonicalColor r A hA ≠ canonicalColor r B hB := by
  convert canonicalColor_fiber_intersect s k r n hs hk hr hn A B hA hB hcardA hcardB hstableA hstableB hboundA hboundB using 1;
  simp_all +decide [ Finset.disjoint_iff_inter_eq_empty, Finset.ext_iff ]

end StableKneser