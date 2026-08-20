import Mathlib
import Catalog.Shared.RainbowAPSpectrumThreshold

/-!
# Asymptotics of the full-spectrum threshold

We turn the two arithmetic criteria of `Shared.RainbowAPSpectrumThreshold` into real analytic
bounds, showing that for an alphabet with `N ≥ 2` letters

  `(N - 1) * log (N + 1) ≤ spectrumThreshold α ≤ N * log (2 N) + 1`.

Both sides are `N log N (1 + o(1))`, so the threshold is asymptotically `N log N`.
-/

open Finset Real

namespace RainbowAP

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Below `(N-1) log (N+1)` the second-moment criterion applies. -/
lemma pow_lt_succ_mul_pow_sub_one {N m : ℕ} (hN : 2 ≤ N)
    (h : (m : ℝ) < ((N : ℝ) - 1) * Real.log ((N : ℝ) + 1)) :
    N ^ m < (N + 1) * (N - 1) ^ m := by
  have hNge : (2 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < (N : ℝ) - 1 := by linarith
  have hxpos : (0 : ℝ) < (N : ℝ) / ((N : ℝ) - 1) := by positivity
  have hxm1 : (N : ℝ) / ((N : ℝ) - 1) - 1 = 1 / ((N : ℝ) - 1) := by
    field_simp
    ring
  have hlogx : Real.log ((N : ℝ) / ((N : ℝ) - 1)) ≤ 1 / ((N : ℝ) - 1) := by
    have hle := Real.log_le_sub_one_of_pos hxpos
    linarith [hxm1]
  have hmlog : (m : ℝ) * Real.log ((N : ℝ) / ((N : ℝ) - 1)) < Real.log ((N : ℝ) + 1) := by
    have hm0 : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
    have h1 : (m : ℝ) * Real.log ((N : ℝ) / ((N : ℝ) - 1)) ≤ (m : ℝ) * (1 / ((N : ℝ) - 1)) :=
      mul_le_mul_of_nonneg_left hlogx hm0
    have h2 : (m : ℝ) * (1 / ((N : ℝ) - 1)) < Real.log ((N : ℝ) + 1) := by
      rw [mul_one_div, div_lt_iff₀ hNpos]
      linarith [h]
    linarith
  have hxm : ((N : ℝ) / ((N : ℝ) - 1)) ^ m < (N : ℝ) + 1 := by
    have h1 : ((N : ℝ) / ((N : ℝ) - 1)) ^ m
        = Real.exp ((m : ℝ) * Real.log ((N : ℝ) / ((N : ℝ) - 1))) := by
      rw [Real.exp_nat_mul, Real.exp_log hxpos]
    have h2 : Real.exp ((m : ℝ) * Real.log ((N : ℝ) / ((N : ℝ) - 1)))
        < Real.exp (Real.log ((N : ℝ) + 1)) := Real.exp_lt_exp.2 hmlog
    rw [Real.exp_log (by linarith)] at h2
    rw [h1]
    exact h2
  have hden : (0 : ℝ) < ((N : ℝ) - 1) ^ m := by positivity
  have hkey : (N : ℝ) ^ m < ((N : ℝ) + 1) * ((N : ℝ) - 1) ^ m := by
    have hdiv : ((N : ℝ) / ((N : ℝ) - 1)) ^ m = (N : ℝ) ^ m / ((N : ℝ) - 1) ^ m := by
      rw [div_pow]
    rw [hdiv, div_lt_iff₀ hden] at hxm
    linarith [hxm]
  have hcast : ((N - 1 : ℕ) : ℝ) = (N : ℝ) - 1 := by
    have h1 : (1 : ℕ) ≤ N := by omega
    push_cast [Nat.cast_sub h1]
    ring
  have hfin : ((N ^ m : ℕ) : ℝ) < (((N + 1) * (N - 1) ^ m : ℕ) : ℝ) := by
    push_cast [hcast]
    exact hkey
  exact_mod_cast hfin

/-- Above `N log (2N)` the union-bound criterion applies. -/
lemma two_mul_pow_lt_pow {N m : ℕ} (hN : 2 ≤ N)
    (h : (N : ℝ) * Real.log (2 * (N : ℝ)) < m) :
    2 * N * (N - 1) ^ m < N ^ m := by
  have hNge : (2 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
  have hNpos : (0 : ℝ) < (N : ℝ) := by linarith
  have hstep : ((N : ℝ) - 1) / (N : ℝ) ≤ Real.exp (-(1 / (N : ℝ))) := by
    have hexp := Real.add_one_le_exp (-(1 / (N : ℝ)))
    have heq : -(1 / (N : ℝ)) + 1 = ((N : ℝ) - 1) / (N : ℝ) := by
      field_simp
      ring
    linarith [hexp, heq.le, heq.ge]
  have hnonneg : (0 : ℝ) ≤ ((N : ℝ) - 1) / (N : ℝ) := by
    apply div_nonneg <;> linarith
  have hpow : (((N : ℝ) - 1) / (N : ℝ)) ^ m ≤ Real.exp (-((m : ℝ) / (N : ℝ))) := by
    calc (((N : ℝ) - 1) / (N : ℝ)) ^ m ≤ (Real.exp (-(1 / (N : ℝ)))) ^ m :=
          pow_le_pow_left₀ hnonneg hstep m
      _ = Real.exp (-((m : ℝ) / (N : ℝ))) := by
          rw [← Real.exp_nat_mul]
          congr 1
          field_simp
  have hEq : Real.exp (-(Real.log (2 * (N : ℝ)))) = 1 / (2 * (N : ℝ)) := by
    rw [Real.exp_neg, Real.exp_log (by linarith), one_div]
  have hlt : Real.exp (-((m : ℝ) / (N : ℝ))) < 1 / (2 * (N : ℝ)) := by
    have hlog : Real.log (2 * (N : ℝ)) < (m : ℝ) / (N : ℝ) := by
      rw [lt_div_iff₀ hNpos]
      linarith [h]
    have h2 : Real.exp (-((m : ℝ) / (N : ℝ))) < Real.exp (-(Real.log (2 * (N : ℝ)))) :=
      Real.exp_lt_exp.2 (by linarith)
    linarith [hEq.le, hEq.ge, h2]
  have hfinal : 2 * (N : ℝ) * ((N : ℝ) - 1) ^ m < (N : ℝ) ^ m := by
    have hdiv : (((N : ℝ) - 1) / (N : ℝ)) ^ m = ((N : ℝ) - 1) ^ m / (N : ℝ) ^ m := by
      rw [div_pow]
    have hNm : (0 : ℝ) < (N : ℝ) ^ m := by positivity
    have hfr : ((N : ℝ) - 1) ^ m / (N : ℝ) ^ m < 1 / (2 * (N : ℝ)) := by
      rw [← hdiv]
      exact lt_of_le_of_lt hpow hlt
    rw [div_lt_div_iff₀ hNm (by linarith)] at hfr
    nlinarith [hfr]
  have hcast : ((N - 1 : ℕ) : ℝ) = (N : ℝ) - 1 := by
    have h1 : (1 : ℕ) ≤ N := by omega
    push_cast [Nat.cast_sub h1]
    ring
  have hfin : (((2 * N * (N - 1) ^ m : ℕ)) : ℝ) < ((N ^ m : ℕ) : ℝ) := by
    push_cast [hcast]
    linarith [hfinal]
  exact_mod_cast hfin

/-- The set defining the threshold is nonempty. -/
lemma spectrum_set_nonempty (hN : 2 ≤ Fintype.card α) :
    {m | 2 * nonSurjCount α m < Fintype.card α ^ m}.Nonempty := by
  set N := Fintype.card α with hNdef
  refine ⟨⌊(N : ℝ) * Real.log (2 * (N : ℝ))⌋₊ + 1, ?_⟩
  apply majority_surjective_of
  apply two_mul_pow_lt_pow hN
  have h1 : (N : ℝ) * Real.log (2 * (N : ℝ))
      < (⌊(N : ℝ) * Real.log (2 * (N : ℝ))⌋₊ : ℝ) + 1 := Nat.lt_floor_add_one _
  push_cast
  linarith

/-- **Upper bound**: the full-spectrum threshold is at most `N log (2N) + 1`. -/
theorem spectrumThreshold_le (hN : 2 ≤ Fintype.card α) :
    (spectrumThreshold α : ℝ)
      ≤ (Fintype.card α : ℝ) * Real.log (2 * (Fintype.card α : ℝ)) + 1 := by
  set N := Fintype.card α with hNdef
  have hmem : spectrumThreshold α ≤ ⌊(N : ℝ) * Real.log (2 * (N : ℝ))⌋₊ + 1 := by
    apply spectrumThreshold_le_of_mem
    apply majority_surjective_of
    apply two_mul_pow_lt_pow hN
    have h1 : (N : ℝ) * Real.log (2 * (N : ℝ))
        < (⌊(N : ℝ) * Real.log (2 * (N : ℝ))⌋₊ : ℝ) + 1 := Nat.lt_floor_add_one _
    push_cast
    linarith
  have h2 : ((⌊(N : ℝ) * Real.log (2 * (N : ℝ))⌋₊ : ℝ))
      ≤ (N : ℝ) * Real.log (2 * (N : ℝ)) := by
    apply Nat.floor_le
    have h2N : (2 : ℝ) ≤ (N : ℝ) := by exact_mod_cast hN
    have : (1 : ℝ) ≤ 2 * (N : ℝ) := by linarith
    have := Real.log_nonneg this
    positivity
  have h3 : (spectrumThreshold α : ℝ) ≤ ((⌊(N : ℝ) * Real.log (2 * (N : ℝ))⌋₊ : ℝ)) + 1 := by
    exact_mod_cast hmem
  linarith

/-- **Lower bound**: the full-spectrum threshold is at least `(N - 1) log (N + 1)`. -/
theorem le_spectrumThreshold (hN : 2 ≤ Fintype.card α) :
    ((Fintype.card α : ℝ) - 1) * Real.log ((Fintype.card α : ℝ) + 1)
      ≤ (spectrumThreshold α : ℝ) := by
  by_contra hcon
  push_neg at hcon
  have hmem := mem_of_spectrumThreshold (spectrum_set_nonempty (α := α) hN)
  have hcrit := majority_nonSurjective_of (α := α) (spectrumThreshold α) hN
    (pow_lt_succ_mul_pow_sub_one hN hcon)
  omega

end RainbowAP