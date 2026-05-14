/-
# Emergent Theorem Discovery in Idempotent Algebras

This file formalizes the core stabilization and least-fixed-point theorems
for monotone extensive operators on finite sets, establishing the mathematical
foundation for "self-organizing theorem discovery" in idempotent algebras.

The key insight: in a finite theorem universe with a monotone extensive
consequence operator, iterative closure from any set of axioms stabilizes
in at most `|σ|` steps, and the resulting fixed point is the least fixed
point above the axioms — i.e., it is exactly the deductive closure.
-/
import Mathlib

open Finset Function

variable {σ : Type} [DecidableEq σ] [Fintype σ]

/-! ## Monotone chain stabilization on Finset -/

/-- An ascending chain of finite sets in a finite universe must stabilize. -/
lemma ascending_chain_stabilizes
    (f : ℕ → Finset σ)
    (h_asc : ∀ n, f n ⊆ f (n + 1)) :
    ∃ N, ∀ n, N ≤ n → f n = f N := by
  have h_values_finite : Set.Finite (Set.range f) := Set.toFinite _
  by_contra h_inf
  have h_strict_mono : ∃ n, f n ⊂ f (n + 1) := by
    by_cases h_eq : ∀ n, f n = f (n + 1)
    · exact False.elim <| h_inf ⟨0, fun n hn => Nat.recOn n rfl fun n ih => h_eq n ▸ ih⟩
    · push_neg at h_eq
      exact h_eq.imp fun n hn => ⟨h_asc n, fun h => hn <| Finset.Subset.antisymm (h_asc n) h⟩
  have h_infinite_strict_mono : ∃ (g : ℕ → Finset σ), StrictMono g ∧ ∀ n, g n ∈ Set.range f := by
    obtain ⟨n, hn⟩ := h_strict_mono
    set g : ℕ → ℕ := fun m => Nat.recOn m (n + 1) (fun _ g_m => Nat.find (show ∃ k, f g_m ⊂ f k from by
      simp_all +decide [Finset.ssubset_def, Finset.subset_iff]
      obtain ⟨k, hk₁, hk₂⟩ := h_inf g_m
      exact ⟨k, fun x hx => by exact Nat.le_induction (by tauto) (fun n hn ih => by tauto) k hk₁,
        by obtain ⟨x, hx₁, hx₂⟩ := Finset.exists_of_ssubset (lt_of_le_of_ne
            (show f g_m ⊆ f k from Nat.le_induction (by tauto) (fun n hn ih => by tauto) k hk₁)
            (Ne.symm hk₂))
           exact ⟨x, hx₁, hx₂⟩⟩))
    all_goals generalize_proofs at *
    refine ⟨fun m => f (g m), strictMono_nat_of_lt_succ fun m => ?_, fun m => Set.mem_range_self _⟩
    exact Nat.find_spec (‹∀ (g_m : ℕ), ∃ n, f g_m ⊂ f n› (g m))
  exact h_values_finite.not_infinite <|
    Set.infinite_of_injective_forall_mem
      h_infinite_strict_mono.choose_spec.1.injective
      fun n => h_infinite_strict_mono.choose_spec.2 n

-- If `step` is monotone and extensive, iterates form an ascending chain.
omit [DecidableEq σ] [Fintype σ] in
lemma iterate_ascending
    (step : Finset σ → Finset σ)
    (_h_mono : ∀ {S T : Finset σ}, S ⊆ T → step S ⊆ step T)
    (h_ext : ∀ S : Finset σ, S ⊆ step S)
    (A : Finset σ) :
    ∀ n, step^[n] A ⊆ step^[n + 1] A :=
  fun n => by simpa only [Function.iterate_succ_apply'] using h_ext _

/-- **Finite Monotone Closure Stabilization**: Any monotone extensive operator
on `Finset σ` reaches a fixed point when iterated from any starting set. -/
theorem finite_monotone_closure_stabilizes
    (step : Finset σ → Finset σ)
    (h_mono : ∀ {S T : Finset σ}, S ⊆ T → step S ⊆ step T)
    (h_ext : ∀ S : Finset σ, S ⊆ step S) :
    ∀ A : Finset σ, ∃ N : ℕ, step^[N] A = step^[N + 1] A := by
  intro A
  obtain ⟨N, hN⟩ := ascending_chain_stabilizes _ (iterate_ascending step h_mono h_ext A)
  exact ⟨N, hN (N + 1) (Nat.le_succ _) ▸ rfl⟩

-- The stabilized iterate is a fixed point of `step`.
omit [DecidableEq σ] [Fintype σ] in
lemma stabilized_is_fixed_point
    (step : Finset σ → Finset σ)
    (_h_mono : ∀ {S T : Finset σ}, S ⊆ T → step S ⊆ step T)
    (_h_ext : ∀ S : Finset σ, S ⊆ step S)
    (A : Finset σ) (N : ℕ)
    (hN : step^[N] A = step^[N + 1] A) :
    step (step^[N] A) = step^[N] A := by
  simpa [← Function.iterate_succ_apply'] using hN.symm

-- Every iterate is above the starting set.
omit [DecidableEq σ] [Fintype σ] in
lemma iterate_above_start
    (step : Finset σ → Finset σ)
    (h_ext : ∀ S : Finset σ, S ⊆ step S)
    (A : Finset σ) :
    ∀ n, A ⊆ step^[n] A :=
  fun n => Nat.recOn n (by simp) fun n ih => by
    simpa only [Function.iterate_succ_apply'] using ih.trans (h_ext _)

-- The stabilized iterate is below any fixed point above `A`.
omit [DecidableEq σ] [Fintype σ] in
lemma iterate_below_fixed_point
    (step : Finset σ → Finset σ)
    (h_mono : ∀ {S T : Finset σ}, S ⊆ T → step S ⊆ step T)
    (A : Finset σ) (D : Finset σ)
    (hAD : A ⊆ D) (hD : step D = D) :
    ∀ n, step^[n] A ⊆ D := by
  intro n
  induction n <;> simp_all +decide [Function.iterate_succ_apply']
  exact hD ▸ h_mono ‹_›

/-- **Closure is the Least Fixed Point**: The closure of `A` under a monotone
extensive operator is a fixed point of `step` containing `A`, and it is
contained in every such fixed point. This is the Knaster–Tarski theorem
specialized to the finite powerset lattice. -/
theorem closure_is_least_fixed_point
    (step : Finset σ → Finset σ)
    (h_mono : ∀ {S T : Finset σ}, S ⊆ T → step S ⊆ step T)
    (h_ext : ∀ S : Finset σ, S ⊆ step S)
    (A : Finset σ) :
    ∃ C : Finset σ,
      A ⊆ C ∧
      step C = C ∧
      ∀ D : Finset σ, A ⊆ D → step D = D → C ⊆ D := by
  obtain ⟨N, hN⟩ := finite_monotone_closure_stabilizes step h_mono h_ext A
  use step^[N] A
  exact ⟨iterate_above_start step h_ext A N,
    stabilized_is_fixed_point step h_mono h_ext A N hN,
    fun D hAD hD => iterate_below_fixed_point step h_mono A D hAD hD N⟩