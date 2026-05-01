import Mathlib

/-! # Well-Founded Induction Bridge

Proves fundamental results about well-founded relations and induction:
1. Well-founded induction: the generalization of strong induction
2. Zorn's Lemma: every chain-bounded partial order has a maximal element
3. ℕ is well-founded: the basis of all number theory
4. Well-founded recursion: defining functions by recursion

Well-founded induction is the MOST GENERAL form of induction.
Zorn's Lemma is equivalent to the Axiom of Choice.
-/

namespace WellFoundedInductionBridge

/-! ## Section 1: Well-Founded Induction -/

/-- **Well-founded induction**: If ∀x, (∀y < x, P y) → P x, then P a for all a.
    THE most general form of induction. -/
theorem wf_induction {α : Sort*} {r : α → α → Prop}
    (hwf : WellFounded r) {P : α → Prop}
    (h : ∀ x, (∀ y, r y x → P y) → P x) (a : α) :
    P a :=
  WellFounded.induction hwf a h

/-! ## Section 2: Zorn's Lemma -/

/-- **Zorn's Lemma**: If every chain in a transitive relation has an upper bound,
    then there exists a maximal element.
    Equivalent to the Axiom of Choice. -/
theorem zorns_lemma {α : Type*} {r : α → α → Prop}
    (h_chain_bounded : ∀ c : Set α, IsChain r c → ∃ ub, ∀ a ∈ c, r a ub)
    (h_trans : ∀ {a b c : α}, r a b → r b c → r a c) :
    ∃ m, ∀ a : α, r m a → r a m :=
  exists_maximal_of_chains_bounded h_chain_bounded h_trans

/-! ## Section 3: ℕ is Well-Founded -/

/-- **ℕ is well-founded under <**: No infinite descending chain.
    Foundation of all number theory and recursive definitions. -/
theorem nat_well_founded : WellFounded (·<· : ℕ → ℕ → Prop) :=
  wellFounded_lt

/-! ## Section 4: Well-Founded Recursion exists -/

/-- Well-founded recursion: we can construct a function by recursion
    on a well-founded relation. The function value at a depends only
    on values at predecessors. -/
noncomputable def wf_recursion {α : Sort*} {r : α → α → Prop}
    {C : α → Sort*} (hwf : WellFounded r)
    (F : (x : α) → ((y : α) → r y x → C y) → C x) (a : α) : C a :=
  WellFounded.fix hwf F a

end WellFoundedInductionBridge
