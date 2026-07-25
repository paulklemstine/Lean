/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Heterogeneity–Gap Theory: Extended Results

This file extends the structural disorder-forcing integrality theory with
additional theorems connecting support-geometry, information-theoretic, and
optimization-theoretic invariants.

## Main Results

* `edgeHeterogeneity_pos_of_supportWidth_pos` — positive support width forces
  positive heterogeneity, bridging support geometry to distributional disorder
* `collisionIndex_lt_one_of_two_sizes` — two distinct edge sizes force collision
  index strictly below 1, the information-theoretic bridge
* `heterogeneity_pos_two_level` — positive heterogeneity for two-level
  edge-size distributions
* `ceil_gap_arithmetic` — ceiling gap arithmetic for the explicit family
* `half_assignment_covers_pair` — fractional transversal witness for pair edges

## Cross-Domain Significance

The collision index theorem establishes the information-theoretic bridge:
a non-degenerate edge-size distribution (support width > 0) has positive
Rényi entropy (collision index < 1). This mirrors the fundamental principle
from statistical mechanics that structural disorder forces nontrivial
phase behavior—here manifesting as integrality separation.
-/

open Finset BigOperators

namespace HetGapExtended

/-! ## Hypergraph Infrastructure -/

/-- A hypergraph on vertex type `V` is a finite collection of edges. -/
structure Hypergraph (V : Type*) where
  edges : Finset (Finset V)

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A finset `S` is a transversal if it intersects every edge. -/
def Hypergraph.IsTransversal (H : Hypergraph V) (S : Finset V) : Prop :=
  ∀ e ∈ H.edges, (S ∩ e).Nonempty

/-- Fractional transversal. -/
def Hypergraph.IsFracTransversal (H : Hypergraph V) (x : V → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ e ∈ H.edges, 1 ≤ ∑ v ∈ e, x v

/-- Value of a fractional transversal. -/
noncomputable def fracTransversalValue (x : V → ℝ) : ℝ :=
  ∑ v : V, x v

/-- The finset of distinct edge cardinalities. -/
def Hypergraph.edgeSizeDistributionSupport (H : Hypergraph V) : Finset ℕ :=
  H.edges.image Finset.card

/-- Support width = max edge size − min edge size. -/
noncomputable def Hypergraph.edgeSizeSupportWidth (H : Hypergraph V) : ℕ :=
  if h : H.edges.Nonempty then
    let sizes := H.edges.image Finset.card
    sizes.max' (h.image _) - sizes.min' (h.image _)
  else 0

/-- Edge-size heterogeneity (variance of edge cardinalities). -/
noncomputable def Hypergraph.edgeHeterogeneity (H : Hypergraph V) : ℝ :=
  if h : H.edges.card = 0 then 0
  else
    let n : ℝ := H.edges.card
    let d_bar := (∑ e ∈ H.edges, (e.card : ℝ)) / n
    (∑ e ∈ H.edges, ((e.card : ℝ) - d_bar) ^ 2) / n

/-- Collision index of the edge-size distribution: Σ pₖ². -/
noncomputable def Hypergraph.edgeSizeCollisionIndex (H : Hypergraph V) : ℝ :=
  if _h : H.edges.card = 0 then 1
  else
    let n : ℝ := H.edges.card
    ∑ k ∈ H.edgeSizeDistributionSupport,
      (((H.edges.filter (fun e => e.card = k)).card : ℝ) / n) ^ 2

/-- k-uniformity. -/
def Hypergraph.IsUniform (H : Hypergraph V) (k : ℕ) : Prop :=
  ∀ e ∈ H.edges, e.card = k

/-- Positive ceiling gap: there exists a fractional transversal witness
    demonstrating τ ≥ ⌈τ*⌉ + 1. -/
def Hypergraph.HasPositiveCeilGap (H : Hypergraph V) : Prop :=
  ∃ (x : V → ℝ), H.IsFracTransversal x ∧
    ∀ (S : Finset V), H.IsTransversal S →
      ⌈fracTransversalValue x⌉₊ + 1 ≤ S.card

/-! ## Theorem: Positive Support Width Forces Positive Heterogeneity -/

/-
If support width > 0, two edges with distinct cardinalities exist.
-/
theorem two_sizes_of_supportWidth_pos
    (H : Hypergraph V)
    (h : 0 < H.edgeSizeSupportWidth) :
    ∃ (e₁ : Finset V), e₁ ∈ H.edges ∧
    ∃ (e₂ : Finset V), e₂ ∈ H.edges ∧ e₁.card ≠ e₂.card := by
  contrapose! h;
  unfold Hypergraph.edgeSizeSupportWidth;
  split_ifs <;> simp_all +decide [ Finset.max', Finset.min' ];
  rw [ tsub_eq_zero_iff_le ];
  exact Finset.sup'_le _ _ fun x hx => Finset.le_inf' _ _ fun y hy => h x hx y hy ▸ le_rfl

/-
**Support width → heterogeneity**: Positive support width forces
    positive edge-size variance.
-/
theorem edgeHeterogeneity_pos_of_supportWidth_pos
    (H : Hypergraph V)
    (h : 0 < H.edgeSizeSupportWidth) :
    0 < H.edgeHeterogeneity := by
  -- By two_sizes_of_supportWidth_pos, there exist edges e₁ and e₂ with distinct cardinalities.
  obtain ⟨e₁, he₁, e₂, he₂, h_distinct⟩ : ∃ e₁ : Finset V, e₁ ∈ H.edges ∧ ∃ e₂ : Finset V, e₂ ∈ H.edges ∧ e₁.card ≠ e₂.card := two_sizes_of_supportWidth_pos H h;
  -- Let $a$ and $b$ be the sizes of $e₁$ and $e₂$ respectively, and let $n$ be the total number of edges.
  set a := e₁.card
  set b := e₂.card
  set n := H.edges.card
  have h_pos : 0 < (∑ e ∈ H.edges, ((e.card : ℝ) - (∑ e ∈ H.edges, (e.card : ℝ)) / n) ^ 2) / n := by
    refine' div_pos _ ( Nat.cast_pos.mpr <| Finset.card_pos.mpr ⟨ e₁, he₁ ⟩ );
    by_contra h_contra
    have h_eq : ∀ e ∈ H.edges, e.card = (∑ e ∈ H.edges, (e.card : ℝ)) / n := by
      exact fun e he => eq_of_sub_eq_zero ( sq_eq_zero_iff.mp ( le_antisymm ( le_of_not_gt fun h => h_contra <| lt_of_lt_of_le h <| Finset.single_le_sum ( fun x _ => sq_nonneg ( ( #x : ℝ ) - ( ∑ e ∈ H.edges, ( #e : ℝ ) ) / n ) ) he ) ( sq_nonneg _ ) ) )
    have h_eq' : a = b := by
      exact_mod_cast h_eq e₁ he₁ |> Eq.trans <| h_eq e₂ he₂ |> Eq.symm
    contradiction;
  grind +locals

/-! ## Theorem: Two-Level Heterogeneity Lower Bound -/

/-
For edges with exactly two distinct sizes a and b (a ≠ b, both occurring),
    heterogeneity is strictly positive.
-/
theorem heterogeneity_pos_two_level
    (H : Hypergraph V) (a b : ℕ) (hab : a ≠ b)
    (ha : ∃ e ∈ H.edges, e.card = a)
    (hb : ∃ e ∈ H.edges, e.card = b) :
    0 < H.edgeHeterogeneity := by
  -- By definition of edgeHeterogeneity, if there are at least two distinct edge sizes, then the variance is positive.
  have h_var_pos : 0 < ∑ e ∈ H.edges, ((e.card : ℝ) - (∑ e ∈ H.edges, (e.card : ℝ)) / (H.edges.card : ℝ)) ^ 2 := by
    -- Since $a \neq b$, there must be at least one edge $e$ such that $e.card \neq d_bar$.
    obtain ⟨e, he⟩ : ∃ e ∈ H.edges, (e.card : ℝ) ≠ (∑ e ∈ H.edges, (e.card : ℝ)) / (H.edges.card : ℝ) := by
      contrapose! hab;
      exact_mod_cast ha.choose_spec.2.symm.trans ( Nat.cast_injective ( hab _ ha.choose_spec.1 |> Eq.trans <| hab _ hb.choose_spec.1 |> Eq.symm ) ) |> Eq.trans <| hb.choose_spec.2;
    exact lt_of_lt_of_le ( by exact sq_pos_of_ne_zero ( sub_ne_zero_of_ne he.2 ) ) ( Finset.single_le_sum ( fun x _ => sq_nonneg ( ( x.card : ℝ ) - ( ∑ e ∈ H.edges, ( e.card : ℝ ) ) / ( H.edges.card : ℝ ) ) ) he.1 );
  convert div_pos h_var_pos ( Nat.cast_pos.mpr <| Finset.card_pos.mpr ⟨ _, ha.choose_spec.1 ⟩ ) using 1;
  unfold Hypergraph.edgeHeterogeneity; aesop;

/-! ## Theorem: Collision Index < 1 for Non-Uniform Distributions

The information-theoretic bridge: nontrivial edge-size support forces the
collision index strictly below 1, corresponding to positive Rényi entropy. -/

/-
If a nonempty hypergraph has two distinct edge sizes, its collision
    index is strictly less than 1.
-/
theorem collisionIndex_lt_one_of_two_sizes
    (H : Hypergraph V) (hne : H.edges.Nonempty)
    (a b : ℕ) (hab : a ≠ b)
    (ha : ∃ e ∈ H.edges, e.card = a)
    (hb : ∃ e ∈ H.edges, e.card = b) :
    H.edgeSizeCollisionIndex < 1 := by
  -- By definition of edgeSizeCollisionIndex, we can write it as a sum over the distinct edge sizes.
  have h_collision_index_def : H.edgeSizeCollisionIndex = ∑ k ∈ H.edgeSizeDistributionSupport, (((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card) ^ 2 := by
    grind +locals;
  -- Since there are at least two distinct edge sizes, we have $\sum_{k \in \text{support}} p_k^2 < \sum_{k \in \text{support}} p_k = 1$.
  have h_sum_lt_one : ∑ k ∈ H.edgeSizeDistributionSupport, (((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card) ^ 2 < ∑ k ∈ H.edgeSizeDistributionSupport, (((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card) := by
    refine' Finset.sum_lt_sum _ _;
    · intro k hk; exact pow_le_of_le_one ( div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) ( div_le_one_of_le₀ ( mod_cast Finset.card_filter_le _ _ ) ( Nat.cast_nonneg _ ) ) ( by norm_num ) ;
    · refine' ⟨ a, _, _ ⟩ <;> simp_all +decide [ Hypergraph.edgeSizeDistributionSupport ];
      refine' pow_lt_self_of_lt_one₀ _ _ _ <;> norm_num;
      · exact div_pos ( Nat.cast_pos.mpr ( Finset.card_pos.mpr ⟨ ha.choose, Finset.mem_filter.mpr ⟨ ha.choose_spec.1, ha.choose_spec.2 ⟩ ⟩ ) ) ( Nat.cast_pos.mpr ( Finset.card_pos.mpr hne ) );
      · rw [ div_lt_one ( Nat.cast_pos.mpr hne.card_pos ) ];
        exact_mod_cast Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ hb.choose, hb.choose_spec.1, by have := hb.choose_spec.2; aesop ⟩ );
  refine' h_collision_index_def ▸ h_sum_lt_one.trans_le _;
  rw [ ← Finset.sum_div _ _ _, div_le_iff₀ ] <;> norm_cast <;> simp_all +decide [ Finset.sum_filter ];
  rw [ ← Finset.card_biUnion ] ; exact Finset.card_le_card ( Finset.biUnion_subset.mpr fun x hx => Finset.filter_subset _ _ ) ;
  exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun e he₁ he₂ => hxy <| by aesop;

/-! ## Uniformity Characterizations -/

/-
Uniform edge sizes ⟹ support width = 0.
-/
theorem edgeSizeSupportWidth_eq_zero_of_uniform
    (H : Hypergraph V)
    (huni : ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k) :
    H.edgeSizeSupportWidth = 0 := by
  obtain ⟨ k, hk ⟩ := huni;
  unfold Hypergraph.edgeSizeSupportWidth;
  split_ifs <;> simp_all +decide [ Finset.max', Finset.min' ]

/-
Support width = 0 with nonempty edges ⟹ uniform.
-/
theorem uniform_of_edgeSizeSupportWidth_eq_zero
    (H : Hypergraph V)
    (hne : H.edges.Nonempty)
    (hwidth : H.edgeSizeSupportWidth = 0) :
    ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k := by
  unfold Hypergraph.edgeSizeSupportWidth at hwidth;
  split_ifs at hwidth ; simp_all +decide [ Finset.max', Finset.min' ];
  rw [ Nat.sub_eq_zero_iff_le ] at hwidth;
  exact ⟨ _, fun e he => le_antisymm ( Finset.le_sup' ( fun x => Finset.card x ) he |> le_trans <| hwidth ) ( Finset.inf'_le _ he ) ⟩

/-
Heterogeneity zero for uniform hypergraphs.
-/
theorem heterogeneity_zero_of_uniform (H : Hypergraph V) (k : ℕ)
    (hk : H.IsUniform k) : H.edgeHeterogeneity = 0 := by
  by_cases h : H.edges.card = 0 <;> simp_all +decide [ Hypergraph.edgeHeterogeneity ];
  rw [ Finset.sum_congr rfl fun e he => by rw [ hk e he ] ] ; norm_num [ h ];
  rw [ Finset.sum_congr rfl fun e he => by rw [ hk e he ] ] ; simp +decide [ sub_eq_zero, h ]

/-! ## Explicit Family: Analysis Building Blocks

We establish key arithmetic and feasibility results for the
disjoint-triangles-plus-large-edge construction. -/

/-- The uniform-1/2 fractional assignment is feasible for pair edges. -/
theorem half_assignment_covers_pair (n : ℕ) (e : Finset (Fin (3 * n)))
    (he : e.card = 2) : 1 ≤ ∑ v ∈ e, (1 / 2 : ℝ) := by
  simp [Finset.sum_const, he]

/-- The uniform-1/2 assignment has total value 3n/2. -/
theorem half_assignment_value (n : ℕ) :
    (∑ _v : Fin (3 * n), (1 / 2 : ℝ)) = 3 * n / 2 := by
  simp [Finset.sum_const, Fintype.card_fin]; ring

/-
Key arithmetic: for n ≥ 3, ⌈3n/2⌉₊ + 1 ≤ 2n.
-/
theorem ceil_gap_arithmetic (n : ℕ) (hn : 3 ≤ n) :
    ⌈(3 * (n : ℝ) / 2)⌉₊ + 1 ≤ 2 * n := by
  -- By simplifying, we can see that this inequality holds for all $n \geq 3$.
  have h_ceil : ⌈(3 * n : ℝ) / 2⌉₊ ≤ (3 * n + 1) / 2 := by
    rw [ Nat.ceil_le ];
    rw [ div_le_iff₀ ] <;> norm_cast ; linarith [ Nat.div_add_mod ( 3 * n + 1 ) 2, Nat.mod_lt ( 3 * n + 1 ) two_pos ];
  omega

/-! ## Formal Conjectures -/

/-- **Heterogeneity–Gap Conjecture (Threshold version)**:
    There exists δ > 0 such that high enough heterogeneity forces
    a positive ceiling gap. -/
def heterogeneity_forces_positive_ceil_gap_conjecture : Prop :=
  ∃ δ : ℝ, 0 < δ ∧
    ∀ (W : Type*) [Fintype W] [DecidableEq W] (H : Hypergraph W),
      10 ≤ Fintype.card W →
      δ < H.edgeHeterogeneity →
      H.HasPositiveCeilGap

/-- **Heterogeneity–Gap Conjecture (Quantitative version)**. -/
def heterogeneity_gap_quantitative_conjecture : Prop :=
  ∀ ε : ℝ, 0 < ε →
    ∃ δ : ℝ, 0 < δ ∧
      ∀ (W : Type*) [Fintype W] [DecidableEq W] (H : Hypergraph W),
        10 ≤ Fintype.card W →
        δ < H.edgeHeterogeneity →
        ∀ (x : W → ℝ), H.IsFracTransversal x →
          ∀ (S : Finset W), H.IsTransversal S →
            ε < (S.card : ℝ) - fracTransversalValue x

end HetGapExtended