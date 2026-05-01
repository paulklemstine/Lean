import Mathlib

/-! # CatalogBuild.Pythagorean.ThreeRoads.AdvancedTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 23
-/

/-- [Section: # CatalogBuild.Pythagorean.ThreeRoads.AdvancedTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 23] -/
theorem divisor_pair_to_triple (N d e : ℤ) (hprod : d * e = N ^ 2)
    (hd_pos : 0 < d) (hle : d ≤ e) (hparity : Even (e - d)) :
    N ^ 2 + ((e - d) / 2) ^ 2 = ((e + d) / 2) ^ 2 := by
  cases abs_cases N <;> nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ e - d from even_iff_two_dvd.mp hparity ), Int.ediv_mul_cancel ( show 2 ∣ e + d from even_iff_two_dvd.mp ( by simpa [ parity_simps ] using hparity ) ) ]

/-- [Section: # CatalogBuild.Pythagorean.ThreeRoads.AdvancedTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 23] -/
theorem triple_to_divisor_pair (N b c : ℤ) (h : N ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = N ^ 2 := by
  grind

theorem divisor_triple_roundtrip (N d e : ℤ) (hprod : d * e = N ^ 2)
    (hparity : Even (e - d)) :
    let b := (e - d) / 2
    let c := (e + d) / 2
    (c - b = d) ∧ (c + b = e) := by
  grind

theorem canonical_prime_triple (p : ℤ) (hp : 1 < p) (hodd : ¬Even p) :
    p ^ 2 + ((p ^ 2 - 1) / 2) ^ 2 = ((p ^ 2 + 1) / 2) ^ 2 := by
  cases abs_cases p <;> nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ p ^ 2 - 1 from even_iff_two_dvd.mp <| by simp_all +decide [ parity_simps ] ), Int.ediv_mul_cancel ( show 2 ∣ p ^ 2 + 1 from even_iff_two_dvd.mp <| by simp_all +decide [ parity_simps ] ) ]

theorem trivial_factorization_triple (N : ℤ) (hN : 1 < N) (hodd : ¬Even N) :
    N ^ 2 + ((N ^ 2 - 1) / 2) ^ 2 = ((N ^ 2 + 1) / 2) ^ 2 := by
  exact canonical_prime_triple N hN hodd

theorem B1_preserves_pythagorean (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  grind

theorem B3_preserves_pythagorean (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  grind

theorem euclid_coprime (m n : ℤ) (hcop : IsCoprime m n)
    (hparity : Even m ↔ ¬Even n) :
    IsCoprime (m ^ 2 - n ^ 2) (2 * m * n) := by
  refine' IsCoprime.symm _;
  refine' IsCoprime.mul_left _ _;
  · refine' IsCoprime.mul_left _ _;
    · refine' Int.prime_two.coprime_iff_not_dvd.mpr _;
      simp_all +decide [ ← even_iff_two_dvd, parity_simps ];
      grind;
    · -- Since $m$ and $n$ are coprime, $m$ and $n^2$ are also coprime.
      have h_coprime_m_n2 : IsCoprime m (n ^ 2) := by
        exact hcop.pow_right;
      convert h_coprime_m_n2.neg_right.add_mul_right_right ( m ) using 1 ; ring;
  · convert hcop.symm.pow_right.add_mul_right_right ( -n ) using 1 ; ring;
    convert rfl

theorem two_triples_factor (N b₁ c₁ b₂ c₂ : ℤ)
    (h₁ : N ^ 2 + b₁ ^ 2 = c₁ ^ 2)
    (h₂ : N ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    (c₁ - b₁) * (c₁ + b₁) = (c₂ - b₂) * (c₂ + b₂) := by
  linarith

theorem leg_product_bound (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 * a * b < c ^ 2 := by
  by_contra h_contra;
  -- If $2ab = c^2$, then $(a - b)^2 = 0$, which implies $a = b$.
  have h_eq : a = b := by
    nlinarith;
  -- Substitute $a = b$ into the equation $a^2 + b^2 = c^2$ to get $2a^2 = c^2$, which implies $c = \pm a\sqrt{2}$.
  have h_c : c = a * Real.sqrt 2 ∨ c = -a * Real.sqrt 2 := by
    exact or_iff_not_imp_left.mpr fun h => mul_left_cancel₀ ( sub_ne_zero_of_ne h ) <| by ring_nf; norm_num; norm_cast; subst h_eq; linarith;
  obtain h | h := h_c <;> [ exact irrational_sqrt_two <| ⟨ c / a, by push_cast [ h ] ; rw [ mul_div_cancel_left₀ _ <| by positivity ] ⟩ ; exact irrational_sqrt_two <| ⟨ -c / a, by push_cast [ h ] ; rw [ div_eq_iff <| by positivity ] ; linarith ⟩ ]

theorem leg_sum_sq_bound (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + b) ^ 2 ≤ 2 * c ^ 2 := by
  linarith [ sq_nonneg ( a - b ) ]

theorem smooth_relation_product (s₁ s₂ N : ℤ) (hN : 0 < N) :
    (s₁ * s₂) % N = ((s₁ % N) * (s₂ % N)) % N := by
  rw [ Int.mul_emod ]

theorem berggren_preserves_lorentz (a b c : ℤ) :
    -- B₁ preserves Q
    (a - 2*b + 2*c)^2 + (2*a - b + 2*c)^2 - (2*a - 2*b + 3*c)^2 = a^2 + b^2 - c^2 ∧
    -- B₂ preserves Q
    (a + 2*b + 2*c)^2 + (2*a + b + 2*c)^2 - (2*a + 2*b + 3*c)^2 = a^2 + b^2 - c^2 ∧
    -- B₃ preserves Q
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 - (-2*a + 2*b + 3*c)^2 = a^2 + b^2 - c^2 := by
  grind

theorem min_hypotenuse_at_depth (d : ℕ) :
    (3 : ℤ) ^ d * 5 ≥ 5 := by
  nlinarith [ pow_pos ( by decide : 0 < 3 ) d ]

theorem B1_parent_recovery (a b c : ℤ) :
    let a' := a - 2*b + 2*c
    let b' := 2*a - b + 2*c
    let c' := 2*a - 2*b + 3*c
    -- Inverse of B₁: recover (a, b, c) from (a', b', c')
    (a' + 2*b' - 2*c' = a) ∧
    (-2*a' - b' + 2*c' = b) ∧
    (-2*a' - 2*b' + 3*c' = c) := by
  grind

theorem gcd_factor_from_triples (N d₁ : ℤ) (hN : 0 < N) :
    (Int.gcd d₁ N : ℤ) ∣ N := by
  exact Int.gcd_dvd_right _ _

theorem hypotenuse_mod_transform (a b c N : ℤ) (hN : 0 < N) :
    (2*a + 2*b + 3*c) % N = (2*a + 2*b + 3*(c % N)) % N := by
  simp +decide [ Int.add_emod, Int.mul_emod ]

theorem leg_difference_identity (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 - b ^ 2 = 2 * a ^ 2 - c ^ 2 := by
  grind

theorem both_legs_less (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a < c ∧ b < c := by
  constructor <;> nlinarith

theorem tree_nodes_at_depth (d : ℕ) : (3 : ℕ) ^ d ≥ 1 := by
  exact Nat.one_le_pow _ _ ( by decide )

theorem tree_total_nodes (d : ℕ) :
    (3 ^ (d + 1) - 1) % 2 = 0 := by
  exact Nat.mod_eq_zero_of_dvd ( by simpa using nat_sub_dvd_pow_sub_pow _ 1 _ )

theorem gaussian_composition (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 = c₁ ^ 2)
    (h₂ : a₂ ^ 2 + b₂ ^ 2 = c₂ ^ 2) :
    (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + b₁ * a₂) ^ 2 = (c₁ * c₂) ^ 2 := by
  linear_combination' h₁ * h₂

theorem self_composition (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a ^ 2 - b ^ 2) ^ 2 + (2 * a * b) ^ 2 = c ^ 4 := by
  linear_combination' h * h