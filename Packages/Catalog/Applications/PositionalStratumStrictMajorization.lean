/-
# Strict majorization : the descending arrangement strictly beats the baseline

`Applications.PositionalStratumMeasure.scan_cost_le_baseline` gives the majorization step
`C_sort ≤ C₀ = (M+1)/2` of the master chain.  This file sharpens it to the *strict*
statement, which is what makes the master chain informative rather than vacuous:

  a descending weight that is **not flat** — i.e. `w b < w a` for some earlier slot `a` —
  has expected scan cost *strictly* below the full-scan baseline (`scan_cost_lt_baseline`),

together with the corresponding equality characterisation (`scan_cost_eq_baseline_iff`):
equality holds exactly on the flat (uniform) weight.

The engine is the exact **Chebyshev double-sum identity** (`chebyshev_double_sum`)

  `∑_i ∑_j (c i - c j)(w i - w j) = 2 (|S| ∑_i c i w i - (∑ c)(∑ w))`,

whose termwise sign analysis under antitonicity yields both the inequality and its
equality case.  This is a genuine second-order refinement: the inequality version follows
from Mathlib's Chebyshev lemma, the strict version does not.
-/
import Applications.PositionalStratumMeasure

namespace PositionalStratum

open Finset

noncomputable section

/-- **Chebyshev double-sum identity.**  The Chebyshev defect of `(c, w)` on a finite set is
half of the sum of all pairwise products `(c i - c j)(w i - w j)`. -/
theorem chebyshev_double_sum (S : Finset ℕ) (c w : ℕ → ℝ) :
    ∑ i ∈ S, ∑ j ∈ S, (c i - c j) * (w i - w j)
      = 2 * ((S.card : ℝ) * (∑ i ∈ S, c i * w i) - (∑ i ∈ S, c i) * ∑ i ∈ S, w i) := by
  have h : ∀ i ∈ S, ∑ j ∈ S, (c i - c j) * (w i - w j)
      = (S.card : ℝ) * (c i * w i) - c i * (∑ j ∈ S, w j) - w i * (∑ j ∈ S, c j)
        + ∑ j ∈ S, c j * w j := by
    intro i _
    simp only [sub_mul, mul_sub, Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul,
      ← Finset.mul_sum, ← Finset.sum_mul]
    ring
  rw [Finset.sum_congr rfl h]
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul,
    ← Finset.mul_sum, ← Finset.sum_mul]
  ring

/-- Under antitonicity every pairwise term of the double sum is nonpositive. -/
lemma pairwise_term_nonpos {M : ℕ} {w : ℕ → ℝ}
    (hanti : ∀ i ∈ positions M, ∀ j ∈ positions M, i ≤ j → w j ≤ w i)
    {i j : ℕ} (hi : i ∈ positions M) (hj : j ∈ positions M) :
    (scanCost i - scanCost j) * (w i - w j) ≤ 0 := by
  simp only [scanCost]
  rcases le_total i j with h | h
  · have hw : w j ≤ w i := hanti i hi j hj h
    have hc : (i : ℝ) - j ≤ 0 := by
      have : (i : ℝ) ≤ j := by exact_mod_cast h
      linarith
    exact mul_nonpos_of_nonpos_of_nonneg hc (by linarith)
  · have hw : w i ≤ w j := hanti j hj i hi h
    have hc : (0 : ℝ) ≤ (i : ℝ) - j := by
      have : (j : ℝ) ≤ i := by exact_mod_cast h
      linarith
    exact mul_nonpos_of_nonneg_of_nonpos hc (by linarith)

/-- **Strict majorization.**  A descending weight with any strict drop between two slots has
expected scan cost strictly below the full-scan baseline `C₀ = (M+1)/2`. -/
theorem scan_cost_lt_baseline {M : ℕ} {w : ℕ → ℝ}
    (hanti : ∀ i ∈ positions M, ∀ j ∈ positions M, i ≤ j → w j ≤ w i)
    (htot : mass (positions M) w = 1)
    {a b : ℕ} (ha : a ∈ positions M) (hb : b ∈ positions M) (hab : a < b) (hdrop : w b < w a) :
    EC M scanCost w < baselineC0 M := by
  classical
  have hMpos : 0 < M := by
    rcases mem_positions.mp ha with ⟨h1, h2⟩
    omega
  have hMR : (0 : ℝ) < M := by exact_mod_cast hMpos
  -- the inner sums are nonpositive, and the one at `a` is strictly negative
  have hinner_nonpos : ∀ i ∈ positions M,
      ∑ j ∈ positions M, (scanCost i - scanCost j) * (w i - w j) ≤ 0 := by
    intro i hi
    exact Finset.sum_nonpos fun j hj => pairwise_term_nonpos hanti hi hj
  have hstrict_term : (scanCost a - scanCost b) * (w a - w b) < 0 := by
    simp only [scanCost]
    have hc : (a : ℝ) - b < 0 := by
      have : (a : ℝ) < b := by exact_mod_cast hab
      linarith
    exact mul_neg_of_neg_of_pos hc (by linarith)
  have hstrict_inner : ∑ j ∈ positions M, (scanCost a - scanCost j) * (w a - w j) < 0 := by
    have hle : ∀ j ∈ positions M, (scanCost a - scanCost j) * (w a - w j) ≤ 0 :=
      fun j hj => pairwise_term_nonpos hanti ha hj
    have hlt : ∑ j ∈ positions M, (scanCost a - scanCost j) * (w a - w j)
        < ∑ _j ∈ positions M, (0 : ℝ) :=
      Finset.sum_lt_sum (fun j hj => by simpa using hle j hj) ⟨b, hb, by simpa using hstrict_term⟩
    simpa using hlt
  have hdouble : ∑ i ∈ positions M, ∑ j ∈ positions M,
      (scanCost i - scanCost j) * (w i - w j) < 0 := by
    have hlt : ∑ i ∈ positions M, (∑ j ∈ positions M, (scanCost i - scanCost j) * (w i - w j))
        < ∑ _i ∈ positions M, (0 : ℝ) :=
      Finset.sum_lt_sum (fun i hi => by simpa using hinner_nonpos i hi)
        ⟨a, ha, by simpa using hstrict_inner⟩
    simpa using hlt
  -- convert via the identity
  have hid := chebyshev_double_sum (positions M) scanCost w
  rw [card_positions] at hid
  have hsumc : ∑ i ∈ positions M, scanCost i = (M : ℝ) * ((M : ℝ) + 1) / 2 := by
    simpa [scanCost] using sum_positions M
  have hsumw : ∑ i ∈ positions M, w i = 1 := htot
  rw [hsumc, hsumw] at hid
  have hdefect : (M : ℝ) * EC M scanCost w - (M : ℝ) * ((M : ℝ) + 1) / 2 * 1 < 0 := by
    rw [EC]
    nlinarith [hid, hdouble]
  rw [baselineC0]
  nlinarith [hdefect, hMR]

/-- **Equality case.**  For a descending weight, the expected scan cost equals the full-scan
baseline exactly when the weight is flat on the positional space. -/
theorem scan_cost_eq_baseline_iff {M : ℕ} (hM : 0 < M) {w : ℕ → ℝ}
    (hanti : ∀ i ∈ positions M, ∀ j ∈ positions M, i ≤ j → w j ≤ w i)
    (htot : mass (positions M) w = 1) :
    EC M scanCost w = baselineC0 M ↔ ∀ i ∈ positions M, ∀ j ∈ positions M, w i = w j := by
  classical
  constructor
  · intro heq i hi j hj
    by_contra hne
    -- a strict drop somewhere contradicts equality via strict majorization
    rcases lt_or_gt_of_ne hne with h | h
    · have hij : j < i := by
        by_contra hcon
        push_neg at hcon
        exact absurd (hanti i hi j hj hcon) (by linarith)
      exact absurd heq (ne_of_lt (scan_cost_lt_baseline hanti htot hj hi hij h))
    · have hij : i < j := by
        by_contra hcon
        push_neg at hcon
        exact absurd (hanti j hj i hi hcon) (by linarith)
      exact absurd heq (ne_of_lt (scan_cost_lt_baseline hanti htot hi hj hij h))
  · intro hflat
    have hMR : (0 : ℝ) < M := by exact_mod_cast hM
    have hne : (positions M).Nonempty := by
      refine ⟨1, ?_⟩
      rw [mem_positions]
      omega
    obtain ⟨i₀, hi₀⟩ := hne
    have hconst : ∀ i ∈ positions M, w i = w i₀ := fun i hi => hflat i hi i₀ hi₀
    have hsum : ∑ i ∈ positions M, w i = (M : ℝ) * w i₀ := by
      rw [Finset.sum_congr rfl hconst, Finset.sum_const, card_positions, nsmul_eq_mul]
    have hval : w i₀ = 1 / (M : ℝ) := by
      have : (M : ℝ) * w i₀ = 1 := by rw [← hsum]; exact htot
      field_simp at this ⊢
      linarith
    have hEC : EC M scanCost w = (∑ i ∈ positions M, scanCost i) * w i₀ := by
      rw [EC, Finset.sum_mul]
      exact Finset.sum_congr rfl fun i hi => by rw [hconst i hi]
    have hsumc : ∑ i ∈ positions M, scanCost i = (M : ℝ) * ((M : ℝ) + 1) / 2 := by
      simpa [scanCost] using sum_positions M
    rw [hEC, hsumc, hval, baselineC0]
    field_simp

end

end PositionalStratum