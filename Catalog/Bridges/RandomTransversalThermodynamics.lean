/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Pythagorean.HypergraphTransversal
import Pythagorean.FracTransversalConcentration

/-!
# Random Transversal Thermodynamics

This file develops the theory of **random transversal thermodynamics** for
hypergraphs, establishing a formal bridge between hypergraph transversal theory,
fractional optimization, and statistical physics of disordered systems.

## Scientific thesis

In sparse random `d`-uniform hypergraphs with linear edge density, the deterministic
worst-case integrality gap bound `τ(H) ≤ d · τ*(H)` is generically far from sharp.
The deviation from sharpness is governed by structural pseudorandomness conditions,
particularly **pair-codegree bounds** (low overlap profiles).

## Main results

* `fracTransversalNum_addEdge_abs_le'`: susceptibility bounded by 1
* `vertex_disjoint_integrality_gap_one`: gap = 1 for vertex-disjoint edges
* `csp_covering_approximation`: CSP d-approximation via transversal rounding
* `fracCoverDensity_monotone`: monotonicity of covering density
* `roundingDefect_nonneg`: rounding defect is nonneg
* `pairCodegree_symm`: pair codegree symmetry
* `transversal_iff_check_covering`: coding-theoretic bridge

## Application keywords

random hypergraphs, transversal number, fractional transversal, integrality gap,
phase transition, statistical physics, susceptibility, finite-size scaling,
random CSP, approximation algorithms, pseudorandomness, codegree bounds,
concentration of measure, universality class
-/

open Finset BigOperators Hypergraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Part I: Structural Pseudorandomness Definitions -/

/-- The **pair codegree** of vertices `u` and `v` in hypergraph `H`:
    the number of edges containing both `u` and `v`. -/
def pairCodegree (H : Hypergraph V) (u v : V) : ℕ :=
  (H.edges.filter (fun e => u ∈ e ∧ v ∈ e)).card

/-- A hypergraph has a **low overlap profile** at level `K` if every pair of
    distinct vertices shares at most `K` edges. -/
def LowOverlapProfile (H : Hypergraph V) (K : ℕ) : Prop :=
  ∀ u v : V, u ≠ v → pairCodegree H u v ≤ K

/-- A hypergraph has **pairwise vertex-disjoint edges**. -/
def PairwiseDisjointEdges (H : Hypergraph V) : Prop :=
  ∀ e₁ ∈ H.edges, ∀ e₂ ∈ H.edges, e₁ ≠ e₂ → Disjoint e₁ e₂

/-! ## Part II: Thermodynamic Observables -/

/-- The **rounding defect**: gap between integer and fractional transversal costs. -/
noncomputable def roundingDefectOf (S : Finset V) (x : V → ℝ) : ℝ :=
  (S.card : ℝ) - fracTransversalValue x

/-- The **fractional cover density**: τ*(H) normalized by vertex count. -/
noncomputable def fracCoverDensity (H : Hypergraph V) : ℝ :=
  fracTransversalNum H / Fintype.card V

/-! ## Part III: Monotone Covering CSPs -/

/-- A **monotone covering CSP** instance. -/
structure MonotoneCoverCSP (V C : Type*) where
  scope : C → Finset V
  maxArity : ℕ
  arity_bound : ∀ c : C, (scope c).card ≤ maxArity

/-- A feasible integral solution hits every constraint scope. -/
def MonotoneCoverCSP.IsFeasible {V C : Type*} [DecidableEq V]
    (I : MonotoneCoverCSP V C) (S : Finset V) : Prop :=
  ∀ c : C, (S ∩ I.scope c).Nonempty

/-- A fractional feasible solution. -/
def MonotoneCoverCSP.IsFracFeasible {V C : Type*} [Fintype V]
    (I : MonotoneCoverCSP V C) (x : V → ℝ) : Prop :=
  (∀ v, 0 ≤ x v) ∧ ∀ c : C, 1 ≤ ∑ v ∈ I.scope c, x v

/-- Convert a CSP to its constraint hypergraph. -/
def MonotoneCoverCSP.toHypergraph {V C : Type*} [Fintype C] [DecidableEq C] [DecidableEq V]
    (I : MonotoneCoverCSP V C) : Hypergraph V :=
  ⟨Finset.image I.scope Finset.univ⟩

/-! ## Part IV: Incidence Codes -/

/-- Convert a hypergraph to its incidence code (checks = edges). -/
def toIncidenceChecks (H : Hypergraph V) : Finset (Finset V) := H.edges

/-- A check-covering set hits every check. -/
def IsCheckCoveringSet (checks : Finset (Finset V)) (S : Finset V) : Prop :=
  ∀ c ∈ checks, (S ∩ c).Nonempty

/-- Removing an edge from a hypergraph. -/
def removeEdge (H : Hypergraph V) (e : Finset V) : Hypergraph V :=
  ⟨H.edges.erase e⟩

/-- Union of two hypergraphs by edge sets. -/
def edgeUnion (H₁ H₂ : Hypergraph V) : Hypergraph V :=
  ⟨H₁.edges ∪ H₂.edges⟩

/-! ## Part V: Core Theorems -/

/-! ### Theorem 1: Susceptibility bound -/

/-- **Susceptibility bound**: |Δτ*| ≤ 1 under single-edge insertion.
    Gateway to concentration of measure via McDiarmid's inequality. -/
theorem fracTransversalNum_addEdge_abs_le' (H : Hypergraph V) (e : Finset V)
    (he : e.Nonempty) :
    |fracTransversalNum (addHyperedge H e) - fracTransversalNum H| ≤ 1 := by
  rw [abs_le]
  exact ⟨by linarith [fracTransversalNum_le_addEdge H e],
         by linarith [fracTransversalNum_addEdge_le H e he]⟩

/-! ### Theorem 2: Vertex-disjoint improved gap -/

/-
In a hypergraph with vertex-disjoint edges, summing a nonneg function
    over edge-vertex pairs ≤ total sum (no double counting).
-/
theorem sum_over_disjoint_edges (H : Hypergraph V) (x : V → ℝ)
    (hx_nn : ∀ v, 0 ≤ x v)
    (hdisj : PairwiseDisjointEdges H) :
    ∑ e ∈ H.edges, ∑ v ∈ e, x v ≤ ∑ v : V, x v := by
  rw [ ← Finset.sum_biUnion ];
  · exact Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => hx_nn _;
  · exact fun e he f hf hne => hdisj e he f hf hne

/-
For vertex-disjoint edges, fractional transversal value ≥ |edges|.
-/
theorem fracTransversal_value_ge_edges_of_disjoint (H : Hypergraph V) (x : V → ℝ)
    (hx : IsFracTransversal H x)
    (hdisj : PairwiseDisjointEdges H) :
    H.edges.card ≤ fracTransversalValue x := by
  exact le_trans ( by simpa using Finset.sum_le_sum fun e ( he : e ∈ H.edges ) ↦ hx.2 e he ) ( sum_over_disjoint_edges H x hx.1 hdisj )

/-
Nonempty edges admit a transversal of size ≤ |edges|.
-/
theorem exists_transversal_of_card_edges (H : Hypergraph V)
    (hne : ∀ e ∈ H.edges, e.Nonempty) :
    ∃ S : Finset V, IsTransversal H S ∧ S.card ≤ H.edges.card := by
  -- By the axiom of choice, we can select a vertex from each edge.
  obtain ⟨f, hf⟩ : ∃ (f : H.edges → V), ∀ e : H.edges, f e ∈ e.val := by
    exact ⟨ fun e => Classical.choose ( hne e.val e.prop ), fun e => Classical.choose_spec ( hne e.val e.prop ) ⟩;
  refine' ⟨ Finset.image f Finset.univ, _, _ ⟩;
  · intro e he;
    exact ⟨ f ⟨ e, he ⟩, Finset.mem_inter.mpr ⟨ Finset.mem_image_of_mem _ ( Finset.mem_univ _ ), hf ⟨ e, he ⟩ ⟩ ⟩;
  · exact Finset.card_image_le.trans_eq ( by simp +decide )

/-
**Vertex-disjoint gap = 1**: integrality gap collapses under
    maximal pseudorandomness (zero overlap).
-/
theorem vertex_disjoint_integrality_gap_one (H : Hypergraph V) (x : V → ℝ)
    (hx : IsFracTransversal H x)
    (hdisj : PairwiseDisjointEdges H)
    (hne : ∀ e ∈ H.edges, e.Nonempty) :
    ∃ S : Finset V, IsTransversal H S ∧
      (S.card : ℝ) ≤ fracTransversalValue x := by
  -- Use the existence of a transversal of size at most |edges| (from h_exists_S)
  obtain ⟨S, hS_transversal, hS_card⟩ : ∃ S : Finset V, IsTransversal H S ∧ S.card ≤ H.edges.card := by
    exact exists_transversal_of_card_edges H hne
  exact ⟨ S, hS_transversal, le_trans ( Nat.cast_le.mpr hS_card ) ( mod_cast fracTransversal_value_ge_edges_of_disjoint H x hx hdisj ) ⟩

/-! ### Theorem 3: CSP covering certificate -/

/-
Fractional CSP solution → fractional transversal of constraint hypergraph.
-/
theorem csp_frac_feasible_is_frac_transversal
    {C : Type*} [Fintype C] [DecidableEq C]
    (I : MonotoneCoverCSP V C) (x : V → ℝ) (hx : I.IsFracFeasible x) :
    IsFracTransversal I.toHypergraph x := by
  refine' ⟨ hx.1, _ ⟩;
  grind +locals

/-
**CSP covering d-approximation**: threshold rounding yields integral
    solution of cost at most `d` times the fractional cost.
-/
theorem csp_covering_approximation
    {C : Type*} [Fintype C] [DecidableEq C]
    (I : MonotoneCoverCSP V C) (x : V → ℝ) (hx : I.IsFracFeasible x)
    (hd_pos : 0 < I.maxArity)
    (hne : ∀ c : C, (I.scope c).Nonempty) :
    ∃ S : Finset V, I.IsFeasible S ∧
      (S.card : ℝ) ≤ I.maxArity * fracTransversalValue x := by
  have := @csp_frac_feasible_is_frac_transversal;
  convert integrality_gap_upper I.toHypergraph x I.maxArity ( this I x hx ) _ _ _;
  · ext; simp [MonotoneCoverCSP.IsFeasible, IsTransversal];
    simp +decide [ MonotoneCoverCSP.toHypergraph ];
  · simp +decide [ MonotoneCoverCSP.toHypergraph ];
    exact fun c => I.arity_bound c;
  · grind +revert;
  · unfold MonotoneCoverCSP.toHypergraph; aesop;

/-! ### Theorem 4: Monotonicity of fracCoverDensity -/

/-
**Monotonicity of fractional cover density**.
-/
theorem fracCoverDensity_monotone {H₁ H₂ : Hypergraph V}
    (hsub : H₁.edges ⊆ H₂.edges)
    (hn : 0 < (Fintype.card V : ℝ)) :
    fracCoverDensity H₁ ≤ fracCoverDensity H₂ := by
  exact div_le_div_of_nonneg_right ( fracTransversal_monotone hsub ) ( Nat.cast_nonneg _ )

/-! ### Theorem 5: Rounding defect bounds -/

/-
**Rounding defect upper bound**: from the d-approximation,
    the rounded set has defect ≤ (d-1) · value(x).
-/
theorem roundingDefect_upper_bound (H : Hypergraph V) (x : V → ℝ) (d : ℕ)
    (hx : IsFracTransversal H x)
    (hd : ∀ e ∈ H.edges, e.card ≤ d)
    (hd_pos : 0 < d)
    (hne : ∀ e ∈ H.edges, e.Nonempty) :
    ∃ S : Finset V, IsTransversal H S ∧
      roundingDefectOf S x ≤ (d - 1 : ℝ) * fracTransversalValue x := by
  obtain ⟨S, hS_transversal, hS_card⟩ : ∃ S : Finset V, IsTransversal H S ∧ (S.card : ℝ) ≤ d * fracTransversalValue x := by
    convert integrality_gap_upper H x d hx hd hd_pos hne using 1;
  exact ⟨ S, hS_transversal, by unfold roundingDefectOf; linarith ⟩

/-! ### Pair codegree properties -/

/-
Pair codegree is symmetric.
-/
theorem pairCodegree_symm (H : Hypergraph V) (u v : V) :
    pairCodegree H u v = pairCodegree H v u := by
  exact congr_arg Finset.card ( by ext; simp +decide [ and_comm ] )

/-
Vertex-disjoint edges have pair codegree at most 1 for distinct vertices:
    at most one edge contains both u and v (since two such edges would share u).
-/
theorem pairCodegree_le_one_of_disjoint (H : Hypergraph V)
    (hdisj : PairwiseDisjointEdges H) (u v : V) :
    pairCodegree H u v ≤ 1 := by
  refine' Finset.card_le_one.mpr _;
  simp +contextual [ PairwiseDisjointEdges ];
  exact fun a ha hu hv b hb hu' hv' => Classical.not_not.1 fun h => Finset.disjoint_left.1 ( hdisj a ha b hb h ) hu hu'

/-
Vertex-disjoint edges have overlap profile 1.
-/
theorem disjoint_has_low_overlap (H : Hypergraph V)
    (hdisj : PairwiseDisjointEdges H) :
    LowOverlapProfile H 1 := by
  exact fun u v huv => by exact le_trans ( pairCodegree_le_one_of_disjoint H hdisj u v ) ( by norm_num ) ;

/-! ### Low overlap = gap 1 -/

/-
Under vertex-disjoint edges, the integrality gap is 1.
    **Proof sketch**: Pick one vertex per edge (≤ |edges| total).
    Disjointness gives Σ x(v) ≥ Σ_e Σ_{v∈e} x(v) ≥ |edges| ≥ |S|.
    This uses `sum_over_disjoint_edges` and `exists_transversal_of_card_edges`.
-/
theorem disjoint_edges_integrality_gap_one (H : Hypergraph V) (x : V → ℝ)
    (hx : IsFracTransversal H x)
    (hdisj : PairwiseDisjointEdges H)
    (hne : ∀ e ∈ H.edges, e.Nonempty) :
    ∃ S : Finset V, IsTransversal H S ∧
      (S.card : ℝ) ≤ fracTransversalValue x :=
  vertex_disjoint_integrality_gap_one H x hx hdisj hne

/-! ### Coding-theoretic bridge -/

/-
**Transversal = check-covering**: bridge to coding theory.
-/
theorem transversal_iff_check_covering (H : Hypergraph V) (S : Finset V) :
    IsTransversal H S ↔ IsCheckCoveringSet (toIncidenceChecks H) S :=
  Iff.rfl

/-
Fractional transversal gives check-covering bound for incidence codes.
-/
theorem incidence_code_covering_bound (H : Hypergraph V) (x : V → ℝ) (d : ℕ)
    (hx : IsFracTransversal H x) (hd : ∀ e ∈ H.edges, e.card ≤ d)
    (hd_pos : 0 < d) (hne : ∀ e ∈ H.edges, e.Nonempty) :
    ∃ S : Finset V, IsCheckCoveringSet (toIncidenceChecks H) S ∧
      (S.card : ℝ) ≤ d * fracTransversalValue x := by
  convert integrality_gap_upper H x d hx hd hd_pos hne using 1

/-! ### Edge operations stability -/

/-- Removing an edge gives a subhypergraph. -/
theorem removeEdge_subset (H : Hypergraph V) (e : Finset V) :
    (removeEdge H e).edges ⊆ H.edges := by
  simp [removeEdge]; exact Finset.erase_subset e H.edges

/-- τ* decreases under edge removal. -/
theorem fracTransversalNum_removeEdge_le (H : Hypergraph V) (e : Finset V) :
    fracTransversalNum (removeEdge H e) ≤ fracTransversalNum H :=
  fracTransversal_monotone (removeEdge_subset H e)

/-
Reinserting a removed edge recovers the original (if edge was present).
-/
theorem addHyperedge_removeEdge (H : Hypergraph V) (e : Finset V)
    (he : e ∈ H.edges) :
    (addHyperedge (removeEdge H e) e).edges = H.edges := by
  ext; simp [addHyperedge, removeEdge, he]

/-! ### Edge union -/

/-
Fractional transversal of both subhypergraphs covers the union.
-/
theorem fracTransversal_union (H₁ H₂ : Hypergraph V) (x : V → ℝ)
    (hx₁ : IsFracTransversal H₁ x) (hx₂ : IsFracTransversal H₂ x) :
    IsFracTransversal (edgeUnion H₁ H₂) x := by
  exact ⟨ hx₁.1, fun e he => by cases Finset.mem_union.mp he <;> [ exact hx₁.2 e ‹_›; exact hx₂.2 e ‹_› ] ⟩

omit [Fintype V] in
/-- Left edges included in union. -/
theorem edgeUnion_subset_left (H₁ H₂ : Hypergraph V) :
    H₁.edges ⊆ (edgeUnion H₁ H₂).edges := by
  simp [edgeUnion]

omit [Fintype V] in
/-- Right edges included in union. -/
theorem edgeUnion_subset_right (H₁ H₂ : Hypergraph V) :
    H₂.edges ⊆ (edgeUnion H₁ H₂).edges := by
  simp [edgeUnion]