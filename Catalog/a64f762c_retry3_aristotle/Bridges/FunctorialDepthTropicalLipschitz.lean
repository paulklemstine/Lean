/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Max-Plus Depth ↔ Multiplicative Shadow Bridge

A *max-plus depth system* packages a composition operation together with a
`Nat`-valued depth that satisfies the tropical (additive) inequality

  `depth (comp f g) ≤ max (depth f) (depth g) + 1`.

Exponentiating the depth with a base `b ≥ 1` turns this additive `max`-bound into
a *multiplicative* Lipschitz-style estimate

  `shadow b (comp f g) ≤ b * max (shadow b f) (shadow b g)`,

and the estimate remains stable under iteration:

  `shadow b (iter n f) ≤ b ^ n * shadow b f`.

The construction is purely elementary `Nat` arithmetic.  The final section adapts
the valuation-depth composition law from `Computation/PadicValuationDepth` to
provide a concrete instance on function endomorphisms.
-/

import Mathlib
import Computation.PadicValuationDepth

/-- A `MaxPlusDepthSystem` bundles a composition law on `α` together with a
`Nat`-valued depth obeying the tropical (max-plus) composition inequality. -/
structure MaxPlusDepthSystem (α : Type*) where
  comp : α → α → α
  depth : α → Nat
  depth_comp_le : ∀ f g, depth (comp f g) ≤ max (depth f) (depth g) + 1

namespace MaxPlusDepthSystem

variable {α : Type*}

/-- The multiplicative *shadow* of `f` at base `b`: exponentiate the depth. -/
def shadow (S : MaxPlusDepthSystem α) (b : Nat) (f : α) : Nat := b ^ S.depth f

/-- Iterated self-composition: `iter (n+1) f = comp (iter n f) f`. -/
def iter (S : MaxPlusDepthSystem α) : Nat → α → α
  | 0, f => f
  | n + 1, f => S.comp (iter S n f) f

@[simp]
theorem iter_succ (S : MaxPlusDepthSystem α) (n : Nat) (f : α) :
    S.iter (n + 1) f = S.comp (S.iter n f) f := rfl

/-! ### Elementary `Nat` arithmetic support -/

/-- Exponent monotonicity for a fixed base `b ≥ 1` (thin wrapper around
`Nat.pow_le_pow_right`). -/
theorem pow_le_pow_of_le {b m n : Nat} (hb : 1 ≤ b) (h : m ≤ n) :
    b ^ m ≤ b ^ n := Nat.pow_le_pow_right hb h

/-- For a base `b ≥ 1`, exponentiation commutes with `max`. -/
theorem pow_max_eq_max_pow (b m n : Nat) (hb : 1 ≤ b) :
    b ^ (max m n) = max (b ^ m) (b ^ n) := by
  rcases le_total m n with h | h
  · rw [max_eq_right h, max_eq_right (Nat.pow_le_pow_right hb h)]
  · rw [max_eq_left h, max_eq_left (Nat.pow_le_pow_right hb h)]

/-! ### The multiplicative bridge -/

/-- **Bridge theorem.**  The additive tropical bound on `depth` becomes a
multiplicative Lipschitz-style bound on `shadow`. -/
theorem shadow_comp_le (S : MaxPlusDepthSystem α) (b : Nat) (f g : α) (hb : 1 ≤ b) :
    S.shadow b (S.comp f g) ≤ b * max (S.shadow b f) (S.shadow b g) := by
  unfold shadow
  calc
    b ^ S.depth (S.comp f g)
        ≤ b ^ (max (S.depth f) (S.depth g) + 1) :=
          Nat.pow_le_pow_right hb (S.depth_comp_le f g)
    _ = b * b ^ (max (S.depth f) (S.depth g)) := by rw [pow_succ]; ring
    _ = b * max (b ^ S.depth f) (b ^ S.depth g) := by
          rw [pow_max_eq_max_pow _ _ _ hb]

/-! ### Stability under iteration -/

/-- The depth of the `n`-fold iterate grows at most linearly in `n`. -/
theorem depth_iter_succ_le (S : MaxPlusDepthSystem α) (n : Nat) (f : α) :
    S.depth (S.iter n f) ≤ S.depth f + n := by
  induction n with
  | zero => simp [iter]
  | succ k ih =>
      rw [iter_succ]
      have hc := S.depth_comp_le (S.iter k f) f
      have hmax : max (S.depth (S.iter k f)) (S.depth f) ≤ S.depth f + k :=
        max_le ih (by omega)
      omega

/-- The multiplicative iterate bound: the shadow of the `n`-fold iterate grows at
most like `b ^ n`. -/
theorem shadow_iter_le (S : MaxPlusDepthSystem α) (b n : Nat) (f : α) (hb : 1 ≤ b) :
    S.shadow b (S.iter n f) ≤ b ^ n * S.shadow b f := by
  unfold shadow
  calc
    b ^ S.depth (S.iter n f)
        ≤ b ^ (S.depth f + n) := Nat.pow_le_pow_right hb (S.depth_iter_succ_le n f)
    _ = b ^ n * b ^ S.depth f := by rw [pow_add]; ring

/-! ### Adapter from the valuation-depth catalog -/

/-- Build a `MaxPlusDepthSystem` on the endomorphisms `α → α` from the
ultrametric composition law of `Computation/PadicValuationDepth`: composition is
ordinary function composition and depth is the valuation depth `vdepth`. -/
def ofUltrametricCompositionLaw (α : Type*) [Semiring α] [UltrametricCompositionLaw α] :
    MaxPlusDepthSystem (α → α) where
  comp f g := f ∘ g
  depth := ValuationDepthMeasure.vdepth
  depth_comp_le := UltrametricCompositionLaw.vdepth_comp

/-- Instantiated bridge for valuation depth under ordinary function composition. -/
theorem shadow_comp_le_valuation (α : Type*) [Semiring α] [UltrametricCompositionLaw α]
    (b : Nat) (f g : α → α) (hb : 1 ≤ b) :
    (ofUltrametricCompositionLaw α).shadow b (f ∘ g) ≤
      b * max ((ofUltrametricCompositionLaw α).shadow b f)
              ((ofUltrametricCompositionLaw α).shadow b g) :=
  (ofUltrametricCompositionLaw α).shadow_comp_le b f g hb

end MaxPlusDepthSystem