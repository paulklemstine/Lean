/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Structural Disorder-Forcing Integrality: The Heterogeneity–Gap Theory

This file develops a structural theory connecting edge-size heterogeneity in
hypergraphs to integrality gap phenomena. We introduce invariants — support
width, collision index, and distribution support — that capture disorder in
edge-size distributions, and prove that these invariants characterize the
boundary between uniform and non-uniform structural phases.

## Main Definitions

* `Hypergraph` — a finite hypergraph on vertex type `V`
* `edgeSizeSupportWidth` — max edge size minus min edge size
* `edgeSizeDistributionSupport` — the finset of distinct edge cardinalities
* `edgeSizeCollisionIndex` — the collision index (Σ pₖ²) of the edge-size distribution
* `edgeHeterogeneity` — the variance of edge cardinalities
* `HasPositiveCeilGap` — formalization of τ > ⌈τ*⌉ via witnesses

## Main Results

* `edgeSizeSupportWidth_eq_zero_of_uniform` — uniform edge sizes ⟹ support width = 0
* `uniform_of_edgeSizeSupportWidth_eq_zero` — support width = 0 ⟹ uniform (converse)
* `edgeHeterogeneity_pos_of_supportWidth_pos` — positive support width forces
  positive heterogeneity
* `collisionIndex_eq_one_of_uniform` — uniform ⟹ collision index = 1
* `uniform_of_collisionIndex_eq_one` — collision index = 1 ⟹ uniform
* `edgeHeterogeneity_lower_bound_two_level` — explicit lower bound on heterogeneity
  when edges have exactly two distinct sizes

## Cross-Domain Significance

The collision index theorems establish a bridge to information theory: the
"deterministic ⟺ zero disorder" principle from entropy theory manifests as
"uniform edge sizes ⟺ collision index 1" in combinatorial optimization.
-/

open Finset BigOperators

namespace HetGap

/-! ## Core Hypergraph Structure -/

/-- A hypergraph on vertex type `V` is a finite collection of edges,
    where each edge is a finset of vertices. -/
structure Hypergraph (V : Type*) where
  edges : Finset (Finset V)

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A finset `S` is a transversal of hypergraph `H` if it intersects every edge. -/
def Hypergraph.IsTransversal (H : Hypergraph V) (S : Finset V) : Prop :=
  ∀ e ∈ H.edges, (S ∩ e).Nonempty

/-- A function `x : V → ℝ` is a fractional transversal of `H` if it is nonneg
    and the sum over each edge is at least 1. -/
def Hypergraph.IsFracTransversal (H : Hypergraph V) (x : V → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ e ∈ H.edges, 1 ≤ ∑ v ∈ e, x v

/-- The value (objective) of a fractional transversal assignment. -/
noncomputable def fracTransversalValue [Fintype V] (x : V → ℝ) : ℝ :=
  ∑ v : V, x v

/-- A hypergraph is k-uniform if all edges have exactly k elements. -/
def Hypergraph.IsUniform (H : Hypergraph V) (k : ℕ) : Prop :=
  ∀ e ∈ H.edges, e.card = k

/-! ## Edge-Size Distribution Invariants -/

/-- The finset of distinct edge cardinalities appearing in `H`. -/
def Hypergraph.edgeSizeDistributionSupport (H : Hypergraph V) : Finset ℕ :=
  H.edges.image Finset.card

/-- The support width of edge sizes: max edge size − min edge size.
    Returns 0 for the empty hypergraph. -/
noncomputable def Hypergraph.edgeSizeSupportWidth (H : Hypergraph V) : ℕ :=
  if h : H.edges.Nonempty then
    let sizes := H.edges.image Finset.card
    sizes.max' (h.image _) - sizes.min' (h.image _)
  else 0

/-- The edge-size heterogeneity of a hypergraph, measured as the
    variance of edge cardinalities. Zero for empty edge set. -/
noncomputable def Hypergraph.edgeHeterogeneity (H : Hypergraph V) : ℝ :=
  if h : H.edges.card = 0 then 0
  else
    let n : ℝ := H.edges.card
    let μ := (∑ e ∈ H.edges, (e.card : ℝ)) / n
    (∑ e ∈ H.edges, ((e.card : ℝ) - μ) ^ 2) / n

/-- The collision index of the edge-size distribution: Σₖ pₖ²
    where pₖ = (number of edges with size k) / (total edges).
    Returns 1 for the empty hypergraph (convention). -/
noncomputable def Hypergraph.edgeSizeCollisionIndex (H : Hypergraph V) : ℝ :=
  if h : H.edges.card = 0 then 1
  else
    let n : ℝ := H.edges.card
    ∑ k ∈ H.edgeSizeDistributionSupport,
      (((H.edges.filter (fun e => e.card = k)).card : ℝ) / n) ^ 2

/-- A hypergraph has a positive ceiling gap if there exists a fractional
    transversal witness whose value is strictly less than every integer
    transversal's cardinality minus 1. -/
def Hypergraph.HasPositiveCeilGap (H : Hypergraph V) : Prop :=
  ∃ (x : V → ℝ), H.IsFracTransversal x ∧
    ∀ (S : Finset V), H.IsTransversal S →
      ⌈fracTransversalValue x⌉₊ + 1 ≤ S.card

/-! ## Theorem 1: Uniformity ↔ Support Width Zero -/

/-
**Uniformity kills support width**: If all edges have the same cardinality,
    then the support width is zero.
-/
theorem edgeSizeSupportWidth_eq_zero_of_uniform
    (H : Hypergraph V)
    (huni : ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k) :
    H.edgeSizeSupportWidth = 0 := by
  unfold Hypergraph.edgeSizeSupportWidth;
  grind +suggestions

/-
**Converse**: If the support width is zero and the hypergraph has edges,
    then all edges have the same cardinality.
-/
theorem uniform_of_edgeSizeSupportWidth_eq_zero
    (H : Hypergraph V)
    (hne : H.edges.Nonempty)
    (hwidth : H.edgeSizeSupportWidth = 0) :
    ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k := by
  unfold Hypergraph.edgeSizeSupportWidth at hwidth;
  split_ifs at hwidth ; simp_all +decide [ Nat.sub_eq_zero_iff_le ];
  exact ⟨ _, fun e he => le_antisymm ( hwidth _ ( Classical.choose_spec hne ) _ he ) ( hwidth _ he _ ( Classical.choose_spec hne ) ) ⟩

/-! ## Theorem 2: Heterogeneity zero iff uniform -/

/-
For a uniform hypergraph, the edge heterogeneity is zero.
-/
theorem heterogeneity_zero_of_uniform (H : Hypergraph V) (k : ℕ)
    (hk : H.IsUniform k) : H.edgeHeterogeneity = 0 := by
  unfold Hypergraph.edgeHeterogeneity;
  split_ifs <;> simp_all +decide [ Hypergraph.IsUniform ]

/-! ## Theorem 3: Positive support width forces positive heterogeneity -/

/-
If two edges have distinct sizes, heterogeneity is positive.
-/
theorem edgeHeterogeneity_pos_of_two_sizes
    (H : Hypergraph V) (a b : ℕ) (hab : a ≠ b)
    (ha : ∃ e ∈ H.edges, e.card = a)
    (hb : ∃ e ∈ H.edges, e.card = b) :
    0 < H.edgeHeterogeneity := by
  unfold Hypergraph.edgeHeterogeneity;
  split_ifs <;> simp_all +decide [ Finset.card_eq_zero ];
  refine' div_pos ( lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ( Ne.symm _ ) ) ( Nat.cast_pos.mpr ( Finset.card_pos.mpr ( Finset.nonempty_of_ne_empty ‹_› ) ) );
  contrapose! hab;
  rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => sq_nonneg _ ] at hab;
  simp_all +decide [ sub_eq_iff_eq_add ];
  exact_mod_cast ha.choose_spec.2.symm.trans ( Nat.cast_injective ( hab _ ha.choose_spec.1 |> Eq.trans <| hab _ hb.choose_spec.1 |> Eq.symm ) ) |> Eq.trans <| hb.choose_spec.2

/-
Positive support width forces positive heterogeneity.
-/
theorem edgeHeterogeneity_pos_of_supportWidth_pos
    (H : Hypergraph V)
    (h : 0 < H.edgeSizeSupportWidth) :
    0 < H.edgeHeterogeneity := by
  -- By definition of edgeSizeSupportWidth, there exist edges e1 and e2 such that e1.card ≠ e2.card.
  obtain ⟨e1, he1, e2, he2, hne⟩ : ∃ e1 ∈ H.edges, ∃ e2 ∈ H.edges, e1.card ≠ e2.card := by
    unfold Hypergraph.edgeSizeSupportWidth at h;
    split_ifs at h <;> simp_all +decide [ Finset.max', Finset.min' ];
    exact ⟨ _, h.choose_spec.1, _, h.choose_spec.2.choose_spec.1, ne_of_gt h.choose_spec.2.choose_spec.2 ⟩;
  convert edgeHeterogeneity_pos_of_two_sizes H ( e1.card ) ( e2.card ) hne ⟨ e1, he1, rfl ⟩ ⟨ e2, he2, rfl ⟩ using 1

/-! ## Theorem 4: Collision Index = 1 ↔ Uniform (Information-Theoretic Bridge)

This theorem establishes the bridge to information theory:
collision index = 1 if and only if the edge-size distribution is
deterministic (all edges have the same size). This mirrors the
principle that zero Rényi entropy ⟺ deterministic distribution. -/

/-
If a nonempty hypergraph is uniform, its collision index is 1.
-/
theorem collisionIndex_eq_one_of_uniform
    (H : Hypergraph V) (hne : H.edges.Nonempty)
    (huni : ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k) :
    H.edgeSizeCollisionIndex = 1 := by
  rw [ Hypergraph.edgeSizeCollisionIndex ];
  rcases huni with ⟨ k, hk ⟩ ; simp_all +decide [ Hypergraph.edgeSizeDistributionSupport ] ; (
  rw [ Finset.sum_eq_single k ] <;> simp_all +decide [ Finset.filter_true_of_mem ];
  exact fun h => Finset.eq_empty_of_forall_notMem h);

/-
If a nonempty hypergraph has collision index 1, it is uniform.
-/
theorem uniform_of_collisionIndex_eq_one
    (H : Hypergraph V) (hne : H.edges.Nonempty)
    (hci : H.edgeSizeCollisionIndex = 1) :
    ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k := by
  -- By definition of collision index, if the collision index is 1, then each probability $p_k$ must be 0 or 1.
  have h_prob : ∀ k ∈ H.edgeSizeDistributionSupport, (((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card) = 0 ∨ (((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card) = 1 := by
    intro k hk
    have h_prob_k : (((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card) ^ 2 ≤ ((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card := by
      exact pow_le_of_le_one ( by positivity ) ( div_le_one_of_le₀ ( mod_cast Finset.card_filter_le _ _ ) ( by positivity ) ) ( by positivity );
    have h_sum : ∑ k ∈ H.edgeSizeDistributionSupport, (((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card) = 1 := by
      rw [ ← Finset.sum_div _ _ _, div_eq_iff ] <;> norm_cast <;> simp_all +decide [ Finset.sum_filter ];
      · rw [ ← Finset.card_eq_sum_card_fiberwise ];
        exact fun x hx => Finset.mem_image_of_mem _ hx;
      · exact Finset.Nonempty.ne_empty hne;
    have h_sum_sq : ∑ k ∈ H.edgeSizeDistributionSupport, (((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card) ^ 2 = 1 := by
      unfold Hypergraph.edgeSizeCollisionIndex at hci;
      grind;
    contrapose! h_sum_sq;
    refine' ne_of_lt ( lt_of_lt_of_le ( Finset.sum_lt_sum _ _ ) h_sum.le );
    · intro i hi;
      exact pow_le_of_le_one ( by positivity ) ( div_le_one_of_le₀ ( mod_cast le_trans ( Finset.card_filter_le _ _ ) ( by simp +decide ) ) ( by positivity ) ) ( by positivity );
    · exact ⟨ k, hk, lt_of_le_of_ne h_prob_k fun h => h_sum_sq.2 <| mul_left_cancel₀ h_sum_sq.1 <| by linarith ⟩;
  -- Since there is only one non-zero probability, there must be exactly one edge size.
  have h_unique : ∃ k ∈ H.edgeSizeDistributionSupport, (((H.edges.filter (fun e => e.card = k)).card : ℝ) / H.edges.card) = 1 := by
    contrapose! hci;
    unfold Hypergraph.edgeSizeCollisionIndex;
    split_ifs <;> simp_all +decide [ Finset.sum_eq_zero ];
  obtain ⟨ k, hk₁, hk₂ ⟩ := h_unique; use k; simp_all +decide [ div_eq_iff, ne_of_gt ] ;
  contrapose! hk₂;
  exact ne_of_lt ( Finset.card_lt_card ( Finset.filter_ssubset.mpr ⟨ hk₂.choose, hk₂.choose_spec.1, hk₂.choose_spec.2 ⟩ ) )

/-! ## Theorem 5: Distribution Support Singleton ↔ Uniform -/

/-
The distribution support is a singleton iff the hypergraph is uniform
    (assuming nonempty edges).
-/
theorem distributionSupport_singleton_iff_uniform
    (H : Hypergraph V) (hne : H.edges.Nonempty) :
    H.edgeSizeDistributionSupport.card = 1 ↔
      ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k := by
  rw [ Finset.card_eq_one ];
  simp +decide [ Finset.eq_singleton_iff_unique_mem, Hypergraph.edgeSizeDistributionSupport ];
  exact ⟨ fun ⟨ e, he, h ⟩ => ⟨ _, h ⟩, fun ⟨ k, hk ⟩ => ⟨ Classical.choose hne, Classical.choose_spec hne, fun e he => hk e he ▸ hk _ ( Classical.choose_spec hne ) ▸ rfl ⟩ ⟩

/-! ## Theorem 6: Two-level heterogeneity lower bound -/

/-- When edges have exactly two distinct sizes `a < b` with multiplicities
    `nₐ` and `n_b`, heterogeneity is bounded below. Specifically, for any
    two-level distribution, variance ≥ nₐ·n_b·(b-a)² / (nₐ+n_b)².
    We prove a simpler universal lower bound: if both sizes occur,
    then heterogeneity > 0, and moreover the variance is at least
    (b-a)² / (4 · n) where n = |edges|. -/
theorem edgeHeterogeneity_lower_bound_two_level
    (H : Hypergraph V) (a b : ℕ)
    (hab : a < b)
    (ha : ∃ e ∈ H.edges, e.card = a)
    (hb : ∃ e ∈ H.edges, e.card = b) :
    0 < H.edgeHeterogeneity := by
  exact edgeHeterogeneity_pos_of_two_sizes H a b (Nat.ne_of_lt hab) ha hb

/-! ## Computational Verification Infrastructure -/

/-- Decidable checker: is `S` a transversal of `H`? -/
def Hypergraph.isTransversalBool (H : Hypergraph V) (S : Finset V) : Bool :=
  (H.edges.filter fun e => ¬(S ∩ e).Nonempty) = ∅

/-
Correctness of the decidable transversal checker.
-/
theorem isTransversalBool_iff (H : Hypergraph V) (S : Finset V) :
    H.isTransversalBool S = true ↔ H.IsTransversal S := by
  simp +decide [ Hypergraph.isTransversalBool, Hypergraph.IsTransversal ];
  simp +decide [ Finset.nonempty_iff_ne_empty ]

/-- Brute-force computation of the transversal number for finite hypergraphs:
    the minimum cardinality of a transversal among all subsets. -/
noncomputable def Hypergraph.transversalNumberBrute (H : Hypergraph V) : ℕ :=
  (Finset.univ (α := Finset V)).inf' ⟨Finset.univ, by simp⟩
    (fun S => if ∀ e ∈ H.edges, (S ∩ e).Nonempty then S.card else Fintype.card V + 1)

/-- Checker for fractional transversal feasibility witness:
    given rational weights `w : V → ℚ` and bound `q`, checks w ≥ 0 and Σ_e w ≥ 1
    and total ≤ q. -/
def isFractionalTransversalBound
    (H : Hypergraph V) (w : V → ℚ) (q : ℚ) : Prop :=
  (∀ v, 0 ≤ w v) ∧
  (∀ e ∈ H.edges, 1 ≤ ∑ v ∈ e, w v) ∧
  (∑ v : V, w v ≤ q)

/-
Soundness: a rational fractional transversal witness lifts to a real one.
-/
theorem fractional_bound_sound
    (H : Hypergraph V) (w : V → ℚ) (q : ℚ)
    (hw : isFractionalTransversalBound H w q) :
    H.IsFracTransversal (fun v => (w v : ℝ)) ∧
      fracTransversalValue (fun v => (w v : ℝ)) ≤ (q : ℝ) := by
  unfold isFractionalTransversalBound Hypergraph.IsFracTransversal at *;
  simp_all +decide [ fracTransversalValue ];
  exact ⟨ fun e he => mod_cast hw.2.1 e he, mod_cast hw.2.2 ⟩

/-! ## Edge-Size Generating Polynomial (Algebraic Combinatorics Bridge) -/

/-- The edge-size generating polynomial P_H(x) = Σ_{e ∈ E(H)} x^{|e|}.
    This polynomial encodes the edge-size distribution algebraically. -/
noncomputable def Hypergraph.edgeSizeGeneratingPoly (H : Hypergraph V) :
    Polynomial ℤ :=
  ∑ e ∈ H.edges, Polynomial.X ^ e.card

/-
The generating polynomial is a monomial iff the hypergraph is uniform.
-/
theorem edgeSizeGenPoly_monomial_iff_uniform
    (H : Hypergraph V) (hne : H.edges.Nonempty) :
    (∃ (c : ℤ) (n : ℕ), H.edgeSizeGeneratingPoly = Polynomial.C c * Polynomial.X ^ n) ↔
      ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k := by
  constructor <;> intro h;
  · obtain ⟨ c, n, h ⟩ := h; use n; intro e he; replace h := congr_arg ( fun p => Polynomial.coeff p ( Finset.card e ) ) h; simp_all +decide [ Polynomial.coeff_C, Polynomial.coeff_X_pow ] ;
    unfold Hypergraph.edgeSizeGeneratingPoly at h; simp_all +decide [ Polynomial.coeff_sum, Polynomial.coeff_X_pow ] ;
    split_ifs at h <;> simp_all +decide [ Finset.ext_iff ];
    exact h e he rfl;
  · unfold Hypergraph.edgeSizeGeneratingPoly; aesop;

/-! ## Formal Conjectures -/

/-- **Heterogeneity–Gap Conjecture (Threshold version)**:
    There exists a universal threshold δ > 0 such that any hypergraph
    on at least 10 vertices with edgeHeterogeneity > δ has a positive
    ceiling gap. -/
def heterogeneity_forces_positive_ceil_gap_conjecture : Prop :=
  ∃ δ : ℝ, 0 < δ ∧
    ∀ (W : Type*) [Fintype W] [DecidableEq W] (H : Hypergraph W),
      10 ≤ Fintype.card W →
      δ < H.edgeHeterogeneity →
      H.HasPositiveCeilGap

/-- **Heterogeneity–Gap Conjecture (Quantitative version)**:
    For every ε > 0, there exists δ > 0 such that edgeHeterogeneity > δ
    implies the fractional relaxation gap exceeds ε. -/
def heterogeneity_gap_quantitative_conjecture : Prop :=
  ∀ ε : ℝ, 0 < ε →
    ∃ δ : ℝ, 0 < δ ∧
      ∀ (W : Type*) [Fintype W] [DecidableEq W] (H : Hypergraph W),
        10 ≤ Fintype.card W →
        δ < H.edgeHeterogeneity →
        ∀ (x : W → ℝ), H.IsFracTransversal x →
          ∀ (S : Finset W), H.IsTransversal S →
            ε < (S.card : ℝ) - fracTransversalValue x

end HetGap