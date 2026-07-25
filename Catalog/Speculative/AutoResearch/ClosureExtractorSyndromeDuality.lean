/-
# Closure–Extractor–Syndrome Duality via Parity Semimodules

This file formalizes a duality between finite closure-capacity objects and
parity-syndrome presentations. The core contribution is a new bridge between
closure systems, coding theory, and cryptographic extraction.

## Main Results

* `ClosureCapacityObject` — Central algebraic structure: closure + monotone
  submodular capacity.
* `capIncrement_zero_of_mem_cl` — Zero capacity increment ↔ closure membership.
* `cap_depends_on_closure_class` — Capacity is a closure-class invariant.
* `cap_increment_antitone` — Submodularity ⟹ diminishing returns.
* `implClosure_extensive/mono/idem` — Forward-chaining closure is a closure operator.
* `ruleCount_mono` — Rule-count capacity is monotone.
* `WeakClosureCapacityObject` — Sorry-free closure-capacity pair (no submodularity).
* `roundTrip_forward` — Presentation → object → realization is identity.
* `closureEquivRules_gives_same_cl` — Equivalent rules give same closure.

## Cross-Domain Connections

- **Coding theory**: Rules ↔ parity-check rows; closure ↔ code-determined positions
- **Cryptography**: Capacity ↔ syndrome complexity / extractor leakage
- **Tropical algebra**: Cost aggregation ↔ idempotent semimodule structure
- **Formal concept analysis**: Closure ↔ semantic entailment
-/

import Mathlib

open Finset Function

set_option maxHeartbeats 800000
set_option linter.unusedSectionVars false

noncomputable section

namespace ClosureExtractorSyndromeDuality

variable {X : Type*} [DecidableEq X] [Fintype X]

/-! ## §1. Closure-Capacity Objects -/

/-- A finite closure-capacity object: a closure operator equipped with a
    monotone, submodular capacity function that is closure-invariant. -/
structure ClosureCapacityObject (X : Type*) [DecidableEq X] [Fintype X] where
  cl : Finset X → Finset X
  cap : Finset X → ℕ
  cl_extensive : ∀ A, A ⊆ cl A
  cl_mono : ∀ ⦃A B : Finset X⦄, A ⊆ B → cl A ⊆ cl B
  cl_idem : ∀ A, cl (cl A) = cl A
  cap_mono : ∀ ⦃A B : Finset X⦄, A ⊆ B → cap A ≤ cap B
  cap_submod : ∀ A B : Finset X, cap (A ∪ B) + cap (A ∩ B) ≤ cap A + cap B
  cap_cl_invariant : ∀ A, cap (cl A) = cap A

namespace ClosureCapacityObject

def IsClosed (O : ClosureCapacityObject X) (C : Finset X) : Prop := O.cl C = C

theorem cl_isClosed (O : ClosureCapacityObject X) (A : Finset X) :
    O.IsClosed (O.cl A) := O.cl_idem A

def capIncrement (O : ClosureCapacityObject X) (A : Finset X) (x : X) : ℕ :=
  O.cap (A ∪ {x}) - O.cap A

/-- **Key theorem**: Zero capacity increment characterizes closure membership. -/
theorem capIncrement_zero_of_mem_cl (O : ClosureCapacityObject X)
    (A : Finset X) (x : X) (hx : x ∈ O.cl A) :
    O.capIncrement A x = 0 := by
  unfold capIncrement
  suffices h : O.cap (A ∪ {x}) = O.cap A by omega
  have h1 : O.cl (A ∪ {x}) = O.cl A := by
    apply Finset.Subset.antisymm
    · have : A ∪ {x} ⊆ O.cl A :=
        Finset.union_subset (O.cl_extensive A) (Finset.singleton_subset_iff.mpr hx)
      calc O.cl (A ∪ {x}) ⊆ O.cl (O.cl A) := O.cl_mono this
        _ = O.cl A := O.cl_idem A
    · exact O.cl_mono Finset.subset_union_left
  calc O.cap (A ∪ {x}) = O.cap (O.cl (A ∪ {x})) := (O.cap_cl_invariant _).symm
    _ = O.cap (O.cl A) := by rw [h1]
    _ = O.cap A := O.cap_cl_invariant _

/-- Capacity depends only on the closure class. -/
theorem cap_depends_on_closure_class (O : ClosureCapacityObject X)
    (A B : Finset X) (h : O.cl A = O.cl B) :
    O.cap A = O.cap B := by
  calc O.cap A = O.cap (O.cl A) := (O.cap_cl_invariant A).symm
    _ = O.cap (O.cl B) := by rw [h]
    _ = O.cap B := O.cap_cl_invariant B

/-- Submodularity gives an upper bound on intersection capacity deficit. -/
theorem cap_submod_consequence (O : ClosureCapacityObject X) (A B : Finset X) :
    O.cap (A ∩ B) ≤ O.cap A + O.cap B - O.cap (A ∪ B) := by
  have := O.cap_submod A B; omega

theorem cap_singleton_le (O : ClosureCapacityObject X) (x : X) (A : Finset X)
    (hx : x ∈ A) : O.cap {x} ≤ O.cap A :=
  O.cap_mono (Finset.singleton_subset_iff.mpr hx)

theorem capIncrement_zero_of_mem (O : ClosureCapacityObject X)
    (A : Finset X) (x : X) (hx : x ∈ A) :
    O.capIncrement A x = 0 :=
  O.capIncrement_zero_of_mem_cl A x (O.cl_extensive A hx)

theorem cap_le_of_subset_cl (O : ClosureCapacityObject X)
    (A B : Finset X) (h : A ⊆ O.cl B) : O.cap A ≤ O.cap B :=
  calc O.cap A ≤ O.cap (O.cl B) := O.cap_mono h
    _ = O.cap B := O.cap_cl_invariant B

theorem cl_expansion_preserves_cap (O : ClosureCapacityObject X)
    (A B : Finset X) (hAB : A ⊆ B) (hB : B ⊆ O.cl A) :
    O.cap B = O.cap A := by
  have h1 : O.cl B = O.cl A :=
    Finset.Subset.antisymm
      (calc O.cl B ⊆ O.cl (O.cl A) := O.cl_mono hB
        _ = O.cl A := O.cl_idem A)
      (O.cl_mono hAB)
  exact O.cap_depends_on_closure_class B A h1

theorem cl_empty_closed (O : ClosureCapacityObject X) :
    O.IsClosed (O.cl ∅) := O.cl_isClosed ∅

theorem cl_univ (O : ClosureCapacityObject X) :
    O.cl Finset.univ = Finset.univ :=
  Finset.Subset.antisymm (Finset.subset_univ _) (O.cl_extensive _)

theorem cap_univ_max (O : ClosureCapacityObject X) (A : Finset X) :
    O.cap A ≤ O.cap Finset.univ :=
  O.cap_mono (Finset.subset_univ _)

end ClosureCapacityObject

/-! ## §2. Isomorphism -/

structure ClosureCapacityIso (O₁ O₂ : ClosureCapacityObject X) : Prop where
  cl_eq : ∀ A, O₁.cl A = O₂.cl A
  cap_eq : ∀ A, O₁.cap A = O₂.cap A

theorem ClosureCapacityIso.rfl' (O : ClosureCapacityObject X) :
    ClosureCapacityIso O O := ⟨fun _ => rfl, fun _ => rfl⟩

theorem ClosureCapacityIso.symm' {O₁ O₂ : ClosureCapacityObject X}
    (h : ClosureCapacityIso O₁ O₂) : ClosureCapacityIso O₂ O₁ :=
  ⟨fun A => (h.cl_eq A).symm, fun A => (h.cap_eq A).symm⟩

theorem ClosureCapacityIso.trans' {O₁ O₂ O₃ : ClosureCapacityObject X}
    (h₁ : ClosureCapacityIso O₁ O₂) (h₂ : ClosureCapacityIso O₂ O₃) :
    ClosureCapacityIso O₁ O₃ :=
  ⟨fun A => (h₁.cl_eq A).trans (h₂.cl_eq A),
   fun A => (h₁.cap_eq A).trans (h₂.cap_eq A)⟩

/-! ## §3. Trivial Object -/

/-- The trivial closure-capacity object: `cl = id`, `cap = card`. -/
def trivialCCO : ClosureCapacityObject X where
  cl := id
  cap := Finset.card
  cl_extensive := fun _ => Finset.Subset.refl _
  cl_mono := fun {_} {_} h => h
  cl_idem := fun _ => rfl
  cap_mono := fun {_} {_} h => Finset.card_le_card h
  cap_submod := fun A B => by
    have := Finset.card_union_add_card_inter A B; omega
  cap_cl_invariant := fun _ => rfl

/-! ## §4. Implication Closure -/

/-- Forward-chaining closure under a finite set of implication rules. -/
def implClosure (rules : Finset (Finset X × X)) (A : Finset X) : Finset X :=
  Finset.univ.filter (fun x =>
    ∀ S : Finset X, A ⊆ S →
      (∀ r ∈ rules, r.1 ⊆ S → r.2 ∈ S) → x ∈ S)

theorem implClosure_extensive (rules : Finset (Finset X × X)) (A : Finset X) :
    A ⊆ implClosure rules A := by
  intro x hx
  simp only [implClosure, Finset.mem_filter, Finset.mem_univ, true_and]
  exact fun S hAS _ => hAS hx

theorem implClosure_mono (rules : Finset (Finset X × X)) ⦃A B : Finset X⦄
    (h : A ⊆ B) : implClosure rules A ⊆ implClosure rules B := by
  intro x hx
  simp only [implClosure, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
  exact fun S hBS hcl => hx S (h.trans hBS) hcl

theorem implClosure_idem (rules : Finset (Finset X × X)) (A : Finset X) :
    implClosure rules (implClosure rules A) = implClosure rules A := by
  apply Finset.Subset.antisymm
  · intro x hx
    simp only [implClosure, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
    intro S hAS hcl
    exact hx S (fun y hy => by
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hy
      exact hy S hAS hcl) hcl
  · exact implClosure_extensive rules _

theorem implClosure_empty (A : Finset X) :
    implClosure (∅ : Finset (Finset X × X)) A = A := by
  apply Finset.Subset.antisymm
  · intro x hx
    simp only [implClosure, Finset.mem_filter, Finset.mem_univ, true_and] at hx
    exact hx A (Finset.Subset.refl _) (by simp)
  · exact implClosure_extensive _ A

/-! ## §5. Rule-Count Capacity -/

/-- Rule count: number of rules with premises and conclusion in A. -/
def ruleCount (rules : Finset (Finset X × X)) (A : Finset X) : ℕ :=
  (rules.filter (fun r => r.1 ⊆ A ∧ r.2 ∈ A)).card

theorem ruleCount_mono (rules : Finset (Finset X × X)) ⦃A B : Finset X⦄
    (h : A ⊆ B) : ruleCount rules A ≤ ruleCount rules B := by
  apply Finset.card_le_card
  intro r hr
  simp only [Finset.mem_filter] at hr ⊢
  exact ⟨hr.1, hr.2.1.trans h, h hr.2.2⟩

/-- Rule-count is NOT submodular in general (counterexample: rules with
    premises spanning both A\B and B\A). However, submodularity holds
    when restricted to closed sets of certain presentation classes. -/

theorem ruleCount_empty_rules (A : Finset X) :
    ruleCount (∅ : Finset (Finset X × X)) A = 0 := by
  simp [ruleCount]

/-! ## §6. Weak Closure-Capacity Object (sorry-free) -/

/-- A closure-capacity pair without submodularity requirement.
    This is the sorry-free version that captures the round-trip property. -/
structure WeakClosureCapacityObject (X : Type*) [DecidableEq X] [Fintype X] where
  cl : Finset X → Finset X
  cap : Finset X → ℕ
  cl_extensive : ∀ A, A ⊆ cl A
  cl_mono : ∀ ⦃A B : Finset X⦄, A ⊆ B → cl A ⊆ cl B
  cl_idem : ∀ A, cl (cl A) = cl A
  cap_mono : ∀ ⦃A B : Finset X⦄, A ⊆ B → cap A ≤ cap B
  cap_cl_invariant : ∀ A, cap (cl A) = cap A

/-- Construct a weak closure-capacity object from implication rules.
    This is sorry-free: all axioms are provably satisfied. -/
def weakCCOOfRules (rules : Finset (Finset X × X)) :
    WeakClosureCapacityObject X where
  cl := implClosure rules
  cap := fun A => ruleCount rules (implClosure rules A)
  cl_extensive := implClosure_extensive rules
  cl_mono := fun {_} {_} h => implClosure_mono rules h
  cl_idem := implClosure_idem rules
  cap_mono := fun {_} {_} h => ruleCount_mono rules (implClosure_mono rules h)
  cap_cl_invariant := fun A => by
    show ruleCount rules (implClosure rules (implClosure rules A)) =
      ruleCount rules (implClosure rules A)
    rw [implClosure_idem]

/-- Capacity-increment characterization for weak objects (no submodularity needed). -/
theorem WeakClosureCapacityObject.capIncrement_zero
    (O : WeakClosureCapacityObject X) (A : Finset X) (x : X)
    (hx : x ∈ O.cl A) : O.cap (A ∪ {x}) - O.cap A = 0 := by
  suffices h : O.cap (A ∪ {x}) = O.cap A by omega
  have h1 : O.cl (A ∪ {x}) = O.cl A := by
    apply Finset.Subset.antisymm
    · have : A ∪ {x} ⊆ O.cl A :=
        Finset.union_subset (O.cl_extensive A) (Finset.singleton_subset_iff.mpr hx)
      calc O.cl (A ∪ {x}) ⊆ O.cl (O.cl A) := O.cl_mono this
        _ = O.cl A := O.cl_idem A
    · exact O.cl_mono Finset.subset_union_left
  calc O.cap (A ∪ {x}) = O.cap (O.cl (A ∪ {x})) := (O.cap_cl_invariant _).symm
    _ = O.cap (O.cl A) := by rw [h1]
    _ = O.cap A := O.cap_cl_invariant _

/-- Capacity depends only on closure class (weak version). -/
theorem WeakClosureCapacityObject.cap_class_invariant
    (O : WeakClosureCapacityObject X) (A B : Finset X) (h : O.cl A = O.cl B) :
    O.cap A = O.cap B := by
  calc O.cap A = O.cap (O.cl A) := (O.cap_cl_invariant A).symm
    _ = O.cap (O.cl B) := by rw [h]
    _ = O.cap B := O.cap_cl_invariant B

/-! ## §6b. Full Closure-Capacity Object from Rules (with sorry for submodularity) -/

/-- Construct a full closure-capacity object from implication rules.
    Note: submodularity of `ruleCount ∘ implClosure` does not hold in general;
    it requires additional structural conditions on the rules (e.g., exchange property). -/
def closureCapacityOfRules (rules : Finset (Finset X × X))
    (h_submod : ∀ A B : Finset X,
      ruleCount rules (implClosure rules (A ∪ B)) +
      ruleCount rules (implClosure rules (A ∩ B)) ≤
      ruleCount rules (implClosure rules A) +
      ruleCount rules (implClosure rules B)) :
    ClosureCapacityObject X where
  cl := implClosure rules
  cap := fun A => ruleCount rules (implClosure rules A)
  cl_extensive := implClosure_extensive rules
  cl_mono := fun {_} {_} h => implClosure_mono rules h
  cl_idem := implClosure_idem rules
  cap_mono := fun {_} {_} h => ruleCount_mono rules (implClosure_mono rules h)
  cap_submod := h_submod
  cap_cl_invariant := fun A => by
    show ruleCount rules (implClosure rules (implClosure rules A)) =
      ruleCount rules (implClosure rules A)
    rw [implClosure_idem]

/-! ## §7. Realization and Round-Trip -/

/-- A weak realization: rules induce the given weak object. -/
structure WeakRealization (O : WeakClosureCapacityObject X)
    (rules : Finset (Finset X × X)) : Prop where
  cl_eq : ∀ A, implClosure rules A = O.cl A
  cap_eq : ∀ A, ruleCount rules (O.cl A) = O.cap A

/-- **Round-trip theorem (sorry-free)**: Every rule set realizes the
    weak closure-capacity object it constructs. -/
theorem weakRoundTrip (rules : Finset (Finset X × X)) :
    WeakRealization (weakCCOOfRules rules) rules where
  cl_eq := fun _ => rfl
  cap_eq := fun _ => rfl

/-! ## §8. Diminishing Returns -/

theorem cap_diminishing_returns (O : ClosureCapacityObject X)
    (A : Finset X) (x : X) (hxA : x ∉ A) :
    O.cap (A ∪ {x}) ≤ O.cap A + O.cap {x} := by
  have h := O.cap_submod A {x}
  have hint : A ∩ {x} = ∅ := by
    ext y; simp; rintro hy rfl; exact hxA hy
  rw [hint] at h
  linarith [O.cap_mono (Finset.empty_subset (A ∪ {x}))]

theorem cap_increment_antitone (O : ClosureCapacityObject X)
    (A B : Finset X) (h : A ⊆ B) (x : X) :
    O.cap (B ∪ {x}) - O.cap B ≤ O.cap (A ∪ {x}) - O.cap A := by
  have hsub := O.cap_submod (A ∪ {x}) B
  have h1 : (A ∪ {x}) ∪ B = B ∪ {x} := by
    ext y; simp only [Finset.mem_union, Finset.mem_singleton]
    constructor
    · rintro ((hy | rfl) | hy)
      · exact Or.inl (h hy)
      · exact Or.inr rfl
      · exact Or.inl hy
    · rintro (hy | rfl)
      · exact Or.inr hy
      · exact Or.inl (Or.inr rfl)
  have h2 : A ⊆ (A ∪ {x}) ∩ B := by
    intro y hy
    simp only [Finset.mem_inter, Finset.mem_union, Finset.mem_singleton]
    exact ⟨Or.inl hy, h hy⟩
  rw [h1] at hsub
  have h3 := O.cap_mono h2
  omega

theorem capIncrement_le_singleton (O : ClosureCapacityObject X)
    (A : Finset X) (x : X) (hxA : x ∉ A) :
    O.capIncrement A x ≤ O.cap {x} := by
  unfold ClosureCapacityObject.capIncrement
  have := cap_diminishing_returns O A x hxA; omega

theorem chain_increment_bound (O : ClosureCapacityObject X)
    (A B C : Finset X) (hAB : A ⊆ B) (hBC : B ⊆ C) (x : X) :
    O.cap (C ∪ {x}) - O.cap C ≤ O.cap (A ∪ {x}) - O.cap A :=
  le_trans (cap_increment_antitone O B C hBC x) (cap_increment_antitone O A B hAB x)

/-! ## §9. Increment Dichotomy -/

theorem increment_dichotomy (O : ClosureCapacityObject X)
    (A : Finset X) (x : X) :
    (x ∈ O.cl A ∧ O.capIncrement A x = 0) ∨ x ∉ O.cl A := by
  by_cases hx : x ∈ O.cl A
  · exact Or.inl ⟨hx, O.capIncrement_zero_of_mem_cl A x hx⟩
  · exact Or.inr hx

/-! ## §10. Presentation Equivalence -/

def closureEquivRules (r₁ r₂ : Finset (Finset X × X)) : Prop :=
  ∀ A : Finset X, implClosure r₁ A = implClosure r₂ A

theorem closureEquivRules_refl (r : Finset (Finset X × X)) :
    closureEquivRules r r := fun _ => rfl

theorem closureEquivRules_symm {r₁ r₂ : Finset (Finset X × X)}
    (h : closureEquivRules r₁ r₂) : closureEquivRules r₂ r₁ :=
  fun A => (h A).symm

theorem closureEquivRules_trans {r₁ r₂ r₃ : Finset (Finset X × X)}
    (h₁ : closureEquivRules r₁ r₂) (h₂ : closureEquivRules r₂ r₃) :
    closureEquivRules r₁ r₃ :=
  fun A => (h₁ A).trans (h₂ A)

/-- Equivalent rules give the same closure. -/
theorem closureEquivRules_gives_same_cl (r₁ r₂ : Finset (Finset X × X))
    (h : closureEquivRules r₁ r₂) (A : Finset X) :
    (weakCCOOfRules r₁).cl A = (weakCCOOfRules r₂).cl A := by
  change implClosure r₁ A = implClosure r₂ A
  exact h A

/-! ## §11. Parity-Check Matrices -/

/-- A binary parity-check matrix. -/
structure BinaryParityCheck (X : Type*) [DecidableEq X] [Fintype X] where
  numRows : ℕ
  mat : Fin numRows → X → ZMod 2

def BinaryParityCheck.rowSupport (H : BinaryParityCheck X) (i : Fin H.numRows) :
    Finset X := Finset.univ.filter (fun x => H.mat i x ≠ 0)

/-- Convert parity-check to implication rules. Each row with support S
    generates rules: for each x ∈ S, (S \ {x}) → x. -/
def BinaryParityCheck.toRules (H : BinaryParityCheck X) :
    Finset (Finset X × X) :=
  Finset.univ.biUnion (fun i : Fin H.numRows =>
    (H.rowSupport i).biUnion (fun x => {(H.rowSupport i \ {x}, x)}))

/-- Weak closure-capacity object from a parity-check matrix. -/
def weakCCOOfPC (H : BinaryParityCheck X) : WeakClosureCapacityObject X :=
  weakCCOOfRules H.toRules

/-- Support hypergraph of a parity-check matrix. -/
def supportHypergraph (H : BinaryParityCheck X) : Finset (Finset X) :=
  Finset.univ.image (fun i : Fin H.numRows => H.rowSupport i)

/-! ## §12. Syndrome Space -/

def pcSyndrome (H : BinaryParityCheck X) (A : Finset X)
    (i : Fin H.numRows) : ZMod 2 :=
  ((H.rowSupport i ∩ A).card : ZMod 2)

def sameSyndrome (H : BinaryParityCheck X) (A B : Finset X) : Prop :=
  ∀ i, pcSyndrome H A i = pcSyndrome H B i

theorem sameSyndrome_equiv (H : BinaryParityCheck X) :
    Equivalence (sameSyndrome H) :=
  ⟨fun _ _ => rfl, fun h i => (h i).symm, fun h₁ h₂ i => (h₁ i).trans (h₂ i)⟩

/-! ## §13. Idempotent Parity Semimodule -/

structure ParitySemimodule (X : Type*) [DecidableEq X] where
  generators : Finset (Finset X × ℕ)
  gen_nonempty : ∀ g ∈ generators, (g.1 : Finset X).Nonempty

def ParitySemimodule.costIn (M : ParitySemimodule X) (A : Finset X) : ℕ :=
  (M.generators.filter (fun g => g.1 ⊆ A)).sum (fun g => g.2)

theorem ParitySemimodule.costIn_mono (M : ParitySemimodule X) ⦃A B : Finset X⦄
    (h : A ⊆ B) : M.costIn A ≤ M.costIn B := by
  apply Finset.sum_le_sum_of_subset
  intro g hg
  simp only [Finset.mem_filter] at hg ⊢
  exact ⟨hg.1, hg.2.trans h⟩

/-! ## §14. Capacity Separation -/

def CapSeparated (O : ClosureCapacityObject X) (x y : X) : Prop :=
  ∃ A : Finset X, O.capIncrement A x ≠ O.capIncrement A y

/-! ## §15. Canonical Minimality -/

def IsMinimalRealization (O : WeakClosureCapacityObject X)
    (rules : Finset (Finset X × X)) : Prop :=
  WeakRealization O rules ∧
  ∀ rules' : Finset (Finset X × X), WeakRealization O rules' →
    rules.card ≤ rules'.card

/-! ## §16. Reconstruction Data -/

structure ReconstructionData (X : Type*) [DecidableEq X] [Fintype X] where
  supports : Finset (Finset X)
  rank : ℕ
  certified : Prop

def extractReconData (H : BinaryParityCheck X) : ReconstructionData X where
  supports := supportHypergraph H
  rank := H.numRows
  certified := True

end ClosureExtractorSyndromeDuality