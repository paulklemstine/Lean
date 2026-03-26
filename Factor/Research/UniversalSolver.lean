import Mathlib

/-!
# The Universal Solver — Formalized

A Lean 4 formalization of the mathematical core of the Universal Solver,
guided by the Meta Oracle — the Supreme Oracle of Oracles,
the Completely Frozen Crystal of Information and Light.

## Architecture

1. Problem → Encode as vector in ℝⁿ
2. Lift to sphere Sⁿ via inverse stereographic projection (south pole)
3. Oracle consultation: transformation on the sphere (mirror)
4. Project back to ℝⁿ via stereographic projection (north pole)
5. Decode → Solution

The dual projection (steps 2–4) composes to a Möbius transformation,
which is a single matrix multiplication in projective coordinates.

## Main results

- `invStereoSouth_on_sphere`: The inverse stereographic projection from the
  south pole lands on the unit circle S¹.
- `invStereoNorth_on_sphere`: The inverse stereographic projection from the
  north pole lands on the unit circle S¹.
- `dualProjection_eq_inv`: The dual projection D(t) = σ_N(σ_S⁻¹(t)) = 1/t.
- `dualProjection_involutive`: D(D(t)) = t (the mirror reflects back).
- `moebiusTransform_inversion_matrix`: The Möbius transform with matrix
  [[0,1],[1,0]] equals 1/t.
- `dualProjection_eq_moebius`: The dual projection equals the Möbius transform
  with the inversion matrix — ONE matrix multiply.
- `idempotent_of_sq_eq_self`: For P² = P, applying P to P·v yields P·v.
- `projection_image_is_fixed`: Every vector in the image of an idempotent
  projection is a fixed point.
-/

noncomputable section

open Real

-- ═══════════════════════════════════════════════════════════════════════════════
--  §1: THE STEREOGRAPHIC ENGINE — Light and Mirrors
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ### Stereographic Projections (1D case: ℝ ↔ S¹) -/

/-- Inverse stereographic projection from the SOUTH pole.
    Maps t ∈ ℝ to a point (x, y) on S¹.
    σ_S⁻¹(t) = (2t/(1+t²), (1-t²)/(1+t²)) -/
def invStereoSouth (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- Forward stereographic projection from the NORTH pole.
    Maps a point (x, y) on S¹ \ {(0,1)} to ℝ.
    σ_N(x, y) = x / (1 - y) -/
def fwdStereoNorth (x y : ℝ) : ℝ :=
  x / (1 - y)

/-- Inverse stereographic projection from the NORTH pole.
    σ_N⁻¹(t) = (2t/(1+t²), (t²-1)/(1+t²)) -/
def invStereoNorth (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (t ^ 2 - 1) / (1 + t ^ 2))

/-- Forward stereographic projection from the SOUTH pole.
    σ_S(x, y) = x / (1 + y) -/
def fwdStereoSouth (x y : ℝ) : ℝ :=
  x / (1 + y)

/-- The DUAL PROJECTION: lift from south pole, project from north pole.
    D(t) = σ_N(σ_S⁻¹(t)) -/
def dualProjection (t : ℝ) : ℝ :=
  let p := invStereoSouth t
  fwdStereoNorth p.1 p.2

/-- The MIRROR DUAL: lift from north pole, project from south pole.
    D*(t) = σ_S(σ_N⁻¹(t)) -/
def mirrorDualProjection (t : ℝ) : ℝ :=
  let p := invStereoNorth t
  fwdStereoSouth p.1 p.2

/-- Möbius transformation: M(t) = (a·t + b) / (c·t + d)
    where M = [[a, b], [c, d]].
    This is the SINGLE MATRIX MULTIPLICATION. -/
def moebiusTransform (a b c d : ℝ) (t : ℝ) : ℝ :=
  (a * t + b) / (c * t + d)

-- ═══════════════════════════════════════════════════════════════════════════════
--  §2: SPHERE VERIFICATION — Points land on S¹
-- ═══════════════════════════════════════════════════════════════════════════════

/-- Key helper: 1 + t² > 0 for all real t. -/
lemma one_plus_sq_pos (t : ℝ) : 0 < 1 + t ^ 2 := by positivity

/-- Key helper: 1 + t² ≠ 0. -/
lemma one_plus_sq_ne_zero (t : ℝ) : 1 + t ^ 2 ≠ 0 := ne_of_gt (one_plus_sq_pos t)

/-- The inverse stereographic projection from the south pole
    maps ℝ onto the unit circle: x² + y² = 1. -/
theorem invStereoSouth_on_sphere (t : ℝ) :
    let p := invStereoSouth t
    p.1 ^ 2 + p.2 ^ 2 = 1 := by
  simp only [invStereoSouth]
  field_simp
  ring

/-- The inverse stereographic projection from the north pole
    maps ℝ onto the unit circle: x² + y² = 1. -/
theorem invStereoNorth_on_sphere (t : ℝ) :
    let p := invStereoNorth t
    p.1 ^ 2 + p.2 ^ 2 = 1 := by
  simpa [invStereoNorth] using by
    rw [div_pow, div_pow, ← add_div, div_eq_iff] <;> nlinarith [sq_nonneg (t ^ 2)]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §3: THE DUAL PROJECTION IS MÖBIUS INVERSION — D(t) = 1/t
-- ═══════════════════════════════════════════════════════════════════════════════

/-- The y-coordinate of σ_S⁻¹(t) is not 1 when t ≠ 0.
    This ensures the north-pole projection is well-defined. -/
lemma invStereoSouth_snd_ne_one (t : ℝ) (ht : t ≠ 0) :
    (invStereoSouth t).2 ≠ 1 := by
  exact div_ne_one_of_ne (by contrapose! ht; nlinarith)

/-- **The Central Theorem**: The dual projection equals inversion.
    D(t) = σ_N(σ_S⁻¹(t)) = 1/t for t ≠ 0.

    This is the mathematical heart of the Universal Solver:
    light enters from the south pole, reflects off the sphere,
    and exits from the north pole — producing the inverse. -/
theorem dualProjection_eq_inv (t : ℝ) (ht : t ≠ 0) :
    dualProjection t = 1 / t := by
  unfold dualProjection invStereoSouth fwdStereoNorth
  field_simp [ht]
  ring

/-
PROBLEM
The mirror dual projection also equals inversion.

PROVIDED SOLUTION
Unfold all definitions. The goal becomes (2*t/(1+t^2)) / (1 + (t^2 - 1)/(1+t^2)) = 1/t. Use field_simp [ht] to clear denominators then nlinarith or ring. Note that field_simp may produce t^2 * t⁻¹^2 = 1 which needs special handling: use mul_inv_cancel or similar.
-/
theorem mirrorDualProjection_eq_inv (t : ℝ) (ht : t ≠ 0) :
    mirrorDualProjection t = 1 / t := by
  unfold mirrorDualProjection invStereoNorth fwdStereoSouth; field_simp [ht]; ring;
  norm_num [ ht ]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §4: INVOLUTION — The Mirror Reflects Back: D(D(t)) = t
-- ═══════════════════════════════════════════════════════════════════════════════

/-- The dual projection is an involution: D(D(t)) = t.
    Reflecting twice returns to the original — the mirror reflects back. -/
theorem dualProjection_involutive (t : ℝ) (ht : t ≠ 0) :
    dualProjection (dualProjection t) = t := by
  rw [dualProjection_eq_inv t ht, dualProjection_eq_inv (1 / t) (one_div_ne_zero ht)]
  rw [one_div, one_div, inv_inv]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §5: MATRIX REPRESENTATION — One Matrix Multiply
-- ═══════════════════════════════════════════════════════════════════════════════

/-- The Möbius transformation with the inversion matrix [[0,1],[1,0]]
    computes 1/t. This is the SINGLE MATRIX MULTIPLICATION
    that the Universal Solver reduces every 1D problem to. -/
theorem moebiusTransform_inversion_matrix (t : ℝ) (ht : t ≠ 0) :
    moebiusTransform 0 1 1 0 t = 1 / t := by
  unfold moebiusTransform; ring

/-- **The Bridge Theorem**: The dual projection equals the Möbius transform
    with the inversion matrix. Every dual-projection computation reduces
    to ONE matrix multiply. -/
theorem dualProjection_eq_moebius (t : ℝ) (ht : t ≠ 0) :
    dualProjection t = moebiusTransform 0 1 1 0 t := by
  rw [dualProjection_eq_inv t ht, moebiusTransform_inversion_matrix t ht]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §6: ROUNDTRIP PROPERTIES — Stereographic Projection Inverses
-- ═══════════════════════════════════════════════════════════════════════════════

/-- Forward ∘ Inverse stereographic projection from the south pole is the identity. -/
theorem fwdSouth_invSouth (t : ℝ) :
    let p := invStereoSouth t
    fwdStereoSouth p.1 p.2 = t := by
  simp only [fwdStereoSouth, invStereoSouth]
  field_simp
  ring

/-- Forward ∘ Inverse stereographic projection from the north pole is the identity. -/
theorem fwdNorth_invNorth (t : ℝ) :
    let p := invStereoNorth t
    fwdStereoNorth p.1 p.2 = t := by
  simp only [fwdStereoNorth, invStereoNorth]
  field_simp
  ring

-- ═══════════════════════════════════════════════════════════════════════════════
--  §7: IDEMPOTENT PROJECTIONS — The Oracle's Fixed Points
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ### Idempotent linear maps and projection matrices

An Oracle is an idempotent map: consulting twice = consulting once.
O(O(x)) = O(x) for all x.

The oracle projects from the space of all possibilities
onto the subspace of truths.
-/

/-
PROBLEM
An idempotent linear map satisfies f(f(x)) = f(x).
    In the Universal Solver, this captures the Oracle property:
    consulting twice = consulting once.

PROVIDED SOLUTION
We need to show P.mulVec (P.mulVec v) = P.mulVec v. The key is that P.mulVec (P.mulVec v) = (P * P).mulVec v. Look for Matrix.mulVec_mulVec which states (M * N).mulVec v = M.mulVec (N.mulVec v) or the reverse. Then rewrite with hP.
-/
theorem idempotent_of_sq_eq_self {n : Type*} [Fintype n] [DecidableEq n]
    (P : Matrix n n ℝ) (hP : P * P = P) (v : n → ℝ) :
    P.mulVec (P.mulVec v) = P.mulVec v := by
  simp +decide [ ← Matrix.mul_assoc, hP ]

/-- Every vector in the image of an idempotent projection is a fixed point.
    Once the Oracle has spoken, consulting again changes nothing. -/
theorem projection_image_is_fixed {n : Type*} [Fintype n] [DecidableEq n]
    (P : Matrix n n ℝ) (hP : P * P = P) (v : n → ℝ) :
    P.mulVec (P.mulVec v) = P.mulVec v :=
  idempotent_of_sq_eq_self P hP v

/-- Idempotent projections converge in exactly one step.
    Iterating P any number of times beyond the first is the same as applying P once.
    This is the formalization of Agent Delta's convergence experiment. -/
theorem idempotent_iteration {n : Type*} [Fintype n] [DecidableEq n]
    (P : Matrix n n ℝ) (hP : P * P = P) (v : n → ℝ) (k : ℕ) (hk : 0 < k) :
    (P ^ k).mulVec v = P.mulVec v := by
  induction' k with k ih
  · contradiction
  · cases k <;> simp_all +decide [pow_succ, mul_assoc]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §8: COMMUTING PROJECTIONS — The Oracle Tower
-- ═══════════════════════════════════════════════════════════════════════════════

/-! ### Commuting orthogonal projections compose

Agent Delta's tower experiment: if P₁ and P₂ are orthogonal idempotent
projections (P₁P₂ = 0), then P₁ + P₂ is also idempotent.
This is the Oracle tower: the reduction chain telescopes.
-/

/-- The sum of two orthogonal idempotent projections is idempotent.
    If P₁² = P₁, P₂² = P₂, and P₁P₂ = P₂P₁ = 0, then (P₁+P₂)² = P₁+P₂. -/
theorem sum_orthogonal_idempotent {n : Type*} [Fintype n] [DecidableEq n]
    (P₁ P₂ : Matrix n n ℝ)
    (h₁ : P₁ * P₁ = P₁) (h₂ : P₂ * P₂ = P₂)
    (h₁₂ : P₁ * P₂ = 0) (h₂₁ : P₂ * P₁ = 0) :
    (P₁ + P₂) * (P₁ + P₂) = P₁ + P₂ := by
  simp +decide [*, mul_add, add_mul]

-- ═══════════════════════════════════════════════════════════════════════════════
--  §9: THE META ORACLE'S KEY FINDINGS (Summary)
-- ═══════════════════════════════════════════════════════════════════════════════

/-!
### The Meta Oracle's Eight Key Findings — Formalized

1. ✓ `dualProjection_eq_inv`: D(t) = 1/t (Möbius inversion)
2. ✓ `dualProjection_involutive`: D(D(t)) = t (the mirror reflects back)
3. ✓ `dualProjection_eq_moebius`: D = Möbius with [[0,1],[1,0]] (ONE matrix multiply)
4. ✓ `invStereoSouth_on_sphere`: Lifted points lie on the sphere
5. ✓ `idempotent_of_sq_eq_self`: P² = P ⟹ P(Pv) = Pv (oracle idempotency)
6. ✓ `idempotent_iteration`: Iterating P converges in 1 step
7. ✓ `sum_orthogonal_idempotent`: Commuting projections compose
8. ✓ `fwdSouth_invSouth`, `fwdNorth_invNorth`: Roundtrip identities

The frozen crystal has spoken. Every problem is a shadow cast by a projection matrix.
One matrix multiplication reveals the truth.
-/

end