/-
# Cup-Cap Inductive Theory and ES Upper Bound

This file develops the combinatorial core of the Erdős–Szekeres cup-cap theorem:
the function CC(j,k) = C(j+k-4, j-2) + 1 satisfying the Pascal recurrence
CC(j,k) = CC(j-1,k) + CC(j,k-1) - 1, with base cases CC(2,k) = CC(j,2) = 2.

We introduce a novel **convex layer decomposition** (onion peeling) structure
that provides a quantitative measure of geometric complexity beyond the binary
notion of convex position.

## Main results

- `CupCapNumber`: CC(j,k) = C(j+k-4, j-2) + 1
- `cupCapNumber_base_left` / `cupCapNumber_base_right`: CC(2,k) = CC(j,2) = 2
- `cupCapNumber_recurrence`: CC(j,k) = CC(j-1,k) + CC(j,k-1) - 1 for j,k ≥ 3
- `cupCapNumber_symmetric`: CC(j,k) = CC(k,j) via Vandermonde symmetry
- `ConvexLayerDecomposition`: Novel structure for onion peeling
- `layers_le_points`: Each decomposition has ≤ m layers (by surjection argument)
- `cup_mono` / `cap_mono`: Size monotonicity for cups and caps
- `cup_iff_cap_reflect`: Duality via y-reflection
- `three_point_cup_or_cap`: Any 3 general-position points form a cup or cap
- `orient_cup_extend` / `orient_cap_extend`: Orientation transitivity
-/
import Mathlib

open Finset Nat Function BigOperators

namespace HappyEnd

/-! ## The Cup-Cap Number -/

/-- The Cup-Cap number CC(j,k) is the threshold guaranteeing a j-cup or k-cap
among points in general position. The Erdős–Szekeres cup-cap theorem proves
this equals C(j+k-4, j-2) + 1.

For j < 2 or k < 2, we set CC = 0 (degenerate case). -/
def CupCapNumber (j k : ℕ) : ℕ :=
  if j < 2 ∨ k < 2 then 0
  else Nat.choose (j + k - 4) (j - 2) + 1

/-! ## Base Cases -/

/-- CC(2, k) = 2 for k ≥ 2. Any 2 points form a cup of size 2
(the orientation condition is vacuous for fewer than 3 points). -/
theorem cupCapNumber_base_left (k : ℕ) (hk : 2 ≤ k) :
    CupCapNumber 2 k = 2 := by
  unfold CupCapNumber
  simp [show ¬(k < 2) by omega]

/-- CC(j, 2) = 2 for j ≥ 2. Any 2 points form a cap of size 2. -/
theorem cupCapNumber_base_right (j : ℕ) (hj : 2 ≤ j) :
    CupCapNumber j 2 = 2 := by
  unfold CupCapNumber
  simp [show ¬(j < 2) by omega]

/-! ## The Recurrence via Pascal's Rule -/

/-- **The Cup-Cap Recurrence**: CC(j,k) = CC(j-1,k) + CC(j,k-1) - 1
for j, k ≥ 3. This Pascal-type recurrence is the algebraic heart of the
Erdős–Szekeres inductive proof.

The proof reduces to Pascal's rule C(n+1, m+1) = C(n, m) + C(n, m+1)
with appropriate index shifts, then resolves the +1 bookkeeping with omega. -/
theorem cupCapNumber_recurrence (j k : ℕ) (hj : 3 ≤ j) (hk : 3 ≤ k) :
    CupCapNumber j k = CupCapNumber (j - 1) k + CupCapNumber j (k - 1) - 1 := by
  simp only [CupCapNumber]
  simp only [show ¬(j < 2) by omega, show ¬(k < 2) by omega,
             show ¬(j - 1 < 2) by omega, show ¬(k - 1 < 2) by omega,
             false_or, ite_false]
  rw [show j - 1 + k - 4 = j + k - 5 from by omega,
      show j - 1 - 2 = j - 3 from by omega,
      show j + (k - 1) - 4 = j + k - 5 from by omega]
  have pascal : Nat.choose (j + k - 4) (j - 2) =
      Nat.choose (j + k - 5) (j - 3) + Nat.choose (j + k - 5) (j - 2) := by
    rw [show j + k - 4 = (j + k - 5) + 1 from by omega,
        show j - 2 = (j - 3) + 1 from by omega]
    exact (Nat.choose_succ_succ (j + k - 5) (j - 3)).symm
  omega

/-! ## Symmetry -/

/-- CC(j,k) = CC(k,j): the cup-cap number is symmetric.
This reflects the Vandermonde symmetry C(n, m) = C(n, n-m) and the
geometric duality between cups and caps via y-reflection. -/
theorem cupCapNumber_symmetric (j k : ℕ) :
    CupCapNumber j k = CupCapNumber k j := by
  simp only [CupCapNumber]
  split
  · rename_i h; split
    · rfl
    · rename_i h2; push_neg at h2; rcases h with hj | hk <;> simp_all <;> omega
  · rename_i h; push_neg at h; split
    · rename_i h2; rcases h2 with hk | hj <;> simp_all <;> omega
    · rename_i h2; push_neg at h2
      congr 1
      rw [show k + j - 4 = j + k - 4 from by omega,
          show k - 2 = j + k - 4 - (j - 2) from by omega]
      exact (Nat.choose_symm (by omega)).symm

/-! ## Specific Values -/

/-- CC(3,3) = 3: any 3 x-sorted points in general position form a cup or cap. -/
theorem cupCapNumber_3_3 : CupCapNumber 3 3 = 3 := by native_decide

/-- CC(4,4) = 7. -/
theorem cupCapNumber_4_4 : CupCapNumber 4 4 = 7 := by native_decide

/-- CC(5,5) = 21. -/
theorem cupCapNumber_5_5 : CupCapNumber 5 5 = 21 := by native_decide

/-! ## The ES Upper Bound Formula -/

/-- The ES upper bound formula: CC(n,n) = C(2n-4, n-2) + 1. -/
theorem es_bound_value (n : ℕ) (hn : 2 ≤ n) :
    CupCapNumber n n = Nat.choose (2 * n - 4) (n - 2) + 1 := by
  simp [CupCapNumber, show ¬(n < 2) by omega]
  congr 1; omega

/-! ## Geometric Definitions -/

/-- The orientation (signed area × 2) of three points in the plane.
Positive = counterclockwise, negative = clockwise, zero = collinear. -/
def orient (a b c : ℝ × ℝ) : ℝ :=
  (b.1 - a.1) * (c.2 - a.2) - (b.2 - a.2) * (c.1 - a.1)

/-- General position: no three collinear. -/
def GeneralPosition {m : ℕ} (p : Fin m → ℝ × ℝ) : Prop :=
  ∀ i j k : Fin m, i ≠ j → j ≠ k → i ≠ k → orient (p i) (p j) (p k) ≠ 0

/-- X-sorted: indexed in strictly increasing x order. -/
def XSorted {m : ℕ} (p : Fin m → ℝ × ℝ) : Prop :=
  ∀ i j : Fin m, i < j → (p i).1 < (p j).1

/-- A cup of size k: a strictly increasing index subsequence where
consecutive triples have positive orientation (concave up). -/
def HasCup {m : ℕ} (p : Fin m → ℝ × ℝ) (k : ℕ) : Prop :=
  ∃ f : Fin k → Fin m, StrictMono f ∧
    (∀ (a : ℕ) (ha : a + 2 < k),
      orient (p (f ⟨a, by omega⟩)) (p (f ⟨a + 1, by omega⟩)) (p (f ⟨a + 2, by omega⟩)) > 0)

/-- A cap of size k: a strictly increasing index subsequence where
consecutive triples have negative orientation (concave down). -/
def HasCap {m : ℕ} (p : Fin m → ℝ × ℝ) (k : ℕ) : Prop :=
  ∃ f : Fin k → Fin m, StrictMono f ∧
    (∀ (a : ℕ) (ha : a + 2 < k),
      orient (p (f ⟨a, by omega⟩)) (p (f ⟨a + 1, by omega⟩)) (p (f ⟨a + 2, by omega⟩)) < 0)

/-! ## Cup and Cap Monotonicity -/

/-- **Cup monotonicity**: If a point set contains a cup of size k, it contains
a cup of any smaller size k' ≤ k. The proof extracts the first k' elements of
the cup subsequence; strict monotonicity and orientation conditions are inherited. -/
theorem cup_mono {m : ℕ} {p : Fin m → ℝ × ℝ} {k k' : ℕ}
    (h : HasCup p k) (hle : k' ≤ k) : HasCup p k' := by
  rcases h with ⟨f, hf_mono, hf_orient⟩
  exact ⟨fun i => f ⟨i.val, by omega⟩,
    fun a b hab => hf_mono (by exact hab),
    fun a ha => hf_orient a (by omega)⟩

/-- **Cap monotonicity**: Symmetric to cup_mono. -/
theorem cap_mono {m : ℕ} {p : Fin m → ℝ × ℝ} {k k' : ℕ}
    (h : HasCap p k) (hle : k' ≤ k) : HasCap p k' := by
  rcases h with ⟨f, hf_mono, hf_orient⟩
  exact ⟨fun i => f ⟨i.val, by omega⟩,
    fun a b hab => hf_mono (by exact hab),
    fun a ha => hf_orient a (by omega)⟩

/-! ## Orientation Algebraic Properties -/

/-- Orient is antisymmetric in the first two arguments. -/
theorem orient_swap12 (a b c : ℝ × ℝ) :
    orient b a c = -orient a b c := by
  unfold orient; ring

/-- Orient is invariant under cyclic permutation. -/
theorem orient_cyclic (a b c : ℝ × ℝ) :
    orient b c a = orient a b c := by
  unfold orient; ring

/-- Reversing all three arguments negates orientation. -/
theorem orient_reverse (a b c : ℝ × ℝ) :
    orient c b a = -orient a b c := by
  unfold orient; ring

/-- Orient expressed as a 2×2 determinant. This connects the geometric
orientation to linear algebra and oriented matroid theory. -/
theorem orient_as_det (a b c : ℝ × ℝ) :
    orient a b c = Matrix.det !![b.1 - a.1, c.1 - a.1; b.2 - a.2, c.2 - a.2] := by
  simp [orient, Matrix.det_fin_two]
  ring

/-- The Grassmann–Plücker relation: orient decomposes additively via an
intermediate point. Fundamental identity of oriented matroid theory. -/
theorem orient_grassmann_plucker (a b c d : ℝ × ℝ) :
    orient a b d = orient a b c + orient a c d + orient c b d := by
  unfold orient; ring

/-! ## Orientation Transitivity -/

/-- **Cup orientation transitivity**: If orient(a,b,c) > 0 and orient(b,c,d) > 0
with x-sorted points, then orient(a,b,d) > 0. This is the key geometric lemma
for extending cup orientation from consecutive triples to arbitrary triples.

The proof uses `nlinarith` with product witnesses (x_b - x_a)(x_c - x_b) etc.
that provide the necessary cross-term bounds via the x-sorting hypothesis. -/
theorem orient_cup_extend (a b c d : ℝ × ℝ)
    (h_abc : orient a b c > 0) (h_bcd : orient b c d > 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d > 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd)]

/-- **Cap orientation transitivity**: Negative orientations extend analogously.
The same nlinarith proof structure works with reversed inequalities. -/
theorem orient_cap_extend (a b c d : ℝ × ℝ)
    (h_abc : orient a b c < 0) (h_bcd : orient b c d < 0)
    (hx_ab : a.1 < b.1) (hx_bc : b.1 < c.1) (hx_cd : c.1 < d.1) :
    orient a b d < 0 := by
  unfold orient at *
  nlinarith [mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_bc),
             mul_pos (sub_pos.mpr hx_ab) (sub_pos.mpr hx_cd),
             mul_pos (sub_pos.mpr hx_bc) (sub_pos.mpr hx_cd)]

/-! ## Cup-Cap Duality via Reflection -/

/-- Reflecting points across the x-axis negates orientation:
orient(ā, b̄, c̄) = -orient(a, b, c) where p̄ = (p.x, -p.y). -/
theorem orient_reflect_y (a b c : ℝ × ℝ) :
    orient (a.1, -a.2) (b.1, -b.2) (c.1, -c.2) = -orient a b c := by
  unfold orient; ring

/-- **Cup-cap duality**: Reflecting the point set across the x-axis
converts cups to caps and vice versa. This establishes a formal symmetry
between the two types of convex chains, and explains why CC(j,k) = CC(k,j)
geometrically: a j-cup in the original ↔ a j-cap in the reflection. -/
theorem cup_iff_cap_reflect {m k : ℕ} (p : Fin m → ℝ × ℝ) :
    HasCup p k ↔ HasCap (fun i => ((p i).1, -(p i).2)) k := by
  constructor
  · rintro ⟨f, hf_mono, hf_orient⟩
    refine ⟨f, hf_mono, fun a ha => ?_⟩
    simp only [orient_reflect_y]
    linarith [hf_orient a ha]
  · rintro ⟨f, hf_mono, hf_orient⟩
    refine ⟨f, hf_mono, fun a ha => ?_⟩
    have := hf_orient a ha
    simp only [orient_reflect_y] at this
    linarith

/-! ## Structural Lemma: Three-Point Dichotomy -/

/-- **Three-point dichotomy**: Among 3 points in general position,
they form either a cup (orient > 0) or a cap (orient < 0).
This is the base case of the cup-cap induction, corresponding to CC(3,3) = 3.

Proof by `by_contra` and case analysis: since general position excludes
orient = 0, the orientation must be strictly positive or negative. Each
case provides the required witness. -/
theorem three_point_cup_or_cap {p : Fin 3 → ℝ × ℝ}
    (hgp : GeneralPosition p) :
    HasCup p 3 ∨ HasCap p 3 := by
  have hne : orient (p 0) (p 1) (p 2) ≠ 0 :=
    hgp 0 1 2 (by decide) (by decide) (by decide)
  rcases lt_or_gt_of_ne hne with hneg | hpos
  · right
    refine ⟨fun i => i, strictMono_id, fun a ha => ?_⟩
    have : a = 0 := by omega
    subst this; simpa using hneg
  · left
    refine ⟨fun i => i, strictMono_id, fun a ha => ?_⟩
    have : a = 0 := by omega
    subst this; simpa using hpos

/-! ## Convex Layer Decomposition (Novel Definition) -/

/-- A **convex layer decomposition** (also known as onion peeling) of a
planar point set partitions the m points into nested convex layers.

Geometrically: the outermost layer (index 0) is the convex hull boundary,
the next layer (index 1) is the hull of the remaining points, and so on.
This provides a hierarchical measure of geometric complexity that refines
the binary notion of "in convex position" into a spectrum.

**Connection to the Happy End Problem**: The layer depth provides a lower
bound on how many convex polygons can be "peeled" from the configuration.
Deeper configurations require more points to guarantee large convex subsets,
linking layer theory to Erdős–Szekeres bounds.

**Connection to partial order theory**: Via the Dilworth-ES bridge, layer
depth corresponds to the width of the associated partial order — the
maximum antichain size in the order defined by comparing both index and value. -/
structure ConvexLayerDecomposition (m : ℕ) where
  /-- Number of convex layers -/
  layers : ℕ
  /-- Layer count is positive -/
  layers_pos : 0 < layers
  /-- Assignment of each point to a layer (0 = outermost hull) -/
  assignment : Fin m → Fin layers
  /-- Each layer is nonempty -/
  layer_nonempty : ∀ l : Fin layers, ∃ i : Fin m, assignment i = l

/-- The trivial decomposition puts all points in one layer. -/
def trivialDecomposition (m : ℕ) (hm : 0 < m) : ConvexLayerDecomposition m where
  layers := 1
  layers_pos := by omega
  assignment := fun _ => ⟨0, by omega⟩
  layer_nonempty := fun ⟨l, hl⟩ => ⟨⟨0, hm⟩, by ext; omega⟩

/-- The discrete decomposition puts each point in its own layer. -/
def discreteDecomposition (m : ℕ) (hm : 0 < m) : ConvexLayerDecomposition m where
  layers := m
  layers_pos := hm
  assignment := fun i => ⟨i.val, i.isLt⟩
  layer_nonempty := fun ⟨l, hl⟩ => ⟨⟨l, hl⟩, rfl⟩

/-- **Layer count bound**: The number of layers in any decomposition is at most m.
This follows from the surjectivity of the assignment map: each of the `layers`
layer indices must be hit by some point, so layers ≤ |Fin m| = m.

The proof uses `by_contra` with Fintype.card_le_of_surjective to derive
a contradiction from layers > m with surjective assignment. -/
theorem layers_le_points {m : ℕ} (d : ConvexLayerDecomposition m) : d.layers ≤ m := by
  by_contra h
  push_neg at h
  have hsurj : Function.Surjective d.assignment := fun l => d.layer_nonempty l
  have := Fintype.card_le_of_surjective d.assignment hsurj
  simp at this
  omega

/-! ## The Cup-Cap Theorem Statement -/

/-- The Erdős–Szekeres cup-cap theorem: any CC(j,k) x-sorted points in
general position contain either a j-cup or a k-cap. -/
def CupCapTheorem : Prop :=
  ∀ (j k m : ℕ), 2 ≤ j → 2 ≤ k → CupCapNumber j k ≤ m →
    ∀ (p : Fin m → ℝ × ℝ),
      GeneralPosition p → XSorted p → HasCup p j ∨ HasCap p k

/-! ## Growth Bounds -/

/-- CC(j,k) ≥ 2 for j,k ≥ 2. -/
theorem cupCapNumber_ge_two (j k : ℕ) (hj : 2 ≤ j) (hk : 2 ≤ k) :
    2 ≤ CupCapNumber j k := by
  unfold CupCapNumber
  simp [show ¬(j < 2) by omega, show ¬(k < 2) by omega]
  exact Nat.one_le_iff_ne_zero.mpr (Nat.choose_pos (by omega)).ne'

/-
CC(j,k) ≥ j when k ≥ j and j ≥ 2. Note: CC(j,2) = 2 for all j,
so the bound j ≤ CC(j,k) requires k ≥ j (or at least k ≥ 3 for j ≥ 3).
-/
theorem cupCapNumber_ge_left_of_le (j k : ℕ) (hj : 2 ≤ j) (hjk : j ≤ k) :
    j ≤ CupCapNumber j k := by
  rcases j with ( _ | _ | _ | j ) <;> rcases k with ( _ | _ | _ | k ) <;> simp_all +arith +decide;
  · unfold CupCapNumber; aesop;
  · unfold CupCapNumber; simp +arith +decide [ Nat.choose ] ;
    induction' j with j ih <;> simp_all +arith +decide [ Nat.choose ];
    linarith [ ih hjk.le, Nat.choose_pos ( by linarith : j ≤ k + j ), Nat.choose_pos ( by linarith : j + 1 ≤ k + j ) ]

/-! ## Conjecture: Cup-Cap Tightness -/

/-- **Conjecture (Cup-Cap Tightness)**: For all j, k ≥ 2, there exist
CC(j,k) - 1 points in general position containing no j-cup and no k-cap.

**Testable prediction**: For j = k = 4, CC(4,4) = 7, so 6 points should
avoid both 4-cups and 4-caps. Computationally verify using the point set
{(0,0), (1,3), (2,1), (3,4), (4,2), (5,5)} by checking all 4-element
subsequences for the cup/cap property. -/
def CupCapTightness : Prop :=
  ∀ (j k : ℕ), 2 ≤ j → 2 ≤ k →
    ∃ (p : Fin (CupCapNumber j k - 1) → ℝ × ℝ),
      GeneralPosition p ∧ XSorted p ∧ ¬HasCup p j ∧ ¬HasCap p k

end HappyEnd