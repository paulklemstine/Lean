/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Semantic Entropy on the Boolean Lattice

This file introduces the **semantic entropy framework** for monotone Boolean functions.
The key objects are:

- `upSat f x`: the upward satisfying fiber — all `z ≥ x` with `f z = true`.
- `semanticMass f x`: the cardinality `|upSat f x|`.
- `semanticEntropy f x`: `log₂(semanticMass f x)`, measuring the logarithmic mass of
  the satisfying region above `x`.
- `entropyDrop f x y`: the decrease in semantic entropy from `x` to `y` when `x ≤ y`.

The central insight is that **monotone computation can only compress semantic entropy**:
moving upward in the Boolean cube shrinks the upward satisfying fiber, so entropy
decreases. This gives a one-way information flow law on the lattice.

## Main results in this file

- `upSat_antitone`: `x ≤ y → upSat f y ⊆ upSat f x` for monotone `f`.
- `semanticMass_antitone`: `x ≤ y → semanticMass f y ≤ semanticMass f x` for monotone `f`.
- `semanticEntropy_antitone`: `x ≤ y → semanticEntropy f y ≤ semanticEntropy f x`.
-/

import Mathlib

open Finset Real

noncomputable section

/-- Boolean vectors `Fin n → Bool` have decidable `≤` (pointwise order). -/
instance boolVecDecidableLE {n : ℕ} (x y : Fin n → Bool) : Decidable (x ≤ y) :=
  Fintype.decidableForallFintype

/-- The upward satisfying fiber: all points `z ≥ x` where `f z = true`. -/
def upSat {n : ℕ} (f : (Fin n → Bool) → Bool) (x : Fin n → Bool) :
    Finset (Fin n → Bool) :=
  Finset.univ.filter (fun z => x ≤ z ∧ f z = true)

/-- The semantic mass: cardinality of the upward satisfying fiber. -/
def semanticMass {n : ℕ} (f : (Fin n → Bool) → Bool) (x : Fin n → Bool) : ℕ :=
  (upSat f x).card

/-- The semantic entropy: `log₂` of the semantic mass.
When the mass is zero, this yields `log₂ 0`, which `Real.logb` maps to `0`. -/
def semanticEntropy {n : ℕ} (f : (Fin n → Bool) → Bool) (x : Fin n → Bool) : ℝ :=
  Real.logb 2 ((semanticMass f x : ℕ) : ℝ)

/-- The entropy drop from `x` to `y`: decrease in semantic entropy. -/
def entropyDrop {n : ℕ} (f : (Fin n → Bool) → Bool) (x y : Fin n → Bool) : ℝ :=
  semanticEntropy f x - semanticEntropy f y

/-- A `MonotoneEntropyProfile` bundles a monotone Boolean function with its
semantic entropy data, serving as a first-class invariant for monotone
complexity analysis. -/
structure MonotoneEntropyProfile (n : ℕ) where
  /-- The underlying Boolean function. -/
  f : (Fin n → Bool) → Bool
  /-- Proof that `f` is monotone with respect to pointwise order. -/
  mono : Monotone f
  /-- The semantic entropy function, which equals `log₂ |upSat f x|`. -/
  semEnt : (Fin n → Bool) → ℝ
  /-- Specification: `semEnt` agrees with the semantic entropy definition. -/
  semEnt_spec : ∀ x, semEnt x = semanticEntropy f x

/-- Construct a `MonotoneEntropyProfile` from a monotone function. -/
def MonotoneEntropyProfile.mk' {n : ℕ} (f : (Fin n → Bool) → Bool) (hf : Monotone f) :
    MonotoneEntropyProfile n :=
  { f := f
    mono := hf
    semEnt := semanticEntropy f
    semEnt_spec := fun _ => rfl }

/-! ## Theorem 1: Antitonicity of semantic entropy -/

/-
**Upward satisfying fiber is antitone**: for monotone `f`, if `x ≤ y`
then every point in `upSat f y` is also in `upSat f x`.

This is the combinatorial core: moving upward shrinks the set of witnesses above.
-/
theorem upSat_antitone {n : ℕ} {f : (Fin n → Bool) → Bool} (hf : Monotone f)
    {x y : Fin n → Bool} (hxy : x ≤ y) :
    upSat f y ⊆ upSat f x := by
  grind +locals

/-
**Semantic mass is antitone**: for monotone `f`, `x ≤ y` implies
`semanticMass f y ≤ semanticMass f x`.
-/
theorem semanticMass_antitone {n : ℕ} {f : (Fin n → Bool) → Bool} (hf : Monotone f)
    {x y : Fin n → Bool} (hxy : x ≤ y) :
    semanticMass f y ≤ semanticMass f x := by
  exact Finset.card_le_card ( upSat_antitone hf hxy )

/-
**Semantic entropy is antitone** (Theorem 1): for a monotone Boolean function `f`,
moving upward in the Boolean cube can only decrease semantic entropy.

This is the fundamental one-way information flow law: monotone computation
on the Boolean lattice induces an entropy contraction.
-/
theorem semanticEntropy_antitone {n : ℕ} {f : (Fin n → Bool) → Bool} (hf : Monotone f)
    {x y : Fin n → Bool} (hxy : x ≤ y) :
    semanticEntropy f y ≤ semanticEntropy f x := by
  by_cases h : ( semanticMass f y : ℝ ) = 0 <;> by_cases h' : ( semanticMass f x : ℝ ) = 0 <;> simp_all +decide [ Real.logb ];
  · unfold semanticEntropy; aesop;
  · exact le_trans ( Real.logb_nonpos ( by norm_num ) ( Nat.cast_nonneg _ ) ( by norm_cast; linarith ) ) ( Real.logb_nonneg ( by norm_num ) ( mod_cast Nat.one_le_iff_ne_zero.mpr h' ) );
  · exact absurd h' ( ne_of_gt ( lt_of_lt_of_le ( Nat.pos_of_ne_zero h ) ( semanticMass_antitone hf hxy ) ) );
  · exact div_le_div_of_nonneg_right ( Real.log_le_log ( by positivity ) ( mod_cast semanticMass_antitone hf hxy ) ) ( Real.log_nonneg ( by norm_num ) )

/-
The entropy drop is nonneg for monotone functions when `x ≤ y`.
-/
theorem entropyDrop_nonneg {n : ℕ} {f : (Fin n → Bool) → Bool} (hf : Monotone f)
    {x y : Fin n → Bool} (hxy : x ≤ y) :
    0 ≤ entropyDrop f x y := by
  exact sub_nonneg_of_le <| semanticEntropy_antitone hf hxy

end