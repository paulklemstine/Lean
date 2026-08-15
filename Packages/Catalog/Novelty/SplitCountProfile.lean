import Mathlib
import Novelty.SplitCountChannel

/-!
# The equality case of the one-bit cap

`Catalog/Novelty/SplitCountLaw.lean` proves the profile-free one-bit cap
`mutualInfo_le_one_of_binary`: *any* channel with a binary input alphabet carries
at most one bit, whatever the output alphabet and whatever the conditional laws.
`Catalog/Novelty/SplitCountChannel.lean` instantiates it at the split-count
channel (`Is_le_one`).

This file settles the **equality case**, which is the half of Conjecture 5 of the
previous cycle that does not depend on the arithmetic of the character:

* `entropyBits_binary_eq_one_iff` : a binary weight vector has entropy exactly
  one bit iff it is balanced;
* `balanced_prior_of_mutualInfo_eq_one` : a binary-input channel attains the cap
  only with a balanced input prior — the equality case is a statement about the
  *prior*, not about the channel;
* `Is_eq_one_iff` : consequently, for the character-pinned fork the cap is
  attained **exactly** at the quadratic characters: `Is n = 1 ↔ n = 2`.

The last statement is proved here *structurally*, from the cap alone: `Is n = 1`
forces the class prior `(1/n, (n−1)/n)` to be balanced, i.e. `1/n = 1/2`.  This
is a different (and shorter) route to the strict inequality `Is n < 1` for
`n > 2` than the analytic argument of `Is_lt_one`, and unlike it, the mechanism
applies verbatim to any 0/1 profile whose class prior is unbalanced.
-/

namespace SplitCountProfile

open Finset Real SplitCountLaw SplitCountChannel

/-- A binary weight vector summing to one carries exactly one bit of entropy iff
it is balanced. -/
lemma entropyBits_binary_eq_one_iff (q : Fin 2 → ℝ) (hs : q 0 + q 1 = 1) :
    entropyBits q = 1 ↔ q 0 = 1 / 2 := by
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [entropyBits_binary_eq q hs, div_eq_one_iff_eq (ne_of_gt hl2),
    Real.binEntropy_eq_log_two]
  constructor
  · intro h; rw [h]; norm_num
  · intro h; rw [h]; norm_num

/-- **The equality case of the one-bit cap.**  A channel with a binary input
alphabet attains one full bit only if its input prior is balanced.  Nothing is
assumed about the output alphabet or the conditional laws. -/
theorem balanced_prior_of_mutualInfo_eq_one {β : Type*} [Fintype β] (p : Fin 2 → β → ℝ)
    (hp : ∀ a b, 0 ≤ p a b) (hrow : ∀ a, 0 < rowMarg p a) (hcol : ∀ b, 0 < colMarg p b)
    (htot : rowMarg p 0 + rowMarg p 1 = 1) (h : mutualInfo p = 1) :
    rowMarg p 0 = 1 / 2 ∧ rowMarg p 1 = 1 / 2 := by
  have h1 : (1:ℝ) ≤ entropyBits (rowMarg p) := by
    rw [← h]; exact mutualInfo_le_rowEntropy p hp hrow hcol
  have h2 : entropyBits (rowMarg p) ≤ 1 := entropyBits_binary_le_one _ htot
  have hH : entropyBits (rowMarg p) = 1 := le_antisymm h2 h1
  have hq0 : rowMarg p 0 = 1 / 2 := (entropyBits_binary_eq_one_iff _ htot).1 hH
  exact ⟨hq0, by linarith⟩

variable {n : ℝ}

/-- **The one-bit cap is attained exactly at the quadratic characters.**  For a
character-pinned fork of order `n ≥ 2`, the split-count carries a full bit iff
`n = 2`; the reason is purely prior-theoretic — a full bit forces the class prior
`(1/n, (n−1)/n)` to be balanced. -/
theorem Is_eq_one_iff (hn : 2 ≤ n) : Is n = 1 ↔ n = 2 := by
  constructor
  · intro h
    have hn0 : (0:ℝ) < n := by linarith
    have htot : rowMarg (forkJoint n) 0 + rowMarg (forkJoint n) 1 = 1 := by
      rw [rowMarg_forkJoint hn, rowMarg_forkJoint hn]
      simpa [prior, Fin.sum_univ_two] using prior_sum hn
    have hbal := balanced_prior_of_mutualInfo_eq_one (forkJoint n) (forkJoint_nonneg hn)
      (rowMarg_pos hn) (colMarg_pos hn) htot h
    have h0 : (1:ℝ) / n = 1 / 2 := by
      have := hbal.1
      rwa [rowMarg_forkJoint hn, show prior n 0 = 1 / n from rfl] at this
    field_simp at h0
    linarith
  · rintro rfl; exact Is_two

end SplitCountProfile