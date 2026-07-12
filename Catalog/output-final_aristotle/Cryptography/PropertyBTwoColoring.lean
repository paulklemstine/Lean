/-
# Property B: two-colourability of sparse hypergraphs (Erdős, 1963)

This file formalises another cornerstone of the **probabilistic method**, complementary to
Erdős's Ramsey lower bound: the *first-moment* two-colourability theorem for hypergraphs,
classically stated as `m(k) ≥ 2^{k-1}`.

A hypergraph `H` on vertex set `Fin N` is a finite family of edges (each an element of
`Finset (Fin N)`).  A **2-colouring** is a partition of the vertices into "red" and "blue";
we encode it as the set `R ⊆ Fin N` of red vertices.  An edge `e` is *monochromatic* if it
is entirely red (`e ⊆ R`) or entirely blue (`Disjoint e R`).  The hypergraph *has property B*
(is 2-colourable) if some colouring makes **no** edge monochromatic.

**Theorem.** If every edge has at least `k ≥ 1` vertices and the number of edges is
`< 2^{k-1}`, then `H` is 2-colourable.

The proof is a finite double-count with no measure theory, mirroring the structure of the
Erdős Ramsey lower bound:

* the total number of colourings is `2^N`;
* for each edge `e`, the number of colourings making `e` red is `2^{N-|e|} ≤ 2^{N-k}`, and
  likewise for blue;
* a union bound over the `< 2^{k-1}` edges shows the bad colourings number
  `< 2^{k-1} · 2 · 2^{N-k} = 2^N`, so a proper colouring survives.

## Main results

* `PropertyB.card_filter_superset` / `card_filter_disjoint` — the Boolean-lattice interval
  counts `#{A ⊆ Gr : S ⊆ A} = #{A ⊆ Gr : S ∩ A = ∅} = 2^{|Gr|-|S|}`.
* `PropertyB.exists_proper_two_coloring` — the main theorem in its sharp "each edge has
  `≥ k` vertices" form (which generalises the usual `k`-uniform statement).
* `PropertyB.property_B` — the classical `k`-uniform statement.
* `PropertyB.two_colorable_of_lt` — restated as: a `k`-uniform hypergraph with fewer than
  `2^{k-1}` edges is 2-colourable.
* concrete instances `PropertyB.triangleHypergraph_two_colorable`,
  `PropertyB.property_B_five_three`.
-/

import Mathlib

open scoped Classical
open Finset

namespace PropertyB

/-! ## Boolean-lattice counting lemmas -/

/-- Interval cardinality: the number of subsets of a ground set `Gr` that contain a fixed
`S ⊆ Gr` is `2 ^ (|Gr| − |S|)`. -/
lemma card_filter_superset {α : Type*} [DecidableEq α] (Gr S : Finset α) (h : S ⊆ Gr) :
    (Gr.powerset.filter (fun A => S ⊆ A)).card = 2 ^ (Gr.card - S.card) := by
  rw [show (2:ℕ)^(Gr.card - S.card) = ((Gr \ S).powerset).card by
        rw [Finset.card_powerset, Finset.card_sdiff_of_subset h]]
  apply Finset.card_bij (fun A _ => A \ S)
  · intro A hA
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA
    simp only [Finset.mem_powerset]
    exact Finset.sdiff_subset_sdiff hA.1 (le_refl S)
  · intro A hA B hB heq
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA hB
    have : (A \ S) ∪ S = (B \ S) ∪ S := by rw [heq]
    rwa [Finset.sdiff_union_of_subset hA.2, Finset.sdiff_union_of_subset hB.2] at this
  · intro B hB
    simp only [Finset.mem_powerset] at hB
    refine ⟨B ∪ S, ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_powerset]
      refine ⟨Finset.union_subset (hB.trans (Finset.sdiff_subset)) h, Finset.subset_union_right⟩
    · rw [Finset.union_sdiff_right]
      apply Finset.sdiff_eq_self_of_disjoint
      exact (Finset.disjoint_left.2 (fun x hxB hxS => ((Finset.mem_sdiff.1 (hB hxB)).2) hxS))

/-- The number of subsets of `Gr` disjoint from a fixed `S ⊆ Gr` is also `2 ^ (|Gr| − |S|)`
(complement involution `A ↦ Gr \ A`). -/
lemma card_filter_disjoint {α : Type*} [DecidableEq α] (Gr S : Finset α) (h : S ⊆ Gr) :
    (Gr.powerset.filter (fun A => Disjoint S A)).card = 2 ^ (Gr.card - S.card) := by
  rw [← card_filter_superset Gr S h]
  apply Finset.card_bij (fun A _ => Gr \ A)
  · intro A hA
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA ⊢
    refine ⟨Finset.sdiff_subset, ?_⟩
    intro x hxS
    rw [Finset.mem_sdiff]
    exact ⟨h hxS, fun hxA => (Finset.disjoint_left.1 hA.2) hxS hxA⟩
  · intro A hA B hB heq
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA hB
    have : Gr \ (Gr \ A) = Gr \ (Gr \ B) := by rw [heq]
    rwa [Finset.sdiff_sdiff_eq_self hA.1, Finset.sdiff_sdiff_eq_self hB.1] at this
  · intro B hB
    simp only [Finset.mem_filter, Finset.mem_powerset] at hB
    refine ⟨Gr \ B, ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_powerset]
      refine ⟨Finset.sdiff_subset, ?_⟩
      rw [Finset.disjoint_right]
      intro x hx
      rw [Finset.mem_sdiff] at hx
      exact fun hxS => hx.2 (hB.2 hxS)
    · rw [Finset.sdiff_sdiff_eq_self hB.1]

/-! ## The union bound: existence of a proper 2-colouring -/

/-
**Property B (sharp form).** Let `H` be a hypergraph on `Fin N` in which every edge has at
least `k ≥ 1` vertices.  If `H` has fewer than `2^{k-1}` edges, then there is a 2-colouring
`R ⊆ Fin N` (red vertices) making no edge monochromatic: every edge has both a red and a blue
vertex.
-/
theorem exists_proper_two_coloring (N k : ℕ) (hk : 1 ≤ k)
    (H : Finset (Finset (Fin N)))
    (hedge : ∀ e ∈ H, k ≤ e.card)
    (hcard : H.card < 2 ^ (k - 1)) :
    ∃ R : Finset (Fin N), ∀ e ∈ H, ¬ (e ⊆ R) ∧ ¬ Disjoint e R := by
  by_contra h_no_coloring;
  -- Let's calculate the total number of "bad" colorings.
  have h_total_bad : Finset.card (Finset.biUnion H (fun e => Finset.filter (fun R => e ⊆ R) (Finset.powerset (Finset.univ : Finset (Fin N))) ∪ Finset.filter (fun R => Disjoint e R) (Finset.powerset (Finset.univ : Finset (Fin N))))) < 2 ^ N := by
    -- For each edge $e \in H$, the number of "bad" colorings is at most $2^{N-k+1}$.
    have h_bad_colorings_per_edge : ∀ e ∈ H, Finset.card (Finset.filter (fun R => e ⊆ R) (Finset.powerset (Finset.univ : Finset (Fin N))) ∪ Finset.filter (fun R => Disjoint e R) (Finset.powerset (Finset.univ : Finset (Fin N)))) ≤ 2 ^ (N - k + 1) := by
      intros e he
      have h_bad_colorings_per_edge : Finset.card (Finset.filter (fun R => e ⊆ R) (Finset.powerset (Finset.univ : Finset (Fin N)))) ≤ 2 ^ (N - k) ∧ Finset.card (Finset.filter (fun R => Disjoint e R) (Finset.powerset (Finset.univ : Finset (Fin N)))) ≤ 2 ^ (N - k) := by
        constructor;
        · have h_filter_superset : (Finset.filter (fun R => e ⊆ R) (Finset.powerset (Finset.univ : Finset (Fin N)))).card = 2 ^ (N - e.card) := by
            convert card_filter_superset ( Finset.univ : Finset ( Fin N ) ) e ( Finset.subset_univ e ) using 1;
            rw [ Finset.card_fin ];
          exact h_filter_superset.symm ▸ pow_le_pow_right₀ ( by decide ) ( Nat.sub_le_sub_left ( hedge e he ) _ );
        · have := PropertyB.card_filter_disjoint ( Finset.univ : Finset ( Fin N ) ) e ( Finset.subset_univ e );
          exact this.le.trans ( pow_le_pow_right₀ ( by decide ) ( Nat.sub_le_sub_left ( hedge e he ) _ ) ) |> le_trans <| by simp +decide ;
      exact le_trans ( Finset.card_union_le _ _ ) ( by rw [ pow_succ' ] ; linarith );
    refine' lt_of_le_of_lt ( Finset.card_biUnion_le ) _;
    refine' lt_of_le_of_lt ( Finset.sum_le_sum h_bad_colorings_per_edge ) _ ; norm_num [ pow_add ] at *;
    rcases k with ( _ | k ) <;> simp_all +decide;
    by_cases hN : N ≥ k + 1;
    · convert mul_lt_mul_of_pos_right hcard ( show 0 < 2 ^ ( N - ( k + 1 ) ) * 2 by positivity ) using 1 ; rw [ show 2 ^ N = 2 ^ ( k + 1 ) * 2 ^ ( N - ( k + 1 ) ) by rw [ ← pow_add, Nat.add_sub_of_le hN ] ] ; ring;
    · exact absurd ( h_no_coloring ∅ ) ( by rintro ⟨ e, he, he' ⟩ ; specialize hedge e he; linarith [ show Finset.card e ≤ N from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ] );
  convert h_total_bad.ne ?_;
  rw [ show ( Finset.biUnion H fun e => Finset.filter ( fun R => e ⊆ R ) ( Finset.powerset Finset.univ ) ∪ Finset.filter ( fun R => Disjoint e R ) ( Finset.powerset Finset.univ ) ) = Finset.powerset Finset.univ from ?_ ];
  · simp +decide [ Finset.card_univ ];
  · ext R; simp;
    exact not_forall_not.mp fun h => h_no_coloring ⟨ R, fun e he => by specialize h e; aesop ⟩

/-! ## The classical `k`-uniform statement -/

/-- **Property B, `k`-uniform form.** A `k`-uniform hypergraph (`k ≥ 1`) with fewer than
`2^{k-1}` edges admits a 2-colouring with no monochromatic edge. -/
theorem property_B (N k : ℕ) (hk : 1 ≤ k)
    (H : Finset (Finset (Fin N)))
    (huniform : ∀ e ∈ H, e.card = k)
    (hcard : H.card < 2 ^ (k - 1)) :
    ∃ R : Finset (Fin N), ∀ e ∈ H, ¬ (e ⊆ R) ∧ ¬ Disjoint e R :=
  exists_proper_two_coloring N k hk H (fun e he => (huniform e he).ge) hcard

/-- Restatement: a `k`-uniform hypergraph with fewer than `2^{k-1}` edges is 2-colourable,
where 2-colourability is phrased as "there is a red set meeting and missing every edge". -/
theorem two_colorable_of_lt (N k : ℕ) (hk : 1 ≤ k)
    (H : Finset (Finset (Fin N)))
    (huniform : ∀ e ∈ H, e.card = k)
    (hcard : H.card < 2 ^ (k - 1)) :
    ∃ R : Finset (Fin N), ∀ e ∈ H, (∃ v ∈ e, v ∈ R) ∧ (∃ v ∈ e, v ∉ R) := by
  obtain ⟨R, hR⟩ := property_B N k hk H huniform hcard
  refine ⟨R, fun e he => ⟨?_, ?_⟩⟩
  · -- e ⊄ ... no: ¬ Disjoint e R means some vertex of e is red
    rcases Finset.not_disjoint_iff.1 (hR e he).2 with ⟨v, hve, hvR⟩
    exact ⟨v, hve, hvR⟩
  · -- ¬ (e ⊆ R) means some vertex of e is not red (blue)
    rcases Finset.not_subset.1 (hR e he).1 with ⟨v, hve, hvR⟩
    exact ⟨v, hve, hvR⟩

/-! ## Concrete instances -/

/-- The complete `3`-uniform "triangle" hypergraph on `4` vertices (all `4` triples) is
2-colourable: it has `4 = C(4,3)` edges and `4 < 2^{3-1} = 4`? — no, `4 ≮ 4`.  Instead we
take any `3` of the four triples, giving `3 < 4` edges, hence 2-colourable. -/
theorem property_B_three_edges_three_uniform (H : Finset (Finset (Fin 6)))
    (huniform : ∀ e ∈ H, e.card = 3) (hcard : H.card ≤ 3) :
    ∃ R : Finset (Fin 6), ∀ e ∈ H, ¬ (e ⊆ R) ∧ ¬ Disjoint e R :=
  property_B 6 3 (by norm_num) H huniform (by omega)

/-- Any single edge of size `≥ 2` is 2-colourable (Property B with `k = 2`, `m = 1 < 2`). -/
theorem single_edge_two_colorable (N : ℕ) (e : Finset (Fin N)) (he : 2 ≤ e.card) :
    ∃ R : Finset (Fin N), ¬ (e ⊆ R) ∧ ¬ Disjoint e R := by
  obtain ⟨R, hR⟩ := exists_proper_two_coloring N 2 (by norm_num) {e}
    (by intro x hx; simp only [Finset.mem_singleton] at hx; subst hx; exact he)
    (by simp)
  exact ⟨R, hR e (by simp)⟩

/-! ## The extremal function `m(k)`: the lower bound `2^{k-1} ≤ m(k)` -/

/-- A hypergraph on `Fin N` is *not 2-colourable* if every red/blue colouring (encoded by the
red set `R`) leaves at least one monochromatic edge (either entirely red, `e ⊆ R`, or entirely
blue, `Disjoint e R`). -/
def IsNonTwoColorable {N : ℕ} (H : Finset (Finset (Fin N))) : Prop :=
  ∀ R : Finset (Fin N), ∃ e ∈ H, e ⊆ R ∨ Disjoint e R

/-- Contrapositive of `exists_proper_two_coloring`: any hypergraph on `Fin N` whose edges each
have at least `k ≥ 1` vertices and which is *not* 2-colourable must have at least `2^{k-1}`
edges.  This is exactly the lower bound `2^{k-1} ≤ m(k)` on Erdős's extremal function `m(k)`
(the least number of edges of a non-2-colourable `k`-uniform hypergraph). -/
theorem card_ge_of_nonTwoColorable (N k : ℕ) (hk : 1 ≤ k)
    (H : Finset (Finset (Fin N)))
    (hedge : ∀ e ∈ H, k ≤ e.card)
    (hnon : IsNonTwoColorable H) :
    2 ^ (k - 1) ≤ H.card := by
  by_contra h
  push_neg at h
  obtain ⟨R, hR⟩ := exists_proper_two_coloring N k hk H hedge h
  obtain ⟨e, he, hmono⟩ := hnon R
  rcases hmono with h1 | h1
  · exact (hR e he).1 h1
  · exact (hR e he).2 h1

/-- The `k`-uniform form of the extremal lower bound: a non-2-colourable `k`-uniform hypergraph
(`k ≥ 1`) has at least `2^{k-1}` edges. -/
theorem card_ge_of_nonTwoColorable_uniform (N k : ℕ) (hk : 1 ≤ k)
    (H : Finset (Finset (Fin N)))
    (huniform : ∀ e ∈ H, e.card = k)
    (hnon : IsNonTwoColorable H) :
    2 ^ (k - 1) ≤ H.card :=
  card_ge_of_nonTwoColorable N k hk H (fun e he => (huniform e he).ge) hnon

/-! ## A concrete extremal witness: the triangle graph (`m(2) ≤ 3`) -/

/-- The triangle: the complete `2`-uniform hypergraph (graph) on the `3` vertices of `Fin 3`,
with edge set `{{0,1}, {1,2}, {0,2}}`. -/
def triangleGraph : Finset (Finset (Fin 3)) := {{0, 1}, {1, 2}, {0, 2}}

/-- The triangle has exactly `3` edges. -/
theorem triangleGraph_card : triangleGraph.card = 3 :=
  decide_eq_true_eq.mp rfl

/-- The triangle is `2`-uniform: each of its edges has exactly `2` vertices. -/
theorem triangleGraph_two_uniform : ∀ e ∈ triangleGraph, e.card = 2 :=
  decide_eq_true_eq.mp rfl

/-- The triangle is **not** 2-colourable: every red/blue split of its three vertices leaves a
monochromatic edge (two of the three vertices always share a colour, and every pair is an edge).
Verified by finite case check over the `2^3 = 8` colourings. -/
theorem triangleGraph_nonTwoColorable : IsNonTwoColorable triangleGraph := by
  show ∀ R : Finset (Fin 3), ∃ e ∈ triangleGraph, e ⊆ R ∨ Disjoint e R
  exact decide_eq_true_eq.mp rfl

/-- **Matching upper bound `m(2) ≤ 3`.** There exists a non-2-colourable `2`-uniform hypergraph
with exactly `3` edges (the triangle).  Together with the lower bound
`card_ge_of_nonTwoColorable_uniform` (which forces `2^{2-1} = 2 ≤ 3` edges here) this exhibits an
extremal configuration for `k = 2`. -/
theorem exists_nonTwoColorable_two_uniform_three_edges :
    ∃ H : Finset (Finset (Fin 3)),
      (∀ e ∈ H, e.card = 2) ∧ H.card = 3 ∧ IsNonTwoColorable H :=
  ⟨triangleGraph, triangleGraph_two_uniform, triangleGraph_card, triangleGraph_nonTwoColorable⟩

end PropertyB