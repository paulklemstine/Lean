/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# A quantitative spectral-edge bound at every order

`Probability.WignerMomentGrowth` bounds every even trace moment of the symmetric
Rademacher ensemble by `N^(k+1) (k+1)^(2k)`.  Because a single large eigenvalue
already forces a large `2k`-th trace moment, Markov's inequality turns that bound
into a tail estimate for the spectral radius: for every order `k` and every
threshold `t > 0`,

  `P [ some eigenvalue of W/√N has modulus ≥ t ] ≤ N (k+1)^(2k) / t^(2k)`.

This is the classical moment route to the spectral edge; the constant `(k+1)^(2k)`
is the crude spanning-tree count rather than the sharp Catalan constant `4^k`, so
the bound becomes informative for `t` of order `k`, and combined with the
deterministic lower bound `√(1 - 1/N) ≤ ‖W/√N‖` of
`Probability.WignerSemicircleCapstone` it sandwiches the spectral radius from both
sides.
-/
import Probability.WignerMomentGrowth

open Matrix BigOperators Finset

namespace RademacherWigner

variable {N : ℕ}

/-- The uniform probability of a set of configurations. -/
noncomputable def prob (A : Finset (Config N)) : ℝ :=
  (A.card : ℝ) / (Fintype.card (Config N) : ℝ)

theorem prob_mono {A B : Finset (Config N)} (h : A ⊆ B) : prob A ≤ prob B := by
  have hM : (0 : ℝ) < (Fintype.card (Config N) : ℝ) := card_config_pos N
  have hcard : (A.card : ℝ) ≤ (B.card : ℝ) := by exact_mod_cast Finset.card_le_card h
  unfold prob
  gcongr

/-- **Markov's inequality** for the uniform ensemble. -/
theorem markov (f : Config N → ℝ) (hf : ∀ g, 0 ≤ f g) {c : ℝ} (hc : 0 < c) :
    prob (Finset.univ.filter fun g : Config N => c ≤ f g) ≤ expect f / c := by
  classical
  set A : Finset (Config N) := Finset.univ.filter fun g : Config N => c ≤ f g with hA
  have h1 : c * (A.card : ℝ) ≤ ∑ g ∈ A, f g := by
    calc c * (A.card : ℝ) = ∑ _g ∈ A, c := by
          rw [Finset.sum_const, nsmul_eq_mul, mul_comm]
      _ ≤ ∑ g ∈ A, f g := Finset.sum_le_sum fun g hg => (Finset.mem_filter.1 hg).2
  have h2 : ∑ g ∈ A, f g ≤ ∑ g : Config N, f g :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) fun g _ _ => hf g
  have hM : (0 : ℝ) < (Fintype.card (Config N) : ℝ) := card_config_pos N
  rw [prob, expect, div_div, div_le_div_iff₀ hM (by positivity)]
  nlinarith [h1, h2, hM.le, hc.le, Nat.cast_nonneg (α := ℝ) A.card]

/-- Every even trace moment is nonnegative: it is a sum of even powers of the
eigenvalues. -/
theorem trace_pow_two_mul_nonneg (g : Config N) (k : ℕ) :
    0 ≤ ((W g) ^ (2 * k)).trace := by
  rw [WignerBridge.trace_pow_eq_sum_eigenvalues_real (W_isHermitian g)]
  refine Finset.sum_nonneg fun i _ => ?_
  rw [pow_mul]
  positivity

/-- The expected `2k`-th trace moment, in the form used below. -/
theorem expect_trace_pow_two_mul_le {k : ℕ} (hk : 1 ≤ k) :
    expect (fun g : Config N => ((W g) ^ (2 * k)).trace)
      ≤ (N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (2 * k) := by
  obtain ⟨m, hm⟩ : ∃ m, m + 1 = 2 * k := ⟨2 * k - 1, by omega⟩
  have h := expect_trace_pow_le (N := N) hm
  rwa [hm] at h

/-- **Spectral-edge tail bound.**  For every order `k ≥ 1` and threshold `t > 0`, the
probability that the ensemble produces an eigenvalue of `W/√N` of modulus at least
`t` is at most `N (k+1)^(2k) / t^(2k)`. -/
theorem prob_exists_large_eigenvalue_le {k : ℕ} (hk : 1 ≤ k) (hN : 0 < N) {t : ℝ}
    (ht : 0 < t) :
    prob (Finset.univ.filter fun g : Config N =>
        ∃ i, t * Real.sqrt (N : ℝ) ≤ |(W_isHermitian g).eigenvalues i|)
      ≤ (N : ℝ) * ((k : ℝ) + 1) ^ (2 * k) / t ^ (2 * k) := by
  classical
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hthr : (0 : ℝ) < t ^ (2 * k) * (N : ℝ) ^ k := by positivity
  -- a large eigenvalue forces a large trace moment
  have hsub : (Finset.univ.filter fun g : Config N =>
        ∃ i, t * Real.sqrt (N : ℝ) ≤ |(W_isHermitian g).eigenvalues i|)
      ⊆ Finset.univ.filter fun g : Config N =>
        t ^ (2 * k) * (N : ℝ) ^ k ≤ ((W g) ^ (2 * k)).trace := by
    intro g hg
    obtain ⟨i, hi⟩ := (Finset.mem_filter.1 hg).2
    refine Finset.mem_filter.2 ⟨Finset.mem_univ g, ?_⟩
    have hpow : (t * Real.sqrt (N : ℝ)) ^ (2 * k) = t ^ (2 * k) * (N : ℝ) ^ k := by
      rw [mul_pow, pow_mul (Real.sqrt (N : ℝ)) 2 k, Real.sq_sqrt (le_of_lt hNR)]
    have hle : (t * Real.sqrt (N : ℝ)) ^ (2 * k)
        ≤ ((W_isHermitian g).eigenvalues i) ^ (2 * k) := by
      have h1 : (t * Real.sqrt (N : ℝ)) ^ (2 * k)
          ≤ |(W_isHermitian g).eigenvalues i| ^ (2 * k) :=
        pow_le_pow_left₀ (by positivity) hi (2 * k)
      have h2 : |(W_isHermitian g).eigenvalues i| ^ (2 * k)
          = ((W_isHermitian g).eigenvalues i) ^ (2 * k) := by
        rw [pow_mul, pow_mul, sq_abs]
      rwa [h2] at h1
    have hsum : ((W_isHermitian g).eigenvalues i) ^ (2 * k)
        ≤ ((W g) ^ (2 * k)).trace := by
      rw [WignerBridge.trace_pow_eq_sum_eigenvalues_real (W_isHermitian g)]
      refine Finset.single_le_sum (f := fun i => (W_isHermitian g).eigenvalues i ^ (2 * k))
        (fun j _ => ?_) (Finset.mem_univ i)
      show (0 : ℝ) ≤ (W_isHermitian g).eigenvalues j ^ (2 * k)
      rw [pow_mul]
      positivity
    rw [← hpow]
    exact hle.trans hsum
  refine (prob_mono hsub).trans ?_
  refine (markov (fun g : Config N => ((W g) ^ (2 * k)).trace)
    (fun g => trace_pow_two_mul_nonneg g k) hthr).trans ?_
  rw [div_le_div_iff₀ hthr (by positivity)]
  have hb := expect_trace_pow_two_mul_le (N := N) hk
  have hpos : (0 : ℝ) < t ^ (2 * k) := by positivity
  calc expect (fun g : Config N => ((W g) ^ (2 * k)).trace) * t ^ (2 * k)
      ≤ ((N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (2 * k)) * t ^ (2 * k) :=
        mul_le_mul_of_nonneg_right hb (le_of_lt hpos)
    _ = (N : ℝ) * ((k : ℝ) + 1) ^ (2 * k) * (t ^ (2 * k) * (N : ℝ) ^ k) := by
        rw [pow_succ]
        ring

end RademacherWigner