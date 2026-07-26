/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic
-/
import Mathlib

/-!
# Symmetry quotients and the information content of rhythmic patterns

A binary musical pattern whose cells are identified by symmetry is constant on
symmetry classes. This file proves that such patterns are exactly Boolean
functions on the quotient. Consequently, if there are `m` symmetry classes,
there are exactly `2^m` admissible patterns.

The result is phrased for an arbitrary setoid. A group action, mirror
identifications, or a crystallographic orbit relation can each supply that
setoid. Thus the same theorem connects orbit spaces from symmetry theory with
binary information capacity in music and coding theory.
-/

namespace WallpaperRhythm

/-- Binary patterns on `α` which are constant on every equivalence class of `s`. -/
def InvariantPattern (α : Type*) (s : Setoid α) :=
  {f : α → Bool // ∀ a b, a ≈ b → f a = f b}

namespace InvariantPattern

variable {α : Type*} (s : Setoid α)

/-- Pull a Boolean labeling of the orbit space back to an invariant pattern. -/
noncomputable def quotientEquiv :
    (Quotient s → Bool) ≃ InvariantPattern α s where
  toFun f :=
    ⟨fun a => f (Quotient.mk s a), fun a b hab =>
      congrArg f (Quotient.sound hab)⟩
  invFun f := Quotient.lift f.1 (fun a b hab => f.2 a b hab)
  left_inv f := by
    funext q
    induction q using Quotient.inductionOn with
    | _ a => rfl
  right_inv f := by
    apply Subtype.ext
    funext a
    rfl

/-- An invariant pattern is uniquely determined by its values on the quotient. -/
theorem quotient_extension_unique (f g : InvariantPattern α s)
    (h : ∀ q : Quotient s,
      (quotientEquiv s).symm f q = (quotientEquiv s).symm g q) :
    f = g := by
  apply (quotientEquiv s).symm.injective
  funext q
  exact h q

noncomputable instance quotientFintype [Fintype α] : Fintype (Quotient s) :=
  Fintype.ofFinite (Quotient s)

noncomputable instance [Fintype α] : Fintype (InvariantPattern α s) := by
  classical
  exact Fintype.ofEquiv (Quotient s → Bool) (quotientEquiv s)

/-- **Symmetry--entropy counting theorem.**

For a finite cell set, if symmetry leaves `m` equivalence classes, then the
space of binary rhythmic patterns respecting that symmetry has cardinality
exactly `2^m`. Equivalently, its base-two information capacity is `m` bits.
-/
theorem card_eq_two_pow_quotient_card (s : Setoid α) [Fintype α] :
    Fintype.card (InvariantPattern α s) =
      2 ^ Fintype.card (Quotient s) := by
  classical
  letI : Fintype (Quotient s) := Fintype.ofFinite (Quotient s)
  rw [Fintype.card_congr (quotientEquiv s).symm]
  simp

/-- Identifying more cells cannot increase the number of independent binary
choices, expressed abstractly by an injection between the quotient spaces. -/
theorem card_mono_of_quotient_injection
    (t : Setoid α) [Fintype α]
    (e : Quotient t ↪ Quotient s) :
    Fintype.card (InvariantPattern α t) ≤
      Fintype.card (InvariantPattern α s) := by
  classical
  rw [card_eq_two_pow_quotient_card t, card_eq_two_pow_quotient_card s]
  exact Nat.pow_le_pow_right (by omega) (Fintype.card_le_of_embedding e)

end InvariantPattern

/-! ## A concrete musical consequence -/

/-- The indiscrete relation models maximal symmetry: every cell lies in one
orbit, so every invariant rhythm is constant. -/
def maximalSymmetrySetoid (α : Type*) : Setoid α where
  r _ _ := True
  iseqv := by
    constructor <;> simp_all

/-- On any nonempty finite grid, maximal symmetry permits exactly two binary
patterns: complete silence and an onset in every cell. -/
theorem maximal_symmetry_has_two_patterns
    (α : Type*) [Fintype α] [Nonempty α] :
    Fintype.card (InvariantPattern α (maximalSymmetrySetoid α)) = 2 := by
  classical
  rw [InvariantPattern.card_eq_two_pow_quotient_card (maximalSymmetrySetoid α)]
  have hcard : Fintype.card (Quotient (maximalSymmetrySetoid α)) = 1 := by
    apply Fintype.card_eq_one_iff.mpr
    let a : α := Classical.choice inferInstance
    refine ⟨Quotient.mk _ a, ?_⟩
    intro q
    induction q using Quotient.inductionOn with
    | _ b => exact Quotient.sound trivial
  rw [hcard]
  norm_num

end WallpaperRhythm