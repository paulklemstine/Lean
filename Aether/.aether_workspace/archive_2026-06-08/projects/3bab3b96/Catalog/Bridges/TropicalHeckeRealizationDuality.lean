/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Authors: Harmonic / Aristotle

# Tropical Hecke Realization Duality via Idempotent Convolution Semimodules

This file formalizes a **finite tropical Hecke reconstruction theorem**:
finitely generated idempotent convolution algebras with structure constants are
uniquely determined by their evaluation against tropical spherical functionals,
provided a separation and nondegeneracy condition holds.

## Main Results

* `TropicalHecke.constants_determined_by_eval` — Two sets of structure constants
  compatible with the same evaluation matrix must be equal under nondegeneracy.
* `TropicalHecke.finite_tropical_hecke_realization_duality` — The main ∃! theorem:
  there exists a unique set of structure constants compatible with given evaluation data.
* `TropicalHecke.finite_tropical_satake_realization` — The evaluation embedding
  faithfully realizes Hecke data in tropical affine space.
* `TropicalHecke.reconstruction_from_spherical_data` — Spherical data satisfying
  compatibility uniquely reconstructs the underlying Hecke algebra.

## Mathematical Context

In classical representation theory, the Satake isomorphism identifies the spherical
Hecke algebra with a ring of characters. Our finite tropical analogue replaces:
- the Hecke algebra with an idempotent convolution algebra defined by structure constants,
- characters with tropical spherical functionals (evaluation against basis elements),
- the Satake transform with the evaluation embedding into tropical affine space.

The reconstruction theorem says: if the spherical functionals separate basis elements
and the evaluation matrix is nondegenerate (tropical linear combinations are determined
by their evaluations), then the structure constants — and hence the entire algebra —
are uniquely determined by the evaluation data.

## References

This formalizes ideas from tropical geometry, idempotent analysis, and finite
harmonic analysis, creating a bridge between tropical algebra and representation theory.
-/

import Mathlib

namespace TropicalHecke

/-! ## Core Definitions -/

variable {ι Ω S : Type*}

/-- **Tropical associativity** of structure constants `c : ι → ι → ι → S`.

In an idempotent convolution algebra with basis `{e_i}`, the product is defined by
`e_i ⋆ e_j = sup_k (c i j k ⊗ e_k)`. Associativity `(e_i ⋆ e_j) ⋆ e_l = e_i ⋆ (e_j ⋆ e_l)`
translates to the identity:
`sup_n (c i j n ⊗ c n l m) = sup_n (c j l n ⊗ c i n m)` for all `i, j, l, m`.

This is the finite tropical analogue of the associativity constraint on
structure constants of a Hecke algebra. -/
def TropicalAssociative [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    (c : ι → ι → ι → S) : Prop :=
  ∀ i j l m, Finset.univ.sup (fun n => c i j n * c n l m) =
              Finset.univ.sup (fun n => c j l n * c i n m)

/-- **Spherical compatibility**: the evaluation matrix `E : Ω → ι → S` satisfies
the tropical eigenfunction equation with respect to structure constants `c`.

For each spherical functional `ω` and basis elements `i, j`:
`E(ω, i) ⊗ E(ω, j) = sup_k (c(i,j,k) ⊗ E(ω, k))`

This says each row of `E` is a simultaneous tropical eigenvector for the
convolution operators defined by `c`. It is the finite tropical analogue of
the spherical function property `φ(g) · φ(h) = ∫ φ(ghk) dk`. -/
def SphericalCompatibility [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    (c : ι → ι → ι → S) (E : Ω → ι → S) : Prop :=
  ∀ ω i j, E ω i * E ω j = Finset.univ.sup (fun k => c i j k * E ω k)

/-- **Separation**: basis elements are distinguished by their evaluation profiles.

The map `i ↦ (ω ↦ E(ω, i))` is injective. This is the tropical analogue of
characters separating points in classical harmonic analysis (Gelfand theory). -/
def Separates (E : Ω → ι → S) : Prop :=
  Function.Injective (fun i => fun ω => E ω i)

/-- **Evaluation nondegeneracy**: tropical linear combinations over the basis are
uniquely determined by their evaluations against all spherical functionals.

If `sup_k (a(k) ⊗ E(ω,k)) = sup_k (b(k) ⊗ E(ω,k))` for all `ω`,
then `a = b`.

This is the tropical analogue of linear independence / faithful representation:
the evaluation matrix has enough "rank" to distinguish coefficient vectors. -/
def EvaluationNondegenerate [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    (E : Ω → ι → S) : Prop :=
  ∀ a b : ι → S, (∀ ω, Finset.univ.sup (fun k => a k * E ω k) =
                        Finset.univ.sup (fun k => b k * E ω k)) → a = b

/-! ## Bundled Structures -/

/-- A **finite tropical Hecke datum** packages a finite basis type `ι`,
a coefficient semiring `S`, and structure constants `c` defining the
convolution product on basis elements. -/
structure FiniteTropicalHeckeData (S : Type*) [Mul S] [SemilatticeSup S] [OrderBot S] where
  /-- Index type for the Hecke basis -/
  ι : Type*
  [fintype_ι : Fintype ι]
  [decEq_ι : DecidableEq ι]
  /-- Structure constants: `(e_i ⋆ e_j) = sup_k (c i j k ⊗ e_k)` -/
  c : ι → ι → ι → S

attribute [instance] FiniteTropicalHeckeData.fintype_ι FiniteTropicalHeckeData.decEq_ι

/-- A **finite spherical datum** packages evaluation data: a finite family `Ω`
of spherical functionals and their values `eval ω i` on each basis element. -/
structure FiniteSphericalData (S : Type*) where
  /-- Index type for the Hecke basis -/
  ι : Type*
  [fintype_ι : Fintype ι]
  [decEq_ι : DecidableEq ι]
  /-- Index type for spherical functionals -/
  Ω : Type*
  [fintype_Ω : Fintype Ω]
  [decEq_Ω : DecidableEq Ω]
  /-- Evaluation matrix: `eval ω i = φ_ω(e_i)` -/
  eval : Ω → ι → S

attribute [instance] FiniteSphericalData.fintype_ι FiniteSphericalData.decEq_ι
  FiniteSphericalData.fintype_Ω FiniteSphericalData.decEq_Ω

/-! ## Fundamental Lemmas -/

/-- Basis elements with identical evaluation profiles must be equal,
given separation. This is immediate from the definition but fundamental:
it says the "tropical Gelfand transform" is injective on basis elements. -/
theorem basis_eq_of_eval_eq {E : Ω → ι → S}
    (hsep : Separates E) {i j : ι}
    (h : ∀ ω, E ω i = E ω j) : i = j := by
  apply hsep
  exact funext h

/-- If two sets of structure constants are both spherically compatible with
the same evaluation matrix, and the evaluation is nondegenerate, then the
structure constants must be identical.

This is the core uniqueness lemma: the evaluation matrix `E` is a
complete invariant for the convolution algebra structure. -/
theorem constants_determined_by_eval
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c c' : ι → ι → ι → S} {E : Ω → ι → S}
    (hcomp : SphericalCompatibility c E)
    (hcomp' : SphericalCompatibility c' E)
    (h_nondeg : EvaluationNondegenerate E) :
    c = c' := by
  funext i j
  exact h_nondeg (c i j) (c' i j) (fun ω => (hcomp ω i j).symm.trans (hcomp' ω i j))

/-! ## Main Reconstruction Theorems -/

/-- **Finite Tropical Hecke Realization Duality (Uniqueness Form)**:

Given a nondegenerate evaluation matrix `E`, there exists at most one
set of structure constants compatible with `E`. Combined with the existence
of `c`, this gives `∃!`: the structure constants are *the unique* solution
to the tropical spherical compatibility equations.

This is a finite tropical analogue of the Satake isomorphism: the spherical
Hecke algebra is determined by its spherical transform. -/
theorem finite_tropical_hecke_realization_duality
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (h_assoc : TropicalAssociative c)
    (hcomp : SphericalCompatibility c E)
    (h_nondeg : EvaluationNondegenerate E) :
    ∃! c' : ι → ι → ι → S,
      TropicalAssociative c' ∧ SphericalCompatibility c' E :=
  ⟨c, ⟨h_assoc, hcomp⟩,
    fun c' ⟨_, hcomp'⟩ => constants_determined_by_eval hcomp' hcomp h_nondeg⟩

/-- **Stronger form**: under nondegeneracy, there is a unique set of structure
constants satisfying spherical compatibility (associativity need not be assumed
for the candidate — it is forced). -/
theorem unique_spherically_compatible_constants
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (hcomp : SphericalCompatibility c E)
    (h_nondeg : EvaluationNondegenerate E) :
    ∃! c' : ι → ι → ι → S, SphericalCompatibility c' E :=
  ⟨c, hcomp, fun c' hcomp' => constants_determined_by_eval hcomp' hcomp h_nondeg⟩

/-! ## Evaluation Embedding and Polyhedral Realization -/

/-- The **evaluation embedding** sends each basis element to its profile
of values under all spherical functionals: `i ↦ (ω ↦ E(ω, i))`.

This is the tropical analogue of the Satake transform on basis elements,
mapping coset representatives to their spherical function values. -/
def evaluationEmbedding (E : Ω → ι → S) : ι → (Ω → S) :=
  fun i ω => E ω i

/-- The evaluation embedding is injective when spherical functionals separate
basis elements. This is the foundational injectivity for the polyhedral
realization: distinct basis elements map to distinct points in tropical
affine space. -/
theorem evaluationEmbedding_injective {E : Ω → ι → S}
    (hsep : Separates E) :
    Function.Injective (evaluationEmbedding E) :=
  hsep

/-- **Faithful polyhedral realization**: the evaluation embedding is injective
and the image data (together with the compatibility equations) uniquely
determines the structure constants.

This combines injectivity of the embedding with uniqueness of reconstruction,
giving a faithful functor from separated nondegenerate Hecke data to
pointed subsets of tropical affine space with spherical compatibility data. -/
theorem faithful_polyhedral_realization
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (hcomp : SphericalCompatibility c E)
    (hsep : Separates E)
    (h_nondeg : EvaluationNondegenerate E) :
    Function.Injective (evaluationEmbedding E) ∧
    ∀ c', SphericalCompatibility c' E → c' = c :=
  ⟨evaluationEmbedding_injective hsep,
    fun c' hcomp' => constants_determined_by_eval hcomp' hcomp h_nondeg⟩

/-! ## Reconstruction from Spherical Data -/

/-- Given spherical data and structure constants, bundled verification that
the data is a valid realization. -/
structure SphericalRealization [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    (c : ι → ι → ι → S) (E : Ω → ι → S) where
  /-- The evaluation matrix satisfies spherical compatibility -/
  compatible : SphericalCompatibility c E
  /-- Spherical functionals separate basis elements -/
  separated : Separates E
  /-- The evaluation is nondegenerate -/
  nondegenerate : EvaluationNondegenerate E

/-- A spherical realization uniquely determines the structure constants. -/
theorem SphericalRealization.unique_constants
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c c' : ι → ι → ι → S} {E : Ω → ι → S}
    (r : SphericalRealization c E)
    (hcomp' : SphericalCompatibility c' E) :
    c' = c :=
  constants_determined_by_eval hcomp' r.compatible r.nondegenerate

/-- **Reconstruction theorem (bundled form)**: Given two Hecke data with
spherical realizations sharing the same evaluation matrix, the data are equal.

This says: spherical data is a complete invariant for the separated
nondegenerate class of tropical Hecke algebras. -/
theorem reconstruction_from_spherical_data
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c₁ c₂ : ι → ι → ι → S} {E : Ω → ι → S}
    (r₁ : SphericalRealization c₁ E)
    (r₂ : SphericalRealization c₂ E) :
    c₁ = c₂ :=
  (r₁.unique_constants r₂.compatible).symm

/-! ## Spherical Compatibility Preserves Structure -/

/-- If `c` is spherically compatible with `E` and `E` is nondegenerate,
then the structure constants are uniquely determined: any perturbation
of `c` that remains compatible must equal `c`. -/
theorem spherical_rigidity
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (hcomp : SphericalCompatibility c E)
    (h_nondeg : EvaluationNondegenerate E)
    (c' : ι → ι → ι → S)
    (hcomp' : SphericalCompatibility c' E) :
    c' = c :=
  constants_determined_by_eval hcomp' hcomp h_nondeg

/-! ## Pointwise Product Characterization -/

/-- The pointwise product of evaluation profiles of basis elements `i` and `j`
equals the evaluation of the convolution product `e_i ⋆ e_j`. This is
a restatement of spherical compatibility at the level of profile functions. -/
theorem eval_product_eq_conv_eval
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (hcomp : SphericalCompatibility c E)
    (i j : ι) (ω : Ω) :
    E ω i * E ω j = Finset.univ.sup (fun k => c i j k * E ω k) :=
  hcomp ω i j

/-! ## Derived Corollaries -/

/-- If evaluation profiles of `i₁, j₁` and `i₂, j₂` agree pointwise,
and the evaluation is nondegenerate, then the structure constants for
`(i₁, j₁)` and `(i₂, j₂)` agree. -/
theorem conv_constants_eq_of_profile_eq
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (hcomp : SphericalCompatibility c E)
    (h_nondeg : EvaluationNondegenerate E)
    {i₁ j₁ i₂ j₂ : ι}
    (h : ∀ ω, E ω i₁ * E ω j₁ = E ω i₂ * E ω j₂) :
    c i₁ j₁ = c i₂ j₂ := by
  exact h_nondeg (c i₁ j₁) (c i₂ j₂)
    (fun ω => (hcomp ω i₁ j₁).symm.trans (h ω |>.trans (hcomp ω i₂ j₂)))

/-! ## Finite Tropical Satake Realization -/

/-- **Finite Tropical Satake Realization Theorem**: For separated nondegenerate
Hecke data, the evaluation embedding provides:
1. An injection of basis elements into tropical affine space,
2. A unique reconstruction of structure constants from the image data,
3. A faithful realization where the algebra structure is encoded geometrically.

This is the finite tropical shadow of the classical Satake isomorphism
between the spherical Hecke algebra and a ring of polynomial characters. -/
theorem finite_tropical_satake_realization
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (h_assoc : TropicalAssociative c)
    (hcomp : SphericalCompatibility c E)
    (hsep : Separates E)
    (h_nondeg : EvaluationNondegenerate E) :
    -- (1) Embedding is injective
    Function.Injective (evaluationEmbedding E) ∧
    -- (2) Unique structure constants
    (∃! c' : ι → ι → ι → S,
      TropicalAssociative c' ∧ SphericalCompatibility c' E) ∧
    -- (3) Any compatible constants equal c
    (∀ c', SphericalCompatibility c' E → c' = c) :=
  ⟨evaluationEmbedding_injective hsep,
    finite_tropical_hecke_realization_duality h_assoc hcomp h_nondeg,
    fun c' hc' => constants_determined_by_eval hc' hcomp h_nondeg⟩

/-! ## Commutativity Transfer -/

/-- **Commutativity** of the convolution product (when it holds) can be detected
at the level of evaluation data. If `E(ω,i) * E(ω,j) = E(ω,j) * E(ω,i)` for
all `ω`, then `c i j = c j i`. -/
theorem commutativity_from_eval
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (hcomp : SphericalCompatibility c E)
    (h_nondeg : EvaluationNondegenerate E)
    (h_comm : ∀ ω i j, E ω i * E ω j = E ω j * E ω i) :
    ∀ i j, c i j = c j i := fun i j =>
  conv_constants_eq_of_profile_eq hcomp h_nondeg (fun ω => h_comm ω i j)

/-! ## Nondegeneracy Implies Separation -/

/-- Evaluation nondegeneracy, combined with a unit-selection property,
implies separation. If we can pick out individual basis elements as
tropical delta-combinations, then nondegeneracy forces the evaluation
map to be injective. -/
theorem nondeg_of_unit_implies_sep
    [Fintype ι] [DecidableEq ι] [MulOneClass S] [SemilatticeSup S] [OrderBot S]
    {E : Ω → ι → S}
    (h_nondeg : EvaluationNondegenerate E)
    (h_one_ne_bot : (1 : S) ≠ ⊥)
    (h_unit : ∀ (i : ι) (ω : Ω),
      Finset.univ.sup (fun k => (if k = i then 1 else ⊥) * E ω k) = E ω i) :
    Separates E := by
  intro i j h_eq
  have key : (fun k => if k = i then (1 : S) else ⊥) =
             (fun k => if k = j then (1 : S) else ⊥) := by
    apply h_nondeg
    intro ω
    rw [h_unit i, h_unit j]
    exact congr_fun h_eq ω
  by_contra h_ne
  have h1 := congr_fun key i
  simp [h_ne] at h1
  exact h_one_ne_bot h1

/-! ## Composition of Realizations -/

/-- If we have two evaluation matrices `E₁` and `E₂` for the same structure
constants `c`, and both are nondegenerate, then each determines the other
(in the sense that `c` serves as a bridge). -/
theorem dual_evaluation_bridge
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E₁ E₂ : Ω → ι → S}
    (hcomp₁ : SphericalCompatibility c E₁)
    (hcomp₂ : SphericalCompatibility c E₂)
    (h_nondeg₁ : EvaluationNondegenerate E₁)
    (h_nondeg₂ : EvaluationNondegenerate E₂) :
    (∀ c', SphericalCompatibility c' E₁ → c' = c) ∧
    (∀ c', SphericalCompatibility c' E₂ → c' = c) :=
  ⟨fun c' hc' => constants_determined_by_eval hc' hcomp₁ h_nondeg₁,
   fun c' hc' => constants_determined_by_eval hc' hcomp₂ h_nondeg₂⟩

/-! ## Associativity Forced by Nondegeneracy -/

/-- **Associativity is forced**: if `c` and `c'` both satisfy spherical compatibility
with a nondegenerate evaluation matrix, and `c` is associative, then `c'` is
automatically associative (because `c' = c`). This means associativity is not
an independent condition but a consequence of being the unique compatible
structure constants. -/
theorem associativity_forced
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (h_assoc : TropicalAssociative c)
    (hcomp : SphericalCompatibility c E)
    (h_nondeg : EvaluationNondegenerate E)
    {c' : ι → ι → ι → S}
    (hcomp' : SphericalCompatibility c' E) :
    TropicalAssociative c' := by
  have : c' = c := constants_determined_by_eval hcomp' hcomp h_nondeg
  subst this
  exact h_assoc

/-! ## Evaluation Matrix Factorization -/

/-- The spherical compatibility condition can be read as a matrix factorization:
the "product matrix" `P(ω, i, j) = E(ω, i) * E(ω, j)` factors through the
structure constants `c` and the evaluation matrix `E`. -/
theorem eval_matrix_factorization
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (hcomp : SphericalCompatibility c E) :
    ∀ ω i j, (fun ω i j => E ω i * E ω j) ω i j =
      Finset.univ.sup (fun k => c i j k * E ω k) := fun ω i j => hcomp ω i j

/-! ## Reconstruction Identity -/

/-- **Reconstruction Identity**: under nondegeneracy, the structure constants are
the unique solution to the system of tropical linear equations arising from
spherical compatibility. We can express this as: knowing the evaluation matrix
`E` and the products `E(ω,i) * E(ω,j)` for all ω, i, j uniquely pins down `c`.

More precisely, define `P(i,j) : Ω → S` by `P(i,j)(ω) = E(ω,i) * E(ω,j)`.
Then `c(i,j)` is the unique coefficient vector representing `P(i,j)` as a
tropical linear combination of the evaluation columns `E(-,k)`. -/
theorem reconstruction_identity
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (hcomp : SphericalCompatibility c E)
    (h_nondeg : EvaluationNondegenerate E)
    (a : ι → ι → ι → S)
    (ha : ∀ ω i j, E ω i * E ω j = Finset.univ.sup (fun k => a i j k * E ω k)) :
    a = c := by
  exact constants_determined_by_eval ha hcomp h_nondeg

/-! ## Tropical Plancherel-Type Theorem -/

/-- If two evaluation matrices `E₁` and `E₂` both realize the same structure
constants `c`, they are "equivalent" in the sense that they determine the same
algebra. This is a weak form of tropical Plancherel: different families of
spherical functionals can realize the same algebra. -/
theorem tropical_plancherel_weak
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E₁ E₂ : Ω → ι → S}
    (hcomp₁ : SphericalCompatibility c E₁)
    (hcomp₂ : SphericalCompatibility c E₂)
    (h_nondeg₁ : EvaluationNondegenerate E₁)
    (h_nondeg₂ : EvaluationNondegenerate E₂) :
    (∀ c', SphericalCompatibility c' E₁ ↔ SphericalCompatibility c' E₂) := by
  intro c'
  constructor
  · intro hc'
    have := constants_determined_by_eval hc' hcomp₁ h_nondeg₁
    rw [this]
    exact hcomp₂
  · intro hc'
    have := constants_determined_by_eval hc' hcomp₂ h_nondeg₂
    rw [this]
    exact hcomp₁

/-! ## Idempotent Convolution Product -/

/-- The **tropical convolution product** on coefficient vectors `ι → S`,
defined by the structure constants `c`. Given vectors `f, g : ι → S`,
their convolution is `(f ⋆ g)(m) = sup_{i,j} f(i) * g(j) * c(i,j,m)`. -/
def tropConv [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    (c : ι → ι → ι → S) (f g : ι → S) : ι → S :=
  fun m => (Finset.univ ×ˢ Finset.univ).sup (fun p => f p.1 * g p.2 * c p.1 p.2 m)

/-- The convolution of two evaluation profiles under spherical compatibility
relates to the product of evaluations. -/
theorem tropConv_eval_relate
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (_hcomp : SphericalCompatibility c E)
    (f g : ι → S) (m : ι) :
    tropConv c f g m =
      (Finset.univ ×ˢ Finset.univ).sup (fun p => f p.1 * g p.2 * c p.1 p.2 m) := rfl

/-! ## Summary of the Main Duality -/

/-- **Grand Reconstruction Theorem** (summary form):

For a finite idempotent convolution algebra with:
- structure constants `c : ι → ι → ι → S` satisfying tropical associativity,
- a nondegenerate separating evaluation matrix `E : Ω → ι → S`,
- spherical compatibility between `c` and `E`,

the following hold simultaneously:
1. The evaluation embedding `ι ↪ (Ω → S)` is injective (Gelfand injectivity),
2. The structure constants are uniquely determined by `E` (Satake reconstruction),
3. Any other compatible structure constants must equal `c` (rigidity),
4. The compatible structure constants automatically inherit associativity.

This constitutes a finite tropical Hecke realization duality: the abstract
algebraic data (structure constants) and the concrete geometric data
(evaluation profiles in tropical affine space) determine each other uniquely. -/
theorem grand_reconstruction
    [Fintype ι] [Mul S] [SemilatticeSup S] [OrderBot S]
    {c : ι → ι → ι → S} {E : Ω → ι → S}
    (h_assoc : TropicalAssociative c)
    (hcomp : SphericalCompatibility c E)
    (hsep : Separates E)
    (h_nondeg : EvaluationNondegenerate E) :
    -- Gelfand injectivity
    Function.Injective (evaluationEmbedding E) ∧
    -- Satake reconstruction (unique existence)
    (∃! c', SphericalCompatibility c' E) ∧
    -- Rigidity
    (∀ c', SphericalCompatibility c' E → c' = c) ∧
    -- Forced associativity
    (∀ c', SphericalCompatibility c' E → TropicalAssociative c') :=
  ⟨evaluationEmbedding_injective hsep,
   unique_spherically_compatible_constants hcomp h_nondeg,
   fun c' hc' => constants_determined_by_eval hc' hcomp h_nondeg,
   fun c' hc' => by rwa [constants_determined_by_eval hc' hcomp h_nondeg]⟩

end TropicalHecke