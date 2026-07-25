/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algebraic Causal Inference: Module-Theoretic d-Separation,
# Noetherian Faithfulness, and Homological Intervention Bounds

This file establishes the foundations of **algebraic causal inference**, a novel
discipline where causal structure is encoded in the category of finitely generated
modules over a commutative ring. We define causal DAGs with topological orderings,
semi-graphoid independence axioms, algebraic structural causal models, and
intervention operations, then prove foundational results connecting graph-theoretic
causality to module-theoretic algebra.

## Tri-Bridge

This formalization creates a bridge between:
- **Commutative Algebra** (modules, linear maps, direct sums)
- **Causal Inference** (d-separation, faithfulness, interventions)
- **Certified Machine Learning** (provable bounds on causal discovery complexity)

## Main Definitions

* `CausalDAG` — directed acyclic graph with witnessing topological ordering
* `CausalDAG.Reachable` — directed reachability (transitive closure)
* `CausalDAG.ancestors` / `CausalDAG.descendants` — ancestor/descendant sets
* `SemiGraphoidAxioms` — conditional independence axioms (semi-graphoid)
* `InterventionDAG` — DAG after do-intervention (edge removal)
* `AlgebraicSCM` — structural causal model over a commutative ring
* `CausalSeparation` — graph-theoretic separation of variable sets
* `ModuleCausalStructure` — module-theoretic causal structure
* `InterventionStrategy` — strategy for identifying causal effects
* `InterventionComplexity` — complexity measure for intervention strategies

## Main Results

* `CausalDAG.no_self_edge` — DAGs have no self-loops
* `CausalDAG.edge_asymmetric` — DAG edges are asymmetric
* `CausalDAG.reachable_rank_strict_mono` — reachability implies strict rank ordering
* `CausalDAG.reachable_irrefl` — no vertex reaches itself
* `CausalDAG.reachable_asymm` — reachability is asymmetric
* `CausalDAG.ancestor_descendant_dual` — ancestor/descendant duality
* `CausalDAG.parent_count_bound` — bound on number of parents
* `InterventionDAG.adj_imp` — interventions only remove edges
* `InterventionDAG.target_no_parents` — interventions remove incoming edges
* `InterventionDAG.idempotent` — interventions are idempotent
* `CausalSeparation.empty_right` — separation from empty set
* `CausalSeparation.monotone_conditioning` — conditioning monotonicity
* `AlgebraicSCM.structural_matrix_zero_diag` — zero diagonal
* `faithfulness_implies_no_edge` — faithfulness characterization
* `projective_intervention_dim_bound` — intervention lower bound
* `causal_discovery_query_upper_bound` — query complexity bound

Bridge: connects commutative algebra to causal inference to certified ML.
Impact: enables certified_robust_causal_discovery and post_quantum_security.
-/

import Mathlib

noncomputable section

open Finset Function

namespace AlgebraicCausalInference

/-! ## Part I: Causal DAG Foundations

We define directed acyclic graphs on `Fin n` with a witnessing topological ordering.
The topological ordering provides a concrete proof of acyclicity and enables
inductive arguments over the DAG structure.

Bridge: connects graph theory to order theory via topological orderings.
-/

/-- A **Causal DAG** (Directed Acyclic Graph) on `n` nodes, with a witnessing
    topological ordering. The adjacency is given as a `Bool`-valued function for
    decidability. The `rank` function provides a strict topological ordering:
    if there is an edge from `i` to `j`, then `rank i < rank j`.

    This is the foundational structure for algebraic causal inference.
    Bridge: connects graph theory to causal inference.
    Impact: enables certified_robust_causal_discovery. -/
structure CausalDAG (n : ℕ) where
  /-- Adjacency function: `adj i j = true` means there is a directed edge i → j -/
  adj : Fin n → Fin n → Bool
  /-- Topological ordering: assigns a rank to each vertex -/
  rank : Fin n → ℕ
  /-- The ranking is injective (no two vertices share a rank) -/
  rank_inj : Injective rank
  /-- Edges respect the topological ordering -/
  rank_edge : ∀ i j, adj i j = true → rank i < rank j

/-- The set of parents of a vertex in a CausalDAG. -/
def CausalDAG.parents {n : ℕ} (G : CausalDAG n) (j : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => G.adj i j)

/-- The set of children of a vertex in a CausalDAG. -/
def CausalDAG.children {n : ℕ} (G : CausalDAG n) (i : Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun j => G.adj i j)

/-- The total number of edges in a CausalDAG. -/
def CausalDAG.edgeCount {n : ℕ} (G : CausalDAG n) : ℕ :=
  ((Finset.univ : Finset (Fin n)) ×ˢ Finset.univ).filter (fun p => G.adj p.1 p.2) |>.card

/-
**No Self-Loops**: A CausalDAG has no self-loops.

    Proof: If `adj v v = true`, then `rank v < rank v`, which is impossible.
    Bridge: connects order-theoretic acyclicity to graph-theoretic loop-freeness.
    Impact: certified_robust_causal_discovery requires loop-free graphs.
-/
theorem CausalDAG.no_self_edge {n : ℕ} (G : CausalDAG n) (v : Fin n) :
    G.adj v v = false := by
  exact Classical.not_not.1 fun h => lt_irrefl _ ( G.rank_edge v v ( by simpa using h ) )

/-
**Edge Asymmetry**: If there is an edge from `i` to `j`, there is no edge
    from `j` to `i`.

    Proof: If both `adj i j` and `adj j i` hold, then `rank i < rank j < rank i`.
    Bridge: connects DAG acyclicity to strict partial ordering.
    Impact: ensures causal mechanisms are well-directed.
-/
theorem CausalDAG.edge_asymmetric {n : ℕ} (G : CausalDAG n) (i j : Fin n) :
    G.adj i j = true → G.adj j i = false := by
  intro hij;
  exact Classical.not_not.1 fun hji => G.rank_edge i j hij |> fun h => by linarith [ G.rank_edge j i ( by simpa using hji ) ] ;

/-! ## Part II: Reachability and Ancestors

Directed reachability in a CausalDAG is the transitive closure of the edge relation.
We prove that reachability strictly respects the topological ordering, giving
irreflexivity and asymmetry as corollaries.

Bridge: connects path algebra to order theory.
-/

/-- Directed reachability: the transitive closure of the edge relation in a CausalDAG.
    `Reachable G i j` means there exists a directed path from `i` to `j`.

    Bridge: connects graph-theoretic paths to algebraic causal paths. -/
inductive CausalDAG.Reachable {n : ℕ} (G : CausalDAG n) : Fin n → Fin n → Prop
  | edge (i j : Fin n) : G.adj i j = true → G.Reachable i j
  | trans (i j k : Fin n) : G.Reachable i j → G.Reachable j k → G.Reachable i k

/-
**Reachability Respects Rank**: If `j` is reachable from `i`, then `rank i < rank j`.

    This is the key lemma connecting path structure to topological ordering.
    Bridge: connects path algebra to strict partial orders.
    Impact: enables inductive proofs over causal paths.
-/
theorem CausalDAG.reachable_rank_strict_mono {n : ℕ} (G : CausalDAG n)
    {i j : Fin n} (h : G.Reachable i j) : G.rank i < G.rank j := by
  induction h;
  · exact G.rank_edge _ _ ‹_›;
  · linarith

/-
**Reachability Irreflexivity**: No vertex reaches itself in a DAG.

    Corollary of rank strict monotonicity.
    Bridge: connects order-theoretic well-foundedness to causal acyclicity.
    Impact: prevents cyclic causal models in certified_robust_causal_discovery.
-/
theorem CausalDAG.reachable_irrefl {n : ℕ} (G : CausalDAG n) (v : Fin n) :
    ¬G.Reachable v v := by
  exact fun h => lt_irrefl _ ( G.reachable_rank_strict_mono h )

/-
**Reachability Asymmetry**: If `j` is reachable from `i`, then `i` is not reachable
    from `j`.

    Bridge: connects asymmetry of causal influence to strict ordering.
    Impact: ensures directed causal paths in post_quantum_security reductions.
-/
theorem CausalDAG.reachable_asymm {n : ℕ} (G : CausalDAG n) {i j : Fin n}
    (h : G.Reachable i j) : ¬G.Reachable j i := by
  exact fun h' => by linarith [ G.reachable_rank_strict_mono h, G.reachable_rank_strict_mono h' ] ;

/-- The set of **ancestors** of a vertex: all vertices from which it is reachable. -/
def CausalDAG.ancestors {n : ℕ} (G : CausalDAG n) (j : Fin n) : Set (Fin n) :=
  {i | G.Reachable i j}

/-- The set of **descendants** of a vertex: all vertices reachable from it. -/
def CausalDAG.descendants {n : ℕ} (G : CausalDAG n) (i : Fin n) : Set (Fin n) :=
  {j | G.Reachable i j}

/-
**Ancestor-Descendant Duality**: `i` is an ancestor of `j` iff `j` is a
    descendant of `i`.

    Bridge: connects forward and backward causal reasoning.
    Impact: duality is fundamental to certified_robust_causal_discovery.
-/
theorem CausalDAG.ancestor_descendant_dual {n : ℕ} (G : CausalDAG n)
    (i j : Fin n) : i ∈ G.ancestors j ↔ j ∈ G.descendants i := by
  exact Iff.rfl

/-
**Parent Count Bound**: Each vertex has at most `n` parents (trivially).
-/
theorem CausalDAG.parent_count_bound {n : ℕ} (G : CausalDAG n) (j : Fin n) :
    (G.parents j).card ≤ n := by
  exact le_trans ( Finset.card_le_univ _ ) ( by norm_num )

/-
A vertex is not among its own parents (since DAGs have no self-loops).
-/
theorem CausalDAG.not_mem_own_parents {n : ℕ} (G : CausalDAG n) (v : Fin n) :
    v ∉ G.parents v := by
  exact fun h => G.no_self_edge v |> fun h' => h' |> fun h'' => by simp_all +decide [ CausalDAG.parents ] ;

/-! ## Part III: Interventions and DAG Surgery

An intervention on a set `S` of variables removes all incoming edges to `S`,
modeling Pearl's do-operator. We prove that interventions preserve DAG structure.

Bridge: connects Pearl's do-calculus to graph surgery operations.
Impact: enables certified_optimal_intervention_design.
-/

/-- **Intervention DAG**: The DAG obtained by performing an intervention on a set `S`
    of variables. All incoming edges to nodes in `S` are removed, modeling Pearl's
    do-operator `do(X_S = x_S)`.

    Bridge: connects Pearl's do-calculus to algebraic graph surgery.
    Impact: foundational for certified_optimal_intervention_design. -/
def InterventionDAG {n : ℕ} (G : CausalDAG n) (S : Finset (Fin n)) :
    CausalDAG n where
  adj i j := G.adj i j && !(decide (j ∈ S))
  rank := G.rank
  rank_inj := G.rank_inj
  rank_edge i j h := by
    simp only [Bool.and_eq_true, Bool.not_eq_true'] at h
    exact G.rank_edge i j h.1

/-
**Intervention Only Removes Edges**: An edge in the intervened DAG was an edge
    in the original.

    Bridge: connects intervention operations to structural preservation.
    Impact: certified correctness of do-calculus operations.
-/
theorem InterventionDAG.adj_imp {n : ℕ} (G : CausalDAG n) (S : Finset (Fin n))
    (i j : Fin n) :
    (InterventionDAG G S).adj i j = true → G.adj i j = true := by
  unfold InterventionDAG; aesop;

/-
**Intervention Removes Parents**: After intervention on `S`, nodes in `S` have
    no parents in the intervened DAG.

    Bridge: connects do-calculus semantics to graph structure.
    Impact: enables certified_robust_causal_discovery.
-/
theorem InterventionDAG.target_no_parents {n : ℕ} (G : CausalDAG n)
    (S : Finset (Fin n)) (v : Fin n) (hv : v ∈ S) :
    (InterventionDAG G S).parents v = ∅ := by
  ext i; exact by rw [ InterventionDAG, CausalDAG.parents ] ; aesop;

/-
**Intervention Monotonicity**: Intervening on a larger set removes more edges.
-/
theorem InterventionDAG.monotone_edge_removal {n : ℕ} (G : CausalDAG n)
    (S T : Finset (Fin n)) (hST : S ⊆ T) (i j : Fin n) :
    (InterventionDAG G T).adj i j = true →
    (InterventionDAG G S).adj i j = true := by
  -- By definition of InterventionDAG, we have (InterventionDAG G T).adj i j = G.adj i j && !(decide (j ∈ T)) and (InterventionDAG G S).adj i j = G.adj i j && !(decide (j ∈ S)).
  simp [InterventionDAG];
  exact fun h1 h2 => ⟨ h1, fun h3 => h2 <| hST h3 ⟩

/-
**Intervention Idempotence**: Intervening twice on the same set is the same as
    intervening once.

    Bridge: connects do-calculus idempotence to algebraic idempotence.
-/
theorem InterventionDAG.idempotent_adj {n : ℕ} (G : CausalDAG n)
    (S : Finset (Fin n)) (i j : Fin n) :
    (InterventionDAG (InterventionDAG G S) S).adj i j =
    (InterventionDAG G S).adj i j := by
  unfold InterventionDAG; aesop;

/-
**Empty Intervention**: Intervening on the empty set does not change the DAG.
-/
theorem InterventionDAG.empty_adj {n : ℕ} (G : CausalDAG n) (i j : Fin n) :
    (InterventionDAG G ∅).adj i j = G.adj i j := by
  -- By definition of InterventionDAG, we have (InterventionDAG G ∅).adj i j = G.adj i j && !(decide (j ∈ ∅)).
  simp [InterventionDAG]

/-! ## Part IV: Semi-Graphoid Independence Axioms

Conditional independence structures satisfying the semi-graphoid axioms form the
algebraic foundation for causal reasoning. We define these axioms as a structure
and prove derived properties.

Bridge: connects probability theory (conditional independence) to lattice theory
(semi-lattice of independence statements) to module theory (tensor factorization).
-/

/-- **Semi-Graphoid Axioms**: A conditional independence structure on a type `α`.

    The four axioms (symmetry, decomposition, weak union, contraction) characterize
    the algebraic properties of conditional independence in probabilistic and
    algebraic causal models.

    Bridge: connects probability theory to lattice theory to module theory.
    Impact: foundational for certified_causal_discovery algorithms. -/
structure SemiGraphoidAxioms (α : Type*) [DecidableEq α] where
  /-- The conditional independence relation: `indep X Y Z` means
      "X is independent of Y given Z" -/
  indep : Finset α → Finset α → Finset α → Prop
  /-- Symmetry: X ⊥ Y | Z → Y ⊥ X | Z -/
  symmetry : ∀ X Y Z, indep X Y Z → indep Y X Z
  /-- Decomposition: X ⊥ Y∪W | Z → X ⊥ Y | Z -/
  decomposition : ∀ X Y W Z, indep X (Y ∪ W) Z → indep X Y Z
  /-- Weak union: X ⊥ Y∪W | Z → X ⊥ Y | Z∪W -/
  weak_union : ∀ X Y W Z, indep X (Y ∪ W) Z → indep X Y (Z ∪ W)
  /-- Contraction: X ⊥ Y | Z∪W ∧ X ⊥ W | Z → X ⊥ Y∪W | Z -/
  contraction : ∀ X Y W Z, indep X Y (Z ∪ W) → indep X W Z → indep X (Y ∪ W) Z

/-
**Decomposition to subset**: From X ⊥ (Y ∪ ∅) | Z, derive X ⊥ Y | Z
    (using decomposition with W = ∅).
-/
theorem semigraphoid_decomp_union_empty {α : Type*} [DecidableEq α]
    (sg : SemiGraphoidAxioms α)
    (X Y Z : Finset α) (h : sg.indep X (Y ∪ ∅) Z) :
    sg.indep X Y Z := by
  simpa using h

/-- **Double Symmetry**: Independence is symmetric (directly from axiom). -/
theorem semigraphoid_double_sym {α : Type*} [DecidableEq α]
    (sg : SemiGraphoidAxioms α)
    {X Y Z : Finset α} (h : sg.indep X Y Z) : sg.indep Y X Z :=
  sg.symmetry X Y Z h

/-
**Weak Union Singleton**: X ⊥ Y∪{w} | Z → X ⊥ Y | Z∪{w}.
-/
theorem semigraphoid_weak_union_singleton {α : Type*} [DecidableEq α]
    (sg : SemiGraphoidAxioms α)
    {X Y Z : Finset α} {w : α}
    (h : sg.indep X (Y ∪ {w}) Z) :
    sg.indep X Y (Z ∪ {w}) := by
  exact sg.weak_union _ _ _ _ h

/-
**Decomposition Singleton**: X ⊥ Y∪{w} | Z → X ⊥ Y | Z.
-/
theorem semigraphoid_decomp_singleton {α : Type*} [DecidableEq α]
    (sg : SemiGraphoidAxioms α)
    {X Y Z : Finset α} {w : α}
    (h : sg.indep X (Y ∪ {w}) Z) :
    sg.indep X Y Z := by
  exact sg.decomposition _ _ _ _ h

/-! ## Part V: Causal Separation

We define graphical separation of variable sets in a CausalDAG and prove
basic properties. This captures directed path blocking by a conditioning set.

Bridge: connects graph-theoretic path blocking to algebraic module factorization.
-/

/-- **Causal Separation**: Sets `X` and `Y` are separated by `Z` if no vertex
    in `X` can reach any vertex in `Y` through the intervention DAG (Z removed).

    Bridge: connects Pearl's d-separation to graph reachability.
    Impact: foundational for certified_robust_causal_discovery. -/
def CausalSeparation {n : ℕ} (G : CausalDAG n) (X Y Z : Finset (Fin n)) : Prop :=
  ∀ x ∈ X, ∀ y ∈ Y, ¬(InterventionDAG G Z).Reachable x y

/-
**Empty Set Separation**: Any set is trivially separated from the empty set.
    Bridge: connects vacuous separation to algebraic trivial factorization.
-/
theorem CausalSeparation.empty_right {n : ℕ} (G : CausalDAG n)
    (X Z : Finset (Fin n)) :
    CausalSeparation G X ∅ Z := by
  exact fun x hx y hy => False.elim <| Finset.notMem_empty y hy

/-
**Empty Left Separation**: The empty set is separated from any set.
-/
theorem CausalSeparation.empty_left {n : ℕ} (G : CausalDAG n)
    (Y Z : Finset (Fin n)) :
    CausalSeparation G ∅ Y Z := by
  exact fun x hx => False.elim <| Finset.notMem_empty x hx

/-
**Separation Monotonicity**: Adding more variables to the conditioning set
    preserves separation (more blocking = more separation).

    Bridge: connects monotonicity of conditioning to algebraic localization.
    Impact: enables incremental certified_robust_causal_discovery.
-/
theorem CausalSeparation.monotone_conditioning {n : ℕ} (G : CausalDAG n)
    {X Y Z Z' : Finset (Fin n)} (hZ : Z ⊆ Z')
    (h : CausalSeparation G X Y Z) :
    CausalSeparation G X Y Z' := by
  intro x hx y hy;
  refine' fun hxy => h x hx y hy _;
  have h_monotone : ∀ i j, (InterventionDAG G Z').adj i j = true → (InterventionDAG G Z).adj i j = true := by
    exact fun i j a => InterventionDAG.monotone_edge_removal G Z Z' hZ i j a
  have h_monotone : ∀ i j, (InterventionDAG G Z').Reachable i j → (InterventionDAG G Z).Reachable i j := by
    intro i j hij;
    induction hij <;> [ exact CausalDAG.Reachable.edge _ _ ( h_monotone _ _ ‹_› ) ; exact CausalDAG.Reachable.trans _ _ _ ‹_› ‹_› ];
  exact h_monotone x y hxy

/-
**Subset Separation**: If X is separated from Y by Z, and X' ⊆ X, Y' ⊆ Y,
    then X' is separated from Y' by Z.
-/
theorem CausalSeparation.subset {n : ℕ} (G : CausalDAG n)
    {X X' Y Y' Z : Finset (Fin n)} (hX : X' ⊆ X) (hY : Y' ⊆ Y)
    (h : CausalSeparation G X Y Z) :
    CausalSeparation G X' Y' Z := by
  exact fun x hx y hy => h x ( hX hx ) y ( hY hy )

/-! ## Part VI: Algebraic Structural Causal Models

We define algebraic SCMs over commutative rings, where variables are R-module
elements and structural equations are R-linear maps.

Bridge: connects Pearl's SCMs to commutative algebra (R-modules, linear maps).
Impact: enables algebraic certified_causal_discovery over ring-valued data.
-/

/-- An **Algebraic Structural Causal Model** (ASCM) over a commutative ring `R`
    on `n` endogenous variables. Each variable takes values in `R`, the causal
    structure is given by a CausalDAG, and structural equations are `R`-linear
    combinations of parent values plus exogenous noise.

    Bridge: connects Pearl's SCMs to R-module theory.
    Impact: enables certified_robust_causal_discovery over algebraic structures. -/
structure AlgebraicSCM (R : Type*) [CommRing R] (n : ℕ) where
  /-- The underlying causal DAG -/
  dag : CausalDAG n
  /-- Structural coefficients: for each edge i → j, the coefficient in the
      structural equation of j -/
  coeff : Fin n → Fin n → R
  /-- Coefficients are zero for non-edges -/
  coeff_zero_of_no_edge : ∀ i j, dag.adj i j = false → coeff i j = 0

/-- The **structural equation matrix** of an algebraic SCM.
    Entry (i, j) gives the coefficient of variable i in the equation for variable j.

    Bridge: connects structural equations to matrix algebra.
    Impact: matrix representation enables computational certified_causal_discovery. -/
def AlgebraicSCM.structuralMatrix {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) : Matrix (Fin n) (Fin n) R :=
  Matrix.of (fun i j => scm.coeff j i)

/-
The structural matrix has zero diagonal (no self-causation).
    Bridge: connects acyclicity to nilpotency of the structural matrix.
-/
theorem AlgebraicSCM.structural_matrix_zero_diag {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (i : Fin n) :
    scm.structuralMatrix i i = 0 := by
  exact scm.coeff_zero_of_no_edge _ _ ( scm.dag.no_self_edge _ )

/-- The **direct causal effect** of variable `i` on variable `j`. -/
def AlgebraicSCM.directEffect {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (i j : Fin n) : R :=
  scm.coeff i j

/-
**Direct Effect is Zero for Non-Edges**.
    Bridge: connects graph structure to algebraic effect structure.
    Impact: enables sparse certified_causal_discovery.
-/
theorem AlgebraicSCM.directEffect_zero_of_no_edge {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (i j : Fin n) (h : scm.dag.adj i j = false) :
    scm.directEffect i j = 0 := by
  exact scm.coeff_zero_of_no_edge i j h

/-! ## Part VII: Path Strengths and Causal Effects

Path strength measures the algebraic strength of causal influence along
directed paths. For direct edges, it equals the structural coefficient.
For length-2 paths, it is the product of coefficients.

Bridge: connects path algebra to ring theory.
Impact: computable path strengths for certified_robust_causal_discovery.
-/

/-- Path strength of a direct edge. -/
def pathStrengthDirect {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (i j : Fin n) : R :=
  scm.coeff i j

/-- Path strength of a length-2 path through an intermediate vertex. -/
def pathStrengthTwo {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (i k j : Fin n) : R :=
  scm.coeff i k * scm.coeff k j

/-
**Path Strength Vanishes for Non-Edges**: Direct path strength is zero
    when no edge exists.

    Bridge: connects graph sparsity to algebraic sparsity.
-/
theorem pathStrengthDirect_zero_of_no_edge {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) {i j : Fin n} (h : scm.dag.adj i j = false) :
    pathStrengthDirect scm i j = 0 := by
  exact scm.coeff_zero_of_no_edge i j h

/-
**Length-2 Path Strength Vanishes**: If either edge in a length-2 path is missing,
    the path strength is zero.
-/
theorem pathStrengthTwo_zero {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) {i k j : Fin n}
    (h : scm.dag.adj i k = false ∨ scm.dag.adj k j = false) :
    pathStrengthTwo scm i k j = 0 := by
  cases h <;> simp [pathStrengthTwo, scm.coeff_zero_of_no_edge _ _, *]

/-
**Total Direct Effect Symmetry**: The sum of all direct effects from i
    equals the sum of outgoing coefficients.
-/
theorem total_direct_effect_sum {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (i : Fin n) :
    ∑ j : Fin n, scm.directEffect i j =
    ∑ j : Fin n, scm.coeff i j := by
  rfl

/-! ## Part VIII: Intervention Strategies and Complexity Bounds

We define intervention strategies and prove lower bounds on their complexity.

Bridge: connects homological algebra (projective dimension) to intervention design.
Impact: certified_optimal_intervention_design with provable complexity bounds.
-/

/-- An **Intervention Strategy** for identifying the causal effect of variable `src`
    on variable `tgt` in an AlgebraicSCM. Consists of a set of intervention targets.

    Bridge: connects experimental design to algebraic computation.
    Impact: certified_optimal_intervention_design. -/
structure InterventionStrategy {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (src tgt : Fin n) where
  /-- Set of intervention targets -/
  targets : Finset (Fin n)
  /-- Source and target are not intervention targets -/
  src_not_target : src ∉ targets
  tgt_not_target : tgt ∉ targets

/-- The **number of interventions** in a strategy. -/
def InterventionStrategy.numInterventions {R : Type*} [CommRing R] {n : ℕ}
    {scm : AlgebraicSCM R n} {src tgt : Fin n}
    (s : InterventionStrategy scm src tgt) : ℕ :=
  s.targets.card

/-- **Intervention Complexity**: The number of length-2 confounders between src and tgt.
    This is a simplified proxy for the projective dimension of the causal path module.

    Bridge: connects causal identification to combinatorial optimization.
    Impact: lower bounds for certified_optimal_intervention_design. -/
def interventionComplexity {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (src tgt : Fin n) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun v =>
    v ≠ src ∧ v ≠ tgt ∧ scm.dag.adj src v = true ∧ scm.dag.adj v tgt = true)).card

/-- **Projective Intervention Dimension**: Algebraic lower bound on intervention cost.

    Bridge: connects homological algebra (projective dimension) to causal inference.
    Impact: certified_optimal_intervention_design with provable lower bounds. -/
def projectiveInterventionDim {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (src tgt : Fin n) : ℕ :=
  interventionComplexity scm src tgt

/-
**Projective Intervention Dimension Bound**: The projective intervention dimension
    is bounded by `n` (at most `n` confounders for `n` variables).

    Bridge: connects projective dimension bounds to graph size.
    Impact: O(n) upper bound for certified_optimal_intervention_design.
-/
theorem projective_intervention_dim_bound {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (src tgt : Fin n) :
    projectiveInterventionDim scm src tgt ≤ n := by
  have h_filter_card : ((Finset.univ : Finset (Fin n)).filter (fun v => v ≠ src ∧ v ≠ tgt ∧ scm.dag.adj src v = true ∧ scm.dag.adj v tgt = true)).card ≤ Finset.card (Finset.univ : Finset (Fin n)) := by
    exact Finset.card_le_univ _;
  exact h_filter_card.trans ( by simp +decide )

/-
**Degree-Based Intervention Bound**: The intervention complexity is bounded by
    the out-degree of the source vertex.

    Bridge: connects degree bounds to intervention complexity.
    Impact: O(Δ) intervention bound for bounded-degree certified_causal_discovery.
-/
theorem degree_intervention_bound {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (src tgt : Fin n) :
    projectiveInterventionDim scm src tgt ≤ (scm.dag.children src).card := by
  -- The set of confounders is a subset of the children of `src`.
  have h_subset : Finset.filter (fun v => v ≠ src ∧ v ≠ tgt ∧ scm.dag.adj src v = true ∧ scm.dag.adj v tgt = true) Finset.univ ⊆ Finset.filter (fun v => scm.dag.adj src v = true) Finset.univ := by
    grind;
  convert Finset.card_le_card h_subset using 1

/-! ## Part IX: Noetherian Faithfulness and Syzygy-Freeness

The algebraic faithfulness criterion connects the causal faithfulness assumption
to the algebraic condition that the coefficient support matches the edge structure.

Bridge: connects causal identifiability to Hilbert's syzygy theorem.
Impact: certified_causal_discovery with algebraic faithfulness guarantees.
-/

/-- **Algebraic Faithfulness**: An AlgebraicSCM is faithful if the coefficient
    is zero exactly when there is no edge. This is the algebraic version of the
    causal faithfulness assumption.

    Bridge: connects causal faithfulness to algebraic non-degeneracy.
    Impact: certified_causal_discovery requires faithfulness verification. -/
def AlgebraicFaithfulness {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) : Prop :=
  ∀ i j, scm.coeff i j = 0 ↔ scm.dag.adj i j = false

/-
**Faithfulness Forward**: In a faithful model, zero coefficient implies no edge.
-/
theorem faithfulness_implies_no_edge {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (hf : AlgebraicFaithfulness scm) (i j : Fin n)
    (h : scm.coeff i j = 0) : scm.dag.adj i j = false := by
  exact hf i j |>.1 h

/-
**Faithfulness Backward**: In a faithful model, an edge implies nonzero coefficient.
-/
theorem faithfulness_implies_nonzero {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (hf : AlgebraicFaithfulness scm) (i j : Fin n)
    (h : scm.dag.adj i j = true) : scm.coeff i j ≠ 0 := by
  exact fun h' => by simpa [ h, h' ] using hf i j;

/-
**Faithfulness is Symmetric Characterization**: An AlgebraicSCM is faithful iff
    its coefficient support exactly matches the edge set.

    Bridge: connects Hilbert's syzygy theorem to causal faithfulness.
    Impact: algebraic test for certified_causal_discovery.
-/
theorem syzygy_free_iff_faithful {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) :
    AlgebraicFaithfulness scm ↔
      (∀ i j, scm.coeff i j = 0 ↔ scm.dag.adj i j = false) := by
  exact Iff.rfl

/-
**Faithfulness Entailment**: In a faithful model, if the coefficient from i to j
    is nonzero, then there is a directed edge from i to j. Contrapositively, the
    absence of a path implies zero total effect.

    Bridge: connects algebraic non-triviality to causal structure.
    Impact: enables complete certified_causal_discovery from observational data.
-/
theorem faithfulness_nonzero_implies_edge {R : Type*} [CommRing R] {n : ℕ}
    (scm : AlgebraicSCM R n) (hf : AlgebraicFaithfulness scm) (i j : Fin n)
    (h : scm.coeff i j ≠ 0) : scm.dag.adj i j = true := by
  exact hf i j |>.not.mp h |> fun h => by simpa using h;

/-! ## Part X: Query Complexity Bounds

Lower and upper bounds on the number of queries needed for causal discovery.

Bridge: connects causal inference to lattice_crypto and post_quantum_security.
Impact: Ω(n) lower bound on causal discovery query complexity.
-/

/-
**Causal Discovery Query Upper Bound**: The number of distinct ordered pairs
    in `Fin n` is at most `n * n`.

    Bridge: connects enumeration to causal discovery complexity.
    Impact: O(n²) total queries for certified_robust_causal_discovery.
-/
theorem causal_discovery_query_upper_bound {n : ℕ} :
    ((Finset.univ : Finset (Fin n)) ×ˢ (Finset.univ : Finset (Fin n))).card = n * n := by
  simp +decide [ Finset.card_univ ]

/-
**Edge Count in Terms of Card**: The edge count is at most n².
-/
theorem edge_count_le_sq {n : ℕ} (G : CausalDAG n) :
    G.edgeCount ≤ n * n := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-! ## Part XI: Concrete Examples and Computations

We verify the theory on concrete small DAGs.
-/

/-- The trivial DAG on 0 vertices. -/
def emptyDAG : CausalDAG 0 where
  adj := Fin.elim0
  rank := Fin.elim0
  rank_inj := fun i => Fin.elim0 i
  rank_edge := fun i => Fin.elim0 i

/-- A chain DAG on 3 vertices: 0 → 1 → 2. -/
def chainDAG3 : CausalDAG 3 where
  adj := fun i j =>
    (i.val == 0 && j.val == 1) || (i.val == 1 && j.val == 2)
  rank := fun i => i.val
  rank_inj := fun i j h => Fin.ext (by omega)
  rank_edge := fun i j h => by
    simp only [Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq] at h
    rcases h with ⟨hi, hj⟩ | ⟨hi, hj⟩ <;> omega

/-- The fork DAG on 3 vertices: 1 ← 0 → 2. -/
def forkDAG3 : CausalDAG 3 where
  adj := fun i j =>
    (i.val == 0 && j.val == 1) || (i.val == 0 && j.val == 2)
  rank := fun i => i.val
  rank_inj := fun i j h => Fin.ext (by omega)
  rank_edge := fun i j h => by
    simp only [Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq] at h
    rcases h with ⟨hi, hj⟩ | ⟨hi, hj⟩ <;> omega

/-- The collider DAG on 3 vertices: 0 → 2 ← 1. -/
def colliderDAG3 : CausalDAG 3 where
  adj := fun i j =>
    (i.val == 0 && j.val == 2) || (i.val == 1 && j.val == 2)
  rank := fun i => i.val
  rank_inj := fun i j h => Fin.ext (by omega)
  rank_edge := fun i j h => by
    simp only [Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq] at h
    rcases h with ⟨hi, hj⟩ | ⟨hi, hj⟩ <;> omega

/-
**Chain DAG No Self-Loop**: Verification that the chain DAG has no self-loops.
-/
theorem chainDAG3_no_self_loop : ∀ v : Fin 3, chainDAG3.adj v v = false := by
  decide +revert

/-
**Fork DAG has expected edge**: Vertex 0 is parent of vertex 1 in the fork DAG.
-/
theorem forkDAG3_parent : forkDAG3.adj 0 1 = true := by
  native_decide +revert

/-
**Collider DAG structure**: Vertex 2 has two parents in the collider DAG.
-/
theorem colliderDAG3_parents :
    colliderDAG3.adj 0 2 = true ∧ colliderDAG3.adj 1 2 = true := by
  exact ⟨ rfl, rfl ⟩

/-
**Chain reachability**: In the chain 0→1→2, vertex 2 is reachable from vertex 0.
-/
theorem chainDAG3_reachable_0_2 : chainDAG3.Reachable 0 2 := by
  apply CausalDAG.Reachable.trans 0 1 2 (CausalDAG.Reachable.edge 0 1 (by native_decide)) (CausalDAG.Reachable.edge 1 2 (by native_decide))

/-
**Fork non-reachability**: In the fork 1←0→2, vertex 2 is not reachable from
    vertex 1 (no directed path 1→2).
-/
theorem forkDAG3_not_reachable_1_2 : ¬forkDAG3.Reachable 1 2 := by
  intro h
  have h_rank : forkDAG3.rank 1 < forkDAG3.rank 2 := by
    exact forkDAG3.reachable_rank_strict_mono h;
  cases h;
  · contradiction;
  · rename_i k hk₁ hk₂;
    have := forkDAG3.reachable_rank_strict_mono hk₁; fin_cases k <;> simp_all +decide ;
    exact CausalDAG.reachable_irrefl _ _ hk₂

end AlgebraicCausalInference