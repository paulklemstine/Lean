import Mathlib.LinearAlgebra.Vandermonde
import Mathlib.LinearAlgebra.Matrix.NonsingularInverse

/-!
# Cyclic orbits on an affine rational normal curve

This file formalizes the elementary Vandermonde core behind the paper's construction.
The affine rational normal curve is `t ↦ (1,t,…,t^(r-1))`.  We show that distinct
parameters give independent curve points, that a diagonal symmetric-power operator
moves a point by scaling its parameter, and consequently that a finite geometric-
progression orbit is MDS whenever its parameters are distinct.
-/

namespace CyclicProjectiveOrbits

open Matrix

/-- The affine chart of the degree `r-1` rational normal curve. -/
def rncPoint {k : Type*} [Monoid k] (r : ℕ) (t : k) : Fin r → k :=
  fun j => t ^ (j : ℕ)

/-
Distinct affine parameters give distinct points of a nonconstant rational normal curve.
-/
theorem rncPoint_injective {k : Type*} [Field k] {r : ℕ} (hr : 2 ≤ r) :
    Function.Injective (rncPoint (k := k) r) := by
  intro x y hxy;
  unfold rncPoint at hxy;
  simpa using congr_fun hxy ⟨ 1, hr ⟩

/-
The matrix whose rows are rational-normal-curve points is the Vandermonde matrix.
-/
theorem rncMatrix_eq_vandermonde {k : Type*} [CommRing k] {r : ℕ}
    (t : Fin r → k) :
    (fun i j => rncPoint r (t i) j) = Matrix.vandermonde t := by
  ext i j
  simp [rncPoint, Matrix.vandermonde_apply]

/-
Distinct parameters make the rational-normal-curve evaluation matrix nonsingular.
-/
theorem rncMatrix_det_ne_zero {k : Type*} [Field k] {r : ℕ}
    {t : Fin r → k} (ht : Function.Injective t) :
    Matrix.det (fun i j => rncPoint r (t i) j) ≠ 0 := by
  rw [rncMatrix_eq_vandermonde]
  exact Matrix.det_vandermonde_ne_zero_iff.mpr ht

/-
Consequently, any linear relation among `r` curve points at distinct parameters is zero.
-/
theorem rnc_points_linearIndependent {k : Type*} [Field k] {r : ℕ}
    {t : Fin r → k} (ht : Function.Injective t) :
    LinearIndependent k (fun i => rncPoint r (t i)) := by
  convert Matrix.linearIndependent_rows_of_det_ne_zero _;
  all_goals try infer_instance;
  convert rncMatrix_det_ne_zero ht

/-- The diagonal operator induced by `diag(1,q)` on the `(r-1)`st symmetric power. -/
def symmetricPowerDiagonal {k : Type*} [CommSemiring k] (r : ℕ) (q : k) :
    (Fin r → k) →ₗ[k] (Fin r → k) where
  toFun v j := q ^ (j : ℕ) * v j
  map_add' _ _ := by ext; simp [mul_add]
  map_smul' _ _ := by ext; simp [mul_comm, mul_assoc]

/-
The symmetric-power diagonal operator preserves the curve and scales its parameter.
-/
theorem symmetricPowerDiagonal_rncPoint {k : Type*} [CommSemiring k]
    (r : ℕ) (q t : k) :
    symmetricPowerDiagonal r q (rncPoint r t) = rncPoint r (q * t) := by
  ext j;
  simp +decide [ symmetricPowerDiagonal, rncPoint, mul_pow ]

/-
Iterating the operator produces a geometric progression on the curve.
-/
theorem symmetricPowerDiagonal_iterate {k : Type*} [CommSemiring k]
    (r m : ℕ) (q t : k) :
    (symmetricPowerDiagonal r q)^[m] (rncPoint r t) = rncPoint r (q ^ m * t) := by
  induction m <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ', mul_assoc ];
  convert symmetricPowerDiagonal_rncPoint r q ( q ^ ‹_› * t ) using 1

/-- An orbit segment is MDS when every choice of `r` orbit columns is independent. -/
def IsMDSOrbitSegment {k : Type*} [Field k] {r n : ℕ}
    (A : (Fin r → k) →ₗ[k] (Fin r → k)) (z : Fin r → k) : Prop :=
  ∀ e : Fin r ↪ Fin n, LinearIndependent k (fun i => A^[((e i : Fin n) : ℕ)] z)

/-
A geometric-progression symmetric-power orbit is MDS provided every selected
parameter `q^i * t` is distinct.
-/
theorem geometricProgressionOrbit_isMDS {k : Type*} [Field k] {r n : ℕ}
    (q t : k)
    (hparam : ∀ e : Fin r ↪ Fin n,
      Function.Injective (fun i : Fin r => q ^ ((e i : Fin n) : ℕ) * t)) :
    IsMDSOrbitSegment (n := n) (symmetricPowerDiagonal r q) (rncPoint r t) := by
  intro e;
  convert rnc_points_linearIndependent ( hparam e ) using 1;
  exact funext fun i => symmetricPowerDiagonal_iterate r ( e i ) q t

/-
A convenient criterion: nonzero `t` and powers of `q` distinct through length `n`
imply that the corresponding Krylov orbit segment is MDS.
-/
theorem geometricProgressionOrbit_isMDS_of_powers_injective {k : Type*} [Field k]
    {r n : ℕ} (q t : k) (ht : t ≠ 0)
    (hq : Function.Injective (fun i : Fin n => q ^ (i : ℕ))) :
    IsMDSOrbitSegment (n := n) (symmetricPowerDiagonal r q) (rncPoint r t) := by
  convert geometricProgressionOrbit_isMDS q t _
  intro e i j h
  have hpowers := hq
  simp_all +decide [Function.Injective.eq_iff hpowers]

end CyclicProjectiveOrbits