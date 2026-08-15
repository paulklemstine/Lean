/-
# The Klein resolvent of `x⁴ + 8x + 12` and the conductor-9 cyclic cubic

The A₄-field of the experiment is the splitting field `L` of `x⁴ + 8x + 12`; the
fixed field `K = L^{V₄}` of the Klein group is the cubic field cut out by the
**Klein resolvent** `y³ - 48y - 64`, whose roots are `r₁r₂+r₃r₄`, `r₁r₃+r₂r₄`,
`r₁r₄+r₂r₃`.  This file proves, over an arbitrary commutative ring / field:

* `A4ForkPinning.klein_resolvent_root` — each `rᵢrⱼ + rₖrₗ` is a root of
  `y³ - 48y - 64` (Vieta computation, no analysis involved);
* `A4ForkPinning.klein_disc`, `A4ForkPinning.quartic_disc_eq_klein_disc`,
  `A4ForkPinning.quartic_disc` — the discriminant of the quartic equals that of
  its resolvent and equals `576²`: a **perfect square**, whence `Gal ⊆ A₄`;
* `A4ForkPinning.klein_resolvent_scaling` — `y³ - 48y - 64 = 64·(z³ - 3z - 1)`
  for `y = 4z`: the resolvent *is* the standard conductor-`9` cyclic cubic;
* `A4ForkPinning.zeta9_root` — `ζ₉ + ζ₉⁻¹` is a root of `z³ - 3z + 1`, and
  `A4ForkPinning.neg_zeta9_root` — `-(ζ₉+ζ₉⁻¹)` is a root of `z³ - 3z - 1`.
  So `K = ℚ(ζ₉)⁺`, the real cyclotomic field of **conductor 9**;
* `A4ForkPinning.no_rat_root_cubic`, `A4ForkPinning.klein_resolvent_no_rat_root`
  — the cubic is irreducible over `ℚ` (no rational root, degree 3), so `K` is a
  genuine cubic field;
* `A4ForkPinning.cubes_mod_nine` — the cubic residues mod `9` are exactly
  `{1, 8}`, a subgroup of index `3` in `(ℤ/9)ˣ`, and `A4ForkPinning.chi9` is the
  resulting cubic residue character with `chi9_mul`, `chi9_eq_zero_iff`.

Together: the `V₄`-fork of the A₄-field is governed by the cubic character mod `9`.
-/
import Mathlib

namespace A4ForkPinning

open Finset

/-! ## Vieta for the Klein resolvent -/

variable {R : Type*} [CommRing R]

/-- The three Klein resolvent values `r₁r₂+r₃r₄`, `r₁r₃+r₂r₄`, `r₁r₄+r₂r₃`
sum to the second elementary symmetric function. -/
theorem klein_sum_identity (a b c d : R) :
    (a * b + c * d) + (a * c + b * d) + (a * d + b * c)
      = a * b + a * c + a * d + b * c + b * d + c * d := by ring

/-- Second symmetric function of the resolvent values, in terms of the `eᵢ`. -/
theorem klein_pair_identity (a b c d : R) :
    (a * b + c * d) * (a * c + b * d) + (a * c + b * d) * (a * d + b * c)
        + (a * d + b * c) * (a * b + c * d)
      = (a + b + c + d) * (a * b * c + a * b * d + a * c * d + b * c * d)
        - 4 * (a * b * c * d) := by ring

/-- Third symmetric function of the resolvent values, in terms of the `eᵢ`. -/
theorem klein_prod_identity (a b c d : R) :
    (a * b + c * d) * ((a * c + b * d) * (a * d + b * c))
      = (a + b + c + d) ^ 2 * (a * b * c * d)
        - 4 * (a * b + a * c + a * d + b * c + b * d + c * d) * (a * b * c * d)
        + (a * b * c + a * b * d + a * c * d + b * c * d) ^ 2 := by ring

section Quartic

variable {a b c d : R}
  (h1 : a + b + c + d = 0)
  (h2 : a * b + a * c + a * d + b * c + b * d + c * d = 0)
  (h3 : a * b * c + a * b * d + a * c * d + b * c * d = -8)
  (h4 : a * b * c * d = 12)

include h1 h2 h3 h4

omit h1 h3 h4 in
/-- For the roots of `x⁴ + 8x + 12`, the Klein resolvent values sum to `0`. -/
theorem klein_sum : (a * b + c * d) + (a * c + b * d) + (a * d + b * c) = 0 := by
  rw [klein_sum_identity, h2]

omit h2 in
/-- … have second symmetric function `-48`. -/
theorem klein_pair :
    (a * b + c * d) * (a * c + b * d) + (a * c + b * d) * (a * d + b * c)
      + (a * d + b * c) * (a * b + c * d) = -48 := by
  rw [klein_pair_identity, h1, h3, h4]; ring

/-- … and product `64`.  So they are the roots of `y³ - 48y - 64`. -/
theorem klein_prod : (a * b + c * d) * (a * c + b * d) * (a * d + b * c) = 64 := by
  have h := klein_prod_identity a b c d
  rw [h1, h2, h3, h4] at h
  rw [show (a * b + c * d) * (a * c + b * d) * (a * d + b * c)
      = (a * b + c * d) * ((a * c + b * d) * (a * d + b * c)) by ring, h]
  ring

/-- **The Klein resolvent.**  If `a, b, c, d` are the roots of `x⁴ + 8x + 12`, then
`ab + cd` is a root of `y³ - 48y - 64`. -/
theorem klein_resolvent_root : (a * b + c * d) ^ 3 - 48 * (a * b + c * d) - 64 = 0 := by
  have hs := klein_sum h2
  have hp := klein_pair h1 h3 h4
  have hq := klein_prod h1 h2 h3 h4
  set A := a * b + c * d
  set B := a * c + b * d
  set C := a * d + b * c
  linear_combination A ^ 2 * hs - A * hp + hq

end Quartic

/-! ## Discriminants -/

/-- Discriminant of a depressed cubic in terms of its roots. -/
theorem cubic_disc_identity {x y z : R} (h : x + y + z = 0) :
    ((x - y) * (y - z) * (z - x)) ^ 2
      = -4 * (x * y + y * z + z * x) ^ 3 - 27 * (x * y * z) ^ 2 := by
  have hz : z = -x - y := by linear_combination h
  subst hz; ring

/-- Discriminant of the depressed cubic `y³ - 48y - 64`: `4·48³ - 27·64² = 576²`. -/
theorem cubic_disc_value {x y z : R} (hs : x + y + z = 0) (hp : x * y + y * z + z * x = -48)
    (hq : x * y * z = 64) : ((x - y) * (y - z) * (z - x)) ^ 2 = 576 ^ 2 := by
  rw [cubic_disc_identity hs, hp, hq]; norm_num

/-- **The discriminant of a quartic equals the discriminant of its Klein resolvent**
— the identity behind "square discriminant ⟹ `Gal ⊆ A₄`". -/
theorem quartic_disc_eq_klein_disc (a b c d : R) :
    ((a - b) * (a - c) * (a - d) * (b - c) * (b - d) * (c - d)) ^ 2
      = (((a * b + c * d) - (a * c + b * d)) * ((a * c + b * d) - (a * d + b * c))
          * ((a * d + b * c) - (a * b + c * d))) ^ 2 := by ring

section Disc

variable {a b c d : R}
  (h1 : a + b + c + d = 0)
  (h2 : a * b + a * c + a * d + b * c + b * d + c * d = 0)
  (h3 : a * b * c + a * b * d + a * c * d + b * c * d = -8)
  (h4 : a * b * c * d = 12)

include h1 h2 h3 h4

/-- The discriminant of the Klein resolvent `y³ - 48y - 64` is `576² = 2¹²·3⁴`. -/
theorem klein_disc :
    (((a * b + c * d) - (a * c + b * d)) * ((a * c + b * d) - (a * d + b * c))
        * ((a * d + b * c) - (a * b + c * d))) ^ 2 = 576 ^ 2 :=
  cubic_disc_value (klein_sum h2) (klein_pair h1 h3 h4) (klein_prod h1 h2 h3 h4)

/-- **`disc(x⁴ + 8x + 12) = 576²` is a perfect square**, so the Galois group has no
transposition: `Gal ⊆ A₄`.  (Combined with the `[4,1,0]` root statistics and
transitivity this pins the group to `A₄`.) -/
theorem quartic_disc :
    ((a - b) * (a - c) * (a - d) * (b - c) * (b - d) * (c - d)) ^ 2 = 576 ^ 2 := by
  rw [quartic_disc_eq_klein_disc]
  exact klein_disc h1 h2 h3 h4

end Disc

/-! ## The resolvent *is* the conductor-9 cyclic cubic -/

/-- `y³ - 48y - 64 = 64·(z³ - 3z - 1)` under `y = 4z`: the Klein resolvent is the
standard cyclic cubic of conductor `9`, rescaled. -/
theorem klein_resolvent_scaling (z : R) :
    (4 * z) ^ 3 - 48 * (4 * z) - 64 = 64 * (z ^ 3 - 3 * z - 1) := by ring

/-- `z³ - 3z - 1` and `z³ - 3z + 1` define the same field: the roots differ by sign. -/
theorem cubic_neg_root {K : Type*} [CommRing K] (z : K) (h : z ^ 3 - 3 * z + 1 = 0) :
    (-z) ^ 3 - 3 * (-z) - 1 = 0 := by linear_combination -h

/-- **`ζ₉ + ζ₉⁻¹` is a root of `z³ - 3z + 1`.**  Hence the cubic field of the Klein
resolvent is the real cyclotomic field `ℚ(ζ₉)⁺`, of conductor `9`. -/
theorem zeta9_root {K : Type*} [Field K] (zeta : K) (h9 : zeta ^ 9 = 1) (h3 : zeta ^ 3 ≠ 1) :
    (zeta + zeta⁻¹) ^ 3 - 3 * (zeta + zeta⁻¹) + 1 = 0 := by
  have hz : zeta ≠ 0 := by
    intro h
    rw [h] at h9
    simp at h9
  have hu : (zeta ^ 3) ^ 3 = 1 := by rw [← pow_mul]; simpa using h9
  have hfac : (zeta ^ 3 - 1) * ((zeta ^ 3) ^ 2 + zeta ^ 3 + 1) = 0 := by linear_combination hu
  have hsum : (zeta ^ 3) ^ 2 + zeta ^ 3 + 1 = 0 := by
    rcases mul_eq_zero.1 hfac with h | h
    · exact absurd (by linear_combination h : zeta ^ 3 = 1) h3
    · exact h
  field_simp
  linear_combination hsum

/-- The corresponding root of the (un-rescaled) resolvent cubic. -/
theorem neg_zeta9_root {K : Type*} [Field K] (zeta : K) (h9 : zeta ^ 9 = 1) (h3 : zeta ^ 3 ≠ 1) :
    (4 * (-(zeta + zeta⁻¹))) ^ 3 - 48 * (4 * (-(zeta + zeta⁻¹))) - 64 = 0 := by
  rw [klein_resolvent_scaling]
  rw [cubic_neg_root _ (zeta9_root zeta h9 h3)]
  ring

/-! ## Irreducibility over `ℚ` -/

/-- The conductor-`9` cubic has no rational root, hence (being cubic) is irreducible
over `ℚ`: `K` is a genuine cubic field. -/
theorem no_rat_root_cubic : ∀ z : ℚ, z ^ 3 - 3 * z + 1 ≠ 0 := by
  intro z hz
  have hden : (z.den : ℚ) ≠ 0 := by exact_mod_cast z.den_nz
  have hzz : (z.num : ℚ) = z * z.den := (div_eq_iff hden).1 (Rat.num_div_den z)
  have key : z.num ^ 3 - 3 * z.num * (z.den : ℤ) ^ 2 + (z.den : ℤ) ^ 3 = 0 := by
    have h : ((z.num : ℚ) ^ 3 - 3 * (z.num : ℚ) * ((z.den : ℤ) : ℚ) ^ 2
        + ((z.den : ℤ) : ℚ) ^ 3 : ℚ) = 0 := by
      push_cast
      rw [hzz]
      linear_combination ((z.den : ℚ)) ^ 3 * hz
    exact_mod_cast h
  have hb : (z.den : ℤ) ∣ z.num ^ 3 :=
    ⟨3 * z.num * (z.den : ℤ) - (z.den : ℤ) ^ 2, by linarith [key]⟩
  have hcop : IsCoprime z.num ((z.den : ℤ)) := by
    rw [Int.isCoprime_iff_gcd_eq_one]; exact z.reduced
  have hbu : IsUnit ((z.den : ℤ)) := (IsCoprime.pow_left hcop).isUnit_of_dvd' hb (dvd_refl _)
  have hb1 : (z.den : ℤ) = 1 := by
    rcases Int.isUnit_iff.1 hbu with h | h
    · exact h
    · exfalso
      have : (0 : ℤ) < z.den := by exact_mod_cast z.pos
      omega
  rw [hb1] at key
  have hdvd : z.num ∣ 1 := ⟨-(z.num ^ 2 - 3), by linarith [key]⟩
  rcases Int.isUnit_iff.1 (isUnit_of_dvd_one hdvd) with h | h <;> rw [h] at key <;> norm_num at key

/-- The Klein resolvent itself has no rational root. -/
theorem klein_resolvent_no_rat_root : ∀ y : ℚ, y ^ 3 - 48 * y - 64 ≠ 0 := by
  intro y hy
  have h4 : y = 4 * (y / 4) := by ring
  have hz : (-(y / 4)) ^ 3 - 3 * (-(y / 4)) + 1 = 0 := by
    have : (4 * (y / 4)) ^ 3 - 48 * (4 * (y / 4)) - 64 = 0 := by rw [← h4]; exact hy
    rw [klein_resolvent_scaling] at this
    have h64 : (y / 4) ^ 3 - 3 * (y / 4) - 1 = 0 := by linarith [this]
    linear_combination -h64
  exact no_rat_root_cubic _ hz

/-! ## The cubic residue character mod 9 -/

/-- **Cubes mod 9.**  A unit mod `9` is a cube exactly when it is `≡ ±1 (mod 9)`.
The cubes form the index-`3` subgroup `{1, 8}` of the cyclic group `(ℤ/9)ˣ` of
order `6` — this is the conductor-`9` cubic residue symbol. -/
theorem cubes_mod_nine (x : ZMod 9) (hx : IsUnit x) :
    (∃ y : ZMod 9, y ^ 3 = x) ↔ (x = 1 ∨ x = 8) := by
  revert hx
  revert x
  decide

theorem card_units_mod_nine : Fintype.card (ZMod 9)ˣ = 6 := by decide

/-- The cubic residue character mod `9`, valued in `ℤ/3`
(`{1,8} ↦ 0`, `{2,7} ↦ 1`, `{4,5} ↦ 2`). -/
def chi9 (x : ZMod 9) : ZMod 3 :=
  if x = 1 ∨ x = 8 then 0 else if x = 2 ∨ x = 7 then 1 else 2

/-- `chi9` is multiplicative on units: it is a genuine cubic Dirichlet character. -/
theorem chi9_mul : ∀ x y : ZMod 9, IsUnit x → IsUnit y → chi9 (x * y) = chi9 x + chi9 y := by
  decide

/-- Its kernel on units is exactly the set of cubes: the fork "`p` is a cube mod 9". -/
theorem chi9_eq_zero_iff : ∀ x : ZMod 9, IsUnit x → (chi9 x = 0 ↔ (∃ y : ZMod 9, y ^ 3 = x)) := by
  decide

/-- The fork is *not* visible mod `3`: both classes mod `3` contain cubes and
non-cubes, so the conductor cannot be lowered.  (Minimality of the modulus `9`.) -/
theorem mod_three_flat : ∀ t : ZMod 9, IsUnit t → ∃ x y : ZMod 9, IsUnit x ∧ IsUnit y ∧
    x.val % 3 = t.val % 3 ∧ y.val % 3 = t.val % 3 ∧ chi9 x = 0 ∧ chi9 y ≠ 0 := by
  decide

end A4ForkPinning