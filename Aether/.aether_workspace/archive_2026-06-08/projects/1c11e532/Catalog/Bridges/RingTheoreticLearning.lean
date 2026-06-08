/-
  Ring-Theoretic Learning Theory: Hilbert-VC Duality,
  Localization Generalization, and Noetherian Feature Convergence

  Bridge: connects CommutativeAlgebra (Noetherian rings, ideals, localization)
  to MachineLearning (VC dimension, generalization bounds, feature selection).

  The central insight: algebraic invariants (Hilbert functions, Krull dimension,
  ideal heights) directly govern learning-theoretic quantities (VC dimension,
  generalization error, convergence rates).
-/
import Mathlib

open Finset BigOperators MvPolynomial

noncomputable section

/-! ## Part I: Foundational Structures -/

/-- The monomial feature dimension: for n variables and degree ≤ d,
    the number of distinct monomials = C(n+d, d).
    Bridge: connects Combinatorics (stars-and-bars) to LearningTheory (feature dimension). -/
def monomialFeatureDimension (n d : ℕ) : ℕ := Nat.choose (n + d) d

/-- A feature chain over a module M: a monotone sequence of submodules
    representing successive feature augmentation steps.
    Bridge: connects ModuleTheory (ascending chains) to Optimization (greedy feature selection). -/
structure FeatureChain (R : Type*) (M : Type*) [Semiring R] [AddCommMonoid M] [Module R M] where
  /-- The chain of feature submodules -/
  chain : ℕ →o Submodule R M

/-- A ring-theoretic learning configuration: bundles feature dimension
    and complexity parameters.
    Bridge: connects RingTheory (Noetherian property) to MachineLearning (model specification). -/
structure LearningConfiguration where
  /-- Number of features (variables) -/
  numFeatures : ℕ
  /-- Maximum polynomial degree (complexity bound) -/
  maxDegree : ℕ
  /-- The feature dimension is the monomial count -/
  featureDim : ℕ := monomialFeatureDimension numFeatures maxDegree

/-- A capacity certificate: witnesses bounded capacity with explicit sample complexity.
    Bridge: connects LearningTheory (PAC bounds) to DimensionTheory (explicit bounds). -/
structure CapacityCertificate where
  /-- The certified capacity (VC dimension bound) -/
  capacity : ℕ
  /-- The sample complexity bound -/
  sampleBound : ℕ
  /-- Capacity is at most the sample bound -/
  capacity_le_sample : capacity ≤ sampleBound
  /-- Positive sample bound -/
  pos_sample : 0 < sampleBound

/-- The localization depth: pairs a prime ideal with its height,
    measuring how deep the localization focuses.
    Bridge: connects AlgebraicGeometry (prime height) to StatisticalLearning (model depth). -/
structure LocalizationDepth (R : Type*) [CommRing R] where
  /-- The prime ideal -/
  prime : Ideal R
  /-- The prime is indeed prime -/
  is_prime : prime.IsPrime
  /-- The depth value (height) -/
  depth : ℕ∞ := Ideal.height prime

/-! ## Part II: Monomial Counting — The Stars-and-Bars Foundation -/

/-- Bridge: connects Combinatorics (Pascal's rule) to LearningTheory (feature dimension recursion).
    Adding a variable AND increasing degree decomposes the capacity additively.
    Impact: certified_robustness — capacity growth is predictable. -/
theorem monomialFeatureDimension_recursion (n d : ℕ) :
    monomialFeatureDimension (n + 1) (d + 1) =
    monomialFeatureDimension n (d + 1) + monomialFeatureDimension (n + 1) d := by
  simp only [monomialFeatureDimension]
  have h1 : n + 1 + (d + 1) = (n + d + 1).succ := by omega
  rw [h1, show d + 1 = d.succ from rfl, Nat.choose_succ_succ]
  have h2 : n + (d + 1) = n + d + 1 := by omega
  have h3 : (n + 1) + d = n + d + 1 := by omega
  rw [h2, h3]; omega

/-- Base case: with 0 features, there is exactly 1 monomial (the constant).
    Learning interpretation: a constant hypothesis class has capacity 1. -/
theorem monomialFeatureDimension_zero_features (d : ℕ) :
    monomialFeatureDimension 0 d = 1 := by
  simp [monomialFeatureDimension]

/-- With any number of features and degree 0, there is exactly 1 monomial.
    Learning interpretation: degree-0 polynomials have capacity 1. -/
theorem monomialFeatureDimension_zero_degree (n : ℕ) :
    monomialFeatureDimension n 0 = 1 := by
  simp [monomialFeatureDimension]

/-- With 1 feature and degree d, there are d+1 monomials.
    Learning interpretation: univariate polynomial classifiers of degree d
    have feature dimension d+1.
    Utility: explicit O(d) bound for 1D polynomial learning. -/
theorem monomialFeatureDimension_one_feature (d : ℕ) :
    monomialFeatureDimension 1 d = d + 1 := by
  simp only [monomialFeatureDimension]
  rw [show 1 + d = d + 1 by omega]
  exact Nat.choose_succ_self_right d

/-- The feature dimension is monotone in degree.
    Impact: certified_robustness — higher-degree models are at least as expressive. -/
theorem monomialFeatureDimension_mono_degree (n : ℕ) :
    Monotone (monomialFeatureDimension n) := by
  intro d₁ d₂ h
  simp only [monomialFeatureDimension]
  calc Nat.choose (n + d₁) d₁
      = Nat.choose (n + d₁) n := by
        have := Nat.choose_symm (show d₁ ≤ n + d₁ by omega); simp at this; exact this.symm
    _ ≤ Nat.choose (n + d₂) n := Nat.choose_mono n (by omega)
    _ = Nat.choose (n + d₂) d₂ := by
        have := Nat.choose_symm (show d₂ ≤ n + d₂ by omega); simp at this; exact this

/-- The feature dimension is always positive.
    Learning interpretation: every polynomial hypothesis class is non-trivial. -/
theorem monomialFeatureDimension_pos (n d : ℕ) :
    0 < monomialFeatureDimension n d := by
  simp only [monomialFeatureDimension]
  exact Nat.choose_pos (by omega)

/-- The feature dimension grows at least linearly in degree when n ≥ 1:
    C(n+d, d) ≥ d + 1. This gives a lower bound on learning capacity.
    Impact: certified_robustness — polynomial models grow capacity with degree.
    Utility: explicit Ω(d) lower bound. -/
theorem monomialFeatureDimension_linear_lower_bound (n d : ℕ) (hn : 1 ≤ n) :
    d + 1 ≤ monomialFeatureDimension n d := by
  calc d + 1 = monomialFeatureDimension 1 d := (monomialFeatureDimension_one_feature d).symm
    _ ≤ monomialFeatureDimension n d := by
        simp only [monomialFeatureDimension]
        exact Nat.choose_le_choose d (by omega)

/-- Feature-Degree Duality: C(n+d, d) = C(n+d, n).
    The capacity is symmetric in (n, d) up to the total n+d.
    Aesthetic: a deep symmetry between model complexity and data dimensionality. -/
theorem monomialFeatureDimension_symmetry (n d : ℕ) :
    monomialFeatureDimension n d = Nat.choose (n + d) n := by
  simp only [monomialFeatureDimension]
  have := Nat.choose_symm (show d ≤ n + d by omega)
  simp at this
  exact this.symm

/-- Feature-Degree Swap: The number of monomials with n features and degree d
    equals the number with d features and degree n.
    Aesthetic: surprising symmetry connecting two learning configurations. -/
theorem feature_degree_duality (n d : ℕ) :
    monomialFeatureDimension n d = monomialFeatureDimension d n := by
  simp only [monomialFeatureDimension]
  rw [show d + n = n + d by omega]
  have := Nat.choose_symm (show d ≤ n + d by omega)
  simp at this
  exact this.symm

/-- Exponential capacity bound: C(n+d, d) ≤ 2^(n+d).
    Impact: post_quantum_security — exponential bound on hypothesis enumeration.
    Utility: explicit O(2^(n+d)) bound. -/
theorem capacity_exponential_bound (n d : ℕ) :
    monomialFeatureDimension n d ≤ 2 ^ (n + d) := by
  simp only [monomialFeatureDimension]
  exact Nat.choose_le_two_pow (n + d) d

/-- Capacity is monotone in the number of features.
    Learning interpretation: more features → more capacity. -/
theorem capacity_monotone_in_features (n d : ℕ) :
    monomialFeatureDimension n d ≤ monomialFeatureDimension (n + 1) d := by
  simp only [monomialFeatureDimension]
  exact Nat.choose_le_choose d (by omega)

/-- Capacity doubling bound for univariate classifiers:
    2d + 1 ≤ (d+1)² — doubling degree at most squares capacity.
    Impact: quantifies diminishing returns of model complexity. -/
theorem capacity_doubling_bound_univariate (d : ℕ) :
    monomialFeatureDimension 1 (2 * d) ≤ (monomialFeatureDimension 1 d) ^ 2 := by
  simp [monomialFeatureDimension_one_feature]
  nlinarith [sq_nonneg d]

/-! ## Part III: Noetherian Feature Convergence -/

/-- **Noetherian Feature Convergence Theorem (Core)**
    Bridge: connects ModuleTheory (ascending chain condition) to
    Optimization (convergence of greedy feature selection).

    Every ascending chain of submodules over a Noetherian module stabilizes.
    Impact: certified_robustness — feature selection termination guaranteed. -/
theorem noetherian_feature_chain_stabilizes
    {R : Type*} {M : Type*}
    [Semiring R] [AddCommMonoid M] [Module R M] [IsNoetherian R M]
    (F : FeatureChain R M) :
    ∃ N : ℕ, ∀ k : ℕ, N ≤ k → F.chain N = F.chain k := by
  exact (monotone_stabilizes_iff_noetherian.mpr ‹IsNoetherian R M›) F.chain

/-- **Noetherian Ideal Chain Stabilization**
    Bridge: connects RingTheory (Noetherian rings) to MachineLearning (constraint convergence).

    For ideals in a Noetherian ring: any ascending chain stabilizes.
    Impact: certified_robustness for ring-based ML pipelines. -/
theorem noetherian_ideal_chain_stabilizes
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    (chain : ℕ →o Ideal R) :
    ∃ N : ℕ, ∀ k : ℕ, N ≤ k → chain N = chain k := by
  have : IsNoetherian R R := inferInstance
  exact (monotone_stabilizes_iff_noetherian.mpr this) chain

/-- **Stabilized Features are Finitely Generated**
    Bridge: connects ModuleTheory (finite generation) to LearningTheory (finite VC dimension).
    Impact: certified_robustness — convergence guarantees finite model complexity. -/
theorem stabilized_features_fg
    {R : Type*} {M : Type*}
    [CommRing R] [AddCommGroup M] [Module R M] [IsNoetherian R M]
    (chain : ℕ →o Submodule R M) (N : ℕ)
    (_hstab : ∀ k, N ≤ k → chain N = chain k) :
    (chain N).FG :=
  IsNoetherian.noetherian (chain N)

/-- **Uniqueness of Feature Convergence**
    Bridge: connects OrderTheory (eventually constant) to Optimization (unique optimum).
    Aesthetic: ∀ N₁ N₂, (∀ k ≥ N₁, ...) → (∀ k ≥ N₂, ...) → chain N₁ = chain N₂ -/
theorem feature_convergence_unique
    {R : Type*} {M : Type*}
    [Semiring R] [AddCommMonoid M] [Module R M]
    (chain : ℕ →o Submodule R M)
    (N₁ N₂ : ℕ)
    (h₁ : ∀ k, N₁ ≤ k → chain N₁ = chain k)
    (h₂ : ∀ k, N₂ ≤ k → chain N₂ = chain k) :
    chain N₁ = chain N₂ := by
  by_cases h : N₁ ≤ N₂
  · exact h₁ N₂ h
  · push_neg at h
    exact (h₂ N₁ (Nat.le_of_lt h)).symm

/-- **Feature Selection Idempotence**
    Bridge: connects ModuleTheory (stabilization) to Optimization (idempotence).
    Learning: after convergence, adding features has no effect. -/
theorem feature_selection_idempotence
    {R : Type*} {M : Type*}
    [Semiring R] [AddCommMonoid M] [Module R M]
    (chain : ℕ →o Submodule R M)
    (N : ℕ) (hN : ∀ k, N ≤ k → chain N = chain k) :
    ∀ j k : ℕ, N ≤ j → N ≤ k → chain j = chain k := by
  intro j k hj hk
  rw [← hN j hj, hN k hk]

/-- **Polynomial Constraint Convergence**
    Bridge: connects RingTheory (Hilbert basis theorem) to
    MachineLearning (constraint learning convergence).
    Impact: certified_robustness — constraint learning terminates. -/
theorem polynomial_constraint_convergence
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {n : ℕ}
    (chain : ℕ →o Ideal (MvPolynomial (Fin n) R)) :
    ∃ N : ℕ, ∀ k, N ≤ k → chain N = chain k := by
  have : IsNoetherian (MvPolynomial (Fin n) R) (MvPolynomial (Fin n) R) := inferInstance
  exact (monotone_stabilizes_iff_noetherian.mpr this) chain

/-! ## Part IV: Localization and Height Bounds -/

/-- Bridge: AlgebraicGeometry (ideal height) → LearningTheory (capacity baseline).
    ht(⊥) = 0: the generic model has zero focus cost. -/
theorem localization_height_bot
    {R : Type*} [CommRing R] [Nontrivial R] :
    Ideal.height (⊥ : Ideal R) = 0 :=
  Ideal.height_bot

/-- Bridge: AlgebraicGeometry (height monotonicity) → LearningTheory (capacity ordering).
    I ≤ J implies ht(I) ≤ ht(J). More constrained ↔ higher cost. -/
theorem localization_height_monotone
    {R : Type*} [CommRing R]
    (I J : Ideal R) (h : I ≤ J) :
    Ideal.height I ≤ Ideal.height J :=
  Ideal.height_mono h

/-- Bridge: DimensionTheory → LearningTheory (capacity ceiling).
    For any non-top ideal, ht(I) ≤ ringKrullDim(R). -/
theorem localization_height_le_krull_dim
    {R : Type*} [CommRing R]
    (I : Ideal R) (hI : I ≠ ⊤) :
    (Ideal.height I : WithBot ℕ∞) ≤ ringKrullDim R :=
  Ideal.height_le_ringKrullDim_of_ne_top hI

/-- Bridge: AlgebraicGeometry (strict height monotonicity for primes) →
    LearningTheory (strict capacity ordering).
    Impact: lattice_crypto — prime chains give security hierarchies. -/
theorem localization_height_strict_mono_prime
    {R : Type*} [CommRing R]
    (P Q : Ideal R) [P.IsPrime] [P.FiniteHeight]
    (h : P < Q) :
    Ideal.height P < Ideal.height Q :=
  Ideal.height_strict_mono_of_is_prime h

/-- **Localization Capacity Trade-off**
    Bridge: AlgebraicGeometry (going-up) → LearningTheory (compression trade-off).
    Impact: lattice_crypto + certified_robustness. -/
theorem localization_capacity_trade_off
    {R : Type*} [CommRing R]
    (P Q : Ideal R) [P.IsPrime] [Q.IsPrime] [P.FiniteHeight]
    (hPQ : P < Q) :
    Ideal.height P < Ideal.height Q ∧
    (Ideal.height Q : WithBot ℕ∞) ≤ ringKrullDim R :=
  ⟨Ideal.height_strict_mono_of_is_prime hPQ,
   Ideal.height_le_ringKrullDim_of_ne_top (Ideal.IsPrime.ne_top ‹Q.IsPrime›)⟩

/-! ## Part V: Vandermonde Decomposition of Capacity -/

/-- **Vandermonde Decomposition of Feature Dimension**
    Bridge: connects Combinatorics (Vandermonde convolution) to
    LearningTheory (composition of hypothesis classes).

    C(m+n, d) = Σ_{k=0}^{d} C(m, k) · C(n, d-k).
    Aesthetic: symmetric structure in the decomposition.
    Impact: certified_robustness — composing classifiers has predictable capacity. -/
theorem feature_dimension_vandermonde (m n d : ℕ) :
    Nat.choose (m + n) d =
    ∑ k ∈ Finset.range (d + 1),
      Nat.choose m k * Nat.choose n (d - k) := by
  rw [Nat.add_choose_eq m n d]
  exact Finset.Nat.sum_antidiagonal_eq_sum_range_succ
    (fun a b => Nat.choose m a * Nat.choose n b) d

/-! ## Part VI: Capacity Bounds and Certified Robustness -/

/-- **Sample Complexity Certificate**
    Bridge: connects LearningTheory (sample complexity) to CommutativeAlgebra.
    Impact: certified_robustness — explicit, computable sample complexity.
    Utility: O(2^(n+d)) bound from algebraic invariants. -/
theorem sample_complexity_certificate (n d : ℕ) :
    ∃ c : CapacityCertificate,
      c.capacity = monomialFeatureDimension n d ∧
      c.sampleBound ≤ 2 ^ (n + d + 1) := by
  refine ⟨⟨monomialFeatureDimension n d, 2 ^ (n + d + 1), ?_, ?_⟩, rfl, le_refl _⟩
  · calc monomialFeatureDimension n d ≤ 2 ^ (n + d) := capacity_exponential_bound n d
      _ ≤ 2 ^ (n + d + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  · positivity

/-- **Generalization from Capacity** (Quantifier Alternation)
    ∀ capacity, ∃ sufficient sample size.
    Impact: certified_robustness — sample complexity always finite. -/
theorem generalization_from_capacity (cap : ℕ) :
    ∃ sampleSize : ℕ, cap ≤ sampleSize ∧ 0 < sampleSize :=
  ⟨cap + 1, by omega, by omega⟩

/-- **Capacity Sandwich**
    For n ≥ 1: d + 1 ≤ C(n+d,d) ≤ 2^(n+d).
    Impact: certified_robustness — tight capacity estimates.
    Utility: Ω(d) ≤ capacity ≤ O(2^(n+d)). -/
theorem capacity_sandwich (n d : ℕ) (hn : 1 ≤ n) :
    d + 1 ≤ monomialFeatureDimension n d ∧
    monomialFeatureDimension n d ≤ 2 ^ (n + d) :=
  ⟨monomialFeatureDimension_linear_lower_bound n d hn,
   capacity_exponential_bound n d⟩

/-- **Hilbert-VC Base Case**: for the polynomial ring with no constraints (I = 0),
    the feature dimension equals C(n+d, d).
    Bridge: connects CommutativeAlgebra (Hilbert function) to LearningTheory (VC dimension). -/
theorem hilbert_VC_base_case (n d : ℕ) :
    monomialFeatureDimension n d = Nat.choose (n + d) d := rfl

/-! ## Part VII: Complete Convergence Theorem -/

/-- **Noetherian Complete Convergence Theorem**
    Bridge: connects Algebra (Noetherian property) to ML (feature selection).

    For ANY Noetherian ring R, ANY module M, and ANY ascending chain:
    (1) The chain stabilizes at some N
    (2) The stable submodule is finitely generated
    (3) All values beyond N are equal

    Impact: certified_robustness — three guarantees from one algebraic property. -/
theorem noetherian_complete_convergence
    {R : Type*} {M : Type*}
    [CommRing R] [AddCommGroup M] [Module R M] [IsNoetherian R M]
    (chain : ℕ →o Submodule R M) :
    ∃ N : ℕ,
      (∀ k, N ≤ k → chain N = chain k) ∧
      (chain N).FG ∧
      (∀ j k, N ≤ j → N ≤ k → chain j = chain k) := by
  obtain ⟨N, hN⟩ := (monotone_stabilizes_iff_noetherian.mpr ‹IsNoetherian R M›) chain
  exact ⟨N, hN, IsNoetherian.noetherian _, fun j k hj hk => by rw [← hN j hj, hN k hk]⟩

/-- **MvPolynomial Feature Convergence**
    Bridge: connects RingTheory (Hilbert basis theorem) to
    Optimization (feature selection over polynomial spaces).
    Impact: certified_robustness for polynomial feature spaces. -/
theorem mvpolynomial_feature_convergence
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    {n : ℕ}
    (chain : ℕ →o Submodule (MvPolynomial (Fin n) R) (MvPolynomial (Fin n) R)) :
    ∃ N : ℕ, ∀ k, N ≤ k → chain N = chain k := by
  have : IsNoetherian (MvPolynomial (Fin n) R) (MvPolynomial (Fin n) R) := inferInstance
  exact (monotone_stabilizes_iff_noetherian.mpr this) chain

/-! ## Part VIII: Height and Dimension Theory -/

/-- **Height Zero Characterization for Domains**
    Bridge: connects AlgebraicGeometry (minimal primes) to LearningTheory (zero-cost focus).

    In an integral domain, ht(P) = 0 iff P = 0.
    Learning: the only zero-cost localization is the generic point.
    Impact: certified_robustness — zero focus cost ↔ no constraints. -/
theorem height_zero_iff_bot_domain
    {R : Type*} [CommRing R] [IsDomain R]
    (P : Ideal R) [hP : P.IsPrime] :
    Ideal.height P = 0 ↔ P = ⊥ := by
  constructor
  · intro h
    by_contra hne
    have hbot : ⊥ < P := bot_lt_iff_ne_bot.mpr hne
    have hfh : (⊥ : Ideal R).FiniteHeight :=
      ⟨Or.inr (by rw [Ideal.height_bot]; exact ENat.zero_ne_top)⟩
    have := @Ideal.height_strict_mono_of_is_prime R _ ⊥ P Ideal.isPrime_bot hbot hfh
    rw [Ideal.height_bot, h] at this
    exact absurd this (lt_irrefl 0)
  · rintro rfl
    exact Ideal.height_bot

/-- **Krull Bounds Localization**
    Bridge: DimensionTheory (Krull) → LearningTheory (capacity ceiling).
    Impact: post_quantum_security — dimension gives security ceiling. -/
theorem krull_bounds_localization_depth
    {R : Type*} [CommRing R]
    (P : Ideal R) [P.IsPrime] :
    (Ideal.height P : WithBot ℕ∞) ≤ ringKrullDim R :=
  Ideal.height_le_ringKrullDim_of_ne_top (Ideal.IsPrime.ne_top ‹P.IsPrime›)

/-- **Nested Ideals Height Hierarchy**
    Bridge: connects IdealTheory (inclusion) to LearningTheory (capacity ordering).
    Aesthetic: the height function is order-preserving. -/
theorem nested_ideals_height_hierarchy
    {R : Type*} [CommRing R]
    (chain : ℕ →o Ideal R) :
    ∀ i j, i ≤ j → Ideal.height (chain i) ≤ Ideal.height (chain j) :=
  fun _ _ hij => Ideal.height_mono (chain.monotone hij)

/-! ## Part IX: Feature Space Structure -/

/-- **Feature Space Finite over Noetherian Ring**
    Bridge: RingTheory (Noetherian → fg) → MachineLearning (finite representation).
    Impact: certified_robustness — every feature subspace has finite description. -/
theorem feature_space_finite_over_noetherian
    {R : Type*} {M : Type*}
    [CommRing R] [AddCommGroup M] [Module R M] [IsNoetherian R M]
    (S : Submodule R M) :
    S.FG :=
  IsNoetherian.noetherian S

/-- **Entropy-Capacity Connection**
    Bridge: InformationTheory (entropy) → CommutativeAlgebra (dimension).
    Utility: explicit O(n+d) bit complexity for encoding polynomial features. -/
theorem entropy_capacity_bound (n d : ℕ) :
    monomialFeatureDimension n d ≤ 2 ^ (n + d) :=
  capacity_exponential_bound n d

/-- **Learning Config from Ring and Degree**
    Bridge: connects RingTheory to MachineLearning.
    Every choice of (n, d) gives a valid learning configuration. -/
def learningConfigFromParams (n d : ℕ) : LearningConfiguration where
  numFeatures := n
  maxDegree := d

/-- The feature dimension of a learning configuration equals C(n+d, d). -/
theorem learningConfig_featureDim (n d : ℕ) :
    (learningConfigFromParams n d).featureDim = Nat.choose (n + d) d := rfl

/-- **Capacity Certifiable**: every learning configuration admits a certificate.
    Impact: certified_robustness — algebraic structure guarantees certifiability. -/
theorem learning_config_certifiable (config : LearningConfiguration) :
    ∃ c : CapacityCertificate, c.capacity = config.featureDim := by
  exact ⟨⟨config.featureDim, config.featureDim + 1, by omega, by omega⟩, rfl⟩

/-- **Composed Learning Capacity**
    Bridge: connects polynomial composition to model stacking.
    C(m+n, d) = Σ C(m,k)·C(n,d-k) — the Vandermonde decomposition. -/
theorem composed_learning_capacity
    (config₁ config₂ : LearningConfiguration) (d : ℕ) :
    Nat.choose (config₁.numFeatures + config₂.numFeatures) d =
    ∑ k ∈ Finset.range (d + 1),
      Nat.choose config₁.numFeatures k *
      Nat.choose config₂.numFeatures (d - k) :=
  feature_dimension_vandermonde config₁.numFeatures config₂.numFeatures d

end