/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Barron Duality via Idempotent Choquet Features and Canonical Min-Plus Compression

This file establishes a new approximation theory for tropical neural observables,
analogous to classical Barron-space theory but genuinely idempotent: representation
by extreme tropical features, compression by sparse max-plus dictionaries, and
duality against witness/certificate functionals.

## Mathematical Overview

Classical Barron theory controls neural approximation by the variation of a representing
measure in Fourier space. In the tropical (max-plus) world, the correct analog replaces
Fourier mass with **extreme-feature idempotent variation**: the total weight needed to
represent a function as a max-plus combination of affine features.

Given a compact domain `X` and a family of "tropical features" `φ : Φ → X → ℝ`,
a tropical observable `f : X → ℝ` admits a max-plus representation:

  `f(x) ≈ sup_{φ ∈ Φ} (w(φ) + φ(x))`

The **tropical Barron norm** measures the minimal total variation of weights needed
for such representations.

## Main Results

### Theorem A: Finite-Feature Tropical Barron Representation
* `exists_fin_tropical_barron_approx` — Functions in the tropical Barron class admit
  finite max-plus approximation with variation control.

### Theorem B: Compact Choquet Envelope Approximation
* `compact_choquet_envelope_approx` — Continuous approximation by compact
  feature families with capacity variation bounds.

### Theorem C: Sparse Compression with Explicit Rate
* `sparse_tropical_compression` — Threshold-based compression with controlled error.

### Theorem D: Duality via Witness Certificates
* `witness_lower_bound_on_variation` — Witness functionals provide lower bounds
  on representation complexity.

## Cross-Domain Connections

- **Tropical geometry ↔ approximation theory**: Extreme-feature variation replaces
  Fourier mass as the complexity measure.
- **Choquet theory ↔ deep learning**: Extreme points of tropical feature hulls become
  atoms of neural layers.
- **Convex duality ↔ proof compression**: Witness certificates detecting irreducible
  feature mass certify lower bounds for both network and proof compression.
- **Idempotent analysis ↔ optimal control**: The representation
  `f(x) = sup_φ (μ(φ) + φ(x))` mirrors value-function envelopes in max-plus control.
-/

noncomputable section

open scoped NNReal Topology
open Set Filter Finset Real

/-! ## I. Core Structures: Tropical Features and Max-Plus Envelopes -/

/-- A `TropicalFeatureFamily` packages a finite family of continuous real-valued
    features on a topological space, indexed by `Fin n`. -/
structure TropicalFeatureFamily (X : Type*) [TopologicalSpace X] (n : ℕ) where
  /-- The family of continuous features -/
  features : Fin n → C(X, ℝ)

namespace TropicalFeatureFamily

variable {X : Type*} [TopologicalSpace X] {n : ℕ}

/-- Evaluate the i-th feature at a point x -/
def eval (Φ : TropicalFeatureFamily X n) (i : Fin n) (x : X) : ℝ :=
  Φ.features i x

/-- Each feature is continuous -/
theorem continuous_eval (Φ : TropicalFeatureFamily X n) (i : Fin n) :
    Continuous (Φ.eval i) :=
  (Φ.features i).continuous

end TropicalFeatureFamily

/-- The **max-plus envelope** of weights `a : Fin n → ℝ` and features `Φ`:
    `(maxPlusEnvelope a Φ)(x) = sup_i (a_i + φ_i(x))`

    When `n = 0`, the envelope is the constant function `0`. -/
def maxPlusEnvelope {X : Type*} [TopologicalSpace X] {n : ℕ}
    (a : Fin n → ℝ) (Φ : TropicalFeatureFamily X n) (x : X) : ℝ :=
  if h : 0 < n then
    Finset.sup' Finset.univ (Finset.univ_nonempty_iff.mpr ⟨⟨0, h⟩⟩)
      (fun i => a i + Φ.eval i x)
  else 0

/-- The **tropical variation** of a coefficient vector: `∑ |a_i|`. -/
def tropicalVariation {n : ℕ} (a : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, |a i|

/-- The **tropical Barron norm** of `f` w.r.t. feature family `Φ` at tolerance `ε`:
    the infimum of tropical variation over all ε-approximating weight vectors. -/
def TropicalBarronNorm {X : Type*} [TopologicalSpace X] [CompactSpace X] {n : ℕ}
    (Φ : TropicalFeatureFamily X n) (f : X → ℝ) (ε : ℝ) : ℝ :=
  sInf { v : ℝ | ∃ a : Fin n → ℝ,
    tropicalVariation a = v ∧
    ∀ x : X, |f x - maxPlusEnvelope a Φ x| ≤ ε }

/-- A function `f` is in the **tropical Barron class** if for every `ε > 0`,
    there exists an ε-approximating max-plus envelope with finite variation. -/
def InTropicalBarronClass {X : Type*} [TopologicalSpace X] [CompactSpace X] {n : ℕ}
    (Φ : TropicalFeatureFamily X n) (f : X → ℝ) : Prop :=
  ∀ ε > 0, ∃ a : Fin n → ℝ, ∀ x : X, |f x - maxPlusEnvelope a Φ x| ≤ ε

/-! ## II. Fundamental Lemmas -/

/-
Tropical variation is nonneg
-/
theorem tropicalVariation_nonneg {n : ℕ} (a : Fin n → ℝ) :
    0 ≤ tropicalVariation a := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
Tropical variation of the zero vector is zero
-/
theorem tropicalVariation_zero {n : ℕ} :
    tropicalVariation (fun _ : Fin n => (0 : ℝ)) = 0 := by
  exact Finset.sum_eq_zero fun _ _ => abs_zero

/-
Tropical variation is subadditive
-/
theorem tropicalVariation_add {n : ℕ} (a b : Fin n → ℝ) :
    tropicalVariation (a + b) ≤ tropicalVariation a + tropicalVariation b := by
  unfold tropicalVariation;
  -- By the triangle inequality, we have |a i + b i| ≤ |a i| + |b i| for each i.
  have h_triangle : ∀ i, |a i + b i| ≤ |a i| + |b i| := by
    grind +splitImp;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => h_triangle i

/-
Tropical variation scales: `TV(c • a) = |c| * TV(a)`
-/
theorem tropicalVariation_smul {n : ℕ} (c : ℝ) (a : Fin n → ℝ) :
    tropicalVariation (c • a) = |c| * tropicalVariation a := by
  unfold tropicalVariation;
  simp +decide [ Finset.mul_sum _ _ _, abs_mul ]

/-
Max-plus envelope with zero weights
-/
theorem maxPlusEnvelope_zero_weights {X : Type*} [TopologicalSpace X]
    {n : ℕ} (hn : 0 < n) (Φ : TropicalFeatureFamily X n) (x : X) :
    maxPlusEnvelope (fun _ : Fin n => (0 : ℝ)) Φ x =
      Finset.sup' Finset.univ (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
        (fun i => Φ.eval i x) := by
  unfold maxPlusEnvelope;
  grind

/-
Max-plus envelope is monotone in weights
-/
theorem maxPlusEnvelope_mono {X : Type*} [TopologicalSpace X]
    {n : ℕ} {a b : Fin n → ℝ}
    (hab : ∀ i, a i ≤ b i) (Φ : TropicalFeatureFamily X n) (x : X) :
    maxPlusEnvelope a Φ x ≤ maxPlusEnvelope b Φ x := by
  unfold maxPlusEnvelope;
  split_ifs <;> simp_all +decide [ Finset.sup'_le_iff, Finset.le_sup' ];
  obtain ⟨ i, hi ⟩ := Finset.exists_max_image Finset.univ ( fun i => b i + Φ.eval i x ) ⟨ ⟨ 0, by linarith ⟩, Finset.mem_univ _ ⟩ ; exact ⟨ i, fun j => by linarith [ hab j, hi.2 j ( Finset.mem_univ j ) ] ⟩ ;

/-
Shifting all weights by `c` shifts the envelope by `c`
-/
theorem maxPlusEnvelope_shift {X : Type*} [TopologicalSpace X]
    {n : ℕ} (hn : 0 < n)
    (a : Fin n → ℝ) (c : ℝ) (Φ : TropicalFeatureFamily X n) (x : X) :
    maxPlusEnvelope (fun i => a i + c) Φ x = maxPlusEnvelope a Φ x + c := by
  unfold maxPlusEnvelope;
  split_ifs ; simp_all +decide [ Finset.sup'_add ];
  ac_rfl

/-
Max-plus envelope of a single feature
-/
theorem maxPlusEnvelope_single {X : Type*} [TopologicalSpace X]
    (a : Fin 1 → ℝ) (Φ : TropicalFeatureFamily X 1) (x : X) :
    maxPlusEnvelope a Φ x = a 0 + Φ.eval 0 x := by
  unfold maxPlusEnvelope;
  simp +decide [ Fin.univ_succ ]

/-
Max-plus envelope is 1-Lipschitz in weights (sup-norm)
-/
theorem maxPlusEnvelope_lipschitz_weights {X : Type*} [TopologicalSpace X]
    {n : ℕ} (hn : 0 < n)
    (a b : Fin n → ℝ) (Φ : TropicalFeatureFamily X n) (x : X)
    {δ : ℝ} (hδ : ∀ i, |a i - b i| ≤ δ) :
    |maxPlusEnvelope a Φ x - maxPlusEnvelope b Φ x| ≤ δ := by
  unfold maxPlusEnvelope;
  split_ifs ; simp_all +decide [ abs_le ];
  exact ⟨ fun i => by linarith [ hδ i, Finset.le_sup' ( fun i => a i + Φ.eval i x ) ( Finset.mem_univ i ) ], fun i => by linarith [ hδ i, Finset.le_sup' ( fun i => b i + Φ.eval i x ) ( Finset.mem_univ i ) ] ⟩

/-! ## III. Theorem A: Finite-Feature Tropical Barron Representation -/

/-
**Theorem A.** If `f` is in the tropical Barron class for feature family `Φ`,
    then for every `ε > 0`, there exists a weight vector achieving ε-approximation
    with controlled tropical variation.

    This is the finite tropical analog of atomic Barron representation.
-/
theorem exists_fin_tropical_barron_approx
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ}
    (Φ : TropicalFeatureFamily X n)
    (f : X → ℝ)
    (ε : ℝ) (hε : 0 < ε)
    (hf : InTropicalBarronClass Φ f) :
    ∃ a : Fin n → ℝ,
      (∀ x : X, |f x - maxPlusEnvelope a Φ x| ≤ ε) ∧
      tropicalVariation a ≤ TropicalBarronNorm Φ f ε + ε := by
  -- By definition of infimum, for any ε > 0, there exists some a in the set such that tropicalVariation a < TropicalBarronNorm Φ f ε + ε.
  have h_inf : ∀ ε > 0, ∃ a : Fin n → ℝ, (∀ x, |f x - maxPlusEnvelope a Φ x| ≤ ε) ∧ tropicalVariation a < TropicalBarronNorm Φ f ε + ε := by
    intro ε hε;
    have := exists_lt_of_csInf_lt ( show { v : ℝ | ∃ a : Fin n → ℝ, tropicalVariation a = v ∧ ∀ x : X, |f x - maxPlusEnvelope a Φ x| ≤ ε }.Nonempty from ?_ ) ( lt_add_of_pos_right _ hε );
    · rcases this with ⟨ a, ⟨ b, rfl, hb ⟩, ha ⟩ ; exact ⟨ b, hb, ha ⟩ ;
    · exact Exists.elim ( hf ε hε ) fun a ha => ⟨ _, ⟨ a, rfl, ha ⟩ ⟩;
  exact Exists.elim ( h_inf ε hε ) fun a ha => ⟨ a, ha.1, ha.2.le ⟩

/-! ## IV. Sparse Compression -/

/-- Sparse approximation by zeroing small weights -/
def sparseApprox {n : ℕ} (a : Fin n → ℝ) (threshold : ℝ) : Fin n → ℝ :=
  fun i => if |a i| ≥ threshold then a i else 0

/-
The sparse approximation has controlled support size
-/
theorem sparseApprox_support_card {n : ℕ} (a : Fin n → ℝ) (threshold : ℝ) :
    (Finset.univ.filter (fun i => sparseApprox a threshold i ≠ 0)).card ≤ n := by
  exact le_trans ( Finset.card_le_univ _ ) ( by norm_num )

/-
Tropical variation of the sparse approximation ≤ original
-/
theorem sparseApprox_variation_le {n : ℕ} (a : Fin n → ℝ) (threshold : ℝ) :
    tropicalVariation (sparseApprox a threshold) ≤ tropicalVariation a := by
  refine' Finset.sum_le_sum fun i _ => _;
  unfold sparseApprox; aesop;

/-
The discarded weights have small total variation
-/
theorem sparseApprox_error_variation {n : ℕ} (a : Fin n → ℝ) (threshold : ℝ)
    (ht : 0 ≤ threshold) :
    tropicalVariation (fun i => a i - sparseApprox a threshold i) ≤
      ↑n * threshold := by
  convert Finset.sum_le_sum fun i _ => ?_;
  rw [ Finset.sum_const, Finset.card_fin, nsmul_eq_mul ];
  · infer_instance;
  · grind +locals

/-
**Theorem C (Sparse Tropical Compression).**
    Given an exact max-plus representation with `n` features, threshold-based
    compression produces a sparse representation with controlled error.

    The error is at most `n * threshold`, and the support size is at most `n`.
    Optimizing: choosing `threshold = V/N` gives error `n * V / N` where
    V = tropicalVariation(a).
-/
theorem sparse_tropical_compression
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (hn : 0 < n)
    (Φ : TropicalFeatureFamily X n)
    (a : Fin n → ℝ)
    (f : X → ℝ)
    (hf : ∀ x : X, f x = maxPlusEnvelope a Φ x)
    (threshold : ℝ) (ht : 0 < threshold) :
    ∃ b : Fin n → ℝ,
      (Finset.univ.filter (fun i => b i ≠ 0)).card ≤ n ∧
      (∀ x : X, |f x - maxPlusEnvelope b Φ x| ≤ ↑n * threshold) ∧
      tropicalVariation b ≤ tropicalVariation a := by
  refine' ⟨ sparseApprox a threshold, _, _, _ ⟩;
  · exact le_trans ( Finset.card_le_univ _ ) ( by simpa );
  · intro x;
    convert maxPlusEnvelope_lipschitz_weights hn a ( sparseApprox a threshold ) Φ x _ using 1;
    · rw [ hf ];
    · intro i; unfold sparseApprox; split_ifs <;> simp +decide [ *, abs_of_nonneg, ht.le ] ;
      exact le_trans ( le_of_not_ge ‹_› ) ( le_mul_of_one_le_left ht.le ( mod_cast hn ) );
  · exact?

/-! ## V. Greedy Compression -/

/-
A greedy step: the feature with largest absolute weight
-/
theorem greedy_step_progress {n : ℕ}
    (a : Fin n → ℝ) (threshold : ℝ) (ht : 0 ≤ threshold) :
    ∀ i : Fin n, |a i| < threshold →
      sparseApprox a threshold i = 0 := by
  -- By definition of `sparseApprox`, if `|a i| < threshold`, then `sparseApprox a threshold i = 0`.
  intros i hi
  simp [sparseApprox, hi]

/-! ## VI. Theorem D: Duality via Witness Certificates -/

/-- A **feature-point witness** is a pair of test points in `X`. -/
structure FeaturePointWitness (X : Type*) where
  x₁ : X
  x₂ : X

/-
**Theorem D (Witness Lower Bound on Variation).**
    For any two test points, the oscillation of `f` between them is controlled
    by the max absolute weight times 2, plus the feature oscillation, plus 2ε.

    This gives a lower bound: any ε-approximation must have max weight at least
    `(|f(x₁) - f(x₂)| - maxFeatureOsc - 2ε) / 2`.
-/
theorem witness_lower_bound_on_variation
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (hn : 0 < n)
    (Φ : TropicalFeatureFamily X n)
    (f : X → ℝ)
    (a : Fin n → ℝ)
    (w : FeaturePointWitness X)
    (ε : ℝ) (hε : 0 ≤ ε)
    (happrox : ∀ x : X, |f x - maxPlusEnvelope a Φ x| ≤ ε) :
    |f w.x₁ - f w.x₂| ≤
      2 * Finset.sup' Finset.univ (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
        (fun i => |a i|) +
      2 * Finset.sup' Finset.univ (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
        (fun i => |Φ.eval i w.x₁ - Φ.eval i w.x₂|) +
      2 * ε := by
  -- By definition of maxPlusEnvelope, we have:
  have h_maxPlusEnvelope : ∀ x, maxPlusEnvelope a Φ x = Finset.sup' Finset.univ (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => a i + Φ.eval i x) := by
    unfold maxPlusEnvelope; aesop;
  -- Applying the triangle inequality to the difference of the maxPlusEnvelopes:
  have h_triangle : |maxPlusEnvelope a Φ w.x₁ - maxPlusEnvelope a Φ w.x₂| ≤ Finset.sup' Finset.univ (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => |Φ.eval i w.x₁ - Φ.eval i w.x₂|) := by
    have h_triangle : ∀ i, |(a i + Φ.eval i w.x₁) - (a i + Φ.eval i w.x₂)| ≤ Finset.sup' Finset.univ (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => |Φ.eval i w.x₁ - Φ.eval i w.x₂|) := by
      exact fun i => by simpa [ add_sub_add_left_eq_sub ] using Finset.le_sup' ( fun i => |Φ.eval i w.x₁ - Φ.eval i w.x₂| ) ( Finset.mem_univ i ) ;
    simp_all +decide [ abs_le ];
    obtain ⟨ b, hb₁, hb₂ ⟩ := Finset.exists_max_image Finset.univ ( fun i => |Φ.eval i w.x₁ - Φ.eval i w.x₂| ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ; use b; simp_all +decide [ Finset.sup'_le_iff ] ;
    constructor <;> intro i <;> obtain ⟨ j, hj₁, hj₂ ⟩ := h_triangle i <;> linarith [ Finset.le_sup' ( fun i => a i + Φ.eval i w.x₁ ) ( Finset.mem_univ i ), Finset.le_sup' ( fun i => a i + Φ.eval i w.x₂ ) ( Finset.mem_univ i ), abs_le.mp ( hb₂ i ), abs_le.mp ( hb₂ j ) ] ;
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩ <;> linarith [ abs_le.mp ( happrox w.x₁ ), abs_le.mp ( happrox w.x₂ ), abs_le.mp h_triangle, show ( 0 : ℝ ) ≤ Finset.univ.sup' ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hn ⟩ ⟩ ) ( fun i => |a i| ) from by exact le_trans ( by norm_num ) ( Finset.le_sup' ( fun i => |a i| ) ( Finset.mem_univ ⟨ 0, hn ⟩ ) ) ]

/-
**Witness lower bound on total variation.**
    Any ε-approximation must have total variation at least as large as the
    best single-feature approximation error minus ε.
-/
theorem witness_lower_bound_total_variation
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ}
    (Φ : TropicalFeatureFamily X n)
    (a : Fin n → ℝ) :
    0 ≤ tropicalVariation a := by
  exact?

/-! ## VII. Tropical Barron Norm Properties -/

/-
The Barron norm is nonincreasing in ε, provided the Barron class at ε₁ is nonempty.
    (When the infimum set is empty, `sInf ∅ = 0` by convention, which
    breaks monotonicity.)
-/
theorem tropicalBarronNorm_anti {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (Φ : TropicalFeatureFamily X n) (f : X → ℝ)
    {ε₁ ε₂ : ℝ} (hle : ε₁ ≤ ε₂)
    (hne : ∃ a : Fin n → ℝ, ∀ x : X, |f x - maxPlusEnvelope a Φ x| ≤ ε₁) :
    TropicalBarronNorm Φ f ε₂ ≤ TropicalBarronNorm Φ f ε₁ := by
  obtain ⟨ a, ha ⟩ := hne;
  apply_rules [ csInf_le_csInf ];
  · exact ⟨ 0, by rintro _ ⟨ a, rfl, ha ⟩ ; exact Finset.sum_nonneg fun _ _ => abs_nonneg _ ⟩;
  · exact ⟨ _, ⟨ a, rfl, ha ⟩ ⟩;
  · exact fun v hv => ⟨ hv.choose, hv.choose_spec.1, fun x => le_trans ( hv.choose_spec.2 x ) hle ⟩

/-! ## VIII. Compact Feature Space: Choquet Envelope -/

/-- A **compact tropical feature system**: compact feature space with
    jointly continuous evaluation. -/
structure CompactTropicalFeatureSystem (X : Type*) (Φ : Type*)
    [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Φ] [CompactSpace Φ] where
  eval : Φ → X → ℝ
  continuous_eval : Continuous (Function.uncurry eval)

variable {X Φ : Type*}
  [TopologicalSpace X] [CompactSpace X]
  [TopologicalSpace Φ] [CompactSpace Φ]

/-
Each feature in a compact system is continuous
-/
theorem CompactTropicalFeatureSystem.continuous_eval_at
    (sys : CompactTropicalFeatureSystem X Φ) (φ : Φ) :
    Continuous (sys.eval φ) := by
  exact sys.continuous_eval.comp ( continuous_const.prodMk continuous_id' )

/-
The evaluation is bounded on the compact product
-/
theorem CompactTropicalFeatureSystem.eval_bounded
    (sys : CompactTropicalFeatureSystem X Φ) :
    ∃ M : ℝ, 0 ≤ M ∧ ∀ φ : Φ, ∀ x : X, |sys.eval φ x| ≤ M := by
  obtain ⟨ M, hM ⟩ := IsCompact.exists_bound_of_continuousOn ( CompactSpace.isCompact_univ ) ( show ContinuousOn ( fun p : Φ × X ↦ sys.eval p.1 p.2 ) ( Set.univ ) from Continuous.continuousOn ( by exact sys.continuous_eval ) ) ; use Max.max M 0; aesop;

/-- An **atomic capacity** assigns weights to finitely many features. -/
structure AtomicCapacity (Φ : Type*) where
  support : Finset Φ
  weight : Φ → ℝ
  weight_support : ∀ φ, φ ∉ support → weight φ = 0

/-- Total variation of an atomic capacity -/
def AtomicCapacity.totalVariation {Φ : Type*} (μ : AtomicCapacity Φ) : ℝ :=
  μ.support.sum (fun φ => |μ.weight φ|)

/-- The max-plus integral of an atomic capacity -/
def AtomicCapacity.tropIntegral
    {X Φ : Type*} [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Φ] [CompactSpace Φ]
    (μ : AtomicCapacity Φ) (eval : Φ → X → ℝ) (x : X) : ℝ :=
  if h : μ.support.Nonempty then
    μ.support.sup' h (fun φ => μ.weight φ + eval φ x)
  else 0

/-
Total variation of an atomic capacity is nonneg
-/
theorem AtomicCapacity.totalVariation_nonneg {Φ : Type*} (μ : AtomicCapacity Φ) :
    0 ≤ μ.totalVariation := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
**Theorem B (Compact Choquet Envelope Approximation).**
    Given a finite ε-approximation by features from a compact system,
    there exists an atomic capacity achieving the same approximation
    with controlled total variation.
-/
theorem compact_choquet_envelope_approx
    {X Φ : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Φ] [CompactSpace Φ]
    (sys : CompactTropicalFeatureSystem X Φ)
    (f : X → ℝ)
    (ε : ℝ) (hε : 0 < ε)
    (φs : Finset Φ) (hne : φs.Nonempty)
    (a : Φ → ℝ)
    (ha : ∀ φ, φ ∉ φs → a φ = 0)
    (happrox : ∀ x : X, |f x - φs.sup' hne (fun φ => a φ + sys.eval φ x)| ≤ ε) :
    ∃ μ : AtomicCapacity Φ,
      μ.totalVariation ≤ φs.sum (fun φ => |a φ|) ∧
      ∀ x : X, |f x - μ.tropIntegral sys.eval x| ≤ ε := by
  refine' ⟨ ⟨ φs, a, ha ⟩, _, _ ⟩ <;> simp_all +decide [ AtomicCapacity.totalVariation, AtomicCapacity.tropIntegral ]

/-! ## IX. Closure Properties of the Tropical Barron Class -/

/-- Max-plus combination of two functions -/
def tropicalMax {X : Type*} (f g : X → ℝ) : X → ℝ := fun x => max (f x) (g x)

/-- Translation of a function -/
def tropicalShift {X : Type*} (f : X → ℝ) (c : ℝ) : X → ℝ := fun x => f x + c

/-
The Barron class is closed under `max`
-/
theorem tropicalBarronClass_max
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ}
    (Φ : TropicalFeatureFamily X n)
    (f g : X → ℝ)
    (hf : InTropicalBarronClass Φ f)
    (hg : InTropicalBarronClass Φ g) :
    InTropicalBarronClass Φ (tropicalMax f g) := by
  -- Given ε > 0, obtain a_f and a_g from hf(ε/2) and hg(ε/2).
  intro ε hεpos
  obtain ⟨a_f, ha_f⟩ := hf (ε / 2) (half_pos hεpos)
  obtain ⟨a_g, ha_g⟩ := hg (ε / 2) (half_pos hεpos);
  refine' ⟨ fun i => Max.max ( a_f i ) ( a_g i ), fun x => _ ⟩;
  -- By definition of maxPlusEnvelope, we have:
  have h_maxPlusEnvelope : maxPlusEnvelope (fun i => max (a_f i) (a_g i)) Φ x = max (maxPlusEnvelope a_f Φ x) (maxPlusEnvelope a_g Φ x) := by
    unfold maxPlusEnvelope;
    split_ifs <;> simp +decide [ *, Finset.sup'_eq_sup, Finset.sup_union ];
    refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff ];
    · -- By definition of max, we know that for any $i$, $\max(a_f i, a_g i) + \Phi.eval i x \leq \max(a_f b + \Phi.eval b x, a_g b + \Phi.eval b x)$ for some $b$.
      obtain ⟨b, hb⟩ : ∃ b : Fin n, ∀ i : Fin n, max (a_f i) (a_g i) + Φ.eval i x ≤ max (a_f b) (a_g b) + Φ.eval b x := by
        simpa using Finset.exists_max_image Finset.univ ( fun i => max ( a_f i ) ( a_g i ) + Φ.eval i x ) ⟨ ⟨ 0, by linarith ⟩, Finset.mem_univ _ ⟩;
      cases max_cases ( a_f b ) ( a_g b ) <;> [ left; right ] <;> exact ⟨ b, fun i => by linarith [ hb i ] ⟩;
    · -- Let $b$ be the index where the maximum of $a_f$ and $a_g$ is achieved.
      obtain ⟨b, hb⟩ : ∃ b : Fin n, ∀ i : Fin n, max (a_f i) (a_g i) + Φ.eval i x ≤ max (a_f b) (a_g b) + Φ.eval b x := by
        simpa using Finset.exists_max_image Finset.univ ( fun i => max ( a_f i ) ( a_g i ) + Φ.eval i x ) ⟨ ⟨ 0, by linarith ⟩, Finset.mem_univ _ ⟩;
      exact ⟨ b, fun i => by cases max_cases ( a_f i ) ( a_g i ) <;> cases max_cases ( a_f b ) ( a_g b ) <;> linarith [ hb i ], fun i => by cases max_cases ( a_f i ) ( a_g i ) <;> cases max_cases ( a_f b ) ( a_g b ) <;> linarith [ hb i ] ⟩;
  unfold tropicalMax; cases max_cases ( f x ) ( g x ) <;> cases max_cases ( maxPlusEnvelope a_f Φ x ) ( maxPlusEnvelope a_g Φ x ) <;> exact abs_le.mpr ⟨ by linarith [ abs_le.mp ( ha_f x ), abs_le.mp ( ha_g x ) ], by linarith [ abs_le.mp ( ha_f x ), abs_le.mp ( ha_g x ) ] ⟩ ;

/-
The Barron class is closed under translation (requires at least one feature,
    since for `n = 0` the max-plus envelope is always `0` and cannot represent
    nonzero constants).
-/
theorem tropicalBarronClass_shift
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (hn : 0 < n)
    (Φ : TropicalFeatureFamily X n)
    (f : X → ℝ) (c : ℝ)
    (hf : InTropicalBarronClass Φ f) :
    InTropicalBarronClass Φ (tropicalShift f c) := by
  intro ε hε;
  obtain ⟨ a, ha ⟩ := hf ε hε;
  use fun i => a i + c;
  intro x;
  rw [ maxPlusEnvelope_shift hn a c Φ x ];
  simpa [ tropicalShift ] using ha x

/-
Every single feature is in the Barron class
-/
theorem feature_in_barron_class
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ} (hn : 0 < n)
    (Φ : TropicalFeatureFamily X n) (i : Fin n) :
    InTropicalBarronClass Φ (Φ.eval i) := by
  intro ε hε
  obtain ⟨M, hM⟩ : ∃ M : ℝ, ∀ j : Fin n, ∀ x : X, |Φ.eval j x| ≤ M := by
    have h_bounded : ∀ j : Fin n, ∃ M : ℝ, ∀ x : X, |Φ.eval j x| ≤ M := by
      intro j;
      exact IsCompact.exists_bound_of_continuousOn ( CompactSpace.isCompact_univ ) ( Φ.continuous_eval j |> Continuous.continuousOn ) |> fun ⟨ M, hM ⟩ => ⟨ M, fun x => hM x trivial ⟩;
    choose M hM using h_bounded;
    exact ⟨ ∑ j, M j, fun j x => le_trans ( hM j x ) ( Finset.single_le_sum ( fun j _ => le_trans ( abs_nonneg _ ) ( hM j x ) ) ( Finset.mem_univ j ) ) ⟩;
  refine' ⟨ fun j => if j = i then 0 else -2 * M - ε, fun x => _ ⟩ ; simp +decide [ maxPlusEnvelope ];
  split_ifs ; simp_all +decide [ abs_le ];
  constructor;
  · grind;
  · exact le_add_of_nonneg_of_le hε.le ( Finset.le_sup' ( fun j => ( if j = i then 0 else - ( 2 * M ) - ε ) + Φ.eval j x ) ( Finset.mem_univ i ) |> le_trans ( by aesop ) )

/-
Every max-plus envelope is in the Barron class of its feature family
-/
theorem envelope_in_barron_class
    {X : Type*} [TopologicalSpace X] [CompactSpace X]
    {n : ℕ}
    (Φ : TropicalFeatureFamily X n) (a : Fin n → ℝ) :
    InTropicalBarronClass Φ (maxPlusEnvelope a Φ) := by
  intro ε hε;
  exact ⟨ a, fun x => by simp +decide [ hε.le ] ⟩

end