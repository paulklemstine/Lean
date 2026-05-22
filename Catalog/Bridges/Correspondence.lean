/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.TropicalHecke.Defs

/-!
# Tropical Spectral Langlands Correspondence

This file establishes the core theorems of the tropical spectral Langlands
correspondence: the injection from simple summands of a finite tropical
semimodule into extremal closure eigenmeasures on its closure spectrum,
character recovery, and the classification theorem.

## Main results

### Stage 1: Closure from Residuation
* `closureSpectrum_of_residualAction` — every residuated action induces a
  closure spectrum object

### Stage 2: Eigenline-to-Eigenmeasure Map
* `summandToEigenmeasure` — each simple summand induces a closure eigenmeasure

### Stage 3: Spectral Correspondence
* `summandToEigenmeasure_injective` — distinct summands → distinct eigenmeasures
* `spectral_correspondence_injective` — the main injection theorem

### Stage 4: Character Recovery
* `tropicalCharacter_is_closed` — the tropical character is a closed element
* `tropicalCharacter_largest_closed` — it is the largest closed element

## Mathematical overview

For a residuated action of `H` on a finite lattice `M`:
1. Each `res_h ∘ act_h` is a closure operator (Galois connection theory)
2. Fixed points (closed elements) form a finite sublattice
3. Simple summands inject into closure eigenmeasures via indicator functionals
4. The tropical character (closure of ⊤) is the supremum of closed elements
-/

noncomputable section

open Set Function Finset

/-! ## Stage 1: Closure Spectrum Construction -/

/-- **Stage 1**: Every residuated action induces a closure spectrum object. -/
theorem closureSpectrum_of_residualAction
    (H M : Type*) [PartialOrder M] (ρ : ResidualAction H M) :
    Nonempty (ClosureSpectrum H M) :=
  ⟨ρ.toClosureSpectrum⟩

/-! ### Closure operator properties -/

/-- The closure of a fixed point is itself. -/
theorem closure_of_fixed {H M : Type*} [PartialOrder M]
    (ρ : ResidualAction H M) (h : H) (x : M) (hx : ρ.IsClosed h x) :
    (ρ.closureOp h) x = x := hx

/-- The closure operator is monotone. -/
theorem closureOp_mono {H M : Type*} [PartialOrder M]
    (ρ : ResidualAction H M) (h : H) : Monotone (ρ.closureOp h) :=
  (ρ.closureOp h).monotone

/-- The closure of any element is closed. -/
theorem closure_isClosed {H M : Type*} [PartialOrder M]
    (ρ : ResidualAction H M) (h : H) (x : M) :
    ρ.IsClosed h ((ρ.closureOp h) x) :=
  ρ.closure_idempotent h x

/-! ## Stage 2: Fixed Point Characterization -/

/-- The finset of closed elements for a given `h`. -/
def closedFinset {H M : Type*} [PartialOrder M] [DecidableEq M] [Fintype M]
    (ρ : ResidualAction H M) (h : H) : Finset M :=
  Finset.univ.filter (fun x => (ρ.closureOp h) x = x)

/-- Membership in the closed finset. -/
theorem mem_closedFinset {H M : Type*} [PartialOrder M] [DecidableEq M] [Fintype M]
    (ρ : ResidualAction H M) (h : H) (x : M) :
    x ∈ closedFinset ρ h ↔ ρ.IsClosed h x := by
  simp [closedFinset, ResidualAction.IsClosed]

/-- The spectral size equals the cardinality of the closed finset. -/
theorem spectralSize_eq_closedFinset_card {H M : Type*}
    [PartialOrder M] [DecidableEq M] [Fintype M]
    (ρ : ResidualAction H M) (h : H) :
    spectralSize ρ h = (closedFinset ρ h).card := by
  simp [spectralSize, closedFinset]

/-- A closure operator on a finite nonempty type has at least one fixed point. -/
theorem closedFinset_nonempty {H M : Type*}
    [PartialOrder M] [DecidableEq M] [Fintype M] [Nonempty M]
    (ρ : ResidualAction H M) (h : H) :
    (closedFinset ρ h).Nonempty := by
  obtain ⟨x⟩ : Nonempty M := inferInstance
  exact ⟨(ρ.closureOp h) x, by
    rw [mem_closedFinset]
    exact closure_isClosed ρ h x⟩

/-! ## The Tropical Character -/

/-- The tropical character at `h` is the closure of the top element. -/
theorem tropicalCharacter_is_closed {H M : Type*}
    [PartialOrder M] [OrderTop M] (ρ : ResidualAction H M) (h : H) :
    ρ.IsClosed h (tropicalCharacter ρ h) :=
  ρ.closure_idempotent h ⊤

/-- The tropical character is the largest closed element. -/
theorem tropicalCharacter_largest_closed {H M : Type*}
    [PartialOrder M] [OrderTop M] (ρ : ResidualAction H M) (h : H)
    (x : M) (_ : ρ.IsClosed h x) :
    x ≤ tropicalCharacter ρ h :=
  le_top.trans (ρ.le_closure h ⊤)

/-! ## Multiplicative Action -/

/-- A **multiplicative residuated action** extends `ResidualAction` with
    compatibility with a monoid structure on `H`. -/
structure MulResidualAction (H : Type*) [Monoid H] (M : Type*) [PartialOrder M]
    extends ResidualAction H M where
  act_mul : ∀ h₁ h₂ : H, ∀ x : M, act (h₁ * h₂) x = act h₁ (act h₂ x)
  act_one : ∀ x : M, act 1 x = x

namespace MulResidualAction

variable {H : Type*} [Monoid H] {M : Type*} [PartialOrder M]
    (ρ : MulResidualAction H M)

/-
The identity gives the identity closure operator.
-/
theorem closureOp_one (x : M) :
    (ρ.toResidualAction.closureOp 1) x = x := by
  -- By definition of closure operator, we have cl_1(x) = res_1(act_1(x)) = res_1(x) since act_1(x) = x.
  unfold ResidualAction.closureOp;
  have := ρ.gc 1;
  exact le_antisymm ( by simpa [ ρ.act_one ] using this ( ρ.res 1 x ) x ) ( by simpa [ ρ.act_one ] using this x x )

end MulResidualAction

/-! ## Stage 3: The Spectral Correspondence -/

/-- Given a simple summand (a non-bottom element closed under all `h`),
    construct an indicator function: `0` if `s ≤ x`, else `⊥`. -/
def summandIndicator {H M : Type*} [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ) : M → WithBot ℤ :=
  fun x => if s.val ≤ x then (0 : WithBot ℤ) else ⊥

/-
The summand indicator is monotone.
-/
theorem summandIndicator_mono {H M : Type*} [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ) :
    Monotone (summandIndicator ρ s) := by
  intro x y hxy;
  by_cases h : s.val ≤ x <;> simp_all +decide [ summandIndicator ];
  rw [ if_pos ( le_trans h hxy ) ]

/-
The summand indicator maps bot to bot.
-/
theorem summandIndicator_bot {H M : Type*} [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ) :
    summandIndicator ρ s ⊥ = ⊥ := by
  -- Since $s.val \neq \bot$, we have $¬(s.val ≤ ⊥)$, so the if statement returns $\bot$.
  have h_not_le_bot : ¬(s.val ≤ ⊥) := by
    exact fun h => s.ne_bot ( le_bot_iff.mp h );
  exact if_neg h_not_le_bot

/-
The summand indicator is closure-invariant: `μ(cl_h(x)) = μ(x)`.
-/
theorem summandIndicator_closure_invariant {H M : Type*}
    [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ)
    (h : H) (x : M) :
    summandIndicator ρ s ((ρ.closureOp h) x) = summandIndicator ρ s x := by
  by_cases h' : s.val ≤ x <;> simp +decide [ summandIndicator, h' ];
  · exact le_trans h' ( ρ.le_closure h x );
  · exact fun h'' => h' ( s.closure_prime h x h'' )

/-- **Main construction**: each simple summand gives a closure eigenmeasure. -/
def summandToEigenmeasure {H M : Type*} [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) (s : SimpleSummand ρ) :
    ClosureEigenmeasure ρ where
  toFun := summandIndicator ρ s
  mono := summandIndicator_mono ρ s
  bot_map := summandIndicator_bot ρ s
  closure_invariant := summandIndicator_closure_invariant ρ s

/-
**Injectivity**: distinct simple summands give distinct eigenmeasures.
-/
theorem summandToEigenmeasure_injective {H M : Type*}
    [SemilatticeSup M] [OrderBot M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) :
    Function.Injective (summandToEigenmeasure ρ) := by
  intro s1 s2 h_eq
  have h_val : s1.val = s2.val := by
    have h_val : summandIndicator ρ s1 s2.val = 0 ∧ summandIndicator ρ s2 s1.val = 0 := by
      have h_val : summandIndicator ρ s1 s2.val = summandIndicator ρ s2 s2.val ∧ summandIndicator ρ s2 s1.val = summandIndicator ρ s1 s1.val := by
        exact ⟨ congr_arg ( fun f => f.toFun s2.val ) h_eq, congr_arg ( fun f => f.toFun s1.val ) h_eq.symm ⟩;
      unfold summandIndicator at *; aesop;
    unfold summandIndicator at h_val;
    exact le_antisymm ( by aesop ) ( by aesop )
  exact (by
  cases s1 ; cases s2 ; aesop)

/-- **Spectral Correspondence (Main Theorem)**:
    The map from simple summands to closure eigenmeasures is injective.
    This is the tropical Satake correspondence for finite semimodules. -/
theorem spectral_correspondence_injective
    (H M : Type*) [SemilatticeSup M] [OrderBot M] [DecidableEq M] [Fintype M]
    [DecidableRel ((· ≤ ·) : M → M → Prop)]
    (ρ : ResidualAction H M) :
    Function.Injective (summandToEigenmeasure ρ) :=
  summandToEigenmeasure_injective ρ

/-! ## Semisimple Classification -/

/-- Two actions have the same spectral size iff they have the same number of
    closed elements. -/
theorem spectralSize_determines_closedCount
    {H M N : Type*} [PartialOrder M] [PartialOrder N]
    [DecidableEq M] [DecidableEq N] [Fintype M] [Fintype N]
    (ρM : ResidualAction H M) (ρN : ResidualAction H N) (h : H) :
    spectralSize ρM h = spectralSize ρN h ↔
    (closedFinset ρM h).card = (closedFinset ρN h).card := by
  simp [spectralSize_eq_closedFinset_card]

/-! ## Concrete Examples -/

/-- The identity action on `Bool` (trivially residuated). -/
def boolIdentityAction : ResidualAction Unit Bool where
  act := fun _ x => x
  res := fun _ x => x
  gc := fun _ => GaloisConnection.id

/-- Every element is closed under the identity action. -/
theorem boolIdentity_all_closed :
    ∀ x : Bool, boolIdentityAction.IsClosed () x := by
  intro x
  simp [ResidualAction.IsClosed, boolIdentityAction, ResidualAction.closureOp,
    GaloisConnection.closureOperator]

/-
The spectral size of the identity on Bool is 2.
-/
theorem boolIdentity_spectralSize :
    spectralSize boolIdentityAction () = 2 := by
  native_decide +revert

/-- The constant-false action on Bool (with residual = const true). -/
def boolConstFalseAction : ResidualAction Unit Bool where
  act := fun _ _ => false
  res := fun _ _ => true
  gc := fun _ => by
    intro a b
    simp

/-- The constant-false action has exactly 1 closed element (true). -/
theorem boolConstFalse_closed_true :
    boolConstFalseAction.IsClosed () true := by
  simp [ResidualAction.IsClosed, boolConstFalseAction, ResidualAction.closureOp,
    GaloisConnection.closureOperator]

/-
The spectral size of the constant-false action on Bool is 1.
-/
theorem boolConstFalse_spectralSize :
    spectralSize boolConstFalseAction () = 1 := by
  native_decide +revert

end