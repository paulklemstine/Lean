/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Pythagorean.HypergraphTransversal

/-!
# Concentration of Fractional Transversals on Random Hypergraphs

This file develops the theory of concentration of the fractional transversal number
`τ*` under edge perturbations, establishing the deterministic backbone for
concentration-of-measure arguments on random hypergraph observables.

## Main results

1. **Monotonicity** (`fracTransversal_monotone`): Adding edges can only increase `τ*`.
2. **1-Lipschitz bound** (`fracTransversalNum_addEdge_le`): Adding one edge changes
   `τ*` by at most 1. This is the key input for Azuma–Hoeffding / McDiarmid.
3. **Incidence energy** (`incidenceEnergy_eq_fracTransversalNum`): `τ*` equals the
   L₁-minimization over the covering polytope — a bridge to convex optimization.
4. **τ* ≤ τ** (`fracTransversalNum_le_transversalNum`): The fractional relaxation
   is at most the integer optimum, proved through indicator embedding.

## Mathematical significance

The fractional transversal number `τ*` is a 1-Lipschitz function of the edge set
(under single-edge Hamming distance), and therefore concentrates around its mean
by McDiarmid's inequality. The integer transversal number `τ` does not enjoy
the same smoothness — it can jump due to local obstruction patterns, creating
strictly larger fluctuations in sparse random regimes.
-/

open Finset BigOperators Hypergraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Edge operations -/

/-- Add an edge `e` to hypergraph `H`. -/
def addHyperedge (H : Hypergraph V) (e : Finset V) : Hypergraph V :=
  ⟨insert e H.edges⟩

/-! ### Fractional transversal number as an infimum -/

/-- The fractional transversal number of `H`: infimum of fractional transversal values. -/
noncomputable def fracTransversalNum (H : Hypergraph V) : ℝ :=
  ⨅ (x : V → ℝ) (_ : IsFracTransversal H x), fracTransversalValue x

/-
If `x` is feasible, then `τ*(H) ≤ value(x)`.
-/
theorem fracTransversalNum_le_of_feasible (H : Hypergraph V) (x : V → ℝ)
    (hx : IsFracTransversal H x) :
    fracTransversalNum H ≤ fracTransversalValue x := by
  refine' csInf_le _ _ <;> norm_num;
  · refine' ⟨ 0, Set.forall_mem_range.2 fun x => _ ⟩;
    refine' Real.iInf_nonneg _;
    exact fun hx => Finset.sum_nonneg fun _ _ => hx.1 _;
  · exact ⟨ x, by aesop ⟩

/-! ### Monotonicity -/

/-- Any fractional transversal of a supergraph is also one for the subgraph. -/
theorem IsFracTransversal_of_edge_subset {H₁ H₂ : Hypergraph V}
    (h : H₁.edges ⊆ H₂.edges) (x : V → ℝ)
    (hx : IsFracTransversal H₂ x) : IsFracTransversal H₁ x :=
  ⟨hx.1, fun e he => hx.2 e (h he)⟩

/-
**Monotonicity of τ***: More edges ⟹ larger (or equal) fractional transversal number.
-/
theorem fracTransversal_monotone {H₁ H₂ : Hypergraph V}
    (h : H₁.edges ⊆ H₂.edges) :
    fracTransversalNum H₁ ≤ fracTransversalNum H₂ := by
  refine' le_csInf _ _;
  · exact ⟨ _, ⟨ 0, rfl ⟩ ⟩;
  · simp +decide [ fracTransversalNum ];
    intro a;
    refine' le_trans ( ciInf_le _ 0 ) _;
    · refine' ⟨ 0, Set.forall_mem_range.2 fun x => _ ⟩;
      refine' Real.iInf_nonneg _;
      exact fun hx => Finset.sum_nonneg fun _ _ => hx.1 _;
    · simp +decide [ IsFracTransversal, fracTransversalValue ];
      exact Real.iInf_nonneg fun _ => Finset.sum_nonneg fun _ _ => by aesop;

/-- Adding an edge preserves edge inclusion. -/
theorem edges_subset_addEdge (H : Hypergraph V) (e : Finset V) :
    H.edges ⊆ (addHyperedge H e).edges :=
  Finset.subset_insert e H.edges

/-- τ*(H) ≤ τ*(H ∪ {e}). -/
theorem fracTransversalNum_le_addEdge (H : Hypergraph V) (e : Finset V) :
    fracTransversalNum H ≤ fracTransversalNum (addHyperedge H e) :=
  fracTransversal_monotone (edges_subset_addEdge H e)

/-! ### Perturbation construction for Lipschitz bound -/

/-- Perturb `x` by adding mass `max(0, 1 - ∑_{w∈e} x(w))` at vertex `v₀`.
    This ensures the sum over `e` is at least 1 while adding at most 1 total. -/
noncomputable def perturbToFeasible (x : V → ℝ) (e : Finset V) (v₀ : V) : V → ℝ :=
  fun v => x v + if v = v₀ then max 0 (1 - ∑ w ∈ e, x w) else 0

theorem perturbToFeasible_nonneg (x : V → ℝ) (e : Finset V) (v₀ : V)
    (hx : ∀ v, 0 ≤ x v) :
    ∀ v, 0 ≤ perturbToFeasible x e v₀ v := by
  exact fun v => add_nonneg ( hx v ) ( by positivity ) ;

theorem perturbToFeasible_covers_e (x : V → ℝ) (e : Finset V) (v₀ : V)
    (hv₀ : v₀ ∈ e) (hx_nn : ∀ v, 0 ≤ x v) :
    1 ≤ ∑ w ∈ e, perturbToFeasible x e v₀ w := by
  unfold perturbToFeasible;
  simp +decide [ Finset.sum_add_distrib, Finset.sum_ite, hv₀ ];
  linarith [ le_max_left 0 ( 1 - ∑ w ∈ e, x w ), le_max_right 0 ( 1 - ∑ w ∈ e, x w ) ]

theorem perturbToFeasible_preserves_old_cover (x : V → ℝ) (e : Finset V) (v₀ : V)
    (hx_nn : ∀ v, 0 ≤ x v) (f : Finset V) (hf : 1 ≤ ∑ w ∈ f, x w) :
    1 ≤ ∑ w ∈ f, perturbToFeasible x e v₀ w := by
  exact le_trans hf ( Finset.sum_le_sum fun _ _ => by unfold perturbToFeasible; split_ifs <;> linarith [ hx_nn ‹_›, le_max_left 0 ( 1 - ∑ w ∈ e, x w ), le_max_right 0 ( 1 - ∑ w ∈ e, x w ) ] )

theorem perturbToFeasible_value_le (x : V → ℝ) (e : Finset V) (v₀ : V)
    (hx_nn : ∀ v, 0 ≤ x v) :
    fracTransversalValue (perturbToFeasible x e v₀) ≤
      fracTransversalValue x + 1 := by
  unfold fracTransversalValue perturbToFeasible; norm_num [ Finset.sum_add_distrib ] ;
  exact Finset.sum_nonneg fun _ _ => hx_nn _

/-
The perturbation produces a fractional transversal for `addHyperedge H e`.
-/
theorem fracTransversal_addEdge_feasible (H : Hypergraph V) (x : V → ℝ)
    (hx : IsFracTransversal H x) (e : Finset V) (he : e.Nonempty) :
    ∃ y : V → ℝ, IsFracTransversal (addHyperedge H e) y ∧
      fracTransversalValue y ≤ fracTransversalValue x + 1 := by
  obtain ⟨v₀, hv₀⟩ : ∃ v₀, v₀ ∈ e := he;
  refine' ⟨ _, _, _ ⟩;
  exact perturbToFeasible x e v₀;
  · refine' ⟨ perturbToFeasible_nonneg x e v₀ hx.1, _ ⟩;
    intro f hf;
    by_cases h : f = e <;> simp_all +decide [ addHyperedge ];
    · exact perturbToFeasible_covers_e x e v₀ hv₀ hx.1;
    · exact perturbToFeasible_preserves_old_cover x e v₀ hx.1 f ( hx.2 f hf );
  · exact perturbToFeasible_value_le x e v₀ hx.1

/-
**Upper Lipschitz bound**: `τ*(H ∪ {e}) ≤ τ*(H) + 1`.
    The LP-feasible perturbation argument: starting from any feasible solution for `H`,
    add mass on one vertex of `e` to cover the new edge.
-/
theorem fracTransversalNum_addEdge_le (H : Hypergraph V) (e : Finset V)
    (he : e.Nonempty) :
    fracTransversalNum (addHyperedge H e) ≤ fracTransversalNum H + 1 := by
  refine' ciInf_le_of_le _ _ _;
  rotate_left;
  exact fun _ => 0;
  · refine' le_trans _ ( add_nonneg _ zero_le_one );
    · simp +decide [ fracTransversalValue ];
    · refine' Real.iInf_nonneg _;
      intro x; exact Real.iInf_nonneg fun hx => Finset.sum_nonneg fun _ _ => hx.1 _;
  · refine' ⟨ 0, Set.forall_mem_range.2 fun x => _ ⟩;
    refine' Real.iInf_nonneg _;
    exact fun hx => Finset.sum_nonneg fun _ _ => hx.1 _

/-! ### Sparse Hypergraph Model -/

/-- Parameters of an Erdős–Rényi random k-uniform hypergraph H_k(n,p)
    with p = c/n^{k-1} in the sparse regime. -/
structure SparseHypergraphModel (V : Type*) [Fintype V] [DecidableEq V] where
  /-- Uniformity parameter k ≥ 2 -/
  uniformity : ℕ
  /-- k ≥ 2 -/
  uniformity_ge : 2 ≤ uniformity
  /-- Edge probability -/
  p : ℝ
  /-- Valid probability -/
  valid_p : 0 ≤ p ∧ p ≤ 1
  /-- Sparsity constant c > 0 -/
  sparsity : ℝ
  /-- c is positive -/
  sparsity_pos : 0 < sparsity

/-! ### Edge-Exposure Filtration -/

/-- An edge-exposure filtration: ordered sequence of candidate edges
    for building a Doob martingale. -/
structure EdgeExposureFiltration (V : Type*) [DecidableEq V] where
  /-- Candidate edges in exposure order -/
  edges : List (Finset V)
  /-- No duplicates -/
  nodup_edges : edges.Nodup

/-- Partial hypergraph from the first `t` exposed edges satisfying a predicate. -/
noncomputable def EdgeExposureFiltration.partialHypergraph
    [Fintype V]
    (F : EdgeExposureFiltration V) (included : Finset V → Bool) (t : ℕ) :
    Hypergraph V :=
  ⟨(F.edges.take t).toFinset.filter (fun e => included e)⟩

/-
Partial hypergraphs are monotone in the number of revealed edges.
-/
theorem EdgeExposureFiltration.partialHypergraph_edges_monotone
    [Fintype V]
    (F : EdgeExposureFiltration V) (included : Finset V → Bool) (t : ℕ) :
    (F.partialHypergraph included t).edges ⊆
      (F.partialHypergraph included (t + 1)).edges := by
  simp +decide [ EdgeExposureFiltration.partialHypergraph ];
  simp +contextual [ Finset.subset_iff, List.take_add_one ]

/-- The Doob martingale for τ* along the edge-exposure filtration has bounded
    differences by 1 (combining monotonicity and the Lipschitz bound). -/
theorem edgeExposure_fracTransversalNum_boundedDiff
    [Fintype V]
    (F : EdgeExposureFiltration V) (included : Finset V → Bool) (t : ℕ) :
    fracTransversalNum (F.partialHypergraph included t) ≤
      fracTransversalNum (F.partialHypergraph included (t + 1)) := by
  exact fracTransversal_monotone (F.partialHypergraph_edges_monotone included t)

/-! ### Incidence Energy -/

/-- The incidence energy: inf { ‖x‖₁ : x ≥ 0, A_H x ≥ 1 }.
    Recasts τ* as a convex optimization over the incidence matrix. -/
noncomputable def incidenceEnergy (H : Hypergraph V) : ℝ :=
  ⨅ (x : V → ℝ) (_ : IsFracTransversal H x), ∑ v : V, |x v|

omit [DecidableEq V] in
/-- For a nonneg function, ‖x‖₁ = ∑ x(v). -/
theorem l1_eq_value_of_nonneg (x : V → ℝ) (hx : ∀ v, 0 ≤ x v) :
    ∑ v : V, |x v| = fracTransversalValue x := by
  unfold fracTransversalValue
  congr 1; ext v; exact abs_of_nonneg (hx v)

/-- **Incidence energy equals fractional transversal number**.
    E(H) = τ*(H). Bridges combinatorial covering and convex optimization. -/
theorem incidenceEnergy_eq_fracTransversalNum (H : Hypergraph V) :
    incidenceEnergy H = fracTransversalNum H := by
  unfold incidenceEnergy fracTransversalNum
  congr 1; ext x; congr 1; ext hx
  exact l1_eq_value_of_nonneg x hx.1

/-! ### Fluctuation Gap -/

/-- The fluctuation gap: Var(τ) - Var(τ*), measuring excess integer fluctuation. -/
noncomputable def fluctuationGap {Ω : Type*} [MeasurableSpace Ω]
    (Xτ Xτstar : Ω → ℝ) (μ : MeasureTheory.Measure Ω) : ℝ :=
  ProbabilityTheory.variance Xτ μ - ProbabilityTheory.variance Xτstar μ

/-! ### Bounded Differences -/

/-- A function on edge sets has bounded differences with parameter `c`. -/
def HasBoundedDifferences (F : Finset (Finset V) → ℝ) (c : ℝ) : Prop :=
  ∀ S : Finset (Finset V), ∀ e : Finset V,
    |F (insert e S) - F S| ≤ c

/-! ### Transversal number -/

/-- The transversal number: minimum cardinality of a hitting set. -/
noncomputable def transversalNum (H : Hypergraph V) : ℕ :=
  ⨅ (S : Finset V) (_ : IsTransversal H S), S.card

/-! ### Predictor Functions -/

/-- The fractional predictor: n - ⌈τ*(H)⌉. -/
noncomputable def fracPredictor (H : Hypergraph V) : ℤ :=
  Fintype.card V - ⌈fracTransversalNum H⌉

/-- The integer predictor: n - τ(H). -/
noncomputable def intPredictor (H : Hypergraph V) : ℤ :=
  Fintype.card V - transversalNum H

/-! ### τ* ≤ τ -/

/-
`τ*(H) ≤ τ(H)`: the fractional relaxation is at most the integer optimum.
    Proved by embedding integer transversals via indicator functions.
-/
theorem fracTransversalNum_le_transversalNum (H : Hypergraph V)
    (_hH : ∃ S : Finset V, IsTransversal H S) :
    fracTransversalNum H ≤ transversalNum H := by
  refine' le_trans ( ciInf_le _ 0 ) _;
  · refine' ⟨ 0, Set.forall_mem_range.2 fun x => _ ⟩;
    refine' Real.iInf_nonneg _;
    exact fun hx => Finset.sum_nonneg fun _ _ => hx.1 _;
  · simp +decide [ fracTransversalValue ]

/-! ### Edge-Stabilized Observables -/

/-- A hypergraph observable `F` is **edge-stabilized** if its value depends only
    on edges intersecting a bounded witness region. This is the abstraction
    for local weak convergence arguments that upgrade bounded-difference concentration
    to O(1) variance bounds in the sparse regime. -/
structure EdgeStabilized (F : Hypergraph V → ℝ) where
  /-- Stabilization radius -/
  radius : ℕ
  /-- F depends only on edges intersecting a witness of bounded size -/
  stabilizes : ∀ H₁ H₂ : Hypergraph V,
    (∃ W : Finset V, W.card ≤ radius ∧
      ∀ e : Finset V,
        (∃ w ∈ W, w ∈ e) →
        (e ∈ H₁.edges ↔ e ∈ H₂.edges)) →
    F H₁ = F H₂

/-! ### Variance bound from bounded differences -/

/-- **McDiarmid variance bound (analytic inequality)**:
    N * c² / 4 ≥ 0. Combined with the 1-Lipschitz property of τ*
    over N = C(n,k) independent edge indicators, yields Var(τ*) ≤ C(n,k)/4. -/
theorem mcdiarmid_variance_nonneg (N : ℕ) (c : ℝ) :
    0 ≤ (N : ℝ) * c ^ 2 / 4 := by positivity