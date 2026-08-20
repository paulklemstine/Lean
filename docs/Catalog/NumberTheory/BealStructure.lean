import NumberTheory.BealConjecture

/-!
# Structure of hypothetical Beal counterexamples, and sharpness of the hypotheses

This file continues `NumberTheory.BealConjecture`.  It contains

* **non-vacuity**: explicit Beal solutions (necessarily with a common prime factor), and an
  infinite family of them;
* **sharpness**: for each of the three exponents, relaxing the bound `≥ 3` to `≥ 2` makes the
  conclusion of Beal's conjecture *false*, witnessed by the classical Fermat–Catalan solutions
  `7 ^ 2 + 2 ^ 5 = 3 ^ 4`, `7 ^ 3 + 13 ^ 2 = 2 ^ 9` and `2 ^ 7 + 17 ^ 3 = 71 ^ 2`;
* **unconditional cases**: solutions with equal bases, or with non-coprime `A, B`, satisfy Beal,
  and no solution at all exists when `3` or `4` divides `gcd (x, y, z)`;
* **a kernel-verified finite check**: Beal's conjecture holds for `A, B ≤ 10`, `C ≤ 40` and
  exponents at most `5`;
* **congruence structure of a counterexample**: exactly one of `A, B, C` is even, and if `C` is
  the even one then `x` and `y` cannot both be even (a mod `8` obstruction);
* **exponent reduction**: Beal's conjecture for exponents that are odd primes or `4` implies
  Beal's conjecture in general;
* **exact Fermat–Catalan reformulation**: Beal's conjecture says precisely that no
  Fermat–Catalan solution has all three exponents `≥ 3`.
-/

namespace Beal

/-! ## Non-vacuity: Beal solutions exist, and they do have a common prime factor -/

theorem isBealSolution_three_six : IsBealSolution 3 6 3 3 3 5 := by
  refine ⟨by norm_num, by norm_num, by norm_num, le_rfl, le_rfl, by norm_num, by norm_num⟩

theorem hasCommonPrime_three_six : HasCommonPrime 3 6 3 :=
  ⟨3, Nat.prime_three, dvd_rfl, by norm_num, dvd_rfl⟩

/-- Beal solutions exist with arbitrarily large `C`: scaling `3 ^ 3 + 6 ^ 3 = 3 ^ 5` by
`t ^ 15` gives `(3 t ^ 5) ^ 3 + (6 t ^ 5) ^ 3 = (3 t ^ 3) ^ 5`. -/
theorem infinitely_many_beal_solutions (N : ℕ) :
    ∃ A B C x y z : ℕ, IsBealSolution A B C x y z ∧ N < C ∧ HasCommonPrime A B C := by
  refine ⟨3 * (N + 1) ^ 5, 6 * (N + 1) ^ 5, 3 * (N + 1) ^ 3, 3, 3, 5,
    ⟨by positivity, by positivity, by positivity, le_rfl, le_rfl, by norm_num, by ring⟩,
    ?_, ⟨3, Nat.prime_three, ⟨(N + 1) ^ 5, rfl⟩, ⟨2 * (N + 1) ^ 5, by ring⟩, ⟨(N + 1) ^ 3, rfl⟩⟩⟩
  calc N < 3 * (N + 1) := by omega
    _ ≤ 3 * (N + 1) ^ 3 := by
        have : (N + 1) ≤ (N + 1) ^ 3 := Nat.le_self_pow (by norm_num) _
        omega

/-! ## Sharpness: the hypothesis `x, y, z ≥ 3` cannot be relaxed to `≥ 2` anywhere -/

private theorem no_common_prime_of_coprime {A B C : ℕ} (h : Nat.Coprime A B) :
    ¬ HasCommonPrime A B C := by
  rintro ⟨p, hp, hpA, hpB, -⟩
  exact hp.one_lt.ne' (Nat.eq_one_of_dvd_coprimes h hpA hpB)

/-- Relaxing the *middle* exponent to `2` destroys Beal's conclusion:
`7 ^ 3 + 13 ^ 2 = 2 ^ 9` with `7, 13, 2` pairwise coprime. -/
theorem beal_false_with_middle_exponent_two :
    ¬ ∀ A B C x y z : ℕ, 0 < A → 0 < B → 0 < C → 3 ≤ x → 2 ≤ y → 3 ≤ z →
      A ^ x + B ^ y = C ^ z → HasCommonPrime A B C := by
  intro h
  exact no_common_prime_of_coprime (A := 7) (B := 13) (C := 2) (by decide)
    (h 7 13 2 3 2 9 (by norm_num) (by norm_num) (by norm_num) le_rfl le_rfl (by norm_num)
      (by norm_num))

/-- Relaxing the exponent of `C` to `2` destroys Beal's conclusion:
`2 ^ 7 + 17 ^ 3 = 71 ^ 2`. -/
theorem beal_false_with_last_exponent_two :
    ¬ ∀ A B C x y z : ℕ, 0 < A → 0 < B → 0 < C → 3 ≤ x → 3 ≤ y → 2 ≤ z →
      A ^ x + B ^ y = C ^ z → HasCommonPrime A B C := by
  intro h
  exact no_common_prime_of_coprime (A := 2) (B := 17) (C := 71) (by decide)
    (h 2 17 71 7 3 2 (by norm_num) (by norm_num) (by norm_num) (by norm_num) le_rfl le_rfl
      (by norm_num))

/-- Relaxing the *first* exponent to `2` destroys Beal's conclusion:
`7 ^ 2 + 2 ^ 5 = 3 ^ 4` with `7, 2, 3` pairwise coprime. -/
theorem beal_false_with_first_exponent_two :
    ¬ ∀ A B C x y z : ℕ, 0 < A → 0 < B → 0 < C → 2 ≤ x → 3 ≤ y → 3 ≤ z →
      A ^ x + B ^ y = C ^ z → HasCommonPrime A B C := by
  intro h
  exact no_common_prime_of_coprime (A := 7) (B := 2) (C := 3) (by decide)
    (h 7 2 3 2 5 4 (by norm_num) (by norm_num) (by norm_num) le_rfl (by norm_num) (by norm_num)
      (by norm_num))

/-! ## Unconditional cases of Beal's conjecture -/

/-- If `A` and `B` already fail to be coprime, Beal's conclusion holds. -/
theorem hasCommonPrime_of_not_coprime {A B C x y z : ℕ} (hsol : IsBealSolution A B C x y z)
    (h : ¬ Nat.Coprime A B) : HasCommonPrime A B C := by
  by_contra hno
  exact h (pairwise_coprime_of_no_common_prime hsol hno).1

/-- Beal's conjecture holds for solutions with equal bases `A = B`. -/
theorem beal_holds_of_bases_eq {A C x y z : ℕ} (hsol : IsBealSolution A A C x y z) :
    HasCommonPrime A A C := by
  obtain ⟨hA, -, hC, hx, hy, hz, heq⟩ := hsol
  rcases Nat.lt_or_ge A 2 with hA1 | hA2
  · -- `A = 1` would force `C ^ z = 2` with `z ≥ 3`, impossible
    exfalso
    obtain rfl : A = 1 := by omega
    simp only [one_pow] at heq
    rcases Nat.lt_or_ge C 2 with hC2 | hC2
    · interval_cases C
      simp_all
    · have : 2 ^ 3 ≤ C ^ z :=
        le_trans (Nat.pow_le_pow_left hC2 3) (Nat.pow_le_pow_right (by omega) hz)
      omega
  · have hp : (A.minFac).Prime := Nat.minFac_prime (by omega)
    have hpA : A.minFac ∣ A := Nat.minFac_dvd A
    exact ⟨A.minFac, hp, hpA, hpA,
      dvd_third_of_dvd_two_ab hp (by omega) (by omega) heq hpA hpA⟩

/-! ## Congruence structure of a hypothetical counterexample -/

/-- In a solution with `A, B` coprime, exactly one of `A, B, C` is even. -/
theorem parity_trichotomy {A B C x y z : ℕ} (hsol : IsBealSolution A B C x y z)
    (hab : Nat.Coprime A B) :
    (Even A ∧ ¬ Even B ∧ ¬ Even C) ∨ (¬ Even A ∧ Even B ∧ ¬ Even C) ∨
      (¬ Even A ∧ ¬ Even B ∧ Even C) := by
  obtain ⟨hA, hB, hC, hx, hy, hz, heq⟩ := hsol
  have hnot : ¬ (Even A ∧ Even B) := by
    rintro ⟨⟨a, rfl⟩, ⟨b, rfl⟩⟩
    have : (2 : ℕ) ∣ Nat.gcd (a + a) (b + b) := Nat.dvd_gcd ⟨a, by ring⟩ ⟨b, by ring⟩
    rw [hab] at this
    omega
  have hpow : ∀ n k : ℕ, 0 < k → (Even (n ^ k) ↔ Even n) := by
    intro n k hk
    simp [Nat.even_pow, hk.ne']
  have hAx := hpow A x (by omega)
  have hBy := hpow B y (by omega)
  have hCz := hpow C z (by omega)
  have hsum : Even (A ^ x + B ^ y) ↔ Even (C ^ z) := by rw [heq]
  rw [Nat.even_add, hAx, hBy, hCz] at hsum
  by_cases hA2 : Even A <;> by_cases hB2 : Even B <;> by_cases hC2 : Even C <;> tauto

private theorem odd_pow_even_mod_eight {n k : ℕ} (hn : ¬ Even n) (hk : Even k) :
    n ^ k % 8 = 1 := by
  obtain ⟨m, rfl⟩ := hk
  have hn1 : n % 2 = 1 := Nat.not_even_iff.mp hn
  have hsq : n ^ 2 % 8 = 1 := by
    have h8 : n % 8 = 1 ∨ n % 8 = 3 ∨ n % 8 = 5 ∨ n % 8 = 7 := by omega
    rw [Nat.pow_mod]
    rcases h8 with h | h | h | h <;> rw [h]
  induction m with
  | zero => norm_num
  | succ j ih =>
    have : n ^ (j + 1 + (j + 1)) = n ^ (j + j) * n ^ 2 := by ring
    rw [this, Nat.mul_mod, ih, hsq]

/-- **A mod-8 obstruction.**  In a Beal solution with `A, B` coprime and `C` even, the exponents
`x` and `y` cannot both be even: odd perfect even powers are `1 mod 8`, while `C ^ z` with
`z ≥ 3` and `C` even is `0 mod 8`, and `1 + 1 ≠ 0 mod 8`. -/
theorem not_both_exponents_even_of_even_C {A B C x y z : ℕ} (hsol : IsBealSolution A B C x y z)
    (hab : Nat.Coprime A B) (hCeven : Even C) : ¬ (Even x ∧ Even y) := by
  rintro ⟨hx2, hy2⟩
  rcases parity_trichotomy hsol hab with ⟨-, -, h⟩ | ⟨-, -, h⟩ | ⟨hA2, hB2, -⟩
  · exact h hCeven
  · exact h hCeven
  obtain ⟨hA, hB, hC, hx, hy, hz, heq⟩ := hsol
  obtain ⟨c, rfl⟩ := hCeven
  have hCz : (c + c) ^ z % 8 = 0 := by
    have h8 : (8 : ℕ) ∣ (c + c) ^ z := by
      have : (2 : ℕ) ^ 3 ∣ (c + c) ^ z :=
        dvd_trans (pow_dvd_pow 2 hz) (pow_dvd_pow_of_dvd ⟨c, by ring⟩ z)
      simpa using this
    omega
  have hAx := odd_pow_even_mod_eight hA2 hx2
  have hBy := odd_pow_even_mod_eight hB2 hy2
  omega

/-- **Beal's conjecture holds whenever `3` or `4` divides the gcd of the exponents**: there is
then simply no solution at all, by Fermat's Last Theorem for exponent `3` resp. `4`.  For
instance, no solution exists with exponents `(6, 9, 15)`. -/
theorem no_solution_of_dvd_gcd_exponents {A B C x y z : ℕ}
    (h : 3 ∣ Nat.gcd x (Nat.gcd y z) ∨ 4 ∣ Nat.gcd x (Nat.gcd y z)) :
    ¬ IsBealSolution A B C x y z := by
  rintro ⟨hA, hB, hC, hx, hy, hz, heq⟩
  set d := Nat.gcd x (Nat.gcd y z) with hd
  have hflt : FermatLastTheoremFor d := by
    rcases h with h | h
    · exact fermatLastTheoremThree.mono h
    · exact fermatLastTheoremFour.mono h
  obtain ⟨mx, hmx⟩ : d ∣ x := Nat.gcd_dvd_left _ _
  obtain ⟨my, hmy⟩ : d ∣ y := dvd_trans (Nat.gcd_dvd_right _ _) (Nat.gcd_dvd_left _ _)
  obtain ⟨mz, hmz⟩ : d ∣ z := dvd_trans (Nat.gcd_dvd_right _ _) (Nat.gcd_dvd_right _ _)
  refine hflt (A ^ mx) (B ^ my) (C ^ mz) (by positivity) (by positivity) (by positivity) ?_
  rw [← pow_mul, ← pow_mul, ← pow_mul, mul_comm mx d, mul_comm my d, mul_comm mz d,
    ← hmx, ← hmy, ← hmz]
  exact heq

/-! ## A kernel-verified finite verification -/

set_option maxHeartbeats 4000000 in
/-- Exhaustive check (verified by the kernel): there is no coprime solution of
`A ^ x + B ^ y = C ^ z` with `A, B ≤ 10`, `C ≤ 40` and `3 ≤ x, y, z ≤ 5`. -/
private theorem small_box_check :
    ∀ A ∈ Finset.Icc 1 10, ∀ B ∈ Finset.Icc 1 10, ∀ C ∈ Finset.Icc 1 40,
      ∀ x ∈ Finset.Icc 3 5, ∀ y ∈ Finset.Icc 3 5, ∀ z ∈ Finset.Icc 3 5,
        Nat.gcd A B = 1 → A ^ x + B ^ y ≠ C ^ z := by decide

/-- **Beal's conjecture is verified in a finite box.**  Every solution with `A, B ≤ 10`,
`C ≤ 40` and exponents at most `5` does have a common prime factor. -/
theorem beal_verified_small_box {A B C x y z : ℕ} (hA : A ≤ 10) (hB : B ≤ 10) (hC : C ≤ 40)
    (hx5 : x ≤ 5) (hy5 : y ≤ 5) (hz5 : z ≤ 5) (hsol : IsBealSolution A B C x y z) :
    HasCommonPrime A B C := by
  by_contra hno
  obtain ⟨hab, -, -⟩ := pairwise_coprime_of_no_common_prime hsol hno
  obtain ⟨hA0, hB0, hC0, hx3, hy3, hz3, heq⟩ := hsol
  exact small_box_check A (Finset.mem_Icc.mpr ⟨hA0, hA⟩) B (Finset.mem_Icc.mpr ⟨hB0, hB⟩)
    C (Finset.mem_Icc.mpr ⟨hC0, hC⟩) x (Finset.mem_Icc.mpr ⟨hx3, hx5⟩)
    y (Finset.mem_Icc.mpr ⟨hy3, hy5⟩) z (Finset.mem_Icc.mpr ⟨hz3, hz5⟩) hab heq

/-! ## Reduction to prime exponents -/

/-- Every `n ≥ 3` is divisible by an odd prime or by `4`. -/
theorem exists_odd_prime_or_four_dvd {n : ℕ} (hn : 3 ≤ n) :
    ∃ d : ℕ, d ∣ n ∧ 3 ≤ d ∧ ((d.Prime ∧ ¬ Even d) ∨ d = 4) := by
  by_cases h4 : 4 ∣ n
  · exact ⟨4, h4, by norm_num, Or.inr rfl⟩
  · -- `n` is odd, or twice an odd number `≥ 3`; either way it has an odd prime divisor
    have hm : ∃ m : ℕ, 3 ≤ m ∧ ¬ Even m ∧ m ∣ n := by
      rcases Nat.even_or_odd n with he | ho
      · obtain ⟨k, hk⟩ := he
        refine ⟨k, ?_, ?_, ⟨2, by omega⟩⟩
        · rcases Nat.lt_or_ge k 3 with h | h
          · interval_cases k <;> simp_all
          · exact h
        · rintro ⟨j, rfl⟩
          exact h4 ⟨j, by omega⟩
      · exact ⟨n, hn, Nat.not_even_iff_odd.mpr ho, dvd_rfl⟩
    obtain ⟨m, hm3, hmodd, hmn⟩ := hm
    refine ⟨m.minFac, dvd_trans (Nat.minFac_dvd m) hmn, ?_, Or.inl ⟨Nat.minFac_prime (by omega), ?_⟩⟩
    · have hp := Nat.minFac_prime (n := m) (by omega)
      have hodd : ¬ Even m.minFac := by
        intro he
        have : (2 : ℕ) ∣ m := dvd_trans (even_iff_two_dvd.mp he) (Nat.minFac_dvd m)
        exact hmodd (even_iff_two_dvd.mpr this)
      have h2 := hp.two_le
      rcases eq_or_lt_of_le h2 with h | h
      · exact absurd (by rw [← h]; exact even_iff_two_dvd.mpr dvd_rfl) hodd
      · omega
    · intro he
      have : (2 : ℕ) ∣ m := dvd_trans (even_iff_two_dvd.mp he) (Nat.minFac_dvd m)
      exact hmodd (even_iff_two_dvd.mpr this)

/-- Beal's conjecture restricted to exponents that are odd primes or `4`. -/
def BealPrimeExponents : Prop :=
  ∀ A B C x y z : ℕ, IsBealSolution A B C x y z →
    ((x.Prime ∧ ¬ Even x) ∨ x = 4) → ((y.Prime ∧ ¬ Even y) ∨ y = 4) →
    ((z.Prime ∧ ¬ Even z) ∨ z = 4) → HasCommonPrime A B C

/-- **Exponent reduction.**  It suffices to prove Beal's conjecture for exponents that are odd
primes or equal to `4`. -/
theorem beal_of_prime_exponents (h : BealPrimeExponents) : BealConjecture := by
  intro A B C x y z hsol
  obtain ⟨hA, hB, hC, hx, hy, hz, heq⟩ := hsol
  obtain ⟨d, ⟨mx, rfl⟩, hd3, hdspec⟩ := exists_odd_prime_or_four_dvd hx
  obtain ⟨e, ⟨my, rfl⟩, he3, hespec⟩ := exists_odd_prime_or_four_dvd hy
  obtain ⟨f, ⟨mz, rfl⟩, hf3, hfspec⟩ := exists_odd_prime_or_four_dvd hz
  have heq' : (A ^ mx) ^ d + (B ^ my) ^ e = (C ^ mz) ^ f := by
    rw [← pow_mul, ← pow_mul, ← pow_mul, mul_comm mx d, mul_comm my e, mul_comm mz f]
    exact heq
  obtain ⟨p, hp, hpA, hpB, hpC⟩ :=
    h (A ^ mx) (B ^ my) (C ^ mz) d e f
      ⟨pow_pos hA mx, pow_pos hB my, pow_pos hC mz, hd3, he3, hf3, heq'⟩ hdspec hespec hfspec
  exact ⟨p, hp, hp.dvd_of_dvd_pow hpA, hp.dvd_of_dvd_pow hpB, hp.dvd_of_dvd_pow hpC⟩

/-! ## Beal's conjecture as the high-exponent part of Fermat–Catalan -/

/-- **Exact Fermat–Catalan reformulation.**  Beal's conjecture holds if and only if no
Fermat–Catalan solution has all three exponents at least `3`. -/
theorem beal_iff_no_high_exponent_fermatCatalan :
    BealConjecture ↔
      ∀ a b c x y z : ℕ, IsFermatCatalanSolution a b c x y z → ¬ (3 ≤ x ∧ 3 ≤ y ∧ 3 ≤ z) := by
  constructor
  · rintro hB a b c x y z ⟨ha, hb, hc, -, -, -, hab, -, -, -, heq⟩ ⟨hx, hy, hz⟩
    obtain ⟨p, hp, hpa, hpb, -⟩ := hB a b c x y z ⟨ha, hb, hc, hx, hy, hz, heq⟩
    exact hp.one_lt.ne' (Nat.eq_one_of_dvd_coprimes hab hpa hpb)
  · intro h A B C x y z hsol
    by_contra hno
    have hmem : (A, B, C, x, y, z) ∈ FermatCatalanSolutions :=
      beal_counterexamples_subset_fermatCatalan ⟨hsol, hno⟩
    exact h A B C x y z hmem ⟨hsol.2.2.2.1, hsol.2.2.2.2.1, hsol.2.2.2.2.2.1⟩

end Beal