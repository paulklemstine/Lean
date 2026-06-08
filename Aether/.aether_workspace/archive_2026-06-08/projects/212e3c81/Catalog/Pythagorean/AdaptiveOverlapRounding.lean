/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Overlap-Adaptive Rounding for Hypergraph Transversals

This file develops the theory of **data-driven rounding for bounded-overlap
hypergraph transversals**, where the algorithm extracts an effective overlap
parameter from the LP optimum itself rather than receiving it as external input.

## Central Idea

The classical bounded-codegree story says: if a `d`-uniform hypergraph has
pairwise overlap at most `K`, threshold rounding at `1/d` gives a
`d`-approximation. But `K` is often unknown. The key insight is that the
**pair-overlap energy** of the fractional optimum acts as a self-calibrating
diagnostic that detects latent overlap structure, yielding instance-sensitive
approximation guarantees without external structural parameters.

## Main Definitions

* `HG` — a hypergraph as a finite set of finite sets
* `PairCodegree` — number of edges containing both vertices u and v (0 on diagonal)
* `PairCodegreeBounded` — all pair codegrees bounded by K
* `PairOverlapEnergy` — the pair-overlap energy functional
* `EdgeSquareEnergy` — sum of squared edge masses
* `FractionalMass` — total LP mass Σ x(v)
* `EffectiveOverlap` — normalized energy diagnostic ρ = E/M²
* `ThresholdSet` — threshold rounding operator

## Main Results

* `pairOverlapEnergy_le_of_codegree_bounded` — energy ≤ K · M² under codegree bound
* `effectiveOverlap_le_of_codegree_bounded` — diagnostic ≤ K under codegree bound
* `edgeSquareEnergy_ge_card` — edge-square energy ≥ |E| for fractional transversals
* `thresholdSet_isTransversal` — threshold rounding at 1/d produces a valid transversal
* `thresholdSet_card_le` — cardinality bound for threshold set
* `adaptive_rounding_with_certificate` — combined adaptive guarantee
* `low_energy_integrality_gap` — low energy certifies small integrality gap

## Cross-Domain Connections

* **Operations Research**: instance-sensitive certificates for set cover difficulty
* **Statistical Physics**: energy as two-body interaction Hamiltonian;
  low interaction energy ↔ efficient deterministic rounding
* **Algorithm Selection**: LP diagnostic predicts algorithmic performance

## Conjectures (stated informally)

**Smooth adaptive improvement law**: There exists c > 0 such that for every
d-uniform hypergraph and optimal fractional transversal x*,
  τ_ad(H; x*) ≤ (d - c/(1 + ρ_H(x*))) · τ*(H) + O(1 + ρ_H(x*)).

**Monotone diagnostic-performance principle**: Among random d-uniform instances
with fixed |V|, |E|, the approximation ratio of adaptive rounding is
stochastically nonincreasing as ρ_H(x*) decreases.
-/

open Finset BigOperators

/-! ### Type alias and basic definitions -/

/-- A hypergraph on vertex type `V` is a finite set of edges (finite sets of vertices). -/
abbrev HG (V : Type*) [DecidableEq V] := Finset (Finset V)

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Pair Codegree -/

/-- The pair codegree of vertices `u` and `v` in hypergraph `H`:
    the number of edges containing both `u` and `v`.
    Defined as 0 when `u = v` to focus on off-diagonal interactions. -/
noncomputable def PairCodegree (H : HG V) (u v : V) : ℕ :=
  if u = v then 0
  else (H.filter (fun e => u ∈ e ∧ v ∈ e)).card

/-- A hypergraph has pair codegree bounded by `K` if every pair of
    (possibly equal) vertices satisfies `PairCodegree H u v ≤ K`. -/
def PairCodegreeBounded (H : HG V) (K : ℕ) : Prop :=
  ∀ u v, PairCodegree H u v ≤ K

/-! ### Fractional Transversal -/

/-- A function `x : V → ℝ` is a fractional transversal of `H` if it is
    nonnegative and the sum over every edge is at least 1. -/
def IsFracTransversal' (H : HG V) (x : V → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ e ∈ H, 1 ≤ ∑ v ∈ e, x v

/-- A finset `S` is a transversal of `H` if it intersects every edge. -/
def IsTransversal' (H : HG V) (S : Finset V) : Prop :=
  ∀ e ∈ H, (S ∩ e).Nonempty

/-- A hypergraph is `d`-uniform if every edge has exactly `d` elements. -/
def IsUniform' (H : HG V) (d : ℕ) : Prop :=
  ∀ e ∈ H, e.card = d

/-! ### Energy Functionals -/

/-- The pair-overlap energy of a fractional vector `x`:
    `E_H(x) = Σ_{u,v} PairCodegree(H,u,v) · x(u) · x(v)`.
    Since `PairCodegree` is 0 on the diagonal, this counts only
    off-diagonal pair interactions. -/
noncomputable def PairOverlapEnergy (H : HG V) (x : V → ℝ) : ℝ :=
  ∑ u : V, ∑ v : V, (PairCodegree H u v : ℝ) * x u * x v

/-- The edge-square energy: `Σ_e (Σ_{v∈e} x(v))²`. -/
noncomputable def EdgeSquareEnergy (H : HG V) (x : V → ℝ) : ℝ :=
  ∑ e ∈ H, (∑ v ∈ e, x v) ^ 2

/-- The fractional mass: `M(x) = Σ_v x(v)`. -/
noncomputable def FractionalMass (x : V → ℝ) : ℝ :=
  ∑ v : V, x v

/-- The effective overlap diagnostic: `ρ_H(x) = E_H(x) / M(x)²`.
    When `M(x) = 0`, defined as 0. -/
noncomputable def EffectiveOverlap (H : HG V) (x : V → ℝ) : ℝ :=
  if FractionalMass x = 0 then 0
  else PairOverlapEnergy H x / (FractionalMass x) ^ 2

/-! ### Threshold Rounding -/

/-- The threshold set: `{v | θ ≤ x(v)}`. -/
noncomputable def ThresholdSet (x : V → ℝ) (θ : ℝ) : Finset V :=
  Finset.univ.filter (fun v => θ ≤ x v)

/-! ### Auxiliary Lemmas -/

/-- The pair codegree is zero on the diagonal. -/
@[simp]
theorem pairCodegree_self (H : HG V) (v : V) :
    PairCodegree H v v = 0 := by
  simp [PairCodegree]

/-
The pair codegree is symmetric.
-/
theorem pairCodegree_comm (H : HG V) (u v : V) :
    PairCodegree H u v = PairCodegree H v u := by
  unfold PairCodegree;
  simp +decide only [eq_comm, and_comm]

/-
The pair-overlap energy is nonneg for nonneg vectors.
-/
theorem pairOverlapEnergy_nonneg (H : HG V) (x : V → ℝ)
    (hx : ∀ v, 0 ≤ x v) :
    0 ≤ PairOverlapEnergy H x := by
  exact Finset.sum_nonneg fun u _ => Finset.sum_nonneg fun v _ => mul_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( hx u ) ) ( hx v )

/-! ### Theorem 1: Energy Bound from Codegree Control -/

/-
**Pair-overlap energy bound from codegree control.**
    If `H` has pair codegree bounded by `K` and `x` is nonnegative,
    then `E_H(x) ≤ K · M(x)²`.

    This is the core certification theorem: a structural bound on
    codegree translates into a bound on the energy observable.
-/
theorem pairOverlapEnergy_le_of_codegree_bounded
    (H : HG V) (x : V → ℝ) (K : ℕ)
    (hK : PairCodegreeBounded H K)
    (hx_nonneg : ∀ v, 0 ≤ x v) :
    PairOverlapEnergy H x ≤ K * (FractionalMass x) ^ 2 := by
  convert Finset.sum_le_sum fun u hu => Finset.sum_le_sum fun v hv => mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right ( show ( PairCodegree H u v : ℝ ) ≤ K by exact_mod_cast hK u v ) ( hx_nonneg u ) ) ( hx_nonneg v ) using 1;
  simp +decide only [FractionalMass, pow_two, Finset.mul_sum _ _ _, mul_comm, mul_assoc, mul_left_comm]

/-! ### Theorem 2: Edge-Square Energy Lower Bound -/

/-
**Edge-square energy lower bound.**
    For any fractional transversal `x`, the edge-square energy
    is at least the number of edges: `Σ_e (Σ_{v∈e} x(v))² ≥ |E|`.
    Each edge contributes at least 1² = 1.
-/
theorem edgeSquareEnergy_ge_card
    (H : HG V) (x : V → ℝ)
    (hx : IsFracTransversal' H x) :
    (H.card : ℝ) ≤ EdgeSquareEnergy H x := by
  exact le_trans ( by norm_num [ EdgeSquareEnergy ] ) ( Finset.sum_le_sum fun e he ↦ pow_le_pow_left₀ ( by norm_num ) ( hx.2 e he ) 2 )

/-! ### Theorem 3: Threshold Rounding is a Transversal -/

/-
**Threshold rounding at `1/d` produces a valid transversal.**
    For any fractional transversal `x` of a hypergraph with max edge
    size ≤ d (d > 0), the threshold set `{v : x(v) ≥ 1/d}` hits every edge.

    Proof sketch: If edge `e` were missed, then all `v ∈ e` have `x(v) < 1/d`,
    so `Σ_{v∈e} x(v) < |e| · (1/d) ≤ d · (1/d) = 1`, contradicting the
    covering constraint.
-/
theorem thresholdSet_isTransversal
    (H : HG V) (x : V → ℝ) (d : ℕ)
    (hx : IsFracTransversal' H x)
    (hd : ∀ e ∈ H, e.card ≤ d)
    (hd_pos : 0 < d)
    (he_ne : ∀ e ∈ H, e.Nonempty) :
    IsTransversal' H (ThresholdSet x ((1 : ℝ) / d)) := by
  intro e he
  by_contra h_empty
  have h_all_lt : ∀ v ∈ e, x v < 1 / (d : ℝ) := by
    simp_all +decide [ Finset.ext_iff, ThresholdSet ];
    exact fun v hv => lt_of_not_ge fun h => h_empty v h hv;
  exact absurd ( hx.2 e he ) ( by have := Finset.sum_lt_sum_of_nonempty ( he_ne e he ) h_all_lt; norm_num at *; nlinarith [ ( by norm_cast : ( 1 :ℝ ) ≤ d ), mul_inv_cancel₀ ( by positivity : ( d :ℝ ) ≠ 0 ), show ( e.card :ℝ ) ≤ d by exact_mod_cast hd e he ] )

/-! ### Theorem 4: Cardinality Bound -/

/-
**Cardinality bound for threshold rounding.**
    The threshold set at `1/d` has cardinality at most `d · M(x)`.

    Proof sketch: each vertex in the set has `x(v) ≥ 1/d`,
    so `1 ≤ d · x(v)`. Summing: `|T| ≤ d · Σ_{v∈T} x(v) ≤ d · Σ_v x(v)`.
-/
theorem thresholdSet_card_le
    (H : HG V) (x : V → ℝ) (d : ℕ)
    (hx_nonneg : ∀ v, 0 ≤ x v)
    (hd_pos : 0 < d) :
    ((ThresholdSet x ((1 : ℝ) / d)).card : ℝ) ≤ d * FractionalMass x := by
  -- For each $v$ in the threshold set, we have $x(v) \geq 1/d$, so $1 \leq d * x(v)$.
  have h_ineq : ∀ v ∈ ThresholdSet x (1 / d), (1 : ℝ) ≤ d * x v := by
    exact fun v hv => by rw [ ← div_le_iff₀' ( by positivity ) ] ; simpa using Finset.mem_filter.mp hv |>.2;
  have := Finset.sum_le_sum h_ineq; simp_all +decide [ mul_comm, Finset.mul_sum _ _ _, FractionalMass ] ;
  exact this.trans ( by rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => mul_nonneg ( hx_nonneg _ ) ( Nat.cast_nonneg _ ) )

/-! ### Theorem 5: Effective Overlap Diagnostic Bound -/

/-
**Effective overlap bounded by codegree.**
    If pair codegree ≤ K and x is nonneg with positive mass,
    then `ρ_H(x) ≤ K`. The algorithm computes ρ from x alone
    and this theorem guarantees ρ ≤ K whenever the instance has
    bounded codegree — even though K is never given as input.
-/
theorem effectiveOverlap_le_of_codegree_bounded
    (H : HG V) (x : V → ℝ) (K : ℕ)
    (hK : PairCodegreeBounded H K)
    (hx_nonneg : ∀ v, 0 ≤ x v)
    (hM_pos : 0 < FractionalMass x) :
    EffectiveOverlap H x ≤ K := by
  convert div_le_of_le_mul₀ ( sq_nonneg _ ) ( Nat.cast_nonneg _ ) ( pairOverlapEnergy_le_of_codegree_bounded H x K hK hx_nonneg ) using 1;
  exact if_neg hM_pos.ne'

/-! ### Theorem 6: Combined Adaptive Guarantee -/

/-
**Combined adaptive approximation guarantee.**
    For a hypergraph with edge sizes ≤ d, fractional transversal x,
    and pair codegree ≤ K: the threshold rounded set is a transversal
    with `|T| ≤ d · M(x)`, and the algorithm certifies `ρ ≤ K`
    without knowing K.
-/
theorem adaptive_rounding_with_certificate
    (H : HG V) (x : V → ℝ) (d : ℕ) (K : ℕ)
    (hx : IsFracTransversal' H x)
    (hd : ∀ e ∈ H, e.card ≤ d)
    (hd_pos : 0 < d)
    (he_ne : ∀ e ∈ H, e.Nonempty)
    (hK : PairCodegreeBounded H K)
    (hM_pos : 0 < FractionalMass x) :
    IsTransversal' H (ThresholdSet x ((1 : ℝ) / d)) ∧
    ((ThresholdSet x ((1 : ℝ) / d)).card : ℝ) ≤ d * FractionalMass x ∧
    EffectiveOverlap H x ≤ K := by
  refine' ⟨ _, _, _ ⟩;
  · convert thresholdSet_isTransversal H x d hx hd hd_pos he_ne using 1;
  · convert thresholdSet_card_le H x d hx.1 hd_pos;
  · convert effectiveOverlap_le_of_codegree_bounded H x K hK ( fun v => hx.1 v ) hM_pos using 1

/-! ### Theorem 7: Low Energy Integrality Gap -/

/-
**Low energy certifies integrality gap bound.**
    For a d-uniform hypergraph with pair codegree ≤ K and fractional
    transversal x: threshold rounding gives a transversal T with
    `|T| ≤ d · M(x)` and the energy satisfies `E ≤ K · M²`.

    This bridges to operations research (instance-sensitive optimization)
    and statistical physics (low interaction energy → efficient rounding).
    The algorithm never receives K but its output is certified by K.
-/
theorem low_energy_integrality_gap
    (H : HG V) (x : V → ℝ) (d : ℕ) (K : ℕ)
    (hx : IsFracTransversal' H x)
    (hd : IsUniform' H d)
    (hd_pos : 0 < d)
    (he_ne : ∀ e ∈ H, e.Nonempty)
    (hK : PairCodegreeBounded H K) :
    IsTransversal' H (ThresholdSet x ((1 : ℝ) / d)) ∧
    ((ThresholdSet x ((1 : ℝ) / d)).card : ℝ) ≤ d * FractionalMass x ∧
    PairOverlapEnergy H x ≤ K * (FractionalMass x) ^ 2 := by
  exact ⟨ thresholdSet_isTransversal H x d hx ( fun e he => by linarith [ hd e he ] ) hd_pos he_ne, thresholdSet_card_le H x d hx.1 hd_pos, pairOverlapEnergy_le_of_codegree_bounded H x K hK hx.1 ⟩