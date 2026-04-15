/-! # CatalogBuild.Logic.HaltingProblem

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 7
-/

import Mathlib

theorem no_universal_decision :
    ¬ ∃ (f : ℕ → (ℕ → Prop)), Surjective f := by
  simp +zetaDelta at *;
  intro P hP;
  contrapose! hP with hP;
  norm_num [ Function.Surjective ];
  exact ⟨ fun n => ¬P n n, fun n hn => by simpa using congr_fun hn n ⟩

/-
PROBLEM
**The Anti-Diagonal Program**: Given any enumeration of predicates,
the anti-diagonal predicate differs from every enumerated one.

PROVIDED SOLUTION
If fun n => ¬ f n n = f m for some m, then evaluating at m: ¬ f m m = f m m, which is a contradiction by iff.
-/

theorem anti_diagonal_escapes (f : ℕ → (ℕ → Prop)) :
    (fun n => ¬ f n n) ∉ Set.range f := by
  exact fun ⟨ n, hn ⟩ => by have := congr_fun hn n; tauto;

/-! ## II. The Halting Problem via Self-Application

The essence of the halting problem: no predicate on programs can
correctly predict its own behavior under self-application. -/

/-
PROBLEM
**Turing's Diagonal**: For any `decide : ℕ → ℕ → Bool`, there
exists a predicate that `decide` gets wrong. This captures the
halting argument: no decision procedure is correct on all inputs.

PROVIDED SOLUTION
Take P n := ¬(decide n n = true). For any n, if decide n n = true ↔ P n, then decide n n = true ↔ ¬(decide n n = true), which is a contradiction.
-/

theorem turing_diagonal (decide : ℕ → ℕ → Bool) :
    ∃ P : ℕ → Prop, ∀ n : ℕ, (decide n n = true ↔ P n) → False := by
  exact ⟨ fun n => if decide n n = Bool.true then Bool.false else Bool.true, by aesop ⟩

/-! ## III. Rice's Theorem Style Result

No non-trivial property of functions can be decided by examining indices. -/

/-
PROBLEM
**No Computable Enumeration of All Predicates**: The predicates on ℕ
cannot be enumerated — this is Cantor's theorem specialized to ℕ.
Equivalently, there are "more behaviors" than there are "programs."

PROVIDED SOLUTION
Cantor's diagonal: given enum, define d(n) = !(enum n n). Then d ≠ enum n for all n because they differ at position n. So d is not in the range of enum, contradicting surjectivity.
-/

theorem predicates_not_enumerable :
    ¬ ∃ (enum : ℕ → (ℕ → Bool)), Surjective enum := by
  rintro ⟨ enum, henum ⟩;
  cases' henum ( fun x => if enum x x = Bool.true then Bool.false else Bool.true ) with n hn ; replace hn := congr_fun hn n ; aesop

/-! ## IV. Uncomputability of Dominating Functions -/

/-
PROBLEM
**No function dominates all others**: There is no function f : ℕ → ℕ
that eventually exceeds every g : ℕ → ℕ. This captures the spirit of
why the Busy Beaver function is uncomputable — it would need to
dominate all computable functions, but no single function can dominate ALL functions.

PROVIDED SOLUTION
Given f, define g(n) = f(n) + 1. Then for all n, g(n) = f(n) + 1 > f(n), so there's no N with g(n) ≤ f(n) for all n ≥ N.
-/

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

/-! ## V. The Productive Set — Constructive Uncomputability -/

/-- **Productive Diagonalization**: Given any function f : ℕ → (ℕ → Prop),
we can *constructively* produce a predicate not in its range.
This is the computational content of Cantor's theorem. -/

def productive_witness (f : ℕ → (ℕ → Prop)) : ℕ → Prop :=
  fun n => ¬ f n n

/-
PROVIDED SOLUTION
Unfold productive_witness. For any n, productive_witness f ≠ f n because they differ at n: productive_witness f n = ¬ f n n while (f n) n = f n n. Use funext and contradiction.
-/

theorem productive_witness_not_in_range (f : ℕ → (ℕ → Prop)) :
    ∀ n : ℕ, productive_witness f ≠ f n := by
  intro n hn; have := congr_fun hn n; simp_all +decide [ productive_witness ] ;

