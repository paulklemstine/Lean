import Mathlib

/-!
# Proof Space II: The order parameter and asymptotic incompleteness

The *order parameter* of proof space is the fraction of statements of length
`≤ n` that are provable:

  `r n = prov n / tot n`.

We work with abstract real-valued counting functions `prov, tot : ℕ → ℝ`, where
`tot` grows like `k ^ n` (the full proof space) and `prov` counts the provable
statements.

The main result, `orderParameter_tendsto_zero`, is an *asymptotic
incompleteness* statement: if the provable statements are exponentially sparse —
growing with a base `a` strictly smaller than the alphabet size `k` — then the
order parameter tends to `0`.  In words: **almost every statement is
unprovable.**  This is the "disordered phase" of proof space, the analogue of a
system sitting below its critical point.
-/

namespace ProofSpace

open Filter Topology

/-- The order parameter: fraction of length-`≤ n` statements that are provable. -/
noncomputable def orderParameter (prov tot : ℕ → ℝ) (n : ℕ) : ℝ := prov n / tot n

/--
The order parameter always lies in `[0, 1]` when there are no more provable
statements than statements and the total count is positive.
-/
theorem orderParameter_mem_Icc (prov tot : ℕ → ℝ) (n : ℕ)
    (h0 : 0 ≤ prov n) (hle : prov n ≤ tot n) (hpos : 0 < tot n) :
    orderParameter prov tot n ∈ Set.Icc (0 : ℝ) 1 := by
  unfold orderParameter; exact ⟨ div_nonneg h0 hpos.le, div_le_one_of_le₀ hle hpos.le ⟩ ;

/--
**Asymptotic incompleteness.**  Suppose the total number of statements of
length `≤ n` is at least `k ^ n` (with `k > 1`), while the provable ones number
at most `C · a ^ n` for some base `a` with `0 ≤ a < k`.  Then the order
parameter tends to `0`: the provable statements have density zero in proof
space.
-/
theorem orderParameter_tendsto_zero (prov tot : ℕ → ℝ) (k a C : ℝ)
    (hk : 1 < k) (ha0 : 0 ≤ a) (hak : a < k) (hC : 0 ≤ C)
    (h0 : ∀ n, 0 ≤ prov n)
    (htot : ∀ n, (k : ℝ) ^ n ≤ tot n)
    (hprov : ∀ n, prov n ≤ C * a ^ n) :
    Tendsto (orderParameter prov tot) atTop (𝓝 0) := by
  -- The upper bound of the order parameter is $C \cdot (a/k)^n$.
  have h_upper_bound : ∀ n, orderParameter prov tot n ≤ C * (a / k) ^ n := by
    intro n; rw [ orderParameter ] ; rw [ div_pow, mul_div ] ; gcongr;
    · exact hprov n;
    · exact htot n;
  exact squeeze_zero ( fun n => div_nonneg ( h0 n ) ( le_trans ( by positivity ) ( htot n ) ) ) h_upper_bound ( by simpa using tendsto_const_nhds.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one ( by positivity ) ( show a / k < 1 by rw [ div_lt_iff₀ ( by positivity ) ] ; linarith ) ) )

end ProofSpace