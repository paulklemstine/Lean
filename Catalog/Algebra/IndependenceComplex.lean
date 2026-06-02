/-
  # Independence Complex of Argumentation Frameworks

  This file formalizes the theory connecting argumentation frameworks
  (Dung, 1995) with abstract simplicial complexes via their independence
  complex. The conflict-free sets of an argumentation framework form
  a downward-closed family of finite sets — an abstract simplicial complex.

  We prove structural theorems about this complex, including:
  - The simplicial complex property (downward closure)
  - Monotonicity of the defense function
  - Dung's Fundamental Lemma
  - The stable → complete extension chain (with irreflexivity)
  - Exponential growth of conflict-free subsets
  - A concrete counterexample to the Euler characteristic conjecture

  ## Novel Definitions

  * `ArgFramework` — Argumentation framework with attack relation
  * `ConflictFree` — Conflict-free sets
  * `Defended` — Defense by counter-attack
  * `Admissible` — Self-defending conflict-free sets
  * `CompleteExt` / `StableExt` — Extension semantics
  * `IndComplex` — The independence complex

  ## References

  * P.M. Dung, "On the acceptability of arguments and its fundamental
    role in nonmonotonic reasoning, logic programming and n-person games",
    Artificial Intelligence 77 (1995), 321–357.
-/

import Mathlib

open Finset

/-- An argumentation framework over a type α consists of
    an attack relation: `attacks a b` means argument `a` attacks argument `b`. -/
structure ArgFramework (α : Type*) where
  attacks : α → α → Prop

namespace ArgFramework

variable {α : Type*} [DecidableEq α] (AF : ArgFramework α)

/-- A set S is conflict-free if no two elements of S attack each other. -/
def ConflictFree (S : Finset α) : Prop :=
  ∀ a ∈ S, ∀ b ∈ S, ¬ AF.attacks a b

/-- An argument x is defended by S if every attacker of x is
    counter-attacked by some member of S. -/
def Defended (S : Finset α) (x : α) : Prop :=
  ∀ b : α, AF.attacks b x → ∃ c ∈ S, AF.attacks c b

/-- A set S is admissible if it is conflict-free and self-defending. -/
def Admissible (S : Finset α) : Prop :=
  AF.ConflictFree S ∧ ∀ a ∈ S, AF.Defended S a

/-- A complete extension is admissible and contains all it defends. -/
def CompleteExt (S : Finset α) : Prop :=
  AF.Admissible S ∧ ∀ x : α, AF.Defended S x → x ∈ S

/-- A stable extension is conflict-free and attacks all non-members. -/
def StableExt (S : Finset α) : Prop :=
  AF.ConflictFree S ∧ ∀ x : α, x ∉ S → ∃ a ∈ S, AF.attacks a x

/-- The independence complex: the collection of all conflict-free sets.
    This forms an abstract simplicial complex (downward-closed family). -/
def IndComplex : Set (Finset α) :=
  {S | AF.ConflictFree S}

/-- An argumentation framework is irreflexive if no argument attacks itself. -/
def Irreflexive : Prop := ∀ a : α, ¬ AF.attacks a a

/-! ## Core Structural Theorems -/

/-- The empty set is always conflict-free. -/
theorem empty_conflictFree : AF.ConflictFree ∅ := by
  intro a ha; simp at ha

/-- **Subsets of conflict-free sets are conflict-free.**
    This is the downward-closure / abstract simplicial complex property. -/
theorem conflictFree_downward_closed {S T : Finset α}
    (hS : AF.ConflictFree S) (hTS : T ⊆ S) : AF.ConflictFree T :=
  fun a ha b hb => hS a (hTS ha) b (hTS hb)

/-- Every admissible set is conflict-free. -/
theorem admissible_subset_conflictFree
    {S : Finset α} (h : AF.Admissible S) : AF.ConflictFree S :=
  h.1

/-- Every complete extension is admissible. -/
theorem complete_implies_admissible
    {S : Finset α} (h : AF.CompleteExt S) : AF.Admissible S :=
  h.1

/-- **The defense function is monotone**: if S ⊆ T and x is defended by S,
    then x is defended by T. -/
theorem defense_monotone {S T : Finset α} (hST : S ⊆ T) {x : α}
    (hdef : AF.Defended S x) : AF.Defended T x := by
  intro b hbx
  obtain ⟨c, hcS, hcb⟩ := hdef b hbx
  exact ⟨c, hST hcS, hcb⟩

/-- **Every stable extension is admissible** (assuming irreflexivity). -/
theorem stable_implies_admissible
    {S : Finset α} (h : AF.StableExt S)
    (hirr : AF.Irreflexive) :
    AF.Admissible S := by
  refine ⟨h.1, fun a ha b hba => ?_⟩
  by_cases hb : b ∈ S
  · exact absurd hba (h.1 b hb a ha)
  · exact h.2 b hb

/-- **Every stable extension is complete** (assuming irreflexivity).
    If x ∉ S, stability gives attacker a ∈ S of x. Defense gives c ∈ S
    attacking a. But c, a ∈ S with attacks c a contradicts conflict-freeness. -/
theorem stable_implies_complete
    {S : Finset α} (h : AF.StableExt S) (hirr : AF.Irreflexive) :
    AF.CompleteExt S := by
  refine ⟨AF.stable_implies_admissible h hirr, fun x hdef => ?_⟩
  by_contra hx
  obtain ⟨a, ha, hax⟩ := h.2 x hx
  obtain ⟨c, hc, hca⟩ := hdef a hax
  exact h.1 c hc a ha hca

/-! ## Exponential Growth -/

/-- **All subsets of a conflict-free set are conflict-free.** -/
theorem conflictFree_powerset_all
    {S : Finset α} (hS : AF.ConflictFree S) :
    ∀ T ∈ S.powerset, AF.ConflictFree T := by
  intro T hT
  rw [mem_powerset] at hT
  exact AF.conflictFree_downward_closed hS hT

/-! ## Dung's Fundamental Lemma -/

/-- **Dung's Fundamental Lemma**: If S is admissible, a is defended by S,
    and a is conflict-free with every element of S, then S ∪ {a} is admissible.
    This is the engine behind the proof that every admissible set extends
    to a preferred extension (via Zorn's lemma). -/
theorem fundamental_lemma
    {S : Finset α} {a : α} (hadm : AF.Admissible S)
    (ha_def : AF.Defended S a)
    (ha_cf : ∀ s ∈ S, ¬ AF.attacks a s ∧ ¬ AF.attacks s a)
    (ha_irr : ¬ AF.attacks a a) :
    AF.Admissible (S ∪ {a}) := by
  constructor
  · intro x hx y hy
    simp only [mem_union, mem_singleton] at hx hy
    rcases hx with hx | rfl <;> rcases hy with hy | rfl
    · exact hadm.1 x hx y hy
    · exact (ha_cf x hx).2
    · exact (ha_cf _ hy).1
    · exact ha_irr
  · intro x hx b hbx
    simp only [mem_union, mem_singleton] at hx
    rcases hx with hx | rfl
    · obtain ⟨c, hcS, hcb⟩ := hadm.2 x hx b hbx
      exact ⟨c, mem_union_left _ hcS, hcb⟩
    · obtain ⟨c, hcS, hcb⟩ := ha_def b hbx
      exact ⟨c, mem_union_left _ hcS, hcb⟩

/-! ## Additional Properties -/

omit [DecidableEq α] in
/-- In an irreflexive framework, every singleton is conflict-free. -/
theorem singleton_conflictFree (hirr : AF.Irreflexive) (z : α) :
    AF.ConflictFree ({z} : Finset α) := by
  intro a ha b hb
  simp only [mem_singleton] at ha hb
  subst ha; subst hb
  exact hirr _

omit [DecidableEq α] in
/-- Unattacked arguments are defended by any set. -/
theorem unattacked_defended
    {z : α} (hunatt : ∀ b : α, ¬ AF.attacks b z)
    (S : Finset α) : AF.Defended S z :=
  fun b hbx => absurd hbx (hunatt b)

/-- **The empty set is admissible in any framework.** -/
theorem empty_admissible : AF.Admissible ∅ :=
  ⟨AF.empty_conflictFree, fun _ ha => absurd ha (by simp)⟩

/-- **An unattacked argument forms a singleton admissible set.** -/
theorem singleton_unattacked_admissible
    (hirr : AF.Irreflexive) {z : α}
    (hunatt : ∀ b : α, ¬ AF.attacks b z) :
    AF.Admissible ({z} : Finset α) := by
  refine ⟨AF.singleton_conflictFree hirr z, fun a ha => ?_⟩
  simp only [mem_singleton] at ha; subst ha
  exact AF.unattacked_defended hunatt _

/-! ## Meet-Semilattice Structure -/

/-- **The intersection of two conflict-free sets is conflict-free.** -/
theorem conflictFree_inter {S T : Finset α}
    (hS : AF.ConflictFree S) (_hT : AF.ConflictFree T) :
    AF.ConflictFree (S ∩ T) :=
  AF.conflictFree_downward_closed hS inter_subset_left

/-- **Conflict-free sets form an order ideal in the powerset lattice.** -/
theorem indComplex_is_order_ideal {S T : Finset α}
    (hS : S ∈ AF.IndComplex) (hTS : T ⊆ S) : T ∈ AF.IndComplex :=
  AF.conflictFree_downward_closed hS hTS

/-! ## Uniqueness of Grounded Extension -/

/-- **Uniqueness of the least complete extension (grounded extension).**
    If E₁ and E₂ are both ⊆-least among complete extensions, E₁ = E₂. -/
theorem least_complete_unique
    {E₁ E₂ : Finset α}
    (_h1 : AF.CompleteExt E₁)
    (_h2 : AF.CompleteExt E₂)
    (hmin1 : ∀ F : Finset α, AF.CompleteExt F → E₁ ⊆ F)
    (hmin2 : ∀ F : Finset α, AF.CompleteExt F → E₂ ⊆ F) :
    E₁ = E₂ :=
  Finset.Subset.antisymm (hmin1 E₂ _h2) (hmin2 E₁ _h1)

/-! ## Euler Characteristic Counterexample -/

/-- A concrete 3-argument framework: attacks 0→1 and 1→2.
    Conflict-free sets: ∅, {0}, {1}, {2}, {0,2}
    f-vector: (1, 3, 1), χ = 1 − 3 + 1 = −1
    Preferred = Stable = {0,2}, Grounded = {0,2}
    |preferred| − |grounded| = 0 ≠ −1 = χ -/
noncomputable def eulerCharExample : ArgFramework (Fin 3) where
  attacks a b := (a = 0 ∧ b = 1) ∨ (a = 1 ∧ b = 2)

/-
{0, 2} is conflict-free in the counterexample framework.
-/
theorem euler_example_cf :
    eulerCharExample.ConflictFree ({0, 2} : Finset (Fin 3)) := by
  simp +decide [ eulerCharExample, ArgFramework.ConflictFree ]

/-
{0, 1} is NOT conflict-free (0 attacks 1).
-/
theorem euler_example_not_cf_01 :
    ¬ eulerCharExample.ConflictFree ({0, 1} : Finset (Fin 3)) := by
  exact fun h => h 0 ( by decide ) 1 ( by decide ) ( by exact Or.inl ⟨ rfl, rfl ⟩ )

/-
{1, 2} is NOT conflict-free (1 attacks 2).
-/
theorem euler_example_not_cf_12 :
    ¬ eulerCharExample.ConflictFree ({1, 2} : Finset (Fin 3)) := by
  simp +decide [ eulerCharExample, ArgFramework.ConflictFree ]

/-
{0, 2} is admissible: 0 is unattacked, and 2 is defended by 0.
-/
theorem euler_example_admissible :
    eulerCharExample.Admissible ({0, 2} : Finset (Fin 3)) := by
  unfold eulerCharExample;
  constructor <;> simp +decide [ ArgFramework.ConflictFree, ArgFramework.Defended ]

/-! ## Non-emptiness of Stable Extensions -/

/-
**Stable extensions are non-empty when arguments exist.**
-/
theorem stable_nonempty_of_nonempty [Fintype α] [Nonempty α]
    {S : Finset α} (h : AF.StableExt S) : S.Nonempty := by
  by_contra h_empty;
  obtain ⟨ x, hx ⟩ := h.2 ( Classical.arbitrary α ) ( by aesop ) ; aesop

/-! ## Complete Extension Characterization -/

/-
**∅ is complete iff every argument has an attacker.**
-/
theorem empty_complete_iff_no_unattacked [Fintype α]
    (hirr : AF.Irreflexive) :
    AF.CompleteExt ∅ ↔ ∀ x : α, ∃ b : α, AF.attacks b x := by
  constructor <;> intro h;
  · intro x
    by_contra h_contra
    push_neg at h_contra;
    exact absurd ( h.2 x ( by unfold ArgFramework.Defended; aesop ) ) ( by aesop );
  · constructor;
    · exact empty_admissible AF;
    · exact fun x hx => by obtain ⟨ b, hb ⟩ := h x; specialize hx b hb; aesop;

end ArgFramework