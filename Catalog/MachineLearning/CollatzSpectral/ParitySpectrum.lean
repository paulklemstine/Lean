/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The exact spectral gap of the Collatz parity transform

`MachineLearning.CollatzSpectralGap` proves a **negative** result: the naive
archimedean Collatz exponential sum has no spectral gap, since it is continuous
in the frequency and equals `N` at frequency `0`.

This file proves the corresponding **positive** result once the frequency
variable is moved to the correct group. Working on `ℤ/2^k` with the *parity
word* of the accelerated Collatz map as the phase, the Fourier transform is

  `F_k(j) = ∑_{n < 2^k} exp(2πi · j · parityWord k n / 2^k)`,

and we prove `F_k(j) = 0` for **every** nonzero frequency `j` mod `2^k`.
So the transform exhibits *total* cancellation — infinitely better than the
square-root cancellation one expects from a random phase — while `F_k(0) = 2^k`.

The mechanism is the Terras bijection proved in
`MachineLearning.CollatzSpectral.ParityBijection`.

## Main results

* `parityFourier_zero_freq` — `F_k(0) = 2^k`.
* `parityFourier_eq_zero` — `F_k(j) = 0` for `0 < j < 2^k`: the exact spectral gap.
* `parity_spectral_gap_beats_sqrt` — the transform beats square-root cancellation
  at every nonzero frequency, in contrast with the archimedean obstruction.
* `parityFourier_parseval` — `∑_j ‖F_k(j)‖² = 4^k`, all the mass sits at DC.
* `card_parityWord_fiber` — each parity word has exactly one preimage mod `2^k`.
* `onesCount_generating_function` — `∑_{n<2^k} x^{s_k(n)} = (1+x)^k` in any
  commutative semiring: the ones-counts are exactly binomially distributed.
* `sum_three_pow_onesCount` — `∑_{n<2^k} 3^{s_k(n)} = 4^k`, hence the *arithmetic*
  mean of the `k`-step multiplier `3^{s}/2^k` over residues mod `2^k` is exactly `1`
  (`mean_multiplier_eq_one`).
* `mean_contractionExp` / `mean_contractionExp_pos` — the *geometric* mean of the
  same multiplier is `(√3/2)^k < 1`: the average contraction exponent is exactly
  `k(log 2 − ½log 3) > 0` per residue class.
-/

import Mathlib
import MachineLearning.CollatzSpectral.ParityBijection
import MachineLearning.CollatzSpectral.ContractionSpectrum

open Finset

namespace CollatzParity

/-! ## §1. The 2-adic Collatz Fourier transform -/

/-- The **Collatz parity transform** at frequency `j` and scale `k`:
the discrete Fourier transform, on the group `ℤ/2^k`, of the map sending a
residue to its length-`k` Collatz parity word. -/
noncomputable def parityFourier (k j : ℕ) : ℂ :=
  ∑ n ∈ Finset.range (2 ^ k),
    Complex.exp (2 * Real.pi * Complex.I * (j * parityWord k n) / ((2 ^ k : ℕ) : ℂ))

/-- At zero frequency the transform is the trivial count `2^k`. -/
theorem parityFourier_zero_freq (k : ℕ) : parityFourier k 0 = (2 ^ k : ℕ) := by
  unfold parityFourier
  simp

/-- **Exact spectral gap.** At every nonzero frequency mod `2^k` the Collatz
parity transform vanishes identically. -/
theorem parityFourier_eq_zero (k j : ℕ) (hj : j ≠ 0) (hjk : j < 2 ^ k) :
    parityFourier k j = 0 := by
  unfold parityFourier
  set N := 2 ^ k with hN
  have hN0 : (N : ℕ) ≠ 0 := by positivity
  set mu : ℂ := Complex.exp (2 * Real.pi * Complex.I / N) with hmu
  have hprim : IsPrimitiveRoot mu N := Complex.isPrimitiveRoot_exp N hN0
  set z : ℂ := mu ^ j with hz
  have hz1 : z ≠ 1 := hprim.pow_ne_one_of_pos_of_lt hj hjk
  have hzN : z ^ N = 1 := by
    rw [hz, ← pow_mul, mul_comm, pow_mul, hprim.pow_eq_one, one_pow]
  have hterm : ∀ w : ℕ,
      Complex.exp (2 * Real.pi * Complex.I * (j * w) / (N : ℂ)) = z ^ w := by
    intro w
    rw [hz, hmu, ← Complex.exp_nat_mul, ← Complex.exp_nat_mul]
    congr 1
    ring
  calc ∑ n ∈ Finset.range N,
        Complex.exp (2 * Real.pi * Complex.I * (j * parityWord k n) / (N : ℂ))
      = ∑ n ∈ Finset.range N, (fun w : ℕ => z ^ w) (parityWord k n) :=
        Finset.sum_congr rfl fun n _ => hterm (parityWord k n)
    _ = ∑ w ∈ Finset.range N, z ^ w := sum_over_parityWords k _
    _ = 0 := by rw [geom_sum_eq hz1, hzN]; simp

/-- The transform is `2^k`-periodic in the frequency, so the previous theorem
covers every nonzero frequency of the group `ℤ/2^k`. -/
theorem parityFourier_eq_zero_of_not_dvd (k j : ℕ) (hj : ¬ (2 ^ k ∣ j)) :
    parityFourier k (j % 2 ^ k) = 0 := by
  refine parityFourier_eq_zero k _ ?_ (Nat.mod_lt _ (by positivity))
  intro h
  exact hj (Nat.dvd_of_mod_eq_zero h)

/-- **The gap beats square-root cancellation.** For a generic phase one expects
the size of a sum of `2^k` unit vectors to be about `√(2^k)`; here it is exactly
zero at every nonzero frequency. Compare `CollatzSpectralGap.proposed_spectral_gap_is_false`,
which shows the *archimedean* transform admits no such bound. -/
theorem parity_spectral_gap_beats_sqrt (k j : ℕ) (hj : j ≠ 0) (hjk : j < 2 ^ k) :
    ‖parityFourier k j‖ < Real.sqrt ((2 ^ k : ℕ) : ℝ) := by
  rw [parityFourier_eq_zero k j hj hjk, norm_zero]
  exact Real.sqrt_pos.mpr (by positivity)

/-- **Parseval**: all of the spectral mass sits at the DC frequency. -/
theorem parityFourier_parseval (k : ℕ) :
    ∑ j ∈ Finset.range (2 ^ k), ‖parityFourier k j‖ ^ 2 = ((2 ^ k : ℕ) : ℝ) ^ 2 := by
  rw [Finset.sum_eq_single 0]
  · rw [parityFourier_zero_freq, Complex.norm_natCast]
  · intro j hj hj0
    rw [parityFourier_eq_zero k j hj0 (Finset.mem_range.mp hj), norm_zero]
    ring
  · intro h
    exact absurd (Finset.mem_range.mpr (by positivity)) h

/-! ## §2. Exact equidistribution of parity words -/

/-- Every length-`k` parity word has **exactly one** preimage among the residues
mod `2^k`. This is the combinatorial content of the spectral gap. -/
theorem card_parityWord_fiber (k w : ℕ) (hw : w < 2 ^ k) :
    ((Finset.range (2 ^ k)).filter (fun n => parityWord k n = w)).card = 1 := by
  obtain ⟨n, hn, hnw⟩ := parityWord_surjective k w hw
  rw [Finset.card_eq_one]
  refine ⟨n, Finset.eq_singleton_iff_unique_mem.mpr ⟨?_, ?_⟩⟩
  · simp [Finset.mem_filter, Finset.mem_range, hn, hnw]
  · intro m hm
    rw [Finset.mem_filter] at hm
    exact parityWord_injOn k hm.1 (by exact_mod_cast Finset.mem_range.mpr hn)
      (by rw [hm.2, hnw])

/-! ## §3. The ones-count generating function -/

/-- The `k`-th parity bit of `n` and of `n + 2^k` disagree, in the form needed
for the doubling induction. -/
lemma pbit_flip' (k i : ℕ) : pbit (2 ^ k + i) k ≠ pbit i k := by
  rw [add_comm]
  exact pbit_flip k i

lemma onesCount_period' (k i : ℕ) : onesCount k (2 ^ k + i) = onesCount k i := by
  rw [add_comm]
  simpa using onesCount_period k i 1

/-- **The doubling pairing.** Passing from scale `k` to scale `k+1` pairs the
residue `i` with `2^k + i`; the two share their first `k` parity bits and have
opposite `k`-th bits, so their odd-step counts are `s` and `s+1` in some order.
This single combinatorial lemma drives every moment computation below. -/
lemma onesCount_pair (k i : ℕ) :
    (onesCount (k + 1) i = onesCount k i ∧
        onesCount (k + 1) (2 ^ k + i) = onesCount k i + 1) ∨
      (onesCount (k + 1) i = onesCount k i + 1 ∧
        onesCount (k + 1) (2 ^ k + i) = onesCount k i) := by
  rw [onesCount_succ, onesCount_succ, onesCount_period']
  rcases pbit_eq_zero_or_one i k with h | h <;>
    rcases pbit_eq_zero_or_one (2 ^ k + i) k with h' | h'
  · exact absurd (h'.trans h.symm) (pbit_flip' k i)
  · exact Or.inl ⟨by omega, by omega⟩
  · exact Or.inr ⟨by omega, by omega⟩
  · exact absurd (h'.trans h.symm) (pbit_flip' k i)

/-- **Binomial equidistribution of the odd-step counts.** For every commutative
semiring `R` and every `x : R`,
`∑_{n < 2^k} x^{s_k(n)} = (1+x)^k`, where `s_k(n)` counts odd steps in the first
`k` accelerated Collatz steps. Equivalently, the number of residues mod `2^k`
with exactly `s` odd steps is `C(k,s)`. -/
theorem onesCount_generating_function {R : Type*} [CommSemiring R] (x : R) (k : ℕ) :
    ∑ n ∈ Finset.range (2 ^ k), x ^ onesCount k n = (1 + x) ^ k := by
  induction k with
  | zero => simp [onesCount]
  | succ k ih =>
    have hsplit : (2 : ℕ) ^ (k + 1) = 2 ^ k + 2 ^ k := by ring
    rw [hsplit, Finset.sum_range_add]
    have h1 : ∀ i ∈ Finset.range (2 ^ k),
        x ^ onesCount (k + 1) i + x ^ onesCount (k + 1) (2 ^ k + i)
          = x ^ onesCount k i * (1 + x) := by
      intro i _
      rcases onesCount_pair k i with ⟨h, h'⟩ | ⟨h, h'⟩ <;> rw [h, h'] <;> ring
    rw [← Finset.sum_add_distrib, Finset.sum_congr rfl h1, ← Finset.sum_mul, ih]
    ring

/-- **Total multiplier mass.** `∑_{n<2^k} 3^{s_k(n)} = 4^k`. -/
theorem sum_three_pow_onesCount (k : ℕ) :
    ∑ n ∈ Finset.range (2 ^ k), 3 ^ onesCount k n = 4 ^ k := by
  have h := onesCount_generating_function (3 : ℕ) k
  rw [show (1 + 3 : ℕ) = 4 by norm_num] at h
  exact h

/-- **The arithmetic mean of the `k`-step Collatz multiplier is exactly `1`.**
The multiplier along the first `k` accelerated steps of `n` is `3^{s_k(n)}/2^k`;
averaged over the `2^k` residue classes mod `2^k` it equals `1` for every `k`.
So the Collatz map is, on the nose, a *critical* (driftless) multiplicative
process in the arithmetic mean. -/
theorem mean_multiplier_eq_one (k : ℕ) :
    (∑ n ∈ Finset.range (2 ^ k), (3 : ℝ) ^ onesCount k n / 2 ^ k) / 2 ^ k = 1 := by
  have h : ∑ n ∈ Finset.range (2 ^ k), (3 : ℝ) ^ onesCount k n = 4 ^ k := by
    have h := onesCount_generating_function (3 : ℝ) k
    rw [show (1 + 3 : ℝ) = 4 by norm_num] at h
    exact h
  rw [← Finset.sum_div, h, div_div, div_eq_one_iff_eq (by positivity),
    show (4 : ℝ) = 2 * 2 by norm_num, mul_pow]

/-! ## §4. The mean contraction exponent: a strictly positive drift -/

/-- **Exact first moment of the odd-step count**: `2·∑_{n<2^k} s_k(n) = k·2^k`,
i.e. the mean number of odd steps is exactly `k/2`. -/
theorem sum_onesCount (k : ℕ) :
    2 * ∑ n ∈ Finset.range (2 ^ k), onesCount k n = k * 2 ^ k := by
  induction k with
  | zero => simp [onesCount]
  | succ k ih =>
    have hsplit : (2 : ℕ) ^ (k + 1) = 2 ^ k + 2 ^ k := by ring
    rw [hsplit, Finset.sum_range_add]
    have h1 : ∀ i ∈ Finset.range (2 ^ k),
        onesCount (k + 1) i + onesCount (k + 1) (2 ^ k + i) = 2 * onesCount k i + 1 := by
      intro i _
      rcases onesCount_pair k i with ⟨h, h'⟩ | ⟨h, h'⟩ <;> rw [h, h'] <;> ring
    rw [← Finset.sum_add_distrib, Finset.sum_congr rfl h1, Finset.sum_add_distrib,
      ← Finset.mul_sum]
    simp only [Finset.sum_const, Finset.card_range, smul_eq_mul, mul_one]
    have hkey : (k + 1) * (2 ^ k + 2 ^ k) = 2 * (k * 2 ^ k) + 2 * 2 ^ k := by ring
    omega

/-- The real-valued first moment. -/
theorem sum_onesCount_real (k : ℕ) :
    ∑ n ∈ Finset.range (2 ^ k), (onesCount k n : ℝ) = (k : ℝ) * 2 ^ k / 2 := by
  have h := sum_onesCount k
  have hc : ((2 * ∑ n ∈ Finset.range (2 ^ k), onesCount k n : ℕ) : ℝ) = ((k * 2 ^ k : ℕ) : ℝ) := by
    exact_mod_cast congrArg (fun t : ℕ => (t : ℝ)) h
  push_cast at hc
  linarith

/-- **The mean contraction exponent.** Averaged over residues mod `2^k`, the
contraction exponent `k·log 2 − s·log 3` of `ContractionSpectrum` equals exactly
`k(log 2 − ½ log 3)`: the geometric mean of the `k`-step multiplier is `(√3/2)^k`. -/
theorem mean_contractionExp (k : ℕ) :
    (∑ n ∈ Finset.range (2 ^ k), contractionExp k (onesCount k n)) / 2 ^ k
      = (k : ℝ) * (Real.log 2 - (1 / 2) * Real.log 3) := by
  have hexp : ∀ n, contractionExp k (onesCount k n)
      = (k : ℝ) * Real.log 2 - (onesCount k n : ℝ) * Real.log 3 := fun n => rfl
  rw [Finset.sum_congr rfl fun n _ => hexp n]
  rw [Finset.sum_sub_distrib]
  simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  rw [← Finset.sum_mul, sum_onesCount_real]
  have h2 : (0 : ℝ) < 2 ^ k := by positivity
  field_simp
  push_cast
  ring

/-- **Positive mean drift at every scale.** Since `log 3 < 2 log 2`, the average
contraction exponent over a full residue system mod `2^k` is strictly positive
for `k ≥ 1`. This is the exact, unconditional form of the usual heuristic that
"a Collatz orbit shrinks by `√3/2` per accelerated step on average". -/
theorem mean_contractionExp_pos (k : ℕ) (hk : 0 < k) :
    0 < (∑ n ∈ Finset.range (2 ^ k), contractionExp k (onesCount k n)) / 2 ^ k := by
  rw [mean_contractionExp k]
  have hk' : (0 : ℝ) < k := by exact_mod_cast hk
  have := positive_drift_at_half
  positivity

/-! ## §5. Extremes versus the mean -/

/-- Despite the positive *mean* drift, at every scale there is a residue class
whose first `k` steps are all odd, and whose contraction exponent is therefore
strictly negative: the drift theorem cannot be upgraded pointwise. -/
theorem exists_expanding_residue (k : ℕ) (hk : 0 < k) :
    ∃ n < 2 ^ k, onesCount k n = k ∧ contractionExp k (onesCount k n) < 0 := by
  obtain ⟨n, hn, hs, _⟩ := exists_all_odd_prefix k
  refine ⟨n, hn, hs, ?_⟩
  rw [hs]
  have hk' : (0 : ℝ) < k := by exact_mod_cast hk
  have h := log_two_lt_log_three
  unfold contractionExp
  nlinarith

/-- And there is a residue class whose first `k` steps are all even, whose
contraction exponent is the maximum `k·log 2`. -/
theorem exists_maximally_contracting_residue (k : ℕ) :
    ∃ n < 2 ^ k, onesCount k n = 0 ∧ contractionExp k (onesCount k n) = (k : ℝ) * Real.log 2 := by
  obtain ⟨n, hn, hs, _⟩ := exists_all_even_prefix k
  refine ⟨n, hn, hs, ?_⟩
  rw [hs]
  unfold contractionExp
  simp

end CollatzParity