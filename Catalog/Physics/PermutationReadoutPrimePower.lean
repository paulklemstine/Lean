import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutAsymmetry
import Physics.PermutationReadoutParityLocalization
import Physics.PermutationReadoutZolotarev

/-!
# Zolotarev for odd prime powers: the readout parity is the Jacobi symbol

This file closes the *prime-power step* of conjecture **C1** of
`FUTURE_DIRECTIONS.md`: for an odd prime `p`, a multiplier `a` coprime to `p`
and any exponent `k ≥ 1`, the index

`i_{p^k} = φ(p^k) / ord_{p^k}(a)`

has the **same parity** as the base index `i_p = (p−1)/ord_p(a)`.  The reason is
purely `p`-adic: the order can only grow by a power of `p` when the modulus is
raised, `ord_{p^k}(a) = ord_p(a)·p^j` with `j ≤ k−1`, so
`i_{p^k} = p^{k−1−j}·i_p` and the extra factor is odd.

Consequently the whole cycle readout of `x ↦ a·x` on `ZMod (p^k)` has parity
`k·i_p`, and the sign of that permutation is exactly the Jacobi symbol
`J(a | p^k) = (a|p)^k`.  This extends `zolotarev_parity` (the prime case) and
`jacobi_readout_parity` (the semiprime case) to the whole prime-power tower.

## Main results

* `Physics.PermReadout.orderOf_prime_pow_dvd` — `ord_{p^k}(a) ∣ ord_p(a)·p^{k−1}`.
* `Physics.PermReadout.orderOf_prime_pow_eq` — `ord_{p^k}(a) = ord_p(a)·p^j`,
  `j ≤ k−1`.
* `Physics.PermReadout.index_prime_pow_parity` — `i_{p^k} ≡ i_p (mod 2)`.
* `Physics.PermReadout.cycleCount_prime_pow` — the cycle count of the
  prime-power modulus as a sum over the divisor tower.
* `Physics.PermReadout.parity_cycleCount_prime_pow` —
  `p^k − #cycles ≡ k·i_p (mod 2)`.
* `Physics.PermReadout.zolotarev_prime_pow` — `J(a | p^k) = 1` iff the
  permutation `x ↦ a·x` of `ZMod (p^k)` is even.
-/

namespace Physics.PermReadout

open Finset

section PrimePower

variable {p a k : ℕ}

/-- **Order growth is `p`-adic.**  Raising the modulus from `p` to `p^k` can
multiply the multiplicative order only by a power of `p`: `ord_{p^k}(a)` divides
`ord_p(a)·p^{k−1}`.  This is the lifting-the-exponent step
`p ∣ x − 1 → p^k ∣ x^{p^{k−1}} − 1`. -/
theorem orderOf_prime_pow_dvd (hk : 0 < k) :
    orderOf ((a : ZMod (p ^ k))) ∣ orderOf ((a : ZMod p)) * p ^ (k - 1) := by
  set d := orderOf ((a : ZMod p)) with hd
  -- `p ∣ a^d − 1` in `ℤ`
  have hbase : (p : ℤ) ∣ (a : ℤ) ^ d - 1 := by
    have : (((a : ℤ) ^ d - 1 : ℤ) : ZMod p) = 0 := by
      push_cast
      rw [hd]
      simp [pow_orderOf_eq_one]
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp this
  -- lift to `p^k ∣ a^{d p^{k−1}} − 1`
  have hlift : (p : ℤ) ^ (k - 1 + 1) ∣ ((a : ℤ) ^ d) ^ p ^ (k - 1) - 1 ^ p ^ (k - 1) :=
    dvd_sub_pow_of_dvd_sub (by simpa using hbase) (k - 1)
  have hk1 : k - 1 + 1 = k := by omega
  rw [hk1, one_pow, ← pow_mul] at hlift
  rw [orderOf_dvd_iff_pow_eq_one]
  have hzero : (((a : ℤ) ^ (d * p ^ (k - 1)) - 1 : ℤ) : ZMod (p ^ k)) = 0 := by
    refine (ZMod.intCast_zmod_eq_zero_iff_dvd _ (p ^ k)).mpr ?_
    simpa using hlift
  have := hzero
  push_cast at this
  linear_combination (norm := (push_cast; ring_nf)) this

/-- The order modulo `p^k` is the order modulo `p` times a power of `p` of
exponent at most `k−1`. -/
theorem orderOf_prime_pow_eq (hp : p.Prime) (hk : 0 < k) (hcop : Nat.Coprime a p) :
    ∃ j ≤ k - 1, orderOf ((a : ZMod (p ^ k))) = orderOf ((a : ZMod p)) * p ^ j := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  have hd0 : 0 < orderOf ((a : ZMod p)) := orderOf_pos_of_coprime hcop
  have hdvd : orderOf ((a : ZMod p)) ∣ orderOf ((a : ZMod (p ^ k))) :=
    orderOf_natCast_dvd_of_dvd (dvd_pow_self p hk.ne')
  obtain ⟨t, ht⟩ := hdvd
  have hup : orderOf ((a : ZMod p)) * t ∣ orderOf ((a : ZMod p)) * p ^ (k - 1) := by
    rw [← ht]; exact orderOf_prime_pow_dvd hk
  have htp : t ∣ p ^ (k - 1) := (mul_dvd_mul_iff_left hd0.ne').mp hup
  obtain ⟨j, hj, rfl⟩ := (Nat.dvd_prime_pow hp).mp htp
  exact ⟨j, hj, ht⟩

/-- **The prime-power index parity law.**  For an odd prime `p` the index
`φ(p^k)/ord_{p^k}(a)` has the same parity as `(p−1)/ord_p(a)`: the whole tower
`p, p², p³, …` reports the same quadratic bit. -/
theorem index_prime_pow_parity (hp : p.Prime) (hodd : p ≠ 2) (hk : 0 < k)
    (hcop : Nat.Coprime a p) :
    Nat.totient (p ^ k) / orderOf ((a : ZMod (p ^ k))) % 2
      = (p - 1) / orderOf ((a : ZMod p)) % 2 := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  have hpodd : p % 2 = 1 := by
    rcases hp.eq_two_or_odd with h | h
    · exact absurd h hodd
    · exact h
  have hd0 : 0 < orderOf ((a : ZMod p)) := orderOf_pos_of_coprime hcop
  obtain ⟨j, hj, hjeq⟩ := orderOf_prime_pow_eq hp hk hcop
  obtain ⟨i, hi⟩ : orderOf ((a : ZMod p)) ∣ p - 1 := by
    have := orderOf_dvd_totient (n := p) hcop
    rwa [Nat.totient_prime hp] at this
  have hie : (p - 1) / orderOf ((a : ZMod p)) = i := by
    rw [hi, Nat.mul_div_cancel_left _ hd0]
  have hsplit : p ^ (k - 1) = p ^ j * p ^ (k - 1 - j) := by
    rw [← pow_add]
    congr 1
    omega
  have hnum : Nat.totient (p ^ k)
      = (orderOf ((a : ZMod p)) * p ^ j) * (p ^ (k - 1 - j) * i) := by
    rw [Nat.totient_prime_pow hp hk, hsplit, hi]
    ring
  have hden0 : 0 < orderOf ((a : ZMod p)) * p ^ j := Nat.mul_pos hd0 (pow_pos hp.pos j)
  rw [hjeq, hnum, Nat.mul_div_cancel_left _ hden0, hie, Nat.mul_mod,
    Nat.pow_mod, hpodd, one_pow]
  simp

/-- The cycle count for a prime-power modulus: the divisor tower
`1, p, …, p^k` contributes `φ(p^j)/ord_{p^j}(a)` cycles at level `j`. -/
theorem cycleCount_prime_pow (hp : p.Prime) (hcop : Nat.Coprime a p) :
    haveI : NeZero (p ^ k) := ⟨pow_ne_zero k hp.pos.ne'⟩
    cycleCount (p ^ k) a
      = ∑ j ∈ Finset.range (k + 1), Nat.totient (p ^ j) / orderOf ((a : ZMod (p ^ j))) := by
  haveI : NeZero (p ^ k) := ⟨pow_ne_zero k hp.pos.ne'⟩
  have hcopk : Nat.Coprime a (p ^ k) := hcop.pow_right k
  rw [cycleCount_eq_sum hcopk, Nat.divisors_prime_pow hp, Finset.sum_map]
  simp only [Function.Embedding.coeFn_mk]
  rw [← Finset.sum_range_reflect]
  refine Finset.sum_congr rfl (fun j hj => ?_)
  have hjk : j ≤ k := by
    have := Finset.mem_range.mp hj
    omega
  have hdiv : p ^ k / p ^ (k + 1 - 1 - j) = p ^ j := by
    rw [show k + 1 - 1 - j = k - j by omega, Nat.pow_div (by omega) hp.pos,
      show k - (k - j) = j by omega]
  rw [hdiv]

/-- **The parity of the prime-power readout.**  The permutation `x ↦ a·x` of
`ZMod (p^k)` has sign parity `k·i_p`, where `i_p = (p−1)/ord_p(a)`: each level
of the tower contributes one copy of the base quadratic bit. -/
theorem parity_cycleCount_prime_pow (hp : p.Prime) (hodd : p ≠ 2)
    (hcop : Nat.Coprime a p) :
    haveI : NeZero (p ^ k) := ⟨pow_ne_zero k hp.pos.ne'⟩
    (p ^ k - cycleCount (p ^ k) a) % 2 = (k * ((p - 1) / orderOf ((a : ZMod p)))) % 2 := by
  haveI : NeZero (p ^ k) := ⟨pow_ne_zero k hp.pos.ne'⟩
  have hpodd : p % 2 = 1 := by
    rcases hp.eq_two_or_odd with h | h
    · exact absurd h hodd
    · exact h
  set i := (p - 1) / orderOf ((a : ZMod p)) with hi
  -- the cycle count as a sum over the tower
  have hsum := cycleCount_prime_pow (k := k) hp hcop
  -- parity of the sum
  have hzero : Nat.totient (p ^ 0) / orderOf ((a : ZMod (p ^ 0))) = 1 := by
    have : orderOf ((a : ZMod (p ^ 0))) = 1 :=
      orderOf_eq_one_iff.mpr (by simpa using Subsingleton.elim _ _)
    simp [this]
  have hparity : cycleCount (p ^ k) a % 2 = (k * i + 1) % 2 := by
    rw [hsum, Finset.sum_range_succ', hzero, Nat.add_mod, Finset.sum_nat_mod]
    have : ∑ x ∈ Finset.range k,
        Nat.totient (p ^ (x + 1)) / orderOf ((a : ZMod (p ^ (x + 1)))) % 2
        = ∑ _x ∈ Finset.range k, i % 2 := by
      refine Finset.sum_congr rfl (fun x _ => ?_)
      exact index_prime_pow_parity hp hodd (Nat.succ_pos x) hcop
    rw [this, Finset.sum_const, Finset.card_range, smul_eq_mul]
    simp [Nat.add_mod, Nat.mul_mod]
  -- the cycle count never exceeds the size of the ring
  have hle : cycleCount (p ^ k) a ≤ p ^ k := by
    have h1 : cycleCount (p ^ k) a ≤ (Finset.univ : Finset (ZMod (p ^ k))).card :=
      Finset.card_image_le
    simpa using h1
  have hpk : p ^ k % 2 = 1 := by
    rw [Nat.pow_mod, hpodd, one_pow]
    simp
  omega

/-- **Zolotarev for odd prime powers.**  The sign of the multiplication
permutation of `ZMod (p^k)` is the Jacobi symbol `J(a | p^k) = (a|p)^k`:  the
permutation is even exactly when the symbol is `+1`.  Together with
`zolotarev_parity` and `jacobi_readout_parity` this shows that the cheapest
global summary of the stratified readout is, at every prime-power level, a
polynomial-time computable quantity. -/
theorem zolotarev_prime_pow (hp : p.Prime) (hodd : p ≠ 2)
    (hcop : Nat.Coprime a p) :
    haveI : NeZero (p ^ k) := ⟨pow_ne_zero k hp.pos.ne'⟩
    (jacobiSym (a : ℤ) (p ^ k) = 1 ↔ (p ^ k - cycleCount (p ^ k) a) % 2 = 0) := by
  haveI : NeZero (p ^ k) := ⟨pow_ne_zero k hp.pos.ne'⟩
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  have hane : ((a : ZMod p)) ≠ 0 := by
    intro h
    have hdvd : p ∣ a := (ZMod.natCast_eq_zero_iff a p).mp h
    have : p = 1 := Nat.Coprime.eq_one_of_dvd hcop.symm hdvd
    exact hp.ne_one this
  have hcast : (((a : ℤ) : ZMod p)) ≠ 0 := by push_cast; exact hane
  have hleg : legendreSym p (a : ℤ) = 1 ↔ IsSquare ((a : ZMod p)) := by
    rw [legendreSym.eq_one_iff p hcast]
    push_cast
    rfl
  have hlegpm : legendreSym p (a : ℤ) = 1 ∨ legendreSym p (a : ℤ) = -1 :=
    legendreSym.eq_one_or_neg_one p hcast
  have hjac : jacobiSym (a : ℤ) (p ^ k) = (legendreSym p (a : ℤ)) ^ k := by
    rw [jacobiSym.pow_right, jacobiSym.legendreSym.to_jacobiSym]
  have hpar := parity_cycleCount_prime_pow (k := k) hp hodd hcop
  have hsq := isSquare_iff_even_index hp hodd hcop
  set i := (p - 1) / orderOf ((a : ZMod p)) with hidef
  rw [hjac, hpar]
  rcases hlegpm with h1 | h1
  · have hieven : i % 2 = 0 := hsq.mp (hleg.mp h1)
    simp [h1, hieven, Nat.mul_mod]
  · have hiodd : i % 2 = 1 := by
      by_contra hcontra
      have h0 : i % 2 = 0 := by omega
      have hsqa : IsSquare ((a : ZMod p)) := hsq.mpr h0
      have hone := hleg.mpr hsqa
      rw [h1] at hone
      norm_num at hone
    rw [h1]
    rcases Nat.even_or_odd k with hkev | hkodd
    · obtain ⟨t, ht⟩ := hkev
      constructor
      · intro _
        rw [Nat.mul_mod, hiodd]
        simp [ht, show t + t = 2 * t by ring]
      · intro _
        rw [show k = 2 * t by omega, pow_mul]
        norm_num
    · obtain ⟨t, ht⟩ := hkodd
      constructor
      · intro hcon
        rw [ht, pow_succ, pow_mul] at hcon
        norm_num at hcon
      · intro hcon
        exfalso
        rw [Nat.mul_mod, hiodd, ht] at hcon
        simp [Nat.add_mod] at hcon

end PrimePower

end Physics.PermReadout