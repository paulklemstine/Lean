/-
# Pythagorean 5-Tuple Factor Theory

Formalization of factor identities, multi-channel GCD extraction,
parity constraints, and cross-difference factoring for 5-tuples.
A 5-tuple is (a₁, a₂, a₃, a₄, a₅) with a₁² + a₂² + a₃² + a₄² = a₅².
-/
import Mathlib

set_option maxHeartbeats 800000

/-! ## Definition -/

/-- A Pythagorean 5-tuple: five integers where the sum of squares of the
    first four equals the square of the fifth. -/
def IsPythagorean5Tuple (a₁ a₂ a₃ a₄ a₅ : ℤ) : Prop :=
  a₁^2 + a₂^2 + a₃^2 + a₄^2 = a₅^2

/-! ## Four-Channel Peel Identities -/

/-- Peel identity channel 1: (a₅ - a₁)(a₅ + a₁) = a₂² + a₃² + a₄² -/
theorem five_tuple_peel_first (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₁) * (a₅ + a₁) = a₂^2 + a₃^2 + a₄^2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

/-- Peel identity channel 2: (a₅ - a₂)(a₅ + a₂) = a₁² + a₃² + a₄² -/
theorem five_tuple_peel_second (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₂) * (a₅ + a₂) = a₁^2 + a₃^2 + a₄^2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

/-- Peel identity channel 3: (a₅ - a₃)(a₅ + a₃) = a₁² + a₂² + a₄² -/
theorem five_tuple_peel_third (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₃) * (a₅ + a₃) = a₁^2 + a₂^2 + a₄^2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

/-- Peel identity channel 4: (a₅ - a₄)(a₅ + a₄) = a₁² + a₂² + a₃² -/
theorem five_tuple_peel_fourth (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₄) * (a₅ + a₄) = a₁^2 + a₂^2 + a₃^2 := by
  unfold IsPythagorean5Tuple at h; nlinarith

/-- All four peel identities hold simultaneously. -/
theorem five_tuple_multi_channel (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (a₅ - a₁) * (a₅ + a₁) = a₂^2 + a₃^2 + a₄^2 ∧
    (a₅ - a₂) * (a₅ + a₂) = a₁^2 + a₃^2 + a₄^2 ∧
    (a₅ - a₃) * (a₅ + a₃) = a₁^2 + a₂^2 + a₄^2 ∧
    (a₅ - a₄) * (a₅ + a₄) = a₁^2 + a₂^2 + a₃^2 := by
  exact ⟨five_tuple_peel_first _ _ _ _ _ h,
         five_tuple_peel_second _ _ _ _ _ h,
         five_tuple_peel_third _ _ _ _ _ h,
         five_tuple_peel_fourth _ _ _ _ _ h⟩

/-! ## Factor Extraction -/

/-
Factor extraction: gcd(a₅ - a₄, a₁) · gcd(a₅ + a₄, a₁) divides a₁².
-/
theorem five_tuple_factor_extraction (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (_h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    (Int.gcd (a₅ - a₄) a₁ : ℤ) * (Int.gcd (a₅ + a₄) a₁ : ℤ) ∣ a₁^2 := by
  convert mul_dvd_mul ( Int.gcd_dvd_right _ _ ) ( Int.gcd_dvd_right _ _ ) using 1;
  ring

/-- The product (a₅ - aᵢ)(a₅ + aᵢ) always divides a₅² - aᵢ² = sum of other squares. -/
theorem five_tuple_factor_identity (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (_h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅) :
    a₅^2 - a₁^2 = a₂^2 + a₃^2 + a₄^2 := by
  unfold IsPythagorean5Tuple at _h; linarith

/-! ## Cross-Difference for Shared-Hypotenuse 5-Tuples -/

/-- When two 5-tuples share a hypotenuse, cross-differences yield factor information. -/
theorem five_tuple_cross_difference (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ d : ℤ)
    (ha : IsPythagorean5Tuple a₁ a₂ a₃ a₄ d)
    (hb : IsPythagorean5Tuple b₁ b₂ b₃ b₄ d) :
    a₄^2 - b₄^2 = (b₁^2 - a₁^2) + (b₂^2 - a₂^2) + (b₃^2 - a₃^2) := by
  unfold IsPythagorean5Tuple at ha hb; linarith

/-- Shared hypotenuse implies equal sums of squares. -/
theorem five_tuple_shared_hypotenuse (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ d : ℤ)
    (ha : IsPythagorean5Tuple a₁ a₂ a₃ a₄ d)
    (hb : IsPythagorean5Tuple b₁ b₂ b₃ b₄ d) :
    a₁^2 + a₂^2 + a₃^2 + a₄^2 = b₁^2 + b₂^2 + b₃^2 + b₄^2 := by
  unfold IsPythagorean5Tuple at ha hb; linarith

/-! ## Parity Constraints -/

/-
In a 5-tuple with even hypotenuse, the number of odd components is even.
-/
theorem five_tuple_parity (a₁ a₂ a₃ a₄ a₅ : ℤ)
    (h : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅)
    (h5even : 2 ∣ a₅) :
    (a₁ % 2 + a₂ % 2 + a₃ % 2 + a₄ % 2) % 2 = 0 := by
  obtain ⟨ k, hk ⟩ := h5even; ( replace h := congr_arg ( · % 2 ) h; norm_num [ hk, Int.add_emod, Int.mul_emod, sq ] at h ⊢; have := Int.emod_nonneg a₁ two_pos.ne'; have := Int.emod_nonneg a₂ two_pos.ne'; have := Int.emod_nonneg a₃ two_pos.ne'; have := Int.emod_nonneg a₄ two_pos.ne'; have := Int.emod_lt_of_pos a₁ two_pos; have := Int.emod_lt_of_pos a₂ two_pos; have := Int.emod_lt_of_pos a₃ two_pos; have := Int.emod_lt_of_pos a₄ two_pos; interval_cases a₁ % 2 <;> interval_cases a₂ % 2 <;> interval_cases a₃ % 2 <;> interval_cases a₄ % 2 <;> trivial; )

/-! ## Lifting from 4D to 5D -/

/-- A Pythagorean quadruple can be lifted to a 5-tuple by appending 0. -/
theorem quadruple_lift_to_5tuple (a b c d : ℤ)
    (h : a^2 + b^2 + c^2 = d^2) :
    IsPythagorean5Tuple a b c 0 d := by
  unfold IsPythagorean5Tuple; simp; linarith

/-- A quadruple (a,b,c,d) gives a 5-tuple if we can split one leg. -/
theorem quadruple_to_5tuple_via_leg (a b c d p q : ℤ)
    (hquad : a^2 + b^2 + c^2 = d^2)
    (hsplit : c^2 = p^2 + q^2) :
    IsPythagorean5Tuple a b p q d := by
  unfold IsPythagorean5Tuple; linarith

/-! ## Bridge Projections -/

/-- The number of 2D projections from a 5-tuple is C(4,2) = 6. -/
theorem five_tuple_projection_count : Nat.choose 4 2 = 6 := by decide

/-- A 5-tuple creates a bridge to a quadruple via projection:
    if a₁² + a₂² = e² for some e, then (e, a₃, a₄, a₅) is a quadruple. -/
theorem five_tuple_bridge (a₁ a₂ a₃ a₄ a₅ e : ℤ)
    (h5 : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅)
    (hproj : a₁^2 + a₂^2 = e^2) :
    e^2 + a₃^2 + a₄^2 = a₅^2 := by
  unfold IsPythagorean5Tuple at h5; linarith

/-- Double bridge: 5-tuple → quadruple → triple. -/
theorem five_tuple_double_bridge (a₁ a₂ a₃ a₄ a₅ e f : ℤ)
    (h5 : IsPythagorean5Tuple a₁ a₂ a₃ a₄ a₅)
    (hbridge1 : a₁^2 + a₂^2 = e^2)
    (hbridge2 : e^2 + a₃^2 = f^2) :
    f^2 + a₄^2 = a₅^2 := by
  unfold IsPythagorean5Tuple at h5; linarith