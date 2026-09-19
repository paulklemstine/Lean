/-
# CONVERSE-COST-CURVE, part I: the gcd-sum witness `M₁` and the reach chain

Setting: `N = p * q` with `p ≠ q` prime (a *semiprime*).  The experimental
programme measures four *factor-revealing witnesses* and their *definition
routes* (the cheapest way to evaluate the witness from `N` alone).  This file
formalises the first witness and the algebraic half of the "reach chain"

    witness  →  s = p + q  →  {p, q}.

* `ConverseCost.pillai` — `M₁(N) = ∑_{x < N} gcd(x, N)` (Pillai's arithmetical
  function), the W1 witness, whose definition route is a full `N`-scan.
* `ConverseCost.pillai_semiprime` — the exact closed form
  `M₁(pq) + 2(p+q) = 4pq + 1`, i.e. `M₁ = 4N - 2s + 1`.
* `ConverseCost.sum_rigidity` — `(N, s)` pins the unordered pair `{p, q}`.
* `ConverseCost.pillai_determines_pair` — hence `M₁` alone (with `N`) pins the
  factorisation: the W1 route *reaches* the factors.

Everything is `ℕ`-valued; natural subtraction is avoided by stating the closed
form additively.
-/
import Mathlib

namespace ConverseCost

open Finset

/-! ## The W1 witness -/

/-- **W1.**  Pillai's gcd-sum `M₁(N) = ∑_{x<N} gcd(x, N)`.  Its definition route
is a full scan of the `N` residues, i.e. cost `Θ(N) = Θ(2^{log N})`. -/
def pillai (N : ℕ) : ℕ := ∑ x ∈ Finset.range N, Nat.gcd x N

/-! ## Counting the residues hit by a prime -/

/-- `gcd x p` is `p` on the multiples of the prime `p` and `1` elsewhere. -/
theorem gcd_prime_eq_ite {p : ℕ} (hp : p.Prime) (x : ℕ) :
    Nat.gcd x p = if p ∣ x then p else 1 := by
  by_cases h : p ∣ x
  · simp [h, Nat.gcd_eq_right]
  · have : Nat.gcd x p ∣ p := Nat.gcd_dvd_right _ _
    rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ this) with h1 | hpp
    · simp [h, h1]
    · exact absurd (hpp ▸ Nat.gcd_dvd_left x p) h

/-- The multiples of `p` below `p * q` are exactly `p·0, …, p·(q-1)`: there are
`q` of them. -/
theorem card_multiples_lt {p q : ℕ} (hp : 0 < p) :
    ((Finset.range (p * q)).filter (fun x => p ∣ x)).card = q := by
  have hset : (Finset.range (p * q)).filter (fun x => p ∣ x)
      = (Finset.range q).image (fun i => p * i) := by
    ext x
    simp only [mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hx, i, rfl⟩
      exact ⟨i, lt_of_mul_lt_mul_left hx (Nat.zero_le p), rfl⟩
    · rintro ⟨i, hi, rfl⟩
      exact ⟨(Nat.mul_lt_mul_left hp).mpr hi, ⟨i, rfl⟩⟩
  rw [hset, Finset.card_image_of_injective _ (mul_right_injective₀ hp.ne'),
    Finset.card_range]

/-- Below `p * q`, the only common multiple of two coprime numbers is `0`. -/
theorem card_common_multiples {p q : ℕ} (hpq : Nat.Coprime p q) (hp : 0 < p) (hq : 0 < q) :
    ((Finset.range (p * q)).filter (fun x => p ∣ x ∧ q ∣ x)).card = 1 := by
  have hset : (Finset.range (p * q)).filter (fun x => p ∣ x ∧ q ∣ x) = {0} := by
    ext x
    simp only [mem_filter, mem_range, Finset.mem_singleton]
    constructor
    · rintro ⟨hx, hpx, hqx⟩
      have : p * q ∣ x := Nat.Coprime.mul_dvd_of_dvd_of_dvd hpq hpx hqx
      rcases Nat.eq_zero_or_pos x with h | h
      · exact h
      · exact absurd (Nat.le_of_dvd h this) (not_le.mpr hx)
    · rintro rfl
      exact ⟨Nat.mul_pos hp hq, dvd_zero _, dvd_zero _⟩
  rw [hset, Finset.card_singleton]

/-! ## The closed form for `M₁` -/

/-- **W1 closed form.**  For a semiprime `N = p q` with distinct primes,
`M₁(N) = 4N - 2(p+q) + 1`, stated additively to avoid `ℕ`-subtraction.

This is the exact statement behind the measured exponent `α = 1.000` for the W1
route: the witness value is an affine function of `N` and `s = p + q`, so
evaluating it by its definition costs one full `N`-scan while its *content* is a
single number `s`. -/
theorem pillai_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    pillai (p * q) + 2 * (p + q) = 4 * (p * q) + 1 := by
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  obtain ⟨a, ha⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  obtain ⟨b, hb⟩ : ∃ b, q = b + 1 := ⟨q - 1, by omega⟩
  subst ha
  subst hb
  -- pointwise expansion of the summand
  have hpt : ∀ x ∈ Finset.range ((a + 1) * (b + 1)),
      Nat.gcd x ((a + 1) * (b + 1))
        = 1 + ((if (a + 1) ∣ x then a else 0) + ((if (b + 1) ∣ x then b else 0)
            + (if (a + 1) ∣ x ∧ (b + 1) ∣ x then a * b else 0))) := by
    intro x _
    rw [Nat.Coprime.gcd_mul x hpq, gcd_prime_eq_ite hp, gcd_prime_eq_ite hq]
    by_cases h1 : (a + 1) ∣ x <;> by_cases h2 : (b + 1) ∣ x <;> simp [h1, h2] <;> ring
  rw [pillai, Finset.sum_congr rfl hpt]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_add_distrib]
  have e1 : ∑ _x ∈ Finset.range ((a + 1) * (b + 1)), 1 = (a + 1) * (b + 1) := by
    simp
  have e2 : ∑ x ∈ Finset.range ((a + 1) * (b + 1)), (if (a + 1) ∣ x then a else 0)
      = a * (b + 1) := by
    rw [← Finset.sum_filter, Finset.sum_const, card_multiples_lt hp0,
      smul_eq_mul, Nat.mul_comm]
  have e3 : ∑ x ∈ Finset.range ((a + 1) * (b + 1)), (if (b + 1) ∣ x then b else 0)
      = b * (a + 1) := by
    have hcomm : (a + 1) * (b + 1) = (b + 1) * (a + 1) := Nat.mul_comm _ _
    rw [hcomm, ← Finset.sum_filter, Finset.sum_const, card_multiples_lt hq0,
      smul_eq_mul, Nat.mul_comm]
  have e4 : ∑ x ∈ Finset.range ((a + 1) * (b + 1)),
      (if (a + 1) ∣ x ∧ (b + 1) ∣ x then a * b else 0) = a * b := by
    rw [← Finset.sum_filter, Finset.sum_const,
      card_common_multiples hpq hp0 hq0, smul_eq_mul, Nat.one_mul]
  rw [e1, e2, e3, e4]
  ring

/-! ## The reach chain: `(N, s)` pins `{p, q}` -/

/-- **Rigidity of the pair.**  Two ordered pairs of naturals with the same sum
and the same product coincide.  This is the `{(N, s)}` theorem: the elementary
symmetric data determines the multiset of roots. -/
theorem sum_rigidity {p q p' q' : ℕ} (hs : p + q = p' + q') (hm : p * q = p' * q')
    (h1 : p ≤ q) (h2 : p' ≤ q') : p = p' ∧ q = q' := by
  have hsZ : (p : ℤ) + q = (p' : ℤ) + q' := by exact_mod_cast hs
  have hmZ : (p : ℤ) * q = (p' : ℤ) * q' := by exact_mod_cast hm
  have hd : ((q : ℤ) - p) ^ 2 = ((q' : ℤ) - p') ^ 2 := by nlinarith [hsZ, hmZ]
  have h1Z : (p : ℤ) ≤ q := by exact_mod_cast h1
  have h2Z : (p' : ℤ) ≤ q' := by exact_mod_cast h2
  have hdiff : (q : ℤ) - p = (q' : ℤ) - p' := by
    nlinarith [hd, h1Z, h2Z, sq_nonneg ((q : ℤ) - p - ((q' : ℤ) - p')),
      sq_nonneg ((q : ℤ) - p + ((q' : ℤ) - p'))]
  constructor
  · have : (p : ℤ) = p' := by linarith
    exact_mod_cast this
  · have : (q : ℤ) = q' := by linarith
    exact_mod_cast this

/-- **W1 reaches the factors.**  If two semiprimes have the same modulus and the
same gcd-sum witness, they have the same factors: `M₁` together with `N`
determines `{p, q}`.  This is the formal content of the measured 100 % reach
rate of the chain `W1 → s → {p,q}`. -/
theorem pillai_determines_pair {p q p' q' : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hp' : p'.Prime) (hq' : q'.Prime) (hne' : p' ≠ q')
    (hle : p ≤ q) (hle' : p' ≤ q')
    (hN : p * q = p' * q') (hM : pillai (p * q) = pillai (p' * q')) :
    p = p' ∧ q = q' := by
  have h1 := pillai_semiprime hp hq hne
  have h2 := pillai_semiprime hp' hq' hne'
  rw [hM, hN] at h1
  have hs : p + q = p' + q' := by omega
  exact sum_rigidity hs hN hle hle'

/-- The witness value determines `s = p + q` explicitly. -/
theorem sum_from_pillai {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    p + q = (4 * (p * q) + 1 - pillai (p * q)) / 2 := by
  have h := pillai_semiprime hp hq hne
  omega

/-! ## Lab notes (machine-checked instances of the closed form) -/

example : pillai (3 * 5) = 45 := by decide
example : pillai (5 * 7) = 117 := by decide

/-- `N = 143 = 11·13`: the closed form gives `M₁ = 4·143 - 2·24 + 1 = 525`. -/
example : pillai (11 * 13) = 525 := by
  have h := pillai_semiprime (by norm_num) (by norm_num) (by norm_num : (11 : ℕ) ≠ 13)
  omega

end ConverseCost