import Mathlib
import Shared.ShorPeakCertificationRamp
import Shared.ShorRampSharpness

/-!
# Where the *real* wall is: the informative ramp and its linear threshold

*(FACT round-25 #1 — QUBIT-TRADE2, cycle 3; builds on
`Shared.ShorRampSharpness`.)*

Cycle 1 refuted the quadratic wall `q = r²` and cycle 2 located the saturation
point at `q = r(r-1)`.  This file answers the remaining question: *is there any
wall at all?*  There is — but it is **linear**, not quadratic.

* `infoPeaks_eq_empty_iff` — **the true wall.**  The set of informative
  certificates (numerator coprime to `r`, so that continued fractions return
  the period itself) is empty **exactly** when `q < 2r`, i.e. when the register
  is narrower than `log₂ r + 1` bits.  Below that line no number of samples can
  help: certification fails deterministically, which is the honest home of the
  round-14 "ten samples fail" observation.  Above it the ramp of cycle 1 runs
  smoothly up to saturation at `q = r(r-1)`.
* `card_infoPeaks_prime` — for a prime period every certificate except the
  trivial one `j = 0` is informative, so the informative count is exactly
  `2⌊q/(2r)⌋`: the ramp and the informative ramp coincide.
* `card_headTotatives_ge` — for a general period the informative count is
  thinned only by the small prime divisors of `r`, with the explicit
  Legendre-type bound `#totatives ≥ B - ∑_{p ∣ r} ⌊B/p⌋`.

The resulting three-regime picture of the register axis is:

| regime            | width                          | behaviour                    |
|-------------------|--------------------------------|------------------------------|
| dead              | `q < 2r`                       | no informative certificate   |
| ramp              | `2r ≤ q < r(r-1)`              | rate `≈ q/r²`, unit slope    |
| saturated         | `r(r-1) ≤ q`                   | every peak certifies         |
-/

namespace ShorPeakRamp

open Finset

/-! ## 1. The linear wall -/

/-- **The true wall is linear.**  Informative certificates exist precisely when
the register holds at least one bit more than `log₂ r`; below `q = 2r`
certification fails deterministically, no matter how many samples are drawn.
-/
theorem infoPeaks_eq_empty_iff (q r : ℕ) (hr : 2 ≤ r) (hco : Nat.Coprime q r)
    (h : 2 * (q / (2 * r)) < r) : infoPeaks q r = ∅ ↔ q < 2 * r := by
  have hcard := card_infoPeaks q r hr hco h
  rw [← Finset.card_eq_zero, hcard]
  constructor
  · intro h0
    have hB : (headTotatives r (q / (2 * r))).card = 0 := by omega
    by_contra hcon
    push_neg at hcon
    have hBpos : 1 ≤ q / (2 * r) := (Nat.one_le_div_iff (by omega)).mpr hcon
    have : 1 ∈ headTotatives r (q / (2 * r)) := by
      simp only [headTotatives, mem_filter, mem_Icc]
      exact ⟨⟨le_refl 1, hBpos⟩, Nat.coprime_one_left r⟩
    have := Finset.card_pos.mpr ⟨1, this⟩
    omega
  · intro hq
    have hB : q / (2 * r) = 0 := Nat.div_eq_of_lt hq
    rw [hB]
    have : headTotatives r 0 = ∅ := by
      simp [headTotatives]
    rw [this]
    simp


/-- **Deterministic failure below the linear wall.**  If the register is
narrower than `log₂(2r)` bits then *no* peak with a coprime numerator can be
certified, whatever the measurement outcome: the failure is deterministic, and
no sample count repairs it.  This is the honest, linear-scale version of the
refuted quadratic wall. -/
theorem deterministic_failure_below_two_mul (q r : ℕ) (hr : 2 ≤ r)
    (hco : Nat.Coprime q r) (hq : q < 2 * r) :
    ∀ j, 0 < j → j < r → Nat.Coprime j r → ¬ PeakCertifies q r j := by
  have hB : q / (2 * r) = 0 := Nat.div_eq_of_lt hq
  have hsat : 2 * (q / (2 * r)) < r := by omega
  have hempty : infoPeaks q r = ∅ := (infoPeaks_eq_empty_iff q r hr hco hsat).mpr hq
  intro j hj0 hjr hjcop hcert
  have hmem : j ∈ infoPeaks q r := by
    simp only [infoPeaks, certPeaks, Finset.mem_filter, Finset.mem_range]
    exact ⟨⟨hjr, (peakCertifies_iff q r j (by omega)).mp hcert⟩, hjcop⟩
  rw [hempty] at hmem
  exact absurd hmem (Finset.notMem_empty j)

/-! ## 2. Prime periods: the whole ramp is informative -/

/-- For a prime period, every residue of the head block is a totative. -/
theorem card_headTotatives_prime (r B : ℕ) (hp : Nat.Prime r) (hB : B < r) :
    (headTotatives r B).card = B := by
  have : headTotatives r B = Icc 1 B := by
    apply Finset.filter_true_of_mem
    intro m hm
    simp only [mem_Icc] at hm
    have hnd : ¬ (r ∣ m) := by
      intro hdvd
      have := Nat.le_of_dvd (by omega) hdvd
      omega
    exact Nat.Coprime.symm ((Nat.Prime.coprime_iff_not_dvd hp).mpr hnd)
  rw [this, Nat.card_Icc]
  omega

/-- **Prime periods.**  Below saturation all certificates but the trivial one
are informative: the informative ramp *is* the ramp. -/
theorem card_infoPeaks_prime (q r : ℕ) (hp : Nat.Prime r) (hco : Nat.Coprime q r)
    (h : 2 * (q / (2 * r)) < r) :
    (infoPeaks q r).card = 2 * (q / (2 * r)) := by
  have hr2 : 2 ≤ r := hp.two_le
  rw [card_infoPeaks q r hr2 hco h, card_headTotatives_prime r _ hp (by omega)]

/-! ## 3. Composite periods: thinning by the small prime divisors -/

/-- The multiples of `p` in the head block are exactly `⌊B/p⌋` many. -/
theorem card_multiples (B p : ℕ) :
    ((Icc 1 B).filter (fun m => p ∣ m)).card = B / p := by
  have hIcc : Finset.Icc 1 B = Finset.Ioc 0 B := rfl
  rw [hIcc]
  exact Nat.Ioc_filter_dvd_card_eq_div B p

/-- **Legendre-type lower bound for the informative ramp.**  The head block
loses only the multiples of the prime divisors of `r`, so the number of
totatives — and hence, by `card_infoPeaks`, half the informative certification
count — is at least `B - ∑_{p ∣ r} ⌊B/p⌋`. -/
theorem card_headTotatives_ge (r B : ℕ) (hr : 0 < r) :
    B - ∑ p ∈ r.primeFactors, B / p ≤ (headTotatives r B).card := by
  classical
  set S : Finset ℕ := Icc 1 B with hS
  have hsplit : (headTotatives r B).card
      + (S.filter (fun m => ¬ Nat.Coprime m r)).card = B := by
    have := Finset.card_filter_add_card_filter_not
      (s := S) (p := fun m => Nat.Coprime m r)
    rw [hS] at this
    simpa [headTotatives, hS, Nat.card_Icc] using this
  have hsub : S.filter (fun m => ¬ Nat.Coprime m r)
      ⊆ r.primeFactors.biUnion (fun p => S.filter (fun m => p ∣ m)) := by
    intro m hm
    simp only [hS, mem_filter, mem_Icc] at hm
    obtain ⟨⟨hm1, hmB⟩, hncop⟩ := hm
    set d := Nat.gcd m r with hd
    have hd1 : d ≠ 1 := hncop
    have hd0 : d ≠ 0 := by
      intro h0
      have : m = 0 := Nat.eq_zero_of_gcd_eq_zero_left (hd ▸ h0)
      omega
    have hd2 : 2 ≤ d := by omega
    have hpp : Nat.Prime d.minFac := Nat.minFac_prime hd1
    have hdm : d.minFac ∣ m := dvd_trans (Nat.minFac_dvd d) (Nat.gcd_dvd_left m r)
    have hdr : d.minFac ∣ r := dvd_trans (Nat.minFac_dvd d) (Nat.gcd_dvd_right m r)
    refine Finset.mem_biUnion.mpr ⟨d.minFac, ?_, ?_⟩
    · exact Nat.mem_primeFactors.mpr ⟨hpp, hdr, by omega⟩
    · simp only [hS, mem_filter, mem_Icc]
      exact ⟨⟨hm1, hmB⟩, hdm⟩
  have hle : (S.filter (fun m => ¬ Nat.Coprime m r)).card
      ≤ ∑ p ∈ r.primeFactors, B / p := by
    calc (S.filter (fun m => ¬ Nat.Coprime m r)).card
        ≤ (r.primeFactors.biUnion (fun p => S.filter (fun m => p ∣ m))).card :=
          Finset.card_le_card hsub
      _ ≤ ∑ p ∈ r.primeFactors, (S.filter (fun m => p ∣ m)).card :=
          Finset.card_biUnion_le
      _ = ∑ p ∈ r.primeFactors, B / p := by
          refine Finset.sum_congr rfl ?_
          intro p _
          rw [hS]
          exact card_multiples B p
  omega

/-- **Informative ramp, composite periods.**  Combining
`card_headTotatives_ge` with `card_infoPeaks`: the informative certification
count is at least `2(B - ∑_{p ∣ r} ⌊B/p⌋)` with `B = ⌊q/(2r)⌋`. -/
theorem card_infoPeaks_ge (q r : ℕ) (hr : 2 ≤ r) (hco : Nat.Coprime q r)
    (h : 2 * (q / (2 * r)) < r) :
    2 * ((q / (2 * r)) - ∑ p ∈ r.primeFactors, (q / (2 * r)) / p)
      ≤ (infoPeaks q r).card := by
  rw [card_infoPeaks q r hr hco h]
  have := card_headTotatives_ge r (q / (2 * r)) (by omega)
  omega

/-! ## 4. Lab notes: the three regimes

With `r = 21` (`r(r-1) = 420`, `2r = 42`):

| `q`  | regime     | `#certPeaks` | `#infoPeaks` |
|------|------------|--------------|--------------|
|  32  | dead       |      1       |      0       |
|  64  | ramp       |      3       |      2       |
| 256  | ramp       |     13       |      8       |
| 512  | saturated  |     21       |     12 = φ(21) |

The dead regime stops exactly at `q = 2r = 42`, as `infoPeaks_eq_empty_iff`
predicts, and the saturated informative count is `φ(r)`, the total number of
usable numerators. -/

example : infoPeaks 32 21 = ∅ := by decide
example : (infoPeaks 64 21).card = 2 := by decide
example : (infoPeaks 512 21).card = 12 := by decide
example : Nat.totient 21 = 12 := by decide

end ShorPeakRamp