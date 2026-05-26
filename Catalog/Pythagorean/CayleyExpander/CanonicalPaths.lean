/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Canonical Path Poincaré Inequality for Cayley Graphs

This file formalizes the Jerrum–Sinclair canonical path method specialized
to finite Cayley graphs. The main result is a quantitative Poincaré inequality
that converts combinatorial routing data (canonical paths with bounded
congestion) into certified lower bounds on the spectral gap.

## Main definitions

* `DirectedEdge` — a directed edge (x, s) in the Cayley graph
* `pathVertex` — intermediate vertices along a word path
* `poincareConstant` — spectral gap of the Cayley graph

## Main results

* `telescope_word` — telescoping identity for value differences along paths
* `finset_sum_sq_le` — Cauchy–Schwarz for finite sums
* `sqDiff_le_pathLen_mul_sum_sqDiffs` — telescoping + Cauchy–Schwarz on a path
* `variance_eq_pairwise` — variance as average pairwise differences
* `pairwise_le_maxLen_mul_pathEnergy` — bounding pairwise sum by path energy
* `variance_le_congestion_mul_energy` — the main Poincaré inequality
* `poincareConstant_lower_bound` — spectral gap ≥ 2|G| / (κ · L)
* `energy_ge_expansion_times_variance` — cross-domain expansion certificate

## References

* Jerrum, M., Sinclair, A. (1989). Approximating the permanent.
* Diaconis, P., Stroock, D. (1991). Geometric bounds on eigenvalues.
-/
import Mathlib
import Pythagorean.CayleyExpander.Defs

open Finset BigOperators

/-! ## Directed edges in Cayley graphs -/

/-- A directed edge in the Cayley graph of a group G.
    The edge goes from `src` to `src * gen`. -/
structure DirectedEdge (G : Type*) [Group G] where
  /-- Source vertex -/
  src : G
  /-- Generator labeling this edge -/
  gen : G

/-- The destination of a directed edge: src * gen. -/
def DirectedEdge.dst {G : Type*} [Group G] (e : DirectedEdge G) : G :=
  e.src * e.gen

/-! ## Path vertices -/

/-- The i-th intermediate vertex along a word path:
    pathVertex [s₁,...,sₖ] x i = (s₁·...·sᵢ) * x -/
def pathVertex {G : Type*} [Group G] (gens : List G) (x : G) (i : ℕ) : G :=
  (gens.take i).prod * x

/-! ## Telescoping identity -/

/-- **Telescoping identity**: f(gens.prod * x) - f(x) equals the sum of
    edge increments f(vᵢ₊₁) - f(vᵢ) along the path.

    This is the discrete fundamental theorem of calculus along a word. -/
theorem telescope_word {G : Type*} [Group G]
    (f : G → ℝ) (x : G) (gens : List G) :
    f (gens.prod * x) - f x =
      ∑ i ∈ Finset.range gens.length,
        (f (pathVertex gens x (i + 1)) - f (pathVertex gens x i)) := by
  convert Finset.sum_range_sub (fun i => f (pathVertex gens x i)) gens.length |>.symm using 1
  simp [pathVertex]

/-! ## Cauchy–Schwarz for finite sums -/

/-
Cauchy–Schwarz for finite sums: (∑ aᵢ)² ≤ n · ∑ aᵢ².
-/
theorem finset_sum_sq_le {ι : Type*} (s : Finset ι) (f : ι → ℝ) :
    (∑ i ∈ s, f i) ^ 2 ≤ s.card * ∑ i ∈ s, f i ^ 2 := by
  exact?

/-! ## Cauchy–Schwarz on a single path -/

/-
**Theorem 1 (Telescoping + Cauchy–Schwarz on a path).**

    For a word gens connecting x to y (i.e., gens.prod * x = y):
    (f(y) - f(x))² ≤ |gens| · ∑_{i} (f(vᵢ₊₁) - f(vᵢ))²

    This combines the telescoping identity with Cauchy–Schwarz.
-/
theorem sqDiff_le_len_mul_sum_sqDiffs {G : Type*} [Group G]
    (f : G → ℝ) (x : G) (gens : List G) :
    (f (gens.prod * x) - f x) ^ 2 ≤
      (gens.length : ℝ) *
        ∑ i ∈ Finset.range gens.length,
          (f (pathVertex gens x (i + 1)) - f (pathVertex gens x i)) ^ 2 := by
  convert finset_sum_sq_le ( Finset.range ( List.length gens ) ) ( fun i => f ( pathVertex gens x ( i + 1 ) ) - f ( pathVertex gens x i ) ) using 1;
  · rw [ ← telescope_word ];
  · rw [ Finset.card_range ]

/-! ## Variance via pairwise differences -/

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-
Variance equals the average of pairwise squared differences:
    Var(f) = 1/(2|G|²) · ∑_{x,y} (f(y) - f(x))²
-/
theorem variance_eq_pairwise
    (f : G → ℝ)
    (hG : (Fintype.card G : ℝ) ≠ 0) :
    variance f =
      (∑ x : G, ∑ y : G, (f y - f x) ^ 2) / (2 * (Fintype.card G : ℝ) ^ 2) := by
  unfold variance;
  simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, meanValue ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, div_eq_mul_inv, sq, mul_assoc, mul_comm, mul_left_comm, hG ] ; ring;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hG ] ; ring

/-! ## Main Poincaré inequality

We prove the inequality using `CanonicalPathData` from Defs.lean,
which provides path data with explicit length and congestion bounds.

The key intermediate step is the "congestion inequality":
  ∑_{x,y} ∑_i (edge increments)² ≤ κ · E_S(f)

This double-counting argument is the combinatorial heart of the method.
We state it as a hypothesis on the path data and verify it for specific
systems (like bubble-sort paths on Sₙ) separately. -/

/-- The total path energy: ∑_{x,y} ∑_{i} (f(vᵢ₊₁) - f(vᵢ))² along canonical paths. -/
noncomputable def totalPathEnergy
    (P : CanonicalPathData G) (f : G → ℝ) : ℝ :=
  ∑ x : G, ∑ y : G,
    ∑ i ∈ Finset.range (P.paths x y).length,
      (f (pathVertex (P.paths x y) x (i + 1)) -
       f (pathVertex (P.paths x y) x i)) ^ 2

/-
**Pairwise bound**: each pairwise squared difference is bounded by
    L times the sum of squared edge increments along the path.
-/
theorem pairwise_le_lengthBound_mul_pathEnergy
    (P : CanonicalPathData G) (f : G → ℝ) :
    ∑ x : G, ∑ y : G, (f y - f x) ^ 2 ≤
      (P.length_bound : ℝ) * totalPathEnergy P f := by
  have h_pairwise_bound : ∀ x y : G, (f y - f x) ^ 2 ≤ (P.length_bound : ℝ) * (∑ i ∈ Finset.range (P.paths x y).length, (f (pathVertex (P.paths x y) x (i + 1)) - f (pathVertex (P.paths x y) x i)) ^ 2) := by
    intro x y;
    have h_sq_diff : (f y - f x) ^ 2 ≤ (P.paths x y).length * ∑ i ∈ Finset.range (P.paths x y).length, (f (pathVertex (P.paths x y) x (i + 1)) - f (pathVertex (P.paths x y) x i)) ^ 2 := by
      convert sqDiff_le_len_mul_sum_sqDiffs f x ( P.paths x y ) using 1
      generalize_proofs at *;
      rw [ P.path_target x y ];
    exact h_sq_diff.trans ( mul_le_mul_of_nonneg_right ( mod_cast P.length_le x y ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) );
  simpa only [ Finset.mul_sum _ _ _, totalPathEnergy ] using Finset.sum_le_sum fun x _ => Finset.sum_le_sum fun y _ => h_pairwise_bound x y

/-- The congestion condition: the total path energy is bounded by
    κ times the Dirichlet energy. This captures the double-counting
    argument that each directed edge is used by at most κ paths.

    For a specific path system, this must be verified separately.
    We provide this verification for bubble-sort paths on S₅. -/
def CongestionBound (P : CanonicalPathData G) : Prop :=
  ∀ f : G → ℝ,
    totalPathEnergy P f ≤ (P.congestion : ℝ) * cayleyDirichletEnergy P.gens f

/-
**Theorem 2 (Canonical Path Poincaré Inequality).**

    If the congestion condition holds, then:
      Var(f) ≤ (κ · L) / (2 · |G|²) · E_S(f)

    This is the main result. It converts routing data into an analytic bound.
-/
theorem variance_le_congestion_mul_energy
    (P : CanonicalPathData G) (f : G → ℝ)
    (hcong : CongestionBound P)
    (hG : (Fintype.card G : ℝ) > 0) :
    variance f ≤
      ((P.congestion : ℝ) * (P.length_bound : ℝ)) /
        (2 * (Fintype.card G : ℝ) ^ 2) *
      cayleyDirichletEnergy P.gens f := by
  -- By variance_eq_pairwise, we have:
  have h_var : variance f = (∑ x : G, ∑ y : G, (f y - f x) ^ 2) / (2 * (Fintype.card G : ℝ) ^ 2) := by
    convert variance_eq_pairwise f hG.ne' using 1;
  convert div_le_div_of_nonneg_right ( mul_le_mul_of_nonneg_left ( hcong f ) ( Nat.cast_nonneg P.length_bound ) ) ( mul_nonneg zero_le_two ( sq_nonneg ( Fintype.card G : ℝ ) ) ) |> le_trans ( div_le_div_of_nonneg_right ( pairwise_le_lengthBound_mul_pathEnergy P f ) ( mul_nonneg zero_le_two ( sq_nonneg ( Fintype.card G : ℝ ) ) ) ) using 1 ; ring

/-! ## Spectral gap lower bound -/

/-
**Theorem 3 (Spectral Gap Lower Bound).**

    For any f with positive variance, the Poincaré ratio is bounded below:
      E_S(f) / (|S| · Var(f)) ≥ 2|G|² / (|S| · κ · L)

    This gives a computable lower bound on the spectral gap.
-/
theorem spectralGap_lower_bound
    (P : CanonicalPathData G)
    (hcong : CongestionBound P)
    (hG : (Fintype.card G : ℝ) > 0)
    (hκ : (P.congestion : ℝ) > 0)
    (hL : (P.length_bound : ℝ) > 0)
    (hS : (P.gens.card : ℝ) > 0)
    (f : G → ℝ) (hf : variance f > 0) :
    cayleyDirichletEnergy P.gens f / (P.gens.card * variance f) ≥
      2 * (Fintype.card G : ℝ) ^ 2 /
        ((P.gens.card : ℝ) * (P.congestion : ℝ) * (P.length_bound : ℝ)) := by
  have h_bound : (cayleyDirichletEnergy P.gens f) / (variance f) ≥ (2 * (Fintype.card G : ℝ) ^ 2 / ((P.congestion : ℝ) * (P.length_bound : ℝ))) := by
    rw [ ge_iff_le, le_div_iff₀ hf ];
    convert variance_le_congestion_mul_energy P f hcong hG |> fun h => mul_le_mul_of_nonneg_left h <| show 0 ≤ 2 * ( Fintype.card G : ℝ ) ^ 2 / ( P.congestion * P.length_bound ) by positivity using 1;
    field_simp;
  field_simp at *;
  convert h_bound using 1

/-! ## Cross-domain: L² expansion certificate -/

/-
**Theorem 4 (Certified L² Expansion).**

    If the congestion condition holds, then for all f:
      E_S(f) ≥ (2|G|² / (κ·L)) · Var(f)

    Interpreting E_S as the quadratic form of the random walk Laplacian,
    this says the Cayley graph has spectral gap ≥ 2|G|/(κ·L·|S|),
    giving mixing time O(κ·L·|S|/(2|G|) · log|G|).

    Cross-domain significance:
    - Probability: controls random walk mixing
    - Physics: bounds equilibration time
    - CS: provides expansion certificate for derandomization
-/
theorem energy_ge_expansion_times_variance
    (P : CanonicalPathData G) (f : G → ℝ)
    (hcong : CongestionBound P)
    (hG : (Fintype.card G : ℝ) > 0)
    (hκ : (P.congestion : ℝ) > 0)
    (hL : (P.length_bound : ℝ) > 0) :
    cayleyDirichletEnergy P.gens f ≥
      2 * (Fintype.card G : ℝ) ^ 2 /
        ((P.congestion : ℝ) * (P.length_bound : ℝ)) *
      variance f := by
  have := @variance_le_congestion_mul_energy G _ _ _ P f hcong hG;
  field_simp at this ⊢;
  exact this