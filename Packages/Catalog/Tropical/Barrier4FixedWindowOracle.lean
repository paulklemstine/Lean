import Mathlib

/-!
# Barrier-4 positional converse, stratum T1: the fixed-window oracle

This file formalises the **T1 (fixed-window oracle)** stratum of the barrier-4 positional /
magnitude converse.  The setting is the min-plus ("tropical") search picture used throughout the
factor-location barrier thread (`Tropical.FactorLocationBarriers`): the search space is normalised
to total measure `1`, a *block* `B` of relative measure `μ` is singled out by an oracle, and the
cost of an algorithm is the expected relative measure it must scan.  The **speedup** of a protocol
is `S = 1 / cost`.

The oracle *hits* with probability `P` (`P = P_hit`).  Three laws are in play.

* `costCert μ P = μ·P + (1−P)·(1−μ)` — the **certified-silence law**: silence is a certificate
  that the target is outside the block, so a silent oracle costs only the complement.
* `costFireOrSilent μ P = 1 − (1−μ)·P` — the **drafted fire-or-silent law**: silence carries no
  certificate, so the whole space must be re-scanned.
* `costRescan μ P = μ + (1−P)` — **protocol B**, block-first with a wasteful full re-scan on miss.

The main results:

* `cost_arithmetic_progression` : the three laws are in arithmetic progression with common gap
  `μ(1−P)`; in particular the drafted law is *superseded* — it strictly understates the certified
  speedup whenever `μ > 0` and `P < 1` (`speedup_drafted_lt_speedup_cert`).
* `speedupB_le_speedupA` : protocol B never beats protocol A.
* `costCert_ge_mu` / `speedupCert_le_inv_mu` : the cap `S_A ≤ 1/μ`, **valid only for `μ ≤ 1/2`**
  and attained exactly at `P = 1` (`speedupCert_at_hit_one`).  The restriction is sharp:
  `speedupCert_gt_inv_mu_of_large_block` exhibits `μ = 9/10, P = 0` with `S_A = 10 > 1/μ`.
* `no_constant_cap` : no constant bounds the certified speedup.
* `costCert_half_block_const` : at `μ = 1/2` the certified speedup is exactly `2`, *independently*
  of `P` — the oracle's information is worthless at the balanced block.
* `blockFirst_dominance_A` : block-first dominance is **unconditional** for protocol A;
* `blockFirst_dominance_B_iff` : for protocol B it holds **iff `μ ≤ P`** — every counterexample
  has `P < μ`, exactly as the finite sweeps reported.
-/

namespace Barrier4

/-! ## 1. The three cost laws -/

/-- Protocol A, committed policy: **certified silence**.  With probability `P` the oracle fires
and the block (measure `μ`) is scanned; with probability `1−P` silence certifies that the target
lies in the complement (measure `1−μ`). -/
def costCert (mu P : ℝ) : ℝ := mu * P + (1 - P) * (1 - mu)

/-- The drafted (superseded) **fire-or-silent** law: silence certifies nothing, so the entire
space is scanned. -/
def costFireOrSilent (mu P : ℝ) : ℝ := 1 - (1 - mu) * P

/-- Protocol B, block-first: pay the block, and on a miss re-scan the whole space. -/
def costRescan (mu P : ℝ) : ℝ := mu + (1 - P)

/-- Protocol B, complement-first. -/
def costRescanComp (mu P : ℝ) : ℝ := (1 - mu) + P

/-- Protocol A, complement-first: when the oracle fires the complement scan is pure waste. -/
def costCertComp (mu P : ℝ) : ℝ := P + (1 - P) * (1 - mu)

/-- Speedup relative to the exhaustive scan of cost `1`. -/
noncomputable def speedup (c : ℝ) : ℝ := 1 / c

/-! ## 2. Positivity of the certified cost -/

theorem costCert_pos {mu P : ℝ} (hmu0 : 0 < mu) (hmu1 : mu < 1) (hP0 : 0 ≤ P) (hP1 : P ≤ 1) :
    0 < costCert mu P := by
  have h : min mu (1 - mu) ≤ costCert mu P := by
    have h1 : min mu (1 - mu) * P ≤ mu * P := by
      have := min_le_left mu (1 - mu); nlinarith
    have h2 : min mu (1 - mu) * (1 - P) ≤ (1 - P) * (1 - mu) := by
      have := min_le_right mu (1 - mu); nlinarith
    have : min mu (1 - mu) = min mu (1 - mu) * P + min mu (1 - mu) * (1 - P) := by ring
    rw [costCert, this]; linarith
  have : 0 < min mu (1 - mu) := lt_min hmu0 (by linarith)
  linarith

/-! ## 3. The three laws form an arithmetic progression -/

/-- **The three laws are equally spaced.**  Passing from the certified law to the drafted
fire-or-silent law, and again from the drafted law to protocol B, each costs exactly `μ(1−P)`:
the price of one non-certifying silence. -/
theorem cost_arithmetic_progression (mu P : ℝ) :
    costFireOrSilent mu P - costCert mu P = mu * (1 - P) ∧
      costRescan mu P - costFireOrSilent mu P = mu * (1 - P) := by
  refine ⟨by simp only [costCert, costFireOrSilent]; ring,
    by simp only [costFireOrSilent, costRescan]; ring⟩

theorem costCert_le_fireOrSilent {mu P : ℝ} (hmu : 0 ≤ mu) (hP : P ≤ 1) :
    costCert mu P ≤ costFireOrSilent mu P := by
  have := (cost_arithmetic_progression mu P).1
  nlinarith

theorem fireOrSilent_le_costRescan {mu P : ℝ} (hmu : 0 ≤ mu) (hP : P ≤ 1) :
    costFireOrSilent mu P ≤ costRescan mu P := by
  have := (cost_arithmetic_progression mu P).2
  nlinarith

/-- **The drafted law is superseded.**  For a nondegenerate block and an imperfect oracle the
fire-or-silent form strictly understates the achievable speedup. -/
theorem speedup_drafted_lt_speedup_cert {mu P : ℝ} (hmu0 : 0 < mu) (hmu1 : mu < 1)
    (hP0 : 0 ≤ P) (hP1 : P < 1) :
    speedup (costFireOrSilent mu P) < speedup (costCert mu P) := by
  have hc : 0 < costCert mu P := costCert_pos hmu0 hmu1 hP0 hP1.le
  have hlt : costCert mu P < costFireOrSilent mu P := by
    have := (cost_arithmetic_progression mu P).1
    nlinarith
  unfold speedup
  exact one_div_lt_one_div_of_lt hc hlt

/-- **Protocol B never beats protocol A.** -/
theorem speedupB_le_speedupA {mu P : ℝ} (hmu0 : 0 < mu) (hmu1 : mu < 1)
    (hP0 : 0 ≤ P) (hP1 : P ≤ 1) :
    speedup (costRescan mu P) ≤ speedup (costCert mu P) := by
  have hc : 0 < costCert mu P := costCert_pos hmu0 hmu1 hP0 hP1
  have h : costCert mu P ≤ costRescan mu P :=
    le_trans (costCert_le_fireOrSilent hmu0.le hP1) (fireOrSilent_le_costRescan hmu0.le hP1)
  exact one_div_le_one_div_of_le hc h

/-! ## 4. The cap `1/μ`, its regime, and the absence of a constant cap -/

/-- For a block of at most half the space, the certified cost is at least `μ`. -/
theorem costCert_ge_mu {mu P : ℝ} (hmu : mu ≤ 1 / 2) (hP : P ≤ 1) : mu ≤ costCert mu P := by
  have : costCert mu P - mu = (1 - P) * (1 - 2 * mu) := by unfold costCert; ring
  nlinarith

/-- **Cap.**  In the regime `μ ≤ 1/2` the certified speedup is at most `1/μ`. -/
theorem speedupCert_le_inv_mu {mu P : ℝ} (hmu0 : 0 < mu) (hmu : mu ≤ 1 / 2)
    (hP0 : 0 ≤ P) (hP1 : P ≤ 1) :
    speedup (costCert mu P) ≤ 1 / mu := by
  have hc : 0 < costCert mu P := costCert_pos hmu0 (by linarith) hP0 hP1
  exact one_div_le_one_div_of_le hmu0 (costCert_ge_mu hmu hP1)

/-- The cap is attained exactly at a perfect oracle. -/
theorem speedupCert_at_hit_one (mu : ℝ) : costCert mu 1 = mu := by unfold costCert; ring

/-- Equality in the cap forces `P = 1` (for `μ < 1/2`). -/
theorem hit_one_of_cap_attained {mu P : ℝ} (hmu : mu < 1 / 2) (h : costCert mu P = mu) : P = 1 := by
  have : (1 - P) * (1 - 2 * mu) = 0 := by unfold costCert at h; nlinarith
  rcases mul_eq_zero.1 this with h1 | h2
  · linarith
  · linarith

/-- **The `μ ≤ 1/2` restriction is sharp.**  A block occupying `9/10` of the space with a
never-firing oracle already gives `S_A = 10 > 1/μ`: certified silence about a huge block is
itself powerful information. -/
theorem speedupCert_gt_inv_mu_of_large_block :
    1 / (9 / 10 : ℝ) < speedup (costCert (9 / 10) 0) := by
  unfold speedup costCert; norm_num

/-- **No constant cap exists.**  For every bound `C` there is a legitimate configuration
`(μ, P)` whose certified speedup exceeds it. -/
theorem no_constant_cap (C : ℝ) :
    ∃ mu P : ℝ, 0 < mu ∧ mu < 1 / 2 ∧ 0 ≤ P ∧ P ≤ 1 ∧ C < speedup (costCert mu P) := by
  refine ⟨1 / (|C| + 3), 1, by positivity, ?_, by norm_num, le_refl _, ?_⟩
  · rw [div_lt_div_iff₀ (by positivity) (by norm_num)]
    have := abs_nonneg C; linarith
  · rw [speedupCert_at_hit_one]
    have h1 : (0:ℝ) < |C| + 3 := by have := abs_nonneg C; linarith
    have : speedup (1 / (|C| + 3)) = |C| + 3 := by
      unfold speedup; rw [one_div_one_div]
    rw [this]
    have := le_abs_self C
    linarith

/-- **Balanced-block invariance.**  At `μ = 1/2` the certified cost is `1/2` for *every* hit
probability: the fixed-window oracle contributes exactly a factor `2` and its accuracy is
irrelevant. -/
theorem costCert_half_block_const (P : ℝ) : costCert (1 / 2) P = 1 / 2 := by
  unfold costCert; ring

/-- Monotonicity: for a sub-half block the certified cost strictly decreases in the hit
probability. -/
theorem costCert_strictAnti_in_P {mu P Q : ℝ} (hmu : mu < 1 / 2) (hPQ : P < Q) :
    costCert mu Q < costCert mu P := by
  have : costCert mu P - costCert mu Q = (Q - P) * (1 - 2 * mu) := by unfold costCert; ring
  nlinarith

/-! ## 5. Block-first dominance -/

/-- **Unconditional block-first dominance for protocol A.** -/
theorem blockFirst_dominance_A {mu P : ℝ} (hmu : mu ≤ 1) (hP : 0 ≤ P) :
    costCert mu P ≤ costCertComp mu P := by
  have : costCertComp mu P - costCert mu P = P * (1 - mu) := by
    unfold costCert costCertComp; ring
  nlinarith

theorem blockFirst_dominance_A_strict {mu P : ℝ} (hmu : mu < 1) (hP : 0 < P) :
    costCert mu P < costCertComp mu P := by
  have : costCertComp mu P - costCert mu P = P * (1 - mu) := by
    unfold costCert costCertComp; ring
  nlinarith

/-- **Restricted block-first dominance for protocol B**: it holds *exactly* on `μ ≤ P`.
Every violation therefore has `P < μ`. -/
theorem blockFirst_dominance_B_iff (mu P : ℝ) :
    costRescan mu P ≤ costRescanComp mu P ↔ mu ≤ P := by
  unfold costRescan costRescanComp
  constructor <;> intro h <;> linarith

/-- A concrete protocol-B counterexample, in the predicted region `P < μ`. -/
theorem blockFirst_fails_B_example :
    costRescanComp (1 / 2 : ℝ) (1 / 4) < costRescan (1 / 2) (1 / 4) ∧ (1 / 4 : ℝ) < 1 / 2 := by
  unfold costRescan costRescanComp; norm_num

/-! ## 6. The uninformative point -/

/-- At the **uninformative point** `P = μ` (the oracle fires exactly as often as the block is
big, i.e. it carries no information beyond the block's measure) the drafted fire-or-silent law
collapses to the pure residue law `1 − μ(1−μ)`; this is the identity that pins Conjecture D's
residue cap to the T1 family (see `Tropical.Barrier4SetCostDichotomy`). -/
theorem fireOrSilent_at_uninformative (mu : ℝ) :
    costFireOrSilent mu mu = 1 - mu * (1 - mu) := by unfold costFireOrSilent; ring

/-- At the uninformative point the *certified* law is bounded by the balanced value `2`. -/
theorem speedupCert_at_uninformative_le_two {mu : ℝ} (hmu0 : 0 < mu) (hmu1 : mu < 1) :
    speedup (costCert mu mu) ≤ 2 := by
  have hc : 0 < costCert mu mu := costCert_pos hmu0 hmu1 hmu0.le hmu1.le
  have hhalf : (1:ℝ) / 2 ≤ costCert mu mu := by
    have : costCert mu mu - 1 / 2 = 2 * (mu - 1 / 2) ^ 2 := by unfold costCert; ring
    nlinarith [sq_nonneg (mu - 1/2)]
  unfold speedup
  rw [div_le_iff₀ hc]
  linarith

end Barrier4