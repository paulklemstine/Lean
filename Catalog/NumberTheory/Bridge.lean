/-
# Bridge: the subspace-counting Gaussian binomial coefficient is the `q`-Pascal one

`Catalog/NumberTheory/SubspaceCounting.lean` defines the Gaussian binomial coefficient as the
quotient `∏_{i<k}(q^n - q^i) / ∏_{i<k}(q^k - q^i)`, which counts the `k`-dimensional subspaces of
an `n`-dimensional vector space over a field with `q` elements.
`Catalog/NumberTheory/QKummer/Basic.lean` defines it by the `q`-Pascal recursion.

`QKummer.gaussBinom_eq_qBinom` identifies the two for every `q ≥ 2` and `k ≤ n`.  Combining this
with the `q`-analogue of Kummer's theorem yields `QKummer.padicValNat_card_submodule`: an exact
formula for the `ℓ`-adic valuation of the *number of `k`-dimensional subspaces* of a finite
vector space, in terms of base-`d` carries (`d = ord_ℓ(q)`) and base-`ℓ` carries.
-/
import Catalog.NumberTheory.QKummer.Valuation
import Catalog.NumberTheory.SubspaceCounting

namespace QKummer

open Finset

variable {q : ℕ}

/-- The numerator of the geometric Gaussian binomial coefficient, in terms of `q`-factorials:
`∏_{i<k}(q^n - q^i) * [n-k]_q! = q^(0+1+⋯+(k-1)) (q-1)^k [n]_q!`. -/
theorem prod_pow_sub_mul_qFact (hq : 2 ≤ q) :
    ∀ n k : ℕ, k ≤ n →
      (∏ i ∈ range k, (q ^ n - q ^ i)) * qFact q (n - k)
        = q ^ (∑ i ∈ range k, i) * (q - 1) ^ k * qFact q n := by
  intro n k
  induction k with
  | zero => simp
  | succ k ih =>
      intro hk
      have hk' : k ≤ n := by omega
      have h1 := ih hk'
      have hpow : q ^ k * q ^ (n - k) = q ^ n := by
        rw [← pow_add]
        congr 1
        omega
      have hstep : q ^ n - q ^ k = q ^ k * ((q - 1) * qNat q (n - k)) := by
        rw [sub_one_mul_qNat (by omega : 1 ≤ q) (n - k), Nat.mul_sub_left_distrib, hpow,
          Nat.mul_one]
      have hnk : n - k = (n - (k + 1)) + 1 := by omega
      have h2 : qFact q (n - k) = qNat q (n - k) * qFact q (n - (k + 1)) := by
        conv_lhs => rw [hnk]
        rw [qFact_succ, ← hnk]
      calc (∏ i ∈ range (k + 1), (q ^ n - q ^ i)) * qFact q (n - (k + 1))
          = (q ^ k * (q - 1)) *
              ((∏ i ∈ range k, (q ^ n - q ^ i)) * (qNat q (n - k) * qFact q (n - (k + 1)))) := by
            rw [Finset.prod_range_succ, hstep]
            ring
        _ = (q ^ k * (q - 1)) * ((∏ i ∈ range k, (q ^ n - q ^ i)) * qFact q (n - k)) := by
            rw [h2]
        _ = (q ^ k * (q - 1)) * (q ^ (∑ i ∈ range k, i) * (q - 1) ^ k * qFact q n) := by rw [h1]
        _ = q ^ (∑ i ∈ range (k + 1), i) * (q - 1) ^ (k + 1) * qFact q n := by
            rw [Finset.sum_range_succ, pow_add, pow_succ]
            ring

/-- The denominator of the geometric Gaussian binomial coefficient:
`∏_{i<k}(q^k - q^i) = q^(0+1+⋯+(k-1)) (q-1)^k [k]_q!`. -/
theorem prod_pow_self_eq (hq : 2 ≤ q) (k : ℕ) :
    (∏ i ∈ range k, (q ^ k - q ^ i)) = q ^ (∑ i ∈ range k, i) * (q - 1) ^ k * qFact q k := by
  have h := prod_pow_sub_mul_qFact hq k k le_rfl
  simpa using h

/-- **The two Gaussian binomial coefficients agree.**  The subspace-counting quotient
`∏_{i<k}(q^n - q^i) / ∏_{i<k}(q^k - q^i)` equals the `q`-Pascal coefficient `binom(n,k)_q`. -/
theorem gaussBinom_eq_qBinom (hq : 2 ≤ q) {n k : ℕ} (hk : k ≤ n) :
    SubspaceCounting.gaussBinom q n k = qBinom q n k := by
  have hnum := prod_pow_sub_mul_qFact hq n k hk
  have hex := qFact_mul_qBinom q n k hk
  have hpos : 0 < ∏ i ∈ range k, (q ^ k - q ^ i) :=
    SubspaceCounting.prod_pos_of_one_lt (by omega)
  have key : (∏ i ∈ range k, (q ^ n - q ^ i))
      = (∏ i ∈ range k, (q ^ k - q ^ i)) * qBinom q n k := by
    refine Nat.eq_of_mul_eq_mul_right (qFact_pos q (n - k)) ?_
    rw [hnum, ← hex, prod_pow_self_eq hq k]
    ring
  rw [SubspaceCounting.gaussBinom, key, Nat.mul_div_cancel_left _ hpos]

section Subspaces

open Module

variable (K V : Type*) [Field K] [Fintype K] [AddCommGroup V] [Module K V] [Finite V]

/-- **`ℓ`-adic valuation of the number of subspaces.**

For an odd prime `ℓ` not dividing the order `q` of the finite field `K`, the number of
`k`-dimensional subspaces of an `n`-dimensional `K`-vector space has `ℓ`-adic valuation given by
the `q`-Kummer formula: `e * c + v_ℓ(binom(⌊n/d⌋,⌊k/d⌋)) + c * v_ℓ(⌊(n-k)/d⌋+1)`, where
`d = ord_ℓ(q)`, `e = v_ℓ([d]_q)` and `c ∈ {0,1}` is the base-`d` carry. -/
theorem padicValNat_card_submodule {ℓ k : ℕ} [Fact ℓ.Prime] (hodd : Odd ℓ)
    (hnd : ¬ ℓ ∣ Fintype.card K) (hk : k ≤ finrank K V) :
    padicValNat ℓ (Nat.card {W : Submodule K V // finrank K W = k})
      = padicValNat ℓ (qNat (Fintype.card K) (orderOf ((Fintype.card K : ℕ) : ZMod ℓ)))
          * (if orderOf ((Fintype.card K : ℕ) : ZMod ℓ)
                ≤ k % orderOf ((Fintype.card K : ℕ) : ZMod ℓ)
                  + (finrank K V - k) % orderOf ((Fintype.card K : ℕ) : ZMod ℓ) then 1 else 0)
        + padicValNat ℓ ((finrank K V / orderOf ((Fintype.card K : ℕ) : ZMod ℓ)).choose
            (k / orderOf ((Fintype.card K : ℕ) : ZMod ℓ)))
        + (if orderOf ((Fintype.card K : ℕ) : ZMod ℓ)
              ≤ k % orderOf ((Fintype.card K : ℕ) : ZMod ℓ)
                + (finrank K V - k) % orderOf ((Fintype.card K : ℕ) : ZMod ℓ) then 1 else 0)
            * padicValNat ℓ ((finrank K V - k) / orderOf ((Fintype.card K : ℕ) : ZMod ℓ) + 1) := by
  have hq : 2 ≤ Fintype.card K := Fintype.one_lt_card
  rw [SubspaceCounting.card_submodule_finrank_eq_gaussBinom K V hk,
    gaussBinom_eq_qBinom hq hk]
  exact qBinom_padicValNat_orderOf hodd hq hnd hk

end Subspaces

end QKummer