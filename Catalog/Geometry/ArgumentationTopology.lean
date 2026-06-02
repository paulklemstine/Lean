/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# The Topology of Argumentation: Why Debates Have Holes

This module formalizes argumentation frameworks (Dung, 1995) and constructs the
**independence complex** (conflict-free complex) of an argumentation framework.
We prove that conflict-free sets form an abstract simplicial complex,
establish structural relationships between admissible sets and preferred extensions,
and disprove the naive Euler characteristic conjecture via explicit counterexample.

## Main Definitions

* `ArgFramework` — An argumentation framework (A, R) with finite argument set
* `ArgFramework.ConflictFree` — Conflict-free sets (no internal attacks)
* `ArgFramework.Defends` — A set S defends argument a against all attackers
* `ArgFramework.Admissible` — Admissible sets (conflict-free + self-defending)
* `ArgFramework.StableExt` — Stable extensions (conflict-free + attacking all outsiders)
* `ArgFramework.CompleteExt` — Complete extensions
* `ArgFramework.GroundedExt` — Grounded extension (least complete extension)
* `ArgFramework.conflictFreeSets` — The independence complex as a Finset of Finsets
* `ArgFramework.characteristicFn` — The characteristic function F

## Main Results

* `conflictFree_down_closed` — Subsets of conflict-free sets are conflict-free
* `empty_admissible` — The empty set is always admissible
* `stable_is_admissible` — Every stable extension is admissible
* `characteristicFn_mono` — The characteristic function is monotone
* `defends_mono` — Defense is monotone in the defending set
* `twoArg_preferred` — The preferred extension of the two-arg framework
* `euler_char_conjecture_false` — The naive Euler characteristic conjecture is false
-/

import Mathlib

open scoped Classical
open Finset BigOperators

noncomputable section

/-! ## Section 1: Argumentation Frameworks -/

/-- An **argumentation framework** (Dung, 1995) consists of a finite set of arguments
    and a binary attack relation. -/
structure ArgFramework (α : Type*) [Fintype α] [DecidableEq α] where
  /-- The attack relation: `attacks a b` means argument `a` attacks argument `b` -/
  attacks : α → α → Prop
  [attacks_dec : DecidableRel attacks]

attribute [instance] ArgFramework.attacks_dec

namespace ArgFramework

variable {α : Type*} [Fintype α] [DecidableEq α] (AF : ArgFramework α)

/-! ### Conflict-Free Sets -/

/-- A set S is **conflict-free** if no argument in S attacks another argument in S. -/
def ConflictFree (S : Finset α) : Prop :=
  ∀ a ∈ S, ∀ b ∈ S, ¬AF.attacks a b

instance conflictFree_decidable (S : Finset α) : Decidable (AF.ConflictFree S) :=
  inferInstanceAs (Decidable (∀ a ∈ S, ∀ b ∈ S, ¬AF.attacks a b))

/-- **Key theorem**: Subsets of conflict-free sets are conflict-free.
    This is the hereditary property making conflict-free sets a simplicial complex. -/
theorem conflictFree_down_closed {S T : Finset α} (hST : T ⊆ S) (hS : AF.ConflictFree S) :
    AF.ConflictFree T :=
  fun a ha b hb => hS a (hST ha) b (hST hb)

/-- The empty set is always conflict-free. -/
theorem empty_conflictFree : AF.ConflictFree ∅ := by
  intro a ha; simp at ha

/-- A singleton {a} is conflict-free iff a does not attack itself. -/
theorem singleton_conflictFree_iff (a : α) :
    AF.ConflictFree {a} ↔ ¬AF.attacks a a := by
  constructor
  · intro h; exact h a (mem_singleton_self a) a (mem_singleton_self a)
  · intro h x hx y hy
    rw [mem_singleton] at hx hy; subst hx; subst hy; exact h

/-! ### Defense and Admissibility -/

/-- A set S **defends** an argument `a` if for every attacker of `a`,
    some member of S counter-attacks that attacker. -/
def Defends (S : Finset α) (a : α) : Prop :=
  ∀ b : α, AF.attacks b a → ∃ c ∈ S, AF.attacks c b

/-- A set S is **admissible** if it is conflict-free and defends all its members. -/
def Admissible (S : Finset α) : Prop :=
  AF.ConflictFree S ∧ ∀ a ∈ S, AF.Defends S a

/-- Every admissible set is conflict-free. -/
theorem admissible_is_conflictFree {S : Finset α} (h : AF.Admissible S) :
    AF.ConflictFree S := h.1

/-- The empty set is always admissible (vacuously self-defending). -/
theorem empty_admissible : AF.Admissible ∅ :=
  ⟨AF.empty_conflictFree, fun a ha => by simp at ha⟩

/-- Subsets of admissible sets are conflict-free. -/
theorem admissible_subset_conflictFree {S T : Finset α}
    (hAdm : AF.Admissible S) (hSub : T ⊆ S) : AF.ConflictFree T :=
  AF.conflictFree_down_closed hSub hAdm.1

/-! ### Preferred Extensions -/

/-- A **preferred extension** is a maximal admissible set. -/
def PreferredExt (S : Finset α) : Prop :=
  AF.Admissible S ∧ ∀ T : Finset α, AF.Admissible T → S ⊆ T → T = S

/-- Every preferred extension is conflict-free. -/
theorem preferred_is_conflictFree {S : Finset α} (h : AF.PreferredExt S) :
    AF.ConflictFree S := h.1.1

/-! ### Stable Extensions -/

/-- A **stable extension** is a conflict-free set that attacks every argument not in it. -/
def StableExt (S : Finset α) : Prop :=
  AF.ConflictFree S ∧ ∀ a : α, a ∉ S → ∃ b ∈ S, AF.attacks b a

/-- Every stable extension defends all its members. -/
theorem stable_defends_members {S : Finset α} (hStab : AF.StableExt S) :
    ∀ a ∈ S, AF.Defends S a := by
  intro a ha b hba
  by_cases hbS : b ∈ S
  · exact absurd hba (hStab.1 b hbS a ha)
  · exact hStab.2 b hbS

/-- **Stable extensions are admissible.** -/
theorem stable_is_admissible {S : Finset α} (hStab : AF.StableExt S) :
    AF.Admissible S :=
  ⟨hStab.1, AF.stable_defends_members hStab⟩

/-! ## Section 2: The Independence Complex -/

/-- The collection of all conflict-free subsets, forming the independence complex. -/
def conflictFreeSets : Finset (Finset α) :=
  Finset.univ.powerset.filter AF.ConflictFree

/-- Membership in conflictFreeSets is equivalent to being conflict-free. -/
theorem mem_conflictFreeSets (S : Finset α) :
    S ∈ AF.conflictFreeSets ↔ AF.ConflictFree S := by
  simp only [conflictFreeSets, mem_filter, mem_powerset]
  exact ⟨fun h => h.2, fun h => ⟨subset_univ S, h⟩⟩

/-- The conflict-free sets are downward closed (hereditary property). -/
theorem conflictFreeSets_down_closed {F G : Finset α}
    (hF : F ∈ AF.conflictFreeSets) (hGF : G ⊆ F) : G ∈ AF.conflictFreeSets := by
  rw [mem_conflictFreeSets] at hF ⊢
  exact AF.conflictFree_down_closed hGF hF

/-- The empty set is in the conflict-free sets. -/
theorem empty_mem_conflictFreeSets : ∅ ∈ AF.conflictFreeSets := by
  rw [mem_conflictFreeSets]
  exact AF.empty_conflictFree

/-- The f-vector: number of faces of dimension k (faces with k+1 elements). -/
def fVector (k : ℕ) : ℕ :=
  (AF.conflictFreeSets.filter (fun F => F.card = k + 1)).card

/-- The **Euler characteristic** of the independence complex. -/
def eulerCharacteristic : ℤ :=
  ∑ k ∈ Finset.range (Fintype.card α),
    (-1 : ℤ) ^ k * (AF.fVector k : ℤ)

/-! ## Section 3: Structural Theorems -/

/-- If a attacks b, then {a, b} is not conflict-free. -/
theorem attack_not_conflictFree {a b : α}
    (h1 : AF.attacks a b) : ¬AF.ConflictFree {a, b} := by
  intro hcf
  exact hcf a (mem_insert_self a {b}) b (mem_insert_of_mem (mem_singleton_self b)) h1

/-! ## Section 4: Complete Extensions and Characteristic Function -/

/-- A **complete extension** is admissible and contains every argument it defends. -/
def CompleteExt (S : Finset α) : Prop :=
  AF.Admissible S ∧ ∀ a : α, AF.Defends S a → a ∈ S

/-- The **grounded extension** is the smallest complete extension. -/
def GroundedExt (S : Finset α) : Prop :=
  AF.CompleteExt S ∧ ∀ T : Finset α, AF.CompleteExt T → S ⊆ T

/-- The **characteristic function** F maps S to arguments defended by S. -/
def characteristicFn (S : Finset α) : Finset α :=
  Finset.univ.filter (fun a => ∀ b : α, AF.attacks b a → ∃ c ∈ S, AF.attacks c b)

/-- The characteristic function is **monotone**. -/
theorem characteristicFn_mono {S T : Finset α} (h : S ⊆ T) :
    AF.characteristicFn S ⊆ AF.characteristicFn T := by
  intro a ha
  simp only [characteristicFn, mem_filter, mem_univ, true_and] at ha ⊢
  intro b hba
  obtain ⟨c, hcS, hcb⟩ := ha b hba
  exact ⟨c, h hcS, hcb⟩

/-- Defense is monotone in the defending set. -/
theorem defends_mono {S T : Finset α} (h : S ⊆ T) {a : α} (hDef : AF.Defends S a) :
    AF.Defends T a := by
  intro b hba
  obtain ⟨c, hcS, hcb⟩ := hDef b hba
  exact ⟨c, h hcS, hcb⟩

/-- The intersection of two conflict-free sets is conflict-free. -/
theorem conflictFree_inter {S T : Finset α}
    (hS : AF.ConflictFree S) : AF.ConflictFree (S ∩ T) :=
  AF.conflictFree_down_closed inter_subset_left hS

/-- An unattacked argument is in F(∅). -/
theorem unattacked_in_charFn_empty (a : α) (h : ∀ b : α, ¬AF.attacks b a) :
    a ∈ AF.characteristicFn ∅ := by
  simp only [characteristicFn, mem_filter, mem_univ, true_and]
  intro b hba; exact absurd hba (h b)

/-! ## Section 5: The Two-Argument Framework (Counterexample) -/

/-- A two-argument framework: 0 attacks 1, no other attacks. -/
def twoArgFramework : ArgFramework (Fin 2) where
  attacks a b := a = 0 ∧ b = 1

/-
{0} is the preferred extension of the two-argument framework.
-/
theorem twoArg_preferred :
    twoArgFramework.PreferredExt ({0} : Finset (Fin 2)) := by
  constructor;
  · constructor <;> simp +decide [ twoArgFramework ];
    exact fun b hb => by fin_cases b <;> simp_all +decide ;
  · rintro T h₁ h₂; fin_cases T <;> simp_all +decide ;
    cases h₁ ; simp_all +decide

/-
{0} is the grounded extension of the two-argument framework.
-/
theorem twoArg_grounded :
    twoArgFramework.GroundedExt ({0} : Finset (Fin 2)) := by
  constructor;
  · constructor;
    · constructor;
      · native_decide +revert;
      · simp +decide [ twoArgFramework, ArgFramework.Defends ];
    · simp +decide [ twoArgFramework, ArgFramework.Defends ];
  · intro T; unfold twoArgFramework; simp +decide [ ArgFramework.CompleteExt ] ;
    fin_cases T <;> simp +decide [ ArgFramework.Admissible, ArgFramework.Defends ]

/-
**The Euler characteristic conjecture is FALSE.**
    For the two-argument framework, χ(K(AF)) ≠ |preferred ext| - |grounded ext|.
    Specifically, χ = 2 but |{pref}| - |grounded| = 1 - 1 = 0.
-/
theorem euler_char_conjecture_false :
    twoArgFramework.eulerCharacteristic ≠
    (1 : ℤ) - (({0} : Finset (Fin 2)).card : ℤ) := by
  simp +decide

/-! ## Section 6: Admissibility Lattice Properties -/

/-
If no argument attacks `a`, then `a` can be added to any conflict-free set
    containing no self-attackers, preserving conflict-freeness.
-/
theorem unattacked_extends_conflictFree {S : Finset α} {a : α}
    (hS : AF.ConflictFree S)
    (hNotAttacked : ∀ b : α, ¬AF.attacks b a)
    (hNotAttacks : ∀ b ∈ S, ¬AF.attacks a b) :
    AF.ConflictFree (insert a S) := by
  intro x hx y hy; aesop;

/-
**Fundamental lemma**: Every stable extension is a preferred extension.
    This connects the "attacking all outsiders" property to maximality.
-/
theorem stable_is_preferred {S : Finset α}
    (hStab : AF.StableExt S)
    (_hNoSelfAttack : ∀ a : α, ¬AF.attacks a a) :
    AF.PreferredExt S := by
  refine' ⟨ _, _ ⟩;
  · exact stable_is_admissible AF hStab;
  · intro T hT hST
    have h_defend : ∀ a ∈ T, a ∈ S := by
      intro a haT
      by_contra h_not_in_S
      obtain ⟨b, hbS, hbT⟩ : ∃ b ∈ S, AF.attacks b a := by
        exact hStab.2 a h_not_in_S
      have h_contradiction : AF.ConflictFree T := by
        exact hT.1
      exact (by
      exact h_contradiction b ( hST hbS ) a haT hbT);
    exact Finset.Subset.antisymm h_defend hST

/-
The number of conflict-free sets is at least 2^k where k is the size of
    any maximum independent set (preferred extension in irreflexive frameworks).
-/
theorem conflictFree_count_lower_bound {S : Finset α}
    (hCF : AF.ConflictFree S) :
    2 ^ S.card ≤ AF.conflictFreeSets.card := by
  have h_subsets : Finset.powerset S ⊆ AF.conflictFreeSets := by
    exact fun T hT => mem_conflictFreeSets AF T |>.2 ( conflictFree_down_closed AF ( Finset.mem_powerset.1 hT ) hCF );
  simpa using Finset.card_le_card h_subsets

end ArgFramework

end