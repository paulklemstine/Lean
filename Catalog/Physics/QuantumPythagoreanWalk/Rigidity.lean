import Physics.QuantumPythagoreanWalk.Coin

/-!
# Quantum-Pythagorean-Walk — XIII. Rigidity of the interference bound

`Coin.lean` proves the coin-independent bound

`‖A(ψ)‖² ≤ |R| · ‖ψ‖²`  (`resonanceAmplitude_sq_le`),

where `R = resonanceSet N n` and `A(ψ) = ∑_{r ∈ R} ψ r`.  This file settles the *equality
case*, i.e. the first half of the "Conjecture 3′" of `FUTURE_DIRECTIONS.md`:

> equality holds **iff** `ψ` is a scalar multiple of the indicator of the resonance set.

So the optimum is attained by exactly one state (up to a global amplitude), the
*resonance-indicator coin* — a state whose preparation already encodes the answer to the
arithmetic question.  This is the precise sense in which the interference mechanism is not
an algorithm: reaching the optimal gain `|R|` requires knowing `R`.

The proof is a variance identity rather than an appeal to the Cauchy–Schwarz equality case:
with `c = A(ψ)/|R|`,

`∑_{r ∈ R} ‖ψ r - c‖² = ∑_{r ∈ R} ‖ψ r‖² - ‖A(ψ)‖²/|R|`  (`sum_norm_sub_const_sq`),

and equality in the bound forces the right-hand side to be `≤ 0`, hence `ψ` is constant on
`R`; the same computation forces `ψ` to vanish off `R`.
-/

namespace QuantumPythagoreanWalk

open Finset

/-! ### A variance identity -/

/-- Expansion of `‖z - c‖²` in an inner-product-free form. -/
private theorem norm_sub_sq_complex (z c : ℂ) :
    ‖z - c‖ ^ 2 = ‖z‖ ^ 2 - 2 * ((starRingEnd ℂ) c * z).re + ‖c‖ ^ 2 := by
  simp only [← Complex.normSq_eq_norm_sq, Complex.normSq_apply, Complex.sub_re,
    Complex.sub_im, Complex.mul_re, Complex.conj_re, Complex.conj_im]
  ring

/-- **Variance identity.**  For any finite family of complex amplitudes and any constant `c`,
the squared deviation from `c` splits into the total intensity, the coherent term and the
constant term. -/
theorem sum_norm_sub_const_sq {ι : Type*} (s : Finset ι) (f : ι → ℂ) (c : ℂ) :
    ∑ r ∈ s, ‖f r - c‖ ^ 2
      = (∑ r ∈ s, ‖f r‖ ^ 2) - 2 * ((starRingEnd ℂ) c * ∑ r ∈ s, f r).re
        + s.card * ‖c‖ ^ 2 := by
  have h1 : ∀ r ∈ s, ‖f r - c‖ ^ 2
      = ‖f r‖ ^ 2 - 2 * ((starRingEnd ℂ) c * f r).re + ‖c‖ ^ 2 :=
    fun r _ => norm_sub_sq_complex (f r) c
  rw [Finset.sum_congr rfl h1]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
  have h2 : ∑ r ∈ s, 2 * ((starRingEnd ℂ) c * f r).re
      = 2 * ((starRingEnd ℂ) c * ∑ r ∈ s, f r).re := by
    simp [Finset.mul_sum, Complex.re_sum]
  rw [h2, Finset.sum_const, nsmul_eq_mul]

/-! ### The optimal state -/

/-- The resonance-indicator state with amplitude `c`: the state supported on the resonance
set, with the constant amplitude `c` there. -/
noncomputable def indicatorState (N : ℤ) (n : ℕ) (c : ℂ) : CoinState n :=
  fun r => if r ∈ resonanceSet N n then c else 0

@[simp] theorem resonanceAmplitude_indicatorState (N : ℤ) (n : ℕ) (c : ℂ) :
    resonanceAmplitude N (indicatorState N n c) = (resonanceSet N n).card * c := by
  unfold resonanceAmplitude indicatorState
  rw [Finset.sum_congr rfl (fun r hr => if_pos hr), Finset.sum_const, nsmul_eq_mul]

@[simp] theorem totalIntensity_indicatorState (N : ℤ) (n : ℕ) (c : ℂ) :
    totalIntensity (indicatorState N n c) = (resonanceSet N n).card * ‖c‖ ^ 2 := by
  unfold totalIntensity indicatorState
  have h : ∀ r : Fin n → Fin 3,
      ‖if r ∈ resonanceSet N n then c else 0‖ ^ 2
        = if r ∈ resonanceSet N n then ‖c‖ ^ 2 else 0 := by
    intro r
    by_cases hr : r ∈ resonanceSet N n <;> simp [hr]
  rw [Finset.sum_congr rfl (fun r _ => h r), Finset.sum_ite_mem, Finset.univ_inter,
    Finset.sum_const, nsmul_eq_mul]

/-- **The indicator state attains the bound.**  Every scalar multiple of the resonance
indicator satisfies `‖A(ψ)‖² = |R| · ‖ψ‖²` — the bound of `resonanceAmplitude_sq_le` is
sharp. -/
theorem indicatorState_attains_bound (N : ℤ) (n : ℕ) (c : ℂ) :
    ‖resonanceAmplitude N (indicatorState N n c)‖ ^ 2
      = (resonanceSet N n).card * totalIntensity (indicatorState N n c) := by
  rw [resonanceAmplitude_indicatorState, totalIntensity_indicatorState]
  rw [norm_mul, mul_pow]
  simp only [Complex.norm_natCast]
  ring

/-! ### Rigidity: nothing else attains it -/

/-- **Rigidity of the interference bound.**  For a nonempty resonance set, a state saturates
the coin-independent bound `‖A(ψ)‖² ≤ |R| · ‖ψ‖²` if and only if it is a scalar multiple of
the resonance indicator.  The optimal coin therefore already "knows" the resonance set. -/
theorem resonanceAmplitude_sq_eq_iff {N : ℤ} {n : ℕ} (hR : (resonanceSet N n).Nonempty)
    (psi : CoinState n) :
    ‖resonanceAmplitude N psi‖ ^ 2 = (resonanceSet N n).card * totalIntensity psi ↔
      ∃ c : ℂ, psi = indicatorState N n c := by
  set R := resonanceSet N n with hRdef
  have hcard : (0 : ℝ) < R.card := by
    exact_mod_cast Finset.card_pos.mpr hR
  constructor
  · intro heq
    set A : ℂ := resonanceAmplitude N psi with hA
    set c : ℂ := A / (R.card : ℂ) with hc
    have hcardC : ((R.card : ℂ)) ≠ 0 :=
      Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hR).ne'
    -- the coherent term and the constant term, computed
    have hconj : ((starRingEnd ℂ) c * A).re = ‖A‖ ^ 2 / R.card := by
      rw [hc, map_div₀, Complex.conj_natCast, div_mul_eq_mul_div,
        mul_comm ((starRingEnd ℂ) A) A, Complex.mul_conj, Complex.normSq_eq_norm_sq]
      rw [show ((‖A‖ ^ 2 : ℝ) : ℂ) / (R.card : ℂ) = (((‖A‖ ^ 2 / R.card : ℝ)) : ℂ) by
        push_cast; ring]
      exact Complex.ofReal_re _
    have hcnorm : ‖c‖ ^ 2 = ‖A‖ ^ 2 / (R.card : ℝ) ^ 2 := by
      rw [hc, norm_div, div_pow]
      simp
    -- the variance identity, specialised
    have hvar : ∑ r ∈ R, ‖psi r - c‖ ^ 2 = (∑ r ∈ R, ‖psi r‖ ^ 2) - ‖A‖ ^ 2 / R.card := by
      rw [sum_norm_sub_const_sq R psi c]
      have hsum : ∑ r ∈ R, psi r = A := rfl
      rw [hsum, hconj, hcnorm]
      field_simp
      ring
    -- the resonant part of the intensity is at most the total intensity
    have hle : ∑ r ∈ R, ‖psi r‖ ^ 2 ≤ totalIntensity psi :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun _ _ _ => sq_nonneg _)
    -- but the hypothesis says the coherent term already exhausts the total intensity
    have hAI : ‖A‖ ^ 2 / R.card = totalIntensity psi := by
      rw [heq]
      field_simp
    have hvar_le : ∑ r ∈ R, ‖psi r - c‖ ^ 2 ≤ 0 := by
      rw [hvar, hAI]
      linarith
    have hvar_ge : (0 : ℝ) ≤ ∑ r ∈ R, ‖psi r - c‖ ^ 2 :=
      Finset.sum_nonneg fun _ _ => sq_nonneg _
    have hvar0 : ∑ r ∈ R, ‖psi r - c‖ ^ 2 = 0 := le_antisymm hvar_le hvar_ge
    -- hence `psi` is constant on `R`
    have hon : ∀ r ∈ R, psi r = c := by
      intro r hr
      have h2 : ‖psi r - c‖ ^ 2 = 0 :=
        (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => sq_nonneg (‖psi i - c‖))).mp hvar0 r hr
      have hz : psi r - c = 0 :=
        norm_eq_zero.mp (pow_eq_zero_iff (n := 2) two_ne_zero |>.mp h2)
      exact sub_eq_zero.mp hz
    -- and vanishes off `R`
    have hres : ∑ r ∈ R, ‖psi r‖ ^ 2 = totalIntensity psi := by
      have := hvar
      rw [hvar0, hAI] at this
      linarith
    have hsplit : ∑ r ∈ Finset.univ \ R, ‖psi r‖ ^ 2 = 0 := by
      have hsd : (∑ r ∈ R, ‖psi r‖ ^ 2) + ∑ r ∈ Finset.univ \ R, ‖psi r‖ ^ 2
          = totalIntensity psi := by
        rw [add_comm]
        exact Finset.sum_sdiff (Finset.subset_univ R)
      linarith
    have hoff : ∀ r, r ∉ R → psi r = 0 := by
      intro r hr
      have hmem : r ∈ Finset.univ \ R := Finset.mem_sdiff.mpr ⟨Finset.mem_univ r, hr⟩
      have h2 : ‖psi r‖ ^ 2 = 0 :=
        (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => sq_nonneg (‖psi i‖))).mp hsplit r hmem
      exact norm_eq_zero.mp (pow_eq_zero_iff (n := 2) two_ne_zero |>.mp h2)
    refine ⟨c, funext fun r => ?_⟩
    by_cases hr : r ∈ R
    · rw [hon r hr]
      simp [indicatorState, ← hRdef, hr]
    · rw [hoff r hr]
      simp [indicatorState, ← hRdef, hr]
  · rintro ⟨c, rfl⟩
    exact indicatorState_attains_bound N n c

/-- **The optimal normalised state.**  The normalised resonance indicator is a state of unit
intensity whose interference gain is exactly the resonance multiplicity `|R|`, so the bound
`resonanceAmplitude_sq_le_card` is attained. -/
theorem normalized_indicatorState_gain {N : ℤ} {n : ℕ} (hR : (resonanceSet N n).Nonempty) :
    Normalized (indicatorState N n ((Real.sqrt (resonanceSet N n).card)⁻¹ : ℝ)) ∧
      ‖resonanceAmplitude N
        (indicatorState N n ((Real.sqrt (resonanceSet N n).card)⁻¹ : ℝ))‖ ^ 2
        = (resonanceSet N n).card := by
  have hcard : (0 : ℝ) < (resonanceSet N n).card := by
    exact_mod_cast Finset.card_pos.mpr hR
  have hsqrt : Real.sqrt (resonanceSet N n).card ≠ 0 :=
    ne_of_gt (Real.sqrt_pos.mpr hcard)
  have hnorm : ‖(((Real.sqrt (resonanceSet N n).card)⁻¹ : ℝ) : ℂ)‖ ^ 2
      = ((resonanceSet N n).card : ℝ)⁻¹ := by
    rw [Complex.norm_real, Real.norm_eq_abs,
      abs_of_pos (inv_pos.mpr (Real.sqrt_pos.mpr hcard))]
    rw [inv_pow, Real.sq_sqrt (le_of_lt hcard)]
  constructor
  · unfold Normalized
    rw [totalIntensity_indicatorState, hnorm]
    field_simp
  · rw [resonanceAmplitude_indicatorState, norm_mul, mul_pow, hnorm]
    simp only [Complex.norm_natCast]
    field_simp

end QuantumPythagoreanWalk