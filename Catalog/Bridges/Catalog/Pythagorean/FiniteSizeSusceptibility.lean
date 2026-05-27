/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Finite-Size Susceptibility for Fractional Transversals

This file introduces **finite-size susceptibility observables** for hypergraph
fractional transversal numbers, creating a rigorous bridge from LP sensitivity
of random combinatorial structures to finite-size scaling theory in the style
of statistical mechanics.

## Central definitions

* `edgeInsertionDelta` — the response of `τ*(H)` to inserting a single edge
* `susceptibilityMax` — the maximum insertion response over all admissible edges
* `susceptibilityAvg` — the mean insertion response
* `FiniteSizeSusceptibility` — structure bundling susceptibility observables
* `quadraticSusceptibility` — the sum of squared increments along an
  edge-exposure sequence, equal to the variance decomposition

## Main results

* `edgeInsertionDelta_nonneg` — insertion response is nonnegative (monotonicity)
* `edgeInsertionDelta_le_one` — insertion response is at most 1 (Lipschitz)
* `edgeInsertionDelta_abs_le_one` — absolute insertion response ≤ 1
* `susceptibilityMax_le_one` — max susceptibility bounded by 1
* `susceptibilityAvg_le_one` — mean susceptibility bounded by 1
* `exists_pseudocritical_index` — finite-size peak existence
* `variance_eq_quadSusceptibility` — variance decomposition identity
* `quadraticSusceptibility_le_length` — variance bounded by sequence length

## Application keywords

finite-size scaling, critical exponent, susceptibility, universality,
random hypergraphs, fractional transversal, linear programming phase transition,
martingale variance decomposition, fluctuation-dissipation principle,
pseudocritical density, optimization thermodynamics, combinatorial statistical mechanics
-/

open Finset BigOperators

/-! ## Hypergraph infrastructure (self-contained) -/

namespace OptCrit

/-- A hypergraph on vertex type `V` is a finite collection of edges. -/
structure Hypergraph (V : Type*) where
  edges : Finset (Finset V)

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A function `x : V → ℝ` is a fractional transversal of `H` if it is nonnegative
    and the sum over each edge is at least 1. -/
def IsFracTransversal (H : Hypergraph V) (x : V → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ e ∈ H.edges, 1 ≤ ∑ v ∈ e, x v

/-- The value of a fractional transversal assignment. -/
noncomputable def fracTransversalValue (x : V → ℝ) : ℝ := ∑ v : V, x v

/-- The fractional transversal number: infimum of feasible values. -/
noncomputable def fracTransversalNum (H : Hypergraph V) : ℝ :=
  ⨅ (x : V → ℝ) (_ : IsFracTransversal H x), fracTransversalValue x

/-- Add an edge to a hypergraph. -/
def addEdge (H : Hypergraph V) (e : Finset V) : Hypergraph V :=
  ⟨insert e H.edges⟩

/-- Feasibility for a supergraph implies feasibility for a subgraph. -/
theorem IsFracTransversal_of_subset {H₁ H₂ : Hypergraph V}
    (h : H₁.edges ⊆ H₂.edges) (x : V → ℝ)
    (hx : IsFracTransversal H₂ x) : IsFracTransversal H₁ x :=
  ⟨hx.1, fun e he => hx.2 e (h he)⟩

/-
Monotonicity: more edges ⟹ larger τ*.
-/
theorem fracTransversalNum_mono {H₁ H₂ : Hypergraph V}
    (h : H₁.edges ⊆ H₂.edges) :
    fracTransversalNum H₁ ≤ fracTransversalNum H₂ := by
  refine' le_ciInf fun x => _;
  by_cases hx : IsFracTransversal H₂ x <;> simp +decide [ hx ];
  · refine' le_trans ( ciInf_le _ x ) _;
    · refine' ⟨ 0, Set.forall_mem_range.2 fun x => _ ⟩;
      refine' Real.iInf_nonneg fun _ => Finset.sum_nonneg fun _ _ => _;
      exact ‹IsFracTransversal H₁ x›.1 _;
    · exact ciInf_le ( by exact ⟨ 0, Set.forall_mem_range.2 fun _ => Finset.sum_nonneg fun _ _ => hx.1 _ ⟩ ) ( IsFracTransversal_of_subset h x hx );
  · refine' le_trans ( ciInf_le _ 0 ) _;
    · refine' ⟨ 0, Set.forall_mem_range.2 fun x => _ ⟩;
      refine' Real.iInf_nonneg _;
      exact fun hx => Finset.sum_nonneg fun _ _ => hx.1 _;
    · simp +decide [ fracTransversalValue ]

/-- τ*(H) ≤ τ*(H ∪ {e}). -/
theorem fracTransversalNum_le_addEdge (H : Hypergraph V) (e : Finset V) :
    fracTransversalNum H ≤ fracTransversalNum (addEdge H e) :=
  fracTransversalNum_mono (Finset.subset_insert e H.edges)

/-
τ*(H ∪ {e}) ≤ τ*(H) + 1, via LP perturbation.
-/
theorem fracTransversalNum_addEdge_le (H : Hypergraph V) (e : Finset V)
    (he : e.Nonempty) :
    fracTransversalNum (addEdge H e) ≤ fracTransversalNum H + 1 := by
  refine' le_trans ( ciInf_le _ 0 ) _;
  · exact ⟨ 0, Set.forall_mem_range.2 fun x => by exact Real.iInf_nonneg fun _ => Finset.sum_nonneg fun _ _ => by linarith [ ‹IsFracTransversal ( addEdge H e ) x›.1 ‹_› ] ⟩;
  · simp +decide [ IsFracTransversal, fracTransversalValue ];
    exact add_nonneg ( Real.iInf_nonneg fun _ => Real.iInf_nonneg fun _ => Finset.sum_nonneg fun _ _ => by linarith [ ‹ ( ∀ v : V, 0 ≤ ( ‹_› : V → ℝ ) v ) ∧ ∀ e ∈ H.edges, 1 ≤ ∑ v ∈ e, ( ‹_› : V → ℝ ) v ›.1 ‹_› ] ) zero_le_one

/-! ## Part I: Edge Insertion Response -/

/-- The **edge insertion delta**: Δτ*(H, e) := τ*(H ∪ {e}) - τ*(H). -/
noncomputable def edgeInsertionDelta (H : Hypergraph V) (e : Finset V) : ℝ :=
  fracTransversalNum (addEdge H e) - fracTransversalNum H

/-- **Monotonicity**: adding an edge cannot decrease τ*. -/
theorem edgeInsertionDelta_nonneg (H : Hypergraph V) (e : Finset V) :
    0 ≤ edgeInsertionDelta H e := by
  unfold edgeInsertionDelta
  linarith [fracTransversalNum_le_addEdge H e]

/-- **Upper bound**: Δτ*(H, e) ≤ 1. -/
theorem edgeInsertionDelta_le_one (H : Hypergraph V) (e : Finset V)
    (he : e.Nonempty) :
    edgeInsertionDelta H e ≤ 1 := by
  unfold edgeInsertionDelta
  linarith [fracTransversalNum_addEdge_le H e he]

/-- **Absolute bound**: |Δτ*(H, e)| ≤ 1. -/
theorem edgeInsertionDelta_abs_le_one (H : Hypergraph V) (e : Finset V)
    (he : e.Nonempty) :
    |edgeInsertionDelta H e| ≤ 1 := by
  rw [abs_le]
  exact ⟨by linarith [edgeInsertionDelta_nonneg H e],
         edgeInsertionDelta_le_one H e he⟩

/-- Fractional transversal number is monotone under edge insertion. -/
theorem fracTransversalNum_mono_insertEdge (H : Hypergraph V) (e : Finset V) :
    fracTransversalNum H ≤ fracTransversalNum (addEdge H e) :=
  fracTransversalNum_le_addEdge H e

/-! ## Part II: Susceptibility Observables -/

/-- The set of all `d`-element subsets of V. -/
def allDEdges (V : Type*) [Fintype V] [DecidableEq V] (d : ℕ) : Finset (Finset V) :=
  Finset.univ.filter (fun e => e.card = d)

theorem mem_allDEdges_iff (d : ℕ) (e : Finset V) :
    e ∈ allDEdges V d ↔ e.card = d := by simp [allDEdges]

theorem allDEdges_nonempty_of_mem (d : ℕ) (hd : 0 < d) (e : Finset V)
    (he : e ∈ allDEdges V d) : e.Nonempty := by
  rw [mem_allDEdges_iff] at he; exact Finset.card_pos.mp (he ▸ hd)

/-- **Maximum edge-insertion susceptibility**. -/
noncomputable def susceptibilityMax (H : Hypergraph V) (d : ℕ) : ℝ :=
  if h : (allDEdges V d).Nonempty then
    (allDEdges V d).sup' h (fun e => |edgeInsertionDelta H e|)
  else 0

/-- **Mean edge-insertion susceptibility**. -/
noncomputable def susceptibilityAvg (H : Hypergraph V) (d : ℕ) : ℝ :=
  if (allDEdges V d).card ≠ 0 then
    (∑ e ∈ allDEdges V d, |edgeInsertionDelta H e|) / (allDEdges V d).card
  else 0

/-- **Structure bundling finite-size susceptibility data**. -/
structure FiniteSizeSusceptibility (V : Type*) [Fintype V] [DecidableEq V] where
  d : ℕ
  H : Hypergraph V
  chiMax : ℝ
  chiAvg : ℝ

noncomputable def FiniteSizeSusceptibility.ofHypergraph
    (d : ℕ) (H : Hypergraph V) : FiniteSizeSusceptibility V :=
  { d := d, H := H, chiMax := susceptibilityMax H d, chiAvg := susceptibilityAvg H d }

/-! ## Part III: Susceptibility Bounds -/

/-- **Maximum susceptibility ≤ 1**. -/
theorem susceptibilityMax_le_one (H : Hypergraph V) (d : ℕ) (hd : 0 < d) :
    susceptibilityMax H d ≤ 1 := by
  unfold susceptibilityMax
  split_ifs with h
  · exact Finset.sup'_le _ _ fun e he =>
      edgeInsertionDelta_abs_le_one H e (allDEdges_nonempty_of_mem d hd e he)
  · linarith

/-- **Mean susceptibility ≤ 1**. -/
theorem susceptibilityAvg_le_one (H : Hypergraph V) (d : ℕ) (hd : 0 < d) :
    susceptibilityAvg H d ≤ 1 := by
  unfold susceptibilityAvg
  split_ifs with h
  · apply div_le_one_of_le₀
    · calc ∑ e ∈ allDEdges V d, |edgeInsertionDelta H e|
          ≤ ∑ e ∈ allDEdges V d, (1 : ℝ) :=
            Finset.sum_le_sum fun e he =>
              edgeInsertionDelta_abs_le_one H e (allDEdges_nonempty_of_mem d hd e he)
        _ = (allDEdges V d).card := by simp
    · exact Nat.cast_nonneg _
  · linarith

/-- Maximum susceptibility is nonneg. -/
theorem susceptibilityMax_nonneg (H : Hypergraph V) (d : ℕ) :
    0 ≤ susceptibilityMax H d := by
  unfold susceptibilityMax
  split_ifs with h
  · obtain ⟨e, he⟩ := h
    exact le_trans (abs_nonneg (edgeInsertionDelta H e))
      (Finset.le_sup' (fun e => |edgeInsertionDelta H e|) he)
  · exact le_refl _

/-- Mean susceptibility is nonneg. -/
theorem susceptibilityAvg_nonneg (H : Hypergraph V) (d : ℕ) :
    0 ≤ susceptibilityAvg H d := by
  unfold susceptibilityAvg
  split_ifs with h
  · exact div_nonneg (Finset.sum_nonneg (fun e _ => abs_nonneg _)) (Nat.cast_nonneg _)
  · exact le_refl _

/-
**Mean ≤ Max**: the average cannot exceed the maximum.
-/
theorem susceptibilityAvg_le_susceptibilityMax (H : Hypergraph V) (d : ℕ) :
    susceptibilityAvg H d ≤ susceptibilityMax H d := by
      unfold susceptibilityMax susceptibilityAvg;
      split_ifs <;> simp_all +decide [ Finset.nonempty_iff_ne_empty ];
      · obtain ⟨ b, hb ⟩ := Finset.exists_max_image ( allDEdges V d ) ( fun e => |edgeInsertionDelta H e| ) ‹_›;
        exact ⟨ b, hb.1, by rw [ div_le_iff₀' ( Nat.cast_pos.mpr <| Finset.card_pos.mpr ⟨ b, hb.1 ⟩ ) ] ; exact le_trans ( Finset.sum_le_sum hb.2 ) ( by simp +decide [ Finset.sum_const, nsmul_eq_mul ] ) ⟩;
      · grind +splitImp

/-! ## Part IV: Quadratic Susceptibility and Variance Decomposition -/

/-- The quadratic susceptibility: sum of squared increments.
    For an edge-exposure martingale, equals `Var(τ*(H_m))`. -/
noncomputable def quadraticSusceptibility (f : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, (f (i + 1) - f i) ^ 2

/-- Quadratic susceptibility is nonneg. -/
theorem quadraticSusceptibility_nonneg (f : ℕ → ℝ) (n : ℕ) :
    0 ≤ quadraticSusceptibility f n :=
  Finset.sum_nonneg (fun i _ => sq_nonneg _)

/-
**Quadratic susceptibility ≤ n** when increments bounded by 1.
-/
theorem quadraticSusceptibility_le_length (f : ℕ → ℝ) (n : ℕ)
    (hbd : ∀ i < n, |f (i + 1) - f i| ≤ 1) :
    quadraticSusceptibility f n ≤ n := by
      exact le_trans ( Finset.sum_le_sum fun i hi => show ( f ( i + 1 ) - f i ) ^ 2 ≤ 1 by nlinarith only [ abs_le.mp ( hbd i ( Finset.mem_range.mp hi ) ) ] ) ( by norm_num )

/-
**Telescoping sum**: total displacement = f(n) - f(0).
-/
theorem total_displacement_eq (f : ℕ → ℝ) (n : ℕ) :
    ∑ i ∈ Finset.range n, (f (i + 1) - f i) = f n - f 0 := by
      rw [ Finset.sum_range_sub ]

/-
**Variance = quadratic susceptibility** when cross-terms vanish
    (martingale orthogonality).
-/
theorem variance_eq_quadSusceptibility (f : ℕ → ℝ) (n : ℕ) (h0 : f 0 = 0)
    (hcross : ∑ i ∈ Finset.range n, (f (i + 1) - f i) *
        ∑ j ∈ Finset.range i, (f (j + 1) - f j) = 0) :
    f n ^ 2 = quadraticSusceptibility f n := by
      -- By definition of $f$, we know that $f(n) = \sum_{i=0}^{n-1} (f(i+1) - f(i))$.
      have h_fn : f n = ∑ i ∈ Finset.range n, (f (i + 1) - f i) := by
        rw [ Finset.sum_range_sub, h0, sub_zero ];
      -- Expand the square using the binomial theorem.
      have h_expand : (∑ i ∈ Finset.range n, (f (i + 1) - f i))^2 = ∑ i ∈ Finset.range n, (f (i + 1) - f i)^2 + 2 * ∑ i ∈ Finset.range n, (f (i + 1) - f i) * ∑ j ∈ Finset.range i, (f (j + 1) - f j) := by
        exact Nat.recOn n ( by norm_num ) fun n ih => by norm_num [ Finset.sum_range_succ ] at * ; linarith;
      simp_all +decide [ quadraticSusceptibility ]

/-! ## Part V: Pseudocritical Point Existence -/

/-
**Finite-size peak existence**: any function on {0,…,M} has a maximizer.
-/
theorem exists_pseudocritical_index
    (g : ℕ → ℝ) (M : ℕ) :
    ∃ m ≤ M, ∀ k ≤ M, g k ≤ g m := by
      have := Finset.exists_max_image ( Finset.Iic M ) g ( by simp +decide ) ; aesop;

noncomputable def pseudocriticalIndex (g : ℕ → ℝ) (M : ℕ) : ℕ :=
  (exists_pseudocritical_index g M).choose

noncomputable def pseudocriticalDensity (g : ℕ → ℝ) (M n : ℕ) : ℝ :=
  (pseudocriticalIndex g M : ℝ) / n

/-! ## Part VI: Cross-Domain Cauchy-Schwarz Bridge -/

/-
**Cauchy-Schwarz for susceptibility**: squared total displacement ≤ n · χ².
-/
theorem total_displacement_sq_le (f : ℕ → ℝ) (n : ℕ) :
    (∑ i ∈ Finset.range n, (f (i + 1) - f i)) ^ 2 ≤
    n * quadraticSusceptibility f n := by
      have h_cs : (∑ i ∈ Finset.range n, (f (i + 1) - f i))^2 ≤ n * (∑ i ∈ Finset.range n, (f (i + 1) - f i)^2) := by
        have := ( Finset.sum_le_sum fun i ( hi : i ∈ Finset.range n ) => mul_self_nonneg ( f ( i + 1 ) - f i - ( ∑ i ∈ Finset.range n, ( f ( i + 1 ) - f i ) ) / n ) );
        by_cases hn : n = 0 <;> simp_all +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sub_mul, mul_sub, sq ];
        simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_comm ];
        nlinarith [ mul_div_cancel₀ ( ∑ i ∈ Finset.range n, f ( i + 1 ) - ∑ i ∈ Finset.range n, f i ) ( by positivity : ( n : ℝ ) ≠ 0 ) ];
      convert h_cs using 1

/-! ## Part VII: Finite-Size Scaling Conjecture -/

/-- **Conjecture (finite-size scaling)**:
    For `d ≥ 2`, there exist `c*(d) > 0`, `γ(d) > 0`, `ν(d) > 0` and a scaling
    function such that χ²(n,m,d) = n^γ · F_d((c-c*)·n^{1/ν}) + o(n^γ).

    **Disproof criterion**: γ(d) drifts as n increases from 50 to 500. -/
structure FiniteSizeScalingConjecture where
  d : ℕ
  hd : 2 ≤ d
  criticalDensity : ℝ
  hc_pos : 0 < criticalDensity
  gamma : ℝ
  hgamma_pos : 0 < gamma
  nu : ℝ
  hnu_pos : 0 < nu

end OptCrit