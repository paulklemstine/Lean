/-! # CatalogBuild.FutureResearch.DivisorFunctionLibrary

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 17
-/

import Mathlib

noncomputable section

noncomputable def σ₀ (n : ℕ) : ℕ := n.divisors.card


theorem sigma1_one : σ₁ 1 = 1 := by simp [σ₁, Nat.divisors_one]


theorem sigma0_one : σ₀ 1 = 1 := by simp [σ₀, Nat.divisors_one]


theorem sigma1_prime (p : ℕ) (hp : Nat.Prime p) : σ₁ p = p + 1 := by
  simp +decide [ add_comm, σ₁ ];
  rw [ hp.sum_divisors, add_comm ]


theorem sigma0_prime (p : ℕ) (hp : Nat.Prime p) : σ₀ p = 2 := by
  unfold σ₀; rw [ hp.divisors, Finset.card_insert_of_notMem ] <;> aesop;


theorem sigma1_prime_power_geom (p n : ℕ) (hp : Nat.Prime p) :
    σ₁ (p ^ n) = ∑ i ∈ Finset.range (n + 1), p ^ i := by
  unfold σ₁
  rw [Nat.divisors_prime_pow hp]
  simp [Finset.sum_map, Function.Embedding.coeFn_mk]


theorem sigma0_prime_power (p n : ℕ) (hp : Nat.Prime p) :
    σ₀ (p ^ n) = n + 1 := by
  unfold σ₀
  rw [Nat.divisors_prime_pow hp]
  simp [Finset.card_map]


theorem sigma1_multiplicative (m n : ℕ) (hcop : Nat.Coprime m n) :
    σ₁ (m * n) = σ₁ m * σ₁ n := by
  unfold σ₁; exact Coprime.sum_divisors_mul hcop


theorem sigma0_multiplicative (m n : ℕ) (hcop : Nat.Coprime m n) :
    σ₀ (m * n) = σ₀ m * σ₀ n := by
  unfold σ₀;
  grind +suggestions


theorem sigma1_lower_bound (n : ℕ) (hn : 1 < n) : n + 1 ≤ σ₁ n := by
  unfold σ₁
  have h1 : 1 ∈ n.divisors := Nat.mem_divisors.mpr ⟨one_dvd n, by omega⟩
  have hn_mem : n ∈ n.divisors := Nat.mem_divisors.mpr ⟨dvd_refl n, by omega⟩
  calc n + 1
    _ = ∑ d ∈ ({1, n} : Finset ℕ), d := by
        simp [Finset.sum_pair (by omega : (1 : ℕ) ≠ n)]; omega
    _ ≤ ∑ d ∈ n.divisors, d := by
        apply Finset.sum_le_sum_of_subset
        intro x hx; simp at hx
        rcases hx with rfl | rfl <;> assumption


theorem sigma1_semiprime_factoring (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    σ₁ (p * q) = (p + 1) * (q + 1) := by
  have hcop : Nat.Coprime p q :=
    hp.coprime_iff_not_dvd.mpr fun h =>
      hpq (hq.eq_one_or_self_of_dvd p h |>.resolve_left hp.one_lt.ne')
  rw [sigma1_multiplicative p q hcop, sigma1_prime p hp, sigma1_prime q hq]


theorem factor_sum_from_sigma1 (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    σ₁ (p * q) - p * q - 1 = p + q := by
  rw [ Nat.sub_sub, Nat.sub_eq_of_eq_add ];
  convert sigma1_semiprime_factoring p q hp hq hpq using 1 ; ring


theorem sigma1_three_prime_powers (p q r : ℕ) (a b c : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hr : Nat.Prime r)
    (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r) :
    σ₁ (p ^ a * q ^ b * r ^ c) = σ₁ (p ^ a) * σ₁ (q ^ b) * σ₁ (r ^ c) := by
  have hcop_pq : Nat.Coprime (p ^ a) (q ^ b) :=
    (hp.coprime_iff_not_dvd.mpr fun h =>
      hpq (hq.eq_one_or_self_of_dvd p h |>.resolve_left hp.one_lt.ne')).pow a b
  have hcop_pq_r : Nat.Coprime (p ^ a * q ^ b) (r ^ c) := by
    apply Nat.Coprime.mul_left
    · exact (hp.coprime_iff_not_dvd.mpr fun h =>
        hpr (hr.eq_one_or_self_of_dvd p h |>.resolve_left hp.one_lt.ne')).pow a c
    · exact (hq.coprime_iff_not_dvd.mpr fun h =>
        hqr (hr.eq_one_or_self_of_dvd q h |>.resolve_left hq.one_lt.ne')).pow b c
  rw [sigma1_multiplicative _ _ hcop_pq_r, sigma1_multiplicative _ _ hcop_pq]


theorem sigma0_semiprime (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    σ₀ (p * q) = 4 := by
  have hcop : Nat.Coprime p q :=
    hp.coprime_iff_not_dvd.mpr fun h =>
      hpq (hq.eq_one_or_self_of_dvd p h |>.resolve_left hp.one_lt.ne')
  rw [sigma0_multiplicative p q hcop, sigma0_prime p hp, sigma0_prime q hq]


theorem totient_prime_val (p : ℕ) (hp : Nat.Prime p) :
    Nat.totient p = p - 1 := Nat.totient_prime hp


theorem sigma1_totient_prime (p : ℕ) (hp : Nat.Prime p) :
    σ₁ p = Nat.totient p + 2 := by
  unfold σ₁;
  rcases p with ( _ | _ | p ) <;> simp_all +arith +decide [ Nat.totient_prime ]


theorem sigma1_plus_totient_prime (p : ℕ) (hp : Nat.Prime p) :
    σ₁ p + Nat.totient p = 2 * p := by
  rw [ Nat.totient_prime hp, sigma1_prime p hp ];
  linarith [ Nat.sub_add_cancel hp.pos ]

end
