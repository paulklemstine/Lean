/-
# Lattice points govern the whole flat family

The catalog computes the coefficients of a semiprime frame `Φ_{pq}` as a difference of indicator
functions of the numerical semigroup `⟨p,q⟩` (`PMFrame.coeff_pmFrame_succ_indicator`).  Prime
inflation and reflection transport that description verbatim to every order of the shape
`2^α p^{β+1} q^{γ+1}`: the coefficient at the *inflated* index `(k+1)·p^β q^γ·2^α` is the same
difference of lattice-point indicators, up to the alternating sign coming from the reflection.
-/
import Mathlib
import Shared.PMFrameTwoParameter
import Algebra.PMFrameFlatFamilies
import Algebra.PMFrameNegation

namespace PMFrameSemigroup

open Polynomial Finset PMFrame PMFrameFlat PMFrameNeg

/-- Prime inflation in both parameters: the coefficient of `Φ_{p^{β+1} q^{γ+1}}` at the inflated
index `k · p^β q^γ` is the `k`-th coefficient of `Φ_{pq}`. -/
theorem coeff_pmFrame_inflate {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (β γ k : ℕ) :
    (pmFrame (p ^ (β + 1) * q ^ (γ + 1))).coeff (k * (p ^ β * q ^ γ))
      = (pmFrame (p * q)).coeff k := by
  have h1 : ∀ j : ℕ, (pmFrame ((p * q) * p ^ β)).coeff (j * p ^ β) = (pmFrame (p * q)).coeff j :=
    coeff_pmFrame_mul_prime_pow hp ⟨q, rfl⟩ β
  have h2 : ∀ j : ℕ, (pmFrame (((p * q) * p ^ β) * q ^ γ)).coeff (j * q ^ γ)
      = (pmFrame ((p * q) * p ^ β)).coeff j :=
    coeff_pmFrame_mul_prime_pow hq ⟨p * p ^ β, by ring⟩ γ
  have hrw : p ^ (β + 1) * q ^ (γ + 1) = ((p * q) * p ^ β) * q ^ γ := by ring
  have hidx : k * (p ^ β * q ^ γ) = (k * p ^ β) * q ^ γ := by ring
  rw [hrw, hidx, h2, h1]

/-- Reflection composed with inflation by a power of two. -/
theorem coeff_pmFrame_two_pow_mul {m : ℕ} (hm : Odd m) (hm1 : 1 < m) (α j : ℕ) :
    (pmFrame (2 ^ (α + 1) * m)).coeff (j * 2 ^ α) = (-1) ^ j * (pmFrame m).coeff j := by
  have h2 : ∀ i : ℕ, (pmFrame ((2 * m) * 2 ^ α)).coeff (i * 2 ^ α) = (pmFrame (2 * m)).coeff i :=
    coeff_pmFrame_mul_prime_pow Nat.prime_two ⟨m, rfl⟩ α
  have hrw : 2 ^ (α + 1) * m = (2 * m) * 2 ^ α := by ring
  rw [hrw, h2, coeff_pmFrame_two_mul hm hm1 j]

theorem odd_prime_pow_mul {p q : ℕ} (hpodd : Odd p) (hqodd : Odd q) (β γ : ℕ) :
    Odd (p ^ (β + 1) * q ^ (γ + 1)) := (hpodd.pow).mul (hqodd.pow)

theorem one_lt_prime_pow_mul {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpodd : Odd p)
    (β γ : ℕ) : 1 < p ^ (β + 1) * q ^ (γ + 1) := by
  have hp3 : 3 ≤ p := by
    have h2 := hp.two_le
    rw [Nat.odd_iff] at hpodd
    omega
  have hq2 : 2 ≤ q := hq.two_le
  have h1 : 3 ≤ p ^ (β + 1) := le_trans hp3 (Nat.le_self_pow (by omega) p)
  have h2 : 2 ≤ q ^ (γ + 1) := le_trans hq2 (Nat.le_self_pow (by omega) q)
  nlinarith

/-- **Lattice-point formula for the flat family.**  For odd primes `p ≠ q` and `k + 1 < pq`, the
coefficient of `Φ_{2^{α+1} p^{β+1} q^{γ+1}}` at the inflated index
`(k+1)·p^β q^γ·2^α` is `±` the difference of the indicators of the numerical semigroup `⟨p,q⟩`
at `k+1` and at `k`. -/
theorem coeff_pmFrame_family_indicator {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hpodd : Odd p) (hqodd : Odd q) (α β γ : ℕ) {k : ℕ} (hk : k + 1 < p * q)
    [Decidable (FrameRep p q (k + 1))] [Decidable (FrameRep p q k)] :
    (pmFrame (2 ^ (α + 1) * (p ^ (β + 1) * q ^ (γ + 1)))).coeff
        (((k + 1) * (p ^ β * q ^ γ)) * 2 ^ α)
      = (-1) ^ ((k + 1) * (p ^ β * q ^ γ)) *
          ((if FrameRep p q (k + 1) then 1 else 0) - (if FrameRep p q k then 1 else 0)) := by
  rw [coeff_pmFrame_two_pow_mul (odd_prime_pow_mul hpodd hqodd β γ)
      (one_lt_prime_pow_mul hp hq hpodd β γ) α,
    coeff_pmFrame_inflate hp hq β γ (k + 1),
    coeff_pmFrame_succ_indicator hp hq hne hk]

/-- The odd case of the same formula (no factor `2`). -/
theorem coeff_pmFrame_odd_family_indicator {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (β γ : ℕ) {k : ℕ} (hk : k + 1 < p * q)
    [Decidable (FrameRep p q (k + 1))] [Decidable (FrameRep p q k)] :
    (pmFrame (p ^ (β + 1) * q ^ (γ + 1))).coeff ((k + 1) * (p ^ β * q ^ γ))
      = (if FrameRep p q (k + 1) then 1 else 0) - (if FrameRep p q k then 1 else 0) := by
  rw [coeff_pmFrame_inflate hp hq β γ (k + 1), coeff_pmFrame_succ_indicator hp hq hne hk]

end PMFrameSemigroup