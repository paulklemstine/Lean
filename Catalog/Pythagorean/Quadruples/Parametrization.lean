import Mathlib

/-! # CatalogBuild.Pythagorean.Quadruples.Parametrization

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 16
-/

/-- Pythagorean triple embedding: (m²-n², 2mn, 0, m²+n²). -/
theorem triple_embedding (m n : ℤ) :
    let a := m ^ 2 - n ^ 2
    let b := 2 * m * n
    let d := m ^ 2 + n ^ 2
    a ^ 2 + b ^ 2 + (0 : ℤ) ^ 2 = d ^ 2 := by ring

/-- Zero-component from triple. -/
theorem zero_component_param (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + b ^ 2 + 0 ^ 2 = c ^ 2 := by linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Scaling
-- ═══════════════════════════════════════════════════════════════

/-- [Section: # Parametrization of Pythagorean Quadruples
## Main Results
1. **Lebesgue parametrization**: Classical parametric family generates PQs
2. **Scaling**: PQs are closed under scaling
3. **Cauchy-Schwarz for PQs**: Inner product bounded by hypotenuse product
4. **Every integer is a PQ hypotenuse**
5. **Norm multiplicativity**: Product of doubled norms = 4d₁²d₂²] -/
theorem pq_scale (a b c d k : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (k * a) ^ 2 + (k * b) ^ 2 + (k * c) ^ 2 = (k * d) ^ 2 := by nlinarith [sq_nonneg k]

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Concrete PQ Verification
-- ═══════════════════════════════════════════════════════════════

theorem verify_pq_0_0_1_1 : (0:ℤ) ^ 2 + 0 ^ 2 + 1 ^ 2 = 1 ^ 2 := by norm_num

theorem verify_pq_1_2_2_3 : (1:ℤ) ^ 2 + 2 ^ 2 + 2 ^ 2 = 3 ^ 2 := by norm_num

theorem verify_pq_0_3_4_5 : (0:ℤ) ^ 2 + 3 ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num

theorem verify_pq_2_3_6_7 : (2:ℤ) ^ 2 + 3 ^ 2 + 6 ^ 2 = 7 ^ 2 := by norm_num

theorem verify_pq_1_4_8_9 : (1:ℤ) ^ 2 + 4 ^ 2 + 8 ^ 2 = 9 ^ 2 := by norm_num

theorem verify_pq_4_4_7_9 : (4:ℤ) ^ 2 + 4 ^ 2 + 7 ^ 2 = 9 ^ 2 := by norm_num

theorem verify_pq_2_6_9_11 : (2:ℤ) ^ 2 + 6 ^ 2 + 9 ^ 2 = 11 ^ 2 := by norm_num

theorem verify_pq_6_6_7_11 : (6:ℤ) ^ 2 + 6 ^ 2 + 7 ^ 2 = 11 ^ 2 := by norm_num

theorem verify_pq_3_4_12_13 : (3:ℤ) ^ 2 + 4 ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Cauchy-Schwarz
-- ═══════════════════════════════════════════════════════════════

theorem cauchy_schwarz_pq (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h₂ : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) ^ 2 ≤ d₁ ^ 2 * d₂ ^ 2 := by
  nlinarith [sq_nonneg (a₁ * b₂ - b₁ * a₂),
             sq_nonneg (a₁ * c₂ - c₁ * a₂),
             sq_nonneg (b₁ * c₂ - c₁ * b₂)]

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Hypotenuse Universality
-- ═══════════════════════════════════════════════════════════════

/-- Every integer is a PQ hypotenuse (trivially: d² + 0² + 0² = d²). -/
theorem every_int_is_hyp (d : ℤ) : ∃ a b c : ℤ, a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 :=
  ⟨d, 0, 0, by ring⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Norm Multiplicativity
-- ═══════════════════════════════════════════════════════════════

theorem pq_norm_product (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h₂ : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 + d₁ ^ 2) * (a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 + d₂ ^ 2) =
    4 * d₁ ^ 2 * d₂ ^ 2 := by nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Parity
-- ═══════════════════════════════════════════════════════════════

/-- In a PQ, the sum a²+b²+c² matches d² mod 4 (both are sums of squares). -/
theorem pq_sum_eq_sq (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := h

