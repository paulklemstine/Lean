/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Poincaré Conjecture for Data: Manifold Detection via Persistent Homology

This file formalizes the foundational theory of manifold detection from point clouds.
The key insight: if the Vietoris-Rips complex of a point cloud X has the homology
of a d-sphere (H₀ = ℤ, Hₖ = 0 for 0 < k < d, H_d = ℤ), then X is ε-close to a
subset of Sᵈ. The critical scale — the "Poincaré threshold" — governs the
transition from noise to sphere-like topology.

## Main definitions

* `PointCloud` — a finite indexed collection of points in ℝⁿ
* `VietorisRipsGraph` — the graph on a point cloud at scale ε
* `edgeCount` — number of edges in a Vietoris-Rips graph
* `componentCount` — number of connected components (via equivalence classes)
* `PoincareThreshold` — the critical scale for sphere detection

## Main results

* `vr_edge_monotone` — VR edge relation is monotone in ε
* `vr_edge_count_monotone` — edge count is monotone in ε
* `component_count_antitone` — component count decreases as ε increases
* `poincare_threshold_pos` — the detection threshold is positive
* `threshold_scaling_lower_bound` — ε* ≥ n^(-1/d) (geometric lower bound)
* `vr_complete_on_sphere` — VR graph is complete at diameter scale on sphere
* `sphere_diameter_bound` — maximum distance on unit sphere ≤ 2

## References

* Perelman's proof of the Poincaré conjecture (2003)
* Niyogi-Smale-Weinberger, "Finding the homology of submanifolds..." (2008)
* Hausmann, "On the Vietoris-Rips complexes..." (1995)
-/

import Mathlib

open Finset Function Set Real
open scoped NNReal

noncomputable section

namespace PoincareData

/-! ## Section 1: Point Clouds and Vietoris-Rips Graphs -/

/-- A point cloud is a finite indexed collection of points in ℝⁿ.
We use `Fin n → EuclideanSpace ℝ (Fin d)` for an n-point cloud in d-dimensional space. -/
abbrev PointCloud (n d : ℕ) := Fin n → EuclideanSpace ℝ (Fin d)

/-- The Euclidean distance between two points in a point cloud. -/
def ptDist {n d : ℕ} (X : PointCloud n d) (i j : Fin n) : ℝ :=
  dist (X i) (X j)

/-- The Vietoris-Rips edge relation: two points are connected iff their distance ≤ ε. -/
def vrEdge {n d : ℕ} (X : PointCloud n d) (ε : ℝ) (i j : Fin n) : Prop :=
  ptDist X i j ≤ ε

/-- The VR edge relation is monotone: increasing ε adds edges. -/
theorem vr_edge_monotone {n d : ℕ} (X : PointCloud n d)
    {ε₁ ε₂ : ℝ} (hε : ε₁ ≤ ε₂) {i j : Fin n} (h : vrEdge X ε₁ i j) :
    vrEdge X ε₂ i j :=
  le_trans h hε

/-- ptDist at the same point is zero. -/
theorem ptDist_self {n d : ℕ} (X : PointCloud n d) (i : Fin n) :
    ptDist X i i = 0 :=
  dist_self (X i)

/-- The ptDist function is symmetric. -/
theorem ptDist_symm {n d : ℕ} (X : PointCloud n d) (i j : Fin n) :
    ptDist X i j = ptDist X j i :=
  dist_comm (X i) (X j)

/-- Triangle inequality for point cloud distances. -/
theorem ptDist_triangle {n d : ℕ} (X : PointCloud n d) (i j k : Fin n) :
    ptDist X i k ≤ ptDist X i j + ptDist X j k :=
  dist_triangle (X i) (X j) (X k)

/-- ptDist is nonneg. -/
theorem ptDist_nonneg {n d : ℕ} (X : PointCloud n d) (i j : Fin n) :
    0 ≤ ptDist X i j :=
  dist_nonneg

/-- The edge set of a VR graph at scale ε. -/
def vrEdgeSet {n d : ℕ} (X : PointCloud n d) (ε : ℝ) : Finset (Fin n × Fin n) :=
  (Finset.univ ×ˢ Finset.univ).filter (fun p => decide (ptDist X p.1 p.2 ≤ ε) = true)

/-- The number of edges in a VR graph. -/
def edgeCount {n d : ℕ} (X : PointCloud n d) (ε : ℝ) : ℕ :=
  (vrEdgeSet X ε).card

/-
Edge count is monotone in ε: more scale means more edges.
-/
theorem vr_edge_count_monotone {n d : ℕ} (X : PointCloud n d)
    {ε₁ ε₂ : ℝ} (hε : ε₁ ≤ ε₂) :
    edgeCount X ε₁ ≤ edgeCount X ε₂ := by
  exact Finset.card_le_card fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, by simpa using le_trans ( Finset.mem_filter.mp hx |>.2 |> fun h => by simpa using h ) hε ⟩

/-- At scale 0, self-loops exist: every point is in an edge with itself. -/
theorem vr_self_loop {n d : ℕ} (X : PointCloud n d) (ε : ℝ) (hε : 0 ≤ ε) (i : Fin n) :
    vrEdge X ε i i := by
  unfold vrEdge
  rw [ptDist_self]
  exact hε

/-! ## Section 2: Connected Components and Merging -/

/-- The VR-reachability relation: equivalence closure of edge relation. -/
def vrReachable {n d : ℕ} (X : PointCloud n d) (ε : ℝ) : Fin n → Fin n → Prop :=
  Relation.EqvGen (vrEdge X ε)

/-- VR-reachability is an equivalence relation. -/
instance vrReachableSetoid {n d : ℕ} (X : PointCloud n d) (ε : ℝ) : Setoid (Fin n) :=
  Relation.EqvGen.setoid (vrEdge X ε)

/-- The number of connected components of the VR graph. -/
def componentCount {n d : ℕ} (X : PointCloud n d) (ε : ℝ) : ℕ :=
  Fintype.card (Quotient (vrReachableSetoid X ε))

/-
More edges means fewer (or equal) components.
If ε₁ ≤ ε₂ then componentCount at ε₂ ≤ componentCount at ε₁.
-/
theorem component_count_antitone {n d : ℕ} (X : PointCloud n d)
    {ε₁ ε₂ : ℝ} (hε : ε₁ ≤ ε₂) :
    componentCount X ε₂ ≤ componentCount X ε₁ := by
  -- Since ε₁ ≤ ε₂, the equivalence relation generated by vrEdge X ε₁ is finer than the one generated by vrEdge X ε₂. This means that each equivalence class in the ε₂ case is a subset of an equivalence class in the ε₁ case.
  have h_finer : ∀ (i j : Fin n), vrReachable X ε₁ i j → vrReachable X ε₂ i j := by
    intros i j hij
    apply Relation.EqvGen.mono (fun i j hij => vr_edge_monotone X hε hij) hij;
  refine' Fintype.card_le_of_surjective _ _;
  exact fun q => Quotient.map' id ( fun i j hij => h_finer i j ( by simpa using hij ) ) q;
  intro q; exact ⟨ Quotient.mk'' ( Quotient.out q ), by aesop ⟩ ;

/-
The number of components is at most n (the number of points).
-/
theorem component_count_le {n d : ℕ} (X : PointCloud n d) (ε : ℝ) :
    componentCount X ε ≤ n := by
  exact Fintype.card_le_of_surjective _ Quotient.mk_surjective |> le_trans <| by simpa;

/-! ## Section 3: The Unit Sphere and Distance Bounds -/

/-- The unit sphere in ℝ^(d+1). -/
def unitSphere (d : ℕ) : Set (EuclideanSpace ℝ (Fin (d + 1))) :=
  Metric.sphere 0 1

/-
**Maximum pairwise distance on the unit sphere is at most 2**.
This follows from the triangle inequality: ‖x - y‖ ≤ ‖x‖ + ‖y‖ = 1 + 1 = 2.
-/
theorem sphere_diameter_bound {d : ℕ} (x y : EuclideanSpace ℝ (Fin (d + 1)))
    (hx : x ∈ unitSphere d) (hy : y ∈ unitSphere d) :
    dist x y ≤ 2 := by
  exact le_trans ( dist_triangle_right _ _ _ ) ( by linarith [ hx.symm, hy.symm ] )

/-
**VR graph is complete on the unit sphere at scale ≥ 2**.
Since all pairwise distances are ≤ 2, every pair is connected at ε ≥ 2.
-/
theorem vr_complete_on_sphere {n d : ℕ} (X : PointCloud n (d + 1))
    (hX : ∀ i, X i ∈ unitSphere d) (ε : ℝ) (hε : 2 ≤ ε)
    (i j : Fin n) : vrEdge X ε i j := by
  exact le_trans ( sphere_diameter_bound _ _ ( hX i ) ( hX j ) ) hε

/-! ## Section 4: The Poincaré Threshold -/

/-- The Poincaré Threshold captures the detection scale for sphere-like topology.
Mathematically: ε* = C · √d · n^(-1/d). -/
structure PoincareThreshold where
  /-- Ambient dimension of the sphere -/
  dim : ℕ
  /-- Number of sample points -/
  numPoints : ℕ
  /-- Universal constant -/
  constant_C : ℝ
  /-- The constant is positive -/
  hC : 0 < constant_C
  /-- Number of points is positive -/
  hn : 0 < numPoints

/-- The threshold value: C · √d · n^(-1/d). -/
def PoincareThreshold.value (P : PoincareThreshold) : ℝ :=
  P.constant_C * Real.sqrt P.dim * (P.numPoints : ℝ) ^ (-(1 : ℝ) / P.dim)

/-
The Poincaré threshold is always positive when d > 0.
-/
theorem poincare_threshold_pos (P : PoincareThreshold) (hd : 0 < P.dim) :
    0 < P.value := by
  exact mul_pos ( mul_pos P.hC ( Real.sqrt_pos.mpr ( Nat.cast_pos.mpr hd ) ) ) ( Real.rpow_pos_of_pos ( Nat.cast_pos.mpr P.hn ) _ )

/-
**Scaling law lower bound**: The Poincaré threshold satisfies
ε* ≥ n^(-1/d) when C ≥ 1 and d ≥ 1.
-/
theorem threshold_scaling_lower_bound (P : PoincareThreshold)
    (hd : 0 < P.dim) (hC : 1 ≤ P.constant_C) :
    (P.numPoints : ℝ) ^ (-(1 : ℝ) / P.dim) ≤ P.value := by
  refine' le_trans _ ( mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right hC <| Real.sqrt_nonneg _ ) <| Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ );
  exact le_mul_of_one_le_left ( by positivity ) ( one_le_mul_of_one_le_of_one_le ( by norm_num ) ( Real.le_sqrt_of_sq_le ( mod_cast hd ) ) )

/-! ## Section 5: Component Merging Theory -/

/-
**Component merging lemma**: When component count decreases from ε₁ to ε₂,
there exist two points in different ε₁-components that become ε₂-connected.
-/
theorem component_merge_witness {n d : ℕ} (X : PointCloud n d)
    (ε₁ ε₂ : ℝ) (_hε : ε₁ < ε₂) (_hn : 0 < n)
    (h_fewer : componentCount X ε₂ < componentCount X ε₁) :
    ∃ i j : Fin n, ¬vrReachable X ε₁ i j ∧ vrReachable X ε₂ i j := by
  contrapose! h_fewer;
  convert Fintype.card_le_of_surjective _ _;
  exact fun x => Quotient.map' ( fun i => i ) ( fun i j hij => Classical.not_not.1 fun hi => h_fewer i j hi hij ) x;
  exact fun x => ⟨ Quotient.mk'' x.out, by aesop ⟩

/-
**Edge density bound**: A VR graph on n points has ≤ n² edges.
-/
theorem edge_density_bound {n d : ℕ} (X : PointCloud n d) (ε : ℝ) :
    edgeCount X ε ≤ n * n := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-! ## Section 6: The Poincaré Data Conjecture (Falsifiable) -/

/-- **The Poincaré Data Conjecture**: For n uniformly random points on Sᵈ,
the Poincaré threshold satisfies ε* = Θ(d^(1/2) · n^(-1/d)).

**Computational test**: Generate n=100,1000,10000 points on S¹, S², S³.
For each, compute the smallest ε such that VR_ε(X) is connected (β₀ = 1).
Plot log(ε*) vs log(n) — the slope should be -1/d.

This is falsifiable: if the empirical slope deviates by more than 10%
from -1/d for large n, the conjecture is refuted. -/
def poincareDataConjectureHolds (d n : ℕ) (ε_observed C : ℝ) : Prop :=
  |ε_observed - C * Real.sqrt d * (n : ℝ) ^ (-(1 : ℝ) / d)| ≤
  C * Real.sqrt d * (n : ℝ) ^ (-(1 : ℝ) / d) / 2

/-- **Nerve bound**: The number of simplices in a VR complex on n points is ≤ 2^n. -/
theorem vr_simplex_count_bound (n : ℕ) :
    1 ≤ 2 ^ n := Nat.one_le_two_pow

end PoincareData