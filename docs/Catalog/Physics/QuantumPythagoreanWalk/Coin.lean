import Physics.QuantumPythagoreanWalk.Walk

/-!
# Quantum-Pythagorean-Walk — IX. The barrier is kinematic: no coin can help

`Walk.lean` analyses the *uniform* coin.  This file removes that assumption entirely: a
depth-`n` state of the walk is an arbitrary complex amplitude assignment
`psi : (Fin n → Fin 3) → ℂ` — equivalently an arbitrary sequence of (possibly
position-dependent, possibly entangling) unitary coins.  Two coin-independent facts are
proved.

* `resonanceAmplitude_eq_zero_of_shallow` — below the critical depth `5·7ⁿ < N` the
  resonance amplitude of **every** state is exactly `0`.  The obstruction is about the
  *support* of the walk, not about the amplitudes, so no choice of coin can evade it.
* `resonanceAmplitude_sq_le` — for **every** state the coherent resonance intensity obeys
  `‖A(psi)‖² ≤ |R| · ‖psi‖²`, where `|R|` is the resonance multiplicity.  So the maximal
  interference gain of *any* coin is exactly the resonance multiplicity `|R|`; the uniform
  coin's gain (`coherent_resonance_amplitude_sq`) is the special case
  `|R|² · 3^{-n} ≤ |R|`.

Together: the interference mechanism is bounded above by an arithmetic quantity (`|R|`) that
vanishes identically until depth `log₇(N/5)`, whatever the dynamics.
-/

namespace QuantumPythagoreanWalk

/-- A depth-`n` state of the walk: an arbitrary complex amplitude for each coin history.
No unitarity or product structure is assumed. -/
abbrev CoinState (n : ℕ) := (Fin n → Fin 3) → ℂ

/-- Total intensity of a state. -/
noncomputable def totalIntensity {n : ℕ} (psi : CoinState n) : ℝ :=
  ∑ r : Fin n → Fin 3, ‖psi r‖ ^ 2

/-- A state is normalised when its total intensity is `1`. -/
def Normalized {n : ℕ} (psi : CoinState n) : Prop := totalIntensity psi = 1

/-- The amplitude that a depth-`n` state assigns to the resonance subspace of `N`: all
resonant branches summed coherently. -/
noncomputable def resonanceAmplitude (N : ℤ) {n : ℕ} (psi : CoinState n) : ℂ :=
  ∑ r ∈ resonanceSet N n, psi r

theorem totalIntensity_nonneg {n : ℕ} (psi : CoinState n) : 0 ≤ totalIntensity psi :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- **Coin-independent barrier.**  Below the critical depth the resonance amplitude of every
state vanishes identically: the obstruction lives in the support of the walk. -/
theorem resonanceAmplitude_eq_zero_of_shallow {N : ℤ} {n : ℕ} (hN : 5 * 7 ^ n < N)
    (psi : CoinState n) : resonanceAmplitude N psi = 0 := by
  unfold resonanceAmplitude
  rw [resonanceSet_eq_empty_of_shallow hN]
  simp

/-- **Coin-independent interference bound.**  The coherent resonance intensity of any state
is at most the resonance multiplicity times the total intensity.  Hence no coin — uniform,
biased, position-dependent or adaptive — can produce an interference gain exceeding the
arithmetic multiplicity `|R|`. -/
theorem resonanceAmplitude_sq_le (N : ℤ) {n : ℕ} (psi : CoinState n) :
    ‖resonanceAmplitude N psi‖ ^ 2
      ≤ (resonanceSet N n).card * totalIntensity psi := by
  have h1 : ‖resonanceAmplitude N psi‖ ≤ ∑ r ∈ resonanceSet N n, ‖psi r‖ :=
    norm_sum_le _ _
  have h2 : (∑ r ∈ resonanceSet N n, ‖psi r‖) ^ 2
      ≤ (resonanceSet N n).card * ∑ r ∈ resonanceSet N n, ‖psi r‖ ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have h3 : ∑ r ∈ resonanceSet N n, ‖psi r‖ ^ 2 ≤ totalIntensity psi :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      (fun _ _ _ => sq_nonneg _)
  have hsum_nonneg : 0 ≤ ∑ r ∈ resonanceSet N n, ‖psi r‖ :=
    Finset.sum_nonneg fun _ _ => norm_nonneg _
  have hcard : (0 : ℝ) ≤ (resonanceSet N n).card := Nat.cast_nonneg _
  calc ‖resonanceAmplitude N psi‖ ^ 2
      ≤ (∑ r ∈ resonanceSet N n, ‖psi r‖) ^ 2 := by
        exact pow_le_pow_left₀ (norm_nonneg _) h1 2
    _ ≤ (resonanceSet N n).card * ∑ r ∈ resonanceSet N n, ‖psi r‖ ^ 2 := h2
    _ ≤ (resonanceSet N n).card * totalIntensity psi :=
        mul_le_mul_of_nonneg_left h3 hcard

/-- For a normalised state the interference gain is bounded by the resonance multiplicity
alone — a purely arithmetic quantity, independent of the dynamics. -/
theorem resonanceAmplitude_sq_le_card {N : ℤ} {n : ℕ} {psi : CoinState n}
    (hpsi : Normalized psi) :
    ‖resonanceAmplitude N psi‖ ^ 2 ≤ (resonanceSet N n).card := by
  have := resonanceAmplitude_sq_le N psi
  rwa [hpsi, mul_one] at this

/-- The gain of any normalised state is at most `3ⁿ`; combined with the previous bound the
useful statement is that the gain is `0` until the resonance set is nonempty. -/
theorem resonanceAmplitude_sq_le_pow {N : ℤ} {n : ℕ} {psi : CoinState n}
    (hpsi : Normalized psi) :
    ‖resonanceAmplitude N psi‖ ^ 2 ≤ (3 : ℝ) ^ n := by
  refine le_trans (resonanceAmplitude_sq_le_card hpsi) ?_
  exact_mod_cast card_resonanceSet_le N n

/-- **The uniform coin realises the general bound.**  Its coherent amplitude squared is
`|R|² · 3^{-n}`, which is `≤ |R|` — the special case of `resonanceAmplitude_sq_le_card`. -/
theorem uniform_coin_gain_le_card (N : ℤ) (n : ℕ) :
    coherentAmplitude N n ^ 2 ≤ (resonanceSet N n).card := by
  rw [coherent_resonance_amplitude_sq]
  have h1 : resonanceProb N n ≤ 1 := resonanceProb_le_one N n
  have h2 : (0 : ℝ) ≤ (resonanceSet N n).card := Nat.cast_nonneg _
  nlinarith [resonanceProb_nonneg N n]

end QuantumPythagoreanWalk