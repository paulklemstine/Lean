import Mathlib

/-!
# Berggren Generators in PGL₂: Projective Dynamics of Pythagorean Triples

This file establishes that the three Berggren generators, when restricted to the
isotropic conic of the Lorentzian form Q(x,y,z) = x² + y² - z², act as
explicit 2×2 linear fractional transformations on the Euclid parameter space.

## Main Results

We work with two parametrizations of the isotropic conic `x² + y² = z²`:

### Parametrization 1: `paramVec(s,t) = (2st, t²-s², t²+s²)`

Under this identification, the Berggren generators act as:
- `A: (s,t) ↦ (s, t + 2s)` — 2×2 matrix `[[1,0],[2,1]]`
- `B: (s,t) ↦ (t, s + 2t)` — 2×2 matrix `[[0,1],[1,2]]`
- `C: (s,t) ↦ (t, 2t - s)` — 2×2 matrix `[[0,1],[-1,2]]`

### Parametrization 2: `euclidVec(m,n) = (m²-n², 2mn, m²+n²)` (standard Euclid)

Under this identification:
- `A: (m,n) ↦ (2m - n, m)` — 2×2 matrix `[[2,-1],[1,0]]`
- `B: (m,n) ↦ (2m + n, m)` — 2×2 matrix `[[2,1],[1,0]]`
- `C: (m,n) ↦ (m + 2n, n)` — 2×2 matrix `[[1,2],[0,1]]`

Note: Generator C in the Euclid parametrization is a shear (translation by 2
in the n-direction), while A and B involve both parameters. In affine coordinate
`u = m/n`, A acts as `u ↦ (2u-1)/u`, B as `u ↦ (2u+1)/u`, C as `u ↦ u+2`.

All identities are proved over an arbitrary commutative ring, giving maximum
generality. Specializing to `ZMod p` for odd primes gives the projective
dynamical system on the isotropic conic over finite fields.

## Strategy

The identities are polynomial, so they are proved by `ring` after expanding
matrix multiplication componentwise. This works over any `CommRing R`.
-/

set_option maxHeartbeats 400000

open Matrix

namespace BerggrenPGL2

/-! ## Section 1: Parametrizations -/

/-- Euclid parametrization variant 1: `(s,t) ↦ (2st, t²-s², t²+s²)`.
    This parametrizes the conic `x² + y² = z²` with `x` as the even leg. -/
def paramVec {R : Type*} [CommRing R] (s t : R) : Fin 3 → R :=
  ![2 * s * t, t ^ 2 - s ^ 2, t ^ 2 + s ^ 2]

/-- Standard Euclid parametrization: `(m,n) ↦ (m²-n², 2mn, m²+n²)`.
    This parametrizes the conic with `m²-n²` as the odd leg. -/
def euclidVec {R : Type*} [CommRing R] (m n : R) : Fin 3 → R :=
  ![m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2]

/-! ## Section 2: Berggren matrices -/

/-- Berggren matrix A. -/
def berggrenA (R : Type*) [CommRing R] : Matrix (Fin 3) (Fin 3) R :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B. -/
def berggrenB (R : Type*) [CommRing R] : Matrix (Fin 3) (Fin 3) R :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix C. -/
def berggrenC (R : Type*) [CommRing R] : Matrix (Fin 3) (Fin 3) R :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-! ## Section 3: Isotropicity of the parametrizations -/

/-- The parametrization `paramVec` lands on the isotropic conic. -/
theorem paramVec_isotropic {R : Type*} [CommRing R] (s t : R) :
    (paramVec s t 0) ^ 2 + (paramVec s t 1) ^ 2 = (paramVec s t 2) ^ 2 := by
  simp [paramVec]; ring

/-- The parametrization `euclidVec` lands on the isotropic conic. -/
theorem euclidVec_isotropic {R : Type*} [CommRing R] (m n : R) :
    (euclidVec m n 0) ^ 2 + (euclidVec m n 1) ^ 2 = (euclidVec m n 2) ^ 2 := by
  simp [euclidVec]; ring

/-! ## Section 4: Berggren action on `paramVec` — core identities -/

/-- **Berggren A on paramVec**: `A · paramVec(s,t) = paramVec(s, t + 2s)`.
    Over any commutative ring. -/
theorem berggrenA_paramVec {R : Type*} [CommRing R] (s t : R) :
    (berggrenA R).mulVec (paramVec s t) = paramVec s (t + 2 * s) := by
  ext i; fin_cases i <;>
    simp [berggrenA, paramVec, mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-- **Berggren B on paramVec**: `B · paramVec(s,t) = paramVec(t, s + 2t)`.
    Note the parameter swap: the first parameter becomes `t`. -/
theorem berggrenB_paramVec {R : Type*} [CommRing R] (s t : R) :
    (berggrenB R).mulVec (paramVec s t) = paramVec t (s + 2 * t) := by
  ext i; fin_cases i <;>
    simp [berggrenB, paramVec, mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-- **Berggren C on paramVec**: `C · paramVec(s,t) = paramVec(t, 2t - s)`.
    Note the parameter swap and reflection. -/
theorem berggrenC_paramVec {R : Type*} [CommRing R] (s t : R) :
    (berggrenC R).mulVec (paramVec s t) = paramVec t (2 * t - s) := by
  ext i; fin_cases i <;>
    simp [berggrenC, paramVec, mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-! ## Section 5: Berggren action on `euclidVec` — standard Euclid form -/

/-- **Berggren A on euclidVec**: `A · euclidVec(m,n) = euclidVec(2m - n, m)`. -/
theorem berggrenA_euclidVec {R : Type*} [CommRing R] (m n : R) :
    (berggrenA R).mulVec (euclidVec m n) = euclidVec (2 * m - n) m := by
  ext i; fin_cases i <;>
    simp [berggrenA, euclidVec, mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-- **Berggren B on euclidVec**: `B · euclidVec(m,n) = euclidVec(2m + n, m)`. -/
theorem berggrenB_euclidVec {R : Type*} [CommRing R] (m n : R) :
    (berggrenB R).mulVec (euclidVec m n) = euclidVec (2 * m + n) m := by
  ext i; fin_cases i <;>
    simp [berggrenB, euclidVec, mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-- **Berggren C on euclidVec**: `C · euclidVec(m,n) = euclidVec(m + 2n, n)`.
    This is a shear / translation by 2 in the n-direction. -/
theorem berggrenC_euclidVec {R : Type*} [CommRing R] (m n : R) :
    (berggrenC R).mulVec (euclidVec m n) = euclidVec (m + 2 * n) n := by
  ext i; fin_cases i <;>
    simp [berggrenC, euclidVec, mulVec, dotProduct, Fin.sum_univ_three] <;> ring

/-! ## Section 6: The corresponding 2×2 Möbius matrices -/

/-- 2×2 matrix for A action on `euclidVec` parameters: `[[2,-1],[1,0]]`. -/
def mobiusA_ev (R : Type*) [CommRing R] : Matrix (Fin 2) (Fin 2) R :=
  !![2, -1; (1 : R), 0]

/-- 2×2 matrix for B action on `euclidVec` parameters: `[[2,1],[1,0]]`. -/
def mobiusB_ev (R : Type*) [CommRing R] : Matrix (Fin 2) (Fin 2) R :=
  !![2, 1; (1 : R), 0]

/-- 2×2 matrix for C action on `euclidVec` parameters (shear): `[[1,2],[0,1]]`. -/
def mobiusC_ev (R : Type*) [CommRing R] : Matrix (Fin 2) (Fin 2) R :=
  !![1, 2; (0 : R), 1]

/-! ## Section 7: Lorentzian form preservation -/

/-- The Lorentzian quadratic form Q(v) = v₀² + v₁² - v₂². -/
def lorentzQ {R : Type*} [CommRing R] (v : Fin 3 → R) : R :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- Berggren A preserves the Lorentzian form. -/
theorem berggrenA_preserves_Q {R : Type*} [CommRing R] (v : Fin 3 → R) :
    lorentzQ ((berggrenA R).mulVec v) = lorentzQ v := by
  simp [lorentzQ, berggrenA, mulVec, dotProduct, Fin.sum_univ_three]; ring

/-- Berggren B preserves the Lorentzian form. -/
theorem berggrenB_preserves_Q {R : Type*} [CommRing R] (v : Fin 3 → R) :
    lorentzQ ((berggrenB R).mulVec v) = lorentzQ v := by
  simp [lorentzQ, berggrenB, mulVec, dotProduct, Fin.sum_univ_three]; ring

/-- Berggren C preserves the Lorentzian form. -/
theorem berggrenC_preserves_Q {R : Type*} [CommRing R] (v : Fin 3 → R) :
    lorentzQ ((berggrenC R).mulVec v) = lorentzQ v := by
  simp [lorentzQ, berggrenC, mulVec, dotProduct, Fin.sum_univ_three]; ring

/-! ## Section 8: Determinants -/

/-- Berggren A has determinant 1 (proper orthogonal). -/
theorem det_berggrenA : (berggrenA ℤ).det = 1 := by native_decide

/-- Berggren B has determinant -1 (improper orthogonal). -/
theorem det_berggrenB : (berggrenB ℤ).det = -1 := by native_decide

/-- Berggren C has determinant 1 (proper orthogonal). -/
theorem det_berggrenC : (berggrenC ℤ).det = 1 := by native_decide

/-- The Euclid-parameter 2×2 matrices have the following determinants. -/
theorem det_mobiusA_ev (R : Type*) [CommRing R] : (mobiusA_ev R).det = 1 := by
  simp [mobiusA_ev, det_fin_two]

theorem det_mobiusB_ev (R : Type*) [CommRing R] : (mobiusB_ev R).det = -1 := by
  simp [mobiusB_ev, det_fin_two]

theorem det_mobiusC_ev (R : Type*) [CommRing R] : (mobiusC_ev R).det = 1 := by
  simp [mobiusC_ev, det_fin_two]

/-! ## Section 9: Projective equivalence -/

/-- Two vectors are projectively equivalent if they differ by a unit scalar. -/
def ProjEquiv {R : Type*} [CommMonoidWithZero R] {n : ℕ} (v w : Fin n → R) : Prop :=
  ∃ a : Rˣ, w = a • v

/-- Berggren generators act projectively on the parametrization (trivially, since
    the identities are exact equalities, not just projective). -/
theorem berggrenA_proj {R : Type*} [CommRing R] (s t : R) :
    ProjEquiv ((berggrenA R).mulVec (paramVec s t)) (paramVec s (t + 2 * s)) :=
  ⟨1, by rw [berggrenA_paramVec]; simp⟩

theorem berggrenB_proj {R : Type*} [CommRing R] (s t : R) :
    ProjEquiv ((berggrenB R).mulVec (paramVec s t)) (paramVec t (s + 2 * t)) :=
  ⟨1, by rw [berggrenB_paramVec]; simp⟩

theorem berggrenC_proj {R : Type*} [CommRing R] (s t : R) :
    ProjEquiv ((berggrenC R).mulVec (paramVec s t)) (paramVec t (2 * t - s)) :=
  ⟨1, by rw [berggrenC_paramVec]; simp⟩

/-! ## Section 10: Specialization to ZMod p -/

/-- Berggren A on the conic over `ZMod p`. -/
theorem berggrenA_ZMod (p : ℕ) [Fact p.Prime] (s t : ZMod p) :
    (berggrenA (ZMod p)).mulVec (paramVec s t) = paramVec s (t + 2 * s) :=
  berggrenA_paramVec s t

/-- Berggren B on the conic over `ZMod p`. -/
theorem berggrenB_ZMod (p : ℕ) [Fact p.Prime] (s t : ZMod p) :
    (berggrenB (ZMod p)).mulVec (paramVec s t) = paramVec t (s + 2 * t) :=
  berggrenB_paramVec s t

/-- Berggren C on the conic over `ZMod p`. -/
theorem berggrenC_ZMod (p : ℕ) [Fact p.Prime] (s t : ZMod p) :
    (berggrenC (ZMod p)).mulVec (paramVec s t) = paramVec t (2 * t - s) :=
  berggrenC_paramVec s t

/-! ## Section 11: Affine chart formulas -/

/-- In affine coordinate `u = t/s`, Berggren A acts as `u ↦ u + 2`. -/
theorem berggrenA_affine {F : Type*} [Field F] (s t : F) (hs : s ≠ 0) :
    (t + 2 * s) / s = t / s + 2 := by field_simp

/-- In affine coordinate `u = (s+2t)/t`, Berggren B swaps and shifts. -/
theorem berggrenB_affine_swap {F : Type*} [Field F] (s t : F) (ht : t ≠ 0) :
    (s + 2 * t) / t = s / t + 2 := by field_simp

/-! ## Section 12: Composition identities -/

/-- C composed twice: `(s,t) ↦ (t, 2t-s) ↦ (2t-s, 2(2t-s)-t) = (2t-s, 3t-2s)`. -/
theorem berggrenC_sq_paramVec {R : Type*} [CommRing R] (s t : R) :
    (berggrenC R).mulVec ((berggrenC R).mulVec (paramVec s t)) =
    paramVec (2 * t - s) (2 * (2 * t - s) - t) := by
  rw [berggrenC_paramVec, berggrenC_paramVec]

/-! ## Section 13: Summary theorems -/

/-- **Main theorem (paramVec form)**: Complete Berggren-to-PGL₂ correspondence.
    The three Berggren 3×3 matrices, acting on the isotropic conic via the
    parametrization `(s,t) ↦ (2st, t²-s², t²+s²)`, are intertwined with
    explicit 2×2 linear maps on the parameter space `(s,t)`:
    - A: `(s,t) ↦ (s, t+2s)`
    - B: `(s,t) ↦ (t, s+2t)`
    - C: `(s,t) ↦ (t, 2t-s)`
    This holds over any commutative ring. -/
theorem berggren_PGL2_paramVec {R : Type*} [CommRing R] (s t : R) :
    (berggrenA R).mulVec (paramVec s t) = paramVec s (t + 2 * s) ∧
    (berggrenB R).mulVec (paramVec s t) = paramVec t (s + 2 * t) ∧
    (berggrenC R).mulVec (paramVec s t) = paramVec t (2 * t - s) :=
  ⟨berggrenA_paramVec s t, berggrenB_paramVec s t, berggrenC_paramVec s t⟩

/-- **Main theorem (euclidVec form)**: Complete Berggren-to-PGL₂ correspondence.
    The three Berggren 3×3 matrices, acting on the isotropic conic via the
    standard Euclid parametrization `(m,n) ↦ (m²-n², 2mn, m²+n²)`, are
    intertwined with the 2×2 matrices `[[2,-1],[1,0]]`, `[[2,1],[1,0]]`,
    `[[1,2],[0,1]]` acting on the parameter space.
    This holds over any commutative ring. -/
theorem berggren_PGL2_euclidVec {R : Type*} [CommRing R] (m n : R) :
    (berggrenA R).mulVec (euclidVec m n) = euclidVec (2 * m - n) m ∧
    (berggrenB R).mulVec (euclidVec m n) = euclidVec (2 * m + n) m ∧
    (berggrenC R).mulVec (euclidVec m n) = euclidVec (m + 2 * n) n :=
  ⟨berggrenA_euclidVec m n, berggrenB_euclidVec m n, berggrenC_euclidVec m n⟩

end BerggrenPGL2