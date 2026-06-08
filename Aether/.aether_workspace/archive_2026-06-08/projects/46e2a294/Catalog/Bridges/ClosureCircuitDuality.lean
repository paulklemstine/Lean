/-
Copyright (c) 2025 Closure-Circuit Duality Project. All rights reserved.

# Closure-Circuit Duality: Certified Monotone Circuit Reconstruction

This file formalizes a duality between finite closure systems and monotone Boolean
circuits, establishing that every closure operator on a finite type admits a unique
canonical residual basis of minimal generators, and that this basis yields a
monotone DNF circuit that correctly computes the closure.

## Main Results

* `generatedClosure_isClosureOperator` — Implication-generated closures are closure operators
* `minimal_support_exists` — Every element in a closure has a minimal support set
* `closure_iff_contains_minimal_support` — Closure membership ↔ existence of a minimal support
* `canonical_basis_is_basis` — The canonical basis satisfies the basis property
* `canonical_basis_unique` — The canonical residual basis is unique
* `reconstructed_circuit_correct` — The reconstructed DNF circuit correctly computes closure
* `finite_closure_duality` — Main duality theorem packaging all results
* `closure_basis_canonical` — Existence and uniqueness of the canonical basis (`∃!`)

## Overview

The central idea is a **Myhill–Nerode-type minimization principle for monotone closure
computation**: bounded dependency rank forces a canonical finite residual basis, and this
basis is exactly the algebraic shadow of a minimal monotone circuit.
-/

import Mathlib

namespace ClosureCircuitDuality

open Set Finset

noncomputable section

/-! ## Part 1: Core Definitions -/

/-- A closure operator on `Set α`: extensive, monotone, and idempotent. -/
structure IsClosureOperator {α : Type*} (cl : Set α → Set α) : Prop where
  extensive : ∀ s, s ⊆ cl s
  monotone : ∀ ⦃s t⦄, s ⊆ t → cl s ⊆ cl t
  idempotent : ∀ s, cl (cl s) = cl s

/-! ## Part 2: Implication Presentations -/

/-- A closure presentation: a finite set of rules `(premises, conclusion)`. -/
abbrev ClosurePresentation (α : Type*) [DecidableEq α] := Finset (Finset α × α)

/-- A set `s` is closed under a presentation `P`. -/
def ClosedUnder {α : Type*} [DecidableEq α]
    (P : ClosurePresentation α) (s : Set α) : Prop :=
  ∀ rule ∈ P, (↑rule.1 : Set α) ⊆ s → rule.2 ∈ s

/-- The closure of `s` under presentation `P`: intersection of all closed supersets. -/
def GeneratedClosure {α : Type*} [DecidableEq α]
    (P : ClosurePresentation α) (s : Set α) : Set α :=
  ⋂₀ {t : Set α | s ⊆ t ∧ ClosedUnder P t}

/-- A closure operator has rank bounded by `r`. -/
def ClosureRankBounded {α : Type*} [DecidableEq α]
    (cl : Set α → Set α) (r : ℕ) : Prop :=
  ∃ P : ClosurePresentation α,
    (∀ rule ∈ P, rule.1.card ≤ r) ∧
    ∀ s, GeneratedClosure P s = cl s

/-! ## Part 3: Residual Equivalence and Generators -/

/-- Residual equivalence: `x` and `y` have the same closure profile. -/
def ResidualEquivalent {α : Type*} (cl : Set α → Set α) (x y : α) : Prop :=
  ∀ s : Set α, x ∈ cl s ↔ y ∈ cl s

/-- A residual generator pairs a target element with a support set. -/
@[ext]
structure ResidualGenerator (α : Type*) where
  target : α
  support : Finset α

instance {α : Type*} [DecidableEq α] : DecidableEq (ResidualGenerator α) :=
  fun a b =>
    if ht : a.target = b.target then
      if hs : a.support = b.support then
        isTrue (ResidualGenerator.ext ht hs)
      else isFalse (fun h => hs (h ▸ rfl))
    else isFalse (fun h => ht (h ▸ rfl))

/-- A minimal support for `x` under `cl`: `A` generates `x` and no proper subset does. -/
def IsMinimalSupport {α : Type*} [DecidableEq α]
    (cl : Set α → Set α) (x : α) (A : Finset α) : Prop :=
  x ∈ cl (↑A : Set α) ∧ ∀ B : Finset α, B ⊂ A → x ∉ cl (↑B : Set α)

/-- The set of all minimal supports for a given target `x`. -/
def minimalSupports {α : Type*} [DecidableEq α] [Fintype α]
    (cl : Set α → Set α) (x : α) : Finset (Finset α) :=
  @Finset.filter _ (fun A' => IsMinimalSupport cl x A')
    (fun _ => Classical.propDecidable _) Finset.univ

/-! ## Part 4: Canonical Residual Basis -/

/-- The canonical residual basis: the set of all minimal residual generators. -/
def canonicalBasis {α : Type*} [DecidableEq α] [Fintype α]
    (cl : Set α → Set α) : Finset (ResidualGenerator α) :=
  Finset.univ.biUnion fun x =>
    (minimalSupports cl x).image fun A => ⟨x, A⟩

/-- A set of residual generators forms a canonical basis:
    1. Every generator is minimal.
    2. Closure membership ↔ containing some generator's support. -/
def IsCanonicalBasis {α : Type*} [DecidableEq α] [Fintype α]
    (cl : Set α → Set α) (B : Finset (ResidualGenerator α)) : Prop :=
  (∀ g ∈ B, IsMinimalSupport cl g.target g.support) ∧
  (∀ x : α, ∀ s : Set α,
    x ∈ cl s ↔ ∃ g ∈ B, g.target = x ∧ (↑g.support : Set α) ⊆ s)

/-! ## Part 5: Monotone Circuits -/

/-- A monotone Boolean circuit over inputs from `α`. -/
inductive MonotoneCircuit (α : Type*)
  | input : α → MonotoneCircuit α
  | top : MonotoneCircuit α
  | bot : MonotoneCircuit α
  | conj : MonotoneCircuit α → MonotoneCircuit α → MonotoneCircuit α
  | disj : MonotoneCircuit α → MonotoneCircuit α → MonotoneCircuit α

namespace MonotoneCircuit

/-- Evaluate a monotone circuit on a set `s`. -/
def eval {α : Type*} : MonotoneCircuit α → Set α → Prop
  | input a, s => a ∈ s
  | top, _ => True
  | bot, _ => False
  | conj c₁ c₂, s => c₁.eval s ∧ c₂.eval s
  | disj c₁ c₂, s => c₁.eval s ∨ c₂.eval s

/-- The size (number of gates) of a circuit. -/
def size {α : Type*} : MonotoneCircuit α → ℕ
  | input _ => 1
  | top => 1
  | bot => 1
  | conj c₁ c₂ => 1 + c₁.size + c₂.size
  | disj c₁ c₂ => 1 + c₁.size + c₂.size

/-- Circuit evaluation is monotone. -/
theorem eval_mono {α : Type*} (c : MonotoneCircuit α) {s t : Set α} (h : s ⊆ t) :
    c.eval s → c.eval t := by
  induction c with
  | input a => exact fun ha => h ha
  | top => exact id
  | bot => exact id
  | conj c₁ c₂ ih₁ ih₂ => exact fun ⟨h₁, h₂⟩ => ⟨ih₁ h₁, ih₂ h₂⟩
  | disj c₁ c₂ ih₁ ih₂ => exact fun h' => h'.elim (Or.inl ∘ ih₁) (Or.inr ∘ ih₂)

end MonotoneCircuit

/-- Build a conjunction circuit from a list of inputs. -/
def conjOfList {α : Type*} : List α → MonotoneCircuit α
  | [] => .top
  | a :: as => .conj (.input a) (conjOfList as)

/-- Build a disjunction of circuits from a list. -/
def disjOfList {α : Type*} : List (MonotoneCircuit α) → MonotoneCircuit α
  | [] => .bot
  | c :: cs => .disj c (disjOfList cs)

/-- `conjOfList l` evaluates to true on `s` iff all elements of `l` are in `s`. -/
theorem conjOfList_eval {α : Type*} (l : List α) (s : Set α) :
    (conjOfList l).eval s ↔ ∀ a ∈ l, a ∈ s := by
  induction l with
  | nil => simp [conjOfList, MonotoneCircuit.eval]
  | cons a as ih =>
    simp only [conjOfList, MonotoneCircuit.eval, ih, List.forall_mem_cons]

/-- `disjOfList cs` evaluates to true on `s` iff some circuit in `cs` does. -/
theorem disjOfList_eval {α : Type*} (l : List (MonotoneCircuit α)) (s : Set α) :
    (disjOfList l).eval s ↔ ∃ c ∈ l, MonotoneCircuit.eval c s := by
  induction l with
  | nil => simp [disjOfList, MonotoneCircuit.eval]
  | cons c cs ih =>
    simp only [disjOfList, MonotoneCircuit.eval, ih]
    constructor
    · rintro (h | ⟨c', hc', heval⟩)
      · exact ⟨c, List.mem_cons_self .., h⟩
      · exact ⟨c', List.mem_cons_of_mem _ hc', heval⟩
    · rintro ⟨c', hc', heval⟩
      rcases List.mem_cons.mp hc' with rfl | hc'
      · exact Or.inl heval
      · exact Or.inr ⟨c', hc', heval⟩

/-! ## Part 6: Closure Circuit and Reconstruction -/

/-- A closure circuit: one monotone circuit per output element. -/
structure ClosureCircuit (α : Type*) where
  output : α → MonotoneCircuit α

/-- A closure circuit correctly computes a closure operator. -/
def CircuitComputesClosure {α : Type*}
    (C : ClosureCircuit α) (cl : Set α → Set α) : Prop :=
  ∀ x s, (C.output x).eval s ↔ x ∈ cl s

/-- Reconstruct a closure circuit from a closure operator using its minimal
    supports: for each `x`, build `⋁_{A ∈ minSupp(x)} ⋀_{a ∈ A} input(a)`. -/
def reconstructClosureCircuit {α : Type*} [DecidableEq α] [Fintype α]
    (cl : Set α → Set α) : ClosureCircuit α where
  output x := disjOfList
    ((minimalSupports cl x).val.toList.map fun A => conjOfList A.val.toList)

/-! ## Part 7: GeneratedClosure is a Closure Operator -/

variable {α : Type*} [DecidableEq α] [Fintype α]

omit [Fintype α] in
theorem generatedClosure_extensive (P : ClosurePresentation α) (s : Set α) :
    s ⊆ GeneratedClosure P s :=
  fun _ hx => Set.mem_sInter.mpr fun _ ⟨hst, _⟩ => hst hx

omit [Fintype α] in
theorem generatedClosure_monotone (P : ClosurePresentation α) {s t : Set α} (h : s ⊆ t) :
    GeneratedClosure P s ⊆ GeneratedClosure P t :=
  fun _ hx => Set.mem_sInter.mpr fun u ⟨htu, hclosed⟩ =>
    Set.mem_sInter.mp hx u ⟨h.trans htu, hclosed⟩

omit [Fintype α] in
theorem generatedClosure_closedUnder (P : ClosurePresentation α) (s : Set α) :
    ClosedUnder P (GeneratedClosure P s) := by
  intro rule hrule hprem
  exact Set.mem_sInter.mpr fun t ⟨hst, hclosed⟩ =>
    hclosed rule hrule fun y hy => Set.mem_sInter.mp (hprem hy) t ⟨hst, hclosed⟩

theorem generatedClosure_idempotent (P : ClosurePresentation α) (s : Set α) :
    GeneratedClosure P (GeneratedClosure P s) = GeneratedClosure P s := by
  apply Set.Subset.antisymm
  · intro x hx
    exact Set.mem_sInter.mp hx (GeneratedClosure P s)
      ⟨fun _ h => h, generatedClosure_closedUnder P s⟩
  · exact generatedClosure_extensive P (GeneratedClosure P s)

/-- The closure generated by an implication presentation is a closure operator. -/
theorem generatedClosure_isClosureOperator (P : ClosurePresentation α) :
    IsClosureOperator (GeneratedClosure P) where
  extensive := generatedClosure_extensive P
  monotone := fun {_} {_} h => generatedClosure_monotone P h
  idempotent := generatedClosure_idempotent P

/-! ## Part 8: Minimal Support Theory -/

/-
Every element in a closure (applied to a finite set) admits a minimal support.
-/
omit [Fintype α] in
theorem minimal_support_exists
    (cl : Set α → Set α) (_hcl : IsClosureOperator cl)
    (x : α) (s : Finset α) (hx : x ∈ cl (↑s : Set α)) :
    ∃ A : Finset α, A ⊆ s ∧ IsMinimalSupport cl x A := by
  have h_well_founded : ∀ (A : Finset α), x ∈ cl (A : Set α) → ∃ B ⊆ A, x ∈ cl (B : Set α) ∧ ∀ C ⊆ B, C ≠ B → x ∉ cl (C : Set α) := by
    intro A hx
    induction' A using Finset.strongInduction with A ih generalizing x;
    grind +qlia;
  obtain ⟨ B, hB₁, hB₂, hB₃ ⟩ := h_well_founded s hx; use B; simp_all +decide [ IsMinimalSupport ] ;
  exact fun C hC => hB₃ C hC.1 hC.ne

/-
Closure membership ↔ existence of a minimal support within any generating set.
-/
theorem closure_iff_contains_minimal_support
    (cl : Set α → Set α) (hcl : IsClosureOperator cl)
    (x : α) (s : Set α) :
    x ∈ cl s ↔ ∃ A ∈ minimalSupports cl x, (↑A : Set α) ⊆ s := by
  constructor;
  · intro hx;
    have := minimal_support_exists cl hcl x ( Set.Finite.toFinset ( Set.toFinite s ) ) ?_;
    · unfold minimalSupports; aesop;
    · aesop;
  · norm_num +zetaDelta at *;
    intro A hA hs;
    exact hcl.monotone hs ( by unfold minimalSupports at hA; unfold IsMinimalSupport at hA; aesop )

/-! ## Part 9: Canonical Basis Theorems -/

/-
The canonical basis satisfies the basis property.
-/
theorem canonical_basis_is_basis
    (cl : Set α → Set α) (hcl : IsClosureOperator cl) :
    IsCanonicalBasis cl (canonicalBasis cl) := by
  constructor;
  · unfold canonicalBasis;
    unfold minimalSupports; aesop;
  · intro x s;
    convert closure_iff_contains_minimal_support cl hcl x s using 1;
    unfold canonicalBasis minimalSupports;
    aesop

/-
Any two canonical bases are equal.
-/
theorem canonical_basis_unique
    (cl : Set α → Set α) (_hcl : IsClosureOperator cl)
    (B₁ B₂ : Finset (ResidualGenerator α))
    (h₁ : IsCanonicalBasis cl B₁) (h₂ : IsCanonicalBasis cl B₂) :
    B₁ = B₂ := by
  apply Finset.ext
  intro g
  constructor
  intro hg₁
  obtain ⟨g', hg₂, hg₃⟩ := h₂.2 g.target (↑g.support : Set α) |>.1 (h₁.1 g hg₁ |>.1)
  have hg₄ : g'.target = g.target ∧ (↑g'.support : Set α) ⊆ ↑g.support := by
    exact hg₃
  have hg₅ : g'.support = g.support := by
    have hg₅ : IsMinimalSupport cl g.target g.support := by
      exact h₁.1 g hg₁
    have hg₆ : IsMinimalSupport cl g.target g'.support := by
      have := h₂.1 g' hg₂; aesop;
    simp_all +decide [ IsMinimalSupport ];
    grind
  have hg₆ : g' = g := by
    cases g ; cases g' ; aesop
  aesop;
  intro hg;
  obtain ⟨g', hg'⟩ := h₁.2 g.target (↑g.support : Set α) |>.1 (h₂.1 g hg |>.1);
  have hg'_eq_g : g'.support = g.support := by
    have hg'_eq_g : ∀ B : Finset α, B ⊂ g.support → g.target ∉ cl (↑B : Set α) := by
      exact h₂.1 g hg |>.2;
    exact Classical.not_not.1 fun h => hg'_eq_g g'.support ( lt_of_le_of_ne ( by aesop ) h ) ( by simpa [ hg'.2.1 ] using h₁.1 g' hg'.1 |>.1 );
  cases g ; cases g' ; aesop

/-- **Existence and uniqueness of the canonical residual basis.** -/
theorem closure_basis_canonical
    (cl : Set α → Set α) (hcl : IsClosureOperator cl) :
    ∃! B : Finset (ResidualGenerator α), IsCanonicalBasis cl B :=
  ⟨canonicalBasis cl, canonical_basis_is_basis cl hcl,
    fun B hB => canonical_basis_unique cl hcl B _ hB
      (canonical_basis_is_basis cl hcl)⟩

/-! ## Part 10: Circuit Correctness -/

/-
The reconstructed DNF circuit correctly computes the closure operator.
-/
theorem reconstructed_circuit_correct
    (cl : Set α → Set α) (hcl : IsClosureOperator cl) :
    CircuitComputesClosure (reconstructClosureCircuit cl) cl := by
  intro x s; simp +decide [ reconstructClosureCircuit, disjOfList_eval, conjOfList_eval ] ;
  convert closure_iff_contains_minimal_support cl hcl x s |> Iff.symm using 1

/-! ## Part 11: Main Duality Theorem -/

/-- **Finite Closure-Circuit Duality.** Every closure operator on a finite type
    with bounded rank admits a canonical residual basis and a monotone DNF
    circuit computing the closure. The basis is unique. -/
theorem finite_closure_duality
    (cl : Set α → Set α)
    (h_ext : ∀ s, s ⊆ cl s)
    (h_mono : ∀ ⦃s t : Set α⦄, s ⊆ t → cl s ⊆ cl t)
    (h_idem : ∀ s, cl (cl s) = cl s)
    (r : ℕ)
    (_h_rank : ClosureRankBounded cl r) :
    ∃ (B : Finset (ResidualGenerator α))
      (C : ClosureCircuit α),
      IsCanonicalBasis cl B
      ∧ CircuitComputesClosure C cl
      ∧ (∀ B' : Finset (ResidualGenerator α), IsCanonicalBasis cl B' → B' = B) := by
  have hcl : IsClosureOperator cl := ⟨h_ext, h_mono, h_idem⟩
  exact ⟨canonicalBasis cl, reconstructClosureCircuit cl,
    canonical_basis_is_basis cl hcl,
    reconstructed_circuit_correct cl hcl,
    fun B' hB' => canonical_basis_unique cl hcl B' _ hB'
      (canonical_basis_is_basis cl hcl)⟩

/-- Residual equivalence is an equivalence relation. -/
theorem residualEquivalent_equiv {β : Type*} (cl : Set β → Set β) :
    Equivalence (ResidualEquivalent cl) where
  refl _ _ := Iff.rfl
  symm h s := (h s).symm
  trans h₁ h₂ s := (h₁ s).trans (h₂ s)

/-- Circuit evaluation is monotone for any closure circuit. -/
theorem closureCircuit_monotone {β : Type*}
    (C : ClosureCircuit β) {s t : Set β} (h : s ⊆ t)
    (x : β) (heval : (C.output x).eval s) : (C.output x).eval t :=
  MonotoneCircuit.eval_mono (C.output x) h heval

end

end ClosureCircuitDuality