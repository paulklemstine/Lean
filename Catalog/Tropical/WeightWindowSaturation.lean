import Tropical.WeightExponentDial

/-!
# Window saturation does not transfer from `1/ℓ` to `1/√ℓ`

The exp-586 erratum leaves a **named open check**: the window-location saturation
`B* = 400` was measured under the harmonic weight `1/ℓ`, and its transfer to the fitted
`√`-weight was flagged as unverified.  This file settles the underlying analytic question
in the negative, in the following precise sense.

For a dyadic-type window `[B, 4B)` define the *window tail mass*
`T_α(B) = ∑_{B ≤ ℓ < 4B} ℓ^(-α)`.  Then

* `WindowSaturation.windowTail_bounds` : `3·4^(-α) · B^(1-α) ≤ T_α(B) ≤ 3 · B^(1-α)`
  for every `α ≥ 0` and `B ≥ 1`.  The window mass is therefore *exactly* of order
  `B^(1-α)`, so the exponent `α = 1` is the critical value separating bounded from
  divergent window mass.
* `WindowSaturation.windowTail_harmonic_le_three` : under `α = 1` every window carries
  mass at most `3`, uniformly in `B` — the analytic reason a saturation scale `B*` can
  exist at all under the harmonic weight.
* `WindowSaturation.windowTail_sqrt_unbounded` : under the fitted `α = 1/2` the window
  mass is *unbounded* in `B` (it grows like `(3/2)·√B`).
* `WindowSaturation.saturation_does_not_transfer` : consequently no uniform bound of the
  harmonic kind holds for the `√`-weight.  The measured saturation `B* = 400` is a
  statement about the harmonic instrument, and it cannot be re-used verbatim after the
  weight refinement.

(The statements are proved for the full integer window; restricting to primes only removes
mass, and the divergence statement is proved by exhibiting explicit windows, so nothing
here depends on prime-counting input.)
-/

open Finset

namespace WindowSaturation

open WeightDial

/-- Mass carried by the window `[B, 4B)` at weight exponent `α`. -/
noncomputable def windowTail (α : ℝ) (B : ℕ) : ℝ :=
  ∑ l ∈ Finset.Ico B (4 * B), (l : ℝ) ^ (-α)

lemma card_window (B : ℕ) : (Finset.Ico B (4 * B)).card = 3 * B := by
  rw [Nat.card_Ico]
  omega

/-- Two-sided estimate: the window mass is of exact order `B^(1-α)`. -/
theorem windowTail_bounds {B : ℕ} (hB : 1 ≤ B) {α : ℝ} (hα : 0 ≤ α) :
    3 * (4 : ℝ) ^ (-α) * (B : ℝ) ^ (1 - α) ≤ windowTail α B ∧
      windowTail α B ≤ 3 * (B : ℝ) ^ (1 - α) := by
  have hB0 : (0 : ℝ) < (B : ℝ) := by exact_mod_cast hB
  have hsplit : (B : ℝ) ^ (1 - α) = (B : ℝ) * (B : ℝ) ^ (-α) := by
    rw [show (1 : ℝ) - α = 1 + -α by ring, Real.rpow_add hB0, Real.rpow_one]
  constructor
  · have hterm : ∀ l ∈ Finset.Ico B (4 * B),
        (4 : ℝ) ^ (-α) * (B : ℝ) ^ (-α) ≤ (l : ℝ) ^ (-α) := by
      intro l hl
      obtain ⟨hl1, hl2⟩ := Finset.mem_Ico.1 hl
      have hl0 : (0 : ℝ) < (l : ℝ) := by
        have : 1 ≤ l := le_trans hB hl1
        exact_mod_cast this
      have hle : (l : ℝ) ≤ 4 * (B : ℝ) := by
        have : (l : ℝ) ≤ ((4 * B : ℕ) : ℝ) := by exact_mod_cast le_of_lt hl2
        push_cast at this; linarith
      rw [← Real.mul_rpow (by norm_num) (le_of_lt hB0), Real.rpow_neg (by positivity),
        Real.rpow_neg (le_of_lt hl0)]
      exact inv_anti₀ (Real.rpow_pos_of_pos hl0 α)
        (Real.rpow_le_rpow (le_of_lt hl0) hle hα)
    calc 3 * (4 : ℝ) ^ (-α) * (B : ℝ) ^ (1 - α)
        = (3 * B : ℕ) * ((4 : ℝ) ^ (-α) * (B : ℝ) ^ (-α)) := by
          rw [hsplit]; push_cast; ring
      _ = ∑ _l ∈ Finset.Ico B (4 * B), ((4 : ℝ) ^ (-α) * (B : ℝ) ^ (-α)) := by
          rw [Finset.sum_const, nsmul_eq_mul, card_window]
      _ ≤ windowTail α B := Finset.sum_le_sum hterm
  · have hterm : ∀ l ∈ Finset.Ico B (4 * B), (l : ℝ) ^ (-α) ≤ (B : ℝ) ^ (-α) := by
      intro l hl
      obtain ⟨hl1, _⟩ := Finset.mem_Ico.1 hl
      have hl0 : (0 : ℝ) < (l : ℝ) := by
        have : 1 ≤ l := le_trans hB hl1
        exact_mod_cast this
      have hBl : (B : ℝ) ≤ (l : ℝ) := by exact_mod_cast hl1
      rw [Real.rpow_neg (le_of_lt hB0), Real.rpow_neg (le_of_lt hl0)]
      exact inv_anti₀ (Real.rpow_pos_of_pos hB0 α) (Real.rpow_le_rpow (le_of_lt hB0) hBl hα)
    calc windowTail α B ≤ ∑ _l ∈ Finset.Ico B (4 * B), (B : ℝ) ^ (-α) :=
          Finset.sum_le_sum hterm
      _ = (3 * B : ℕ) * (B : ℝ) ^ (-α) := by
          rw [Finset.sum_const, nsmul_eq_mul, card_window]
      _ = 3 * (B : ℝ) ^ (1 - α) := by rw [hsplit]; push_cast; ring

/-- **Under the harmonic weight the window mass is uniformly bounded** — this is what makes
a finite saturation scale `B*` meaningful for `1/ℓ`. -/
theorem windowTail_harmonic_le_three {B : ℕ} (hB : 1 ≤ B) : windowTail 1 B ≤ 3 := by
  have h := (windowTail_bounds hB (α := 1) zero_le_one).2
  have hB0 : (0 : ℝ) < (B : ℝ) := by exact_mod_cast hB
  rwa [sub_self, Real.rpow_zero, mul_one] at h

/-- At the fitted exponent the square window `[n², 4n²)` carries mass at least `3n/2`. -/
theorem windowTail_sqrt_ge {n : ℕ} (hn : 1 ≤ n) :
    (3 : ℝ) / 2 * n ≤ windowTail (1 / 2) (n ^ 2) := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hB : 1 ≤ n ^ 2 := Nat.one_le_pow _ _ hn
  have h := (windowTail_bounds hB (α := 1 / 2) (by norm_num)).1
  have hcast : ((n ^ 2 : ℕ) : ℝ) = (n : ℝ) ^ (2 : ℕ) := by push_cast; ring
  have hpow : ((n ^ 2 : ℕ) : ℝ) ^ (1 - 1 / 2 : ℝ) = (n : ℝ) := by
    rw [hcast, ← Real.rpow_natCast (n : ℝ) 2, ← Real.rpow_mul (le_of_lt hn0)]
    norm_num
  have h4 : (4 : ℝ) ^ (-(1 / 2) : ℝ) = 1 / 2 := by
    have : (4 : ℝ) = (2 : ℝ) ^ (2 : ℕ) := by norm_num
    rw [this, ← Real.rpow_natCast (2 : ℝ) 2, ← Real.rpow_mul (by norm_num)]
    norm_num
  rw [hpow, h4] at h
  linarith

/-- **Under the fitted `√`-weight the window mass is unbounded.** -/
theorem windowTail_sqrt_unbounded (C : ℝ) : ∃ B : ℕ, 1 ≤ B ∧ C < windowTail (1 / 2) B := by
  obtain ⟨n, hn⟩ := exists_nat_gt (max C 1)
  have hnR : (1 : ℝ) < (n : ℝ) := lt_of_le_of_lt (le_max_right C 1) hn
  have hn1 : 1 ≤ n := by
    have : 1 < n := by exact_mod_cast hnR
    omega
  refine ⟨n ^ 2, Nat.one_le_pow _ _ hn1, ?_⟩
  have hge := windowTail_sqrt_ge hn1
  have hCn : C < (n : ℝ) := lt_of_le_of_lt (le_max_left C 1) hn
  linarith

/-- **The named open check, resolved negatively.**  A uniform window-mass bound of the kind
enjoyed by the harmonic weight fails for the `√`-weight, so a saturation scale measured
under `1/ℓ` carries no automatic meaning under `1/√ℓ`. -/
theorem saturation_does_not_transfer :
    (∀ B : ℕ, 1 ≤ B → windowTail 1 B ≤ 3) ∧
      ¬ ∃ C : ℝ, ∀ B : ℕ, 1 ≤ B → windowTail (1 / 2) B ≤ C := by
  refine ⟨fun B hB => windowTail_harmonic_le_three hB, ?_⟩
  rintro ⟨C, hC⟩
  obtain ⟨B, hB1, hB2⟩ := windowTail_sqrt_unbounded C
  exact absurd (hC B hB1) (not_le.2 hB2)

end WindowSaturation