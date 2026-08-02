/-
# Perfect cuboids: an Euler brick near-miss and its algebraic surface

This file gives a self-contained formalization of Euler bricks and perfect
cuboids.  It verifies the classical brick `(44,117,240)`, proves that its space
diagonal is not integral, derives the diagonal-cone equation, and gives a
rational parametrization of the quadric underlying the normalized equations.
-/
import Mathlib

namespace PerfectCuboidResearch

/-- `n` is a square of a natural number. -/
def IsSquare (n : ℕ) : Prop := ∃ k : ℕ, k ^ 2 = n

/-- All three face diagonals of the box are integral. -/
def IsEulerBrick (x y z : ℕ) : Prop :=
  IsSquare (x ^ 2 + y ^ 2) ∧
  IsSquare (x ^ 2 + z ^ 2) ∧
  IsSquare (y ^ 2 + z ^ 2)

/-- An Euler brick whose space diagonal is also integral. -/
def IsPerfectCuboid (x y z : ℕ) : Prop :=
  IsEulerBrick x y z ∧ IsSquare (x ^ 2 + y ^ 2 + z ^ 2)

/-- The classical `(44,117,240)` box has integral face diagonals
`125`, `244`, and `267`. -/
theorem brick_44_117_240 : IsEulerBrick 44 117 240 := by
  refine ⟨⟨125, by norm_num [pow_two]⟩, ⟨244, by norm_num [pow_two]⟩,
    ⟨267, by norm_num [pow_two]⟩⟩

/-- `73225`, the squared space diagonal of `(44,117,240)`, lies strictly
between `270²` and `271²`, so it is not a square. -/
theorem not_square_73225 : ¬ IsSquare 73225 := by
  rintro ⟨k, hk⟩
  have hk_le : k ≤ 270 := by
    by_contra h
    have h271 : 271 ≤ k := by omega
    nlinarith
  nlinarith

/-- The classical Euler brick is a genuine near-miss, not a perfect cuboid. -/
theorem brick_44_117_240_not_perfect :
    IsEulerBrick 44 117 240 ∧ ¬ IsPerfectCuboid 44 117 240 := by
  refine ⟨brick_44_117_240, ?_⟩
  rintro ⟨_, hs⟩
  apply not_square_73225
  norm_num [IsSquare, pow_two] at hs ⊢
  exact hs

/-- Scaling preserves all integral face diagonals.  Positivity of the scale is
not needed: the zero scale is algebraically valid as well. -/
theorem scale_euler_brick {x y z : ℕ} (k : ℕ)
    (h : IsEulerBrick x y z) : IsEulerBrick (k * x) (k * y) (k * z) := by
  rcases h with ⟨⟨a, ha⟩, ⟨b, hb⟩, ⟨c, hc⟩⟩
  refine ⟨⟨k * a, ?_⟩, ⟨k * b, ?_⟩, ⟨k * c, ?_⟩⟩
  · simp only [mul_pow]
    rw [ha]
    ring
  · simp only [mul_pow]
    rw [hb]
    ring
  · simp only [mul_pow]
    rw [hc]
    ring

/-- Scaling also preserves (hypothetical) perfect cuboids. -/
theorem scale_perfect_cuboid {x y z : ℕ} (k : ℕ)
    (h : IsPerfectCuboid x y z) :
    IsPerfectCuboid (k * x) (k * y) (k * z) := by
  rcases h with ⟨hfaces, ⟨d, hd⟩⟩
  refine ⟨scale_euler_brick k hfaces, ⟨k * d, ?_⟩⟩
  simp only [mul_pow]
  rw [hd]
  ring

/-- Face and space diagonals of any rational perfect cuboid lie on the
`(3,1)` diagonal cone `a²+b²+c² = 2d²`. -/
theorem diagonal_cone_equation
    {x y z a b c d : ℚ}
    (ha : a ^ 2 = x ^ 2 + y ^ 2)
    (hb : b ^ 2 = x ^ 2 + z ^ 2)
    (hc : c ^ 2 = y ^ 2 + z ^ 2)
    (hd : d ^ 2 = x ^ 2 + y ^ 2 + z ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 = 2 * d ^ 2 := by
  nlinarith

/-- Conversely, the three face equations and the diagonal-cone equation force
the space-diagonal equation.  Thus the cone is an exact replacement for the
fourth equation once all face equations are known. -/
theorem diagonal_cone_equation_converse
    {x y z a b c d : ℚ}
    (ha : a ^ 2 = x ^ 2 + y ^ 2)
    (hb : b ^ 2 = x ^ 2 + z ^ 2)
    (hc : c ^ 2 = y ^ 2 + z ^ 2)
    (hcone : a ^ 2 + b ^ 2 + c ^ 2 = 2 * d ^ 2) :
    d ^ 2 = x ^ 2 + y ^ 2 + z ^ 2 := by
  nlinarith

/-- The affine quadric that appears after normalizing one edge of a perfect
cuboid. -/
def OnCuboidQuadric (u v w : ℚ) : Prop := w ^ 2 = u ^ 2 + v ^ 2 - 1

/-- Normalizing two face diagonals and the space diagonal by a nonzero edge
produces a rational point on `w² = u²+v²-1`. -/
theorem normalization_lands_on_quadric
    {x y z a b d : ℚ} (hx : x ≠ 0)
    (ha : a ^ 2 = x ^ 2 + y ^ 2)
    (hb : b ^ 2 = x ^ 2 + z ^ 2)
    (hd : d ^ 2 = x ^ 2 + y ^ 2 + z ^ 2) :
    OnCuboidQuadric (a / x) (b / x) (d / x) := by
  unfold OnCuboidQuadric
  field_simp
  nlinarith

/-- A two-parameter rational parametrization of the quadric
`w² = u²+v²-1`, obtained by intersecting it with lines through `(1,0,0)`.
The exceptional locus is the tangent condition `1+p²-q²=0`. -/
theorem quadric_rational_parametrization (p q : ℚ)
    (hden : 1 + p ^ 2 - q ^ 2 ≠ 0) :
    OnCuboidQuadric
      ((p ^ 2 - q ^ 2 - 1) / (1 + p ^ 2 - q ^ 2))
      ((-2 * p) / (1 + p ^ 2 - q ^ 2))
      ((-2 * q) / (1 + p ^ 2 - q ^ 2)) := by
  unfold OnCuboidQuadric
  field_simp
  ring

/-- The parametrization is complete away from its base point: every rational
point on the quadric with `u ≠ 1` is recovered by taking the slopes
`p = v/(u-1)` and `q = w/(u-1)`. -/
theorem quadric_parametrization_complete
    {u v w : ℚ} (hquad : OnCuboidQuadric u v w) (hu : u ≠ 1) :
    let p := v / (u - 1)
    let q := w / (u - 1)
    1 + p ^ 2 - q ^ 2 ≠ 0 ∧
      u = (p ^ 2 - q ^ 2 - 1) / (1 + p ^ 2 - q ^ 2) ∧
      v = (-2 * p) / (1 + p ^ 2 - q ^ 2) ∧
      w = (-2 * q) / (1 + p ^ 2 - q ^ 2) := by
  dsimp
  unfold OnCuboidQuadric at hquad
  have hsub : u - 1 ≠ 0 := sub_ne_zero.mpr hu
  have hD : 1 + (v / (u - 1)) ^ 2 - (w / (u - 1)) ^ 2 =
      -2 / (u - 1) := by
    field_simp [hsub]
    nlinarith
  have hden : 1 + (v / (u - 1)) ^ 2 - (w / (u - 1)) ^ 2 ≠ 0 := by
    rw [hD]
    exact div_ne_zero (by norm_num) hsub
  have hN : (v / (u - 1)) ^ 2 - (w / (u - 1)) ^ 2 - 1 =
      (-2 * u) / (u - 1) := by
    field_simp [hsub]
    nlinarith
  refine ⟨hden, ?_⟩
  rw [hD, hN]
  constructor
  · field_simp [hsub]
  constructor
  · field_simp [hsub]
  · field_simp [hsub]

end PerfectCuboidResearch