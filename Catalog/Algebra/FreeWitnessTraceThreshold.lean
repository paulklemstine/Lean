/-
# The Partial Free-Witness Threshold for Semiprimes

Let `N = p * q` be a semiprime (`p ≠ q` primes) and let

  `σ_k(N) = ∑_{d ∣ N} d ^ k = (1 + p^k) * (1 + q^k)`

be the *free witness* of order `k`.  The classical observation is that `σ₂(N)`
determines the factorisation of `N`: from `σ₂(N)` one reads off the **trace**
`t = p + q` via `t² = σ₂(N) + 2N − N² − 1`, and then `p, q` are the two roots of
`x² − t x + N`.

The question addressed here is *how much* of the witness is needed: if only
`σ_k(N) mod m` is available, for which moduli `m` is the factorisation still
determined uniquely?

Main results:

* `sigma_semiprime` : `σ k (p*q) = (1 + p^k)(1 + q^k)`.
* `trace_sq_identity`, `traceOf_eq`, `recover_factors` : the exact (`k = 2`)
  recovery algorithm, proved correct.
* `sum_prod_determines` : sum and product determine an unordered pair.
* `witness_sub_trivial` : the *only* obstruction to modular uniqueness is the
  trivial factorisation, and its witness gap is exactly `(p^k − 1)(q^k − 1)`.
* `sigma_mod_determines_iff` : **sharp threshold theorem** — `σ_k(N) mod m`
  determines the factorisation of `N = pq` **iff** `m ∤ (p^k − 1)(q^k − 1)`.
* `threshold_below_trace`, `constant_modulus_suffices_infinitely_often` :
  the threshold is *not* of order `p + q`; a constant modulus (`m = 7`) suffices
  for infinitely many semiprimes with `p, q` arbitrarily large (via Dirichlet).
  This refutes the conjectured `m* = 5 (p+q)` law.
* `not_determines_of_lt_five`, `five_determines_iff`, `least_modulus_eq_five` :
  the matching lower bound `m* ≥ 5` (from `24 ∣ p² − 1`) and the exact
  characterisation of the semiprimes with `m* = 5`.
* `determines_one_iff_not_dvd_totient` : at order 1 the obstruction is exactly
  Euler's totient `φ(N)` — the RSA trapdoor.
* `exists_prime_determines`, `exists_prime_determines_of_card_gt`,
  `card_primeFactors_gap_le_log` : counting bounds — only `O(log N)` candidate
  prime moduli ever need to be tried.
* `witness_modEq_iff_dvd_powsum_diff` : the separation principle for arbitrary
  `N`, unifying all of the above.
* `witness_injective_pow`, `witness_char_poly` : rigidity of the full witness at
  every order, and the recovered characteristic polynomial.
-/

import Mathlib

open ArithmeticFunction
open scoped ArithmeticFunction.sigma

namespace FreeWitness

/-! ## The witness of a candidate factorisation -/

/-- The order-`k` witness attached to a candidate factorisation `N = a * b`,
namely the value `σ_k` would take if `a` and `b` were distinct primes. -/
def sigmaWitness (k a b : ℕ) : ℕ := (1 + a ^ k) * (1 + b ^ k)

/-- For a semiprime `N = p * q` the divisor power sum is the witness of the
prime factorisation. -/
theorem sigma_semiprime (k : ℕ) {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    σ k (p * q) = sigmaWitness k p q := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have h := (isMultiplicative_sigma (k := k)).map_mul_of_coprime hcop
  have hp' : σ k p = 1 + p ^ k := by
    rw [sigma_apply, hp.divisors, Finset.sum_pair hp.one_lt.ne]
    simp
  have hq' : σ k q = 1 + q ^ k := by
    rw [sigma_apply, hq.divisors, Finset.sum_pair hq.one_lt.ne]
    simp
  rw [h, hp', hq', sigmaWitness]

/-! ## Factor pairs of a semiprime -/

/-- The only factorisations of a semiprime are the trivial one and the prime one. -/
theorem factor_pairs {p q a b : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hab : a * b = p * q) :
    (a = 1 ∧ b = p * q) ∨ (a = p ∧ b = q) ∨ (a = q ∧ b = p) ∨ (a = p * q ∧ b = 1) := by
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  have hadvd : a ∣ p * q := ⟨b, hab.symm⟩
  have ha0 : 0 < a := by
    rcases Nat.eq_zero_or_pos a with rfl | h
    · rw [zero_mul] at hab
      exact absurd hab.symm (Nat.mul_pos hp0 hq0).ne'
    · exact h
  by_cases hpa : p ∣ a
  · obtain ⟨c, rfl⟩ := hpa
    have hcb : c * b = q := by
      refine Nat.eq_of_mul_eq_mul_left hp0 ?_
      rw [← mul_assoc]
      exact hab
    rcases hq.eq_one_or_self_of_dvd c ⟨b, hcb.symm⟩ with rfl | rfl
    · right; left
      refine ⟨by ring, ?_⟩
      rw [one_mul] at hcb
      exact hcb
    · right; right; right
      have hb1 : b = 1 := by
        refine Nat.eq_of_mul_eq_mul_left hq0 ?_
        rw [mul_one]
        exact hcb
      exact ⟨rfl, hb1⟩
  · have hcop : Nat.Coprime p a := (Nat.Prime.coprime_iff_not_dvd hp).mpr hpa
    have hdq : a ∣ q := Nat.Coprime.dvd_of_dvd_mul_left hcop.symm hadvd
    rcases hq.eq_one_or_self_of_dvd a hdq with rfl | rfl
    · left
      refine ⟨rfl, ?_⟩
      rw [one_mul] at hab
      exact hab
    · right; right; left
      refine ⟨rfl, ?_⟩
      refine Nat.eq_of_mul_eq_mul_left ha0 ?_
      rw [hab]
      ring

/-! ## Sum and product determine an unordered pair -/

/-- Two naturals are determined, up to order, by their sum and their product:
they are the two roots of `x² − (a+b) x + ab`. -/
theorem sum_prod_determines {a b c d : ℕ} (hprod : a * b = c * d) (hsum : a + b = c + d) :
    (a = c ∧ b = d) ∨ (a = d ∧ b = c) := by
  have h1 : (a : ℤ) * b = (c : ℤ) * d := by exact_mod_cast hprod
  have h2 : (a : ℤ) + b = (c : ℤ) + d := by exact_mod_cast hsum
  have key : ((a : ℤ) - c) * ((a : ℤ) - d) = 0 := by nlinarith [h1, h2]
  rcases mul_eq_zero.mp key with h | h
  · have hac : a = c := by exact_mod_cast sub_eq_zero.mp h
    exact Or.inl ⟨hac, by omega⟩
  · have had : a = d := by exact_mod_cast sub_eq_zero.mp h
    exact Or.inr ⟨had, by omega⟩

/-! ## Exact recovery from the full witness (`k = 2`) -/

/-- The trace identity: `σ₂(N) + 2N = (p+q)² + N² + 1`. -/
theorem trace_sq_identity {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    σ 2 (p * q) + 2 * (p * q) = (p + q) ^ 2 + (p * q) ^ 2 + 1 := by
  rw [sigma_semiprime 2 hp hq hpq, sigmaWitness]
  ring

/-- The trace extracted from the witness `w = σ₂(N)`. -/
def traceOf (N w : ℕ) : ℕ := Nat.sqrt (w + 2 * N - N ^ 2 - 1)

/-- The extracted trace is indeed `p + q`. -/
theorem traceOf_eq {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    traceOf (p * q) (σ 2 (p * q)) = p + q := by
  have h := trace_sq_identity hp hq hpq
  have hkey : σ 2 (p * q) + 2 * (p * q) - (p * q) ^ 2 - 1 = (p + q) ^ 2 := by
    rw [h]
    omega
  unfold traceOf
  rw [hkey, Nat.sqrt_eq']

/-- Full recovery: from `N` and `σ₂(N)` the two prime factors are computed by
the classical quadratic formula `p, q = (t ± √(t² − 4N)) / 2`. -/
theorem recover_factors {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    let t := traceOf (p * q) (σ 2 (p * q))
    let d := Nat.sqrt (t ^ 2 - 4 * (p * q))
    (t - d) / 2 = p ∧ (t + d) / 2 = q := by
  intro t d
  have ht : t = p + q := traceOf_eq hp hq (by omega)
  have hle : p ≤ q := hlt.le
  have key : (p + q) ^ 2 = (q - p) ^ 2 + 4 * (p * q) := by
    zify [hle]
    ring
  have hd : d = q - p := by
    have h : t ^ 2 - 4 * (p * q) = (q - p) ^ 2 := by
      rw [ht, key, Nat.add_sub_cancel]
    simp only [d, h, Nat.sqrt_eq']
  constructor <;> omega

/-! ## The modular threshold -/

/-- The witness gap between the trivial factorisation `N = 1 · N` and the prime
factorisation is exactly `(p^k − 1)(q^k − 1)`. -/
theorem witness_sub_trivial (k p q : ℕ) :
    (sigmaWitness k 1 (p * q) : ℤ) - (sigmaWitness k p q : ℤ)
      = ((p : ℤ) ^ k - 1) * ((q : ℤ) ^ k - 1) := by
  simp only [sigmaWitness]
  push_cast
  rw [mul_pow]
  ring

private theorem gap_dvd_of_modEq {k m p q : ℕ}
    (hcong : Nat.ModEq m (sigmaWitness k 1 (p * q)) (sigmaWitness k p q)) :
    (m : ℤ) ∣ ((p : ℤ) ^ k - 1) * ((q : ℤ) ^ k - 1) := by
  have h : (m : ℤ) ∣ (sigmaWitness k p q : ℤ) - (sigmaWitness k 1 (p * q) : ℤ) :=
    (Nat.modEq_iff_dvd).mp hcong
  have h2 : (m : ℤ) ∣ (sigmaWitness k 1 (p * q) : ℤ) - (sigmaWitness k p q : ℤ) := by
    simpa [neg_sub] using (dvd_neg.mpr h)
  rwa [witness_sub_trivial] at h2

private theorem modEq_of_gap_dvd {k m p q : ℕ}
    (hdvd : (m : ℤ) ∣ ((p : ℤ) ^ k - 1) * ((q : ℤ) ^ k - 1)) :
    Nat.ModEq m (sigmaWitness k 1 (p * q)) (sigmaWitness k p q) := by
  have h2 : (m : ℤ) ∣ (sigmaWitness k 1 (p * q) : ℤ) - (sigmaWitness k p q : ℤ) := by
    rw [witness_sub_trivial]; exact hdvd
  refine (Nat.modEq_iff_dvd).mpr ?_
  simpa [neg_sub] using (dvd_neg.mpr h2)

/-- **Sharp threshold theorem.**  For a semiprime `N = p q`, the residue
`σ_k(N) mod m` determines the factorisation of `N` **iff** `m` does not divide
`(p^k − 1)(q^k − 1)`.  (Left-hand side: no candidate factorisation `N = a b`
other than the prime one produces the same witness residue.) -/
theorem sigma_mod_determines_iff (k m : ℕ) {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    (∀ a b : ℕ, a * b = p * q →
        Nat.ModEq m (sigmaWitness k a b) (sigmaWitness k p q) →
        (a = p ∧ b = q) ∨ (a = q ∧ b = p))
      ↔ ¬ ((m : ℤ) ∣ ((p : ℤ) ^ k - 1) * ((q : ℤ) ^ k - 1)) := by
  have hp1 : 1 < p := hp.one_lt
  have hq1 : 1 < q := hq.one_lt
  constructor
  · intro H hdvd
    rcases H 1 (p * q) (by ring) (modEq_of_gap_dvd hdvd) with ⟨h1, _⟩ | ⟨h1, _⟩ <;> omega
  · intro hnd a b hab hcong
    rcases factor_pairs hp hq hab with ⟨rfl, rfl⟩ | h | h | ⟨rfl, rfl⟩
    · exact absurd (gap_dvd_of_modEq hcong) hnd
    · exact Or.inl h
    · exact Or.inr h
    · refine absurd (gap_dvd_of_modEq (k := k) (m := m) (p := p) (q := q) ?_) hnd
      have hsymm : sigmaWitness k (p * q) 1 = sigmaWitness k 1 (p * q) := by
        simp [sigmaWitness, mul_comm]
      rwa [hsymm] at hcong

/-! ## Refutation of the `m* = Θ(p+q)` law -/

/-- An explicit semiprime for which a modulus far below the trace already
determines the factorisation: `N = 11 · 17 = 187`, `m = 7 < p + q = 28`,
while the conjectured threshold would be `5 (p+q) = 140`. -/
theorem threshold_below_trace :
    ∀ a b : ℕ, a * b = 11 * 17 →
      Nat.ModEq 7 (sigmaWitness 2 a b) (sigmaWitness 2 11 17) →
      (a = 11 ∧ b = 17) ∨ (a = 17 ∧ b = 11) := by
  refine (sigma_mod_determines_iff 2 7 (by norm_num) (by norm_num)).mpr ?_
  decide

/-- **The threshold is not of order `p + q`.**  For every bound `B` there are
primes `q > p > B` such that the *constant* modulus `m = 7` already determines
the factorisation of `N = p q` from `σ₂(N) mod 7`. -/
theorem constant_modulus_suffices_infinitely_often (B : ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ B < p ∧ p < q ∧
      ∀ a b : ℕ, a * b = p * q →
        Nat.ModEq 7 (sigmaWitness 2 a b) (sigmaWitness 2 p q) →
        (a = p ∧ b = q) ∨ (a = q ∧ b = p) := by
  obtain ⟨p, hpB, hp, hpmod⟩ :=
    Nat.forall_exists_prime_gt_and_modEq B (q := 7) (a := 2) (by norm_num) (by norm_num)
  obtain ⟨q, hqp, hq, hqmod⟩ :=
    Nat.forall_exists_prime_gt_and_modEq p (q := 7) (a := 2) (by norm_num) (by norm_num)
  refine ⟨p, q, hp, hq, hpB, hqp, ?_⟩
  refine (sigma_mod_determines_iff 2 7 hp hq).mpr ?_
  intro hdvd
  have hpz : ((p : ZMod 7)) = (2 : ZMod 7) := by
    have := (ZMod.natCast_eq_natCast_iff p 2 7).mpr hpmod
    simpa using this
  have hqz : ((q : ZMod 7)) = (2 : ZMod 7) := by
    have := (ZMod.natCast_eq_natCast_iff q 2 7).mpr hqmod
    simpa using this
  have hz : (((((p : ℤ) ^ 2 - 1) * ((q : ℤ) ^ 2 - 1) : ℤ)) : ZMod 7) = 0 :=
    (ZMod.intCast_zmod_eq_zero_iff_dvd _ 7).mpr (by exact_mod_cast hdvd)
  rw [show ((((((p : ℤ) ^ 2 - 1) * ((q : ℤ) ^ 2 - 1) : ℤ)) : ZMod 7))
      = ((p : ZMod 7) ^ 2 - 1) * ((q : ZMod 7) ^ 2 - 1) by push_cast; ring] at hz
  rw [hpz, hqz] at hz
  revert hz
  decide

/-! ## Cycle 2: locating the threshold exactly

The threshold theorem reduces everything to an arithmetic question about the
*witness gap* `G_k(p,q) = (p^k − 1)(q^k − 1)`: a modulus `m` works iff `m ∤ G`.
We now determine the *least* working modulus.  The answer is bounded by an
absolute constant infinitely often, is never smaller than `5` (for `p, q > 3`),
and equals `5` precisely when `p, q ≢ ±1 (mod 5)`. -/

/-- The witness gap `(p^k − 1)(q^k − 1)`, as a natural number. -/
def gap (k p q : ℕ) : ℕ := (p ^ k - 1) * (q ^ k - 1)

theorem gap_cast {k p q : ℕ} (hp : 1 ≤ p) (hq : 1 ≤ q) :
    (gap k p q : ℤ) = ((p : ℤ) ^ k - 1) * ((q : ℤ) ^ k - 1) := by
  have hp' : 1 ≤ p ^ k := Nat.one_le_pow _ _ hp
  have hq' : 1 ≤ q ^ k := Nat.one_le_pow _ _ hq
  simp only [gap]
  push_cast [Nat.cast_sub hp', Nat.cast_sub hq']
  ring

/-- `Determines k m p q` : the residue of the order-`k` witness modulo `m`
pins down the factorisation `N = p q`. -/
def Determines (k m p q : ℕ) : Prop :=
  ∀ a b : ℕ, a * b = p * q →
    Nat.ModEq m (sigmaWitness k a b) (sigmaWitness k p q) →
    (a = p ∧ b = q) ∨ (a = q ∧ b = p)

/-- Natural-number form of the sharp threshold theorem. -/
theorem determines_iff_not_dvd_gap (k m : ℕ) {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    Determines k m p q ↔ ¬ (m ∣ gap k p q) := by
  rw [Determines, sigma_mod_determines_iff k m hp hq,
    ← gap_cast (k := k) hp.one_lt.le hq.one_lt.le, Int.natCast_dvd_natCast]

/-! ### The order-1 witness: the gap *is* Euler's totient -/

/-- For the order-1 witness `σ₁(N) = 1 + p + q + N` the gap is exactly `φ(N)`. -/
theorem gap_one_eq_totient {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    gap 1 p q = Nat.totient (p * q) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  rw [Nat.totient_mul hcop, Nat.totient_prime hp, Nat.totient_prime hq, gap, pow_one, pow_one]

/-- **RSA reading of the threshold theorem**: the residue `σ₁(N) mod m`
determines the factorisation of `N = p q` iff `m` does not divide `φ(N)`.
The obstruction to partial-information factoring at order 1 is precisely the
Euler totient, the classical RSA trapdoor. -/
theorem determines_one_iff_not_dvd_totient (m : ℕ) {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) :
    Determines 1 m p q ↔ ¬ (m ∣ Nat.totient (p * q)) := by
  rw [determines_iff_not_dvd_gap 1 m hp hq, gap_one_eq_totient hp hq hpq]

/-! ### A universal lower bound: `m* ≥ 5` -/

theorem sq_mod_twentyfour {p : ℕ} (h2 : p % 2 = 1) (h3 : p % 3 ≠ 0) : p ^ 2 % 24 = 1 := by
  have hmod : p ^ 2 % 24 = (p % 24) ^ 2 % 24 := by rw [Nat.pow_mod]
  have hlt : p % 24 < 24 := Nat.mod_lt _ (by norm_num)
  have e2 : p % 24 % 2 = 1 := by rw [Nat.mod_mod_of_dvd p (by norm_num : (2 : ℕ) ∣ 24)]; exact h2
  have e3 : p % 24 % 3 ≠ 0 := by
    rw [Nat.mod_mod_of_dvd p (by norm_num : (3 : ℕ) ∣ 24)]; exact h3
  rw [hmod]
  interval_cases h : (p % 24) <;> first | rfl | omega

/-- For every prime `p > 3` one has `24 ∣ p² − 1`. -/
theorem twentyfour_dvd_sq_sub_one {p : ℕ} (hp : p.Prime) (h3 : 3 < p) : 24 ∣ p ^ 2 - 1 := by
  have h2 : p % 2 = 1 := Nat.odd_iff.mp (hp.odd_of_ne_two (by omega))
  have h3' : p % 3 ≠ 0 := by
    intro h
    have : (3 : ℕ) ∣ p := Nat.dvd_of_mod_eq_zero h
    rcases (Nat.Prime.eq_one_or_self_of_dvd hp 3 this) with h' | h' <;> omega
  have hsq := sq_mod_twentyfour h2 h3'
  have h1 : 1 ≤ p ^ 2 := Nat.one_le_pow _ _ hp.pos
  generalize p ^ 2 = x at hsq h1
  omega

/-- `24` always divides the order-`2` witness gap of a semiprime with both
prime factors `> 3`. -/
theorem twentyfour_dvd_gap {p q : ℕ} (hp : p.Prime) (hp3 : 3 < p) :
    24 ∣ gap 2 p q :=
  Dvd.dvd.mul_right (twentyfour_dvd_sq_sub_one hp hp3) _

/-- **Universal lower bound on the threshold**: for `p, q > 3` no modulus
`1 ≤ m ≤ 4` determines the factorisation. -/
theorem not_determines_of_lt_five {p q m : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp3 : 3 < p) (hm1 : 1 ≤ m) (hm : m < 5) :
    ¬ Determines 2 m p q := by
  rw [determines_iff_not_dvd_gap 2 m hp hq, not_not]
  have h24 : m ∣ 24 := by interval_cases m <;> decide
  exact h24.trans (twentyfour_dvd_gap hp hp3)

/-! ### When the least modulus is exactly `5` -/

theorem five_dvd_sq_sub_one_iff {p : ℕ} (hp : 1 ≤ p) :
    5 ∣ p ^ 2 - 1 ↔ (p % 5 = 1 ∨ p % 5 = 4) := by
  have hmod : p ^ 2 % 5 = (p % 5) ^ 2 % 5 := by rw [Nat.pow_mod]
  have hlt : p % 5 < 5 := Nat.mod_lt _ (by norm_num)
  have h1 : 1 ≤ p ^ 2 := Nat.one_le_pow _ _ hp
  have key : (5 ∣ p ^ 2 - 1) ↔ p ^ 2 % 5 = 1 := by
    generalize p ^ 2 = x at h1 ⊢
    omega
  rw [key, hmod]
  interval_cases h : (p % 5) <;> simp

/-- The modulus `5` works exactly when neither prime is `≡ ±1 (mod 5)`. -/
theorem five_determines_iff {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    Determines 2 5 p q ↔
      (p % 5 ≠ 1 ∧ p % 5 ≠ 4 ∧ q % 5 ≠ 1 ∧ q % 5 ≠ 4) := by
  rw [determines_iff_not_dvd_gap 2 5 hp hq, gap]
  rw [Nat.Prime.dvd_mul (by norm_num), five_dvd_sq_sub_one_iff hp.one_lt.le,
    five_dvd_sq_sub_one_iff hq.one_lt.le]
  tauto

/-- **The constant is `5`, not `5 (p+q)`.**  For primes `p, q > 3` that avoid
`±1 (mod 5)`, the least modulus determining the factorisation from `σ₂ mod m`
is exactly `5`, uniformly in the size of `p` and `q`. -/
theorem least_modulus_eq_five {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp3 : 3 < p)
    (hp5 : p % 5 ≠ 1 ∧ p % 5 ≠ 4) (hq5 : q % 5 ≠ 1 ∧ q % 5 ≠ 4) :
    Determines 2 5 p q ∧ ∀ m, 1 ≤ m → m < 5 → ¬ Determines 2 m p q :=
  ⟨(five_determines_iff hp hq).mpr ⟨hp5.1, hp5.2, hq5.1, hq5.2⟩,
    fun _ hm1 hm => not_determines_of_lt_five hp hq hp3 hm1 hm⟩

/-! ### A counting bound: few primes can fail -/

/-- The witness gap of a semiprime is positive for every order `k ≥ 1`. -/
theorem gap_pos {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {k : ℕ} (hk : k ≠ 0) :
    0 < gap k p q := by
  have hk1 : 1 ≤ k := Nat.one_le_iff_ne_zero.mpr hk
  have hp2 : 2 ≤ p ^ k := by
    calc 2 ≤ p := hp.two_le
      _ = p ^ 1 := (pow_one p).symm
      _ ≤ p ^ k := Nat.pow_le_pow_right hp.one_lt.le hk1
  have hq2 : 2 ≤ q ^ k := by
    calc 2 ≤ q := hq.two_le
      _ = q ^ 1 := (pow_one q).symm
      _ ≤ q ^ k := Nat.pow_le_pow_right hq.one_lt.le hk1
  have h1 : 0 < p ^ k - 1 := by omega
  have h2 : 0 < q ^ k - 1 := by omega
  simpa [gap] using Nat.mul_pos h1 h2

/-- If a finite set `S` of primes has more elements than `log₂` of the gap,
then some prime in `S` already determines the factorisation.  (Concretely:
the gap is `< N²`, so `2 log₂ N + 1` primes always suffice.) -/
theorem exists_prime_determines {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {k : ℕ} (hk : k ≠ 0)
    (S : Finset ℕ) (hS : ∀ r ∈ S, r.Prime) (hcard : gap k p q < 2 ^ S.card) :
    ∃ r ∈ S, Determines k r p q := by
  by_contra! H
  have hdvd : ∀ r ∈ S, r ∣ gap k p q := by
    intro r hr
    have := H r hr
    rw [determines_iff_not_dvd_gap k r hp hq, not_not] at this
    exact this
  have hprod : ∏ r ∈ S, r ∣ gap k p q :=
    Finset.prod_primes_dvd _ (fun r hr => (Nat.prime_iff.mp (hS r hr))) hdvd
  have hpos : 0 < gap k p q := gap_pos hp hq hk
  have hle : 2 ^ S.card ≤ ∏ r ∈ S, r := by
    calc 2 ^ S.card = ∏ _r ∈ S, 2 := by rw [Finset.prod_const]
      _ ≤ ∏ r ∈ S, r := Finset.prod_le_prod' (fun r hr => (hS r hr).two_le)
  have : ∏ r ∈ S, r ≤ gap k p q := Nat.le_of_dvd hpos hprod
  omega

/-- Concrete form of the counting bound: if the gap is smaller than
`2 ^ π(x)`, then some prime below `x` already determines the factorisation. -/
theorem exists_small_prime_determines {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {k : ℕ} (hk : k ≠ 0)
    (x : ℕ) (hcard : gap k p q < 2 ^ (Nat.primesBelow x).card) :
    ∃ r < x, r.Prime ∧ Determines k r p q := by
  obtain ⟨r, hrS, hr⟩ :=
    exists_prime_determines hp hq hk (Nat.primesBelow x)
      (fun r hr => Nat.prime_of_mem_primesBelow hr) hcard
  exact ⟨r, Nat.lt_of_mem_primesBelow hrS, Nat.prime_of_mem_primesBelow hrS, hr⟩

/-- **Pigeonhole form of the counting bound**: any family of more than
`ω(gap)` distinct primes contains a determining modulus. -/
theorem exists_prime_determines_of_card_gt {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {k : ℕ}
    (hk : k ≠ 0) (S : Finset ℕ) (hS : ∀ r ∈ S, r.Prime)
    (hcard : (gap k p q).primeFactors.card < S.card) :
    ∃ r ∈ S, Determines k r p q := by
  by_contra! H
  have hpos : 0 < gap k p q := gap_pos hp hq hk
  have hsub : S ⊆ (gap k p q).primeFactors := by
    intro r hr
    have hd := H r hr
    rw [determines_iff_not_dvd_gap k r hp hq, not_not] at hd
    exact Nat.mem_primeFactors.mpr ⟨hS r hr, hd, hpos.ne'⟩
  exact absurd (Finset.card_le_card hsub) (by omega)

/-- The number of primes one has to try is at most `log₂` of the gap: the
factor information carried by `σ_k` modulo small primes is `O(log N)` bits. -/
theorem card_primeFactors_gap_le_log {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {k : ℕ}
    (hk : k ≠ 0) : (gap k p q).primeFactors.card ≤ Nat.log 2 (gap k p q) := by
  have hpos : 0 < gap k p q := gap_pos hp hq hk
  have hdvd : ∏ r ∈ (gap k p q).primeFactors, r ∣ gap k p q := Nat.prod_primeFactors_dvd _
  have hle : 2 ^ (gap k p q).primeFactors.card ≤ ∏ r ∈ (gap k p q).primeFactors, r := by
    calc 2 ^ (gap k p q).primeFactors.card = ∏ _r ∈ (gap k p q).primeFactors, 2 := by
          rw [Finset.prod_const]
      _ ≤ ∏ r ∈ (gap k p q).primeFactors, r :=
          Finset.prod_le_prod' (fun r hr => (Nat.prime_of_mem_primeFactors hr).two_le)
  have h2 : 2 ^ (gap k p q).primeFactors.card ≤ gap k p q :=
    hle.trans (Nat.le_of_dvd hpos hdvd)
  exact (Nat.le_log_iff_pow_le (by norm_num) hpos.ne').mpr h2

/-! ### The unifying separation principle -/

/-- **Separation principle.**  For *any* `N` and any two factorisations
`N = a b = c d`, the two witnesses agree modulo `m` exactly when `m` divides the
difference of the power sums `a^k + b^k` and `c^k + d^k`.  All threshold results
above are instances of this identity: the free witness sees a factorisation only
through its power sum, i.e. through the *trace coordinate*. -/
theorem witness_modEq_iff_dvd_powsum_diff {k m a b c d : ℕ} (h : a * b = c * d) :
    Nat.ModEq m (sigmaWitness k a b) (sigmaWitness k c d) ↔
      (m : ℤ) ∣ (((a : ℤ) ^ k + (b : ℤ) ^ k) - ((c : ℤ) ^ k + (d : ℤ) ^ k)) := by
  have hz : ((a : ℤ) * b) = ((c : ℤ) * d) := by exact_mod_cast h
  have hprod : (a : ℤ) ^ k * (b : ℤ) ^ k = (c : ℤ) ^ k * (d : ℤ) ^ k := by
    rw [← mul_pow, ← mul_pow, hz]
  have hexp : (sigmaWitness k c d : ℤ) - (sigmaWitness k a b : ℤ)
      = -((((a : ℤ) ^ k + (b : ℤ) ^ k) - ((c : ℤ) ^ k + (d : ℤ) ^ k))) := by
    simp only [sigmaWitness]
    push_cast
    ring_nf
    linarith [hprod]
  rw [Nat.modEq_iff_dvd, hexp, dvd_neg]

/-! ### Rigidity of the full witness -/

/-- **Witness rigidity, all orders** (no primality needed): for every `k ≥ 1`,
the pair *(product, order-`k` witness)* is a complete invariant of an unordered
pair of naturals.  This is the exact sense in which the free witness carries the
whole factorisation. -/
theorem witness_injective_pow {k a b c d : ℕ} (hk : 1 ≤ k) (hprod : a * b = c * d)
    (hw : sigmaWitness k a b = sigmaWitness k c d) :
    (a = c ∧ b = d) ∨ (a = d ∧ b = c) := by
  have hprodk : a ^ k * b ^ k = c ^ k * d ^ k := by
    rw [← mul_pow, ← mul_pow, hprod]
  have hsumk : a ^ k + b ^ k = c ^ k + d ^ k := by
    have hw' : 1 + a ^ k + b ^ k + a ^ k * b ^ k = 1 + c ^ k + d ^ k + c ^ k * d ^ k := by
      simp only [sigmaWitness] at hw
      ring_nf at hw ⊢
      linarith [hw]
    omega
  have hinj : Function.Injective (fun x : ℕ => x ^ k) := Nat.pow_left_injective (by omega)
  rcases sum_prod_determines hprodk hsumk with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨hinj h1, hinj h2⟩
  · exact Or.inr ⟨hinj h1, hinj h2⟩

/-- The order-2 case of `witness_injective_pow`: `(N, σ₂)` is a complete
invariant of the unordered factor pair. -/
theorem witness_injective {a b c d : ℕ} (hprod : a * b = c * d)
    (hw : sigmaWitness 2 a b = sigmaWitness 2 c d) :
    (a = c ∧ b = d) ∨ (a = d ∧ b = c) :=
  witness_injective_pow (by norm_num) hprod hw

/-! ### The recovered quadratic -/

/-- The recovery algorithm produces the correct *characteristic polynomial* of
the factorisation: `X² − t X + N` with `t` the trace read off from `σ₂(N)`
splits as `(X − p)(X − q)` over `ℤ`. -/
theorem witness_char_poly {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (Polynomial.X - Polynomial.C (p : ℤ)) * (Polynomial.X - Polynomial.C (q : ℤ))
      = Polynomial.X ^ 2
        - Polynomial.C ((traceOf (p * q) (σ 2 (p * q)) : ℤ)) * Polynomial.X
        + Polynomial.C ((p * q : ℕ) : ℤ) := by
  rw [traceOf_eq hp hq hpq]
  push_cast
  simp only [Polynomial.C_add, Polynomial.C_mul]
  ring

end FreeWitness