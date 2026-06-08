/-
# Boundary Determines Bulk: Rigidity of Tree-Like Metrics

This file proves that boundary distance data determines the full metric
in tree-like finite metric spaces. This is a discrete/tropical avatar of
the boundary rigidity problem from Riemannian geometry.

## Main Results

- `median_distance_formula_a`: The distance from a to the median m of
  (a, b, c) is (d(a,b) + d(a,c) - d(b,c)) / 2.

- `boundary_determines_interior_boundary_distances`: Boundary-boundary
  agreement implies vertex-boundary agreement via median witnesses.

- `boundary_determines_bulk_distance`: The main rigidity theorem —
  boundary distances determine all distances under tree hypotheses.

## Cross-Domain Connections

1. **Tropical geometry**: The map x ↦ (d(x,b))_{b∈B} is a tropical coordinate chart.
2. **Phylogenetics**: Boundary = leaves; distance-based tree reconstruction.
3. **Network tomography**: Boundary sensors determine hidden network geometry.
4. **Riemannian boundary rigidity**: Discrete avatar of Michel's conjecture.
-/
import Mathlib

namespace BoundaryRigidity

open Finset

/-! ## Core Definitions -/

/-- A finite metric is tree-like if it satisfies the four-point condition. -/
def IsTreeLikeMetric {V : Type} [Fintype V] (d : V → V → ℝ) : Prop :=
  (∀ x y, 0 ≤ d x y) ∧
  (∀ x y, d x y = d y x) ∧
  (∀ x, d x x = 0) ∧
  (∀ w x y z,
    d w x + d y z ≤ max (d w y + d x z) (d w z + d x y))

/-- m is a median of a, b, c: lies on all three geodesics. -/
def IsMedian {V : Type} (d : V → V → ℝ) (m a b c : V) : Prop :=
  d a b = d a m + d m b ∧
  d a c = d a m + d m c ∧
  d b c = d b m + d m c

/-- x is boundary-visible: its boundary profile determines it uniquely. -/
def BoundaryVisible {V : Type} (B : Finset V) (d : V → V → ℝ) (x : V) : Prop :=
  ∀ y, (∀ b ∈ B, d x b = d y b) → x = y

/-- The boundary distance profile. -/
def BoundaryProfile {V : Type} (B : Finset V) (d : V → V → ℝ) (x : V) :
    {v // v ∈ B} → ℝ :=
  fun b => d x b.1

/-- The Gromov product: (d(x,a) + d(x,b) - d(a,b)) / 2. -/
noncomputable def gromovProduct {V : Type} (d : V → V → ℝ) (x a b : V) : ℝ :=
  (d x a + d x b - d a b) / 2

/-- In a tree, the boundary "reaches" everywhere: for any vertex x and any
direction (toward y), there is a boundary vertex s beyond x. Formally,
x lies on the geodesic from y to s: d(y,s) = d(y,x) + d(x,s). -/
def BoundaryReaches {V : Type} (B : Finset V) (d : V → V → ℝ) : Prop :=
  ∀ x y : V, ∃ s ∈ B, d y s = d y x + d x s

/-- Joint boundary reaches: for any x, y, there exists s ∈ B that is a
reach witness for both metrics simultaneously. This holds when the two
metrics share the same underlying tree combinatorics. -/
def JointBoundaryReaches {V : Type} (B : Finset V)
    (d₁ d₂ : V → V → ℝ) : Prop :=
  ∀ x y : V, ∃ s ∈ B,
    d₁ y s = d₁ y x + d₁ x s ∧ d₂ y s = d₂ y x + d₂ x s

/-! ## Branch-Point Distance Formulas -/

/-- d(a,m) = (d(a,b) + d(a,c) - d(b,c)) / 2 for m = median(a,b,c). -/
theorem median_distance_formula_a
    {V : Type} (d : V → V → ℝ) (m a b c : V)
    (hsym : ∀ u v, d u v = d v u)
    (hmed : IsMedian d m a b c) :
    d a m = (d a b + d a c - d b c) / 2 := by
  linarith [hmed.1, hmed.2.1, hmed.2.2, hsym a m, hsym b m, hsym c m]

/-- d(m,b) = (d(a,b) + d(b,c) - d(a,c)) / 2 for m = median(a,b,c). -/
theorem median_distance_formula_mb
    {V : Type} (d : V → V → ℝ) (m a b c : V)
    (hsym : ∀ u v, d u v = d v u)
    (hmed : IsMedian d m a b c) :
    d m b = (d a b + d b c - d a c) / 2 := by
  linarith [hmed.1, hmed.2.1, hmed.2.2, hsym a m, hsym b m, hsym c m]

/-- d(m,c) = (d(a,c) + d(b,c) - d(a,b)) / 2 for m = median(a,b,c). -/
theorem median_distance_formula_mc
    {V : Type} (d : V → V → ℝ) (m a b c : V)
    (hsym : ∀ u v, d u v = d v u)
    (hmed : IsMedian d m a b c) :
    d m c = (d a c + d b c - d a b) / 2 := by
  linarith [hmed.1, hmed.2.1, hmed.2.2, hsym a b, hsym a c, hsym b c,
            hsym m a, hsym m b, hsym m c]

/-! ## Boundary Profile Injectivity -/

/-- BoundaryVisible implies the boundary profile map is injective. -/
theorem boundary_profile_injective
    {V : Type} [Fintype V] [DecidableEq V]
    (B : Finset V) (d : V → V → ℝ)
    (hvis : ∀ x : V, BoundaryVisible B d x) :
    Function.Injective (BoundaryProfile B d) := by
  intro x y hxy
  exact hvis x y fun b hb => congr_fun hxy ⟨b, hb⟩

/-! ## Boundary Agreement on Branch-Point Depths -/

/-
If two metrics agree on B×B and x = median(s,a,b) in both,
then d₁(s,x) = d₂(s,x). By the median formula, d(s,x) only
involves boundary-boundary distances.
-/
theorem boundary_agrees_implies_depth_to_median_vertex
    {V : Type} [Fintype V] [DecidableEq V]
    (B : Finset V) (d₁ d₂ : V → V → ℝ)
    (hsym₁ : ∀ u v, d₁ u v = d₁ v u)
    (hsym₂ : ∀ u v, d₂ u v = d₂ v u)
    (x s a b : V)
    (hs : s ∈ B) (ha : a ∈ B) (hb : b ∈ B)
    (hmed₁ : IsMedian d₁ x s a b)
    (hmed₂ : IsMedian d₂ x s a b)
    (hbdry : ∀ u ∈ B, ∀ v ∈ B, d₁ u v = d₂ u v) :
    d₁ s x = d₂ s x := by
  convert median_distance_formula_a d₁ x s a b hsym₁ hmed₁ using 1;
  convert ( median_distance_formula_a d₂ x s a b hsym₂ hmed₂ ) using 1;
  rw [ hbdry s hs a ha, hbdry s hs b hb, hbdry a ha b hb ]

/-! ## Step 1: Boundary determines interior-boundary distances -/

/-
If for every vertex x and boundary point s, there exist a, b ∈ B
with x = median(s,a,b) in both metrics, and the metrics agree on B×B,
then they agree on all vertex-boundary distances.
-/
theorem boundary_determines_interior_boundary_distances
    {V : Type} [Fintype V] [DecidableEq V]
    (B : Finset V) (d₁ d₂ : V → V → ℝ)
    (hsym₁ : ∀ x y, d₁ x y = d₁ y x)
    (hsym₂ : ∀ x y, d₂ x y = d₂ y x)
    (hbdry : ∀ u ∈ B, ∀ v ∈ B, d₁ u v = d₂ u v)
    (hwitness : ∀ x : V, ∀ s ∈ B, ∃ a b : V, a ∈ B ∧ b ∈ B ∧
      IsMedian d₁ x s a b ∧ IsMedian d₂ x s a b) :
    ∀ x : V, ∀ s ∈ B, d₁ x s = d₂ x s := by
  intro x s hs;
  obtain ⟨ a, b, ha, hb, h₁, h₂ ⟩ := hwitness x s hs;
  linarith [ hbdry s hs a ha, boundary_agrees_implies_depth_to_median_vertex B d₁ d₂ hsym₁ hsym₂ x s a b hs ha hb h₁ h₂ hbdry, hsym₁ x s, hsym₂ x s ]

/-! ## Step 2: Interior-boundary distances + boundary reaches → all distances -/

/-
If two metrics agree on vertex-boundary distances and the boundary
reaches all directions in both metrics, then d₁(x,y) = d₂(x,y) for
all x, y. Key idea: d(y,s) = d(y,x) + d(x,s) implies
d(y,x) = d(y,s) - d(x,s), determined by boundary distances.
-/
theorem interior_boundary_and_reaches_implies_bulk
    {V : Type} [Fintype V] [DecidableEq V]
    (B : Finset V) (d₁ d₂ : V → V → ℝ)
    (hsym₁ : ∀ x y, d₁ x y = d₁ y x)
    (hsym₂ : ∀ x y, d₂ x y = d₂ y x)
    (hint : ∀ x : V, ∀ s ∈ B, d₁ x s = d₂ x s)
    (hreach : JointBoundaryReaches B d₁ d₂) :
    ∀ x y : V, d₁ x y = d₂ x y := by
  intros x y
  obtain ⟨s, hsB, h1, h2⟩ := hreach x y;
  grind

/-! ## Main Theorem -/

/-
**Main Theorem: Boundary determines bulk distances.**

Given two symmetric metrics d₁, d₂ on a finite set V with boundary B:
- Both satisfy the boundary-reaches condition (every branch has a boundary vertex)
- For every vertex x and boundary point s, there exist a, b ∈ B with
  x = median(s,a,b) in both metrics
- d₁ and d₂ agree on B × B

Then d₁ = d₂ everywhere. This is a discrete tropical boundary rigidity theorem.
-/
theorem boundary_determines_bulk_distance
    {V : Type} [Fintype V] [DecidableEq V]
    (B : Finset V)
    (d₁ d₂ : V → V → ℝ)
    (hsym₁ : ∀ x y, d₁ x y = d₁ y x)
    (hsym₂ : ∀ x y, d₂ x y = d₂ y x)
    (hreach : JointBoundaryReaches B d₁ d₂)
    (hbdry : ∀ a ∈ B, ∀ b ∈ B, d₁ a b = d₂ a b)
    (hwitness : ∀ x : V, ∀ s ∈ B, ∃ a b : V, a ∈ B ∧ b ∈ B ∧
      IsMedian d₁ x s a b ∧ IsMedian d₂ x s a b) :
    ∀ x y : V, d₁ x y = d₂ x y := by
  exact interior_boundary_and_reaches_implies_bulk _ _ _ hsym₁ hsym₂
    (boundary_determines_interior_boundary_distances _ _ _ hsym₁ hsym₂ hbdry hwitness) hreach

/-! ## Tropical Reconstruction Identities -/

/-- d(x,y) = d(x,a) + d(y,a) - 2 * gromovProduct d a x y (tautological). -/
theorem distance_via_gromov
    {V : Type} (d : V → V → ℝ) (x y a : V)
    (hsym : ∀ u v, d u v = d v u) :
    d x y = d x a + d y a - 2 * gromovProduct d a x y := by
  unfold gromovProduct; linarith [hsym x y, hsym x a, hsym y a]

/-- Gromov product is nonneg for tree-like metrics. -/
theorem gromov_product_nonneg
    {V : Type} [Fintype V] (d : V → V → ℝ) (x a b : V)
    (htree : IsTreeLikeMetric d) :
    0 ≤ gromovProduct d x a b := by
  unfold IsTreeLikeMetric gromovProduct at *; grind

/-- Four-point condition ↔ Gromov product min-plus inequality (0-hyperbolicity). -/
theorem gromov_product_min_inequality
    {V : Type} [Fintype V] (d : V → V → ℝ) (x a b c : V)
    (htree : IsTreeLikeMetric d) :
    gromovProduct d x a b ≥
      min (gromovProduct d x a c) (gromovProduct d x b c) := by
  unfold gromovProduct
  obtain ⟨h₁, h₂, h₃, h₄⟩ := htree
  grind

end BoundaryRigidity