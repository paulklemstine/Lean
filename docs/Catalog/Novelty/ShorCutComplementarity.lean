import Novelty.ShorCutAlignment

/-! # The corrected input/output law for the two endpoints of the QFT

`ShorCutAlignment.not_complementary_ranks` refutes the naive complementarity
conjecture (`rank_in · rank_out` bounded below by a function of `min(r,m)`).
This file proves the corrected law suggested by that refutation.

The engine is an *order* characterisation of the cut period:
`r ∣ B · k ↔ (r / gcd(r,B)) ∣ k` (`dvd_mul_iff_cutPeriod_dvd`), i.e.
`cutPeriod r B` is the order of the block size `B` in `ℤ/r`.  From it:

* `cutPeriod_lcm` : `cutPeriod (lcm r m) B = lcm (cutPeriod r B) (cutPeriod m B)`
  — the joint cut period is the *lcm* of the two endpoint cut periods, not their
  product and not a complementary divisor pair;
* `schmidtRank_mul_ge` : `min C (cutPeriod (lcm r m) B) ≤ rank_in · rank_out`,
  the corrected complementarity inequality;
* `lcm_dvd_of_both_rank_one` : a cut compresses **both** endpoints only when the
  block size is a multiple of `lcm(r, m)` — so, by `not_dvd_pow_two_of_odd`, never
  for a power-of-two cut of an odd order.
-/

open Finset

namespace ShorIrreducible

open IITTensorNetwork

section Complementarity

variable {B C r m x0 j Q : ℕ} {amp : ℝ}

/-- **The cut period is an order.**  `r ∣ B·k` exactly when `r/gcd(r,B)` divides
`k`; in other words `cutPeriod r B` is the additive order of `B` in `ℤ/r`. -/
theorem dvd_mul_iff_cutPeriod_dvd (hr : 0 < r) (B k : ℕ) :
    r ∣ B * k ↔ cutPeriod r B ∣ k := by
  have hg : 0 < Nat.gcd r B := Nat.gcd_pos_of_pos_left B hr
  have hrg : Nat.gcd r B * (r / Nat.gcd r B) = r :=
    Nat.mul_div_cancel' (Nat.gcd_dvd_left r B)
  have hBg : Nat.gcd r B * (B / Nat.gcd r B) = B :=
    Nat.mul_div_cancel' (Nat.gcd_dvd_right r B)
  constructor
  · intro h
    have h1 : Nat.gcd r B * (r / Nat.gcd r B)
        ∣ Nat.gcd r B * ((B / Nat.gcd r B) * k) := by
      rw [hrg, ← mul_assoc, hBg]
      exact h
    have h2 : (r / Nat.gcd r B) ∣ (B / Nat.gcd r B) * k :=
      (mul_dvd_mul_iff_left (by omega : Nat.gcd r B ≠ 0)).mp h1
    have h3 : (r / Nat.gcd r B) ∣ k * (B / Nat.gcd r B) := by
      rwa [mul_comm] at h2
    exact Nat.Coprime.dvd_of_dvd_mul_right (Nat.coprime_div_gcd_div_gcd hg) h3
  · rintro ⟨t, rfl⟩
    refine ⟨(B / Nat.gcd r B) * t, ?_⟩
    calc B * (cutPeriod r B * t)
        = (Nat.gcd r B * (B / Nat.gcd r B)) * (cutPeriod r B * t) := by rw [hBg]
      _ = (Nat.gcd r B * cutPeriod r B) * ((B / Nat.gcd r B) * t) := by ring
      _ = r * ((B / Nat.gcd r B) * t) := by rw [cutPeriod, hrg]

/-- **The joint cut period is the lcm of the endpoint cut periods.** -/
theorem cutPeriod_lcm (hr : 0 < r) (hm : 0 < m) :
    cutPeriod (Nat.lcm r m) B = Nat.lcm (cutPeriod r B) (cutPeriod m B) := by
  have hL : 0 < Nat.lcm r m := Nat.pos_of_ne_zero (by
    simp [Nat.lcm_eq_zero_iff]
    omega)
  refine Nat.dvd_antisymm ?_ ?_
  · refine (dvd_mul_iff_cutPeriod_dvd hL B _).mp (Nat.lcm_dvd ?_ ?_)
    · exact (dvd_mul_iff_cutPeriod_dvd hr B _).mpr (Nat.dvd_lcm_left _ _)
    · exact (dvd_mul_iff_cutPeriod_dvd hm B _).mpr (Nat.dvd_lcm_right _ _)
  · have hLdvd : Nat.lcm r m ∣ B * cutPeriod (Nat.lcm r m) B :=
      (dvd_mul_iff_cutPeriod_dvd hL B _).mpr dvd_rfl
    refine Nat.lcm_dvd ?_ ?_
    · exact (dvd_mul_iff_cutPeriod_dvd hr B _).mp
        (dvd_trans (Nat.dvd_lcm_left r m) hLdvd)
    · exact (dvd_mul_iff_cutPeriod_dvd hm B _).mp
        (dvd_trans (Nat.dvd_lcm_right r m) hLdvd)

/-- A truncated product bound: `min C (a·b) ≤ min C a · min C b` for positive
`C`, `a`, `b`. -/
lemma min_mul_le_mul_min {C a b : ℕ} (hC : 0 < C) (ha : 0 < a) (hb : 0 < b) :
    min C (a * b) ≤ min C a * min C b := by
  rcases le_total a C with hac | hac
  · rcases le_total b C with hbc | hbc
    · rw [min_eq_right hac, min_eq_right hbc]
      exact min_le_right _ _
    · rw [min_eq_right hac, min_eq_left hbc]
      calc min C (a * b) ≤ C := min_le_left _ _
        _ = 1 * C := (one_mul C).symm
        _ ≤ a * C := Nat.mul_le_mul_right C ha
  · rw [min_eq_left hac]
    calc min C (a * b) ≤ C := min_le_left _ _
      _ = C * 1 := (mul_one C).symm
      _ ≤ C * min C b := Nat.mul_le_mul_left C (le_min hC hb)

/-- **The corrected complementarity law.**  The product of the two endpoint
Schmidt ranks of the QFT is at least `min C (lcm(r,m) / gcd(lcm(r,m), B))`. -/
theorem schmidtRank_mul_ge [NeZero r] [NeZero m] (hamp : amp ≠ 0) (hr : 0 < r)
    (hm : 0 < m) (hC : 0 < C) (hrB : r ≤ B) (hmB : m ≤ B) :
    min C (cutPeriod (Nat.lcm r m) B)
      ≤ schmidtRank (combCutMatrix B C r x0 amp)
        * schmidtRank (outputCutMatrix B C m j Q amp) := by
  rw [schmidtRank_combCut_sharp hamp hr hrB, schmidtRank_outputCut hamp hm hmB,
    cutPeriod_lcm hr hm]
  calc min C (Nat.lcm (cutPeriod r B) (cutPeriod m B))
      ≤ min C (cutPeriod r B * cutPeriod m B) := by
        refine min_le_min_left C ?_
        exact Nat.le_of_dvd (Nat.mul_pos (cutPeriod_pos hr) (cutPeriod_pos hm))
          (Nat.lcm_dvd_mul _ _)
    _ ≤ min C (cutPeriod r B) * min C (cutPeriod m B) :=
        min_mul_le_mul_min hC (cutPeriod_pos hr) (cutPeriod_pos hm)

/-- **A cut compresses both endpoints only when it is aligned with `lcm(r,m)`.**
Together with `not_dvd_pow_two_of_odd` this shows that no power-of-two cut of an
odd-order comb can be cheap at both ends of the QFT. -/
theorem lcm_dvd_of_both_rank_one [NeZero r] [NeZero m] (hamp : amp ≠ 0) (hr : 0 < r)
    (hm : 0 < m) (hC : 2 ≤ C) (hrB : r ≤ B) (hmB : m ≤ B)
    (hin : schmidtRank (combCutMatrix B C r x0 amp) = 1)
    (hout : schmidtRank (outputCutMatrix B C m j Q amp) = 1) :
    Nat.lcm r m ∣ B := by
  have hL : 0 < Nat.lcm r m := Nat.pos_of_ne_zero (by
    simp [Nat.lcm_eq_zero_iff]
    omega)
  have hkey := schmidtRank_mul_ge (C := C) (x0 := x0) (j := j) (Q := Q) hamp hr hm
    (by omega) hrB hmB
  rw [hin, hout, mul_one] at hkey
  have hcp : cutPeriod (Nat.lcm r m) B = 1 := by
    have h1 : min C (cutPeriod (Nat.lcm r m) B) ≤ 1 := hkey
    have h2 : 0 < cutPeriod (Nat.lcm r m) B := cutPeriod_pos hL
    rcases le_total C (cutPeriod (Nat.lcm r m) B) with h | h
    · rw [min_eq_left h] at h1; omega
    · rw [min_eq_right h] at h1; omega
  have hquot : Nat.lcm r m / Nat.gcd (Nat.lcm r m) B = 1 := hcp
  have hdvd : Nat.gcd (Nat.lcm r m) B ∣ Nat.lcm r m := Nat.gcd_dvd_left _ _
  have heq : Nat.gcd (Nat.lcm r m) B = Nat.lcm r m := by
    have hdc : (Nat.lcm r m / Nat.gcd (Nat.lcm r m) B) * Nat.gcd (Nat.lcm r m) B
        = Nat.lcm r m := Nat.div_mul_cancel hdvd
    rwa [hquot, one_mul] at hdc
  calc Nat.lcm r m = Nat.gcd (Nat.lcm r m) B := heq.symm
    _ ∣ B := Nat.gcd_dvd_right _ _

end Complementarity

end ShorIrreducible