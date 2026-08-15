import Mathlib

/-!
# Power-sum GCD factor reveal

For a modulus `N` put

`powerSum N k = ∑_{a = 1}^{N} a ^ k`.

The main result of this file is a *complete* description of `gcd (powerSum N k) N`
when `N = p * q` is a semiprime and `k ≥ 1`:

`gcd (powerSum (p*q) k, p*q) = (if (p-1) ∣ k then 1 else p) * (if (q-1) ∣ k then 1 else q)`.

The mechanism is a two-step reduction.

* *Periodicity.* The interval `[1, N]` with `N = p * m` covers every residue class
  modulo `p` exactly `m` times, so `powerSum (p*m) k ≡ m * ∑_{x ∈ ZMod p} x^k (mod p)`.
* *Fermat.* For `k ≥ 1`, `∑_{x ∈ ZMod p} x^k = -1` if `(p-1) ∣ k` and `= 0` otherwise.

Consequently `p ∣ powerSum (p*m) k ↔ ¬ (p-1) ∣ k` (when `p ∤ m`), and the gcd formula
follows from multiplicativity of `Nat.gcd` over coprime factors.

Specialising to `k = p - 1` gives the advertised **factor reveal**:
`gcd (powerSum (p*q) (p-1), p*q) = q` whenever `(q-1) ∤ (p-1)`.

## Main results

* `PowerSumReveal.sum_pow_zmod` — Fermat power-sum over `ZMod p`.
* `PowerSumReveal.powerSum_cast` — the periodicity reduction, in `ZMod p`.
* `PowerSumReveal.prime_dvd_powerSum_iff` — divisibility criterion.
* `PowerSumReveal.gcd_powerSum_semiprime` — the master gcd formula.
* `PowerSumReveal.powerSum_factor_reveal` — Theorem 1 (factor reveal at `k = p-1`).
-/

namespace PowerSumReveal

open Finset

/-- `powerSum N k = ∑_{a=1}^{N} a ^ k`, the `k`-th power sum of a complete residue
system modulo `N`. -/
def powerSum (N k : ℕ) : ℕ := ∑ a ∈ Finset.Icc 1 N, a ^ k

@[simp] lemma powerSum_zero_exp (N : ℕ) : powerSum N 0 = N := by
  simp [powerSum]

/-! ## Step 1: the Fermat power sum over `ZMod p` -/

/-- **Fermat power sum.**  For a prime `p` and `k ≥ 1`,
`∑_{x : ZMod p} x ^ k = -1` when `(p-1) ∣ k` and `0` otherwise. -/
theorem sum_pow_zmod (p : ℕ) [Fact p.Prime] {k : ℕ} (hk : k ≠ 0) :
    ∑ x : ZMod p, x ^ k = if (p - 1) ∣ k then -1 else 0 := by
  classical
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  let φ : (ZMod p)ˣ ↪ ZMod p := ⟨fun x ↦ x, Units.val_injective⟩
  have hmap : univ.map φ = univ \ {0} := by
    ext x
    simpa only [mem_map, mem_univ, Function.Embedding.coeFn_mk, true_and, mem_sdiff,
      mem_singleton, φ] using isUnit_iff_ne_zero
  calc ∑ x : ZMod p, x ^ k = ∑ x ∈ univ \ {(0 : ZMod p)}, x ^ k := by
        rw [← sum_sdiff ({0} : Finset (ZMod p)).subset_univ, sum_singleton, zero_pow hk,
          add_zero]
    _ = ∑ x : (ZMod p)ˣ, ((x : ZMod p) ^ k) := by simp [φ, ← hmap, univ.sum_map φ]
    _ = if (p - 1) ∣ k then -1 else 0 := by
        rw [FiniteField.sum_pow_units (ZMod p) k, hcard]

/-! ## Step 2: periodicity of `a ↦ a mod p` on an interval of length `p * m` -/

/-- Summing a function of `a mod p` over one full period `range p` is the same as
summing over `ZMod p`. -/
theorem sum_range_modCast (p : ℕ) [NeZero p] (f : ZMod p → ZMod p) :
    ∑ a ∈ range p, f (a : ZMod p) = ∑ x : ZMod p, f x := by
  refine Finset.sum_nbij' (i := fun a => ((a : ZMod p))) (j := fun x => x.val) ?_ ?_ ?_ ?_ ?_
  · intro a _; simp
  · intro x _; simp [ZMod.val_lt]
  · intro a ha; simp only [mem_range] at ha; simp [ZMod.val_natCast_of_lt ha]
  · intro x _; simp
  · intro _ _; rfl

/-- Over `m` full periods the residues repeat, so the sum is `m` copies of the
sum over `ZMod p`. -/
theorem sum_range_mul_modCast (p : ℕ) [NeZero p] (f : ZMod p → ZMod p) (m : ℕ) :
    ∑ a ∈ range (p * m), f (a : ZMod p) = m • ∑ x : ZMod p, f x := by
  induction m with
  | zero => simp
  | succ m ih =>
      have hpm : p * (m + 1) = p * m + p := by ring
      have base : ∑ a ∈ range p, f ((p * m + a : ℕ) : ZMod p) = ∑ x : ZMod p, f x := by
        have hshift : ∀ a : ℕ, ((p * m + a : ℕ) : ZMod p) = (a : ZMod p) := by
          intro a; push_cast [ZMod.natCast_self]; ring
        simp only [hshift]
        exact sum_range_modCast p f
      rw [hpm, Finset.sum_range_add, ih, base, succ_nsmul]

/-- The interval `[1, N]` and the interval `[0, N)` have the same `k`-th power sum
modulo `p` whenever `k ≥ 1` and `p ∣ N`. -/
theorem powerSum_cast_eq_range (p N : ℕ) [NeZero p] {k : ℕ} (hk : k ≠ 0)
    (hN : (N : ZMod p) = 0) :
    ((powerSum N k : ℕ) : ZMod p) = ∑ a ∈ range N, (a : ZMod p) ^ k := by
  have hcast : ((powerSum N k : ℕ) : ZMod p) = ∑ a ∈ Finset.Icc 1 N, (a : ZMod p) ^ k := by
    unfold powerSum; push_cast; rfl
  rw [hcast]
  have hins : range (N + 1) = insert 0 (Finset.Icc 1 N) := by
    ext x; simp only [mem_range, Finset.mem_insert, Finset.mem_Icc]; omega
  have hnot : (0 : ℕ) ∉ Finset.Icc 1 N := by simp
  have h1 : ∑ a ∈ range (N + 1), (a : ZMod p) ^ k
      = (0 : ZMod p) ^ k + ∑ a ∈ Finset.Icc 1 N, (a : ZMod p) ^ k := by
    rw [hins, Finset.sum_insert hnot]; norm_num
  have h2 : ∑ a ∈ range (N + 1), (a : ZMod p) ^ k
      = ∑ a ∈ range N, (a : ZMod p) ^ k + (N : ZMod p) ^ k := Finset.sum_range_succ _ N
  rw [zero_pow hk, zero_add] at h1
  rw [hN, zero_pow hk, add_zero] at h2
  rw [← h1, h2]

/-- **Periodicity reduction.**  For `N = p * m` and `k ≥ 1`,
`powerSum N k ≡ m * ∑_{x : ZMod p} x^k (mod p)`. -/
theorem powerSum_cast (p m : ℕ) [NeZero p] {k : ℕ} (hk : k ≠ 0) :
    ((powerSum (p * m) k : ℕ) : ZMod p) = (m : ZMod p) * ∑ x : ZMod p, x ^ k := by
  have hN : ((p * m : ℕ) : ZMod p) = 0 := by push_cast [ZMod.natCast_self]; ring
  rw [powerSum_cast_eq_range p (p * m) hk hN,
    sum_range_mul_modCast p (fun x => x ^ k) m, nsmul_eq_mul]

/-! ## Step 3: the divisibility criterion -/

/-- **Divisibility criterion.**  If `p` is prime, `p ∤ m` and `k ≥ 1`, then
`p ∣ powerSum (p * m) k` exactly when `(p-1) ∤ k`. -/
theorem prime_dvd_powerSum_iff {p m k : ℕ} (hp : p.Prime) (hpm : ¬ p ∣ m) (hk : k ≠ 0) :
    p ∣ powerSum (p * m) k ↔ ¬ (p - 1) ∣ k := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hcast := powerSum_cast p m hk
  rw [sum_pow_zmod p hk] at hcast
  have hmne : (m : ZMod p) ≠ 0 := fun h => hpm ((ZMod.natCast_eq_zero_iff m p).1 h)
  constructor
  · intro hdvd hdk
    have h0 : ((powerSum (p * m) k : ℕ) : ZMod p) = 0 :=
      (ZMod.natCast_eq_zero_iff _ p).2 hdvd
    rw [hcast, if_pos hdk] at h0
    exact hmne (by simpa using h0)
  · intro hdk
    refine (ZMod.natCast_eq_zero_iff _ p).1 ?_
    rw [hcast, if_neg hdk, mul_zero]

/-! ## Step 4: the gcd formula -/

/-- `gcd n p` for a prime `p` is `p` or `1` according to divisibility. -/
theorem gcd_prime_eq {n p : ℕ} (hp : p.Prime) : Nat.gcd n p = if p ∣ n then p else 1 := by
  split <;> rename_i h
  · exact Nat.gcd_eq_right h
  · exact Nat.Coprime.gcd_eq_one ((Nat.Prime.coprime_iff_not_dvd hp).2 h).symm

/-- **Master formula.**  For a semiprime `N = p * q` with `p ≠ q` and `k ≥ 1`, the gcd
`gcd (powerSum N k) N` is determined by which of `p-1`, `q-1` divide `k`. -/
theorem gcd_powerSum_semiprime {p q k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hk : k ≠ 0) :
    Nat.gcd (powerSum (p * q) k) (p * q)
      = (if (p - 1) ∣ k then 1 else p) * (if (q - 1) ∣ k then 1 else q) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  have hqp : ¬ p ∣ q := fun h => hpq ((Nat.prime_dvd_prime_iff_eq hp hq).1 h)
  have hpq' : ¬ q ∣ p := fun h => hpq ((Nat.prime_dvd_prime_iff_eq hq hp).1 h).symm
  have hP : p ∣ powerSum (p * q) k ↔ ¬ (p - 1) ∣ k := prime_dvd_powerSum_iff hp hqp hk
  have hQ : q ∣ powerSum (p * q) k ↔ ¬ (q - 1) ∣ k := by
    have := prime_dvd_powerSum_iff hq hpq' hk
    rwa [mul_comm q p] at this
  rw [Nat.Coprime.gcd_mul _ hcop, gcd_prime_eq hp, gcd_prime_eq hq]
  by_cases h1 : (p - 1) ∣ k <;> by_cases h2 : (q - 1) ∣ k <;>
    simp [h1, h2, hP, hQ]

/-! ## Theorem 1: the factor reveal -/

/-- **Theorem 1 (power-sum factor reveal).**  Let `N = p * q` with `p`, `q` distinct
primes and suppose `(q-1) ∤ (p-1)`.  Then one gcd computation at exponent `k = p - 1`
returns the factor `q`:
`gcd (∑_{a=1}^{N} a^{p-1}, N) = q`. -/
theorem powerSum_factor_reveal {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hdvd : ¬ (q - 1) ∣ (p - 1)) :
    Nat.gcd (powerSum (p * q) (p - 1)) (p * q) = q := by
  have hk : p - 1 ≠ 0 := by
    have := hp.two_le; omega
  rw [gcd_powerSum_semiprime hp hq hpq hk, if_pos dvd_rfl, if_neg hdvd, one_mul]

/-- Dual form: at `k = q - 1` the reveal returns `p`, provided `(p-1) ∤ (q-1)`. -/
theorem powerSum_factor_reveal' {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hdvd : ¬ (p - 1) ∣ (q - 1)) :
    Nat.gcd (powerSum (p * q) (q - 1)) (p * q) = p := by
  have hk : q - 1 ≠ 0 := by
    have := hq.two_le; omega
  rw [gcd_powerSum_semiprime hp hq hpq hk, if_pos dvd_rfl, if_neg hdvd, mul_one]

/-- The reveal is *proper*: the gcd at `k = p - 1` is a nontrivial divisor of `N`,
i.e. neither `1` nor `N`. -/
theorem powerSum_reveal_proper {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hdvd : ¬ (q - 1) ∣ (p - 1)) :
    Nat.gcd (powerSum (p * q) (p - 1)) (p * q) ≠ 1 ∧
      Nat.gcd (powerSum (p * q) (p - 1)) (p * q) ≠ p * q := by
  rw [powerSum_factor_reveal hp hq hpq hdvd]
  refine ⟨hq.ne_one, ?_⟩
  intro h
  have hp1 : 1 < p := hp.one_lt
  have hq0 : 0 < q := hq.pos
  nlinarith [h]

end PowerSumReveal