/-! # CatalogBuild.Computation.Oracles.OracleAnalysis

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 8
-/

import Mathlib

/-- [Section: # CatalogBuild.Computation.Oracles.OracleAnalysis
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 8] -/
theorem oracle_partial_correctness (N a b : ℕ) (h_prod : a * b = N)
    (ha : 1 < a) (hb : 1 < b) : ¬ Nat.Prime N := by
  rintro H; rw [ ← h_prod, Nat.prime_mul_iff ] at H; aesop;





/-- The search space grows exponentially: 2^(2*(n+1)) = 4 * 2^(2*n). -/
theorem search_space_exponential_growth (n : ℕ) :
    2^(2*(n+1)) = 4 * 2^(2*n) := by
  ring





/-- [Section: # CatalogBuild.Computation.Oracles.OracleAnalysis
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 8] -/
theorem bit_flip_change (a : ℕ) (k : ℕ) :
    (a + 2^k) - a = 2^k := by
  rw [ Nat.add_sub_cancel_left ]





/-- [Section: # CatalogBuild.Computation.Oracles.OracleAnalysis
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 8] -/
theorem bit_flip_product_change (a b k : ℕ) :
    (a + 2^k) * b - a * b = 2^k * b := by
  grind





theorem msb_flip_catastrophic (b n : ℕ) (hb : 0 < b) (hn : 0 < n) :
    2^(n-1) * b ≥ b := by
  exact le_mul_of_one_le_left hb.le ( Nat.one_le_pow _ _ ( by decide ) )





theorem factoring_not_in_BPP_evidence (N : ℕ) (hN : 2 ≤ N) :
    ∃ d, d ∣ N ∧ 1 ≤ d := by
  exact ⟨ 1, one_dvd _, by norm_num ⟩





theorem exponential_dominates (n : ℕ) (hn : 5 ≤ n) :
    n * n < 2^n := by
  induction' hn with n hn ih <;> norm_num [ Nat.pow_succ ] at * ; nlinarith





theorem oracle_no_speedup (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≤ q) (N : ℕ) (hN : N = p * q) :
    p ≤ N := by
  nlinarith [ hp.two_le, hq.two_le ]




