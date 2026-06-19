import Mathlib
import Catalog.Algebra.JonesTemperleyLiebBraid4

/-!
# A non-abelianity certificate for Jones braid operators

This file isolates the *algebraic* mechanism responsible for non-abelian
(Fibonacci / Jones) braiding: the Jones image of a Temperley–Lieb generator is a
unit-twisted affine deformation of that generator, and the deformation preserves
exactly the failure of commutativity of the underlying generators.

For a field `K`, a (possibly noncommutative) `K`-algebra `A`, a unit `u : Kˣ`
and an element `X : A`, the Jones operator is
`jonesOp u X = (u : K) • 1 + ((↑u⁻¹ : K) • X)`.

We prove:

* `jonesOp_commutator`: the exact commutator identity
  `jonesOp u X * jonesOp u Y - jonesOp u Y * jonesOp u X
     = ((↑u⁻¹ : K) * (↑u⁻¹ : K)) • (X * Y - Y * X)`;
* `jonesOp_commute_iff`: the non-abelianity equivalence
  `jonesOp u X * jonesOp u Y = jonesOp u Y * jonesOp u X ↔ X * Y = Y * X`,
  using injectivity of scalar multiplication by the nonzero scalar `(↑u⁻¹)^2`.

This is a *bridge* theorem: noncommuting Temperley–Lieb generators give
noncommuting Jones braid images, and conversely.  **No claim of density,
universality, topology, or quantum-computational completeness is made.**

We also relate the unit-based `jonesOp` to the field-element-based operator
`JonesTemperleyLiebBraid4.jonesOp` of the catalog, and give one concrete
`2 × 2` rational matrix example.
-/

namespace JonesBraidNonabelianCertificate

variable {K A : Type*} [Field K] [Ring A] [Algebra K A]

/-- The Jones image of a Temperley–Lieb generator, parametrized by a unit
`u : Kˣ`: `jonesOp u X = (u : K) • 1 + ((↑u⁻¹ : K) • X)`. -/
def jonesOp (u : Kˣ) (X : A) : A := (u : K) • (1 : A) + ((↑u⁻¹ : K) • X)

/-- Scalar multiplication by the value of a unit of `K` is injective on `A`:
`(↑v : K) • z = 0 ↔ z = 0`.  This is the cancellation property used to transport
non-commutativity through the Jones map. -/
theorem unit_smul_eq_zero_iff (v : Kˣ) (z : A) :
    (↑v : K) • z = 0 ↔ z = 0 := by
  constructor
  · intro h
    have := congrArg (fun w : A => (↑v⁻¹ : K) • w) h
    simpa [smul_smul] using this
  · intro h; simp [h]

/-- **Exact commutator identity.**  The Jones map turns the commutator of two
generators into a scalar multiple (by `(↑u⁻¹)^2`) of that commutator. -/
theorem jonesOp_commutator (u : Kˣ) (X Y : A) :
    jonesOp u X * jonesOp u Y - jonesOp u Y * jonesOp u X
      = ((↑u⁻¹ : K) * (↑u⁻¹ : K)) • (X * Y - Y * X) := by
  unfold jonesOp
  simp +decide [mul_add, add_mul, smul_smul, smul_sub]
  abel1

/-- **Non-abelianity equivalence.**  The Jones operators of `X` and `Y` commute
if and only if `X` and `Y` commute. -/
theorem jonesOp_commute_iff (u : Kˣ) (X Y : A) :
    jonesOp u X * jonesOp u Y = jonesOp u Y * jonesOp u X ↔ X * Y = Y * X := by
  rw [← sub_eq_zero, jonesOp_commutator, ← Units.val_mul, unit_smul_eq_zero_iff,
    sub_eq_zero]

/-- Specialization bridge: the unit-based `jonesOp u X` agrees with the
field-element-based `JonesTemperleyLiebBraid4.jonesOp (↑u) X` of the catalog. -/
theorem jonesOp_eq_catalog (u : Kˣ) (X : A) :
    jonesOp u X = JonesTemperleyLiebBraid4.jonesOp (↑u : K) X := by
  unfold JonesTemperleyLiebBraid4.jonesOp
  simp [jonesOp]

/-- Catalog corollary: noncommuting Temperley–Lieb generators give noncommuting
catalog Jones images (and conversely). -/
theorem catalog_jonesOp_commute_iff (u : Kˣ) (X Y : A) :
    JonesTemperleyLiebBraid4.jonesOp (↑u : K) X
        * JonesTemperleyLiebBraid4.jonesOp (↑u : K) Y
      = JonesTemperleyLiebBraid4.jonesOp (↑u : K) Y
        * JonesTemperleyLiebBraid4.jonesOp (↑u : K) X
    ↔ X * Y = Y * X := by
  convert jonesOp_commute_iff u X Y using 1
  rw [← jonesOp_eq_catalog, ← jonesOp_eq_catalog]

/-! ### A concrete `2 × 2` rational example -/

/-- A nilpotent upper-triangular generator. -/
def exampleX : Matrix (Fin 2) (Fin 2) ℚ := !![0, 1; 0, 0]

/-- A nilpotent lower-triangular generator. -/
def exampleY : Matrix (Fin 2) (Fin 2) ℚ := !![0, 0; 1, 0]

/-- The two explicit matrices do not commute: their `(0,0)` entries differ. -/
theorem exampleX_mul_exampleY_ne :
    exampleX * exampleY ≠ exampleY * exampleX := by
  intro h
  have h00 := congrFun (congrFun h 0) 0
  simp [exampleX, exampleY] at h00

/-- Concrete conclusion: for every rational unit `u`, the Jones operators of
`exampleX` and `exampleY` fail to commute.  This is the bridge theorem in
action: non-commuting generators force non-commuting Jones braid images. -/
theorem example_jonesOp_noncommute (u : ℚˣ) :
    jonesOp u exampleX * jonesOp u exampleY
      ≠ jonesOp u exampleY * jonesOp u exampleX := by
  rw [Ne, jonesOp_commute_iff]
  exact exampleX_mul_exampleY_ne

end JonesBraidNonabelianCertificate