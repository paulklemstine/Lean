/-
# Perfect Cuboid — Euler Brick Families

We construct infinite families of Euler bricks (face diagonals all integral)
and prove the existence of arbitrarily large Euler bricks.
-/
import Mathlib

namespace PerfectCuboid

/-- A natural number is a perfect square. -/
def IsSquare (n : ℕ) : Prop := ∃ k : ℕ, k ^ 2 = n

/-- An Euler brick: all three face diagonals are integers. -/
def IsEulerBrick (x y z : ℕ) : Prop :=
  IsSquare (x ^ 2 + y ^ 2) ∧
  IsSquare (x ^ 2 + z ^ 2) ∧
  IsSquare (y ^ 2 + z ^ 2)

/-- The classic smallest Euler brick: (44, 117, 240). -/
theorem euler_brick_44_117_240 : IsEulerBrick 44 117 240 := by
  unfold IsEulerBrick IsSquare
  exact ⟨⟨125, by norm_num⟩, ⟨244, by norm_num⟩, ⟨267, by norm_num⟩⟩

/-
Scaling preserves the Euler brick property.
-/
theorem euler_brick_scale {x y z : ℕ} (k : ℕ) (_hk : k > 0)
    (h : IsEulerBrick x y z) : IsEulerBrick (k * x) (k * y) (k * z) := by
  rcases h with ⟨ ⟨ a, ha ⟩, ⟨ b, hb ⟩, ⟨ c, hc ⟩ ⟩;
  constructor <;> ring_nf at *;
  · exact ⟨ k * a, by nlinarith ⟩;
  · exact ⟨ ⟨ k * b, by nlinarith ⟩, ⟨ k * c, by nlinarith ⟩ ⟩

/-
There exist arbitrarily large Euler bricks.
This follows from scaling the (44, 117, 240) brick.
-/
theorem exists_euler_bricks_arbitrarily_large :
    ∀ N : ℕ, ∃ x y z : ℕ, x ≥ N ∧ y ≥ N ∧ z ≥ N ∧ IsEulerBrick x y z := by
  intro N
  use (N+1) * 44, (N+1) * 117, (N+1) * 240;
  exact ⟨ by linarith, by linarith, by linarith, euler_brick_scale _ ( Nat.succ_pos _ ) ( euler_brick_44_117_240 ) ⟩

/-
Scaling the (44,117,240) brick gives an infinite family.
-/
theorem euler_brick_scaling_family (k : ℕ) (hk : k > 0) :
    IsEulerBrick (44 * k) (117 * k) (240 * k) := by
  convert euler_brick_scale k hk ( euler_brick_44_117_240 ) using 1 ; ring;
  · ring;
  · ring

/-- The Euler brick (240, 252, 275). -/
theorem euler_brick_240_252_275 : IsEulerBrick 240 252 275 := by
  unfold IsEulerBrick IsSquare
  exact ⟨⟨348, by norm_num⟩, ⟨365, by norm_num⟩, ⟨373, by norm_num⟩⟩

/-- The Euler brick (85, 132, 720). -/
theorem euler_brick_85_132_720 : IsEulerBrick 85 132 720 := by
  unfold IsEulerBrick IsSquare
  exact ⟨⟨157, by norm_num⟩, ⟨725, by norm_num⟩, ⟨732, by norm_num⟩⟩

end PerfectCuboid