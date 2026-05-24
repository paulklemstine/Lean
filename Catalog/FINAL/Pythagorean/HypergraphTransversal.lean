/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Fractional Transversals and Integrality Gaps in Hypergraphs

This file develops the theory of fractional transversals and fractional matchings
for finite hypergraphs, and proves fundamental bounds relating the fractional
transversal number to the integer transversal number.

## Main Definitions

* `Hypergraph` — a hypergraph on vertex type `V`, given by a finite set of edges
* `Hypergraph.IsTransversal` — a set that intersects every edge
* `Hypergraph.IsFracTransversal` — a nonnegative real-valued function on vertices
  with sum ≥ 1 on every edge
* `Hypergraph.IsFracMatching` — a nonnegative real-valued function on edges
  with sum ≤ 1 at every vertex

## Main Results

* `Hypergraph.indicator_isFracTransversal` — the indicator of an integer transversal
  is a fractional transversal, giving τ* ≤ τ
* `Hypergraph.weak_duality` — for any fractional transversal x and fractional matching y,
  the matching value is at most the transversal value (ν* ≤ τ*)
* `Hypergraph.rounding_transversal` — any fractional transversal can be rounded to
  an integer transversal of size at most d_max times the fractional value
* `Hypergraph.uniform_rounding` — the k-uniform special case
-/

namespace Hypergraph

/-- A hypergraph on vertex type `V` is a finite collection of edges,
    where each edge is a finset of vertices. -/
structure Hypergraph (V : Type*) where
  edges : Finset (Finset V)

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A finset `S` is a transversal of hypergraph `H` if it intersects every edge. -/
def IsTransversal (H : Hypergraph V) (S : Finset V) : Prop :=
  ∀ e ∈ H.edges, (S ∩ e).Nonempty

/-- A function `x : V → ℝ` is a fractional transversal of `H` if it is nonnegative
    and the sum over each edge is at least 1. -/
def IsFracTransversal (H : Hypergraph V) (x : V → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ e ∈ H.edges, 1 ≤ ∑ v ∈ e, x v

/-- The value (objective) of a fractional transversal assignment. -/
noncomputable def fracTransversalValue (x : V → ℝ) : ℝ :=
  ∑ v : V, x v

/-- A function `y : Finset V → ℝ` is a fractional matching of `H` if it is nonnegative
    on edges and the sum at each vertex is at most 1. -/
def IsFracMatching (H : Hypergraph V) (y : Finset V → ℝ) : Prop :=
  (∀ e, 0 ≤ y e) ∧
  ∀ v : V, ∑ e ∈ H.edges.filter (fun e => v ∈ e), y e ≤ 1

/-- The value of a fractional matching assignment. -/
noncomputable def fracMatchingValue (H : Hypergraph V) (y : Finset V → ℝ) : ℝ :=
  ∑ e ∈ H.edges, y e

/-- The indicator function of a finset, as a real-valued function. -/
noncomputable def indicator (S : Finset V) : V → ℝ :=
  fun v => if v ∈ S then 1 else 0

omit [Fintype V] in
theorem indicator_nonneg (S : Finset V) (v : V) : 0 ≤ indicator S v := by
  simp [indicator]
  split <;> norm_num

omit [Fintype V] in
theorem indicator_mem (S : Finset V) (v : V) (hv : v ∈ S) : indicator S v = 1 := by
  simp [indicator, hv]

omit [Fintype V] in
theorem indicator_not_mem (S : Finset V) (v : V) (hv : v ∉ S) : indicator S v = 0 := by
  simp [indicator, hv]

/-
**Indicator is fractional transversal**: If `S` is a transversal of `H`,
    then the indicator function of `S` is a fractional transversal. This
    immediately gives τ* ≤ τ.
-/
theorem indicator_isFracTransversal (H : Hypergraph V) (S : Finset V)
    (hS : IsTransversal H S) : IsFracTransversal H (indicator S) := by
  refine' ⟨ indicator_nonneg S, fun e he => _ ⟩;
  obtain ⟨ v, hv ⟩ := hS e he;
  refine' le_trans _ ( Finset.single_le_sum ( fun x _ => indicator_nonneg S x ) ( Finset.mem_coe.mpr ( Finset.mem_of_mem_inter_right hv ) ) ) ; simp +decide [ indicator_mem S v ( Finset.mem_of_mem_inter_left hv ) ]

/-
The value of the indicator fractional transversal equals the cardinality of the set.
-/
theorem indicator_value (S : Finset V) :
    fracTransversalValue (indicator S) = (S.card : ℝ) := by
  unfold fracTransversalValue indicator;
  simp +decide

/-
**Weak duality**: For any fractional transversal `x` and fractional matching `y`,
    the matching value is at most the transversal value. This is the LP weak duality
    inequality ν* ≤ τ*.
-/
theorem weak_duality (H : Hypergraph V) (x : V → ℝ) (y : Finset V → ℝ)
    (hx : IsFracTransversal H x) (hy : IsFracMatching H y) :
    fracMatchingValue H y ≤ fracTransversalValue x := by
  -- Apply the commutativity of summation to swap the order of the sums.
  have h_comm : ∑ e ∈ H.edges, y e * ∑ v ∈ e, x v = ∑ v, x v * ∑ e ∈ H.edges.filter (fun e => v ∈ e), y e := by
    simp +decide only [Finset.mul_sum _ _ _, mul_comm];
    rw [ Finset.sum_sigma', Finset.sum_sigma' ];
    refine' Finset.sum_bij ( fun e _ => ⟨ e.snd, e.fst ⟩ ) _ _ _ _ <;> aesop;
  refine' le_trans _ ( h_comm.trans_le _ );
  · exact Finset.sum_le_sum fun e he => le_mul_of_one_le_right ( hy.1 e ) ( hx.2 e he );
  · exact Finset.sum_le_sum fun v _ => mul_le_of_le_one_right ( hx.1 v ) ( hy.2 v )

/-
**Rounding bound**: Given a fractional transversal `x` and a bound `d` on edge sizes,
    the threshold set `{v | x(v) ≥ 1/d}` is a transversal.
-/
theorem threshold_isTransversal (H : Hypergraph V) (x : V → ℝ) (d : ℕ)
    (hx : IsFracTransversal H x)
    (hd : ∀ e ∈ H.edges, e.card ≤ d)
    (hd_pos : 0 < d)
    (he_ne : ∀ e ∈ H.edges, e.Nonempty) :
    IsTransversal H (Finset.univ.filter (fun v => (1 : ℝ) / d ≤ x v)) := by
  intro e he
  obtain ⟨v, hv⟩ : ∃ v ∈ e, x v ≥ 1 / d := by
    by_contra h_contra
    push_neg at h_contra
    have h_sum_lt_one : ∑ v ∈ e, x v < 1 := by
      refine' lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ( he_ne e he ) h_contra ) _ ; simp +decide [ hd_pos.ne', hd e he ];
      exact div_le_one_of_le₀ ( mod_cast hd e he ) ( Nat.cast_nonneg _ )
    generalize_proofs at *; (
    exact h_sum_lt_one.not_ge ( hx.2 e he ))
  exact ⟨v, by
    grind⟩

/-
**Rounding size bound**: The threshold set has cardinality at most `d * ∑ x(v)`.
-/
omit [DecidableEq V] in
theorem threshold_card_bound (x : V → ℝ) (d : ℕ)
    (hx_nn : ∀ v, 0 ≤ x v) (hd_pos : 0 < d) :
    ((Finset.univ.filter (fun v => (1 : ℝ) / d ≤ x v)).card : ℝ) ≤
      d * fracTransversalValue x := by
  -- Since every vertex in $S$ has $x(v) \ge 1/d$, and $d > 0$, we have $1 \le d \cdot x(v)$. Summing over $S$ gives:
  have h_sum_bound : ∑ v ∈ Finset.univ.filter (fun v => (1 : ℝ) / d ≤ x v), 1 ≤ d * ∑ v ∈ Finset.univ.filter (fun v => (1 : ℝ) / d ≤ x v), x v := by
    rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun i hi => by rw [ Finset.mem_filter ] at hi; nlinarith [ one_div_mul_cancel ( by positivity : ( d : ℝ ) ≠ 0 ), ( by norm_cast : ( 1 :ℝ ) ≤ d ) ] ;
  exact le_trans ( by simpa ) ( h_sum_bound.trans ( mul_le_mul_of_nonneg_left ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.filter_subset _ _ ) fun _ _ _ => hx_nn _ ) ( Nat.cast_nonneg _ ) ) )

/-- **Integrality gap bound (combined)**: For any fractional transversal of value `c`
    with edge sizes bounded by `d`, there exists an integer transversal of size ≤ `d * c`.
    This gives τ ≤ d_max · τ*. -/
theorem integrality_gap_upper (H : Hypergraph V) (x : V → ℝ) (d : ℕ)
    (hx : IsFracTransversal H x) (hd : ∀ e ∈ H.edges, e.card ≤ d)
    (hd_pos : 0 < d) (he_ne : ∀ e ∈ H.edges, e.Nonempty) :
    ∃ S : Finset V, IsTransversal H S ∧
      (S.card : ℝ) ≤ d * fracTransversalValue x := by
  exact ⟨_, threshold_isTransversal H x d hx hd hd_pos he_ne,
    threshold_card_bound x d hx.1 hd_pos⟩

/-- The edge-size heterogeneity of a hypergraph, measured as the
    variance of edge cardinalities. Zero iff uniform. -/
noncomputable def edgeHeterogeneity (H : Hypergraph V) : ℝ :=
  if _h : H.edges.card = 0 then 0
  else
    let d_bar := (∑ e ∈ H.edges, (e.card : ℝ)) / H.edges.card
    (∑ e ∈ H.edges, ((e.card : ℝ) - d_bar)^2) / H.edges.card

/-- A hypergraph is k-uniform if all edges have exactly k elements. -/
def IsUniform (H : Hypergraph V) (k : ℕ) : Prop :=
  ∀ e ∈ H.edges, e.card = k

/-- **Uniform integrality gap**: For k-uniform hypergraphs, any fractional transversal
    of value `c` can be rounded to an integer transversal of size ≤ `k * c`. -/
theorem uniform_integrality_gap (H : Hypergraph V) (x : V → ℝ) (k : ℕ)
    (hx : IsFracTransversal H x) (hk : IsUniform H k)
    (hk_pos : 0 < k) (he_ne : ∀ e ∈ H.edges, e.Nonempty) :
    ∃ S : Finset V, IsTransversal H S ∧
      (S.card : ℝ) ≤ k * fracTransversalValue x := by
  exact integrality_gap_upper H x k hx (fun e he => le_of_eq (hk e he)) hk_pos he_ne

/-- A heterogeneous hypergraph has at least two distinct edge sizes. -/
def IsHeterogeneous (H : Hypergraph V) : Prop :=
  ∃ e₁ ∈ H.edges, ∃ e₂ ∈ H.edges, e₁.card ≠ e₂.card

/-
For a uniform hypergraph, the edge heterogeneity is zero.
-/
omit [Fintype V] [DecidableEq V] in
theorem heterogeneity_zero_of_uniform (H : Hypergraph V) (k : ℕ)
    (hk : IsUniform H k) : edgeHeterogeneity H = 0 := by
  rw [ edgeHeterogeneity ];
  split_ifs <;> simp_all +decide [ IsUniform ]

end Hypergraph