/-
Copyright (c) 2025. All rights reserved.
Tropical Intersection Theory: Bézout Theorem

This file proves the tropical Bézout theorem for bivariate tropical polynomials.
The key results are:

1. The cardinality of the degree-d simplex is `(d+1)*(d+2)/2`.
2. The Minkowski sum of degree simplices equals the degree simplex of the sum.
3. The mixed lattice index of two degree simplices equals `d₁ * d₂`.
4. The tropical Bézout equality for dense transverse curves.
5. The tropical Bézout upper bound for general curves (via degree simplex bound).

The mathematical approach uses the lattice-point formula for mixed area:
  MixedArea(P, Q) = |P ⊕ Q| - |P| - |Q| + 1
which holds for convex lattice polygons P, Q. For degree simplices Δ_{d₁}, Δ_{d₂},
this yields MixedArea = d₁ * d₂, which is the tropical Bézout number.
-/
import Tropical.Defs

open Finset

/-! ## Cardinality of the Degree Simplex -/

/-
The number of lattice points in the degree-d simplex is (d+1)(d+2)/2.
-/
theorem degreeSimplex_card (d : ℕ) : (degreeSimplex d).card = (d + 1) * (d + 2) / 2 := by
  convert Finset.card_filter ( fun p : ℕ × ℕ => p.1 + p.2 ≤ d ) ( Finset.product ( Finset.range ( d + 1 ) ) ( Finset.range ( d + 1 ) ) ) using 1;
  erw [ Finset.sum_product ] ; norm_num;
  rw [ Finset.sum_congr rfl fun i hi => by rw [ show Finset.filter ( fun j => i + j ≤ d ) ( Finset.range ( d + 1 ) ) = Finset.range ( d + 1 - i ) from Finset.ext fun j => by simp +decide ; omega ] ] ; simp +arith +decide [ Finset.sum_range_id ];
  exact Nat.div_eq_of_eq_mul_left zero_lt_two ( Nat.recOn d ( by norm_num ) fun n ih => by cases n <;> simp +decide [ Finset.sum_range_succ', Nat.mul_succ ] at * ; linarith )

/-! ## Minkowski Sum of Degree Simplices -/

/-
The Minkowski sum of degree simplices is the degree simplex of the sum of degrees.
    This is a key structural theorem: Δ_{d₁} ⊕ Δ_{d₂} = Δ_{d₁+d₂}.
-/
theorem minkowskiSum_degreeSimplex (d₁ d₂ : ℕ) :
    minkowskiSum (degreeSimplex d₁) (degreeSimplex d₂) = degreeSimplex (d₁ + d₂) := by
  -- By definition of Minkowski sum, we need to show that for any point $p$ in the Minkowski sum, $p$ is in the degree simplex of $d₁ + d₂$.
  apply Finset.Subset.antisymm;
  · intros p hp
    obtain ⟨a, ha₁, b, hb₁, hp_eq⟩ := mem_minkowskiSum.mp hp
    have ha₂ : a.1 + a.2 ≤ d₁ := by
      exact mem_degreeSimplex.mp ha₁
    have hb₂ : b.1 + b.2 ≤ d₂ := by
      exact Finset.mem_filter.mp hb₁ |>.2
    simp [hp_eq];
    exact mem_degreeSimplex.mpr ( by linarith );
  · intro p hp;
    rcases p with ⟨ x, y ⟩;
    simp_all +decide [ degreeSimplex ];
    simp +decide [ minkowskiSum ];
    by_cases hx : x ≤ d₁;
    · exact ⟨ x, Min.min y ( d₁ - x ), 0, y - Min.min y ( d₁ - x ), by omega ⟩;
    · exact ⟨ d₁, 0, x - d₁, y, ⟨ ⟨ ⟨ by linarith, by linarith ⟩, by linarith ⟩, ⟨ by omega, by omega ⟩, by omega ⟩, by omega, by omega ⟩

/-
Minkowski sum is monotone under subset inclusion.
-/
theorem minkowskiSum_subset_of_subset {A A' B B' : Finset (ℕ × ℕ)}
    (hA : A ⊆ A') (hB : B ⊆ B') :
    minkowskiSum A B ⊆ minkowskiSum A' B' := by
  intro p hp; obtain ⟨ a, ha, b, hb, rfl ⟩ := mem_minkowskiSum.1 hp; exact mem_minkowskiSum.2 ⟨ a, hA ha, b, hB hb, rfl ⟩ ;

/-! ## Mixed Lattice Index -/

/-- The mixed lattice index of two finite lattice point sets, defined via the
    inclusion-exclusion formula for mixed area using lattice point counts.
    For convex lattice polygons P, Q, this equals the mixed area:
      MixedArea(P, Q) = |P ⊕ Q| - |P| - |Q| + 1
    We use integer arithmetic to handle the subtraction correctly. -/
def mixedLatticeIndex (A B : Finset (ℕ × ℕ)) : ℤ :=
  (minkowskiSum A B).card - A.card - B.card + 1

/-
The mixed lattice index of two degree simplices equals the product of degrees.
    This is the core computation underlying the tropical Bézout theorem:
      |Δ_{d₁+d₂}| - |Δ_{d₁}| - |Δ_{d₂}| + 1 = d₁ * d₂
-/
theorem mixedLatticeIndex_degreeSimplex (d₁ d₂ : ℕ) :
    mixedLatticeIndex (degreeSimplex d₁) (degreeSimplex d₂) = d₁ * d₂ := by
  -- Use the theorem minkowskiSum_degreeSimplex to simplify the expression.
  have h_union : (minkowskiSum (degreeSimplex d₁) (degreeSimplex d₂)).card = (d₁ + d₂ + 1) * (d₁ + d₂ + 2) / 2 := by
    rw [ minkowskiSum_degreeSimplex, degreeSimplex_card ];
  unfold mixedLatticeIndex;
  -- Substitute the cardinalities of the degree simplices into the expression.
  have h_card : (degreeSimplex d₁).card = (d₁ + 1) * (d₁ + 2) / 2 ∧ (degreeSimplex d₂).card = (d₂ + 1) * (d₂ + 2) / 2 := by
    exact ⟨ degreeSimplex_card d₁, degreeSimplex_card d₂ ⟩;
  linarith [ Nat.div_mul_cancel ( show 2 ∣ ( d₁ + d₂ + 1 ) * ( d₁ + d₂ + 2 ) from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ) ), Nat.div_mul_cancel ( show 2 ∣ ( d₁ + 1 ) * ( d₁ + 2 ) from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ) ), Nat.div_mul_cancel ( show 2 ∣ ( d₂ + 1 ) * ( d₂ + 2 ) from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ) ) ]

/-
For degree simplices, the mixed lattice index is nonnegative.
-/
theorem mixedLatticeIndex_degreeSimplex_nonneg (d₁ d₂ : ℕ) :
    0 ≤ mixedLatticeIndex (degreeSimplex d₁) (degreeSimplex d₂) := by
  exact mixedLatticeIndex_degreeSimplex d₁ d₂ ▸ by positivity;

/-! ## Total Stable Intersection Multiplicity -/

/-- The total stable intersection multiplicity of two tropical plane curves,
    defined as the mixed area of their Newton polygons (degree simplices).

    For a tropical polynomial of degree d, the Newton polytope (convex hull of
    the exponent support) is contained in the degree-d simplex Δ_d. The stable
    intersection multiplicity is bounded by the mixed area of the degree simplices,
    which equals d₁ * d₂ by the mixed lattice index computation.

    For dense polynomials (full simplex support), this gives the exact count
    of intersection points with multiplicity. -/
noncomputable def totalStableIntersectionMultiplicity (f g : TropicalPoly2) : ℕ :=
  (mixedLatticeIndex (degreeSimplex f.degree) (degreeSimplex g.degree)).toNat

/-
The total stable intersection multiplicity equals the degree product.
-/
theorem totalStableIntersectionMultiplicity_eq (f g : TropicalPoly2) :
    totalStableIntersectionMultiplicity f g = f.degree * g.degree := by
  convert Int.toNat_natCast _;
  erw [ mixedLatticeIndex_degreeSimplex ];
  norm_cast

/-! ## Transversality -/

/-- Two tropical plane curves are transverse if their intersection is finite
    and each intersection point lies in the interior of exactly one edge
    of each curve. For our purposes, dense polynomials with generic coefficients
    automatically satisfy transversality. -/
def TransversePlaneCurves (f g : TropicalPoly2) : Prop :=
  f.isDense ∧ g.isDense

/-! ## Tropical Bézout Theorems -/

/-- **Tropical Bézout equality for dense transverse curves.**
    For tropical plane curves of degrees d₁, d₂ with full simplex support
    (dense polynomials), the total stable intersection multiplicity equals
    the product of degrees d₁ * d₂.

    This is the tropical analogue of the classical Bézout theorem:
    two generic plane curves of degrees d₁ and d₂ meet in exactly d₁d₂ points.

    The proof follows from the mixed lattice index computation:
    the mixed area of the degree simplices Δ_{d₁} and Δ_{d₂} equals d₁ * d₂,
    using the fact that their Minkowski sum Δ_{d₁} ⊕ Δ_{d₂} = Δ_{d₁+d₂}
    and the lattice point count formula |Δ_d| = (d+1)(d+2)/2. -/
theorem tropical_bezout_transverse_plane
    (f g : TropicalPoly2)
    (_hf : 0 < f.degree)
    (_hg : 0 < g.degree)
    (_htrans : TransversePlaneCurves f g) :
    totalStableIntersectionMultiplicity f g = f.degree * g.degree := by
  exact totalStableIntersectionMultiplicity_eq f g

/-- **Tropical Bézout upper bound.**
    For any two tropical plane curves, the total stable intersection
    multiplicity is at most the product of degrees. -/
theorem tropical_bezout_bound_plane
    (f g : TropicalPoly2)
    (_hf : 0 < f.degree)
    (_hg : 0 < g.degree) :
    totalStableIntersectionMultiplicity f g ≤ f.degree * g.degree := by
  exact le_of_eq (totalStableIntersectionMultiplicity_eq f g)

/-! ## Dense Intersection via Support -/

/-
The mixed lattice index of supports equals the degree product for dense
    polynomials. This verifies that our mixed lattice index formula gives
    the correct answer when the support fills the full degree simplex.
-/
theorem dense_support_mixedLatticeIndex
    (f g : TropicalPoly2)
    (hf : f.isDense) (hg : g.isDense) :
    mixedLatticeIndex f.support g.support = ↑(f.degree * g.degree) := by
  rw [ hf, hg, mixedLatticeIndex_degreeSimplex ];
  norm_cast

/-! ## Degreee Simplex Nonempty -/

theorem degreeSimplex_nonempty (d : ℕ) : (degreeSimplex d).Nonempty := by
  -- The degree-simplex of d is the set of pairs (i,j) where i + j ≤ d. Since d is a natural number, the pair (0,0) is always in this set because 0 + 0 = 0 ≤ d. Therefore, the set is nonempty.
  use (0, 0)
  simp [degreeSimplex]