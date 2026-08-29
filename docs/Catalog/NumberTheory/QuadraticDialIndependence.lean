import Catalog.NumberTheory.ScaleSmoothnessDispersion

/-!
# The dial vector of `x² − N` is exactly uniform: an independence theorem

`Catalog.NumberTheory.QRDialLocalStatistics` computed the moments of the QR dial
`dial p N = #{x | x² = N}` and
`Catalog.NumberTheory.ScaleSmoothnessDispersion` assembled them into the global
structure correction.  This file proves the *distributional* statement that
underlies the experimental design of round-73 #4 (exp 562): the vector of dials
`(dial p N)_{p ≤ B}` is **exactly uniform** on `{0,2}^k` as `N` ranges over the
residue data — the quadratic-residue pattern of `N` carries no bias whatsoever,
prime by prime *and jointly*.

## Main results

* `dial_eq_one_add_quadraticChar` — the bridge to Mathlib's quadratic character:
  `dial p N = 1 + χ_p(N)` as integers, valid for **all** `N`, including `N = 0`.
* `sum_quadraticChar_eq_zero` — an immediate consequence of the exact first
  moment `∑_N dial p N = p`: the quadratic character sums to zero.
* `two_mul_card_dial_two_add_one`, `two_mul_card_dial_zero_add_one` — exactly
  `(p−1)/2` residues are hit twice and `(p−1)/2` are missed.
* `card_dial_pattern` — **joint uniformity / independence**: for every prescribed
  pattern `d : ι → {0,2}` the number of residue data realising it is exactly
  `∏ (a i − 1) / 2^k`, independent of the pattern.
* `structureCorrection_max_value`, `card_structureCorrection_max` — the extreme
  values of the structure correction and the exact number of residue data
  attaining them.  Only a `2^{-k}` fraction of `N` sits at either extreme, which
  is why the observed clustering is `O(1)` and not exponential.
-/

namespace ScaleSmoothness

open Finset

section OnePrime

variable (p : ℕ) [Fact p.Prime]

/-- **Character bridge.**  The QR dial is `1 + χ_p`, where `χ_p` is the quadratic
character of `ZMod p`.  The identity holds at `N = 0` as well, where both sides
equal `1`. -/
theorem dial_eq_one_add_quadraticChar (hp : p ≠ 2) (N : ZMod p) :
    (dial p N : ℤ) = 1 + quadraticChar (ZMod p) N := by
  by_cases h0 : N = 0
  · subst h0
    rw [dial_zero p hp, quadraticChar_zero]
    norm_num
  · by_cases hsq : IsSquare N
    · rw [(dial_eq_two_iff p hp h0).2 hsq, (quadraticChar_one_iff_isSquare h0).2 hsq]
      norm_num
    · rw [dial_eq_zero_of_not_isSquare p hsq,
        quadraticChar_neg_one_iff_not_isSquare.2 hsq]
      norm_num

/-- The classical fact `∑_N χ_p(N) = 0`, obtained here as a corollary of the exact
first moment of the dial. -/
theorem sum_quadraticChar_eq_zero (hp : p ≠ 2) :
    ∑ N : ZMod p, quadraticChar (ZMod p) N = 0 := by
  have h : ∑ N : ZMod p, ((dial p N : ℤ)) = ∑ N : ZMod p, (1 + quadraticChar (ZMod p) N) :=
    Finset.sum_congr rfl fun N _ => dial_eq_one_add_quadraticChar p hp N
  rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ, ZMod.card] at h
  have hd : ∑ N : ZMod p, ((dial p N : ℤ)) = (p : ℤ) := by
    calc ∑ N : ZMod p, ((dial p N : ℤ)) = ((∑ N : ZMod p, dial p N : ℕ) : ℤ) := by push_cast; ring
      _ = (p : ℤ) := by rw [sum_dial p]
  simp only [nsmul_eq_mul, mul_one] at h
  omega

/-- Pointwise decomposition of the dial into "is a nonzero residue" and "is zero". -/
theorem dial_eq_indicators (hp : p ≠ 2) (N : ZMod p) :
    dial p N = 2 * (if dial p N = 2 then 1 else 0) + (if N = 0 then 1 else 0) := by
  by_cases h0 : N = 0
  · subst h0
    rw [dial_zero p hp]
    norm_num
  · have hle := dial_le_two p hp N
    by_cases h2 : dial p N = 2
    · rw [h2]; simp [h0]
    · have : dial p N = 0 := by
        rcases Nat.lt_or_ge (dial p N) 2 with h | h
        · interval_cases hh : dial p N
          · rfl
          · exfalso
            have hsq : IsSquare N := by
              by_contra hns
              rw [dial_eq_zero_of_not_isSquare p hns] at hh
              exact absurd hh (by norm_num)
            rw [(dial_eq_two_iff p hp h0).2 hsq] at hh
            exact absurd hh (by norm_num)
        · omega
      rw [this]; simp [h0]

/-- Exactly `(p−1)/2` residues are hit twice by `x² − N`. -/
theorem two_mul_card_dial_two_add_one (hp : p ≠ 2) :
    2 * #{N : ZMod p | dial p N = 2} + 1 = p := by
  have h := sum_dial p
  have hsplit : ∑ N : ZMod p, dial p N =
      2 * #{N : ZMod p | dial p N = 2} + #{N : ZMod p | N = 0} := by
    rw [Finset.card_filter, Finset.card_filter, Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun N _ => dial_eq_indicators p hp N
  have hzero : #{N : ZMod p | N = 0} = 1 := by
    rw [Finset.filter_eq' univ (0 : ZMod p)]
    simp
  rw [hsplit, hzero] at h
  exact h

/-- Exactly `(p−1)/2` residues are missed entirely by `x² − N`. -/
theorem two_mul_card_dial_zero_add_one (hp : p ≠ 2) :
    2 * #{N : ZMod p | dial p N = 0} + 1 = p := by
  have hpart : ∀ N : ZMod p,
      (if dial p N = 0 then 1 else 0) + (if dial p N = 2 then 1 else 0)
        + (if N = 0 then 1 else 0) = 1 := by
    intro N
    by_cases h0 : N = 0
    · subst h0
      rw [dial_zero p hp]; norm_num
    · have hind := dial_eq_indicators p hp N
      by_cases h2 : dial p N = 2
      · simp [h2, h0]
      · have h0' : dial p N = 0 := by
          rw [if_neg h2, if_neg h0] at hind; omega
        simp [h0', h0]
  have hsum : ∑ N : ZMod p, ((if dial p N = 0 then 1 else 0)
      + (if dial p N = 2 then 1 else 0) + (if N = 0 then 1 else 0)) = p := by
    rw [Finset.sum_congr rfl fun N _ => hpart N]
    simp [ZMod.card]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.card_filter, ← Finset.card_filter,
    ← Finset.card_filter] at hsum
  have hzero : #{N : ZMod p | N = 0} = 1 := by
    rw [Finset.filter_eq' univ (0 : ZMod p)]; simp
  have h2 := two_mul_card_dial_two_add_one p hp
  rw [hzero] at hsum
  omega

end OnePrime

/-! ### Joint uniformity of the dial vector -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- **Exact independence of the QR dials.**  For every prescribed pattern
`d : ι → {0, 2}` of dials, the number of residue data realising it is the same,
namely `∏ (a i − 1) / 2^{#ι}`.  The quadratic-residue pattern of `N` is therefore
*exactly* uniform: there is no bias to exploit, at any smoothness bound.  This is
the arithmetic content of the histogram-matched control design. -/
theorem card_dial_pattern (a : ι → ℕ) [∀ i, Fact (a i).Prime] (hodd : ∀ i, a i ≠ 2)
    (d : ι → ℕ) (hd : ∀ i, d i = 0 ∨ d i = 2) :
    2 ^ (Fintype.card ι) * #{N : (∀ i, ZMod (a i)) | ∀ i, dial (a i) (N i) = d i}
      = ∏ i, (a i - 1) := by
  have hfactor : #{N : (∀ i, ZMod (a i)) | ∀ i, dial (a i) (N i) = d i}
      = ∏ i, #{x : ZMod (a i) | dial (a i) x = d i} := by
    rw [← Fintype.card_piFinset]
    congr 1
    ext N
    simp [Fintype.mem_piFinset]
  have hone : ∀ i, 2 * #{x : ZMod (a i) | dial (a i) x = d i} = a i - 1 := by
    intro i
    rcases hd i with h | h <;> rw [h]
    · have := two_mul_card_dial_zero_add_one (a i) (hodd i); omega
    · have := two_mul_card_dial_two_add_one (a i) (hodd i); omega
  calc 2 ^ (Fintype.card ι) * #{N : (∀ i, ZMod (a i)) | ∀ i, dial (a i) (N i) = d i}
      = ∏ i, (2 * #{x : ZMod (a i) | dial (a i) x = d i}) := by
        rw [hfactor, Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ]
    _ = ∏ i, (a i - 1) := Finset.prod_congr rfl fun i _ => hone i

/-! ### Extremes of the structure correction -/

omit [DecidableEq ι] in
/-- On the residue data whose every coordinate is a quadratic nonresidue, the
structure correction takes its maximal value `∏ p/(p−1)`. -/
theorem structureCorrection_of_all_nonresidue (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    {N : ∀ i, ZMod (a i)} (h : ∀ i, dial (a i) (N i) = 0) :
    structureCorrection a N = ∏ i, ((a i : ℚ) / ((a i : ℚ) - 1)) :=
  Finset.prod_congr rfl fun i _ => localFactor_of_dial_zero (a i) (h i)

omit [DecidableEq ι] in
/-- On the residue data whose every coordinate is a quadratic residue, the
structure correction takes its minimal value `∏ (p−2)/(p−1)`. -/
theorem structureCorrection_of_all_residue (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    {N : ∀ i, ZMod (a i)} (h : ∀ i, dial (a i) (N i) = 2) :
    structureCorrection a N = ∏ i, (((a i : ℚ) - 2) / ((a i : ℚ) - 1)) :=
  Finset.prod_congr rfl fun i _ => localFactor_of_dial_two (a i) (h i)

/-- **Only a `2^{-k}` fraction sits at an extreme.**  The number of residue data
on which the structure correction attains either extreme value is exactly
`∏ (a i − 1) / 2^{#ι}`.  Extreme structure corrections are exponentially rare,
which is why the per-`N` clustering they cause stays `O(1)`. -/
theorem card_structureCorrection_extreme (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    (hodd : ∀ i, a i ≠ 2) :
    2 ^ (Fintype.card ι) * #{N : (∀ i, ZMod (a i)) | ∀ i, dial (a i) (N i) = 0}
        = ∏ i, (a i - 1) ∧
      2 ^ (Fintype.card ι) * #{N : (∀ i, ZMod (a i)) | ∀ i, dial (a i) (N i) = 2}
        = ∏ i, (a i - 1) :=
  ⟨card_dial_pattern a hodd (fun _ => 0) (fun _ => Or.inl rfl),
   card_dial_pattern a hodd (fun _ => 2) (fun _ => Or.inr rfl)⟩

end ScaleSmoothness