import Catalog.Physics.CyclicTypeDivisorBound

/-!
# Prime-power decomposition of the splitting-type channel

`Catalog.Physics.CyclicTypeChannelPrime.HT_mul_coprime` shows that the entropy of the
splitting type is *additive* over coprime factorisations of the cyclic order,
`H(T)(mn) = H(T)(m) + H(T)(n)`.  Iterating this over the prime factorisation of `n` gives the
complete structural description of the channel: the type entropy of `C_n` is the sum of the
type entropies of its Sylow pieces.

## Main results

* `CyclicType.HT_one` : the trivial group carries no information.
* `CyclicType.HT_eq_sum_primePow` : `H(T)(n) = Σ_{p ∣ n} H(T)(p^{v_p(n)})` — the type channel
  decomposes over the Sylow decomposition of the cyclic Galois group.
* `CyclicType.HT_squarefree` : for squarefree orders this becomes the explicit two-state sum
  `Σ_{p ∣ n} (log₂ p − ((p−1)/p) log₂ (p−1))`.
* `CyclicType.HT_ge_of_dvd_coprime_cofactor` : each Sylow piece is a lower bound for the whole
  channel — adding prime factors never destroys information.
-/

set_option maxHeartbeats 1000000

namespace CyclicType

open Finset

variable {n : ℕ}

/-- The trivial cyclic order carries no splitting information. -/
theorem HT_one : HT 1 = 0 := by
  rw [HT_divisor_formula (by norm_num)]
  simp

/-- **Sylow decomposition of the type channel.**  The splitting-type entropy of a cyclic order
is the sum of the entropies of its prime-power parts. -/
theorem HT_eq_sum_primePow (hn : n ≠ 0) :
    HT n = ∑ p ∈ n.primeFactors, HT (p ^ n.factorization p) := by
  have hmul : ∀ x y : ℕ, x.Coprime y →
      (Multiplicative.ofAdd (HT (x * y)) : Multiplicative ℝ)
        = Multiplicative.ofAdd (HT x) * Multiplicative.ofAdd (HT y) := by
    intro x y h
    rcases Nat.eq_zero_or_pos x with hx | hx
    · subst hx
      rw [Nat.coprime_zero_left] at h
      subst h
      simp [HT_one]
    rcases Nat.eq_zero_or_pos y with hy | hy
    · subst hy
      rw [Nat.coprime_zero_right] at h
      subst h
      simp [HT_one]
    rw [HT_mul_coprime hx hy h]
    rfl
  have hf1 : (Multiplicative.ofAdd (HT 1) : Multiplicative ℝ) = 1 := by
    rw [HT_one]; rfl
  have hmain := Nat.multiplicative_factorization
    (fun m => (Multiplicative.ofAdd (HT m) : Multiplicative ℝ)) hmul hf1 hn
  rw [Finsupp.prod, Nat.support_factorization] at hmain
  have hprod : ∏ p ∈ n.primeFactors,
      (Multiplicative.ofAdd (HT (p ^ n.factorization p)) : Multiplicative ℝ)
      = Multiplicative.ofAdd (∑ p ∈ n.primeFactors, HT (p ^ n.factorization p)) := by
    rw [ofAdd_sum]
  rw [hprod] at hmain
  exact Multiplicative.ofAdd.injective hmain

/-- For a squarefree cyclic order the channel is an explicit sum of two-state prime channels. -/
theorem HT_squarefree (hn : Squarefree n) (hpos : n ≠ 0) :
    HT n = ∑ p ∈ n.primeFactors,
      (Real.logb 2 p - ((p - 1 : ℕ) : ℝ) / p * Real.logb 2 ((p - 1 : ℕ) : ℝ)) := by
  rw [HT_eq_sum_primePow hpos]
  refine Finset.sum_congr rfl (fun p hp => ?_)
  have hprime : p.Prime := Nat.prime_of_mem_primeFactors hp
  have hle : n.factorization p ≤ 1 := (Nat.squarefree_iff_factorization_le_one hpos).1 hn p
  have hpos' : 0 < n.factorization p :=
    (Nat.Prime.factorization_pos_of_dvd hprime hpos (Nat.dvd_of_mem_primeFactors hp))
  have h1 : n.factorization p = 1 := by omega
  rw [h1, pow_one, HT_prime hprime]

/-- Adding coprime prime factors never destroys information: every Sylow piece of the cyclic
order is a lower bound for the entropy of the full type channel. -/
theorem HT_ge_of_dvd_coprime_cofactor {m k : ℕ} (hm : 0 < m) (hk : 0 < k)
    (h : Nat.Coprime m k) : HT m ≤ HT (m * k) := by
  rw [HT_mul_coprime hm hk h]
  have := HT_nonneg hk
  linarith

end CyclicType