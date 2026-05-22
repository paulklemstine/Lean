import Mathlib

/-!
# Tropical Legendre–Fenchel Duality

This file formalizes a **tropical duality principle** centered on the Legendre–Fenchel
transform for real-valued functions, with the quadratic function `f(x) = x²/2` as the
canonical seed case. The quadratic is a fixed point of the Legendre transform, and this
fact is the gateway connecting classical convex conjugation to tropical (min-plus) algebra.

## Main results

* `fenchel_young_quadratic` — the Fenchel–Young inequality: `x * y ≤ x²/2 + y²/2`
* `fenchel_young_quadratic_eq_iff` — equality holds iff `x = y`
* `legendre_half_sq` — the Legendre transform of `x²/2` is `y²/2`
* `legendre_biconjugate_half_sq` — double conjugation recovers the original function
* `quad_penalty_minimizer` — tropical (inf) reformulation: lower bound
* `quad_penalty_minimizer_eq` — attainment at the optimizer `x = y`
* `tropical_legendre_quadratic` — `sInf` formulation of tropical duality
* `tropical_sup_neg_inf` — bridge between sup and inf via negation (min-max duality)

## Strategy

All proofs reduce to the completing-the-square identity
  `x * y - x²/2 = y²/2 - (x - y)²/2`
combined with nonnegativity of squares. This makes the development entirely algebraic
and avoids importing abstract convex conjugate machinery.
-/

noncomputable section

open Set Real

/-! ## The Legendre–Fenchel Transform -/

/-- The Legendre–Fenchel transform (convex conjugate) of a function `f : ℝ → ℝ`. -/
def legendreTransform (f : ℝ → ℝ) (y : ℝ) : ℝ :=
  sSup (Set.range fun x : ℝ => x * y - f x)

/-! ## Completing the Square — the Algebraic Engine -/

/-- The completing-the-square identity that drives the entire development. -/
theorem complete_the_square (x y : ℝ) :
    x * y - x ^ 2 / 2 = y ^ 2 / 2 - (x - y) ^ 2 / 2 := by ring

/-! ## Fenchel–Young Inequality -/

/-- **Fenchel–Young inequality** for the quadratic: `x * y ≤ x²/2 + y²/2`.
This is the inequality form of Legendre duality and follows from `0 ≤ (x - y)²`. -/
theorem fenchel_young_quadratic (x y : ℝ) :
    x * y ≤ x ^ 2 / 2 + y ^ 2 / 2 := by nlinarith [sq_nonneg (x - y)]

/-- **Fenchel–Young equality characterization**: equality holds iff `x = y`. -/
theorem fenchel_young_quadratic_eq_iff (x y : ℝ) :
    x * y = x ^ 2 / 2 + y ^ 2 / 2 ↔ x = y := by
  constructor
  · intro h; nlinarith [sq_nonneg (x - y)]
  · intro h; subst h; ring

/-! ## Quadratic Legendre Identity -/

/-- Upper bound: for all `x`, `x * y - x²/2 ≤ y²/2`. -/
theorem legendre_quad_upper_bound (x y : ℝ) :
    x * y - x ^ 2 / 2 ≤ y ^ 2 / 2 := by nlinarith [sq_nonneg (x - y)]

/-- Attainment: the supremum is achieved at `x = y`. -/
theorem legendre_quad_attained (y : ℝ) :
    y * y - y ^ 2 / 2 = y ^ 2 / 2 := by ring

/-- The range `{x * y - x²/2 | x : ℝ}` is bounded above by `y²/2`. -/
theorem legendre_quad_bddAbove (y : ℝ) :
    BddAbove (Set.range fun x : ℝ => x * y - x ^ 2 / 2) := by
  exact ⟨y ^ 2 / 2, by rintro _ ⟨x, rfl⟩; exact legendre_quad_upper_bound x y⟩

/-- The range `{x * y - x²/2 | x : ℝ}` is nonempty. -/
theorem legendre_quad_nonempty (y : ℝ) :
    (Set.range fun x : ℝ => x * y - x ^ 2 / 2).Nonempty :=
  ⟨y * y - y ^ 2 / 2, ⟨y, rfl⟩⟩

/-
**Legendre transform of the half-square**: `(x²/2)★(y) = y²/2`.
This is the primary duality theorem: the quadratic is a fixed point of
the Legendre–Fenchel transform.
-/
theorem legendre_half_sq (y : ℝ) :
    legendreTransform (fun x : ℝ => x ^ 2 / 2) y = y ^ 2 / 2 := by
  exact le_antisymm ( csSup_le ( Set.range_nonempty _ ) ( by rintro _ ⟨ x, rfl ⟩ ; linarith [ sq_nonneg ( x - y ) ] ) ) ( le_csSup ⟨ y ^ 2 / 2, by rintro _ ⟨ x, rfl ⟩ ; linarith [ sq_nonneg ( x - y ) ] ⟩ ⟨ y, by ring ⟩ )

/-
**Biconjugation theorem**: double Legendre transform of `x²/2` recovers `x²/2`.
Since the quadratic is its own conjugate, biconjugation is trivially involutive.
-/
theorem legendre_biconjugate_half_sq (x : ℝ) :
    legendreTransform (legendreTransform (fun x : ℝ => x ^ 2 / 2)) x = x ^ 2 / 2 := by
  convert legendre_half_sq x using 1;
  exact congr_arg ( fun f => legendreTransform f x ) ( funext fun x => legendre_half_sq x )

/-! ## Tropical (Min-Plus) Reformulation -/

/-
Lower bound for the quadratic penalty: `x²/2 - x * y ≥ -(y²/2)`.
-/
theorem quad_penalty_minimizer (y : ℝ) :
    ∀ x : ℝ, x ^ 2 / 2 - x * y ≥ -(y ^ 2 / 2) := by
  exact fun x => by linarith [ sq_nonneg ( x - y ) ] ;

/-- Attainment of the quadratic penalty minimum at `x = y`. -/
theorem quad_penalty_minimizer_eq (y : ℝ) :
    y ^ 2 / 2 - y * y = -(y ^ 2 / 2) := by ring

/-- The range `{x²/2 - x * y | x : ℝ}` is bounded below. -/
theorem quad_penalty_bddBelow (y : ℝ) :
    BddBelow (Set.range fun x : ℝ => x ^ 2 / 2 - x * y) := by
  exact ⟨-(y ^ 2 / 2), by rintro _ ⟨x, rfl⟩; linarith [quad_penalty_minimizer y x]⟩

/-
**Tropical Legendre duality**: the infimum formulation.
`inf_x (x²/2 - x * y) = -(y²/2)`.
-/
theorem tropical_legendre_quadratic (y : ℝ) :
    sInf (Set.range fun x : ℝ => x ^ 2 / 2 - x * y) = -(y ^ 2 / 2) := by
  exact le_antisymm ( csInf_le ⟨ - ( y ^ 2 / 2 ), Set.forall_mem_range.2 fun x => by nlinarith [ sq_nonneg ( x - y ) ] ⟩ ⟨ y, by ring ⟩ ) ( le_csInf ⟨ - ( y ^ 2 / 2 ), ⟨ y, by ring ⟩ ⟩ <| Set.forall_mem_range.2 fun x => by nlinarith [ sq_nonneg ( x - y ) ] )

/-! ## Min-Max Duality Bridge -/

/-- **Min-max duality**: `min a b = -(max (-a) (-b))`.
This is the fundamental bridge between tropical min-plus and max-plus algebras. -/
theorem min_max_duality (a b : ℝ) : min a b = -(max (-a) (-b)) := by
  simp [min_def, max_def]; split_ifs <;> linarith

/-- **Tropical mirror duality**: negation is involutive. -/
theorem tropical_mirror_duality (a : ℝ) : - (- a) = a := neg_neg a

/-
**Sup-Inf negation bridge**: `sSup S = -(sInf (negImage S))` for bounded nonempty sets.
This connects the Legendre sup-formulation to the tropical inf-formulation.
-/
theorem tropical_sup_neg_inf (S : Set ℝ) :
    sSup S = -(sInf (Set.image (fun x => -x) S)) := by
  aesop

/-! ## Connections to Kantorovich Duality -/

/-
The Legendre transform evaluated at a point gives a weak duality bound
for the single-site transport problem: for all `x`, `x * y ≤ f(x) + f★(y)`.
-/
theorem legendre_weak_duality_quadratic (x y : ℝ) :
    x * y ≤ x ^ 2 / 2 + legendreTransform (fun x : ℝ => x ^ 2 / 2) y := by
  convert fenchel_young_quadratic x y using 1;
  exact congrArg _ ( legendre_half_sq _ )

end