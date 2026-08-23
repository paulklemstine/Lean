import Pythagorean.PrefixApproximation

/-!
# Irrationality is *exactly* aperiodicity of the decimal expansion

`Pyth.not_irrational_ofDigits_of_eventually_periodic` showed that an eventually periodic digit
sequence yields a rational number.  Here we prove the converse — a rational number has an
eventually periodic decimal expansion — by the classical long-division / pigeonhole argument,
phrased as a statement about the orbit of the fractional-part map `t ↦ frac(10·t)`.

Combining the two directions gives the exact digit-theoretic content of irrationality
(`Pyth.irrational_iff_not_eventually_periodic`):

> for `x ∈ [0,1)`, `x` is irrational **iff** its decimal digit sequence is not eventually
> periodic.

This is a sharp boundary statement for the whole cycle: aperiodicity is *all* that
irrationality gives.  Everything else — digit frequencies, normality, autocorrelation — is
left completely free, as the witnesses of the companion files show, and as the main theorems
`Pyth.prefix_determines_no_digit_law` and `Pyth.prefix_determines_no_autocorrelation_law`
quantify.
-/

namespace Pyth

open Filter Real

/-! ## Digits of a shifted fractional part -/

/-- Cutting the expansion at position `k` replaces `x` by the fractional part of `10ᵏ·x`. -/
theorem digits_fract_shift {x : ℝ} (hx : 0 ≤ x) (k j : ℕ) :
    Real.digits x 10 (k + j) = Real.digits (Int.fract ((10:ℝ) ^ k * x)) 10 j := by
  have hy0 : (0:ℝ) ≤ (10:ℝ) ^ k * x := by positivity
  have hI : (0:ℤ) ≤ ⌊(10:ℝ) ^ k * x⌋ := Int.floor_nonneg.mpr hy0
  set N : ℕ := (⌊(10:ℝ) ^ k * x⌋).toNat * 10 ^ (j + 1) with hN
  have htn : ((⌊(10:ℝ) ^ k * x⌋.toNat : ℕ) : ℝ) = (⌊(10:ℝ) ^ k * x⌋ : ℝ) := by
    rw [← Int.cast_natCast, Int.toNat_of_nonneg hI]
  have hcast : ((N : ℕ) : ℝ) = (⌊(10:ℝ) ^ k * x⌋ : ℝ) * 10 ^ (j + 1) := by
    rw [hN, Nat.cast_mul, htn]
    push_cast
    ring
  have hsplit : (⌊(10:ℝ) ^ k * x⌋ : ℝ) + Int.fract ((10:ℝ) ^ k * x) = (10:ℝ) ^ k * x :=
    Int.floor_add_fract _
  have h10 : (10:ℝ) ^ (k + j + 1) = (10:ℝ) ^ k * 10 ^ (j + 1) := by
    rw [show k + j + 1 = k + (j + 1) by omega, pow_add]
  have he : x * (10:ℝ) ^ (k + j + 1)
      = Int.fract ((10:ℝ) ^ k * x) * 10 ^ (j + 1) + (N : ℝ) := by
    rw [hcast]
    calc x * (10:ℝ) ^ (k + j + 1) = ((10:ℝ) ^ k * x) * 10 ^ (j + 1) := by rw [h10]; ring
      _ = ((⌊(10:ℝ) ^ k * x⌋ : ℝ) + Int.fract ((10:ℝ) ^ k * x)) * 10 ^ (j + 1) := by rw [hsplit]
      _ = Int.fract ((10:ℝ) ^ k * x) * 10 ^ (j + 1)
            + (⌊(10:ℝ) ^ k * x⌋ : ℝ) * 10 ^ (j + 1) := by ring
  have hnn : 0 ≤ Int.fract ((10:ℝ) ^ k * x) * (10:ℝ) ^ (j + 1) := by
    have := Int.fract_nonneg ((10:ℝ) ^ k * x)
    positivity
  have hfloor : ⌊x * (10:ℝ) ^ (k + j + 1)⌋₊
      = ⌊Int.fract ((10:ℝ) ^ k * x) * (10:ℝ) ^ (j + 1)⌋₊ + N := by
    rw [he, Nat.floor_add_natCast hnn]
  have hdvd : N % 10 = 0 := by
    have : (10:ℕ) ∣ N := ⟨(⌊(10:ℝ) ^ k * x⌋).toNat * 10 ^ j, by rw [hN]; ring⟩
    omega
  apply Fin.ext
  rw [digits_val, digits_val, hfloor]
  omega

/-! ## Pigeonhole on the fractional-part orbit -/

/-- For a rational number the orbit `k ↦ frac(10ᵏ x)` is finite, so it repeats. -/
theorem exists_fract_eq_of_not_irrational {x : ℝ} (h : ¬ Irrational x) :
    ∃ k₁ k₂ : ℕ, k₁ < k₂ ∧ Int.fract ((10:ℝ) ^ k₁ * x) = Int.fract ((10:ℝ) ^ k₂ * x) := by
  rw [Irrational, not_not] at h
  obtain ⟨q, hq⟩ := h
  have hb : 0 < q.den := q.pos
  have hbR : ((q.den : ℝ)) ≠ 0 := by exact_mod_cast q.den_ne_zero
  -- the orbit is given by the residues of `10ᵏ · num` modulo `den`
  have hfract : ∀ k : ℕ, Int.fract ((10:ℝ) ^ k * x)
      = (((10 ^ k * q.num) % (q.den : ℤ) : ℤ) : ℝ) / (q.den : ℕ) := by
    intro k
    have hx : x = (q.num : ℝ) / (q.den : ℝ) := by rw [← hq, Rat.cast_def]
    have hxk : (10:ℝ) ^ k * x = (((10 ^ k * q.num : ℤ)) : ℝ) / ((q.den : ℕ) : ℝ) := by
      rw [hx]
      push_cast
      field_simp
    rw [hxk, Int.fract_div_intCast_eq_div_intCast_mod]
  set g : ℕ → ℕ := fun k => (((10 ^ k * q.num) % (q.den : ℤ))).toNat with hg
  have hmaps : Set.MapsTo g (Finset.range (q.den + 1)) (Finset.range q.den) := by
    intro k _
    simp only [Finset.coe_range, Set.mem_Iio, hg]
    have h1 : (0:ℤ) ≤ (10 ^ k * q.num) % (q.den : ℤ) :=
      Int.emod_nonneg _ (by exact_mod_cast q.den_ne_zero)
    have h2 : (10 ^ k * q.num) % (q.den : ℤ) < (q.den : ℤ) :=
      Int.emod_lt_of_pos _ (by exact_mod_cast hb)
    omega
  obtain ⟨k₁, hk₁, k₂, hk₂, hne, hgg⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to (by simp) hmaps
  have hZ : ∀ k k' : ℕ, g k = g k' →
      ((10 ^ k * q.num) % (q.den : ℤ)) = ((10 ^ k' * q.num) % (q.den : ℤ)) := by
    intro k k' hkk
    have h1 : (0:ℤ) ≤ (10 ^ k * q.num) % (q.den : ℤ) :=
      Int.emod_nonneg _ (by exact_mod_cast q.den_ne_zero)
    have h2 : (0:ℤ) ≤ (10 ^ k' * q.num) % (q.den : ℤ) :=
      Int.emod_nonneg _ (by exact_mod_cast q.den_ne_zero)
    simp only [hg] at hkk
    omega
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · exact ⟨k₁, k₂, hlt, by rw [hfract, hfract, hZ k₁ k₂ hgg]⟩
  · exact ⟨k₂, k₁, hlt, by rw [hfract, hfract, hZ k₂ k₁ hgg.symm]⟩

/-! ## Rational ⇒ eventually periodic -/

/-- **A rational number has an eventually periodic decimal expansion.** -/
theorem digits_eventually_periodic_of_not_irrational {x : ℝ} (hx : 0 ≤ x) (h : ¬ Irrational x) :
    ∃ n p : ℕ, 0 < p ∧
      ∀ i, Real.digits x 10 (i + p + n) = Real.digits x 10 (i + n) := by
  obtain ⟨k₁, k₂, hlt, heq⟩ := exists_fract_eq_of_not_irrational h
  refine ⟨k₁, k₂ - k₁, by omega, fun i => ?_⟩
  have e1 : i + (k₂ - k₁) + k₁ = k₂ + i := by omega
  have e2 : i + k₁ = k₁ + i := by omega
  rw [e1, e2, digits_fract_shift hx k₂ i, ← heq, ← digits_fract_shift hx k₁ i]

/-! ## The dichotomy -/

/-- **Irrationality is exactly aperiodicity.**  For `x ∈ [0,1)` the decimal expansion of `x`
is eventually periodic if and only if `x` is rational.  This is the *entire* digit-theoretic
content of irrationality: no frequency, normality or correlation statement follows from it. -/
theorem irrational_iff_not_eventually_periodic {x : ℝ} (hx : x ∈ Set.Ico (0:ℝ) 1) :
    Irrational x ↔
      ¬ ∃ n p : ℕ, 0 < p ∧
        ∀ i, Real.digits x 10 (i + p + n) = Real.digits x 10 (i + n) := by
  constructor
  · rintro hirr ⟨n, p, hp, hper⟩
    have hxd : Real.ofDigits (Real.digits x 10) = x :=
      Real.ofDigits_digits (by norm_num) hx
    have hnot := not_irrational_ofDigits_of_eventually_periodic (Real.digits x 10) n p hp hper
    rw [hxd] at hnot
    exact hnot hirr
  · intro hnp
    by_contra hrat
    exact hnp (digits_eventually_periodic_of_not_irrational hx.1 hrat)

/-- The sparse witness is a concrete instance of the dichotomy: it is irrational, hence its
digits are not eventually periodic — even though they are extremely far from equidistributed. -/
theorem sparseReal_not_eventually_periodic :
    ¬ ∃ n p : ℕ, 0 < p ∧
      ∀ i, Real.digits sparseReal 10 (i + p + n) = Real.digits sparseReal 10 (i + n) :=
  (irrational_iff_not_eventually_periodic
    ⟨sparseReal_nonneg, sparseReal_lt_one⟩).mp irrational_sparseReal

end Pyth