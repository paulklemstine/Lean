import Mathlib

/-!
# Local Temperley–Lieb / Jones braid identity

This file gives a minimal, self-contained formalization of the *local* Jones braid
relation built from a single Temperley–Lieb idempotent-like generator together with a
unit parameter `q`.

Let `R` be a commutative ring and `A` a (possibly noncommutative) unital `R`-algebra.
Given a unit `q : Rˣ`, set the loop parameter `δ = -(q + q⁻¹)` and define the Jones
braid generators
`jonesGen q e = q + e`, `jonesGenInv q e = q⁻¹ + e`
(where scalars are mapped into `A` via `algebraMap`).

If `e, f : A` satisfy the local Temperley–Lieb relations
`e² = δ e`, `f² = δ f`, `e f e = e`, `f e f = f`,
then the braid relation
`jonesGen q e * jonesGen q f * jonesGen q e = jonesGen q f * jonesGen q e * jonesGen q f`
holds, and each `jonesGen q e` is a unit with inverse `jonesGenInv q e`.
-/

namespace TLBraidLocal

variable {R : Type*} [CommRing R]
variable {A : Type*} [Ring A] [Algebra R A]

/-- The Temperley–Lieb loop parameter `δ = -(q + q⁻¹)` associated to a unit `q`. -/
def tlLoop (q : Rˣ) : R := -((q : R) + ((q⁻¹ : Rˣ) : R))

/-- The Jones braid generator `q + e`. -/
def jonesGen (q : Rˣ) (e : A) : A := algebraMap R A (q : R) + e

/-- The inverse Jones braid generator `q⁻¹ + e`. -/
def jonesGenInv (q : Rˣ) (e : A) : A := algebraMap R A ((q⁻¹ : Rˣ) : R) + e

/-- A general scalar-parametrized braid identity.  If `e, f` satisfy the Temperley–Lieb
relations with loop parameter `δ` and the scalar coefficient identity
`a² + abδ + b² = 0` holds, then the braid relation holds for `a + b·e` and `a + b·f`. -/
theorem tl_braid_general (a b δ : R) (e f : A)
    (he2 : e * e = algebraMap R A δ * e)
    (hf2 : f * f = algebraMap R A δ * f)
    (hefe : e * f * e = e)
    (hfef : f * e * f = f)
    (hcoef : a * a + a * b * δ + b * b = 0) :
    (algebraMap R A a + algebraMap R A b * e) * (algebraMap R A a + algebraMap R A b * f)
        * (algebraMap R A a + algebraMap R A b * e)
      = (algebraMap R A a + algebraMap R A b * f) * (algebraMap R A a + algebraMap R A b * e)
        * (algebraMap R A a + algebraMap R A b * f) := by
  simp only [mul_assoc, add_assoc, mul_add, add_mul] at *
  simp_all +decide [← mul_assoc, ← map_mul, -map_add]
  simp_all +decide [mul_assoc, Algebra.algebraMap_eq_smul_one]
  simp_all +decide [mul_comm a, mul_assoc, ← smul_assoc]
  rw [show a * a = -(b * (δ * a) + b * b) by linear_combination' hcoef]
  simp +decide [mul_add, add_smul]
  abel_nf

/-- A general inverse identity: if `e² = δ e`, `a b = 1` and `a + b + δ = 0`, then
`(a + e)(b + e) = 1` and `(b + e)(a + e) = 1`. -/
theorem tl_inverse_general (a b δ : R) (e : A)
    (he2 : e * e = algebraMap R A δ * e)
    (hab : a * b = 1)
    (habδ : a + b + δ = 0) :
    (algebraMap R A a + e) * (algebraMap R A b + e) = 1
      ∧ (algebraMap R A b + e) * (algebraMap R A a + e) = 1 := by
  simp_all +decide [← eq_sub_iff_add_eq']
  simp_all +decide [mul_comm, add_mul, mul_add, ← map_mul]
  simp +decide [Algebra.commutes]

/-- The specialized Jones braid relation. -/
theorem jonesGen_braid (q : Rˣ) (e f : A)
    (he2 : e * e = algebraMap R A (tlLoop q) * e)
    (hf2 : f * f = algebraMap R A (tlLoop q) * f)
    (hefe : e * f * e = e)
    (hfef : f * e * f = f) :
    jonesGen q e * jonesGen q f * jonesGen q e
      = jonesGen q f * jonesGen q e * jonesGen q f := by
  convert tl_braid_general (↑q) 1 (tlLoop q) e f he2 hf2 hefe hfef ?_ using 1 <;> norm_num [tlLoop]
  · rfl
  · rfl
  · linear_combination -Units.mul_inv q

/-- `jonesGen q e * jonesGenInv q e = 1`. -/
theorem jonesGen_mul_jonesGenInv (q : Rˣ) (e : A)
    (he2 : e * e = algebraMap R A (tlLoop q) * e) :
    jonesGen q e * jonesGenInv q e = 1 :=
  (tl_inverse_general (q : R) ((q⁻¹ : Rˣ) : R) (tlLoop q) e he2 (Units.mul_inv q)
    (by simp only [tlLoop]; ring)).1

/-- `jonesGenInv q e * jonesGen q e = 1`. -/
theorem jonesGenInv_mul_jonesGen (q : Rˣ) (e : A)
    (he2 : e * e = algebraMap R A (tlLoop q) * e) :
    jonesGenInv q e * jonesGen q e = 1 :=
  (tl_inverse_general (q : R) ((q⁻¹ : Rˣ) : R) (tlLoop q) e he2 (Units.mul_inv q)
    (by simp only [tlLoop]; ring)).2

/-- Each Jones braid generator is a unit, with inverse `jonesGenInv q e`. -/
theorem jonesGen_isUnit (q : Rˣ) (e : A)
    (he2 : e * e = algebraMap R A (tlLoop q) * e) :
    IsUnit (jonesGen q e) :=
  ⟨⟨jonesGen q e, jonesGenInv q e, jonesGen_mul_jonesGenInv q e he2,
      jonesGenInv_mul_jonesGen q e he2⟩, rfl⟩

end TLBraidLocal