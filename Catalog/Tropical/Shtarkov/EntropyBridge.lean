/-
# The entropy bridge: tropical envelope = empirical entropy

Second research cycle.  The upper bound of `FiniteState.lean` was obtained by
counting; here we *identify* the tropical (max-plus) envelope of the
finite-state class analytically.  The maximum-likelihood value of a word is
exactly `exp(-Ĥ(x))` where `Ĥ(x)` is the **empirical (conditional) entropy** of
`x` relative to the machine — the sum, over states, of the number of visits
times the binary entropy of the empirical emission frequency in that state.

Consequences proved here:

* `shtarkovSum_eq_sum_exp_neg_empEntropy` — the Shtarkov sum is the partition
  function `∑_x e^{-Ĥ(x)}` of empirical entropy: minimax regret is the free
  energy of the empirical-entropy ensemble;
* `sum_exp_neg_empEntropy_le` — a Kraft-type inequality: for *any* `k`-state
  machine, `∑_{x ∈ {0,1}^n} e^{-Ĥ(x)} ≤ ((n+1)^2)^k`, a purely combinatorial
  statement about empirical entropies of binary words;
* `empEntropy_le` — `Ĥ(x) ≤ n log 2`, via `binEnt_le_log_two`.
-/

import Catalog.Tropical.Shtarkov.FiniteState

open Finset

namespace TropicalShtarkov

variable {k : ℕ}

/-! ## Binary entropy (in nats) -/

/-- Binary entropy in nats. -/
noncomputable def binEnt (p : ℝ) : ℝ := -p * Real.log p - (1 - p) * Real.log (1 - p)

theorem binEnt_zero : binEnt 0 = 0 := by simp [binEnt]

theorem binEnt_one : binEnt 1 = 0 := by simp [binEnt]

/-- Binary entropy is maximal at `1/2`, where it equals `log 2`. -/
theorem binEnt_le_log_two {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) : binEnt p ≤ Real.log 2 := by
  rcases eq_or_lt_of_le h0 with h | hp0
  · rw [← h, binEnt_zero]
    exact Real.log_nonneg (by norm_num)
  rcases eq_or_lt_of_le h1 with h | hp1
  · rw [h, binEnt_one]
    exact Real.log_nonneg (by norm_num)
  have hq : 0 < 1 - p := by linarith
  have e1 : Real.log (1 / (2 * p)) ≤ 1 / (2 * p) - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  have e2 : Real.log (1 / (2 * (1 - p))) ≤ 1 / (2 * (1 - p)) - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  have l1 : Real.log (1 / (2 * p)) = -(Real.log 2 + Real.log p) := by
    rw [one_div, Real.log_inv, Real.log_mul (by norm_num) (ne_of_gt hp0)]
  have l2 : Real.log (1 / (2 * (1 - p))) = -(Real.log 2 + Real.log (1 - p)) := by
    rw [one_div, Real.log_inv, Real.log_mul (by norm_num) (ne_of_gt hq)]
  rw [l1] at e1
  rw [l2] at e2
  have m1 : p * (-(Real.log 2 + Real.log p)) ≤ p * (1 / (2 * p) - 1) :=
    mul_le_mul_of_nonneg_left e1 hp0.le
  have m2 : (1 - p) * (-(Real.log 2 + Real.log (1 - p))) ≤ (1 - p) * (1 / (2 * (1 - p)) - 1) :=
    mul_le_mul_of_nonneg_left e2 hq.le
  have r1 : p * (1 / (2 * p) - 1) = 1 / 2 - p := by field_simp
  have r2 : (1 - p) * (1 / (2 * (1 - p)) - 1) = 1 / 2 - (1 - p) := by field_simp
  rw [r1] at m1
  rw [r2] at m2
  unfold binEnt
  nlinarith [m1, m2]

/-! ## Maximum-likelihood factors -/

theorem mlParam_zero_left (b : ℕ) : mlParam 0 b = 0 := by
  unfold mlParam; split <;> simp

theorem mlParam_pos {a : ℕ} (b : ℕ) (ha : 0 < a) : 0 < mlParam a b := by
  unfold mlParam
  rw [if_neg (by omega)]
  have h1 : (0:ℝ) < a := by exact_mod_cast ha
  have h2 : (0:ℝ) < (a : ℝ) + b := by positivity
  positivity

theorem mlParam_lt_one (a : ℕ) {b : ℕ} (hb : 0 < b) : mlParam a b < 1 := by
  unfold mlParam
  rw [if_neg (by omega)]
  have h1 : (0:ℝ) < b := by exact_mod_cast hb
  have h2 : (0:ℝ) < (a : ℝ) + b := by positivity
  rw [div_lt_one h2]
  linarith

/-- Every maximum-likelihood factor is strictly positive (including the
degenerate cases `a = 0` and `b = 0`). -/
theorem mlFactor_pos (a b : ℕ) : 0 < mlParam a b ^ a * (1 - mlParam a b) ^ b := by
  rcases Nat.eq_zero_or_pos a with ha | ha
  · subst ha
    rw [mlParam_zero_left]
    norm_num
  rcases Nat.eq_zero_or_pos b with hb | hb
  · subst hb
    have : (0:ℝ) < mlParam a 0 := mlParam_pos 0 ha
    simpa using pow_pos this a
  exact mul_pos (pow_pos (mlParam_pos b ha) a)
    (pow_pos (by linarith [mlParam_lt_one a hb]) b)

/-- **The maximum-likelihood factor is the exponential of an entropy.** -/
theorem log_mlFactor (a b : ℕ) :
    Real.log (mlParam a b ^ a * (1 - mlParam a b) ^ b)
      = -(((a : ℝ) + b) * binEnt (mlParam a b)) := by
  set t := mlParam a b with ht
  have hta : 0 < t ^ a := by
    rcases Nat.eq_zero_or_pos a with ha | ha
    · simp [ha]
    · exact pow_pos (mlParam_pos b ha) a
  have htb : 0 < (1 - t) ^ b := by
    rcases Nat.eq_zero_or_pos b with hb | hb
    · simp [hb]
    · exact pow_pos (by linarith [mlParam_lt_one a hb]) b
  rw [Real.log_mul (ne_of_gt hta) (ne_of_gt htb), Real.log_pow, Real.log_pow]
  rcases Nat.eq_zero_or_pos (a + b) with hab | hab
  · have ha : a = 0 := by omega
    have hb : b = 0 := by omega
    simp [ha, hb]
  have hne : ¬ a + b = 0 := by omega
  have htv : t = (a : ℝ) / ((a : ℝ) + b) := by rw [ht]; unfold mlParam; rw [if_neg hne]
  have hsum : (0:ℝ) < (a : ℝ) + b := cast_add_pos hne
  have hA : (a : ℝ) = ((a : ℝ) + b) * t := by rw [htv]; field_simp
  have hB : (b : ℝ) = ((a : ℝ) + b) * (1 - t) := by rw [htv]; field_simp; ring
  unfold binEnt
  linear_combination Real.log t * hA + Real.log (1 - t) * hB

/-! ## Empirical entropy of a word relative to a machine -/

/-- The empirical (conditional) entropy of the word `x` relative to `M`: the sum
over states of the visit count times the binary entropy of the empirical
emission frequency in that state. -/
noncomputable def empEntropy (M : FSM k) (n : ℕ) (x : Word n) : ℝ :=
  ∑ s : Fin k, ((visits M x (s, true) + visits M x (s, false) : ℕ) : ℝ)
    * binEnt (mlParam (visits M x (s, true)) (visits M x (s, false)))

/-- **Maximum likelihood = exponential of minus the empirical entropy.** -/
theorem prob_ml_eq_exp_neg_empEntropy (M : FSM k) (n : ℕ) (x : Word n) :
    prob M (mlOf (countVec M x)).1 n x = Real.exp (-(empEntropy M n x)) := by
  have hfac : prob M (mlOf (countVec M x)).1 n x
      = ∏ s : Fin k, (mlParam (visits M x (s, true)) (visits M x (s, false))
          ^ visits M x (s, true)
        * (1 - mlParam (visits M x (s, true)) (visits M x (s, false)))
          ^ visits M x (s, false)) := by
    rw [prob_eq_prod_states]
    rfl
  have hpos : 0 < prob M (mlOf (countVec M x)).1 n x := by
    rw [hfac]
    exact Finset.prod_pos fun s _ => mlFactor_pos _ _
  have hlog : Real.log (prob M (mlOf (countVec M x)).1 n x) = -(empEntropy M n x) := by
    rw [hfac, Real.log_prod (fun s _ => ne_of_gt (mlFactor_pos _ _))]
    unfold empEntropy
    rw [← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl fun s _ => ?_
    rw [log_mlFactor]
    push_cast
    ring
  rw [← hlog, Real.exp_log hpos]

/-! ## The Shtarkov sum as a partition function -/

/-- The pointwise supremum over the class is attained at the plug-in source. -/
theorem ciSup_fsmClass_eq (M : FSM k) (n : ℕ) (x : Word n) :
    (⨆ θ : Params k, fsmClass M n θ x) = prob M (mlOf (countVec M x)).1 n x := by
  refine le_antisymm (ciSup_le fun θ => prob_le_prob_ml M θ.2 n x) ?_
  exact le_ciSup (bddAbove_of_le_one (fsmClass_le_one M n) x) (mlOf (countVec M x))

/-- **The Shtarkov sum is the partition function of empirical entropy.** -/
theorem shtarkovSum_eq_sum_exp_neg_empEntropy (M : FSM k) (n : ℕ) :
    shtarkovSum (fsmClass M n) = ∑ x : Word n, Real.exp (-(empEntropy M n x)) := by
  unfold shtarkovSum
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [ciSup_fsmClass_eq, prob_ml_eq_exp_neg_empEntropy]

/-- **A Kraft-type inequality for empirical entropy.**  For any `k`-state
machine, the empirical entropies of the `2^n` binary words of length `n` satisfy
`∑_x e^{-Ĥ(x)} ≤ ((n+1)^2)^k`. -/
theorem sum_exp_neg_empEntropy_le (M : FSM k) (n : ℕ) :
    ∑ x : Word n, Real.exp (-(empEntropy M n x)) ≤ (((n : ℝ) + 1) * ((n : ℝ) + 1)) ^ k := by
  rw [← shtarkovSum_eq_sum_exp_neg_empEntropy]
  exact shtarkovSum_fsmClass_le M n

/-! ## Empirical entropy is at most `n log 2` -/

/-- The visit counts of a word partition its length. -/
theorem sum_visits_eq (M : FSM k) {n : ℕ} (x : Word n) :
    ∑ p : Fin k × Bool, visits M x p = n := by
  unfold visits
  rw [← Finset.card_eq_sum_card_fiberwise
    (f := fun i => (stAux M M.init (pad x) i, pad x i)) (fun i _ => mem_univ _)]
  exact Finset.card_range n

/-- The per-state visit counts of a word sum to its length. -/
theorem sum_visits_states_nat (M : FSM k) {n : ℕ} (x : Word n) :
    ∑ s : Fin k, (visits M x (s, true) + visits M x (s, false)) = n := by
  have h2 : ∑ s : Fin k, (visits M x (s, true) + visits M x (s, false))
      = ∑ p : Fin k × Bool, visits M x p := by
    rw [Fintype.sum_prod_type]
    exact Finset.sum_congr rfl fun s _ =>
      (Fintype.sum_bool (fun b => visits M x (s, b))).symm
  rw [h2, sum_visits_eq]

theorem sum_visits_states (M : FSM k) {n : ℕ} (x : Word n) :
    ∑ s : Fin k, ((visits M x (s, true) + visits M x (s, false) : ℕ) : ℝ) = n := by
  exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) (sum_visits_states_nat M x)

/-- Empirical entropy never exceeds the trivial bound `n log 2`. -/
theorem empEntropy_le (M : FSM k) (n : ℕ) (x : Word n) :
    empEntropy M n x ≤ n * Real.log 2 := by
  have hbound : ∀ s : Fin k,
      ((visits M x (s, true) + visits M x (s, false) : ℕ) : ℝ)
        * binEnt (mlParam (visits M x (s, true)) (visits M x (s, false)))
      ≤ ((visits M x (s, true) + visits M x (s, false) : ℕ) : ℝ) * Real.log 2 := by
    intro s
    refine mul_le_mul_of_nonneg_left ?_ (by positivity)
    exact binEnt_le_log_two (mlParam_nonneg _ _) (mlParam_le_one _ _)
  calc empEntropy M n x ≤ ∑ s : Fin k,
        ((visits M x (s, true) + visits M x (s, false) : ℕ) : ℝ) * Real.log 2 :=
        Finset.sum_le_sum fun s _ => hbound s
    _ = n * Real.log 2 := by rw [← Finset.sum_mul, sum_visits_states]

/-- Empirical entropy is nonnegative. -/
theorem empEntropy_nonneg (M : FSM k) (n : ℕ) (x : Word n) : 0 ≤ empEntropy M n x := by
  refine Finset.sum_nonneg fun s _ => mul_nonneg (by positivity) ?_
  set t := mlParam (visits M x (s, true)) (visits M x (s, false)) with ht
  have h0 : 0 ≤ t := mlParam_nonneg _ _
  have h1 : t ≤ 1 := mlParam_le_one _ _
  unfold binEnt
  have e1 : -t * Real.log t ≥ 0 := by
    rcases eq_or_lt_of_le h0 with h | hpos
    · rw [← h]; simp
    · have : Real.log t ≤ 0 := Real.log_nonpos (le_of_lt hpos) h1
      nlinarith
  have e2 : -(1 - t) * Real.log (1 - t) ≥ 0 := by
    rcases eq_or_lt_of_le h1 with h | hlt
    · rw [h]; simp
    · have hq : 0 < 1 - t := by linarith
      have : Real.log (1 - t) ≤ 0 := Real.log_nonpos hq.le (by linarith)
      nlinarith
  linarith

end TropicalShtarkov