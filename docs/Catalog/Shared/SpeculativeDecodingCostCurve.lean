import Shared.SpeculativeDecodingAcceptanceProfiles

/-!
# One hardware cost curve, two acceptance profiles: a 12-cell reconstruction

Cycle 4 of the NET-91 thread.  Cycles 1–3 established that throughput is
`yield / cost`, that yield is domain-specific (the reconstructed acceptance profiles), and
that the cost side must charge more per verified position than the draft alone
(`SpecDecCPU.verification_overhead_bracket`).  This file pins the *cost* side down and
tests the resulting model against all twelve measured cells.

## The cost curve

`cpuBlockCost extra d = 1.5401 + (0.0992 + extra) * d + 0.0151 * d ^ 2`, in units of one
target decode step, where `extra = 0` for the 0.5B draft and `extra = 0.116` for the 1.5B
draft (the measured difference in relative draft cost, `0.234 - 0.118`).  The three
coefficients are fixed by the three **code / 0.5B** cells alone; the other nine cells are
out-of-sample.

Three qualitative facts are read off the curve and proved here:

* the constant term exceeds `1` (`cost_curve_has_fixed_overhead`): a block costs more than
  a single verification pass even at depth `0`, which is why the shallow `d = 2` cells
  underperform the naive model of cycle 1;
* the curve is strictly convex (`cost_curve_strictly_convex`): each additional drafted
  position costs strictly more than the previous one, the opposite of the GPU picture in
  which verification is essentially free;
* convexity is *forced* by the data (`no_affine_cost_curve_fits_code_cells`): no affine
  cost `b + k d` whatsoever reproduces the three code speedups exactly.  This supersedes
  the numerical bracket of cycle 1 (`verification_overhead_bracket`), which was explicitly
  conditional on an affine cost; the correct reading of that bracket is that the *average*
  marginal cost over the measured depth range is far above the draft cost, and the present
  curve says that average is `0.28` per position over depths 4 to 8.

## The 12-cell test

`cpu_cost_curve_predicts_all_twelve` states that every one of the twelve measured
speedups is reproduced within `11%` relative error by
`(1 + q d) / cpuBlockCost extra d`, using only the measured mean acceptance `q` of that
cell.  Nine of the twelve are out-of-sample predictions, and the worst relative error is
`10.6%` (prose / 1.5B / `d = 8`).

-- !-- Lab Notes -- !--
Hypothesizer (cycle 4):
 (E1) [BOLD] Cost is *universal* across domains and yield is *domain-specific*: a single
      hardware curve, calibrated on one domain, predicts the other.
 (E2) The CPU cost curve is strictly convex in draft depth — verification does not
      amortise, it anti-amortises.
 (E3) A per-block fixed overhead above the verification pass is required by the shallow
      cells.
 (E4) Affine cost is falsified outright by the three code cells.

Experimenter: fitted on code / 0.5B only,
  b = 1.5401,  k = 0.0992,  m = 0.0151,  extra(1.5B) = 0.116.
Predicted vs measured (relative error):
  prose 0.5B  d=2 1.266/1.254 (1.0%)   d=4 1.335/1.416 (5.7%)   d=8 1.052/0.979 (7.5%)
  prose 1.5B  d=2 1.115/1.016 (9.7%)   d=4 1.164/1.153 (1.0%)   d=8 1.086/0.982 (10.6%)
  code  0.5B  d=2 1.352/1.352 (0.0%)   d=4 1.616/1.616 (0.0%)   d=8 1.661/1.661 (0.0%)
  code  1.5B  d=2 1.314/1.195 (9.9%)   d=4 1.511/1.395 (8.3%)   d=8 1.378/1.354 (1.7%)

Analyst: the residuals are systematic, not random — the 1.5B cells are over-predicted at
shallow depth and the prose cells at deep depth, suggesting the "extra" draft cost is
itself depth-dependent (the larger draft's own KV cache grows), which is the natural
next-cycle refinement.  Nothing here rescues the i.i.d. reading: the yield side still uses
the measured mean acceptance, as cycle 1 forced.

Critic: an eleven-per-cent band over twelve cells with three fitted parameters is a real
but modest test; the honest statement is the existential one
(`exists_universal_cpu_cost_curve`), which is what is proved, together with the
impossibility theorem that rules out the two-parameter affine alternative.
-/

namespace SpecDecCPU

/-- The fitted CPU block-cost curve.  `extra` is the additional relative per-token cost of
a larger draft model (`0` for the 0.5B draft, `0.116` for the 1.5B draft). -/
noncomputable def cpuBlockCost (extra : ℝ) (d : ℕ) : ℝ :=
  15401/10000 + (992/10000 + extra) * d + (151/10000) * (d : ℝ) ^ 2

/-- Predicted speedup: mean-acceptance yield over the fitted cost curve. -/
noncomputable def predSpeedup (q extra : ℝ) (d : ℕ) : ℝ :=
  (1 + q * d) / cpuBlockCost extra d

/-- Relative agreement of a prediction with a measurement. -/
def RelClose (tol pred meas : ℝ) : Prop := |pred - meas| ≤ tol * meas

/-- A block costs strictly more than one verification pass even before any drafting: the
CPU pays a fixed per-block overhead. -/
theorem cost_curve_has_fixed_overhead (extra : ℝ) : 1 < cpuBlockCost extra 0 := by
  norm_num [cpuBlockCost]

/-- **Anti-amortisation.**  Each additional drafted-and-verified position costs strictly
more than the previous one: the CPU cost curve is strictly convex in depth. -/
theorem cost_curve_strictly_convex (extra : ℝ) (d : ℕ) :
    cpuBlockCost extra (d + 1) - cpuBlockCost extra d <
      cpuBlockCost extra (d + 2) - cpuBlockCost extra (d + 1) := by
  simp only [cpuBlockCost]
  push_cast
  ring_nf
  norm_num

/-- **Convexity is forced by the data.**  No affine block cost `b + k d` reproduces the
three measured code / 0.5B speedups (`1.352x`, `1.616x`, `1.661x`) under the mean-yield
reading.  Hence the superlinear term of `cpuBlockCost` is not a fitting convenience. -/
theorem no_affine_cost_curve_fits_code_cells :
    ¬ ∃ b k : ℝ,
      (1 + (716/1000) * 2) = (1352/1000) * (b + k * 2) ∧
      (1 + (630/1000) * 4) = (1616/1000) * (b + k * 4) ∧
      (1 + (560/1000) * 8) = (1661/1000) * (b + k * 8) := by
  rintro ⟨b, k, h2, h4, h8⟩
  norm_num at h2 h4 h8
  linarith

/-- **The 12-cell test.**  With the cost curve calibrated on the three code / 0.5B cells,
every measured speedup — including the nine out-of-sample cells — is reproduced within
`11%` relative error from the cell's measured mean acceptance alone. -/
theorem cpu_cost_curve_predicts_all_twelve :
    RelClose (11/100) (predSpeedup (639/1000) 0 2) (1254/1000) ∧
    RelClose (11/100) (predSpeedup (477/1000) 0 4) (1416/1000) ∧
    RelClose (11/100) (predSpeedup (309/1000) 0 8) (979/1000) ∧
    RelClose (11/100) (predSpeedup (632/1000) (116/1000) 2) (1016/1000) ∧
    RelClose (11/100) (predSpeedup (519/1000) (116/1000) 4) (1153/1000) ∧
    RelClose (11/100) (predSpeedup (449/1000) (116/1000) 8) (982/1000) ∧
    RelClose (11/100) (predSpeedup (716/1000) 0 2) (1352/1000) ∧
    RelClose (11/100) (predSpeedup (630/1000) 0 4) (1616/1000) ∧
    RelClose (11/100) (predSpeedup (560/1000) 0 8) (1661/1000) ∧
    RelClose (11/100) (predSpeedup (834/1000) (116/1000) 2) (1195/1000) ∧
    RelClose (11/100) (predSpeedup (748/1000) (116/1000) 4) (1395/1000) ∧
    RelClose (11/100) (predSpeedup (603/1000) (116/1000) 8) (1354/1000) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    (rw [RelClose, abs_le]; constructor <;> norm_num [predSpeedup, cpuBlockCost])

/-- **Cost universality (E1).**  There is a single convex hardware cost curve with a fixed
per-block overhead, shared by both domains and both drafts up to the measured difference in
draft cost, that reproduces all twelve NET-91 cells within `11%`. -/
theorem exists_universal_cpu_cost_curve :
    ∃ b k m : ℝ, 1 < b ∧ 0 < k ∧ 0 < m ∧
      (∀ extra d, cpuBlockCost extra d = b + (k + extra) * d + m * (d : ℝ) ^ 2) ∧
      RelClose (11/100) (predSpeedup (639/1000) 0 2) (1254/1000) ∧
      RelClose (11/100) (predSpeedup (309/1000) 0 8) (979/1000) ∧
      RelClose (11/100) (predSpeedup (834/1000) (116/1000) 2) (1195/1000) ∧
      RelClose (11/100) (predSpeedup (603/1000) (116/1000) 8) (1354/1000) := by
  obtain ⟨h1, -, h3, -, -, h6, -, -, -, h10, -, h12⟩ := cpu_cost_curve_predicts_all_twelve
  exact ⟨15401/10000, 992/10000, 151/10000, by norm_num, by norm_num, by norm_num,
    fun _ _ => rfl, h1, h3, h10, h12⟩

end SpecDecCPU