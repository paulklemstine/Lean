/-! # CatalogBuild.Bridges.WellFoundedInductionBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 4
-/

import Mathlib

noncomputable section

/-- **Well-founded induction**: If ∀x, (∀y < x, P y) → P x, then P a for all a.
THE most general form of induction. -/
theorem wf_induction {α : Sort*} {r : α → α → Prop}
    (hwf : WellFounded r) {P : α → Prop}
    (h : ∀ x, (∀ y, r y x → P y) → P x) (a : α) :
    P a :=
  WellFounded.induction hwf a h


/-- **Zorn's Lemma**: If every chain in a transitive relation has an upper bound,
then there exists a maximal element.
Equivalent to the Axiom of Choice. -/
theorem zorns_lemma {α : Type*} {r : α → α → Prop}
    (h_chain_bounded : ∀ c : Set α, IsChain r c → ∃ ub, ∀ a ∈ c, r a ub)
    (h_trans : ∀ {a b c : α}, r a b → r b c → r a c) :
    ∃ m, ∀ a : α, r m a → r a m :=
  exists_maximal_of_chains_bounded h_chain_bounded h_trans


/-- **ℕ is well-founded under <**: No infinite descending chain.
Foundation of all number theory and recursive definitions. -/
theorem nat_well_founded : WellFounded (·<· : ℕ → ℕ → Prop) :=
  wellFounded_lt


/-- Well-founded recursion: we can construct a function by recursion
on a well-founded relation. The function value at a depends only
on values at predecessors. -/
noncomputable def wf_recursion {α : Sort*} {r : α → α → Prop}
    {C : α → Sort*} (hwf : WellFounded r)
    (F : (x : α) → ((y : α) → r y x → C y) → C x) (a : α) : C a :=
  WellFounded.fix hwf F a


end
