/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Certified Mathematical Significance Metrics: Valuation Theory

This file develops a formal theory of significance as a **modular valuation**
on the lattice of finite knowledge states. Building on the monotonicity results
in `Core.lean`, we prove:

1. **Valuation (modularity)**: `σ(K₁ ∪ K₂) + σ(K₁ ∩ K₂) = σ(K₁) + σ(K₂)`
2. **Disjoint additivity**: `σ(K₁ ∪ K₂) = σ(K₁) + σ(K₂)` when disjoint
3. **Threshold crossing implies novelty**: crossing a threshold is impossible
   without genuinely new content
4. **ProofShape feature extraction**: significance computed from proof skeletons
5. **Domain coverage lower bounds**: cross-domain reach forces significance
6. **Triple significance and MasterClass monotonicity**

These results establish significance as a proper **valuation** on the finite
distributive lattice of knowledge states — analogous to rank, measure, or entropy.

## References to Core.lean

- `significance_monotone` from Core.lean is the foundation for lattice monotonicity
- `significance_from_proofs_monotone` is refined via ProofShape feature extraction
- The `AdvancesField` predicate strengthens `strict_advancement` from Core.lean
-/
import Mathlib

open Finset BigOperators

namespace SignificanceMetrics

/-! ## I. Significance as a Monotone Valuation on Finite Sets -/

/-- Significance of a knowledge state: the total weight of all atoms present. -/
def significance {α : Type*} [DecidableEq α] (w : α → ℕ) (K : Finset α) : ℕ :=
  K.sum w

/-- Significance is monotone under subset inclusion. -/
theorem significance_monotone_finset
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    {K₁ K₂ : Finset α}
    (h : K₁ ⊆ K₂) :
    significance w K₁ ≤ significance w K₂ := by
  exact Finset.sum_le_sum_of_subset h

/-- Significance is a `Monotone` function on `Finset α`. -/
theorem significance_monotone_lattice
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) :
    Monotone (significance w : Finset α → ℕ) := by
  intro K₁ K₂ h
  exact significance_monotone_finset w h

/-
**Disjoint additivity**: significance of a disjoint union equals the sum.
    This identifies significance as a **finitely additive measure** on disjoint knowledge.
-/
theorem significance_eq_add_of_disjoint
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    {K₁ K₂ : Finset α}
    (hdisj : Disjoint K₁ K₂) :
    significance w (K₁ ∪ K₂) =
      significance w K₁ + significance w K₂ := by
  exact Finset.sum_union hdisj

/-
**Modularity / Inclusion-Exclusion**: The fundamental valuation identity.
    This makes significance a **modular function** on the lattice of finite sets,
    analogous to rank functions in matroid theory and measures in probability.
-/
theorem significance_union_inter
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    (K₁ K₂ : Finset α) :
    significance w (K₁ ∪ K₂) + significance w (K₁ ∩ K₂) =
      significance w K₁ + significance w K₂ := by
  unfold significance; rw [ Finset.sum_union_inter ] ;

/-
Significance of inserting a fresh element.
-/
theorem significance_insert
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) {K : Finset α} {a : α}
    (ha : a ∉ K) :
    significance w (insert a K) = significance w K + w a := by
  unfold significance; rw [ Finset.sum_insert ha, add_comm ] ;

/-! ## II. Threshold Theorems: Certified Advancement -/

/-- A knowledge transition advances the field if it crosses a significance
    threshold while genuinely adding new content. -/
def AdvancesField {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ) (K_old K_new : Finset α) : Prop :=
  K_old ⊆ K_new ∧
  significance w K_old < τ ∧
  τ ≤ significance w K_new ∧
  ∃ a ∈ K_new, a ∉ K_old

/-
**Threshold crossing implies novelty**: if significance increases strictly
    under a superset relation, there must be genuinely new content.
    This is the formal core of an automated quality gate.
-/
theorem threshold_crossing_yields_new_weight
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ)
    {K_old K_new : Finset α}
    (hsub : K_old ⊆ K_new)
    (hold : significance w K_old < τ)
    (hnew : τ ≤ significance w K_new) :
    ∃ a ∈ K_new, a ∉ K_old := by
  contrapose! hnew;
  rwa [ Finset.Subset.antisymm hnew hsub ]

/-
**Advancement from threshold crossing**: combines monotonicity, threshold
    crossing, and novelty into a single certified quality gate.
-/
theorem advances_of_threshold_crossing
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ)
    {K_old K_new : Finset α}
    (hsub : K_old ⊆ K_new)
    (hold : significance w K_old < τ)
    (hnew : τ ≤ significance w K_new)
    (hstrict : K_old ≠ K_new) :
    AdvancesField w τ K_old K_new := by
  constructor;
  · assumption;
  · grind

/-! ## III. ProofShape: Significance from Proof-Term Structure -/

/-- An abstract proof skeleton modeling the recursive structure of proof terms.
    - `ax a`: an axiom or lemma reference tagged by `a`
    - `app p q`: function application (modus ponens)
    - `lam p`: lambda abstraction (implication introduction)
    - `pair p q`: conjunction introduction -/
inductive ProofShape (α : Type*)
  | ax    : α → ProofShape α
  | app   : ProofShape α → ProofShape α → ProofShape α
  | lam   : ProofShape α → ProofShape α
  | pair  : ProofShape α → ProofShape α → ProofShape α
deriving DecidableEq, Repr

/-- Structural size of a proof shape: counts all constructor nodes. -/
def ProofShape.size {α : Type*} : ProofShape α → ℕ
  | .ax _    => 1
  | .app p q => p.size + q.size + 1
  | .lam p   => p.size + 1
  | .pair p q => p.size + q.size + 1

/-- The set of atomic features (axiom tags) appearing in a proof shape. -/
def ProofShape.features {α : Type*} [DecidableEq α] : ProofShape α → Finset α
  | .ax a    => {a}
  | .app p q => p.features ∪ q.features
  | .lam p   => p.features
  | .pair p q => p.features ∪ q.features

/-- Significance of a proof shape: the significance of its extracted feature set. -/
def significanceFromProofShape {α : Type*} [DecidableEq α]
    (w : α → ℕ) (p : ProofShape α) : ℕ :=
  significance w p.features

/-
Feature count is bounded by proof size.
-/
theorem ProofShape.features_card_le_size {α : Type*} [DecidableEq α]
    (p : ProofShape α) :
    p.features.card ≤ p.size := by
  -- We will prove this by induction on the structure of the proof shape `p`.
  induction' p with p q hp hq;
  · exact Nat.le_add_left _ _;
  · exact le_trans ( Finset.card_union_le _ _ ) ( by linarith! [ show ( q.app hp ).size = q.size + hp.size + 1 from rfl ] );
  · rename_i ih; exact Nat.le_succ_of_le ih;
  · grind +locals

/-
Significance from proof shape is bounded by weighted size.
-/
theorem significanceFromProofShape_le_weighted_size
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (C : ℕ)
    (hw : ∀ a, w a ≤ C)
    (p : ProofShape α) :
    significanceFromProofShape w p ≤ C * p.size := by
  -- By definition of `significanceFromProofShape`, we know that it is equal to the sum of the weights of the features in `p`.
  have h_significance : significanceFromProofShape w p = (p.features).sum w := by
    rfl;
  exact h_significance ▸ le_trans ( Finset.sum_le_sum fun _ _ => hw _ ) ( by simpa [ mul_comm ] using Nat.mul_le_mul_left C ( ProofShape.features_card_le_size p ) )

/-
Significance from proof shape is monotone under feature inclusion.
-/
theorem significanceFromProofShape_monotone_under_feature_inclusion
    {α : Type*} [DecidableEq α]
    (w : α → ℕ)
    {p q : ProofShape α}
    (h : p.features ⊆ q.features) :
    significanceFromProofShape w p ≤ significanceFromProofShape w q := by
  -- Apply the fact that the sum of a subset is less than or equal to the sum of the superset.
  apply Finset.sum_le_sum_of_subset h

/-- Computability witness: there exists a function computing significance
    from proof shapes, and it equals the definition. -/
theorem significanceFromProofShape_computable
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) :
    ∃ f : ProofShape α → ℕ, f = significanceFromProofShape w := by
  exact ⟨_, rfl⟩

/-! ## IV. Domain Coverage and Cross-Domain Significance -/

/-- Domain coverage: the set of domains touched by a knowledge state,
    where `tag` assigns each atom to a domain. -/
def domainCoverage {α β : Type*} [DecidableEq β] (tag : α → β) (K : Finset α) : Finset β :=
  K.image tag

/-
**Cross-domain lower bound**: if every atom has weight ≥ 1,
    then significance is at least as large as the number of distinct domains covered.
    This certifies that broad cross-domain reach forces nontrivial significance.
-/
theorem significance_lower_bound_from_domain_coverage
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (w : α → ℕ) (tag : α → β)
    (hpos : ∀ a, 1 ≤ w a)
    (K : Finset α) :
    (domainCoverage tag K).card ≤ significance w K := by
  -- By definition of domainCoverage, it's a subset of K.image tag, and K.image tag has cardinality ≤ K.card by Finset.card_image_le.
  have h_card_domainCoverage : (domainCoverage tag K).card ≤ K.card := by
    exact Finset.card_image_le;
  exact le_trans h_card_domainCoverage ( le_trans ( by simp +decide ) ( Finset.sum_le_sum fun x hx => hpos x ) )

/-! ## V. Triple Significance and MasterClass -/

/-- Triple significance: combines depth, novelty, and bridge weights
    into a single composite metric. -/
def significanceTriple {α : Type*} [DecidableEq α]
    (d n b : α → ℕ) (K : Finset α) : ℕ :=
  significance d K + significance n K + significance b K

/-
Triple significance is monotone.
-/
theorem significanceTriple_monotone
    {α : Type*} [DecidableEq α]
    (d n b : α → ℕ) :
    Monotone (significanceTriple d n b : Finset α → ℕ) := by
  exact fun K L hKL => by exact add_le_add_three ( Finset.sum_le_sum_of_subset hKL ) ( Finset.sum_le_sum_of_subset hKL ) ( Finset.sum_le_sum_of_subset hKL ) ;

/-- A knowledge state is master-class if its triple significance meets a threshold. -/
def MasterClass {α : Type*} [DecidableEq α]
    (d n b : α → ℕ) (τ : ℕ) (K : Finset α) : Prop :=
  τ ≤ significanceTriple d n b K

/-
**MasterClass is upward-closed**: once a knowledge state is master-class,
    any superset remains master-class. This is the monotonicity of quality gates.
-/
theorem masterClass_monotone
    {α : Type*} [DecidableEq α]
    (d n b : α → ℕ) (τ : ℕ)
    {K₁ K₂ : Finset α}
    (h : K₁ ⊆ K₂)
    (hk : MasterClass d n b τ K₁) :
    MasterClass d n b τ K₂ := by
  exact le_trans hk ( significanceTriple_monotone d n b h )

/-! ## VI. Significance Lower Bound from Feature Diversity -/

/-- ProofShape height: the longest root-to-leaf path. -/
def ProofShape.height {α : Type*} : ProofShape α → ℕ
  | .ax _    => 1
  | .app p q => max p.height q.height + 1
  | .lam p   => p.height + 1
  | .pair p q => max p.height q.height + 1

/-
Height is bounded by size.
-/
theorem ProofShape.height_le_size {α : Type*} (p : ProofShape α) :
    p.height ≤ p.size := by
  induction' p using ProofShape.recOn with p q hp hq;
  · exact Nat.le_refl 1;
  · exact Nat.succ_le_succ ( max_le ( by linarith ) ( by linarith ) );
  · exact Nat.succ_le_succ ‹_›;
  · rename_i p q hp hq;
    exact Nat.succ_le_succ ( max_le ( hp.trans ( Nat.le_add_right _ _ ) ) ( hq.trans ( Nat.le_add_left _ _ ) ) )

/-
Size is always positive.
-/
theorem ProofShape.size_pos {α : Type*} (p : ProofShape α) :
    0 < p.size := by
  -- By definition of size, we can prove this by induction on the structure of p.
  induction' p with p q hp hq;
  · exact Nat.succ_pos _;
  · exact Nat.succ_pos _;
  · exact Nat.succ_pos _;
  · exact Nat.succ_pos _

end SignificanceMetrics