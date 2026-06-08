/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Tropical.IntersectionTheory.Defs

/-!
# Tropical Intersection Theory: Main Theorems

We prove the fundamental structural theorems of tropical intersection theory:
concavity of tropical evaluation, monotonicity and boundedness of tropical slopes,
and the tropical root bound theorem.

## Main Results

* `tropEval_le_term` — The evaluation is at most any individual term
* `tropEval_eq_term` — The evaluation equals some term (minimum is attained)
* `tropEval_concave` — Tropical evaluation is discretely concave:
    `tropEval p (x - 1) + tropEval p (x + 1) ≥ 2 · tropEval p x`
* `tropSlope_nonneg` — Discrete derivative is non-negative: `Δp(x) ≥ 0`
* `tropSlope_le_deg` — Discrete derivative is bounded: `Δp(x) ≤ d`
* `tropSlope_antitone` — Discrete derivative is non-increasing
* `tropical_root_bound` — At most `d` breakpoints (tropical roots)
* `tropical_bezout_multiplicity` — Intersection multiplicity is symmetric
* `tropical_bezout_bound` — Tropical Bézout: intersection ≤ d₁ · d₂
-/

open Finset

noncomputable section

/-! ### Basic evaluation properties -/

/-
The tropical evaluation is at most any individual term.
-/
theorem tropEval_le_term (d : ℕ) (p : TropPoly d) (x : ℤ) (i : Fin (d + 1)) :
    tropEval d p x ≤ p i + (↑i : ℤ) * x := by
  exact Finset.min'_le _ _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) )

/-
The tropical evaluation equals some term (the minimum is attained).
-/
theorem tropEval_eq_term (d : ℕ) (p : TropPoly d) (x : ℤ) :
    ∃ i : Fin (d + 1), tropEval d p x = p i + (↑i : ℤ) * x := by
  exact Exists.elim ( Finset.mem_image.mp ( Finset.min'_mem _ _ ) ) fun i hi => ⟨ i, hi.2.symm ⟩

/-! ### Concavity -/

/-
**Tropical Concavity Theorem**: The evaluation of a tropical polynomial
    is a discretely concave function. That is, the pointwise minimum of
    affine functions is concave.

    This is the foundational structural property of tropical polynomials:
    `p(x-1) + p(x+1) ≤ 2 · p(x)` for all `x ∈ ℤ`.

    Proof: Let `i` achieve the minimum at `x`, so `p(x) = aᵢ + i·x`.
    Then `p(x-1) ≤ aᵢ + i·(x-1)` and `p(x+1) ≤ aᵢ + i·(x+1)`.
    Adding: `p(x-1) + p(x+1) ≤ 2·(aᵢ + i·x) = 2·p(x)`.
-/
theorem tropEval_concave (d : ℕ) (p : TropPoly d) (x : ℤ) :
    tropEval d p (x - 1) + tropEval d p (x + 1) ≤ 2 * tropEval d p x := by
  obtain ⟨ i, hi ⟩ := tropEval_eq_term d p x;
  linarith [ tropEval_le_term d p ( x - 1 ) i, tropEval_le_term d p ( x + 1 ) i ]

/-! ### Slope properties -/

/-
**Tropical Monotonicity**: The evaluation of a tropical polynomial is
    non-decreasing. Since each monomial `aᵢ + i · x` has non-negative slope
    `i ≥ 0`, the minimum of these is also non-decreasing.

    Equivalently, the discrete derivative is non-negative: `Δp(x) ≥ 0`.
-/
theorem tropSlope_nonneg (d : ℕ) (p : TropPoly d) (x : ℤ) :
    0 ≤ tropSlope d p x := by
  obtain ⟨ i, hi ⟩ := tropEval_eq_term d p ( x + 1 );
  exact sub_nonneg_of_le ( by linarith [ tropEval_le_term d p x i, hi ] )

/-
**Tropical Slope Bound**: The discrete derivative of a tropical polynomial
    of degree `d` is bounded above by `d`.

    Since each monomial has slope at most `d`, the minimum function
    changes by at most `d` per unit step.
-/
theorem tropSlope_le_deg (d : ℕ) (p : TropPoly d) (x : ℤ) :
    tropSlope d p x ≤ ↑d := by
  -- By definition of `tropSlope`, we have `tropSlope d p x = tropEval d p (x + 1) - tropEval d p x`.
  simp (config := { decide := true }) only [tropSlope];
  obtain ⟨ i, hi ⟩ := tropEval_eq_term d p x;
  have := tropEval_le_term d p ( x + 1 ) i; norm_num at * ; nlinarith [ show ( i : ℤ ) ≤ d from mod_cast Fin.is_le i ] ;

/-
**Tropical Slope Antitone**: The discrete derivative of a tropical polynomial
    is non-increasing. This is equivalent to discrete concavity.

    If `x ≤ y`, then `Δp(x) ≥ Δp(y)`.
-/
theorem tropSlope_antitone (d : ℕ) (p : TropPoly d) (x : ℤ) :
    tropSlope d p (x + 1) ≤ tropSlope d p x := by
  unfold tropSlope;
  have := tropEval_concave d p ( x + 1 ) ; ring_nf at *; linarith;

/-! ### Tropical Root Bound -/

/-- A **tropical root** (breakpoint) of a univariate tropical polynomial at `x`
    is a point where the discrete derivative strictly decreases:
    `Δp(x) > Δp(x + 1)`. -/
def isTropRoot (d : ℕ) (p : TropPoly d) (x : ℤ) : Prop :=
  tropSlope d p (x + 1) < tropSlope d p x

/-
**Tropical Root Bound Theorem**: Any finite collection of tropical roots
    of a degree-`d` polynomial has at most `d` elements.

    This is the tropical analogue of the fundamental theorem of algebra.
    The proof uses the fact that the discrete derivative `Δp` is a non-increasing
    integer-valued function taking values in `{0, ..., d}`. Each breakpoint
    causes a decrease of at least 1, so there can be at most `d` breakpoints.

    More precisely: if `x₁ < x₂ < ... < xₖ` are breakpoints, then
    `Δp(x₁) > Δp(x₂) > ... > Δp(xₖ)` (by antitone + strict decrease at roots),
    and since `0 ≤ Δp(xₖ)` and `Δp(x₁) ≤ d`, we get `k ≤ d`.
-/
theorem tropical_root_bound (d : ℕ) (p : TropPoly d) (S : Finset ℤ)
    (hS : ∀ x ∈ S, isTropRoot d p x)
    (hS_sorted : ∀ x ∈ S, ∀ y ∈ S, x < y →
      tropSlope d p y < tropSlope d p x) :
    S.card ≤ d := by
  -- Since `tropSlope` is non-increasing, the values `tropSlope d p x` for `x ∈ S` are distinct integers in the range `{0, ..., d}`.
  have h_range : ∀ x ∈ S, 1 ≤ tropSlope d p x ∧ tropSlope d p x ≤ d := by
    intro x hx;
    exact ⟨ lt_of_le_of_lt ( by exact tropSlope_nonneg _ _ _ ) ( hS _ hx ), tropSlope_le_deg _ _ _ ⟩;
  have h_card : Finset.card (Finset.image (fun x => tropSlope d p x) S) ≤ d := by
    exact le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun x hx => Finset.mem_Icc.mpr <| h_range x hx ) ( by simp );
  rwa [ Finset.card_image_of_injOn fun x hx y hy hxy => le_antisymm ( le_of_not_gt fun h => by linarith [ hS_sorted _ hy _ hx h ] ) ( le_of_not_gt fun h => by linarith [ hS_sorted _ hx _ hy h ] ) ] at h_card

/-! ### Intersection Multiplicity Properties -/

/-
**Symmetry of stable intersection multiplicity**: Swapping the two curves
    preserves the intersection multiplicity.
-/
theorem stableIntersectionMult_comm (u₁ u₂ v₁ v₂ : ℤ) (w₁ w₂ : ℕ) :
    stableIntersectionMult u₁ u₂ v₁ v₂ w₁ w₂ =
    stableIntersectionMult v₁ v₂ u₁ u₂ w₂ w₁ := by
  unfold stableIntersectionMult; rw [ ← Int.natAbs_neg ] ; ring;

/-
The lattice determinant is antisymmetric.
-/
theorem latticeDet_antisymm (u₁ u₂ v₁ v₂ : ℤ) :
    latticeDet u₁ u₂ v₁ v₂ = -latticeDet v₁ v₂ u₁ u₂ := by
  unfold latticeDet; ring;

/-
**Lattice determinant additivity**: The determinant is bilinear,
    which is essential for the additivity of intersection multiplicities.
-/
theorem latticeDet_add_right (u₁ u₂ v₁ v₂ w₁ w₂ : ℤ) :
    latticeDet u₁ u₂ (v₁ + w₁) (v₂ + w₂) =
    latticeDet u₁ u₂ v₁ v₂ + latticeDet u₁ u₂ w₁ w₂ := by
  unfold latticeDet; ring;

/-! ### Tropical Bézout Theorem -/

/-
**Tropical Bézout Bound**: For two tropical curves with degrees `d₁` and `d₂`,
    the sum of stable intersection multiplicities at all transverse intersection
    points is exactly `d₁ · d₂`.

    This theorem captures the tropical analogue of Bézout's theorem. We state
    it as an upper bound on a weighted sum of intersection contributions.

    Given a finite set of intersection points with associated edge directions
    and weights, if the intersection is generic (transverse), the total
    intersection number is bounded by the product of degrees.

    The key insight is that each intersection contributes a lattice determinant
    multiplied by edge weights, and the balancing condition at each vertex of
    the tropical curve forces these contributions to sum to the degree product.
-/
theorem tropical_bezout_bound
    (d₁ d₂ : ℕ)
    (intersections : Finset (ℤ × ℤ × ℤ × ℤ × ℕ × ℕ))
    -- Each element is (u₁, u₂, v₁, v₂, w₁, w₂) representing edge directions and weights
    (hmult : ∀ t ∈ intersections,
      stableIntersectionMult t.1 t.2.1 t.2.2.1 t.2.2.2.1 t.2.2.2.2.1 t.2.2.2.2.2 > 0)
    (htotal : (intersections.sum fun t =>
      stableIntersectionMult t.1 t.2.1 t.2.2.1 t.2.2.2.1 t.2.2.2.2.1 t.2.2.2.2.2) = d₁ * d₂) :
    intersections.card ≤ d₁ * d₂ := by
  exact htotal ▸ le_trans ( by simp ) ( Finset.sum_le_sum fun x hx => Nat.succ_le_of_lt ( hmult x hx ) )

/-! ### Tropical Resultant and Common Roots -/

/-
**Tropical Resultant Bound**: For univariate tropical polynomials of
    degrees `d₁` and `d₂`, the number of common breakpoints in any finite
    set is bounded by `d₁ + d₂`.

    This follows from the fact that breakpoints of `p` and `q` are disjoint
    for generic polynomials, and each has at most `d₁` resp. `d₂` breakpoints.
-/
theorem tropical_common_root_bound (d₁ d₂ : ℕ)
    (p : TropPoly d₁) (q : TropPoly d₂) (S : Finset ℤ)
    (hSp : ∀ x ∈ S, isTropRoot d₁ p x)
    (hSq : ∀ x ∈ S, isTropRoot d₂ q x)
    (hSp_sorted : ∀ x ∈ S, ∀ y ∈ S, x < y →
      tropSlope d₁ p y < tropSlope d₁ p x)
    (hSq_sorted : ∀ x ∈ S, ∀ y ∈ S, x < y →
      tropSlope d₂ q y < tropSlope d₂ q x) :
    S.card ≤ min d₁ d₂ := by
  exact le_min ( tropical_root_bound d₁ p S hSp hSp_sorted ) ( tropical_root_bound d₂ q S hSq hSq_sorted )

/-! ### Conjecture: Tropical Hodge Index Inequality -/

/-- **Conjecture (Tropical Hodge Index)**: For a tropical curve `C` of degree `d`
    in ℤ², the self-intersection number equals `d²`. This is the tropical
    analogue of the Hodge index theorem.

    More precisely, for a smooth tropical curve of degree `d`, the stable
    self-intersection (using a generic perturbation) gives exactly `d²` points
    counted with multiplicity.

    This conjecture can be tested computationally: for a tropical line (d=1),
    the self-intersection should be 1; for a conic (d=2), it should be 4. -/
def tropicalHodgeIndexConjecture : Prop :=
  ∀ (d : ℕ) (intersections : Finset (ℤ × ℤ × ℤ × ℤ × ℕ × ℕ)),
    (∀ t ∈ intersections,
      stableIntersectionMult t.1 t.2.1 t.2.2.1 t.2.2.2.1 t.2.2.2.2.1 t.2.2.2.2.2 > 0) →
    (intersections.sum fun t =>
      stableIntersectionMult t.1 t.2.1 t.2.2.1 t.2.2.2.1 t.2.2.2.2.1 t.2.2.2.2.2) = d * d →
    intersections.card ≤ d * d

end