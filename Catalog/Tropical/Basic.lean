/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# GL₃ Tropical Satake: Core Definitions

This file establishes the foundational types and operations for the GL₃ tropical
Satake finite-determinacy theory.

## Overview

For GL₃, a **dominant coweight** is a triple `(a, b, c) ∈ ℕ³` with `a ≥ b ≥ c`.
The **dominant box** `BoxDom(B)` is the finite set of dominant coweights with `a ≤ B`.

We define three families of **tropical Satake observables**, corresponding to the
three fundamental representations `ω₁, ω₂, ω₃` of GL₃:

1. **Rank-1 profile** (`rank1Profile`): tropical convolution with the standard
   representation character. Uses the weights `e₁, e₂, e₃`.
2. **Rank-2 profile** (`rank2Profile`): tropical convolution with the exterior square
   character. Uses the weights `e₁+e₂, e₁+e₃, e₂+e₃`.
3. **Edge moment** (`edgeMoment`): tropical convolution with the determinant character
   `ω₃ = (1,1,1)`. This is the key reconstruction tool: as a shift operator, it
   recovers function values without the information loss inherent in max operations.

The finite-determinacy theorem (proved in `FiniteDeterminacy.lean`) shows that
equality of these observables on finite test sets forces equality of the underlying
functions.
-/

open Finset

/-! ### Dominance and support conditions -/

/-- A triple `(a, b, c)` is dominant if `a ≥ b ≥ c`. -/
def IsDominant (a b c : ℕ) : Prop := b ≤ a ∧ c ≤ b

/-- A function on `ℕ³` has finite support within box `B` if it vanishes outside
    the dominant box `{(a,b,c) : b ≤ a, c ≤ b, a ≤ B}`. -/
def FiniteSupportWithin (B : ℕ) (f : ℕ → ℕ → ℕ → ℤ) : Prop :=
  ∀ a b c : ℕ, (B < a ∨ a < b ∨ b < c) → f a b c = 0

/-- The box `BoxDom(B)` as a `Finset` of triples. -/
def boxDomFinset (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (Finset.range (B + 1) ×ˢ Finset.range (B + 1) ×ˢ Finset.range (B + 1)).filter
    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b

lemma mem_boxDomFinset {B : ℕ} {a b c : ℕ} :
    (a, b, c) ∈ boxDomFinset B ↔ a ≤ B ∧ b ≤ a ∧ c ≤ b := by
  simp [boxDomFinset, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
  omega

/-! ### Tropical Satake observables -/

/-- **Rank-1 profile**: tropical convolution with the standard representation `ω₁`.

The weights of the standard representation of GL₃ are `e₁ = (1,0,0)`,
`e₂ = (0,1,0)`, `e₃ = (0,0,1)`. The rank-1 profile at `(a,b,c)` is
`max{f(a-1,b,c), f(a,b-1,c), f(a,b,c-1)}` with appropriate guards for ℕ subtraction.

Note: Invalid shifts (where subtraction would go below 0) contribute the value `0`,
which serves as the tropical "zero" in this ℤ-valued model. -/
def rank1Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
  let v1 := if 1 ≤ a then f (a - 1) b c else 0
  let v2 := if 1 ≤ b then f a (b - 1) c else 0
  let v3 := if 1 ≤ c then f a b (c - 1) else 0
  max v1 (max v2 v3)

/-- **Rank-2 profile**: tropical convolution with the exterior square `ω₂ = ∧²`.

The weights of `∧²(ℂ³)` are `e₁+e₂ = (1,1,0)`, `e₁+e₃ = (1,0,1)`,
`e₂+e₃ = (0,1,1)`. The rank-2 profile at `(a,b,c)` is
`max{f(a-1,b-1,c), f(a-1,b,c-1), f(a,b-1,c-1)}`. -/
def rank2Profile (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
  let v1 := if 1 ≤ a ∧ 1 ≤ b then f (a - 1) (b - 1) c else 0
  let v2 := if 1 ≤ a ∧ 1 ≤ c then f (a - 1) b (c - 1) else 0
  let v3 := if 1 ≤ b ∧ 1 ≤ c then f a (b - 1) (c - 1) else 0
  max v1 (max v2 v3)

/-- **Edge moment**: tropical convolution with the determinant character `ω₃ = (1,1,1)`.

This is the shift operator: `edgeMoment f (a,b,c) = f(a-1, b-1, c-1)`.
As a representation-theoretic operation, it corresponds to convolution with the
one-dimensional determinant representation `det = ∧³(ℂ³)`. Unlike the rank-1 and
rank-2 profiles (which use `max` and can lose information), the determinant
convolution perfectly preserves all function values.

This is the key observable that makes finite determinacy possible: it acts as an
exact reconstruction tool rather than a lossy tropical projection. -/
def edgeMoment (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) : ℤ :=
  if 1 ≤ a ∧ 1 ≤ b ∧ 1 ≤ c then f (a - 1) (b - 1) (c - 1) else 0

/-- Combined triple convolution observable using both rank-1 and rank-2 generators.
    This packages rank-1 and rank-2 data together for the combined hypothesis form. -/
def tripleConvObservable (f : ℕ → ℕ → ℕ → ℤ) (t s : ℕ × ℕ × ℕ) : ℤ :=
  rank1Profile f t.1 t.2.1 t.2.2 + rank2Profile f s.1 s.2.1 s.2.2

/-! ### Finite test ranges -/

/-- The finite range of rank-1 test parameters determined by box bound `B`. -/
def finiteRank1Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b

/-- The finite range of rank-2 test parameters determined by box bound `B`. -/
def finiteRank2Range (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
    fun ⟨a, b, c⟩ => b ≤ a ∧ c ≤ b

/-- The finite range of edge moment test parameters determined by box bound `B`.
    These are the shifted dominant coweights `(a+1, b+1, c+1)` for `(a,b,c) ∈ BoxDom(B)`. -/
def finiteEdgeMomentRange (B : ℕ) : Finset (ℕ × ℕ × ℕ) :=
  (Finset.range (B + 2) ×ˢ Finset.range (B + 2) ×ˢ Finset.range (B + 2)).filter
    fun ⟨a, b, c⟩ => 1 ≤ c ∧ c ≤ b ∧ b ≤ a

/-! ### Key computation lemmas -/

/-- The edge moment at a shifted point exactly recovers the function value.
    This is the fundamental reconstruction identity. -/
@[simp]
lemma edgeMoment_succ (f : ℕ → ℕ → ℕ → ℤ) (a b c : ℕ) :
    edgeMoment f (a + 1) (b + 1) (c + 1) = f a b c := by
  simp [edgeMoment]

/-- Shifted dominant coweights lie in the edge moment range. -/
lemma shifted_mem_finiteEdgeMomentRange {B a b c : ℕ}
    (haB : a ≤ B) (hab : b ≤ a) (hbc : c ≤ b) :
    (a + 1, b + 1, c + 1) ∈ finiteEdgeMomentRange B := by
  simp [finiteEdgeMomentRange, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
  omega

/-- The rank-2 profile at the floor level `(a+1, b+1, 0)` yields `max(f(a,b,0), 0)`.
    When `f` is nonneg-valued on the floor, this equals `f(a,b,0)`.
    The `c = 0` case is special because both `ω₂`-weight shifts involving `c-1`
    fall outside `ℕ`, leaving only the `(1,1,0)`-weight shift. -/
lemma rank2Profile_floor_level (f : ℕ → ℕ → ℕ → ℤ) (a b : ℕ) :
    rank2Profile f (a + 1) (b + 1) 0 = max (f a b 0) 0 := by
  simp [rank2Profile]

/-- For functions supported in `BoxDom(B)`, values at `a > B` vanish. -/
lemma FiniteSupportWithin.vanish_above {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
    (hf : FiniteSupportWithin B f) {a : ℕ} (ha : B < a) (b c : ℕ) :
    f a b c = 0 := by
  exact hf a b c (Or.inl ha)

/-- For functions supported in `BoxDom(B)`, values outside dominant cone vanish. -/
lemma FiniteSupportWithin.vanish_nondominant {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
    (hf : FiniteSupportWithin B f) {a b c : ℕ} (h : a < b ∨ b < c) :
    f a b c = 0 := by
  exact hf a b c (by tauto)

/-- Bounded-support functions vanish outside the box: explicit formulation. -/
lemma bounded_support_implies_vanishing_outside {B : ℕ} {f : ℕ → ℕ → ℕ → ℤ}
    (hf : FiniteSupportWithin B f) {a b c : ℕ}
    (h : ¬(a ≤ B ∧ b ≤ a ∧ c ≤ b)) :
    f a b c = 0 := by
  apply hf; push_neg at h; omega