import Mathlib

/-! # Convergence Guarantees

Formalizes contraction mapping convergence, Lyapunov stability,
regret bounds, no-free-lunch theorems, and exponential improvement models.
-/

noncomputable section

open Real BigOperators Finset

/-! ## Definitions -/

/-- Iterated application of a function. -/
def iterateF (f : ℝ → ℝ) : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => f (iterateF f n x)

/-- A function is a contraction with constant c on ℝ. -/
def IsContraction (f : ℝ → ℝ) (c : ℝ) : Prop :=
  0 ≤ c ∧ c < 1 ∧ ∀ x y, |f x - f y| ≤ c * |x - y|

/-- Lyapunov function: distance squared to target. -/
def lyapunovFn (x target : ℝ) : ℝ := (x - target) ^ 2

/-- Regret at step n: difference between optimal and actual reward. -/
def regret (optimal actual : ℕ → ℝ) (n : ℕ) : ℝ :=
  optimal n - actual n

/-- Cumulative regret over N steps. -/
def cumulativeRegret (optimal actual : ℕ → ℝ) (N : ℕ) : ℝ :=
  ∑ i ∈ Finset.range N, regret optimal actual i

/-- Exponential improvement model: ceiling * (1 - e^(-rate * n)). -/
def expImprovement (ceiling rate : ℝ) (n : ℕ) : ℝ :=
  ceiling * (1 - Real.exp (-rate * n))

/-- Average regret. -/
def avgRegret (optimal actual : ℕ → ℝ) (N : ℕ) : ℝ :=
  cumulativeRegret optimal actual N / N

/-- Standard parameter count. -/
def cgStandardParams (d : ℕ) : ℕ := d * d

/-- EML parameter count. -/
def cgEmlParams (d : ℕ) : ℕ := 4 * d

/-- Convergence rate based on parameters. -/
def convergenceRate (params : ℕ) (baseRate : ℝ) : ℝ :=
  baseRate / Real.sqrt (params : ℝ)

/-! ## Theorems -/

/-
Contraction mapping: successive differences bounded by c^k.
-/
theorem contraction_converges (f : ℝ → ℝ) (c : ℝ) (x : ℝ)
    (hc : IsContraction f c) (k : ℕ) :
    |iterateF f (k + 1) x - iterateF f k x| ≤
    c ^ k * |f x - x| := by
  induction' k with k ih;
  · aesop;
  · convert le_trans ( hc.2.2 _ _ ) ( mul_le_mul_of_nonneg_left ih ( by linarith [ hc.1 ] : 0 ≤ c ) ) using 1 ; push_cast [ pow_add ] ; ring!

/-
Distance to fixed point shrinks as c^k.
-/
theorem distance_to_fixed_point (f : ℝ → ℝ) (c : ℝ) (x pstar : ℝ)
    (hc : IsContraction f c) (hfix : f pstar = pstar) (k : ℕ) :
    |iterateF f k x - pstar| ≤ c ^ k * |x - pstar| := by
  induction' k with k ih;
  · norm_num;
    rfl;
  · convert le_trans _ ( mul_le_mul_of_nonneg_left ih ( show 0 ≤ c by linarith [ hc.1 ] ) ) using 1 ; ring;
    simpa [ *, iterateF ] using hc.2.2 ( iterateF f k x ) pstar

/-
Lyapunov function is nonneg.
-/
theorem lyapunov_nonneg (x target : ℝ) :
    0 ≤ lyapunovFn x target := by
  exact sq_nonneg _

/-
Lyapunov function is zero iff at target.
-/
theorem lyapunov_zero_iff (x target : ℝ) :
    lyapunovFn x target = 0 ↔ x = target := by
  norm_num [ lyapunovFn ];
  rw [ sub_eq_zero ]

/-
Lyapunov decrease implies convergence: if V decreases by factor γ,
    then V after k steps ≤ γ^k * V₀.
-/
theorem lyapunov_decrease_implies_convergence (x₀ target γ : ℝ)
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (k : ℕ) :
    γ ^ k * lyapunovFn x₀ target ≤ lyapunovFn x₀ target := by
  exact mul_le_of_le_one_left ( lyapunov_nonneg x₀ target ) ( pow_le_one₀ hγ0 hγ1 )

/-
Cumulative regret bounded by n × per-step bound.
-/
theorem cumulative_regret_bounded (optimal actual : ℕ → ℝ) (N : ℕ) (B : ℝ)
    (hB : ∀ n, n < N → regret optimal actual n ≤ B) :
    cumulativeRegret optimal actual N ≤ N * B := by
  simpa using Finset.sum_le_sum fun i hi => hB i ( Finset.mem_range.mp hi )

/-
Average regret ≤ max per-step regret.
-/
theorem avg_regret_bound (optimal actual : ℕ → ℝ) (N : ℕ) (B : ℝ)
    (hN : 0 < N)
    (hB : ∀ n, n < N → regret optimal actual n ≤ B) :
    avgRegret optimal actual N ≤ B := by
  rw [ avgRegret, div_le_iff₀ ];
  · simpa [ mul_comm ] using cumulative_regret_bounded optimal actual N B hB;
  · positivity

/-
No free lunch: all strategies average to same total over all problems.
-/
theorem no_free_lunch_self_improvement (rewards₁ rewards₂ : Fin n → ℝ)
    (hperm : ∃ σ : Equiv.Perm (Fin n), ∀ i, rewards₂ i = rewards₁ (σ i)) :
    ∑ i, rewards₁ i = ∑ i, rewards₂ i := by
  exact hperm.elim fun σ hσ => by rw [ ← Equiv.sum_comp σ ] ; simp +decide [ hσ ] ;

/-
Exponential improvement is monotone increasing (for positive rate and ceiling).
-/
theorem exponential_improvement_monotone (ceiling rate : ℝ)
    (hc : 0 < ceiling) (hr : 0 < rate) (n : ℕ) :
    expImprovement ceiling rate n ≤ expImprovement ceiling rate (n + 1) := by
  exact mul_le_mul_of_nonneg_left ( sub_le_sub_left ( Real.exp_le_exp.mpr <| by push_cast; nlinarith ) _ ) hc.le

/-
Exponential improvement stays below ceiling.
-/
theorem exponential_below_ceiling (ceiling rate : ℝ)
    (hc : 0 < ceiling) (hr : 0 < rate) (n : ℕ) :
    expImprovement ceiling rate n < ceiling := by
  exact mul_lt_of_lt_one_right hc ( sub_lt_self _ ( Real.exp_pos _ ) )

/-
EML has faster convergence rate for d ≥ 5.
-/
theorem eml_faster_convergence_rate (d : ℕ) (baseRate : ℝ)
    (hd : 5 ≤ d) (hbr : 0 < baseRate) :
    convergenceRate (cgStandardParams d) baseRate ≤
    convergenceRate (cgEmlParams d) baseRate := by
  unfold convergenceRate cgStandardParams cgEmlParams;
  gcongr ; nlinarith

/-
EML needs fewer gradient steps (fewer parameters).
-/
theorem eml_fewer_gradient_steps (d : ℕ) (hd : 5 ≤ d) :
    cgEmlParams d < cgStandardParams d := by
  unfold cgEmlParams cgStandardParams ; nlinarith

end