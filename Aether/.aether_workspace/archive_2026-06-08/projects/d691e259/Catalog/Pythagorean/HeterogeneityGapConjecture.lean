/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Structural Disorder-Forcing Integrality: The Heterogeneity–Gap Theory

This file develops a structural theory connecting edge-size heterogeneity in
hypergraphs to integrality gap phenomena. We introduce new invariants—support
width, collision index, and distribution support—that capture disorder in
edge-size distributions, and prove that these invariants characterize the
boundary between uniform and non-uniform structural phases.

## Main Definitions

* `Hypergraph` — a finite hypergraph on vertex type `V`
* `edgeSizeSupportWidth` — max edge size minus min edge size
* `edgeSizeDistributionSupport` — the finset of distinct edge cardinalities
* `edgeSizeCollisionIndex` — the collision index (Σ pₖ²) of the edge-size distribution
* `edgeHeterogeneity` — the variance of edge cardinalities
* `HasPositiveCeilGap` — whether ⌈τ*⌉ < τ for some fractional transversal witness

## Main Results

* `edgeSizeSupportWidth_eq_zero_of_uniform` — uniform edge sizes ⟹ support width = 0
* `uniform_of_edgeSizeSupportWidth_eq_zero` — support width = 0 ⟹ uniform (converse)
* `edgeHeterogeneity_pos_of_two_sizes` — two distinct edge sizes force positive heterogeneity
* `collisionIndex_eq_one_iff_uniform` — collision index = 1 ⟺ uniform edge sizes
* `distributionSupport_singleton_iff_uniform` — |support| = 1 ⟺ uniform

## Cross-Domain Significance

The collision index theorem establishes a bridge to information theory: the
"deterministic ⟺ zero disorder" principle from entropy theory manifests as
"uniform edge sizes ⟺ collision index 1" in combinatorial optimization.
-/

open Finset BigOperators

namespace HypergraphHetGap

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
noncomputable def fracTransversalValue (x : V → ℝ) : ℝ :=
  ∑ v : V, x v

/-! ## Edge-Size Distribution Invariants -/

/-- The multiset of edge cardinalities. -/
def Hypergraph.edgeSizeMultiset (H : Hypergraph V) : Multiset ℕ :=
  H.edges.val.map Finset.card

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
    let d_bar := (∑ e ∈ H.edges, (e.card : ℝ)) / n
    (∑ e ∈ H.edges, ((e.card : ℝ) - d_bar) ^ 2) / n

/-- The collision index of the edge-size distribution: Σₖ pₖ²
    where pₖ = (number of edges with size k) / (total edges).
    Returns 1 for the empty hypergraph (convention). -/
noncomputable def Hypergraph.edgeSizeCollisionIndex (H : Hypergraph V) : ℝ :=
  if h : H.edges.card = 0 then 1
  else
    let n : ℝ := H.edges.card
    ∑ k ∈ H.edgeSizeDistributionSupport,
      (((H.edges.filter (fun e => e.card = k)).card : ℝ) / n) ^ 2

/-- A hypergraph is k-uniform if all edges have exactly k elements. -/
def Hypergraph.IsUniform (H : Hypergraph V) (k : ℕ) : Prop :=
  ∀ e ∈ H.edges, e.card = k

/-- A hypergraph has a positive ceiling gap if there exists a fractional
    transversal x such that every integer transversal S has
    |S| ≥ ⌈value(x)⌉ + 1, i.e. τ ≥ ⌈τ*⌉ + 1. -/
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

/-! ## Theorem 2: Distribution Support Singleton ↔ Uniformity -/

/-
The distribution support is a singleton iff the hypergraph is uniform
    (assuming nonempty edges).
-/
theorem distributionSupport_singleton_iff_uniform
    (H : Hypergraph V) (hne : H.edges.Nonempty) :
    H.edgeSizeDistributionSupport.card = 1 ↔
      ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k := by
  constructor <;> intro h <;> simp_all +decide [ Finset.card_eq_one, Hypergraph.edgeSizeDistributionSupport ];
  · exact ⟨ h.choose, fun e he => Finset.mem_singleton.mp ( h.choose_spec ▸ Finset.mem_image_of_mem _ he ) ⟩;
  · exact ⟨ h.choose, Finset.eq_singleton_iff_nonempty_unique_mem.2 ⟨ hne.image _, fun e he => by obtain ⟨ e', he', rfl ⟩ := Finset.mem_image.1 he; exact h.choose_spec e' he' ⟩ ⟩

/-! ## Theorem 3: Two Distinct Edge Sizes Force Positive Heterogeneity -/

/-
If a hypergraph has edges of two distinct sizes, its heterogeneity is
    strictly positive. This is the key theorem establishing that support
    width > 0 forces positive variance.
-/
theorem edgeHeterogeneity_pos_of_two_sizes
    (H : Hypergraph V) (a b : ℕ) (hab : a ≠ b)
    (ha : ∃ e ∈ H.edges, e.card = a)
    (hb : ∃ e ∈ H.edges, e.card = b) :
    0 < H.edgeHeterogeneity := by
  unfold Hypergraph.edgeHeterogeneity;
  split_ifs <;> simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg ];
  refine' div_pos _ ( Nat.cast_pos.mpr <| Finset.card_pos.mpr <| Finset.nonempty_of_ne_empty ‹_› );
  by_contra h_contra;
  -- If the sum of squares is zero, then each term must be zero.
  have h_each_zero : ∀ e ∈ H.edges, (e.card : ℝ) = (∑ e ∈ H.edges, (e.card : ℝ)) / (H.edges.card : ℝ) := by
    exact fun e he => eq_of_sub_eq_zero ( sq_eq_zero_iff.mp ( le_antisymm ( le_of_not_gt fun h => h_contra <| lt_of_lt_of_le h <| Finset.single_le_sum ( fun x _ => sq_nonneg ( ( x.card : ℝ ) - ( ∑ e ∈ H.edges, ( e.card : ℝ ) ) / H.edges.card ) ) he ) <| sq_nonneg _ ) );
  exact hab ( by obtain ⟨ e₁, he₁, rfl ⟩ := ha; obtain ⟨ e₂, he₂, rfl ⟩ := hb; exact_mod_cast h_each_zero e₁ he₁ |> Eq.trans <| h_each_zero e₂ he₂ |> Eq.symm )

/-! ## Theorem 4: Collision Index Characterization (Cross-Domain Bridge)

This theorem establishes the information-theoretic bridge:
collision index = 1 if and only if the edge-size distribution is
deterministic (all edges have the same size). This mirrors the
fundamental principle from information theory that a distribution
has zero Rényi entropy (equivalently, collision index 1) if and only
if it is supported on a single value. -/

/-
If a nonempty hypergraph is uniform, its collision index is 1.
-/
theorem collisionIndex_eq_one_of_uniform
    (H : Hypergraph V) (hne : H.edges.Nonempty)
    (huni : ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k) :
    H.edgeSizeCollisionIndex = 1 := by
  -- Since there's only one size, the support of the edge-size distribution is a singleton set {k}.
  obtain ⟨k, hk⟩ := huni
  have h_support_singleton : H.edgeSizeDistributionSupport = {k} := by
    exact Finset.eq_singleton_iff_nonempty_unique_mem.mpr ⟨ Finset.image_nonempty.mpr hne, fun x hx => by obtain ⟨ e, he, rfl ⟩ := Finset.mem_image.mp hx; exact hk e he ⟩;
  -- Since the distribution support is {k}, the sum over the colliding indices has only one term: (edges.filter (card = k)).card = edges.card.
  unfold Hypergraph.edgeSizeCollisionIndex
  simp [h_support_singleton, hne];
  exact fun _ => Or.inl ( by rw [ Finset.filter_true_of_mem hk, div_self ] ; aesop )

/-
If a nonempty hypergraph has collision index 1, it is uniform.
-/
theorem uniform_of_collisionIndex_eq_one
    (H : Hypergraph V) (hne : H.edges.Nonempty)
    (hci : H.edgeSizeCollisionIndex = 1) :
    ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k := by
  unfold Hypergraph.edgeSizeCollisionIndex at hci;
  split_ifs at hci <;> simp_all +decide [ Finset.sum_div _ _ _ ];
  -- By the properties of the sum of squares, if the sum of the squares of the probabilities is 1, then each probability must be either 0 or 1.
  have h_prob_one : ∀ k ∈ H.edgeSizeDistributionSupport, (Finset.card (Finset.filter (fun e => Finset.card e = k) H.edges) : ℝ) / Finset.card H.edges = 0 ∨ (Finset.card (Finset.filter (fun e => Finset.card e = k) H.edges) : ℝ) / Finset.card H.edges = 1 := by
    have h_prob_one : ∀ k ∈ H.edgeSizeDistributionSupport, (Finset.card (Finset.filter (fun e => Finset.card e = k) H.edges) : ℝ) / Finset.card H.edges ≤ 1 := by
      exact fun k hk => div_le_one_of_le₀ ( mod_cast Finset.card_filter_le _ _ ) ( Nat.cast_nonneg _ );
    have h_prob_one : ∑ k ∈ H.edgeSizeDistributionSupport, ((Finset.card (Finset.filter (fun e => Finset.card e = k) H.edges) : ℝ) / Finset.card H.edges) = 1 := by
      rw [ ← Finset.sum_div _ _ _, div_eq_iff ] <;> norm_cast <;> simp_all +decide [ Finset.sum_filter ];
      rw [ ← Finset.card_eq_sum_card_fiberwise ];
      exact fun x hx => Finset.mem_image_of_mem _ hx;
    contrapose! hci;
    refine' ne_of_lt ( lt_of_lt_of_le ( Finset.sum_lt_sum _ _ ) _ );
    use fun k => ( Finset.card ( Finset.filter ( fun e => Finset.card e = k ) H.edges ) : ℝ ) / Finset.card H.edges;
    · exact fun k hk => pow_le_of_le_one ( div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) ( by solve_by_elim ) ( by norm_num );
    · obtain ⟨ k, hk₁, hk₂, hk₃ ⟩ := hci; exact ⟨ k, hk₁, pow_lt_self_of_lt_one₀ ( lt_of_le_of_ne ( div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) ( Ne.symm hk₂ ) ) ( lt_of_le_of_ne ( by solve_by_elim ) hk₃ ) ( by norm_num ) ⟩ ;
    · linarith;
  -- Since the sum of the probabilities is 1, there must be exactly one k where the probability is 1.
  obtain ⟨k, hk⟩ : ∃ k ∈ H.edgeSizeDistributionSupport, (Finset.card (Finset.filter (fun e => Finset.card e = k) H.edges) : ℝ) / Finset.card H.edges = 1 := by
    contrapose! hci;
    rw [ Finset.sum_eq_zero ] <;> aesop;
  simp_all +decide [ div_eq_iff ];
  exact ⟨ k, fun e he => Classical.not_not.1 fun h => absurd hk.2 ( ne_of_lt ( Finset.card_lt_card ( Finset.filter_ssubset.2 ⟨ e, he, h ⟩ ) ) ) ⟩

/-! ## Theorem 5: Heterogeneity Zero iff Uniform -/

/-
For a uniform hypergraph, the edge heterogeneity is zero.
-/
theorem heterogeneity_zero_of_uniform (H : Hypergraph V) (k : ℕ)
    (hk : H.IsUniform k) : H.edgeHeterogeneity = 0 := by
  unfold Hypergraph.edgeHeterogeneity;
  split_ifs <;> simp_all +decide [ Hypergraph.IsUniform ]

/-! ## Computational Verification Infrastructure -/

/-- Decidable checker: is `S` a transversal of `H`? -/
def Hypergraph.isTransversalDec (H : Hypergraph V) (S : Finset V) : Bool :=
  H.edges.biUnion (fun e => if (S ∩ e).Nonempty then ∅ else {e}) = ∅

/-
Correctness of the decidable transversal checker.
-/
theorem isTransversalDec_iff (H : Hypergraph V) (S : Finset V) :
    H.isTransversalDec S = true ↔ H.IsTransversal S := by
  simp +decide [ Hypergraph.isTransversalDec, Hypergraph.IsTransversal ];
  simp +contextual [ Finset.ext_iff ];
  grind

/-- Decidable checker for fractional transversal feasibility witness:
    given weights `w : V → ℚ` and bound `q`, checks w ≥ 0 and Σ_e w ≥ 1
    and total ≤ q. -/
def isFractionalTransversalBound
    (H : Hypergraph V) (w : V → ℚ) (q : ℚ) : Prop :=
  (∀ v, 0 ≤ w v) ∧
  (∀ e ∈ H.edges, 1 ≤ ∑ v ∈ e, w v) ∧
  (∑ v : V, w v ≤ q)

/-! ## Formal Conjecture: Heterogeneity Forces Positive Gap

This is the grand conjecture — stated precisely for future work.
We conjecture that sufficiently large edge-size heterogeneity forces
a positive integrality gap beyond trivial ceiling effects. -/

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

/-! ## Edge-Size Generating Polynomial (Algebraic Combinatorics Bridge) -/

/-- The edge-size generating polynomial P_H(x) = Σ_{e ∈ E(H)} x^{|e|}.
    This polynomial encodes the edge-size distribution algebraically. -/
noncomputable def Hypergraph.edgeSizeGeneratingPolynomial (H : Hypergraph V) :
    Polynomial ℤ :=
  ∑ e ∈ H.edges, Polynomial.X ^ e.card

/-
The generating polynomial is a monomial iff the hypergraph is uniform.
    This connects the algebraic-combinatorial perspective to structural
    uniformity.
-/
omit [Fintype V] [DecidableEq V] in
theorem edgeSizeGeneratingPolynomial_monomial_iff_uniform
    (H : Hypergraph V) (_hne : H.edges.Nonempty) :
    (∃ (c : ℤ) (n : ℕ), H.edgeSizeGeneratingPolynomial = Polynomial.C c * Polynomial.X ^ n) ↔
      ∃ k : ℕ, ∀ e ∈ H.edges, e.card = k := by
  constructor <;> intro h;
  · obtain ⟨ c, n, h ⟩ := h;
    -- Since the polynomial is C c * X^n, the only nonzero coefficient is at degree n with value c. So all edges have card = n.
    have h_coeff : ∀ d, d ≠ n → (Polynomial.coeff (H.edgeSizeGeneratingPolynomial) d) = 0 := by
      aesop;
    use n;
    intro e he; specialize h_coeff ( Finset.card e ) ; simp_all +decide [ Hypergraph.edgeSizeGeneratingPolynomial ] ;
    replace h := congr_arg ( fun p => p.coeff ( Finset.card e ) ) h ; simp_all +decide [ Polynomial.coeff_X_pow ] ;
    split_ifs at h <;> simp_all +decide [ Finset.filter_eq ];
    exact h he rfl;
  · obtain ⟨ k, hk ⟩ := h;
    unfold Hypergraph.edgeSizeGeneratingPolynomial;
    rw [ Finset.sum_congr rfl fun e he => by rw [ hk e he ] ] ; aesop

end HypergraphHetGap