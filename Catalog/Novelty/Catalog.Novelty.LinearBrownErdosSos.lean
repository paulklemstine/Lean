/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Linear Brown–Erdős–Sós framework

This file develops the combinatorial groundwork surrounding the **(Linear) Brown–Erdős–Sós (BES)
conjecture**.  Recall that for `r`-uniform hypergraphs the BES extremal function `f_r(n; v, e)`
counts the maximum number of edges of an `r`-uniform hypergraph on `n` vertices that contains *no*
`e` edges spanning at most `v` vertices.  The conjecture of Brown, Erdős and Sós (1973) concerns the
critical span value

> `v = (r-2)·e + 3`,

and asserts that on this threshold the extremal function is sub-quadratic, `f_r(n; (r-2)e+3, e) =
o(n²)`.  The single solved instance `r = 3, e = 3`, where the threshold reads `(3-2)·3+3 = 6`, is
exactly the **Ruzsa–Szemerédi `(6,3)`-theorem**: three triples spanning at most six vertices form a
"linear triangle", and forbidding them caps the edge count at `o(n²)`.

The *linear* refinement studies the same threshold under the structural hypothesis of linearity
(any two edges meet in at most one vertex), the regime of Keevash–Long.  This file isolates the
exact, finitary facts that underpin the programme.

## Main results
* `linear_packing_bound` — the **pair-packing / Fisher-type bound**
  `|E(H)| · C(r,2) ≤ C(n,2)` for any linear `r`-uniform hypergraph.
* `linear_span_ge` — the **span lower bound** from incidence double counting: any `k` edges of a
  linear `r`-uniform hypergraph span at least `k·r − C(k,2)` vertices, stated subtraction-free as
  `k·r ≤ |span| + C(k,2)`.
* `total_span_lower_bound` — if every `k` edges span more than `(r-2)k+3` vertices, the *total* span
  exceeds `(r-2)k+3` as well.
* `besThreshold`, `ruzsaSzemeredi_threshold`, `linear_threshold_tight`,
  `linear_threshold_gap`, `linear_meets_threshold` — the **threshold comparison** results: the
  linear span bound matches the BES threshold exactly for `k ∈ {2,3}` (in particular at the
  Ruzsa–Szemerédi point `r=3, k=3`, value `6`), and falls strictly short for `k ≥ 4`, which is
  precisely where the conjecture becomes non-trivial.
* `LinearBESConjecture` — the **open conjecture** itself, stated as an explicit `Prop` (left
  unproven, as it is a major open problem).
-/
import Mathlib

open Finset

namespace LinearHypergraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A finite family of edges is **`r`-uniform** if every edge has exactly `r` vertices. -/
def IsUniform (edges : Finset (Finset V)) (r : ℕ) : Prop :=
  ∀ e ∈ edges, e.card = r

/-- A finite family of edges is **linear** if any two distinct edges meet in at most one vertex. -/
def IsLinear (edges : Finset (Finset V)) : Prop :=
  ∀ e₁ ∈ edges, ∀ e₂ ∈ edges, e₁ ≠ e₂ → (e₁ ∩ e₂).card ≤ 1

/-- The set of vertices **spanned** by a family of edges: the union of all its edges. -/
def span (edges : Finset (Finset V)) : Finset V := edges.biUnion id

omit [Fintype V] in
@[simp] theorem mem_span {edges : Finset (Finset V)} {v : V} :
    v ∈ span edges ↔ ∃ e ∈ edges, v ∈ e := by
  simp [span]

/-! ### Pair-disjointness, the engine of the packing bound -/

omit [Fintype V] in
/-- For a linear family, the "pair sets" `powersetCard 2 e` are pairwise disjoint: a common
2-subset would force two edges to share two vertices. -/
theorem pairs_disjoint {edges : Finset (Finset V)} (hlin : IsLinear edges) :
    (edges : Set (Finset V)).PairwiseDisjoint (fun e => powersetCard 2 e) := by
  intro e he f hf hne
  by_contra h_inter
  have h_card : (e ∩ f).card ≥ 2 := by
    obtain ⟨p, hp₁, hp₂⟩ := Finset.not_disjoint_iff.mp h_inter
    exact Finset.card_le_card (Finset.subset_inter (Finset.mem_powersetCard.mp hp₁ |>.1)
      (Finset.mem_powersetCard.mp hp₂ |>.1)) |> le_trans (Finset.mem_powersetCard.mp hp₁ |>.2.ge)
  linarith [hlin e he f hf hne]

/-- The disjoint union of the per-edge pair sets is contained in the set of all vertex pairs. -/
theorem biUnion_pairs_subset (edges : Finset (Finset V)) :
    edges.biUnion (fun e => powersetCard 2 e) ⊆ (univ : Finset V).powersetCard 2 := by
  intro p hp
  simp only [Finset.mem_biUnion, Finset.mem_powersetCard] at hp ⊢
  obtain ⟨e, _, hpe, hpc⟩ := hp
  exact ⟨Finset.subset_univ p, hpc⟩

/-! ### 1. The linear packing bound -/

/--
**Linear packing bound.** For a linear `r`-uniform hypergraph `H` on `n = |V|` vertices,
`|E(H)| · C(r,2) ≤ C(n,2)`.  Each edge accounts for `C(r,2)` pairs of vertices, linearity makes
these pair-sets disjoint, and there are only `C(n,2)` pairs in total.
-/
theorem linear_packing_bound {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) :
    edges.card * r.choose 2 ≤ (Fintype.card V).choose 2 := by
  have h_final : ∑ e ∈ edges, (powersetCard 2 e).card = edges.card * r.choose 2 := by
    rw [Finset.sum_congr rfl fun x hx => by rw [Finset.card_powersetCard, huni x hx]]
    simp +decide
  rw [← h_final, ← Finset.card_biUnion (pairs_disjoint hlin)]
  exact le_trans (Finset.card_le_card (biUnion_pairs_subset edges))
    (by simp +decide [Finset.card_univ, Nat.choose_two_right])

/-! ### 2. The span lower bound -/

/-
**Span lower bound (incidence double count).** Any `k` edges of a linear `r`-uniform hypergraph
span at least `k·r − C(k,2)` vertices.  Stated subtraction-free:
`(#edges)·r ≤ |span edges| + C(#edges, 2)`.

Proof idea: count incidences `∑_v deg(v) = (#edges)·r` and pairs through a vertex
`∑_v C(deg v, 2) = ∑_{e≠f} |e ∩ f| ≤ C(#edges, 2)` (linearity), then use `deg v − 1 ≤ C(deg v, 2)`.
-/
theorem linear_span_ge {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) :
    edges.card * r ≤ (span edges).card + (edges.card).choose 2 := by
  have h_deg : ∀ v ∈ span edges, (Finset.card (Finset.filter (fun e => v ∈ e) edges)) ≤ 1 + Nat.choose (Finset.card (Finset.filter (fun e => v ∈ e) edges)) 2 := by
    intro v hv; rcases n : Finset.card ( Finset.filter ( fun e => v ∈ e ) edges ) with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.choose ] ;
  have h_sum_deg : ∑ v ∈ span edges, Finset.card (Finset.filter (fun e => v ∈ e) edges) = edges.card * r := by
    simp +decide only [card_filter];
    rw [ Finset.sum_comm, Finset.sum_congr rfl fun x hx => ?_ ];
    rw [ Finset.sum_const, smul_eq_mul, mul_comm ];
    simp +decide;
    rw [ Finset.inter_eq_right.mpr ( show x ⊆ span edges from fun v hv => Finset.mem_biUnion.mpr ⟨ x, hx, hv ⟩ ), huni x hx ];
  have h_sum_choose : ∑ v ∈ span edges, Nat.choose (Finset.card (Finset.filter (fun e => v ∈ e) edges)) 2 ≤ Nat.choose edges.card 2 := by
    have h_sum_choose : ∑ v ∈ span edges, Nat.choose (Finset.card (Finset.filter (fun e => v ∈ e) edges)) 2 = ∑ p ∈ Finset.powersetCard 2 edges, (Finset.card (Finset.filter (fun v => ∀ e ∈ p, v ∈ e) (span edges))) := by
      have h_sum_choose : ∀ v ∈ span edges, Nat.choose (Finset.card (Finset.filter (fun e => v ∈ e) edges)) 2 = ∑ p ∈ Finset.powersetCard 2 edges, (if ∀ e ∈ p, v ∈ e then 1 else 0) := by
        intro v hv
        have h_pair_count : Finset.powersetCard 2 (Finset.filter (fun e => v ∈ e) edges) = Finset.filter (fun p => ∀ e ∈ p, v ∈ e) (Finset.powersetCard 2 edges) := by
          grind;
        replace h_pair_count := congr_arg Finset.card h_pair_count; aesop;
      rw [ Finset.sum_congr rfl h_sum_choose, Finset.sum_comm ] ; simp +decide ;
    -- Since each pair of edges intersects in at most one vertex, the number of vertices in the intersection of any two edges is at most 1.
    have h_inter : ∀ p ∈ Finset.powersetCard 2 edges, (Finset.card (Finset.filter (fun v => ∀ e ∈ p, v ∈ e) (span edges))) ≤ 1 := by
      intro p hp; rw [ Finset.mem_powersetCard ] at hp; obtain ⟨ e₁, e₂, he₁, he₂, he ⟩ := Finset.card_eq_two.mp hp.2; simp_all +decide [ Finset.subset_iff ] ;
      exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun v => v ∈ e₁ ∧ v ∈ e₂ ) ( span edges ) ⊆ e₁ ∩ e₂ from fun x hx => by aesop ) ) ( hlin e₁ hp.1 e₂ hp.2 he₁ );
    exact h_sum_choose.symm ▸ le_trans ( Finset.sum_le_sum h_inter ) ( by simp +decide );
  exact h_sum_deg ▸ le_trans ( Finset.sum_le_sum h_deg ) ( by simp +decide [ Finset.sum_add_distrib ] ; linarith )

omit [Fintype V] in
/--
**Total span lower bound.** If every `k` edges of `H` span more than `(r-2)·k + 3` vertices, then
(provided `H` has at least `k` edges) the *whole* family spans more than `(r-2)·k + 3` vertices:
a `k`-subset witnesses the bound and its span is contained in the total span.
-/
theorem total_span_lower_bound {edges : Finset (Finset V)} {r k : ℕ}
    (hkm : k ≤ edges.card)
    (hspan : ∀ S ⊆ edges, S.card = k → (r - 2) * k + 3 < (span S).card) :
    (r - 2) * k + 3 < (span edges).card := by
  obtain ⟨S, hSsub, hScard⟩ := Finset.exists_subset_card_eq hkm
  have hlt := hspan S hSsub hScard
  have hmono : span S ⊆ span edges :=
    Finset.biUnion_subset_biUnion_of_subset_left id hSsub
  exact lt_of_lt_of_le hlt (Finset.card_le_card hmono)

/-! ### 3. Threshold comparison and the Ruzsa–Szemerédi point -/

/-- The **Brown–Erdős–Sós span threshold** `(r-2)·k + 3` for `k` edges of an `r`-uniform
hypergraph. -/
def besThreshold (r k : ℕ) : ℕ := (r - 2) * k + 3

/-- At the Ruzsa–Szemerédi point `r = 3, k = 3`, the BES threshold equals `6`: forbidding three
triples on at most six vertices is the `(6,3)`-problem. -/
theorem ruzsaSzemeredi_threshold : besThreshold 3 3 = 6 := by
  decide

/--
**Threshold tightness for small `k`.** For `k = 2` and `k = 3` (and `r ≥ 2`) the linear span bound
is exactly tight against the BES threshold:
`k·r = besThreshold r k + C(k,2)`.  Hence linearity *alone* forces any `k ≤ 3` edges to span at
least `besThreshold r k` vertices.
-/
theorem linear_threshold_tight {r k : ℕ} (hr : 2 ≤ r) (hk : k = 2 ∨ k = 3) :
    k * r = besThreshold r k + k.choose 2 := by
  rcases hk with rfl | rfl <;> simp only [besThreshold, Nat.choose] <;> omega

/--
**Threshold gap for `k = 4`.** From `k = 4` on, the linear span bound falls strictly short of the
BES threshold: `besThreshold r 4 + C(4,2) = 4·r + 1 > 4·r`.  This is the first `k` where the linear
span bound no longer guarantees the BES span condition, marking the onset of the open regime.
-/
theorem linear_threshold_gap {r : ℕ} (hr : 2 ≤ r) :
    4 * r < besThreshold r 4 + (4).choose 2 := by
  simp only [besThreshold, Nat.choose]
  omega

/--
**Linearity meets the threshold for `k ≤ 3`.** Combining the span lower bound with threshold
tightness: any `k ∈ {2,3}` edges of a linear `r`-uniform hypergraph (`r ≥ 2`) span at least
`besThreshold r k` vertices.
-/
theorem linear_meets_threshold {edges : Finset (Finset V)} {r k : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges)
    (hr : 2 ≤ r) (hcard : edges.card = k) (hk : k = 2 ∨ k = 3) :
    besThreshold r k ≤ (span edges).card := by
  have h1 := linear_span_ge huni hlin
  rw [hcard] at h1
  have h2 := linear_threshold_tight (r := r) (k := k) hr hk
  omega

/-! ### 4. The open conjecture -/

/--
**The Linear Brown–Erdős–Sós conjecture** (for parameters `r` and `k`).

A linear `r`-uniform hypergraph in which every `k` edges span more than the BES threshold
`(r-2)k+3` vertices has a *sub-quadratic* number of edges: for every `ε > 0` there is `N` such that
for all `n ≥ N`, every such hypergraph on `n` vertices has at most `ε·n²` edges.

This is a major open problem; it is solved only for `r = 3, k = 3` (the Ruzsa–Szemerédi
`(6,3)`-theorem).  It is stated here as an explicit `Prop` and deliberately left **unproven**. -/
def LinearBESConjecture (r k : ℕ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ N : ℕ, ∀ (n : ℕ), N ≤ n →
    ∀ (W : Type) [Fintype W] [DecidableEq W], Fintype.card W = n →
      ∀ (edges : Finset (Finset W)),
        IsUniform edges r → IsLinear edges →
        (∀ S ⊆ edges, S.card = k → (r - 2) * k + 3 < (span S).card) →
        (edges.card : ℝ) ≤ ε * (n : ℝ) ^ 2

end LinearHypergraph