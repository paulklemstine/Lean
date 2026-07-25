import Mathlib
import EML.EMLLogDerivHom
import EML.EMLRiccatiNormalForm

/-!
# The Möbius / PGL₂ Structure of the Riccati Equation for EML ODEs

The differential-Galois slogan for the catalog says *"the Galois group of an EML
equation is an EML group."*  For a *first-order linear* equation `y′ = a·y` the
catalog (`EML.EMLFirstOrderGroup`) pins the Galois group inside the multiplicative
group of constants `Gₘ(constants)`.  This file does the analogous, and genuinely
nonlinear, computation for the **Riccati equation**

    v′ + v² + p·v + q = 0,

the equation governing the logarithmic derivative `v = y′/y` of a second-order linear
EML ODE (see `EML.EMLRiccatiNormalForm`).  Its symmetry group is *projective*: the
differential Galois group of a Riccati equation is a subgroup of `PGL₂(constants)`,
acting on solutions by Möbius transformations.  The decisive, basis-free invariant of
that projective action is the **cross-ratio**, and the theorem of this file is that the
cross-ratio of any four solutions is a **constant**.

Everything is proved in an arbitrary differential field `K` (Mathlib's `Differential`
typeclass, derivation `·′`), reusing the catalog's first-order solution calculus
`EML.EMLLogDerivHom` (`firstOrder_mul`, `firstOrder_div`).

## Main results

* `riccati_diff` — **difference of two Riccati solutions is first-order linear**: if
  `v₁, v₂` both solve `v′ + v² + p·v + q = 0`, then `(v₁ − v₂)′ = −(v₁ + v₂ + p)·(v₁ − v₂)`.
  So the difference `v₁ − v₂` is an `EML.EMLLogDerivHom`-style first-order solution,
  with coefficient `−(v₁ + v₂ + p)`.
* `riccati_diff_logDeriv` — the logarithmic-derivative form `(v₁ − v₂)′/(v₁ − v₂) =
  −(v₁ + v₂ + p)` for distinct solutions.
* `crossRatio` — the cross-ratio `((v₁−v₃)(v₂−v₄))/((v₁−v₄)(v₂−v₃))`.
* `riccati_crossRatio_isConstant` — **the cross-ratio of four Riccati solutions is a
  constant** (`(crossRatio …)′ = 0`).  This is the statement that the differential
  Galois group of the Riccati equation is a subgroup of `PGL₂(constants)`: the
  projective invariant of its action is fixed.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the catalog handles the *linear* first-order Galois group
(`Gₘ`) and the *linear* second-order Wronskian theory, but the Riccati equation itself
is nonlinear and its symmetry group should be *projective*, `PGL₂(constants)`, not
linear.  The falsifiable prediction: a basis-free projective invariant — the
cross-ratio of four solutions — is annihilated by the derivation, i.e. constant.  If
true, this is the exact Riccati analogue of the catalog's "Galois group is an EML
group" and it should reduce to the first-order calculus of `EMLLogDerivHom`.

Experiment (Experimenter): first establish `riccati_diff`: subtracting the two Riccati
equations, `(v₁−v₂)′ = v₁′−v₂′ = −(v₁²−v₂²) − p(v₁−v₂) = −(v₁+v₂+p)(v₁−v₂)`, a one-line
`linear_combination h₁ − h₂` after `map_sub`.  This exhibits every difference `v_i−v_j`
as a first-order solution with coefficient `−(v_i+v_j+p)`.  Feed the four differences to
the catalog `EMLLogDerivHom.firstOrder_mul` (numerator and denominator of the
cross-ratio are products of two differences) and then `EMLLogDerivHom.firstOrder_div`:
the cross-ratio solves `w′ = κ·w` with
`κ = (−(v₁+v₃+p) − (v₂+v₄+p)) − (−(v₁+v₄+p) − (v₂+v₃+p))`.  The `p`'s cancel and the
remaining linear terms telescope to `κ = 0` by `ring`, so `(crossRatio)′ = 0·w = 0`.

Analysis (Analyst): the cancellation `κ = 0` is the heart of the matter — it is the
"chain rule" identity underlying invariance of the cross-ratio under Möbius maps, here
realized differential-algebraically.  Two solutions differing by the `Gₘ`-coefficient
`−(v₁+v₂+p)` is precisely the rank-1 piece (`EMLFirstOrderGroup`); the *projective*
combination of four such pieces collapses the additive coefficients to zero.  The
hypotheses `v₁ ≠ v₄`, `v₂ ≠ v₃` are exactly the well-definedness of the cross-ratio's
denominator (the catalog `firstOrder_div` needs the denominator nonzero), nothing more.

Critique (Critic): non-vacuous and load-bearing.  The Riccati equations on all four
solutions are used (drop any one and `riccati_diff` for the corresponding pair fails).
The `v₁ ≠ v₄`/`v₂ ≠ v₃` hypotheses are necessary (else the cross-ratio is `0/0`).  The
proof uses genuine catalog machinery (`firstOrder_mul`/`firstOrder_div`) and the
insight-bearing `linear_combination`/`ring` cancellation, never `rfl`/`decide`/`simp`-only.

Synthesis (PI): with `EMLFirstOrderGroup` (Galois group of `y′ = a·y` is `Gₘ`) and this
file (Galois group of `v′ + v² + p·v + q = 0` is `⊆ PGL₂`), the catalog now carries both
the *linear* and the *projective* Galois pictures.  The cross-ratio invariant is the
Riccati-level shadow of the Wronskian, and it is the precise reason the Kovacic
algorithm classifies Riccati solvability by the `PGL₂(constants)`-orbit type of the
solution set.
-- !-- Lab Notes -- !--
-/

open scoped Differential

namespace EMLRiccatiMobius

variable {K : Type*} [Field K] [Differential K]

/-! ### Difference of two Riccati solutions is a first-order linear solution -/

/-- **Difference law.** If `v₁` and `v₂` both solve the Riccati equation
`v′ + v² + p·v + q = 0`, then their difference satisfies the first-order linear
equation `(v₁ − v₂)′ = −(v₁ + v₂ + p)·(v₁ − v₂)`.  Hence `v₁ − v₂` is an
`EML.EMLLogDerivHom`-type first-order solution with coefficient `−(v₁ + v₂ + p)`. -/
theorem riccati_diff (p q v₁ v₂ : K)
    (h₁ : v₁′ + v₁ ^ 2 + p * v₁ + q = 0)
    (h₂ : v₂′ + v₂ ^ 2 + p * v₂ + q = 0) :
    (v₁ - v₂)′ = -(v₁ + v₂ + p) * (v₁ - v₂) := by
  rw [map_sub]
  linear_combination h₁ - h₂

/-- **Difference law, logarithmic form.** For two *distinct* Riccati solutions the
logarithmic derivative of their difference is `−(v₁ + v₂ + p)`. -/
theorem riccati_diff_logDeriv (p q v₁ v₂ : K)
    (h₁ : v₁′ + v₁ ^ 2 + p * v₁ + q = 0)
    (h₂ : v₂′ + v₂ ^ 2 + p * v₂ + q = 0) (hne : v₁ ≠ v₂) :
    (v₁ - v₂)′ / (v₁ - v₂) = -(v₁ + v₂ + p) := by
  rw [riccati_diff p q v₁ v₂ h₁ h₂]
  field_simp [sub_ne_zero.mpr hne]

/-! ### The cross-ratio and its invariance -/

/-- The **cross-ratio** of four field elements,
`((v₁ − v₃)(v₂ − v₄)) / ((v₁ − v₄)(v₂ − v₃))`.  This is the basis-free projective
invariant on which the Möbius (`PGL₂`) action operates. -/
def crossRatio (v₁ v₂ v₃ v₄ : K) : K :=
  ((v₁ - v₃) * (v₂ - v₄)) / ((v₁ - v₄) * (v₂ - v₃))

/-- **The cross-ratio of four Riccati solutions is a constant.** If `v₁, v₂, v₃, v₄`
all solve the Riccati equation `v′ + v² + p·v + q = 0` (with `v₁ ≠ v₄` and `v₂ ≠ v₃` so
the cross-ratio is defined), then `(crossRatio v₁ v₂ v₃ v₄)′ = 0`.

This is the differential-Galois statement that the Galois group of a Riccati equation is
a subgroup of `PGL₂(constants)`: its action on solutions preserves the projective
cross-ratio invariant.  The proof exhibits each difference `v_i − v_j` as a first-order
solution (`riccati_diff`) and runs the catalog product/quotient calculus
(`EMLLogDerivHom.firstOrder_mul`, `firstOrder_div`); the additive coefficients telescope
to zero. -/
theorem riccati_crossRatio_isConstant (p q v₁ v₂ v₃ v₄ : K)
    (h₁ : v₁′ + v₁ ^ 2 + p * v₁ + q = 0)
    (h₂ : v₂′ + v₂ ^ 2 + p * v₂ + q = 0)
    (h₃ : v₃′ + v₃ ^ 2 + p * v₃ + q = 0)
    (h₄ : v₄′ + v₄ ^ 2 + p * v₄ + q = 0)
    (h14 : v₁ ≠ v₄) (h23 : v₂ ≠ v₃) :
    (crossRatio v₁ v₂ v₃ v₄)′ = 0 := by
  unfold crossRatio
  have hNum := EMLLogDerivHom.firstOrder_mul (-(v₁ + v₃ + p)) (-(v₂ + v₄ + p))
    (v₁ - v₃) (v₂ - v₄) (riccati_diff p q v₁ v₃ h₁ h₃) (riccati_diff p q v₂ v₄ h₂ h₄)
  have hDen := EMLLogDerivHom.firstOrder_mul (-(v₁ + v₄ + p)) (-(v₂ + v₃ + p))
    (v₁ - v₄) (v₂ - v₃) (riccati_diff p q v₁ v₄ h₁ h₄) (riccati_diff p q v₂ v₃ h₂ h₃)
  have hDen_ne : (v₁ - v₄) * (v₂ - v₃) ≠ 0 :=
    mul_ne_zero (sub_ne_zero.mpr h14) (sub_ne_zero.mpr h23)
  have key := EMLLogDerivHom.firstOrder_div _ _ _ _ hDen_ne hNum hDen
  have hcoeff :
      (-(v₁ + v₃ + p) + -(v₂ + v₄ + p)) - (-(v₁ + v₄ + p) + -(v₂ + v₃ + p)) = 0 := by ring
  rw [key, hcoeff, zero_mul]

end EMLRiccatiMobius