/-
# The Euler Brick Tree, I: the Saunderson generator over the Berggren tree

This file builds the *brick generator*: an explicit polynomial map sending a
Pythagorean triple `(u,v,w)` to an integer box whose three face diagonals are
integral (an Euler brick), together with closed formulas for the three face
diagonals and for the square of the space diagonal.

The catalog already contains

* the Berggren machinery on Pythagorean triples
  (`Tropical.BerggrenTrees.Parent_hyp_lt`, `Bridges.BerggrenTrees.BerggrenPythagoreanCore`),
* the static perfect-cuboid geometry (`Geometry.PerfectCuboid.AlgebraicSurface`:
  the diagonal cone `a²+b²+c² = 2d²` and the rational parametrization of the
  normalized quadric),
* small explicit bricks (`Algebra.AbstractAlgebra.EulerBricks`).

Here we add the *dynamic* layer: the generator, its diagonal identities, and the
exact arithmetic reduction of the perfect-cuboid condition on the generated
family to a single quartic square condition, namely that `w⁴ + 16u²v²` be a
square, i.e. that `(w², 4uv)` be the legs of a Pythagorean triple.
-/
import Mathlib
import Tropical.BerggrenTrees.Parent_hyp_lt

namespace EulerBrickTree

/-! ## Bricks -/

/-- An (integral) *Euler brick*: all three face diagonals of the box with edges
`x, y, z` are integers. -/
def IsBrick (x y z : ℤ) : Prop :=
  (∃ p : ℤ, x ^ 2 + y ^ 2 = p ^ 2) ∧
  (∃ q : ℤ, x ^ 2 + z ^ 2 = q ^ 2) ∧
  (∃ r : ℤ, y ^ 2 + z ^ 2 = r ^ 2)

/-- A *perfect cuboid*: an Euler brick whose space diagonal is integral too. -/
def IsPerfectCuboid (x y z : ℤ) : Prop :=
  IsBrick x y z ∧ ∃ s : ℤ, x ^ 2 + y ^ 2 + z ^ 2 = s ^ 2

/-- A brick is *nondegenerate* when all three edges are nonzero. -/
def Nondegenerate (x y z : ℤ) : Prop := x ≠ 0 ∧ y ≠ 0 ∧ z ≠ 0

theorem isBrick_comm_xy {x y z : ℤ} (h : IsBrick x y z) : IsBrick y x z := by
  obtain ⟨⟨p, hp⟩, ⟨q, hq⟩, ⟨r, hr⟩⟩ := h
  exact ⟨⟨p, by linarith⟩, ⟨r, hr⟩, ⟨q, hq⟩⟩

theorem isBrick_neg_left {x y z : ℤ} (h : IsBrick x y z) : IsBrick (-x) y z := by
  obtain ⟨⟨p, hp⟩, ⟨q, hq⟩, ⟨r, hr⟩⟩ := h
  refine ⟨⟨p, by rw [← hp]; ring⟩, ⟨q, by rw [← hq]; ring⟩, ⟨r, hr⟩⟩

/-- Bricks are stable under scaling of all edges. -/
theorem isBrick_scale {x y z : ℤ} (k : ℤ) (h : IsBrick x y z) :
    IsBrick (k * x) (k * y) (k * z) := by
  obtain ⟨⟨p, hp⟩, ⟨q, hq⟩, ⟨r, hr⟩⟩ := h
  refine ⟨⟨k * p, ?_⟩, ⟨k * q, ?_⟩, ⟨k * r, ?_⟩⟩ <;>
    · ring_nf
      nlinarith [hp, hq, hr]

/-! ## The Saunderson generator

Given a Pythagorean triple `(u,v,w)` (i.e. `u² + v² = w²`) the box
`(u(4v²-w²), v(4u²-w²), 4uvw)` is an Euler brick.  On the Berggren root
`(3,4,5)` it returns the classical brick `(117, 44, 240)`. -/

/-- The brick generator attached to a Pythagorean triple. -/
def brick (u v w : ℤ) : ℤ × ℤ × ℤ :=
  (u * (4 * v ^ 2 - w ^ 2), v * (4 * u ^ 2 - w ^ 2), 4 * u * v * w)

@[simp] theorem brick_fst (u v w : ℤ) : (brick u v w).1 = u * (4 * v ^ 2 - w ^ 2) := rfl
@[simp] theorem brick_snd (u v w : ℤ) : (brick u v w).2.1 = v * (4 * u ^ 2 - w ^ 2) := rfl
@[simp] theorem brick_thd (u v w : ℤ) : (brick u v w).2.2 = 4 * u * v * w := rfl

/-- First face diagonal: `x² + y² = (w³)²`, a *perfect cube* hypotenuse. -/
theorem brick_face_xy {u v w : ℤ} (h : IsPT u v w) :
    (u * (4 * v ^ 2 - w ^ 2)) ^ 2 + (v * (4 * u ^ 2 - w ^ 2)) ^ 2 = (w ^ 3) ^ 2 := by
  unfold IsPT at h
  linear_combination (16 * u ^ 2 * v ^ 2 + w ^ 4) * h

/-- Second face diagonal: `x² + z² = (u(w²+4v²))²`. -/
theorem brick_face_xz (u v w : ℤ) :
    (u * (4 * v ^ 2 - w ^ 2)) ^ 2 + (4 * u * v * w) ^ 2 = (u * (w ^ 2 + 4 * v ^ 2)) ^ 2 := by
  ring

/-- Third face diagonal: `y² + z² = (v(w²+4u²))²`. -/
theorem brick_face_yz (u v w : ℤ) :
    (v * (4 * u ^ 2 - w ^ 2)) ^ 2 + (4 * u * v * w) ^ 2 = (v * (w ^ 2 + 4 * u ^ 2)) ^ 2 := by
  ring

/-- **The generator produces Euler bricks.** -/
theorem brick_isBrick {u v w : ℤ} (h : IsPT u v w) :
    IsBrick (brick u v w).1 (brick u v w).2.1 (brick u v w).2.2 :=
  ⟨⟨w ^ 3, brick_face_xy h⟩, ⟨u * (w ^ 2 + 4 * v ^ 2), brick_face_xz u v w⟩,
    ⟨v * (w ^ 2 + 4 * u ^ 2), brick_face_yz u v w⟩⟩

/-- The Berggren root `(3,4,5)` is mapped to the classical smallest Euler brick
`(44, 117, 240)` (up to sign and order of the edges). -/
theorem brick_root : brick 3 4 5 = (117, 44, 240) := by
  norm_num [brick]

theorem root_isPT : IsPT 3 4 5 := by norm_num [IsPT]

theorem brick_root_isBrick : IsBrick 117 44 240 := by
  have := brick_isBrick root_isPT
  rwa [brick_root] at this

/-! ## The space diagonal of a generated brick -/

/-- The square of the space diagonal of the generated brick factors as
`w² * (w⁴ + 16 u² v²)`. -/
theorem brick_space_diagonal {u v w : ℤ} (h : IsPT u v w) :
    (u * (4 * v ^ 2 - w ^ 2)) ^ 2 + (v * (4 * u ^ 2 - w ^ 2)) ^ 2 + (4 * u * v * w) ^ 2
      = w ^ 2 * (w ^ 4 + 16 * u ^ 2 * v ^ 2) := by
  unfold IsPT at h
  linear_combination (16 * u ^ 2 * v ^ 2 + w ^ 4) * h

/-- **Exact reduction.**  For a nonzero `w`, the generated brick is a perfect
cuboid *iff* `w⁴ + 16u²v²` is a perfect square, i.e. iff `(w², 4uv)` are the
legs of a Pythagorean triple.  This converts the perfect-cuboid question on the
whole generated family into one quartic square condition. -/
theorem brick_perfect_iff {u v w : ℤ} (h : IsPT u v w) (hw : w ≠ 0) :
    IsPerfectCuboid (brick u v w).1 (brick u v w).2.1 (brick u v w).2.2 ↔
      ∃ s : ℤ, w ^ 4 + 16 * u ^ 2 * v ^ 2 = s ^ 2 := by
  constructor
  · rintro ⟨-, s, hs⟩
    simp only [brick_fst, brick_snd, brick_thd] at hs
    rw [brick_space_diagonal h] at hs
    -- `w² ∣ s²`, hence `w ∣ s`, and dividing gives the square root.
    have hdvd : w ∣ s := by
      have h2 : w ^ 2 ∣ s ^ 2 := ⟨w ^ 4 + 16 * u ^ 2 * v ^ 2, hs.symm⟩
      exact (Int.pow_dvd_pow_iff (by norm_num)).mp h2
    obtain ⟨t, rfl⟩ := hdvd
    refine ⟨t, ?_⟩
    have hw2 : (w : ℤ) ^ 2 ≠ 0 := pow_ne_zero _ hw
    have : w ^ 2 * (w ^ 4 + 16 * u ^ 2 * v ^ 2) = w ^ 2 * t ^ 2 := by
      rw [hs]; ring
    exact mul_left_cancel₀ hw2 this
  · rintro ⟨s, hs⟩
    refine ⟨brick_isBrick h, ⟨w * s, ?_⟩⟩
    simp only [brick_fst, brick_snd, brick_thd]
    rw [brick_space_diagonal h, hs]
    ring

/-! ## Nondegeneracy of the generated bricks -/

/-- For a primitive Pythagorean triple with positive entries the generated brick
has three nonzero edges. -/
theorem brick_nondegenerate {u v w : ℤ} (h : IsPT u v w) (hu : 0 < u) (hv : 0 < v)
    (hw : 0 < w) (hcop : Int.gcd u v = 1) :
    Nondegenerate (brick u v w).1 (brick u v w).2.1 (brick u v w).2.2 := by
  unfold IsPT at h
  have key : ∀ a b : ℤ, 0 < a → 0 < b → Int.gcd a b = 1 → a ^ 2 = 3 * b ^ 2 → False := by
    intro a b ha hb hab heq
    -- `b² ∣ a²` together with coprimality forces `b = 1`, and `a² = 3` is impossible.
    have hdvd : b.natAbs ∣ a.natAbs ^ 2 := by
      have : b ∣ a ^ 2 := ⟨3 * b, by linarith [heq]⟩
      simpa [Int.natAbs_pow] using Int.natAbs_dvd_natAbs.mpr this
    have hcopN : Nat.Coprime b.natAbs (a.natAbs ^ 2) :=
      Nat.Coprime.pow_right 2 (Nat.Coprime.symm hab)
    have hb1 : b.natAbs = 1 := Nat.Coprime.eq_one_of_dvd hcopN hdvd
    have hb' : b = 1 := by
      rcases Int.natAbs_eq b with hbe | hbe <;> omega
    subst hb'
    have h3 : a ^ 2 = 3 := by linarith
    rcases lt_or_ge a 2 with hlt | hge
    · interval_cases a
      omega
    · nlinarith
  refine ⟨?_, ?_, ?_⟩
  · intro hx
    rcases mul_eq_zero.mp hx with h0 | h0
    · exact absurd h0 (ne_of_gt hu)
    · exact key u v hu hv hcop (by nlinarith)
  · intro hy
    rcases mul_eq_zero.mp hy with h0 | h0
    · exact absurd h0 (ne_of_gt hv)
    · exact key v u hv hu (by rwa [Int.gcd_comm]) (by nlinarith)
  · have : (0:ℤ) < 4 * u * v * w := by positivity
    exact ne_of_gt this

end EulerBrickTree