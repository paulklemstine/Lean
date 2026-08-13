import Mathlib
import Algebra.QubitTrade.RecordCount

/-!
# QUBIT-TRADE X: two samples already succeed on a majority of records

`RecordCount.lean` shows that a *good* record — one whose numerators are jointly
coprime to the order `r` — exists as soon as `ω(r) < 2^m`.  That is an existence
statement; it says nothing about how likely a random record is to be good, and
the union bound used there is lossy by a factor `ω(r)`.

Here we sharpen the count to a **density** statement, and the loss disappears:

* `QubitTrade.sum_inv_sq_primes_lt_half` — for *every* finite set `S` of primes,
  `Σ_{p ∈ S} p⁻² < 1/2`.  This is an unconditional, elementary bound: the four
  primes below `11` contribute `18589/44100`, and the remaining primes, being
  distinct odd numbers `≥ 11`, contribute at most `1/20` by telescoping
  `(2k+1)⁻² ≤ (4k)⁻¹ − (4(k+1))⁻¹`.
* `QubitTrade.card_badRecords_le_sum` — the exact union bound
  `#bad ≤ Σ_{p ∣ r} (r/p)^m`, with no `ω(r)` slack.
* `QubitTrade.two_pow_card_goodRecords` — hence for **every** `r ≥ 1` and every
  `m ≥ 2`, `r^m < 2 · #good`: *strictly more than half* of all length-`m`
  records of numerators recover the order.
* `QubitTrade.two_samples_recover_majority` — the same statement phrased through
  the estimator `recordEstimate` of `SampleFungibility.lean`: two samples read
  above the register threshold return the true order `r` for a majority of
  numerator pairs, uniformly in `r`.
* `QubitTrade.pow_mul_card_badRecords_lt` / `QubitTrade.card_goodRecords_lower` —
  the concentration form: the failure probability of `m ≥ 2` samples is
  `< 2^{-(m-1)}`, again with no `ω(r)` factor, so the success probability rises
  exponentially in the sample count while remaining uniform in the order.

This settles, with the explicit constant `1/2` in place of the conjectured
`6/π² ≈ 0.6079`, the quantitative half of the "qubit ↔ sample" ledger: above the
`2 log₂ r` register threshold, **two** samples suffice with probability `> 1/2`
for every order, so the sample budget really is `O(1)` per constant success
probability, while the qubit budget is rigid.
-/

namespace QubitTrade

open Finset

/-! ### An unconditional bound on `Σ_p p⁻²` over primes -/

/-- Telescoping sum of `(4k)⁻¹ − (4(k+1))⁻¹` from `5` up to `N`. -/
private theorem telescope_quarter {N : ℕ} (hN : 5 ≤ N) :
    ∑ k ∈ Finset.Ico 5 N, ((1:ℚ) / (4 * k) - 1 / (4 * (k + 1))) = 1 / 20 - 1 / (4 * N) := by
  induction N with
  | zero => omega
  | succ n ih =>
      rcases Nat.lt_or_ge n 5 with h | h
      · have hn : n = 4 := by omega
        subst hn
        norm_num
      · rw [Finset.sum_Ico_succ_top (by omega), ih h]
        have hn : (n : ℚ) ≠ 0 := by
          have : (0:ℕ) < n := by omega
          positivity
        push_cast
        field_simp
        ring

/-- Every term of the telescoping sum is nonnegative. -/
private theorem telescope_term_nonneg {k : ℕ} (hk : 1 ≤ k) :
    (0:ℚ) ≤ 1 / (4 * k) - 1 / (4 * (k + 1)) := by
  have hk0 : (0:ℚ) < (k : ℚ) := by exact_mod_cast hk
  have h1 : (0:ℚ) < 4 * (k : ℚ) := by linarith
  have h2 : (0:ℚ) < 4 * ((k : ℚ) + 1) := by linarith
  rw [sub_nonneg]
  apply div_le_div_of_nonneg_left (by norm_num) h1 (by linarith)

/-- For an odd `p ≥ 11`, `p⁻²` is dominated by the telescoping term at `k = p / 2`. -/
private theorem inv_sq_le_telescope {p : ℕ} (hp : 11 ≤ p) (hodd : Odd p) :
    (1:ℚ) / (p : ℚ) ^ 2 ≤ 1 / (4 * (p / 2 : ℕ)) - 1 / (4 * ((p / 2 : ℕ) + 1)) := by
  obtain ⟨k, hk⟩ := hodd
  have hk5 : 5 ≤ k := by omega
  have hdiv : p / 2 = k := by omega
  rw [hdiv]
  have hkQ : (5:ℚ) ≤ (k : ℚ) := by exact_mod_cast hk5
  have hpQ : (p : ℚ) = 2 * (k : ℚ) + 1 := by
    have : ((p : ℕ) : ℚ) = ((2 * k + 1 : ℕ) : ℚ) := by exact_mod_cast congrArg (fun n : ℕ => n) hk
    push_cast at this
    linarith
  have hk0 : (0:ℚ) < (k : ℚ) := by linarith
  have hp0 : (0:ℚ) < (p : ℚ) := by rw [hpQ]; linarith
  have hkey : (1:ℚ) / (4 * k) - 1 / (4 * ((k : ℚ) + 1)) = 1 / (4 * k * (k + 1)) := by
    field_simp
    ring
  rw [hkey]
  refine one_div_le_one_div_of_le (by positivity) ?_
  rw [hpQ]
  nlinarith [hk0]

/-- The primes `≥ 11` in any finite set contribute at most `1/20` to `Σ p⁻²`. -/
private theorem sum_inv_sq_tail (B : Finset ℕ) (hB : ∀ p ∈ B, 11 ≤ p ∧ Odd p) :
    ∑ p ∈ B, (1:ℚ) / (p : ℚ) ^ 2 ≤ 1 / 20 := by
  classical
  set g : ℕ → ℚ := fun k => 1 / (4 * k) - 1 / (4 * (k + 1)) with hg
  have hstep : ∑ p ∈ B, (1:ℚ) / (p : ℚ) ^ 2 ≤ ∑ p ∈ B, g (p / 2) := by
    refine Finset.sum_le_sum ?_
    intro p hp
    exact inv_sq_le_telescope (hB p hp).1 (hB p hp).2
  have hinj : ∀ x ∈ B, ∀ y ∈ B, x / 2 = y / 2 → x = y := by
    intro x hx y hy hxy
    obtain ⟨kx, hkx⟩ := (hB x hx).2
    obtain ⟨ky, hky⟩ := (hB y hy).2
    omega
  have himage : ∑ p ∈ B, g (p / 2) = ∑ k ∈ B.image (fun p => p / 2), g k :=
    (Finset.sum_image hinj).symm
  -- the image sits inside `Ico 5 N`
  set N : ℕ := (B.image (fun p => p / 2)).sup id + 5 with hN
  have hsub : B.image (fun p => p / 2) ⊆ Finset.Ico 5 N := by
    intro k hk
    obtain ⟨p, hp, rfl⟩ := Finset.mem_image.1 hk
    have h11 := (hB p hp).1
    refine Finset.mem_Ico.2 ⟨by omega, ?_⟩
    have : id (p / 2) ≤ (B.image (fun p => p / 2)).sup id := Finset.le_sup hk
    simp only [id] at this
    omega
  have hN5 : 5 ≤ N := by omega
  have hmono : ∑ k ∈ B.image (fun p => p / 2), g k ≤ ∑ k ∈ Finset.Ico 5 N, g k := by
    refine Finset.sum_le_sum_of_subset_of_nonneg hsub ?_
    intro k hk _
    have : 5 ≤ k := (Finset.mem_Ico.1 hk).1
    exact telescope_term_nonneg (by omega)
  have htel : ∑ k ∈ Finset.Ico 5 N, g k = 1 / 20 - 1 / (4 * N) := telescope_quarter hN5
  have hNpos : (0:ℚ) < (N : ℚ) := by
    have : (0:ℕ) < N := by omega
    exact_mod_cast this
  have : (0:ℚ) ≤ 1 / (4 * N) := by positivity
  linarith [hstep, himage.le, hmono, htel.le]

/-- **The reciprocal squares of the primes never reach `1/2`.**  For every finite
set `S` of primes, `Σ_{p ∈ S} p⁻² < 1/2`.  (The true value of the full sum is
`≈ 0.4522`; the elementary argument here gives `≤ 20794/44100 ≈ 0.4715`.) -/
theorem sum_inv_sq_primes_lt_half (S : Finset ℕ) (hS : ∀ p ∈ S, Nat.Prime p) :
    ∑ p ∈ S, (1:ℚ) / (p : ℚ) ^ 2 < 1 / 2 := by
  classical
  have hsplit : ∑ p ∈ S, (1:ℚ) / (p : ℚ) ^ 2
      = ∑ p ∈ S.filter (fun p => p < 11), (1:ℚ) / (p : ℚ) ^ 2
        + ∑ p ∈ S.filter (fun p => ¬ p < 11), (1:ℚ) / (p : ℚ) ^ 2 :=
    (Finset.sum_filter_add_sum_filter_not S (fun p => p < 11) _).symm
  -- the small primes
  have hsmall : ∑ p ∈ S.filter (fun p => p < 11), (1:ℚ) / (p : ℚ) ^ 2 ≤ 18589 / 44100 := by
    have hsub : S.filter (fun p => p < 11) ⊆ ({2, 3, 5, 7} : Finset ℕ) := by
      intro p hp
      rw [Finset.mem_filter] at hp
      have hprime := hS p hp.1
      have h2 : 2 ≤ p := hprime.two_le
      have hlt : p < 11 := hp.2
      interval_cases p <;> simp_all (config := { decide := true })
    have hle : ∑ p ∈ S.filter (fun p => p < 11), (1:ℚ) / (p : ℚ) ^ 2
        ≤ ∑ p ∈ ({2, 3, 5, 7} : Finset ℕ), (1:ℚ) / (p : ℚ) ^ 2 := by
      refine Finset.sum_le_sum_of_subset_of_nonneg hsub ?_
      intro i _ _
      positivity
    have hval : ∑ p ∈ ({2, 3, 5, 7} : Finset ℕ), (1:ℚ) / (p : ℚ) ^ 2 = 18589 / 44100 := by
      norm_num [Finset.sum_insert, Finset.mem_insert]
    linarith [hle, hval.le, hval.ge]
  -- the large primes
  have hlarge : ∑ p ∈ S.filter (fun p => ¬ p < 11), (1:ℚ) / (p : ℚ) ^ 2 ≤ 1 / 20 := by
    refine sum_inv_sq_tail _ ?_
    intro p hp
    rw [Finset.mem_filter] at hp
    have hprime := hS p hp.1
    refine ⟨by omega, ?_⟩
    rcases hprime.eq_two_or_odd' with h2 | hodd
    · omega
    · exact hodd
  rw [hsplit]
  linarith

/-! ### From the prime bound to the density of good records -/

variable {r m : ℕ}

/-- The sharp union bound: bad records are covered by the prime-multiple records. -/
theorem card_badRecords_le_sum (hr : 0 < r) :
    (badRecords r m).card ≤ ∑ p ∈ r.primeFactors, (r / p) ^ m := by
  classical
  refine le_trans (Finset.card_le_card (badRecords_subset hr)) ?_
  refine le_trans Finset.card_biUnion_le ?_
  refine Finset.sum_le_sum ?_
  intro p hp
  exact le_of_eq (card_multipleRecords (Nat.prime_of_mem_primeFactors hp).pos
    (Nat.dvd_of_mem_primeFactors hp))

/-- The union bound, over `ℚ`, in the form `#bad ≤ r^m · Σ_{p ∣ r} p^{-m}`. -/
private theorem card_badRecords_le_rat (hr : 0 < r) :
    ((badRecords r m).card : ℚ) ≤ (r : ℚ) ^ m * ∑ p ∈ r.primeFactors, (1:ℚ) / (p : ℚ) ^ m := by
  have hnat := card_badRecords_le_sum (r := r) (m := m) hr
  have hcast : ((∑ p ∈ r.primeFactors, (r / p) ^ m : ℕ) : ℚ)
      = (r : ℚ) ^ m * ∑ p ∈ r.primeFactors, (1:ℚ) / (p : ℚ) ^ m := by
    rw [Nat.cast_sum, Finset.mul_sum]
    refine Finset.sum_congr rfl ?_
    intro p hp
    have hdvd : p ∣ r := Nat.dvd_of_mem_primeFactors hp
    have hp0 : (p : ℚ) ≠ 0 := by
      have := (Nat.prime_of_mem_primeFactors hp).pos
      positivity
    rw [Nat.cast_pow, Nat.cast_div hdvd hp0, div_pow]
    ring
  calc ((badRecords r m).card : ℚ) ≤ ((∑ p ∈ r.primeFactors, (r / p) ^ m : ℕ) : ℚ) := by
        exact_mod_cast hnat
    _ = _ := hcast

/-- The records that *do* satisfy the joint-coprimality criterion. -/
noncomputable def goodRecords (r m : ℕ) : Finset (Fin m → ℕ) :=
  (allRecords r m).filter (fun f => Nat.gcd (recordGcd (List.ofFn f)) r = 1)

theorem card_good_add_card_bad (r m : ℕ) :
    (goodRecords r m).card + (badRecords r m).card = r ^ m := by
  classical
  rw [goodRecords, badRecords, ← card_allRecords (r := r) (m := m)]
  exact Finset.card_filter_add_card_filter_not (p := fun f => Nat.gcd
    (recordGcd (List.ofFn f)) r = 1)

/-- The prime-power sums that control the failure probability: for `m ≥ 2`,
`Σ_{p ∣ r} p^{-m} < 2^{-(m-1)}`. -/
private theorem sum_inv_pow_primeFactors_lt (hm : 2 ≤ m) :
    ∑ p ∈ r.primeFactors, (1:ℚ) / (p : ℚ) ^ m < 1 / 2 ^ (m - 1) := by
  classical
  have hterm : ∀ p ∈ r.primeFactors,
      (1:ℚ) / (p : ℚ) ^ m ≤ (1 / 2 ^ (m - 2)) * (1 / (p : ℚ) ^ 2) := by
    intro p hp
    have h2 : 2 ≤ p := (Nat.prime_of_mem_primeFactors hp).two_le
    have hp2 : (2:ℚ) ≤ (p : ℚ) := by exact_mod_cast h2
    have hp0 : (0:ℚ) < (p : ℚ) := by linarith
    have hsplit : (p : ℚ) ^ m = (p : ℚ) ^ 2 * (p : ℚ) ^ (m - 2) := by
      rw [← pow_add]
      congr 1
      omega
    have hpow : (2:ℚ) ^ (m - 2) ≤ (p : ℚ) ^ (m - 2) :=
      pow_le_pow_left₀ (by norm_num) hp2 _
    have hprod : (p : ℚ) ^ 2 * (2:ℚ) ^ (m - 2) ≤ (p : ℚ) ^ m := by
      rw [hsplit]
      exact mul_le_mul_of_nonneg_left hpow (by positivity)
    have hpos : (0:ℚ) < (p : ℚ) ^ 2 * (2:ℚ) ^ (m - 2) := by positivity
    calc (1:ℚ) / (p : ℚ) ^ m ≤ 1 / ((p : ℚ) ^ 2 * (2:ℚ) ^ (m - 2)) :=
          one_div_le_one_div_of_le hpos hprod
      _ = (1 / 2 ^ (m - 2)) * (1 / (p : ℚ) ^ 2) := by ring
  have hle : ∑ p ∈ r.primeFactors, (1:ℚ) / (p : ℚ) ^ m
      ≤ (1 / 2 ^ (m - 2)) * ∑ p ∈ r.primeFactors, (1:ℚ) / (p : ℚ) ^ 2 := by
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum hterm
  have hhalf := sum_inv_sq_primes_lt_half r.primeFactors
    (fun p hp => Nat.prime_of_mem_primeFactors hp)
  have hcoef : (0:ℚ) < 1 / 2 ^ (m - 2) := by positivity
  have hstrict : (1 / 2 ^ (m - 2)) * ∑ p ∈ r.primeFactors, (1:ℚ) / (p : ℚ) ^ 2
      < (1 / 2 ^ (m - 2)) * (1 / 2) := mul_lt_mul_of_pos_left hhalf hcoef
  have hval : (1 / (2:ℚ) ^ (m - 2)) * (1 / 2) = 1 / 2 ^ (m - 1) := by
    have : (2:ℚ) ^ (m - 1) = 2 ^ (m - 2) * 2 := by
      rw [← pow_succ]
      congr 1
      omega
    rw [this]
    field_simp
  linarith [hle, hstrict, hval.le, hval.ge]

/-- **The failure probability decays exponentially in the number of samples**, with
no `ω(r)` factor: for every order `r ≥ 1` and every `m ≥ 2`, fewer than a fraction
`2^{-(m-1)}` of the `r^m` records fail the joint-coprimality test.  For `m = 2`
this is the majority statement; for growing `m` it is exponential concentration,
uniformly in `r`. -/
theorem pow_mul_card_badRecords_lt (hr : 0 < r) (hm : 2 ≤ m) :
    2 ^ (m - 1) * (badRecords r m).card < r ^ m := by
  classical
  have hsum := sum_inv_pow_primeFactors_lt (r := r) (m := m) hm
  have hrQ : (0:ℚ) < (r : ℚ) ^ m := by
    have : (0:ℚ) < (r : ℚ) := by exact_mod_cast hr
    positivity
  have hlt : ((badRecords r m).card : ℚ) < (r : ℚ) ^ m / 2 ^ (m - 1) := by
    refine lt_of_le_of_lt (card_badRecords_le_rat (r := r) (m := m) hr) ?_
    calc (r : ℚ) ^ m * ∑ p ∈ r.primeFactors, (1:ℚ) / (p : ℚ) ^ m
        < (r : ℚ) ^ m * (1 / 2 ^ (m - 1)) := mul_lt_mul_of_pos_left hsum hrQ
      _ = (r : ℚ) ^ m / 2 ^ (m - 1) := by ring
  have hpow : (0:ℚ) < (2:ℚ) ^ (m - 1) := by positivity
  have : ((2 ^ (m - 1) * (badRecords r m).card : ℕ) : ℚ) < ((r ^ m : ℕ) : ℚ) := by
    push_cast
    rw [lt_div_iff₀ hpow] at hlt
    linarith
  exact_mod_cast this

/-- **Strictly fewer than half of all records are bad**, for every order `r ≥ 1`
and every record length `m ≥ 2`. -/
theorem two_mul_card_badRecords_lt (hr : 0 < r) (hm : 2 ≤ m) :
    2 * (badRecords r m).card < r ^ m := by
  have hbase := pow_mul_card_badRecords_lt (r := r) (m := m) hr hm
  have hmono : (2:ℕ) ≤ 2 ^ (m - 1) := by
    calc (2:ℕ) = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ (m - 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  calc 2 * (badRecords r m).card ≤ 2 ^ (m - 1) * (badRecords r m).card :=
        Nat.mul_le_mul_right _ hmono
    _ < r ^ m := hbase

/-- **Two samples already succeed on a majority of records.**  For every order
`r ≥ 1` and every `m ≥ 2`, strictly more than half of the `r^m` possible records
of numerators are jointly coprime to `r`.  In particular the success probability
of the `m = 2` post-processing is `> 1/2`, uniformly in `r` — no dependence on
`ω(r)` at all. -/
theorem two_pow_card_goodRecords (hr : 0 < r) (hm : 2 ≤ m) :
    r ^ m < 2 * (goodRecords r m).card := by
  have hsum := card_good_add_card_bad r m
  have hbad := two_mul_card_badRecords_lt (r := r) (m := m) hr hm
  omega

/-- The same statement through the estimator: for a majority of records the
`gcd`-based post-processing of `SampleFungibility.lean` returns the true order. -/
theorem two_samples_recover_majority (hr : 0 < r) (hm : 2 ≤ m) :
    r ^ m < 2 * ((allRecords r m).filter
      (fun f => recordEstimate (List.ofFn f) r = r)).card := by
  classical
  have hsub : goodRecords r m ⊆ (allRecords r m).filter
      (fun f => recordEstimate (List.ofFn f) r = r) := by
    intro f hf
    rw [goodRecords, Finset.mem_filter] at hf
    exact Finset.mem_filter.2 ⟨hf.1, samples_recover hr hf.2⟩
  have := Finset.card_le_card hsub
  have hgood := two_pow_card_goodRecords (r := r) (m := m) hr hm
  omega

/-- **Exponential concentration of the sample side of the ledger.**  For every
order `r ≥ 1` and every `m ≥ 2`, the good records outnumber `r^m (1 − 2^{-(m-1)})`:
the success probability of `m` samples is `> 1 − 2^{-(m-1)}`, uniformly in `r`.
This is the sharp form of `RecordCount.good_record_of_log_log`, with the `ω(r)`
factor of the earlier union bound removed. -/
theorem card_goodRecords_lower (hr : 0 < r) (hm : 2 ≤ m) :
    (2 ^ (m - 1) - 1) * r ^ m < 2 ^ (m - 1) * (goodRecords r m).card := by
  set K := 2 ^ (m - 1) with hK
  have hK1 : 1 ≤ K := Nat.one_le_two_pow
  have hsum := card_good_add_card_bad r m
  have hbad := pow_mul_card_badRecords_lt (r := r) (m := m) hr hm
  rw [← hK] at hbad
  have hdist : K * (goodRecords r m).card + K * (badRecords r m).card = K * r ^ m := by
    rw [← Nat.mul_add, hsum]
  have hNle : r ^ m ≤ K * r ^ m := Nat.le_mul_of_pos_left _ (by omega)
  have hsubeq : (K - 1) * r ^ m = K * r ^ m - r ^ m := by
    rw [Nat.sub_mul, one_mul]
  omega

end QubitTrade