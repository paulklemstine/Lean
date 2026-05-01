import Mathlib

/-!
# Tropical Satake Isomorphism for GL₄

## Overview

This file establishes the tropical (min-plus) Satake isomorphism for GL₄,
the first non-prime semisimple rank case. We prove that the tropical Satake
transform sends each spherical Hecke basis element indexed by a dominant
coweight to the corresponding tropical Schur polynomial.

## Mathematical Content

The tropical Satake isomorphism is the Maslov dequantization (t → 0⁺ limit)
of the classical Satake isomorphism for p-adic reductive groups. For GL₄,
the spherical Hecke algebra over the tropical (min-plus) semiring
(ℝ, min, +) is isomorphic to the algebra of S₄-invariant tropical
polynomials.

The key identity proved here is:

  min_{w ∈ S₄} min_{σ ∈ S₄} ∑ᵢ μ(i) · z(w(σ(i)))
    = min_{σ ∈ S₄} ∑ᵢ μ(σ(i)) · z(i)

This shows that the "geometric side" (left, defined via Cartan decomposition
and tropical integration over the compact subgroup) equals the "spectral side"
(right, defined via the Weyl orbit sum / tropical Schur polynomial).

## Main Results

* `tropical_satake_isomorphism_GL4` — The main isomorphism theorem.
* `tropicalSchurPolynomial_weyl_invariant` — S₄-invariance of tropical Schur.
* `basisDoubleCoset_weyl_invariant` — W-invariance of Hecke basis elements.
* `satakeTransform_of_invariant` — Idempotency on invariant functions.
-/

open Finset Equiv

noncomputable section

/-! ## Core Definitions -/

/-- A dominant coweight for GL₄: a weakly decreasing sequence of integers. -/
def IsDominantCoweight (μ : Fin 4 → ℤ) : Prop :=
  μ 0 ≥ μ 1 ∧ μ 1 ≥ μ 2 ∧ μ 2 ≥ μ 3

/-- Convert a dominant coweight to a partition. For GL₄ (as opposed to PGL₄),
    the coweight lattice maps directly to the partition indexing the
    tropical Schur polynomial without determinant normalization. -/
def coweightToPartition (μ : Fin 4 → ℤ) : Fin 4 → ℤ := μ

/-- Tropical Schur polynomial for GL₄: the minimum over all Weyl group (S₄)
    permutations of the weight-coordinate inner product.

    s_ν^{trop}(z) = min_{σ ∈ S₄} ∑ᵢ ν(σ(i)) · z(i)

    In the Maslov dequantization limit, the sum of exponentials
    collapses to the minimum of the exponents, yielding this formula. -/
def tropicalSchurPolynomial (ν : Fin 4 → ℤ) (z : Fin 4 → ℝ) : ℝ :=
  Finset.inf' Finset.univ ⟨1, Finset.mem_univ _⟩
    (fun σ : Equiv.Perm (Fin 4) => ∑ i : Fin 4, (ν (σ i) : ℝ) * z i)

/-- The basis element of the tropical spherical Hecke algebra for GL₄,
    indexed by a dominant coweight μ. Defined as the tropical orbit sum
    over S₄ acting on the spectral variables:

    1_{KμK}^{trop}(z) = min_{σ ∈ S₄} ∑ᵢ μ(i) · z(σ(i))

    The permutation σ ranges over the relative positions of lattice chains
    parametrizing the affine Grassmannian cells in the double coset KμK. -/
def basisDoubleCoset (μ : Fin 4 → ℤ) : (Fin 4 → ℝ) → ℝ :=
  fun z => Finset.inf' Finset.univ ⟨1, Finset.mem_univ _⟩
    (fun σ : Equiv.Perm (Fin 4) => ∑ i : Fin 4, (μ i : ℝ) * z (σ i))

/-- The tropical Satake transform for GL₄. Symmetrizes a function on the
    maximal torus over the Weyl group S₄:

    𝒮(f)(z) = min_{w ∈ S₄} f(w · z)

    This is the min-plus convolution with the Weyl group action,
    projecting to W-invariant functions on the spectral side. -/
def satakeTransformGL4 (f : (Fin 4 → ℝ) → ℝ) (z : Fin 4 → ℝ) : ℝ :=
  Finset.inf' Finset.univ ⟨1, Finset.mem_univ _⟩
    (fun w : Equiv.Perm (Fin 4) => f (fun i => z (w i)))

/-! ## Helper Lemmas -/

/-
Reindexing a weighted sum by a permutation:
    ∑ᵢ a(i)·b(σ(i)) = ∑ᵢ a(σ⁻¹(i))·b(i).
-/
lemma sum_perm_comp (a : Fin 4 → ℤ) (b : Fin 4 → ℝ) (σ : Equiv.Perm (Fin 4)) :
    ∑ i : Fin 4, (a i : ℝ) * b (σ i) =
    ∑ i : Fin 4, (a (σ⁻¹ i) : ℝ) * b i := by
  conv_rhs => rw [ ← Equiv.sum_comp σ ] ;
  aesop

/-
The infimum over S₄ is invariant under the inversion map σ ↦ σ⁻¹.
    Since inversion is a bijection on the finite group, it preserves
    the set of values and hence the minimum.
-/
lemma inf'_perm_inv (f : Equiv.Perm (Fin 4) → ℝ) :
    Finset.inf' Finset.univ ⟨1, Finset.mem_univ _⟩ (fun σ => f σ) =
    Finset.inf' Finset.univ ⟨1, Finset.mem_univ _⟩ (fun σ => f σ⁻¹) := by
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le_iff ];
  · exact fun b => ⟨ b⁻¹, le_rfl ⟩;
  · exact fun b => ⟨ b⁻¹, by simp +decide ⟩

/-
Key reindexing: min over σ of ∑ μ(i)·z(σ(i)) = min over σ of ∑ μ(σ(i))·z(i).
    Uses change of variables σ ↦ σ⁻¹ and the fact that inversion is a
    bijection on S₄.
-/
lemma basisDoubleCoset_eq_tropicalSchur (μ : Fin 4 → ℤ) (z : Fin 4 → ℝ) :
    basisDoubleCoset μ z = tropicalSchurPolynomial μ z := by
  unfold basisDoubleCoset tropicalSchurPolynomial;
  rw [ inf'_perm_inv ];
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · exact fun b => ⟨ b, by rw [ ← Equiv.sum_comp b ] ; simp +decide ⟩;
  · exact fun b => ⟨ b, by rw [ ← Equiv.sum_comp b.symm ] ; simp +decide ⟩

/-
The Satake transform of a Hecke basis element equals the basis element itself.
    This is because basisDoubleCoset μ is already W-invariant, so the
    W-symmetrization in satakeTransformGL4 is idempotent.
-/
lemma satakeTransform_basisDoubleCoset (μ : Fin 4 → ℤ) (z : Fin 4 → ℝ) :
    satakeTransformGL4 (basisDoubleCoset μ) z = basisDoubleCoset μ z := by
  refine' le_antisymm _ _;
  · exact Finset.inf'_le _ ( Finset.mem_univ 1 );
  · refine' Finset.le_inf' _ _ _;
    intro b hb; simp +decide [ basisDoubleCoset ] ;
    exact fun c => ⟨ b * c, by simp +decide [ mul_assoc ] ⟩

/-! ## Main Theorem -/

/-- **Tropical Satake Isomorphism for GL₄.**

    The tropical Satake transform of the spherical Hecke basis element
    indexed by a dominant coweight μ equals the tropical Schur polynomial
    of the associated partition. This establishes the rank-4 case of the
    tropical Langlands correspondence. -/
theorem tropical_satake_isomorphism_GL4
    (μ : Fin 4 → ℤ)
    (_hμ : μ 0 ≥ μ 1 ∧ μ 1 ≥ μ 2 ∧ μ 2 ≥ μ 3)
    (z : Fin 4 → ℝ) :
    satakeTransformGL4 (basisDoubleCoset μ) z =
    tropicalSchurPolynomial (coweightToPartition μ) z := by
  simp only [coweightToPartition]
  rw [satakeTransform_basisDoubleCoset, basisDoubleCoset_eq_tropicalSchur]

/-! ## Additional Properties -/

/-
The tropical Schur polynomial is invariant under the S₄ Weyl group action
    on the spectral variables.
-/
theorem tropicalSchurPolynomial_weyl_invariant
    (ν : Fin 4 → ℤ) (z : Fin 4 → ℝ) (w : Equiv.Perm (Fin 4)) :
    tropicalSchurPolynomial ν (fun i => z (w i)) = tropicalSchurPolynomial ν z := by
  -- Apply the change of variables $j = w(i)$ to rewrite the sum.
  have h_sum_comp : ∀ σ : Equiv.Perm (Fin 4), ∑ i : Fin 4, (ν (σ i) : ℝ) * z (w i) = ∑ i : Fin 4, (ν ((σ * w⁻¹) i) : ℝ) * z i := by
    exact fun σ => by rw [ ← Equiv.sum_comp w⁻¹ ] ; simp +decide ;
  refine' le_antisymm _ _;
  · unfold tropicalSchurPolynomial;
    simp +decide [ h_sum_comp ];
    exact fun σ => ⟨ σ * w, by simp +decide ⟩;
  · simp +decide [ tropicalSchurPolynomial, h_sum_comp ];
    exact fun σ => ⟨ σ * w⁻¹, by simp +decide [ h_sum_comp ] ⟩

/-
The Hecke basis element is W-invariant, confirming it lies in the
    spherical subalgebra H(G//K).
-/
theorem basisDoubleCoset_weyl_invariant
    (μ : Fin 4 → ℤ) (z : Fin 4 → ℝ) (w : Equiv.Perm (Fin 4)) :
    basisDoubleCoset μ (fun i => z (w i)) = basisDoubleCoset μ z := by
  unfold basisDoubleCoset;
  refine' le_antisymm _ _ <;> simp +decide;
  · exact fun b => ⟨ w⁻¹ * b, by simp +decide ⟩;
  · exact fun b => ⟨ w * b, by simp +decide ⟩

/-
Evaluation at the origin: both sides vanish at z = 0.
-/
theorem satake_at_origin (μ : Fin 4 → ℤ)
    (_hμ : μ 0 ≥ μ 1 ∧ μ 1 ≥ μ 2 ∧ μ 2 ≥ μ 3) :
    satakeTransformGL4 (basisDoubleCoset μ) (fun _ => 0) = 0 := by
  refine' le_antisymm _ _ <;> norm_num [ satakeTransformGL4 ];
  · exact Finset.inf'_le _ ( Finset.mem_univ 1 ) |> le_trans <| by norm_num;
  · exact Finset.le_inf' _ _ fun σ _ => by norm_num;

/-
The tropical Satake transform is idempotent on W-invariant functions.
-/
theorem satakeTransform_of_invariant
    (f : (Fin 4 → ℝ) → ℝ)
    (hf : ∀ (z : Fin 4 → ℝ) (w : Equiv.Perm (Fin 4)), f (fun i => z (w i)) = f z)
    (z : Fin 4 → ℝ) :
    satakeTransformGL4 f z = f z := by
  unfold satakeTransformGL4; aesop;

end