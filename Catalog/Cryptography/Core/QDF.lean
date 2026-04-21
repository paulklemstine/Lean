/-! # CatalogBuild.Cryptography.Core.QDF

Auto-generated from theorem catalog database.
Domain: Cryptography/Core
Declarations: 43
-/

import Mathlib

/-- **Theorem 2.1 (Cone Property):** The QDF cone is closed under integer scaling. -/
theorem cone_scaling (a b c d k : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad (k*a) (k*b) (k*c) (k*d) := by
  unfold IsPythQuad at *; nlinarith [sq_nonneg k, sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]




/-- **Theorem 2.2a (Component Bound):** a² ≤ d² for any Pythagorean quadruple. -/
theorem component_bound_a (a b c d : ℤ) (h : IsPythQuad a b c d) :
    a^2 ≤ d^2 := by
  unfold IsPythQuad at h; nlinarith [sq_nonneg b, sq_nonneg c]




/-- **Theorem 2.2b (Component Bound):** b² ≤ d² for any Pythagorean quadruple. -/
theorem component_bound_b (a b c d : ℤ) (h : IsPythQuad a b c d) :
    b^2 ≤ d^2 := by
  unfold IsPythQuad at h; nlinarith [sq_nonneg a, sq_nonneg c]




/-- **Theorem 2.2c (Component Bound):** c² ≤ d² for any Pythagorean quadruple. -/
theorem component_bound_c (a b c d : ℤ) (h : IsPythQuad a b c d) :
    c^2 ≤ d^2 := by
  unfold IsPythQuad at h; nlinarith [sq_nonneg a, sq_nonneg b]




/-- **Theorem 2.3 (Gram Diagonal):** The ℤ⁴ squared norm equals 2d². -/
theorem gram_diagonal (a b c d : ℤ) (h : IsPythQuad a b c d) :
    a^2 + b^2 + c^2 + d^2 = 2 * d^2 := by
  unfold IsPythQuad at h; linarith




/-- [Section: # CatalogBuild.Cryptography.Core.QDF
Auto-generated from theorem catalog database.
Domain: Cryptography/Core
Declarations: 43] -/
theorem cauchy_schwarz_qdf (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d₁) (h₂ : IsPythQuad a₂ b₂ c₂ d₂) :
    (a₁*a₂ + b₁*b₂ + c₁*c₂)^2 ≤ d₁^2 * d₂^2 := by
  exact le_of_sub_nonneg ( by rw [ show d₁ ^ 2 = a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 by exact h₁.symm, show d₂ ^ 2 = a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 by exact h₂.symm ] ; nlinarith only [ sq_nonneg ( a₁ * b₂ - b₁ * a₂ ), sq_nonneg ( b₁ * c₂ - c₁ * b₂ ), sq_nonneg ( c₁ * a₂ - a₁ * c₂ ) ] )




/-- **Theorem 2.5 (Reduction / Parallelogram Formula):** -/
theorem reduction_formula (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d₁) (h₂ : IsPythQuad a₂ b₂ c₂ d₂) :
    (a₁ - a₂)^2 + (b₁ - b₂)^2 + (c₁ - c₂)^2 =
    d₁^2 + d₂^2 - 2*(a₁*a₂ + b₁*b₂ + c₁*c₂) := by
  unfold IsPythQuad at *; nlinarith [sq_nonneg (a₁ - a₂), sq_nonneg (b₁ - b₂), sq_nonneg (c₁ - c₂)]




/-- [Section: # CatalogBuild.Cryptography.Core.QDF
Auto-generated from theorem catalog database.
Domain: Cryptography/Core
Declarations: 43] -/
theorem primitive_reduction (a b c d g : ℤ) (hg : g ≠ 0)
    (ha : g ∣ a) (hb : g ∣ b) (hc : g ∣ c) (hd : g ∣ d)
    (h : IsPythQuad a b c d) :
    IsPythQuad (a / g) (b / g) (c / g) (d / g) := by
  -- By definition of IsPythQuad, we have that $a^2 + b^2 + c^2 = d^2$.
  obtain ⟨k, hk⟩ := ha
  obtain ⟨l, hl⟩ := hb
  obtain ⟨m, hm⟩ := hc
  obtain ⟨n, hn⟩ := hd
  have h_eq : (k * g)^2 + (l * g)^2 + (m * g)^2 = (n * g)^2 := by
    rw [IsPythQuad] at h; subst_vars; ring_nf at *; aesop;
  simp_all +decide [ mul_pow, mul_div_cancel_left₀ _ hg ];
  exact mul_left_cancel₀ ( pow_ne_zero 2 hg ) ( by linear_combination' h_eq )




/-- **Theorem 3.1 (Modular QDF):** The QDF identity is preserved mod m. -/
theorem modular_qdf (a b c d m : ℤ) (h : IsPythQuad a b c d) :
    (a^2 + b^2 + c^2) % m = d^2 % m := by
  unfold IsPythQuad at h; rw [h]




/-- **Theorem 3.2 (Modular Radical):** The radical decomposition is preserved mod m. -/
theorem modular_radical (a b c d m : ℤ) (h : IsPythQuad a b c d) :
    ((d - c) * (d + c)) % m = (a^2 + b^2) % m := by
  unfold IsPythQuad at h
  congr 1; nlinarith




/-- **Theorem 3.3 (Scaling Homomorphism):** Scaling preserves the identity mod m. -/
theorem scaling_homomorphism (a b c d k m : ℤ) (h : IsPythQuad a b c d) :
    ((k*a)^2 + (k*b)^2 + (k*c)^2) % m = (k*d)^2 % m := by
  have h2 := cone_scaling a b c d k h
  unfold IsPythQuad at h2; rw [h2]




/-- **Theorem 3.4 (Additive Cross-Term / Noise Formula):**
Component-wise addition produces a residual (noise) of
2·(inner product − hypotenuse product). -/
theorem additive_cross_term (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d₁) (h₂ : IsPythQuad a₂ b₂ c₂ d₂) :
    (a₁ + a₂)^2 + (b₁ + b₂)^2 + (c₁ + c₂)^2 - (d₁ + d₂)^2 =
    2 * (a₁*a₂ + b₁*b₂ + c₁*c₂ - d₁*d₂) := by
  unfold IsPythQuad at *; nlinarith




theorem exact_homomorphism (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d₁) (h₂ : IsPythQuad a₂ b₂ c₂ d₂) :
    IsPythQuad (a₁ + a₂) (b₁ + b₂) (c₁ + c₂) (d₁ + d₂) ↔
    a₁*a₂ + b₁*b₂ + c₁*c₂ = d₁*d₂ := by
  grind +locals




/-- **Theorem 3.6 (CRT Compatibility):** QDF identities compose under CRT. -/
theorem crt_compatibility (a b c d m₁ m₂ : ℤ) (h : IsPythQuad a b c d) :
    (a^2 + b^2 + c^2) % (m₁ * m₂) = d^2 % (m₁ * m₂) := by
  unfold IsPythQuad at h; rw [h]




theorem rational_bloch_sphere (a b c d : ℤ) (hd : d ≠ 0) (h : IsPythQuad a b c d) :
    (a : ℚ)^2 / (d : ℚ)^2 + (b : ℚ)^2 / (d : ℚ)^2 + (c : ℚ)^2 / (d : ℚ)^2 = 1 := by
  rw [ ← add_div, ← add_div, div_eq_iff ] <;> norm_cast ; aesop;
  positivity




/-- **Theorem 4.2 (Error Detection / Syndrome):**
A single-component error a → a+e produces residual e(2a+e). -/
theorem error_syndrome (a b c d e : ℤ) (h : IsPythQuad a b c d) :
    (a + e)^2 + b^2 + c^2 - d^2 = e * (2 * a + e) := by
  unfold IsPythQuad at h; nlinarith




/-- **Theorem 4.3 (Error Syndrome Factoring):**
The syndrome factors as e·(2a + e), providing error magnitude info. -/
theorem error_syndrome_factored (a b c d e : ℤ) (h : IsPythQuad a b c d) :
    (a + e)^2 + b^2 + c^2 - d^2 = 2*a*e + e^2 := by
  unfold IsPythQuad at h; nlinarith




/-- **Theorem 4.5 (Code Distance):** Distance between two same-sphere quadruples. -/
theorem code_distance (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d) (h₂ : IsPythQuad a₂ b₂ c₂ d) :
    (a₁ - a₂)^2 + (b₁ - b₂)^2 + (c₁ - c₂)^2 =
    2 * (d^2 - (a₁*a₂ + b₁*b₂ + c₁*c₂)) := by
  unfold IsPythQuad at *; nlinarith




/-- **Theorem 5.1 (Distance Formula):** Distance for same-sphere quadruples. -/
theorem tda_distance_formula (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d) (h₂ : IsPythQuad a₂ b₂ c₂ d) :
    (a₁ - a₂)^2 + (b₁ - b₂)^2 + (c₁ - c₂)^2 =
    2*d^2 - 2*(a₁*a₂ + b₁*b₂ + c₁*c₂) := by
  unfold IsPythQuad at *; nlinarith




theorem max_distance (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d) (h₂ : IsPythQuad a₂ b₂ c₂ d) :
    (a₁ - a₂)^2 + (b₁ - b₂)^2 + (c₁ - c₂)^2 ≤ 4 * d^2 := by
  -- By the Cauchy-Schwarz inequality, we have that $(a_1 a_2 + b_1 b_2 + c_1 c_2)^2 \leq (a_1^2 + b_1^2 + c_1^2)(a_2^2 + b_2^2 + c_2^2)$.
  have h_cauchy_schwarz : (a₁ * a₂ + b₁ * b₂ + c₁ * c₂)^2 ≤ (a₁^2 + b₁^2 + c₁^2) * (a₂^2 + b₂^2 + c₂^2) := by
    linarith [ sq_nonneg ( a₁ * b₂ - b₁ * a₂ ), sq_nonneg ( b₁ * c₂ - c₁ * b₂ ), sq_nonneg ( c₁ * a₂ - a₁ * c₂ ) ];
  unfold IsPythQuad at h₁ h₂;
  nlinarith




/-- **Theorem 5.3 (Sign Symmetry):** Negating components preserves the quadruple. -/
theorem sign_symmetry_a (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad (-a) b c d := by
  unfold IsPythQuad at *; nlinarith [sq_nonneg a]




theorem sign_symmetry_b (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad a (-b) c d := by
  unfold IsPythQuad at *; nlinarith [sq_nonneg b]




theorem sign_symmetry_c (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad a b (-c) d := by
  unfold IsPythQuad at *; nlinarith [sq_nonneg c]




/-- **Theorem 5.4 (Permutation Symmetry):** Permuting legs preserves the quadruple. -/
theorem permutation_symmetry_12 (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad b a c d := by
  unfold IsPythQuad at *; linarith




theorem permutation_symmetry_13 (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad c b a d := by
  unfold IsPythQuad at *; linarith




theorem permutation_symmetry_23 (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad a c b d := by
  unfold IsPythQuad at *; linarith




/-- **Theorem 5.5 (Filtration Bound):** Quadratic family hypotenuse ≥ 1. -/
theorem filtration_bound (n : ℤ) (hn : 0 ≤ n) :
    n^2 + n + 1 ≥ 1 := by nlinarith [sq_nonneg n]




/-- **Theorem 5.6 (Monotone Birth Times):** Consecutive hypotenuses strictly increase. -/
theorem monotone_birth_times (n : ℤ) (hn : 0 ≤ n) :
    (n+1)^2 + (n+1) + 1 > n^2 + n + 1 := by nlinarith




/-- **Theorem 5.7 (Gap Size):** Gap between consecutive hypotenuses is 2n+2. -/
theorem gap_size (n : ℤ) :
    (n+1)^2 + (n+1) + 1 - (n^2 + n + 1) = 2*n + 2 := by ring




/-- **Theorem 5.8 (Antipodal Map):** Negating all legs is an involution. -/
theorem antipodal_involution (a b c d : ℤ) (h : IsPythQuad a b c d) :
    IsPythQuad (-a) (-b) (-c) d := by
  unfold IsPythQuad at *; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]




/-- **Theorem 6.1 (Classical Pythagorean Embedding):**
(2mn)² + (m²−n²)² + 0² = (m²+n²)². -/
theorem classical_embedding (m n : ℤ) :
    IsPythQuad (2*m*n) (m^2 - n^2) 0 (m^2 + n^2) := by
  unfold IsPythQuad; ring




/-- **Theorem 6.2 (Quadratic Family):**
n² + (n+1)² + (n(n+1))² = (n²+n+1)². -/
theorem quadratic_family (n : ℤ) :
    IsPythQuad n (n+1) (n*(n+1)) (n^2+n+1) := by
  unfold IsPythQuad; ring




/-- **Theorem 6.2b (Negative Family):**
The quadratic family is preserved under n → −n−1. -/
theorem negative_family (n : ℤ) :
    IsPythQuad (-n) (-n-1) ((-n)*(-n-1)) (n^2+n+1) := by
  unfold IsPythQuad; ring




/-- **Theorem 6.3 (Triple Composition):**
Applying the quadratic family to d₁ = n²+n+1 produces a valid quadruple. -/
theorem triple_composition (n : ℤ) :
    let d₁ := n^2 + n + 1
    IsPythQuad d₁ (d₁ + 1) (d₁ * (d₁ + 1)) (d₁^2 + d₁ + 1) := by
  unfold IsPythQuad; ring




/-- **Theorem 6.4 (Difference Identity):**
Factoring the difference of two family hypotenuses squared. -/
theorem difference_identity (m n : ℤ) :
    (m^2 + m + 1)^2 - (n^2 + n + 1)^2 =
    (m - n) * (m + n + 1) * (m^2 + m + n^2 + n + 2) := by ring




/-- **Theorem 6.5 (Quartic Family):** Substituting n → n² gives the quartic family. -/
theorem quartic_family (n : ℤ) :
    IsPythQuad (n^2) (n^2 + 1) (n^2 * (n^2 + 1)) (n^4 + n^2 + 1) := by
  unfold IsPythQuad; ring




/-- **Theorem 6.6 (Residue Class):** Hypotenuse ≡ 1 (mod n) for n ≠ 0. -/
theorem residue_class (n : ℤ) :
    n ∣ (n^2 + n + 1 - 1) := by
  use (n + 1); ring




theorem fidelity_bound (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d₁) (h₂ : IsPythQuad a₂ b₂ c₂ d₂)
    (hd₁ : d₁ ≠ 0) (hd₂ : d₂ ≠ 0)
    (hCS : (a₁*a₂ + b₁*b₂ + c₁*c₂)^2 ≤ d₁^2 * d₂^2) :
    (a₁*a₂ + b₁*b₂ + c₁*c₂ : ℚ)^2 / ((d₁ : ℚ)^2 * (d₂ : ℚ)^2) ≤ 1 := by
  exact div_le_one_of_le₀ ( mod_cast hCS ) ( by positivity )




/-- **Theorem 6.8 (HE–TDA Bridge):**
The additive cross-term equals the TDA distance correction. -/
theorem he_tda_bridge (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d) (h₂ : IsPythQuad a₂ b₂ c₂ d) :
    (a₁ - a₂)^2 + (b₁ - b₂)^2 + (c₁ - c₂)^2 +
    2*(a₁*a₂ + b₁*b₂ + c₁*c₂) = 2*d^2 := by
  unfold IsPythQuad at *; nlinarith




/-- **Theorem 6.9 (Midpoint Identity):** -/
theorem midpoint_identity (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d) (h₂ : IsPythQuad a₂ b₂ c₂ d) :
    (a₁ + a₂)^2 + (b₁ + b₂)^2 + (c₁ + c₂)^2 =
    2*d^2 + 2*(a₁*a₂ + b₁*b₂ + c₁*c₂) := by
  unfold IsPythQuad at *; nlinarith




theorem noise_bounded_by_hypotenuse_product (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d₁) (h₂ : IsPythQuad a₂ b₂ c₂ d₂)
    (hCS : (a₁*a₂ + b₁*b₂ + c₁*c₂)^2 ≤ d₁^2 * d₂^2) :
    (a₁*a₂ + b₁*b₂ + c₁*c₂ - d₁*d₂)^2 ≤ 4 * d₁^2 * d₂^2 := by
  linarith [ sq_nonneg ( a₁ * a₂ + b₁ * b₂ + c₁ * c₂ + d₁ * d₂ ) ]




/-- Additive noise for orthogonal quadruples is exactly −2d₁d₂. -/
theorem orthogonal_noise (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPythQuad a₁ b₁ c₁ d₁) (h₂ : IsPythQuad a₂ b₂ c₂ d₂)
    (horth : a₁*a₂ + b₁*b₂ + c₁*c₂ = 0) :
    (a₁ + a₂)^2 + (b₁ + b₂)^2 + (c₁ + c₂)^2 - (d₁ + d₂)^2 =
    -2 * d₁ * d₂ := by
  have := additive_cross_term a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ h₁ h₂
  linarith




/-- Modular reduction chain: the QDF identity is preserved through any modular cascade. -/
theorem modular_cascade (a b c d m₁ m₂ : ℤ) (h : IsPythQuad a b c d) :
    ((a^2 + b^2 + c^2) % m₁) % m₂ = (d^2 % m₁) % m₂ := by
  unfold IsPythQuad at h; rw [h]



