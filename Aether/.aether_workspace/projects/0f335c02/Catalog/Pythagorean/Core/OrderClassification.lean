import Mathlib

/-! # CatalogBuild.Pythagorean.Core.OrderClassification

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 12
-/

/-- Trace of the two-pole map matrix: 2(ab+1) -/
def twoPole_trace (a b : ℚ) : ℚ := 2 * (a * b + 1)

/-- Brahmagupta–Fibonacci identity variant: (1+a²)(1+b²) = (ab+1)² + (a-b)² -/
theorem brahmagupta_fibonacci_1 (a b : ℤ) :
    (1 + a ^ 2) * (1 + b ^ 2) = (a * b + 1) ^ 2 + (a - b) ^ 2 := by ring

/-- [Section: # CatalogBuild.Pythagorean.Core.OrderClassification
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 12] -/
theorem order2_trace_zero (a b : ℤ) (h : a * b = -1) :
    twoPole_trace (a : ℚ) (b : ℚ) = 0 := by
      unfold twoPole_trace; norm_cast; nlinarith;

/-- [Section: # CatalogBuild.Pythagorean.Core.OrderClassification
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 12] -/
theorem order2_integer_solutions (a b : ℤ) (h : a * b = -1) :
    (a = 1 ∧ b = -1) ∨ (a = -1 ∧ b = 1) := by
      rw [ Int.mul_eq_neg_one_iff_eq_one_or_neg_one ] at h ; tauto

theorem twoPole_1_neg1 (t : ℚ) (ht : 2 * t ≠ 0) :
    twoPole 1 (-1) t = -1 / t := by
      unfold twoPole; rw [ div_eq_div_iff ] <;> ring_nf <;> aesop;

theorem twoPole_1_neg1_order2 (t : ℚ) (ht : t ≠ 0) (ht2 : (-1 : ℚ) / t ≠ 0) :
    twoPole 1 (-1) (twoPole 1 (-1) t) = t := by
      convert twoPole_1_neg1 ( -1 / t ) ( by aesop ) using 1 ; ring;
      · unfold twoPole; ring;
      · grind

theorem order4_condition (a b : ℤ) :
    2 * (a * b + 1) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) ↔
    (a * b + 1 = a - b ∨ a * b + 1 = b - a) := by
      -- Apply the difference of squares formula to factor the left-hand side.
      have h_factor : 2 * (a * b + 1) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) ↔ (a * b + 1 - (a - b)) * (a * b + 1 + (a - b)) = 0 := by
        constructor <;> intro h <;> linarith [ brahmagupta_fibonacci_1 a b ];
      norm_num [ sub_eq_iff_eq_add, add_eq_zero_iff_eq_neg ] at * ; aesop;

theorem order4_case2_solutions (a b : ℤ) (h : (a - 1) * (b + 1) = -2) :
    (a = 2 ∧ b = -3) ∨ (a = 0 ∧ b = 1) ∨ (a = 3 ∧ b = -2) ∨ (a = -1 ∧ b = 0) := by
      have : a - 1 ∣ -2 := h ▸ dvd_mul_right _ _; ( have : a - 1 ∣ 2 := dvd_neg.mp this; ( have : a - 1 ≤ 2 := Int.le_of_dvd ( by decide ) this; ( have : a - 1 ≥ -2 := neg_le_of_abs_le ( Int.le_of_dvd ( by decide ) ( by simpa ) ) ; interval_cases _ : a - 1 <;> simp_all +decide [ sub_eq_iff_eq_add' ] ; ) ) );
      · linarith;
      · linarith;
      · linarith

theorem order4_case1_solutions (a b : ℤ) (h : (a + 1) * (b - 1) = -2) :
    (a = 0 ∧ b = -1) ∨ (a = -2 ∧ b = 3) ∨ (a = 1 ∧ b = 0) ∨ (a = -3 ∧ b = 2) := by
      have : a + 1 ∣ -2 := h ▸ dvd_mul_right _ _; ( have : a + 1 ∣ 2 := Int.dvd_neg.mp this; ( have : a + 1 ≤ 2 := Int.le_of_dvd ( by decide ) this; ( have : a + 1 ≥ -2 := neg_le_of_abs_le ( Int.le_of_dvd ( by decide ) ( by simpa ) ) ; interval_cases _ : a + 1 <;> simp_all +decide ) ) ) ;
      · exact Or.inr <| Or.inr <| Or.inr ⟨ by linarith, by linarith ⟩;
      · grind;
      · grind;
      · exact Or.inr <| Or.inr <| Or.inl ⟨ by linarith, by linarith ⟩

theorem no_order3 (a b : ℤ) (hab : a ≠ b) :
    3 * (a * b + 1) ^ 2 ≠ (a - b) ^ 2 := by
      by_contra h;
      -- If 3 * x^2 = y^2 for integers x and y, then √3 = y/x is rational, which is a contradiction.
      have h_contra : ∃ r : ℚ, r^2 = 3 := by
        use (a - b) / (a * b + 1);
        rw [ div_pow, div_eq_iff ] <;> norm_cast ; cases lt_or_gt_of_ne hab <;> nlinarith;
        nlinarith [ mul_self_pos.2 ( sub_ne_zero.2 hab ) ];
      exact h_contra.elim fun r hr => by apply_fun fun x => x.num at hr; norm_num [ sq, Rat.mul_self_num ] at hr; nlinarith [ show r.num ≤ 1 by nlinarith, show r.num ≥ -1 by nlinarith ] ;

theorem no_order6 (a b : ℤ) (hab : a ≠ b) :
    (a * b + 1) ^ 2 ≠ 3 * (a - b) ^ 2 := by
      by_contra h_contra;
      -- From the equation $(ab + 1)^2 = 3(a - b)^2$, we can deduce that $ab + 1$ must be divisible by $a - b$.
      have h_div : (a - b) ∣ (a * b + 1) := by
        exact Int.pow_dvd_pow_iff two_ne_zero |>.1 <| h_contra.symm ▸ dvd_mul_left _ _;
      -- Let $k$ be an integer such that $ab + 1 = k(a - b)$.
      obtain ⟨k, hk⟩ : ∃ k : ℤ, a * b + 1 = k * (a - b) := by
        exact dvd_iff_exists_eq_mul_left.mp h_div;
      -- Substitute $ab + 1 = k(a - b)$ into the equation $(ab + 1)^2 = 3(a - b)^2$ to get $k^2(a - b)^2 = 3(a - b)^2$, which simplifies to $k^2 = 3$.
      have h_k_sq : k ^ 2 = 3 := by
        exact mul_left_cancel₀ ( pow_ne_zero 2 ( sub_ne_zero_of_ne hab ) ) ( by rw [ hk ] at h_contra; linarith );
      nlinarith [ show k ≤ 1 by nlinarith, show k ≥ -1 by nlinarith ]

theorem rotation_angle_rational (a b : ℤ) (hab : a ≠ b) :
    ∃ (p q : ℤ), q ≠ 0 ∧
    p * ((1 + a ^ 2) * (1 + b ^ 2)) = q * (a * b + 1) ^ 2 := by
      exact ⟨ ( a * b + 1 ) ^ 2, ( 1 + a ^ 2 ) * ( 1 + b ^ 2 ), by exact mul_ne_zero ( by nlinarith ) ( by nlinarith ), by ring ⟩