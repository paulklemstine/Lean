import Mathlib

/-!
# Power-sum GCD factoring: `gcd(∑_{a=1}^{N} a^k, N)` reveals the prime factors

Let `F(N,k) = ∑_{a=1}^{N} a^k` (`powerSum N k` below).  For a prime `r` dividing
`N` exactly once, the residues `1, …, N` cover each residue class mod `r` the
same number of times, so mod `r` the power sum collapses to a multiple of the
complete power sum `∑_{x : ZMod r} x^k`, which is the classical `-1`/`0`
dichotomy of finite fields.  The upshot is a *complete* characterisation

  `r ∣ F(N,k)  ↔  ¬ (r-1) ∣ k`      (`prime_dvd_powerSum_iff`)

from which the whole "factor reveal" phenomenon follows by elementary gcd
bookkeeping.

## Main results

* `sum_pow_univ_ZMod` : `∑ x : ZMod p, x^k = if (p-1) ∣ k then -1 else 0` for
  `k > 0` (the complete-power-sum dichotomy, including the zero element).
* `cast_powerSum` : `(F(p*q, k) : ZMod p) = q * (if (p-1) ∣ k then -1 else 0)`.
* `prime_dvd_powerSum_iff` : the divisibility characterisation above.
* `gcd_powerSum_semiprime` : for distinct primes `p q` and `k > 0`,
  `gcd (F(pq,k)) (pq) = (if (p-1) ∣ k then 1 else p) * (if (q-1) ∣ k then 1 else q)`.
* `gcd_powerSum_eq_factor` : **Theorem 1** — if `(q-1) ∤ (p-1)` then
  `gcd (F(pq, p-1)) (pq) = q`, a nontrivial factor of `N = pq`.
* `powerSum_coprime_iff_squarefree` : for squarefree `N`, `F(N,k)` is coprime to
  `N` exactly when every prime `r ∣ N` satisfies `(r-1) ∣ k` — the Carmichael
  condition.
-/

open Finset

namespace PowerSumGCD

/-- The power sum `F(N,k) = ∑_{a=1}^{N} a^k`. -/
def powerSum (N k : ℕ) : ℕ := ∑ a ∈ Finset.Icc 1 N, a ^ k

@[simp] lemma powerSum_zero (k : ℕ) : powerSum 0 k = 0 := by simp [powerSum]

lemma powerSum_succ (N k : ℕ) : powerSum (N + 1) k = powerSum N k + (N + 1) ^ k := by
  simp [powerSum, Finset.sum_Icc_succ_top (Nat.succ_le_succ (Nat.zero_le N))]

/-- For `k > 0` the power sum over `1, …, N` is the sum over `range N` plus the top term
(the `a = 0` term vanishes). -/
lemma powerSum_eq_sum_range_add (N k : ℕ) (hk : 0 < k) :
    powerSum N k = (∑ a ∈ Finset.range N, a ^ k) + N ^ k := by
  induction N with
  | zero => simp [powerSum, zero_pow hk.ne']
  | succ N ih => rw [powerSum_succ, ih, Finset.sum_range_succ]

section CastLemmas

variable {R : Type*} [AddCommMonoid R]

/-- Summing `f` over the canonical representatives `0, …, p-1` is summing over `ZMod p`. -/
lemma sum_range_cast (p : ℕ) [NeZero p] (f : ZMod p → R) :
    ∑ r ∈ Finset.range p, f (r : ZMod p) = ∑ x : ZMod p, f x := by
  refine Finset.sum_nbij (fun r => ((r : ℕ) : ZMod p)) ?_ ?_ ?_ ?_
  · intros; exact Finset.mem_univ _
  · intro a ha b hb hab
    simp only [Finset.mem_coe, Finset.mem_range] at ha hb
    have := congrArg ZMod.val hab
    rwa [ZMod.val_natCast_of_lt ha, ZMod.val_natCast_of_lt hb] at this
  · intro x _
    exact ⟨x.val, by simp [ZMod.val_lt], by simp [ZMod.natCast_val]⟩
  · intros; rfl

/-- The residues `0, …, pn-1` cover each class mod `p` exactly `n` times. -/
lemma sum_range_mul_cast (p : ℕ) [NeZero p] (f : ZMod p → R) (n : ℕ) :
    ∑ a ∈ Finset.range (p * n), f (a : ZMod p) = n • ∑ x : ZMod p, f x := by
  induction n with
  | zero => simp
  | succ n ih =>
    have h : p * (n + 1) = p * n + p := by ring
    rw [h, Finset.sum_range_add, ih, succ_nsmul]
    congr 1
    rw [← sum_range_cast p f]
    refine Finset.sum_congr rfl fun r _ => ?_
    congr 1
    push_cast
    simp

end CastLemmas

/-- **Complete power sum over a prime field.**  For `k > 0`,
`∑_{x ∈ ZMod p} x^k = -1` if `(p-1) ∣ k` and `0` otherwise. -/
theorem sum_pow_univ_ZMod (p : ℕ) [Fact p.Prime] {k : ℕ} (hk : 0 < k) :
    ∑ x : ZMod p, x ^ k = if (p - 1) ∣ k then -1 else 0 := by
  classical
  have h0 : ∑ x : ZMod p, x ^ k = ∑ x ∈ (univ : Finset (ZMod p)) \ {0}, x ^ k := by
    rw [← Finset.sum_sdiff ({0} : Finset (ZMod p)).subset_univ, Finset.sum_singleton,
      zero_pow hk.ne', add_zero]
  have h1 : ∑ x ∈ (univ : Finset (ZMod p)) \ {0}, x ^ k = ∑ x : (ZMod p)ˣ, (x ^ k : ZMod p) := by
    let φ : (ZMod p)ˣ ↪ ZMod p := ⟨fun x ↦ x, Units.val_injective⟩
    have hmap : univ.map φ = univ \ {0} := by
      ext x
      simpa only [Finset.mem_map, Finset.mem_univ, Function.Embedding.coeFn_mk, true_and,
        Finset.mem_sdiff, Finset.mem_singleton, φ] using isUnit_iff_ne_zero
    simp [φ, ← hmap, univ.sum_map φ]
  rw [h0, h1, FiniteField.sum_pow_units (ZMod p) k]
  simp [ZMod.card]

/-- The power sum modulo a prime factor `p` of `N = p * q`. -/
theorem cast_powerSum (p q : ℕ) [Fact p.Prime] {k : ℕ} (hk : 0 < k) :
    ((powerSum (p * q) k : ℕ) : ZMod p) = (q : ZMod p) * (if (p - 1) ∣ k then -1 else 0) := by
  have hp : p ≠ 0 := (Fact.out (p := p.Prime)).pos.ne'
  haveI : NeZero p := ⟨hp⟩
  rw [powerSum_eq_sum_range_add _ _ hk]
  push_cast
  have h1 : ((p : ZMod p) * (q : ZMod p)) ^ k = 0 := by
    simp [zero_pow hk.ne']
  have h2 : ∑ a ∈ Finset.range (p * q), ((a : ZMod p)) ^ k = q • ∑ x : ZMod p, x ^ k :=
    sum_range_mul_cast p (fun x => x ^ k) q
  rw [h1, add_zero, h2, sum_pow_univ_ZMod p hk, nsmul_eq_mul]

/-- **Divisibility characterisation.**  For a prime `p` not dividing `q` and `k > 0`,
the prime `p` divides `F(pq, k)` precisely when `(p-1) ∤ k`. -/
theorem prime_dvd_powerSum_iff {p q k : ℕ} (hp : p.Prime) (hpq : ¬ p ∣ q) (hk : 0 < k) :
    p ∣ powerSum (p * q) k ↔ ¬ (p - 1) ∣ k := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hcast := cast_powerSum p q hk
  have hq0 : (q : ZMod p) ≠ 0 := fun h => hpq ((ZMod.natCast_eq_zero_iff q p).mp h)
  constructor
  · intro hdvd hdk
    rw [if_pos hdk, mul_neg_one] at hcast
    have h3 : ((powerSum (p * q) k : ℕ) : ZMod p) = 0 :=
      (ZMod.natCast_eq_zero_iff _ _).mpr hdvd
    rw [h3] at hcast
    exact hq0 (neg_eq_zero.mp hcast.symm)
  · intro hdk
    rw [if_neg hdk, mul_zero] at hcast
    exact (ZMod.natCast_eq_zero_iff _ _).mp hcast

/-- gcd with a prime is either the prime (when it divides) or `1`. -/
lemma gcd_prime_eq {p a : ℕ} (hp : p.Prime) :
    Nat.gcd a p = if p ∣ a then p else 1 := by
  by_cases h : p ∣ a
  · simp [h, Nat.gcd_eq_right h]
  · simp [h, Nat.Coprime.gcd_eq_one (((hp.coprime_iff_not_dvd).mpr h).symm)]

/-- **The full gcd formula for a semiprime.**  For distinct primes `p, q` and `k > 0`,

`gcd (F(pq,k), pq) = (if (p-1) ∣ k then 1 else p) * (if (q-1) ∣ k then 1 else q)`.

In particular the gcd is a nontrivial factor exactly when precisely one of
`(p-1) ∣ k`, `(q-1) ∣ k` holds. -/
theorem gcd_powerSum_semiprime {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : 0 < k) :
    Nat.gcd (powerSum (p * q) k) (p * q)
      = (if (p - 1) ∣ k then 1 else p) * (if (q - 1) ∣ k then 1 else q) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have hpq' : ¬ p ∣ q := fun h => hpq ((Nat.prime_dvd_prime_iff_eq hp hq).mp h)
  have hqp' : ¬ q ∣ p := fun h => hpq ((Nat.prime_dvd_prime_iff_eq hq hp).mp h).symm
  rw [hcop.gcd_mul _]
  have hP : Nat.gcd (powerSum (p * q) k) p = if (p - 1) ∣ k then 1 else p := by
    rw [gcd_prime_eq hp]
    by_cases h : (p - 1) ∣ k
    · simp [h, (prime_dvd_powerSum_iff hp hpq' hk).not_left.mpr (by simpa using h)]
    · simp [h, (prime_dvd_powerSum_iff hp hpq' hk).mpr h]
  have hQ : Nat.gcd (powerSum (p * q) k) q = if (q - 1) ∣ k then 1 else q := by
    have hcomm : powerSum (p * q) k = powerSum (q * p) k := by rw [Nat.mul_comm]
    rw [hcomm, gcd_prime_eq hq]
    by_cases h : (q - 1) ∣ k
    · simp [h, (prime_dvd_powerSum_iff hq hqp' hk).not_left.mpr (by simpa using h)]
    · simp [h, (prime_dvd_powerSum_iff hq hqp' hk).mpr h]
  rw [hP, hQ]

/-- **Theorem 1 (power-sum factor reveal).**  For distinct primes `p, q` with `p > 1`,
if `(q-1) ∤ (p-1)` then `gcd (F(pq, p-1), pq) = q`: the power sum at exponent `p-1`
hands over the prime factor `q`. -/
theorem gcd_powerSum_eq_factor {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hdvd : ¬ (q - 1) ∣ (p - 1)) :
    Nat.gcd (powerSum (p * q) (p - 1)) (p * q) = q := by
  have hk : 0 < p - 1 := by
    have := hp.two_le; omega
  rw [gcd_powerSum_semiprime hp hq hpq hk, if_pos dvd_rfl, if_neg hdvd, one_mul]

/-- The gcd found at `k = p-1` is a *proper nontrivial* divisor of `N = pq`. -/
theorem gcd_powerSum_nontrivial {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hdvd : ¬ (q - 1) ∣ (p - 1)) :
    1 < Nat.gcd (powerSum (p * q) (p - 1)) (p * q) ∧
      Nat.gcd (powerSum (p * q) (p - 1)) (p * q) < p * q := by
  rw [gcd_powerSum_eq_factor hp hq hpq hdvd]
  refine ⟨hq.one_lt, ?_⟩
  calc q = 1 * q := (one_mul q).symm
    _ < p * q := by
        exact Nat.mul_lt_mul_of_lt_of_le hp.one_lt le_rfl hq.pos

/-- For a squarefree `N` and a prime `r ∣ N`, we may split `N = r * m` with `r ∤ m`. -/
lemma exists_cofactor_of_squarefree {N r : ℕ} (hN : Squarefree N) (hr : r.Prime) (hrN : r ∣ N) :
    ∃ m, N = r * m ∧ ¬ r ∣ m := by
  obtain ⟨m, rfl⟩ := hrN
  refine ⟨m, rfl, ?_⟩
  rintro ⟨t, rfl⟩
  have := hN r ⟨t, by ring⟩
  exact hr.one_lt.ne' (Nat.isUnit_iff.mp this)

/-- **Carmichael-type coprimality criterion.**  For squarefree `N` and `k > 0`, the power
sum `F(N,k)` is coprime to `N` exactly when `(r-1) ∣ k` for every prime `r ∣ N`. -/
theorem powerSum_coprime_iff_squarefree {N k : ℕ} (hN : Squarefree N) (hk : 0 < k) :
    Nat.Coprime (powerSum N k) N ↔ ∀ r : ℕ, r.Prime → r ∣ N → (r - 1) ∣ k := by
  constructor
  · intro hcop r hr hrN
    by_contra hdk
    obtain ⟨m, hm, hrm⟩ := exists_cofactor_of_squarefree hN hr hrN
    rw [hm] at hcop
    have hdvdF : r ∣ powerSum (r * m) k := (prime_dvd_powerSum_iff hr hrm hk).mpr hdk
    have hg : r ∣ Nat.gcd (powerSum (r * m) k) (r * m) := Nat.dvd_gcd hdvdF ⟨m, rfl⟩
    rw [hcop] at hg
    exact hr.one_lt.ne' (Nat.dvd_one.mp hg)
  · intro h
    by_contra hcop
    obtain ⟨r, hr, hrF, hrN⟩ := Nat.Prime.not_coprime_iff_dvd.mp hcop
    obtain ⟨m, hm, hrm⟩ := exists_cofactor_of_squarefree hN hr hrN
    rw [hm] at hrF
    exact (prime_dvd_powerSum_iff hr hrm hk).mp hrF (h r hr hrN)

end PowerSumGCD