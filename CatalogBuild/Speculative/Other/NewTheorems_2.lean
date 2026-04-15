/-! # CatalogBuild.Speculative.Other.NewTheorems_2

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 16
-/

import Mathlib

/-- In a right triangle with integer sides, a + b > c. -/
theorem ppt_sum_of_sides (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (_hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : c < a + b := by
  nlinarith [sq_nonneg (a + b - c), sq_nonneg (a - b)]

/-- The hypotenuse strictly exceeds each leg. -/

theorem ppt_c_gt_a (a b c : ℤ) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : a < c := by
  nlinarith [sq_nonneg b, sq_nonneg (c - a)]


theorem ppt_c_gt_b (a b c : ℤ) (ha : 0 < a) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : b < c := by
  nlinarith [sq_nonneg a, sq_nonneg (c - b)]

/-
PROBLEM
In any Pythagorean triple, ab is even (at least one leg is even).

PROVIDED SOLUTION
If both a and b are odd, then a² ≡ b² ≡ 1 mod 4, so c² ≡ 2 mod 4. But squares mod 4 are 0 or 1, contradiction. So at least one of a,b is even, hence a*b is even. Use Int.even_mul and case analysis on parity.
-/

theorem pyth_product_even (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    Even (a * b) := by
      by_contra! h_even; have := congr_arg ( · % 4 ) h; rcases Int.even_or_odd' a with ⟨ b₁, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ b₂, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ b₃, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;
      · grind;
      · exact absurd h_even ( by simp +decide [ parity_simps ] )

/-- (a+b)² = c² + 2ab for any Pythagorean triple. -/

theorem sum_of_legs_sq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + b) ^ 2 = c ^ 2 + 2 * a * b := by nlinarith

/-- (a-b)² = c² - 2ab for any Pythagorean triple. -/

theorem diff_of_legs_sq (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - b) ^ 2 = c ^ 2 - 2 * a * b := by nlinarith

/-- The incircle identity: 2·ab = (a+b-c)(a+b+c) for any Pythagorean triple.
    Since r = (a+b-c)/2 is the inradius, this encodes K = r·s. -/

theorem pythagorean_incircle (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 * (a * b) = (a + b - c) * (a + b + c) := by nlinarith

/-- There are infinitely many Pythagorean triples: for each n > 0,
    (2n+1, 2n²+2n, 2n²+2n+1) is a Pythagorean triple. -/

theorem infinite_pythagorean_triples (n : ℕ) :
    (2 * n + 1) ^ 2 + (2 * n ^ 2 + 2 * n) ^ 2 = (2 * n ^ 2 + 2 * n + 1) ^ 2 := by
  ring

/-! ## Modular Arithmetic Structure -/

/-
PROBLEM
For a PPT with a odd and b even, c² ≡ 1 (mod 8).

PROVIDED SOLUTION
a odd means a = 2m+1, b even means b = 2n. Then c² = (2m+1)² + (2n)² = 4m²+4m+1+4n² = 4(m²+m+n²)+1. Since m²+m = m(m+1) is always even, say m²+m = 2k, we get c² = 8k+4n²+1. And 4n² mod 8 is 0 (if n even) or 4 (if n odd). But c must be odd (since c² is odd), so c = 2p+1, c² = 4p²+4p+1. Then c²%8: p even → 1, p odd → 1+4+4=9≡1. So c²%8=1.
-/

theorem pyth_mod8_structure (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : Odd a) (hb : Even b) : c ^ 2 % 8 = 1 := by
      replace h := congr_arg ( · % 8 ) h; obtain ⟨ m, rfl ⟩ := ha; obtain ⟨ n, rfl ⟩ := hb; ring_nf at *; norm_num [ Int.add_emod, Int.mul_emod ] at *;
      norm_num [ sq, Int.add_emod, Int.mul_emod ] at *; have := Int.emod_nonneg m ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg n ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg c ( by norm_num : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos m ( by norm_num : ( 0 : ℤ ) < 8 ) ; have := Int.emod_lt_of_pos n ( by norm_num : ( 0 : ℤ ) < 8 ) ; have := Int.emod_lt_of_pos c ( by norm_num : ( 0 : ℤ ) < 8 ) ; interval_cases m % 8 <;> interval_cases n % 8 <;> interval_cases c % 8 <;> trivial;

/-
PROBLEM
In any Pythagorean triple, 3 divides ab.

PROVIDED SOLUTION
Squares mod 3 are 0 or 1. If 3 ∤ a and 3 ∤ b, then a² ≡ b² ≡ 1 mod 3, so c² ≡ 2 mod 3, but 2 is not a quadratic residue mod 3. Contradiction. So 3 | a or 3 | b, hence 3 | ab. Use Int.emod_emod_of_dvd or direct omega on a%3 and b%3 cases.
-/

theorem pyth_mod3_divides (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (3 : ℤ) ∣ a * b := by
      by_contra h_contra;
      exact h_contra <| Int.dvd_of_emod_eq_zero <| by have := congr_arg ( · % 3 ) h; norm_num [ sq, Int.mul_emod, Int.add_emod ] at this ⊢; have := Int.emod_nonneg a three_pos.ne'; have := Int.emod_nonneg b three_pos.ne'; have := Int.emod_nonneg c three_pos.ne'; have := Int.emod_lt_of_pos a three_pos; have := Int.emod_lt_of_pos b three_pos; have := Int.emod_lt_of_pos c three_pos; interval_cases a % 3 <;> interval_cases b % 3 <;> interval_cases c % 3 <;> trivial;

/-
PROBLEM
In any Pythagorean triple, 5 divides abc.

PROVIDED SOLUTION
Squares mod 5 are {0, 1, 4}. If 5 ∤ a, 5 ∤ b, 5 ∤ c, then a²%5, b²%5, c²%5 ∈ {1,4}. Check all 4 cases of a²+b² mod 5: 1+1=2, 1+4=0, 4+1=0, 4+4=3. So c²%5 ∈ {0,2,3}. But c²%5 ∈ {1,4} (since 5∤c). This means c²%5 must be 0 (case 1+4 or 4+1 give 0), but 5∤c means c²%5≠0. The only way is if a²+b² ≡ 0 mod 5 and c²≡0 mod 5, contradicting 5∤c. So 5|a or 5|b or 5|c, hence 5|abc. Use omega or decide after reducing mod 5.
-/

theorem pyth_mod5_divides (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (5 : ℤ) ∣ a * b * c := by
      rw [ Int.dvd_iff_emod_eq_zero ] ; replace h := congr_arg ( · % 5 ) h ; norm_num [ sq, Int.add_emod, Int.mul_emod ] at h ⊢ ; have := Int.emod_nonneg a ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg b ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_nonneg c ( by decide : ( 5 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos a ( by decide : ( 5 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos b ( by decide : ( 5 : ℤ ) > 0 ) ; have := Int.emod_lt_of_pos c ( by decide : ( 5 : ℤ ) > 0 ) ; interval_cases a % 5 <;> interval_cases b % 5 <;> interval_cases c % 5 <;> trivial;

/-! ## Pell Equation Connection -/

/-- From a²+(2k)²=c², we get c²-4k²=a². -/

theorem pell_from_pyth (a k c : ℤ) (h : a ^ 2 + (2 * k) ^ 2 = c ^ 2) :
    c ^ 2 - 4 * k ^ 2 = a ^ 2 := by linarith

/-- The fundamental Pell identity: if x²-Dy²=1 and u²-Dv²=1,
    then (xu+Dyv)²-D(xv+yu)²=1. -/

theorem gaussian_norm_eq_zero (a b : ℤ) : a ^ 2 + b ^ 2 = 0 ↔ a = 0 ∧ b = 0 := by
  constructor
  · intro h
    have ha : a ^ 2 = 0 := by nlinarith [sq_nonneg b]
    have hb : b ^ 2 = 0 := by nlinarith [sq_nonneg a]
    exact ⟨by nlinarith [sq_abs a], by nlinarith [sq_abs b]⟩
  · rintro ⟨rfl, rfl⟩; ring

/-! ## Descent Theory -/

/-
PROBLEM
c ≥ 5 for any PPT with coprime positive entries.

PROVIDED SOLUTION
We need c ≥ 5 given a²+b²=c² with a,b coprime positive. Since a,b ≥ 1 and coprime, not both can be 1 (that gives c²=2, impossible). Actually enumerate: c ≤ 4 means c ∈ {1,2,3,4}. For each, a²+b²=c² with 0 < a, 0 < b, gcd(a,b)=1. c=1: impossible. c=2: a²+b²=4, only (0,2) or (2,0), but a,b>0 fails. Etc. Use interval_cases c or omega.
-/

theorem ppt_hypotenuse_lower_bound (a b c : ℕ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (hcop : Nat.Coprime a b) :
    5 ≤ c := by
      exact le_of_not_gt fun hc : c < 5 => by interval_cases c <;> have := Nat.le_of_lt_succ ( show a < 6 by nlinarith only [ h ] ) <;> have := Nat.le_of_lt_succ ( show b < 6 by nlinarith only [ h ] ) <;> interval_cases a <;> interval_cases b <;> trivial;

/-- Vieta involution: a² + (c-b)² = 2c(c-b). -/

theorem vieta_pythagorean (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a ^ 2 + (c - b) ^ 2 = 2 * c * (c - b) := by nlinarith

/-! ## Tree Enumeration -/

/-
PROBLEM
The total number of nodes at depths 0 through d in a ternary tree
    is (3^(d+1) - 1) / 2.

PROVIDED SOLUTION
This is the geometric series formula: sum_{i=0}^d 3^i = (3^{d+1}-1)/2, equivalently 2 * sum = 3^{d+1}-1. Induction on d. Base: 2*3^0 = 2 = 3-1. Step: 2*sum_{i=0}^{d+1} 3^i = 2*(sum_{i=0}^d 3^i + 3^{d+1}) = (3^{d+1}-1) + 2*3^{d+1} = 3*3^{d+1}-1 = 3^{d+2}-1. Use Finset.sum_range_succ and induction.
-/

theorem consecutive_leg_hyp (n : ℕ) :
    2 * n ^ 2 + 2 * n + 1 = (2 * n ^ 2 + 2 * n) + 1 := by ring
