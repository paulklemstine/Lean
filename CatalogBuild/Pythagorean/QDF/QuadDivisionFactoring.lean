/-! # CatalogBuild.Pythagorean.QDF.QuadDivisionFactoring

Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 21
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.QDF.QuadDivisionFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 21] -/
theorem odd_trivial_triple (n : ℤ) (hn : n % 2 = 1) :
    n ^ 2 + ((n ^ 2 - 1) / 2) ^ 2 = ((n ^ 2 + 1) / 2) ^ 2 := by
  cases abs_cases n <;> nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ n ^ 2 - 1 from Int.dvd_self_sub_of_emod_eq ( by simp +decide [ sq, Int.mul_emod, hn ] ) ), Int.ediv_mul_cancel ( show 2 ∣ n ^ 2 + 1 from Int.dvd_of_emod_eq_zero ( by simp +decide [ sq, Int.mul_emod, Int.add_emod, hn ] ) ) ]


/-- [Section: # CatalogBuild.Pythagorean.QDF.QuadDivisionFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 21] -/
theorem even_trivial_triple (m : ℤ) (hm : m > 0) :
    (2 * m) ^ 2 + (m ^ 2 - 1) ^ 2 = (m ^ 2 + 1) ^ 2 := by
  ring


/-- [Section: # CatalogBuild.Pythagorean.QDF.QuadDivisionFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 21] -/
theorem quad_factor_identity (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 := by
  linarith


theorem triple_lift_to_quadruple (a b e k d : ℤ)
    (h1 : a ^ 2 + b ^ 2 = e ^ 2)
    (h2 : e ^ 2 + k ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2 := by
  linarith


theorem gcd_dc_divides_sum_sq (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    ↑(Int.gcd (d - c) (d + c)) ∣ (a ^ 2 + b ^ 2) := by
  exact ⟨ ( d - c ) * ( d + c ) / Int.gcd ( d - c ) ( d + c ), by linarith [ Int.ediv_mul_cancel <| show ( Int.gcd ( d - c ) ( d + c ) : ℤ ) ∣ ( d - c ) * ( d + c ) from dvd_mul_of_dvd_left ( Int.gcd_dvd_left _ _ ) _ ] ⟩


theorem factor_extraction_product (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (↑(Int.gcd (d - c) a) : ℤ) * ↑(Int.gcd (d + c) a) ∣ a ^ 2 := by
  convert mul_dvd_mul ( Int.gcd_dvd_right ( d - c ) a ) ( Int.gcd_dvd_right ( d + c ) a ) using 1 ; ring


theorem trivial_triple_hypotenuse (n : ℤ) (hn_odd : n % 2 = 1) (hn_pos : n > 0) :
    n ^ 2 + ((n ^ 2 - 1) / 2) ^ 2 = ((n ^ 2 + 1) / 2) ^ 2 := by
  exact odd_trivial_triple n hn_odd


theorem shared_hypotenuse_eq (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 := by
  grind


theorem cross_difference_identity (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    c₁ ^ 2 - c₂ ^ 2 = (a₂ ^ 2 - a₁ ^ 2) + (b₂ ^ 2 - b₁ ^ 2) := by
  grind


theorem cross_difference_factored (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (c₁ - c₂) * (c₁ + c₂) =
    (a₂ - a₁) * (a₂ + a₁) + (b₂ - b₁) * (b₂ + b₁) := by
  linarith


theorem berggrenM1_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenM1 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  unfold berggrenM1; linarith;


theorem berggrenM2_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenM2 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  unfold berggrenM2; linarith;


theorem berggrenM3_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenM3 a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  unfold berggrenM3; linarith;


theorem berggren_bridge_triple (a b c k d : ℤ)
    (h_pyth : a ^ 2 + b ^ 2 = c ^ 2)
    (h_quad : a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2)
    (e : ℤ) (h_e : a ^ 2 + k ^ 2 = e ^ 2) :
    e ^ 2 + b ^ 2 = d ^ 2 := by
  linarith


theorem berggren_hypotenuse_growth_M1 (a b c : ℤ) :
    (berggrenM1 a b c).2.2 = 2 * a - 2 * b + 3 * c := by
  rfl


theorem berggren_hypotenuse_growth_M2 (a b c : ℤ) :
    (berggrenM2 a b c).2.2 = 2 * a + 2 * b + 3 * c := by
  rfl


theorem gcd_cascade_divides (c₁ c₂ N : ℤ) (hN : N > 0) :
    ↑(Int.gcd (c₁ ^ 2 - c₂ ^ 2) N) ∣ N := by
  exact Int.gcd_dvd_right _ _


theorem gcd_divides_right (a N : ℤ) : ↑(Int.gcd a N) ∣ N := by
  exact Int.gcd_dvd_right _ _


theorem quad_reduction_preserves (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (g : ℤ) (hg : g > 0) (ha : g ∣ a) (hb : g ∣ b) (hc : g ∣ c) (hd : g ∣ d) :
    (a / g) ^ 2 + (b / g) ^ 2 + (c / g) ^ 2 = (d / g) ^ 2 := by
  obtain ⟨ k₁, rfl ⟩ := ha; obtain ⟨ k₂, rfl ⟩ := hb; obtain ⟨ k₃, rfl ⟩ := hc; obtain ⟨ k₄, rfl ⟩ := hd; ring;
  rw [ Int.mul_ediv_cancel_left _ hg.ne', Int.mul_ediv_cancel_left _ hg.ne', Int.mul_ediv_cancel_left _ hg.ne', Int.mul_ediv_cancel_left _ hg.ne' ] ; nlinarith [ mul_pos hg hg ]


theorem quad_parity_constraint (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hd_even : 2 ∣ d) (ha_odd : ¬ 2 ∣ a) (hb_odd : ¬ 2 ∣ b) :
    2 ∣ c := by
  obtain ⟨ k, hk ⟩ := hd_even; replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ m, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ n, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ o, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;
  norm_num [ hk, mul_pow ] at h


theorem quad_component_sum_sq (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a + b + c + d) ^ 2 =
    2 * (d ^ 2 + d * (a + b + c) + a * b + a * c + b * c) := by
  grind


