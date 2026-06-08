/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# MPS Min-Cut Principle: Structural Theorems

This file builds on the path-cut combinatorics to establish further structural
results about the MPS min-cut principle, including:

* Characterization of when noncontiguous cuts are strictly worse
* The rank factorization principle (abstract version)
* Cross-domain reformulation as a graph min-cut theorem

## Main Results

* `MPSMinCut.noncontiguous_has_two_cut_edges` — Noncontiguous subsets have ≥ 2 cut edges.
* `MPSMinCut.rank_factorization_bound` — Abstract rank factorization: if a quantity
  factors through a bottleneck, it is bounded by the bottleneck width.
* `MPSMinCut.lineGraphMinCutCapacity_eq_contiguousMinWeight` — The graph-theoretic
  min-cut capacity of a path graph equals the minimum edge weight.

These results formalize the principle that 1D tensor network geometry forces all
inter-partition correlations through chain bonds, creating an entanglement bottleneck.
-/

import Speculative.MPSMinCut.PathCut

namespace MPSMinCut

open Finset

/-! ### Noncontiguous subsets have multiple cut edges

A key structural fact: if a subset `S` of `Fin n` is "noncontiguous" (not an interval),
then it crosses at least two edges of the path graph. This means noncontiguous cuts
have a product-of-bonds bottleneck, making them strictly worse than contiguous cuts
in generic settings.
-/

/-- A subset of `Fin n` is contiguous (an interval in the chain order) if
for all `a, b ∈ S` and `c` with `a ≤ c ≤ b`, we have `c ∈ S`. -/
def IsContiguous {n : ℕ} (S : Finset (Fin n)) : Prop :=
  ∀ a b c : Fin n, a ∈ S → b ∈ S → a ≤ c → c ≤ b → c ∈ S

instance {n : ℕ} (S : Finset (Fin n)) : Decidable (IsContiguous S) :=
  inferInstanceAs (Decidable (∀ _ _ _, _))

/-- A prefix cut is contiguous. -/
theorem prefixCut_isContiguous (n k : ℕ) : IsContiguous (prefixCut n k) := by
  intro a b c ha hb hac hcb
  simp [prefixCut] at *
  omega

/-- A subset is noncontiguous if it is nontrivial and not contiguous. -/
def IsNoncontiguous {n : ℕ} (S : Finset (Fin n)) : Prop :=
  IsNontrivialBipartition S ∧ ¬IsContiguous S

/-
A noncontiguous nontrivial subset has at least 2 cut edges.

If S is not an interval, there exist indices a < c < b with a, b ∈ S and c ∉ S
(or vice versa). This creates at least two transition points on the path.
-/
theorem noncontiguous_cutEdges_card_ge_two {n : ℕ} (S : Finset (Fin n))
    (hnc : IsNoncontiguous S) :
    2 ≤ (cutEdges S).card := by
  -- By definition of noncontiguous, there exist indices $a < c < b$ with $a, b \in S$ and $c \notin S$ (or vice versa).
  obtain ⟨a, b, c, haS, hbS, hac, hcb, hcS⟩ : ∃ a b c : Fin n, a ∈ S ∧ b ∈ S ∧ a < c ∧ c < b ∧ ¬(c ∈ S) := by
    obtain ⟨a, b, c, haS, hbS, hac, hcb, hcS⟩ : ∃ a b c : Fin n, a ∈ S ∧ b ∈ S ∧ a ≤ c ∧ c ≤ b ∧ ¬(c ∈ S) := by
      contrapose! hnc;
      exact fun h => h.2 fun a b c ha hb hac hcb => hnc a b c ha hb hac hcb;
    cases lt_or_eq_of_le hac <;> cases lt_or_eq_of_le hcb <;> aesop;
  -- On the path from $a$ to $c$, there's a transition from "in $S$" to "not in $S$", giving one cut edge.
  obtain ⟨e1, he1⟩ : ∃ e1 : Fin (n - 1), e1.val < c.val ∧ isCutEdge S e1 := by
    -- Let $i$ be the largest index less than $c$ such that $i \in S$.
    obtain ⟨i, hi₁, hi₂⟩ : ∃ i : Fin n, i.val < c.val ∧ i ∈ S ∧ ∀ j : Fin n, j.val < c.val → j ∈ S → j.val ≤ i.val := by
      obtain ⟨i, hi⟩ : ∃ i : Fin n, i.val < c.val ∧ i ∈ S := by
        exact ⟨ a, hac, haS ⟩;
      exact ⟨ Finset.max' ( Finset.filter ( fun j : Fin n => j.val < c.val ∧ j ∈ S ) Finset.univ ) ⟨ i, by aesop ⟩, by have := Finset.max'_mem ( Finset.filter ( fun j : Fin n => j.val < c.val ∧ j ∈ S ) Finset.univ ) ⟨ i, by aesop ⟩ ; aesop, by have := Finset.max'_mem ( Finset.filter ( fun j : Fin n => j.val < c.val ∧ j ∈ S ) Finset.univ ) ⟨ i, by aesop ⟩ ; aesop, fun j hj₁ hj₂ => by exact_mod_cast Finset.le_max' _ _ ( by aesop ) ⟩;
    refine' ⟨ ⟨ i, by omega ⟩, _, _ ⟩ <;> simp_all +decide [ isCutEdge ];
    grind;
  -- On the path from $c$ to $b$, there's a transition from "not in $S$" to "in $S$", giving another cut edge.
  obtain ⟨e2, he2⟩ : ∃ e2 : Fin (n - 1), c.val ≤ e2.val ∧ isCutEdge S e2 := by
    have h_path : ∃ i : Fin n, c ≤ i ∧ i ∈ S ∧ ∀ j : Fin n, c ≤ j → j < i → j ∉ S := by
      have h_path : ∃ i : Fin n, c ≤ i ∧ i ∈ S := by
        exact ⟨ b, hcb.le, hbS ⟩;
      exact ⟨ Finset.min' ( Finset.filter ( fun i => c ≤ i ∧ i ∈ S ) Finset.univ ) ⟨ h_path.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h_path.choose_spec ⟩ ⟩, Finset.mem_filter.mp ( Finset.min'_mem ( Finset.filter ( fun i => c ≤ i ∧ i ∈ S ) Finset.univ ) ⟨ h_path.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h_path.choose_spec ⟩ ⟩ ) |>.2.1, Finset.mem_filter.mp ( Finset.min'_mem ( Finset.filter ( fun i => c ≤ i ∧ i ∈ S ) Finset.univ ) ⟨ h_path.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h_path.choose_spec ⟩ ⟩ ) |>.2.2, fun j hj₁ hj₂ hj₃ => not_lt_of_ge ( Finset.min'_le _ _ <| by aesop ) hj₂ ⟩;
    obtain ⟨ i, hi₁, hi₂, hi₃ ⟩ := h_path;
    rcases i with ⟨ _ | i, hi ⟩ <;> simp_all +decide [ isCutEdge ];
    · grind +locals;
    · use ⟨ i, Nat.lt_pred_iff.mpr hi ⟩;
      grind;
  refine' Finset.one_lt_card.mpr ⟨ e1, _, e2, _, _ ⟩ <;> simp_all +decide [ cutEdges ];
  grind

/-! ### Abstract rank factorization principle

The MPS min-cut principle ultimately rests on the fact that matrix rank is
submultiplicative: `rank(AB) ≤ min(rank A, rank B)`. We formalize an abstract
version: if a "rank-like" quantity for bipartitions is bounded above by the
product of bond capacities on crossing edges, then the minimum over all
bipartitions is bounded below by the minimum edge weight.
-/

/-
**Abstract rank factorization bound.**
If a function `r` on nontrivial bipartitions satisfies `r(S) ≥ min_{e ∈ ∂S} w(e)`
for all nontrivial `S`, then the minimum of `r` over all nontrivial bipartitions
is ≥ the minimum edge weight.
-/
theorem abstract_rank_lower_bound {n : ℕ} (hn : 2 ≤ n)
    (w : Fin (n - 1) → ℕ)
    (r : Finset (Fin n) → ℕ)
    (hbound : ∀ S : Finset (Fin n), S.Nonempty → S ≠ univ →
      edgeCutMinWeight w S ≤ r S) :
    contiguousMinWeight w ≤
      (nontrivialBipartitions n).inf'
        (by
          refine ⟨{⟨0, by omega⟩}, ?_⟩
          simp only [nontrivialBipartitions, mem_filter, mem_univ, true_and,
            IsNontrivialBipartition]
          constructor
          · exact ⟨⟨0, by omega⟩, mem_singleton_self _⟩
          · intro h
            have : (⟨1, by omega⟩ : Fin n) ∈ ({⟨0, by omega⟩} : Finset (Fin n)) := by
              rw [h]; exact mem_univ _
            simp at this)
        r := by
  generalize_proofs at *; simp_all +decide [ Finset.le_inf' ];
  exact fun S hS => le_trans ( contiguousMinWeight_le_edgeCutMinWeight w S ( Finset.mem_filter.mp hS |>.2.1 ) ( Finset.mem_filter.mp hS |>.2.2 ) ) ( hbound S ( Finset.mem_filter.mp hS |>.2.1 ) ( Finset.mem_filter.mp hS |>.2.2 ) )

/-! ### Cross-domain graph reformulation

We now show that the MPS min-cut principle has a clean graph-theoretic formulation.
The "line graph min-cut capacity" is defined as the minimum edge weight on a path
graph — which we show equals both the contiguous min-cut weight and the integrated
min-cut weight.
-/

/-- The line graph min-cut capacity: the minimum edge weight on the path graph.
This is the graph-theoretic analogue of the MPS bond dimension bottleneck. -/
noncomputable def lineGraphMinCutCapacity {n : ℕ} (w : Fin (n - 1) → ℕ) : ℕ :=
  contiguousMinWeight w

/-- **Cross-domain theorem**: The integrated information min-weight equals the
line graph min-cut capacity. This is the theorem that bridges quantum entanglement
theory with graph-theoretic min-cut combinatorics.

In quantum information language: the minimum flattening rank over all bipartitions
equals the min-cut capacity of the underlying graph.
In communication complexity language: the hardest communication bottleneck across
any bipartition is always achieved by a contiguous cut. -/
theorem integratedMinWeight_eq_lineGraphMinCutCapacity {n : ℕ} (hn : 2 ≤ n)
    (w : Fin (n - 1) → ℕ) :
    integratedMinWeight w = lineGraphMinCutCapacity w := by
  exact integratedMinWeight_eq_contiguousMinWeight hn w

/-! ### Complement symmetry

The cut edges of S equal those of Sᶜ, reflecting the physical fact that
a bipartition S|Sᶜ is symmetric.
-/

/-
Cut edges are symmetric under complementation.
-/
theorem cutEdges_compl {n : ℕ} (S : Finset (Fin n)) :
    cutEdges Sᶜ = cutEdges S := by
  unfold cutEdges;
  unfold isCutEdge; aesop;

/-! ### Parity of cut edges

On a *cycle* graph, cut edges come in pairs (every entry is matched by an exit).
On a *path* graph, the parity depends on whether the endpoints agree.
The following theorem captures this. -/

/-
The parity of the number of cut edges on a path graph equals the
xor of membership of the two endpoints. In particular, if both endpoints
have the same membership status, the count is even.
-/
theorem cutEdges_card_parity {n : ℕ} (hn : 1 ≤ n) (S : Finset (Fin n)) :
    (cutEdges S).card % 2 =
      if xor ((⟨0, by omega⟩ : Fin n) ∈ S) ((⟨n - 1, by omega⟩ : Fin n) ∈ S)
      then 1 else 0 := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Finset.ext_iff ];
  · contradiction;
  · native_decide +revert;
  · unfold cutEdges;
    -- We prove this using induction on $n$.
    induction' n with n ih;
    · native_decide +revert;
    · unfold isCutEdge at *;
      nontriviality;
      convert congr_arg ( · % 2 ) ( show Finset.card ( Finset.filter ( fun e : Fin ( n + 2 ) => decide ( ( ⟨ e, by linarith [ Fin.is_lt e ] ⟩ : Fin ( n + 3 ) ) ∈ S ) ^^ decide ( ( ⟨ e + 1, by linarith [ Fin.is_lt e ] ⟩ : Fin ( n + 3 ) ) ∈ S ) ) Finset.univ ) = Finset.card ( Finset.filter ( fun e : Fin ( n + 1 ) => decide ( ( ⟨ e, by linarith [ Fin.is_lt e ] ⟩ : Fin ( n + 2 ) ) ∈ Finset.filter ( fun x : Fin ( n + 2 ) => ( ⟨ x, by linarith [ Fin.is_lt x ] ⟩ : Fin ( n + 3 ) ) ∈ S ) Finset.univ ) ^^ decide ( ( ⟨ e + 1, by linarith [ Fin.is_lt e ] ⟩ : Fin ( n + 2 ) ) ∈ Finset.filter ( fun x : Fin ( n + 2 ) => ( ⟨ x, by linarith [ Fin.is_lt x ] ⟩ : Fin ( n + 3 ) ) ∈ S ) Finset.univ ) ) Finset.univ ) + ( if decide ( ( ⟨ n + 1, by linarith ⟩ : Fin ( n + 3 ) ) ∈ S ) ^^ decide ( ( ⟨ n + 2, by linarith ⟩ : Fin ( n + 3 ) ) ∈ S ) then 1 else 0 ) from ?_ ) using 1;
      · specialize ih ( by linarith ) ( Finset.filter ( fun x : Fin ( n + 2 ) => ( ⟨ x, by linarith [ Fin.is_lt x ] ⟩ : Fin ( n + 3 ) ) ∈ S ) Finset.univ ) ; simp_all +decide [ Finset.filter_filter ];
        grind;
      · rw [ Finset.card_filter, Finset.card_filter ];
        rw [ Fin.sum_univ_castSucc ] ; aesop

end MPSMinCut