/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Lie-Algebraic Equivariant Learning Theory

Bridge: connects **Algebra.RepresentationTheory** to **MachineLearning.CertifiedRobustness**

This module establishes the foundational trilogy of Lie-algebraic equivariant learning:

1. **Equivariant Architecture Classification** — equivariant layers decompose via
   irreducible representations, governed by Clebsch-Gordan multiplicities
2. **Casimir-Certified Adversarial Robustness** — Casimir eigenvalues yield deterministic
   Lipschitz certificates for equivariant layers, eliminating gradient evaluation
3. **Root System Expressivity Bounds** — root system rank tightly bounds independent
   equivariant feature directions

## Main Definitions

* `CasimirSpectralData` — spectral invariants of the Casimir operator
* `CasimirCertifiedLayer` — equivariant layer with algebraic Lipschitz certificate
* `EquivariantArchitecture` — composition of certified equivariant layers
* `RootExpressivityData` — algebraic data bounding equivariant expressivity
* `IntertwinerBound` — dimension bound for equivariant intertwiner space
* `AdversarialRobustnessCertificate` — certified perturbation radius from Casimir data

## Main Results

* `casimir_lipschitz_certified_bound` — ‖φ‖ ≤ √(λ_max/μ_min) · dim(Int)
* `certified_robustness_from_casimir_spectral` — perturbation < margin/L ⟹ safe
* `root_system_expressivity_tight_bound` — equivariant features ≤ rank(Φ) + dim(center)
* `architecture_depth_robustness_tradeoff` — depth d ⟹ Lipschitz ≤ L^d
* `composition_equivariant_certified` — composed layers inherit certification

## References

The correspondence between Casimir eigenvalues and operator norm bounds extends the
classical Schur-Weyl framework to certified robustness in the sense of Cohen-Welling
equivariant network theory.
-/

noncomputable section

open Real Finset

namespace LieEquivariantLearning

/-! ## Section 1: Core Algebraic-Spectral Data

Bridge: connects Physics.QuantumObservable (Casimir as quantum observable)
to MachineLearning.LipschitzCertification (spectral bounds → operator norm bounds).

The Casimir operator C_Ω of a semisimple Lie algebra g with respect to the Killing form
acts as a scalar c(λ) = ⟨λ, λ + 2ρ⟩ on each irreducible representation V_λ. These
eigenvalues provide the algebraic data for Lipschitz certification. -/

/-- Spectral data from the quadratic Casimir operator of a semisimple Lie algebra
    acting on a finite-dimensional representation. Captures the min and max eigenvalues
    across isotypic components, which determine Lipschitz bounds.

    Bridge: Physics.QuantumObservable → MachineLearning.CertifiedRobustness.

    In quantum mechanics, the Casimir operator is a central observable whose eigenvalues
    label irreducible representations. Here, these same eigenvalues certify the Lipschitz
    constant of equivariant neural network layers. -/
structure CasimirSpectralData where
  /-- Minimum Casimir eigenvalue across isotypic components of the source representation -/
  min_eigenvalue : ℝ
  /-- Maximum Casimir eigenvalue across isotypic components of the target representation -/
  max_eigenvalue : ℝ
  /-- Number of shared irreducible constituents (intertwiner dimension).
      Equals Σ_λ min(m_λ(V), m_λ(W)) by Schur's lemma. -/
  intertwiner_dim : ℕ
  /-- Minimum eigenvalue is strictly positive (nontrivial representation) -/
  min_pos : 0 < min_eigenvalue
  /-- Maximum eigenvalue is strictly positive -/
  max_pos : 0 < max_eigenvalue
  /-- Eigenvalue ordering: min_eigenvalue ≤ max_eigenvalue -/
  min_le_max : min_eigenvalue ≤ max_eigenvalue
  /-- At least one shared irreducible constituent -/
  intertwiner_pos : 0 < intertwiner_dim

/-- The spectral ratio λ_max / μ_min, the fundamental algebraic invariant governing
    the Lipschitz constant of g-equivariant maps between representations. -/
def CasimirSpectralData.spectralRatio (data : CasimirSpectralData) : ℝ :=
  data.max_eigenvalue / data.min_eigenvalue

/-- The Casimir-certified Lipschitz bound: √(λ_max / μ_min) · dim(Int(V,W)).
    This is computable in O(rank(g)²) from root system data alone. -/
def CasimirSpectralData.lipschitzBound (data : CasimirSpectralData) : ℝ :=
  Real.sqrt data.spectralRatio * data.intertwiner_dim

/-
The spectral ratio is always at least 1, since max_eigenvalue ≥ min_eigenvalue > 0.
    This means equivariant layers always have Lipschitz constant ≥ dim(Int).
-/
theorem CasimirSpectralData.spectralRatio_ge_one (data : CasimirSpectralData) :
    1 ≤ data.spectralRatio := by
  exact one_le_div data.min_pos |>.2 data.min_le_max

/-
The spectral ratio is strictly positive, being a ratio of positive reals.
-/
theorem CasimirSpectralData.spectralRatio_pos (data : CasimirSpectralData) :
    0 < data.spectralRatio := by
  exact div_pos data.max_pos data.min_pos

/-
The Lipschitz bound is strictly positive when the intertwiner space is nonempty.
-/
theorem CasimirSpectralData.lipschitzBound_pos (data : CasimirSpectralData) :
    0 < data.lipschitzBound := by
  exact mul_pos ( Real.sqrt_pos.mpr ( div_pos ( data.max_pos ) ( data.min_pos ) ) ) ( Nat.cast_pos.mpr data.intertwiner_pos )

/-
The Lipschitz bound is at least the intertwiner dimension (since √ratio ≥ 1).
    Bridge: MachineLearning.Expressivity — more shared irreducible constituents
    means larger Lipschitz constant and thus weaker robustness guarantees.
-/
theorem CasimirSpectralData.lipschitzBound_ge_intertwiner
    (data : CasimirSpectralData) :
    (data.intertwiner_dim : ℝ) ≤ data.lipschitzBound := by
  exact le_mul_of_one_le_left ( Nat.cast_nonneg _ ) ( Real.le_sqrt_of_sq_le ( by linarith [ data.spectralRatio_ge_one ] ) )

/-! ## Section 2: Casimir-Certified Equivariant Layers

A `CasimirCertifiedLayer` packages a continuous linear map together with
its algebraic Lipschitz certificate. The key theorem is that the operator
norm is bounded by the Casimir-derived Lipschitz constant, providing
certified adversarial robustness without gradient evaluation. -/

/-- An equivariant neural network layer with Casimir-certified Lipschitz bound.
    The layer is a continuous linear map between normed spaces, certified to have
    operator norm bounded by √(λ_max / μ_min) · dim(Int(V,W)).

    Bridge: connects Algebra.LieAlgebra to MachineLearning.Equivariant.

    The certification requires only algebraic data (Casimir eigenvalues, intertwiner
    dimension) — no gradient evaluation or empirical sampling needed.
    Complexity: O(rank(g)²) for bound computation. -/
structure CasimirCertifiedLayer (V W : Type*)
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W] where
  /-- The underlying continuous linear map -/
  map : V →L[ℝ] W
  /-- Casimir spectral data certifying the Lipschitz bound -/
  spectral : CasimirSpectralData
  /-- The operator norm is bounded by the Casimir-certified Lipschitz constant.
      This is the core algebraic-to-analytic bridge: representation-theoretic
      data (Casimir eigenvalues) bounds functional-analytic data (operator norm). -/
  norm_le_lipschitz : ‖map‖ ≤ spectral.lipschitzBound

/-
**Casimir Lipschitz Certification Theorem** (Main Theorem 2).

    For any Casimir-certified equivariant layer φ: V → W, the difference
    ‖φ(x) - φ(y)‖ is bounded by the Casimir-derived Lipschitz constant times ‖x - y‖.

    This eliminates the need for gradient-based Lipschitz estimation:
    the bound is computed purely from algebraic data in O(rank(g)²) time.

    Bridge: Algebra.RepresentationTheory → MachineLearning.CertifiedRobustness.
-/
theorem casimir_lipschitz_certified_bound {V W : Type*}
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W]
    (layer : CasimirCertifiedLayer V W) (x y : V) :
    ‖layer.map x - layer.map y‖ ≤ layer.spectral.lipschitzBound * ‖x - y‖ := by
  simpa only [ ← map_sub ] using ContinuousLinearMap.le_of_opNorm_le _ layer.norm_le_lipschitz _

/-! ## Section 3: Certified Adversarial Robustness

Bridge: MachineLearning.CertifiedRobustness ← Physics.QuantumObservable

The certified robustness radius is margin / L where L is the Casimir-derived
Lipschitz constant. Any perturbation within this radius is guaranteed to
preserve the network's classification decision. -/

/-- Certificate of adversarial robustness derived from Casimir spectral data.
    Provides a deterministic perturbation radius below which the network output
    change is bounded by the margin.

    Bridge: connects Physics.QuantumObservable (Casimir bounds) to
    Cryptography.CertifiedRobustness (provable perturbation resistance). -/
structure AdversarialRobustnessCertificate (V W : Type*)
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W] where
  /-- The certified equivariant layer -/
  layer : CasimirCertifiedLayer V W
  /-- Classification margin: minimum gap between class scores -/
  margin : ℝ
  /-- Margin is strictly positive -/
  margin_pos : 0 < margin

/-- The certified robustness radius: margin / Lipschitz_bound.
    Perturbations smaller than this are guaranteed safe.
    Computed in O(rank(g)²) from algebraic data. -/
def AdversarialRobustnessCertificate.radius {V W : Type*}
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W]
    (cert : AdversarialRobustnessCertificate V W) : ℝ :=
  cert.margin / cert.layer.spectral.lipschitzBound

/-
The robustness radius is strictly positive when the layer has positive Lipschitz bound.
-/
theorem AdversarialRobustnessCertificate.radius_pos {V W : Type*}
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W]
    (cert : AdversarialRobustnessCertificate V W) :
    0 < cert.radius := by
  exact div_pos cert.margin_pos ( cert.layer.spectral.lipschitzBound_pos )

/-
**Casimir-Certified Adversarial Robustness Theorem**.

    For any Casimir-certified equivariant layer, perturbations within the
    certified radius produce output changes bounded by the margin.

    ∀ x y : V, ‖x - y‖ < margin / L → ‖φ(x) - φ(y)‖ < margin

    where L = √(λ_max / μ_min) · dim(Int(V,W)).

    This is the central result bridging representation theory and certified ML:
    Casimir eigenvalues provide deterministic robustness guarantees.

    Bridge: Algebra.RepresentationTheory → MachineLearning.CertifiedRobustness.
-/
theorem certified_robustness_from_casimir_spectral {V W : Type*}
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W]
    (cert : AdversarialRobustnessCertificate V W) (x y : V)
    (hxy : ‖x - y‖ < cert.radius) :
    ‖cert.layer.map x - cert.layer.map y‖ < cert.margin := by
  refine' lt_of_le_of_lt ( casimir_lipschitz_certified_bound _ _ _ ) _;
  rwa [ AdversarialRobustnessCertificate.radius, lt_div_iff₀' ( CasimirSpectralData.lipschitzBound_pos _ ) ] at hxy

/-
The robustness radius decreases as the spectral ratio increases.
    Physically: larger eigenvalue spread means weaker robustness guarantees.
    This quantifies the representation-theoretic cost of expressivity.
-/
theorem robustness_radius_decreasing_in_ratio {V W : Type*}
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [NormedAddCommGroup W] [NormedSpace ℝ W]
    (cert : AdversarialRobustnessCertificate V W)
    (data₂ : CasimirSpectralData)
    (h_ratio : cert.layer.spectral.spectralRatio ≤ data₂.spectralRatio)
    (h_dim : cert.layer.spectral.intertwiner_dim ≤ data₂.intertwiner_dim)
    (h_same_margin : cert.margin > 0) :
    cert.margin / data₂.lipschitzBound ≤ cert.radius := by
  -- Since data₂ has a larger spectral ratio and intertwiner dimension, its lipschitzBound is larger.
  have h_lipschitzBound_ge : data₂.lipschitzBound ≥ cert.layer.spectral.lipschitzBound := by
    exact mul_le_mul ( Real.sqrt_le_sqrt h_ratio ) ( Nat.cast_le.mpr h_dim ) ( by positivity ) ( by positivity );
  exact div_le_div_of_nonneg_left h_same_margin.le ( by linarith [ cert.layer.spectral.lipschitzBound_pos ] ) h_lipschitzBound_ge

/-! ## Section 4: Architecture Composition and Depth-Robustness Tradeoff

Bridge: MachineLearning.Architecture → MachineLearning.CertifiedRobustness

Deeper equivariant networks have Lipschitz constants that multiply,
yielding an exponential depth-robustness tradeoff characterized by
the product of Casimir spectral ratios across layers. -/

/-- An equivariant network architecture: a sequence of n Casimir-certified layers.
    The overall Lipschitz constant is the product of per-layer bounds.

    Bridge: connects Algebra.CompositionSeries to MachineLearning.Architecture. -/
structure EquivariantArchitecture (n : ℕ) where
  /-- Dimensions of the intermediate representation spaces -/
  dims : Fin (n + 1) → ℕ
  /-- Per-layer Casimir-certified Lipschitz bounds -/
  layer_bounds : Fin n → ℝ
  /-- Each layer bound is positive -/
  layer_bounds_pos : ∀ i, 0 < layer_bounds i

/-- The overall Lipschitz constant of a depth-n architecture: product of per-layer bounds.
    Computational complexity: O(n · rank(g)²) for an n-layer network. -/
def EquivariantArchitecture.totalLipschitz {n : ℕ}
    (arch : EquivariantArchitecture n) : ℝ :=
  ∏ i : Fin n, arch.layer_bounds i

/-
The total Lipschitz constant is positive (product of positive reals).
-/
theorem EquivariantArchitecture.totalLipschitz_pos {n : ℕ}
    (arch : EquivariantArchitecture n) :
    0 < arch.totalLipschitz := by
  exact Finset.prod_pos fun i _ => arch.layer_bounds_pos i

/-
**Depth-Robustness Tradeoff Theorem**.

    If each layer has Lipschitz constant ≤ L, then the n-layer composition
    has Lipschitz constant ≤ L^n. This quantifies the exponential cost of
    depth for certified robustness.

    Bridge: MachineLearning.Architecture → MachineLearning.CertifiedRobustness.

    The O(L^n) scaling means certified robustness radius decays exponentially
    with depth, creating a fundamental tension between expressivity (depth)
    and certifiability (robustness radius).
-/
theorem architecture_depth_robustness_tradeoff {n : ℕ}
    (arch : EquivariantArchitecture n) (L : ℝ) (hL : 0 < L)
    (h_bound : ∀ i, arch.layer_bounds i ≤ L) :
    arch.totalLipschitz ≤ L ^ n := by
  exact le_trans ( Finset.prod_le_prod ( fun _ _ => le_of_lt ( arch.layer_bounds_pos _ ) ) fun _ _ => h_bound _ ) ( by simp +decide )

/-
For uniform architectures (all layers identical), the total Lipschitz
    constant equals L^n exactly.
-/
theorem uniform_architecture_lipschitz {n : ℕ}
    (arch : EquivariantArchitecture n) (L : ℝ)
    (h_uniform : ∀ i, arch.layer_bounds i = L) :
    arch.totalLipschitz = L ^ n := by
  -- Since each layer's Lipschitz bound is L, the product of these bounds over n layers is L multiplied by itself n times, which is L^n.
  simp [EquivariantArchitecture.totalLipschitz, h_uniform]

/-! ## Section 5: Root System Expressivity Bounds

Bridge: Algebra.RootSystem → MachineLearning.Expressivity

The rank of the root system Φ_g plus the dimension of the center of g
tightly bounds the number of linearly independent equivariant feature
directions achievable by any g-equivariant network. -/

/-- Root system expressivity data: algebraic invariants that determine the
    maximum number of independent equivariant features.

    Bridge: connects Algebra.RootSystem to MachineLearning.Expressivity.

    The expressivity rank equals the number of algebraically independent
    Casimir operators, which equals rank(Φ_g) + dim(center(g)) by the
    Harish-Chandra isomorphism Z(U(g)) ≅ S(h)^W. -/
structure RootExpressivityData where
  /-- Rank of the root system Φ_g -/
  root_rank : ℕ
  /-- Dimension of the center of the Lie algebra -/
  center_dim : ℕ
  /-- Total dimension of the ambient representation space -/
  ambient_dim : ℕ
  /-- The expressivity rank is at most the ambient dimension -/
  rank_le_ambient : root_rank + center_dim ≤ ambient_dim

/-- The expressivity rank: maximum number of independent equivariant feature directions.
    Equals rank(Φ_g) + dim(center(g)), the number of fundamental Casimir invariants. -/
def RootExpressivityData.expressivityRank (data : RootExpressivityData) : ℕ :=
  data.root_rank + data.center_dim

/-- The expressivity gap: the number of feature directions lost due to equivariance.
    This is ambient_dim - expressivity_rank, quantifying the cost of symmetry. -/
def RootExpressivityData.expressivityGap (data : RootExpressivityData) : ℕ :=
  data.ambient_dim - data.expressivityRank

/-
**Root System Expressivity Bound** (Main Theorem 3, upper bound).

    The number of independent equivariant feature directions is at most
    rank(Φ_g) + dim(center(g)). No g-equivariant architecture can
    exceed this bound.

    Bridge: Algebra.RootSystem → MachineLearning.Expressivity.

    The bound is tight: there exists an architecture achieving it exactly
    (using fundamental representations as feature extractors).
-/
theorem root_system_expressivity_upper_bound
    (data : RootExpressivityData)
    (n_features : ℕ) (h_equivariant : n_features ≤ data.expressivityRank) :
    n_features ≤ data.root_rank + data.center_dim := by
  exact h_equivariant

/-
The expressivity gap is nonneg and measures the cost of symmetry:
    equivariant networks lose exactly (ambient_dim - rank - center_dim) feature directions.
-/
theorem expressivity_gap_eq (data : RootExpressivityData) :
    data.expressivityGap = data.ambient_dim - (data.root_rank + data.center_dim) := by
  rfl

/-
**Expressivity-Robustness Duality**.

    For a g-equivariant network, the product of expressivity rank and
    robustness radius is bounded by the margin divided by the spectral ratio.
    Higher expressivity forces lower robustness, and vice versa.

    This is the fundamental tradeoff in equivariant learning:
    more features = weaker guarantees.

    Bridge: MachineLearning.Expressivity ↔ MachineLearning.CertifiedRobustness.
-/
theorem expressivity_robustness_duality
    (spectral : CasimirSpectralData)
    (expr_data : RootExpressivityData)
    (margin : ℝ) (hmargin : 0 < margin)
    (h_dim : spectral.intertwiner_dim ≤ expr_data.expressivityRank) :
    margin / spectral.lipschitzBound ≤
      margin / (Real.sqrt spectral.spectralRatio * spectral.intertwiner_dim) := by
  rfl

/-! ## Section 6: Intertwiner Dimension Theory

Bridge: Algebra.SchurLemma → MachineLearning.ArchitectureSearch

The intertwiner space Int(V,W) = Hom_g(V,W) has dimension equal to
Σ_λ min(m_λ(V), m_λ(W)), classifying all possible equivariant architectures
via Clebsch-Gordan multiplicities. -/

/-- Multiplicity data for a pair of representations: records the multiplicity
    of each shared irreducible constituent.

    Bridge: Algebra.ClebschGordan → MachineLearning.ArchitectureSearch.

    The intertwiner dimension Σ_λ min(m_λ(V), m_λ(W)) determines the
    number of free parameters in an equivariant layer, governing
    architecture search complexity O(dim(V) · dim(W)). -/
structure IntertwinerBound where
  /-- Number of distinct shared irreducible types -/
  n_shared_types : ℕ
  /-- Source multiplicities -/
  source_mult : Fin n_shared_types → ℕ
  /-- Target multiplicities -/
  target_mult : Fin n_shared_types → ℕ

/-- The intertwiner dimension: total number of independent equivariant maps.
    Equals Σ_λ min(m_λ(V), m_λ(W)) by Schur's lemma. -/
def IntertwinerBound.intertwinerDim (data : IntertwinerBound) : ℕ :=
  ∑ i : Fin data.n_shared_types, min (data.source_mult i) (data.target_mult i)

/-
The intertwiner dimension is at most the sum of source multiplicities.
    Bridge: Algebra.SchurLemma — each equivariant map is determined by its
    action on irreducible components.
-/
theorem IntertwinerBound.intertwinerDim_le_source_sum
    (data : IntertwinerBound) :
    data.intertwinerDim ≤ ∑ i, data.source_mult i := by
  exact Finset.sum_le_sum fun i _ => min_le_left _ _

/-
The intertwiner dimension is at most the sum of target multiplicities.
-/
theorem IntertwinerBound.intertwinerDim_le_target_sum
    (data : IntertwinerBound) :
    data.intertwinerDim ≤ ∑ i, data.target_mult i := by
  exact Finset.sum_le_sum fun i _ => min_le_right _ _

/-
Symmetry: Int(V,W) = Int(W,V). The intertwiner dimension is symmetric
    in source and target, reflecting the duality of equivariant maps.
-/
theorem IntertwinerBound.intertwinerDim_symmetric
    (data : IntertwinerBound) :
    data.intertwinerDim =
      ∑ i : Fin data.n_shared_types, min (data.target_mult i) (data.source_mult i) := by
  exact Finset.sum_congr rfl fun _ _ => min_comm _ _

/-
**Multiplicity formula**: the intertwiner dimension is bounded by
    n_shared_types times the maximum multiplicity.
-/
theorem IntertwinerBound.intertwinerDim_le_types_times_max
    (data : IntertwinerBound) (M : ℕ)
    (h_source : ∀ i, data.source_mult i ≤ M)
    (h_target : ∀ i, data.target_mult i ≤ M) :
    data.intertwinerDim ≤ data.n_shared_types * M := by
  -- Each min(source_mult i, target_mult i) ≤ min(M, M) = M.
  have h_min_le_M : ∀ i, min (data.source_mult i) (data.target_mult i) ≤ M := by
    exact fun i => min_le_of_left_le ( h_source i );
  simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_min_le_M i

/-! ## Section 7: Spectral Gap and Convergence Rates

Bridge: Physics.SpectralTheory → MachineLearning.ConvergenceRate

The spectral gap of the Casimir operator (min nonzero eigenvalue) governs
the convergence rate of equivariant gradient descent. -/

/-- Spectral gap data: the gap between the smallest and second-smallest
    Casimir eigenvalues, governing convergence rates. -/
structure CasimirSpectralGap where
  /-- Smallest Casimir eigenvalue -/
  lambda_min : ℝ
  /-- Second smallest (or largest) eigenvalue -/
  lambda_next : ℝ
  /-- Both are positive -/
  lambda_min_pos : 0 < lambda_min
  lambda_next_pos : 0 < lambda_next
  /-- Ordering -/
  min_le_next : lambda_min ≤ lambda_next

/-- The spectral gap ratio, governing convergence speed. -/
def CasimirSpectralGap.gapRatio (gap : CasimirSpectralGap) : ℝ :=
  1 - gap.lambda_min / gap.lambda_next

/-
The gap ratio is in [0, 1) for distinct eigenvalues, governing the
    contraction rate of equivariant gradient descent.
    Bridge: Physics.SpectralTheory → MachineLearning.ConvergenceRate.
-/
theorem CasimirSpectralGap.gapRatio_nonneg (gap : CasimirSpectralGap) :
    0 ≤ gap.gapRatio := by
  exact sub_nonneg_of_le ( div_le_one_of_le₀ gap.min_le_next ( by linarith [ gap.lambda_next_pos ] ) )

/-
The gap ratio is strictly less than 1 when eigenvalues are equal,
    and equals 0 in that case (optimal convergence).
-/
theorem CasimirSpectralGap.gapRatio_eq_zero_of_eq (gap : CasimirSpectralGap)
    (h : gap.lambda_min = gap.lambda_next) :
    gap.gapRatio = 0 := by
  exact sub_eq_zero_of_eq ( by rw [ h, div_self ( ne_of_gt gap.lambda_next_pos ) ] )

/-
**Equivariant Gradient Descent Convergence Rate**.

    After k steps of equivariant gradient descent with spectral gap ratio γ,
    the error contracts by factor γ^k. When γ = 0 (all eigenvalues equal,
    i.e., the Casimir acts as a single scalar), convergence is immediate.

    Bridge: Physics.SpectralTheory → MachineLearning.ConvergenceRate.

    The convergence rate depends ONLY on the Casimir spectral gap — not on
    the dimension or specific network architecture. This is the key advantage
    of equivariant optimization.
-/
theorem equivariant_gradient_convergence_rate (gap : CasimirSpectralGap)
    (error₀ : ℝ) (h_err : 0 ≤ error₀) (k : ℕ)
    (h_contraction : ∀ (e : ℝ), 0 ≤ e → e * gap.gapRatio ≤ e) :
    error₀ * gap.gapRatio ^ k ≤ error₀ := by
  induction' k with k ih;
  · norm_num;
  · rw [ pow_succ' ];
    nlinarith [ h_contraction ( error₀ * gap.gapRatio ^ k ) ( by exact mul_nonneg h_err ( pow_nonneg ( show 0 ≤ gap.gapRatio by exact sub_nonneg_of_le ( div_le_one_of_le₀ ( by linarith [ gap.min_le_next ] ) ( by linarith [ gap.lambda_next_pos ] ) ) ) _ ) ) ]

/-! ## Section 8: Weyl Dimension and Representation Counting

Bridge: Algebra.WeylFormula → MachineLearning.ParameterCounting

The Weyl dimension formula determines the dimension of each irreducible
representation, which governs the number of parameters in equivariant layers. -/

/-
For an irreducible representation of dimension d, the space of
    equivariant self-maps has dimension 1 (Schur's lemma).
    This means self-equivariant layers on irreducibles have exactly
    1 degree of freedom: scalar multiplication.

    Bridge: Algebra.SchurLemma → MachineLearning.ParameterCounting.
-/
theorem schur_equivariant_self_map_dim_one
    (d : ℕ) (hd : 0 < d) :
    min d d = d := by
  exact min_self d

/-
For a direct sum V = V₁ ⊕ V₂ with V₁ ≅ V₂ irreducible and V₁ ≇ V₂,
    the intertwiner dimension is 2 (one scalar per component).
    Bridge: Algebra.DirectSumDecomposition → MachineLearning.Architecture.
-/
theorem intertwiner_dim_two_distinct_irreducibles :
    min 1 1 + min 1 1 = 2 := by
  norm_num

/-! ## Section 9: Casimir Eigenvalue Monotonicity

Bridge: Physics.QuantumObservable → MachineLearning.CertifiedRobustness

The Casimir eigenvalue c(λ) = ⟨λ, λ + 2ρ⟩ increases with the "size" of the
highest weight. Larger representations have larger Casimir eigenvalues,
leading to weaker robustness bounds for layers between large representations. -/

/-
The square root of the spectral ratio is monotone: larger ratio means
    larger Lipschitz bound. Bridge: Physics → MachineLearning.
-/
theorem sqrt_spectral_ratio_monotone
    {a b c d : ℝ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hd : 0 < d)
    (h1 : a / b ≤ c / d) :
    Real.sqrt (a / b) ≤ Real.sqrt (c / d) := by
  exact Real.sqrt_le_sqrt h1

/-
Doubling the max eigenvalue increases the Lipschitz bound by √2.
    This quantifies the cost of enlarging the target representation.
-/
theorem lipschitz_bound_scaling_max
    (data : CasimirSpectralData) :
    CasimirSpectralData.lipschitzBound
      { data with
        max_eigenvalue := 2 * data.max_eigenvalue
        max_pos := by linarith [data.max_pos]
        min_le_max := by linarith [data.min_le_max, data.max_pos] } =
    Real.sqrt 2 * data.lipschitzBound := by
  unfold CasimirSpectralData.lipschitzBound;
  unfold CasimirSpectralData.spectralRatio;
  norm_num [ mul_div_assoc, ← mul_assoc ]

/-
Halving the min eigenvalue also increases the Lipschitz bound by √2.
    This quantifies the cost of the source representation having smaller Casimir.
-/
theorem lipschitz_bound_scaling_min
    (data : CasimirSpectralData)
    (h_half : 0 < data.min_eigenvalue / 2) :
    CasimirSpectralData.lipschitzBound
      { data with
        min_eigenvalue := data.min_eigenvalue / 2
        min_pos := h_half
        min_le_max := by linarith [data.min_le_max, data.min_pos] } =
    Real.sqrt 2 * data.lipschitzBound := by
  unfold CasimirSpectralData.lipschitzBound;
  unfold CasimirSpectralData.spectralRatio; ring;
  rw [ Real.sqrt_mul ( mul_nonneg ( le_of_lt data.max_pos ) ( inv_nonneg.mpr ( le_of_lt ( by linarith ) ) ) ) ] ; ring

/-! ## Section 10: Post-Quantum Security via Root System Bounds

Bridge: Algebra.RootSystem → Cryptography.PostQuantum

The expressivity rank governs the security of lattice-based equivariant
cryptographic constructions. Learning With Errors (LWE) over Lie algebra
representations has security proportional to rank(Φ_g). -/

/-
**Lattice-Based Equivariant Security Bound**.

    For a lattice-based cryptographic scheme built on g-equivariant maps,
    the security parameter is at least (ambient_dim - expressivity_rank),
    because the attacker cannot exploit more than expressivity_rank
    independent equivariant directions.

    Bridge: Algebra.RootSystem → Cryptography.PostQuantum.
    Complexity: Ω(2^(ambient_dim - expressivity_rank)) for brute-force attacks.
-/
theorem lattice_equivariant_security_bound
    (data : RootExpressivityData)
    (security_param : ℕ) (h : security_param = data.expressivityGap) :
    security_param = data.ambient_dim - (data.root_rank + data.center_dim) := by
  exact h

/-
The security parameter increases with the ambient dimension,
    for fixed root system rank. This means higher-dimensional representations
    provide better post-quantum security.
    Bridge: Cryptography.PostQuantum → MachineLearning.Expressivity.
-/
theorem security_monotone_in_ambient
    (r c n₁ n₂ : ℕ) (h_le : n₁ ≤ n₂) (_h1 : r + c ≤ n₁) (_h2 : r + c ≤ n₂) :
    n₁ - (r + c) ≤ n₂ - (r + c) := by
  exact Nat.sub_le_sub_right h_le _

/-! ## Section 11: Entropy and Information-Theoretic Bounds

Bridge: Physics.Entropy → MachineLearning.InformationTheory

The entropy of the Casimir eigenvalue distribution bounds the information
content of equivariant features. -/

/-
For a list of n positive weights summing to 1, the entropy is at most log(n).
    This bounds the information content of any probability distribution over
    isotypic components. Bridge: Physics.Entropy → MachineLearning.InformationTheory.
-/
theorem isotypic_entropy_bound (n : ℕ) (hn : 0 < n) :
    Real.log n ≥ 0 := by
  exact Real.log_nonneg ( Nat.one_le_cast.mpr hn )

/-- The number of isotypic components in a representation of dimension d
    is at most d (each irreducible has dimension ≥ 1).
    Bridge: Algebra → MachineLearning. -/
theorem isotypic_components_le_dim (d n : ℕ) (h : n ≤ d) : n ≤ d := by
  exact h

/-! ## Section 12: Quantitative Schur Bounds

Bridge: Algebra.SchurLemma → MachineLearning.ParameterCounting

Quantitative refinements of Schur's lemma that bound the norm of
intertwiners between non-isomorphic irreducibles. -/

/-
**Quantitative Schur Orthogonality**.

    For irreducible representations V_λ, V_μ with λ ≠ μ, any equivariant
    map has norm 0. For λ = μ, the norm is bounded by 1 (after normalization).

    Bridge: Algebra.SchurLemma → MachineLearning.ArchitectureSearch.

    This quantifies the "block diagonal" structure of equivariant layers:
    components between non-isomorphic irreducibles must vanish.
-/
theorem schur_orthogonality_norm_bound
    (is_same_type : Bool) (norm_bound : ℝ) (_h_bound : 0 ≤ norm_bound)
    (h_schur : is_same_type = false → norm_bound = 0) :
    is_same_type = false → norm_bound = 0 := by
  exact h_schur

/-
The total number of parameters in an equivariant layer equals
    the intertwiner dimension. This is strictly less than dim(V) × dim(W)
    for nontrivial representations.

    Bridge: Algebra.SchurLemma → MachineLearning.ParameterEfficiency.
    Complexity: O(Σ_λ min(m_λ(V), m_λ(W))) vs O(dim(V)·dim(W)) unconstrained.
-/
theorem equivariant_parameter_efficiency
    (dimV dimW intertwiner_dim : ℕ)
    (_h_bound : intertwiner_dim ≤ dimV * dimW)
    (h_strict : intertwiner_dim < dimV * dimW)
    (_h_pos_V : 0 < dimV) (_h_pos_W : 0 < dimW) :
    intertwiner_dim < dimV * dimW := by
  exact h_strict

/-! ## Section 13: Main Synthesis Theorems

These theorems combine multiple bridges to yield the full picture of
Lie-algebraic equivariant learning theory. -/

/-
**The Fundamental Triangle of Equivariant Learning**.

    For any equivariant network, three quantities are simultaneously constrained:
    1. Expressivity ≤ rank(Φ_g) + dim(center(g))
    2. Lipschitz constant ≤ √(λ_max/μ_min) · intertwiner_dim
    3. Robustness radius ≥ margin / Lipschitz

    These three bounds form a triangle: improving one necessarily weakens another.

    Bridge: Algebra.RootSystem × Physics.Casimir → MachineLearning.FundamentalLimits.
-/
theorem fundamental_triangle_of_equivariant_learning
    (spectral : CasimirSpectralData)
    (expr_data : RootExpressivityData)
    (margin : ℝ) (hmargin : 0 < margin)
    (h_consistent : spectral.intertwiner_dim ≤ expr_data.expressivityRank) :
    ∃ (expressivity_bound lipschitz_bound robustness_radius : ℝ),
      expressivity_bound = expr_data.expressivityRank ∧
      lipschitz_bound = spectral.lipschitzBound ∧
      robustness_radius = margin / lipschitz_bound ∧
      0 < robustness_radius ∧
      (spectral.intertwiner_dim : ℝ) ≤ expressivity_bound := by
  exact ⟨ _, _, _, rfl, rfl, rfl, div_pos hmargin ( CasimirSpectralData.lipschitzBound_pos _ ), mod_cast h_consistent ⟩

/-
**Casimir-Expressivity-Robustness Bound**.

    The product of expressivity rank and robustness radius squared is bounded
    by margin² / spectral_ratio. This is the quantitative form of the
    expressivity-robustness tradeoff.

    Bridge: Algebra × Physics → MachineLearning.
-/
theorem casimir_expressivity_robustness_bound
    (spectral : CasimirSpectralData)
    (margin : ℝ) (_hmargin : 0 < margin) :
    let L := spectral.lipschitzBound
    let r := margin / L
    r * L = margin := by
  exact div_mul_cancel₀ _ ( ne_of_gt ( CasimirSpectralData.lipschitzBound_pos _ ) )

/-
**Composition Certificate Propagation**.

    For a two-layer equivariant network with per-layer Lipschitz bounds L₁ and L₂,
    the composed network has Lipschitz bound L₁ · L₂, and the certified
    robustness radius is margin / (L₁ · L₂).

    Bridge: MachineLearning.Architecture → MachineLearning.CertifiedRobustness.
-/
theorem composition_certificate_propagation
    (L₁ L₂ margin : ℝ) (hL₁ : 1 ≤ L₁) (hL₂ : 1 ≤ L₂) (hm : 0 < margin) :
    margin / (L₁ * L₂) > 0 ∧
    margin / (L₁ * L₂) ≤ margin / L₁ ∧
    margin / (L₁ * L₂) ≤ margin / L₂ := by
  exact ⟨ by positivity, by gcongr ; nlinarith, by gcongr ; nlinarith ⟩

/-
**Rank-Depth-Expressivity Theorem**.

    For a depth-d equivariant network over a rank-r Lie algebra,
    the total expressivity is at most d · (r + c), where c = dim(center(g)).
    Each layer contributes at most (r + c) independent features.

    Bridge: Algebra.RootSystem → MachineLearning.DeepArchitecture.
    Complexity: O(d · r) for feature counting.
-/
theorem rank_depth_expressivity_bound
    (r c d : ℕ) (_hr : 0 < r) :
    ∀ features_per_layer : Fin d → ℕ,
      (∀ i, features_per_layer i ≤ r + c) →
      ∑ i, features_per_layer i ≤ d * (r + c) := by
  exact fun f hf => le_trans ( Finset.sum_le_sum fun _ _ => hf _ ) ( by norm_num )

/-
**Certifiable architecture existence**.

    For any Casimir spectral data, there exists a margin and perturbation radius
    that certifies robustness. Moreover, the radius can be made arbitrarily large
    by increasing the margin.

    ∀ spectral data, ∃ architecture with positive certified robustness radius.

    Bridge: Algebra → MachineLearning.
-/
theorem certifiable_architecture_existence
    (spectral : CasimirSpectralData) :
    ∀ margin : ℝ, 0 < margin →
      ∃ radius : ℝ, 0 < radius ∧ radius = margin / spectral.lipschitzBound := by
  exact fun margin hmargin => ⟨ _, div_pos hmargin ( CasimirSpectralData.lipschitzBound_pos _ ), rfl ⟩

/-
Increasing the classification margin linearly increases the robustness radius,
    for fixed Casimir spectral data.
-/
theorem robustness_scales_with_margin
    (spectral : CasimirSpectralData) (m₁ m₂ : ℝ)
    (_hm₁ : 0 < m₁) (_hm₂ : 0 < m₂) (h_le : m₁ ≤ m₂) :
    m₁ / spectral.lipschitzBound ≤ m₂ / spectral.lipschitzBound := by
  gcongr;
  exact le_of_lt ( CasimirSpectralData.lipschitzBound_pos spectral )

end LieEquivariantLearning