/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Moments of the Wigner Semicircle Distribution

The Wigner semicircle law states that the empirical spectral distribution of a
Wigner random matrix converges weakly to the semicircle distribution.  The
combinatorial heart of the *moment method* proof is the following fact: the
moments of the (standard, radius-2) semicircle distribution are exactly the
**Catalan numbers**,

  m_{2k} = C_k,   m_{2k+1} = 0,

and these numbers satisfy the Catalan recurrence

  C_{n+1} = ∑_{i=0}^{n} C_i · C_{n-i}.

This recurrence is precisely the recurrence one obtains for the limiting expected
traces `(1/N) E tr(W^{2k})` of a Wigner ensemble via the non-crossing pair
partition (Dyck path) enumeration.  This file develops this moment sequence as a
real-valued function on `ℕ` and proves the chain of facts that make it the unique
candidate limit in the moment method.

## Main results

- `scMoment_zero`        — the 0-th moment is 1 (total mass).
- `scMoment_odd`         — all odd moments vanish (symmetry).
- `scMoment_two_mul`     — the `2k`-th moment equals `catalan k`.
- `scMoment_recurrence`  — the Wigner/Catalan moment recurrence.
- `scMoment_centralBinom`— closed form via the central binomial coefficient.
- `scMoment_le_four_pow` — the Carleman-type growth bound `m_{2k} ≤ 4^k`,
                           which guarantees the moment problem is determinate.
- concrete values `scMoment_two`, `scMoment_four`, `scMoment_six`.
-/
import Mathlib

namespace MachineLearning.WignerSemicircle

open scoped BigOperators

/-- The moment sequence of the standard semicircle distribution: the `n`-th
moment is `catalan (n/2)` for even `n` and `0` for odd `n`. -/
noncomputable def scMoment (n : ℕ) : ℝ :=
  if Even n then (catalan (n / 2) : ℝ) else 0

/-- The total mass (0-th moment) of the semicircle distribution is `1`. -/
theorem scMoment_zero : scMoment 0 = 1 := by
  simp [scMoment, catalan_zero]

/-- All odd moments of the (symmetric) semicircle distribution vanish. -/
theorem scMoment_odd {n : ℕ} (h : ¬ Even n) : scMoment n = 0 := by
  simp [scMoment, h]

/-- The even moment `m_{2k}` equals the `k`-th Catalan number. -/
theorem scMoment_two_mul (k : ℕ) : scMoment (2 * k) = (catalan k : ℝ) := by
  rw [scMoment, if_pos (even_two_mul k)]
  congr 2
  omega

/-- Every moment is nonnegative. -/
theorem scMoment_nonneg (n : ℕ) : 0 ≤ scMoment n := by
  unfold scMoment; split <;> positivity

/-- Closed form for the even moments via the central binomial coefficient:
`m_{2k} = C(2k, k) / (k+1)`. -/
theorem scMoment_centralBinom (k : ℕ) :
    scMoment (2 * k) = (Nat.centralBinom k : ℝ) / (k + 1) := by
  rw [scMoment_two_mul]
  have h := succ_mul_catalan_eq_centralBinom k
  have hc : ((k + 1 : ℕ) * catalan k : ℝ) = (Nat.centralBinom k : ℝ) := by
    exact_mod_cast congrArg (Nat.cast) h
  push_cast at hc
  field_simp
  linarith [hc]

/-- The **Wigner moment recurrence** (the Catalan recurrence): the `2(n+1)`-th
moment is the convolution of the lower even moments,
`m_{2(n+1)} = ∑_{i=0}^{n} m_{2i} · m_{2(n-i)}`. -/
theorem scMoment_recurrence (n : ℕ) :
    scMoment (2 * (n + 1)) =
      ∑ i ∈ Finset.range (n + 1), scMoment (2 * i) * scMoment (2 * (n - i)) := by
  have hconv : ∀ i ∈ Finset.range (n + 1),
      scMoment (2 * i) * scMoment (2 * (n - i)) = (catalan i : ℝ) * catalan (n - i) := by
    intro i _
    rw [scMoment_two_mul, scMoment_two_mul]
  rw [scMoment_two_mul, Finset.sum_congr rfl hconv, catalan_succ]
  push_cast
  rw [Fin.sum_univ_eq_sum_range (fun i => (catalan i : ℝ) * catalan (n - i)) (n + 1)]

/-- Carleman-type growth bound: the even moments grow at most like `4^k`.
Together with the vanishing odd moments this makes the semicircle moment problem
*determinate*, so the semicircle distribution is the unique possible weak limit. -/
theorem scMoment_le_four_pow (k : ℕ) : scMoment (2 * k) ≤ (4 : ℝ) ^ k := by
  rw [scMoment_two_mul]
  have hcat : catalan k ≤ Nat.centralBinom k := by
    have h := succ_mul_catalan_eq_centralBinom k
    calc catalan k ≤ (k + 1) * catalan k := Nat.le_mul_of_pos_left _ (Nat.succ_pos k)
      _ = Nat.centralBinom k := h
  have hcb : Nat.centralBinom k ≤ 4 ^ k := by
    have hsum : ∑ i ∈ Finset.range (2 * k + 1), (2 * k).choose i = 2 ^ (2 * k) :=
      Nat.sum_range_choose (2 * k)
    have hmem : k ∈ Finset.range (2 * k + 1) := by
      simp only [Finset.mem_range]; omega
    have hle : (2 * k).choose k ≤ ∑ i ∈ Finset.range (2 * k + 1), (2 * k).choose i :=
      Finset.single_le_sum (fun i _ => Nat.zero_le _) hmem
    rw [hsum] at hle
    calc Nat.centralBinom k = (2 * k).choose k := rfl
      _ ≤ 2 ^ (2 * k) := hle
      _ = 4 ^ k := by rw [pow_mul]; norm_num
  have : catalan k ≤ 4 ^ k := le_trans hcat hcb
  calc (catalan k : ℝ) ≤ ((4 ^ k : ℕ) : ℝ) := by exact_mod_cast this
    _ = (4 : ℝ) ^ k := by push_cast; ring

theorem scMoment_two : scMoment 2 = 1 := by
  have := scMoment_two_mul 1; simpa [catalan_one] using this

theorem scMoment_four : scMoment 4 = 2 := by
  have := scMoment_two_mul 2; simpa [catalan_two] using this

theorem scMoment_six : scMoment 6 = 5 := by
  have := scMoment_two_mul 3; simpa [catalan_three] using this

end MachineLearning.WignerSemicircle