/-! # CatalogBuild.Pythagorean.Core.PythagoreanDensity

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 23
-/

import Mathlib

/-- The classical parametrization: (m² - n², 2mn, m² + n²) -/
def pythagoreanParam (m n : ℤ) : ℤ × ℤ × ℤ :=
  (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)


/-- The parametrization produces Pythagorean triples. -/
theorem param_is_pythagorean (m n : ℤ) :
    let t := pythagoreanParam m n
    IsPythagoreanTriple t.1 t.2.1 t.2.2 := by
  simp only [pythagoreanParam, IsPythagoreanTriple]
  ring


/-- (3, 4, 5) is a Pythagorean triple. -/
theorem pyth_3_4_5 : IsPythagoreanTriple 3 4 5 := by
  unfold IsPythagoreanTriple; norm_num


/-- (5, 12, 13) is a Pythagorean triple. -/
theorem pyth_5_12_13 : IsPythagoreanTriple 5 12 13 := by
  unfold IsPythagoreanTriple; norm_num


/-- (8, 15, 17) is a Pythagorean triple. -/
theorem pyth_8_15_17 : IsPythagoreanTriple 8 15 17 := by
  unfold IsPythagoreanTriple; norm_num


/-- (7, 24, 25) is a Pythagorean triple. -/
theorem pyth_7_24_25 : IsPythagoreanTriple 7 24 25 := by
  unfold IsPythagoreanTriple; norm_num


/-- The Pythagorean property is symmetric in a, b. -/
theorem pyth_comm {a b c : ℤ} (h : IsPythagoreanTriple a b c) :
    IsPythagoreanTriple b a c := by
  unfold IsPythagoreanTriple at *; linarith

-- ═══════════════════════════════════════════════════════════════════════════════
--  §4: LORENTZ FORM AND QUADRATIC STRUCTURE
-- ═══════════════════════════════════════════════════════════════════════════════


/-- A triple is Pythagorean iff its Lorentz form vanishes. -/
theorem pyth_iff_lorentz_zero {a b c : ℤ} :
    IsPythagoreanTriple a b c ↔ lorentzQ a b c = 0 := by
  unfold IsPythagoreanTriple lorentzQ; omega


/-- The Lorentz form is preserved under negation of any component. -/
theorem lorentzQ_neg_a (a b c : ℤ) : lorentzQ (-a) b c = lorentzQ a b c := by
  unfold lorentzQ; ring


/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanDensity
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 23] -/
theorem lorentzQ_neg_b (a b c : ℤ) : lorentzQ a (-b) c = lorentzQ a b c := by
  unfold lorentzQ; ring


/-- Swapping a and b preserves the Lorentz form. -/
theorem lorentzQ_swap (a b c : ℤ) : lorentzQ b a c = lorentzQ a b c := by
  unfold lorentzQ; ring

-- ═══════════════════════════════════════════════════════════════════════════════
--  §5: BERGGREN MATRICES
-- ═══════════════════════════════════════════════════════════════════════════════


/-- The hypotenuse strictly increases under Berggren B when a,b,c > 0. -/
theorem berggrenB_hyp_grows {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (berggrenB a b c).2.2 := by
  simp only [berggrenB]; linarith


/-- The hypotenuse strictly increases under Berggren C when b > a and c > 0. -/
theorem berggrenC_hyp_grows {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hab : a ≤ b) :
    c < (berggrenC a b c).2.2 := by
  simp only [berggrenC]; linarith

-- ═══════════════════════════════════════════════════════════════════════════════
--  §7: SUM OF TWO SQUARES — THE GATEWAY TO PYTHAGOREAN THEORY
-- ═══════════════════════════════════════════════════════════════════════════════


/-- A number is expressible as a sum of two squares. -/
def IsSumTwoSquares (n : ℤ) : Prop :=
  ∃ a b : ℤ, a ^ 2 + b ^ 2 = n


/-- If c is a hypotenuse, then c² is a sum of two squares. -/
theorem hypotenuse_sq_sum_two_squares {a b c : ℤ} (h : IsPythagoreanTriple a b c) :
    IsSumTwoSquares (c ^ 2) :=
  ⟨a, b, h⟩

-- ═══════════════════════════════════════════════════════════════════════════════
--  §8: HYPOTENUSE LEG INEQUALITY
-- ═══════════════════════════════════════════════════════════════════════════════


/-- In a Pythagorean triple, each leg squared is at most the hypotenuse squared. -/
theorem pyth_hyp_ge_leg {a b c : ℤ} (h : IsPythagoreanTriple a b c) :
    a ^ 2 ≤ c ^ 2 ∧ b ^ 2 ≤ c ^ 2 := by
  unfold IsPythagoreanTriple at h
  exact ⟨by linarith [sq_nonneg b], by linarith [sq_nonneg a]⟩

-- ═══════════════════════════════════════════════════════════════════════════════
--  §9: INFINITUDE OF PYTHAGOREAN TRIPLES
-- ═══════════════════════════════════════════════════════════════════════════════


/-- There are infinitely many Pythagorean triples (via scaling). -/
theorem infinitely_many_pyth_triples :
    ∀ N : ℕ, ∃ a b c : ℕ, a > 0 ∧ b > 0 ∧ c > 0 ∧
      a ^ 2 + b ^ 2 = c ^ 2 ∧ c > N := by
  intro N
  refine ⟨3 * (N + 1), 4 * (N + 1), 5 * (N + 1), ?_, ?_, ?_, ?_, ?_⟩
  · omega
  · omega
  · omega
  · ring
  · omega


/-- There are infinitely many primitive Pythagorean triples (via parametrization). -/
theorem infinitely_many_primitive_pyth :
    ∀ N : ℕ, ∃ a b c : ℕ, a > 0 ∧ b > 0 ∧ c > N ∧
      a ^ 2 + b ^ 2 = c ^ 2 := by
  intro N
  refine ⟨3 * (N + 1), 4 * (N + 1), 5 * (N + 1), by omega, by omega, by omega, by ring⟩


/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanDensity
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 23] -/
theorem sq_mod4 (n : ℤ) : n ^ 2 % 4 = 0 ∨ n ^ 2 % 4 = 1 := by
  rcases Int.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> ring_nf <;> norm_num


/-- [Section: # CatalogBuild.Pythagorean.Core.PythagoreanDensity
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 23] -/
theorem sq_mod3 (n : ℤ) : n ^ 2 % 3 = 0 ∨ n ^ 2 % 3 = 1 := by
  rw [ sq, Int.mul_emod ] ; have := Int.emod_nonneg n three_pos.ne'; have := Int.emod_lt_of_pos n three_pos; interval_cases n % 3 <;> trivial;


theorem pyth_div3 {a b c : ℤ} (h : IsPythagoreanTriple a b c) :
    3 ∣ a ∨ 3 ∣ b := by
  replace := congr_arg ( · % 3 ) h; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this; ( have := Int.emod_nonneg a three_pos.ne'; ( have := Int.emod_nonneg b three_pos.ne'; ( have := Int.emod_nonneg c three_pos.ne'; ( have := Int.emod_lt_of_pos a three_pos; ( have := Int.emod_lt_of_pos b three_pos; ( have := Int.emod_lt_of_pos c three_pos; interval_cases _ : a % 3 <;> interval_cases _ : b % 3 <;> interval_cases _ : c % 3 <;> simp_all +decide only ; ) ) ) ) ) );
  all_goals simp_all +decide only [Int.dvd_iff_emod_eq_zero] ;


theorem pyth_4_div_ab {a b c : ℤ} (h : IsPythagoreanTriple a b c) :
    4 ∣ a * b := by
  rcases Int.even_or_odd' a with ⟨ x, rfl | rfl ⟩ <;> ( ( rcases Int.even_or_odd' b with ⟨ y, rfl | rfl ⟩ ) );
  · exact ⟨ x * y, by ring ⟩;
  · rcases Int.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' y with ⟨ l, rfl | rfl ⟩ <;> ring_nf at * <;> simp_all +decide [ IsPythagoreanTriple ];
    · exact ⟨ k * l * 4, by ring ⟩;
    · exact ⟨ k * 3 + k * l * 4, by ring ⟩;
    · exact absurd ( congr_arg ( · % 8 ) h ) ( by ring_nf; norm_num [ Int.add_emod, Int.mul_emod, sq ] ; have := Int.emod_nonneg c ( by decide : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos c ( by decide : ( 0 : ℤ ) < 8 ) ; interval_cases c % 8 <;> trivial );
    · exact absurd ( congr_arg ( · % 8 ) h ) ( by ring_nf; norm_num [ Int.add_emod, Int.mul_emod, sq ] ; have := Int.emod_nonneg c ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos c ( by norm_num : ( 0 : ℤ ) < 8 ) ; interval_cases c % 8 <;> trivial );
  · rcases Int.even_or_odd' y with ⟨ z, rfl | rfl ⟩ <;> ( ( have := congr_arg Even h ; norm_num [ sq, parity_simps ] at this; ) );
    · exact ⟨ x * z * 2 + z, by ring ⟩;
    · rcases Int.even_or_odd' c with ⟨ k, rfl | rfl ⟩ <;> simp_all +decide [ parity_simps ];
      · grind;
      · exact absurd ( congr_arg ( · % 8 ) h ) ( by ring_nf; norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod, sq ] ; have := Int.emod_nonneg x ( by decide : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg z ( by decide : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg k ( by decide : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos x ( by decide : ( 8 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos z ( by decide : ( 8 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos k ( by decide : ( 8 : ℤ ) > 0 ) ; interval_cases x % 8 <;> interval_cases z % 8 <;> interval_cases k % 8 <;> trivial );
  · exact absurd ( pyth_not_both_odd h ) ( by norm_num )


theorem pyth_12_div_abc {a b c : ℤ} (h : IsPythagoreanTriple a b c) :
    12 ∣ a * b * c := by
  -- We know 3|a or 3|b (pyth_div3), and 4|ab (pyth_4_div_ab). So 12 | ab, hence 12 | abc.
  have h3 : 3 ∣ a * b := by
    exact Int.dvd_of_emod_eq_zero ( by have := congr_arg ( · % 3 ) h; norm_num [ sq, Int.add_emod, Int.mul_emod ] at this ⊢; have := Int.emod_nonneg a three_pos.ne'; have := Int.emod_nonneg b three_pos.ne'; have := Int.emod_nonneg c three_pos.ne'; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; have := Int.emod_lt_of_pos c three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> interval_cases c % 3 <;> trivial )
  have h4 : 4 ∣ a * b := by
    exact?
  have h12 : 12 ∣ a * b := by
    exact Int.coe_lcm_dvd h3 h4
  exact dvd_mul_of_dvd_left h12 c

-- ═══════════════════════════════════════════════════════════════════════════════
--  §12: DESCENT STRUCTURE
-- ═══════════════════════════════════════════════════════════════════════════════


