import Novelty.ShorCutRankSharp
import Novelty.ShorQFTOutput

/-! # The QFT *output* state is entangled too

A common intuition about Shor's algorithm is that the QFT output is "nearly a
single basis state", so that only the *input* of the QFT is hard to represent
classically.  This file refutes that intuition inside the model: the output of
the QFT on a comb of period `r` in a register of size `Q = r · m` is again a
comb — of period `m`, with unit-modulus phases — and therefore has exactly the
same kind of exponential Schmidt rank across a register cut.

* `outputCutMatrix_eq_diagonal_mul` : the output state across a cut is the input
  comb of period `m` conjugated by two *diagonal unitaries* (a row phase
  `ζ^{j b}` and a column phase `ζ^{j B c}`);
* `schmidtRank_outputCut` : hence its Schmidt rank is exactly
  `min C (m / gcd(m, B))`, the same formula as for the input with `r` replaced
  by `m = Q / r`;
* `two_le_schmidtRank_outputCut` : the output is *not* a product state across
  the cut whenever `m ∤ B` — in particular it is not a single basis state;
* `not_hasBondDim_outputCut` : the bond-dimension obstruction applies at the
  output endpoint of the QFT as well as at the input.

Combined with `norm_combDFT` (all `r` surviving amplitudes have equal modulus)
this settles the "both endpoints of the QFT are entangled" claim.
-/

open Finset Matrix

namespace ShorIrreducible

open IITTensorNetwork

section OutputState

variable {B C m j Q : ℕ} [NeZero m] {amp : ℝ}

/-- The QFT output state of a comb of period `r` in a register of size
`Q = r · m`, presented across the cut `x = b + B · c`.  Its support is the set
of multiples of `m`, and its amplitudes are `amp` times a phase. -/
noncomputable def outputCutMatrix (B C m j Q : ℕ) (amp : ℝ) : Matrix (Fin B) (Fin C) ℂ :=
  fun b c =>
    if m ∣ ((b : ℕ) + B * (c : ℕ)) then (amp : ℂ) * zeta Q ^ (j * ((b : ℕ) + B * (c : ℕ)))
    else 0

/-- **The QFT output across a cut is the period-`m` comb conjugated by diagonal
phase matrices.** -/
theorem outputCutMatrix_eq_diagonal_mul (B C m j Q : ℕ) (amp : ℝ) :
    outputCutMatrix B C m j Q amp
      = Matrix.diagonal (fun b : Fin B => zeta Q ^ (j * (b : ℕ)))
          * combCutMatrix B C m 0 amp
          * Matrix.diagonal (fun c : Fin C => zeta Q ^ (j * (B * (c : ℕ)))) := by
  ext b c
  rw [Matrix.mul_assoc, Matrix.diagonal_mul, Matrix.mul_diagonal]
  by_cases h : m ∣ ((b : ℕ) + B * (c : ℕ))
  · have hmod : ((b : ℕ) + B * (c : ℕ)) % m = 0 % m := by
      rw [Nat.zero_mod]
      exact Nat.dvd_iff_mod_eq_zero.mp h
    rw [outputCutMatrix, if_pos h, combCutMatrix, if_pos hmod,
      show j * ((b : ℕ) + B * (c : ℕ)) = j * (b : ℕ) + j * (B * (c : ℕ)) by ring, pow_add]
    ring
  · have hmod : ¬ ((b : ℕ) + B * (c : ℕ)) % m = 0 % m := by
      rw [Nat.zero_mod]
      exact fun hc => h (Nat.dvd_iff_mod_eq_zero.mpr hc)
    rw [outputCutMatrix, if_neg h, combCutMatrix, if_neg hmod]
    ring

lemma isUnit_det_diagonal_zeta {n : ℕ} (f : Fin n → ℕ) (Q : ℕ) :
    IsUnit (Matrix.diagonal (fun i : Fin n => zeta Q ^ (f i))).det := by
  rw [Matrix.det_diagonal]
  refine IsUnit.mk0 _ (Finset.prod_ne_zero_iff.mpr fun i _ => ?_)
  exact pow_ne_zero _ (Complex.exp_ne_zero _)

/-- **The Schmidt rank of the QFT output across a cut**: the same formula as for
the input comb, with the period `r` replaced by `m = Q / r`. -/
theorem schmidtRank_outputCut (hamp : amp ≠ 0) (hm : 0 < m) (hB : m ≤ B) :
    schmidtRank (outputCutMatrix B C m j Q amp) = min C (cutPeriod m B) := by
  rw [schmidtRank, outputCutMatrix_eq_diagonal_mul,
    Matrix.rank_mul_eq_left_of_isUnit_det _ _ (isUnit_det_diagonal_zeta _ _),
    Matrix.rank_mul_eq_right_of_isUnit_det _ _ (isUnit_det_diagonal_zeta _ _),
    ← schmidtRank, schmidtRank_combCut_sharp hamp hm hB]

/-- **The QFT output is not a product state across the cut** — a fortiori not a
single basis state — as soon as the block size does not resolve the output
period. -/
theorem two_le_schmidtRank_outputCut (hamp : amp ≠ 0) (hm : 0 < m) (hB : m ≤ B)
    (hC : 2 ≤ C) (hndvd : ¬ m ∣ B) :
    2 ≤ schmidtRank (outputCutMatrix B C m j Q amp) := by
  rw [schmidtRank_outputCut hamp hm hB]
  refine le_min hC ?_
  by_contra hcon
  push_neg at hcon
  have hpos : 0 < cutPeriod m B := cutPeriod_pos hm
  have hone : cutPeriod m B = 1 := by omega
  have hgcd : Nat.gcd m B = m := by
    have hdvd : Nat.gcd m B ∣ m := Nat.gcd_dvd_left m B
    have hmul : Nat.gcd m B * (m / Nat.gcd m B) = m := Nat.mul_div_cancel' hdvd
    rw [cutPeriod] at hone
    rw [hone, mul_one] at hmul
    exact hmul
  exact hndvd (hgcd ▸ Nat.gcd_dvd_right m B)

/-- The tensor-network obstruction at the *output* endpoint of the QFT. -/
theorem not_hasBondDim_outputCut (hamp : amp ≠ 0) (hm : 0 < m) (hB : m ≤ B) {χ : ℕ}
    (hχ : χ < min C (cutPeriod m B)) : ¬ HasBondDim (outputCutMatrix B C m j Q amp) χ := by
  intro h
  have := schmidtRank_le_of_hasBondDim h
  rw [schmidtRank_outputCut hamp hm hB] at this
  exact absurd this (not_le.mpr hχ)

end OutputState

end ShorIrreducible