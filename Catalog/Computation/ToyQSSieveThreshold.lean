import Mathlib
import Shared.SmoothCountSparsity
import Shared.NumberTheory.IsSmooth

/-!
# The log-sieve threshold test is an exact survivor filter — iff it sieves prime powers

Context (experiment 470, H1 and ledger).  The measured advantage of the sieve over
naive trial division is the constant *survivor-filtering* factor: instead of
~`π(B)` trial divisions per value, the sieve performs ~2 log-additions per value
(one per hit of a sieve line) and only the survivors of a log threshold are
divided.  For this to be a pure algorithmic gain, the threshold test must be an
**exact** filter: it may not lose relations.  The ledger records the bug where it
did: sieving only first powers lost every relation with a repeated prime factor.

This file proves the exact characterisation.  For a factor base `S` of primes, the
sieve with prime powers `p, p², …, p^K` accumulates, at the value `v`,

  `sieveLog S K v = ∑_{p ∈ S} #{1 ≤ k ≤ K : p^k ∣ v} · log p`.

* `sieveHits_eq_min` — the hit count of `p` at `v` is `min (v_p(v)) K`;
* `sieveLog_eq_log_sieveProduct` — the accumulator is `log` of an explicit divisor
  `sieveProduct S K v ∣ v` (`sieveProduct_dvd`);
* `sieve_accepts_iff` — **the threshold `sieveLog = log v` is met iff `v` is
  `S`-smooth and every exponent is `≤ K`**;
* `first_power_sieve_accepts_iff` — with `K = 1` (the bug) exactly the *squarefree*
  smooth values survive;
* `first_power_sieve_misses` — every non-squarefree smooth value is lost, with a
  strict log deficit;
* `full_sieve_exact` — with `K ≥ log₂ v` (Hensel lines up to that height, see
  `ToyQSHensel.rootCountPow_eq_two`) the filter is exact:
  survivors = `B`-smooth values, as decided by trial division (`isSmooth`).
-/

namespace ToyQSSieve

open Finset

/-- Number of sieve lines `p^k` (`1 ≤ k ≤ K`) that hit the value `v`. -/
def sieveHits (K v p : ℕ) : ℕ := ((Finset.Icc 1 K).filter (fun k => p ^ k ∣ v)).card

/-- The divisor of `v` "seen" by the sieve. -/
def sieveProduct (S : Finset ℕ) (K v : ℕ) : ℕ := ∏ p ∈ S, p ^ sieveHits K v p

/-- The log accumulator of the sieve at the value `v`. -/
noncomputable def sieveLog (S : Finset ℕ) (K v : ℕ) : ℝ :=
  ∑ p ∈ S, (sieveHits K v p : ℝ) * Real.log p

/-- The hit count is the `p`-adic valuation, truncated at the sieve height `K`. -/
theorem sieveHits_eq_min {p K v : ℕ} (hp : p.Prime) (hv : v ≠ 0) :
    sieveHits K v p = min (v.factorization p) K := by
  unfold sieveHits
  have : (Finset.Icc 1 K).filter (fun k => p ^ k ∣ v) = Finset.Icc 1 (min (v.factorization p) K) := by
    ext k
    simp only [Finset.mem_filter, Finset.mem_Icc, hp.pow_dvd_iff_le_factorization hv]
    omega
  rw [this, Nat.card_Icc]
  omega

/-- Factorisation of a product of powers of distinct primes. -/
theorem factorization_prod_pow {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) (e : ℕ → ℕ) (q : ℕ) :
    (∏ p ∈ S, p ^ e p).factorization q = if q ∈ S then e q else 0 := by
  classical
  rw [Nat.factorization_prod (fun p hp => pow_ne_zero _ (hS p hp).ne_zero)]
  rw [Finset.sum_apply']
  rw [Finset.sum_congr rfl (fun p hp => by rw [(hS p hp).factorization_pow])]
  simp only [Finsupp.single_apply]
  rw [Finset.sum_ite_eq']

theorem sieveProduct_ne_zero {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) (K v : ℕ) :
    sieveProduct S K v ≠ 0 :=
  Finset.prod_ne_zero_iff.2 (fun p hp => pow_ne_zero _ (hS p hp).ne_zero)

/-- Factorisation of the sieve product. -/
theorem factorization_sieveProduct {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) {K v : ℕ}
    (hv : v ≠ 0) (q : ℕ) :
    (sieveProduct S K v).factorization q =
      if q ∈ S then min (v.factorization q) K else 0 := by
  unfold sieveProduct
  rw [factorization_prod_pow hS]
  split_ifs with hq
  · exact sieveHits_eq_min (hS q hq) hv
  · rfl

/-- The sieve only ever sees a divisor of the value. -/
theorem sieveProduct_dvd {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) {K v : ℕ} (hv : v ≠ 0) :
    sieveProduct S K v ∣ v := by
  rw [← Nat.factorization_le_iff_dvd (sieveProduct_ne_zero hS K v) hv]
  intro q
  rw [factorization_sieveProduct hS hv]
  split_ifs <;> omega

/-- The accumulator is the logarithm of the sieve product. -/
theorem sieveLog_eq_log_sieveProduct {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) (K v : ℕ) :
    sieveLog S K v = Real.log (sieveProduct S K v) := by
  unfold sieveLog sieveProduct
  push_cast
  rw [Real.log_prod]
  · refine Finset.sum_congr rfl (fun p _ => ?_)
    rw [Real.log_pow]
  · intro p hp
    exact pow_ne_zero _ (by exact_mod_cast (hS p hp).ne_zero)

/-- **Exact acceptance criterion (multiplicative form).** -/
theorem sieveProduct_eq_iff {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) {K v : ℕ} (hv : v ≠ 0) :
    sieveProduct S K v = v ↔
      (∀ q, q.Prime → q ∣ v → q ∈ S) ∧ (∀ q ∈ S, v.factorization q ≤ K) := by
  constructor
  · intro h
    have hf : ∀ q, (sieveProduct S K v).factorization q = v.factorization q := by
      intro q; rw [h]
    refine ⟨fun q hq hqv => ?_, fun q hqS => ?_⟩
    · by_contra hqS
      have h1 := hf q
      rw [factorization_sieveProduct hS hv, if_neg hqS] at h1
      have : 1 ≤ v.factorization q := (hq.dvd_iff_one_le_factorization hv).1 hqv
      omega
    · have h1 := hf q
      rw [factorization_sieveProduct hS hv, if_pos hqS] at h1
      omega
  · rintro ⟨hsm, hK⟩
    refine Nat.eq_of_factorization_eq (sieveProduct_ne_zero hS K v) hv (fun q => ?_)
    rw [factorization_sieveProduct hS hv]
    split_ifs with hq
    · have := hK q hq; omega
    · by_contra hne
      have hpos : v.factorization q ≠ 0 := fun h => hne h.symm
      have hmem : q ∈ v.primeFactors := by
        rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 hpos
      exact hq (hsm q (Nat.prime_of_mem_primeFactors hmem) (Nat.dvd_of_mem_primeFactors hmem))

/-- **The threshold test, exactly.**  The log accumulator reaches `log v` iff `v`
is `S`-smooth with every exponent at most the sieve height `K`. -/
theorem sieve_accepts_iff {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) {K v : ℕ} (hv : v ≠ 0) :
    sieveLog S K v = Real.log v ↔
      (∀ q, q.Prime → q ∣ v → q ∈ S) ∧ (∀ q ∈ S, v.factorization q ≤ K) := by
  rw [sieveLog_eq_log_sieveProduct hS, ← sieveProduct_eq_iff hS hv]
  have h1 : (0 : ℝ) < sieveProduct S K v := by
    exact_mod_cast Nat.pos_of_ne_zero (sieveProduct_ne_zero hS K v)
  have h2 : (0 : ℝ) < v := by exact_mod_cast Nat.pos_of_ne_zero hv
  rw [Real.log_injOn_pos.eq_iff h1 h2]
  exact_mod_cast Iff.rfl

/-- The accumulator never exceeds `log v`. -/
theorem sieveLog_le {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) {K v : ℕ} (hv : v ≠ 0) :
    sieveLog S K v ≤ Real.log v := by
  rw [sieveLog_eq_log_sieveProduct hS]
  have h1 : (0 : ℝ) < sieveProduct S K v := by
    exact_mod_cast Nat.pos_of_ne_zero (sieveProduct_ne_zero hS K v)
  apply Real.log_le_log h1
  exact_mod_cast Nat.le_of_dvd (Nat.pos_of_ne_zero hv) (sieveProduct_dvd hS hv)

/-- **The first-power bug, exactly.**  Sieving only the lines modulo `p` (height
`K = 1`) accepts precisely the *squarefree* `S`-smooth values. -/
theorem first_power_sieve_accepts_iff {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) {v : ℕ}
    (hv : v ≠ 0) :
    sieveLog S 1 v = Real.log v ↔ (∀ q, q.Prime → q ∣ v → q ∈ S) ∧ Squarefree v := by
  rw [sieve_accepts_iff hS hv, Nat.squarefree_iff_factorization_le_one hv]
  constructor
  · rintro ⟨hsm, hK⟩
    refine ⟨hsm, fun q => ?_⟩
    by_cases hq : q ∈ S
    · exact hK q hq
    · by_contra hne
      have hpos : v.factorization q ≠ 0 := by omega
      have hmem : q ∈ v.primeFactors := by
        rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 hpos
      exact hq (hsm q (Nat.prime_of_mem_primeFactors hmem) (Nat.dvd_of_mem_primeFactors hmem))
  · rintro ⟨hsm, hsq⟩
    exact ⟨hsm, fun q _ => hsq q⟩

/-- **Every repeated-factor relation is lost by the first-power sieve**, with a
strict deficit in the log accumulator. -/
theorem first_power_sieve_misses {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) {v : ℕ}
    (hv : v ≠ 0) (hnsq : ¬ Squarefree v) :
    sieveLog S 1 v < Real.log v := by
  refine lt_of_le_of_ne (sieveLog_le hS hv) (fun h => hnsq ?_)
  exact ((first_power_sieve_accepts_iff hS hv).1 h).2

/-- **Exactness of the full sieve.**  With the factor base `factorBase B` and lines
up to height `K ≥ log₂ v`, the survivors of the log threshold are *exactly* the
`B`-smooth values in the sense of trial division (`isSmooth`).  The sieve
therefore loses no relation and admits no false positive: its advantage over trial
division is purely the algorithmic survivor filter. -/
theorem full_sieve_exact {B K v : ℕ} (hv : v ≠ 0) (hK : Nat.log 2 v ≤ K) :
    sieveLog (SmoothSparsity.factorBase B) K v = Real.log v ↔ isSmooth B v := by
  have hS : ∀ p ∈ SmoothSparsity.factorBase B, p.Prime :=
    fun p hp => (SmoothSparsity.mem_factorBase.1 hp).1
  rw [sieve_accepts_iff hS hv]
  constructor
  · rintro ⟨hsm, -⟩ q hq hqv
    exact (SmoothSparsity.mem_factorBase.1 (hsm q hq hqv)).2
  · intro hsm
    refine ⟨fun q hq hqv => SmoothSparsity.mem_factorBase.2 ⟨hq, hsm q hq hqv⟩,
      fun q _ => ?_⟩
    exact (SmoothSparsity.factorization_le_log_two hv le_rfl).trans hK

/-! ## Lab notes (kernel-checked instances from the toy run for `N = 103764863`)

`10342² - N = 3192101 = 11² · 23 · 31 · 37` is a genuine relation over the
admissible factor base that the first-power sieve rejects, while
`10756² - N = 11926673 = 11 · 17 · 23 · 47 · 59` is squarefree and survives both. -/

example : (10342 : ℤ) ^ 2 - 103764863 = 11 ^ 2 * 23 * 31 * 37 := by norm_num
example : ¬ Squarefree (3192101 : ℕ) := by
  rw [show (3192101 : ℕ) = 11 * 11 * 26381 by norm_num]
  intro h
  exact absurd (h 11 ⟨26381, by ring⟩) (by simp)
example : (10756 : ℤ) ^ 2 - 103764863 = 11 * 17 * 23 * 47 * 59 := by norm_num

end ToyQSSieve