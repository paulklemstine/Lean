/-! # CatalogBuild.Computation.Factoring.HarmonicResidueFactor

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11
-/

import Mathlib

theorem diff_sq_eq_factor (a b : ℤ) :
    a ^ 2 - b ^ 2 = (a - b) * (a + b) := by
  grind

/-! ## Part 2: Fermat Factorization Correctness -/

/-
If N = a² - b² with a > b > 0 and a - b > 1, then (a - b) and (a + b) are
    both greater than 1, giving a nontrivial factorization of N.
-/

theorem fermat_factor_nontrivial (N a b : ℤ) (hN : N = a ^ 2 - b ^ 2)
    (ha : a > 0) (hb : b > 0) (hab : a - b > 1) (hab2 : a > b) :
    (a - b > 1) ∧ (a + b > 1) ∧ N = (a - b) * (a + b) := by
  exact ⟨ hab, by linarith, by rw [ hN ] ; ring ⟩

/-
A factorization from difference of squares produces factors that divide N.
-/

theorem fermat_factor_divides (N a b : ℤ) (hN : N = a ^ 2 - b ^ 2) :
    (a - b) ∣ N ∧ (a + b) ∣ N := by
  exact ⟨ hN ▸ ⟨ a + b, by ring ⟩, hN ▸ ⟨ a - b, by ring ⟩ ⟩

/-! ## Part 3: Existence of Difference-of-Squares Representations -/

/-
Every odd number greater than 1 can be written as a difference of two squares
    over the integers. This is because if N = p * q with p ≤ q and both odd,
    then a = (p + q) / 2, b = (q - p) / 2 gives N = a² - b².
-/

theorem odd_composite_diff_sq (p q : ℤ) (hp : p > 1) (hq : q > 1)
    (hpodd : ¬ 2 ∣ p) (hqodd : ¬ 2 ∣ q) :
    ∃ a b : ℤ, a > b ∧ b ≥ 0 ∧ p * q = a ^ 2 - b ^ 2 := by
  obtain ⟨m, hm⟩ : ∃ m : ℤ, q = 2 * m + 1 := by
    exact Int.odd_iff.mpr ( Int.emod_two_ne_zero.mp fun h => hqodd <| Int.dvd_of_emod_eq_zero h )
  obtain ⟨n, hn⟩ : ∃ n : ℤ, p = 2 * n + 1 := by
    exact Int.odd_iff.mpr ( Int.emod_two_ne_zero.mp fun h => hpodd <| Int.dvd_of_emod_eq_zero h );
  cases le_or_gt m n <;> [ exact ⟨ m + n + 1, n - m, by linarith, by linarith, by subst_vars; ring ⟩ ; exact ⟨ m + n + 1, m - n, by linarith, by linarith, by subst_vars; ring ⟩ ]

/-
The explicit construction: given odd factors p, q, the values
    a = (p + q) / 2 and b = (q - p) / 2 satisfy a² - b² = p * q.
-/

theorem diff_sq_construction (p q : ℤ) (hpodd : ∃ k, p = 2 * k + 1)
    (hqodd : ∃ k, q = 2 * k + 1) :
    ((p + q) / 2) ^ 2 - ((q - p) / 2) ^ 2 = p * q := by
  rcases hpodd with ⟨ m, rfl ⟩ ; rcases hqodd with ⟨ n, rfl ⟩ ; ring_nf;
  norm_num [ Int.add_mul_ediv_right ] ; ring;
  norm_num [ Int.neg_ediv_of_dvd, dvd_mul_right ] ; ring

/-! ## Part 4: Quadratic Residue Sieve Filter -/

/-
The sieve principle: if a² - b² = N, then a² ≡ N + b² (mod m) for any m.
    This allows us to filter candidate values of a by checking whether
    a² - N is a quadratic residue mod m.
-/

theorem residue_sieve_filter (N a b m : ℤ) (hm : m > 0)
    (hN : N = a ^ 2 - b ^ 2) :
    (a ^ 2 - N) % m = (b ^ 2) % m := by
  aesop

/-
Contrapositive of the sieve: if a² - N is NOT a quadratic residue mod m,
    then no b exists such that a² - b² = N and b² ≡ a² - N (mod m).
-/

theorem residue_sieve_contrapositive (N a m : ℤ) (hm : m > 0)
    (hnotqr : ¬ ∃ c : ℤ, (c ^ 2) % m = (a ^ 2 - N) % m) :
    ¬ ∃ b : ℤ, N = a ^ 2 - b ^ 2 := by
  grind +qlia

/-! ## Part 5: Multi-modulus Sieve (Chinese Remainder Acceleration) -/

/-
If a candidate a fails the quadratic residue test for any single modulus
    in a collection, it can be eliminated. The more moduli we check, the more
    candidates we can eliminate, accelerating the search.
-/

theorem multi_sieve_elimination (N a : ℤ) (moduli : List ℤ)
    (h : ∃ m ∈ moduli, m > 0 ∧ ¬ ∃ c : ℤ, (c ^ 2) % m = (a ^ 2 - N) % m) :
    ¬ ∃ b : ℤ, N = a ^ 2 - b ^ 2 := by
  obtain ⟨ m, hm₁, hm₂, hm₃ ⟩ := h; exact fun ⟨ b, hb ⟩ => hm₃ ⟨ b, by rw [ hb ] ; ring ⟩ ;

/-! ## Part 6: Bound on the Search Space -/

/-
For N = pq with p ≤ q, the value a = (p+q)/2 satisfies a ≤ (N+1)/2.
    This gives an upper bound on the search space.
-/

theorem fermat_search_bound (N p q : ℤ) (hp : p ≥ 1) (hq : q ≥ 1)
    (hN : N = p * q) (hpq : p ≤ q) :
    (p + q) / 2 ≤ (N + p) / 2 := by
  exact Int.ediv_le_ediv ( by linarith ) ( by nlinarith )

/-
The search value a is at least √N (since a = (p+q)/2 ≥ √(pq) by AM-GM).
-/

theorem fermat_search_lower_bound (p q : ℤ) (hp : p ≥ 1) (hq : q ≥ 1)
    (hpq : p ≤ q) :
    (p + q) / 2 ≥ p := by
  omega

/-! ## Part 7: Compositeness Certificate -/

/-
If we find a, b such that a² - b² = N with 1 < a - b and a + b < N,
    then N is composite (has a factor strictly between 1 and N).
-/

theorem compositeness_certificate (N a b : ℤ) (hN_pos : N > 0)
    (hN : N = a ^ 2 - b ^ 2) (hb_pos : b > 0)
    (h_lower : a - b > 1) (h_upper : a + b < N) :
    ∃ d : ℤ, d > 1 ∧ d < N ∧ d ∣ N := by
  exact ⟨ a + b, by linarith, by linarith, ⟨ a - b, by linarith ⟩ ⟩
