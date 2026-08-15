import Mathlib

/-!
# Power-sum factor reveal for squarefree moduli

For a modulus `N` let
`F(N, k) = ∑_{a = 1}^{N} a ^ k`  (`PowerSumReveal.powerSum`).

The central observation is a **complete local computation**: if `p` is a prime
dividing `N` and `k ≥ 1`, then modulo `p` the interval `{1, …, N}` covers each
residue class exactly `N / p` times, so

`F(N, k) ≡ (N / p) · ∑_{x ∈ ZMod p} x ^ k ≡ (N / p) · (if (p-1) ∣ k then -1 else 0)  (mod p)`.

For squarefree `N` this gives the exact criterion

`p ∣ F(N, k) ↔ ¬ (p - 1) ∣ k`,

hence the exact evaluation of the gcd

`gcd (F(N, k), N) = ∏ { p ∈ N.primeFactors | ¬ (p - 1) ∣ k }`,

which for a semiprime `N = p q` specialises to
`gcd (F(N, k), N) = (if (p-1) ∣ k then 1 else p) * (if (q-1) ∣ k then 1 else q)`,
and in particular `gcd (F(N, p-1), N) = q` whenever `(q-1) ∤ (p-1)`.

Main results:

* `sum_pow_zmod` — `∑_{x : ZMod p} x ^ k = if (p-1) ∣ k then -1 else 0` for `k ≠ 0`.
* `cast_powerSum` — the local formula for `F(N,k)` modulo a prime divisor of `N`.
* `prime_dvd_powerSum_iff` — `p ∣ F(N,k) ↔ ¬ (p-1) ∣ k` for squarefree `N`.
* `gcd_powerSum_semiprime` — Theorem 1, in exact (all `k`) form.
* `powerSum_reveal` — the factoring corollary at `k = p - 1`.
* `gcd_powerSum_squarefree` — the general squarefree product formula.
* `gcd_powerSum_eq_one_iff` — the gcd is `1` exactly on multiples of the
  Carmichael function `λ(N) = lcm_{p ∣ N} (p-1)`.
-/

namespace PowerSumReveal

open Finset

/-! ## The local sum over `ZMod p` -/

/-- **Fermat/Euler power sum.**  For `k ≠ 0` the sum of `k`-th powers over all of
`ZMod p` is `-1` when `(p-1) ∣ k` and `0` otherwise. -/
theorem sum_pow_zmod (p : ℕ) [Fact p.Prime] {k : ℕ} (hk : k ≠ 0) :
    ∑ x : ZMod p, x ^ k = if (p - 1) ∣ k then -1 else 0 := by
  have h1 : ∑ x : (ZMod p)ˣ, ((x : ZMod p)) ^ k
      = if Fintype.card (ZMod p) - 1 ∣ k then -1 else 0 :=
    FiniteField.sum_pow_units (ZMod p) k
  rw [ZMod.card p] at h1
  rw [← h1]
  have h2 : ∑ x : (ZMod p)ˣ, ((x : ZMod p)) ^ k = ∑ x : {y : ZMod p // y ≠ 0}, ((x : ZMod p)) ^ k :=
    Fintype.sum_equiv (unitsEquivNeZero) _ _ (fun _ => rfl)
  rw [h2, ← Finset.sum_subtype (Finset.univ.erase (0 : ZMod p)) (by intro x; simp) (fun x => x ^ k)]
  exact (Finset.sum_erase _ (by simp [hk])).symm

/-- A block of `p` consecutive naturals starting at `0` hits every residue exactly once:
the general statement, for an arbitrary function on `ZMod p`. -/
theorem sum_range_cast {M : Type*} [AddCommMonoid M] (p : ℕ) [NeZero p] (g : ZMod p → M) :
    ∑ a ∈ range p, g (a : ZMod p) = ∑ x : ZMod p, g x := by
  refine Finset.sum_nbij' (i := fun a => (a : ZMod p)) (j := fun x => x.val) ?_ ?_ ?_ ?_ ?_ <;>
    intros <;> simp_all [ZMod.natCast_val, ZMod.val_lt, Nat.mod_eq_of_lt]

/-- `{0, …, m p - 1}` covers each residue class modulo `p` exactly `m` times. -/
theorem sum_range_mul_cast {M : Type*} [AddCommMonoid M] (p : ℕ) [NeZero p] (g : ZMod p → M)
    (m : ℕ) : ∑ a ∈ range (m * p), g (a : ZMod p) = m • (∑ x : ZMod p, g x) := by
  have hrange : ∀ n : ℕ, ∑ a ∈ range p, g ((n * p + a : ℕ) : ZMod p) = ∑ x : ZMod p, g x := by
    intro n
    rw [← sum_range_cast p g]
    refine Finset.sum_congr rfl ?_
    intro a _
    congr 1
    push_cast [ZMod.natCast_self]
    ring
  induction m with
  | zero => simp
  | succ m ih =>
      have h : (m + 1) * p = m * p + p := by ring
      rw [h, Finset.sum_range_add, ih, hrange, succ_nsmul]

/-- Monomial specialisation of `sum_range_mul_cast`. -/
theorem sum_range_mul_cast_pow (p : ℕ) [NeZero p] (k m : ℕ) :
    ∑ a ∈ range (m * p), ((a : ZMod p)) ^ k = m • (∑ x : ZMod p, x ^ k) :=
  sum_range_mul_cast p (fun x => x ^ k) m

/-! ## The power sum and its local values -/

/-- `F(N, k) = ∑_{a=1}^{N} a ^ k`. -/
def powerSum (N k : ℕ) : ℕ := ∑ a ∈ Finset.Icc 1 N, a ^ k

@[simp] theorem powerSum_one (k : ℕ) : powerSum 1 k = 1 := by simp [powerSum]

/-- **Local formula.**  Modulo a prime divisor `p` of `N`, the power sum collapses to
`(N/p) · (if (p-1) ∣ k then -1 else 0)`. -/
theorem cast_powerSum (N p k : ℕ) (hp : p.Prime) (hpN : p ∣ N) (hk : k ≠ 0) :
    ((powerSum N k : ℕ) : ZMod p) = (N / p) • (if (p - 1) ∣ k then (-1 : ZMod p) else 0) := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hcast : ((powerSum N k : ℕ) : ZMod p) = ∑ a ∈ Finset.Icc 1 N, ((a : ZMod p)) ^ k := by
    simp [powerSum]
  have hins : Finset.range (N + 1) = insert 0 (Finset.Icc 1 N) := by
    ext x; simp [Finset.mem_Icc]; omega
  have h1 : ∑ a ∈ Finset.range (N + 1), ((a : ZMod p)) ^ k
      = ∑ a ∈ Finset.Icc 1 N, ((a : ZMod p)) ^ k := by
    rw [hins, Finset.sum_insert (by simp)]
    simp [hk]
  have h2 : ∑ a ∈ Finset.range (N + 1), ((a : ZMod p)) ^ k
      = ∑ a ∈ Finset.range N, ((a : ZMod p)) ^ k := by
    rw [Finset.sum_range_succ, (ZMod.natCast_eq_zero_iff N p).mpr hpN]
    simp [hk]
  have hN : N = (N / p) * p := (Nat.div_mul_cancel hpN).symm
  rw [hcast, ← h1, h2, show (Finset.range N) = Finset.range ((N / p) * p) by rw [← hN],
    sum_range_mul_cast_pow p k (N / p), sum_pow_zmod p hk]

/-- In a squarefree modulus a prime divisor does not divide the complementary cofactor. -/
theorem not_dvd_div_of_squarefree {N p : ℕ} (hsq : Squarefree N) (hpN : p ∣ N) (hp : p.Prime) :
    ¬ p ∣ N / p := by
  intro h
  have hNp : N = (N / p) * p := (Nat.div_mul_cancel hpN).symm
  obtain ⟨c, hc⟩ := h
  have : p * p ∣ N := ⟨c, by rw [hNp, hc]; ring⟩
  exact hp.not_isUnit (hsq p this)

/-- **Exact local criterion.**  For squarefree `N`, a prime divisor `p` of `N` divides
`F(N,k)` precisely when `(p-1) ∤ k`. -/
theorem prime_dvd_powerSum_iff {N p k : ℕ} (hp : p.Prime) (hpN : p ∣ N) (hsq : Squarefree N)
    (hk : k ≠ 0) : p ∣ powerSum N k ↔ ¬ (p - 1) ∣ k := by
  haveI : Fact p.Prime := ⟨hp⟩
  rw [← ZMod.natCast_eq_zero_iff (powerSum N k) p, cast_powerSum N p k hp hpN hk]
  by_cases hd : (p - 1) ∣ k
  · simp only [hd, if_true, not_true_eq_false, iff_false]
    intro h
    have h' : ((N / p : ℕ) : ZMod p) = 0 := by
      rw [nsmul_eq_mul] at h
      simpa using h
    exact not_dvd_div_of_squarefree hsq hpN hp ((ZMod.natCast_eq_zero_iff _ p).mp h')
  · simp [hd]

/-! ## The gcd evaluation -/

/-- For two distinct primes the gcd with `p*q` is read off from divisibility by `p` and `q`. -/
theorem gcd_two_primes {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (m : ℕ) :
    Nat.gcd m (p * q) = (if p ∣ m then p else 1) * (if q ∣ m then q else 1) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  by_cases hpm : p ∣ m <;> by_cases hqm : q ∣ m
  · have hdvd : p * q ∣ m := Nat.Coprime.mul_dvd_of_dvd_of_dvd hcop hpm hqm
    simp [hpm, hqm, Nat.gcd_eq_right hdvd]
  · have hcq : Nat.Coprime m q := (Nat.Prime.coprime_iff_not_dvd hq).mpr hqm |>.symm
    have h1 : Nat.gcd m (p * q) = Nat.gcd m p := Nat.gcd_mul_left_right_of_gcd_eq_one hcq
    simp [hpm, hqm, h1, Nat.gcd_eq_right hpm]
  · have hcp : Nat.Coprime m p := (Nat.Prime.coprime_iff_not_dvd hp).mpr hpm |>.symm
    have h1 : Nat.gcd m (p * q) = Nat.gcd m q :=
      Nat.Coprime.gcd_mul_left_cancel_right q hcp.symm
    simp [hpm, hqm, h1, Nat.gcd_eq_right hqm]
  · have hcp : Nat.Coprime m p := (Nat.Prime.coprime_iff_not_dvd hp).mpr hpm |>.symm
    have hcq : Nat.Coprime m q := (Nat.Prime.coprime_iff_not_dvd hq).mpr hqm |>.symm
    simp [hpm, hqm, Nat.Coprime.mul_right hcp hcq]

/-- A semiprime is squarefree. -/
theorem squarefree_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    Squarefree (p * q) :=
  Nat.squarefree_mul_iff.mpr ⟨(Nat.coprime_primes hp hq).mpr hpq, hp.squarefree, hq.squarefree⟩

/-- **Theorem 1 (power-sum factor reveal), exact form.**  For a semiprime `N = p q` and any
exponent `k ≥ 1`,
`gcd (F(N,k), N) = (if (p-1) ∣ k then 1 else p) * (if (q-1) ∣ k then 1 else q)`. -/
theorem gcd_powerSum_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {k : ℕ}
    (hk : k ≠ 0) :
    Nat.gcd (powerSum (p * q) k) (p * q)
      = (if (p - 1) ∣ k then 1 else p) * (if (q - 1) ∣ k then 1 else q) := by
  have hsq := squarefree_semiprime hp hq hpq
  have hpdvd : p ∣ powerSum (p * q) k ↔ ¬ (p - 1) ∣ k :=
    prime_dvd_powerSum_iff hp ⟨q, rfl⟩ hsq hk
  have hqdvd : q ∣ powerSum (p * q) k ↔ ¬ (q - 1) ∣ k :=
    prime_dvd_powerSum_iff hq ⟨p, mul_comm p q⟩ hsq hk
  rw [gcd_two_primes hp hq hpq]
  by_cases h1 : (p - 1) ∣ k <;> by_cases h2 : (q - 1) ∣ k <;>
    simp [h1, h2, hpdvd, hqdvd]

/-- **Factoring corollary.**  If `(q-1) ∤ (p-1)` then the single gcd
`gcd (F(pq, p-1), pq)` equals `q`: the power sum reveals the factor `q`. -/
theorem powerSum_reveal {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hdvd : ¬ (q - 1) ∣ (p - 1)) :
    Nat.gcd (powerSum (p * q) (p - 1)) (p * q) = q := by
  have hk : p - 1 ≠ 0 := by
    have := hp.two_le; omega
  rw [gcd_powerSum_semiprime hp hq hpq hk]
  simp [hdvd]

/-- Symmetric form: `gcd (F(pq, q-1), pq) = p` when `(p-1) ∤ (q-1)`. -/
theorem powerSum_reveal' {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hdvd : ¬ (p - 1) ∣ (q - 1)) :
    Nat.gcd (powerSum (p * q) (q - 1)) (p * q) = p := by
  have hk : q - 1 ≠ 0 := by
    have := hq.two_le; omega
  rw [gcd_powerSum_semiprime hp hq hpq hk]
  simp [hdvd]

/-! ## The general squarefree formula -/

/-- **General reveal theorem.**  For squarefree `N ≥ 1` and `k ≥ 1`,
`gcd (F(N,k), N)` is exactly the product of the prime divisors `p` of `N`
with `(p-1) ∤ k`. -/
theorem gcd_powerSum_squarefree {N k : ℕ} (hN : N ≠ 0) (hsq : Squarefree N) (hk : k ≠ 0) :
    Nat.gcd (powerSum N k) N = ∏ p ∈ N.primeFactors.filter (fun p => ¬ (p - 1) ∣ k), p := by
  classical
  set S : Finset ℕ := N.primeFactors.filter (fun p => ¬ (p - 1) ∣ k) with hS
  refine Nat.dvd_antisymm ?_ ?_
  · -- gcd divides the product: the gcd is squarefree and all its prime factors lie in `S`
    have hgN : Nat.gcd (powerSum N k) N ∣ N := Nat.gcd_dvd_right _ _
    have hgsq : Squarefree (Nat.gcd (powerSum N k) N) := hsq.squarefree_of_dvd hgN
    have hg0 : Nat.gcd (powerSum N k) N ≠ 0 := by
      intro h
      exact hN (Nat.eq_zero_of_gcd_eq_zero_right h)
    have hprod : ∏ p ∈ (Nat.gcd (powerSum N k) N).primeFactors, p = Nat.gcd (powerSum N k) N :=
      Nat.prod_primeFactors_of_squarefree hgsq
    rw [← hprod]
    refine Finset.prod_dvd_prod_of_subset _ _ _ ?_
    intro p hp
    have hpp : p.Prime := Nat.prime_of_mem_primeFactors hp
    have hpg : p ∣ Nat.gcd (powerSum N k) N := Nat.dvd_of_mem_primeFactors hp
    have hpN : p ∣ N := hpg.trans hgN
    have hpF : p ∣ powerSum N k := hpg.trans (Nat.gcd_dvd_left _ _)
    have : ¬ (p - 1) ∣ k := (prime_dvd_powerSum_iff hpp hpN hsq hk).mp hpF
    simp [hS, Nat.mem_primeFactors, hpp, hpN, hN, this]
  · -- the product divides the gcd
    have hSN : ∀ p ∈ S, p.Prime ∧ p ∣ N ∧ p ∣ powerSum N k := by
      intro p hp
      rw [hS, Finset.mem_filter, Nat.mem_primeFactors] at hp
      obtain ⟨⟨hpp, hpN, _⟩, hk'⟩ := hp
      exact ⟨hpp, hpN, (prime_dvd_powerSum_iff hpp hpN hsq hk).mpr hk'⟩
    have hdvdN : (∏ p ∈ S, p) ∣ N := by
      refine Finset.prod_primes_dvd _ ?_ ?_
      · intro p hp; exact (hSN p hp).1.prime
      · intro p hp; exact (hSN p hp).2.1
    have hdvdF : (∏ p ∈ S, p) ∣ powerSum N k := by
      refine Finset.prod_primes_dvd _ ?_ ?_
      · intro p hp; exact (hSN p hp).1.prime
      · intro p hp; exact (hSN p hp).2.2
    exact Nat.dvd_gcd hdvdF hdvdN

/-- The Carmichael-type exponent of a squarefree modulus:
`λ(N) = lcm_{p ∣ N} (p - 1)`. -/
def lam (N : ℕ) : ℕ := N.primeFactors.lcm (fun p => p - 1)

/-- **Carmichael detection.**  For squarefree `N > 1` and `k ≥ 1`, the gcd is trivial exactly
when `k` is a multiple of `λ(N)`. -/
theorem gcd_powerSum_eq_one_iff {N k : ℕ} (hN : 1 < N) (hsq : Squarefree N) (hk : k ≠ 0) :
    Nat.gcd (powerSum N k) N = 1 ↔ lam N ∣ k := by
  classical
  have hN0 : N ≠ 0 := by omega
  rw [gcd_powerSum_squarefree hN0 hsq hk, lam, Finset.lcm_dvd_iff]
  constructor
  · intro h p hp
    by_contra hc
    have hmem : p ∈ N.primeFactors.filter (fun p => ¬ (p - 1) ∣ k) :=
      Finset.mem_filter.mpr ⟨hp, hc⟩
    have hpdvd : p ∣ ∏ p ∈ N.primeFactors.filter (fun p => ¬ (p - 1) ∣ k), p :=
      Finset.dvd_prod_of_mem _ hmem
    rw [h] at hpdvd
    exact (Nat.prime_of_mem_primeFactors hp).one_lt.ne' (Nat.dvd_one.mp hpdvd)
  · intro h
    refine Finset.prod_eq_one ?_
    intro p hp
    rw [Finset.mem_filter] at hp
    exact absurd (h p hp.1) hp.2

end PowerSumReveal