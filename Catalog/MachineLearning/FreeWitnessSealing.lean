import MachineLearning.FreeWitnessSigmaK

/-!
# Cycle 3: the sealing question — how much of a witness is a function of `N` alone

§5 of `16_FreeWitness_Classification.md` proposes a proof direction for barrier 4:
*find `N₁ ≡ N₂ (mod 2^k)` with `C(N₁) ≢ C(N₂) (mod 2^k)`; since `p, q mod 2^k` are
underdetermined by `N mod 2^k`, such a pair would prove that no formula in the residues
of `N` exists.*

The computations behind this file show that the situation is more delicate than the
paper assumes, and both halves are proved here.

**Negative result (the truncation leaks nothing, up to 6 bits).**
`sigma_even_two_adic`: for *every* even exponent `2j` and all distinct odd primes,
`σ_{2j}(N) ≡ 2 + 2 N^{2j} (mod 64)`.
So the low 6 bits of the SIGK witness are an explicit polynomial in `N`: no separating
pair `N₁ ≡ N₂ (mod 2^k)` exists for any `k ≤ 6`.  The reason is 2-adic:
`8 ∣ p² - 1` for odd `p`, hence `64 ∣ (p^{2j} - 1)(q^{2j} - 1)`, and
`σ_k(N) = 2 + 2N^k - (p^k - 1)(q^k - 1)` identically.  A search over all semiprimes with
both prime factors below 300 finds no separating pair at `2^6`, matching the theorem.

**Positive result (7 bits do separate, and the separation is unconditional).**
`sigma_two_no_mod_formula`: at `2^7 = 128` the separation the paper asks for exists —
`15 = 3·5` and `527 = 17·31` satisfy `527 ≡ 15 (mod 128)` while
`σ₂(527) ≡ 68` and `σ₂(15) ≡ 4 (mod 128)`.  Hence **no function whatsoever** of
`N mod 128` — polynomial or not — computes `σ₂(N) mod 128` on odd semiprimes.  This is
strictly stronger than the polynomial barrier of `FreeWitnessClassification.lean`.
The same pair separates the modular circle count already at `2^5 = 32`
(`circleCount_no_mod_formula`), so CIRC is 2-adically *less* sealed than SIGK.

**Sharpness of the classification hypothesis.**
`sigma_zero_is_polynomial`: at `k = 0` the witness degenerates — `σ₀(pq) = 4` is
constant, hence a polynomial in `N` carrying no factor information at all.  So the
hypothesis `k ≥ 1` in `FreeWitness.classification_of_powerWeight` cannot be dropped.
-/

namespace FreeWitness

open ArithmeticFunction

/-! ## The 2-adic identity -/

/-- `8 ∣ p² - 1` for odd `p`. -/
lemma eight_dvd_sq_sub_one {p : ℕ} (hp : Odd p) : (8 : ℤ) ∣ (p : ℤ) ^ 2 - 1 := by
  obtain ⟨m, rfl⟩ := hp
  have hm : (2 : ℤ) ∣ (m : ℤ) * (m + 1) := by
    rcases Int.even_or_odd (m : ℤ) with ⟨t, ht⟩ | ⟨t, ht⟩
    · exact ⟨t * (m + 1), by rw [ht]; ring⟩
    · exact ⟨(2 * t + 1) * (t + 1), by rw [ht]; ring⟩
  obtain ⟨t, ht⟩ := hm
  refine ⟨t, ?_⟩
  push_cast
  nlinarith [ht]

/-- `8 ∣ p^{2j} - 1` for odd `p`: the even powers inherit the 2-adic divisibility of the
square (the case `j = 0` being trivial). -/
lemma eight_dvd_even_pow_sub_one {p : ℕ} (hp : Odd p) (j : ℕ) :
    (8 : ℤ) ∣ (p : ℤ) ^ (2 * j) - 1 := by
  have hdvd : ((p : ℤ) ^ 2 - 1) ∣ ((p : ℤ) ^ 2) ^ j - 1 ^ j := sub_dvd_pow_sub_pow _ _ j
  have h1 : ((p : ℤ) ^ 2) ^ j = (p : ℤ) ^ (2 * j) := by rw [← pow_mul]
  rw [h1, one_pow] at hdvd
  exact (eight_dvd_sq_sub_one hp).trans hdvd

/-- The exact identity behind all 2-adic statements:
`σ_k(pq) = 2 + 2 N^k - (p^k - 1)(q^k - 1)`. -/
lemma sigma_semiprime_shift {k p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    ((sigma k (p * q) : ℕ) : ℤ)
      = 2 + 2 * ((p : ℤ) * q) ^ k - ((p : ℤ) ^ k - 1) * ((q : ℤ) ^ k - 1) := by
  rw [sigma_semiprime hp hq hpq]
  push_cast
  ring

/-- **The truncation leaks nothing below 64.**  For every even exponent `2j` and all
distinct odd primes, `σ_{2j}(N) ≡ 2 + 2 N^{2j} (mod 64)` — the low six bits of the
witness are an explicit polynomial in `N`, so no `2^k`-separation with `k ≤ 6` can
exist. -/
theorem sigma_even_two_adic {j p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    (64 : ℤ) ∣ ((sigma (2 * j) (p * q) : ℕ) : ℤ) - (2 + 2 * ((p : ℤ) * q) ^ (2 * j)) := by
  have hpodd : Odd p := hp.odd_of_ne_two hp2
  have hqodd : Odd q := hq.odd_of_ne_two hq2
  obtain ⟨a, ha⟩ := eight_dvd_even_pow_sub_one hpodd j
  obtain ⟨b, hb⟩ := eight_dvd_even_pow_sub_one hqodd j
  refine ⟨-(a * b), ?_⟩
  rw [sigma_semiprime_shift hp hq hpq, ha, hb]
  ring

/-- The case `k = 2`: `σ₂(N) ≡ 2 + 2N² (mod 64)` for odd semiprimes. -/
theorem sigma_two_mod_64 {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    (64 : ℤ) ∣ ((sigma 2 (p * q) : ℕ) : ℤ) - (2 + 2 * ((p : ℤ) * q) ^ 2) := by
  have := sigma_even_two_adic (j := 1) hp hq hp2 hq2 hpq
  simpa using this

/-! ## The separation at `2^7`, and for CIRC already at `2^5` -/

/-- **No function of `N mod 128` computes `σ₂(N) mod 128`.**  The pair
`15 = 3·5`, `527 = 17·31` has `527 ≡ 15 (mod 128)` but `σ₂` values `4` and `68` mod
`128`.  This is the separation asked for in §5 of the paper, in its strongest form: the
obstruction is not merely to polynomial formulas but to *any* formula in the residue of
the modulus. -/
theorem sigma_two_no_mod_formula :
    ∀ g : ℕ → ℕ, ¬ (∀ p q : ℕ, p.Prime → q.Prime → p ≠ 2 → q ≠ 2 → p ≠ q →
      sigma 2 (p * q) % 128 = g ((p * q) % 128)) := by
  intro g hg
  have h1 := hg 3 5 (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h2 := hg 17 31 (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  rw [sigma_semiprime (by norm_num) (by norm_num) (by norm_num)] at h1
  rw [sigma_semiprime (by norm_num) (by norm_num) (by norm_num)] at h2
  norm_num at h1 h2
  omega

/-- **The circle count is even less sealed: no function of `N mod 32` computes
`C(N) mod 32`.**  Same pair: `C(15) = 16`, `C(527) = 16 · 32 = 512`, and
`527 ≡ 15 (mod 32)`. -/
theorem circleCount_no_mod_formula :
    ∀ g : ℕ → ℕ, ¬ (∀ p q : ℕ, p.Prime → q.Prime → p ≠ 2 → q ≠ 2 → p ≠ q →
      HalfPlane.circleCount (p * q) % 32 = g ((p * q) % 32)) := by
  intro g hg
  have h1 := hg 3 5 (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h2 := hg 17 31 (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  rw [HalfPlane.circleCount_semiprime (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num)] at h1
  rw [HalfPlane.circleCount_semiprime (by norm_num) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num)] at h2
  norm_num at h1 h2
  omega

/-! ## Sharpness of the classification hypothesis `k ≥ 1` -/

/-- At `k = 0` the divisor power sum degenerates to the divisor *count*, which is the
constant `4` on semiprimes. -/
theorem sigma_zero_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    sigma 0 (p * q) = 4 := by
  rw [sigma_semiprime hp hq hpq]
  norm_num

/-- **`k ≥ 1` is necessary in the classification.**  The `k = 0` witness *is* a
polynomial in `N` (the constant `4`), so it is not a free witness: it carries no factor
information.  The non-polynomiality theorem therefore fails exactly at the degenerate
exponent. -/
theorem sigma_zero_is_polynomial :
    ∃ P : Polynomial ℤ, ∀ p q : ℕ, p.Prime → q.Prime → p ≠ q →
      ((sigma 0 (p * q) : ℕ) : ℤ) = P.eval ((p : ℤ) * q) := by
  refine ⟨Polynomial.C 4, ?_⟩
  intro p q hp hq hpq
  rw [sigma_zero_semiprime hp hq hpq]
  simp

/-! ### Lab notes (cycle 3)

2-adic sealing experiment.  For all semiprimes `N = pq` with `3 ≤ p < q < 300`
(about 3·10⁵ pairs) we searched for `N₁ ≡ N₂ (mod 2^k)` with witness values
incongruent mod `2^k`:

```
modulus 2^k :   8    16    32    64    128    256
sigma_2      : none  none  none  none  FOUND  FOUND    (15 = 3·5 vs 527 = 17·31)
circleCount  : none  none  FOUND FOUND FOUND  FOUND    (same pair)
```
`σ₂(15) = 260 ≡ 4`, `σ₂(527) = 278980 ≡ 68 (mod 128)`; `C(15) = 16`, `C(527) = 512`,
so `C(527) ≡ 0` and `C(15) ≡ 16 (mod 32)`.
The "none" entries are explained by the theorem `sigma_even_two_adic`
(`σ_{2j} ≡ 2 + 2N^{2j} mod 64`), so they are not an artefact of the search range.
-/

example : sigma 2 15 = 260 := by decide

example : (278980 : ℕ) % 128 = 68 ∧ (260 : ℕ) % 128 = 4 := by norm_num

end FreeWitness