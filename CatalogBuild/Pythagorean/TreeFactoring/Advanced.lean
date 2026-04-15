/-! # CatalogBuild.Pythagorean.TreeFactoring.Advanced

Auto-generated from theorem catalog database.
Domain: Pythagorean/TreeFactoring
Declarations: 41
-/

import Mathlib

/-- Product of all three channels equals (d²-a²)(d²-b²)(d²-c²). -/
theorem triple_channel_product (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (a^2 + b^2) * (a^2 + c^2) * (b^2 + c^2) =
    (d^2 - c^2) * (d^2 - b^2) * (d^2 - a^2) := by
  have h1 : a^2 + b^2 = d^2 - c^2 := by linarith
  have h2 : a^2 + c^2 = d^2 - b^2 := by linarith
  have h3 : b^2 + c^2 = d^2 - a^2 := by linarith
  rw [h1, h2, h3]

/-- Channel product sum: Σ ch_i · ch_j for i<j. -/

theorem channel_product_sum (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (a^2+b^2)*(a^2+c^2) + (a^2+b^2)*(b^2+c^2) + (a^2+c^2)*(b^2+c^2) =
    d^4 + a^2*b^2 + a^2*c^2 + b^2*c^2 := by nlinarith

/-! ## §2. Cascade Depth and Representation Counting -/

/-- Two representations yield three channel difference identities. -/

theorem cascade_opportunities (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2) (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    (a₁^2 + b₁^2) - (a₂^2 + b₂^2) = c₂^2 - c₁^2 ∧
    (a₁^2 + c₁^2) - (a₂^2 + c₂^2) = b₂^2 - b₁^2 ∧
    (b₁^2 + c₁^2) - (b₂^2 + c₂^2) = a₂^2 - a₁^2 := by
  constructor <;> [linarith; constructor <;> linarith]

/-- Cross-representation channel GCD: g | ch₁(ab) and g | ch₂(ab) implies g | (c₂²-c₁²). -/

theorem cross_rep_channel_gcd (a₁ b₁ c₁ a₂ b₂ c₂ d g : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2) (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2)
    (hg1 : g ∣ (a₁^2 + b₁^2)) (hg2 : g ∣ (a₂^2 + b₂^2)) :
    g ∣ (c₂^2 - c₁^2) := by
  have : c₂^2 - c₁^2 = (a₁^2 + b₁^2) - (a₂^2 + b₂^2) := by linarith
  rw [this]; exact dvd_sub hg1 hg2

/-- Three-way cascade: g divides all channel differences across 3 representations. -/

theorem three_way_cascade (c₁ c₂ c₃ d g : ℤ)
    (h1 : g ∣ (d - c₁)) (h2 : g ∣ (d - c₂)) (h3 : g ∣ (d - c₃)) :
    g ∣ (c₁ - c₂) ∧ g ∣ (c₁ - c₃) ∧ g ∣ (c₂ - c₃) := by
  refine ⟨?_, ?_, ?_⟩
  · have : c₁ - c₂ = (d - c₂) - (d - c₁) := by ring
    rw [this]; exact dvd_sub h2 h1
  · have : c₁ - c₃ = (d - c₃) - (d - c₁) := by ring
    rw [this]; exact dvd_sub h3 h1
  · have : c₂ - c₃ = (d - c₃) - (d - c₂) := by ring
    rw [this]; exact dvd_sub h3 h2

/-- Three-way cascade: sum identities. -/

theorem three_way_cascade_sums (c₁ c₂ c₃ d g : ℤ)
    (h1 : g ∣ (d - c₁)) (h2 : g ∣ (d - c₂)) (h3 : g ∣ (d - c₃)) :
    g ∣ (c₁ + c₂ - 2*d) ∧ g ∣ (c₁ + c₃ - 2*d) ∧ g ∣ (c₂ + c₃ - 2*d) := by
  refine ⟨?_, ?_, ?_⟩
  · have eq : c₁ + c₂ - 2 * d = -((d - c₁) + (d - c₂)) := by ring
    rw [eq]; exact dvd_neg.mpr (dvd_add h1 h2)
  · have eq : c₁ + c₃ - 2 * d = -((d - c₁) + (d - c₃)) := by ring
    rw [eq]; exact dvd_neg.mpr (dvd_add h1 h3)
  · have eq : c₂ + c₃ - 2 * d = -((d - c₂) + (d - c₃)) := by ring
    rw [eq]; exact dvd_neg.mpr (dvd_add h2 h3)

/-! ## §3. Quadruple-Factor Correspondence -/

/-- If two quadruples share d and have p | c₁ and p | c₂, then p² | both AB-channels. -/

theorem shared_factor_both_channels (a₁ b₁ c₁ a₂ b₂ c₂ d p : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2) (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2)
    (hpd : p ∣ d) (hpc1 : p ∣ c₁) (hpc2 : p ∣ c₂) :
    p^2 ∣ (a₁^2 + b₁^2) ∧ p^2 ∣ (a₂^2 + b₂^2) := by
  constructor
  · have : a₁^2 + b₁^2 = d^2 - c₁^2 := by linarith
    rw [this]; exact dvd_sub (pow_dvd_pow_of_dvd hpd 2) (pow_dvd_pow_of_dvd hpc1 2)
  · have : a₂^2 + b₂^2 = d^2 - c₂^2 := by linarith
    rw [this]; exact dvd_sub (pow_dvd_pow_of_dvd hpd 2) (pow_dvd_pow_of_dvd hpc2 2)

/-! ## §4. Channel Arithmetic Descent -/

/-- Common factor of all components divides d². -/

theorem common_factor_divides_d2 (a b c d g : ℤ)
    (h : a^2 + b^2 + c^2 = d^2) (ha : g ∣ a) (hb : g ∣ b) (hc : g ∣ c) :
    g^2 ∣ d^2 := by
  obtain ⟨a', rfl⟩ := ha; obtain ⟨b', rfl⟩ := hb; obtain ⟨c', rfl⟩ := hc
  exact ⟨a'^2 + b'^2 + c'^2, by nlinarith⟩

/-! ## §5. Channel Modular Fingerprints -/

/-- If p | d, then a²+b²+c² ≡ 0 (mod p²). -/

theorem channel_sum_mod_p2 (a b c d p : ℤ) (h : a^2 + b^2 + c^2 = d^2) (hp : p ∣ d) :
    p^2 ∣ (a^2 + b^2 + c^2) := by
  rw [h]; exact pow_dvd_pow_of_dvd hp 2

/-- Channel mod p: if p | d and p | c, then p | (a²+b²). -/

theorem channel_mod_p (a b c d p : ℤ) (h : a^2 + b^2 + c^2 = d^2)
    (hpd : p ∣ d) (hpc : p ∣ c) :
    p ∣ (a^2 + b^2) := by
  have heq : a^2 + b^2 = d^2 - c^2 := by linarith
  rw [heq]
  exact dvd_sub (dvd_pow hpd (by norm_num : 2 ≠ 0)) (dvd_pow hpc (by norm_num : 2 ≠ 0))

/-! ## §6. Cascade Sum Identities -/

/-- Cascade sum identity: (d-c₁) + (d-c₂) = 2d - c₁ - c₂. -/

theorem cascade_sum (c₁ c₂ d : ℤ) :
    (d - c₁) + (d - c₂) = 2 * d - (c₁ + c₂) := by ring

/-- If g | (d-c₁) and g | (d-c₂), then g | (2d - c₁ - c₂). -/

theorem cascade_sum_div (c₁ c₂ d g : ℤ)
    (h1 : g ∣ (d - c₁)) (h2 : g ∣ (d - c₂)) :
    g ∣ (2*d - (c₁ + c₂)) := by
  have : 2*d - (c₁ + c₂) = (d - c₁) + (d - c₂) := by ring
  rw [this]; exact dvd_add h1 h2

/-! ## §7. Channel Quadratic Forms -/

/-- The channel quadratic: (d-c)(d+c) = a²+b². -/

theorem channel_bound (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    a^2 + b^2 ≤ d^2 := by nlinarith [sq_nonneg c]

/-- Each channel value is nonneg. -/

theorem channel_nonneg (a b : ℤ) : 0 ≤ a^2 + b^2 := by positivity

/-- Channel constraint: sum of channels = 2d². -/

theorem channel_constraint (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (a^2 + b^2) + (a^2 + c^2) + (b^2 + c^2) = 2 * d^2 := by linarith

/-! ## §8. Sphere Geometry and Factoring -/

/-- The sum of squared distances and squared sums = 4d². -/

theorem distance_plus_sum_identity (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2) (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    (a₁ - a₂)^2 + (b₁ - b₂)^2 + (c₁ - c₂)^2 +
    (a₁ + a₂)^2 + (b₁ + b₂)^2 + (c₁ + c₂)^2 = 4 * d^2 := by nlinarith

/-- The midpoint of two representations has norm ≤ d (squared form). -/

theorem midpoint_norm_bound (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2) (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    (a₁ + a₂)^2 + (b₁ + b₂)^2 + (c₁ + c₂)^2 ≤ 4 * d^2 := by
  nlinarith [sq_nonneg (a₁ - a₂), sq_nonneg (b₁ - b₂), sq_nonneg (c₁ - c₂)]

/-- Parallelogram law on the sphere. -/

theorem sphere_parallelogram_law (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ) :
    (a₁ + a₂)^2 + (b₁ + b₂)^2 + (c₁ + c₂)^2 +
    (a₁ - a₂)^2 + (b₁ - b₂)^2 + (c₁ - c₂)^2 =
    2 * (a₁^2 + b₁^2 + c₁^2) + 2 * (a₂^2 + b₂^2 + c₂^2) := by ring

/-! ## §9. Factor-Channel Interaction for Composite d -/

/-- If d = p*q, then p² | (a²+b²+c²). -/

theorem factor_appears_in_sum (a b c p q : ℤ)
    (h : a^2 + b^2 + c^2 = (p*q)^2) :
    p^2 ∣ (a^2 + b^2 + c^2) := by
  rw [h]; exact ⟨q^2, by ring⟩

/-! ## §10. Higher-Dimensional Cascades -/

/-- 4D channel sum: 6 pair-channels sum to 3d². -/

theorem dim4_channel_sum (a b c e d : ℤ)
    (h : a^2 + b^2 + c^2 + e^2 = d^2) :
    (a^2+b^2) + (a^2+c^2) + (a^2+e^2) + (b^2+c^2) + (b^2+e^2) + (c^2+e^2) = 3*d^2 := by
  linarith

/-- 4D cross-channel GCD. -/

theorem dim4_cross_channel (x y z g : ℤ)
    (h1 : g ∣ (x^2 + y^2)) (h2 : g ∣ (x^2 + z^2)) :
    g ∣ (y^2 - z^2) := by
  have : y^2 - z^2 = (x^2 + y^2) - (x^2 + z^2) := by ring
  rw [this]; exact dvd_sub h1 h2

/-- 4D: complementary channel pairs sum to d². -/

theorem dim4_complementary_channels (a b c e d : ℤ)
    (h : a^2 + b^2 + c^2 + e^2 = d^2) :
    (a^2+b^2) + (c^2+e^2) = d^2 ∧
    (a^2+c^2) + (b^2+e^2) = d^2 ∧
    (a^2+e^2) + (b^2+c^2) = d^2 := by
  constructor <;> [linarith; constructor <;> linarith]

/-- 5D: 10 pair-channels sum to 4d². -/

theorem dim5_channel_sum (a b c e f d : ℤ)
    (h : a^2 + b^2 + c^2 + e^2 + f^2 = d^2) :
    (a^2+b^2) + (a^2+c^2) + (a^2+e^2) + (a^2+f^2) +
    (b^2+c^2) + (b^2+e^2) + (b^2+f^2) +
    (c^2+e^2) + (c^2+f^2) + (e^2+f^2) = 4*d^2 := by linarith

/-! ## §11. Quadruple Linking Theorems -/

/-- Cross-channel linking: component square differences sum to zero. -/

theorem cross_channel_linking (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2) (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2) :
    (a₁^2 - a₂^2) + (b₁^2 - b₂^2) + (c₁^2 - c₂^2) = 0 := by linarith

/-! ## §12. Factoring via Channel Asymmetry -/

/-- If channel values are unequal, the difference factors via b²-c². -/

theorem asymmetry_factors (a b c : ℤ) (hbc : b ≠ c) :
    b^2 - c^2 = (b - c) * (b + c) ∧ b - c ≠ 0 := by
  constructor
  · ring
  · omega

/-- Maximum channel: if c = ±1 then the AB-channel is d²-1. -/

theorem max_channel_value (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) (hc : c^2 = 1) :
    a^2 + b^2 = d^2 - 1 := by linarith

/-! ## §13. Cascade Propagation -/

/-- Cascade propagation: gcd(d-c₁, c₂-c₁) divides d-c₂. -/

theorem cascade_propagation (c₁ c₂ d g : ℤ)
    (h1 : g ∣ (d - c₁)) (h2 : g ∣ (c₂ - c₁)) :
    g ∣ (d - c₂) := by
  have : d - c₂ = (d - c₁) - (c₂ - c₁) := by ring
  rw [this]; exact dvd_sub h1 h2

/-- Four representations yield 6 GCD values. -/

theorem four_rep_cascade (c₁ c₂ c₃ c₄ d g : ℤ)
    (h1 : g ∣ (d - c₁)) (h2 : g ∣ (d - c₂)) (h3 : g ∣ (d - c₃)) (h4 : g ∣ (d - c₄)) :
    g ∣ (c₁-c₂) ∧ g ∣ (c₁-c₃) ∧ g ∣ (c₁-c₄) ∧
    g ∣ (c₂-c₃) ∧ g ∣ (c₂-c₄) ∧ g ∣ (c₃-c₄) := by
  constructor
  · have eq : c₁ - c₂ = (d - c₂) - (d - c₁) := by ring
    rw [eq]; exact dvd_sub h2 h1
  constructor
  · have eq : c₁ - c₃ = (d - c₃) - (d - c₁) := by ring
    rw [eq]; exact dvd_sub h3 h1
  constructor
  · have eq : c₁ - c₄ = (d - c₄) - (d - c₁) := by ring
    rw [eq]; exact dvd_sub h4 h1
  constructor
  · have eq : c₂ - c₃ = (d - c₃) - (d - c₂) := by ring
    rw [eq]; exact dvd_sub h3 h2
  constructor
  · have eq : c₂ - c₄ = (d - c₄) - (d - c₂) := by ring
    rw [eq]; exact dvd_sub h4 h2
  · have eq : c₃ - c₄ = (d - c₄) - (d - c₃) := by ring
    rw [eq]; exact dvd_sub h4 h3

/-! ## §14. Channel-Hypotenuse Interaction -/

/-- Sum of all six linear factors: Σ(d±x) = 6d for x ∈ {a,b,c}. -/

theorem sum_linear_factors (a b c d : ℤ) :
    (d-a) + (d+a) + (d-b) + (d+b) + (d-c) + (d+c) = 6*d := by ring

/-- Product of same-sign factors is a cubic in d. -/

theorem same_sign_product (a b c d : ℤ) :
    (d-a)*(d-b)*(d-c) = d^3 - (a+b+c)*d^2 + (a*b+a*c+b*c)*d - a*b*c := by ring

/-- Product of opposite-sign factors. -/

theorem opposite_sign_product (a b c d : ℤ) :
    (d+a)*(d+b)*(d+c) = d^3 + (a+b+c)*d^2 + (a*b+a*c+b*c)*d + a*b*c := by ring

/-- Difference of same/opposite products. -/

theorem product_difference (a b c d : ℤ) :
    (d+a)*(d+b)*(d+c) - (d-a)*(d-b)*(d-c) = 2*((a+b+c)*d^2 + a*b*c) := by ring

/-! ## §15. Prime Factor Channel Dichotomy -/

/-- For any prime p | d, either p | c (and hence p | both d±c) or
    p ∤ c and Euclid's lemma applies to a²+b² = (d-c)(d+c). -/

theorem prime_factor_channel_dichotomy (a b c d p : ℤ) (h : a^2 + b^2 + c^2 = d^2)
    (hp : Prime p) (hpd : p ∣ d) :
    (p ∣ c ∧ p ∣ (d-c) ∧ p ∣ (d+c)) ∨
    (¬(p ∣ c) ∧ (p ∣ (a^2 + b^2) → p ∣ (d-c) ∨ p ∣ (d+c))) := by
  by_cases hc : p ∣ c
  · left; exact ⟨hc, dvd_sub hpd hc, dvd_add hpd hc⟩
  · right
    constructor
    · exact hc
    · intro hab
      have : a^2 + b^2 = (d-c)*(d+c) := by nlinarith
      rw [this] at hab
      exact hp.dvd_or_dvd hab

/-! ## §16. Channel Ratio Identities -/

/-- The ratio of two channels determines the third. -/

theorem channel_ratio_determines (a b c : ℤ) :
    (a^2+b^2) + (b^2+c^2) - (a^2+c^2) = 2*b^2 := by ring

/-- Channel values satisfy a triangle-like inequality. -/

theorem channel_triangle (a b c : ℤ) :
    (a^2+b^2) ≤ (a^2+c^2) + (b^2+c^2) := by nlinarith [sq_nonneg c]

/-- d² from channels. -/

theorem d_from_channels (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    2*d^2 = (a^2+b^2) + (a^2+c^2) + (b^2+c^2) := by linarith

/-! ## §17. Newton's Identity for Channels -/

/-- Sum of channel squares in terms of components. -/

theorem channel_sq_sum (a b c : ℤ) :
    (a^2+b^2)^2 + (a^2+c^2)^2 + (b^2+c^2)^2 =
    2*(a^4 + b^4 + c^4) + 2*(a^2*b^2 + a^2*c^2 + b^2*c^2) := by ring

/-! ## §18. Channel Product Expansion -/

/-- The expanded channel product in terms of d. -/

theorem channel_product_expanded (a b c d : ℤ) :
    (d^2-a^2)*(d^2-b^2)*(d^2-c^2) =
    d^6 - d^4*(a^2+b^2+c^2) + d^2*(a^2*b^2+a^2*c^2+b^2*c^2) - a^2*b^2*c^2 := by ring

/-
Since a²+b²+c² = d², the product simplifies.
-/

theorem channel_product_simplified (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d^2-a^2)*(d^2-b^2)*(d^2-c^2) =
    d^2*(a^2*b^2+a^2*c^2+b^2*c^2) - a^2*b^2*c^2 := by
      grind

/-! ## §19. Orthogonal Representation Cascades -/

/-- Orthogonal representations maximize cascade effectiveness. -/

theorem orthogonal_max_cascade (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : a₁^2 + b₁^2 + c₁^2 = d^2) (h₂ : a₂^2 + b₂^2 + c₂^2 = d^2)
    (horth : a₁*a₂ + b₁*b₂ + c₁*c₂ = 0) :
    (a₁ - a₂)^2 + (b₁ - b₂)^2 + (c₁ - c₂)^2 = 2*d^2 := by nlinarith

/-- Parallel representations give zero distance. -/

theorem parallel_trivial (a b c : ℤ) :
    (a - a)^2 + (b - b)^2 + (c - c)^2 = 0 := by ring

/-! ## §20. Computational Verifications -/

-- Verify cascade on d=35 = 5×7
-- Q1 = (6, 10, 33, 35), Q2 = (15, 10, 30, 35)
example : (6:ℤ)^2 + 10^2 + 33^2 = 35^2 := by norm_num
example : (15:ℤ)^2 + 10^2 + 30^2 = 35^2 := by norm_num
-- gcd(35-33, 35-30) = gcd(2, 5) = 1 (not useful for this pair)
-- gcd(35-10, 35-30) = gcd(25, 5) = 5, and 5 | 35 ✓

-- d = 21 = 3×7
-- Q = (6, 9, 18, 21)
example : (6:ℤ)^2 + 9^2 + 18^2 = 21^2 := by norm_num
-- Channel: (21-18)(21+18) = 3×39; factor 3 revealed: 3 | 21 ✓
example : (3:ℤ) ∣ (21 - 18) := by norm_num
example : (3:ℤ) ∣ (21 + 18) := by norm_num

-- Small quadruples
example : (1:ℤ)^2 + 2^2 + 2^2 = 3^2 := by norm_num
example : (2:ℤ)^2 + 3^2 + 6^2 = 7^2 := by norm_num
example : (1:ℤ)^2 + 4^2 + 8^2 = 9^2 := by norm_num
example : (4:ℤ)^2 + 4^2 + 7^2 = 9^2 := by norm_num

-- Verify channel product identity for (2,3,6,7)
example : ((2:ℤ)^2 + 3^2) * ((2:ℤ)^2 + 6^2) * ((3:ℤ)^2 + 6^2) =
    (7^2 - 6^2) * (7^2 - 3^2) * (7^2 - 2^2) := by norm_num
