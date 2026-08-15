import Geometry.PowerSumFactorReveal

/-!
# Carmichael periodicity of the power-sum gcd, and factor recovery

Continuing `Geometry.PowerSumFactorReveal`, let `N = p * q` be a semiprime and

`g k = gcd (powerSum N k) N`,  `powerSum N k = ∑_{a=1}^{N} a^k`.

The master formula of the previous file shows that, for `k ≥ 1`, `g k` depends on `k`
only through the two Boolean quantities `(p-1) ∣ k` and `(q-1) ∣ k`.  Hence `g` is
periodic with period the Carmichael number `λ(N) = lcm (p-1) (q-1)`, and in fact
`λ(N)` is *exactly* the least period, because

`g k = 1 ↔ λ(N) ∣ k`   (for `k ≥ 1`).

So `λ(N)` is readable off the sequence `g 1, g 2, g 3, …` as the position of its first
`1`.  The last section addresses **factor recovery**.  The naive claim
"`p + q = N - λ(N) + 1`" is *false* in general — it confuses `λ(N) = lcm(p-1,q-1)`
with `φ(N) = (p-1)(q-1)`; `p = 5, q = 13` is a counterexample
(`lambda_recovery_counterexample`).  The correct identity is

`gcd (p-1) (q-1) * λ(N) + (p + q) = N + 1`,

which reduces to the naive one exactly under the guard `gcd (p-1) (q-1) = 1`.
Together with a Vieta uniqueness lemma this recovers `p` and `q`.

## Main results

* `PowerSumReveal.gcd_powerSum_periodic` — periodicity with period `λ(N)`.
* `PowerSumReveal.gcd_powerSum_eq_one_iff` — `g k = 1 ↔ λ(N) ∣ k`.
* `PowerSumReveal.lambda_isLeast_period_point` — `λ(N)` is the least `k ≥ 1` with `g k = 1`.
* `PowerSumReveal.gcd_powerSum_least_period` — no smaller positive number is a period.
* `PowerSumReveal.lambda_recovery_counterexample` — the naive recovery formula fails.
* `PowerSumReveal.carmichael_totient_recovery` — the corrected recovery identity.
* `PowerSumReveal.semiprime_recovered_from_period` — full recovery of `{p, q}` under the guard.
-/

namespace PowerSumReveal

open Finset

variable {p q : ℕ}

/-- The Carmichael function of a semiprime `p * q` with distinct primes: `lcm (p-1) (q-1)`. -/
def carmichael (p q : ℕ) : ℕ := Nat.lcm (p - 1) (q - 1)

lemma carmichael_pos (hp : p.Prime) (hq : q.Prime) : 0 < carmichael p q := by
  have h1 : 0 < p - 1 := by have := hp.two_le; omega
  have h2 : 0 < q - 1 := by have := hq.two_le; omega
  exact Nat.pos_of_ne_zero fun h => by
    rcases Nat.lcm_eq_zero_iff.mp h with h' | h' <;> omega

lemma dvd_carmichael_left : (p - 1) ∣ carmichael p q := Nat.dvd_lcm_left _ _

lemma dvd_carmichael_right : (q - 1) ∣ carmichael p q := Nat.dvd_lcm_right _ _

/-! ## Periodicity -/

/-- **Theorem 3a (Carmichael periodicity).**  For `k ≥ 1` the gcd sequence
`k ↦ gcd (powerSum (p*q) k) (p*q)` is invariant under shifting `k` by `λ(N) = lcm(p-1,q-1)`. -/
theorem gcd_powerSum_periodic (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {k : ℕ}
    (hk : k ≠ 0) :
    Nat.gcd (powerSum (p * q) (k + carmichael p q)) (p * q)
      = Nat.gcd (powerSum (p * q) k) (p * q) := by
  have hk' : k + carmichael p q ≠ 0 := by omega
  have h1 : (p - 1) ∣ (k + carmichael p q) ↔ (p - 1) ∣ k :=
    (Nat.dvd_add_iff_left (dvd_carmichael_left (p := p) (q := q))).symm
  have h2 : (q - 1) ∣ (k + carmichael p q) ↔ (q - 1) ∣ k :=
    (Nat.dvd_add_iff_left (dvd_carmichael_right (p := p) (q := q))).symm
  rw [gcd_powerSum_semiprime hp hq hpq hk', gcd_powerSum_semiprime hp hq hpq hk]
  by_cases hA : (p - 1) ∣ k <;> by_cases hB : (q - 1) ∣ k <;>
    simp [hA, hB, h1, h2]

/-- **Theorem 3b.**  For `k ≥ 1` the gcd is trivial exactly at the multiples of `λ(N)`. -/
theorem gcd_powerSum_eq_one_iff (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {k : ℕ}
    (hk : k ≠ 0) :
    Nat.gcd (powerSum (p * q) k) (p * q) = 1 ↔ carmichael p q ∣ k := by
  rw [gcd_powerSum_semiprime hp hq hpq hk, carmichael, Nat.lcm_dvd_iff]
  constructor
  · intro h
    by_cases hA : (p - 1) ∣ k
    · by_cases hB : (q - 1) ∣ k
      · exact ⟨hA, hB⟩
      · rw [if_pos hA, if_neg hB, one_mul] at h; exact absurd h hq.ne_one
    · rw [if_neg hA] at h
      exact absurd (Nat.eq_one_of_mul_eq_one_right h) hp.ne_one
  · rintro ⟨hA, hB⟩
    rw [if_pos hA, if_pos hB, one_mul]

/-- **Theorem 3c.**  `λ(N)` is the least positive exponent at which the gcd becomes `1`;
in particular it is *readable* from the gcd sequence. -/
theorem lambda_isLeast_period_point (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    IsLeast {k : ℕ | 0 < k ∧ Nat.gcd (powerSum (p * q) k) (p * q) = 1} (carmichael p q) := by
  constructor
  · refine ⟨carmichael_pos hp hq, ?_⟩
    exact (gcd_powerSum_eq_one_iff hp hq hpq (carmichael_pos hp hq).ne').2 dvd_rfl
  · rintro k ⟨hk0, hk1⟩
    exact Nat.le_of_dvd hk0 ((gcd_powerSum_eq_one_iff hp hq hpq hk0.ne').1 hk1)

/-- **Theorem 3d (minimality of the period).**  No `d` with `0 < d < λ(N)` is a period
of the gcd sequence: the witness is `k = λ(N)`. -/
theorem gcd_powerSum_least_period (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {d : ℕ}
    (hd0 : 0 < d) (hd : d < carmichael p q) :
    ∃ k : ℕ, 0 < k ∧ Nat.gcd (powerSum (p * q) (k + d)) (p * q)
      ≠ Nat.gcd (powerSum (p * q) k) (p * q) := by
  refine ⟨carmichael p q, carmichael_pos hp hq, ?_⟩
  have hlam : carmichael p q ≠ 0 := (carmichael_pos hp hq).ne'
  have h1 : Nat.gcd (powerSum (p * q) (carmichael p q)) (p * q) = 1 :=
    (gcd_powerSum_eq_one_iff hp hq hpq hlam).2 dvd_rfl
  have h2 : ¬ carmichael p q ∣ (carmichael p q + d) := by
    intro h
    have : carmichael p q ∣ d := (Nat.dvd_add_right dvd_rfl).mp h
    exact absurd (Nat.le_of_dvd hd0 this) (not_le.mpr hd)
  have h3 : Nat.gcd (powerSum (p * q) (carmichael p q + d)) (p * q) ≠ 1 := by
    intro h
    exact h2 ((gcd_powerSum_eq_one_iff hp hq hpq (by omega)).1 h)
  rw [h1]; exact h3

/-! ## Factor recovery: the naive formula and its repair -/

/-- **Critic's counterexample.**  The claim `p + q = N - λ(N) + 1` is *false* in general:
for `p = 5`, `q = 13` we have `N = 65`, `λ(N) = lcm 4 12 = 12`, and `65 - 12 + 1 = 54 ≠ 18`.
The failure is exactly the factor `gcd (p-1) (q-1) = 4`. -/
theorem lambda_recovery_counterexample :
    carmichael 5 13 = 12 ∧ 5 * 13 - carmichael 5 13 + 1 ≠ 5 + 13 := by
  constructor
  · decide
  · decide

/-- **Corrected recovery identity.**  For any `p, q ≥ 1`,
`gcd (p-1) (q-1) * λ + (p + q) = p*q + 1` where `λ = lcm (p-1) (q-1)`.
Equivalently `φ(N) + (p+q) = N + 1` with `φ(N) = (p-1)(q-1) = gcd · lcm`. -/
theorem carmichael_totient_recovery (hp : 1 ≤ p) (hq : 1 ≤ q) :
    Nat.gcd (p - 1) (q - 1) * carmichael p q + (p + q) = p * q + 1 := by
  have h := Nat.gcd_mul_lcm (p - 1) (q - 1)
  rw [carmichael, h]
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 1 := ⟨q - 1, by omega⟩
  simp only [Nat.add_sub_cancel]
  ring

/-- Under the guard `gcd (p-1) (q-1) = 1` the naive formula is correct:
`λ(N) + (p + q) = N + 1`. -/
theorem carmichael_recovery_of_coprime (hp : 1 ≤ p) (hq : 1 ≤ q)
    (hcop : Nat.Coprime (p - 1) (q - 1)) :
    carmichael p q + (p + q) = p * q + 1 := by
  have := carmichael_totient_recovery hp hq
  rwa [hcop, one_mul] at this

/-- **Vieta uniqueness.**  A pair of naturals is determined by its sum and product,
once ordered. -/
theorem vieta_unique {s N a b a' b' : ℕ} (h1 : a + b = s) (h2 : a * b = N)
    (h3 : a' + b' = s) (h4 : a' * b' = N) (hab : a ≤ b) (hab' : a' ≤ b') :
    a = a' ∧ b = b' := by
  have key : ((a : ℤ) - a') * ((a : ℤ) + a' - s) = 0 := by
    have e1 : (a : ℤ) * ((s : ℤ) - a) = N := by
      have : (b : ℤ) = (s : ℤ) - a := by push_cast [← h1]; ring
      rw [← this]; exact_mod_cast h2
    have e2 : (a' : ℤ) * ((s : ℤ) - a') = N := by
      have : (b' : ℤ) = (s : ℤ) - a' := by push_cast [← h3]; ring
      rw [← this]; exact_mod_cast h4
    nlinarith [e1, e2]
  rcases mul_eq_zero.1 key with h | h
  · have : a = a' := by omega
    exact ⟨this, by omega⟩
  · -- here `a' = b`, hence `b' = a`, and the orderings force `a = b`
    have hab2 : (a : ℤ) + a' = s := by omega
    have ha' : a' = b := by omega
    have hb' : b' = a := by omega
    subst ha'; subst hb'
    omega

/-- **Theorem 3 (full form).**  Suppose `N = p * q` with `p < q` distinct primes and
`gcd (p-1) (q-1) = 1`.  Reading the least period `λ = λ(N)` off the gcd sequence
determines the factorisation: any ordered pair `(a, b)` with `a * b = N` and
`a + b = N + 1 - λ` equals `(p, q)`. -/
theorem semiprime_recovered_from_period (hp : p.Prime) (hq : q.Prime) (hlt : p < q)
    (hcop : Nat.Coprime (p - 1) (q - 1)) {a b : ℕ} (hab : a ≤ b)
    (hprod : a * b = p * q) (hsum : a + b = p * q + 1 - carmichael p q) :
    a = p ∧ b = q := by
  have hrec : carmichael p q + (p + q) = p * q + 1 :=
    carmichael_recovery_of_coprime hp.one_lt.le hq.one_lt.le hcop
  have hsum' : a + b = p + q := by omega
  exact (vieta_unique (a := a) (b := b) (a' := p) (b' := q) hsum' hprod rfl rfl hab
    hlt.le).imp id id

end PowerSumReveal