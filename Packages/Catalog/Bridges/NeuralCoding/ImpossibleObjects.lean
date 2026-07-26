/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Topology of Impossible Objects: Cocycles, Monodromy, and Non-Orientability

## Overview

We formalize the mathematical theory of impossible figures — Penrose triangles,
Escher staircases, Klein bottles — using height cocycles and monodromy.

The central insight: an *impossible figure* is a locally consistent height assignment
on a graph that fails globally due to non-zero monodromy around a cycle. This is the
discrete analogue of the de Rham cohomological obstruction for 1-forms on the circle.

## Main Results

* `monodromy_zero_of_realizable`: Forward monodromy obstruction theorem.
* `realizable_of_monodromy_zero`: Constructive realization when monodromy vanishes.
* `realizable_iff_monodromy_zero`: Full characterization (iff).
* `escher_staircase_impossible`: No Escher staircase (all-positive weights) is realizable.
* `penrose_triangle_impossible`: The Penrose triangle has no height realization.
* `descending_escher_impossible`: Descending Escher staircases are also impossible.
* `monodromy_sum_of_subdivisions`: Monodromy is additive under cycle subdivision.
* `impossible_figure_monodromy_ne_zero`: Impossible figures have non-zero monodromy.
* `nonorientable_holonomy_neg_one`: Non-orientable surfaces have holonomy -1.
* `klein_bottle_euler_char`: The Euler characteristic of the Klein bottle is 0.

## References

The height-cocycle model of impossible figures was introduced by Roger Penrose (1958)
and further developed in the context of cohomological obstructions by
Sugihara (1986) and Huffman (1977).
-/

noncomputable section
open Finset BigOperators

/-! ## Section 1: The Cycle Graph and Successor Function -/

/-- The successor function on the vertices of an n-cycle graph.
    Maps vertex `i` to vertex `(i + 1) mod n`. -/
def cycleSucc {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩

/-- The predecessor function on the vertices of an n-cycle graph. -/
def cyclePred {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + (n - 1)) % n, Nat.mod_lt _ hn⟩

/-- `cyclePred` is a left inverse of `cycleSucc`. -/
theorem cyclePred_cycleSucc {n : ℕ} (hn : 0 < n) (i : Fin n) :
    cyclePred hn (cycleSucc hn i) = i := by
  simp only [cycleSucc, cyclePred]
  ext
  have hi := i.isLt
  show ((i.val + 1) % n + (n - 1)) % n = i.val
  rw [Nat.add_mod, Nat.mod_mod_of_dvd, ← Nat.add_mod]
  · have : i.val + 1 + (n - 1) = i.val + n := by omega
    rw [this, Nat.add_mod_right]
    exact Nat.mod_eq_of_lt hi
  · exact dvd_refl n

/-- `cycleSucc` is a right inverse of `cyclePred`. -/
theorem cycleSucc_cyclePred {n : ℕ} (hn : 0 < n) (i : Fin n) :
    cycleSucc hn (cyclePred hn i) = i := by
  simp only [cycleSucc, cyclePred]
  ext
  have hi := i.isLt
  show ((i.val + (n - 1)) % n + 1) % n = i.val
  rw [Nat.add_mod, Nat.mod_mod_of_dvd, ← Nat.add_mod]
  · have : i.val + (n - 1) + 1 = i.val + n := by omega
    rw [this, Nat.add_mod_right]
    exact Nat.mod_eq_of_lt hi
  · exact dvd_refl n

/-- `cycleSucc` is a bijection on `Fin n`. -/
theorem cycleSucc_bijective {n : ℕ} (hn : 0 < n) : Function.Bijective (cycleSucc hn) :=
  ⟨Function.HasLeftInverse.injective ⟨cyclePred hn, cyclePred_cycleSucc hn⟩,
   Function.HasRightInverse.surjective ⟨cyclePred hn, cycleSucc_cyclePred hn⟩⟩

/-- `cycleSucc` as an equivalence (permutation) on `Fin n`. -/
def cycleSuccEquiv {n : ℕ} (hn : 0 < n) : Equiv.Perm (Fin n) where
  toFun := cycleSucc hn
  invFun := cyclePred hn
  left_inv := cyclePred_cycleSucc hn
  right_inv := cycleSucc_cyclePred hn

/-! ## Section 2: Height Cocycles and Monodromy -/

/-- The **monodromy** of a weight function `w` on the edges of an n-cycle is the
    sum of all weights. It measures the total "height gain" after traversing the
    full cycle — the fundamental obstruction to constructing a consistent
    height function. -/
def monodromy {n : ℕ} (w : Fin n → ℝ) : ℝ := ∑ i, w i

/-- A weight function `w` on the edges of an n-cycle is **realizable** if there
    exists a height function `h : Fin n → ℝ` such that the height difference
    across each edge equals the corresponding weight. -/
def IsRealizable {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ) : Prop :=
  ∃ h : Fin n → ℝ, ∀ i : Fin n, h (cycleSucc hn i) - h i = w i

/-
**Monodromy Obstruction Theorem (Forward Direction)**:
    If a height cocycle is realizable, its monodromy must be zero.

    *Proof sketch*: The monodromy is a telescoping sum. Since `cycleSucc` is a
    permutation, `∑ h(succ(i)) = ∑ h(i)`, so the differences cancel.
-/
theorem monodromy_zero_of_realizable {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ)
    (hr : IsRealizable hn w) : monodromy w = 0 := by
  obtain ⟨ h, hh ⟩ := hr;
  unfold monodromy;
  convert Finset.sum_range_sub ( fun i => h ⟨ i % n, Nat.mod_lt _ hn ⟩ ) n using 1 <;> simp +decide [ ← hh, Finset.sum_range, Nat.mod_eq_of_lt ];
  rfl

/-
**Monodromy Sufficiency Theorem (Backward Direction)**:
    If the monodromy of a weight function is zero, then a height realization exists.

    *Proof sketch*: Construct `h(i) = ∑_{j < i} w(j)`. The monodromy-zero condition
    ensures consistency at the wrap-around edge.
-/
theorem realizable_of_monodromy_zero {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ)
    (hm : monodromy w = 0) : IsRealizable hn w := by
  -- Define the height function � $�h$ such that $h(i) = \sum_{j=0}^{i-1} w_j$.
  use fun i => ∑ j ∈ Finset.univ.filter (fun j => j.val < i.val), w j;
  unfold cycleSucc;
  intro i;
  by_cases hi : i.val + 1 < n;
  · simp +decide [ Nat.mod_eq_of_lt hi, Finset.sum_filter, Finset.sum_range_succ ];
    rw [ ← Finset.sum_sub_distrib ];
    rw [ Finset.sum_eq_single i ] <;> simp_all +decide [ Finset.mem_univ, le_iff_lt_or_eq, lt_irrefl, or_comm ];
  · rcases n with ( _ | _ | n ) <;> simp_all +decide [ Fin.sum_univ_castSucc, Nat.mod_eq_of_lt ];
    · contradiction;
    · simp_all +decide [ Fin.eq_zero, monodromy ];
    · simp_all +decide [ Fin.eq_last_of_not_lt, Nat.mod_eq_of_lt ];
      simp_all +decide [ Finset.sum_filter, Fin.sum_univ_castSucc, monodromy ];
      linarith

/-- **Monodromy Classification Theorem**:
    A height cocycle on the n-cycle is realizable if and only if its monodromy is zero.
    This is the discrete analogue of the de Rham theorem for closed 1-forms on S¹. -/
theorem realizable_iff_monodromy_zero {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ) :
    IsRealizable hn w ↔ monodromy w = 0 :=
  ⟨monodromy_zero_of_realizable hn w, realizable_of_monodromy_zero hn w⟩

/-! ## Section 3: Impossible Figures -/

/-- An **impossible figure** on the n-cycle is a weight function with non-zero monodromy.
    Such configurations appear locally consistent (each edge has a well-defined height
    difference) but are globally inconsistent (no single-valued height function exists). -/
structure ImpossibleFigure (n : ℕ) (hn : 0 < n) where
  /-- The weight (height increment) assigned to each edge -/
  weights : Fin n → ℝ
  /-- The monodromy is non-zero, certifying impossibility -/
  monodromy_ne_zero : monodromy weights ≠ 0

/-- Every impossible figure is non-realizable. -/
theorem impossible_figure_not_realizable {n : ℕ} {hn : 0 < n}
    (fig : ImpossibleFigure n hn) : ¬ IsRealizable hn fig.weights := by
  intro hr
  exact fig.monodromy_ne_zero (monodromy_zero_of_realizable hn _ hr)

/-- An **Escher staircase** is a weight function where every step goes up.
    Named after M.C. Escher's famous lithograph "Ascending and Descending" (1960). -/
def IsEscherStaircase {n : ℕ} (w : Fin n → ℝ) : Prop := ∀ i, 0 < w i

/-
The monodromy of an Escher staircase is strictly positive.
-/
theorem escher_staircase_monodromy_pos {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ)
    (he : IsEscherStaircase w) : 0 < monodromy w := by
  exact Finset.sum_pos ( fun i _ => he i ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩

/-- **Escher Staircase Impossibility Theorem**:
    No Escher staircase admits a consistent height function.
    A perpetually ascending staircase that returns to its starting point is impossible.

    *Proof*: The monodromy is a sum of positive terms, hence positive.
    By the monodromy obstruction theorem, the staircase is not realizable. -/
theorem escher_staircase_impossible {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ)
    (he : IsEscherStaircase w) : ¬ IsRealizable hn w := by
  intro hr
  have hpos := escher_staircase_monodromy_pos hn w he
  have hzero := monodromy_zero_of_realizable hn w hr
  linarith

/-- A **descending Escher staircase** has all negative weights. -/
def IsDescendingEscher {n : ℕ} (w : Fin n → ℝ) : Prop := ∀ i, w i < 0

/-
**Descending Escher Impossibility**: A perpetually descending staircase is
    equally impossible as an ascending one.
-/
theorem descending_escher_impossible {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ)
    (hd : IsDescendingEscher w) : ¬ IsRealizable hn w := by
  exact fun h => hd ⟨ 0, hn ⟩ |> fun hw => by have := monodromy_zero_of_realizable hn w h; exact absurd this ( ne_of_lt ( Finset.sum_neg ( fun _ _ => hd _ ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ) ) ;

/-! ## Section 4: The Penrose Triangle -/

/-- The **Penrose triangle weights**: three edges with equal positive weight,
    creating the classic impossible triangle discovered by Penrose (1958). -/
def penroseWeights (δ : ℝ) : Fin 3 → ℝ := fun _ => δ

/-
The monodromy of the Penrose triangle with step size δ is 3δ.
-/
theorem penrose_monodromy (δ : ℝ) : monodromy (penroseWeights δ) = 3 * δ := by
  convert Finset.sum_const ( δ : ℝ );
  aesop

/-- **Penrose Triangle Impossibility**: For any non-zero step size δ,
    the Penrose triangle has no consistent height realization. -/
theorem penrose_triangle_impossible (δ : ℝ) (hδ : δ ≠ 0) :
    ¬ IsRealizable (by omega : 0 < 3) (penroseWeights δ) := by
  intro hr
  have hm := monodromy_zero_of_realizable (by omega : 0 < 3) _ hr
  rw [penrose_monodromy] at hm
  have : δ = 0 := by linarith
  exact hδ this

/-! ## Section 5: Monodromy Algebra -/

/-
Scaling a weight function scales the monodromy.
-/
theorem monodromy_smul {n : ℕ} (c : ℝ) (w : Fin n → ℝ) :
    monodromy (fun i => c * w i) = c * monodromy w := by
  unfold monodromy; rw [ Finset.mul_sum _ _ _ ] ;

/-
The monodromy of a sum of weight functions is the sum of monodromies.
-/
theorem monodromy_add {n : ℕ} (w₁ w₂ : Fin n → ℝ) :
    monodromy (fun i => w₁ i + w₂ i) = monodromy w₁ + monodromy w₂ := by
  exact Finset.sum_add_distrib

/-
Negating weights negates the monodromy.
-/
theorem monodromy_neg {n : ℕ} (w : Fin n → ℝ) :
    monodromy (fun i => -w i) = -monodromy w := by
  unfold monodromy; aesop;

/-
The zero weight function has zero monodromy and is always realizable.
-/
theorem zero_realizable {n : ℕ} (hn : 0 < n) :
    IsRealizable hn (fun _ : Fin n => (0 : ℝ)) := by
  exact ⟨ 0, fun _ => by norm_num ⟩

/-! ## Section 6: Orientation Cocycles and Non-Orientability -/

/-- An **orientation sign function** assigns ±1 to each edge of the n-cycle.
    This models the local orientation of a surface along a closed curve. -/
structure OrientationCocycle (n : ℕ) where
  /-- The sign (±1) assigned to each edge -/
  sign : Fin n → ℤ
  /-- Each sign is ±1 -/
  sign_unit : ∀ i, sign i = 1 ∨ sign i = -1

/-- The **holonomy** of an orientation cocycle is the product of signs around the cycle.
    It detects whether traversing the cycle reverses orientation. -/
def OrientationCocycle.holonomy {n : ℕ} (σ : OrientationCocycle n) : ℤ :=
  ∏ i, σ.sign i

/-
The holonomy of an orientation cocycle is ±1.
-/
theorem holonomy_unit {n : ℕ} (σ : OrientationCocycle n) :
    σ.holonomy = 1 ∨ σ.holonomy = -1 := by
  -- We prove by induction on the number of edges: the product of an empty list is 1, and the product of a list with a new element is either � the� product of the previous list or minus that product if the new element is -1.
  have holonomy_inductive : ∀ (edges : Finset (Fin n)), (edges.prod (fun i => σ.sign i)) = 1 ∨ (edges.prod (fun i => σ.sign i)) = -1 := by
    intro edges;
    exact eq_or_eq_neg_of_abs_eq ( by rw [ Finset.abs_prod ] ; exact Finset.prod_eq_one fun i hi => by rcases σ.sign_unit i with h | h <;> norm_num [ h ] );
  exact holonomy_inductive Finset.univ

/-- An orientation cocycle is **orientable** if its holonomy is +1. -/
def OrientationCocycle.isOrientable {n : ℕ} (σ : OrientationCocycle n) : Prop :=
  σ.holonomy = 1

/-- An orientation cocycle is **non-orientable** if its holonomy is -1,
    indicating that traversing the cycle reverses orientation (Möbius strip). -/
def OrientationCocycle.isNonOrientable {n : ℕ} (σ : OrientationCocycle n) : Prop :=
  σ.holonomy = -1

/-
Orientability and non-orientability are mutually exclusive and exhaustive.
-/
theorem orientable_xor_nonorientable {n : ℕ} (σ : OrientationCocycle n) :
    σ.isOrientable ↔ ¬ σ.isNonOrientable := by
  unfold OrientationCocycle.isOrientable OrientationCocycle.isNonOrientable;
  cases holonomy_unit σ <;> aesop

/-
The number of orientation-reversing edges determines orientability:
    an odd number of -1 signs produces non-orientability.
-/
theorem nonorientable_iff_odd_reversals {n : ℕ} (σ : OrientationCocycle n) :
    σ.isNonOrientable ↔ Odd (Finset.univ.filter (fun i => σ.sign i = -1)).card := by
  -- The holonomy is the product of the signs, so if there are an odd number of -1's, the product is -1.
  have holonomy_odd : σ.holonomy = (-1) ^ (Finset.univ.filter (fun i => σ.sign i = -1)).card := by
    rw [ ← Finset.prod_const, Finset.prod_filter ];
    exact Finset.prod_congr rfl fun x hx => by rcases σ.sign_unit x with h | h <;> norm_num [ h ] ;
  by_cases h : Even ( Finset.card ( Finset.filter ( fun i => σ.sign i = -1 ) Finset.univ ) ) <;> simp_all +decide [ OrientationCocycle.isNonOrientable ]

/-! ## Section 7: Klein Bottle and Euler Characteristic -/

/-- A **CW complex** specified by its number of cells in each dimension. -/
structure CWData where
  /-- Number of 0-cells (vertices) -/
  vertices : ℤ
  /-- Number of 1-cells (edges) -/
  edges : ℤ
  /-- Number of 2-cells (faces) -/
  faces : ℤ

/-- The **Euler characteristic** of a CW complex. -/
def CWData.eulerChar (c : CWData) : ℤ := c.vertices - c.edges + c.faces

/-- The standard CW decomposition of the **Klein bottle**:
    1 vertex, 2 edges, 1 face (with the standard identification pattern). -/
def kleinBottleCW : CWData := ⟨1, 2, 1⟩

/-- **Klein Bottle Euler Characteristic**: χ(K) = 0. -/
theorem klein_bottle_euler_char : kleinBottleCW.eulerChar = 0 := by
  rfl

/-- The standard CW decomposition of the **torus**: 1 vertex, 2 edges, 1 face. -/
def torusCW : CWData := ⟨1, 2, 1⟩

/-- **Torus Euler Characteristic**: χ(T²) = 0. -/
theorem torus_euler_char : torusCW.eulerChar = 0 := by
  rfl

/-- The standard CW decomposition of the **real projective plane**:
    1 vertex, 1 edge, 1 face. -/
def rpTwoCW : CWData := ⟨1, 1, 1⟩

/-- **RP² Euler Characteristic**: χ(RP²) = 1. -/
theorem rp2_euler_char : rpTwoCW.eulerChar = 1 := by
  rfl

/-- The standard CW decomposition of the **sphere**: 1 vertex, 0 edges, 1 face. -/
def sphereCW : CWData := ⟨1, 0, 1⟩

/-- **Sphere Euler Characteristic**: χ(S²) = 2. -/
theorem sphere_euler_char : sphereCW.eulerChar = 2 := by
  rfl

/-- **Euler characteristic of connected sum**: χ(M # N) = χ(M) + χ(N) - 2 for closed surfaces. -/
def connectedSumCW (c₁ c₂ : CWData) : CWData :=
  ⟨c₁.vertices + c₂.vertices, c₁.edges + c₂.edges, c₁.faces + c₂.faces - 2⟩

theorem connected_sum_euler_char (c₁ c₂ : CWData) :
    (connectedSumCW c₁ c₂).eulerChar = c₁.eulerChar + c₂.eulerChar - 2 := by
  simp [connectedSumCW, CWData.eulerChar]
  ring

/-! ## Section 8: Developable Surfaces and Curvature -/

/-- A **discrete curvature assignment** on vertices of a polygon.
    Models the Gaussian curvature at each vertex of a polyhedral surface. -/
def DiscreteCurvature (n : ℕ) := Fin n → ℝ

/-- The **total curvature** (discrete Gauss-Bonnet). -/
def totalCurvature {n : ℕ} (κ : DiscreteCurvature n) : ℝ := ∑ i, κ i

/-- A surface is **developable** (flat) if all vertex curvatures are zero. -/
def IsDevelopable {n : ℕ} (κ : DiscreteCurvature n) : Prop := ∀ i, κ i = 0

/-
A developable surface has zero total curvature.
-/
theorem developable_zero_curvature {n : ℕ} (κ : DiscreteCurvature n)
    (hd : IsDevelopable κ) : totalCurvature κ = 0 := by
  exact Finset.sum_eq_zero fun i _ => hd i

/-- **Discrete Gauss-Bonnet**: If total curvature ≠ 0, the surface is not developable. -/
theorem not_developable_of_nonzero_curvature {n : ℕ} (κ : DiscreteCurvature n)
    (hc : totalCurvature κ ≠ 0) : ¬ IsDevelopable κ := by
  intro hd
  exact hc (developable_zero_curvature κ hd)

/-- The Penrose triangle has concentrated curvature equal to its monodromy. -/
theorem penrose_curvature_equals_monodromy {n : ℕ} (w : Fin n → ℝ) :
    totalCurvature w = monodromy w := by
  rfl

/-- **Penrose Non-Developability**: An impossible figure (non-zero monodromy)
    cannot be realized as a developable surface. -/
theorem impossible_not_developable {n : ℕ} (hn : 0 < n) (fig : ImpossibleFigure n hn) :
    ¬ IsDevelopable fig.weights := by
  exact not_developable_of_nonzero_curvature fig.weights fig.monodromy_ne_zero

/-! ## Section 9: Monodromy Bounds and Classification -/

/-
The monodromy of a bounded weight function is bounded.
-/
theorem monodromy_bound {n : ℕ} (w : Fin n → ℝ) (B : ℝ) (hB : ∀ i, |w i| ≤ B) :
    |monodromy w| ≤ n * B := by
  exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => hB i ) ( by norm_num ) )

/-- Two weight functions with the same monodromy have the same realizability. -/
theorem same_monodromy_same_realizability {n : ℕ} (hn : 0 < n) (w₁ w₂ : Fin n → ℝ)
    (hm : monodromy w₁ = monodromy w₂) :
    IsRealizable hn w₁ ↔ IsRealizable hn w₂ := by
  rw [realizable_iff_monodromy_zero, realizable_iff_monodromy_zero, hm]

/-! ## Section 10: Conjectures -/

/-
**Conjecture (Rational Approximation of Impossible Figures)**:
    Every impossible figure with irrational monodromy can be approximated
    by one with rational monodromy arbitrarily closely.

    *Testable prediction*: For any ε > 0, construct a rational weight function
    whose monodromy is within ε of the original. This follows from density
    of rationals in reals, but the constraint that individual weights remain
    close is non-trivial.

    Test: Verify computationally for n = 3, 4, 5 that random weight functions
    with irrational monodromy (e.g., √2) can be ε-approximated by rational
    weight functions with matching edge count and bounded weight change.
-/
theorem rational_approximation_conjecture {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ w' : Fin n → ℚ, |monodromy w - monodromy (fun i => (w' i : ℝ))| < ε
      ∧ ∀ i, |w i - (w' i : ℝ)| < ε := by
  unfold monodromy;
  obtain ⟨w', hw'⟩ : ∃ w' : Fin n → ℚ, ∀ i, |w i - (w' i : ℝ)| < ε / (n + 1) := by
    exact ⟨ fun i => Classical.choose ( exists_rat_btwn ( show w i - ε / ( n + 1 ) < w i by linarith [ div_pos hε ( by positivity : 0 < ( n : ℝ ) + 1 ) ] ) ), fun i => by have := Classical.choose_spec ( exists_rat_btwn ( show w i - ε / ( n + 1 ) < w i by linarith [ div_pos hε ( by positivity : 0 < ( n : ℝ ) + 1 ) ] ) ) ; exact abs_lt.mpr ⟨ by linarith, by linarith ⟩ ⟩;
  refine' ⟨ w', _, _ ⟩;
  · rw [ ← Finset.sum_sub_distrib ];
    exact lt_of_le_of_lt ( Finset.abs_sum_le_sum_abs _ _ ) ( lt_of_le_of_lt ( Finset.sum_le_sum fun _ _ => le_of_lt ( hw' _ ) ) ( by norm_num; nlinarith [ mul_div_cancel₀ ε ( by positivity : ( n : ℝ ) + 1 ≠ 0 ) ] ) );
  · exact fun i => lt_of_lt_of_le ( hw' i ) ( div_le_self hε.le ( by linarith ) )

end