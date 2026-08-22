/-
# The transcript's Shannon entropy, and the reconciliation chain rule

For a uniformly distributed raw key the public transcript is itself uniformly
distributed on the `2 ^ r` achievable syndromes (`r = rank H`), because all
fibers of the syndrome map have the same size.  Consequently:

* `Scheme.transcriptProb_eq` — every achievable transcript has probability
  `2 ^ (-r)`;
* `Scheme.transcriptEntropy_eq_rank` — the transcript carries exactly `r` bits
  of Shannon entropy: no more (it is a linear image) and no less (the checks are
  independent up to rank);
* `Scheme.entropy_chain_rule` — `n = H(transcript) + H(key | transcript)`, the
  exact bookkeeping of the reconciliation protocol: every bit that leaves the
  raw key either becomes public or stays secret.
-/

import Mathlib
import Computation.InformationReconciliation
import Computation.InformationReconciliationLeakage

open Matrix Finset Module

namespace InformationReconciliation

variable {n m : ℕ} (S : Scheme n m)

/-- The probability that a uniformly random key produces the transcript `s`. -/
noncomputable def Scheme.transcriptProb (s : Synd m) : ℝ :=
  ((S.consistent s).card : ℝ) / 2 ^ n

/-- Every achievable transcript is equally likely, with probability `2 ^ (-r)`. -/
theorem Scheme.transcriptProb_eq (a : Key n) :
    S.transcriptProb (S.transcript a) = 1 / 2 ^ S.rank := by
  have hr := S.rank_le_dim
  rw [Scheme.transcriptProb, S.card_consistent a]
  have h : (2 : ℝ) ^ (n - S.rank) * 2 ^ S.rank = 2 ^ n := by
    rw [← pow_add]
    congr 1
    omega
  push_cast
  rw [div_eq_div_iff (by positivity) (by positivity), one_mul, h]

/-- Shannon entropy (in bits) of the public transcript, for a uniformly
distributed raw key. -/
noncomputable def Scheme.transcriptEntropy : ℝ :=
  ∑ s ∈ Finset.univ.image S.syndrome,
    -(S.transcriptProb s) * Real.logb 2 (S.transcriptProb s)

/-- **The transcript carries exactly `rank H` bits.** -/
theorem Scheme.transcriptEntropy_eq_rank : S.transcriptEntropy = S.rank := by
  classical
  have hterm : ∀ s ∈ Finset.univ.image S.syndrome,
      -(S.transcriptProb s) * Real.logb 2 (S.transcriptProb s)
        = (S.rank : ℝ) / 2 ^ S.rank := by
    intro s hs
    obtain ⟨a, -, rfl⟩ := Finset.mem_image.1 hs
    rw [show S.syndrome a = S.transcript a from rfl, S.transcriptProb_eq a, one_div,
      Real.logb_inv, Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one]
    field_simp
  rw [Scheme.transcriptEntropy, Finset.sum_congr rfl hterm, Finset.sum_const,
    S.card_image_syndrome, nsmul_eq_mul]
  field_simp
  push_cast
  ring

/-- **Chain rule for reconciliation.**  The `n` bits of the raw key split
exactly into the `r` bits published in the transcript and the `n - r` bits of
residual min-entropy that survive it. -/
theorem Scheme.entropy_chain_rule (a : Key n) :
    (n : ℝ) = S.transcriptEntropy
      + Real.logb 2 ((S.consistent (S.transcript a)).card : ℝ) := by
  rw [S.transcriptEntropy_eq_rank, S.residual_min_entropy a]
  ring

/-- The transcript entropy never exceeds the number of published bits. -/
theorem Scheme.transcriptEntropy_le_length : S.transcriptEntropy ≤ m := by
  rw [S.transcriptEntropy_eq_rank]
  exact_mod_cast S.rank_le_length

end InformationReconciliation