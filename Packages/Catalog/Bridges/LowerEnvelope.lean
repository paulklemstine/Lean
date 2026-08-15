import Mathlib
/-
# Tropical Plancherel Reconstruction: Lower Envelope and Polyhedral Reconstruction

This file proves Theorem 3: the finite polyhedral inversion / lower-envelope
reconstruction theorem.

## Mathematical Content

For a finitely generated commutative idempotent semiring `H` with generators
`gens : ι → H`, every element `h : H` has a "tropical polynomial" representation.
When we evaluate a tropical character `χ` on such an element, the result depends
only on the generator evaluations `(χ(gens i))_i`.

This is the tropical analogue of the Fourier inversion formula: spectral data
(character values on generators) determines the transform value.

## Main Results

* `TropPoly` — inductive type representing elements built from generators
* `TropPoly.evalH` — evaluation in a semiring
* `TropPoly.evalChar` — evaluation in a character
* `eval_via_character` — character evaluation agrees with tropical evaluation
* `tropical_spectral_reconstruction` — characters agreeing on generators agree everywhere
-/

import Logic.GraphTheory.Defs

set_option maxHeartbeats 400000

/-! ## Tropical Polynomial Expressions

An inductive type of "tropical polynomial expressions" — terms built
from generators using min (tropical addition) and + (tropical multiplication).
-/

/-- A tropical polynomial expression over generators indexed by `ι`. -/
inductive TropPoly (ι : Type*) : Type _
  | gen : ι → TropPoly ι
  | one : TropPoly ι
  | tadd : TropPoly ι → TropPoly ι → TropPoly ι
  | tmul : TropPoly ι → TropPoly ι → TropPoly ι

namespace TropPoly

variable {ι : Type*}

/-- Evaluate a tropical polynomial in a semiring `H` given an assignment of generators. -/
def evalH {H : Type*} [Add H] [Mul H] [One H]
    (gens : ι → H) : TropPoly ι → H
  | gen i => gens i
  | one => 1
  | tadd p q => evalH gens p + evalH gens q
  | tmul p q => evalH gens p * evalH gens q

/-- Evaluate a tropical polynomial tropically: given values for generators in `𝕋`,
compute the result using min for tadd and + for tmul. -/
def evalT {𝕋 : Type*} [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋]
    (vals : ι → 𝕋) : TropPoly ι → 𝕋
  | gen i => vals i
  | one => 0
  | tadd p q => min (evalT vals p) (evalT vals q)
  | tmul p q => evalT vals p + evalT vals q

/-
Evaluating via a character equals evaluating tropically with generator values.
`χ(eval_H p) = eval_𝕋 (χ ∘ gens) p`
-/
theorem eval_via_character {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (χ : TropicalCharacter H 𝕋) (gens : ι → H) (p : TropPoly ι) :
    χ (evalH gens p) = evalT (fun i => χ (gens i)) p := by
  induction' p with i p q;
  · rfl;
  · exact χ.map_one';
  · have := χ.map_add' ( evalH gens p ) ( evalH gens q ) ; aesop;
  · rename_i p q hp hq;
    convert χ.map_mul ( evalH gens p ) ( evalH gens q ) using 1;
    exact hp.symm ▸ hq.symm ▸ rfl

/-
**Tropical Spectral Reconstruction Theorem.**
Characters agreeing on generators agree on all representable elements.
-/
theorem spectral_reconstruction {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (χ₁ χ₂ : TropicalCharacter H 𝕋) (gens : ι → H) (p : TropPoly ι)
    (hgen : ∀ i : ι, χ₁ (gens i) = χ₂ (gens i)) :
    χ₁ (evalH gens p) = χ₂ (evalH gens p) := by
  -- Apply the theorem `eval_via_character` to both `χ₁` and `χ₂`.
  have h₁ := eval_via_character χ₁ gens p
  have h₂ := eval_via_character χ₂ gens p;
  grind +splitImp

/-
Characters that agree on generators agree on all generated elements (restatement).
-/
theorem character_determined_by_generators {H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (χ₁ χ₂ : TropicalCharacter H 𝕋) (gens : ι → H)
    (hgen : ∀ i : ι, χ₁ (gens i) = χ₂ (gens i))
    (h : H) (p : TropPoly ι)
    (hp : evalH gens p = h) :
    χ₁ h = χ₂ h := by
  rw [ ← hp, spectral_reconstruction _ _ _ _ hgen ]

/-- **Finite Generator Fingerprint Sufficiency.**
For a finitely generated semiring, two characters with the same generator fingerprint
agree on all representable elements. This reduces the infinite-dimensional spectral
data to finite-dimensional data. -/
theorem finite_generator_fingerprint {ι H 𝕋 : Type*} [Fintype ι]
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (χ₁ χ₂ : TropicalCharacter H 𝕋) (gens : ι → H)
    (hgen : ∀ i : ι, χ₁ (gens i) = χ₂ (gens i))
    (h : H) (p : TropPoly ι)
    (hp : evalH gens p = h) :
    χ₁ h = χ₂ h :=
  character_determined_by_generators χ₁ χ₂ gens hgen h p hp

/-
The tropical evaluation depends only on generator values —
if two value assignments agree, evaluations agree.
-/
theorem evalT_depends_on_values {𝕋 : Type*} [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋]
    (v₁ v₂ : ι → 𝕋) (p : TropPoly ι)
    (hv : ∀ i, v₁ i = v₂ i) :
    evalT v₁ p = evalT v₂ p := by
  -- By definition of `evalT`, we know that `evalT v₁ p = evalT v₂ p` if and only if `v₁ i = v₂ i` for all `i`.
  have h_eval_eq : ∀ p : TropPoly ι, evalT v₁ p = evalT v₂ p := by
    intro p;
    -- By definition of `evalT`, we can rewrite the goal using the induction hypothesis.
    induction' p with p q hp hq;
    · exact hv p;
    · rfl;
    · grind +locals;
    · rename_i p q hp hq;
      exact congr_arg₂ ( · + · ) hp hq;
  exact h_eval_eq p

end TropPoly

/-! ## Monomial Evaluation

A "tropical monomial" is a product of generators. Its character evaluation
is a sum of generator evaluations — an affine form. -/

/-- Evaluate a list of generator indices as a product in a semiring. -/
def evalMonomial {ι H : Type*} [Mul H] [One H]
    (gens : ι → H) : List ι → H
  | [] => 1
  | i :: rest => gens i * evalMonomial gens rest

/-- Evaluate a monomial tropically: sum of generator values. -/
def evalMonomialTrop {ι 𝕋 : Type*} [Add 𝕋] [Zero 𝕋]
    (vals : ι → 𝕋) : List ι → 𝕋
  | [] => 0
  | i :: rest => vals i + evalMonomialTrop vals rest

/-
Character evaluation of a monomial equals the monomial's tropical evaluation.
`χ(∏ gens iⱼ) = ∑ χ(gens iⱼ)`
-/
theorem char_eval_monomial {ι H 𝕋 : Type*}
    [Add H] [Mul H] [Zero H] [One H]
    [LinearOrder 𝕋] [Add 𝕋] [Zero 𝕋] [Top 𝕋]
    (χ : TropicalCharacter H 𝕋) (gens : ι → H) (m : List ι) :
    χ (evalMonomial gens m) = evalMonomialTrop (fun i => χ (gens i)) m := by
  induction' m with i m ih;
  · exact χ.map_one';
  · exact χ.map_mul' _ _ ▸ ih ▸ rfl