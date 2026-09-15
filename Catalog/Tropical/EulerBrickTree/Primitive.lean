/-
# The Euler Brick Tree, V: descent of bricks to primitive bricks

The Berggren descent of `Tropical.EulerBrickTree.Descent` organises the
*generated* bricks into a tree with one seed.  This file supplies the second
half of a descent theory: the reduction of an *arbitrary* Euler brick to a
primitive one.

* `isBrick_of_mul`: brick-hood descends through a common factor;
* `brick_descent`: every nonzero Euler brick is a positive integer multiple of a
  primitive Euler brick — every brick descends to a primitive brick, and the
  primitive bricks are the minimal elements of the brick space;
* `primitiveBrick_exactly_one_odd`: a primitive Euler brick has exactly one odd
  edge, the other two being divisible by `4`;
* `primitiveBrick_720_dvd`: consequently `720 ∣ xyz` for every primitive Euler
  brick.
-/
import Mathlib
import Tropical.EulerBrickTree.Core
import Tropical.EulerBrickTree.Obstruction

namespace EulerBrickTree

/-- The gcd of the three edges. -/
def gcd3 (x y z : ℤ) : ℕ := Nat.gcd (Nat.gcd x.natAbs y.natAbs) z.natAbs

/-- A *primitive* Euler brick: the three edges have no common factor. -/
def IsPrimitiveBrick (x y z : ℤ) : Prop := IsBrick x y z ∧ gcd3 x y z = 1

theorem gcd3_dvd_left (x y z : ℤ) : ((gcd3 x y z : ℕ) : ℤ) ∣ x :=
  Int.dvd_natAbs.mp (Int.natCast_dvd_natCast.mpr ((Nat.gcd_dvd_left _ _).trans
    (Nat.gcd_dvd_left _ _)))

theorem gcd3_dvd_mid (x y z : ℤ) : ((gcd3 x y z : ℕ) : ℤ) ∣ y :=
  Int.dvd_natAbs.mp (Int.natCast_dvd_natCast.mpr ((Nat.gcd_dvd_left _ _).trans
    (Nat.gcd_dvd_right _ _)))

theorem gcd3_dvd_right (x y z : ℤ) : ((gcd3 x y z : ℕ) : ℤ) ∣ z :=
  Int.dvd_natAbs.mp (Int.natCast_dvd_natCast.mpr (Nat.gcd_dvd_right _ _))

/-- Any common divisor of the three edges divides their gcd. -/
theorem dvd_gcd3 {x y z d : ℤ} (hx : d ∣ x) (hy : d ∣ y) (hz : d ∣ z) :
    d.natAbs ∣ gcd3 x y z :=
  Nat.dvd_gcd (Nat.dvd_gcd (Int.natAbs_dvd_natAbs.mpr hx) (Int.natAbs_dvd_natAbs.mpr hy))
    (Int.natAbs_dvd_natAbs.mpr hz)

theorem gcd3_pos {x y z : ℤ} (hne : ¬(x = 0 ∧ y = 0 ∧ z = 0)) : 0 < gcd3 x y z := by
  rcases Nat.eq_zero_or_pos (gcd3 x y z) with h0 | h
  · exfalso
    have h1 : Nat.gcd x.natAbs y.natAbs = 0 ∧ z.natAbs = 0 := Nat.gcd_eq_zero_iff.mp h0
    have h2 : x.natAbs = 0 ∧ y.natAbs = 0 := Nat.gcd_eq_zero_iff.mp h1.1
    exact hne ⟨Int.natAbs_eq_zero.mp h2.1, Int.natAbs_eq_zero.mp h2.2,
      Int.natAbs_eq_zero.mp h1.2⟩
  · exact h

/-- Brick-hood descends through a common factor. -/
theorem isBrick_of_mul {g x y z : ℤ} (hg : g ≠ 0) (h : IsBrick (g * x) (g * y) (g * z)) :
    IsBrick x y z := by
  have key : ∀ a b p : ℤ, (g * a) ^ 2 + (g * b) ^ 2 = p ^ 2 → ∃ q : ℤ, a ^ 2 + b ^ 2 = q ^ 2 := by
    intro a b p hp
    have hdvd : g ∣ p := by
      have h2 : g ^ 2 ∣ p ^ 2 := ⟨a ^ 2 + b ^ 2, by rw [← hp]; ring⟩
      exact (Int.pow_dvd_pow_iff (by norm_num)).mp h2
    obtain ⟨t, rfl⟩ := hdvd
    refine ⟨t, ?_⟩
    have hg2 : g ^ 2 ≠ 0 := pow_ne_zero _ hg
    have hcan : g ^ 2 * (a ^ 2 + b ^ 2) = g ^ 2 * t ^ 2 := by linear_combination hp
    exact mul_left_cancel₀ hg2 hcan
  obtain ⟨⟨p, hp⟩, ⟨q, hq⟩, ⟨r, hr⟩⟩ := h
  exact ⟨key x y p hp, key x z q hq, key y z r hr⟩

/-- **Descent to primitive bricks.**  Every Euler brick with a nonzero edge is a
positive multiple of a primitive Euler brick. -/
theorem brick_descent {x y z : ℤ} (h : IsBrick x y z) (hne : ¬(x = 0 ∧ y = 0 ∧ z = 0)) :
    ∃ g x' y' z' : ℤ, 0 < g ∧ x = g * x' ∧ y = g * y' ∧ z = g * z' ∧
      IsPrimitiveBrick x' y' z' := by
  set n : ℕ := gcd3 x y z with hn
  have hnpos : 0 < n := gcd3_pos hne
  set g : ℤ := (n : ℤ) with hgdef
  have hg0 : 0 < g := by rw [hgdef]; exact_mod_cast hnpos
  have hgx : g ∣ x := gcd3_dvd_left x y z
  have hgy : g ∣ y := gcd3_dvd_mid x y z
  have hgz : g ∣ z := gcd3_dvd_right x y z
  obtain ⟨x', hx'⟩ := hgx
  obtain ⟨y', hy'⟩ := hgy
  obtain ⟨z', hz'⟩ := hgz
  have hbrick' : IsBrick x' y' z' := by
    refine isBrick_of_mul (g := g) (by omega) ?_
    rw [← hx', ← hy', ← hz']
    exact h
  refine ⟨g, x', y', z', hg0, hx', hy', hz', hbrick', ?_⟩
  -- primitivity of the quotient
  set G : ℤ := ((gcd3 x' y' z' : ℕ) : ℤ) with hG
  have hGx : G ∣ x' := gcd3_dvd_left x' y' z'
  have hGy : G ∣ y' := gcd3_dvd_mid x' y' z'
  have hGz : G ∣ z' := gcd3_dvd_right x' y' z'
  have hprod : (G * g).natAbs ∣ n := by
    refine dvd_gcd3 ?_ ?_ ?_
    · obtain ⟨c, hc⟩ := hGx; exact ⟨c, by rw [hx', hc]; ring⟩
    · obtain ⟨c, hc⟩ := hGy; exact ⟨c, by rw [hy', hc]; ring⟩
    · obtain ⟨c, hc⟩ := hGz; exact ⟨c, by rw [hz', hc]; ring⟩
  have habs : (G * g).natAbs = gcd3 x' y' z' * n := by
    rw [hG, hgdef, Int.natAbs_mul, Int.natAbs_natCast, Int.natAbs_natCast]
  rw [habs] at hprod
  have hsplit : gcd3 x' y' z' * n ∣ 1 * n := by simpa using hprod
  exact Nat.dvd_one.mp (Nat.dvd_of_mul_dvd_mul_right hnpos hsplit)

/-! ## The 2-adic shape of a primitive brick -/

theorem isBrick_comm_xz {x y z : ℤ} (h : IsBrick x y z) : IsBrick z y x := by
  obtain ⟨⟨p, hp⟩, ⟨q, hq⟩, ⟨r, hr⟩⟩ := h
  exact ⟨⟨r, by linarith⟩, ⟨q, by linarith⟩, ⟨p, by linarith⟩⟩

theorem isBrick_comm_yz {x y z : ℤ} (h : IsBrick x y z) : IsBrick y x z := isBrick_comm_xy h

/-- **Exactly one odd edge.**  In a primitive Euler brick precisely one edge is
odd, and the other two are divisible by `4`. -/
theorem primitiveBrick_exactly_one_odd {x y z : ℤ} (h : IsPrimitiveBrick x y z) :
    (x % 2 = 1 ∧ (4:ℤ) ∣ y ∧ (4:ℤ) ∣ z) ∨
    (y % 2 = 1 ∧ (4:ℤ) ∣ x ∧ (4:ℤ) ∣ z) ∨
    (z % 2 = 1 ∧ (4:ℤ) ∣ x ∧ (4:ℤ) ∣ y) := by
  obtain ⟨hb, hprim⟩ := h
  obtain ⟨⟨p, hp⟩, ⟨q, hq⟩, ⟨r, hr⟩⟩ := hb
  -- not all three edges can be even, else `2` divides the gcd
  have hnotalleven : ¬ ((2:ℤ) ∣ x ∧ (2:ℤ) ∣ y ∧ (2:ℤ) ∣ z) := by
    rintro ⟨h1, h2, h3⟩
    have := dvd_gcd3 h1 h2 h3
    rw [hprim] at this
    simp at this
  rcases Int.emod_two_eq_zero_or_one x with hx | hx
  · rcases Int.emod_two_eq_zero_or_one y with hy | hy
    · -- `x, y` even, so `z` must be odd
      have hz : z % 2 = 1 := by
        rcases Int.emod_two_eq_zero_or_one z with hz | hz
        · exact absurd ⟨by omega, by omega, by omega⟩ hnotalleven
        · exact hz
      exact Or.inr (Or.inr ⟨hz, four_dvd_of_odd_leg hz (by linarith : z ^ 2 + x ^ 2 = q ^ 2),
        four_dvd_of_odd_leg hz (by linarith : z ^ 2 + y ^ 2 = r ^ 2)⟩)
    · exact Or.inr (Or.inl ⟨hy, four_dvd_of_odd_leg hy (by linarith : y ^ 2 + x ^ 2 = p ^ 2),
        four_dvd_of_odd_leg hy hr⟩)
  · exact Or.inl ⟨hx, four_dvd_of_odd_leg hx hp, four_dvd_of_odd_leg hx hq⟩

/-- **`720 ∣ xyz` for every primitive Euler brick.** -/
theorem primitiveBrick_720_dvd {x y z : ℤ} (h : IsPrimitiveBrick x y z) :
    (720 : ℤ) ∣ x * y * z := by
  rcases primitiveBrick_exactly_one_odd h with ⟨hx, -, -⟩ | ⟨hy, -, -⟩ | ⟨hz, -, -⟩
  · exact seven_hundred_twenty_dvd hx h.1
  · have hd := seven_hundred_twenty_dvd hy (isBrick_comm_yz h.1)
    have e : y * x * z = x * y * z := by ring
    rwa [e] at hd
  · have hd := seven_hundred_twenty_dvd hz (isBrick_comm_xz h.1)
    have e : z * y * x = x * y * z := by ring
    rwa [e] at hd

/-- The classical brick `(117,44,240)` is primitive. -/
theorem brick_root_primitive : IsPrimitiveBrick 117 44 240 :=
  ⟨brick_root_isBrick, by decide⟩

end EulerBrickTree