import Mathlib

/-!
# Causal integration: core

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/CausalIntegration/Core.lean`.  It is reconstructed here
as a self-contained development of *discrete causal operators*.

An operator `T` on discrete signals `ℕ → ℝ` is **causal** when the value of `T f`
at time `n` depends only on the samples `f 0, …, f n`.  The prototypical causal
operator is discrete integration (running sum), and its (formal) inverse is the
backward difference.  The main results here are:

* `CausalIntegration.integrate_isCausal` — the running sum is causal;
* `CausalIntegration.integrate_diff` and `CausalIntegration.diff_integrate` — the
  **discrete fundamental theorem of calculus**: difference and integration are
  mutually inverse;
* `CausalIntegration.isCausal_id`, `isCausal_add`, `isCausal_smul` — the causal
  operators form a submodule of all operators.
-/

namespace CausalIntegration

/-- A discrete signal. -/
abbrev Signal : Type := ℕ → ℝ

/-- An operator on signals. -/
abbrev Op : Type := Signal → Signal

/-- `T` is **causal** if `T f n` only depends on the values `f k` for `k ≤ n`. -/
def IsCausal (T : Op) : Prop :=
  ∀ f g : Signal, ∀ n : ℕ, (∀ k, k ≤ n → f k = g k) → T f n = T g n

/-- Discrete integration: the running sum `(∫ f)(n) = ∑_{k ≤ n} f k`. -/
def integrate (f : Signal) : Signal := fun n => ∑ k ∈ Finset.range (n + 1), f k

/-- Backward difference, with the convention `(Δ f)(0) = f 0`. -/
def diff (f : Signal) : Signal := fun n => if n = 0 then f 0 else f n - f (n - 1)

@[simp] lemma integrate_zero (f : Signal) : integrate f 0 = f 0 := by
  simp [integrate]

lemma integrate_succ (f : Signal) (n : ℕ) :
    integrate f (n + 1) = integrate f n + f (n + 1) := by
  simp [integrate, Finset.sum_range_succ]

@[simp] lemma diff_zero (f : Signal) : diff f 0 = f 0 := by simp [diff]

lemma diff_succ (f : Signal) (n : ℕ) : diff f (n + 1) = f (n + 1) - f n := by
  simp [diff]

/-- **Causality of integration.** -/
theorem integrate_isCausal : IsCausal integrate := by
  intro f g n h
  refine Finset.sum_congr rfl fun k hk => ?_
  exact h k (Nat.lt_succ_iff.mp (Finset.mem_range.mp hk))

/-- **Causality of the backward difference.** -/
theorem diff_isCausal : IsCausal diff := by
  intro f g n h
  rcases n with _ | m
  · simp [h 0 le_rfl]
  · rw [diff_succ, diff_succ, h (m + 1) le_rfl, h m (Nat.le_succ m)]

/-- **Discrete fundamental theorem of calculus, first form.**  Integrating the
backward difference recovers the signal. -/
theorem integrate_diff (f : Signal) (n : ℕ) : integrate (diff f) n = f n := by
  induction n with
  | zero => simp
  | succ m ih => rw [integrate_succ, ih, diff_succ]; ring

/-- **Discrete fundamental theorem of calculus, second form.**  Differencing the
running sum recovers the signal. -/
theorem diff_integrate (f : Signal) (n : ℕ) : diff (integrate f) n = f n := by
  rcases n with _ | m
  · simp
  · rw [diff_succ, integrate_succ]; ring

/-! ## The linear structure of causal operators -/

theorem isCausal_id : IsCausal id := fun _ _ n h => h n le_rfl

theorem isCausal_const (c : ℝ) : IsCausal (fun _ _ => c) := fun _ _ _ _ => rfl

theorem isCausal_add {S T : Op} (hS : IsCausal S) (hT : IsCausal T) :
    IsCausal (fun f n => S f n + T f n) := by
  intro f g n h
  simp only
  rw [hS f g n h, hT f g n h]

theorem isCausal_smul (c : ℝ) {T : Op} (hT : IsCausal T) :
    IsCausal (fun f n => c * T f n) := by
  intro f g n h
  simp only
  rw [hT f g n h]

end CausalIntegration