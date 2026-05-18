/-
# Hyperbolic Crafting: Tropical Shortest Paths on Scaled Coupled Geometries

This module formalizes the mathematics behind optimal portal network design
in dual-world systems with metric compression. The key insight is that a
deterministic scaling between two metric spaces (e.g., Overworld and Nether
at 1:8 ratio) induces a min-plus shortest-path problem whose optimal
infrastructure backbone is characterized by spanning tree optimality.

## Main results

* `lift_scaling_exact`: The L1 distance scales exactly by factor 8 under
  the lift map `(x,z) ↦ (8x, 8z)`.
* `nether_scaling_exact`: On the 8-lattice, Nether distance is exactly 1/8
  of Overworld distance.
* `nether_scaling_rounding_error_bound`: For arbitrary integer coordinates,
  the rounding error from integer division is bounded by 14.
* `nether_beats_overworld_beyond_threshold`: With portal cost `c`, Nether
  travel dominates beyond a threshold distance.
* `tropical_two_step_optimal`: Two-step route optimization equals min-plus
  matrix composition.
* `portal_network_mst_optimality`: MST minimizes total infrastructure cost
  among all spanning trees.
-/
import Mathlib

open Finset

/-! ## Section 1: Metric Definitions -/

/-- Manhattan (L1) distance between two integer-coordinate points. -/
def L1Dist (p q : ℤ × ℤ) : ℕ :=
  Int.natAbs (p.1 - q.1) + Int.natAbs (p.2 - q.2)

/-- Lift Nether coordinates to Overworld by scaling by 8. -/
def LiftOver (p : ℤ × ℤ) : ℤ × ℤ := (8 * p.1, 8 * p.2)

/-- Map Overworld coordinates to Nether by integer division by 8. -/
def NetherMap (p : ℤ × ℤ) : ℤ × ℤ := (p.1 / 8, p.2 / 8)

/-- Predicate: a point lies on the 8-lattice (both coordinates divisible by 8). -/
def DivBy8Point (p : ℤ × ℤ) : Prop := 8 ∣ p.1 ∧ 8 ∣ p.2

/-! ## Section 2: Exact Scaling Theorems -/

/-
**Theorem 1a (Lift form)**: L1 distance scales exactly by 8 under the lift map.
This is the cleanest form of the tropical scaling law.
-/
theorem lift_scaling_exact (p q : ℤ × ℤ) :
    L1Dist (LiftOver p) (LiftOver q) = 8 * L1Dist p q := by
  unfold L1Dist LiftOver;
  lia

/-
**Theorem 1b**: On the 8-lattice, Nether distance times 8 equals Overworld distance.
-/
theorem nether_scaling_exact (p q : ℤ × ℤ)
    (hp : DivBy8Point p) (hq : DivBy8Point q) :
    L1Dist (NetherMap p) (NetherMap q) * 8 = L1Dist p q := by
  unfold L1Dist NetherMap;
  rcases hp with ⟨ ⟨ a, ha ⟩, ⟨ b, hb ⟩ ⟩ ; rcases hq with ⟨ ⟨ c, hc ⟩, ⟨ d, hd ⟩ ⟩ ; simp +decide [*];
  grind

/-
L1Dist is symmetric.
-/
theorem L1Dist_symm (p q : ℤ × ℤ) : L1Dist p q = L1Dist q p := by
  unfold L1Dist; ring;
  grind +splitImp

/-
L1Dist of a point with itself is zero.
-/
theorem L1Dist_self (p : ℤ × ℤ) : L1Dist p p = 0 := by
  -- By definition of L1 distance, we have L1Dist p p = |p.1 - p.1| + |p.2 - p.2|.
  simp [L1Dist]

/-
NetherMap is a left inverse of LiftOver.
-/
theorem NetherMap_LiftOver (p : ℤ × ℤ) : NetherMap (LiftOver p) = p := by
  unfold LiftOver NetherMap; aesop;

/-
LiftOver points are always on the 8-lattice.
-/
theorem LiftOver_divBy8 (p : ℤ × ℤ) : DivBy8Point (LiftOver p) := by
  exact ⟨ ⟨ p.1, rfl ⟩, ⟨ p.2, rfl ⟩ ⟩

/-! ## Section 3: Rounding Error Bound -/

/-
**Variant A**: For arbitrary integer coordinates, the rounding distortion
from integer division by 8 is bounded. Specifically:
  L1Dist(p,q) - 8 * L1Dist(NetherMap p, NetherMap q) ≤ 14
This captures the fact that Nether compression introduces at most bounded error.
-/
theorem nether_scaling_rounding_error_bound (p q : ℤ × ℤ) :
    (L1Dist p q : ℤ) - 8 * (L1Dist (NetherMap p) (NetherMap q) : ℤ) ≤ 14 := by
  unfold L1Dist NetherMap;
  grind

/-
The rounding error is also bounded from below: the Nether distance can
overestimate by at most 14 units (in Overworld scale).
-/
theorem nether_scaling_rounding_error_lower (p q : ℤ × ℤ) :
    -14 ≤ (L1Dist p q : ℤ) - 8 * (L1Dist (NetherMap p) (NetherMap q) : ℤ) := by
  unfold L1Dist NetherMap;
  grind

/-! ## Section 4: Portal Cost Threshold -/

/-
**Variant B**: With portal activation cost `c` each way, Nether travel
(cost = 2c + d) beats Overworld travel (cost = 8d) when d is large enough.
Specifically, if 16c < 7d, then 2c + d < 8d.
-/
theorem nether_beats_overworld_beyond_threshold
    (c d : ℕ) (h : 16 * c < 7 * d) :
    2 * c + d < 8 * d := by
  omega

/-! ## Section 5: Tropical Matrix Operations -/

/-- Min-plus (tropical) matrix multiplication on ℕ. -/
noncomputable def tropicalMatMul {n : ℕ} [NeZero n]
    (A B : Fin n → Fin n → ℕ) : Fin n → Fin n → ℕ :=
  fun i k => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + B j k)

/-- The dual-world cost between two portal sites: min of Overworld direct
travel and Nether travel (with portal cost `c`). -/
def dualWorldCost (c : ℕ) (sites : Fin n → ℤ × ℤ) (i k : Fin n) : ℕ :=
  min (L1Dist (sites i) (sites k))
      (2 * c + L1Dist (NetherMap (sites i)) (NetherMap (sites k)))

/-
**Theorem 2**: Two-step shortest path equals tropical matrix product.
The optimal cost of traveling from i to k via exactly one intermediate
portal j is the tropical matrix square of the weight matrix.
-/
theorem tropical_two_step_optimal {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℕ) (i k : Fin n) :
    tropicalMatMul W W i k =
      Finset.inf' Finset.univ Finset.univ_nonempty (fun j => W i j + W j k) := by
  rfl

/-! ## Section 6: Spanning Trees and MST Optimality -/

/-- Total weight of a set of edges under a symmetric weight function. -/
def totalEdgeWeight {n : ℕ} (w : Fin n → Fin n → ℕ) (edges : Finset (Fin n × Fin n)) : ℕ :=
  edges.sum (fun e => w e.1 e.2)

/-- A path exists between two vertices using edges from the given set. -/
inductive EdgePath {n : ℕ} (edges : Finset (Fin n × Fin n)) : Fin n → Fin n → Prop where
  | refl (v : Fin n) : EdgePath edges v v
  | step (u v w : Fin n) :
      ((u, v) ∈ edges ∨ (v, u) ∈ edges) →
      EdgePath edges v w → EdgePath edges u w

/-- A spanning tree: an edge set that connects all vertices
and has exactly n-1 edges. -/
structure IsSpanningTree {n : ℕ} (edges : Finset (Fin n × Fin n)) : Prop where
  connected : ∀ u v : Fin n, EdgePath edges u v
  card : edges.card = n - 1

/-- An MST: a spanning tree with minimum total weight. -/
def IsMST {n : ℕ} (w : Fin n → Fin n → ℕ) (T : Finset (Fin n × Fin n)) : Prop :=
  IsSpanningTree T ∧
  ∀ T' : Finset (Fin n × Fin n), IsSpanningTree T' →
    totalEdgeWeight w T ≤ totalEdgeWeight w T'

/-- **Theorem 3**: An MST minimizes total infrastructure cost among all spanning trees.
This is definitional — the real content is that this structure characterizes optimal
portal network architecture when edge weights come from the compressed Nether metric. -/
theorem portal_network_mst_optimality {n : ℕ}
    (w : Fin n → Fin n → ℕ) (T : Finset (Fin n × Fin n))
    (hT : IsMST w T) (T' : Finset (Fin n × Fin n)) (hT' : IsSpanningTree T') :
    totalEdgeWeight w T ≤ totalEdgeWeight w T' :=
  hT.2 T' hT'

/-! ## Section 7: Tropical Closure -/

/-- Tropical closure (one iteration): improve all-pairs costs by considering
one-hop intermediate stops. -/
noncomputable def tropicalClose {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℕ) : Fin n → Fin n → ℕ :=
  fun i k => min (W i k) (tropicalMatMul W W i k)

/-- The tropical closure never increases costs. -/
theorem tropicalClose_le {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℕ) (i k : Fin n) :
    tropicalClose W i k ≤ W i k :=
  Nat.min_le_left _ _

/-
Idempotence: if W already encodes shortest paths (W i k ≤ W i j + W j k for all j),
then tropical closure is a fixpoint.
-/
theorem tropicalClose_fixpoint {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℕ) (i k : Fin n)
    (h : ∀ j, W i k ≤ W i j + W j k) :
    tropicalClose W i k = W i k := by
  exact min_eq_left ( Finset.le_inf' _ _ fun j _ => h j )

/-! ## Section 8: Connecting the Pieces -/

/-- The portal network cost matrix on 8-lattice points, using the Nether-compressed
metric, satisfies the exact scaling law. This connects Theorem 1 to Theorem 3:
the weights used in the MST are exactly 1/8 of Overworld distances. -/
theorem portal_cost_on_lattice
    (sites : Fin n → ℤ × ℤ)
    (hSites : ∀ i, DivBy8Point (sites i))
    (i k : Fin n) :
    L1Dist (NetherMap (sites i)) (NetherMap (sites k)) * 8 = L1Dist (sites i) (sites k) :=
  nether_scaling_exact _ _ (hSites i) (hSites k)

/-
The dual-world cost with zero portal entry cost reduces to the Nether distance
on 8-lattice aligned points, since Nether travel always dominates.
-/
theorem dualWorldCost_zero_portal_lattice
    (sites : Fin n → ℤ × ℤ)
    (hSites : ∀ i, DivBy8Point (sites i))
    (i k : Fin n) (_hne : i ≠ k) (hpos : 0 < L1Dist (sites i) (sites k)) :
    dualWorldCost 0 sites i k =
      L1Dist (NetherMap (sites i)) (NetherMap (sites k)) := by
  unfold dualWorldCost;
  simp +zetaDelta at *;
  linarith [ nether_scaling_exact ( sites i ) ( sites k ) ( hSites i ) ( hSites k ) ]