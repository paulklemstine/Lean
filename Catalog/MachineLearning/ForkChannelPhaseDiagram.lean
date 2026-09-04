import MachineLearning.ForkChannelTableClosure

/-!
# The fork-channel phase diagram

`MachineLearning.ForkChannelTableClosure` showed that the comparison of two fork
channels is exactly the comparison of their parameters
(`p` for AND, `1-p` for OR, `(1-2p)²` for XOR, `1` for the split count), so the
*ordering* of the four channels is a function of the bias `p` alone.

This file computes that function completely.  The bias axis `(0,1)` splits into
four open regimes separated by the three critical biases `1/4`, `1/2`, `3/4`:

| regime | ordering (weakest → strongest) |
|---|---|
| `0 < p < 1/4`   | `A < X < g < Is` |
| `1/4 < p < 1/2` | `X < A < g < Is` |
| `1/2 < p < 3/4` | `X < g < A < Is` |
| `3/4 < p < 1`   | `g < X < A < Is` |

At the critical biases exactly one pair of Boolean channels merges
(`A = X` at `1/4`, `A = g` at `1/2`, `X = g` at `3/4`), and never two pairs at once:
there is **no triple point** (`no_triple_point`).  The split-count channel is never
part of a merge — it strictly dominates the three Boolean channels at every bias and
every size, and it does so by an unbounded factor asymptotically
(`boolean_channel_o_one_div`, `isChan_mul_succ`).

Everything here is a consequence of order rigidity, so every ordering statement is
uniform in the fork size: the diagram never changes as the fork grows.
-/

open Filter Topology

namespace ForkChannel

variable {p : ℝ}

/-! ## Parameter comparisons -/

theorem xor_param_lt_p_iff (hp1 : p < 1) : (1 - 2*p) ^ 2 < p ↔ 1/4 < p := by
  constructor
  · intro h; nlinarith
  · intro h; nlinarith

theorem xor_param_lt_q_iff (hp : 0 < p) : (1 - 2*p) ^ 2 < 1 - p ↔ p < 3/4 := by
  constructor
  · intro h; nlinarith
  · intro h; nlinarith

/-! ## The four open regimes -/

/-- `0 < p < 1/4`: the AND channel is the weakest, the XOR channel beats it. -/
theorem regime_low (hp : 0 < p) (hp4 : p < 1/4) {n : ℕ} (hn : 1 ≤ n) :
    aChan p n < xChan p n ∧ xChan p n < gChan p n ∧ gChan p n < isChan p n := by
  have hp1 : p < 1 := by linarith
  refine ⟨?_, ?_, ?_⟩
  · rw [aChan_eq hp hp1, xChan_eq hp hp1, Phi_lt_iff hp.le (param_xor_nonneg p) hn]
    nlinarith
  · rw [xChan_eq hp hp1, gChan_eq hp hp1, Phi_lt_iff (param_xor_nonneg p) (by linarith) hn]
    nlinarith
  · rw [gChan_eq hp hp1, isChan_eq hp hp1, Phi_lt_iff (by linarith) zero_le_one hn]
    linarith

/-- `1/4 < p < 1/2`: the XOR channel is the weakest. -/
theorem regime_midlow (hp4 : 1/4 < p) (hp2 : p < 1/2) {n : ℕ} (hn : 1 ≤ n) :
    xChan p n < aChan p n ∧ aChan p n < gChan p n ∧ gChan p n < isChan p n := by
  have hp : 0 < p := by linarith
  have hp1 : p < 1 := by linarith
  refine ⟨?_, ?_, ?_⟩
  · rw [xChan_eq hp hp1, aChan_eq hp hp1, Phi_lt_iff (param_xor_nonneg p) hp.le hn]
    nlinarith
  · rw [aChan_eq hp hp1, gChan_eq hp hp1, Phi_lt_iff hp.le (by linarith) hn]
    linarith
  · rw [gChan_eq hp hp1, isChan_eq hp hp1, Phi_lt_iff (by linarith) zero_le_one hn]
    linarith

/-- `1/2 < p < 3/4`: the AND channel overtakes the OR channel, XOR still weakest. -/
theorem regime_midhigh (hp2 : 1/2 < p) (hp34 : p < 3/4) {n : ℕ} (hn : 1 ≤ n) :
    xChan p n < gChan p n ∧ gChan p n < aChan p n ∧ aChan p n < isChan p n := by
  have hp : 0 < p := by linarith
  have hp1 : p < 1 := by linarith
  refine ⟨?_, ?_, ?_⟩
  · rw [xChan_eq hp hp1, gChan_eq hp hp1, Phi_lt_iff (param_xor_nonneg p) (by linarith) hn]
    nlinarith
  · rw [gChan_eq hp hp1, aChan_eq hp hp1, Phi_lt_iff (by linarith) hp.le hn]
    linarith
  · rw [aChan_eq hp hp1, isChan_eq hp hp1, Phi_lt_iff hp.le zero_le_one hn]
    linarith

/-- `3/4 < p < 1`: the OR channel becomes the weakest of all. -/
theorem regime_high (hp34 : 3/4 < p) (hp1 : p < 1) {n : ℕ} (hn : 1 ≤ n) :
    gChan p n < xChan p n ∧ xChan p n < aChan p n ∧ aChan p n < isChan p n := by
  have hp : 0 < p := by linarith
  refine ⟨?_, ?_, ?_⟩
  · rw [gChan_eq hp hp1, xChan_eq hp hp1, Phi_lt_iff (by linarith) (param_xor_nonneg p) hn]
    nlinarith
  · rw [xChan_eq hp hp1, aChan_eq hp hp1, Phi_lt_iff (param_xor_nonneg p) hp.le hn]
    nlinarith
  · rw [aChan_eq hp hp1, isChan_eq hp hp1, Phi_lt_iff hp.le zero_le_one hn]
    linarith

/-! ## The three critical biases -/

/-- At `p = 1/4` the AND and XOR channels merge, at every fork size. -/
theorem critical_quarter (n : ℕ) : aChan (1/4 : ℝ) n = xChan (1/4 : ℝ) n := by
  rw [aChan_eq (by norm_num) (by norm_num), xChan_eq (by norm_num) (by norm_num)]
  norm_num

/-- At `p = 1/2` the AND and OR channels merge, at every fork size. -/
theorem critical_half (n : ℕ) : aChan (1/2 : ℝ) n = gChan (1/2 : ℝ) n := by
  rw [aChan_eq (by norm_num) (by norm_num), gChan_eq (by norm_num) (by norm_num)]
  norm_num

/-- At `p = 3/4` the XOR and OR channels merge, at every fork size. -/
theorem critical_three_quarters (n : ℕ) : xChan (3/4 : ℝ) n = gChan (3/4 : ℝ) n := by
  rw [xChan_eq (by norm_num) (by norm_num), gChan_eq (by norm_num) (by norm_num)]
  norm_num

/-- The XOR channel carries *no* information about a single bit exactly at the
unbiased point, where the parity readout is independent of any one coordinate. -/
theorem xChan_eq_zero_iff (hp : 0 < p) (hp1 : p < 1) {n : ℕ} (hn : 1 ≤ n) :
    xChan p n = 0 ↔ p = 1/2 := by
  have h0 : Phi (0:ℝ) n = 0 := by
    rw [Phi, zero_pow (by omega : n ≠ 0), zero_div]
  rw [xChan_eq hp hp1, ← h0, Phi_eq_iff (param_xor_nonneg p) le_rfl hn]
  constructor
  · intro h; nlinarith
  · intro h; rw [h]; norm_num

/-- **No triple point.**  The three Boolean channels are never all equal: the merges at
`1/4`, `1/2` and `3/4` are pairwise and isolated. -/
theorem no_triple_point (hp : 0 < p) (hp1 : p < 1) {n : ℕ} (hn : 1 ≤ n) :
    ¬ (aChan p n = gChan p n ∧ gChan p n = xChan p n) := by
  rintro ⟨h1, h2⟩
  rw [aChan_eq hp hp1, gChan_eq hp hp1, Phi_eq_iff hp.le (by linarith) hn] at h1
  rw [gChan_eq hp hp1, xChan_eq hp hp1,
    Phi_eq_iff (by linarith) (param_xor_nonneg p) hn] at h2
  -- `h1` forces `p = 1/2`, and then `h2` reads `1/2 = 0`
  have hhalf : p = 1/2 := by linarith
  rw [hhalf] at h2
  norm_num at h2

/-! ## Asymptotic separation from the split-count channel -/

/-- The split-count channel, rescaled by the fork size, is exactly constant. -/
theorem isChan_mul_succ (hp : 0 < p) (hp1 : p < 1) (n : ℕ) :
    ((n : ℝ) + 1) * isChan p n = 1 := by
  rw [isChan_value hp hp1]
  field_simp

/-- Rescaled by the fork size, any profile with parameter `< 1` still vanishes. -/
theorem Phi_mul_succ_tendsto_zero {t : ℝ} (ht : 0 ≤ t) (ht1 : t < 1) :
    Tendsto (fun n : ℕ => ((n : ℝ) + 1) * Phi t n) atTop (𝓝 0) := by
  refine squeeze_zero (fun n => mul_nonneg (by positivity) (Phi_nonneg ht n))
    (g := fun n : ℕ => ((n : ℝ) + 1) * t ^ n) (fun n => ?_) ?_
  · have := Phi_le_pow ht n
    nlinarith [Phi_nonneg ht n, pow_nonneg ht n, Nat.cast_nonneg (α := ℝ) n]
  · have h1 : Tendsto (fun n : ℕ => (n : ℝ) * t ^ n) atTop (𝓝 0) :=
      tendsto_self_mul_const_pow_of_lt_one ht ht1
    have h2 : Tendsto (fun n : ℕ => (t : ℝ) ^ n) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one ht ht1
    simpa [add_mul, one_mul] using h1.add h2

/-- **The Boolean channels are `o(1/n)`**: after multiplying by the fork size — the
scale at which the split-count channel is constant — the AND channel still vanishes.
So the split-count channel dominates by an unbounded factor. -/
theorem aChan_mul_succ_tendsto_zero (hp : 0 < p) (hp1 : p < 1) :
    Tendsto (fun n : ℕ => ((n : ℝ) + 1) * aChan p n) atTop (𝓝 0) := by
  refine Tendsto.congr (fun n => by rw [aChan_eq hp hp1 n]) ?_
  exact Phi_mul_succ_tendsto_zero hp.le hp1

theorem gChan_mul_succ_tendsto_zero (hp : 0 < p) (hp1 : p < 1) :
    Tendsto (fun n : ℕ => ((n : ℝ) + 1) * gChan p n) atTop (𝓝 0) := by
  refine Tendsto.congr (fun n => by rw [gChan_eq hp hp1 n]) ?_
  exact Phi_mul_succ_tendsto_zero (by linarith) (by linarith)

theorem xChan_mul_succ_tendsto_zero (hp : 0 < p) (hp1 : p < 1) :
    Tendsto (fun n : ℕ => ((n : ℝ) + 1) * xChan p n) atTop (𝓝 0) := by
  refine Tendsto.congr (fun n => by rw [xChan_eq hp hp1 n]) ?_
  refine Phi_mul_succ_tendsto_zero (param_xor_nonneg p) ?_
  nlinarith

/-- The Boolean-to-split ratio collapses: no Boolean channel keeps a fixed share of
the split-count channel. -/
theorem boolean_channel_o_one_div (hp : 0 < p) (hp1 : p < 1) :
    Tendsto (fun n : ℕ => aChan p n / isChan p n) atTop (𝓝 0) := by
  refine Tendsto.congr (fun n => ?_) (aChan_mul_succ_tendsto_zero hp hp1)
  rw [isChan_value hp hp1]
  have hn : ((n : ℝ) + 1) ≠ 0 := by positivity
  field_simp

end ForkChannel