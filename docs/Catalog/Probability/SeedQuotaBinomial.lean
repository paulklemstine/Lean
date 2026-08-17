/-
# Binomial rung theory of a seed ensemble: the parity law of calibration

`Logic.KneeMedianLaw` formalised the *quota ladder* of a seed ensemble — the least budget
at which at least `m` of the seeds clear the accuracy bar — and
`Logic.KneeMedianAmplification` computed the three rung distribution functions of a
**three**-seed ensemble from the eight-point sample space (`quotaProb p m`, with the median
rung `3p² − 2p³`).  Round NET-48 closed the three-seed ensemble at `(d = 4, ctx = 2048)`
with knee set `{160, 224, 256}`, median `224 = (7/8)·(d·ctx/32)`, and its stated next step
is a **fourth seed** at the same cell.

This file supplies the general-`n` theory that the fourth seed forces, in the probability
model the round uses: `n` independent seeds, each clearing the bar at a fixed budget with
probability `p`; the `m`-th rung of the quota ladder sits at or below that budget exactly
when at least `m` of the seeds pass.  The rung distribution function is therefore the
binomial upper tail `rungProb n m p`.

Main results.

* `SeedQuota.rungProb_succ` — the Pascal recursion
  `rungProb (n+1) (m+1) p = p · rungProb n m p + (1-p) · rungProb n (m+1) p`, proved from
  the sum definition.
* `SeedQuota.rungProb_mono_p` / `rungProb_strictMono_p` — every rung is (strictly)
  increasing in the per-seed pass probability.  The monotone step is an induction on `n`
  through the Pascal recursion; strictness comes from the exact one-term rung gap
  `rungProb_sub_succ`.
* `SeedQuota.tailCount_symm` — the reflection identity
  `tailCount n m + tailCount n (n+1-m) = 2^n`, together with `tailCount_strictAnti`.
* **The parity law of calibration.**  `rungProb_half_eq_iff` : a rung is *calibrated*
  (reads `1/2` when the seeds are coin flips) iff `2m = n+1`.  Hence
  `exists_calibrated_rung_iff_odd` : an ensemble has a calibrated rung **iff its size is
  odd**, and then it is unique (`calibrated_rung_unique`); an even ensemble has **no**
  calibrated rung (`even_no_calibrated_rung`).
* **The calibration defect of an even ensemble.**  `even_central_rungs` :
  `rungProb (2r) r (1/2) = 1/2 + defect r` and `rungProb (2r) (r+1) (1/2) = 1/2 - defect r`
  with `defect r = C(2r,r)/2^(2r+1)`; so `even_rungs_average_calibrated` : the two central
  rungs of an even ensemble average to exactly `1/2` — calibration is recovered only by
  averaging, which is precisely the convention "median of an even sample = mean of the two
  middle order statistics".
* `SeedQuota.defect_strictAnti` and `SeedQuota.defect_tendsto_zero` — the defect strictly
  decreases in `r` and tends to `0` at rate `r^(-1/2)`, via the self-contained central
  binomial bound `centralBinom_sq_mul_le` : `C(2r,r)^2 · (3r+1) ≤ 16^r`.  Even ensembles are
  asymptotically, but never exactly, calibrated.
-/

import Mathlib

namespace SeedQuota

open Finset

/-! ## 1.  The binomial upper tail as a rung distribution function -/

/-- `tailCount n m` is the number of `n`-seed pass/fail outcomes in which at least `m` seeds
pass: `∑_{j ≥ m} C(n,j)`. -/
def tailCount (n m : ℕ) : ℕ := ∑ j ∈ Finset.Ico m (n + 1), n.choose j

/-- `rungProb n m p` is the probability that at least `m` of `n` independent seeds pass,
each with probability `p`; equivalently (by `KneeAmplify.quotaBudget_le_iff`) the
probability that the `m`-th rung of the quota ladder sits at or below the given budget. -/
noncomputable def rungProb (n m : ℕ) (p : ℝ) : ℝ :=
  ∑ j ∈ Finset.Ico m (n + 1), (n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)

/-- The bottom rung is certain: at least `0` seeds always pass. -/
theorem rungProb_zero (n : ℕ) (p : ℝ) : rungProb n 0 p = 1 := by
  have h : (p + (1 - p)) ^ n
      = ∑ k ∈ range (n + 1), p ^ k * (1 - p) ^ (n - k) * (n.choose k : ℝ) :=
    add_pow p (1 - p) n
  have h1 : p + (1 - p) = 1 := by ring
  rw [h1, one_pow] at h
  calc rungProb n 0 p
      = ∑ k ∈ range (n + 1), p ^ k * (1 - p) ^ (n - k) * (n.choose k : ℝ) := by
        rw [rungProb, Nat.Ico_zero_eq_range]
        exact Finset.sum_congr rfl fun k _ => by ring
    _ = 1 := h.symm

/-- Above the top rung nothing can pass. -/
theorem rungProb_of_gt {n m : ℕ} (h : n + 1 ≤ m) (p : ℝ) : rungProb n m p = 0 := by
  rw [rungProb, Finset.Ico_eq_empty (by omega), Finset.sum_empty]

theorem rungProb_nonneg {n m : ℕ} {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) : 0 ≤ rungProb n m p := by
  refine Finset.sum_nonneg fun j _ => ?_
  have : (0:ℝ) ≤ 1 - p := by linarith
  positivity

/-- **Rungs are antitone in the quota**: demanding more passing seeds is less likely. -/
theorem rungProb_antitone {n m m' : ℕ} {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) (hm : m ≤ m') :
    rungProb n m' p ≤ rungProb n m p := by
  refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.Ico_subset_Ico hm le_rfl) ?_
  intro j _ _
  have : (0:ℝ) ≤ 1 - p := by linarith
  positivity

/-- **The rung gap is a single binomial term.**  Raising the quota by one costs exactly the
probability that *exactly* `m` seeds pass. -/
theorem rungProb_sub_succ {n m : ℕ} (h : m ≤ n) (p : ℝ) :
    rungProb n m p - rungProb n (m + 1) p = (n.choose m : ℝ) * p ^ m * (1 - p) ^ (n - m) := by
  have hlt : m < n + 1 := by omega
  rw [rungProb, rungProb, Finset.sum_eq_sum_Ico_succ_bot hlt]
  ring

/-! ## 2.  The Pascal recursion and monotonicity in the per-seed probability -/

private theorem sum_Ico_shift (m n : ℕ) (f : ℕ → ℝ) :
    ∑ j ∈ Finset.Ico (m + 1) (n + 1), f j = ∑ i ∈ Finset.Ico m n, f (i + 1) := by
  rw [Finset.sum_Ico_eq_sum_range, Finset.sum_Ico_eq_sum_range]
  have hidx : n + 1 - (m + 1) = n - m := by omega
  rw [hidx]
  exact Finset.sum_congr rfl fun i _ => by ring_nf

/-- **Pascal recursion for the rungs.**  Conditioning on the last seed:
`P(≥ m+1 of n+1) = p · P(≥ m of n) + (1-p) · P(≥ m+1 of n)`. -/
theorem rungProb_succ (n m : ℕ) (p : ℝ) :
    rungProb (n + 1) (m + 1) p = p * rungProb n m p + (1 - p) * rungProb n (m + 1) p := by
  have hL : rungProb (n + 1) (m + 1) p
      = ∑ i ∈ Finset.Ico m (n + 1),
          ((n.choose i : ℝ) + (n.choose (i + 1) : ℝ)) * p ^ (i + 1) * (1 - p) ^ (n - i) := by
    rw [rungProb]
    have hsh := sum_Ico_shift m (n + 1)
      (fun j => ((n + 1).choose j : ℝ) * p ^ j * (1 - p) ^ (n + 1 - j))
    rw [hsh]
    refine Finset.sum_congr rfl fun i _ => ?_
    have hc : ((n + 1).choose (i + 1) : ℝ) = (n.choose i : ℝ) + (n.choose (i + 1) : ℝ) := by
      rw [Nat.choose_succ_succ]
      push_cast
      ring
    have hs : n + 1 - (i + 1) = n - i := by omega
    simp only [hc, hs]
  have hsecond : ∑ i ∈ Finset.Ico m (n + 1),
      (n.choose (i + 1) : ℝ) * p ^ (i + 1) * (1 - p) ^ (n - i)
      = (1 - p) * rungProb n (m + 1) p := by
    rcases lt_or_ge n m with hnm | hmn
    · rw [Finset.Ico_eq_empty (by omega), rungProb, Finset.Ico_eq_empty (by omega)]
      simp
    · rw [Nat.Ico_succ_right_eq_insert_Ico hmn, Finset.sum_insert (by simp)]
      have hzero : (n.choose (n + 1) : ℝ) = 0 := by
        rw [Nat.choose_succ_self]; norm_num
      have hrest : ∑ i ∈ Finset.Ico m n,
          (n.choose (i + 1) : ℝ) * p ^ (i + 1) * (1 - p) ^ (n - i)
          = (1 - p) * rungProb n (m + 1) p := by
        rw [rungProb, Finset.mul_sum]
        rw [sum_Ico_shift m n (fun j => (1 - p) * ((n.choose j : ℝ) * p ^ j * (1 - p) ^ (n - j)))]
        refine Finset.sum_congr rfl fun i hi => ?_
        simp only [Finset.mem_Ico] at hi
        have hexp : n - i = (n - (i + 1)) + 1 := by omega
        rw [hexp]
        ring
      rw [hzero, hrest]
      ring
  have hsplit : ∀ i ∈ Finset.Ico m (n + 1),
      ((n.choose i : ℝ) + (n.choose (i + 1) : ℝ)) * p ^ (i + 1) * (1 - p) ^ (n - i)
        = p * ((n.choose i : ℝ) * p ^ i * (1 - p) ^ (n - i))
          + (n.choose (i + 1) : ℝ) * p ^ (i + 1) * (1 - p) ^ (n - i) := by
    intro i _
    ring
  rw [hL, Finset.sum_congr rfl hsplit, Finset.sum_add_distrib, ← Finset.mul_sum, hsecond]
  simp only [rungProb]

/-- **Every rung is monotone in the per-seed pass probability.**  Proved by induction on the
ensemble size through the Pascal recursion; the essential extra input is that rungs are
antitone in the quota. -/
theorem rungProb_mono_p (n m : ℕ) {p q : ℝ} (h0 : 0 ≤ p) (hpq : p ≤ q) (h1 : q ≤ 1) :
    rungProb n m p ≤ rungProb n m q := by
  induction n generalizing m with
  | zero =>
      match m with
      | 0 => simp [rungProb_zero]
      | (k + 1) => rw [rungProb_of_gt (by omega), rungProb_of_gt (by omega)]
  | succ n ih =>
      match m with
      | 0 => simp [rungProb_zero]
      | (k + 1) =>
          have hq0 : 0 ≤ q := le_trans h0 hpq
          have hp1 : p ≤ 1 := le_trans hpq h1
          have hA : rungProb n k p ≤ rungProb n k q := ih k
          have hB : rungProb n (k + 1) p ≤ rungProb n (k + 1) q := ih (k + 1)
          have hAB : rungProb n (k + 1) p ≤ rungProb n k p :=
            rungProb_antitone h0 hp1 (Nat.le_succ k)
          rw [rungProb_succ, rungProb_succ]
          nlinarith [hA, hB, hAB, hq0, h1, hpq]

/-- **Strict monotonicity.**  For a nontrivial quota (`1 ≤ m ≤ n`) and a nondegenerate
probability the rung distribution function is strictly increasing: an ensemble rung really
does resolve the per-seed probability. -/
theorem rungProb_strictMono_p {n m : ℕ} (hm : 1 ≤ m) (hmn : m ≤ n) {p q : ℝ}
    (h0 : 0 < p) (hpq : p < q) (h1 : q < 1) :
    rungProb n m p < rungProb n m q := by
  obtain ⟨n', rfl⟩ : ∃ n', n = n' + 1 := ⟨n - 1, by omega⟩
  obtain ⟨k, rfl⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
  have hkn : k ≤ n' := by omega
  have hq0 : 0 ≤ q := le_of_lt (lt_trans h0 hpq)
  have hp1 : p ≤ 1 := le_of_lt (lt_trans hpq h1)
  have hA : rungProb n' k p ≤ rungProb n' k q :=
    rungProb_mono_p n' k h0.le hpq.le h1.le
  have hB : rungProb n' (k + 1) p ≤ rungProb n' (k + 1) q :=
    rungProb_mono_p n' (k + 1) h0.le hpq.le h1.le
  have hgap : rungProb n' k p - rungProb n' (k + 1) p
      = (n'.choose k : ℝ) * p ^ k * (1 - p) ^ (n' - k) := rungProb_sub_succ hkn p
  have hgap_pos : 0 < rungProb n' k p - rungProb n' (k + 1) p := by
    rw [hgap]
    have hc : (0:ℝ) < (n'.choose k : ℝ) := by exact_mod_cast Nat.choose_pos hkn
    have h1p : (0:ℝ) < 1 - p := by linarith
    positivity
  rw [rungProb_succ, rungProb_succ]
  nlinarith [hA, hB, hgap_pos, hq0, h1, hpq]

/-! ## 3.  Coin-flip seeds: the reflection identity and the parity law -/

/-- At `p = 1/2` a rung reads the counting fraction `tailCount n m / 2^n`. -/
theorem rungProb_half (n m : ℕ) : rungProb n m (1/2 : ℝ) = (tailCount n m : ℝ) / 2 ^ n := by
  rw [rungProb, tailCount, Nat.cast_sum, Finset.sum_div]
  refine Finset.sum_congr rfl fun j hj => ?_
  simp only [Finset.mem_Ico] at hj
  have hpow : (1 - 1/2 : ℝ) ^ (n - j) * (1/2 : ℝ) ^ j = (1/2 : ℝ) ^ n := by
    rw [show (1 - 1/2 : ℝ) = 1/2 by norm_num, ← pow_add]
    congr 1
    omega
  calc (n.choose j : ℝ) * (1/2 : ℝ) ^ j * (1 - 1/2 : ℝ) ^ (n - j)
      = (n.choose j : ℝ) * ((1 - 1/2 : ℝ) ^ (n - j) * (1/2 : ℝ) ^ j) := by ring
    _ = (n.choose j : ℝ) * (1/2 : ℝ) ^ n := by rw [hpow]
    _ = (n.choose j : ℝ) / 2 ^ n := by rw [one_div, inv_pow]; ring

/-- **Reflection.**  Swapping pass and fail is a bijection of the sample space, so the low
counts are the complementary high counts. -/
theorem sum_range_eq_tailCount (n m : ℕ) (h : m ≤ n + 1) :
    ∑ j ∈ range m, n.choose j = tailCount n (n + 1 - m) := by
  rw [tailCount]
  refine Finset.sum_nbij' (fun i => n - i) (fun j => n - j) ?_ ?_ ?_ ?_ ?_
  · intro a ha
    simp only [Finset.mem_range] at ha
    simp only [Finset.mem_Ico]
    omega
  · intro b hb
    simp only [Finset.mem_Ico] at hb
    simp only [Finset.mem_range]
    omega
  · intro a ha
    simp only [Finset.mem_range] at ha
    show n - (n - a) = a
    omega
  · intro b hb
    simp only [Finset.mem_Ico] at hb
    show n - (n - b) = b
    omega
  · intro a ha
    simp only [Finset.mem_range] at ha
    exact (Nat.choose_symm (by omega)).symm

/-- **The reflection identity.**  `tailCount n m + tailCount n (n+1-m) = 2^n`. -/
theorem tailCount_symm (n m : ℕ) (h : m ≤ n + 1) :
    tailCount n m + tailCount n (n + 1 - m) = 2 ^ n := by
  rw [← sum_range_eq_tailCount n m h, tailCount, add_comm]
  rw [Finset.sum_range_add_sum_Ico _ h]
  exact Nat.sum_range_choose n

/-- Raising the quota strictly decreases the count, as long as the quota stays meaningful. -/
theorem tailCount_strictAnti {n m m' : ℕ} (hm : m < m') (hm' : m' ≤ n + 1) :
    tailCount n m' < tailCount n m := by
  rw [tailCount, tailCount]
  refine Finset.sum_lt_sum_of_subset (Finset.Ico_subset_Ico hm.le le_rfl) (i := m) ?_ ?_ ?_ ?_
  · simp only [Finset.mem_Ico]; omega
  · simp only [Finset.mem_Ico]; omega
  · exact Nat.choose_pos (by omega)
  · intro j _ _
    exact Nat.zero_le _

/-- **The parity law of calibration.**  A rung of an `n`-seed ensemble reads exactly `1/2`
on coin-flip seeds iff `2m = n + 1`.  Calibration is thus a *parity* phenomenon: it requires
`n` odd. -/
theorem rungProb_half_eq_iff {n m : ℕ} (h : m ≤ n + 1) :
    rungProb n m (1/2 : ℝ) = 1/2 ↔ 2 * m = n + 1 := by
  have hsymm := tailCount_symm n m h
  have hpow : (0:ℝ) < 2 ^ n := by positivity
  rw [rungProb_half, div_eq_div_iff (ne_of_gt hpow) (by norm_num : (2:ℝ) ≠ 0)]
  constructor
  · intro hcount
    have hnat : 2 * tailCount n m = 2 ^ n := by
      have : (2 * tailCount n m : ℝ) = ((2:ℝ) ^ n) := by push_cast at hcount ⊢; linarith
      exact_mod_cast this
    by_contra hne
    rcases lt_trichotomy m (n + 1 - m) with hlt | heqm | hgt
    · have hstrict := tailCount_strictAnti (n := n) (m := m) (m' := n + 1 - m) hlt (by omega)
      omega
    · omega
    · have hstrict := tailCount_strictAnti (n := n) (m := n + 1 - m) (m' := m) hgt (by omega)
      omega
  · intro hm
    have hrefl : n + 1 - m = m := by omega
    rw [hrefl] at hsymm
    have hcast : (2 * tailCount n m : ℝ) = ((2:ℝ) ^ n) := by
      exact_mod_cast (by omega : 2 * tailCount n m = 2 ^ n)
    push_cast at hcast ⊢
    linarith

/-- **Odd ensembles: the median rung is calibrated.** -/
theorem odd_median_rung_calibrated (r : ℕ) :
    rungProb (2 * r + 1) (r + 1) (1/2 : ℝ) = 1/2 :=
  (rungProb_half_eq_iff (by omega)).2 (by omega)

/-- **Even ensembles have no calibrated rung.**  Whatever quota is read off a `2r`-seed
ensemble, it is biased on coin-flip seeds. -/
theorem even_no_calibrated_rung (r m : ℕ) :
    rungProb (2 * r) m (1/2 : ℝ) ≠ 1/2 := by
  rcases le_or_gt m (2 * r + 1) with h | h
  · intro hcon
    have := (rungProb_half_eq_iff h).1 hcon
    omega
  · rw [rungProb_of_gt (by omega)]
    norm_num

/-- **Calibration is exactly an odd-size phenomenon.** -/
theorem exists_calibrated_rung_iff_odd (n : ℕ) :
    (∃ m, rungProb n m (1/2 : ℝ) = 1/2) ↔ Odd n := by
  constructor
  · rintro ⟨m, hm⟩
    rcases Nat.even_or_odd n with he | ho
    · obtain ⟨r, hr⟩ := he
      rw [show n = 2 * r by omega] at hm
      exact absurd hm (even_no_calibrated_rung r m)
    · exact ho
  · rintro ⟨r, hr⟩
    refine ⟨r + 1, ?_⟩
    rw [show n = 2 * r + 1 by omega]
    exact odd_median_rung_calibrated r

/-- And when it exists the calibrated rung is unique. -/
theorem calibrated_rung_unique {n m m' : ℕ} (h : m ≤ n + 1) (h' : m' ≤ n + 1)
    (hm : rungProb n m (1/2 : ℝ) = 1/2) (hm' : rungProb n m' (1/2 : ℝ) = 1/2) : m = m' := by
  have h1 := (rungProb_half_eq_iff h).1 hm
  have h2 := (rungProb_half_eq_iff h').1 hm'
  omega

/-! ## 4.  The calibration defect of an even ensemble -/

/-- The calibration defect of a `2r`-seed ensemble: `C(2r,r)/2^(2r+1)`. -/
noncomputable def defect (r : ℕ) : ℝ := ((2 * r).choose r : ℝ) / 2 ^ (2 * r + 1)

theorem defect_pos (r : ℕ) : 0 < defect r := by
  have hc : (0:ℝ) < ((2 * r).choose r : ℝ) := by exact_mod_cast Nat.choose_pos (by omega)
  unfold defect
  positivity

/-- **The two central rungs of an even ensemble are symmetric about `1/2`**, offset by the
calibration defect. -/
theorem even_central_rungs (r : ℕ) :
    rungProb (2 * r) r (1/2 : ℝ) = 1/2 + defect r ∧
      rungProb (2 * r) (r + 1) (1/2 : ℝ) = 1/2 - defect r := by
  have hsymm : tailCount (2 * r) r + tailCount (2 * r) (r + 1) = 2 ^ (2 * r) := by
    have h := tailCount_symm (2 * r) (r + 1) (by omega)
    have hidx : 2 * r + 1 - (r + 1) = r := by omega
    rw [hidx] at h
    omega
  have hgap : tailCount (2 * r) r = tailCount (2 * r) (r + 1) + (2 * r).choose r := by
    rw [tailCount, tailCount, Finset.sum_eq_sum_Ico_succ_bot (by omega : r < 2 * r + 1)]
    omega
  have keyR : 2 * (tailCount (2 * r) r : ℝ) = 2 ^ (2 * r) + ((2 * r).choose r : ℝ) := by
    exact_mod_cast (by omega : 2 * tailCount (2 * r) r = 2 ^ (2 * r) + (2 * r).choose r)
  have keyR2 : 2 * (tailCount (2 * r) (r + 1) : ℝ) + 2 * ((2 * r).choose r : ℝ)
      = 2 ^ (2 * r) + ((2 * r).choose r : ℝ) := by
    exact_mod_cast (by omega : 2 * tailCount (2 * r) (r + 1) + 2 * ((2 * r).choose r)
      = 2 ^ (2 * r) + (2 * r).choose r)
  have hp : (0:ℝ) < 2 ^ (2 * r) := by positivity
  have hpow2 : (2:ℝ) ^ (2 * r + 1) = 2 ^ (2 * r) * 2 := pow_succ 2 (2 * r)
  constructor
  · rw [rungProb_half, defect, hpow2]
    field_simp
    linarith [keyR]
  · rw [rungProb_half, defect, hpow2]
    field_simp
    linarith [keyR2]

/-- **Averaging restores calibration.**  The two central rungs of an even ensemble average to
exactly `1/2` — the formal content of the convention that the median of an even sample is the
mean of the two middle order statistics. -/
theorem even_rungs_average_calibrated (r : ℕ) :
    (rungProb (2 * r) r (1/2 : ℝ) + rungProb (2 * r) (r + 1) (1/2 : ℝ)) / 2 = 1/2 := by
  obtain ⟨h1, h2⟩ := even_central_rungs r
  rw [h1, h2]
  ring

/-- **The odd rung is a convex combination of the two central even rungs**, with weights `p`
and `1-p`: one more seed interpolates between the two readings an even ensemble offers. -/
theorem odd_rung_convex (r : ℕ) (p : ℝ) :
    rungProb (2 * r + 1) (r + 1) p
      = p * rungProb (2 * r) r p + (1 - p) * rungProb (2 * r) (r + 1) p :=
  rungProb_succ (2 * r) r p

/-- Consequently the odd median rung is bracketed by the two central even rungs. -/
theorem odd_rung_bracket (r : ℕ) {p : ℝ} (h0 : 0 ≤ p) (h1 : p ≤ 1) :
    rungProb (2 * r) (r + 1) p ≤ rungProb (2 * r + 1) (r + 1) p ∧
      rungProb (2 * r + 1) (r + 1) p ≤ rungProb (2 * r) r p := by
  have hconv := odd_rung_convex r p
  have hanti : rungProb (2 * r) (r + 1) p ≤ rungProb (2 * r) r p :=
    rungProb_antitone h0 h1 (Nat.le_succ r)
  constructor <;> nlinarith [hconv, hanti, h0, h1]

/-- **Why the parity law holds, structurally.**  At `p = 1/2` the convex combination of
`odd_rung_convex` is the plain *average* of the two central even rungs; by
`even_rungs_average_calibrated` that average is exactly `1/2`.  So the calibration of an odd
ensemble is precisely the averaging convention for even ones, carried out by an extra
seed. -/
theorem odd_calibration_is_even_averaging (r : ℕ) :
    rungProb (2 * r + 1) (r + 1) (1/2 : ℝ)
      = (rungProb (2 * r) r (1/2 : ℝ) + rungProb (2 * r) (r + 1) (1/2 : ℝ)) / 2 ∧
    rungProb (2 * r + 1) (r + 1) (1/2 : ℝ) = 1/2 := by
  have hconv := odd_rung_convex r (1/2 : ℝ)
  refine ⟨by rw [hconv]; ring, ?_⟩
  rw [hconv]
  have := even_rungs_average_calibrated r
  linarith [this]

/-- **The defect strictly decreases** with ensemble size: larger even ensembles are less
biased, but by `even_no_calibrated_rung` never unbiased. -/
theorem defect_strictAnti (r : ℕ) : defect (r + 1) < defect r := by
  have hrec := Nat.succ_mul_centralBinom_succ r
  have hcpos : 0 < Nat.centralBinom r := Nat.centralBinom_pos r
  have hlt : Nat.centralBinom (r + 1) < 4 * Nat.centralBinom r := by
    have h1 : (r + 1) * Nat.centralBinom (r + 1) < (r + 1) * (4 * Nat.centralBinom r) := by
      rw [hrec]; nlinarith
    exact lt_of_mul_lt_mul_left h1 (Nat.zero_le _)
  have hltR : ((2 * (r + 1)).choose (r + 1) : ℝ) < 4 * ((2 * r).choose r : ℝ) := by
    exact_mod_cast hlt
  have hpow : (2:ℝ) ^ (2 * (r + 1) + 1) = 2 ^ (2 * r + 1) * 4 := by
    rw [show 2 * (r + 1) + 1 = (2 * r + 1) + 2 by ring, pow_add]
    norm_num
  have hp : (0:ℝ) < 2 ^ (2 * r + 1) := by positivity
  unfold defect
  rw [hpow, div_lt_div_iff₀ (by positivity) hp]
  nlinarith [hltR, hp]

/-- **A self-contained central binomial bound**: `C(2r,r)^2 · (3r+1) ≤ 16^r`, equivalently
`C(2r,r) ≤ 4^r / sqrt (3r+1)`.  Proved by induction from the recursion
`(r+1)·C(2r+2,r+1) = 2(2r+1)·C(2r,r)`. -/
theorem centralBinom_sq_mul_le (r : ℕ) :
    (Nat.centralBinom r) ^ 2 * (3 * r + 1) ≤ 16 ^ r := by
  induction r with
  | zero => simp [Nat.centralBinom]
  | succ r ih =>
      have hrec : (r + 1) * (Nat.centralBinom (r + 1)) = 2 * (2 * r + 1) * Nat.centralBinom r :=
        Nat.succ_mul_centralBinom_succ r
      have hkey : ((r + 1) ^ 2) * ((Nat.centralBinom (r + 1)) ^ 2 * (3 * (r + 1) + 1))
          ≤ ((r + 1) ^ 2) * 16 ^ (r + 1) := by
        have hsq : ((r + 1) * Nat.centralBinom (r + 1)) ^ 2
            = (2 * (2 * r + 1)) ^ 2 * (Nat.centralBinom r) ^ 2 := by
          rw [hrec]; ring
        have hprod : ((r + 1) ^ 2) * ((Nat.centralBinom (r + 1)) ^ 2)
            = ((r + 1) * Nat.centralBinom (r + 1)) ^ 2 := by ring
        have hexp : ((r + 1) ^ 2) * ((Nat.centralBinom (r + 1)) ^ 2 * (3 * (r + 1) + 1))
            = (2 * (2 * r + 1)) ^ 2 * (Nat.centralBinom r) ^ 2 * (3 * r + 4) := by
          calc ((r + 1) ^ 2) * ((Nat.centralBinom (r + 1)) ^ 2 * (3 * (r + 1) + 1))
              = (((r + 1) ^ 2) * ((Nat.centralBinom (r + 1)) ^ 2)) * (3 * r + 4) := by ring
            _ = (2 * (2 * r + 1)) ^ 2 * (Nat.centralBinom r) ^ 2 * (3 * r + 4) := by
                rw [hprod, hsq]
        rw [hexp]
        have hstep : (2 * (2 * r + 1)) ^ 2 * (3 * r + 4)
            ≤ (2 * (r + 1)) ^ 2 * (3 * r + 1) * 4 := by nlinarith
        calc (2 * (2 * r + 1)) ^ 2 * (Nat.centralBinom r) ^ 2 * (3 * r + 4)
            = ((2 * (2 * r + 1)) ^ 2 * (3 * r + 4)) * (Nat.centralBinom r) ^ 2 := by ring
          _ ≤ ((2 * (r + 1)) ^ 2 * (3 * r + 1) * 4) * (Nat.centralBinom r) ^ 2 :=
              Nat.mul_le_mul_right _ hstep
          _ = ((r + 1) ^ 2) * 16 * ((Nat.centralBinom r) ^ 2 * (3 * r + 1)) := by ring
          _ ≤ ((r + 1) ^ 2) * 16 * 16 ^ r := Nat.mul_le_mul_left _ ih
          _ = ((r + 1) ^ 2) * 16 ^ (r + 1) := by ring
      have hpos : 0 < (r + 1) ^ 2 := by positivity
      exact Nat.le_of_mul_le_mul_left hkey hpos

/-- **Even ensembles are asymptotically calibrated.**  The defect tends to `0` (at rate
`r^(-1/2)`), so the bias of an even ensemble is real but vanishing: the finite-`r` statement
`even_no_calibrated_rung` is not contradicted in the limit. -/
theorem defect_tendsto_zero : Filter.Tendsto defect Filter.atTop (nhds 0) := by
  have hbound : ∀ r : ℕ, defect r ≤ 1 / (2 * Real.sqrt (3 * r + 1)) := by
    intro r
    have hsq := centralBinom_sq_mul_le r
    have hsqR : ((2 * r).choose r : ℝ) ^ 2 * (3 * (r : ℝ) + 1) ≤ 16 ^ r := by
      have : ((Nat.centralBinom r : ℝ)) ^ 2 * (3 * (r : ℝ) + 1) ≤ 16 ^ r := by
        exact_mod_cast hsq
      simpa [Nat.centralBinom] using this
    have hcpos : (0:ℝ) ≤ ((2 * r).choose r : ℝ) := Nat.cast_nonneg _
    have hspos : (0:ℝ) < Real.sqrt (3 * (r : ℝ) + 1) := by
      apply Real.sqrt_pos.2; positivity
    have h4 : (0:ℝ) < 4 ^ r := by positivity
    have hsqsq : (Real.sqrt (3 * (r : ℝ) + 1)) ^ 2 = 3 * (r : ℝ) + 1 :=
      Real.sq_sqrt (by positivity)
    have h16 : ((4:ℝ) ^ r) ^ 2 = 16 ^ r := by
      rw [← pow_mul, mul_comm r 2, pow_mul]
      norm_num
    have hkey : ((2 * r).choose r : ℝ) * Real.sqrt (3 * (r : ℝ) + 1) ≤ 4 ^ r := by
      by_contra hcon
      push_neg at hcon
      nlinarith [hcon, hcpos, hspos, hsqR, hsqsq, h16, h4]
    have hdef : defect r = ((2 * r).choose r : ℝ) / (2 * 4 ^ r) := by
      unfold defect
      rw [show (2:ℝ) ^ (2 * r + 1) = 2 * 4 ^ r by
        rw [pow_succ, pow_mul]; norm_num; ring]
    rw [hdef, div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [hkey, hspos]
  have hlim : Filter.Tendsto (fun r : ℕ => 1 / (2 * Real.sqrt (3 * r + 1))) Filter.atTop
      (nhds 0) := by
    have hlin : Filter.Tendsto (fun r : ℕ => 3 * (r : ℝ) + 1) Filter.atTop Filter.atTop := by
      apply Filter.tendsto_atTop_add_const_right
      exact Filter.Tendsto.const_mul_atTop (by norm_num : (0:ℝ) < 3) tendsto_natCast_atTop_atTop
    have hsqrt : Filter.Tendsto (fun r : ℕ => Real.sqrt (3 * (r : ℝ) + 1)) Filter.atTop
        Filter.atTop := Real.tendsto_sqrt_atTop.comp hlin
    have hs : Filter.Tendsto (fun r : ℕ => 2 * Real.sqrt (3 * (r : ℝ) + 1)) Filter.atTop
        Filter.atTop := Filter.Tendsto.const_mul_atTop (by norm_num : (0:ℝ) < 2) hsqrt
    have := hs.inv_tendsto_atTop
    simpa [Pi.inv_def, one_div] using this
  exact squeeze_zero (fun r => (defect_pos r).le) hbound hlim

end SeedQuota