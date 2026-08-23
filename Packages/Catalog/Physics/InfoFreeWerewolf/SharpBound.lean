/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Catalog.Physics.InfoFreeWerewolf.SecondOrder

/-!
# The sharp union-bound defect: `n · defect ≤ k(k-1)/2`

`Bounds.lean` proves the union bound `failProb v k ≤ k · surv (v+k)` together with an
*existential* `O(1/n)` reverse bound.  This file replaces the existential constant by the
explicit value `k(k-1)/2 = C(k,2)` — the number of unordered pairs of wolves — and shows
that this constant is **optimal**: it is attained exactly, at every odd population, for
`k = 2` and `k = 3`.

The engine is the exact *defect recursion*

`(v+k+3) · defect (v+2) (k+1) = (k+1) · defect (v+1) k + (v+2) · defect v (k+1)`,

in which the union-bound term `k · surv n` cancels identically because `surv` satisfies the
same one-step ladder as the population.  Writing `g v k = (v+k)·defect v k`, this becomes

`g (v+2) (k+1) = [ (k+1)·g (v+1) k + (v+2)·g v (k+1) ] / (v+k+1)`,

a convex-combination-like recursion for which `C(k,2)` is a *fixed point*: substituting
`g(v+1,k) = C(k,2)` and `g(v,k+1) = C(k+1,2)` on the right reproduces `C(k+1,2)` exactly.
That is the structural reason the constant is `C(k,2)` and not something else.

## Main results

* `surv_le_surv_add_two`, `surv_add_six_le_half` : elementary monotonicity of the survival
  ladder along a fixed parity, and the numerical bound `surv n ≤ 1/2` for `n ≥ 6`.
* `mul_surv_le_half` : `k · surv k ≤ (k+1)/2`.
* `surv_sq_odd_le`, `mul_surv_sq_le_two` : a purely rational proof that `n · surv n ^ 2 ≤ 2`
  — an elementary bound on the Wallis product, with no analysis.
* `defect_recursion` : the exact defect recursion.
* `defect_scaled_le` : **the sharp bound** `(v+k) · defect v k ≤ k(k-1)/2`.
* `failProb_ge_sharp` : the resulting explicit two-sided estimate for the wolf-win
  probability.
* `sharp_constant_attained_two_wolves`, `sharp_constant_attained_three_wolves` :
  optimality of the constant `C(k,2)` for `k = 2, 3`.
-/

namespace InfoFreeWerewolf

/-! ### Elementary bounds on the survival ladder -/

/-- Along a fixed parity the survival product is non-increasing. -/
theorem surv_le_surv_add_two (n : ℕ) : surv (n + 2) ≤ surv n := by
  rw [surv_succ_succ]
  have hp : (0 : ℚ) < surv n := surv_pos n
  rw [div_le_iff₀ (by positivity)]
  nlinarith

/-- From population `6` on, the survival product is at most `1/2`.  (It is not at
population `5`: `surv 5 = 8/15 > 1/2`, an example of the parity oscillation.) -/
theorem surv_add_six_le_half : ∀ n : ℕ, surv (n + 6) ≤ 1 / 2
  | 0 => by norm_num [surv]
  | 1 => by norm_num [surv]
  | (n + 2) => by
      have h := surv_add_six_le_half n
      have h2 : surv (n + 2 + 6) ≤ surv (n + 6) := by
        rw [show n + 2 + 6 = (n + 6) + 2 from by omega]
        exact surv_le_surv_add_two (n + 6)
      linarith

/-- `k · surv k ≤ (k+1)/2`, proved by a two-step induction along the ladder. -/
theorem mul_surv_le_half : ∀ k : ℕ, (k : ℚ) * surv k ≤ ((k : ℚ) + 1) / 2
  | 0 => by norm_num
  | 1 => by norm_num [surv]
  | 2 => by norm_num [surv]
  | (k + 3) => by
      have h := mul_surv_le_half (k + 1)
      have hp : (0 : ℚ) < surv (k + 1) := surv_pos _
      push_cast at h
      rw [show k + 3 = (k + 1) + 2 from by omega, surv_succ_succ (k + 1)]
      push_cast
      have key : ((k : ℚ) + 1 + 2) * (surv (k + 1) * ((k : ℚ) + 1 + 1) / ((k : ℚ) + 1 + 2))
          = surv (k + 1) * ((k : ℚ) + 2) := by
        field_simp
        ring
      rw [key]
      nlinarith [h, hp, mul_le_mul_of_nonneg_left h (show (0 : ℚ) ≤ (k : ℚ) + 2 by positivity)]

/-! ### An elementary rational bound on the Wallis product -/

/-- The odd counterpart of `surv_sq_even_le`.  Note the *half*-weight `m+1` instead of
`2m+1`: the odd ladder sits above the separator, and this is the sharp elementary bound
in the other direction.  Equivalently `(2m+1) · surv (2m+1) ^ 2 ≤ (2m+1)/(m+1) ≤ 2`,
i.e. the Wallis product `W m` is bounded by `2` — proved here with no analysis at all. -/
theorem surv_sq_odd_le : ∀ m : ℕ, ((m : ℚ) + 1) * surv (2 * m + 1) ^ 2 ≤ 1
  | 0 => by norm_num [surv]
  | (m + 1) => by
      have h := surv_sq_odd_le m
      have hp : (0 : ℚ) < surv (2 * m + 1) := surv_pos _
      have hd : (0 : ℚ) < (2 * (m : ℚ) + 1 + 2) ^ 2 := by positivity
      rw [show 2 * (m + 1) + 1 = (2 * m + 1) + 2 from by omega, surv_succ_succ (2 * m + 1)]
      push_cast
      rw [div_pow, ← mul_div_assoc, div_le_one hd]
      nlinarith [h, hp, sq_nonneg (surv (2 * m + 1))]

/-- `n · surv n ^ 2 ≤ 2` for every population, uniformly in the parity.  The even case is
bounded by `1` (`surv_sq_even_le`) and the odd case by `2` (`surv_sq_odd_le`); the true
limits are `2/π ≈ 0.6366` and `π/2 ≈ 1.5708`. -/
theorem mul_surv_sq_le_two (n : ℕ) : (n : ℚ) * surv n ^ 2 ≤ 2 := by
  rcases Nat.even_or_odd n with ⟨m, hm⟩ | ⟨m, hm⟩
  · subst hm
    have h := surv_sq_even_le m
    have hp : (0 : ℚ) < surv (m + m) := surv_pos _
    have e : m + m = 2 * m := by omega
    rw [e] at *
    push_cast
    nlinarith
  · subst hm
    have h := surv_sq_odd_le m
    have hp : (0 : ℚ) < surv (2 * m + 1) := surv_pos _
    push_cast
    nlinarith

/-! ### The value of the game with a single villager -/

/-- With one villager and at least two wolves the village is already lost. -/
theorem failProb_one_villager (j : ℕ) : failProb 1 (j + 2) = 1 := by
  rw [failProb_step 0 (j + 1)]
  have e1 : failProb 0 (j + 1) = 1 := by rw [failProb]
  have e2 : failProb (0 - 1) (j + 1 + 1) = 1 := by norm_num [failProb]
  rw [e1, e2]
  have h : ((j : ℚ) + 1 + 2) ≠ 0 := by positivity
  field_simp
  ring

/-! ### The defect recursion -/

/-- **The defect recursion.**  The union-bound term `k · surv n` cancels identically
against the same term in the two children, because the survival ladder and the population
ladder step in lockstep.  What remains is a clean linear recursion in the defect alone. -/
theorem defect_recursion (v k : ℕ) :
    ((v : ℚ) + k + 3) * defect (v + 2) (k + 1)
      = ((k : ℚ) + 1) * defect (v + 1) k + ((v : ℚ) + 2) * defect v (k + 1) := by
  have hs : surv (v + k + 3) = surv (v + k + 1) * ((v : ℚ) + k + 2) / ((v : ℚ) + k + 3) := by
    rw [show v + k + 3 = (v + k + 1) + 2 from by omega, surv_succ_succ (v + k + 1)]
    push_cast
    ring
  simp only [defect]
  rw [show v + 2 + (k + 1) = v + k + 3 from by omega,
    show v + 1 + k = v + k + 1 from by omega,
    show v + (k + 1) = v + k + 1 from by omega,
    failProb_step' v k, hs]
  have hne : ((v : ℚ) + k + 3) ≠ 0 := by positivity
  push_cast
  field_simp
  ring

/-! ### The sharp bound -/

/-- **Sharp union-bound defect.**  For every population `n = v + k` and every wolf count,

`n · (k · surv n - failProb v k) ≤ k(k-1)/2 = C(k,2)`.

The constant `C(k,2)` counts the unordered pairs of wolves, i.e. exactly the first
inclusion–exclusion correction to the union bound; the proof shows it is a fixed point of
the defect recursion.  Together with `failProb_le_union` this pins the wolf-win probability
to an interval of width `C(k,2)/n`. -/
theorem defect_scaled_le : ∀ v k : ℕ,
    ((v : ℚ) + (k : ℚ)) * defect v k ≤ (k : ℚ) * ((k : ℚ) - 1) / 2
  | 0, 0 => by norm_num [defect, failProb]
  | 0, (j + 1) => by
      have h := mul_surv_le_half (j + 1)
      have e : failProb 0 (j + 1) = 1 := by rw [failProb]
      simp only [defect, Nat.zero_add, e]
      push_cast at h ⊢
      nlinarith [h]
  | 1, 0 => by norm_num [defect, failProb]
  | 1, 1 => by
      have e : failProb 1 1 = surv 2 := by rw [failProb_one_wolf]
      norm_num [defect, e]
  | 1, (j + 2) => by
      have e := failProb_one_villager j
      have hp : (0 : ℚ) < surv (j + 3) := surv_pos _
      simp only [defect, e, show 1 + (j + 2) = j + 3 from by omega]
      push_cast
      rcases Nat.lt_or_ge j 3 with hj | hj
      · interval_cases j <;> norm_num [surv]
      · obtain ⟨t, rfl⟩ : ∃ t, j = t + 3 := ⟨j - 3, by omega⟩
        have hhalf : surv (t + 3 + 3) ≤ 1 / 2 := by
          rw [show t + 3 + 3 = t + 6 from by omega]
          exact surv_add_six_le_half t
        have hmul : ((t : ℚ) + 5) * ((t : ℚ) + 6) * surv (t + 3 + 3)
            ≤ ((t : ℚ) + 5) * ((t : ℚ) + 6) * (1 / 2) :=
          mul_le_mul_of_nonneg_left hhalf (by positivity)
        push_cast
        nlinarith [hmul]
  | (v + 2), 0 => by norm_num [defect, failProb]
  | (v + 2), (k + 1) => by
      have h1 := defect_scaled_le (v + 1) k
      have h2 := defect_scaled_le v (k + 1)
      have hr := defect_recursion v k
      have hpos : (0 : ℚ) < (v : ℚ) + k + 1 := by positivity
      push_cast at h1 h2 ⊢
      have key : ((v : ℚ) + k + 1) * (((v : ℚ) + 2 + ((k : ℚ) + 1)) * defect (v + 2) (k + 1))
          ≤ ((v : ℚ) + k + 1) * (((k : ℚ) + 1) * ((k : ℚ) + 1 - 1) / 2) := by
        have hrr : ((v : ℚ) + 2 + ((k : ℚ) + 1)) * defect (v + 2) (k + 1)
            = ((k : ℚ) + 1) * defect (v + 1) k + ((v : ℚ) + 2) * defect v (k + 1) := by
          rw [← hr]
          ring
        rw [hrr]
        nlinarith [h1, h2,
          mul_le_mul_of_nonneg_left h1 (show (0 : ℚ) ≤ (k : ℚ) + 1 by positivity),
          mul_le_mul_of_nonneg_left h2 (show (0 : ℚ) ≤ (v : ℚ) + 2 by positivity)]
      exact le_of_mul_le_mul_left key hpos
  termination_by v _ => v

/-- **Explicit two-sided estimate.**  For every `v` and `k`,
`k·surv n - C(k,2)/n ≤ failProb v k ≤ k·surv n` with `n = v + k` (positive `n`). -/
theorem failProb_ge_sharp (v k : ℕ) (hn : 0 < v + k) :
    (k : ℚ) * surv (v + k) - ((k : ℚ) * ((k : ℚ) - 1) / 2) / ((v : ℚ) + (k : ℚ))
      ≤ failProb v k := by
  have hpos : (0 : ℚ) < (v : ℚ) + (k : ℚ) := by
    have h0 : (0 : ℚ) < ((v + k : ℕ) : ℚ) := by exact_mod_cast hn
    push_cast at h0
    linarith
  have h := defect_scaled_le v k
  simp only [defect] at h
  have key : (k : ℚ) * surv (v + k) - failProb v k
      ≤ ((k : ℚ) * ((k : ℚ) - 1) / 2) / ((v : ℚ) + (k : ℚ)) := by
    rw [le_div_iff₀ hpos]
    nlinarith [h]
  linarith

/-! ### Optimality of the constant -/

/-- The constant `C(2,2) = 1` is attained at every odd population with two wolves. -/
theorem sharp_constant_attained_two_wolves (m : ℕ) :
    (((2 * m + 1 : ℕ) : ℚ) + ((2 : ℕ) : ℚ)) * defect (2 * m + 1) 2
      = ((2 : ℕ) : ℚ) * (((2 : ℕ) : ℚ) - 1) / 2 := by
  have e : ((2 * m + 1 : ℕ) : ℚ) + ((2 : ℕ) : ℚ) = 2 * (m : ℚ) + 3 := by
    push_cast
    ring
  rw [e, defect_two_wolves_odd m]
  norm_num

/-- The constant `C(3,2) = 3` is attained at every odd population with three wolves. -/
theorem sharp_constant_attained_three_wolves (m : ℕ) :
    (((2 * m : ℕ) : ℚ) + ((3 : ℕ) : ℚ)) * defect (2 * m) 3
      = ((3 : ℕ) : ℚ) * (((3 : ℕ) : ℚ) - 1) / 2 := by
  have e : ((2 * m : ℕ) : ℚ) + ((3 : ℕ) : ℚ) = 2 * (m : ℚ) + 3 := by
    push_cast
    ring
  rw [e, defect_three_wolves_odd m]
  norm_num

/-! ### A quantitative form of the parity expansions -/

/-- **Explicit rate for the parity expansions.**  The rescaled wolf-win probability
`√n · failProb (n-k) k` differs from `k · √n · surv n` by at most `C(k,2)/√n`.  Combined
with `tendsto_scaled_surv_even_pop` and `tendsto_scaled_surv_odd_pop` this turns the two
parity limits `k√(2/π)` and `k√(π/2)` into quantitative statements with an explicit,
`k`-dependent but population-uniform error term of order `n^{-1/2}`. -/
theorem scaled_failProb_error_bound (v k : ℕ) (hn : 0 < v + k) :
    |Real.sqrt ((v + k : ℕ) : ℝ) * ((failProb v k : ℚ) : ℝ)
        - (k : ℝ) * (Real.sqrt ((v + k : ℕ) : ℝ) * ((surv (v + k) : ℚ) : ℝ))|
      ≤ ((k : ℝ) * ((k : ℝ) - 1) / 2) / Real.sqrt ((v + k : ℕ) : ℝ) := by
  have hnpos : (0 : ℝ) < ((v + k : ℕ) : ℝ) := by exact_mod_cast hn
  have hs : 0 < Real.sqrt ((v + k : ℕ) : ℝ) := Real.sqrt_pos.2 hnpos
  have hss : Real.sqrt ((v + k : ℕ) : ℝ) * Real.sqrt ((v + k : ℕ) : ℝ) = ((v + k : ℕ) : ℝ) :=
    Real.mul_self_sqrt hnpos.le
  have hq0 : (0 : ℚ) ≤ (k : ℚ) * surv (v + k) - failProb v k := by
    have := failProb_le_union v k
    linarith
  have hq1 : (k : ℚ) * surv (v + k) - failProb v k
      ≤ ((k : ℚ) * ((k : ℚ) - 1) / 2) / ((v : ℚ) + (k : ℚ)) := by
    have := failProb_ge_sharp v k hn
    linarith
  have hr0 : (0 : ℝ) ≤ (k : ℝ) * ((surv (v + k) : ℚ) : ℝ) - ((failProb v k : ℚ) : ℝ) := by
    have := (Rat.cast_le (K := ℝ)).2 hq0
    push_cast at this
    linarith
  have hr1 : (k : ℝ) * ((surv (v + k) : ℚ) : ℝ) - ((failProb v k : ℚ) : ℝ)
      ≤ ((k : ℝ) * ((k : ℝ) - 1) / 2) / ((v : ℝ) + (k : ℝ)) := by
    have := (Rat.cast_le (K := ℝ)).2 hq1
    push_cast at this
    linarith
  have hvk : ((v : ℝ) + (k : ℝ)) = ((v + k : ℕ) : ℝ) := by push_cast; ring
  rw [hvk] at hr1
  rw [abs_sub_comm, abs_of_nonneg (by nlinarith [hr0, hs.le] : (0 : ℝ) ≤
    (k : ℝ) * (Real.sqrt ((v + k : ℕ) : ℝ) * ((surv (v + k) : ℚ) : ℝ))
      - Real.sqrt ((v + k : ℕ) : ℝ) * ((failProb v k : ℚ) : ℝ))]
  rw [le_div_iff₀ hs]
  have hkey : ((k : ℝ) * (Real.sqrt ((v + k : ℕ) : ℝ) * ((surv (v + k) : ℚ) : ℝ))
      - Real.sqrt ((v + k : ℕ) : ℝ) * ((failProb v k : ℚ) : ℝ)) * Real.sqrt ((v + k : ℕ) : ℝ)
      = (Real.sqrt ((v + k : ℕ) : ℝ) * Real.sqrt ((v + k : ℕ) : ℝ)) *
        ((k : ℝ) * ((surv (v + k) : ℚ) : ℝ) - ((failProb v k : ℚ) : ℝ)) := by
    ring
  rw [hkey, hss]
  have hC : ((v + k : ℕ) : ℝ) * (((k : ℝ) * ((k : ℝ) - 1) / 2) / ((v + k : ℕ) : ℝ))
      = (k : ℝ) * ((k : ℝ) - 1) / 2 := by
    field_simp
  calc ((v + k : ℕ) : ℝ) * ((k : ℝ) * ((surv (v + k) : ℚ) : ℝ) - ((failProb v k : ℚ) : ℝ))
      ≤ ((v + k : ℕ) : ℝ) * (((k : ℝ) * ((k : ℝ) - 1) / 2) / ((v + k : ℕ) : ℝ)) :=
        mul_le_mul_of_nonneg_left hr1 hnpos.le
    _ = (k : ℝ) * ((k : ℝ) - 1) / 2 := hC

end InfoFreeWerewolf