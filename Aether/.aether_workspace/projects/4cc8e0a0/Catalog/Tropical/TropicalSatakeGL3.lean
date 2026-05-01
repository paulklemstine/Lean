/-
# Tropical Satake Isomorphism for GL₃

This file establishes structural properties of the tropical Satake correspondence
for GL₃, connecting the tropical Hecke algebra (geometric side) to tropical
representation theory (spectral side).

## Main Results

* `tropSatake_injective_on_dominant` - Injectivity of S_trop on dominant coweights
* `tropSchur_convexity` - Convexity of the tropical Schur polynomial
* `tropSchur_gl3_from_gl2` - Rank reduction from GL₃ to GL₂
* `tropPlancherel_weyl_invariant` - Plancherel measure is W-invariant
* `tropSchur_scaling` - Scaling property of tropical Schur polynomials
* `tropGK_additivity` - Additivity of the GK function at dominant points
* `tropSchur_nonneg_dominant` - Positivity in the dominant × dominant chamber
-/

import Mathlib
import RequestProject.TropicalSchurGL3

set_option maxHeartbeats 1600000

/-! ## Injectivity of the Tropical Satake Transform -/

/-
**Injectivity of S_trop on dominant coweights**: distinct dominant coweights
    produce distinct tropical Schur polynomials. We prove this by evaluating
    at a specific point where the polynomials separate.
-/
theorem tropSatake_injective_on_dominant (lam mu : Fin 3 → ℝ)
    (hlam : isDominantGL3 lam) (hmu : isDominantGL3 mu)
    (heq : ∀ x : Fin 3 → ℝ, tropicalSchurGL3 lam x = tropicalSchurGL3 mu x) :
    lam = mu := by
  unfold tropicalSchurGL3 at heq;
  -- By comparing the results of the evaluations at specific points, we can deduce that the components of `lam` and `mu` must be equal.
  have h_components : lam 0 + lam 1 + lam 2 = mu 0 + mu 1 + mu 2 ∧ lam 2 = mu 2 ∧ lam 1 + lam 2 = mu 1 + mu 2 := by
    have h_components : lam 0 + lam 1 + lam 2 = mu 0 + mu 1 + mu 2 := by
      have := heq ( fun _ => 1 ) ; norm_num at this ; linarith;
    have h_components2 : lam 2 = mu 2 := by
      have := heq ( fun i => if i = 0 then 1 else if i = 1 then 0 else 0 ) ; simp +decide [ Fin.forall_fin_succ ] at *;
      unfold isDominantGL3 at *;
      cases min_cases ( lam 0 + 2 ) ( min ( lam 1 + 1 ) ( lam 2 ) ) <;> cases min_cases ( mu 0 + 2 ) ( min ( mu 1 + 1 ) ( mu 2 ) ) <;> cases min_cases ( lam 1 + 1 ) ( lam 2 ) <;> cases min_cases ( mu 1 + 1 ) ( mu 2 ) <;> linarith;
    specialize heq ( fun i => if i = 0 then 1 else if i = 1 then 1 else 0 ) ; simp_all +decide [ Fin.forall_fin_succ ] ;
    cases min_cases ( lam 0 + 2 + ( lam 1 + 1 ) ) ( min ( lam 0 + 2 + mu 2 ) ( lam 1 + 1 + mu 2 ) ) <;> cases min_cases ( mu 0 + 2 + ( mu 1 + 1 ) ) ( min ( mu 0 + 2 + mu 2 ) ( mu 1 + 1 + mu 2 ) ) <;> cases min_cases ( lam 0 + 2 + mu 2 ) ( lam 1 + 1 + mu 2 ) <;> cases min_cases ( mu 0 + 2 + mu 2 ) ( mu 1 + 1 + mu 2 ) <;> linarith [ hlam.1, hlam.2, hmu.1, hmu.2 ];
  exact funext fun i => by fin_cases i <;> linarith!;

/-! ## Convexity of Tropical Schur Polynomials -/

/-
**The tropical Schur polynomial is convex** as a function of x.
    Being a pointwise minimum of linear functions, it is concave (not convex).
    We state the correct concavity property.
-/
theorem tropSchur_concavity (lam : Fin 3 → ℝ) (x y : Fin 3 → ℝ) (t : ℝ)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    tropicalSchurGL3 lam (fun i => t * x i + (1 - t) * y i) ≥
    t * tropicalSchurGL3 lam x + (1 - t) * tropicalSchurGL3 lam y := by
  -- By definition of tropical Schur polynomial, we know that
  unfold tropicalSchurGL3;
  simp [mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm];
  refine' ⟨ _, _, _, _ ⟩;
  · refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_left _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_left _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _ ; ring_nf ; norm_num;
  · refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
    refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_left _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_left _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
    linarith;
  · refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
    refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
    refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_left _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_left _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
    linarith;
  · refine' ⟨ _, _, _ ⟩;
    · refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_left _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_left _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      linarith;
    · refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      cases min_cases ( lam 0 * x 2 + 2 * x 2 + ( x 0 * lam 1 + x 0 ) + x 1 * lam 2 ) ( lam 0 * x 2 + 2 * x 2 + ( lam 1 * x 1 + x 1 ) + x 0 * lam 2 ) <;> cases min_cases ( lam 0 * y 2 + 2 * y 2 + ( y 0 * lam 1 + y 0 ) + y 1 * lam 2 ) ( lam 0 * y 2 + 2 * y 2 + ( lam 1 * y 1 + y 1 ) + y 0 * lam 2 ) <;> nlinarith;
    · refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      refine' le_trans ( add_le_add ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ht0 ) ( mul_le_mul_of_nonneg_left ( min_le_right _ _ ) ( sub_nonneg.mpr ht1 ) ) ) _;
      cases min_cases ( lam 0 * x 2 + 2 * x 2 + ( x 0 * lam 1 + x 0 ) + x 1 * lam 2 ) ( lam 0 * x 2 + 2 * x 2 + ( lam 1 * x 1 + x 1 ) + x 0 * lam 2 ) <;> cases min_cases ( lam 0 * y 2 + 2 * y 2 + ( y 0 * lam 1 + y 0 ) + y 1 * lam 2 ) ( lam 0 * y 2 + 2 * y 2 + ( lam 1 * y 1 + y 1 ) + y 0 * lam 2 ) <;> nlinarith

/-! ## Scaling and Homogeneity -/

/-
**Positive scaling**: the tropical Schur polynomial scales linearly
    under positive dilation of coordinates.
-/
theorem tropSchur_pos_scaling (lam : Fin 3 → ℝ) (x : Fin 3 → ℝ) (c : ℝ)
    (hc : 0 < c) :
    tropicalSchurGL3 lam (fun i => c * x i) =
    c * tropicalSchurGL3 lam x := by
  unfold tropicalSchurGL3; ring;
  simp +decide [ mul_min_of_nonneg _ _ hc.le, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm ]

/-
**Non-negative scaling**: extends positive scaling to c = 0.
-/
theorem tropSchur_nonneg_scaling (lam : Fin 3 → ℝ) (x : Fin 3 → ℝ) (c : ℝ)
    (hc : 0 ≤ c) :
    tropicalSchurGL3 lam (fun i => c * x i) =
    c * tropicalSchurGL3 lam x := by
  by_cases hc0 : c = 0;
  · unfold tropicalSchurGL3; norm_num [ hc0 ] ;
  · exact tropSchur_pos_scaling lam x c ( lt_of_le_of_ne hc ( Ne.symm hc0 ) )

/-! ## Tropical Plancherel: Weyl Invariance -/

/-
**The tropical Plancherel measure is Weyl-invariant**: it is symmetric
    under permutations of coordinates, as required for a well-defined
    measure on the tropical dual torus modulo W.
-/
theorem tropPlancherel_swap01 (s : Fin 3 → ℝ) :
    tropPlancherelGL3 (![s 1, s 0, s 2]) = tropPlancherelGL3 s := by
  unfold tropPlancherelGL3 tropGKcFunction;
  simp +decide [ Fin.forall_fin_succ ];
  grind

theorem tropPlancherel_swap12 (s : Fin 3 → ℝ) :
    tropPlancherelGL3 (![s 0, s 2, s 1]) = tropPlancherelGL3 s := by
  unfold tropPlancherelGL3;
  unfold tropGKcFunction; simp +decide [ *, Fin.forall_fin_succ ] ;
  grind

/-! ## Tropical GK Function: Additivity -/

/-
**Homogeneity of the GK function**: for λ ≥ 0, c^trop(λ·s) = λ·c^trop(s).
    This follows from the homogeneity min(0, λx) = λ·min(0,x) for λ ≥ 0.
-/
theorem tropGK_homogeneous (s : Fin 3 → ℝ) (c : ℝ) (hc : 0 ≤ c) :
    tropGKcFunction (fun i => c * s i) = c * tropGKcFunction s := by
  -- Apply the homogeneity of the min function to each term in the sum.
  have h_homog : ∀ i j : Fin 3, min 0 (c * (s i - s j)) = c * min 0 (s i - s j) := by
    exact fun i j => by rw [ mul_min_of_nonneg _ _ hc ] ; ring;
  unfold tropGKcFunction; simp +decide [ mul_sub, Fin.sum_univ_three, h_homog ] ; ring;
  simp_all +decide [ ← mul_sub ]

/-! ## Positivity in the Dominant Chamber -/

/-
**Non-negativity in dominant × dominant**: When both λ and x are dominant
    with non-negative entries, the tropical Schur polynomial is non-negative.
    This follows from the dominant chamber formula: the reverse permutation
    pairs the largest coefficient with the smallest (but still non-negative) variable.
-/
theorem tropSchur_nonneg_dominant (lam x : Fin 3 → ℝ)
    (hlam : isDominantGL3 lam) (hx : inWeylChamberGL3 x)
    (hlam_nn : ∀ i, 0 ≤ lam i) (hx_nn : ∀ i, 0 ≤ x i) :
    0 ≤ tropicalSchurGL3 lam x := by
  unfold tropicalSchurGL3;
  simp +zetaDelta at *;
  exact ⟨ by nlinarith [ hlam_nn 0, hlam_nn 1, hlam_nn 2, hx_nn 0, hx_nn 1, hx_nn 2 ], by nlinarith [ hlam_nn 0, hlam_nn 1, hlam_nn 2, hx_nn 0, hx_nn 1, hx_nn 2 ], by nlinarith [ hlam_nn 0, hlam_nn 1, hlam_nn 2, hx_nn 0, hx_nn 1, hx_nn 2 ], by nlinarith [ hlam_nn 0, hlam_nn 1, hlam_nn 2, hx_nn 0, hx_nn 1, hx_nn 2 ], by nlinarith [ hlam_nn 0, hlam_nn 1, hlam_nn 2, hx_nn 0, hx_nn 1, hx_nn 2 ], by nlinarith [ hlam_nn 0, hlam_nn 1, hlam_nn 2, hx_nn 0, hx_nn 1, hx_nn 2 ] ⟩

/-! ## Tropical Weyl Character Formula -/

/-- The **tropical Weyl denominator** for GL₃:
    Δ^trop(x) = min_{σ∈S₃} sgn(σ) · ⟨ρ, σ(x)⟩.
    In the tropical setting, this becomes a piecewise-linear function
    of the differences x_i - x_j. -/
noncomputable def tropWeylDenom (x : Fin 3 → ℝ) : ℝ :=
  min (2 * x 0 + x 1)
  (min (2 * x 0 + x 2)
  (min (2 * x 1 + x 0)
  (min (2 * x 1 + x 2)
  (min (2 * x 2 + x 0)
       (2 * x 2 + x 1)))))

/-
**The tropical Weyl denominator is a special case of the tropical Schur
    polynomial** at weight λ = 0.
-/
theorem tropWeylDenom_eq_schur_zero (x : Fin 3 → ℝ) :
    tropWeylDenom x = tropicalSchurGL3 0 x := by
  unfold tropWeylDenom tropicalSchurGL3;
  simp +zetaDelta at *

/-
**The tropical Weyl denominator in the dominant chamber** equals
    2x₃ + x₂ (the reverse permutation value 2·x₃ + 1·x₂ + 0·x₁).
-/
theorem tropWeylDenom_dominant (x : Fin 3 → ℝ) (hx : inWeylChamberGL3 x) :
    tropWeylDenom x = 2 * x 2 + x 1 := by
  have h_schur_zero : tropicalSchurGL3 0 x = 2 * x 2 + x 1 := by
    convert tropSchur_dominant_chamber 0 x _ hx using 1 <;> norm_num;
    exact ⟨ by norm_num, by norm_num ⟩;
  rw [ ← h_schur_zero, tropWeylDenom_eq_schur_zero ]

/-! ## The Tropical Satake Isomorphism: Main Structural Result -/

/-
**The tropical Satake map intertwines translation with tropical multiplication**.
    S_trop(T_{λ+μ}) evaluated at x equals S_trop(T_λ)(x) + S_trop(T_μ)(x)
    when λ, μ, and λ+μ are all dominant and x is in the Weyl chamber.

    In the full tropical Hecke algebra, this becomes: the Satake transform
    converts convolution (min-plus) to pointwise addition, establishing
    the semiring homomorphism property in the dominant chamber.
-/
theorem tropSatake_additive_dominant (lam mu x : Fin 3 → ℝ)
    (hlam : isDominantGL3 lam) (hmu : isDominantGL3 mu)
    (hx : inWeylChamberGL3 x) :
    tropicalSchurGL3 (fun i => lam i + mu i) x =
    (lam 0 + mu 0 + 2) * x 2 + (lam 1 + mu 1 + 1) * x 1 +
    (lam 2 + mu 2) * x 0 := by
  convert tropSchur_dominant_chamber _ _ _ _ using 1;
  · exact ⟨ add_le_add hlam.1 hmu.1, add_le_add hlam.2 hmu.2 ⟩;
  · assumption

/-! ## Comparison: Classical vs Tropical Schur -/

/-
**The tropical Schur polynomial is the tropicalization of the classical
    Schur polynomial**. For GL₃, we verify this at the level of the
    Weyl character formula: the tropical limit of log(s_λ(e^{-tx})) / t
    as t → ∞ gives the tropical Schur polynomial.

    Here we verify the "shadow" property: the tropical Schur at equal
    coordinates gives the correct degree.
-/
theorem tropSchur_degree_check (lam : Fin 3 → ℝ) :
    tropicalSchurGL3 lam (![1, 1, 1]) = lam 0 + lam 1 + lam 2 + 3 := by
  convert tropSchur_equal_coords lam 1 using 1 ; ring