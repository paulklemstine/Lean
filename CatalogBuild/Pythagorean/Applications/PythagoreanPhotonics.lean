/-! # CatalogBuild.Pythagorean.Applications.PythagoreanPhotonics

Auto-generated from theorem catalog database.
Domain: Pythagorean/Applications
Declarations: 32
-/

import Mathlib

/-- A lattice null vector is a nonzero integer vector on the null cone -/
def IsLatticeNull (a b c : ℤ) : Prop :=
  a ^ 2 + b ^ 2 = c ^ 2 ∧ (a ≠ 0 ∨ b ≠ 0)


/-- The Minkowski form in (2+1) dimensions -/
def minkowski3 (a b c : ℤ) : ℤ :=
  a ^ 2 + b ^ 2 - c ^ 2


/-- [Section: # CatalogBuild.Pythagorean.Applications.PythagoreanPhotonics
Auto-generated from theorem catalog database.
Domain: Pythagorean/Applications
Declarations: 32] -/
theorem lattice_null_minkowski_zero (a b c : ℤ) (h : IsLatticeNull a b c) :
    minkowski3 a b c = 0 := by
  unfold IsLatticeNull at h; unfold minkowski3; linarith;


/-- [Section: # CatalogBuild.Pythagorean.Applications.PythagoreanPhotonics
Auto-generated from theorem catalog database.
Domain: Pythagorean/Applications
Declarations: 32] -/
theorem lattice_null_neg (a b c : ℤ) (h : IsLatticeNull a b c) :
    IsLatticeNull (-a) (-b) c := by
  unfold IsLatticeNull at *; aesop;


/-- [Section: # CatalogBuild.Pythagorean.Applications.PythagoreanPhotonics
Auto-generated from theorem catalog database.
Domain: Pythagorean/Applications
Declarations: 32] -/
theorem lattice_null_swap (a b c : ℤ) (h : IsLatticeNull a b c) :
    IsLatticeNull b a c := by
  exact ⟨ by linarith [ h.1 ], by have := h.2; tauto ⟩


theorem lattice_null_scale (a b c : ℤ) (k : ℤ) (hk : k ≠ 0) (h : IsLatticeNull a b c) :
    IsLatticeNull (k * a) (k * b) (k * c) := by
  exact ⟨ by linear_combination' h.1 * k ^ 2, by exact Or.imp ( fun ha => by aesop ) ( fun hb => by aesop ) h.2 ⟩


theorem euclid_is_lattice_null (m n : ℤ) (hmn : m ≠ n) :
    IsLatticeNull (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) := by
  -- By definition of IsLatticeNull, we need to show that (m^2 - n^2)^2 + (2mn)^2 = (m^2 + n^2)^2 and that m^2 - n^2 ≠ 0 or 2mn ≠ 0.
  constructor;
  · grind;
  · contrapose! hmn; aesop;


theorem euclid_hypotenuse_pos (m n : ℤ) (hm : 0 < m) (hn : 0 < n) :
    0 < m ^ 2 + n ^ 2 := by
  positivity


theorem euclid_identity (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring


theorem berggren_B_hypotenuse_growth (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    3 * c < 2 * a + 2 * b + 3 * c := by
  linarith


theorem berggren_A_hypotenuse_bound (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    c < 2 * a - 2 * b + 3 * c := by
  nlinarith only [ ha, hb, hc, hpyth ]


theorem brahmagupta_fibonacci_explicit (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring


theorem hypotenuse_product_is_sum_of_squares
    (a b c d : ℤ) (h1 : a ^ 2 + b ^ 2 = c ^ 2) (h2 : a ^ 2 + b ^ 2 = d ^ 2) :
    ∃ e f : ℤ, c ^ 2 * d ^ 2 = e ^ 2 + f ^ 2 := by
  exact ⟨ c * d, 0, by ring ⟩


theorem quad_param_valid (m n p q : ℤ) :
    IsPythQuadruple
      (m^2 + n^2 - p^2 - q^2)
      (2 * (m*q + n*p))
      (2 * (n*q - m*p))
      (m^2 + n^2 + p^2 + q^2) := by
  exact Eq.symm ( by ring ) ;


theorem triple_embeds_in_quadruple (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    IsPythQuadruple a b 0 c := by
  exact Eq.trans ( by ring ) h


theorem quad_perm_12 (a b c d : ℤ) (h : IsPythQuadruple a b c d) :
    IsPythQuadruple b a c d := by
  unfold IsPythQuadruple at *; linarith;


theorem quad_perm_13 (a b c d : ℤ) (h : IsPythQuadruple a b c d) :
    IsPythQuadruple c b a d := by
  unfold IsPythQuadruple at h ⊢; linarith;


theorem quad_scale (a b c d k : ℤ) (h : IsPythQuadruple a b c d) :
    IsPythQuadruple (k*a) (k*b) (k*c) (k*d) := by
  unfold IsPythQuadruple at h ⊢; linear_combination' k ^ 2 * h;


theorem lattice_dispersion_correction_sign (p a : ℝ) (hp : 0 < p) (ha : 0 < a) :
    Real.sin (p * a / 2) ≤ p * a / 2 := by
  exact le_of_lt ( Real.sin_lt <| by positivity )


theorem dispersion_small_momentum (x : ℝ) (hx : 0 ≤ x) (hx1 : x ≤ 1) :
    |Real.sin x - x| ≤ x ^ 3 := by
  have h_sin_approx : ∀ x : ℝ, 0 ≤ x → x ≤ 1 → |Real.sin x - x| ≤ x^3 := by
    intro x hx hx1
    have h_sin_approx : ∀ x : ℝ, 0 ≤ x → x ≤ 1 → Real.sin x ≥ x - x^3 / 6 := by
      -- Let's choose any $x$ in the interval $[0, 1]$.
      intro x hx hx1
      have h_sin_approx : ∀ t ∈ Set.Icc 0 x, Real.cos t ≥ 1 - t^2 / 2 := by
        exact fun t a => Real.one_sub_sq_div_two_le_cos;
      -- Integrate both sides of $\cos t \geq 1 - t^2 / 2$ from $0$ to $x$.
      have h_integral_approx : ∫ t in (0 : ℝ)..x, Real.cos t ≥ ∫ t in (0 : ℝ)..x, (1 - t^2 / 2) := by
        refine' intervalIntegral.integral_mono_on _ _ _ _ <;> aesop;
      norm_num at h_integral_approx; linarith;
    have h_sin_approx : ∀ x : ℝ, 0 ≤ x → x ≤ 1 → Real.sin x ≤ x := by
      exact fun x hx hx1 => if h : x = 0 then by norm_num [ h ] else le_of_lt ( Real.sin_lt <| lt_of_le_of_ne hx <| Ne.symm h );
    exact abs_le.mpr ⟨ by nlinarith [ pow_nonneg hx 2, pow_nonneg hx 3, ‹∀ x : ℝ, 0 ≤ x → x ≤ 1 → Real.sin x ≥ x - x ^ 3 / 6› x hx hx1 ], by nlinarith [ pow_nonneg hx 2, pow_nonneg hx 3, h_sin_approx x hx hx1 ] ⟩;
  exact h_sin_approx x hx hx1


theorem pyth_triple_div_3 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    3 ∣ a ∨ 3 ∣ b := by
  -- Consider the equation modulo 3. The possible values for squares modulo 3 are 0 or 1.
  have h_mod3 : (a ^ 2 + b ^ 2) % 3 = c ^ 2 % 3 := by
    rw [h];
  norm_num [ sq, Int.add_emod, Int.mul_emod ] at h_mod3;
  rw [ Int.dvd_iff_emod_eq_zero, Int.dvd_iff_emod_eq_zero ] ; have := Int.emod_nonneg a three_ne_zero; have := Int.emod_nonneg b three_ne_zero; have := Int.emod_nonneg c three_ne_zero; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; have := Int.emod_lt_of_pos c three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> interval_cases c % 3 <;> trivial;


theorem pyth_triple_div_4 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    4 ∣ a * b := by
  rcases Int.even_or_odd' a with ⟨ x, rfl | rfl ⟩ <;> ( rcases Int.even_or_odd' b with ⟨ y, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *; );
  · rcases Int.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> ( rcases Int.even_or_odd' y with ⟨ l, rfl | rfl ⟩ <;> ring_nf at * <;> have := congr_arg ( · % 4 ) h <;> norm_num [ Int.add_emod, Int.mul_emod ] at this ⊢; );
    · exact absurd ( congr_arg ( · % 8 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg c ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos c ( by norm_num : ( 0 : ℤ ) < 8 ) ; interval_cases c % 8 <;> trivial );
    · exact absurd ( congr_arg ( · % 8 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg c ( by decide : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos c ( by decide : ( 0 : ℤ ) < 8 ) ; interval_cases c % 8 <;> trivial );
  · rcases Int.even_or_odd' y with ⟨ k, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num at *;
    exact absurd ( congr_arg ( · % 8 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg x ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg c ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos x ( by norm_num : ( 8 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos c ( by norm_num : ( 8 : ℤ ) > 0 ) ; interval_cases x % 8 <;> interval_cases c % 8 <;> trivial );
  · exact absurd ( congr_arg ( · % 4 ) h ) ( by norm_num [ sq, Int.add_emod, Int.mul_emod ] ; have := Int.emod_nonneg c four_pos.ne'; have := Int.emod_lt_of_pos c four_pos; interval_cases c % 4 <;> trivial )


theorem primitive_hypotenuse_odd (a b c : ℕ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hgcd : Nat.gcd a (Nat.gcd b c) = 1)
    (ha : 0 < a) (hb : 0 < b) :
    ¬ 2 ∣ c := by
  contrapose! hgcd; have := congr_arg ( · % 4 ) h; rcases Nat.even_or_odd' a with ⟨ b₁, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' b with ⟨ b₂, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' c with ⟨ b₃, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at *;
  · norm_num [ Nat.gcd_mul_right, Nat.gcd_mul_left ];
  · grind;
  · norm_num [ Nat.dvd_add_left ] at hgcd


theorem smallest_primitive_triple (a b c : ℕ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (ha : 0 < a) (hb : 0 < b)
    (hab : a ≤ b) (hprim : Nat.gcd a b = 1) :
    5 ≤ c := by
  by_contra h_contra;
  interval_cases c <;> norm_num at * <;> have := Nat.le_of_lt_succ ( show a < 6 by nlinarith only [ h ] ) <;> have := Nat.le_of_lt_succ ( show b < 6 by nlinarith only [ h ] ) <;> interval_cases a <;> interval_cases b <;> trivial


theorem arbitrarily_large_triples (N : ℕ) :
    ∃ a b c : ℕ, a ^ 2 + b ^ 2 = c ^ 2 ∧ 0 < a ∧ 0 < b ∧ N < c := by
  exact ⟨ 3 * ( N + 1 ), 4 * ( N + 1 ), 5 * ( N + 1 ), by ring, by positivity, by positivity, by linarith ⟩


theorem arbitrarily_large_quadruples (N : ℕ) :
    ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ∧ 0 < a ∧ 0 < b ∧ 0 < c ∧ N < d := by
  exact ⟨ 3 * N + 3, 4 * N + 4, 12 * N + 12, 13 * N + 13, by ring, by linarith, by linarith, by linarith, by linarith ⟩


theorem euclid_density (m₁ m₂ : ℕ) (hm : m₁ < m₂) :
    ∃ a b c : ℕ, a ^ 2 + b ^ 2 = c ^ 2 ∧ m₁ ^ 2 < c ∧ c ≤ m₂ ^ 2 + 1 := by
  exact ⟨ 0, m₁ ^ 2 + 1, m₁ ^ 2 + 1, by ring, by nlinarith, by nlinarith ⟩


theorem berggren_A_preserves_norm (a b c : ℤ) :
    minkowski3 (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) =
    minkowski3 a b c := by
  unfold minkowski3; ring;


theorem berggren_B_preserves_norm (a b c : ℤ) :
    minkowski3 (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) =
    minkowski3 a b c := by
  unfold minkowski3; ring;


theorem berggren_C_preserves_norm (a b c : ℤ) :
    minkowski3 (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) =
    minkowski3 a b c := by
  unfold minkowski3; ring;


theorem seven_not_sum_of_squares : ¬ ∃ a b : ℕ, a ^ 2 + b ^ 2 = 7 := by
  exact fun ⟨ a, b, h ⟩ => by have := Nat.le_of_lt_succ ( show a < 3 by nlinarith ) ; have := Nat.le_of_lt_succ ( show b < 3 by nlinarith ) ; interval_cases a <;> interval_cases b <;> trivial;


theorem twentyfive_two_representations :
    ∃ a₁ b₁ a₂ b₂ : ℕ, a₁ ^ 2 + b₁ ^ 2 = 25 ∧ a₂ ^ 2 + b₂ ^ 2 = 25 ∧
    (a₁, b₁) ≠ (a₂, b₂) ∧ 0 < a₁ ∧ 0 < b₁ ∧ 0 < a₂ ∧ 0 < b₂ := by
  exists 3, 4, 4, 3


