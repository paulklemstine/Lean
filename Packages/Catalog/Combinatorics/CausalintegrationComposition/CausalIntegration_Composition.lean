import Shared.CausalintegrationCore.CausalIntegration_Core

/-!
# Causal integration: composition

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/CausalIntegration/Composition.lean`.  It is reconstructed
here as the composition theory of the causal operators introduced in
`Shared.CausalintegrationCore.CausalIntegration_Core`.

Main results:

* `CausalIntegration.isCausal_comp` — causal operators are closed under composition,
  so they form a monoid;
* `CausalIntegration.integrate_comp_diff` / `diff_comp_integrate` — integration and
  differencing are mutually inverse *as operators*;
* `CausalIntegration.iteratedIntegrate` and `iteratedIntegrate_isCausal` — the
  iterated running sum is causal;
* `CausalIntegration.integrate_two_eq_weighted` — the second running sum is the
  discrete Abel/Cauchy formula `∑_{k ≤ n} (n + 1 - k) f k`.
-/

namespace CausalIntegration

/-- **Composition.**  A composite of causal operators is causal. -/
theorem isCausal_comp {S T : Op} (hS : IsCausal S) (hT : IsCausal T) :
    IsCausal (S ∘ T) := by
  intro f g n h
  refine hS (T f) (T g) n fun k hk => ?_
  exact hT f g k fun j hj => h j (hj.trans hk)

/-- Integration then differencing is the identity operator. -/
theorem diff_comp_integrate : diff ∘ integrate = (id : Op) := by
  funext f n
  exact diff_integrate f n

/-- Differencing then integration is the identity operator. -/
theorem integrate_comp_diff : integrate ∘ diff = (id : Op) := by
  funext f n
  exact integrate_diff f n

/-- The `m`-fold running sum. -/
def iteratedIntegrate : ℕ → Op
  | 0 => id
  | m + 1 => integrate ∘ iteratedIntegrate m

@[simp] lemma iteratedIntegrate_zero : iteratedIntegrate 0 = id := rfl

lemma iteratedIntegrate_succ (m : ℕ) :
    iteratedIntegrate (m + 1) = integrate ∘ iteratedIntegrate m := rfl

/-- Every iterated running sum is causal. -/
theorem iteratedIntegrate_isCausal (m : ℕ) : IsCausal (iteratedIntegrate m) := by
  induction m with
  | zero => exact isCausal_id
  | succ k ih => exact isCausal_comp integrate_isCausal ih

/-- The double running sum is the weighted single sum
`(∫²f)(n) = ∑_{k ≤ n} (n + 1 - k) · f k`, the discrete Abel summation formula. -/
theorem integrate_two_eq_weighted (f : Signal) (n : ℕ) :
    iteratedIntegrate 2 f n = ∑ k ∈ Finset.range (n + 1), ((n + 1 - k : ℕ) : ℝ) * f k := by
  induction n with
  | zero => simp [iteratedIntegrate, integrate]
  | succ m ih =>
      have hstep : iteratedIntegrate 2 f (m + 1)
          = iteratedIntegrate 2 f m + integrate f (m + 1) := by
        simp only [iteratedIntegrate_succ, Function.comp_apply]
        exact integrate_succ _ m
      rw [hstep, ih, integrate,
        Finset.sum_range_succ (f := fun k => ((m + 1 + 1 - k : ℕ) : ℝ) * f k),
        Finset.sum_range_succ (f := f)]
      have hlast : ((m + 1 + 1 - (m + 1) : ℕ) : ℝ) = 1 := by norm_num
      rw [hlast, one_mul]
      have key : ∑ k ∈ Finset.range (m + 1), ((m + 1 + 1 - k : ℕ) : ℝ) * f k
          = ∑ k ∈ Finset.range (m + 1), (((m + 1 - k : ℕ) : ℝ) * f k + f k) := by
        refine Finset.sum_congr rfl fun k hk => ?_
        have hk' : k ≤ m := Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)
        have hc : ((m + 1 + 1 - k : ℕ) : ℝ) = ((m + 1 - k : ℕ) : ℝ) + 1 := by
          rw [show m + 1 + 1 - k = (m + 1 - k) + 1 by omega]
          push_cast
          ring
        rw [hc]
        ring
      rw [key, Finset.sum_add_distrib]
      ring

/-- Iterating differencing undoes iterating integration. -/
theorem iteratedDiff_integrate (m : ℕ) (f : Signal) :
    (diff^[m]) (iteratedIntegrate m f) = f := by
  induction m generalizing f with
  | zero => rfl
  | succ k ih =>
      rw [iteratedIntegrate_succ]
      simp only [Function.comp_apply]
      rw [Function.iterate_succ_apply]
      have hdi : diff (integrate (iteratedIntegrate k f)) = iteratedIntegrate k f :=
        funext fun n => diff_integrate _ n
      rw [hdi, ih]

end CausalIntegration