/-! # CatalogBuild.Speculative.Forbidden.SelfDefeatingOracle

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 5
-/

import Mathlib

theorem no_complete_oracle_catalog (oracle : ℕ → (ℕ → Bool)) :
    ∃ adversary : ℕ → Bool, adversary ∉ Set.range oracle := by
  exact not_forall.mp fun h => by have := h; exact absurd ( this ( fun n => if oracle n n = Bool.true then Bool.false else Bool.true ) ) ( by rintro ⟨ k, hk ⟩ ; replace hk := congr_fun hk k; aesop ) ;

/-
PROBLEM
**The Diagonal Adversary:** Explicitly constructs the strategy that
    defeats every cataloged oracle. For each n, it does the opposite of
    what oracle n does at position n.

PROVIDED SOLUTION
For any n, fun k => !oracle k k differs from oracle n at index n, because !oracle n n ≠ oracle n n.
-/

theorem diagonal_adversary_defeats_all (oracle : ℕ → (ℕ → Bool)) :
    ∀ n : ℕ, (fun k => !oracle k k) ≠ oracle n := by
  intro n hn; have := congr_fun hn n; aesop

/-! ### Theorem 2: The Liar's Fixed Point — Lawvere's Engine of Paradox

If `e : α → (α → β)` is surjective, then every `f : β → β` has a fixed point.
Negation has no fixed point. Therefore: no surjection to function space.
This single theorem generates Russell, Cantor, Gödel, Tarski, AND Turing. -/

/-
PROBLEM
**Lawvere's Fixed Point Theorem:**
    If `e : α → α → β` is surjective, then every `f : β → β` has a fixed point.
    The proof: define g(a) = f(e(a)(a)). Get a₀ with e(a₀) = g.
    Then e(a₀)(a₀) = g(a₀) = f(e(a₀)(a₀)). QED.

PROVIDED SOLUTION
Intro f. Define g : α → β by g a = f (e a a). Since e is surjective, get a₀ with e a₀ = g. Then e a₀ a₀ = g a₀ = f (e a₀ a₀). So x := e a₀ a₀ is a fixed point.
-/

theorem no_surjection_to_arrow_prop (α : Type*) :
    ¬ ∃ e : α → α → Prop, Surjective e := by
  intro ⟨ e, he ⟩;
  have := lawvere_fixed_point e he
  simp at this;
  exact absurd ( this fun x => ¬x ) ( by tauto )

/-! ### Theorem 3: The Halting Diagonal

No enumeration of all Boolean sequences can be surjective.
This is the algorithmic version: you cannot write a program
that outputs every possible program's behavior. -/

/-
PROBLEM
**The Halting Diagonal:** No enumeration of ℕ → Bool is surjective.
    This is Cantor's theorem specialized to the space of computations.

PROVIDED SOLUTION
Use cantor_surjective or the diagonal: if surjective, then fun n => !enum n n is in range, giving contradiction.
-/

theorem halting_diagonal_surjection (enum : ℕ → (ℕ → Bool)) :
    ¬ Surjective enum := by
  intro h;
  obtain ⟨ k, hk ⟩ := h ( fun n => if enum n n = Bool.true then Bool.false else Bool.true ) ; specialize hk ; replace hk := congr_fun hk k ; aesop;

/-! ### Theorem 4: Every Surjection Creates a Fixed Point Trap

The constructive core: given a surjection, we can COMPUTE
the fixed point. Evil is not just possible — it's computable. -/

/-
PROBLEM
Given a surjection `e`, the diagonal trick explicitly constructs
    the fixed point of any endofunction. Evil has a recipe.

PROVIDED SOLUTION
Same as lawvere_fixed_point. Use lawvere_fixed_point e he f.
-/

theorem constructive_fixed_point {α β : Type*} (e : α → α → β)
    (he : Surjective e) (f : β → β) :
    ∃ b : β, f b = b := by
  exact?

