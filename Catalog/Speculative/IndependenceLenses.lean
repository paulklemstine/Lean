/-! # CatalogBuild.Speculative.IndependenceLenses

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.IndependenceLenses
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10] -/
def residueLens (p ℓ : ℕ) : ℕ := p % ℓ




/-- [Section: # CatalogBuild.Speculative.IndependenceLenses
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10] -/
theorem residue_constrains (p ℓ : ℕ) :
    ∃ k, p = ℓ * k + p % ℓ := ⟨p / ℓ, (Nat.div_add_mod p ℓ).symm⟩




theorem odd_prime_odd {p : ℕ} (hp : Nat.Prime p) (hp2 : p ≠ 2) : ¬ 2 ∣ p := by
  rw [ hp.dvd_iff_eq ] <;> aesop




theorem distinct_primes_coprime {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hne : p ≠ q) : Nat.Coprime p q := by
  simpa [ hne ] using Nat.coprime_primes hp hq




theorem k_independent_reduction (S k : ℕ) (hS : 0 < S) (hk : 1 ≤ k) :
    S / 2 ^ k < S := by
  apply Nat.div_lt_self hS
  calc 2 ^ k ≥ 2 ^ 1 := Nat.pow_le_pow_right (by norm_num) hk
    _ = 2 := by norm_num




theorem combined_search_reduction (n k : ℕ) (hk : k ≤ n) :
    2 ^ n / 2 ^ k = 2 ^ (n - k) :=
  Nat.pow_div hk (by norm_num : 0 < 2)




def primeCountDecidable (n : ℕ) : ℕ :=
  ((Finset.Icc 2 n).filter Nat.Prime).card




theorem nine_independent_lenses : primeCountDecidable 23 ≥ 9 := by native_decide




theorem nine_primes_coprime :
    List.Pairwise Nat.Coprime [2, 3, 5, 7, 11, 13, 17, 19, 23] := by native_decide




theorem rsa2048_lens_reduction : 1024 - 9 = 1015 := by norm_num



