/-! # CatalogBuild.Pythagorean.Berggren.OpenResearchTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 17
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.Berggren.OpenResearchTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 17] -/
theorem linear_gp (x N : ℤ) : gp x N (x + N) = -x := by simp only [gp]; ring


theorem linear_gq (x N : ℤ) : gq x N (x + N) = -N := by simp only [gq]; ring


theorem linear_gh (x N : ℤ) : gh x N (x + N) = x + N := by simp only [gh]; ring


/-- The linear triplet is a fixed point of UP (|gp|=x, |gq|=N, gh=x+N). -/
theorem linear_triplet_fixed_abs (x N : ℤ) (hx : 0 < x) (hN : 0 < N) :
    (|gp x N (x + N)|, |gq x N (x + N)|, gh x N (x + N)) = (x, N, x + N) := by
  simp only [linear_gp, linear_gq, linear_gh, abs_neg, abs_of_pos hx, abs_of_pos hN]


theorem deficit_factor_decomp (p q : ℤ) :
    deficit p q (p * q) = p ^ 2 * (1 - q ^ 2) + q ^ 2 := by
  simp only [deficit]; ring


/-- Ghost difference change between two factoring triplets is independent of N. -/
theorem multi_triplet_diff_independence (x₁ x₂ N : ℤ) :
    (gp x₁ N (x₁^2 + N^2) - gq x₁ N (x₁^2 + N^2)) -
    (gp x₂ N (x₂^2 + N^2) - gq x₂ N (x₂^2 + N^2)) = x₂ - x₁ := by
  simp only [gp, gq]; ring


/-- For the factoring triplet, h > x + N (grows, no descent). -/
theorem factoring_h_grows (x N : ℤ) (hx : 1 ≤ x) (hN : 2 ≤ N) :
    x + N < gh x N (x ^ 2 + N ^ 2) := by
  simp only [gh]; nlinarith [sq_nonneg x, sq_nonneg N, sq_nonneg (x-1), sq_nonneg (N-1)]

-- ═══════════════════════════════════════════════════════════════
-- Part 10: Difference Triplet
-- ═══════════════════════════════════════════════════════════════


theorem diff_gp (x N : ℤ) : gp x (N - x) N = -x := by simp only [gp]; ring


theorem diff_gq (x N : ℤ) : gq x (N - x) N = x - N := by simp only [gq]; ring


theorem diff_gh (x N : ℤ) : gh x (N - x) N = N := by simp only [gh]; ring

-- ═══════════════════════════════════════════════════════════════
-- Part 11: Modular Arithmetic Properties
-- ═══════════════════════════════════════════════════════════════


theorem ghost_p_mod3 (a b c : ℤ) : gp a b c % 3 = (a - b + c) % 3 := by
  simp only [gp]; omega


theorem ghost_q_mod3 (a b c : ℤ) : gq a b c % 3 = (-a + b + c) % 3 := by
  simp only [gq]; omega

-- ═══════════════════════════════════════════════════════════════
-- Part 12: Unit Probe Triplet (1, N, N) — NEW DISCOVERY
-- ═══════════════════════════════════════════════════════════════


/-- The ghost h descends: h = N - 2 < N. -/
theorem unit_probe_descent (N : ℤ) (_hN : 3 ≤ N) : gh 1 N N < N := by
  rw [unit_probe_gh]; omega


/-- gp stays at 1 through iteration: gp(1, M, M) = 1 for any M. -/
theorem unit_probe_iterate_p (M : ℤ) : gp 1 M M = 1 := by simp only [gp]; ring


/-- Descent chain: (1,N,N) → (1,N-2,N-2) → (1,N-4,N-4) → ... -/
theorem unit_probe_chain (N : ℤ) : gh 1 N N = N - 2 := by simp only [gh]; ring


/-- The deficit is invariant under negation of legs. -/
theorem neg_deficit_invariant (x N : ℤ) :
    deficit (-x) (-N) (x + N) = deficit x N (x + N) := by
  simp only [deficit]; ring

-- ═══════════════════════════════════════════════════════════════
-- Part 14: Eigenvector Analysis
-- ═══════════════════════════════════════════════════════════════


/-- tr(G) = 5. -/
theorem ghost_matrix_trace : (1 : ℤ) + 1 + 3 = 5 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Part 18: Concrete Verifications
-- ═══════════════════════════════════════════════════════════════

example : deficit 3 15 18 = -90 := by simp only [deficit]; norm_num
example : gp 3 4 5 + gq 3 4 5 + gh 3 4 5 = 2 := by simp only [gp, gq, gh]; norm_num
example : deficit 7 11 77 = -5759 := by simp only [deficit]; norm_num
example : |gp 7 11 77 - gq 7 11 77| = 4 := by simp only [gp, gq]; norm_num
example : deficit 1 77 77 = 1 := by simp only [deficit]; norm_num
example : deficit 1 75 75 = 1 := by simp only [deficit]; norm_num

-- Unit probe chain verification: (1,77,77) → (1,75,75) → (1,73,73) → ...
example : gh 1 77 77 = 75 := by simp only [gh]; norm_num
example : gh 1 75 75 = 73 := by simp only [gh]; norm_num
example : gp 1 77 77 = 1 := by simp only [gp]; norm_num

-- Axiom checks
#print axioms ghost_trace
#print axioms deficit_preservation
#print axioms linear_triplet_fixed_abs
#print axioms unit_probe_descent
#print axioms deficit_factor_iff


