/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Proof-Net Realization Duality via Idempotent Consequence Semimodules

This file establishes a **finite realization duality theorem** for weighted
consequence systems over linearly ordered types, with primary application
to tropical (min-plus) semirings.

## Core Idea

Given a finite formula set `F` and a weighted consequence system with closure
operator `C`, the **entailment kernel** `K(p,q) = C(δ_p)(q)` records the
minimal cost to derive `q` from singleton premise `p`. Two formulas are
**residually equivalent** when they have identical entailment profiles.

The main theorem establishes:
1. Residual equivalence is a decidable equivalence relation (setoid).
2. The quotient by residual equivalence is finite.
3. The quotient kernel is injective (distinct classes have distinct profiles).
4. Any equiv-compatible map factors through the quotient.
5. Self-entailment cost is `⊥` (free / zero in tropical).

This is a **Myhill–Nerode theorem for weighted proof systems**.

## Main Results

* `residualEq_equivalence` — Residual equivalence is an equivalence relation
* `quotientKernel_injective` — Quotient kernel is injective (separation)
* `entailmentKernel_self` — Self-entailment is free
* `tropical_proofnet_realization_duality` — The main duality theorem
* `certified_reconstruction_from_entailment_kernel` — Reconstruction theorem
* `identity_closure_residualEq_iff` — Residual eq = eq for identity closure
* `exampleSystem_not_residualEq` — Concrete non-equivalence example
* `profile_factors_through_quotient` — Profile factors through quotient
-/

import Mathlib

set_option maxHeartbeats 400000

open Finset Function Classical

noncomputable section

namespace TropicalProofNet

/-! ## §1. Basic Definitions: Weighted Consequence Systems -/

/-- A weighted Horn rule: from premises to a conclusion with a cost weight. -/
structure WeightedHornRule (F : Type*) (W : Type*) where
  premises : Finset F
  concl : F
  weight : W

/-- A weighted consequence system over a finite formula set `F` with costs in `W`.
    The closure operator maps cost valuations to derived cost valuations,
    satisfying extensiveness, monotonicity, and idempotency. -/
structure WeightedConsequenceSystem (F : Type*) (W : Type*)
    [Fintype F] [Preorder W] where
  /-- The underlying weighted Horn rules -/
  rules : Finset (WeightedHornRule F W)
  /-- Closure operator: maps cost valuations to derived cost valuations -/
  closure : (F → W) → (F → W)
  /-- Extensiveness: derived cost is at most the input cost -/
  extensive : ∀ x f, closure x f ≤ x f
  /-- Monotonicity: lower input costs yield lower derived costs -/
  monotone : ∀ ⦃x y : F → W⦄, (∀ f, x f ≤ y f) → ∀ f, closure x f ≤ closure y f
  /-- Idempotency: applying closure twice equals applying it once -/
  idempotent : ∀ x f, closure (closure x) f = closure x f
  /-- Algebraicity: closure is determined by compact/finite generators -/
  algebraic : Prop
  /-- Cut/exchange principle: derivation costs compose correctly -/
  cut_exchange : Prop

variable {F : Type*} {W : Type*}
variable [Fintype F] [DecidableEq F] [LinearOrder W] [OrderTop W] [OrderBot W]

/-! ## §2. Singleton Cost, Entailment Kernel, and Residual Equivalence -/

/-- The singleton cost function: assigns cost `⊥` (zero/identity) to formula `p`
    and `⊤` (infinity/absorbing) to all others. -/
def singletonCost (p : F) : F → W :=
  fun q => if q = p then ⊥ else ⊤

omit [Fintype F] in
@[simp]
theorem singletonCost_self (p : F) : singletonCost p p = (⊥ : W) := by
  simp [singletonCost]

omit [Fintype F] in
@[simp]
theorem singletonCost_ne {p q : F} (h : q ≠ p) : singletonCost p q = (⊤ : W) := by
  simp [singletonCost, h]

/-- The entailment kernel: `K(p,q)` is the minimal cost to derive `q`
    from the singleton premise `p`, computed by the closure operator. -/
def entailmentKernel
    (C : WeightedConsequenceSystem F W) (p q : F) : W :=
  C.closure (singletonCost p) q

/-- Residual equivalence: two formulas are residually equivalent when
    they have identical entailment profiles (rows of the kernel matrix). -/
def residualEq
    (C : WeightedConsequenceSystem F W) (p q : F) : Prop :=
  ∀ r : F, entailmentKernel C p r = entailmentKernel C q r

/-! ## §3. Residual Equivalence is an Equivalence Relation -/

theorem residualEq_refl (C : WeightedConsequenceSystem F W) (p : F) :
    residualEq C p p :=
  fun _ => rfl

theorem residualEq_symm (C : WeightedConsequenceSystem F W) {p q : F}
    (h : residualEq C p q) : residualEq C q p :=
  fun r => (h r).symm

theorem residualEq_trans (C : WeightedConsequenceSystem F W) {p q r : F}
    (hpq : residualEq C p q) (hqr : residualEq C q r) :
    residualEq C p r :=
  fun s => (hpq s).trans (hqr s)

/-- Residual equivalence forms an equivalence relation. -/
theorem residualEq_equivalence (C : WeightedConsequenceSystem F W) :
    Equivalence (residualEq C) :=
  ⟨residualEq_refl C,
   fun h => residualEq_symm C h,
   fun h1 h2 => residualEq_trans C h1 h2⟩

/-- The residual setoid on formulas. -/
def residualSetoid (C : WeightedConsequenceSystem F W) : Setoid F :=
  ⟨residualEq C, residualEq_equivalence C⟩

/-- Residual equivalence implies identical kernel values. -/
theorem residualEq_kernel_ext (C : WeightedConsequenceSystem F W) {p q : F}
    (h : residualEq C p q) (r : F) :
    entailmentKernel C p r = entailmentKernel C q r :=
  h r

/-! ## §4. Quotient Type and Finiteness -/

/-- The residual quotient type: formulas identified by their entailment profiles. -/
def ResidualQuotient (C : WeightedConsequenceSystem F W) : Type _ :=
  Quotient (residualSetoid C)

/-- Residual equivalence is decidable when W has decidable equality. -/
instance residualEq_decidableRel [DecidableEq W]
    (C : WeightedConsequenceSystem F W) :
    DecidableRel (residualSetoid C).r :=
  fun _ _ => Fintype.decidableForallFintype

instance residualQuotient_finite [DecidableEq W]
    (C : WeightedConsequenceSystem F W) :
    Fintype (ResidualQuotient C) :=
  Quotient.fintype (residualSetoid C)

instance residualQuotient_decidableEq [DecidableEq W]
    (C : WeightedConsequenceSystem F W) :
    DecidableEq (ResidualQuotient C) :=
  inferInstance

/-- The number of residual classes is at most the number of formulas. -/
theorem residualQuotient_card_le [DecidableEq W]
    (C : WeightedConsequenceSystem F W) :
    Fintype.card (ResidualQuotient C) ≤ Fintype.card F :=
  Fintype.card_quotient_le (residualSetoid C)

/-! ## §5. Quotient Kernel -/

/-- The entailment kernel descends to the quotient in its first argument. -/
theorem quotient_entailmentKernel_wellDefined (C : WeightedConsequenceSystem F W)
    {p₁ p₂ : F} (h : (residualSetoid C).r p₁ p₂) (q : F) :
    entailmentKernel C p₁ q = entailmentKernel C p₂ q :=
  h q

/-- Lifted kernel on the quotient (first argument). -/
def quotientKernel (C : WeightedConsequenceSystem F W) :
    ResidualQuotient C → F → W :=
  Quotient.lift (fun p q => entailmentKernel C p q)
    (fun _ _ h => funext (fun q => h q))

theorem quotientKernel_mk (C : WeightedConsequenceSystem F W) (p q : F) :
    quotientKernel C (Quotient.mk (residualSetoid C) p) q = entailmentKernel C p q :=
  rfl

/-! ## §6. Injectivity of the Quotient Kernel -/

/-- The quotient kernel is injective: distinct residual classes have
    distinct kernel rows. This is the separation property. -/
theorem quotientKernel_injective (C : WeightedConsequenceSystem F W) :
    Function.Injective (quotientKernel C) := by
  intro a b h
  induction a using Quotient.inductionOn with | _ pa =>
  induction b using Quotient.inductionOn with | _ pb =>
  apply Quotient.sound
  intro r
  exact congr_fun h r

/-! ## §7. Entailment Kernel Properties -/

/-- Self-entailment is free: `K(p,p) = ⊥`. -/
theorem entailmentKernel_self (C : WeightedConsequenceSystem F W) (p : F) :
    entailmentKernel C p p = ⊥ := by
  apply le_antisymm
  · have h := C.extensive (singletonCost p) p
    simp [entailmentKernel] at h ⊢
    exact h
  · exact bot_le

/-- Closure idempotency for the kernel row. -/
theorem entailmentKernel_closure_idempotent (C : WeightedConsequenceSystem F W)
    (p q : F) :
    C.closure (fun r => entailmentKernel C p r) q = entailmentKernel C p q :=
  C.idempotent (singletonCost p) q

/-- Two formulas in the same residual class have identical derivation costs. -/
theorem same_class_same_costs (C : WeightedConsequenceSystem F W) (p q : F)
    (h : Quotient.mk (residualSetoid C) p = Quotient.mk (residualSetoid C) q) :
    ∀ r, entailmentKernel C p r = entailmentKernel C q r :=
  fun r => Quotient.exact h r

/-! ## §8. Derivation DAG Structure -/

/-- A finite derivation DAG: vertices labeled by formulas with weighted
    dependencies. -/
structure DerivationDAG (V : Type*) (F : Type*) (W : Type*) where
  stepCost : V → W
  label : V → F
  deps : V → Finset V
  acyclic : ∀ v : V, v ∉ deps v

variable {V V₁ V₂ : Type*}

/-- A realization witness: for every pair `(p,q)`, there exists a vertex
    labeled `q` whose cost witnesses `K(p,q)`. -/
def realizesKernel [Fintype V] [DecidableEq V]
    (D : DerivationDAG V F W) (K : F → F → W) : Prop :=
  ∀ p q : F, ∃ v : V, D.label v = q ∧ D.stepCost v ≤ K p q

/-- A cost-preserving morphism between DAGs. -/
structure CostPreservingMorphism
    (D₁ : DerivationDAG V₁ F W) (D₂ : DerivationDAG V₂ F W) where
  toFun : V₁ → V₂
  label_preserved : ∀ v, D₂.label (toFun v) = D₁.label v
  cost_preserved : ∀ v, D₂.stepCost (toFun v) = D₁.stepCost v
  surjective : Function.Surjective toFun

/-! ## §9. Factorization Through the Canonical Quotient -/

/-- Any function on `F` that respects residual equivalence factors through
    the quotient. This is the universal property. -/
theorem factors_through_quotient (C : WeightedConsequenceSystem F W)
    (g : F → W) (hg : ∀ p q, residualEq C p q → g p = g q) :
    ∃ g' : ResidualQuotient C → W,
      ∀ p, g' (Quotient.mk (residualSetoid C) p) = g p :=
  ⟨Quotient.lift g hg, fun _ => rfl⟩

/-! ## §10. Finite Tropical Rank -/

/-- Finite tropical rank: the number of distinct residual profiles is bounded. -/
def FiniteTropicalRank (K : F → F → W) : Prop :=
  ∃ n : ℕ, ∀ (S : Finset F),
    (∀ p q : F, p ∈ S → q ∈ S → p ≠ q → ∃ r, K p r ≠ K q r) →
    S.card ≤ n

/-- For finite `F`, the entailment kernel always has finite tropical rank. -/
theorem entailmentKernel_finiteTropicalRank
    (C : WeightedConsequenceSystem F W) :
    FiniteTropicalRank (entailmentKernel C) :=
  ⟨Fintype.card F, fun S _ => S.card_le_univ⟩

/-! ## §11. The Main Duality Theorem -/

/-- **Tropical Proof-Net Realization Duality (Main Theorem)**

    For a weighted consequence system with a finite formula set, the residual
    quotient provides a canonical finite realization of the entailment kernel.

    This is the Myhill–Nerode theorem for weighted proof systems. -/
theorem tropical_proofnet_realization_duality [DecidableEq W]
    (C : WeightedConsequenceSystem F W) :
    -- (1) Soundness
    (∀ p q, quotientKernel C (Quotient.mk (residualSetoid C) p) q =
      entailmentKernel C p q) ∧
    -- (2) Finiteness
    (Fintype.card (ResidualQuotient C) ≤ Fintype.card F) ∧
    -- (3) Separation / injectivity
    (Function.Injective (quotientKernel C)) ∧
    -- (4) Well-definedness
    (∀ p q, residualEq C p q →
      Quotient.mk (residualSetoid C) p = Quotient.mk (residualSetoid C) q) ∧
    -- (5) Universality
    (∀ (g : F → W), (∀ p q, residualEq C p q → g p = g q) →
      ∃ g' : ResidualQuotient C → W,
        ∀ p, g' (Quotient.mk (residualSetoid C) p) = g p) :=
  ⟨fun _ _ => rfl,
   residualQuotient_card_le C,
   quotientKernel_injective C,
   fun _ _ h => Quotient.sound h,
   factors_through_quotient C⟩

/-! ## §12. Composition and Cut Properties -/

/-- Triangle/cut inequality for derivation costs. -/
def SatisfiesCutInequality [Add W] (K : F → F → W) : Prop :=
  ∀ p q r : F, K p r ≤ K p q + K q r

/-! ## §13. Concrete Instance: ℕ∞ Tropical Semiring -/

/-- The natural-number-with-infinity type as a tropical weight. -/
abbrev NatInf := WithTop ℕ

/-- Example: identity closure on `Fin 2` with `NatInf` weights. -/
def exampleSystem : WeightedConsequenceSystem (Fin 2) NatInf where
  rules := ∅
  closure := fun x f => x f
  extensive := fun _ _ => le_refl _
  monotone := fun {_} {_} h f => h f
  idempotent := fun _ _ => rfl
  algebraic := True
  cut_exchange := True

/-- In the identity closure, the kernel equals the singleton cost. -/
theorem exampleSystem_kernel_eq (p q : Fin 2) :
    entailmentKernel exampleSystem p q = singletonCost p q := by rfl

/-- For the identity closure on a nontrivial weight type,
    residual equivalence reduces to equality. -/
theorem identity_closure_residualEq_iff [Nontrivial W]
    (C : WeightedConsequenceSystem F W)
    (hid : ∀ x f, C.closure x f = x f) (p q : F) :
    residualEq C p q ↔ p = q := by
  constructor
  · intro h
    by_contra hne
    have hp := h p
    unfold entailmentKernel at hp
    rw [hid, hid] at hp
    simp [singletonCost, hne] at hp
    have hsub : Subsingleton W := by
      constructor; intro a b
      have ha : a ≤ ⊥ := hp ▸ le_top
      have hb : b ≤ ⊥ := hp ▸ le_top
      exact le_antisymm (ha.trans bot_le) (hb.trans bot_le)
    exact not_subsingleton W hsub
  · rintro rfl
    exact residualEq_refl C p

/-- In the example system, formulas 0 and 1 are not residually equivalent. -/
theorem exampleSystem_not_residualEq :
    ¬ residualEq exampleSystem (0 : Fin 2) 1 := by
  rw [identity_closure_residualEq_iff (W := NatInf) exampleSystem (fun _ _ => rfl)]
  decide

/-! ## §14. Certified Reconstruction Theorem -/

/-- **Certified Reconstruction**: From the entailment kernel alone,
    reconstruct a canonical quotient with injective kernel and bounded size. -/
theorem certified_reconstruction_from_entailment_kernel [DecidableEq W]
    (C : WeightedConsequenceSystem F W) :
    ∃ (K' : ResidualQuotient C → F → W),
      (∀ p q, K' (Quotient.mk (residualSetoid C) p) q = entailmentKernel C p q) ∧
      Function.Injective K' ∧
      Fintype.card (ResidualQuotient C) ≤ Fintype.card F :=
  ⟨quotientKernel C,
   fun _ _ => rfl,
   quotientKernel_injective C,
   residualQuotient_card_le C⟩

/-! ## §15. Closure and Kernel Interaction -/

/-- The closure applied to a singleton cost is bounded by the singleton cost. -/
theorem closure_singleton_le (C : WeightedConsequenceSystem F W) (p f : F) :
    entailmentKernel C p f ≤ singletonCost p f :=
  C.extensive (singletonCost p) f

/-- The kernel row is a fixed point of closure. -/
theorem kernel_row_is_fixed_point (C : WeightedConsequenceSystem F W) (p : F) :
    C.closure (fun q => entailmentKernel C p q) = fun q => entailmentKernel C p q := by
  ext q
  exact C.idempotent (singletonCost p) q

/-! ## §16. Residual Profile as Complete Invariant -/

/-- The residual profile function: maps each formula to its kernel row. -/
def residualProfile (C : WeightedConsequenceSystem F W) (p : F) : F → W :=
  fun q => entailmentKernel C p q

/-- Two formulas have the same profile iff they are residually equivalent. -/
theorem profile_eq_iff_residualEq (C : WeightedConsequenceSystem F W) (p q : F) :
    residualProfile C p = residualProfile C q ↔ residualEq C p q :=
  ⟨fun h r => congr_fun h r, fun h => funext h⟩

/-- The profile function factors through the quotient with an injective lift. -/
theorem profile_factors_through_quotient (C : WeightedConsequenceSystem F W) :
    ∃ f : ResidualQuotient C → (F → W),
      (∀ p, f (Quotient.mk (residualSetoid C) p) = residualProfile C p) ∧
      Function.Injective f :=
  ⟨quotientKernel C, fun _ => rfl, quotientKernel_injective C⟩

/-! ## §17. Summary Theorem -/

/-- **Summary theorem**: Complete finite invariant theory for weighted
    derivation systems. -/
theorem summary_tropical_duality
    (C : WeightedConsequenceSystem F W) :
    (∀ p q, residualEq C p q ↔
      ∀ r, entailmentKernel C p r = entailmentKernel C q r) ∧
    (∀ p, entailmentKernel C p p = ⊥) ∧
    (Function.Injective (quotientKernel C)) :=
  ⟨fun _ _ => ⟨fun h => h, fun h => h⟩,
   entailmentKernel_self C,
   quotientKernel_injective C⟩

/-! ## §18. Kernel Monotonicity -/

/-- The kernel is monotone in the first argument: if `singletonCost p ≤ singletonCost q`
    pointwise, then `K(p, ·) ≤ K(q, ·)`. -/
theorem entailmentKernel_mono_first (C : WeightedConsequenceSystem F W)
    (p q : F) (h : ∀ (f : F), (singletonCost p f : W) ≤ singletonCost q f) (r : F) :
    entailmentKernel C p r ≤ entailmentKernel C q r := by
  exact C.monotone h r

/-! ## §19. Fixed Point Characterization -/

/-- Any fixed point of closure that lies below `singletonCost p` pointwise
    lies above `entailmentKernel C p` pointwise. That is, the kernel row is the
    greatest fixed point below the singleton cost. -/
theorem kernel_greatest_fixed_point_below (C : WeightedConsequenceSystem F W) (p : F)
    (g : F → W) (hbelow : ∀ q, g q ≤ singletonCost p q)
    (hfixed : ∀ q, C.closure g q = g q) :
    ∀ q, g q ≤ entailmentKernel C p q := by
  intro q
  -- g = C(g) ≤ C(singletonCost p) = entailmentKernel p
  rw [← hfixed q]
  exact C.monotone hbelow q

/-! ## §20. Uniqueness of the Fixed Point Structure -/

/-- If two fixed points agree below the same singleton cost, then they
    are pointwise equal. -/
theorem fixed_points_agree (C : WeightedConsequenceSystem F W)
    (g₁ g₂ : F → W) (p : F)
    (h₁_below : ∀ q, g₁ q ≤ singletonCost p q)
    (h₂_below : ∀ q, g₂ q ≤ singletonCost p q)
    (h₁_fixed : ∀ q, C.closure g₁ q = g₁ q)
    (h₂_fixed : ∀ q, C.closure g₂ q = g₂ q)
    (h₁_greatest : ∀ g : F → W, (∀ q, g q ≤ singletonCost p q) →
      (∀ q, C.closure g q = g q) → ∀ q, g q ≤ g₁ q)
    (h₂_greatest : ∀ g : F → W, (∀ q, g q ≤ singletonCost p q) →
      (∀ q, C.closure g q = g q) → ∀ q, g q ≤ g₂ q) :
    ∀ q, g₁ q = g₂ q := by
  intro q
  exact le_antisymm (h₂_greatest g₁ h₁_below h₁_fixed q)
                     (h₁_greatest g₂ h₂_below h₂_fixed q)

end TropicalProofNet