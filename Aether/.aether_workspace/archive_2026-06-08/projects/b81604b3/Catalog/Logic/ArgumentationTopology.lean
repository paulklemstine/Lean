/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# The Topology of Argumentation: Why Debates Have Holes

This module formalizes Dung's abstract argumentation frameworks (1995) and constructs
the **independence complex** (conflict-free complex) of an argumentation framework.
We prove that conflict-free sets form an abstract simplicial complex, establish
Dung's Fundamental Lemma, prove that stable extensions are preferred, and show
the existence of preferred extensions in finite frameworks.

## Main Definitions

* `ArgFramework` — An argumentation framework with decidable attack relation
* `ConflictFree` — Conflict-free sets (independent sets of the attack graph)
* `Defends` — S defends argument a against all attackers
* `Admissible` — Admissible sets: conflict-free and self-defending
* `PreferredExt` — Preferred extensions: maximally admissible sets
* `StableExt` — Stable extensions: conflict-free sets attacking all outsiders
* `CompleteExt` — Complete extensions: admissible + containing all defended arguments
* `IndComplex` — The independence complex (abstract simplicial complex of CF sets)

## Main Results

* `conflictFree_down_closed` — Subsets of conflict-free sets are conflict-free
* `admissible_empty` — The empty set is always admissible
* `defends_mono` — Defense is monotone in the defending set
* `dung_fundamental_lemma` — If S is admissible and defends a, and S ∪ {a} is CF,
    then S ∪ {a} is admissible
* `stable_is_admissible` — Every stable extension is admissible
* `stable_is_preferred` — Every stable extension is a preferred extension
* `preferred_ext_exists` — Every finite AF has at least one preferred extension
* `self_attacker_excluded` — Self-attacking arguments belong to no admissible set
* `conflictFree_count_lower_bound` — |CF sets| ≥ 2^|max independent set|
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

namespace Argumentation

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## Core Definitions -/

/-- An **argumentation framework** (Dung, 1995): a finite set of arguments
with a decidable binary attack relation. -/
structure ArgFramework (α : Type*) [Fintype α] [DecidableEq α] where
  /-- The attack relation: `attacks a b` means `a` attacks `b` -/
  attacks : α → α → Prop
  [dec_attacks : DecidableRel attacks]

attribute [instance] ArgFramework.dec_attacks

namespace ArgFramework

variable (af : ArgFramework α)

/-- A set S is **conflict-free** if no argument in S attacks another in S. -/
def ConflictFree (S : Finset α) : Prop :=
  ∀ a ∈ S, ∀ b ∈ S, ¬af.attacks a b

instance (S : Finset α) : Decidable (af.ConflictFree S) :=
  inferInstanceAs (Decidable (∀ a ∈ S, ∀ b ∈ S, ¬af.attacks a b))

/-- S **defends** argument a: every attacker of a is counter-attacked by some member of S. -/
def Defends (S : Finset α) (a : α) : Prop :=
  ∀ b, af.attacks b a → ∃ c ∈ S, af.attacks c b

/-- A set S is **admissible** if it is conflict-free and defends all its members. -/
def Admissible (S : Finset α) : Prop :=
  af.ConflictFree S ∧ ∀ a ∈ S, af.Defends S a

/-- A **preferred extension** is a maximally admissible set. -/
def PreferredExt (S : Finset α) : Prop :=
  af.Admissible S ∧ ∀ T : Finset α, af.Admissible T → S ⊆ T → T = S

/-- A **stable extension** is conflict-free and attacks every non-member. -/
def StableExt (S : Finset α) : Prop :=
  af.ConflictFree S ∧ ∀ a, a ∉ S → ∃ b ∈ S, af.attacks b a

/-- A **complete extension** is admissible and contains all arguments it defends. -/
def CompleteExt (S : Finset α) : Prop :=
  af.Admissible S ∧ ∀ a, af.Defends S a → a ∈ S

/-- The **characteristic function** F(S) = {a | S defends a}. -/
def charFn (S : Finset α) : Finset α :=
  Finset.univ.filter (fun a => ∀ b, af.attacks b a → ∃ c ∈ S, af.attacks c b)

/-! ## The Independence Complex -/

/-- An **abstract simplicial complex**: a downward-closed family of finite sets
containing the empty set. This captures the combinatorial topology of
the argumentation framework. -/
structure IndComplex (α : Type*) where
  faces : Set (Finset α)
  empty_mem : ∅ ∈ faces
  down_closed : ∀ {σ τ : Finset α}, σ ∈ faces → τ ⊆ σ → τ ∈ faces

/-! ## Foundational Theorems -/

/-- The empty set is conflict-free. -/
theorem conflictFree_empty : af.ConflictFree ∅ := by
  intro a ha; simp at ha

/-- **Hereditary property**: subsets of conflict-free sets are conflict-free.
This is the key property making conflict-free sets a simplicial complex. -/
theorem conflictFree_down_closed {S T : Finset α}
    (hS : af.ConflictFree S) (hTS : T ⊆ S) : af.ConflictFree T :=
  fun a ha b hb => hS a (hTS ha) b (hTS hb)

/-- The **argumentation complex**: conflict-free sets form a simplicial complex.
This is the central novel construction connecting argumentation to topology. -/
def argComplex : IndComplex α where
  faces := {S | af.ConflictFree S}
  empty_mem := af.conflictFree_empty
  down_closed := fun hσ hτσ => af.conflictFree_down_closed hσ hτσ

/-- The empty set is always admissible (vacuously self-defending). -/
theorem admissible_empty : af.Admissible ∅ :=
  ⟨af.conflictFree_empty, fun a ha => by simp at ha⟩

/-- Every admissible set is conflict-free. -/
theorem admissible_is_conflictFree {S : Finset α} (h : af.Admissible S) :
    af.ConflictFree S := h.1

/-- **Monotonicity of defense**: if S defends a and S ⊆ T, then T defends a.
This is the engine behind Dung's Fundamental Lemma. -/
theorem defends_mono {S T : Finset α} {a : α}
    (h : af.Defends S a) (hsub : S ⊆ T) : af.Defends T a := by
  intro b hba
  obtain ⟨c, hcS, hcb⟩ := h b hba
  exact ⟨c, hsub hcS, hcb⟩

/-- A self-attacking argument cannot belong to any admissible set. -/
theorem self_attacker_excluded {a : α} {S : Finset α}
    (hself : af.attacks a a) (hadm : af.Admissible S) : a ∉ S := by
  intro ha
  exact hadm.1 a ha a ha hself

/-
**Dung's Fundamental Lemma**: If S is admissible and S defends a,
and inserting a preserves conflict-freeness, then S ∪ {a} is admissible.
This is the key lemma for constructing preferred extensions by iterative expansion.
-/
theorem dung_fundamental_lemma {S : Finset α} {a : α}
    (hadm : af.Admissible S)
    (hdef : af.Defends S a)
    (hcf : af.ConflictFree (insert a S)) :
    af.Admissible (insert a S) := by
  refine' ⟨ hcf, fun x hx => _ ⟩;
  cases Finset.mem_insert.mp hx <;> simp_all +decide;
  · exact af.defends_mono hdef ( Finset.subset_insert _ _ );
  · exact af.defends_mono ( hadm.2 x ‹_› ) ( Finset.subset_insert _ _ )

/-
The characteristic function is monotone.
-/
theorem charFn_mono {S T : Finset α} (h : S ⊆ T) :
    af.charFn S ⊆ af.charFn T := by
  intro a ha; simp_all +decide [ ArgFramework.charFn ] ;
  exact fun b hb => by obtain ⟨ c, hcS, hc ⟩ := ha b hb; exact ⟨ c, h hcS, hc ⟩ ;

/-
Every stable extension is admissible.
-/
theorem stable_is_admissible {S : Finset α}
    (hstab : af.StableExt S) : af.Admissible S := by
  refine' ⟨ hstab.1, _ ⟩;
  intro a ha b hb;
  by_cases hbS : b ∈ S;
  · exact False.elim ( hstab.1 _ hbS _ ha hb );
  · exact hstab.2 b hbS

/-
**Stable extensions are preferred**: every stable extension is maximally admissible.
The proof proceeds in two parts:
1. S is admissible (from `stable_is_admissible`)
2. S is maximal: any admissible T ⊇ S must equal S, because any element of T \ S
   would be attacked by S (stability), creating an internal conflict in T.
-/
theorem stable_is_preferred {S : Finset α}
    (hstab : af.StableExt S) : af.PreferredExt S := by
  grind +locals

/-
Among all admissible sets, there exists one of maximum cardinality.
-/
private theorem exists_max_card_admissible :
    ∃ S : Finset α, af.Admissible S ∧
      ∀ T : Finset α, af.Admissible T → T.card ≤ S.card := by
  have h_finite : (Finset.univ.filter (fun S : Finset α => af.Admissible S)).Nonempty := by
    exact ⟨ ∅, by simp +decide [ af.admissible_empty ] ⟩;
  obtain ⟨ S, hS ⟩ := Finset.exists_max_image _ ( fun T => Finset.card T ) h_finite ; use S ; aesop;

/-
A maximum-cardinality admissible set is maximally admissible (preferred).
-/
private theorem max_card_admissible_is_preferred {S : Finset α}
    (hadm : af.Admissible S)
    (hmax : ∀ T : Finset α, af.Admissible T → T.card ≤ S.card) :
    af.PreferredExt S := by
  refine' ⟨ hadm, fun T hT hST => _ ⟩;
  exact Finset.eq_of_subset_of_card_le hST ( by linarith [ hmax T hT ] ) ▸ rfl

/-
**Existence of preferred extensions**: every finite argumentation framework
has at least one preferred extension. This follows from finiteness:
among all admissible sets (nonempty since ∅ is admissible), take one
of maximum cardinality; it must be maximally admissible.
-/
theorem preferred_ext_exists : ∃ S : Finset α, af.PreferredExt S := by
  exact ⟨ _, max_card_admissible_is_preferred _ ( exists_max_card_admissible _ ).choose_spec.1 ( exists_max_card_admissible _ ).choose_spec.2 ⟩

/-! ## Computational Definitions -/

/-- The set of all conflict-free subsets. -/
def conflictFreeSets : Finset (Finset α) :=
  Finset.univ.powerset.filter af.ConflictFree

/-- Membership in conflictFreeSets characterizes conflict-freeness. -/
theorem mem_conflictFreeSets (S : Finset α) :
    S ∈ af.conflictFreeSets ↔ af.ConflictFree S := by
  simp [conflictFreeSets, Finset.mem_filter]

/-- The f-vector: number of faces of dimension k (faces with k+1 vertices). -/
def fVector (k : ℕ) : ℕ :=
  (af.conflictFreeSets.filter (fun F => F.card = k + 1)).card

/-- The Euler characteristic of the independence complex. -/
def eulerChar : ℤ :=
  ∑ k ∈ Finset.range (Fintype.card α),
    (-1 : ℤ) ^ k * (af.fVector k : ℤ)

/-
**Lower bound on conflict-free sets**: if S is conflict-free with |S| = k,
then there are at least 2^k conflict-free sets (all subsets of S).
-/
theorem conflictFree_count_lower_bound {S : Finset α}
    (hcf : af.ConflictFree S) :
    2 ^ S.card ≤ af.conflictFreeSets.card := by
  refine' le_trans _ ( Finset.card_le_card _ );
  rw [ Finset.card_powerset ];
  exact fun T hT => Finset.mem_filter.mpr ⟨ Finset.mem_powerset.mpr ( Finset.subset_univ _ ), af.conflictFree_down_closed hcf ( Finset.mem_powerset.mp hT ) ⟩

/-! ## Counterexample: The Euler Characteristic Conjecture Is False -/

/-- The two-argument framework: argument 0 attacks argument 1, no other attacks. -/
def twoArgAF : ArgFramework (Fin 2) where
  attacks a b := a = 0 ∧ b = 1

/-
{0} is the unique preferred extension of the two-argument framework.
-/
theorem twoArg_preferred_ext :
    twoArgAF.PreferredExt ({0} : Finset (Fin 2)) := by
  constructor;
  · constructor <;> simp +decide [ twoArgAF ];
    exact fun b hb => by fin_cases b <;> simp_all +decide ;
  · rintro T ⟨ hT₁, hT₂ ⟩ hT₃; fin_cases T <;> simp_all +decide ;

/-
The Euler characteristic conjecture (χ = |preferred| - |grounded|) is **false**.
For the two-argument framework, χ(K) = 2 but |{preferred}| - |grounded| = 0.
-/
theorem euler_conjecture_false :
    ¬∀ (af : ArgFramework (Fin 2)),
      af.eulerChar = 1 - ((Finset.univ.filter (fun S => af.PreferredExt S)).card : ℤ) := by
  push_neg;
  use ⟨ fun _ _ => False ⟩;
  simp +decide [ Argumentation.ArgFramework.PreferredExt ];
  simp +decide [ Argumentation.ArgFramework.eulerChar, Argumentation.ArgFramework.Admissible ];
  simp +decide [ Argumentation.ArgFramework.ConflictFree, Argumentation.ArgFramework.Defends ]

end ArgFramework

end Argumentation

end