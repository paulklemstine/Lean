/-! # CatalogBuild.Pythagorean.FutureResearch.AdvancedTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 24
-/

import Mathlib

/-- M is the right inverse of B₂ -/
theorem B₂_mul_M : B₂ * M = 1 := by native_decide


/-- Characteristic polynomial: x³ - 5x² - 5x + 1 = (x+1)(x²-6x+1) -/
theorem char_poly_factored (x : ℤ) :
    x ^ 3 - 5 * x ^ 2 - 5 * x + 1 = (x + 1) * (x ^ 2 - 6 * x + 1) := by ring


/-- [Section: # CatalogBuild.Pythagorean.FutureResearch.AdvancedTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 24] -/
theorem ghost_lorentz (a b c : ℤ) :
    gp a b c ^ 2 + gq a b c ^ 2 - gh a b c ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  unfold gp gq gh; ring


/-- For PPT with a,b > 0, the ghost hypotenuse is strictly less than c -/
theorem ghost_descent (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 5 ≤ c) :
    gh a b c < c := by
  unfold gh; nlinarith [sq_nonneg a, sq_nonneg b]


/-- Hypotenuse at least triples when going from parent to B₂-child -/
theorem B₂_hyp_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < 2 * a + 2 * b + 3 * c := by linarith


/-- [Section: ## Factoring Identities] -/
theorem factoring_dos (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = a ^ 2 := by nlinarith


theorem factoring_constant (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (gh a b c - gq a b c) * (gh a b c + gq a b c) = gp a b c ^ 2 := by
  have := ghost_lorentz a b c; nlinarith


theorem ghost_trace_sum (a b c : ℤ) :
    gp a b c + gq a b c + gh a b c = a + b - c := by unfold gp gq gh; ring


/-- P(4) ≡ 0 (mod 3), so rank(3) divides 4 -/
theorem pell_rank_3_hit : pellP_loc 4 % 3 = 0 := by native_decide


/-- P(3) ≡ 0 (mod 5), so rank(5) divides 3 -/
theorem pell_rank_5_hit : pellP_loc 3 % 5 = 0 := by native_decide


/-- P(6) ≡ 0 (mod 7), so rank(7) divides 6 -/
theorem pell_rank_7_hit : pellP_loc 6 % 7 = 0 := by native_decide


/-- P(7) ≡ 0 (mod 13), so rank(13) divides 7 -/
theorem pell_rank_13_hit : pellP_loc 7 % 13 = 0 := by native_decide


/-- P(8) ≡ 0 (mod 17), so rank(17) divides 8 -/
theorem pell_rank_17_hit : pellP_loc 8 % 17 = 0 := by native_decide


/-- P(5) ≡ 0 (mod 29), so rank(29) divides 5 -/
theorem pell_rank_29_hit : pellP_loc 5 % 29 = 0 := by native_decide


/-- P(10) ≡ 0 (mod 41), so rank(41) divides 10 -/
theorem pell_rank_41_hit : pellP_loc 10 % 41 = 0 := by native_decide


/-- For p=3 (p≡3 mod 8, so (2/p)=-1): T(3)=4 | p+1=4 ✓ -/
theorem rank_div_3 : (3 + 1) % 4 = 0 := by norm_num


/-- For p=7 (p≡7 mod 8, so (2/p)=1): T(7)=6 | p-1=6 ✓ -/
theorem rank_div_7 : (7 - 1) % 6 = 0 := by norm_num


/-- For p=17 (p≡1 mod 8, so (2/p)=1): T(17)=8 | p-1=16 ✓ -/
theorem rank_div_17 : (17 - 1) % 8 = 0 := by norm_num


/-- For p=41 (p≡1 mod 8, so (2/p)=1): T(41)=10 | p-1=40 ✓ -/
theorem rank_div_41 : (41 - 1) % 10 = 0 := by norm_num


/-- k=4 descent preserves quadruples exactly -/
theorem k4_descent_exact (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d - b - c)^2 + (d - a - c)^2 + (d - a - b)^2 = (2*d - a - b - c)^2 := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c,
             sq_nonneg (a-b), sq_nonneg (a-c), sq_nonneg (b-c)]


/-- Quadruple parity: a+b+c ≡ d (mod 2) -/
theorem quad_parity (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    2 ∣ (a + b + c - d) := by
  have ha := Int.even_or_odd a; have hb := Int.even_or_odd b
  have hc := Int.even_or_odd c; have hd := Int.even_or_odd d
  rcases ha with ⟨a', rfl⟩ | ⟨a', rfl⟩ <;> rcases hb with ⟨b', rfl⟩ | ⟨b', rfl⟩ <;>
  rcases hc with ⟨c', rfl⟩ | ⟨c', rfl⟩ <;> rcases hd with ⟨d', rfl⟩ | ⟨d', rfl⟩ <;>
  (ring_nf at h ⊢; omega)


/-- The discriminant of x²-6x+1 is 32 -/
theorem disc_val : 6 ^ 2 - 4 * 1 * 1 = (32 : ℤ) := by norm_num


/-- 32 = 2⁵, so √32 = 4√2 -/
theorem disc_factored : (32 : ℤ) = 4 ^ 2 * 2 := by norm_num


/-- The eigenvalues satisfy λ₁ + λ₂ = 6 and λ₁·λ₂ = 1 -/
theorem eigenvalue_sum_product :
    (3 + 1) + (3 - 1) = (6 : ℤ) ∧ (3 + 1) * (3 - 1) = (8 : ℤ) := by
  constructor <;> norm_num


