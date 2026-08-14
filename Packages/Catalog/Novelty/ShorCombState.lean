import Novelty.ShorFullState

/-! # The periodic comb across a register cut: bond dimension is the order

After the function register of Shor's algorithm is measured, the exponent
register is left in the **periodic comb**

`c_x = [x ≡ x₀ (mod r)]`  (suitably normalized),  `x < Q = B * C`,

which is the *input of the quantum Fourier transform*.  A tensor-train / MPS
emulation cuts the exponent register into a low part `b < B` and a high part
`c < C` via `x = b + B·c`.  This file computes the Schmidt data of the comb
across such a cut.

Writing `combCutMatrix B C r x₀ amp` for the coefficient matrix of the comb
across the cut, the main results are:

* `combCutMatrix_eq_matchMatrix` : the comb across a cut is a fibre-matching
  state for the labels `b ↦ b mod r` and `c ↦ x₀ - B·c mod r`;
* `schmidtRank_combCut_le` : the Schmidt rank is at most `min r (min B C)` —
  the cut can never see more than the order;
* `schmidtRank_combCut_eq` : if `gcd(B, r) = 1` (automatic for a power-of-two
  cut of an *odd* order) and `r ≤ B`, `r ≤ C`, then the Schmidt rank is
  **exactly `r`**, and hence `bondDim_combCut_ge` : every MPS representation of
  the comb across that cut has bond dimension at least `r`;
* `flatSchmidtSpectrum_combCut` : in the opposite regime `B ≤ r`, `C ≤ r` the
  Schmidt spectrum is *flat* — all singular values are equal, so there is no
  tail to truncate;
* `schmidtRank_combCut_eq_one_of_dvd` : the *only* way the comb factorizes
  across the cut is `r ∣ B`, i.e. when the low half of the register already
  resolves the period.  This is the sharp form of the folklore
  `D = Θ(min(r, Q/r))`.
-/

open Finset Matrix
open scoped ComplexOrder

namespace ShorIrreducible

open IITTensorNetwork

section Comb

variable {B C r x0 : ℕ} [NeZero r] {amp : ℝ}

/-- Label of the low half of the exponent register: its residue mod `r`. -/
def combLeft (B r : ℕ) : Fin B → ZMod r := fun b => ((b : ℕ) : ZMod r)

/-- Label of the high half: the residue the low half has to complete to `x₀`. -/
def combRight (B C r x0 : ℕ) : Fin C → ZMod r :=
  fun c => (x0 : ZMod r) - (B : ZMod r) * ((c : ℕ) : ZMod r)

/-- The **periodic comb** `[x ≡ x₀ mod r]` across the cut `x = b + B·c`. -/
noncomputable def combCutMatrix (B C r x0 : ℕ) (amp : ℝ) : Matrix (Fin B) (Fin C) ℂ :=
  fun b c => if ((b : ℕ) + B * (c : ℕ)) % r = x0 % r then (amp : ℂ) else 0

/-- The comb across a cut is a fibre-matching state. -/
theorem combCutMatrix_eq_matchMatrix (B C r x0 : ℕ) [NeZero r] (amp : ℝ) :
    combCutMatrix B C r x0 amp = matchMatrix (combLeft B r) (combRight B C r x0) amp := by
  ext b c
  have hiff : ((b : ℕ) + B * (c : ℕ)) % r = x0 % r ↔ combLeft B r b = combRight B C r x0 c := by
    rw [← ZMod.natCast_eq_natCast_iff']
    constructor
    · intro h
      have h' : ((b : ℕ) : ZMod r) + (B : ZMod r) * ((c : ℕ) : ZMod r) = (x0 : ZMod r) := by
        push_cast at h
        exact h
      rw [combLeft, combRight, eq_sub_iff_add_eq]
      exact h'
    · intro h
      rw [combLeft, combRight, eq_sub_iff_add_eq] at h
      push_cast
      exact h
  by_cases h : ((b : ℕ) + B * (c : ℕ)) % r = x0 % r
  · rw [combCutMatrix, if_pos h, matchMatrix, if_pos (hiff.mp h)]
  · rw [combCutMatrix, if_neg h, matchMatrix, if_neg (fun hc => h (hiff.mpr hc))]

/-! ### The generic upper bound -/

theorem card_matchSet_comb_le_order :
    (matchSet (combLeft B r) (combRight B C r x0)).card ≤ r := by
  classical
  calc (matchSet (combLeft B r) (combRight B C r x0)).card
      ≤ (univ : Finset (ZMod r)).card := Finset.card_le_card (Finset.subset_univ _)
    _ = r := by rw [Finset.card_univ, ZMod.card]

/-- **The Schmidt rank of the comb across a cut is at most `min r (min B C)`.**
No cut can resolve more than the order, and none can exceed the size of the
smaller half. -/
theorem schmidtRank_combCut_le (hamp : amp ≠ 0) :
    schmidtRank (combCutMatrix B C r x0 amp) ≤ min r (min B C) := by
  classical
  rw [combCutMatrix_eq_matchMatrix, schmidtRank_matchMatrix hamp]
  refine le_min card_matchSet_comb_le_order (le_min ?_ ?_)
  · calc (matchSet (combLeft B r) (combRight B C r x0)).card
        ≤ ((univ : Finset (Fin B)).image (combLeft B r)).card :=
          Finset.card_le_card Finset.inter_subset_left
      _ ≤ (univ : Finset (Fin B)).card := Finset.card_image_le
      _ = B := by simp
  · calc (matchSet (combLeft B r) (combRight B C r x0)).card
        ≤ ((univ : Finset (Fin C)).image (combRight B C r x0)).card :=
          Finset.card_le_card Finset.inter_subset_right
      _ ≤ (univ : Finset (Fin C)).card := Finset.card_image_le
      _ = C := by simp

/-! ### The exponential regime: rank exactly `r` -/

/-- If the low half of the register is at least as long as the period, every
residue occurs in it. -/
theorem image_combLeft_eq_univ (hB : r ≤ B) :
    (univ : Finset (Fin B)).image (combLeft B r) = univ := by
  classical
  refine Finset.eq_univ_of_forall fun s => ?_
  refine Finset.mem_image.mpr ⟨⟨s.val, lt_of_lt_of_le (ZMod.val_lt s) hB⟩, Finset.mem_univ _, ?_⟩
  rw [combLeft]
  exact ZMod.natCast_zmod_val s

/-- If the high half is at least as long as the period and the block size `B` is
invertible mod `r` (automatic for a power-of-two cut of an odd order), every
residue occurs as a high-half label as well. -/
theorem image_combRight_eq_univ (hC : r ≤ C) (hcop : Nat.Coprime B r) :
    (univ : Finset (Fin C)).image (combRight B C r x0) = univ := by
  classical
  refine Finset.eq_univ_of_forall fun s => ?_
  set t : ZMod r := ((B : ZMod r))⁻¹ * ((x0 : ZMod r) - s) with ht
  refine Finset.mem_image.mpr ⟨⟨t.val, lt_of_lt_of_le (ZMod.val_lt t) hC⟩, Finset.mem_univ _, ?_⟩
  rw [combRight]
  have hval : ((t.val : ℕ) : ZMod r) = t := ZMod.natCast_zmod_val t
  rw [show (((⟨t.val, lt_of_lt_of_le (ZMod.val_lt t) hC⟩ : Fin C) : ℕ) : ZMod r) = t from hval, ht]
  rw [← mul_assoc, ZMod.coe_mul_inv_eq_one B hcop, one_mul]
  ring

/-- **The comb has Schmidt rank exactly `r` across every sufficiently balanced
cut.**  In particular, for an odd order `r` and a power-of-two register split
with both halves of size at least `r`, the Schmidt rank across the cut equals
the order — exponentially large in the bit size for factoring-relevant `r`. -/
theorem schmidtRank_combCut_eq (hamp : amp ≠ 0) (hB : r ≤ B) (hC : r ≤ C)
    (hcop : Nat.Coprime B r) :
    schmidtRank (combCutMatrix B C r x0 amp) = r := by
  classical
  rw [combCutMatrix_eq_matchMatrix, schmidtRank_matchMatrix hamp, matchSet,
    image_combLeft_eq_univ hB, image_combRight_eq_univ hC hcop, Finset.inter_self,
    Finset.card_univ, ZMod.card]

/-- **The tensor-network obstruction for the QFT input.**  Every MPS /
tensor-train representation of the comb across the cut has bond dimension at
least `r`. -/
theorem bondDim_combCut_ge (hamp : amp ≠ 0) (hB : r ≤ B) (hC : r ≤ C) (hcop : Nat.Coprime B r)
    {χ : ℕ} (h : HasBondDim (combCutMatrix B C r x0 amp) χ) : r ≤ χ := by
  have := schmidtRank_le_of_hasBondDim h
  rwa [schmidtRank_combCut_eq hamp hB hC hcop] at this

theorem not_hasBondDim_combCut (hamp : amp ≠ 0) (hB : r ≤ B) (hC : r ≤ C)
    (hcop : Nat.Coprime B r) {χ : ℕ} (hχ : χ < r) :
    ¬ HasBondDim (combCutMatrix B C r x0 amp) χ :=
  fun h => absurd (bondDim_combCut_ge hamp hB hC hcop h) (not_le.mpr hχ)

/-! ### The flat regime: no singular-value tail to truncate -/

omit [NeZero r] in
theorem injective_combLeft (hB : B ≤ r) : Function.Injective (combLeft B r) := by
  intro b b' h
  rw [combLeft] at h
  have h' : (b : ℕ) % r = (b' : ℕ) % r := (ZMod.natCast_eq_natCast_iff' _ _ _).mp h
  rw [Nat.mod_eq_of_lt (lt_of_lt_of_le b.isLt hB), Nat.mod_eq_of_lt (lt_of_lt_of_le b'.isLt hB)]
    at h'
  exact Fin.ext h'

omit [NeZero r] in
theorem injective_combRight (hC : C ≤ r) (hcop : Nat.Coprime B r) :
    Function.Injective (combRight B C r x0) := by
  intro c c' h
  simp only [combRight] at h
  rw [sub_right_inj] at h
  have hBu : IsUnit (B : ZMod r) := (ZMod.isUnit_iff_coprime B r).mpr hcop
  have h' : ((c : ℕ) : ZMod r) = ((c' : ℕ) : ZMod r) := hBu.mul_left_cancel h
  have h'' : (c : ℕ) % r = (c' : ℕ) % r := (ZMod.natCast_eq_natCast_iff' _ _ _).mp h'
  rw [Nat.mod_eq_of_lt (lt_of_lt_of_le c.isLt hC), Nat.mod_eq_of_lt (lt_of_lt_of_le c'.isLt hC)]
    at h''
  exact Fin.ext h''

/-- **The Schmidt spectrum of the comb is flat** whenever both halves of the cut
are shorter than the period: all nonzero singular values coincide, so a
truncated MPS discards weight that is *not* small.  (This is the incompressible
regime described in the assessment.) -/
theorem flatSchmidtSpectrum_combCut (hamp : amp ≠ 0) (hB : B ≤ r) (hC : C ≤ r)
    (hcop : Nat.Coprime B r)
    (hnorm : amp ^ 2 * ((matchSet (combLeft B r) (combRight B C r x0)).card : ℝ) = 1)
    (hne : (matchSet (combLeft B r) (combRight B C r x0)).Nonempty) :
    FlatSchmidtSpectrum (combCutMatrix B C r x0 amp) := by
  rw [combCutMatrix_eq_matchMatrix]
  exact flatSchmidtSpectrum_matchMatrix_of_injective hamp (injective_combLeft hB)
    (injective_combRight hC hcop) hnorm hne

/-- In the flat regime the entanglement entropy is exactly `log` of the Schmidt
rank: the state is maximally entangled for its rank. -/
theorem entanglementEntropy_combCut_flat (hB : B ≤ r) (hC : C ≤ r) (hcop : Nat.Coprime B r)
    (hnorm : amp ^ 2 * ((matchSet (combLeft B r) (combRight B C r x0)).card : ℝ) = 1)
    (hne : (matchSet (combLeft B r) (combRight B C r x0)).Nonempty) :
    entanglementEntropy (combCutMatrix B C r x0 amp)
      = Real.log ((matchSet (combLeft B r) (combRight B C r x0)).card) := by
  rw [combCutMatrix_eq_matchMatrix]
  exact entanglementEntropy_matchMatrix_of_injective (injective_combLeft hB)
    (injective_combRight hC hcop) hnorm hne

/-! ### The degenerate regime -/

/-- **The comb factorizes across the cut exactly when the low half already
resolves the period.**  If `r ∣ B` the high half carries no information about
the residue and the Schmidt rank collapses to `1`: this is the (classically
easy) small-`r`-divides-`B` corner, the only place where a bond dimension below
`r` occurs. -/
theorem schmidtRank_combCut_eq_one_of_dvd (hamp : amp ≠ 0) (hdvd : r ∣ B) (hC : 0 < C)
    (hB : r ≤ B) :
    schmidtRank (combCutMatrix B C r x0 amp) = 1 := by
  classical
  have hB0 : (B : ZMod r) = 0 := (ZMod.natCast_eq_zero_iff B r).mpr hdvd
  have hright : ∀ c : Fin C, combRight B C r x0 c = (x0 : ZMod r) := by
    intro c
    rw [combRight, hB0, zero_mul, sub_zero]
  have himg : (univ : Finset (Fin C)).image (combRight B C r x0) = {(x0 : ZMod r)} := by
    apply Finset.Subset.antisymm
    · intro s hs
      obtain ⟨c, -, rfl⟩ := Finset.mem_image.mp hs
      rw [hright c]
      exact Finset.mem_singleton_self _
    · intro s hs
      rw [Finset.mem_singleton] at hs
      subst hs
      exact Finset.mem_image.mpr ⟨⟨0, hC⟩, Finset.mem_univ _, hright _⟩
  rw [combCutMatrix_eq_matchMatrix, schmidtRank_matchMatrix hamp, matchSet,
    image_combLeft_eq_univ hB, himg, Finset.univ_inter, Finset.card_singleton]

end Comb

end ShorIrreducible