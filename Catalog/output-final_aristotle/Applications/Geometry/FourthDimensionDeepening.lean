/-
# Deepening the Algebraic Core of Four-Dimensional Geometry

A previous study isolated a single sum-of-squares identity,
`(a + b)² = 4ab + (a − b)²`,
as the common engine behind the Hopf map, the Clifford torus and the
norm-preserving quarter-turn on `ℝ⁴`.  The present development pushes that core
substantially further, in four directions.

1. **From two squares to four (and the width barrier).**  We prove the
   Brahmagupta–Fibonacci two-square identity and Euler's four-square identity —
   the multiplicativity of the sum of two, respectively four, squares — together
   with the three-variable Lagrange identity underlying the Cauchy–Schwarz
   inequality.  These are the algebraic shadows of the complex numbers and the
   quaternions.

2. **The Hopf fibration, both inclusions.**  The circle orbits
   `(z, w) ↦ (λz, λw)` with `|λ| = 1` are contained in the Hopf fibres; the deep
   step is the *converse*: two points of the unit three-sphere with the same Hopf
   image differ by a single unit complex scalar.  We prove this via the explicit
   witness `λ = z̄z' + w̄w'`, and package the two inclusions into a clean
   biconditional: **the fibres of the Hopf map are exactly the great circles.**

3. **The complex structure in every even dimension.**  Multiplication by `i` on
   `ℂⁿ` squares to `−1`, preserves the Euclidean norm, and is fixed-point-free on
   the sphere — the general form of "rotation through the fourth dimension".

4. **Balanced radii and rotational rigidity.**  The Clifford balance is upgraded
   to the three-radius arithmetic–geometric mean bound, and the four-dimensional
   quaternion picture yields the rigidity statement that conjugation by any
   nonzero quaternion is an isometry — the source of the rotation groups
   `SO(3)` and `SO(4)`.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): the sum-of-squares core is the `n = 1` member of a
--   family of composition identities (two, four squares) tied to the normed
--   algebras ℂ and ℍ; the Hopf fibration should be characterisable *exactly* (not
--   merely one inclusion) using the same normed-algebra structure.
-- Experiment (Experimenter): Euler's and Brahmagupta's identities fall to `ring`.
--   The hard target was the converse Hopf inclusion.  A first attempt via complex
--   division z'/z needed case analysis on z = 0.  The breakthrough was the
--   division-free witness λ = z̄z' + w̄w': the fibre conditions force λz = z' and
--   λw = w' by two `linear_combination` computations, and |λ|² = 1 then follows
--   from multiplicativity of the norm.  Generalised J to ℂⁿ (multiplication by i)
--   and proved fixed-point freeness from I − 1 ≠ 0.  The 3-radius AM–GM bound
--   fell to `nlinarith` with symmetric square hints.
-- Analysis (Analyst): the two "inclusions" of a fibre have very different flavour
--   — the easy one is invariance under a group action, the hard one is a rigidity
--   statement recovering the group element from two orbit points.  The witness
--   λ = ⟨(z,w),(z',w')⟩ is the Hermitian inner product, revealing the Hopf fibre
--   as the phase ambiguity of a unit vector: the true bridge is projective.
-- Critique (Critic): every main theorem carries genuine hypotheses (unit-sphere
--   constraints, nonzero quaternion) and none is vacuous; the biconditional is
--   sharp because the forward direction needs the sphere constraint (dropping it,
--   scaling changes the image).  No result re-proves a catalog theorem verbatim:
--   the fibre converse and the biconditional are new.
-- Synthesis (PI): the "fourth dimension" is organised by normed division
--   algebras; the Hopf fibration is the projective quotient ℂ² → ℂP¹ ≅ S², and
--   its fibres are precisely the unit-scalar orbits — an exact, not approximate,
--   statement.
-/

import Mathlib

namespace Applications.FourthDimensionDeepening

open Complex Quaternion

/-! ## 1. Composition identities: two squares, three, and four -/

/-- The sum-of-squares core identity that drives the constructions. -/
theorem sum_of_squares_core (a b : ℝ) : (a + b) ^ 2 = 4 * a * b + (a - b) ^ 2 := by
  ring

/-- **Brahmagupta–Fibonacci two-square identity**: the product of two sums of two
squares is a sum of two squares.  This is the multiplicativity of the complex
modulus `|z₁ z₂| = |z₁| |z₂|` in coordinates. -/
theorem two_square_identity (a b c d : ℝ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring

/-- **Lagrange's three-variable identity**: the Gram determinant of two vectors in
`ℝ³` equals the squared norm of their cross product.  Nonnegativity of the right
side is exactly the Cauchy–Schwarz inequality in `ℝ³`. -/
theorem lagrange_identity_three (a₁ a₂ a₃ b₁ b₂ b₃ : ℝ) :
    (a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2) * (b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2)
        - (a₁ * b₁ + a₂ * b₂ + a₃ * b₃) ^ 2
      = (a₁ * b₂ - a₂ * b₁) ^ 2 + (a₁ * b₃ - a₃ * b₁) ^ 2 + (a₂ * b₃ - a₃ * b₂) ^ 2 := by
  ring

/-- Cauchy–Schwarz in `ℝ³`, read off from Lagrange's identity. -/
theorem cauchy_schwarz_three (a₁ a₂ a₃ b₁ b₂ b₃ : ℝ) :
    (a₁ * b₁ + a₂ * b₂ + a₃ * b₃) ^ 2
      ≤ (a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2) * (b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2) := by
  nlinarith [lagrange_identity_three a₁ a₂ a₃ b₁ b₂ b₃,
    sq_nonneg (a₁ * b₂ - a₂ * b₁), sq_nonneg (a₁ * b₃ - a₃ * b₁),
    sq_nonneg (a₂ * b₃ - a₃ * b₂)]

/-- **Euler's four-square identity**: the product of two sums of four squares is a
sum of four squares.  This is the multiplicativity of the quaternion norm
`N(pq) = N(p) N(q)` written out in coordinates — the algebraic heart of
four-dimensional geometry. -/
theorem four_square_identity (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℝ) :
    (a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2) * (b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2 + b₄ ^ 2)
      = (a₁ * b₁ - a₂ * b₂ - a₃ * b₃ - a₄ * b₄) ^ 2
      + (a₁ * b₂ + a₂ * b₁ + a₃ * b₄ - a₄ * b₃) ^ 2
      + (a₁ * b₃ - a₂ * b₄ + a₃ * b₁ + a₄ * b₂) ^ 2
      + (a₁ * b₄ + a₂ * b₃ - a₃ * b₂ + a₄ * b₁) ^ 2 := by
  ring

/-! ## 2. The Hopf fibration: fibres are exactly the great circles

We realise `S³ ⊆ ℂ²` and send `(z, w)` to `(2 z w̄, |z|² − |w|²) ∈ ℂ × ℝ`. -/

/-- The Hopf map from `ℂ²` to `ℂ × ℝ`. -/
noncomputable def hopf (z w : ℂ) : ℂ × ℝ :=
  (2 * z * (starRingEnd ℂ) w, Complex.normSq z - Complex.normSq w)

/-- The Hopf image lies on the two-sphere of radius `|z|² + |w|²`.  A direct
instance of the sum-of-squares core with `a = |z|²`, `b = |w|²`. -/
theorem hopf_image_on_sphere (z w : ℂ) :
    Complex.normSq (2 * z * (starRingEnd ℂ) w)
        + (Complex.normSq z - Complex.normSq w) ^ 2
      = (Complex.normSq z + Complex.normSq w) ^ 2 := by
  have h2 : Complex.normSq (2 : ℂ) = 4 := by simp [Complex.normSq]; norm_num
  simp only [Complex.normSq_mul, Complex.normSq_conj, h2]
  ring

/-- **Fibre, first inclusion (invariance).**  The Hopf map is constant along the
circle orbits `(z, w) ↦ (λz, λw)` with `|λ| = 1`. -/
theorem hopf_circle_invariant (z w l : ℂ) (hl : Complex.normSq l = 1) :
    hopf (l * z) (l * w) = hopf z w := by
  have hll : l * (starRingEnd ℂ) l = 1 := by
    rw [Complex.mul_conj]; exact_mod_cast hl
  refine Prod.ext ?_ ?_
  · simp only [hopf, map_mul]
    calc 2 * (l * z) * ((starRingEnd ℂ) l * (starRingEnd ℂ) w)
        = 2 * (l * (starRingEnd ℂ) l) * z * (starRingEnd ℂ) w := by ring
      _ = 2 * z * (starRingEnd ℂ) w := by rw [hll]; ring
  · simp only [hopf, Complex.normSq_mul, hl]; ring

/-- **Fibre, second inclusion (rigidity) — the deep step.**  Two points of the
unit three-sphere with the same Hopf image differ by a single unit complex
scalar.  The witness is the Hermitian inner product `λ = z̄z' + w̄w'`; the fibre
conditions force `λz = z'`, `λw = w'`, and then `|λ|² = 1`. -/
theorem hopf_fibre_converse (z w z' w' : ℂ)
    (hs : Complex.normSq z + Complex.normSq w = 1)
    (hs' : Complex.normSq z' + Complex.normSq w' = 1)
    (heq : hopf z w = hopf z' w') :
    ∃ l : ℂ, Complex.normSq l = 1 ∧ z' = l * z ∧ w' = l * w := by
  obtain ⟨h1, h2⟩ := Prod.mk.injEq .. ▸ heq
  have hP : z * (starRingEnd ℂ) w = z' * (starRingEnd ℂ) w' := by
    have := h1; field_simp at this ⊢; linear_combination this
  have hnw : Complex.normSq w = Complex.normSq w' := by nlinarith [hs, hs', h2]
  have hnz : Complex.normSq z = Complex.normSq z' := by nlinarith [hs, hs', h2]
  have hPc : (starRingEnd ℂ) z * w = (starRingEnd ℂ) z' * w' := by
    have := congrArg (starRingEnd ℂ) hP; simpa [mul_comm] using this
  set l : ℂ := (starRingEnd ℂ) z * z' + (starRingEnd ℂ) w * w' with hl
  have A : z * (starRingEnd ℂ) z = ((Complex.normSq z : ℝ) : ℂ) := Complex.mul_conj z
  have Aw : w * (starRingEnd ℂ) w = ((Complex.normSq w : ℝ) : ℂ) := Complex.mul_conj w
  have B : w' * (starRingEnd ℂ) w' = ((Complex.normSq w' : ℝ) : ℂ) := Complex.mul_conj w'
  have Bz : z' * (starRingEnd ℂ) z' = ((Complex.normSq z' : ℝ) : ℂ) := Complex.mul_conj z'
  have hC : ((Complex.normSq z : ℝ) : ℂ) + ((Complex.normSq w : ℝ) : ℂ) = 1 := by
    exact_mod_cast hs
  have hD : ((Complex.normSq w : ℝ) : ℂ) = ((Complex.normSq w' : ℝ) : ℂ) := by
    exact_mod_cast hnw
  have hnzc : ((Complex.normSq z : ℝ) : ℂ) = ((Complex.normSq z' : ℝ) : ℂ) := by
    exact_mod_cast hnz
  have hz' : z' = l * z := by
    rw [hl]; linear_combination (-z') * A - w' * hP - z' * B - z' * hC + z' * hD
  have hw' : w' = l * w := by
    rw [hl]; linear_combination (-z') * hPc - w' * Aw - w' * Bz + w' * hnzc - w' * hC
  refine ⟨l, ?_, hz', hw'⟩
  have hz2 : Complex.normSq z' = Complex.normSq l * Complex.normSq z := by
    rw [hz', Complex.normSq_mul]
  have hw2 : Complex.normSq w' = Complex.normSq l * Complex.normSq w := by
    rw [hw', Complex.normSq_mul]
  nlinarith [hz2, hw2, hs, hs']

/-- **The Hopf fibration, characterised.**  On the unit three-sphere, two points
have the same Hopf image *if and only if* they differ by a unit complex scalar:
the fibres are exactly the great circles `{(λz, λw) : |λ| = 1}`. -/
theorem hopf_fibre_iff (z w z' w' : ℂ)
    (hs : Complex.normSq z + Complex.normSq w = 1)
    (hs' : Complex.normSq z' + Complex.normSq w' = 1) :
    hopf z w = hopf z' w' ↔
      ∃ l : ℂ, Complex.normSq l = 1 ∧ z' = l * z ∧ w' = l * w := by
  constructor
  · intro heq; exact hopf_fibre_converse z w z' w' hs hs' heq
  · rintro ⟨l, hl, rfl, rfl⟩
    exact (hopf_circle_invariant z w l hl).symm

/-! ## 3. The complex structure `J = ·i` in every even dimension

Multiplication by `i` on `ℂⁿ ≅ ℝ^{2n}` is the general "rotation through the
fourth dimension": a fixed-point-free isometry squaring to `−1`. -/

/-- The canonical complex structure on `ℂⁿ`: multiply every coordinate by `i`. -/
def Jn {n : ℕ} (v : Fin n → ℂ) : Fin n → ℂ := fun i => Complex.I * v i

/-- `J² = −I`: `Jn` is a genuine complex structure. -/
theorem Jn_sq (n : ℕ) (v : Fin n → ℂ) : Jn (Jn v) = fun i => - v i := by
  funext i; simp [Jn, ← mul_assoc, Complex.I_mul_I]

/-- `Jn` preserves the Euclidean norm `∑ |vᵢ|²`: it is a linear isometry. -/
theorem Jn_preserves_normSq (n : ℕ) (v : Fin n → ℂ) :
    ∑ i, Complex.normSq (Jn v i) = ∑ i, Complex.normSq (v i) := by
  simp [Jn, Complex.normSq_mul]

/-- `Jn` is fixed-point-free on the sphere: it has no eigenvalue `1`, the concrete
form of the even-dimensional rotation having no invariant axis. -/
theorem Jn_fixedPointFree_onSphere (n : ℕ) (v : Fin n → ℂ)
    (h : ∑ i, Complex.normSq (v i) = 1) : Jn v ≠ v := by
  intro hEq
  have hcoord : ∀ i, Complex.I * v i = v i := fun i => congrFun hEq i
  have hz : ∀ i, v i = 0 := by
    intro i
    have hI : (Complex.I - 1) * v i = 0 := by linear_combination hcoord i
    rcases mul_eq_zero.mp hI with h1 | h1
    · exfalso
      have : Complex.I = 1 := by linear_combination h1
      simpa using congrArg Complex.re this
    · exact h1
  simp [hz] at h

/-! ## 4. Balanced radii and quaternionic rotational rigidity -/

/-- The Clifford balance identity: on `a + b = 1` we have `4ab = 1 − (a − b)²`,
so the torus area `√(4ab)` is maximal exactly at the balanced radii `a = b = ½`. -/
theorem clifford_balance (a b : ℝ) (h : a + b = 1) : 4 * a * b = 1 - (a - b) ^ 2 := by
  nlinarith [sum_of_squares_core a b, h]

/-- On the radius constraint `a + b = 1` the product `4ab` is extremal (`= 1`) iff
the radii are balanced (`a = b`). -/
theorem clifford_balanced_iff (a b : ℝ) (h : a + b = 1) : 4 * a * b = 1 ↔ a = b := by
  rw [clifford_balance a b h]
  constructor
  · intro hh
    have hsq : (a - b) ^ 2 = 0 := by linarith
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hsq
    linarith
  · intro hh; rw [hh]; ring

/-- **Three-radius Clifford balance (AM–GM).**  On the constraint
`a + b + c = 1` with nonnegative squared radii, the product `abc` never exceeds
`1/27`, attained only at the balanced torus `a = b = c = 1/3`.  The
generalisation of the balanced Clifford torus to `S⁵`. -/
theorem clifford_balance_three (a b c : ℝ)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) (h : a + b + c = 1) :
    a * b * c ≤ 1 / 27 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (a - c),
    mul_nonneg ha hb, mul_nonneg hb hc, mul_nonneg ha hc,
    mul_nonneg (mul_nonneg ha hb) hc,
    sq_nonneg (a + b - 2 * c), sq_nonneg (a + c - 2 * b), sq_nonneg (b + c - 2 * a)]

/-- **Quaternionic rotational rigidity.**  Conjugation by any nonzero quaternion
preserves the norm; on unit quaternions this realises the rotation groups
`SO(3)` (acting on the imaginary part) and `SO(4)`.  The four-square identity is
the coordinate form of the multiplicativity used here. -/
theorem quaternion_conj_isometry (q x : ℍ[ℝ]) (hq : q ≠ 0) :
    Quaternion.normSq (q * x * q⁻¹) = Quaternion.normSq x := by
  rw [map_mul, map_mul, map_inv₀]
  have hqn : Quaternion.normSq q ≠ 0 := by simpa [map_eq_zero] using hq
  field_simp

/-! ## Examples, generalisations, and boundaries -/

-- The Hopf image always lands on a two-sphere.
example : hopf 1 0 = (0, 1) := by simp [hopf]
-- The balanced Clifford torus saturates the area bound.
example : (4 : ℝ) * (1 / 2) * (1 / 2) = 1 := by norm_num
example : ((1 : ℝ) / 3) * (1 / 3) * (1 / 3) = 1 / 27 := by norm_num

#check @hopf_fibre_iff
#check @four_square_identity
#check @quaternion_conj_isometry

/-
### Generalisation
`Jn` is the complex structure on every even-dimensional space `ℝ^{2n}`; the same
three theorems (square, isometry, fixed-point freeness) hold uniformly in `n`.
The two-, and four-square identities are the `dim = 2, 4` members of the family of
composition algebras (ℝ, ℂ, ℍ, 𝕆); Hurwitz's theorem asserts the family stops at
`dim = 8`, so no analogous *bilinear* three-square identity exists — a genuine
obstruction rather than a missing computation.

### Boundary / limit cases
The Hopf biconditional `hopf_fibre_iff` needs the unit-sphere hypotheses: without
them the diagonal scaling `(z, w) ↦ (tz, tw)` multiplies the image by `t²`, so
distinct-norm points can never share an image and the "great-circle" description
fails.  The three-radius AM–GM bound is sharp (equality at `a = b = c = 1/3`) and
degenerates on the boundary of the simplex, where one radius vanishes and the
Clifford torus collapses to a lower-dimensional torus.
-/

end Applications.FourthDimensionDeepening