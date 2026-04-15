/-! # CatalogBuild.Speculative.Forbidden.SelfDefeatingOracle

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 5
-/

import Mathlib

/-- [Section: ### Theorem 1: The Oracle Killer
No catalog of strategies `oracle : ℕ → (ℕ → Bool)` can list ALL strategies.
The diagonal adversary — who does the OPPOSITE of what the oracle predicts
at each index — always escapes the catalog. This is Cantor's theorem in
algorithmic disguise.] -/
theorem no_complete_oracle_catalog (oracle : ℕ → (ℕ → Bool)) :
    ∃ adversary : ℕ → Bool, adversary ∉ Set.range oracle := by
  exact not_forall.mp fun h => by have := h; exact absurd ( this ( fun n => if oracle n n = Bool.true then Bool.false else Bool.true ) ) ( by rintro ⟨ k, hk ⟩ ; replace hk := congr_fun hk k; aesop ) ;


theorem diagonal_adversary_defeats_all (oracle : ℕ → (ℕ → Bool)) :
    ∀ n : ℕ, (fun k => !oracle k k) ≠ oracle n := by
  intro n hn; have := congr_fun hn n; aesop


theorem no_surjection_to_arrow_prop (α : Type*) :
    ¬ ∃ e : α → α → Prop, Surjective e := by
  intro ⟨ e, he ⟩;
  have := lawvere_fixed_point e he
  simp at this;
  exact absurd ( this fun x => ¬x ) ( by tauto )


/-- [Section: ### Theorem 3: The Halting Diagonal
No enumeration of all Boolean sequences can be surjective.
This is the algorithmic version: you cannot write a program
that outputs every possible program's behavior.] -/
theorem halting_diagonal_surjection (enum : ℕ → (ℕ → Bool)) :
    ¬ Surjective enum := by
  intro h;
  obtain ⟨ k, hk ⟩ := h ( fun n => if enum n n = Bool.true then Bool.false else Bool.true ) ; specialize hk ; replace hk := congr_fun hk k ; aesop;


/-- [Section: ### Theorem 4: Every Surjection Creates a Fixed Point Trap
The constructive core: given a surjection, we can COMPUTE
the fixed point. Evil is not just possible — it's computable.] -/
theorem constructive_fixed_point {α β : Type*} (e : α → α → β)
    (he : Surjective e) (f : β → β) :
    ∃ b : β, f b = b := by
  exact?

