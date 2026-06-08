/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Fourier Analysis on Finite Abelian Groups — Definitions

This file develops the foundational definitions for Fourier analysis on finite
abelian groups, grounded in representation theory. The central abstraction is
`FiniteCharacterBasis`: a complete system of orthogonal multiplicative characters
that serves as the canonical spectral basis.

## Main definitions

* `FiniteCharacterBasis G` — A complete orthogonal system of characters on a
  finite commutative group `G`, axiomatizing the key properties needed for
  Fourier analysis.
* `fourierTransform` — The Fourier transform of a function `f : G → ℂ` with
  respect to a character basis.
* `fourierInverse` — The inverse Fourier transform.
* `convolution` — Convolution of two functions on a finite group.
* `finSupportCard` — The cardinality of the support of a function.

## References

* Terras, *Fourier Analysis on Finite Groups and Applications*
* Donoho–Stark, *Uncertainty principles and signal recovery*
-/

import Mathlib

open Finset Complex BigOperators

noncomputable section

/-- A `FiniteCharacterBasis` on a finite commutative group `G` is a complete
system of orthogonal multiplicative characters `χ : ι → G → ℂ`, indexed by
a type `ι` of the same cardinality as `G`.

This structure axiomatizes:
- **multiplicativity**: each `χ i` is a group homomorphism to `ℂˣ`,
- **orthogonality**: characters are orthogonal (summing over group elements),
- **dual orthogonality**: characters are orthogonal (summing over character index),
- **completeness**: the number of characters equals `|G|`.

The dual orthogonality is a consequence of orthogonality + completeness for
actual character groups, but we include it as an axiom for convenience. -/
structure FiniteCharacterBasis (G : Type*) [Fintype G] [CommGroup G] [DecidableEq G] where
  /-- The index type for the characters. -/
  ι : Type*
  /-- The index type is a `Fintype`. -/
  fintype_ι : Fintype ι
  /-- Decidable equality on ι. -/
  deceq_ι : DecidableEq ι
  /-- The characters themselves: multiplicative maps `G → ℂ`. -/
  χ : ι → G → ℂ
  /-- Each character maps the identity to 1. -/
  map_one : ∀ i, χ i 1 = 1
  /-- Each character is multiplicative. -/
  map_mul : ∀ i x y, χ i (x * y) = χ i x * χ i y
  /-- Characters are orthogonal with respect to the natural inner product
  (summing over group elements). -/
  orthogonal :
    ∀ i j, ∑ g : G, χ i g * starRingEnd ℂ (χ j g) =
      if i = j then (Fintype.card G : ℂ) else 0
  /-- The character system is complete: |ι| = |G|. -/
  complete : Fintype.card ι = Fintype.card G
  /-- Dual orthogonality: summing over characters yields a delta on group
  elements. For actual character groups this follows from the other axioms
  by a linear algebra argument. -/
  dual_orthogonal :
    ∀ g h, ∑ i, χ i g * starRingEnd ℂ (χ i h) =
      if g = h then (Fintype.card G : ℂ) else 0

attribute [instance] FiniteCharacterBasis.fintype_ι FiniteCharacterBasis.deceq_ι

namespace FiniteCharacterBasis

variable {G : Type*} [Fintype G] [CommGroup G] [DecidableEq G]  -- DecidableEq already in structure
variable (B : FiniteCharacterBasis G)

/-- The Fourier transform of `f : G → ℂ` with respect to a character basis `B`.
This sends `f` to the function `f̂ : B.ι → ℂ` defined by
  `f̂(i) = ∑_{g ∈ G} f(g) * conj(χ_i(g))`. -/
def fourierTransform (f : G → ℂ) : B.ι → ℂ :=
  fun i => ∑ g : G, f g * starRingEnd ℂ (B.χ i g)

/-- The inverse Fourier transform, recovering `f` from its Fourier coefficients.
  `f(g) = (1/|G|) * ∑_i f̂(i) * χ_i(g)`. -/
def fourierInverse (F : B.ι → ℂ) : G → ℂ :=
  fun g => (1 / (Fintype.card G : ℂ)) * ∑ i : B.ι, F i * B.χ i g

/-- Convolution of two functions on a finite group. -/
def convolution (_ : FiniteCharacterBasis G) (f h : G → ℂ) : G → ℂ :=
  fun x => ∑ y : G, f y * h (y⁻¹ * x)

/-- The cardinality of the support of a function. -/
def finSupportCard {α : Type*} [Fintype α] {β : Type*} [Zero β]
    [DecidableEq β] (f : α → β) : ℕ :=
  Fintype.card {x : α // f x ≠ 0}

/-- The spectral support cardinality: the number of nonzero Fourier coefficients. -/
def spectralSupportCard (f : G → ℂ) : ℕ :=
  finSupportCard (B.fourierTransform f)

/-
Basic lemmas about characters

Each character is a map to the roots of unity, hence has unit norm.
We derive this from multiplicativity and finiteness of the group.
-/
lemma χ_pow (i : B.ι) (g : G) (n : ℕ) :
    B.χ i (g ^ n) = (B.χ i g) ^ n := by
      induction' n with n ih;
      · simp +decide [ B.map_one ];
      · rw [ pow_succ', B.map_mul, ih, pow_succ ];
        ring

/-
A character maps inverses to conjugates.
-/
lemma χ_inv (i : B.ι) (g : G) :
    B.χ i g⁻¹ = starRingEnd ℂ (B.χ i g) := by
      -- Since $g^{|G|} = 1$, we have $\chi(g^{|G|}) = \chi(1) = 1$.
      have h_char_pow : B.χ i (g ^ Fintype.card G) = 1 := by
        simp +decide [ pow_card_eq_one ];
        exact B.map_one i;
      -- Since $g$ has finite order, there exists some $k$ such that $g^k = 1$. Hence, $\chi(g)^k = \chi(1) = 1$, implying $|\chi(g)| = 1$.
      have h_char_norm : ‖B.χ i g‖ = 1 := by
        -- Since $g^{|G|} = 1$, we have $\chi(g)^{|G|} = 1$.
        have h_char_pow_eq : (B.χ i g) ^ Fintype.card G = 1 := by
          rw [ ← h_char_pow, B.χ_pow ];
        simpa [ pow_eq_one_iff_of_nonneg ] using congr_arg Norm.norm h_char_pow_eq;
      -- Since $g$ has finite order, there exists some $k$ such that $g^k = 1$. Hence, $\chi(g)^k = \chi(1) = 1$, implying $|\chi(g)| = 1$. Therefore, $\chi(g)$ is a root of unity.
      have h_char_root : B.χ i g⁻¹ = (B.χ i g)⁻¹ := by
        exact eq_inv_of_mul_eq_one_right ( by rw [ ← B.map_mul ] ; aesop );
      simp_all +decide [ Complex.inv_def, Complex.normSq_eq_norm_sq ]

/-
Characters have unit norm: `|χ_i(g)|² = 1` for all `i, g`.
-/
lemma χ_norm_one (i : B.ι) (g : G) :
    Complex.normSq (B.χ i g) = 1 := by
      -- By definition of exponentiation, we know that $(B.χ i g)^{Fintype.card G} = B.χ i (g^{Fintype.card G})$.
      have h_exp : (B.χ i g) ^ Fintype.card G = B.χ i (g ^ Fintype.card G) := by
        rw [ B.χ_pow ];
      norm_num [ Complex.normSq_eq_norm_sq, B.map_one ] at *;
      exact Or.inl ( by have := congr_arg Norm.norm h_exp; norm_num at this; rw [ pow_eq_one_iff_of_nonneg ] at this <;> aesop )

/-
Character values are nonzero.
-/
lemma χ_ne_zero (i : B.ι) (g : G) :
    B.χ i g ≠ 0 := by
      intro h_zero
      have h_contra : 1 = B.χ i 1 := by
        rw [ B.map_one ];
      have h_contra : B.χ i (g * g⁻¹) = B.χ i g * B.χ i g⁻¹ := by
        exact B.map_mul i g g⁻¹;
      aesop

/-- The conjugate of a character value equals its value at the inverse. -/
lemma conj_χ_eq_inv (i : B.ι) (g : G) :
    starRingEnd ℂ (B.χ i g) = B.χ i g⁻¹ :=
  (B.χ_inv i g).symm

end FiniteCharacterBasis

end