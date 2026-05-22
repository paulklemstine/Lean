/-
# Perfect Cuboid — Primitive Reduction

Every perfect cuboid scales from a primitive one. This is a foundational
reduction: the open problem need only be answered for primitive solutions.
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

/-- A perfect cuboid: Euler brick with integral space diagonal. -/
def IsPerfectCuboid (x y z : ℕ) : Prop :=
  IsEulerBrick x y z ∧ IsSquare (x ^ 2 + y ^ 2 + z ^ 2)

/-- `gcd(x, gcd(y, z)) = 1`. -/
def PrimitiveTriple (x y z : ℕ) : Prop :=
  Nat.gcd x (Nat.gcd y z) = 1

/-
**Key lemma:** if `g ∣ x`, `g ∣ y`, and `g^2 ∣ (x^2 + y^2)`,
then `IsSquare (x^2 + y^2)` implies `IsSquare ((x/g)^2 + (y/g)^2)`.
-/
theorem isSquare_sum_div {x y g : ℕ} (hg : g > 0)
    (hgx : g ∣ x) (hgy : g ∣ y)
    (h : IsSquare (x ^ 2 + y ^ 2)) :
    IsSquare ((x / g) ^ 2 + (y / g) ^ 2) := by
  -- Since g | x and g | y, write x = g*x', y = g*y'. Then x²+y² = g²(x'²+y'²).
  obtain ⟨x', hx'⟩ := hgx
  obtain ⟨y', hy'⟩ := hgy
  have h_eq : x^2 + y^2 = g^2 * (x'^2 + y'^2) := by
    grind;
  obtain ⟨ z, hz ⟩ := h;
  exact ⟨ z / g, by nlinarith [ Nat.div_mul_cancel ( show g ∣ z from Nat.pow_dvd_pow_iff ( by decide ) |>.1 <| hz.symm ▸ h_eq.symm ▸ dvd_mul_right _ _ ), Nat.div_mul_cancel ( show g ∣ x from hx'.symm ▸ dvd_mul_right _ _ ), Nat.div_mul_cancel ( show g ∣ y from hy'.symm ▸ dvd_mul_right _ _ ) ] ⟩

/-
Descaling: if `g ∣ x`, `g ∣ y`, `g ∣ z`, `g > 0`, and `(x,y,z)` is a
perfect cuboid, then `(x/g, y/g, z/g)` is also a perfect cuboid.
-/
theorem perfect_cuboid_descale {x y z g : ℕ}
    (hg : g > 0)
    (hgx : g ∣ x) (hgy : g ∣ y) (hgz : g ∣ z)
    (h : IsPerfectCuboid x y z) :
    IsPerfectCuboid (x / g) (y / g) (z / g) := by
  -- Apply the definition of IsPerfectCuboid
  rcases h with ⟨hBrick, hSpace⟩;
  constructor;
  · exact ⟨ isSquare_sum_div hg hgx hgy hBrick.1, isSquare_sum_div hg hgx hgz hBrick.2.1, isSquare_sum_div hg hgy hgz hBrick.2.2 ⟩;
  · -- Since $g^2$ divides $x^2 + y^2 + z^2$, we can write $x^2 + y^2 + z^2 = g^2 * k$ for some integer $k$.
    obtain ⟨k, hk⟩ : ∃ k : ℕ, x^2 + y^2 + z^2 = g^2 * k := by
      exact dvd_add ( dvd_add ( pow_dvd_pow_of_dvd hgx 2 ) ( pow_dvd_pow_of_dvd hgy 2 ) ) ( pow_dvd_pow_of_dvd hgz 2 );
    obtain ⟨ a, ha ⟩ := hSpace;
    -- Since $g$ divides $a$, we can write $a = g * m$ for some integer $m$.
    obtain ⟨m, hm⟩ : ∃ m : ℕ, a = g * m := by
      exact Nat.pow_dvd_pow_iff ( by decide ) |>.1 ( ha.symm ▸ hk.symm ▸ dvd_mul_right _ _ );
    use m;
    nlinarith [ Nat.div_mul_cancel hgx, Nat.div_mul_cancel hgy, Nat.div_mul_cancel hgz ]

/-
**Primitive reduction theorem.**
Every nontrivial perfect cuboid `(x, y, z)` scales from a primitive
perfect cuboid. The hypothesis `x + y + z > 0` excludes the degenerate
case `(0, 0, 0)`.
-/
theorem perfect_cuboid_has_primitive_scaling
    {x y z : ℕ} (h : IsPerfectCuboid x y z) (hpos : x + y + z > 0) :
    ∃ g x' y' z',
      g > 0 ∧
      x = g * x' ∧ y = g * y' ∧ z = g * z' ∧
      PrimitiveTriple x' y' z' ∧
      IsPerfectCuboid x' y' z' := by
  refine' ⟨ Nat.gcd x ( Nat.gcd y z ), x / Nat.gcd x ( Nat.gcd y z ), y / Nat.gcd x ( Nat.gcd y z ), z / Nat.gcd x ( Nat.gcd y z ), _, _, _, _, _, _ ⟩;
  grind;
  · rw [ Nat.mul_div_cancel' ( Nat.gcd_dvd_left _ _ ) ];
  · rw [ Nat.mul_div_cancel' ( Nat.dvd_trans ( Nat.gcd_dvd_right _ _ ) ( Nat.gcd_dvd_left _ _ ) ) ];
  · rw [ Nat.mul_div_cancel' ( Nat.dvd_trans ( Nat.gcd_dvd_right _ _ ) ( Nat.gcd_dvd_right _ _ ) ) ];
  · unfold PrimitiveTriple;
    rw [ Nat.gcd_div ];
    · rw [ Nat.gcd_div ( Nat.gcd_dvd_left _ _ ) ( Nat.gcd_dvd_right _ _ ), Nat.div_self ( Nat.pos_of_ne_zero ( by aesop ) ) ];
    · exact Nat.dvd_trans ( Nat.gcd_dvd_right _ _ ) ( Nat.gcd_dvd_left _ _ );
    · exact Nat.dvd_trans ( Nat.gcd_dvd_right _ _ ) ( Nat.gcd_dvd_right _ _ );
  · apply perfect_cuboid_descale;
    · contrapose! hpos; aesop;
    · exact Nat.gcd_dvd_left _ _;
    · exact Nat.dvd_trans ( Nat.gcd_dvd_right _ _ ) ( Nat.gcd_dvd_left _ _ );
    · exact Nat.dvd_trans ( Nat.gcd_dvd_right _ _ ) ( Nat.gcd_dvd_right _ _ );
    · assumption

end PerfectCuboid