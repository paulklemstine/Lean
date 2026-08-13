import Mathlib
import Algebra.QubitTrade.SampleFungibility

/-!
# QUBIT-TRADE IX: how many samples? `log₂ log₂ r` of them

Above the resolution threshold the only obstruction left is `gcd (k, r) > 1`, and
`SampleFungibility.lean` says a record works exactly when its numerators are
jointly coprime to `r`.  Here we *count* the bad records and get the second half
of the resource ledger:

* `QubitTrade.card_bad_records_le` — the number of length-`m` records of
  numerators that fail the joint-coprimality test is at most
  `ω(r) · r^m / 2^m` (stated multiplicatively, in `ℕ`);
* `QubitTrade.exists_good_record` — hence a *successful* record of length `m`
  exists as soon as `ω(r) < 2^m`;
* `QubitTrade.good_record_of_log_log` — and `m = log₂ log₂ r + 1` samples always
  suffice, since `ω(r) ≤ log₂ r`.

Together with `Threshold.lean`: **`2 log₂ r` qubits and `log₂ log₂ r` samples.**
The register size is forced; the sample count is almost free.  That asymmetry is
the precise sense in which qubits and samples are *not* fungible below the
threshold and only mildly fungible above it.
-/

namespace QubitTrade

open Finset

variable {r m : ℕ}

/-- All length-`m` records of numerators below `r`. -/
def allRecords (r m : ℕ) : Finset (Fin m → ℕ) :=
  Fintype.piFinset (fun _ : Fin m => Finset.range r)

/-- The records that fail the joint-coprimality criterion of `samples_recover`. -/
noncomputable def badRecords (r m : ℕ) : Finset (Fin m → ℕ) :=
  (allRecords r m).filter (fun f => Nat.gcd (recordGcd (List.ofFn f)) r ≠ 1)

theorem card_allRecords : (allRecords r m).card = r ^ m := by
  rw [allRecords, Fintype.card_piFinset]
  simp

/-- Records all of whose entries are divisible by `p`. -/
def multipleRecords (r m p : ℕ) : Finset (Fin m → ℕ) :=
  Fintype.piFinset (fun _ : Fin m => (Finset.range r).filter (fun x => p ∣ x))

theorem card_multiples {p : ℕ} (hp : 0 < p) (hd : p ∣ r) :
    ((Finset.range r).filter (fun x => p ∣ x)).card = r / p := by
  have himg : (Finset.range r).filter (fun x => p ∣ x)
      = (Finset.range (r / p)).image (fun i => p * i) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_image]
    constructor
    · rintro ⟨hx, k, rfl⟩
      exact ⟨k, by rw [Nat.lt_div_iff_mul_lt' hd]; omega, rfl⟩
    · rintro ⟨k, hk, rfl⟩
      refine ⟨?_, ⟨k, rfl⟩⟩
      rw [Nat.lt_div_iff_mul_lt' hd] at hk
      omega
  rw [himg, Finset.card_image_of_injective _ (mul_right_injective₀ (by omega : p ≠ 0)),
    Finset.card_range]

theorem card_multipleRecords {p : ℕ} (hp : 0 < p) (hd : p ∣ r) :
    (multipleRecords r m p).card = (r / p) ^ m := by
  rw [multipleRecords, Fintype.card_piFinset]
  simp [card_multiples hp hd]

/-- Every bad record has all its entries divisible by some prime factor of `r`. -/
theorem badRecords_subset (hr : 0 < r) :
    badRecords r m ⊆ (r.primeFactors).biUnion (fun p => multipleRecords r m p) := by
  intro f hf
  rw [badRecords, Finset.mem_filter] at hf
  obtain ⟨hmem, hgcd⟩ := hf
  obtain ⟨p, hp, hpg⟩ := Nat.exists_prime_and_dvd hgcd
  have hpr : p ∣ r := hpg.trans (Nat.gcd_dvd_right _ _)
  refine Finset.mem_biUnion.mpr ⟨p, Nat.mem_primeFactors.mpr ⟨hp, hpr, by omega⟩, ?_⟩
  rw [multipleRecords, Fintype.mem_piFinset]
  intro i
  rw [Finset.mem_filter, Finset.mem_range]
  refine ⟨?_, ?_⟩
  · rw [allRecords, Fintype.mem_piFinset] at hmem
    simpa using hmem i
  · refine hpg.trans ?_
    exact (Nat.gcd_dvd_left _ _).trans (recordGcd_dvd_mem (by simp : f i ∈ List.ofFn f))

/-- **The bad records are exponentially rare.**  At most a fraction `ω(r) / 2^m`
of the length-`m` records fails the joint-coprimality criterion. -/
theorem card_bad_records_le (hr : 0 < r) :
    (badRecords r m).card * 2 ^ m ≤ r.primeFactors.card * r ^ m := by
  have hsub := Finset.card_le_card (badRecords_subset (m := m) hr)
  have hbi : ((r.primeFactors).biUnion (fun p => multipleRecords r m p)).card
      ≤ ∑ p ∈ r.primeFactors, (multipleRecords r m p).card := Finset.card_biUnion_le
  have hterm : ∀ p ∈ r.primeFactors, (multipleRecords r m p).card * 2 ^ m ≤ r ^ m := by
    intro p hp
    have hprime := Nat.prime_of_mem_primeFactors hp
    have hpd : p ∣ r := Nat.dvd_of_mem_primeFactors hp
    rw [card_multipleRecords hprime.pos hpd, ← mul_pow]
    refine Nat.pow_le_pow_left ?_ m
    have h2 : 2 ≤ p := hprime.two_le
    have : r / p * p ≤ r := Nat.div_mul_le_self r p
    calc r / p * 2 ≤ r / p * p := Nat.mul_le_mul_left _ h2
      _ ≤ r := this
  calc (badRecords r m).card * 2 ^ m
      ≤ (∑ p ∈ r.primeFactors, (multipleRecords r m p).card) * 2 ^ m := by
        exact Nat.mul_le_mul_right _ (le_trans hsub hbi)
    _ = ∑ p ∈ r.primeFactors, (multipleRecords r m p).card * 2 ^ m := by
        rw [Finset.sum_mul]
    _ ≤ ∑ _p ∈ r.primeFactors, r ^ m := Finset.sum_le_sum hterm
    _ = r.primeFactors.card * r ^ m := by rw [Finset.sum_const, smul_eq_mul]

/-- The number of distinct prime factors is at most `log₂ r`. -/
theorem two_pow_card_primeFactors_le (hr : 0 < r) : 2 ^ r.primeFactors.card ≤ r := by
  calc 2 ^ r.primeFactors.card = ∏ _p ∈ r.primeFactors, 2 := by rw [Finset.prod_const]
    _ ≤ ∏ p ∈ r.primeFactors, p :=
        Finset.prod_le_prod' (fun p hp => (Nat.prime_of_mem_primeFactors hp).two_le)
    _ ≤ r := Nat.le_of_dvd hr (Nat.prod_primeFactors_dvd r)

/-- **A successful record exists once `2^m` beats the number of prime factors.** -/
theorem exists_good_record (hr : 0 < r) (hm : r.primeFactors.card < 2 ^ m) :
    ∃ f : Fin m → ℕ, (∀ i, f i < r) ∧ Nat.gcd (recordGcd (List.ofFn f)) r = 1 := by
  have hlt : (badRecords r m).card < (allRecords r m).card := by
    rw [card_allRecords]
    have h1 := card_bad_records_le (r := r) (m := m) hr
    have hrm : 0 < r ^ m := Nat.pow_pos hr
    by_contra hcon
    push_neg at hcon
    have h3 : r ^ m * 2 ^ m ≤ r.primeFactors.card * r ^ m :=
      le_trans (Nat.mul_le_mul_right _ hcon) h1
    have h5 : r ^ m * 2 ^ m ≤ r ^ m * r.primeFactors.card := by
      calc r ^ m * 2 ^ m ≤ r.primeFactors.card * r ^ m := h3
        _ = r ^ m * r.primeFactors.card := mul_comm _ _
    have h4 := Nat.le_of_mul_le_mul_left h5 hrm
    omega
  obtain ⟨f, hf, hfb⟩ := Finset.exists_mem_notMem_of_card_lt_card hlt
  refine ⟨f, ?_, ?_⟩
  · intro i
    rw [allRecords, Fintype.mem_piFinset] at hf
    simpa using hf i
  · by_contra hgcd
    exact hfb (by rw [badRecords, Finset.mem_filter]; exact ⟨hf, hgcd⟩)

/-- **`log₂ log₂ r + 1` samples always suffice.**  For every order `r ≥ 2` and every
`m` with `log₂ r < 2 ^ m` there is a record of `m` numerators below `r` that
recovers the order exactly. -/
theorem good_record_of_log_log (hr : 0 < r) (hm : Nat.log 2 r < 2 ^ m) :
    ∃ f : Fin m → ℕ, (∀ i, f i < r) ∧ recordEstimate (List.ofFn f) r = r := by
  have hw : r.primeFactors.card ≤ Nat.log 2 r := by
    have h1 : 2 ^ r.primeFactors.card ≤ r := two_pow_card_primeFactors_le hr
    exact (Nat.le_log_iff_pow_le (by norm_num) (by omega)).mpr h1
  obtain ⟨f, hf, hgcd⟩ := exists_good_record hr (lt_of_le_of_lt hw hm)
  exact ⟨f, hf, samples_recover hr hgcd⟩

end QubitTrade