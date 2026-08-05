import Mathlib

/-!
# Exponential bounds for diagonal Ramsey numbers: the analytic interface

This file isolates the final quantitative step used by sub-four diagonal Ramsey
bounds.  The combinatorial part of such an argument typically produces a fixed
multiplicative saving `q < 1` per clique size, giving a bound `(4q)^k`.  The
results below convert that estimate, without asymptotic notation, into the
standard form `(4 - ε)^k` with one fixed `ε > 0`.

The development is deliberately parameterized by the catalog's Ramsey-number
sequence: it makes no new graph or Ramsey-number definition.  Consequently the
lemmas can be applied directly to any existing encoding of diagonal Ramsey
numbers.
-/

namespace RamseyBounds

/-- A sequence has an eventual diagonal-Ramsey-style upper bound with base
strictly below four. -/
def HasSubFourUpperBound (r : ℕ → ℕ) : Prop :=
  ∃ ε : ℝ, 0 < ε ∧ ε < 4 ∧ ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ (4 - ε) ^ k

/-- A fixed proportional saving over the classical base four. -/
def HasProportionalSaving (r : ℕ → ℕ) : Prop :=
  ∃ q : ℝ, 0 < q ∧ q < 1 ∧ ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ (4 * q) ^ k

/-- The exact change of variables between a proportional saving `q` and an
additive saving `ε`. -/
theorem four_mul_eq_four_sub_saving {q : ℝ} :
    4 * q = 4 - 4 * (1 - q) := by
  ring

/-- A positive proportional saving produces a positive additive gap below four.
This is the final algebraic passage from a bound of the shape `(4q)^k` to the
usual `(4-ε)^k` formulation. -/
theorem hasSubFourUpperBound_of_proportionalSaving {r : ℕ → ℕ}
    (h : HasProportionalSaving r) : HasSubFourUpperBound r := by
  obtain ⟨q, hq_pos, hq_lt_one, k₀, hk₀⟩ := h
  use 4 * (1 - q)
  refine ⟨by linarith, by linarith, k₀, ?_⟩
  intro k hk
  have := hk₀ k hk
  rwa [four_mul_eq_four_sub_saving] at this

/-- Conversely, every eventual `(4-ε)^k` bound with `0 < ε < 4` can be
normalized as `(4q)^k` for a fixed `q ∈ (0,1)`. -/
theorem hasProportionalSaving_of_hasSubFourUpperBound {r : ℕ → ℕ}
    (h : HasSubFourUpperBound r) : HasProportionalSaving r := by
  obtain ⟨ε, hε_pos, hε_lt_4, k₀, hr⟩ := h
  use (4 - ε) / 4
  refine ⟨by linarith, by linarith, k₀, ?_⟩
  intro k hk
  have heq : (4 - ε : ℝ) = 4 * ((4 - ε) / 4) := by ring
  rw [heq] at hr
  exact hr k hk

/-- The additive-gap and proportional-saving formulations are equivalent. -/
theorem subFour_iff_proportionalSaving (r : ℕ → ℕ) :
    HasSubFourUpperBound r ↔ HasProportionalSaving r :=
  ⟨hasProportionalSaving_of_hasSubFourUpperBound,
    hasSubFourUpperBound_of_proportionalSaving⟩

/-- An exponentially decaying correction to the base four gives an explicit
sub-four gap `ε = 4(1-exp(-δ))`. -/
theorem hasSubFourUpperBound_of_expSaving {r : ℕ → ℕ} {δ : ℝ} (hδ : 0 < δ)
    (h : ∃ k₀ : ℕ, ∀ k ≥ k₀,
      (r k : ℝ) ≤ (4 * Real.exp (-δ)) ^ k) :
    HasSubFourUpperBound r := by
  -- Set ε = 4 * (1 - exp(-δ))
  use 4 * (1 - Real.exp (-δ))
  -- Show ε > 0: since δ > 0, exp(-δ) < 1, so 1 - exp(-δ) > 0
  have hexp_lt_one : Real.exp (-δ) < 1 := by
    rw [Real.exp_lt_one_iff]
    exact neg_neg_of_pos hδ
  have hε_pos : 0 < 4 * (1 - Real.exp (-δ)) := by linarith
  refine ⟨hε_pos, ?_, ?_⟩
  -- Show ε < 4: since exp(-δ) > 0, we have 1 - exp(-δ) < 1, so 4*(1 - exp(-δ)) < 4
  have hexp_pos : 0 < Real.exp (-δ) := Real.exp_pos _
  linarith
  -- Need to convert (4 * exp(-δ))^k to (4 - 4*(1 - exp(-δ)))^k
  obtain ⟨k₀, hk₀⟩ := h
  exact ⟨k₀, fun k hk => by
    have : (4 : ℝ) * Real.exp (-δ) = 4 - 4 * (1 - Real.exp (-δ)) := by ring
    rw [← this]
    exact hk₀ k hk⟩

/-- A pointwise multiplicative saving is stable under replacing the saving
factor by a larger one.  This permits estimates to be rounded up to a simpler
constant without losing the exponential improvement. -/
theorem proportionalSaving_mono {r : ℕ → ℕ} {q q' : ℝ}
    (hq : 0 < q) (hqq' : q ≤ q')
    (h : ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ (4 * q) ^ k) :
    ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ (4 * q') ^ k := by
  obtain ⟨k₀, hk⟩ := h
  use k₀
  intro k hk'
  exact le_trans (hk k hk') (by gcongr)

/-- A fixed polynomial loss does not destroy a strict exponential saving.

More precisely, if `r k` is eventually at most `k^d (4q)^k` for one fixed
`q ∈ (0,1)`, then it is eventually bounded by `(4-ε)^k` for a fixed positive
`ε`.  The proof absorbs the polynomial into the larger saving factor
`q' = (q+1)/2`, which is still strictly below one. -/
theorem hasSubFourUpperBound_of_polynomialLoss {r : ℕ → ℕ} (d : ℕ)
    {q : ℝ} (hq : 0 < q) (hq_lt_one : q < 1)
    (h : ∃ k₀ : ℕ, ∀ k ≥ k₀,
      (r k : ℝ) ≤ (k : ℝ) ^ d * (4 * q) ^ k) :
    HasSubFourUpperBound r := by
  let q' : ℝ := (q + 1) / 2
  have hq'_pos : 0 < q' := by
    dsimp [q']
    linarith
  have hq'_lt_one : q' < 1 := by
    dsimp [q']
    linarith
  have hbase : ‖(4 * q : ℝ)‖ < 4 * q' := by
    rw [Real.norm_eq_abs, abs_of_pos (mul_pos (by norm_num) hq)]
    dsimp [q']
    linarith
  have hasym :=
    isLittleO_pow_const_mul_const_pow_const_pow_of_norm_lt d hbase
  have hev : ∀ᶠ k : ℕ in Filter.atTop,
      ‖(k : ℝ) ^ d * (4 * q) ^ k‖ ≤ 1 * ‖(4 * q') ^ k‖ :=
    hasym.bound zero_lt_one
  rw [Filter.eventually_atTop] at hev
  obtain ⟨N, hN⟩ := hev
  obtain ⟨k₀, hk₀⟩ := h
  use 4 * (1 - q')
  refine ⟨by nlinarith, by nlinarith, max N k₀, ?_⟩
  intro k hk
  have hkN : N ≤ k := le_trans (le_max_left _ _) hk
  have hkk₀ : k₀ ≤ k := le_trans (le_max_right _ _) hk
  calc
    (r k : ℝ) ≤ (k : ℝ) ^ d * (4 * q) ^ k := hk₀ k hkk₀
    _ ≤ (4 * q') ^ k := by
      have hb := hN k hkN
      rw [Real.norm_eq_abs, Real.norm_eq_abs, one_mul,
        abs_of_nonneg (mul_nonneg (pow_nonneg (Nat.cast_nonneg _) _)
          (pow_nonneg (le_of_lt (mul_pos (by norm_num) hq)) _)),
        abs_of_nonneg
          (pow_nonneg (le_of_lt (mul_pos (by norm_num) hq'_pos)) _)] at hb
      exact hb
    _ = (4 - 4 * (1 - q')) ^ k := by ring_nf

end RamseyBounds