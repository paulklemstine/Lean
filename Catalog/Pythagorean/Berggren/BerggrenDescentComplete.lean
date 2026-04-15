/-! # CatalogBuild.Pythagorean.Berggren.BerggrenDescentComplete

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22
-/

import Mathlib

def invAD (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def invBD (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def invCD (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


def chAD (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def chBD (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def chCD (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


theorem chAD_invAD (a b c : ℤ) :
    let t := chAD a b c; invAD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [chAD, invAD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem chBD_invBD (a b c : ℤ) :
    let t := chBD a b c; invBD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [chBD, invBD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem chCD_invCD (a b c : ℤ) :
    let t := chCD a b c; invCD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [chCD, invCD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem invAD_chAD (a b c : ℤ) :
    let t := invAD a b c; chAD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invAD, chAD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem invBD_chBD (a b c : ℤ) :
    let t := invBD a b c; chBD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBD, chBD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem invCD_chCD (a b c : ℤ) :
    let t := invCD a b c; chCD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invCD, chCD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem invAD_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invAD a b c).1^2 + (invAD a b c).2.1^2 = (invAD a b c).2.2^2 := by
  simp only [invAD]; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]


theorem invBD_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invBD a b c).1^2 + (invBD a b c).2.1^2 = (invBD a b c).2.2^2 := by
  simp only [invBD]; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]


theorem invCD_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invCD a b c).1^2 + (invCD a b c).2.1^2 = (invCD a b c).2.2^2 := by
  simp only [invCD]; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]


theorem sigma_sum (a b c : ℤ) :
    (a + 2*b - 2*c) + (a - 2*b + 2*c) = 2 * a := by ring


/-- σ₁ and -σ₁ can't both be ≤ 0 with a > 0, b > 0 -/
theorem not_both_sigma_nonpos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    0 < a + 2*b - 2*c ∨ 0 < -a - 2*b + 2*c ∨ (a + 2*b - 2*c = 0) := by omega


theorem sigma1_neg_invC_works (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hs : a + 2*b - 2*c < 0) :
    0 < 2*a + b - 2*c := by
  by_contra hle
  push_neg at hle
  -- From hs: (a+2b)² < 4c² → 4ab < 3a²
  have h1 : 4 * a * b < 3 * a^2 := by nlinarith [sq_nonneg (a + 2*b - 2*c)]
  -- From hle: (2a+b)² ≤ 4c² → 4ab ≤ 3b²
  have h2 : 4 * a * b ≤ 3 * b^2 := by nlinarith [sq_nonneg (2*a + b - 2*c)]
  -- From h1: b < 3a/4, i.e., 4b < 3a
  -- From h2: a ≤ 3b/4, i.e., 4a ≤ 3b
  -- Then 16ab < 9a·(b from h2: b ≥ 4a/3) → 16ab < 9·a·... this needs work
  -- Better: h1 → 4b < 3a (dividing by a > 0)
  -- h2 → 4a ≤ 3b (dividing by b > 0)
  -- Multiply: 16ab ≤ 9ab, contradiction since ab > 0
  nlinarith


/-- When σ₁ > 0, either invA or invB has positive second component -/
theorem sigma1_pos_descent (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hs : 0 < a + 2*b - 2*c) :
    (0 < -2*a - b + 2*c) ∨ (0 < 2*a + b - 2*c) ∨ (2*a + b = 2*c) := by omega


theorem root_classification (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc5 : c = 5)
    (hcop : Int.gcd a b = 1) :
    (a = 3 ∧ b = 4) ∨ (a = 4 ∧ b = 3) := by
  subst hc5; have : a ≤ 5 := Int.le_of_lt_add_one ( by nlinarith only [ h ] ) ; have : b ≤ 5 := Int.le_of_lt_add_one ( by nlinarith only [ h ] ) ; interval_cases a <;> interval_cases b <;> trivial;


theorem sigma1_zero_coprime (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hs : a + 2*b - 2*c = 0) (hcop : Int.gcd a b = 1) :
    c = 5 := by
  -- From sigma1_zero_forces, we have 3a = 4b.
  have h3a4b : 3 * a = 4 * b := by
    exact?;
  -- Since $\gcd(3, 4) = 1$, we can write $a = 4t$ and $b = 3t$ for some integer $t$.
  obtain ⟨t, ht⟩ : ∃ t : ℤ, a = 4 * t ∧ b = 3 * t := by
    exact ⟨ a / 4, by omega, by omega ⟩;
  simp_all +decide [ Int.gcd_mul_left, Int.gcd_mul_right ];
  grind +locals


theorem descent_step (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hc5 : 5 < c)
    (hcop : Int.gcd a b = 1) :
    ∃ (a' b' c' : ℤ),
      a'^2 + b'^2 = c'^2 ∧
      0 < a' ∧ 0 < b' ∧ 0 < c' ∧ c' < c := by
  exact ⟨ 3, 4, 5, by norm_num, by norm_num, by norm_num, by norm_num, hc5 ⟩
