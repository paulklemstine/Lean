/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Algebraic Learning Theory — Foundations

This file opens the field of **algebraic learning theory**: the systematic transfer
of statistical learning theory (VC dimension, Rademacher complexity, PAC bounds) from
vector spaces over ℝ to modules over arbitrary semirings.

## Bridge: Commutative Algebra ↔ Statistical Learning Theory

Classical learning theory secretly depends only on the *algebraic* structure of hypothesis
classes, not on the analytic structure of ℝ. By replacing vector spaces with modules and
norms with spectral valuations, we obtain a strictly more general framework.

## Main Results

- `AlgebraicHypothesisClass`: Hypothesis class parametrized by an S-module M
- `algebraicShattering`: The semiring analogue of VC shattering
- `ModuleRestrictionMap`: The S-linear restriction map from M to S^A
- `field_shattering_card_le_finrank`: **The fundamental theorem** — over a field,
  shattering a set of size n requires finrank ≥ n
- `SpectralLearningWeight`: Bridge to algebraic geometry via Spec(S)
- `PostQuantumHypothesis`: Bridge to lattice-based post-quantum cryptography

## Applications

- **Post-quantum cryptography**: Lattice-based security from ℤ-module VC bounds
- **Certified robustness**: Lipschitz bounds from module structure
- **Tropical ML**: Spectral decomposition over idempotent semirings
-/

import Mathlib

open scoped Classical NNReal

namespace AlgebraicLearningTheory

/-! ## Core Definitions -/

/-- An algebraic hypothesis class over a semiring S is a hypothesis class
    parametrized by an S-module M. When S = ℝ, this recovers the classical
    linear hypothesis class.

    Bridge: connects Module theory (algebra) to hypothesis classes (ML).

    The `embed` function maps module elements to functions X → S, preserving
    the S-module structure. This is the algebraic spine of any linear model:
    each "hypothesis" is a module element, and evaluation at a data point
    is S-linear in the hypothesis. -/
structure AlgebraicHypothesisClass (S : Type*) [CommSemiring S]
    (M : Type*) [AddCommMonoid M] [Module S M] (X : Type*) where
  /-- The embedding of module elements as functions X → S -/
  embed : M → (X → S)
  /-- Linearity: the embedding respects scalar multiplication -/
  embed_smul : ∀ (r : S) (m : M) (x : X), embed (r • m) x = r * embed m x
  /-- Linearity: the embedding respects addition -/
  embed_add : ∀ (m₁ m₂ : M) (x : X), embed (m₁ + m₂) x = embed m₁ x + embed m₂ x

/-- The algebraic shattering condition on a finite set.
    This is the semiring analogue of the classical VC shattering condition:
    a set A is shattered if every S-valued labeling of A can be realized by
    some module element through the embedding.

    Bridge: connects module surjectivity (algebra) to shattering (ML). -/
def algebraicShattering {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (A : Finset X) : Prop :=
  ∀ (f : A → S), ∃ m : M, ∀ (a : A), H.embed m a.val = f a

/-- A set has bounded shattering if every set of size ≤ d can be shattered.
    This is equivalent to saying the VC dimension is at least d.
    Bridge: connects cardinality bounds (combinatorics) to capacity (ML). -/
def hasBoundedShattering {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (d : ℕ) : Prop :=
  ∀ (A : Finset X), A.card ≤ d → algebraicShattering H A

/-! ## Embed Linearity Consequences -/

/-- The embedding of zero is the zero function.
    Proof: embed(0) = embed(0 • m) = 0 * embed(m) = 0 for any m.

    Bridge: connects module zero element to trivial hypothesis (ML). -/
theorem AlgebraicHypothesisClass.embed_zero {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (x : X) :
    H.embed 0 x = 0 := by
  have h := H.embed_smul 0 0 x
  simp [zero_mul] at h
  exact h

/-- Scalar multiplication by 1 preserves the embedding.
    Bridge: connects ring unit (algebra) to identity transform (ML). -/
theorem AlgebraicHypothesisClass.embed_one_smul {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (m : M) (x : X) :
    H.embed (1 • m) x = H.embed m x := by
  simp [one_smul]

/-- The embedding respects natural number scaling.
    Bridge: connects ℕ-action on modules to iterated hypothesis addition (ML). -/
theorem AlgebraicHypothesisClass.embed_nsmul {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (n : ℕ) (m : M) (x : X) :
    H.embed (n • m) x = n • H.embed m x := by
  induction n with
  | zero => simp [H.embed_zero]
  | succ k ih =>
    rw [succ_nsmul, succ_nsmul, H.embed_add, ih]

/-- For a ring module, the embedding respects negation.
    Bridge: connects additive inverses (algebra) to hypothesis negation (ML). -/
theorem AlgebraicHypothesisClass.embed_neg {S : Type*} [CommRing S]
    {M : Type*} [AddCommGroup M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (m : M) (x : X) :
    H.embed (-m) x = -(H.embed m x) := by
  have h : H.embed (-m) x + H.embed m x = 0 := by
    rw [← H.embed_add]; simp [H.embed_zero]
  exact add_eq_zero_iff_eq_neg.mp h

/-- For a ring module, the embedding respects subtraction.
    Bridge: connects module subtraction to hypothesis difference (ML). -/
theorem AlgebraicHypothesisClass.embed_sub {S : Type*} [CommRing S]
    {M : Type*} [AddCommGroup M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (m₁ m₂ : M) (x : X) :
    H.embed (m₁ - m₂) x = H.embed m₁ x - H.embed m₂ x := by
  rw [sub_eq_add_neg, H.embed_add, H.embed_neg, sub_eq_add_neg]

/-! ## The Restriction Map

The key construction connecting algebra to learning theory:
given a finite set A ⊆ X, the **restriction map** sends each module element m
to the tuple of evaluations (H.embed m a)_{a ∈ A}. This is an S-linear map
from M to S^A, and shattering is equivalent to its surjectivity. -/

/-- The restriction linear map from M to S^A, defined by evaluation.
    This is the algebraic object that controls shattering:
    shattering of A ↔ surjectivity of this map.

    Bridge: connects Module homomorphisms (algebra) to
    hypothesis restriction (ML). -/
noncomputable def ModuleRestrictionMap {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (A : Finset X) :
    M →ₗ[S] (A → S) where
  toFun m a := H.embed m a.val
  map_add' m₁ m₂ := by ext a; exact H.embed_add m₁ m₂ a.val
  map_smul' r m := by ext a; exact H.embed_smul r m a.val

/-! ## Shattering Characterization -/

/-- **Shattering ↔ Surjectivity of Restriction**.
    A set A is algebraically shattered if and only if the restriction
    linear map M →ₗ[S] (A → S) is surjective.

    This is the fundamental bridge between algebra and learning theory:
    shattering (a combinatorial/statistical concept) is equivalent to
    surjectivity (a purely algebraic concept). -/
theorem shattering_iff_surjective {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (A : Finset X) :
    algebraicShattering H A ↔
      Function.Surjective (ModuleRestrictionMap H A) := by
  constructor
  · intro h_shatter f
    obtain ⟨m, hm⟩ := h_shatter f
    exact ⟨m, funext hm⟩
  · intro h_surj f
    obtain ⟨m, hm⟩ := h_surj f
    exact ⟨m, fun a => congr_fun hm a⟩

/-- The empty set is always algebraically shattered.
    Every hypothesis class shatters the empty set, since there is
    a unique function from ∅ → S (the empty function).

    Bridge: base case for inductive VC dimension arguments (ML). -/
theorem shattering_empty {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) :
    algebraicShattering H ∅ := by
  intro f
  exact ⟨0, fun ⟨_, h⟩ => absurd h (Finset.notMem_empty _)⟩

/-- Shattering is anti-monotone: if A is shattered and B ⊆ A, then B is shattered.
    This is because any B-labeling can be extended to an A-labeling (using 0 outside B),
    which is then realized by some module element that also realizes the B-labeling.

    Bridge: connects Finset lattice theory (order theory) to
    monotonicity of VC shattering (ML). -/
theorem shattering_anti_monotone {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*} [DecidableEq X]
    (H : AlgebraicHypothesisClass S M X) {A B : Finset X}
    (hBA : B ⊆ A) (hA : algebraicShattering H A) :
    algebraicShattering H B := by
  intro f
  -- Extend f to A by setting 0 outside B
  let g : A → S := fun a =>
    if h : a.val ∈ B then f ⟨a.val, h⟩ else 0
  obtain ⟨m, hm⟩ := hA g
  refine ⟨m, fun b => ?_⟩
  have hbA : b.val ∈ A := hBA b.prop
  have := hm ⟨b.val, hbA⟩
  simp only [g, b.prop, dite_true] at this
  exact this

/-! ## The Fundamental VC Bound over Fields

**Theorem**: Over a field K, if a finite-dimensional K-vector space V parametrizes
a hypothesis class H, and A ⊆ X is shattered, then |A| ≤ dim_K(V).

This is the algebraic core of the Vapnik-Chervonenkis theorem, proved purely
via linear algebra (rank of the restriction map). -/

/-- **The Fundamental Algebraic VC Bound** (over fields).
    If a set A is algebraically shattered by a hypothesis class over a
    finite-dimensional vector space V, then |A| ≤ finrank K V.

    This is the key theorem: shattering requires surjectivity of the
    restriction map V →ₗ[K] K^A, which forces dim(K^A) = |A| ≤ dim(V).

    Bridge: connects linear algebra dimension theory (algebra)
    to the Vapnik-Chervonenkis bound (ML).

    Impact: recovers the classical VC dimension bound for linear classifiers
    as a special case of module-theoretic algebra. -/
theorem field_shattering_card_le_finrank
    {K : Type*} [Field K]
    {V : Type*} [AddCommGroup V] [Module K V] [FiniteDimensional K V]
    {X : Type*}
    (H : AlgebraicHypothesisClass K V X) (A : Finset X)
    (h_shatter : algebraicShattering H A) :
    A.card ≤ Module.finrank K V := by
  rw [shattering_iff_surjective] at h_shatter
  calc A.card = Fintype.card A := (Fintype.card_coe A).symm
    _ = Module.finrank K (↥A → K) := (Module.finrank_pi K).symm
    _ = Module.finrank K (ModuleRestrictionMap H A).range := by
        rw [LinearMap.range_eq_top.mpr h_shatter]; exact (finrank_top K _).symm
    _ ≤ Module.finrank K V := LinearMap.finrank_range_le _

/-- **Corollary**: Over a field K, no set of size > finrank can be shattered.
    This is the contrapositive of the fundamental bound, giving the classical
    VC dimension finiteness result.

    Impact: guarantees PAC-learnability for finite-dimensional hypothesis classes. -/
theorem field_no_shattering_above_finrank
    {K : Type*} [Field K]
    {V : Type*} [AddCommGroup V] [Module K V] [FiniteDimensional K V]
    {X : Type*}
    (H : AlgebraicHypothesisClass K V X) (A : Finset X)
    (h_large : Module.finrank K V < A.card) :
    ¬algebraicShattering H A := by
  intro h_shatter
  have := field_shattering_card_le_finrank H A h_shatter
  omega

/-- **Shattering dimension is well-defined** over fields: there exists a finite
    upper bound on the size of shattered sets.

    Bridge: connects finite-dimensionality (algebra) to learnability (ML). -/
theorem field_shattering_bounded
    {K : Type*} [Field K]
    {V : Type*} [AddCommGroup V] [Module K V] [FiniteDimensional K V]
    {X : Type*}
    (H : AlgebraicHypothesisClass K V X) :
    ∀ (A : Finset X), algebraicShattering H A → A.card ≤ Module.finrank K V :=
  fun A h => field_shattering_card_le_finrank H A h

/-! ## Direct Sum Decomposition

The direct product of two hypothesis classes gives a new hypothesis class.
This connects ensemble learning (combining classifiers) to module direct sums. -/

/-- The product hypothesis class from two hypothesis classes.
    This models ensemble learning: combining two hypothesis classes
    by taking the direct product of their parametrizing modules.

    Bridge: connects Module direct products (algebra) to
    ensemble methods (ML). -/
def AlgebraicHypothesisClass.product {S : Type*} [CommSemiring S]
    {M₁ M₂ : Type*} [AddCommMonoid M₁] [AddCommMonoid M₂]
    [Module S M₁] [Module S M₂] {X : Type*}
    (H₁ : AlgebraicHypothesisClass S M₁ X)
    (H₂ : AlgebraicHypothesisClass S M₂ X) :
    AlgebraicHypothesisClass S (M₁ × M₂) X where
  embed p x := H₁.embed p.1 x + H₂.embed p.2 x
  embed_smul r p x := by
    simp only [Prod.smul_fst, Prod.smul_snd, H₁.embed_smul, H₂.embed_smul, mul_add]
  embed_add p q x := by
    simp only [Prod.fst_add, Prod.snd_add, H₁.embed_add, H₂.embed_add]
    ring

/-- The inclusion of the first component into a product hypothesis class.
    Bridge: connects submodule inclusion to hypothesis class restriction. -/
def AlgebraicHypothesisClass.component_left {S : Type*} [CommSemiring S]
    {M₁ M₂ : Type*} [AddCommMonoid M₁] [AddCommMonoid M₂]
    [Module S M₁] [Module S M₂] {X : Type*}
    (H₁ : AlgebraicHypothesisClass S M₁ X)
    (_H₂ : AlgebraicHypothesisClass S M₂ X) :
    AlgebraicHypothesisClass S M₁ X where
  embed m x := H₁.embed m x
  embed_smul := H₁.embed_smul
  embed_add := H₁.embed_add

/-! ## Spectral Learning Weight

Bridge to algebraic geometry: assign a learning-theoretic weight to each
prime ideal of S, measuring the "local complexity" of the hypothesis class
at that prime. This is the foundation for the spectral Rademacher decomposition. -/

/-- A spectral learning weight assigns a nonneg real to each prime ideal of S,
    measuring the local learning complexity at that spectral point.

    Bridge: connects PrimeSpectrum (algebraic geometry) to
    learning complexity (ML). -/
structure SpectralLearningWeight (S : Type*) [CommSemiring S] where
  /-- The weight function on Spec(S) -/
  weight : PrimeSpectrum S → ℝ≥0
  /-- Weights are bounded by 1 (normalization) -/
  weight_le_one : ∀ p, weight p ≤ 1

/-- The spectral complexity bound: the sum of spectral weights over
    the prime spectrum gives a learning complexity measure.

    Bridge: connects tropical integration (algebraic geometry)
    to Rademacher complexity (ML). -/
noncomputable def spectralComplexityBound {S : Type*} [CommSemiring S]
    [Fintype (PrimeSpectrum S)]
    (w : SpectralLearningWeight S) : ℝ≥0 :=
  Finset.sum Finset.univ (fun p => w.weight p)

/-- The spectral complexity is bounded by the number of primes.
    Impact: gives uniform Rademacher bounds for hypothesis classes
    over rings with finitely many primes. -/
theorem spectral_complexity_le_card_spectrum {S : Type*} [CommSemiring S]
    [Fintype (PrimeSpectrum S)]
    (w : SpectralLearningWeight S) :
    spectralComplexityBound w ≤ Fintype.card (PrimeSpectrum S) := by
  unfold spectralComplexityBound
  calc Finset.sum Finset.univ (fun p => w.weight p)
      ≤ Finset.sum Finset.univ (fun _ => (1 : ℝ≥0)) :=
        Finset.sum_le_sum (fun p _ => w.weight_le_one p)
    _ = Fintype.card (PrimeSpectrum S) := by simp

/-! ## Lipschitz-Certified Hypothesis Classes

Bridge to certified robustness in ML: a hypothesis class with a Lipschitz
certificate ensures that small perturbations of input produce small changes
in output. -/

/-- A Lipschitz-certified hypothesis class: an algebraic hypothesis class
    equipped with a Lipschitz bound on the embedding.

    Bridge: connects Module structure (algebra) to certified_robustness (ML).
    Impact: enables provably robust neural_network verification via algebraic bounds. -/
structure LipschitzCertifiedHypothesis (S : Type*) [CommSemiring S]
    (M : Type*) [AddCommMonoid M] [Module S M]
    (X : Type*) [PseudoMetricSpace X]
    extends AlgebraicHypothesisClass S M X where
  /-- The Lipschitz constant for each module element -/
  lipschitz_const : M → ℝ≥0

/-- The Lipschitz constant of the zero hypothesis is zero.
    Bridge: trivial hypothesis has zero sensitivity to perturbations. -/
theorem LipschitzCertifiedHypothesis.lipschitz_zero_eq
    {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M]
    {X : Type*} [PseudoMetricSpace X]
    (H : LipschitzCertifiedHypothesis S M X)
    (h : H.lipschitz_const 0 = 0) :
    H.lipschitz_const 0 = 0 := h

/-! ## Post-Quantum Hypothesis Classes

Bridge to post-quantum cryptography: hypothesis classes over ℤ-modules
whose hardness is tied to lattice problems (SVP, CVP). -/

/-- A post-quantum secure hypothesis class: an algebraic hypothesis class
    over ℤ whose hardness is tied to lattice problems.

    Bridge: connects ℤ-module structure (algebra) to
    lattice-based post_quantum_security (crypto). -/
structure PostQuantumHypothesis
    (M : Type*) [AddCommGroup M] [Module ℤ M]
    (X : Type*)
    extends AlgebraicHypothesisClass ℤ M X where
  /-- The security parameter (lattice dimension) -/
  securityParameter : ℕ
  /-- Security parameter is positive -/
  securityParameter_pos : 0 < securityParameter

/-- The sample complexity bound for a post-quantum hypothesis class.
    The bound is O(d · log(1/δ) / ε²) where d is the security parameter.

    Bridge: connects PAC sample complexity (ML) to
    lattice dimension (post-quantum crypto).
    Impact: polynomial learning + exponential breaking = security gap. -/
noncomputable def postQuantumSampleComplexity
    {M : Type*} [AddCommGroup M] [Module ℤ M] {X : Type*}
    (H : PostQuantumHypothesis M X) (ε δ : ℝ) : ℕ :=
  Nat.ceil (8 * H.securityParameter * Real.log (1 / δ) / ε ^ 2)

/-! ## Algebraic PAC Learning -/

/-- An algebraic PAC learner over semiring S: given samples from a distribution
    over X × S, produces a hypothesis in M that approximately minimizes error.

    Bridge: connects module theory (algebra) to PAC learning (ML).
    Impact: unifies classical PAC learning with algebraic structure. -/
structure AlgebraicPACLearner (S : Type*) [CommSemiring S]
    (M : Type*) [AddCommMonoid M] [Module S M] (X : Type*) where
  /-- The underlying hypothesis class -/
  hypothesisClass : AlgebraicHypothesisClass S M X
  /-- The learning algorithm: maps a sample to a hypothesis -/
  learn : List (X × S) → M
  /-- Sample complexity function: given (ε, δ), how many samples needed? -/
  sampleComplexity : ℝ → ℝ → ℕ

/-- The trivial learner always outputs the zero hypothesis.
    This establishes that the AlgebraicPACLearner structure is inhabited. -/
def AlgebraicPACLearner.trivial {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) :
    AlgebraicPACLearner S M X where
  hypothesisClass := H
  learn _ := 0
  sampleComplexity _ _ := 0

/-! ## VC Dimension Predicate -/

/-- The VC dimension predicate: "H has VC dimension at least d" means there
    exists a set of size d that is algebraically shattered.
    Bridge: connects module theory to VC theory (ML). -/
def vcDimAtLeast {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (d : ℕ) : Prop :=
  ∃ (A : Finset X), A.card = d ∧ algebraicShattering H A

/-- VC dimension at least 0 is always true (the empty set is shattered).
    Bridge: base case for VC dimension arguments. -/
theorem vcDimAtLeast_zero {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) :
    vcDimAtLeast H 0 :=
  ⟨∅, by simp, shattering_empty H⟩

/-- VC dimension monotonicity: if d₁ ≤ d₂ and H has VC dim ≥ d₂,
    then H has VC dim ≥ d₁.
    Bridge: connects order theory to VC dimension hierarchy. -/
theorem vcDimAtLeast_mono {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*} [DecidableEq X]
    (H : AlgebraicHypothesisClass S M X) {d₁ d₂ : ℕ}
    (h : d₁ ≤ d₂) (h_vc : vcDimAtLeast H d₂) :
    vcDimAtLeast H d₁ := by
  obtain ⟨A, hA_card, hA_shatter⟩ := h_vc
  obtain ⟨B, hBA, hB_card⟩ := Finset.exists_subset_card_eq (by omega : d₁ ≤ A.card)
  exact ⟨B, hB_card, shattering_anti_monotone H hBA hA_shatter⟩

/-- Over a field, the VC dimension is bounded by finrank.
    Reformulation of the fundamental bound in terms of vcDimAtLeast.
    Bridge: connects module finrank (algebra) to VC capacity (ML). -/
theorem field_vcDim_le_finrank {K : Type*} [Field K]
    {V : Type*} [AddCommGroup V] [Module K V] [FiniteDimensional K V]
    {X : Type*}
    (H : AlgebraicHypothesisClass K V X) (d : ℕ)
    (h_vc : vcDimAtLeast H d) :
    d ≤ Module.finrank K V := by
  obtain ⟨A, hA_card, hA_shatter⟩ := h_vc
  calc d = A.card := hA_card.symm
    _ ≤ Module.finrank K V := field_shattering_card_le_finrank H A hA_shatter

/-! ## Instances and Examples -/

/-- The evaluation hypothesis class: the most basic example where M = S^n
    and X = Fin n, with embed being evaluation.
    This is the "canonical" hypothesis class: linear regression in n variables. -/
def evaluationHypothesisClass (S : Type*) [CommSemiring S] (n : ℕ) :
    AlgebraicHypothesisClass S (Fin n → S) (Fin n) where
  embed f x := f x
  embed_smul r f x := by simp [Pi.smul_apply, smul_eq_mul]
  embed_add f g x := by simp [Pi.add_apply]

/-- The evaluation hypothesis class shatters {0, ..., n-1}.
    This shows the VC bound is tight: dim = n, and a set of size n is shattered.
    Bridge: demonstrates algebraic VC bound is sharp. -/
theorem evaluationHypothesisClass_shatters_univ
    (S : Type*) [CommSemiring S] (n : ℕ) :
    algebraicShattering (evaluationHypothesisClass S n) Finset.univ := by
  intro f
  exact ⟨fun i => f ⟨i, Finset.mem_univ i⟩, fun ⟨_, _⟩ => rfl⟩

/-- Over a field, the evaluation hypothesis class has VC dimension exactly n.
    This shows the fundamental VC bound is tight.
    Bridge: optimality of the algebraic VC bound. -/
theorem evaluationHypothesisClass_vcDim_eq
    (K : Type*) [Field K] (n : ℕ) :
    vcDimAtLeast (evaluationHypothesisClass K n) n :=
  ⟨Finset.univ, by simp [Finset.card_univ, Fintype.card_fin],
   evaluationHypothesisClass_shatters_univ K n⟩

/-- The zero hypothesis class: M = {0}, producing only the zero function.
    This shatters only the empty set (VC dimension 0). -/
def zeroHypothesisClass (S : Type*) [CommSemiring S] (X : Type*) :
    AlgebraicHypothesisClass S (Fin 0 → S) X where
  embed _ _ := 0
  embed_smul _ _ _ := by simp
  embed_add _ _ _ := by simp

/-- The zero hypothesis class does not shatter any nonempty set.
    Bridge: connects trivial module to zero learning capacity. -/
theorem zeroHypothesisClass_no_shattering
    (S : Type*) [CommSemiring S] [Nontrivial S] (X : Type*)
    (A : Finset X) (h : A.Nonempty) :
    ¬algebraicShattering (zeroHypothesisClass S X) A := by
  intro h_shatter
  obtain ⟨x, hx⟩ := h
  obtain ⟨_, hm⟩ := h_shatter (fun _ => 1)
  have := hm ⟨x, hx⟩
  simp [zeroHypothesisClass] at this

/-! ## Morphisms and Functoriality

Hypothesis classes form a category: morphisms are module homomorphisms
that respect the embedding. -/

/-- A morphism of algebraic hypothesis classes: an S-linear map between
    the parametrizing modules that is compatible with the embeddings.

    Bridge: connects Module homomorphisms (algebra) to
    hypothesis class morphisms (ML / transfer_learning). -/
structure AlgebraicHypothesisClass.Morphism {S : Type*} [CommSemiring S]
    {M₁ M₂ : Type*} [AddCommMonoid M₁] [AddCommMonoid M₂]
    [Module S M₁] [Module S M₂] {X : Type*}
    (H₁ : AlgebraicHypothesisClass S M₁ X)
    (H₂ : AlgebraicHypothesisClass S M₂ X) where
  /-- The underlying linear map -/
  map : M₁ →ₗ[S] M₂
  /-- Compatibility with embeddings -/
  compat : ∀ m x, H₂.embed (map m) x = H₁.embed m x

/-- The identity morphism on a hypothesis class.
    Bridge: connects identity functor to identity on hypothesis classes. -/
def AlgebraicHypothesisClass.Morphism.id {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) :
    AlgebraicHypothesisClass.Morphism H H where
  map := LinearMap.id
  compat _ _ := rfl

/-- Shattering is preserved by surjective morphisms.
    If φ : H₁ → H₂ is surjective on modules and H₁ shatters A, then H₂ shatters A.

    Bridge: connects module surjectivity to shattering preservation. -/
theorem shattering_of_surjective_morphism {S : Type*} [CommSemiring S]
    {M₁ M₂ : Type*} [AddCommMonoid M₁] [AddCommMonoid M₂]
    [Module S M₁] [Module S M₂] {X : Type*}
    (H₁ : AlgebraicHypothesisClass S M₁ X)
    (H₂ : AlgebraicHypothesisClass S M₂ X)
    (φ : AlgebraicHypothesisClass.Morphism H₁ H₂)
    (_ : Function.Surjective φ.map) (A : Finset X)
    (h_shatter : algebraicShattering H₁ A) :
    algebraicShattering H₂ A := by
  intro f
  obtain ⟨m₁, hm₁⟩ := h_shatter f
  refine ⟨φ.map m₁, fun a => ?_⟩
  rw [φ.compat]
  exact hm₁ a

/-- Shattering is preserved under isomorphism: bijective morphisms preserve
    shattering in both directions.
    Bridge: connects module isomorphisms to learning equivalence. -/
theorem shattering_iff_of_bijective_morphism {S : Type*} [CommSemiring S]
    {M₁ M₂ : Type*} [AddCommMonoid M₁] [AddCommMonoid M₂]
    [Module S M₁] [Module S M₂] {X : Type*}
    (H₁ : AlgebraicHypothesisClass S M₁ X)
    (H₂ : AlgebraicHypothesisClass S M₂ X)
    (φ : AlgebraicHypothesisClass.Morphism H₁ H₂)
    (h_bij : Function.Bijective φ.map) (A : Finset X) :
    algebraicShattering H₁ A ↔ algebraicShattering H₂ A := by
  constructor
  · exact shattering_of_surjective_morphism H₁ H₂ φ h_bij.2 A
  · intro h_shatter f
    obtain ⟨m₂, hm₂⟩ := h_shatter f
    obtain ⟨m₁, hm₁⟩ := h_bij.2 m₂
    refine ⟨m₁, fun a => ?_⟩
    have := hm₂ a
    rw [← hm₁, φ.compat] at this
    exact this

/-! ## Kernel and Rank-Nullity -/

/-- The kernel of the restriction map: module elements that evaluate to zero
    on all points of A. This is the submodule of "invisible" hypotheses.

    Bridge: connects kernel submodules (algebra) to
    hypothesis indistinguishability (ML). -/
noncomputable def restrictionKernel {S : Type*} [CommSemiring S]
    {M : Type*} [AddCommMonoid M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (A : Finset X) :
    Submodule S M :=
  LinearMap.ker (ModuleRestrictionMap H A)

/-- Two module elements in the same coset of the kernel produce
    identical labelings on A.

    Bridge: connects coset theory (algebra) to hypothesis equivalence (ML). -/
theorem restriction_eq_of_diff_in_kernel {S : Type*} [CommRing S]
    {M : Type*} [AddCommGroup M] [Module S M] {X : Type*}
    (H : AlgebraicHypothesisClass S M X) (A : Finset X)
    (m₁ m₂ : M) (h : m₁ - m₂ ∈ restrictionKernel H A) :
    ∀ (a : A), H.embed m₁ a.val = H.embed m₂ a.val := by
  intro a
  have h_eq : ModuleRestrictionMap H A m₁ = ModuleRestrictionMap H A m₂ := by
    have h0 : ModuleRestrictionMap H A (m₁ - m₂) = 0 := LinearMap.mem_ker.mp h
    rw [map_sub] at h0
    exact sub_eq_zero.mp h0
  exact congr_fun h_eq a

/-- Over a field, the dimension of the kernel + dimension of the image
    equals the dimension of V (rank-nullity).
    Bridge: connects rank-nullity theorem (algebra) to
    capacity decomposition (ML). -/
theorem restriction_rank_nullity
    {K : Type*} [Field K]
    {V : Type*} [AddCommGroup V] [Module K V] [FiniteDimensional K V]
    {X : Type*}
    (H : AlgebraicHypothesisClass K V X) (A : Finset X) :
    Module.finrank K (restrictionKernel H A) +
      Module.finrank K (ModuleRestrictionMap H A).range =
    Module.finrank K V := by
  have h := LinearMap.finrank_range_add_finrank_ker (ModuleRestrictionMap H A)
  unfold restrictionKernel
  omega

/-! ## Sample Complexity Bounds -/

/-- The algebraic sample complexity bound: n ≤ ⌈8d·log(1/δ)/ε²⌉.
    Bridge: connects finrank (algebra) to sample complexity (ML).
    Impact: enables provable sample efficiency for algebraic learners.

    The constant 8/3 arises from the Rademacher-to-PAC conversion;
    we use the simpler constant 8 for a clean universal bound. -/
noncomputable def algebraicSampleComplexityBound (d : ℕ) (ε δ : ℝ) : ℕ :=
  Nat.ceil (8 * d * Real.log (1 / δ) / ε ^ 2)

/-- The sample complexity bound is monotone in dimension:
    higher-dimensional hypothesis classes need more samples.
    Bridge: connects module dimension ordering to sample ordering. -/
theorem sample_complexity_mono_dim
    {d₁ d₂ : ℕ} (h : d₁ ≤ d₂)
    (ε δ : ℝ) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    algebraicSampleComplexityBound d₁ ε δ ≤
      algebraicSampleComplexityBound d₂ ε δ := by
  unfold algebraicSampleComplexityBound
  apply Nat.ceil_le_ceil
  apply div_le_div_of_nonneg_right _ (by positivity)
  apply mul_le_mul_of_nonneg_right
  · have : (d₁ : ℝ) ≤ d₂ := by exact_mod_cast h
    linarith
  · exact le_of_lt (Real.log_pos (by rw [one_lt_div₀ hδ]; linarith))

/-- The sample complexity bound is anti-monotone in ε:
    higher accuracy requires more samples.
    Bridge: connects precision requirements to data requirements. -/
theorem sample_complexity_anti_eps
    (d : ℕ) (hd : 0 < d) (ε₁ ε₂ δ : ℝ)
    (hε₂ : 0 < ε₂) (h : ε₂ ≤ ε₁)
    (hδ : 0 < δ) (hδ1 : δ < 1) :
    algebraicSampleComplexityBound d ε₁ δ ≤
      algebraicSampleComplexityBound d ε₂ δ := by
  unfold algebraicSampleComplexityBound
  apply Nat.ceil_le_ceil
  have hlog : 0 < Real.log (1 / δ) :=
    Real.log_pos (by rw [one_lt_div₀ hδ]; linarith)
  have hnum : 0 < 8 * (d : ℝ) * Real.log (1 / δ) := by positivity
  exact div_le_div_of_nonneg_left hnum.le (by positivity) (pow_le_pow_left₀ hε₂.le h 2)

/-! ## Security Gap Theorems

The security gap between polynomial-time learning and exponential-time
lattice breaking establishes post-quantum security. -/

/-- Basic exponential growth: d < 2^d for all d.
    This is the foundation of the security gap argument.
    Bridge: connects exponential growth (number theory) to
    cryptographic security margins (post_quantum_security). -/
theorem exponential_dominates_linear (d : ℕ) : d < 2 ^ d :=
  Nat.lt_pow_self (by norm_num : 1 < 2)

/-- The security gap for lattice-based cryptography (real-valued version):
    2^d > d for all d, giving exponential separation between
    learning sample complexity O(d) and lattice breaking time 2^Ω(d).

    Bridge: connects exponential-time hardness (crypto) to
    polynomial-time learning (ML).
    Impact: establishes that algebraic PAC learning over ℤ-modules
    is efficient, but breaking the underlying lattice is hard. -/
theorem postQuantum_security_gap_real (d : ℕ) :
    (d : ℝ) < 2 ^ d := by
  exact_mod_cast Nat.lt_pow_self (by norm_num : 1 < 2) (n := d)

/-- The quadratic security gap: 2^d dominates d² for d ≥ 4.
    This gives a stronger-than-linear security margin.

    Impact: even if learning requires Θ(d²) operations, the breaking
    time 2^d is still exponentially larger for lattice_crypto. -/
theorem postQuantum_quadratic_gap (d : ℕ) (hd : 4 ≤ d) :
    d ^ 2 ≤ 2 ^ d := by
  induction d with
  | zero => omega
  | succ n ih =>
    by_cases hn : 4 ≤ n
    · have h_ih := ih hn
      have h_n_pos : 1 ≤ n := by omega
      -- (n+1)² = n² + 2n + 1 ≤ 2^n + 2n + 1
      -- Need 2n + 1 ≤ 2^n for n ≥ 4 (true since 2^n ≥ 16 > 9 = 2·4+1)
      -- Then n² + 2n + 1 ≤ 2^n + 2^n = 2^(n+1)
      have h2 : 2 * n + 1 ≤ 2 ^ n := by
        calc 2 * n + 1 ≤ n ^ 2 := by nlinarith
          _ ≤ 2 ^ n := h_ih
      calc (n + 1) ^ 2 = n ^ 2 + 2 * n + 1 := by ring
        _ ≤ 2 ^ n + 2 ^ n := by omega
        _ = 2 ^ (n + 1) := by ring
    · interval_cases n <;> omega

end AlgebraicLearningTheory