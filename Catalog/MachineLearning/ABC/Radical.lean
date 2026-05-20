import Mathlib

/-!
# Radical of a Natural Number

The **radical** of a natural number `n`, denoted `rad n`, is the product of the distinct
prime factors of `n`. This is the squarefree kernel of `n` — the largest squarefree divisor
of `n`.

## Main definitions

* `rad n` — the product of distinct prime divisors of `n`

## Main results

* `rad_dvd` — `rad n ∣ n` for all `n`
* `rad_squarefree` — `rad n` is squarefree for all positive `n`
* `rad_pow_eq_rad` — `rad (a ^ n) = rad a` for `n ≥ 1`
* `rad_mono` — if `m ∣ n` and `n ≠ 0` then `rad m ∣ rad n`
* `rad_mul_of_coprime` — `rad (m * n) = rad m * rad n` for coprime `m, n`
-/

open Finset Nat

/-- The radical of `n` is the product of its distinct prime factors. -/
def rad (n : ℕ) : ℕ := n.primeFactors.prod id

@[simp]
theorem rad_zero : rad 0 = 1 := by simp [rad]

@[simp]
theorem rad_one : rad 1 = 1 := by simp [rad]

/-- `rad n` divides `n`. This is `Nat.prod_primeFactors_dvd`. -/
theorem rad_dvd (n : ℕ) : rad n ∣ n := by
  exact Nat.prod_primeFactors_dvd n

/-
`rad n` is squarefree when `n > 0`.
-/
theorem rad_squarefree {n : ℕ} (hn : n ≠ 0) : Squarefree (rad n) := by
  -- Since the product of distinct primes is squarefree, we can conclude that rad(n) is squarefree.
  have h_rad_squarefree : ∀ {S : Finset ℕ}, (∀ p ∈ S, Nat.Prime p) → Squarefree (S.prod id) := by
    -- Since the product of distinct primes is squarefree, we can apply the theorem `Nat.squarefree_prod_of_prime`.
    intros S hS_prime; exact (by
    induction S using Finset.induction <;> simp_all +decide [ Nat.squarefree_mul_iff ];
    exact ⟨ Nat.Coprime.prod_right fun x hx => hS_prime.1.coprime_iff_not_dvd.mpr fun h => ‹¬_› <| by have := Nat.prime_dvd_prime_iff_eq hS_prime.1 ( hS_prime.2 x hx ) ; aesop, hS_prime.1.squarefree ⟩);
  exact h_rad_squarefree fun p hp => Nat.prime_of_mem_primeFactors hp

/-
The radical of a prime power equals the prime.
-/
theorem rad_prime_pow {p k : ℕ} (hp : Nat.Prime p) (hk : k ≠ 0) :
    rad (p ^ k) = p := by
  unfold rad;
  rw [ Nat.primeFactors_pow ] <;> aesop

/-
`rad (a ^ n) = rad a` for `n ≥ 1`.
-/
theorem rad_pow_eq_rad (a : ℕ) {n : ℕ} (hn : n ≠ 0) :
    rad (a ^ n) = rad a := by
  unfold rad;
  cases n <;> simp_all +decide [ Nat.primeFactors_pow ]

/-
If `m ∣ n` and `n ≠ 0`, then `rad m ∣ rad n`.
-/
theorem rad_mono {m n : ℕ} (h : m ∣ n) (hn : n ≠ 0) : rad m ∣ rad n := by
  apply_rules [ Finset.prod_dvd_prod_of_subset, Nat.primeFactors_mono ]

/-
For coprime `m, n` with both nonzero, `rad (m * n) = rad m * rad n`.
-/
theorem rad_mul_of_coprime {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0)
    (h : Nat.Coprime m n) :
    rad (m * n) = rad m * rad n := by
  unfold rad;
  rw [ Nat.primeFactors_mul hm hn, Finset.prod_union <| Nat.Coprime.disjoint_primeFactors h ]

/-
Primes dividing `rad n` are exactly primes dividing `n`.
-/
theorem mem_primeFactors_rad {n p : ℕ} (hn : n ≠ 0) :
    p ∈ (rad n).primeFactors ↔ p ∈ n.primeFactors := by
  simp +zetaDelta at *;
  -- Let's unfold the definition of `rad`
  intro hp
  simp [rad];
  simp +decide [ hn, hp.dvd_iff_not_coprime, Nat.coprime_prod_right_iff, Nat.coprime_prod_left_iff ];
  simp +decide [ Nat.coprime_prod_right_iff, Nat.coprime_prod_left_iff, Finset.prod_eq_zero_iff, hp.ne_one, hn ];
  simp +decide [ ← Nat.coprime_iff_gcd_eq_one, hp.coprime_iff_not_dvd ];
  exact ⟨ fun ⟨ x, hx₁, hx₂, hx₃ ⟩ => dvd_trans hx₃ hx₂, fun hx => ⟨ p, hp, hx, dvd_rfl ⟩ ⟩

/-
`rad n` is positive when `n` is positive.
-/
theorem rad_pos {n : ℕ} (hn : 0 < n) : 0 < rad n := by
  exact Finset.prod_pos fun p hp => Nat.Prime.pos ( Nat.prime_of_mem_primeFactors hp )