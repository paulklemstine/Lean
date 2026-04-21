/-! # CatalogBuild.Speculative.Forbidden.SelfDefeatingOracle

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 5
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.Forbidden.SelfDefeatingOracle
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 5] -/
theorem no_complete_oracle_catalog (oracle : ℕ → (ℕ → Bool)) :
    ∃ adversary : ℕ → Bool, adversary ∉ Set.range oracle := by
  exact not_forall.mp fun h => by have := h; exact absurd ( this ( fun n => if oracle n n = Bool.true then Bool.false else Bool.true ) ) ( by rintro ⟨ k, hk ⟩ ; replace hk := congr_fun hk k; aesop ) ;




/-- [Section: # CatalogBuild.Speculative.Forbidden.SelfDefeatingOracle
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 5] -/
theorem diagonal_adversary_defeats_all (oracle : ℕ → (ℕ → Bool)) :
    ∀ n : ℕ, (fun k => !oracle k k) ≠ oracle n := by
  intro n hn; have := congr_fun hn n; aesop




theorem no_surjection_to_arrow_prop (α : Type*) :
    ¬ ∃ e : α → α → Prop, Surjective e := by
  intro ⟨ e, he ⟩;
  have := lawvere_fixed_point e he
  simp at this;
  exact absurd ( this fun x => ¬x ) ( by tauto )




theorem halting_diagonal_surjection (enum : ℕ → (ℕ → Bool)) :
    ¬ Surjective enum := by
  intro h;
  obtain ⟨ k, hk ⟩ := h ( fun n => if enum n n = Bool.true then Bool.false else Bool.true ) ; specialize hk ; replace hk := congr_fun hk k ; aesop;




theorem constructive_fixed_point {α β : Type*} (e : α → α → β)
    (he : Surjective e) (f : β → β) :
    ∃ b : β, f b = b := by
  exact?



