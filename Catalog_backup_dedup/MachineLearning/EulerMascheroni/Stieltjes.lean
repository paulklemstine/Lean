import Catalog.MachineLearning.EulerMascheroni.SeriesRepresentation

/-!
# The zeroth Stieltjes constant is the Euler–Mascheroni constant

The Stieltjes constants `γ_m` are defined by the limit
```
γ_m = lim_{n→∞} ( ∑_{k=1}^n (log k)^m / k  −  (log n)^{m+1}/(m+1) ).
```
They appear as the Laurent coefficients of the Riemann zeta function at `s = 1`:
`ζ(s) = 1/(s−1) + ∑_m (−1)^m/m! · γ_m (s−1)^m`.  The zeroth one, `γ_0`, *is* the
Euler–Mascheroni constant.  We formalize the defining sequence `stieltjesSeq`
and prove `γ_0 = γ`, i.e. `stieltjesSeq 0 → eulerMascheroniConstant`.

-- !-- Lab Notes -- !--
HYPOTHESIS.  For `m = 0` the defining sequence collapses to `H_n − log n`, which
is exactly Mathlib's *upper* approximant `eulerMascheroniSeq'` for `n ≥ 1`, hence
converges to `γ`.

EXPERIMENT.  `stieltjesSeq_zero_eq` rewrites `(log k)^0 = 1` and uses
`harmonic_eq_sum_Icc` to recognise `∑_{k=1}^n 1/k = H_n`.  Then
`stieltjesSeq_zero_eq_seq'` matches it with `eulerMascheroniSeq'` (which has a
special value `2` only at `n = 0`).  `tendsto_stieltjesSeq_zero` transfers the
Mathlib limit via `Tendsto.congr'` on the cofinite-eventually-equal sequences.

ANALYSIS.  The `n = 0` corner is the only subtlety: `eulerMascheroniSeq' 0 = 2`
by definition, while `stieltjesSeq 0 0 = -log 0 = 0`; the two agree only
eventually (`n ≥ 1`), which is exactly what `Tendsto.congr'` needs.

CRITIQUE.  The result is not a definitional rename: it equates two *a priori*
different limit definitions (Stieltjes vs. Mathlib's `H_n − log n`) and routes
through `harmonic_eq_sum_Icc`.  It also positively locates `γ_0` between the
lower and upper Mathlib approximants.

SYNTHESIS.  `stieltjesSeq 0` is a faithful formalization of the `m = 0` Stieltjes
constant, and it equals `γ`, anchoring the whole Stieltjes hierarchy at `γ`.
-/

open Filter Topology Real

namespace EulerMascheroni

/-- The defining sequence of the `m`-th Stieltjes constant:
`∑_{k=1}^n (log k)^m / k − (log n)^{m+1}/(m+1)`. -/
noncomputable def stieltjesSeq (m n : ℕ) : ℝ :=
  (∑ k ∈ Finset.Icc 1 n, (Real.log k) ^ m / k) - (Real.log n) ^ (m + 1) / (m + 1)

/-- For `m = 0` the Stieltjes sequence is `H_n − log n`. -/
theorem stieltjesSeq_zero_eq (n : ℕ) :
    stieltjesSeq 0 n = (harmonic n : ℝ) - Real.log n := by
  simp only [stieltjesSeq, pow_zero, pow_one, Nat.cast_zero, zero_add, div_one]
  rw [harmonic_eq_sum_Icc]
  push_cast
  congr 1
  apply Finset.sum_congr rfl
  intro k _; rw [one_div]

/-- For `n ≥ 1`, the `m = 0` Stieltjes sequence equals Mathlib's upper
approximant `eulerMascheroniSeq'`. -/
theorem stieltjesSeq_zero_eq_seq' (n : ℕ) (hn : 1 ≤ n) :
    stieltjesSeq 0 n = Real.eulerMascheroniSeq' n := by
  rw [stieltjesSeq_zero_eq n, Real.eulerMascheroniSeq', if_neg (by omega)]

/-- **Main Stieltjes connection.**  The zeroth Stieltjes constant equals the
Euler–Mascheroni constant: `stieltjesSeq 0 → γ`. -/
theorem tendsto_stieltjesSeq_zero :
    Tendsto (stieltjesSeq 0) atTop (𝓝 Real.eulerMascheroniConstant) := by
  apply Real.tendsto_eulerMascheroniSeq'.congr'
  filter_upwards [eventually_ge_atTop 1] with n hn
  exact (stieltjesSeq_zero_eq_seq' n hn).symm

/-- The zeroth Stieltjes constant is an upper approximant: for every `n ≥ 1`
the limit `γ` lies strictly below `stieltjesSeq 0 n`. -/
theorem eulerMascheroniConstant_lt_stieltjesSeq_zero (n : ℕ) (hn : 1 ≤ n) :
    Real.eulerMascheroniConstant < stieltjesSeq 0 n := by
  rw [stieltjesSeq_zero_eq_seq' n hn]
  exact Real.eulerMascheroniConstant_lt_eulerMascheroniSeq' n

end EulerMascheroni