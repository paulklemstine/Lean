import Geometry.PowerSumFactorReveal

/-!
# Cycle 3: the power-sum reveal at a prime power

The squarefree theory of `Geometry.PowerSumSquarefree` rests on the Fermat evaluation
`∑_{x : ZMod p} x^k = -1` (if `(p-1) ∣ k`) or `0`.  This file removes the squarefreeness
restriction at odd primes by proving the prime-power analogue

`∑_{a < p^e} a^k ≡ -p^{e-1} (mod p^e)` if `(p-1) ∣ k`, and `≡ 0 (mod p^e)` otherwise,

for every odd prime `p`, every `e ≥ 1` and every `k ≥ 1`.  Note the exponent: the
condition is `(p-1) ∣ k`, **not** `λ(p^e) = p^{e-1}(p-1) ∣ k`; the extra `p`-part of the
unit group plays no role.  (Numerically: for `p^e = 9` the sum is `≡ 6 = -3` for every
even `k`, not only for `k` divisible by `6`.)

The proof is an induction on `e` using the "lift the exponent" step

`∑_{a < p^e} a^k ≡ p · ∑_{a < p^{e-1}} a^k (mod p^e)`,

obtained by writing `a = p^{e-1} j + r` and expanding binomially: the square of
`p^{e-1}` vanishes mod `p^e`, and the linear term carries the Gauss sum
`∑_{j<p} j = p(p-1)/2`, which is divisible by `p` precisely because `p` is odd.

Consequences: for `N = p^e * m` with `p ∤ m`,

`gcd (powerSum N k, p^e) = if (p-1) ∣ k then p^{e-1} else p^e`,

so a prime power `p^e ‖ N` is revealed in full unless `(p-1) ∣ k`, in which case exactly
one power of `p` is lost.  This is the correct generalisation of the semiprime master
formula to non-squarefree moduli.

## Main results

* `PowerSumReveal.sum_range_pow_prime_pow` — the prime-power Fermat sum.
* `PowerSumReveal.powerSum_prime_pow_dvd` / `powerSum_prime_pow_not_dvd`.
* `PowerSumReveal.gcd_powerSum_prime_pow` — the prime-power master formula.
-/

namespace PowerSumReveal

open Finset

/-! ## Two elementary tools -/

/-- Splitting a range of length `M * t` into `t` blocks of length `M`. -/
theorem sum_range_block {R : Type*} [AddCommMonoid R] (M : ℕ) (f : ℕ → R) (t : ℕ) :
    ∑ a ∈ range (M * t), f a = ∑ j ∈ range t, ∑ r ∈ range M, f (M * j + r) := by
  induction t with
  | zero => simp
  | succ t ih =>
      have h : M * (t + 1) = M * t + M := by ring
      rw [h, Finset.sum_range_add, ih, Finset.sum_range_succ]

/-- Binomial expansion when the increment squares to zero. -/
theorem add_pow_of_sq_eq_zero {R : Type*} [CommRing R] (x y : R) (hy : y ^ 2 = 0) (k : ℕ) :
    (x + y) ^ (k + 1) = x ^ (k + 1) + (k + 1) * x ^ k * y := by
  induction k with
  | zero => simp
  | succ k ih =>
      have h : (x + y) ^ (k + 2) = (x + y) ^ (k + 1) * (x + y) := by ring
      rw [h, ih]; push_cast; linear_combination ((k : R) + 1) * x ^ k * hy

/-! ## Lifting the exponent -/

/-- **Lift-the-exponent step.**  For an odd prime `p` and `e ≥ 2`,
`∑_{a < p^e} a^k ≡ p · ∑_{r < p^{e-1}} r^k (mod p^e)` for every `k ≥ 1`. -/
theorem sum_pow_zmod_step (p e k' : ℕ) (hp : p.Prime) (hodd : p ≠ 2) (he : 2 ≤ e) :
    (∑ a ∈ range (p ^ e), (a : ZMod (p ^ e)) ^ (k' + 1))
      = (p : ZMod (p ^ e)) * ∑ r ∈ range (p ^ (e - 1)), (r : ZMod (p ^ e)) ^ (k' + 1) := by
  obtain ⟨c, hc⟩ : ∃ c, p - 1 = 2 * c := by
    obtain ⟨m, hm⟩ := hp.odd_of_ne_two hodd
    exact ⟨m, by omega⟩
  set M := p ^ (e - 1) with hM
  have hMe : M * p = p ^ e := by
    rw [hM, ← pow_succ]; congr 1; omega
  have hMsq : ((M : ZMod (p ^ e))) ^ 2 = 0 := by
    have hd : (p : ℕ) ^ e ∣ M ^ 2 := by
      rw [hM, ← pow_mul]; exact pow_dvd_pow p (by omega)
    have h := (ZMod.natCast_eq_zero_iff (M ^ 2) (p ^ e)).2 hd
    push_cast at h
    exact h
  have hMp : (M : ZMod (p ^ e)) * (p : ZMod (p ^ e)) = 0 := by
    have h : ((M * p : ℕ) : ZMod (p ^ e)) = 0 := by
      rw [hMe]; exact (ZMod.natCast_eq_zero_iff _ _).2 dvd_rfl
    push_cast at h; exact h
  have hgauss : ∑ i ∈ range p, i = p * c := by
    have h2 := Finset.sum_range_id_mul_two p
    have h3 : p * (p - 1) = 2 * (p * c) := by rw [hc]; ring
    omega
  have key : ∀ j ∈ range p, ∑ r ∈ range M, ((M * j + r : ℕ) : ZMod (p ^ e)) ^ (k' + 1)
      = (∑ r ∈ range M, (r : ZMod (p ^ e)) ^ (k' + 1))
        + (((k' : ZMod (p ^ e)) + 1) * (∑ r ∈ range M, (r : ZMod (p ^ e)) ^ k'))
          * ((M : ZMod (p ^ e)) * j) := by
    intro j _
    have hy : ((M : ZMod (p ^ e)) * j) ^ 2 = 0 := by
      have h : ((M : ZMod (p ^ e)) * j) ^ 2
          = (M : ZMod (p ^ e)) ^ 2 * (j : ZMod (p ^ e)) ^ 2 := by ring
      rw [h, hMsq, zero_mul]
    have hterm : ∀ r ∈ range M, ((M * j + r : ℕ) : ZMod (p ^ e)) ^ (k' + 1)
        = (r : ZMod (p ^ e)) ^ (k' + 1)
          + ((k' : ZMod (p ^ e)) + 1) * (r : ZMod (p ^ e)) ^ k' * ((M : ZMod (p ^ e)) * j) := by
      intro r _
      push_cast
      rw [add_comm ((M : ZMod (p ^ e)) * j) (r : ZMod (p ^ e))]
      exact add_pow_of_sq_eq_zero (r : ZMod (p ^ e)) ((M : ZMod (p ^ e)) * j) hy k'
    rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.sum_mul,
      ← Finset.mul_sum]
  calc ∑ a ∈ range (p ^ e), (a : ZMod (p ^ e)) ^ (k' + 1)
      = ∑ j ∈ range p, ∑ r ∈ range M, ((M * j + r : ℕ) : ZMod (p ^ e)) ^ (k' + 1) := by
        rw [← hMe, sum_range_block]
    _ = ∑ _j ∈ range p, ((∑ r ∈ range M, (r : ZMod (p ^ e)) ^ (k' + 1))
          + (((k' : ZMod (p ^ e)) + 1) * (∑ r ∈ range M, (r : ZMod (p ^ e)) ^ k'))
            * ((M : ZMod (p ^ e)) * _j)) := Finset.sum_congr rfl key
    _ = (p : ZMod (p ^ e)) * ∑ r ∈ range M, (r : ZMod (p ^ e)) ^ (k' + 1) := by
        rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
        have hj : ∑ i ∈ range p, (i : ZMod (p ^ e)) = ((p * c : ℕ) : ZMod (p ^ e)) := by
          rw [← hgauss]; push_cast; rfl
        have hzero : (M : ZMod (p ^ e)) * ((p * c : ℕ) : ZMod (p ^ e)) = 0 := by
          push_cast; rw [← mul_assoc, hMp, zero_mul]
        rw [hj, hzero, mul_zero, add_zero, Finset.sum_const, Finset.card_range, nsmul_eq_mul]

/-! ## The prime-power Fermat sum -/

/-- The integer power sum over a complete residue system. -/
def intPowerSum (M k : ℕ) : ℤ := ∑ a ∈ range M, (a : ℤ) ^ k

lemma intPowerSum_cast (M k : ℕ) [NeZero M] :
    ((intPowerSum M k : ℤ) : ZMod M) = ∑ a ∈ range M, (a : ZMod M) ^ k := by
  unfold intPowerSum
  push_cast
  rfl

/-- **Prime-power Fermat sum.**  For an odd prime `p`, `e ≥ 1` and `k ≥ 1`,
`∑_{a < p^e} a^k ≡ -p^{e-1} (mod p^e)` when `(p-1) ∣ k`, and `≡ 0 (mod p^e)` otherwise. -/
theorem sum_range_pow_prime_pow (p : ℕ) (hp : p.Prime) (hodd : p ≠ 2) {k : ℕ} (hk : k ≠ 0) :
    ∀ e : ℕ, 1 ≤ e →
      intPowerSum (p ^ e) k ≡ (if (p - 1) ∣ k then -(p : ℤ) ^ (e - 1) else 0) [ZMOD (p ^ e : ℕ)] := by
  haveI : Fact p.Prime := ⟨hp⟩
  intro e
  induction e with
  | zero => intro h; exact absurd h (by omega)
  | succ e ih =>
      intro _
      rcases Nat.eq_zero_or_pos e with rfl | he
      · -- base case `e = 1`: the classical Fermat power sum
        simp only [Nat.sub_self, pow_zero]
        have hbase : ((intPowerSum p k : ℤ) : ZMod p) = ((if (p - 1) ∣ k then -1 else 0 : ℤ) : ZMod p) := by
          rw [intPowerSum_cast p k, sum_range_modCast p (fun x => x ^ k), sum_pow_zmod p hk]
          split <;> push_cast <;> simp
        have := (ZMod.intCast_eq_intCast_iff _ _ _).1 hbase
        simpa using this
      · -- inductive step
        have he2 : 2 ≤ e + 1 := by omega
        have hstep : intPowerSum (p ^ (e + 1)) k ≡ (p : ℤ) * intPowerSum (p ^ e) k [ZMOD (p ^ (e + 1) : ℕ)] := by
          obtain ⟨k', rfl⟩ : ∃ k', k = k' + 1 := ⟨k - 1, by omega⟩
          refine (ZMod.intCast_eq_intCast_iff _ _ _).1 ?_
          have h := sum_pow_zmod_step p (e + 1) k' hp hodd he2
          simp only [Nat.add_sub_cancel] at h
          rw [intPowerSum_cast (p ^ (e + 1)) (k' + 1)]
          push_cast
          rw [h]
          congr 1
          rw [intPowerSum]
          push_cast
          rfl
        have hIH := ih he
        have hmul : (p : ℤ) * intPowerSum (p ^ e) k
            ≡ (p : ℤ) * (if (p - 1) ∣ k then -(p : ℤ) ^ (e - 1) else 0)
              [ZMOD ((p : ℤ) * (p ^ e : ℕ))] := Int.ModEq.mul_left' hIH
        have hmod : ((p : ℤ) * (p ^ e : ℕ)) = ((p ^ (e + 1) : ℕ) : ℤ) := by
          push_cast; ring
        rw [hmod] at hmul
        have hval : (p : ℤ) * (if (p - 1) ∣ k then -(p : ℤ) ^ (e - 1) else 0)
            = (if (p - 1) ∣ k then -(p : ℤ) ^ (e + 1 - 1) else 0) := by
          have hee : e + 1 - 1 = (e - 1) + 1 := by omega
          rw [hee]
          split
          · rw [pow_succ]; ring
          · ring
        rw [hval] at hmul
        exact hstep.trans hmul

/-! ## Consequences for the power sum -/

/-- The power sum of `N = p^e * m` reduced modulo `p^e`. -/
theorem powerSum_prime_pow_cast (p e m : ℕ) (hp : p.Prime) (hodd : p ≠ 2) (he : 1 ≤ e)
    {k : ℕ} (hk : k ≠ 0) :
    ((powerSum (p ^ e * m) k : ℕ) : ℤ)
      ≡ (m : ℤ) * (if (p - 1) ∣ k then -(p : ℤ) ^ (e - 1) else 0) [ZMOD (p ^ e : ℕ)] := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero (p ^ e) := ⟨pow_ne_zero _ hp.pos.ne'⟩
  refine (ZMod.intCast_eq_intCast_iff _ _ _).1 ?_
  have h1 : ((powerSum (p ^ e * m) k : ℕ) : ZMod (p ^ e))
      = (m : ZMod (p ^ e)) * ∑ x : ZMod (p ^ e), x ^ k := powerSum_cast (p ^ e) m hk
  have h2 : ∑ x : ZMod (p ^ e), x ^ k = ∑ a ∈ range (p ^ e), (a : ZMod (p ^ e)) ^ k :=
    (sum_range_modCast (p ^ e) (fun x => x ^ k)).symm
  have h3 : ((intPowerSum (p ^ e) k : ℤ) : ZMod (p ^ e))
      = ((if (p - 1) ∣ k then -(p : ℤ) ^ (e - 1) else 0 : ℤ) : ZMod (p ^ e)) :=
    (ZMod.intCast_eq_intCast_iff _ _ _).2 (sum_range_pow_prime_pow p hp hodd hk e he)
  rw [intPowerSum_cast (p ^ e) k] at h3
  push_cast at h1 h3 ⊢
  rw [h1, h2, h3]

/-- If `(p-1) ∤ k` then the *whole* prime power `p^e ‖ N` divides the power sum. -/
theorem powerSum_prime_pow_dvd {p e m k : ℕ} (hp : p.Prime) (hodd : p ≠ 2) (he : 1 ≤ e)
    (hk : k ≠ 0) (hdk : ¬ (p - 1) ∣ k) : p ^ e ∣ powerSum (p ^ e * m) k := by
  have h := powerSum_prime_pow_cast p e m hp hodd he hk (k := k)
  rw [if_neg hdk, mul_zero] at h
  have hz : ((p ^ e : ℕ) : ℤ) ∣ ((powerSum (p ^ e * m) k : ℕ) : ℤ) :=
    Int.modEq_zero_iff_dvd.1 h
  exact_mod_cast hz

/-- If `(p-1) ∣ k` then exactly one power of `p` is lost: `p^{e-1}` divides the power sum
but `p^e` does not (assuming `p ∤ m`). -/
theorem powerSum_prime_pow_not_dvd {p e m k : ℕ} (hp : p.Prime) (hodd : p ≠ 2) (he : 1 ≤ e)
    (hk : k ≠ 0) (hdk : (p - 1) ∣ k) (hm : ¬ p ∣ m) :
    p ^ (e - 1) ∣ powerSum (p ^ e * m) k ∧ ¬ p ^ e ∣ powerSum (p ^ e * m) k := by
  have h := powerSum_prime_pow_cast p e m hp hodd he hk (k := k)
  rw [if_pos hdk] at h
  have hdvd : ((p ^ e : ℕ) : ℤ) ∣ ((powerSum (p ^ e * m) k : ℕ) : ℤ)
      + (m : ℤ) * (p : ℤ) ^ (e - 1) := by
    have h1 := Int.ModEq.dvd h.symm
    have h2 : ((powerSum (p ^ e * m) k : ℕ) : ℤ) - (m : ℤ) * -(p : ℤ) ^ (e - 1)
        = ((powerSum (p ^ e * m) k : ℕ) : ℤ) + (m : ℤ) * (p : ℤ) ^ (e - 1) := by ring
    rwa [h2] at h1
  constructor
  · -- `p^{e-1}` divides the sum
    have hple : ((p ^ (e - 1) : ℕ) : ℤ) ∣ ((p ^ e : ℕ) : ℤ) := by
      push_cast
      exact pow_dvd_pow (p : ℤ) (by omega)
    have h3 : ((p ^ (e - 1) : ℕ) : ℤ) ∣ ((powerSum (p ^ e * m) k : ℕ) : ℤ) := by
      have h4 : ((p ^ (e - 1) : ℕ) : ℤ) ∣ (m : ℤ) * (p : ℤ) ^ (e - 1) := by
        push_cast
        exact Dvd.intro_left _ rfl
      have h5 := dvd_trans hple hdvd
      exact (dvd_add_right h4).mp (by rwa [add_comm] at h5)
    exact_mod_cast h3
  · -- but `p^e` does not
    intro hcon
    have hcon' : ((p ^ e : ℕ) : ℤ) ∣ ((powerSum (p ^ e * m) k : ℕ) : ℤ) := by exact_mod_cast hcon
    have hfin : ((p ^ e : ℕ) : ℤ) ∣ (m : ℤ) * (p : ℤ) ^ (e - 1) :=
      (dvd_add_right hcon').mp hdvd
    have hnat : p ^ e ∣ m * p ^ (e - 1) := by exact_mod_cast hfin
    have hsplit : p ^ e = p ^ (e - 1) * p := by
      rw [← pow_succ]; congr 1; omega
    rw [hsplit] at hnat
    have hnat' : p ^ (e - 1) * p ∣ p ^ (e - 1) * m := by
      rwa [mul_comm (p ^ (e - 1)) m]
    have hpos : 0 < p ^ (e - 1) := pow_pos hp.pos _
    exact hm ((mul_dvd_mul_iff_left hpos.ne').mp hnat')

/-- **Prime-power master formula.**  For `N = p^e * m` with `p` an odd prime, `p ∤ m`,
`e ≥ 1` and `k ≥ 1`:
`gcd (powerSum N k, p^e) = if (p-1) ∣ k then p^{e-1} else p^e`. -/
theorem gcd_powerSum_prime_pow {p e m k : ℕ} (hp : p.Prime) (hodd : p ≠ 2) (he : 1 ≤ e)
    (hk : k ≠ 0) (hm : ¬ p ∣ m) :
    Nat.gcd (powerSum (p ^ e * m) k) (p ^ e)
      = if (p - 1) ∣ k then p ^ (e - 1) else p ^ e := by
  by_cases hdk : (p - 1) ∣ k
  · rw [if_pos hdk]
    obtain ⟨hlow, hhigh⟩ := powerSum_prime_pow_not_dvd hp hodd he hk hdk hm
    have hg : Nat.gcd (powerSum (p ^ e * m) k) (p ^ e) ∣ p ^ e := Nat.gcd_dvd_right _ _
    obtain ⟨i, hi, hgi⟩ := (Nat.dvd_prime_pow hp).1 hg
    have hle : p ^ (e - 1) ∣ Nat.gcd (powerSum (p ^ e * m) k) (p ^ e) :=
      Nat.dvd_gcd hlow (pow_dvd_pow p (by omega))
    have hine : i ≠ e := by
      intro hie
      have hd : Nat.gcd (powerSum (p ^ e * m) k) (p ^ e) ∣ powerSum (p ^ e * m) k :=
        Nat.gcd_dvd_left _ _
      rw [hgi, hie] at hd
      exact hhigh hd
    have hige : e - 1 ≤ i := by
      rw [hgi] at hle
      exact (Nat.pow_dvd_pow_iff_le_right hp.one_lt).1 hle
    have : i = e - 1 := by omega
    rw [hgi, this]
  · rw [if_neg hdk]
    exact Nat.gcd_eq_right (powerSum_prime_pow_dvd hp hodd he hk hdk)

end PowerSumReveal