import Mathlib

/-!
# Beal's conjecture: structure theory, and its links to Fermat–Catalan and `abc`

Beal's conjecture asserts that if `A ^ x + B ^ y = C ^ z` with `A, B, C` positive integers
and exponents `x, y, z ≥ 3`, then `A, B, C` have a common prime factor.  The conjecture is
open.  This file develops the surrounding *structure theory* and proves, unconditionally,
a number of statements that pin down exactly where the difficulty lies, together with two
conditional theorems that make the classical folklore links to the Fermat–Catalan
conjecture and to the `abc` conjecture completely precise.

## Main definitions

* `Beal.IsBealSolution A B C x y z` — the Beal equation with positive bases and exponents `≥ 3`.
* `Beal.HasCommonPrime A B C` — the conclusion of Beal's conjecture.
* `Beal.BealConjecture` — the conjecture itself.
* `Beal.rad` — the radical (squarefree kernel) of a natural number.
* `Beal.ABCBound K` — an integral, effective form of the `abc` conjecture with `ε = 1/12`.
* `Beal.ABCConjecture` — the Masser–Oesterlé `abc` conjecture in its usual real form.
* `Beal.IsFermatCatalanSolution` — a Fermat–Catalan solution (coprime, hyperbolic exponents).

## Main results

* `Beal.dvd_third_of_dvd_two_*`: a prime dividing two of `A, B, C` divides the third; hence
  "a common prime factor" can be tested pairwise (`Beal.pairwise_coprime_of_no_common_prime`).
* `Beal.beal_iff_no_coprime_solution`: Beal's conjecture is equivalent to the non-existence of
  a solution with `Nat.Coprime A B` — a single coprimality suffices.
* `Beal.beal_implies_flt`: Beal's conjecture implies Fermat's Last Theorem for every `n ≥ 3`
  (by descent along the common prime factor).
* `Beal.no_solution_of_flt`, `Beal.beal_holds_of_equal_exponents_dvd`: unconditional cases of
  Beal's conjecture coming from Mathlib's `fermatLastTheoremThree` and `fermatLastTheoremFour`.
* `Beal.exponent_sum_lt_one`: **every** Beal solution is strictly hyperbolic,
  `1/x + 1/y + 1/z < 1`; the boundary case `(3,3,3)` is excluded by FLT₃.
* `Beal.beal_counterexamples_subset_fermatCatalan`,
  `Beal.finite_of_fermatCatalan_finite`: the Fermat–Catalan conjecture implies that Beal's
  conjecture has at most finitely many counterexamples.
* `Beal.counterexample_bounded_of_abcBound`: the `abc` conjecture (in the effective integral
  form `ABCBound K`) forces every Beal counterexample to satisfy `C ^ z ≤ K ^ 12`.
* `Beal.abcBound_of_abcConjecture`: the real-analytic `abc` conjecture implies `ABCBound K`
  for some `K`, so the two previous results combine into
  `Beal.abc_implies_beal_counterexamples_bounded`.
-/

namespace Beal

open Finset

/-! ## Basic definitions -/

/-- `A ^ x + B ^ y = C ^ z` with positive bases and all three exponents at least `3`. -/
def IsBealSolution (A B C x y z : ℕ) : Prop :=
  0 < A ∧ 0 < B ∧ 0 < C ∧ 3 ≤ x ∧ 3 ≤ y ∧ 3 ≤ z ∧ A ^ x + B ^ y = C ^ z

/-- `A`, `B`, `C` have a common prime factor. -/
def HasCommonPrime (A B C : ℕ) : Prop := ∃ p : ℕ, p.Prime ∧ p ∣ A ∧ p ∣ B ∧ p ∣ C

/-- **Beal's conjecture**. -/
def BealConjecture : Prop :=
  ∀ A B C x y z : ℕ, IsBealSolution A B C x y z → HasCommonPrime A B C

/-! ## The three-way divisibility collapse -/

/-- A prime dividing `A` and `B` divides `C`. -/
theorem dvd_third_of_dvd_two_ab {p A B C x y z : ℕ} (hp : p.Prime) (hx : 0 < x) (hy : 0 < y)
    (heq : A ^ x + B ^ y = C ^ z) (hA : p ∣ A) (hB : p ∣ B) : p ∣ C := by
  have hCz : p ∣ C ^ z := by
    rw [← heq]
    exact Nat.dvd_add (dvd_pow hA hx.ne') (dvd_pow hB hy.ne')
  exact hp.dvd_of_dvd_pow hCz

/-- A prime dividing `A` and `C` divides `B`. -/
theorem dvd_third_of_dvd_two_ac {p A B C x y z : ℕ} (hp : p.Prime) (hx : 0 < x) (hz : 0 < z)
    (heq : A ^ x + B ^ y = C ^ z) (hA : p ∣ A) (hC : p ∣ C) : p ∣ B := by
  have hBy : p ∣ B ^ y := by
    have : B ^ y = C ^ z - A ^ x := by omega
    rw [this]
    exact Nat.dvd_sub (dvd_pow hC hz.ne') (dvd_pow hA hx.ne')
  exact hp.dvd_of_dvd_pow hBy

/-- A prime dividing `B` and `C` divides `A`. -/
theorem dvd_third_of_dvd_two_bc {p A B C x y z : ℕ} (hp : p.Prime) (hy : 0 < y) (hz : 0 < z)
    (heq : A ^ x + B ^ y = C ^ z) (hB : p ∣ B) (hC : p ∣ C) : p ∣ A := by
  have hAx : p ∣ A ^ x := by
    have : A ^ x = C ^ z - B ^ y := by omega
    rw [this]
    exact Nat.dvd_sub (dvd_pow hC hz.ne') (dvd_pow hB hy.ne')
  exact hp.dvd_of_dvd_pow hAx

/-- If a Beal solution has no common prime factor, then its bases are pairwise coprime. -/
theorem pairwise_coprime_of_no_common_prime {A B C x y z : ℕ}
    (hsol : IsBealSolution A B C x y z) (hno : ¬ HasCommonPrime A B C) :
    Nat.Coprime A B ∧ Nat.Coprime A C ∧ Nat.Coprime B C := by
  obtain ⟨_, _, _, hx, hy, hz, heq⟩ := hsol
  have hx : 0 < x := by omega
  have hy : 0 < y := by omega
  have hz : 0 < z := by omega
  refine ⟨?_, ?_, ?_⟩ <;> by_contra hc <;>
    obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd (n := Nat.gcd _ _) hc
  · exact hno ⟨p, hp, (Nat.dvd_gcd_iff.mp hpd).1, (Nat.dvd_gcd_iff.mp hpd).2,
      dvd_third_of_dvd_two_ab hp hx hy heq (Nat.dvd_gcd_iff.mp hpd).1 (Nat.dvd_gcd_iff.mp hpd).2⟩
  · exact hno ⟨p, hp, (Nat.dvd_gcd_iff.mp hpd).1,
      dvd_third_of_dvd_two_ac hp hx hz heq (Nat.dvd_gcd_iff.mp hpd).1 (Nat.dvd_gcd_iff.mp hpd).2,
      (Nat.dvd_gcd_iff.mp hpd).2⟩
  · exact hno ⟨p, hp,
      dvd_third_of_dvd_two_bc hp hy hz heq (Nat.dvd_gcd_iff.mp hpd).1 (Nat.dvd_gcd_iff.mp hpd).2,
      (Nat.dvd_gcd_iff.mp hpd).1, (Nat.dvd_gcd_iff.mp hpd).2⟩

/-- Beal's conjecture is equivalent to the non-existence of a solution with `A` and `B`
coprime: a single coprimality condition already captures the whole conjecture. -/
theorem beal_iff_no_coprime_solution :
    BealConjecture ↔ ¬ ∃ A B C x y z : ℕ, IsBealSolution A B C x y z ∧ Nat.Coprime A B := by
  constructor
  · rintro hB ⟨A, B, C, x, y, z, hsol, hcop⟩
    obtain ⟨p, hp, hpA, hpB, -⟩ := hB A B C x y z hsol
    exact hp.one_lt.ne' (Nat.eq_one_of_dvd_coprimes hcop hpA hpB)
  · intro h A B C x y z hsol
    by_contra hno
    exact h ⟨A, B, C, x, y, z, hsol, (pairwise_coprime_of_no_common_prime hsol hno).1⟩

/-! ## Unconditional cases coming from Fermat's Last Theorem -/

/-- FLT for the exponent `n` says exactly that there is no Beal solution with all three
exponents equal to `n`. -/
theorem no_solution_of_flt {n : ℕ} (h : FermatLastTheoremFor n) (A B C : ℕ) :
    ¬ IsBealSolution A B C n n n := by
  rintro ⟨hA, hB, hC, -, -, -, heq⟩
  exact h A B C hA.ne' hB.ne' hC.ne' heq

/-- Beal's conjecture holds (vacuously, there being no solutions) for equal exponents
divisible by `3` or by `4`. -/
theorem beal_holds_of_equal_exponents_dvd {n : ℕ} (h : 3 ∣ n ∨ 4 ∣ n) (A B C : ℕ) :
    ¬ IsBealSolution A B C n n n := by
  rcases h with h | h
  · exact no_solution_of_flt (fermatLastTheoremThree.mono h) A B C
  · exact no_solution_of_flt (fermatLastTheoremFour.mono h) A B C

/-! ## Beal implies Fermat's Last Theorem -/

/-- Beal's conjecture implies Fermat's Last Theorem for every exponent `n ≥ 3`, by descent
along the common prime factor. -/
theorem beal_implies_flt (hB : BealConjecture) {n : ℕ} (hn : 3 ≤ n) : FermatLastTheoremFor n := by
  have key : ∀ a b c : ℕ, a ≠ 0 → b ≠ 0 → c ≠ 0 → a ^ n + b ^ n ≠ c ^ n := by
    intro a
    induction a using Nat.strong_induction_on with
    | _ a ih =>
      intro b c ha hb hc heq
      obtain ⟨p, hp, hpa, hpb, hpc⟩ :=
        hB a b c n n n ⟨Nat.pos_of_ne_zero ha, Nat.pos_of_ne_zero hb, Nat.pos_of_ne_zero hc,
          hn, hn, hn, heq⟩
      obtain ⟨a', rfl⟩ := hpa
      obtain ⟨b', rfl⟩ := hpb
      obtain ⟨c', rfl⟩ := hpc
      have hp0 : 0 < p ^ n := pow_pos hp.pos n
      have hdesc : a' ^ n + b' ^ n = c' ^ n := by
        have : p ^ n * (a' ^ n + b' ^ n) = p ^ n * c' ^ n := by
          rw [Nat.mul_add]
          simpa [mul_pow] using heq
        exact Nat.eq_of_mul_eq_mul_left hp0 this
      have ha' : a' ≠ 0 := by rintro rfl; simp at ha
      have hb' : b' ≠ 0 := by rintro rfl; simp at hb
      have hc' : c' ≠ 0 := by rintro rfl; simp at hc
      exact ih a' (by nlinarith [hp.two_le, Nat.pos_of_ne_zero ha']) b' c' ha' hb' hc' hdesc
  exact key

/-! ## Every Beal solution is strictly hyperbolic -/

/-- Every Beal solution satisfies the *quantitative* hyperbolicity bound
`1/x + 1/y + 1/z ≤ 11/12`.  The only exponent triple with `x, y, z ≥ 3` and
`1/x + 1/y + 1/z > 11/12` is `(3,3,3)`, which is ruled out by FLT₃.  The constant `11/12`
is exactly what powers the `abc` argument below. -/
theorem exponent_sum_le_eleven_twelfths {A B C x y z : ℕ} (hsol : IsBealSolution A B C x y z) :
    (1 : ℚ) / x + 1 / y + 1 / z ≤ 11 / 12 := by
  obtain ⟨hA, hB, hC, hx, hy, hz, heq⟩ := hsol
  have h3 : ∀ n : ℕ, 3 ≤ n → (1 : ℚ) / n ≤ 1 / 3 := by
    intro n hn
    apply one_div_le_one_div_of_le (by norm_num)
    exact_mod_cast hn
  have h4 : ∀ n : ℕ, 4 ≤ n → (1 : ℚ) / n ≤ 1 / 4 := by
    intro n hn
    apply one_div_le_one_div_of_le (by norm_num)
    exact_mod_cast hn
  by_cases hx4 : 4 ≤ x
  · linarith [h4 x hx4, h3 y hy, h3 z hz]
  by_cases hy4 : 4 ≤ y
  · linarith [h3 x hx, h4 y hy4, h3 z hz]
  by_cases hz4 : 4 ≤ z
  · linarith [h3 x hx, h3 y hy, h4 z hz4]
  · -- the remaining exponent triple is `(3,3,3)`, excluded by Fermat's Last Theorem for `n = 3`
    exfalso
    obtain rfl : x = 3 := by omega
    obtain rfl : y = 3 := by omega
    obtain rfl : z = 3 := by omega
    exact no_solution_of_flt fermatLastTheoremThree A B C ⟨hA, hB, hC, le_rfl, le_rfl, le_rfl, heq⟩

/-- Every Beal solution is strictly hyperbolic: `1/x + 1/y + 1/z < 1`. -/
theorem exponent_sum_lt_one {A B C x y z : ℕ} (hsol : IsBealSolution A B C x y z) :
    (1 : ℚ) / x + 1 / y + 1 / z < 1 :=
  lt_of_le_of_lt (exponent_sum_le_eleven_twelfths hsol) (by norm_num)

/-! ## The Fermat–Catalan connection -/

/-- A Fermat–Catalan solution: pairwise coprime positive bases, exponents at least `2`,
and hyperbolic exponent triple. -/
def IsFermatCatalanSolution (a b c x y z : ℕ) : Prop :=
  0 < a ∧ 0 < b ∧ 0 < c ∧ 2 ≤ x ∧ 2 ≤ y ∧ 2 ≤ z ∧
    Nat.Coprime a b ∧ Nat.Coprime a c ∧ Nat.Coprime b c ∧
    (1 : ℚ) / x + 1 / y + 1 / z < 1 ∧ a ^ x + b ^ y = c ^ z

/-- The set of counterexamples to Beal's conjecture. -/
def BealCounterexamples : Set (ℕ × ℕ × ℕ × ℕ × ℕ × ℕ) :=
  {t | IsBealSolution t.1 t.2.1 t.2.2.1 t.2.2.2.1 t.2.2.2.2.1 t.2.2.2.2.2 ∧
       ¬ HasCommonPrime t.1 t.2.1 t.2.2.1}

/-- The set of Fermat–Catalan solutions. -/
def FermatCatalanSolutions : Set (ℕ × ℕ × ℕ × ℕ × ℕ × ℕ) :=
  {t | IsFermatCatalanSolution t.1 t.2.1 t.2.2.1 t.2.2.2.1 t.2.2.2.2.1 t.2.2.2.2.2}

theorem beal_counterexamples_subset_fermatCatalan :
    BealCounterexamples ⊆ FermatCatalanSolutions := by
  rintro ⟨A, B, C, x, y, z⟩ ⟨hsol, hno⟩
  obtain ⟨hab, hac, hbc⟩ := pairwise_coprime_of_no_common_prime hsol hno
  have hhyp := exponent_sum_lt_one hsol
  obtain ⟨hA, hB, hC, hx, hy, hz, heq⟩ := hsol
  exact ⟨hA, hB, hC, by omega, by omega, by omega, hab, hac, hbc, hhyp, heq⟩

/-- The Fermat–Catalan conjecture (finiteness of the solution set) implies that Beal's
conjecture has at most finitely many counterexamples. -/
theorem finite_of_fermatCatalan_finite (h : FermatCatalanSolutions.Finite) :
    BealCounterexamples.Finite :=
  h.subset beal_counterexamples_subset_fermatCatalan

/-! ## The `abc` connection -/

/-- The radical (squarefree kernel) of a natural number. -/
def rad (n : ℕ) : ℕ := ∏ p ∈ n.primeFactors, p

theorem rad_pos {n : ℕ} : 0 < rad n :=
  Finset.prod_pos fun _ hp => (Nat.prime_of_mem_primeFactors hp).pos

theorem rad_dvd_self (n : ℕ) : rad n ∣ n := Nat.prod_primeFactors_dvd n

/-- The radical only sees the prime support, so it is insensitive to exponents. -/
theorem rad_pow_mul_pow_mul_pow {A B C x y z : ℕ} (hA : 0 < A) (hB : 0 < B) (hC : 0 < C)
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    rad (A ^ x * B ^ y * C ^ z) = rad (A * B * C) := by
  have hA' : A ≠ 0 := hA.ne'
  have hB' : B ≠ 0 := hB.ne'
  have hC' : C ≠ 0 := hC.ne'
  unfold rad
  congr 1
  rw [Nat.primeFactors_mul (by positivity) (by positivity),
    Nat.primeFactors_mul (by positivity) (by positivity),
    Nat.primeFactors_mul (mul_ne_zero hA' hB') hC', Nat.primeFactors_mul hA' hB',
    Nat.primeFactors_pow _ hx.ne', Nat.primeFactors_pow _ hy.ne', Nat.primeFactors_pow _ hz.ne']

/-- An integral, effective version of the `abc` conjecture with `ε = 1/12`:
`c ^ 12 ≤ K * rad (a b c) ^ 13` for all coprime triples `a + b = c`. -/
def ABCBound (K : ℕ) : Prop :=
  ∀ a b c : ℕ, 0 < a → 0 < b → a + b = c → Nat.Coprime a b →
    c ^ 12 ≤ K * rad (a * b * c) ^ 13

/-- The Masser–Oesterlé `abc` conjecture. -/
def ABCConjecture : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ K : ℝ, 0 < K ∧ ∀ a b c : ℕ, 0 < a → 0 < b → a + b = c →
    Nat.Coprime a b → (c : ℝ) ≤ K * (rad (a * b * c) : ℝ) ^ (1 + ε)

/-- Key exponent-counting step: for a Beal solution the product of the bases is small
compared with `N = C ^ z`, namely `(A B C) ^ 12 ≤ N ^ 11`.  This is where the hypothesis
`x, y, z ≥ 3` (plus FLT₃ to exclude `(3,3,3)`) is used. -/
theorem prod_bases_pow_le {A B C x y z : ℕ} (hsol : IsBealSolution A B C x y z) :
    (A * B * C) ^ 12 ≤ (C ^ z) ^ 11 := by
  obtain ⟨hA, hB, hC, hx, hy, hz, heq⟩ := hsol
  set N := C ^ z with hN
  have hAxN : A ^ x ≤ N := by have : 0 < B ^ y := pow_pos hB y; omega
  have hByN : B ^ y ≤ N := by have : 0 < A ^ x := pow_pos hA x; omega
  have hmono : ∀ (a m n : ℕ), 0 < a → m ≤ n → a ^ m ≤ a ^ n := fun a m n ha h =>
    Nat.pow_le_pow_right ha h
  have hA3 : A ^ 3 ≤ N := le_trans (hmono A 3 x hA hx) hAxN
  have hB3 : B ^ 3 ≤ N := le_trans (hmono B 3 y hB hy) hByN
  have hC3 : C ^ 3 ≤ N := le_trans (hmono C 3 z hC hz) le_rfl
  by_cases hx4 : 4 ≤ x
  · have hA4 : A ^ 4 ≤ N := le_trans (hmono A 4 x hA hx4) hAxN
    calc (A * B * C) ^ 12 = (A ^ 4) ^ 3 * (B ^ 3) ^ 4 * (C ^ 3) ^ 4 := by ring
      _ ≤ N ^ 3 * N ^ 4 * N ^ 4 := by gcongr
      _ = N ^ 11 := by ring
  by_cases hy4 : 4 ≤ y
  · have hB4 : B ^ 4 ≤ N := le_trans (hmono B 4 y hB hy4) hByN
    calc (A * B * C) ^ 12 = (A ^ 3) ^ 4 * (B ^ 4) ^ 3 * (C ^ 3) ^ 4 := by ring
      _ ≤ N ^ 4 * N ^ 3 * N ^ 4 := by gcongr
      _ = N ^ 11 := by ring
  by_cases hz4 : 4 ≤ z
  · have hC4 : C ^ 4 ≤ N := hmono C 4 z hC hz4
    calc (A * B * C) ^ 12 = (A ^ 3) ^ 4 * (B ^ 3) ^ 4 * (C ^ 4) ^ 3 := by ring
      _ ≤ N ^ 4 * N ^ 4 * N ^ 3 := by gcongr
      _ = N ^ 11 := by ring
  · exfalso
    obtain rfl : x = 3 := by omega
    obtain rfl : y = 3 := by omega
    obtain rfl : z = 3 := by omega
    exact no_solution_of_flt fermatLastTheoremThree A B C ⟨hA, hB, hC, le_rfl, le_rfl, le_rfl, heq⟩

/-- **`abc` bounds Beal counterexamples.**  If the effective `abc` bound holds with constant
`K`, then any counterexample to Beal's conjecture satisfies `C ^ z ≤ K ^ 12`. -/
theorem counterexample_bounded_of_abcBound {K A B C x y z : ℕ} (habc : ABCBound K)
    (hsol : IsBealSolution A B C x y z) (hno : ¬ HasCommonPrime A B C) :
    C ^ z ≤ K ^ 12 := by
  have hprod := prod_bases_pow_le hsol
  obtain ⟨hab, -, -⟩ := pairwise_coprime_of_no_common_prime hsol hno
  obtain ⟨hA, hB, hC, hx, hy, hz, heq⟩ := hsol
  have hx : 0 < x := by omega
  have hy : 0 < y := by omega
  have hz : 0 < z := by omega
  set N := C ^ z with hN
  have hNpos : 0 < N := pow_pos hC z
  -- apply the `abc` bound to the coprime triple `A ^ x + B ^ y = C ^ z`
  have habc' := habc (A ^ x) (B ^ y) N (pow_pos hA x) (pow_pos hB y) heq (hab.pow x y)
  -- the radical of `A ^ x B ^ y C ^ z` is the radical of `A B C`, hence at most `A B C`
  have hrad : rad (A ^ x * B ^ y * N) ≤ A * B * C := by
    rw [hN, rad_pow_mul_pow_mul_pow hA hB hC hx hy hz]
    exact Nat.le_of_dvd (by positivity) (rad_dvd_self _)
  have hstep : N ^ 12 ≤ K * (A * B * C) ^ 13 :=
    le_trans habc' (Nat.mul_le_mul_left K (Nat.pow_le_pow_left hrad 13))
  -- raise to the 12th power and feed in the exponent count `(A B C) ^ 12 ≤ N ^ 11`
  have h144 : N ^ 144 ≤ K ^ 12 * N ^ 143 := by
    calc N ^ 144 = (N ^ 12) ^ 12 := by ring
      _ ≤ (K * (A * B * C) ^ 13) ^ 12 := Nat.pow_le_pow_left hstep 12
      _ = K ^ 12 * ((A * B * C) ^ 12) ^ 13 := by ring
      _ ≤ K ^ 12 * (N ^ 11) ^ 13 := by gcongr
      _ = K ^ 12 * N ^ 143 := by ring
  have : N * N ^ 143 ≤ K ^ 12 * N ^ 143 := by
    calc N * N ^ 143 = N ^ 144 := by ring
      _ ≤ K ^ 12 * N ^ 143 := h144
  exact Nat.le_of_mul_le_mul_right this (pow_pos hNpos 143)

/-- The real-analytic `abc` conjecture implies the integral bound `ABCBound K`. -/
theorem abcBound_of_abcConjecture (h : ABCConjecture) : ∃ K : ℕ, 0 < K ∧ ABCBound K := by
  obtain ⟨K, -, hKb⟩ := h (1 / 12) (by norm_num)
  refine ⟨⌈K ^ 12⌉₊ + 1, Nat.succ_pos _, ?_⟩
  intro a b c ha hb hsum hcop
  set r := rad (a * b * c) with hrdef
  have h1 : (c : ℝ) ≤ K * (r : ℝ) ^ (1 + (1 / 12 : ℝ)) := hKb a b c ha hb hsum hcop
  have hrR : (1 : ℝ) ≤ (r : ℝ) := by exact_mod_cast rad_pos (n := a * b * c)
  have key : (c : ℝ) ^ 12 ≤ K ^ 12 * (r : ℝ) ^ 13 := by
    have h2 : (c : ℝ) ^ 12 ≤ (K * (r : ℝ) ^ (1 + (1 / 12 : ℝ))) ^ 12 := by gcongr
    refine h2.trans_eq ?_
    rw [mul_pow, ← Real.rpow_natCast ((r : ℝ) ^ ((1 : ℝ) + 1 / 12)) 12,
      ← Real.rpow_mul (by positivity)]
    norm_num
  have hceil : K ^ 12 ≤ ((⌈K ^ 12⌉₊ + 1 : ℕ) : ℝ) := by
    push_cast
    linarith [Nat.le_ceil (K ^ 12)]
  have hfin : (c : ℝ) ^ 12 ≤ ((⌈K ^ 12⌉₊ + 1 : ℕ) : ℝ) * (r : ℝ) ^ 13 := by
    refine key.trans ?_
    gcongr
  exact_mod_cast hfin

/-- **The `abc` conjecture implies that Beal's conjecture has only bounded counterexamples.** -/
theorem abc_implies_beal_counterexamples_bounded (h : ABCConjecture) :
    ∃ M : ℕ, ∀ A B C x y z : ℕ, IsBealSolution A B C x y z → ¬ HasCommonPrime A B C →
      A ^ x ≤ M ∧ B ^ y ≤ M ∧ C ^ z ≤ M := by
  obtain ⟨K, -, hK⟩ := abcBound_of_abcConjecture h
  refine ⟨K ^ 12, fun A B C x y z hsol hno => ?_⟩
  have hbound := counterexample_bounded_of_abcBound hK hsol hno
  obtain ⟨hA, hB, hC, -, -, -, heq⟩ := hsol
  have h1 : 0 < A ^ x := pow_pos hA x
  have h2 : 0 < B ^ y := pow_pos hB y
  exact ⟨by omega, by omega, hbound⟩

/-- **The `abc` conjecture also bounds the exponents** of a Beal counterexample whose two
summand bases are at least `2`: the whole `6`-tuple then lies in an explicit finite box. -/
theorem abc_implies_beal_exponents_bounded (h : ABCConjecture) :
    ∃ M : ℕ, ∀ A B C x y z : ℕ, IsBealSolution A B C x y z → ¬ HasCommonPrime A B C →
      2 ≤ A → 2 ≤ B → A ≤ M ∧ B ≤ M ∧ C ≤ M ∧ x ≤ M ∧ y ≤ M ∧ z ≤ M := by
  obtain ⟨M, hM⟩ := abc_implies_beal_counterexamples_bounded h
  refine ⟨M, fun A B C x y z hsol hno hA2 hB2 => ?_⟩
  obtain ⟨hAx, hBy, hCz⟩ := hM A B C x y z hsol hno
  obtain ⟨hA, hB, hC, hx, hy, hz, heq⟩ := hsol
  -- `C ≥ 2` since `C ^ z = A ^ x + B ^ y ≥ 16`
  have hC2 : 2 ≤ C := by
    by_contra hlt
    obtain rfl : C = 1 := by omega
    have h1 : 2 ^ 3 ≤ A ^ x :=
      le_trans (Nat.pow_le_pow_left hA2 3) (Nat.pow_le_pow_right (by omega) hx)
    have h2 : 2 ^ 3 ≤ B ^ y :=
      le_trans (Nat.pow_le_pow_left hB2 3) (Nat.pow_le_pow_right (by omega) hy)
    simp only [one_pow] at heq
    omega
  -- a base is at most its own power, and an exponent is smaller than `2` to that exponent
  have hbase : ∀ a e : ℕ, 2 ≤ a → 3 ≤ e → a ^ e ≤ M → a ≤ M ∧ e ≤ M := by
    intro a e ha he hae
    have h2e : 2 ^ e ≤ a ^ e := Nat.pow_le_pow_left ha e
    have hlt : e < 2 ^ e := Nat.lt_two_pow_self
    have hself : a ≤ a ^ e := Nat.le_self_pow (by omega) a
    exact ⟨le_trans hself hae, by omega⟩
  obtain ⟨hA', hx'⟩ := hbase A x hA2 hx hAx
  obtain ⟨hB', hy'⟩ := hbase B y hB2 hy hBy
  obtain ⟨hC', hz'⟩ := hbase C z hC2 hz hCz
  exact ⟨hA', hB', hC', hx', hy', hz'⟩

end Beal