/-! # CatalogBuild.Logic.HaltingProblem

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 7
-/

import Mathlib

/-- [Section: ## I. The Computational Diagonal
The halting problem is Cantor's diagonal argument in computational form.
The key insight: if we could decide all properties of programs, we could
construct a program that contradicts any decision procedure.] -/
theorem no_universal_decision :
    ¬ ∃ (f : ℕ → (ℕ → Prop)), Surjective f := by
  simp +zetaDelta at *;
  intro P hP;
  contrapose! hP with hP;
  norm_num [ Function.Surjective ];
  exact ⟨ fun n => ¬P n n, fun n hn => by simpa using congr_fun hn n ⟩


theorem anti_diagonal_escapes (f : ℕ → (ℕ → Prop)) :
    (fun n => ¬ f n n) ∉ Set.range f := by
  exact fun ⟨ n, hn ⟩ => by have := congr_fun hn n; tauto;


/-- [Section: ## II. The Halting Problem via Self-Application
The essence of the halting problem: no predicate on programs can
correctly predict its own behavior under self-application.] -/
theorem turing_diagonal (decide : ℕ → ℕ → Bool) :
    ∃ P : ℕ → Prop, ∀ n : ℕ, (decide n n = true ↔ P n) → False := by
  exact ⟨ fun n => if decide n n = Bool.true then Bool.false else Bool.true, by aesop ⟩


/-- [Section: ## III. Rice's Theorem Style Result
No non-trivial property of functions can be decided by examining indices.] -/
theorem predicates_not_enumerable :
    ¬ ∃ (enum : ℕ → (ℕ → Bool)), Surjective enum := by
  rintro ⟨ enum, henum ⟩;
  cases' henum ( fun x => if enum x x = Bool.true then Bool.false else Bool.true ) with n hn ; replace hn := congr_fun hn n ; aesop


/-- [Section: ## IV. Uncomputability of Dominating Functions] -/
theorem no_universal_dominator :
    ¬ ∃ (f : ℕ → ℕ), ∀ (g : ℕ → ℕ), ∃ N, ∀ n, N ≤ n → g n ≤ f n := by
  by_contra h_contra
  obtain ⟨f, hf⟩ := h_contra
  have h_diag : ∀ n, f n < f n + 1 := by
    exact fun n => Nat.lt_succ_self _
  have h_exists_N : ∃ N, ∀ n, N ≤ n → f n + 1 ≤ f n := by
    exact hf _
  obtain ⟨N, hN⟩ := h_exists_N
  exact lt_irrefl (f N + 1) (by linarith [hN N le_rfl])


/-- **Productive Diagonalization**: Given any function f : ℕ → (ℕ → Prop),
we can *constructively* produce a predicate not in its range.
This is the computational content of Cantor's theorem. -/
def productive_witness (f : ℕ → (ℕ → Prop)) : ℕ → Prop :=
  fun n => ¬ f n n


/-- [Section: ## V. The Productive Set — Constructive Uncomputability] -/
theorem productive_witness_not_in_range (f : ℕ → (ℕ → Prop)) :
    ∀ n : ℕ, productive_witness f ≠ f n := by
  intro n hn; have := congr_fun hn n; simp_all +decide [ productive_witness ] ;

