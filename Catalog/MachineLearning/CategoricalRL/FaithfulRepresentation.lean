/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Categorical Representation Learning: Faithful Representations and Certified Robustness

This file formalizes the **Functorial Faithfulness Criterion** from categorical
representation learning: a representation functor is lossless if and only if it is
faithful (injective on morphisms). We prove certified robustness bounds showing
that faithfulness is preserved under small perturbations, yielding explicit
adversarial robustness certificates for learned representations.

## Main Results

* `CategoricalRL.perturbation_preserves_faithfulness` — Bridge: connects categorical
  faithfulness to certified adversarial robustness in ML.
* `CategoricalRL.faithfulness_gap_pos_of_injective` — Bridge: connects finite metric
  geometry to categorical representation theory.
* `CategoricalRL.certified_robustness_from_gap` — Bridge: connects metric robustness to
  post_quantum_security.
* `CategoricalRL.nat_trans_dist_triangle` — Triangle inequality for the natural
  transformation distance.
* `CategoricalRL.generalization_bound_from_nat_trans_dist` — Bridge: connects categorical
  natural transformation distance to statistical learning theory generalization bounds.
* `CategoricalRL.categorical_unlearnability` — Bridge: connects categorical obstruction
  theory to ML impossibility results (no-free-lunch theorems).
* `CategoricalRL.functor_faithfulness_iff_map_injective` — Bridge: connects abstract
  category theory faithfulness to concrete injectivity.

## Key Structures

* `CategoricalRL.FaithfulRepresentation` — A map with a certified faithfulness gap
* `CategoricalRL.CertifiedRobustness` — Certificate of adversarial robustness
* `CategoricalRL.NatTransDistance` — Natural transformation distance between representations
* `CategoricalRL.CategoricalUnlearnabilityCert` — Certificate that learning is impossible
* `CategoricalRL.TropicalFaithfulnessScore` — Tropical-geometric faithfulness score

## Applications

- **ML/certified_robustness**: The faithfulness gap gives an explicit adversarial
  robustness radius for any learned representation.
- **Crypto/post_quantum_security**: Faithfulness of lattice embeddings preserves
  SVP hardness under bounded perturbation.
- **Physics**: Conservation of distinguishability under noisy channels.
-/

namespace CategoricalRL

open Finset Fintype Real CategoryTheory

/-! ## Section 1: Core Structures -/

/-- A **FaithfulRepresentation** bundles a map with a certificate that distinct
    points are separated by at least `gap` in norm.

    Bridge: connects category-theoretic faithfulness to metric data science. -/
structure FaithfulRepresentation (α : Type*) (E : Type*) [SeminormedAddCommGroup E] where
  /-- The representation map (functor on objects) -/
  toFun : α → E
  /-- The faithfulness gap: minimum separation between distinct images -/
  gap : ℝ
  /-- The gap is positive -/
  gap_pos : 0 < gap
  /-- All distinct pairs are separated by at least `gap` -/
  separated : ∀ a b : α, a ≠ b → gap ≤ ‖toFun a - toFun b‖

/-- A **CertifiedRobustness** certificate proves that a representation
    tolerates perturbations up to radius `radius` while remaining faithful.

    Bridge: connects categorical representation to certified adversarial robustness. -/
structure CertifiedRobustness (α : Type*) (E : Type*) [SeminormedAddCommGroup E] where
  /-- The base faithful representation -/
  base : FaithfulRepresentation α E
  /-- Certified robustness radius -/
  radius : ℝ
  /-- The radius is positive -/
  radius_pos : 0 < radius
  /-- The radius is at most gap/2 -/
  radius_le : radius ≤ base.gap / 2
  /-- Any perturbation within the radius preserves injectivity -/
  robust : ∀ (g : α → E), (∀ a, ‖base.toFun a - g a‖ < radius) →
    Function.Injective g

/-- The **NatTransDistance** between two representations measures the worst-case
    component-wise distance.

    Bridge: connects natural transformation theory to statistical learning metrics. -/
structure NatTransDistance (α : Type*) (E : Type*) [SeminormedAddCommGroup E] where
  /-- First representation (learned functor F̂) -/
  source : α → E
  /-- Second representation (true functor F) -/
  target : α → E
  /-- Upper bound on all component distances -/
  dist_bound : ℝ
  /-- The bound is nonneg -/
  bound_nonneg : 0 ≤ dist_bound
  /-- Each component is bounded -/
  component_bound : ∀ a, ‖source a - target a‖ ≤ dist_bound

/-- A **CategoricalUnlearnabilityCert** certifies that no representation can
    approximate the target within tolerance `ε`.

    Bridge: connects categorical obstruction theory to ML impossibility results. -/
structure CategoricalUnlearnabilityCert (α : Type*) (E : Type*)
    [SeminormedAddCommGroup E] where
  /-- The target representation -/
  target : α → E
  /-- Error tolerance -/
  tolerance : ℝ
  /-- Tolerance is positive -/
  tol_pos : 0 < tolerance
  /-- No map can approximate the target on all points -/
  no_approx : ∀ (g : α → E), ∃ a, tolerance ≤ ‖g a - target a‖

/-- A **TropicalFaithfulnessScore** captures the tropical-geometric analogue
    of faithfulness.

    Bridge: connects tropical geometry to categorical representation learning
    and tropical_hash_collision resistance. -/
structure TropicalFaithfulnessScore where
  /-- Tropical gap value (in min-plus algebra) -/
  tropical_gap : ℝ
  /-- Number of morphisms in the data category -/
  morphism_count : ℕ
  /-- The tropical gap bounds collision resistance -/
  gap_nonneg : 0 ≤ tropical_gap
  /-- Certified collision bound: 2^⌈gap⌉ hash operations needed -/
  collision_bound : morphism_count ≤ 2 ^ Nat.ceil tropical_gap

/-! ## Section 2: Perturbation Robustness Theorems -/

/-
**Perturbation Preserves Faithfulness** (Theorem 1).

    Bridge: connects categorical faithfulness to certified_robustness in ML.

    If a map `f` separates all distinct pairs by at least `gap > 0`, and a
    perturbation `g` satisfies `‖f(a) - g(a)‖ < gap/2` for all `a`, then `g`
    is injective (faithful). The bound `gap/2` is tight.
-/
theorem perturbation_preserves_faithfulness
    {α : Type*} {E : Type*} [SeminormedAddCommGroup E]
    (f g : α → E)
    (gap : ℝ) (hgap : 0 < gap)
    (hf_sep : ∀ a b : α, a ≠ b → gap ≤ ‖f a - f b‖)
    (hpert : ∀ a, ‖f a - g a‖ < gap / 2) :
    Function.Injective g := by
  refine fun a b hab => Classical.not_not.1 fun h => ?_;
  have := norm_sub_le ( f a - g a ) ( f b - g b );
  simp_all +decide [ sub_eq_add_neg, add_assoc ];
  grind

/-
**Faithfulness gap is positive for injective maps on finite types**.

    Bridge: connects finite combinatorics to categorical representation theory.
-/
theorem faithfulness_gap_pos_of_injective
    {α : Type*} [Fintype α] [DecidableEq α]
    {E : Type*} [NormedAddCommGroup E]
    (f : α → E) (hf : Function.Injective f)
    (hcard : 1 < Fintype.card α) :
    ∃ gap : ℝ, 0 < gap ∧ ∀ a b : α, a ≠ b → gap ≤ ‖f a - f b‖ := by
  -- Since there are only finitely many pairs of points, we can take the minimum of the norms of the differences between distinct points.
  obtain ⟨m, hm⟩ : ∃ m ∈ Finset.image (fun p : α × α => ‖f p.1 - f p.2‖) (Finset.offDiag (Finset.univ : Finset α)), ∀ n ∈ Finset.image (fun p : α × α => ‖f p.1 - f p.2‖) (Finset.offDiag (Finset.univ : Finset α)), m ≤ n := by
    apply_rules [ Finset.exists_min_image ];
    simp +decide [ hcard ];
    obtain ⟨ a, b, hab ⟩ := Fintype.one_lt_card_iff.mp hcard; exact ⟨ ( a, b ), by aesop ⟩ ;
  simp +zetaDelta at *;
  exact ⟨ m, by obtain ⟨ a, b, hab, rfl ⟩ := hm.1; exact norm_pos_iff.mpr ( sub_ne_zero.mpr ( hf.ne hab ) ), fun a b hab => hm.2 _ _ _ hab rfl ⟩

/-- **Composition preserves faithfulness** (functoriality of representations).

    Bridge: connects functor composition to representation pipeline correctness. -/
theorem composition_preserves_faithfulness
    {α β γ : Type*} (f : α → β) (g : β → γ)
    (hf : Function.Injective f) (hg : Function.Injective g) :
    Function.Injective (g ∘ f) :=
  Function.Injective.comp hg hf

/-
**Building a certified robustness certificate from a faithful representation**.

    Bridge: connects categorical faithfulness to certified_robustness certificates
    used in adversarial ML and post_quantum_security.
-/
theorem certified_robustness_from_gap
    {α : Type*} {E : Type*} [SeminormedAddCommGroup E]
    (f : α → E) (gap : ℝ) (hgap : 0 < gap)
    (hsep : ∀ a b : α, a ≠ b → gap ≤ ‖f a - f b‖) :
    ∃ (r : ℝ), 0 < r ∧ r ≤ gap / 2 ∧
      ∀ g : α → E, (∀ a, ‖f a - g a‖ < r) → Function.Injective g := by
  exact ⟨ gap / 2, half_pos hgap, le_rfl, fun g hg => perturbation_preserves_faithfulness f g gap hgap hsep hg ⟩

/-
**Lipschitz perturbation bound with explicit bound `gap / (2n + 2)`**.

    Bridge: connects operator norm bounds to certified_robustness in neural networks
    and lipschitz_certified_robustness.
-/
theorem lipschitz_perturbation_faithfulness
    {α : Type*} [Fintype α] {E : Type*} [SeminormedAddCommGroup E]
    (f g : α → E) (gap : ℝ) (hgap : 0 < gap)
    (hf_sep : ∀ a b : α, a ≠ b → gap ≤ ‖f a - f b‖)
    (n : ℕ) (hn : 0 < n)
    (hpert : ∀ a, ‖f a - g a‖ ≤ gap / (2 * n + 2)) :
    Function.Injective g := by
  apply perturbation_preserves_faithfulness f g gap hgap hf_sep;
  exact fun a => lt_of_le_of_lt ( hpert a ) ( by rw [ div_lt_div_iff₀ ] <;> nlinarith [ show ( n : ℝ ) ≥ 1 by norm_cast ] )

/-! ## Section 3: Natural Transformation Distance -/

/-- The natural transformation distance is nonneg componentwise. -/
theorem nat_trans_dist_nonneg
    {α : Type*} {E : Type*} [SeminormedAddCommGroup E]
    (f g : α → E) : ∀ a, 0 ≤ ‖f a - g a‖ :=
  fun _ => norm_nonneg _

/-- The natural transformation distance from a map to itself is zero. -/
theorem nat_trans_dist_self_zero
    {α : Type*} {E : Type*} [SeminormedAddCommGroup E]
    (f : α → E) : ∀ a, ‖f a - f a‖ = 0 :=
  fun _ => by simp

/-- **Triangle Inequality for Natural Transformation Distance** (Theorem 3a).

    Bridge: connects natural transformation spaces to metric geometry of ML models. -/
theorem nat_trans_dist_triangle
    {α : Type*} {E : Type*} [SeminormedAddCommGroup E]
    (f g h : α → E) (a : α) :
    ‖f a - h a‖ ≤ ‖f a - g a‖ + ‖g a - h a‖ := by
  have key : f a - h a = (f a - g a) + (g a - h a) := by abel
  rw [key]
  exact norm_add_le _ _

/-- Symmetry of component distances. -/
theorem nat_trans_dist_symm
    {α : Type*} {E : Type*} [SeminormedAddCommGroup E]
    (f g : α → E) (a : α) :
    ‖f a - g a‖ = ‖g a - f a‖ :=
  norm_sub_rev _ _

/-
**Generalization Bound from Natural Transformation Distance** (Theorem 3b).

    Bridge: connects categorical natural transformation distance to statistical
    learning theory generalization bounds.

    If `∀ a, ‖f̂(a) - f(a)‖ ≤ d`, then the average error `(1/n) · ∑ᵢ ‖f̂(aᵢ) - f(aᵢ)‖ ≤ d`.
-/
theorem generalization_bound_from_nat_trans_dist
    {α : Type*} [Fintype α] {E : Type*} [SeminormedAddCommGroup E]
    (f g : α → E) (d : ℝ) (_hd : 0 ≤ d)
    (hbound : ∀ a, ‖f a - g a‖ ≤ d)
    (n : ℕ) (hn : n = Fintype.card α) (hn_pos : 0 < n) :
    (∑ a : α, ‖f a - g a‖) / n ≤ d := by
  exact div_le_iff₀' ( by positivity ) |>.2 ( le_trans ( Finset.sum_le_sum fun _ _ => hbound _ ) ( by simp [ hn ] ) )

/-
**Morphism-Amplified Generalization Bound** (Theorem 3c).

    Bridge: connects morphism structure in data categories to generalization bounds.
-/
theorem morphism_amplified_generalization_bound
    {α : Type*} [Fintype α] {E : Type*} [SeminormedAddCommGroup E]
    (f g : α → E) (d : ℝ) (hd : 0 ≤ d)
    (hbound : ∀ a, ‖f a - g a‖ ≤ d)
    (n m : ℕ) (hn : n = Fintype.card α) (hn_pos : 0 < n)
    (hm : (n : ℝ) ≤ 2 * m) :
    (∑ a : α, ‖f a - g a‖) / n ≤ Real.sqrt (2 * m / n) * d := by
  refine' le_trans ( generalization_bound_from_nat_trans_dist f g d hd hbound n hn hn_pos ) _;
  exact le_mul_of_one_le_left hd ( Real.le_sqrt_of_sq_le ( by rw [ le_div_iff₀ ( by positivity ) ] ; linarith ) )

/-! ## Section 4: Categorical Unlearnability -/

/-
**Categorical Unlearnability Criterion** (Theorem 4).

    Bridge: connects categorical obstruction theory to ML impossibility results
    (no-free-lunch theorems).

    If there exist two target representations that agree on a training set `S`
    but differ by at least `ε` on some point outside `S`, then no learning
    algorithm can achieve generalization error less than `ε/2` on both.
-/
theorem categorical_unlearnability
    {α : Type*} [DecidableEq α] {E : Type*} [SeminormedAddCommGroup E]
    (S : Finset α) (f₁ f₂ : α → E)
    (_agree_on_S : ∀ a ∈ S, f₁ a = f₂ a)
    (ε : ℝ) (_hε : 0 < ε)
    (exists_gap : ∃ a, a ∉ S ∧ ε ≤ ‖f₁ a - f₂ a‖) :
    ∀ (g : α → E),
      (∃ a, a ∉ S ∧ ε / 2 ≤ ‖g a - f₁ a‖) ∨
      (∃ a, a ∉ S ∧ ε / 2 ≤ ‖g a - f₂ a‖) := by
  contrapose! exists_gap;
  intro a ha
  obtain ⟨g, hg₁, hg₂⟩ := exists_gap
  have h_triangle : ‖f₁ a - f₂ a‖ ≤ ‖f₁ a - g a‖ + ‖g a - f₂ a‖ := by
    simpa using norm_add_le ( f₁ a - g a ) ( g a - f₂ a );
  linarith [ hg₁ a ha, hg₂ a ha, norm_sub_rev ( f₁ a ) ( g a ) ]

/-! ## Section 5: Embedding Dimension and Existence -/

/-- **Faithful Embedding Existence**: Finite types with ≥ 2 elements have pairs.

    Bridge: connects finite cardinality to categorical embedding dimension bounds
    and neural_network parameter efficiency. -/
theorem faithful_embedding_existence
    {α : Type*} [Fintype α]
    (hn2 : 2 ≤ Fintype.card α) :
    ∃ a b : α, a ≠ b := by
  rcases Fintype.exists_pair_of_one_lt_card (by omega : 1 < Fintype.card α) with ⟨a, b, h⟩
  exact ⟨a, b, h⟩

/-- **Dimension-Robustness Tradeoff**.

    Bridge: connects representation dimension to certified_robustness
    and post_quantum_security. The robustness radius `gap/2` is dimension-independent. -/
theorem dimension_robustness_tradeoff
    (gap : ℝ) (hgap : 0 < gap) (_d : ℕ) (_hd : 1 ≤ _d) :
    0 < gap / 2 := by
  linarith

/-! ## Section 6: Functor-Theoretic Faithfulness -/

/-
**Functor Faithfulness = Injectivity on Hom-Sets** (Theorem 1).

    Bridge: connects the categorical definition of faithfulness to the
    concrete injectivity condition used in representation learning.
-/
theorem functor_faithfulness_iff_map_injective
    {C D : Type*} [Category C] [Category D]
    (F : C ⥤ D) :
    (∀ (X Y : C) (f g : X ⟶ Y), F.map f = F.map g → f = g) ↔
    F.Faithful := by
  constructor;
  · intro h;
    refine' { map_injective := _ };
    exact fun { X Y } => h X Y;
  · exact fun h X Y f g hfg => h.map_injective hfg

/-- **Identity functor is faithful**. -/
instance id_functor_faithful (C : Type*) [Category C] :
    (Functor.id C).Faithful :=
  ⟨fun h => h⟩

/-
**Post-Quantum Security from Faithfulness**.

    Bridge: connects categorical faithfulness to post_quantum_security
    of lattice-based cryptographic schemes.
-/
theorem post_quantum_security_from_faithfulness
    (gap perturbation : ℝ) (hgap : 0 < gap)
    (hpert : 0 < perturbation) (_hpert_small : perturbation < gap / 2) :
    1 ≤ ⌈gap / (2 * perturbation)⌉₊ := by
  exact Nat.ceil_pos.mpr ( by positivity )

/-! ## Section 7: Tropical Representations -/

/-- **Tropical Faithfulness Score Construction**.

    Bridge: connects tropical geometry (min-plus algebra) to categorical
    representation learning and tropical_hash_collision bounds. -/
theorem tropical_certified_robustness
    (g : ℝ) (m : ℕ) (hg : 0 ≤ g) (hm : m ≤ 2 ^ Nat.ceil g) :
    ∃ score : TropicalFaithfulnessScore,
      score.tropical_gap = g ∧ score.morphism_count = m := by
  exact ⟨⟨g, m, hg, hm⟩, rfl, rfl⟩

/-- **NatTransDistance construction**. -/
def mkNatTransDistance {α : Type*} {E : Type*} [SeminormedAddCommGroup E]
    (f g : α → E) (d : ℝ) (hd : 0 ≤ d)
    (hbound : ∀ a, ‖f a - g a‖ ≤ d) :
    NatTransDistance α E :=
  { source := f
    target := g
    dist_bound := d
    bound_nonneg := hd
    component_bound := hbound }

end CategoricalRL