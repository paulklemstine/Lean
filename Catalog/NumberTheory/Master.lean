/-
# The `q`-analogue of Kummer's theorem for *every* prime

`Catalog/NumberTheory/QKummer/Valuation.lean` proves the `q`-Kummer formula for odd primes with
`d = ord_ℓ(q)`, and `Catalog/NumberTheory/QKummer/TwoAdic.lean` shows that at `ℓ = 2` this recipe
fails and must be replaced by the order of `q` modulo `4`.  This file packages the two cases into
one statement, valid for every prime `ℓ ∤ q`:

* `QKummer.qPeriod q ℓ` : the order of `q` modulo `ℓ` for odd `ℓ`, and modulo `4` for `ℓ = 2`;
* `QKummer.qOffset q ℓ` : the valuation `v_ℓ([qPeriod]_q)`;
* `QKummer.isQRegular_qPeriod` : `(qPeriod, qOffset)` is a regular datum at every prime `ℓ ∤ q`;
* `QKummer.qBinom_padicValNat_master` : the `q`-Kummer formula at every prime `ℓ ∤ q`.
-/
import Catalog.NumberTheory.QKummer.TwoAdic

namespace QKummer

/-- The period of the `ℓ`-adic valuation of `q`-integers: the multiplicative order of `q` modulo
`ℓ`, except at `ℓ = 2` where one must use the order modulo `4`. -/
noncomputable def qPeriod (q ℓ : ℕ) : ℕ :=
  if ℓ = 2 then orderOf ((q : ℕ) : ZMod 4) else orderOf ((q : ℕ) : ZMod ℓ)

/-- The offset of the `ℓ`-adic valuation of `q`-integers: `v_ℓ([d]_q)` for the period `d`. -/
noncomputable def qOffset (q ℓ : ℕ) : ℕ := padicValNat ℓ (qNat q (qPeriod q ℓ))

theorem qPeriod_two_of_one_mod_four {q : ℕ} (hq : q % 4 = 1) : qPeriod q 2 = 1 := by
  have hcast : ((q : ℕ) : ZMod 4) = 1 := by
    rw [← ZMod.natCast_mod q 4, hq]
    norm_num
  rw [qPeriod, if_pos rfl, hcast, orderOf_one]

theorem qPeriod_two_of_three_mod_four {q : ℕ} (hq : q % 4 = 3) : qPeriod q 2 = 2 := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  have hcast : ((q : ℕ) : ZMod 4) = 3 := by
    rw [← ZMod.natCast_mod q 4, hq]
    norm_num
  rw [qPeriod, if_pos rfl, hcast]
  exact orderOf_eq_prime (by decide) (by decide)

theorem qPeriod_of_odd {q ℓ : ℕ} (hodd : Odd ℓ) :
    qPeriod q ℓ = orderOf ((q : ℕ) : ZMod ℓ) := by
  have h2 : ℓ ≠ 2 := by
    have := Nat.odd_iff.mp hodd
    omega
  rw [qPeriod, if_neg h2]

/-- **A regular datum at every prime.**  For any prime `ℓ` not dividing `q ≥ 2`, the `ℓ`-adic
valuations of the `q`-integers are regular with period `qPeriod q ℓ` and offset `qOffset q ℓ`. -/
theorem isQRegular_qPeriod {q ℓ : ℕ} [hp : Fact ℓ.Prime] (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) :
    IsQRegular q ℓ (qPeriod q ℓ) (qOffset q ℓ) := by
  rcases Nat.Prime.eq_two_or_odd' hp.out with h2 | hodd
  · subst h2
    have hq2 : q % 2 = 1 := by omega
    have hcases : q % 4 = 1 ∨ q % 4 = 3 := by omega
    rcases hcases with h1 | h3
    · rw [qOffset, qPeriod_two_of_one_mod_four h1, qNat_one, padicValNat.one]
      exact isQRegular_two_of_one_mod_four hq h1
    · rw [qOffset, qPeriod_two_of_three_mod_four h3]
      exact isQRegular_two_of_three_mod_four h3
  · rw [qPeriod_of_odd hodd, qOffset, qPeriod_of_odd hodd]
    exact isQRegular_of_odd_prime hodd hq hnd

/-- **The `q`-analogue of Kummer's theorem, for every prime.**

For any prime `ℓ` not dividing `q ≥ 2`, with `D = qPeriod q ℓ` (the order of `q` modulo `ℓ`, or
modulo `4` when `ℓ = 2`) and `E = qOffset q ℓ = v_ℓ([D]_q)`,

`v_ℓ(binom(n,k)_q) = E · c + v_ℓ(binom(⌊n/D⌋,⌊k/D⌋)) + c · v_ℓ(⌊(n-k)/D⌋+1)`,

where `c ∈ {0,1}` is the carry out of the base-`D` digit when `k` and `n-k` are added. -/
theorem qBinom_padicValNat_master {q ℓ : ℕ} [hp : Fact ℓ.Prime] (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q)
    {n k : ℕ} (hk : k ≤ n) :
    padicValNat ℓ (qBinom q n k)
      = qOffset q ℓ * (if qPeriod q ℓ ≤ k % qPeriod q ℓ + (n - k) % qPeriod q ℓ then 1 else 0)
        + padicValNat ℓ ((n / qPeriod q ℓ).choose (k / qPeriod q ℓ))
        + (if qPeriod q ℓ ≤ k % qPeriod q ℓ + (n - k) % qPeriod q ℓ then 1 else 0)
            * padicValNat ℓ ((n - k) / qPeriod q ℓ + 1) :=
  qBinom_padicValNat (isQRegular_qPeriod hq hnd) hk

end QKummer