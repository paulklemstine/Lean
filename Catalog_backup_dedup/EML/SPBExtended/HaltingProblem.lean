import Mathlib

/-! # CatalogBuild.Logic.HaltingProblem

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 7
-/

/-- [Section: # CatalogBuild.Logic.HaltingProblem
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 7] -/
theorem no_universal_decision :
    ¬ ∃ (f : ℕ → (ℕ → Prop)), Surjective f := by
  simp +zetaDelta at *;
  intro P hP;
  contrapose! hP with hP;
  norm_num [ Function.Surjective ];
  exact ⟨ fun n => ¬P n n, fun n hn => by simpa using congr_fun hn n ⟩

/-- [Section: # CatalogBuild.Logic.HaltingProblem
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 7] -/
theorem anti_diagonal_escapes (f : ℕ → (ℕ → Prop)) :
    (fun n => ¬ f n n) ∉ Set.range f := by
  exact fun ⟨ n, hn ⟩ => by have := congr_fun hn n; tauto;

theorem turing_diagonal (decide : ℕ → ℕ → Bool) :
    ∃ P : ℕ → Prop, ∀ n : ℕ, (decide n n = true ↔ P n) → False := by
  exact ⟨ fun n => if decide n n = Bool.true then Bool.false else Bool.true, by aesop ⟩

theorem predicates_not_enumerable :
    ¬ ∃ (enum : ℕ → (ℕ → Bool)), Surjective enum := by
  rintro ⟨ enum, henum ⟩;
  cases' henum ( fun x => if enum x x = Bool.true then Bool.false else Bool.true ) with n hn ; replace hn := congr_fun hn n ; aesop

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

theorem productive_witness_not_in_range (f : ℕ → (ℕ → Prop)) :
    ∀ n : ℕ, productive_witness f ≠ f n := by
  intro n hn; have := congr_fun hn n; simp_all +decide [ productive_witness ] ;

