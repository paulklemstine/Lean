/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Optimality of the density threshold for linear `r`-uniform hypergraphs

A hypergraph is *linear* (a.k.a. *partial Steiner*) when any two distinct edges meet in at most
one vertex.  This is the structural hypothesis underlying the Brown–Erdős–Sós (BES) programme and
the Keevash–Long (2023) work on sparse linear hypergraphs: linearity is exactly the condition that
"no pair of vertices is covered twice".

The fundamental density statement is the *pair-counting bound*: a linear `r`-uniform hypergraph on
`n` vertices has at most `C(n,2) / C(r,2)` edges, equivalently

> `m · C(r,2) ≤ C(n,2)`,

where `m` is the number of edges.  Writing this over `ℝ` gives the density threshold
`m ≤ n(n-1) / (r(r-1))`, with leading coefficient `1/(r(r-1))`.

We prove this bound and, crucially, its **optimality**: a *Steiner* system `S(2,r,n)` — a linear
hypergraph in which every pair of vertices is covered (necessarily exactly once) — attains equality
`m · C(r,2) = C(n,2)`.  Thus the coefficient `1/(r(r-1))` cannot be improved; the threshold is
sharp whenever a Steiner system exists.

## Catalog connections
* `Brown–Erdős–Sós conjecture`: linearity = "every pair covered at most once" is the `e = 2`
  boundary case of the BES extremal function; `linear_card_le` is the exact pair-count cap that the
  general BES function refines.
* `Keevash–Long 2023 (sparse linear hypergraphs)`: this file isolates the linear-hypergraph density
  threshold `1/(r(r-1))` whose optimality `steiner_card_eq` is the anchor of their regime.
* `mathlib: Finset.card_biUnion`, `Finset.card_powersetCard`: the disjoint-pairs double count is
  powered by these two cardinality lemmas.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Linearity is *equivalent* to the pairwise-disjointness of the
  "pair sets" `powersetCard 2 e`.  Hence the edge count is governed by a single double count of
  vertex pairs, giving `m · C(r,2) ≤ C(n,2)`, and Steiner systems make this an equality.
Experiment (Experimenter): Modelled a hypergraph as `edges : Finset (Finset V)` with uniformity
  `e.card = r` and linearity `(e₁ ∩ e₂).card ≤ 1` for `e₁ ≠ e₂`.  Mapped each edge `e` to its
  2-subsets `powersetCard 2 e` (cardinality `C(r,2)`); linearity forces these families to be
  pairwise disjoint, so `card_biUnion` turns `∑ C(r,2)` into the size of a subfamily of all pairs.
Analysis (Analyst): The bound is a pure counting identity once disjointness is established: the
  load-bearing step is `pairs_disjoint`, which converts the geometric "share ≤ 1 vertex" into the
  combinatorial "share no 2-subset".  Equality in the Steiner case is the same identity run with
  the inclusion replaced by `biUnion = univ.powersetCard 2`.
Critique (Critic): No theorem is vacuous — `linear_card_le` holds for *every* uniform linear
  hypergraph (including the empty one, where it reads `0 ≤ C(n,2)`), and `steiner_card_eq` is a
  genuine equality conditioned on full pair coverage, which is exactly the defining property of a
  Steiner system.  The optimality claim is therefore real: the same `C(r,2)` factor appears on both
  the `≤` and the `=` side, so the coefficient is sharp.
Synthesis (PI): A self-contained, sharp density threshold `m ≤ C(n,2)/C(r,2)` for linear
  hypergraphs, with matching Steiner equality certifying optimality of the `1/(r(r-1))` coefficient.
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

/-- A **Steiner system** `S(2,r,n)`: a linear `r`-uniform family covering every pair of vertices,
i.e. every 2-element subset of the vertex set is contained in some edge. -/
def IsSteiner (edges : Finset (Finset V)) (r : ℕ) : Prop :=
  IsUniform edges r ∧ IsLinear edges ∧
    ∀ p ∈ (univ : Finset V).powersetCard 2, ∃ e ∈ edges, p ⊆ e

/-
**Key combinatorial step.** For a linear family, the "pair sets" `powersetCard 2 e` are
pairwise disjoint: a common 2-subset would force two edges to share two vertices.
-/
omit [Fintype V] in
theorem pairs_disjoint {edges : Finset (Finset V)} (hlin : IsLinear edges) :
    (edges : Set (Finset V)).PairwiseDisjoint (fun e => powersetCard 2 e) := by
  intro e he f hf hne
  by_contra h_inter
  have h_card : (e ∩ f).card ≥ 2 := by
    obtain ⟨ p, hp₁, hp₂ ⟩ := Finset.not_disjoint_iff.mp h_inter; exact Finset.card_le_card ( Finset.subset_inter ( Finset.mem_powersetCard.mp hp₁ |>.1 ) ( Finset.mem_powersetCard.mp hp₂ |>.1 ) ) |> le_trans ( Finset.mem_powersetCard.mp hp₁ |>.2.ge ) ;
  linarith [hlin e he f hf hne]

/-
The disjoint union of the per-edge pair sets is contained in the set of all vertex pairs.
-/
theorem biUnion_pairs_subset (edges : Finset (Finset V)) :
    edges.biUnion (fun e => powersetCard 2 e) ⊆ (univ : Finset V).powersetCard 2 := by
  grind +suggestions

/-
**Density threshold (upper bound).** A linear `r`-uniform hypergraph on `n = |V|` vertices has
at most `C(n,2)/C(r,2)` edges: `m · C(r,2) ≤ C(n,2)`.
-/
theorem linear_card_le {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) :
    edges.card * r.choose 2 ≤ (Fintype.card V).choose 2 := by
  -- By combining the results from the previous steps, we conclude the proof.
  have h_final : ∑ e ∈ edges, (e.powersetCard 2).card = edges.card * r.choose 2 := by
    rw [ Finset.sum_congr rfl fun x hx => by rw [ Finset.card_powersetCard, huni x hx ] ] ; simp +decide ;
  rw [ ← h_final, ← Finset.card_biUnion ];
  · exact le_trans ( Finset.card_le_card ( biUnion_pairs_subset edges ) ) ( by simp +decide [ Finset.card_univ, Nat.choose_two_right ] );
  · exact pairs_disjoint hlin

/-
**Optimality / sharpness.** A Steiner system attains the threshold with equality:
`m · C(r,2) = C(n,2)`. Hence the coefficient `1/(r(r-1))` in the density bound cannot be improved.
-/
theorem steiner_card_eq {edges : Finset (Finset V)} {r : ℕ}
    (hst : IsSteiner edges r) :
    edges.card * r.choose 2 = (Fintype.card V).choose 2 := by
  -- By definition of IsSteiner, we know that every pair of vertices is contained in exactly one edge.
  have h_pairwise_disjoint : (edges.biUnion (fun e => Finset.powersetCard 2 e)) = Finset.powersetCard 2 (Finset.univ : Finset V) := by
    refine' Finset.Subset.antisymm ( biUnion_pairs_subset edges ) _;
    intro p hp; cases' hst.2.2 p hp with e he; aesop;
  have h_card_biUnion : (edges.biUnion (fun e => Finset.powersetCard 2 e)).card = edges.card * r.choose 2 := by
    rw [ Finset.card_biUnion ];
    · simp +decide;
      rw [ Finset.sum_congr rfl fun x hx => by rw [ hst.1 x hx ] ] ; simp +decide;
    · exact pairs_disjoint hst.2.1;
  aesop

/-
**Real-valued density bound.** Restating `linear_card_le` as
`m ≤ n(n-1) / (r(r-1))` over `ℝ`, for `r ≥ 2`.
-/
theorem linear_density_real {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) (hr : 2 ≤ r) :
    (edges.card : ℝ) ≤
      (Fintype.card V : ℝ) * (Fintype.card V - 1) / ((r : ℝ) * (r - 1)) := by
  -- Apply the density bound from the previous steps.
  have h_density : edges.card * (r * (r - 1)) ≤ (Fintype.card V) * ((Fintype.card V) - 1) := by
    convert mul_le_mul_of_nonneg_right ( linear_card_le huni hlin ) zero_le_two using 1 <;> norm_num [ Nat.choose_two_right ];
    · rw [ mul_assoc, Nat.div_mul_cancel ( even_iff_two_dvd.mp ( Nat.even_mul_pred_self _ ) ) ];
    · rw [ Nat.div_mul_cancel ( even_iff_two_dvd.mp ( Nat.even_mul_pred_self _ ) ) ];
  rw [ le_div_iff₀, mul_comm ];
  · rcases r with ( _ | _ | r ) <;> norm_num at *;
    cases n : Fintype.card V <;> simp_all +decide [ mul_comm ];
    norm_cast;
  · exact mul_pos ( by positivity ) ( by norm_num; linarith )

end LinearHypergraph