import EulerMascheroni.Irrationality

/-!
# Effective bounds for the Euler–Mascheroni constant

The companion file `Irrationality.lean` showed that an irrationality proof of `γ`
must exhibit arbitrarily small nonzero integer linear forms `q·γ − p`, but that
the only known approximations (`seq n = H_n − log(n+1)`, `seq' n = H_n − log n`)
carry a logarithm.  Here we quantify those approximations: both bracket `γ` with
an **explicit, effective** error `log(n+1) − log n = log(1 + 1/n)`.

-- !-- Lab Notes -- !--
HYPOTHESIS.  From the Mathlib sandwich `seq n < γ < seq' n` and the fact that the
bracket width is exactly `seq' n − seq n = log(n+1) − log n`, both one-sided
errors are strictly bounded by that width.

EXPERIMENT.  `seq' n − seq n = (H_n − log n) − (H_n − log(n+1)) = log(n+1) − log n`
for `n ≥ 1`; this is `log(1 + 1/n)` which decreases to `0` like `1/n`.

INSIGHT.  These bounds are *effective*: given `n`, one can in principle compute
`H_n` and rational bounds for the logarithm to enclose `γ`.  The obstruction to
irrationality is not the *speed* of approximation (it is only `~1/n`, far worse
than the `geometric` rates that power irrationality proofs of `e`, `ζ(3)`), but
that the approximants are transcendental combinations, not rationals.  A future
irrationality attack needs approximants with controlled *rational* denominators
and width `o(1/q)` — see FUTURE_DIRECTIONS.md.
-/

open Filter Topology Real

namespace EulerMascheroni

/--
The bracket width equals `log(n+1) − log n` for `n ≥ 1`.
-/
theorem eulerMascheroni_trap_width_eq (n : ℕ) (hn : 1 ≤ n) :
    eulerMascheroniSeq' n - eulerMascheroniSeq n = Real.log (n + 1) - Real.log n := by
  have hn0 : n ≠ 0 := by omega
  simp only [Real.eulerMascheroniSeq', Real.eulerMascheroniSeq, if_neg hn0]
  ring

/--
**Effective lower approximation.**  `seq n` underestimates `γ` with error
strictly less than `log(n+1) − log n`.
-/
theorem eulerMascheroniConstant_sub_seq_lt (n : ℕ) (hn : 1 ≤ n) :
    eulerMascheroniConstant - eulerMascheroniSeq n < Real.log (n + 1) - Real.log n := by
  -- By combining the results from `eulerMascheroni_trap_width_eq` and `eulerMascheroniConstant_lt_eulerMascheroniSeq'`, we get the desired inequality.
  have h_combined : eulerMascheroniConstant - eulerMascheroniSeq n < eulerMascheroniSeq' n - eulerMascheroniSeq n := by
    exact sub_lt_sub_right ( eulerMascheroniSeq_sandwich n |>.2 ) _;
  exact h_combined.trans_le ( by rw [ EulerMascheroni.eulerMascheroni_trap_width_eq n hn ] )

/--
**Effective upper approximation.**  `seq' n` overestimates `γ` with error
strictly less than `log(n+1) − log n`.
-/
theorem seq'_sub_eulerMascheroniConstant_lt (n : ℕ) (hn : 1 ≤ n) :
    eulerMascheroniSeq' n - eulerMascheroniConstant < Real.log (n + 1) - Real.log n := by
  have := eulerMascheroniSeq_sandwich n;
  linarith [ eulerMascheroni_trap_width_eq n hn ]

/--
The two-sided absolute error of the lower approximant is effective.
-/
theorem abs_eulerMascheroniSeq_sub_lt (n : ℕ) (hn : 1 ≤ n) :
    |eulerMascheroniSeq n - eulerMascheroniConstant| < Real.log (n + 1) - Real.log n := by
  rw [ abs_sub_comm, abs_of_pos ];
  · convert EulerMascheroni.eulerMascheroniConstant_sub_seq_lt n hn using 1;
  · exact sub_pos_of_lt ( eulerMascheroniSeq_lt_eulerMascheroniConstant n )

end EulerMascheroni