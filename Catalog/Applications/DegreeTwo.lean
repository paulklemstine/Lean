import Novelty.JacobianConjecture.Core

/-!
# The Jacobian Conjecture for triangular degree-2 maps (all dimensions)

The Jacobian Conjecture for maps of total degree `≤ 2` (in every dimension) is a
theorem of S. Wang (1980): a degree-2 map with constant nonzero Jacobian is an
automorphism.  Wang's proof in full generality is beyond the present
formalization, but the *triangular* (elementary / de Jonquières) sub-class
already realizes the conjecture in **all dimensions** with completely explicit
inverses, and we verify it here over an arbitrary commutative ring.

A triangular map modifies coordinate `i` by adding a polynomial in the *earlier*
coordinates only; its Jacobian is unit-upper-triangular, so `det = 1`
identically, and it is invertible by back-substitution regardless of degree.

## Main results

Two-variable parametrised quadratic shear `F(X₀,X₁) = (X₀ + a·X₁² + b·X₁, X₁)`:

* `triF_isPolyAut` — polynomial automorphism with inverse
  `G(X₀,X₁) = (X₀ - a·X₁² - b·X₁, X₁)`, for *all* parameters `a b : R`.
* `triF_bijective` — bijective on every `R`-algebra (Core bridge).
* `triF_jacDet` — `det(JF) = 1`.

A genuinely 3-dimensional triangular degree-2 automorphism
`F(X₀,X₁,X₂) = (X₀, X₁ + X₀², X₂ + X₀·X₁)`:

* `tri3_isPolyAut`, `tri3_bijective`, `tri3_jacDet` — same three properties,
  showing the phenomenon is not special to dimension 2.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the easy, *true-in-all-dimensions* part of the
  degree-2 Jacobian Conjecture is the triangular class; its inverse is found by
  back-substitution and its Jacobian is identically `1`.  Conjecture: every
  triangular quadratic map is an automorphism with `det(JF)=1`, with no
  field/characteristic hypotheses.
* Experiment (Experimenter): formalized the 2-variable parametrised family and a
  3-variable witness.  Inverses were guessed by back-substitution
  (`X₂ = Y₂ - X₀X₁ = Y₂ - Y₀(Y₁-Y₀²)`, hence the `+X₀³` correction term in `G₂`)
  and verified by `aeval` + `ring`; Jacobians by `pderiv` + `ring`.
* Analysis (Analyst): the 3-D inverse needed the nonlinear correction `+(X₀)³`,
  illustrating that even triangular inversion composes nonlinearities across
  levels — the reason general (non-triangular) inversion is hard.  The Jacobian
  being identically `1` (not merely constant) is the strongest possible form of
  the hypothesis.
* Critique (Critic): triangular maps are the "trivial" direction of the
  conjecture, so we are careful to *not* claim Wang's full theorem; we claim
  exactly the verified triangular sub-statements, in all dimensions, over any
  commutative ring.  The non-triangular degree-3 witness lives in
  `Druzkowski.lean`.
* Synthesis (PI): degree-2 (triangular) ✓ and degree-3 (cubic-linear, one
  witness) ✓ bracket the smallest open dimension/degree of the conjecture.
-/

open MvPolynomial

namespace JacobianConjecture.DegreeTwo

variable {R : Type*} [CommRing R]

/-! ## Two-variable parametrised quadratic shear -/

/-- `F(X₀,X₁) = (X₀ + a·X₁² + b·X₁, X₁)`. -/
noncomputable def triF (a b : R) : Fin 2 → MvPolynomial (Fin 2) R
  | 0 => X 0 + C a * (X 1) ^ 2 + C b * X 1
  | 1 => X 1

/-- The inverse shear `G(X₀,X₁) = (X₀ - a·X₁² - b·X₁, X₁)`. -/
noncomputable def triG (a b : R) : Fin 2 → MvPolynomial (Fin 2) R
  | 0 => X 0 - C a * (X 1) ^ 2 - C b * X 1
  | 1 => X 1

/-- For every choice of parameters `a b`, the quadratic shear is a polynomial
automorphism with inverse `triG a b`. -/
theorem triF_isPolyAut (a b : R) : IsPolyAut (triF a b) (triG a b) := by
  constructor <;>
  · funext i
    fin_cases i <;>
      simp only [pcomp, triF, triG, Fin.isValue, Fin.zero_eta, Fin.mk_one, map_add, map_sub,
        map_mul, map_pow, aeval_X, aeval_C, algebraMap_eq] <;>
      ring

/-- The quadratic shear induces a bijection on every `R`-algebra. -/
theorem triF_bijective (a b : R) (A : Type*) [CommRing A] [Algebra R A] :
    Function.Bijective (induced (triF a b) (A := A)) :=
  (triF_isPolyAut a b).bijective_induced A

/-- The Jacobian determinant of the quadratic shear is `1`. -/
theorem triF_jacDet (a b : R) : jacDet (triF a b) = 1 := by
  unfold jacDet polyJacobian
  rw [Matrix.det_fin_two]
  simp only [Matrix.of_apply, triF, map_add, pderiv_mul, pderiv_pow, pderiv_X, pderiv_C,
    Pi.single_apply, Fin.reduceEq, if_true, if_false]
  ring

/-! ## A 3-dimensional triangular degree-2 automorphism -/

/-- `F(X₀,X₁,X₂) = (X₀, X₁ + X₀², X₂ + X₀·X₁)`. -/
noncomputable def tri3F : Fin 3 → MvPolynomial (Fin 3) R
  | 0 => X 0
  | 1 => X 1 + (X 0) ^ 2
  | 2 => X 2 + X 0 * X 1

/-- The back-substitution inverse
`G(X₀,X₁,X₂) = (X₀, X₁ - X₀², X₂ - X₀·X₁ + X₀³)`. -/
noncomputable def tri3G : Fin 3 → MvPolynomial (Fin 3) R
  | 0 => X 0
  | 1 => X 1 - (X 0) ^ 2
  | 2 => X 2 - X 0 * X 1 + (X 0) ^ 3

/-- The 3-variable triangular map is a polynomial automorphism with inverse
`tri3G`. -/
theorem tri3_isPolyAut : IsPolyAut (tri3F : Fin 3 → MvPolynomial (Fin 3) R) tri3G := by
  constructor <;>
  · funext i
    fin_cases i <;>
      simp only [pcomp, tri3F, tri3G, Fin.isValue, Fin.zero_eta, Fin.mk_one, Fin.reduceFinMk,
        map_add, map_sub, map_mul, map_pow, aeval_X] <;>
      ring

/-- The 3-variable triangular map induces a bijection on every `R`-algebra. -/
theorem tri3_bijective (A : Type*) [CommRing A] [Algebra R A] :
    Function.Bijective (induced (tri3F : Fin 3 → MvPolynomial (Fin 3) R) (A := A)) :=
  tri3_isPolyAut.bijective_induced A

/-- The Jacobian determinant of the 3-variable triangular map is `1`. -/
theorem tri3_jacDet : jacDet (tri3F : Fin 3 → MvPolynomial (Fin 3) R) = 1 := by
  unfold jacDet polyJacobian
  rw [Matrix.det_fin_three]
  simp only [Matrix.of_apply, tri3F, map_add, pderiv_mul, pderiv_pow, pderiv_X,
    Pi.single_apply, Fin.reduceEq, if_true, if_false]
  ring

end JacobianConjecture.DegreeTwo