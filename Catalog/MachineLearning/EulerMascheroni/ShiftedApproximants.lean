import Mathlib

/-!
# The one-parameter family of shifted approximants to the Euler–Mascheroni constant

For a real shift `c`, define
```
shiftedSeq c n = H_n − log(n + c).
```
This interpolates Mathlib's two approximants and the midpoint accelerator of
`MachineLearning.EulerMascheroni.MidpointAcceleration`:
* `c = 1`  : `eulerMascheroniSeq  n = H_n − log(n+1)`   (lower, increasing);
* `c = 1/2`: the quadratic *midpoint* accelerator `H_n − log(n+1/2)`;
* `c = 0`  : `eulerMascheroniSeq' n = H_n − log n`       (upper, decreasing).

Main results:
* `tendsto_shiftedSeq` : **for every shift `c`** the sequence converges to `γ`.
  (The defining limit of `γ` is robust under any bounded shift of the argument of `log`.)
* `shiftedSeq_strictAnti_shift` : for fixed `n`, the value strictly **decreases** in `c`.
* `shiftedSeq_mem_Ioo` : hence for `c ∈ (0,1)` and `n ≥ 1`, the approximant lies
  strictly between Mathlib's lower and upper approximants.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The convergence `H_n − log n → γ` should be a
*degenerate* member of a continuum: any shift `c` produces the same limit, since
shifting `log`'s argument by a bounded amount perturbs by `log((n+1)/(n+c)) → 0`.
Counter-intuitive corollary: there is no canonical "correct" shift — the limit is
shift-invariant, and the *quality* of approximation (linear vs. quadratic) is the
only thing the shift controls.

EXPERIMENT (Experimenter).  Checked `c ∈ {0, 1/2, 1, 2, 5}`: every sequence's
tail tracks `γ ≈ 0.5772`, and `shiftedSeq c n` is monotone decreasing in `c` at
each fixed `n` (e.g. `n=10`: `c=0 ↦ 0.6264 > c=1/2 ↦ 0.5776 > c=1 ↦ 0.5311`),
with the midpoint `c=1/2` landing closest to `γ`.

ANALYSIS (Analyst).  The convergence proof factors through the *known* Mathlib
limit `Real.tendsto_eulerMascheroniSeq` plus the elementary fact
`log(n+1) − log(n+c) = log((n+1)/(n+c)) → 0` (continuity of `log` at `1` and
`(n+1)/(n+c) → 1`).  Strict shift-monotonicity is just strict monotonicity of
`log`.  The interpolation property then localizes `γ` for the whole interior
family using only the two Mathlib endpoint facts.

CRITIQUE (Critic).  Convergence for *all* `c` is genuinely more general than the
two Mathlib instances and the midpoint file; it is not vacuous (the perturbation
term is nonzero for `c ≠ 1`) and the limit identification needs the `→ 0` lemma,
not just `simp`.

SYNTHESIS (PI).  A unifying continuum of approximants; the shift is a free
parameter that fixes neither the limit (always `γ`) but does control the bias.
-/

open Filter Topology Real

namespace EulerMascheroniShifted

/-- The shifted approximant `H_n − log(n + c)`. -/
noncomputable def shiftedSeq (c : ℝ) (n : ℕ) : ℝ := (harmonic n : ℝ) - Real.log ((n : ℝ) + c)

/-
`c = 1` recovers Mathlib's lower approximant `eulerMascheroniSeq`.
-/
theorem shiftedSeq_one : shiftedSeq 1 = Real.eulerMascheroniSeq := by
  exact funext fun n => by unfold shiftedSeq eulerMascheroniSeq; norm_num;

/-
`c = 0`, for `n ≥ 1`, recovers Mathlib's upper approximant `eulerMascheroniSeq'`.
-/
theorem shiftedSeq_zero_eq (n : ℕ) (hn : 1 ≤ n) :
    shiftedSeq 0 n = Real.eulerMascheroniSeq' n := by
  unfold shiftedSeq; simp [eulerMascheroniSeq'];
  aesop

/-
**Shift-invariance of the limit.**  For *every* real shift `c`, the sequence
`H_n − log(n + c)` converges to the Euler–Mascheroni constant `γ`.
-/
theorem tendsto_shiftedSeq (c : ℝ) :
    Tendsto (shiftedSeq c) atTop (𝓝 Real.eulerMascheroniConstant) := by
  -- By definition of $shiftedSeq$, we can write it as $shiftedSeq c n = eulerMascheroniSeq n + (Real.log ((n:ℝ)+1) - Real.log ((n:ℝ)+c))$.
  have h_shifted : ∀ n : ℕ, shiftedSeq c n = Real.eulerMascheroniSeq n + (Real.log ((n:ℝ)+1) - Real.log ((n:ℝ)+c)) := by
    intro n
    simp [shiftedSeq, Real.eulerMascheroniSeq];
  rw [ Filter.tendsto_congr h_shifted ];
  -- The perturbation term $g n = \log((n+1)/(n+c))$ tends to $0$ as $n$ tends to infinity.
  have h_perturbation : Filter.Tendsto (fun n : ℕ => Real.log ((n + 1 : ℝ) / (n + c))) Filter.atTop (nhds 0) := by
    -- We can rewrite the limit expression using the property of logarithms: $\log((n+1)/(n+c)) = \log(1 + (1-c)/(n+c))$.
    suffices h_log : Filter.Tendsto (fun n : ℕ => Real.log (1 + (1 - c) / (n + c))) Filter.atTop (nhds 0) by
      refine h_log.congr' ( by filter_upwards [ Filter.eventually_gt_atTop ⌈|c|⌉₊ ] with n hn using by rw [ one_add_div ( by cases abs_cases c <;> linarith [ Nat.le_ceil ( |c| ), show ( n : ℝ ) ≥ ⌈|c|⌉₊ + 1 by exact_mod_cast hn ] ) ] ; ring );
    convert Filter.Tendsto.log ( tendsto_const_nhds.add ( tendsto_const_nhds.div_atTop ( tendsto_natCast_atTop_atTop.atTop_add tendsto_const_nhds ) ) ) _ using 2 <;> norm_num;
  simpa using Filter.Tendsto.add ( Real.tendsto_eulerMascheroniSeq ) ( h_perturbation.congr' <| by filter_upwards [ Filter.eventually_gt_atTop ⌈|c|⌉₊ ] with n hn using by rw [ Real.log_div ( by positivity ) ( by cases abs_cases c <;> linarith [ Nat.le_ceil ( |c| ), ( by norm_cast : ( n :ℝ ) > ⌈|c|⌉₊ ) ] ) ] )

/-
For a fixed index `n`, the approximant is strictly decreasing in the shift `c`
(provided `n + c > 0`).
-/
theorem shiftedSeq_strictAnti_shift (n : ℕ) {c d : ℝ} (hc : 0 < (n : ℝ) + c) (h : c < d) :
    shiftedSeq d n < shiftedSeq c n := by
  exact sub_lt_sub_left ( Real.log_lt_log hc ( by linarith ) ) _

/-
**Interpolation.**  For `c ∈ (0,1)` and `n ≥ 1`, the shifted approximant lies
strictly between Mathlib's lower (`eulerMascheroniSeq n`) and upper
(`eulerMascheroniSeq' n`) approximants.
-/
theorem shiftedSeq_mem_Ioo (n : ℕ) (hn : 1 ≤ n) {c : ℝ} (h0 : 0 < c) (h1 : c < 1) :
    Real.eulerMascheroniSeq n < shiftedSeq c n ∧
      shiftedSeq c n < Real.eulerMascheroniSeq' n := by
  exact ⟨ shiftedSeq_strictAnti_shift n ( by positivity ) h1, shiftedSeq_zero_eq n hn ▸ shiftedSeq_strictAnti_shift n ( by positivity ) h0 ⟩

end EulerMascheroniShifted