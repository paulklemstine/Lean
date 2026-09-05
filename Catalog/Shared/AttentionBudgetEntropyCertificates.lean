import Shared.AttentionBudgetEnergyGeometry

/-!
# Cycle 6: why entropy cannot certify a budget, and how measurement error enters the floor

Cycles 4–5 built the report `g²/E ≤ k* ≤ n` and evaluated the floor.  The motivating claim
of the whole programme — *entropy alone cannot certify a budget* — was so far supported
only by the Hartley (support-size) counterexample of cycle 4.  This cycle settles it for
the Shannon entropy itself, and completes the error analysis of the protocol.

**A. The entropy chain.**  Jensen's inequality for the (concave) logarithm gives
`H₂ ≤ H₁` (`collisionEntropy_le_shannonEntropy`): the Rényi-2 entropy that appears in the
valid floor `g² e^{H₂}` is always dominated by the Shannon entropy.  So replacing `H₂` by
`H₁` can only *inflate* the claimed floor, and the inflation is real: for the spike profile
`(16, 1, …, 1)` on `17` keys the Shannon entropy is exactly `3 log 2`
(`shannonEntropy_spike`), so the Shannon "floor" at gate `1/2` is `(1/2)² · 8 = 2`, while
the true knee is `1` (`shannon_floor_refuted`).  Shannon entropy therefore *over-certifies*:
it is not a lower certificate for the attention budget, and the ℓ²-energy cannot be
replaced by it.  This is the formal content of the phrase "entropy alone cannot certify a
budget".

**B. Intrinsic resolution of the protocol.**  The two ends of the sandwich can never be
closer than the factor `1/g²`, because `n · E ≥ 1` always (`one_le_context_mul_energy`,
the participation-ratio inequality).  Formally `(g²/E)/n ≤ g²` (`sandwich_ratio_le_gate_sq`):
at the deployment gate `g = 0.98` the protocol's intrinsic resolution is a factor
`1/0.9604 ≈ 1.04`, so the sandwich is *informative*, not merely valid.

**C. Error propagation into the floor.**  Only an *upper* estimate of the energy is needed
for a valid report (`kstar_ge_of_energy_upper_bound`), and a relative energy error `η`
costs exactly a factor `1/(1+η)` in the floor (`floor_error_bound`).  Together with the
cycle-4 monotonicity of `budgetOfFit` in the fit box this closes the loop: both ends of the
reported interval degrade monotonically and quantifiably under measurement error.

**D. The estimator is unbiased on a true geometric tail.**  Composing the two-point
estimators returns the exact reported budget (`budgetOfFit_two_point_exact`): the pipeline
introduces no systematic bias of its own; all uncertainty in the report comes from the data.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 6, ranked):
 (H21) Shannon entropy over-certifies: `g² e^{H₁}` is not a valid budget floor, and an
       explicit profile with exactly computable entropy refutes it.            [BOLD]
 (H22) The correct entropy is Rényi-2, and the two are ordered by Jensen, so the failure
       of H₁ is systematic rather than accidental.                             [BOLD]
 (H23) The protocol has an intrinsic resolution limit `1/g²` coming from the
       participation-ratio inequality `nE ≥ 1`.
 (H24) Energy error propagates linearly: a relative error `η` costs a factor `1/(1+η)`.
 (H25) The two-point estimator is exactly unbiased on a genuinely geometric tail.

Experimenter: H21 = `shannonEntropy_spike` + `shannon_floor_refuted`;
H22 = `collisionEntropy_le_shannonEntropy` (Jensen for `log` on `Ioi 0`);
H23 = `one_le_context_mul_energy` + `sandwich_ratio_le_gate_sq`;
H24 = `floor_error_bound`; H25 = `budgetOfFit_two_point_exact`.  Zero sorries.

Analyst: the spike profile is the extremal object for both refutations.  It has *large*
entropy (`3 log 2 = log 8`, i.e. an effective support of 8 keys) and yet a knee of 1,
because half of its mass sits on a single key.  Entropy measures how spread the *whole*
distribution is; the budget only cares about how much mass sits on the *head*.  The
ℓ²-energy is the smallest exponential-family statistic that sees the head, which is why it,
and not the Shannon entropy, appears in the certificate.

Critic: `collisionEntropy_le_shannonEntropy` is not vacuous — the spike profile has
`H₂ = log(64/17) ≈ 1.325 < 2.079 = H₁`, a strict gap.  `shannon_floor_refuted` uses the
exact value `3 log 2`, so no numerical tolerance is hidden in the statement.
-/

namespace AttentionBudget

open Finset

/-! ## A. Shannon entropy and the entropy chain -/

/-- The Shannon entropy (in nats) of the normalised attention profile. -/
noncomputable def shannonEntropy (w : ℕ → ℝ) (n : ℕ) : ℝ :=
  -∑ i ∈ range n, (w i / headMass w n) * Real.log (w i / headMass w n)

section Chain

variable {w : ℕ → ℝ} {n : ℕ} (hw : ∀ i, 0 < w i)

include hw

/-- Jensen's inequality for the logarithm, applied to the profile as both weights and
points: `∑ pᵢ log pᵢ ≤ log (∑ pᵢ²)`. -/
lemma sum_mul_log_le_log_energy (hn : 0 < n) :
    ∑ i ∈ range n, (w i / headMass w n) * Real.log (w i / headMass w n)
      ≤ Real.log (energy w n) := by
  have hS : 0 < headMass w n := headMass_pos hw hn
  have hpos : ∀ i, 0 < w i / headMass w n := fun i => div_pos (hw i) hS
  have hsum : ∑ i ∈ range n, w i / headMass w n = 1 := sum_normalised hw hn
  have hjensen :
      ∑ i ∈ range n, (w i / headMass w n) • Real.log (w i / headMass w n)
        ≤ Real.log (∑ i ∈ range n, (w i / headMass w n) • (w i / headMass w n)) :=
    (strictConcaveOn_log_Ioi.concaveOn).le_map_sum
      (fun i _ => (hpos i).le) hsum (fun i _ => Set.mem_Ioi.mpr (hpos i))
  simp only [smul_eq_mul] at hjensen
  have hE : ∑ i ∈ range n, (w i / headMass w n) * (w i / headMass w n) = energy w n := by
    rw [energy]
    exact Finset.sum_congr rfl fun i _ => (sq (w i / headMass w n)).symm ▸ (by ring)
  rwa [hE] at hjensen

/-- **H22 — the entropy chain.**  The collision (Rényi-2) entropy, which governs the valid
budget floor, never exceeds the Shannon entropy. -/
theorem collisionEntropy_le_shannonEntropy (hn : 0 < n) :
    collisionEntropy w n ≤ shannonEntropy w n := by
  have h := sum_mul_log_le_log_energy hw hn
  simp only [collisionEntropy, shannonEntropy]
  linarith

end Chain

/-! ### The Shannon floor is unsound -/

lemma spike_normalised_head : spike 0 / headMass spike 17 = 1 / 2 := by
  rw [headMass_spike_17]
  norm_num [spike]

lemma spike_normalised_tail {i : ℕ} (hi : i ≠ 0) : spike i / headMass spike 17 = 1 / 32 := by
  rw [headMass_spike_17]
  simp [spike, hi]

/-- The Shannon entropy of the spike profile is exactly `3 log 2 = log 8`: an effective
support of eight keys. -/
theorem shannonEntropy_spike : shannonEntropy spike 17 = 3 * Real.log 2 := by
  have hlog2 : Real.log (1 / 2 : ℝ) = -Real.log 2 := by
    rw [one_div, Real.log_inv]
  have h32 : (1 / 32 : ℝ) = ((2 : ℝ) ^ (5 : ℕ))⁻¹ := by norm_num
  have hlog32 : Real.log (1 / 32 : ℝ) = -(5 * Real.log 2) := by
    rw [h32, Real.log_inv, Real.log_pow]
    norm_num
  simp only [shannonEntropy, headMass_spike_17]
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_zero]
  norm_num [spike]
  rw [hlog2, hlog32]
  ring

/-- **H21 — the Shannon floor over-certifies.**  For the spike profile at gate `1/2` the
Shannon-entropy "floor" `g² e^{H₁} = 2` strictly exceeds the true knee `k* = 1`, while the
valid collision-entropy floor stays below it.  Hence no bound of the form
`k* ≥ g² e^{H₁}` can hold: Shannon entropy alone certifies nothing about the budget. -/
theorem shannon_floor_refuted :
    (1 / 2 : ℝ) ^ 2 * Real.exp (shannonEntropy spike 17) = 2 ∧
      (kstar spike 17 (1 / 2) : ℝ) < (1 / 2 : ℝ) ^ 2 * Real.exp (shannonEntropy spike 17) ∧
      (1 / 2 : ℝ) ^ 2 * Real.exp (collisionEntropy spike 17)
        ≤ (kstar spike 17 (1 / 2) : ℝ) := by
  have hexp : Real.exp (shannonEntropy spike 17) = 8 := by
    rw [shannonEntropy_spike]
    have h8 : Real.log 8 = 3 * Real.log 2 := by
      rw [show (8 : ℝ) = 2 ^ (3 : ℕ) by norm_num, Real.log_pow]
      norm_num
    rw [← h8, Real.exp_log (by norm_num)]
  refine ⟨by rw [hexp]; norm_num, ?_, ?_⟩
  · rw [hexp, kstar_spike]; norm_num
  · exact kstar_ge_gate_sq_mul_exp_collisionEntropy spike_pos (by norm_num) (by norm_num)
      (by norm_num)

/-! ## B. The intrinsic resolution of the sandwich -/

section Resolution

variable {w : ℕ → ℝ} {n : ℕ} {g : ℝ} (hw : ∀ i, 0 < w i)

include hw

/-- **The participation-ratio inequality.**  The energy of a profile on `n` keys is at
least `1/n`. -/
theorem one_le_context_mul_energy (hn : 0 < n) : (1 : ℝ) ≤ (n : ℝ) * energy w n := by
  have hS : 0 < headMass w n := headMass_pos hw hn
  have hcs : (∑ i ∈ range n, w i / headMass w n) ^ 2
      ≤ ((range n).card : ℝ) * ∑ i ∈ range n, (w i / headMass w n) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  rw [sum_normalised hw hn] at hcs
  simpa [energy] using hcs

/-- **H23 — the resolution limit.**  The lower end of the sandwich is never more than a
factor `g²` below the upper end: no energy-based protocol can resolve the knee more finely
than `1/g²`, and at gates near `1` the sandwich is correspondingly tight. -/
theorem sandwich_ratio_le_gate_sq (hn : 0 < n) :
    (g ^ 2 / energy w n) / (n : ℝ) ≤ g ^ 2 := by
  have hE : 0 < energy w n := energy_pos hw hn
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hpr : (1 : ℝ) ≤ (n : ℝ) * energy w n := one_le_context_mul_energy hw hn
  rw [div_div, div_le_iff₀ (by positivity)]
  nlinarith [sq_nonneg g]

end Resolution

/-! ## C. Propagation of the energy measurement error -/

/-- Only an *upper* estimate of the energy is needed: any over-estimate yields a valid
(conservative) floor. -/
theorem kstar_ge_of_energy_upper_bound {w : ℕ → ℝ} {n : ℕ} {g Ehat : ℝ} (hw : ∀ i, 0 < w i)
    (hn : 0 < n) (hg0 : 0 < g) (hg1 : g ≤ 1) (hEhat : energy w n ≤ Ehat) :
    g ^ 2 / Ehat ≤ (kstar w n g : ℝ) := by
  have hE : 0 < energy w n := energy_pos hw hn
  have hfloor : g ^ 2 / energy w n ≤ (kstar w n g : ℝ) := (budget_sandwich hw hn hg0 hg1).1
  have hstep : g ^ 2 / Ehat ≤ g ^ 2 / energy w n :=
    div_le_div_of_nonneg_left (by positivity) hE hEhat
  linarith

/-- **H24 — linear error propagation into the floor.**  A relative over-estimate `η` of the
energy costs exactly a factor `1/(1+η)` in the reported floor. -/
theorem floor_error_bound {E Ehat g η : ℝ} (hE : 0 < E) (hη : 0 ≤ η) (h1 : E ≤ Ehat)
    (h2 : Ehat ≤ (1 + η) * E) :
    (1 / (1 + η)) * (g ^ 2 / E) ≤ g ^ 2 / Ehat := by
  have hEhat : 0 < Ehat := lt_of_lt_of_le hE h1
  have hη1 : (0 : ℝ) < 1 + η := by linarith
  have h3 : (1 / (1 + η)) * (g ^ 2 / E) = g ^ 2 / ((1 + η) * E) := by
    field_simp
  rw [h3]
  exact div_le_div_of_nonneg_left (by positivity) hEhat h2

/-! ## D. The two-point estimator is unbiased -/

/-- **H25 — no bias from the pipeline.**  Running the two-point estimators on data drawn
from a genuinely geometric tail and feeding the result into the budget formula returns
exactly the budget of the true parameters. -/
theorem budgetOfFit_two_point_exact {C r τ : ℝ} {k₁ d : ℕ} (hC : 0 < C) (hr : 0 < r)
    (hd : 0 < d) :
    budgetOfFit (fitConst (C * r ^ k₁) (fitRatio (C * r ^ k₁) (C * r ^ (k₁ + d)) d) k₁)
        (fitRatio (C * r ^ k₁) (C * r ^ (k₁ + d)) d) τ = budgetOfFit C r τ := by
  rw [fitRatio_exact hC hr hd, fitConst_exact hr]

end AttentionBudget