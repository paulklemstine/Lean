/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import Mathlib

/-!
# Weighted Consequence Systems: Definitions

This file defines the core objects for a proof-complexity semantics
of finite closure systems via weighted consequence systems.

## Main Definitions

* `WeightedConsequence.IsClosureOperator` — extensive, monotone, idempotent operator on sets
* `WeightedConsequence.WeightedRule` — a Horn-style rule with premises, conclusion, and weight
* `WeightedConsequence.Derivable` — inductive derivability from a set of weighted rules
* `WeightedConsequence.derivableClosure` — the closure operator induced by derivability
* `WeightedConsequence.minDerivCost` — minimum derivation cost for a target set

## Overview

A **weighted consequence system** consists of Horn-style rules `(premises, conclusion, weight)`
where premises is a finite set of atomic propositions, conclusion is a single proposition,
and weight is a nonneg integer. The **derivable closure** of a set `S` under rules `R` is the
smallest set containing `S` and closed under all rules. The **minimum derivation cost** of
deriving a target set `T` from `∅` is the infimum of total rule weights over all sufficient
subsets of rules.
-/

open Set Finset

namespace WeightedConsequence

variable {α : Type*}

/-! ## Closure Operators -/

/-- A closure operator on `Set α`: extensive, monotone, idempotent. -/
structure IsClosureOperator (cl : Set α → Set α) : Prop where
  extensive : ∀ A, A ⊆ cl A
  monotone : ∀ ⦃A B : Set α⦄, A ⊆ B → cl A ⊆ cl B
  idempotent : ∀ A, cl (cl A) = cl A

/-- A set is closed if `cl A = A`. -/
def IsClosed (cl : Set α → Set α) (A : Set α) : Prop := cl A = A

/-! ## Weighted Rules -/

/-- A weighted Horn rule: derives `conclusion` from `premises` at cost `weight`. -/
structure WeightedRule (α : Type*) where
  premises : Finset α
  conclusion : α
  weight : ℕ
  deriving DecidableEq

/-! ## Derivability -/

/-- Inductive derivability: `x` is derivable from `S` using `rules` if either
    `x ∈ S` (base), or there is a rule `r ∈ rules` whose premises are all derivable
    and whose conclusion is `x`. -/
inductive Derivable (rules : Set (WeightedRule α)) (S : Set α) : α → Prop where
  | base (hx : x ∈ S) : Derivable rules S x
  | step (r : WeightedRule α) (hr : r ∈ rules)
    (hprem : ∀ p ∈ r.premises, Derivable rules S p) :
    Derivable rules S r.conclusion

/-- The derivable closure of `S` under `rules`: the set of all derivable elements. -/
def derivableClosure (rules : Set (WeightedRule α)) (S : Set α) : Set α :=
  {x | Derivable rules S x}

/-! ## Derivable Closure is a Closure Operator -/

theorem derivableClosure_extensive (rules : Set (WeightedRule α)) (S : Set α) :
    S ⊆ derivableClosure rules S :=
  fun _ hx => Derivable.base hx

theorem Derivable.mono {rules : Set (WeightedRule α)} {S T : Set α} (h : S ⊆ T)
    {x : α} (hd : Derivable rules S x) : Derivable rules T x := by
  induction hd with
  | base hx => exact Derivable.base (h hx)
  | step r hr _ ih => exact Derivable.step r hr (fun p hp => ih p hp)

theorem derivableClosure_mono (rules : Set (WeightedRule α)) {S T : Set α} (h : S ⊆ T) :
    derivableClosure rules S ⊆ derivableClosure rules T :=
  fun _ hd => hd.mono h

theorem Derivable.flatten {rules : Set (WeightedRule α)} {S : Set α}
    {x : α} (hd : Derivable rules (derivableClosure rules S) x) :
    Derivable rules S x := by
  induction hd with
  | base hx => exact hx
  | step r hr _ ih => exact Derivable.step r hr (fun p hp => ih p hp)

theorem derivableClosure_idempotent (rules : Set (WeightedRule α)) (S : Set α) :
    derivableClosure rules (derivableClosure rules S) = derivableClosure rules S := by
  ext x
  exact ⟨Derivable.flatten, fun h => derivableClosure_extensive rules _ h⟩

/-- The derivable closure operator is a closure operator. -/
theorem derivableClosure_isClosureOperator (rules : Set (WeightedRule α)) :
    IsClosureOperator (derivableClosure rules) where
  extensive := derivableClosure_extensive rules
  monotone := fun {_ _} h => derivableClosure_mono rules h
  idempotent := derivableClosure_idempotent rules

/-! ## Monotonicity in Rules -/

theorem Derivable.rules_mono {R₁ R₂ : Set (WeightedRule α)} (h : R₁ ⊆ R₂)
    {S : Set α} {x : α} (hd : Derivable R₁ S x) : Derivable R₂ S x := by
  induction hd with
  | base hx => exact Derivable.base hx
  | step r hr _ ih => exact Derivable.step r (h hr) (fun p hp => ih p hp)

theorem derivableClosure_rules_mono {R₁ R₂ : Set (WeightedRule α)} (h : R₁ ⊆ R₂)
    (S : Set α) : derivableClosure R₁ S ⊆ derivableClosure R₂ S :=
  fun _ hd => hd.rules_mono h

/-! ## Closed Sets under Derivability -/

theorem derivableClosure_closed (rules : Set (WeightedRule α)) (S : Set α) :
    IsClosed (derivableClosure rules) (derivableClosure rules S) :=
  derivableClosure_idempotent rules S

/-! ## Weighted Consequence Systems -/

/-- A weighted consequence system is a finite set of weighted rules. -/
structure WCS (α : Type*) where
  rules : Finset (WeightedRule α)

/-- The closure operator induced by a weighted consequence system. -/
def WCS.closure (R : WCS α) : Set α → Set α :=
  derivableClosure (↑R.rules : Set (WeightedRule α))

theorem WCS.closure_isClosureOperator (R : WCS α) :
    IsClosureOperator R.closure :=
  derivableClosure_isClosureOperator _

/-! ## Minimum Derivation Cost -/

/-- The minimum derivation cost: infimum of total weight over all subsets of rules
    sufficient to derive the target from ∅. Uses `ℕ∞ = WithTop ℕ`. -/
noncomputable def minDerivCost [DecidableEq α] (R : WCS α) (target : Set α) : ℕ∞ :=
  ⨅ (S : Finset (WeightedRule α)) (_ : S ⊆ R.rules)
    (_ : target ⊆ derivableClosure (↑S) ∅),
    ((S.sum WeightedRule.weight : ℕ) : ℕ∞)

/-! ## Closed Rank and Proof Rate -/

open Classical in
/-- The rank of a closed set relative to a closure: minimum generator cardinality. -/
noncomputable def closedRank [Fintype α]
    (cl : Set α → Set α) (C : Set α) : ℕ :=
  sInf {n : ℕ | ∃ S : Finset α, S.card = n ∧ cl (↑S) = C}

/-- The proof rate: supremum of costs over closed sets of bounded rank. -/
noncomputable def proofRate [Fintype α]
    (cl : Set α → Set α)
    (κ : {C : Set α // cl C = C} → ℕ∞)
    (m : ℕ) : ℕ∞ :=
  ⨆ (C : {C : Set α // cl C = C}) (_ : closedRank cl C.1 ≤ m), κ C

/-! ## Bundle of Axioms for Closure-Capacity Structures -/

open Classical in
/-- The axioms for a closure-capacity structure: normalization, monotonicity, subadditivity. -/
structure ClosureCapacityAxioms [Fintype α]
    (cl : Set α → Set α) (hcl : IsClosureOperator cl)
    (κ : {C : Set α // cl C = C} → ℕ∞) : Prop where
  norm : κ ⟨cl ∅, by rw [hcl.idempotent]⟩ = 0
  mono : ∀ {C D : Set α} (hC : cl C = C) (hD : cl D = D),
    C ⊆ D → κ ⟨C, hC⟩ ≤ κ ⟨D, hD⟩
  subadd : ∀ (A B : Set α),
    κ ⟨cl (A ∪ B), by rw [hcl.idempotent]⟩
      ≤ κ ⟨cl A, by rw [hcl.idempotent]⟩
        + κ ⟨cl B, by rw [hcl.idempotent]⟩

end WeightedConsequence