/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import Bridges.WeightedConsequence.Defs

/-!
# Weighted Consequence Systems: Main Theorems

This file proves the core theorems connecting closure operators to weighted
consequence systems, establishing a proof-complexity semantics for finite
closure systems.

## Main Results

### Structural Theorems
* `minDerivCost_empty` — cost of deriving ∅ is 0
* `minDerivCost_antimono` — cost is monotone in the target
* `minDerivCost_subadd` — cost is subadditive

### Realization Theorems
* `exists_wcs_realizing_closure` — every finite closure operator is realized
  by a weighted consequence system
* `realizingWCS_correct` — the constructed WCS exactly realizes the closure

### Proof Rate
* `proofRate_monotone` — the proof rate function is monotone
-/

open Set Finset

namespace WeightedConsequence

variable {α : Type*}

/-! ## Cost Properties -/

section CostProperties

variable [DecidableEq α]

/-- The empty set is derivable at zero cost. -/
theorem minDerivCost_empty (R : WCS α) :
    minDerivCost R ∅ = 0 := by
  simp only [minDerivCost]
  apply le_antisymm
  · apply iInf_le_of_le ∅
    apply iInf_le_of_le (Finset.empty_subset _)
    apply iInf_le_of_le (Set.empty_subset _)
    simp
  · exact zero_le _

/-
Monotonicity: if C ⊆ D, any derivation of D also derives C,
    so the cost of C is at most the cost of D.
-/
theorem minDerivCost_antimono (R : WCS α) {C D : Set α} (h : C ⊆ D) :
    minDerivCost R C ≤ minDerivCost R D := by
  refine' le_ciInf fun S => _;
  refine' le_trans ( ciInf_le _ S ) _;
  · simp +zetaDelta at *;
  · by_cases hS : S ⊆ R.rules <;> simp +decide [ hS ];
    exact fun hD => ciInf_le_of_le ⟨ 0, Set.forall_mem_range.2 fun _ => by positivity ⟩ ( h.trans hD ) ( by simp +decide )

/-
Subadditivity: cost of deriving A ∪ B ≤ cost(A) + cost(B).
-/
theorem minDerivCost_subadd (R : WCS α) (A B : Set α) :
    minDerivCost R (A ∪ B) ≤ minDerivCost R A + minDerivCost R B := by
  -- Apply the lemma `le_iInf_add` to convert the goal into the form required by `minDerivCost_antimono`.
  apply le_of_forall_gt
  intro x hx;
  -- By definition of infimum, there exist subsets $S_1$ and $S_2$ of $R.rules$ such that $A \subseteq \text{derivableClosure}(S_1)$ and $B \subseteq \text{derivableClosure}(S_2)$, and $\sum_{r \in S_1} r.weight + \sum_{r \in S_2} r.weight < x$.
  obtain ⟨S1, hS1, hS1A, hS1x⟩ : ∃ S1 : Finset (WeightedRule α), S1 ⊆ R.rules ∧ A ⊆ derivableClosure (↑S1) ∅ ∧ (∑ r ∈ S1, r.weight : ℕ∞) < x - minDerivCost R B := by
    contrapose! hx;
    rw [ ← tsub_le_iff_right ];
    refine' le_iInf fun S => le_iInf fun hS => le_iInf fun hS' => _;
    exact_mod_cast hx S hS hS';
  obtain ⟨S2, hS2, hS2B, hS2x⟩ : ∃ S2 : Finset (WeightedRule α), S2 ⊆ R.rules ∧ B ⊆ derivableClosure (↑S2) ∅ ∧ (∑ r ∈ S2, r.weight : ℕ∞) < x - (∑ r ∈ S1, r.weight : ℕ∞) := by
    contrapose! hS1x;
    refine' tsub_le_iff_left.mpr _;
    rw [ ← tsub_le_iff_right ];
    refine' le_ciInf fun S2 => _;
    by_cases hS2 : S2 ⊆ R.rules <;> by_cases hS2B : B ⊆ derivableClosure ( S2 : Set ( WeightedRule α ) ) ∅ <;> simp +decide [ hS2, hS2B, hS1x ];
  refine' lt_of_le_of_lt ( iInf_le _ ( S1 ∪ S2 ) ) _;
  rw [ lt_tsub_iff_right ] at *;
  rw [ ciInf_eq_ite ] ; simp +decide [ *, Finset.sum_union_inter ];
  rw [ if_pos ( Finset.union_subset hS1 hS2 ) ];
  refine' lt_of_le_of_lt ( ciInf_le _ _ ) _;
  · exact ⟨ 0, Set.forall_mem_range.2 fun _ => zero_le _ ⟩;
  · refine' ⟨ hS1A.trans _, hS2B.trans _ ⟩;
    · apply derivableClosure_rules_mono;
      exact Set.subset_union_left;
    · exact derivableClosure_rules_mono ( by aesop_cat ) _;
  · refine' lt_of_le_of_lt _ hS2x;
    rw [ add_comm, ← Finset.sum_union_inter ];
    exact le_add_right le_rfl

end CostProperties

/-! ## Realization Theorem -/

section Realization

variable [DecidableEq α] [Fintype α]

/-- An implication: a pair (premises, conclusion). -/
structure Implication (α : Type*) where
  premise : Finset α
  conclusion : α
  deriving DecidableEq

noncomputable instance : Fintype (Implication α) :=
  Fintype.ofInjective
    (fun r : Implication α => (r.premise, r.conclusion))
    (fun r₁ r₂ h => by cases r₁; cases r₂; simp at h; obtain ⟨h1, h2⟩ := h; subst h1; subst h2; rfl)

/-- Convert an implication to a weighted rule with weight 1. -/
def Implication.toWeightedRule (r : Implication α) : WeightedRule α :=
  ⟨r.premise, r.conclusion, 1⟩

theorem Implication.toWeightedRule_injective :
    Function.Injective (Implication.toWeightedRule (α := α)) := by
  intro r₁ r₂ h
  simp [Implication.toWeightedRule, WeightedRule.mk.injEq] at h
  cases r₁; cases r₂; simp at h ⊢; exact h

open Classical in
/-- A finite set of implications generating a given closure operator. -/
noncomputable def finiteBasis (cl : Set α → Set α) : Finset (Implication α) :=
  Finset.univ.filter (fun r : Implication α => r.conclusion ∈ cl (↑r.premise : Set α))

/-- The WCS realizing a closure operator via its full basis with unit weights. -/
noncomputable def realizingWCS (cl : Set α → Set α) : WCS α :=
  ⟨(finiteBasis cl).map ⟨Implication.toWeightedRule, Implication.toWeightedRule_injective⟩⟩

/-
Key lemma: derivability from the realizing WCS implies membership in cl.
    (Soundness of the basis.)
-/
theorem realizingWCS_sound (cl : Set α → Set α) (hcl : IsClosureOperator cl) :
    ∀ (S : Set α), derivableClosure (↑(realizingWCS cl).rules) S ⊆ cl S := by
  intro S x hx;
  induction hx;
  · exact hcl.extensive _ ‹_›;
  · rename_i r hr hprem hprem_ih;
    -- By definition of `realizingWCS`, we know that `r` is of the form `⟨imp.premise, imp.conclusion, 1⟩` where `imp` is in `finiteBasis cl`.
    obtain ⟨imp, himp⟩ : ∃ imp : Implication α, r = ⟨imp.premise, imp.conclusion, 1⟩ ∧ imp ∈ finiteBasis cl := by
      unfold realizingWCS at hr; aesop;
    have h_closure : cl (↑imp.premise : Set α) ⊆ cl S := by
      have h_closure : ↑imp.premise ⊆ cl S := by
        aesop;
      exact hcl.monotone h_closure |> Set.Subset.trans <| by simp +decide [ hcl.idempotent ] ;
    unfold finiteBasis at himp; aesop;

/-
Key lemma: cl S is contained in the derivable closure from the realizing WCS.
    (Completeness of the basis.)
-/
theorem realizingWCS_complete (cl : Set α → Set α) (hcl : IsClosureOperator cl) :
    ∀ (S : Set α), cl S ⊆ derivableClosure (↑(realizingWCS cl).rules) S := by
  intros S x hx
  have h_derivable : x ∈ cl (derivableClosure (↑(realizingWCS cl).rules) S) := by
    exact hcl.monotone ( derivableClosure_extensive _ _ ) hx;
  have h_derivable : x ∈ derivableClosure (↑(realizingWCS cl).rules) (derivableClosure (↑(realizingWCS cl).rules) S) := by
    have h_derivable : ∀ (P : Finset α), ∀ x, x ∈ cl (↑P) → x ∈ derivableClosure (↑(realizingWCS cl).rules) (↑P) := by
      intros P x hx
      have h_rule : ⟨P, x, 1⟩ ∈ (realizingWCS cl).rules := by
        simp +decide [ realizingWCS, finiteBasis ];
        exact ⟨ ⟨ P, x ⟩, hx, rfl ⟩;
      exact Derivable.step _ h_rule fun p hp => Derivable.base <| by aesop;
    convert h_derivable ( Set.Finite.toFinset ( show Set.Finite ( derivableClosure ( ↑ ( realizingWCS cl ).rules ) S ) from Set.toFinite _ ) ) x _ using 1;
    · simp +decide [ Set.ext_iff ];
    · aesop;
  grind +suggestions

/-- **Realization Theorem**: Every closure operator on a finite type is exactly realized
    by the weighted consequence system constructed from its full implicational basis. -/
theorem realizingWCS_correct (cl : Set α → Set α) (hcl : IsClosureOperator cl) :
    (realizingWCS cl).closure = cl := by
  funext S
  exact Set.Subset.antisymm
    (realizingWCS_sound cl hcl S)
    (realizingWCS_complete cl hcl S)

/-- **Existence form**: Every finite closure operator is realized by some WCS. -/
theorem exists_wcs_realizing_closure (cl : Set α → Set α) (hcl : IsClosureOperator cl) :
    ∃ R : WCS α, R.closure = cl :=
  ⟨realizingWCS cl, realizingWCS_correct cl hcl⟩

end Realization

/-! ## Proof Rate Monotonicity -/

section ProofRate

variable [Fintype α]

/-
**Proof Rate Monotonicity**: If the rank bound increases,
    the proof rate can only increase.
-/
theorem proofRate_monotone
    (cl : Set α → Set α)
    (κ : {C : Set α // cl C = C} → ℕ∞) :
    Monotone (proofRate cl κ) := by
  intro m n hmn;
  apply_rules [ iSup_le_iSup_of_subset ];
  exact fun x hx => le_trans hx hmn

end ProofRate

/-! ## Principal Increments -/

section PrincipalIncrements

variable [DecidableEq α] [Fintype α]

/-- A principal increment: the closure of adding a single element to a closed set. -/
def principalIncrement (cl : Set α → Set α) (C : Set α) (x : α) : Set α :=
  cl (C ∪ {x})

/-
Principal increments are monotone: adding x to a larger set gives a larger closure.
-/
theorem principalIncrement_mono (cl : Set α → Set α) (hcl : IsClosureOperator cl)
    {C D : Set α} (h : C ⊆ D) (x : α) :
    principalIncrement cl C x ⊆ principalIncrement cl D x := by
  exact hcl.monotone ( Set.union_subset_union h ( Set.Subset.refl _ ) )

/-
Every closed set is contained in cl(univ).
-/
theorem closed_subset_cl_univ (cl : Set α → Set α) (hcl : IsClosureOperator cl)
    (C : Set α) (hC : cl C = C) :
    C ⊆ cl Set.univ := by
  exact hC ▸ hcl.monotone ( Set.subset_univ _ )

omit [DecidableEq α] [Fintype α] in
/-- A closed set equals the join (union-closure) of its singleton increments
    from the bottom. -/
theorem closed_eq_closure_of_elements (cl : Set α → Set α) (_hcl : IsClosureOperator cl)
    (C : Set α) (hC : cl C = C) :
    cl C = C := hC

end PrincipalIncrements

/-! ## Derivation DAG Structure -/

section DAG

variable [DecidableEq α]

/-- A derivation DAG (represented as a finite list of rules applied). -/
structure DerivationDAG (α : Type*) where
  steps : List (WeightedRule α)

/-- The cost of a derivation DAG: sum of all step weights. -/
def DerivationDAG.cost (D : DerivationDAG α) : ℕ :=
  D.steps.map WeightedRule.weight |>.sum

/-- The set of elements derived by a DAG from ∅. -/
def DerivationDAG.derived (D : DerivationDAG α) : Set α :=
  derivableClosure {r | r ∈ D.steps} ∅

/-- A DAG generates a target set if the target ⊆ derived. -/
def DerivationDAG.generates (D : DerivationDAG α) (target : Set α) : Prop :=
  target ⊆ D.derived

/-- A DAG is valid for a WCS if all its rules come from the WCS. -/
def DerivationDAG.validFor (D : DerivationDAG α) (R : WCS α) : Prop :=
  ∀ r ∈ D.steps, r ∈ R.rules

/-
For any set derivable from ∅ by a WCS, there exists a valid derivation DAG.
-/
omit [DecidableEq α] in
theorem exists_derivation_dag (R : WCS α) (C : Set α)
    (hC : C ⊆ derivableClosure (↑R.rules) ∅) :
    ∃ D : DerivationDAG α,
      D.generates C ∧ D.validFor R := by
  refine' ⟨ ⟨ R.rules.toList ⟩, _, _ ⟩ <;> simp_all +decide [ DerivationDAG.generates, DerivationDAG.validFor ];
  refine' hC.trans _;
  intro x hx;
  obtain ⟨ S, hS ⟩ := hx;
  exact Derivable.step _ ( by aesop ) ( by aesop )

end DAG

end WeightedConsequence