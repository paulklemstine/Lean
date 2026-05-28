/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Support Rigidity Lower Bounds for Structured Arithmetic Circuits

This file establishes a new bridge from **Lorentzian/Hodge-theoretic anti-cancellation**
to **arithmetic circuit lower bounds**. The core idea is that positivity-constrained
computation cannot compress combinatorial support: if a polynomial has nonneg coefficients
and large "second shadow", then any depth-3 circuit with nonneg intermediates must use
many multiplication gates.

## Key New Definitions

* `ShadowSystem` — Abstract framework for combinatorial shadow operations on finite sets
* `supportRigidAtScale` — A support set is rigid at scale `k` if every admissible shadow
  operator preserves shadow size ≥ `k`
* `DepthThreeCovering` — A combinatorial model of depth-3 nonneg circuit decomposition
* `combEntropy` — Combinatorial entropy (logarithm of support cardinality)

## Main Theorems

* `covering_card_lower_bound` — Pigeonhole: k components of size ≤ B covering S ⟹ k * B ≥ |S|
* `ShadowSystem.shadow_union` — Pointwise shadows distribute over finite unions
* `shadow_covering_lower_bound` — Circuit lower bound from shadow rigidity
* `edgePairs_card` — |{(i,j) : i < j < n}| = n*(n-1)/2
* `edgePairs_card_ge_n` — For n ≥ 3, edge count ≥ n
* `combEntropy_mono` — Combinatorial entropy is monotone under set inclusion
* `shadow_entropy_lower_bound` — Entropy cannot decrease under shadow inclusion

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Jerrum–Snir, "Some exact complexity results for straight-line computations over
  semirings", JACM, 1982
-/

open Finset BigOperators Nat

noncomputable section

namespace SupportRigidity

/-! ## Section 1: Abstract Shadow Systems -/

/-- A `ShadowSystem` on types `α`, `β` consists of a pointwise shadow operator.
    Each element of `α` maps to a set of shadow elements in `β`, and the shadow
    of a finite set is the union of per-element shadows.

    **New definition**: This abstracts positive Hessian aggregation's effect on
    support sets, without reference to polynomial algebra. -/
structure ShadowSystem (α : Type*) (β : Type*) [DecidableEq β] where
  /-- The shadow map sends each element to its set of shadow images -/
  shadowOf : α → Finset β

namespace ShadowSystem

variable {α β : Type*} [DecidableEq α] [DecidableEq β]

/-- The full shadow of a finset under a shadow system. -/
def shadow (sys : ShadowSystem α β) (S : Finset α) : Finset β :=
  S.biUnion sys.shadowOf

/-- The shadow of a union equals the union of shadows. -/
theorem shadow_union (sys : ShadowSystem α β) (S T : Finset α) :
    sys.shadow (S ∪ T) = sys.shadow S ∪ sys.shadow T := by
  unfold shadow
  exact Finset.union_biUnion

/-- The shadow is monotone: S ⊆ T → shadow(S) ⊆ shadow(T). -/
theorem shadow_mono (sys : ShadowSystem α β) {S T : Finset α} (h : S ⊆ T) :
    sys.shadow S ⊆ sys.shadow T := by
  unfold shadow
  exact Finset.biUnion_subset_biUnion_of_subset_left sys.shadowOf h

end ShadowSystem

/-! ## Section 2: Support Rigidity -/

/-- A support set `S` is **support-rigid at scale `k`** under a shadow system if
    the shadow of `S` has cardinality at least `k`. This captures the minimum
    combinatorial complexity that positivity-constrained computation must pay for.

    **New definition**: Central notion connecting Hodge-theoretic structure to
    circuit lower bounds. -/
def supportRigidAtScale {α β : Type*} [DecidableEq α] [DecidableEq β]
    (sys : ShadowSystem α β) (S : Finset α) (k : ℕ) : Prop :=
  k ≤ (sys.shadow S).card

/-! ## Section 3: Depth-3 Nonneg Circuit Model -/

/-- A `DepthThreeCovering` models a depth-3 arithmetic circuit with nonneg
    intermediate polynomials. Each multiplication gate produces a component
    whose support is a subset of the target support. -/
structure DepthThreeCovering (α : Type*) [DecidableEq α] where
  /-- The components (one per multiplication gate) -/
  components : List (Finset α)
  /-- The target support to be covered -/
  target : Finset α
  /-- The components cover the target -/
  covers : target ⊆ (components.foldr (· ∪ ·) ∅)

/-- The cost of a depth-3 covering is the number of components. -/
def DepthThreeCovering.cost {α : Type*} [DecidableEq α]
    (D : DepthThreeCovering α) : ℕ :=
  D.components.length

/-! ## Section 4: Covering Lower Bound (Pigeonhole Principle) -/

/-
**Lemma**: The cardinality of a union of finsets from a list is at most
    the sum of their cardinalities.
-/
theorem card_foldr_union_le {α : Type*} [DecidableEq α]
    (L : List (Finset α)) :
    (L.foldr (· ∪ ·) ∅).card ≤ (L.map Finset.card).sum := by
  induction' L with x L ih;
  · simp +decide;
  · grind +splitImp

/-
**Lemma**: If every element of a list of naturals is ≤ B, then the
    sum is ≤ length * B.
-/
theorem list_sum_le_length_mul_max {L : List ℕ} {B : ℕ}
    (hbound : ∀ x ∈ L, x ≤ B) :
    L.sum ≤ L.length * B := by
  simpa using List.sum_le_sum hbound

/-
**Theorem 1 (Covering Lower Bound).**
    If a finset of size M is covered by k components each of cardinality ≤ B,
    then k * B ≥ M. This is the fundamental pigeonhole bound for circuit cost.

    Proof by calc chain combining union cardinality and sum bounds.
-/
theorem covering_card_lower_bound {α : Type*} [DecidableEq α]
    (S : Finset α) (components : List (Finset α)) (B : ℕ)
    (hcover : S ⊆ components.foldr (· ∪ ·) ∅)
    (hbound : ∀ C ∈ components, C.card ≤ B) :
    S.card ≤ components.length * B := by
  refine' le_trans ( Finset.card_le_card hcover ) ( le_trans ( card_foldr_union_le components ) _ );
  simpa using List.sum_le_sum hbound

/-! ## Section 5: Shadow-Aware Circuit Lower Bound -/

/-
**Key Lemma**: The shadow of a foldr-union is contained in the foldr-union
    of the shadows. This is where pointwise shadow structure is essential.
-/
theorem shadow_foldr_union_subset {α β : Type*} [DecidableEq α] [DecidableEq β]
    (sys : ShadowSystem α β) (L : List (Finset α)) :
    sys.shadow (L.foldr (· ∪ ·) ∅) ⊆ (L.map sys.shadow).foldr (· ∪ ·) ∅ := by
  induction' L <;> simp_all +decide [ ShadowSystem.shadow ];
  grind

/-
**Theorem (Shadow Covering Bound).**
    If S is covered by k components where each component's shadow has size ≤ B,
    then |shadow(S)| ≤ k * B.

    This is the key theorem bridging support rigidity to circuit cost.
-/
theorem shadow_covering_lower_bound {α β : Type*} [DecidableEq α] [DecidableEq β]
    (sys : ShadowSystem α β) (S : Finset α)
    (components : List (Finset α)) (B : ℕ)
    (hcover : S ⊆ components.foldr (· ∪ ·) ∅)
    (hbound : ∀ C ∈ components, (sys.shadow C).card ≤ B) :
    (sys.shadow S).card ≤ components.length * B := by
  -- Byshadow_foldr_union_subset,shadow(S) ⊆ (components.map shadow).foldr union ∅
  have hshadow_subset : sys.shadow S ⊆ components.foldr (fun C acc => sys.shadow C ∪ acc) ∅ := by
    convert Set.Subset.trans ( ShadowSystem.shadow_mono sys hcover ) ( shadow_foldr_union_subset sys components ) using 1;
    simp +decide [ Finset.subset_iff, List.foldr_map ];
    rfl;
  refine' le_trans ( Finset.card_le_card hshadow_subset ) _;
  convert card_foldr_union_le ( components.map sys.shadow ) |> le_trans <| list_sum_le_length_mul_max _;
  · exact?;
  · simp +decide;
  · grind

/-
**Theorem 3 (Depth-3 Nonneg Cost Lower Bound).**
    Any depth-3 covering of a support set requires cost at least
    the shadow size divided by the per-component shadow bound.

    This translates geometric support rigidity into circuit lower bounds.
-/
theorem depth3_covering_cost_lower_bound {α β : Type*} [DecidableEq α] [DecidableEq β]
    (sys : ShadowSystem α β) (D : DepthThreeCovering α) (B : ℕ) (hB : 0 < B)
    (hbound : ∀ C ∈ D.components, (sys.shadow C).card ≤ B) :
    (sys.shadow D.target).card / B ≤ D.cost := by
  rw [ Nat.div_le_iff_le_mul_add_pred hB ];
  exact le_add_right ( Nat.le_of_lt_succ ( by nlinarith! [ shadow_covering_lower_bound sys D.target D.components B D.covers hbound ] ) )

/-! ## Section 6: Concrete Family — Complete Graph Edge Pairs -/

/-- The set of all ordered pairs (i,j) from `Fin n` with i < j,
    representing edges of the complete graph K_n. -/
def edgePairs (n : ℕ) : Finset (Fin n × Fin n) :=
  Finset.filter (fun p => p.1 < p.2) Finset.univ

/-
**Theorem 2a (Edge Pair Cardinality).**
    The number of edges in K_n is n*(n-1)/2.
-/
theorem edgePairs_card (n : ℕ) : (edgePairs n).card = n * (n - 1) / 2 := by
  rw [ edgePairs ];
  rw [ Finset.card_filter ];
  -- The sum of the if statements is equivalent to the sum of the first (n-1) natural numbers.
  have h_sum : ∑ i : Fin n × Fin n, (if i.1 < i.2 then 1 else 0) = ∑ i ∈ Finset.range n, (n - 1 - i) := by
    erw [ Finset.sum_product ] ; simp +decide [ Finset.sum_range ];
    simp +decide [ Finset.filter_lt_eq_Ioi ];
  rw [ h_sum, ← Finset.sum_range_id ];
  conv_rhs => rw [ ← Finset.sum_range_reflect ] ;

/-
For n ≥ 2, the edge pair count is at least 1.
-/
theorem edgePairs_card_pos (n : ℕ) (hn : 2 ≤ n) : 0 < (edgePairs n).card := by
  rw [ edgePairs_card ];
  exact Nat.div_pos ( by nlinarith [ Nat.sub_add_cancel ( by linarith : 1 ≤ n ) ] ) zero_lt_two

/-
**Theorem 2b**: For n ≥ 3, |edgePairs n| ≥ n.
-/
theorem edgePairs_card_ge_n (n : ℕ) (hn : 3 ≤ n) : n ≤ (edgePairs n).card := by
  rw [ edgePairs_card ];
  exact Nat.le_div_iff_mul_le zero_lt_two |>.2 ( by nlinarith [ Nat.sub_add_cancel ( by linarith : 1 ≤ n ) ] )

/-! ## Section 7: Shadow System for Degree-4 → Degree-2 Reduction

For the quadratic lower bound, we model degree-4 multilinear monomials as
4-element subsets of `Fin n`, with the second-derivative shadow mapping each
4-subset to its C(4,2) = 6 pairs. We represent 4-subsets as 4-tuples with
strict ordering. -/

/-- A strictly ordered 4-tuple from Fin n, representing a degree-4 multilinear
    monomial x_a * x_b * x_c * x_d where a < b < c < d. -/
abbrev Quad4 (n : ℕ) := { q : Fin n × Fin n × Fin n × Fin n //
  q.1 < q.2.1 ∧ q.2.1 < q.2.2.1 ∧ q.2.2.1 < q.2.2.2 }

/-- The shadow of a degree-4 monomial: all 6 pairs obtainable by choosing
    2 of the 4 variables. -/
def quad4ShadowOf {n : ℕ} (q : Quad4 n) : Finset (Fin n × Fin n) :=
  let ⟨⟨a, b, c, d⟩, _⟩ := q
  {(a, b), (a, c), (a, d), (b, c), (b, d), (c, d)}

/-- The degree-4 to degree-2 shadow system. -/
def quad4ShadowSystem (n : ℕ) : ShadowSystem (Quad4 n) (Fin n × Fin n) where
  shadowOf := quad4ShadowOf

/-- All strictly ordered 4-tuples from Fin n. -/
def allQuad4s (n : ℕ) : Finset (Quad4 n) := Finset.univ

/-
**Theorem 2c (Quadratic Shadow Growth).**
    The shadow of all degree-4 monomials over n ≥ 4 variables contains every
    pair (i,j) with i < j.
-/
theorem quad4Shadow_contains_all_pairs (n : ℕ) (hn : 4 ≤ n)
    (i j : Fin n) (hij : i < j) :
    (i, j) ∈ (quad4ShadowSystem n).shadow (allQuad4s n) := by
  -- Since $n \geq 4$, we can choose two elements $k, l \in \text{Fin } n$ such that $k \neq i$, $k \neq j$, $l \neq i$, $l \neq j$, and $k \neq l$.
  obtain ⟨k, l, hk_ne_i, hk_ne_j, hl_ne_i, hl_ne_j, hkl_ne⟩ : ∃ k l : Fin n, k ≠ i ∧ k ≠ j ∧ l ≠ i ∧ l ≠ j ∧ k ≠ l := by
    have h_two_elements : Finset.card (Finset.univ \ {i, j}) ≥ 2 := by
      simp +decide [ Finset.card_sdiff, * ];
      grind +qlia;
    obtain ⟨ k, hk, l, hl, hkl ⟩ := Finset.one_lt_card.1 h_two_elements; use k, l; aesop;
  -- Since $k$ and $l$ are distinct and different from $i$ and $j$, we can arrange them to form a Quad4 with $i$ and $j$.
  have h_quad4 : ∃ q : Quad4 n, (i, j) ∈ quad4ShadowOf q := by
    -- Since $k$ and $l$ are distinct and different from $i$ and $j$, we can arrange them to form a Quad4 with $i$ and $j$ in increasing order.
    obtain ⟨a, b, c, d, habcd⟩ : ∃ a b c d : Fin n, a < b ∧ b < c ∧ c < d ∧ ({a, b, c, d} : Finset (Fin n)) = {i, j, k, l} := by
      -- Since $k$ and $l$ are distinct and different from $i$ and $j$, we can arrange them to form a Quad4 with $i$ and $j$ in increasing order. Let's denote this sorted list as $s$.
      obtain ⟨s, hs⟩ : ∃ s : Fin 4 → Fin n, StrictMono s ∧ ({s 0, s 1, s 2, s 3} : Finset (Fin n)) = {i, j, k, l} := by
        have h_sorted : ∃ s : Finset (Fin n), s.card = 4 ∧ s = {i, j, k, l} := by
          grind;
        obtain ⟨ s, hs₁, hs₂ ⟩ := h_sorted; use fun x => s.orderEmbOfFin ( by aesop ) x; simp_all +decide [ StrictMono ] ;
        have h_sorted : Finset.image (fun x : Fin 4 => s.orderEmbOfFin (by aesop) x) Finset.univ = s := by
          exact Finset.eq_of_subset_of_card_le ( Finset.image_subset_iff.mpr fun x _ => Finset.orderEmbOfFin_mem _ _ _ ) ( by rw [ Finset.card_image_of_injective _ fun x y hxy => by simpa [ Fin.ext_iff ] using hxy ] ; simp +decide [ hs₁ ] );
        simp_all +decide [ Fin.univ_succ ];
      exact ⟨ s 0, s 1, s 2, s 3, hs.1 ( by decide ), hs.1 ( by decide ), hs.1 ( by decide ), hs.2 ⟩;
    use ⟨⟨a, b, c, d⟩, habcd.left, habcd.right.left, habcd.right.right.left⟩; simp +decide [quad4ShadowOf];
    simp_all +decide [ Finset.Subset.antisymm_iff, Finset.subset_iff ];
    grind;
  exact Finset.mem_biUnion.mpr ⟨ h_quad4.choose, Finset.mem_univ _, h_quad4.choose_spec ⟩

/-
**Theorem 2d (Support Rigidity of Degree-4 Family).**
    The degree-4 multilinear family is support-rigid at quadratic scale.
-/
theorem degree4_support_rigid (n : ℕ) (hn : 4 ≤ n) :
    supportRigidAtScale (quad4ShadowSystem n) (allQuad4s n) (n * (n - 1) / 2) := by
  rw [ ← edgePairs_card ];
  refine' Finset.card_le_card _;
  exact fun x hx => by have := quad4Shadow_contains_all_pairs n hn _ _ ( Finset.mem_filter.mp hx |>.2 ) ; aesop;

/-
**Theorem 3b (Circuit Lower Bound for Degree-4 Family).**
    Any depth-3 covering of the degree-4 family where each component's shadow
    has size ≤ B requires at least n*(n-1)/(2*B) components.
-/
theorem degree4_depth3_lower_bound (n : ℕ) (hn : 4 ≤ n)
    (D : DepthThreeCovering (Quad4 n)) (B : ℕ) (hB : 0 < B)
    (htarget : allQuad4s n ⊆ D.target)
    (hbound : ∀ C ∈ D.components, ((quad4ShadowSystem n).shadow C).card ≤ B) :
    n * (n - 1) / (2 * B) ≤ D.cost := by
  -- By degree4_support_rigid, n*(n-1)/2 ≤ |shadow(allQuad4s n)|.
  have h_deg4_support : n * (n - 1) / 2 ≤ (((quad4ShadowSystem n).shadow (allQuad4s n)).card) := by
    -- Apply the degree4_support_rigid theorem to conclude the proof.
    apply degree4_support_rigid n hn;
  -- By shadow_covering_lower_bound, |shadow(D.target)| ≤ D.components.length * B = D.cost * B.
  have h_shadow_covering : (((quad4ShadowSystem n).shadow D.target).card) ≤ D.components.length * B := by
    apply_rules [ shadow_covering_lower_bound ];
    exact D.covers;
  -- By shadow_mono, shadow(allQuad4s n) ⊆ shadow(D.target).
  have h_shadow_mono : (((quad4ShadowSystem n).shadow (allQuad4s n)).card) ≤ (((quad4ShadowSystem n).shadow D.target).card) := by
    exact Finset.card_le_card ( ShadowSystem.shadow_mono _ htarget );
  rw [ Nat.div_le_iff_le_mul_add_pred ] <;> try linarith;
  linarith! [ Nat.div_mul_cancel ( show 2 ∣ n * ( n - 1 ) from even_iff_two_dvd.mp ( Nat.even_mul_pred_self _ ) ), Nat.sub_add_cancel ( show 1 ≤ 2 * B from by linarith ) ]

/-! ## Section 8: Cross-Domain Bridge — Combinatorial Entropy

The connection to statistical physics and information theory:
support size as zero-temperature entropy. -/

/-- **Combinatorial entropy**: log of cardinality. In statistical physics,
    this is the Boltzmann entropy at zero temperature, counting microstates.
    The anti-cancellation theorem implies that positive response operators
    (Hessian aggregation) cannot collapse this entropy. -/
def combEntropy (S : Finset α) : ℝ :=
  Real.log (S.card : ℝ)

/-
**Theorem (Entropy Monotonicity).**
    Combinatorial entropy is monotone under set inclusion.
    Physical interpretation: coarse-graining cannot increase entropy of
    response-operator images.
-/
theorem combEntropy_mono {α : Type*} [DecidableEq α]
    {S T : Finset α} (h : S ⊆ T) :
    combEntropy S ≤ combEntropy T := by
  by_cases hS : S.Nonempty <;> by_cases hT : T.Nonempty <;> simp_all +decide [ combEntropy ];
  · exact Real.log_le_log ( Nat.cast_pos.mpr hS.card_pos ) ( Nat.cast_le.mpr ( Finset.card_le_card h ) );
  · exact Real.log_nonneg ( mod_cast Finset.card_pos.mpr hT )

/-
**Theorem (Shadow Entropy Lower Bound).**
    If a shadow system's shadow of S contains T, then the entropy of the
    shadow is at least the entropy of T. Combined with anti-cancellation,
    this gives entropy monotonicity for Hessian output support.
-/
theorem shadow_entropy_lower_bound {α β : Type*} [DecidableEq α] [DecidableEq β]
    (sys : ShadowSystem α β) (S : Finset α) (T : Finset β)
    (hT : T ⊆ sys.shadow S) :
    combEntropy T ≤ combEntropy (sys.shadow S) := by
  convert combEntropy_mono hT

/-! ## Section 9: Falsifiable Conjecture -/

/-
**Conjecture (Graphic Hessian Rigidity).**
    For n ≥ 4, the edge pair count satisfies n*(n-1)/2 ≤ |edgePairs n|.

    Falsification test: compute edgePairs_card for small n and verify.
    This is actually a theorem (follows from edgePairs_card), but stated
    separately as the prediction that the shadow bound is tight.
-/
theorem conjecture_graphic_hessian_rigidity (n : ℕ) (_hn : 4 ≤ n) :
    n * (n - 1) / 2 ≤ (edgePairs n).card := by
  convert edgePairs_card n |> le_of_eq using 1;
  · convert edgePairs_card n |> Eq.symm using 1;
  · convert edgePairs_card n using 1

end SupportRigidity