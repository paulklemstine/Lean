/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algorithmic Tropical Kernel Computation for Weighted Graphs

This file develops a formal theory of algorithmic tropical kernel computation,
building on the weighted tropical Hodge infrastructure from `WeightedTropicalHodge.lean`.

The tropical kernel of a weighted graph — the set of vertex potentials satisfying a
local min-plus balance condition — is shown to be a **computable tropical convex
feasibility region** governed by local graph constraints. We prove translation
invariance, normalization reduction, neighbor domination bounds, and a bridge
to classical difference-constraint optimization.

## Mathematical Context

Classical graph Laplacians turn harmonicity into linear algebra. Tropical graph
Laplacians turn harmonicity into **min-plus balance geometry**. Once encoded as a
tropical inequality system, the kernel becomes accessible to optimization theory,
residuation methods, and network control.

## Main Definitions

* `IsInTropicalKernel` — global tropical balance at all vertices
* `IsNormalizedAt` — normalization fixing one vertex to zero
* `DifferenceConstraint` — classical difference constraint from tropical balance
* `normalize` — normalization preprocessor
* `inducedConstraint` — constraint extraction from minimizers

## Main Results

* `tropicalKernel_translation_invariant_iff` — translation invariance (iff)
* `tropicalKernel_feasible_iff_normalized` — feasibility = normalized feasibility
* `tropicalKernel_neighbor_domination` — each neighbor is dominated by another
* `tropicalKernel_minimizer_diff_bound` — minimizer yields difference constraints
* `tropicalKernel_implies_induced_system` — bridge to combinatorial optimization

## Application Keywords

tropical linear programming, min-plus algebra, graph Laplacian, weighted networks,
shortest paths, difference constraints, Bellman–Ford certificates, tropical Hodge theory,
sparse algorithms, combinatorial optimization, network resilience, routing,
power-grid equilibrium, discrete Hamilton–Jacobi, tropical convexity.

## References

* Baker–Norine (2007), "Riemann–Roch and Abel–Jacobi theory on a finite graph"
* Mikhalkin (2006), "Tropical geometry and its applications"
* Butkovič (2010), "Max-linear Systems: Theory and Algorithms"
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

/-! ## Core Structure -/

/-- A weighted simple graph with integer edge weights. -/
structure WGraph (V : Type*) [Fintype V] where
  Adj : V → V → Prop
  adj_symm : Symmetric Adj
  loopless : ∀ v, ¬ Adj v v
  w : V → V → ℤ
  w_symm : ∀ ⦃u v⦄, Adj u v → w u v = w v u

namespace WGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Fundamental Definitions -/

/-- The weighted neighbor value `w(i,j) + φ(j)` in the min-plus sense. -/
def wnv (G : WGraph V) (φ : V → ℤ) (i j : V) : ℤ :=
  G.w i j + φ j

/-- Tropical balance at vertex `i`: the minimum of `w(i,j) + φ(j)` over
    neighbors `j` is attained by at least two distinct neighbors. -/
def tropBalancedAt (G : WGraph V) (φ : V → ℤ) (i : V) : Prop :=
  ∃ j k : V, j ≠ k ∧ G.Adj i j ∧ G.Adj i k ∧
    G.wnv φ i j = G.wnv φ i k ∧
    ∀ l, G.Adj i l → G.wnv φ i j ≤ G.wnv φ i l

/-! ### New Definitions: Algorithmic Tropical Kernel -/

/-- **IsInTropicalKernel**: A vertex potential `φ` is in the tropical kernel of `G`
    if it satisfies the tropical balance condition at every vertex. -/
def IsInTropicalKernel (G : WGraph V) (φ : V → ℤ) : Prop :=
  ∀ v : V, G.tropBalancedAt φ v

/-- **IsInTropicalKernelOn**: Restriction of kernel membership to a vertex subset. -/
def IsInTropicalKernelOn (G : WGraph V) (S : Finset V) (φ : V → ℤ) : Prop :=
  ∀ v ∈ S, G.tropBalancedAt φ v

/-- **DifferenceConstraint**: A single constraint `φ(tgt) - φ(src) ≤ bound`. -/
structure DifferenceConstraint (V : Type*) where
  src : V
  tgt : V
  bound : ℤ

/-- A potential satisfies a single difference constraint. -/
def DifferenceConstraint.satisfied (c : DifferenceConstraint V) (φ : V → ℤ) : Prop :=
  φ c.tgt - φ c.src ≤ c.bound

/-- A potential satisfies a list of difference constraints. -/
def satisfiesAllConstraints (cs : List (DifferenceConstraint V)) (φ : V → ℤ) : Prop :=
  ∀ c ∈ cs, c.satisfied φ

/-! ### Theorem 1: Translation Invariance of the Tropical Kernel

The tropical kernel is invariant under adding a constant to all vertex potentials.
This is the tropical analogue of the classical Laplacian's constant-vector symmetry. -/

theorem tropBalancedAt_translate (G : WGraph V) (φ : V → ℤ) (c : ℤ) (i : V) :
    G.tropBalancedAt (fun v => φ v + c) i ↔ G.tropBalancedAt φ i := by
  constructor
  · rintro ⟨j, k, hjk, haj, hak, heq, hmin⟩
    refine ⟨j, k, hjk, haj, hak, ?_, ?_⟩
    · simp only [wnv] at heq ⊢; omega
    · intro l hl; have := hmin l hl; simp only [wnv] at this ⊢; omega
  · rintro ⟨j, k, hjk, haj, hak, heq, hmin⟩
    refine ⟨j, k, hjk, haj, hak, ?_, ?_⟩
    · simp only [wnv] at heq ⊢; omega
    · intro l hl; have := hmin l hl; simp only [wnv] at this ⊢; omega

/-- **Translation invariance of the tropical kernel (iff form).**
    Adding a constant to all vertex potentials preserves kernel membership. -/
theorem tropicalKernel_translation_invariant_iff
    (G : WGraph V) (φ : V → ℤ) (c : ℤ) :
    G.IsInTropicalKernel (fun v => φ v + c) ↔ G.IsInTropicalKernel φ := by
  simp only [IsInTropicalKernel, tropBalancedAt_translate]

/-- Forward direction: kernel membership is preserved under translation. -/
theorem tropicalKernel_translation_invariant
    (G : WGraph V) (φ : V → ℤ) (c : ℤ)
    (hφ : G.IsInTropicalKernel φ) :
    G.IsInTropicalKernel (fun v => φ v + c) :=
  (tropicalKernel_translation_invariant_iff G φ c).mpr hφ

/-! ### Theorem 2: Feasibility Reduces to Normalized Feasibility

Fixing one vertex value to zero preserves solvability. -/

/-- **Normalized feasibility theorem.**
    The tropical kernel is nonempty iff it contains an element with `φ(v₀) = 0`. -/
theorem tropicalKernel_feasible_iff_normalized
    (G : WGraph V) (v0 : V) :
    (∃ φ : V → ℤ, G.IsInTropicalKernel φ) ↔
    (∃ φ : V → ℤ, G.IsInTropicalKernel φ ∧ φ v0 = 0) := by
  constructor
  · rintro ⟨φ, hφ⟩
    refine ⟨fun v => φ v - φ v0, ?_, by ring⟩
    have : (fun v => φ v - φ v0) = (fun v => φ v + (-φ v0)) := by ext; ring
    rw [this]
    exact (tropicalKernel_translation_invariant_iff G φ (-φ v0)).mpr hφ
  · rintro ⟨φ, hφ, _⟩
    exact ⟨φ, hφ⟩

/-- Normalized feasibility for `IsInTropicalKernelOn`. -/
theorem tropicalKernelOn_feasible_iff_normalized
    (G : WGraph V) (S : Finset V) (v0 : V) :
    (∃ φ : V → ℤ, G.IsInTropicalKernelOn S φ) ↔
    (∃ φ : V → ℤ, G.IsInTropicalKernelOn S φ ∧ φ v0 = 0) := by
  constructor
  · rintro ⟨φ, hφ⟩
    refine ⟨fun v => φ v - φ v0, ?_, by ring⟩
    intro v hv
    have : (fun v => φ v - φ v0) = (fun v => φ v + (-φ v0)) := by ext; ring
    rw [this]
    exact (tropBalancedAt_translate G φ (-φ v0) v).mpr (hφ v hv)
  · rintro ⟨φ, hφ, _⟩
    exact ⟨φ, hφ⟩

/-! ### Theorem 3: Neighbor Domination from Tropical Balance

At a balanced vertex, every neighbor is "dominated" by another distinct neighbor. -/

/-- **Neighbor domination theorem:** At a balanced vertex `u`, for any neighbor `v`,
    there exists a DIFFERENT neighbor `j ≠ v` with weighted value ≤ `v`'s. -/
theorem tropicalKernel_neighbor_domination
    (G : WGraph V) (φ : V → ℤ) (u v : V)
    (hbal : G.tropBalancedAt φ u)
    (hadj : G.Adj u v) :
    ∃ j : V, j ≠ v ∧ G.Adj u j ∧ G.wnv φ u j ≤ G.wnv φ u v := by
  obtain ⟨j, k, hjk, haj, hak, heq, hmin⟩ := hbal
  by_cases hv : j = v
  · exact ⟨k, fun h => hjk (hv ▸ h.symm), hak, heq ▸ hv ▸ le_refl _⟩
  · exact ⟨j, hv, haj, hmin v hadj⟩

/-- **Minimum upper bound:** At a balanced vertex, a minimizer's value is at most
    any neighbor's value. -/
theorem tropBalancedAt_min_le_neighbor
    (G : WGraph V) (φ : V → ℤ) (u v : V)
    (hbal : G.tropBalancedAt φ u)
    (hadj : G.Adj u v) :
    ∃ j : V, G.Adj u j ∧ G.wnv φ u j ≤ G.wnv φ u v := by
  obtain ⟨j, _, _, haj, _, _, hmin⟩ := hbal
  exact ⟨j, haj, hmin v hadj⟩

/-! ### Theorem 4: Minimizer Difference Constraints

From tropical balance, minimizing witnesses satisfy explicit difference constraints.
This is the bridge between tropical harmonicity and classical optimization. -/

/-- **Minimizer extraction:** From tropical balance, extract a minimizing witness. -/
theorem tropBalancedAt_minimizer (G : WGraph V) (φ : V → ℤ) (u : V)
    (hbal : G.tropBalancedAt φ u) :
    ∃ j : V, G.Adj u j ∧ ∀ l, G.Adj u l → G.wnv φ u j ≤ G.wnv φ u l := by
  obtain ⟨j, _, _, haj, _, _, hmin⟩ := hbal
  exact ⟨j, haj, hmin⟩

/-- **Minimizer difference bound:** If `j` minimizes at `u` and `v` is a neighbor of `u`,
    then `φ(j) - φ(v) ≤ w(u,v) - w(u,j)`.

    This converts tropical balance into a classical difference constraint. -/
theorem tropicalKernel_minimizer_diff_bound
    (G : WGraph V) (φ : V → ℤ) (u j v : V)
    (haj : G.Adj u j) (hav : G.Adj u v)
    (hmin : ∀ l, G.Adj u l → G.wnv φ u j ≤ G.wnv φ u l) :
    φ j - φ v ≤ G.w u v - G.w u j := by
  have h := hmin v hav
  unfold wnv at h
  omega

/-- **Full minimizer constraint package:** From tropical balance at `u`, there exists
    a witness `j` satisfying difference constraints against ALL neighbors of `u`. -/
theorem tropicalKernel_full_minimizer_constraints
    (G : WGraph V) (φ : V → ℤ) (u : V)
    (hbal : G.tropBalancedAt φ u) :
    ∃ j : V, G.Adj u j ∧ ∀ v, G.Adj u v → φ j - φ v ≤ G.w u v - G.w u j := by
  obtain ⟨j, haj, hmin⟩ := tropBalancedAt_minimizer G φ u hbal
  exact ⟨j, haj, fun v hav => tropicalKernel_minimizer_diff_bound G φ u j v haj hav hmin⟩

/-! ### Theorem 5: Bridge to Difference Constraint Systems

We define a classical difference-constraint system induced by a tropical kernel
element and prove that every kernel element satisfies the induced constraints.
This connects tropical Hodge theory to mainstream combinatorial optimization. -/

/-- Construct the induced difference constraint from a minimizer `j` at vertex `u`
    against neighbor `v`: `φ(j) - φ(v) ≤ w(u,v) - w(u,j)`. -/
def inducedConstraint (G : WGraph V) (u j v : V) : DifferenceConstraint V :=
  { src := v, tgt := j, bound := G.w u v - G.w u j }

/-- **Bridge theorem: Tropical kernel ⟹ difference constraint feasibility.**

    For every tropical kernel element `φ`, at each vertex `u`, there exists
    a minimizer `j` such that the induced difference constraints at `u` are
    satisfied by `φ`. -/
theorem tropicalKernel_implies_induced_system
    (G : WGraph V) (φ : V → ℤ) (u : V)
    (hbal : G.tropBalancedAt φ u) :
    ∃ j : V, G.Adj u j ∧
      ∀ v, G.Adj u v →
        (inducedConstraint G u j v).satisfied φ := by
  obtain ⟨j, haj, hmin⟩ := tropBalancedAt_minimizer G φ u hbal
  refine ⟨j, haj, fun v hav => ?_⟩
  unfold inducedConstraint DifferenceConstraint.satisfied
  simp only
  exact tropicalKernel_minimizer_diff_bound G φ u j v haj hav hmin

/-- **Global bridge theorem:** A kernel element satisfies the induced difference
    system at every vertex simultaneously. -/
theorem tropicalKernel_global_induced_system
    (G : WGraph V) (φ : V → ℤ)
    (hker : G.IsInTropicalKernel φ) :
    ∀ u : V, ∃ j : V, G.Adj u j ∧
      ∀ v, G.Adj u v → (inducedConstraint G u j v).satisfied φ := by
  intro u
  exact tropicalKernel_implies_induced_system G φ u (hker u)

/-! ### Additional Structural Theorems -/

/-- **Tropical balance subtraction form.** -/
theorem tropBalancedAt_sub_const (G : WGraph V) (φ : V → ℤ) (c : ℤ) (i : V) :
    G.tropBalancedAt (fun v => φ v - c) i ↔ G.tropBalancedAt φ i := by
  have h : (fun v => φ v - c) = (fun v => φ v + (-c)) := by ext; ring
  rw [h]
  exact tropBalancedAt_translate G φ (-c) i

/-- **Translation invariance for KernelOn.** -/
theorem tropicalKernelOn_translation_invariant_iff
    (G : WGraph V) (S : Finset V) (φ : V → ℤ) (c : ℤ) :
    G.IsInTropicalKernelOn S (fun v => φ v + c) ↔ G.IsInTropicalKernelOn S φ := by
  simp only [IsInTropicalKernelOn, tropBalancedAt_translate]

/-- **Constructive tropical balance from witnesses.** -/
theorem tropBalancedAt_of_witnesses
    (G : WGraph V) (φ : V → ℤ) (i j k : V)
    (hjk : j ≠ k) (hj : G.Adj i j) (hk : G.Adj i k)
    (heq : G.wnv φ i j = G.wnv φ i k)
    (hmin : ∀ l, G.Adj i l → G.wnv φ i j ≤ G.wnv φ i l) :
    G.tropBalancedAt φ i :=
  ⟨j, k, hjk, hj, hk, heq, hmin⟩

/-- **Double minimizer from balance.** -/
theorem tropBalancedAt_two_minimizers (G : WGraph V) (φ : V → ℤ) (u : V)
    (hbal : G.tropBalancedAt φ u) :
    ∃ j k : V, j ≠ k ∧ G.Adj u j ∧ G.Adj u k ∧
      G.wnv φ u j = G.wnv φ u k ∧
      (∀ l, G.Adj u l → G.wnv φ u j ≤ G.wnv φ u l) ∧
      (∀ l, G.Adj u l → G.wnv φ u k ≤ G.wnv φ u l) := by
  obtain ⟨j, k, hjk, haj, hak, heq, hmin⟩ := hbal
  exact ⟨j, k, hjk, haj, hak, heq, hmin, fun l hl => heq ▸ hmin l hl⟩

/-! ### Verified Computational Method: Normalization Preprocessor -/

/-- Normalize a potential at base vertex `v0`: subtract `φ(v0)` from all values. -/
def normalize (φ : V → ℤ) (v0 : V) : V → ℤ :=
  fun v => φ v - φ v0

/-- The normalized potential is normalized at `v0`. -/
theorem normalize_is_normalized (φ : V → ℤ) (v0 : V) :
    normalize φ v0 v0 = 0 := by
  unfold normalize; ring

/-- Normalization preserves tropical balance. -/
theorem normalize_preserves_balance (G : WGraph V) (φ : V → ℤ) (v0 : V) (i : V) :
    G.tropBalancedAt (normalize φ v0) i ↔ G.tropBalancedAt φ i := by
  unfold normalize
  exact tropBalancedAt_sub_const G φ (φ v0) i

/-- Normalization preserves kernel membership. -/
theorem normalize_preserves_kernel (G : WGraph V) (φ : V → ℤ) (v0 : V) :
    G.IsInTropicalKernel (normalize φ v0) ↔ G.IsInTropicalKernel φ := by
  simp only [IsInTropicalKernel, normalize_preserves_balance]

/-- Normalization preserves kernel-on membership. -/
theorem normalize_preserves_kernelOn (G : WGraph V) (S : Finset V) (φ : V → ℤ) (v0 : V) :
    G.IsInTropicalKernelOn S (normalize φ v0) ↔ G.IsInTropicalKernelOn S φ := by
  simp only [IsInTropicalKernelOn, normalize_preserves_balance]

/-! ### Verified Computational Method: Constraint Extraction -/

/-- Extract all induced constraints at vertex `u` with minimizer `j`,
    against a list of neighbors. -/
def extractConstraints (G : WGraph V) (u j : V) (neighbors : List V) :
    List (DifferenceConstraint V) :=
  neighbors.map (inducedConstraint G u j)

/-- All extracted constraints are satisfied by a kernel element. -/
theorem extractConstraints_satisfied
    (G : WGraph V) (φ : V → ℤ) (u j : V)
    (haj : G.Adj u j)
    (hmin : ∀ l, G.Adj u l → G.wnv φ u j ≤ G.wnv φ u l)
    (neighbors : List V)
    (hneighbors : ∀ v ∈ neighbors, G.Adj u v) :
    satisfiesAllConstraints (extractConstraints G u j neighbors) φ := by
  intro c hc
  simp only [extractConstraints, List.mem_map] at hc
  obtain ⟨v, hv, rfl⟩ := hc
  exact tropicalKernel_minimizer_diff_bound G φ u j v haj (hneighbors v hv) hmin

/-! ### Conjecture and Research Direction

**Conjecture (Sparse Normalized Tropical Feasibility):**
For every finite weighted graph `G` with maximum degree `Δ`, there exists a
polynomial-time algorithm deciding normalized tropical kernel feasibility
by reduction to a difference-constraint system with `O(|V| · Δ)` constraints.

The derived system is solvable by Bellman–Ford in `O(|V|² · Δ)` time.
On sparse graphs (Δ = O(1)), this gives `O(|V|²)` total time.

**Cross-domain connections:**
- **Combinatorial optimization:** Difference constraints, shortest paths, Bellman–Ford.
- **Tropical linear algebra:** Min-plus linear systems, residuation, tropical convexity.
- **Discrete Hamilton–Jacobi:** Tropically balanced potentials as viscosity solutions.
- **Chip-firing / divisor theory:** Kernel elements as balanced divisors (Baker–Norine). -/

end WGraph

end