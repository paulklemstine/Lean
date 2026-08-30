import Mathlib
import Bridges.TreeSieveLottery

/-!
# The corrected tree sieve collapses to Dixon — and Dixon really splits

`Catalog.Bridges.TreeSieveLottery` shows that an integer identity `X² = Y²`
carries no information about `N`, and that any *corrected* variant must instead
produce a congruence `x² ≡ y² [mod N]` with `x ≢ ± y`.  This file supplies the
positive half of that dichotomy, so that the collapse statement is not vacuous:

* `exists_nontrivial_sqrt_one` — for distinct odd primes `p, q` there is an
  explicit `z` (built from a Bézout identity) with `pq ∣ (z-1)(z+1)`,
  `pq ∤ z - 1`, `pq ∤ z + 1`.
* `dixon_route_splits` — end-to-end: combined with
  `TreeSieve.dixon_split_nontrivial`, the gcd step then outputs a proper
  nontrivial factor of `N = p * q`.
* `gcd_z_sub_one_eq_p` — the factor obtained is exactly `p`.
* `gcd_pair_recovers_factorization` — the two nontrivial roots `z ∓ 1` return
  `p` and `q` respectively, and their gcds multiply back to `N`: a structured
  root has yield `1`, so all Dixon-class cost lies in producing the relation.

Together with `TreeSieve.intSquareRelation_gcd_trivial` this pins the dichotomy:
the tree sieve as stated returns `N` itself, and any repair lands in the
Dixon / quadratic-sieve class, whose cost is governed by smoothness, not by the
tree.

The last section isolates why a constant-factor smoothness advantage (the
measured `7.31×`) cannot move an exponent: `exponent_dominance` shows that for
`α < β` *every* constant `C` is eventually beaten, so a cost exponent `1/2` —
such as the multi-target ascending sweep — is dominated by exponent `1/4`
regardless of constants.
-/

namespace DixonCollapse

open TreeSieve

/-! ## An explicit nontrivial square root of `1` modulo `p * q` -/

section

variable {p q : ℕ}

/-- Bézout data for two distinct primes. -/
theorem bezout_of_distinct_primes (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    ∃ u v : ℤ, u * p + v * q = 1 := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have hco : IsCoprime (p : ℤ) (q : ℤ) := Int.isCoprime_iff_gcd_eq_one.mpr (by
    simpa [Int.gcd_natCast_natCast] using hcop)
  obtain ⟨u, v, huv⟩ := hco
  exact ⟨u, v, huv⟩

variable {u v : ℤ}

/-- With `up + vq = 1`, the prime `q` cannot divide `u * p`. -/
theorem not_dvd_mul (hq : q.Prime) (huv : u * p + v * q = 1) : ¬ (q : ℤ) ∣ u * p := by
  intro h
  have h1 : (q : ℤ) ∣ 1 := by
    have : (q : ℤ) ∣ u * p + v * q := dvd_add h ⟨v, by ring⟩
    rwa [huv] at this
  have : (q : ℕ) ∣ 1 := by exact_mod_cast h1
  have := Nat.le_of_dvd Nat.one_pos this
  exact absurd hq.two_le (by omega)

/-- `q` does not divide `2 * u * p` either, because `q` is odd. -/
theorem not_dvd_two_mul (hq : q.Prime) (hq2 : q ≠ 2) (huv : u * p + v * q = 1) :
    ¬ (q : ℤ) ∣ 2 * (u * p) := by
  intro h
  have hqp : Prime (q : ℤ) := Nat.prime_iff_prime_int.mp hq
  rcases (hqp.dvd_mul).mp h with h2 | h2
  · have : (q : ℕ) ∣ 2 := by exact_mod_cast h2
    have := (Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp this
    exact hq2 this
  · exact not_dvd_mul hq huv h2

/-- **Explicit nontrivial square root of unity.**  For distinct odd primes,
`z = 1 - 2up` (where `up + vq = 1`) is a square root of `1` modulo `p * q`
distinct from `± 1`. -/
theorem exists_nontrivial_sqrt_one (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) :
    ∃ z : ℤ, ((p * q : ℕ) : ℤ) ∣ (z - 1) * (z + 1) ∧
      ¬ ((p * q : ℕ) : ℤ) ∣ (z - 1) ∧ ¬ ((p * q : ℕ) : ℤ) ∣ (z + 1) ∧
      ((p : ℤ) ∣ (z - 1) ∧ ¬ (q : ℤ) ∣ (z - 1)) ∧
      ((q : ℤ) ∣ (z + 1) ∧ ¬ (p : ℤ) ∣ (z + 1)) := by
  obtain ⟨u, v, huv⟩ := bezout_of_distinct_primes hp hq hpq
  have hz1 : (1 - 2 * u * (p : ℤ)) - 1 = -(2 * (u * p)) := by ring
  have hz2 : (1 - 2 * u * (p : ℤ)) + 1 = 2 * (v * q) := by linarith [huv]
  have hqnd : ¬ (q : ℤ) ∣ ((1 - 2 * u * (p : ℤ)) - 1) := by
    rw [hz1, dvd_neg]
    exact not_dvd_two_mul hq hq2 huv
  have hpnd : ¬ (p : ℤ) ∣ ((1 - 2 * u * (p : ℤ)) + 1) := by
    rw [hz2]
    exact not_dvd_two_mul hp hp2 (by linarith [huv] : v * q + u * p = 1)
  refine ⟨1 - 2 * u * (p : ℤ), ?_, ?_, ?_, ⟨⟨-2 * u, by ring⟩, hqnd⟩,
    ⟨⟨2 * v, by rw [hz2]; ring⟩, hpnd⟩⟩
  · refine ⟨-4 * (u * v), ?_⟩
    rw [hz1, hz2]
    push_cast
    ring
  · intro hdvd
    refine hqnd (dvd_trans ?_ hdvd)
    exact ⟨(p : ℤ), by push_cast; ring⟩
  · intro hdvd
    refine hpnd (dvd_trans ?_ hdvd)
    exact ⟨(q : ℤ), by push_cast; ring⟩

/-- **The corrected route really splits `N`.**  For distinct odd primes the
Dixon mechanism produces a proper nontrivial factor of `N = p * q`. -/
theorem dixon_route_splits (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) :
    ∃ z : ℤ, 1 < Int.gcd (z - 1) ((p * q : ℕ) : ℤ) ∧
      (Int.gcd (z - 1) ((p * q : ℕ) : ℤ) : ℤ) < ((p * q : ℕ) : ℤ) := by
  obtain ⟨z, hprod, h1, h2, -, -⟩ := exists_nontrivial_sqrt_one hp hq hpq hp2 hq2
  have hN : (1 : ℤ) < ((p * q : ℕ) : ℤ) := by
    have : 4 ≤ p * q := Nat.mul_le_mul hp.two_le hq.two_le
    exact_mod_cast (by omega : 1 < p * q)
  exact ⟨z, dixon_split_nontrivial hN hprod h1 h2⟩

/-- **Exact gcd.**  If `x` is divisible by `p` but not by `q`, then its gcd with
`p * q` is exactly `p`. -/
theorem gcd_eq_of_dvd_not_dvd (hq : q.Prime) (hp0 : p ≠ 0) {x : ℤ}
    (hpd : (p : ℤ) ∣ x) (hqnd : ¬ (q : ℤ) ∣ x) :
    Int.gcd x ((p * q : ℕ) : ℤ) = p := by
  have hgdvd : Int.gcd x ((p * q : ℕ) : ℤ) ∣ p * q := by
    have h : ((Int.gcd x ((p * q : ℕ) : ℤ) : ℕ) : ℤ) ∣ ((p * q : ℕ) : ℤ) :=
      Int.gcd_dvd_right _ _
    exact_mod_cast h
  have hpg : p ∣ Int.gcd x ((p * q : ℕ) : ℤ) := by
    have hpz : (p : ℤ) ∣ ((p * q : ℕ) : ℤ) := by push_cast; exact Dvd.intro q rfl
    exact Int.dvd_gcd hpd hpz
  obtain ⟨k, hk⟩ := hpg
  have hkq : k ∣ q := by
    have hpk : p * k ∣ p * q := by rw [← hk]; exact hgdvd
    exact (mul_dvd_mul_iff_left hp0).mp hpk
  rcases hq.eq_one_or_self_of_dvd k hkq with h1 | h1
  · rw [hk, h1, mul_one]
  · exfalso
    have hgd : ((Int.gcd x ((p * q : ℕ) : ℤ) : ℕ) : ℤ) ∣ x := Int.gcd_dvd_left _ _
    have hqg : (q : ℤ) ∣ ((Int.gcd x ((p * q : ℕ) : ℤ) : ℕ) : ℤ) := by
      rw [hk, h1]; push_cast; exact Dvd.intro_left _ rfl
    exact hqnd (dvd_trans hqg hgd)

/-- **Both prime factors are recovered.**  The two nontrivial square roots of
`1` modulo `N = p * q` reveal `p` and `q` respectively: for the explicit root
`z`, `gcd (z - 1, N) = p` and `gcd (z + 1, N) = q`, and the two gcds multiply
back to `N`.  So a structured root has yield `1`, and all the cost of a
Dixon-class method sits in producing the relation, none in exploiting it. -/
theorem gcd_pair_recovers_factorization (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) :
    ∃ z : ℤ, Int.gcd (z - 1) ((p * q : ℕ) : ℤ) = p ∧
      Int.gcd (z + 1) ((p * q : ℕ) : ℤ) = q ∧
      Int.gcd (z - 1) ((p * q : ℕ) : ℤ) * Int.gcd (z + 1) ((p * q : ℕ) : ℤ) = p * q := by
  obtain ⟨z, -, -, -, ⟨hpd, hqnd⟩, ⟨hqd, hpnd⟩⟩ := exists_nontrivial_sqrt_one hp hq hpq hp2 hq2
  have h1 : Int.gcd (z - 1) ((p * q : ℕ) : ℤ) = p :=
    gcd_eq_of_dvd_not_dvd hq hp.ne_zero hpd hqnd
  have h2 : Int.gcd (z + 1) ((p * q : ℕ) : ℤ) = q := by
    have := gcd_eq_of_dvd_not_dvd hp hq.ne_zero hqd hpnd
    rwa [Nat.mul_comm q p] at this
  exact ⟨z, h1, h2, by rw [h1, h2]⟩

/-- The factor recovered by the explicit square root is exactly `p`. -/
theorem gcd_z_sub_one_eq_p (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) :
    ∃ z : ℤ, Int.gcd (z - 1) ((p * q : ℕ) : ℤ) = p := by
  obtain ⟨z, h1, -, -⟩ := gcd_pair_recovers_factorization hp hq hpq hp2 hq2
  exact ⟨z, h1⟩

end

/-! ## Constant factors never move an exponent -/

/-- **Exponent dominance.**  If `α < β` then for every constant `C > 0` and all
`N` beyond `C^{1/(β-α)}`, the `α`-cost beats the `β`-cost even after the
constant is applied.  Hence a constant-factor smoothness advantage (`7.31×`)
cannot upgrade an exponent-`1/2` search into anything sub-`N^{1/2}`, and
exponent `1/4` (Pollard-ρ) dominates exponent `1/2` (trial division). -/
theorem exponent_dominance {a b C N : ℝ} (hab : a < b) (hC : 0 < C) (hN1 : 1 ≤ N)
    (hN : C ^ (1 / (b - a)) < N) : C * N ^ a < N ^ b := by
  have hNpos : (0 : ℝ) < N := lt_of_lt_of_le one_pos hN1
  have hba : 0 < b - a := by linarith
  have hCrw : (C ^ (1 / (b - a))) ^ (b - a) = C := by
    rw [← Real.rpow_mul hC.le, one_div, inv_mul_cancel₀ (ne_of_gt hba), Real.rpow_one]
  have hlt : C < N ^ (b - a) := by
    calc C = (C ^ (1 / (b - a))) ^ (b - a) := hCrw.symm
      _ < N ^ (b - a) := Real.rpow_lt_rpow (Real.rpow_nonneg hC.le _) hN hba
  have hpow : (0 : ℝ) < N ^ a := Real.rpow_pos_of_pos hNpos a
  calc C * N ^ a < N ^ (b - a) * N ^ a := mul_lt_mul_of_pos_right hlt hpow
    _ = N ^ b := by rw [← Real.rpow_add hNpos]; ring_nf

end DixonCollapse