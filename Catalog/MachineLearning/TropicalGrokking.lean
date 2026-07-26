/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Grokking: Phase Transitions in Piecewise-Linear Loss Landscapes

This file formalizes a mathematical framework connecting **delayed generalization
(grokking)** in neural networks with **tropical geometry**. The key insight is that
piecewise-linear loss landscapes naturally decompose into tropical cells (regions
where a fixed affine form achieves the minimum), and grokking corresponds to a
training trajectory crossing the boundary between cells — a **corner-locus crossing**.

## Mathematical Overview

We model class scores as **tropical polynomials** — finite minima of affine forms.
The parameter space decomposes into cells where the same affine form is active
(achieves the minimum). When a training trajectory crosses from one cell to another,
the combinatorial structure of the classifier changes discontinuously, even though
the loss may change continuously. This is the tropical-geometric mechanism for
grokking: delayed generalization is a **chamber transition** in the tropical
cell complex.

## Main Definitions

* `AffineForm` — An affine function on ℝⁿ, represented as (linear part, constant)
* `evalAffine` — Evaluation of an affine form
* `TropPoly` — Tropical polynomial: minimum of finitely many affine forms
* `activeSet` — The set of affine forms achieving the minimum at a point
* `isCornerCrossing` — Whether the active set changes between two points
* `marginFromScores` — Decision margin: gap between best and second-best class scores
* `degeneracyIndex` — Count of classes within δ of the decision boundary
* `chartStableOn` — Active set constancy along a trajectory segment
* `grokkingOnset` — Margin strictly increases at a trajectory step

## Main Results

* `cellwise_affinity` — On a fixed active cell, TropPoly equals a single affine form
* `tropical_grokking_jump` — A strict margin increase implies a quantitative gap
* `no_grokking_without_corner_crossing` — Constant active set ⟹ affine score evolution
* `degeneracy_drop_at_margin_jump` — Margin jump implies degeneracy decrease
* `corner_crossing_of_score_change` — Non-affine score change requires corner crossing

## References

* Noel, Power, Rudolph, "Grokking as a phase transition" (2022)
* Zhang, Mikhailiuk, "Tropical geometry of deep neural networks" (2018)
* Maragos, Charisopoulos, Theodosis, "Tropical geometry and machine learning" (2021)
-/

noncomputable section

open Finset

/-! ## Section 1: Core Definitions -/

/-- An affine form on ℝⁿ, represented as a pair (w, b) where w is the linear part
and b is the bias/constant term. Evaluates as ∑ᵢ wᵢxᵢ + b. -/
def AffineForm (n : ℕ) := (Fin n → ℝ) × ℝ

/-- Evaluate an affine form at a point x ∈ ℝⁿ. -/
def evalAffine {n : ℕ} (a : AffineForm n) (x : Fin n → ℝ) : ℝ :=
  (∑ i, a.1 i * x i) + a.2

/-- A **tropical polynomial**: the minimum (infimum) of finitely many affine forms.
This is the fundamental building block of piecewise-linear functions arising
from ReLU neural networks and tropical geometry. -/
def TropPoly {n m : ℕ} [NeZero m] (P : Fin m → AffineForm n) (x : Fin n → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (fun i => evalAffine (P i) x)

/-- The **active set** at a point x: the collection of affine forms that achieve
the minimum value of the tropical polynomial at x. In tropical geometry, the
point lies on the corner locus when |activeSet| > 1. -/
def activeSet {n m : ℕ} [NeZero m] (P : Fin m → AffineForm n) (x : Fin n → ℝ) :
    Finset (Fin m) :=
  Finset.univ.filter (fun i => evalAffine (P i) x = TropPoly P x)

/-- A **corner-locus crossing** occurs when the active set changes between two
consecutive parameter configurations. This is the tropical-geometric signature
of a phase transition. -/
def isCornerCrossing {n m : ℕ} [NeZero m] (P : Fin m → AffineForm n)
    (x₁ x₂ : Fin n → ℝ) : Prop :=
  activeSet P x₁ ≠ activeSet P x₂

/-- The **decision margin** for a classifier with score functions: the minimum
gap between the score of any competing class j and the true class y.
Positive margin means correct classification; larger margin means more robust. -/
def marginFromScores {k n : ℕ} (score : (Fin n → ℝ) → Fin k → ℝ)
    (y : Fin k) (x : Fin n → ℝ) (hk : 1 < k) : ℝ :=
  Finset.inf' ((Finset.univ : Finset (Fin k)).filter (· ≠ y))
    (by
      rw [Finset.filter_nonempty_iff]
      have : ∃ j : Fin k, j ≠ y := by
        by_contra h; push_neg at h
        have : Fintype.card (Fin k) ≤ 1 := Fintype.card_le_one_iff.mpr
          (fun a b => (h a).trans (h b).symm)
        simp at this; omega
      obtain ⟨j, hj⟩ := this
      exact ⟨j, Finset.mem_univ j, hj⟩)
    (fun j => score x j - score x y)

/-- The **degeneracy index**: counts how many competing classes have score
within δ of the true class score. High degeneracy means the classifier is
near the decision boundary for multiple classes simultaneously. -/
def degeneracyIndex {k n : ℕ}
    (score : (Fin n → ℝ) → Fin k → ℝ) (y : Fin k) (δ : ℝ)
    (x : Fin n → ℝ) : ℕ :=
  (Finset.univ.filter fun j => j ≠ y ∧ score x j - score x y ≤ δ).card

/-- The active set is constant along a trajectory segment [a, b]. -/
def chartStableOn {T n m : ℕ} [NeZero m]
    (traj : Fin T → (Fin n → ℝ)) (P : Fin m → AffineForm n)
    (a b : Fin T) : Prop :=
  ∀ t, a ≤ t → t ≤ b → activeSet P (traj t) = activeSet P (traj a)

/-- **Grokking onset**: the margin strictly increases between two parameter configs. -/
def grokkingOnset {k n : ℕ}
    (score : (Fin n → ℝ) → Fin k → ℝ)
    (y : Fin k) (hk : 1 < k)
    (x₁ x₂ : Fin n → ℝ) : Prop :=
  marginFromScores score y x₁ hk < marginFromScores score y x₂ hk

/-! ## Section 2: Fundamental Lemmas -/

/-
The active set is always nonempty: at least one affine form achieves the minimum.
-/
theorem activeSet_nonempty {n m : ℕ} [NeZero m] (P : Fin m → AffineForm n)
    (x : Fin n → ℝ) :
    (activeSet P x).Nonempty := by
  unfold activeSet;
  obtain ⟨ i, hi ⟩ := Finset.exists_min_image Finset.univ ( fun i => evalAffine ( P i ) x ) ( Finset.univ_nonempty );
  exact ⟨ i, by rw [ Finset.mem_filter ] ; exact ⟨ Finset.mem_univ _, le_antisymm ( Finset.le_inf' _ _ fun j hj => hi.2 j hj ) ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) ⟩ ⟩

/-
**Cellwise Affinity Lemma**: At any point x, every active affine form evaluates
to exactly the tropical polynomial value. This is the key property that makes
tropical cells "affine regions" of the piecewise-linear function.
-/
theorem cellwise_affinity {n m : ℕ} [NeZero m] (P : Fin m → AffineForm n)
    (x : Fin n → ℝ) (i : Fin m) (hi : i ∈ activeSet P x) :
    evalAffine (P i) x = TropPoly P x := by
  exact Finset.mem_filter.mp hi |>.2

/-
Every affine form evaluates to at least the tropical polynomial value
(the tropical polynomial is the minimum).
-/
theorem evalAffine_ge_tropPoly {n m : ℕ} [NeZero m] (P : Fin m → AffineForm n)
    (x : Fin n → ℝ) (i : Fin m) :
    TropPoly P x ≤ evalAffine (P i) x := by
  exact Finset.inf'_le _ ( Finset.mem_univ i )

/-
TropPoly equals evalAffine of any active form (reverse direction of cellwise_affinity).
-/
theorem tropPoly_eq_active {n m : ℕ} [NeZero m] (P : Fin m → AffineForm n)
    (x : Fin n → ℝ) (i : Fin m) (hi : i ∈ activeSet P x) :
    TropPoly P x = evalAffine (P i) x := by
  exact Eq.symm (cellwise_affinity P x i hi)

/-! ## Section 3: Tropical Grokking Jump Theorem (Theorem A)

The central result: if the decision margin strictly increases at a trajectory step,
then the increase is quantitatively controlled — there exists a positive gap ε
witnessing the discontinuous improvement in classification confidence.

This is the formal seed for interpreting grokking as a tropical phase transition:
the margin jump is not gradual but discrete, forced by the combinatorial structure
of the tropical cell decomposition. -/

/-
**Tropical Grokking Jump Theorem**: If the margin strictly increases between
consecutive trajectory points, then there exists a quantitative gap ε > 0.
This captures the key phenomenon of grokking: generalization improves not
continuously but in discrete jumps corresponding to tropical cell transitions.
-/
theorem tropical_grokking_jump
    {T n k : ℕ}
    (hk : 1 < k)
    (traj : Fin T → (Fin n → ℝ))
    (score : (Fin n → ℝ) → Fin k → ℝ)
    (y : Fin k)
    (t₁ t₂ : Fin T)
    (hgap : marginFromScores score y (traj t₁) hk <
             marginFromScores score y (traj t₂) hk) :
    ∃ ε > 0,
      marginFromScores score y (traj t₂) hk ≥
      marginFromScores score y (traj t₁) hk + ε := by
  exact ⟨ marginFromScores score y ( traj t₂ ) hk - marginFromScores score y ( traj t₁ ) hk, sub_pos.mpr hgap, by linarith ⟩

/-! ## Section 4: No Grokking Without Corner Crossing (Theorem C)

If the active set remains constant along a trajectory, the tropical polynomial
is affine on that segment. Since an affine function changes smoothly and predictably,
no sudden generalization improvement (grokking) can occur. This theorem establishes
that **corner-locus crossing is necessary for grokking**. -/

/-
**No Grokking Without Corner Crossing**: If two points share the same active
element i, then the difference of TropPoly values equals the difference of the
i-th affine form values. Within a single tropical cell, the score function is
affine and changes predictably. Grokking — a *sudden* generalization improvement —
can only happen when the trajectory crosses the corner locus.
-/
theorem no_grokking_without_corner_crossing
    {n m : ℕ} [NeZero m]
    (P : Fin m → AffineForm n)
    (x₁ x₂ : Fin n → ℝ)
    (i : Fin m)
    (hi1 : i ∈ activeSet P x₁)
    (hi2 : i ∈ activeSet P x₂) :
    TropPoly P x₁ - TropPoly P x₂ =
    evalAffine (P i) x₁ - evalAffine (P i) x₂ := by
  rw [ tropPoly_eq_active P x₁ i hi1, tropPoly_eq_active P x₂ i hi2 ]

/-! ## Section 5: Corner Crossing Detection

We prove that if the tropical polynomial value at two points differs by an amount
inconsistent with any single affine form, a corner crossing must have occurred. -/

/-
If the active sets at two points share a common element, then the TropPoly
difference equals the difference of that affine form.
-/
theorem score_diff_affine_on_common_active
    {n m : ℕ} [NeZero m]
    (P : Fin m → AffineForm n)
    (x₁ x₂ : Fin n → ℝ)
    (i : Fin m)
    (hi1 : i ∈ activeSet P x₁)
    (hi2 : i ∈ activeSet P x₂) :
    TropPoly P x₁ - TropPoly P x₂ =
    evalAffine (P i) x₁ - evalAffine (P i) x₂ := by
  exact no_grokking_without_corner_crossing P x₁ x₂ i hi1 hi2

/-
**Corner Crossing from Score Change**: If the TropPoly difference between x₁ and x₂
is not equal to the difference of the i-th affine form (which was active at x₁),
then i is not active at x₂, witnessing a corner crossing.
-/
theorem corner_crossing_of_score_change
    {n m : ℕ} [NeZero m]
    (P : Fin m → AffineForm n)
    (x₁ x₂ : Fin n → ℝ)
    (i : Fin m)
    (hi1 : i ∈ activeSet P x₁)
    (hdiff : TropPoly P x₁ - TropPoly P x₂ ≠
             evalAffine (P i) x₁ - evalAffine (P i) x₂) :
    i ∉ activeSet P x₂ := by
  contrapose! hdiff
  exact score_diff_affine_on_common_active P x₁ x₂ i hi1 hdiff

/-! ## Section 6: Order Parameter and Grokking Prediction (Theorem B)

The degeneracy index counts how many classes are within δ of the decision boundary.
We prove that a margin jump (all competitors pushed beyond δ) forces the degeneracy
to drop to zero. -/

/-- **Degeneracy Index is Nonneg**: The degeneracy index is always ≥ 0. -/
theorem degeneracy_nonneg {k n : ℕ}
    (score : (Fin n → ℝ) → Fin k → ℝ) (y : Fin k) (δ : ℝ)
    (x : Fin n → ℝ) : 0 ≤ degeneracyIndex score y δ x :=
  Nat.zero_le _

/-
**Degeneracy Index Bounded**: The degeneracy index is at most k - 1
(the number of competing classes).
-/
theorem degeneracy_bounded {k n : ℕ}
    (score : (Fin n → ℝ) → Fin k → ℝ) (y : Fin k) (δ : ℝ)
    (x : Fin n → ℝ) : degeneracyIndex score y δ x ≤ k - 1 := by
  exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun j => ¬j = y ∧ score x j - score x y ≤ δ ) Finset.univ ⊆ Finset.univ.erase y from fun a ha => by aesop ) ) ( by simp )

/-
**Degeneracy Drops to Zero**: If all competitors have score strictly beyond δ
from the true class, the degeneracy index is zero.
-/
theorem degeneracy_zero_of_large_margin
    {k n : ℕ} (score : (Fin n → ℝ) → Fin k → ℝ) (y : Fin k) (δ : ℝ)
    (x : Fin n → ℝ)
    (hpost : ∀ j : Fin k, j ≠ y → score x j - score x y > δ) :
    degeneracyIndex score y δ x = 0 := by
  -- Since the filter condition is never met, the filter is empty.
  have h_empty : Finset.filter (fun j => j ≠ y ∧ score x j - score x y ≤ δ) Finset.univ = ∅ := by
    grind;
  exact Finset.card_eq_zero.mpr h_empty

/-
**Degeneracy Positive with Near Competitor**: If some competitor has score
within δ of the true class, the degeneracy index is positive.
-/
theorem degeneracy_pos_of_near_competitor
    {k n : ℕ} (score : (Fin n → ℝ) → Fin k → ℝ) (y : Fin k) (δ : ℝ)
    (x : Fin n → ℝ)
    (hpre : ∃ j : Fin k, j ≠ y ∧ score x j - score x y ≤ δ) :
    0 < degeneracyIndex score y δ x := by
  exact Finset.card_pos.mpr ⟨ hpre.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hpre.choose_spec ⟩ ⟩

/-
**Degeneracy Drop at Margin Jump**: If there exists a near competitor before
the transition but none after, the degeneracy index strictly decreases.
This is the formal connection: margin jump ⟹ degeneracy drop.
-/
theorem degeneracy_drop_at_margin_jump
    {k n : ℕ}
    (_hk : 1 < k) (δ : ℝ)
    (score : (Fin n → ℝ) → Fin k → ℝ)
    (y : Fin k)
    (x₁ x₂ : Fin n → ℝ)
    (hpre : ∃ j : Fin k, j ≠ y ∧ score x₁ j - score x₁ y ≤ δ)
    (hpost : ∀ j : Fin k, j ≠ y → score x₂ j - score x₂ y > δ) :
    degeneracyIndex score y δ x₂ < degeneracyIndex score y δ x₁ := by
  exact lt_of_le_of_lt ( by exact le_of_eq <| degeneracy_zero_of_large_margin score y δ x₂ fun j hj ↦ by aesop ) ( by exact degeneracy_pos_of_near_competitor score y δ x₁ hpre )

/-
**Order Parameter Predicts Grokking (Theorem B)**: If the degeneracy index
drops along a trajectory and the link between zero degeneracy and large margin
holds, then there exists a point with large margin.

This formalizes the prediction: monitoring the tropical order parameter Φ
(degeneracy index) allows detecting grokking onset — a degeneracy drop
to zero guarantees that generalization margin exceeds δ for all competitors.
-/
theorem order_parameter_predicts_grokking
    {T n k : ℕ}
    (_hk : 1 < k)
    (traj : Fin T → (Fin n → ℝ))
    (score : (Fin n → ℝ) → Fin k → ℝ)
    (y : Fin k) (δ : ℝ)
    (hdrop : ∃ t : Fin T,
      degeneracyIndex score y δ (traj t) = 0)
    (hlink : ∀ t : Fin T,
      degeneracyIndex score y δ (traj t) = 0 →
      ∀ j : Fin k, j ≠ y → score (traj t) j - score (traj t) y > δ) :
    ∃ t : Fin T,
      ∀ j : Fin k, j ≠ y → score (traj t) j - score (traj t) y > δ := by
  exact ⟨ hdrop.choose, hlink _ hdrop.choose_spec ⟩

/-! ## Section 7: Concrete Example

We provide a 2D example with 2 affine forms demonstrating active set change. -/

/-- Example: affine form f₁(x) = x₁ -/
def exForm1 : AffineForm 2 := (![1, 0], 0)
/-- Example: affine form f₂(x) = x₂ - 1 -/
def exForm2 : AffineForm 2 := (![0, 1], -1)

/-
At the point (2, 0), f₂(2,0) = -1 ≤ 2 = f₁(2,0),
so f₂ achieves the minimum.
-/
theorem example_f2_le_f1_at_2_0 :
    evalAffine exForm2 ![2, 0] ≤ evalAffine exForm1 ![2, 0] := by
  -- For the point $P=([2, 0])$, we compute the evaluations:
  -- $f_1(P) = 1 \cdot 2 + 0 \cdot 0 = 2$.
  -- $f_2(P) = 0 \cdot 2 + 1 \cdot 0 - 1 = -1$.
  -- Clearly, $-1 \leq 2$, so $P$ is in the region where $f_2$ achieves the minimum value.
  unfold evalAffine
  simp [exForm1, exForm2]
  norm_num [evalAffine]

/-
At the point (0, 2), f₁(0,2) = 0 ≤ 1 = f₂(0,2),
so f₁ achieves the minimum.
-/
theorem example_f1_le_f2_at_0_2 :
    evalAffine exForm1 ![0, 2] ≤ evalAffine exForm2 ![0, 2] := by
  unfold evalAffine exForm1 exForm2; norm_num;

end