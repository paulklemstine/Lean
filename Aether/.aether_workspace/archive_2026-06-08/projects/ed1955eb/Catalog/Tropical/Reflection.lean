/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Reflection Theorems and Decision Procedure

This file packages the soundness of `cnormalize_ca` into reflection theorems
that serve as the kernel certificates for a `tropical` tactic.

## Main results

- `cnormalize_ca_eq_implies_semantic_eq`: equal normal forms ⟹ semantic equality
- `prove_tropical_eq_by_norm`: decidable tactic kernel (uses `decide`)
- `ACEquiv.sound`: semantic soundness of AC equivalence

## How the reflection pipeline works

To prove `⊢ t₁ = t₂` where `t₁, t₂` are tropical expressions over `min` and `+`:
1. Reify both sides into `CTropExpr` values `e₁, e₂`
2. Apply `prove_tropical_eq_by_norm e₁ e₂ (by native_decide) σ`
   where `σ` maps variable indices to the actual ℝ values

The `native_decide` call runs the normalizer at compile time and checks
that the results are syntactically identical.
-/

import Tropical.Soundness

open CTropExpr

/-! ## Core Reflection Theorems -/

/-- **Reflection theorem**: if two expressions have equal normal forms,
they evaluate to the same value under every variable assignment. -/
theorem cnormalize_ca_eq_implies_semantic_eq
    (e₁ e₂ : CTropExpr) (h : cnormalize_ca e₁ = cnormalize_ca e₂) :
    ∀ σ : ℕ → ℝ, eval σ e₁ = eval σ e₂ := by
  intro σ
  calc eval σ e₁ = eval σ (cnormalize_ca e₁) := (cnormalize_ca_sound σ e₁).symm
    _ = eval σ (cnormalize_ca e₂) := by rw [h]
    _ = eval σ e₂ := cnormalize_ca_sound σ e₂

/-- **Decidable reflection theorem**: the `decide` version for automation. -/
theorem cnormalize_ca_decide_sound
    (e₁ e₂ : CTropExpr) (h : decide (cnormalize_ca e₁ = cnormalize_ca e₂) = true) :
    ∀ σ : ℕ → ℝ, eval σ e₁ = eval σ e₂ :=
  cnormalize_ca_eq_implies_semantic_eq e₁ e₂ (of_decide_eq_true h)

/-- **Tactic kernel certificate**: this is the theorem that a `tropical` tactic
applies behind the scenes. The `native_decide` or `decide` call verifies
syntactic equality of the normalized forms at elaboration time. -/
theorem prove_tropical_eq_by_norm
    (e₁ e₂ : CTropExpr)
    (h : decide (cnormalize_ca e₁ = cnormalize_ca e₂) = true) :
    ∀ σ : ℕ → ℝ, eval σ e₁ = eval σ e₂ :=
  cnormalize_ca_decide_sound e₁ e₂ h

/-! ## AC Equivalence Relation -/

/-- The AC congruence on tropical expressions: the smallest congruence
containing commutativity, associativity, and idempotence of `min`,
and commutativity and associativity of `+`. -/
inductive ACEquiv : CTropExpr → CTropExpr → Prop
  | refl  : ∀ e, ACEquiv e e
  | symm  : ∀ {e₁ e₂}, ACEquiv e₁ e₂ → ACEquiv e₂ e₁
  | trans : ∀ {e₁ e₂ e₃}, ACEquiv e₁ e₂ → ACEquiv e₂ e₃ → ACEquiv e₁ e₃
  | tmin_comm  : ∀ e₁ e₂, ACEquiv (.tmin e₁ e₂) (.tmin e₂ e₁)
  | tmin_assoc : ∀ e₁ e₂ e₃,
      ACEquiv (.tmin (.tmin e₁ e₂) e₃) (.tmin e₁ (.tmin e₂ e₃))
  | add_comm  : ∀ e₁ e₂, ACEquiv (.add e₁ e₂) (.add e₂ e₁)
  | add_assoc : ∀ e₁ e₂ e₃,
      ACEquiv (.add (.add e₁ e₂) e₃) (.add e₁ (.add e₂ e₃))
  | cong_tmin : ∀ {a a' b b'}, ACEquiv a a' → ACEquiv b b' →
      ACEquiv (.tmin a b) (.tmin a' b')
  | cong_add  : ∀ {a a' b b'}, ACEquiv a a' → ACEquiv b b' →
      ACEquiv (.add a b) (.add a' b')
  | tmin_idem : ∀ e, ACEquiv (.tmin e e) e

/-- **Semantic soundness of ACEquiv**: AC-equivalent expressions evaluate equally
under any variable assignment. -/
theorem ACEquiv.sound {e₁ e₂ : CTropExpr} (h : ACEquiv e₁ e₂) :
    ∀ σ : ℕ → ℝ, eval σ e₁ = eval σ e₂ := by
  intro σ
  induction h with
  | refl _ => rfl
  | symm _ ih => exact ih.symm
  | trans _ _ ih₁ ih₂ => exact ih₁.trans ih₂
  | tmin_comm a b => exact min_comm (eval σ a) (eval σ b)
  | tmin_assoc a b c => exact min_assoc (eval σ a) (eval σ b) (eval σ c)
  | add_comm a b => show eval σ a + eval σ b = eval σ b + eval σ a; ring
  | add_assoc a b c => show eval σ a + eval σ b + eval σ c = eval σ a + (eval σ b + eval σ c); ring
  | cong_tmin _ _ ih₁ ih₂ => simp only [eval]; rw [ih₁, ih₂]
  | cong_add _ _ ih₁ ih₂ => simp only [eval]; rw [ih₁, ih₂]
  | tmin_idem e => exact min_self (eval σ e)