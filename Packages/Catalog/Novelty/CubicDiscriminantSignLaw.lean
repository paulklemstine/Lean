/-
# The discriminant sign law for a cubic with a rational root

For a depressed cubic `f = X³ + a X + b` over a field of characteristic `≠ 2`, the
*sign character* of the Galois action on the roots is detected by whether the
discriminant `Δ = -4a³ - 27b²` is a square.  This file proves, for every field,
the "reducible half" of that law (Stickelberger's parity for cubics):

* `disc_factor` : if `f(r) = 0`, then `Δ = (-3r² - 4a) (3r² + a)²`, i.e. `Δ` is the
  discriminant of the residual quadratic up to a square.
* `isSquare_disc_iff` : if `f(r) = 0` and `Δ ≠ 0`, then
  `Δ` is a square  ↔  `f` has a second root `s ≠ r`.

So, for primes at which `f` has a root, the splitting type "1 + 2" (odd Frobenius,
a transposition) occurs exactly when `Δ` is a non-square.  The sign character of
the splitting field is the quadratic character of `Δ`: its conductor is attached
to the discriminant (`3` for `x³ - 2`, `31` for `x³ + x + 1`), while the *shape* of
the channel is attached only to the group `S₃`.
-/
import Mathlib

namespace CubicDiscriminantSignLaw

variable {F : Type*} [Field F]

/-- The depressed cubic `X³ + a X + b`, evaluated at `x`. -/
def cubic (a b x : F) : F := x ^ 3 + a * x + b

/-- Its discriminant `-4a³ - 27b²`. -/
def disc (a b : F) : F := -4 * a ^ 3 - 27 * b ^ 2

/-- Factor theorem for the cubic with root `r`: `f = (X - r) (X² + r X + (a + r²))`. -/
lemma cubic_factor (a b r x : F) (hr : cubic a b r = 0) :
    cubic a b x = (x - r) * (x ^ 2 + r * x + (a + r ^ 2)) := by
  unfold cubic at *
  linear_combination hr

/-- The discriminant of a cubic with root `r` is the discriminant `-3r² - 4a` of the
residual quadratic times the square of the residual quadratic's value at `r`. -/
theorem disc_factor (a b r : F) (hr : cubic a b r = 0) :
    disc a b = (-3 * r ^ 2 - 4 * a) * (3 * r ^ 2 + a) ^ 2 := by
  unfold cubic disc at *
  have hb : b = -r ^ 3 - a * r := by linear_combination hr
  subst hb
  ring

/-- **Stickelberger's parity law, reducible case.**  Let `f = X³ + aX + b` have a root
`r` in a field of characteristic `≠ 2` and non-zero discriminant.  Then the
discriminant is a square iff `f` has a second root: splitting type `1+1+1` versus `1+2`. -/
theorem isSquare_disc_iff (h2 : (2 : F) ≠ 0) (a b r : F) (hr : cubic a b r = 0)
    (hΔ : disc a b ≠ 0) :
    IsSquare (disc a b) ↔ ∃ s, s ≠ r ∧ cubic a b s = 0 := by
  have hD := disc_factor a b r hr
  have hm : 3 * r ^ 2 + a ≠ 0 := by
    intro h; apply hΔ; rw [hD, h]; ring
  constructor
  · rintro ⟨t, ht⟩
    set u := t / (3 * r ^ 2 + a)
    have hu : u ^ 2 = -3 * r ^ 2 - 4 * a := by
      have : t * t = (-3 * r ^ 2 - 4 * a) * (3 * r ^ 2 + a) ^ 2 := ht ▸ hD
      simp only [u, div_pow]
      field_simp
      linear_combination this
    refine ⟨(u - r) / 2, ?_, ?_⟩
    · intro hs
      have hu' : u = 3 * r := by field_simp at hs; linear_combination hs
      apply hm
      have : (3 * r) ^ 2 = -3 * r ^ 2 - 4 * a := hu' ▸ hu
      have h4 : (4 : F) ≠ 0 := by
        have : (4 : F) = 2 * 2 := by norm_num
        rw [this]; exact mul_ne_zero h2 h2
      have : 4 * (3 * r ^ 2 + a) = 0 := by linear_combination this
      exact (mul_eq_zero.1 this).resolve_left h4
    · rw [cubic_factor a b r _ hr]
      have : ((u - r) / 2) ^ 2 + r * ((u - r) / 2) + (a + r ^ 2) = 0 := by
        field_simp
        linear_combination hu
      rw [this, mul_zero]
  · rintro ⟨s, hsr, hs⟩
    rw [cubic_factor a b r s hr] at hs
    have hq : s ^ 2 + r * s + (a + r ^ 2) = 0 :=
      (mul_eq_zero.1 hs).resolve_left (sub_ne_zero.2 hsr)
    refine ⟨(2 * s + r) * (3 * r ^ 2 + a), ?_⟩
    rw [hD]
    linear_combination (-4 * (3 * r ^ 2 + a) ^ 2) * hq

/-- Contrapositive form: a cubic with a root and a non-square discriminant has
exactly one root (splitting type `1 + 2`, odd Frobenius). -/
theorem unique_root_of_not_isSquare (h2 : (2 : F) ≠ 0) (a b r : F) (hr : cubic a b r = 0)
    (hΔ : ¬ IsSquare (disc a b)) : ∀ s, cubic a b s = 0 → s = r := by
  intro s hs
  by_contra hsr
  have hΔ0 : disc a b ≠ 0 := by
    intro h; exact hΔ ⟨0, by rw [h]; ring⟩
  exact hΔ ((isSquare_disc_iff h2 a b r hr hΔ0).2 ⟨s, hsr, hs⟩)

end CubicDiscriminantSignLaw