/-! # CatalogBuild.Computation.Factoring.HarmonicResidueFactor

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11
-/

import Mathlib

/-- [Section: # CatalogBuild.Computation.Factoring.HarmonicResidueFactor
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11] -/
theorem diff_sq_eq_factor (a b : ℤ) :
    a ^ 2 - b ^ 2 = (a - b) * (a + b) := by
  grind


/-- [Section: # CatalogBuild.Computation.Factoring.HarmonicResidueFactor
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11] -/
theorem fermat_factor_nontrivial (N a b : ℤ) (hN : N = a ^ 2 - b ^ 2)
    (ha : a > 0) (hb : b > 0) (hab : a - b > 1) (hab2 : a > b) :
    (a - b > 1) ∧ (a + b > 1) ∧ N = (a - b) * (a + b) := by
  exact ⟨ hab, by linarith, by rw [ hN ] ; ring ⟩


/-- [Section: # CatalogBuild.Computation.Factoring.HarmonicResidueFactor
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11] -/
theorem fermat_factor_divides (N a b : ℤ) (hN : N = a ^ 2 - b ^ 2) :
    (a - b) ∣ N ∧ (a + b) ∣ N := by
  exact ⟨ hN ▸ ⟨ a + b, by ring ⟩, hN ▸ ⟨ a - b, by ring ⟩ ⟩


theorem odd_composite_diff_sq (p q : ℤ) (hp : p > 1) (hq : q > 1)
    (hpodd : ¬ 2 ∣ p) (hqodd : ¬ 2 ∣ q) :
    ∃ a b : ℤ, a > b ∧ b ≥ 0 ∧ p * q = a ^ 2 - b ^ 2 := by
  obtain ⟨m, hm⟩ : ∃ m : ℤ, q = 2 * m + 1 := by
    exact Int.odd_iff.mpr ( Int.emod_two_ne_zero.mp fun h => hqodd <| Int.dvd_of_emod_eq_zero h )
  obtain ⟨n, hn⟩ : ∃ n : ℤ, p = 2 * n + 1 := by
    exact Int.odd_iff.mpr ( Int.emod_two_ne_zero.mp fun h => hpodd <| Int.dvd_of_emod_eq_zero h );
  cases le_or_gt m n <;> [ exact ⟨ m + n + 1, n - m, by linarith, by linarith, by subst_vars; ring ⟩ ; exact ⟨ m + n + 1, m - n, by linarith, by linarith, by subst_vars; ring ⟩ ]


theorem diff_sq_construction (p q : ℤ) (hpodd : ∃ k, p = 2 * k + 1)
    (hqodd : ∃ k, q = 2 * k + 1) :
    ((p + q) / 2) ^ 2 - ((q - p) / 2) ^ 2 = p * q := by
  rcases hpodd with ⟨ m, rfl ⟩ ; rcases hqodd with ⟨ n, rfl ⟩ ; ring_nf;
  norm_num [ Int.add_mul_ediv_right ] ; ring;
  norm_num [ Int.neg_ediv_of_dvd, dvd_mul_right ] ; ring


theorem residue_sieve_filter (N a b m : ℤ) (hm : m > 0)
    (hN : N = a ^ 2 - b ^ 2) :
    (a ^ 2 - N) % m = (b ^ 2) % m := by
  aesop


theorem residue_sieve_contrapositive (N a m : ℤ) (hm : m > 0)
    (hnotqr : ¬ ∃ c : ℤ, (c ^ 2) % m = (a ^ 2 - N) % m) :
    ¬ ∃ b : ℤ, N = a ^ 2 - b ^ 2 := by
  grind +qlia


theorem multi_sieve_elimination (N a : ℤ) (moduli : List ℤ)
    (h : ∃ m ∈ moduli, m > 0 ∧ ¬ ∃ c : ℤ, (c ^ 2) % m = (a ^ 2 - N) % m) :
    ¬ ∃ b : ℤ, N = a ^ 2 - b ^ 2 := by
  obtain ⟨ m, hm₁, hm₂, hm₃ ⟩ := h; exact fun ⟨ b, hb ⟩ => hm₃ ⟨ b, by rw [ hb ] ; ring ⟩ ;


theorem fermat_search_bound (N p q : ℤ) (hp : p ≥ 1) (hq : q ≥ 1)
    (hN : N = p * q) (hpq : p ≤ q) :
    (p + q) / 2 ≤ (N + p) / 2 := by
  exact Int.ediv_le_ediv ( by linarith ) ( by nlinarith )


theorem fermat_search_lower_bound (p q : ℤ) (hp : p ≥ 1) (hq : q ≥ 1)
    (hpq : p ≤ q) :
    (p + q) / 2 ≥ p := by
  omega


theorem compositeness_certificate (N a b : ℤ) (hN_pos : N > 0)
    (hN : N = a ^ 2 - b ^ 2) (hb_pos : b > 0)
    (h_lower : a - b > 1) (h_upper : a + b < N) :
    ∃ d : ℤ, d > 1 ∧ d < N ∧ d ∣ N := by
  exact ⟨ a + b, by linarith, by linarith, ⟨ a - b, by linarith ⟩ ⟩


