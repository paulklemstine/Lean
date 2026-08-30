import Shared.SpeculativeDecodingCostDominance

/-!
# Unimodality of throughput in draft depth, and the validity of greedy depth tuning

Cycle 2 of the NET-91 thread.  Cycle 1
(`Shared.SpeculativeDecodingCostDominance`) established *draft-cost dominance* and the
fact that the "deepening pays" frontier is monotone in acceptance.  It left open the
question a practitioner actually faces: the experiment tuned depth on the grid
`{2, 4, 8}` and found different winners per domain — but is a *local* search over depth
guaranteed to find the *global* optimum, or can throughput have several humps, so that
the observed prose collapse past `d = 4` hides a later revival?

The answer here is a genuine structure theorem: **for any yield with nonincreasing
increments over an affine cost, throughput in depth is unimodal**.  Once one extra draft
step fails to pay, no deeper step ever pays again (`decline_propagates`,
`decline_persists`), so hill-climbing from `d = 0` and stopping at the first
non-improving step returns a global optimum (`greedy_depth_optimal`).  Concavity of the
yield is exactly what the i.i.d. model supplies — its increments are `a ^ (d+1)` — and it
is also the qualitative property any position-dependent acceptance profile with
nonincreasing per-position acceptance enjoys.  So the *grid* `{2, 4, 8}` used in NET-91
cannot have missed a second hump: the measured collapse is terminal.

Instantiated at the measured 0.5B-draft cost `c = 0.118`, the model's optimal depths are

  prose (`a = 0.477`) : `d* = 2`   (`prose_optimal_depth_two`)
  code  (`a = 0.630`) : `d* = 3`   (`code_optimal_depth_three`)

a strict, provable domain split (`optimal_depth_domain_split`): at exactly the same
depth-3 decision the two domains disagree, so no single static depth is optimal for both.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 2, 5 conjectures):
 (C1) [BOLD] Throughput is unimodal in depth for every concave yield: the depth landscape
      has no second hump, so greedy tuning is exact.
 (C2) The i.i.d. yield is concave, hence C1 applies to cycle 1's model verbatim.
 (C3) The model's optimal depths for the measured prose and code acceptances differ, and
      the difference is exhibited by a single decision (`d = 2 → 3`).
 (C4) Concavity is *necessary* in the sense that an affine yield (cycle 1's mean-yield
      reading) has no interior optimum at all — already proved in cycle 1.
 (C5) Unimodality plus cycle 1's monotone frontier gives a monotone optimal-depth
      selector: higher acceptance never lowers the greedy stopping depth.

Experimenter: C1–C3 and C5 are formalised below with zero sorries; C4 is
`SpecDecCPU.affine_ratio_mono` / `affine_ratio_anti` from cycle 1.

Analyst: the proof of C1 is a two-line marginal-cost computation once the comparison is
put in cross-multiplied form: `speedup (d+1) < speedup d` is *equivalent* to
`increment d * blockCost c d < c * yield d`, and the left side is nonincreasing while the
right side is nondecreasing in `d`.  The same identity explains why the affine reading has
no interior optimum: there the two sides are, respectively, constant and affine, so they
cross at most once and never re-cross.

Critic: the two numeric optima are corollaries of the general theorem, not standalone
`norm_num` facts — each needs three evaluated comparisons plus `greedy_depth_optimal` to
become a statement quantified over *all* depths.
-/

namespace SpecDecCPU

open Finset

/-! ## A general concave-yield block model -/

/-- Throughput of a block model with arbitrary yield curve `Y` over the affine cost
`blockCost c d = 1 + c * d`. -/
noncomputable def genSpeedup (Y : ℕ → ℝ) (c : ℝ) (d : ℕ) : ℝ := Y d / blockCost c d

lemma genSpeedup_yieldGeom (a c : ℝ) (d : ℕ) :
    genSpeedup (yieldGeom a) c d = speedup a c d := rfl

/-- Cross-multiplied form of "one more draft step does not pay": the marginal yield of the
extra position, charged at the current block cost, falls short of the extra draft cost
charged at the current yield. -/
lemma genSpeedup_succ_lt_iff {Y : ℕ → ℝ} {c : ℝ} (hc : 0 ≤ c) (d : ℕ) :
    genSpeedup Y c (d + 1) < genSpeedup Y c d ↔
      (Y (d + 1) - Y d) * blockCost c d < c * Y d := by
  rw [genSpeedup, genSpeedup, div_lt_div_iff₀ (blockCost_pos hc (d + 1))
    (blockCost_pos hc d)]
  have h : blockCost c (d + 1) = blockCost c d + c := by
    simp only [blockCost, Nat.cast_add, Nat.cast_one]; ring
  rw [h]
  constructor <;> intro hh <;> nlinarith

/-- **Unimodality step.**  If the yield has nonincreasing increments, then once deepening
the draft by one step stops paying, the next step does not pay either. -/
theorem decline_propagates {Y : ℕ → ℝ} {c : ℝ} (hc : 0 ≤ c) {d : ℕ}
    (hconc : Y (d + 2) - Y (d + 1) ≤ Y (d + 1) - Y d)
    (h : genSpeedup Y c (d + 1) < genSpeedup Y c d) :
    genSpeedup Y c (d + 2) < genSpeedup Y c (d + 1) := by
  rw [genSpeedup_succ_lt_iff hc] at h
  rw [genSpeedup_succ_lt_iff hc]
  have hb : 0 < blockCost c d := blockCost_pos hc d
  have hb1 : blockCost c (d + 1) = blockCost c d + c := by
    simp only [blockCost, Nat.cast_add, Nat.cast_one]; ring
  rw [hb1]
  nlinarith

/-- **Unimodality.**  Under nonincreasing yield increments, a single non-improving step at
depth `D` forces every deeper step to be non-improving: throughput has no second hump. -/
theorem decline_persists {Y : ℕ → ℝ} {c : ℝ} (hc : 0 ≤ c)
    (hconc : ∀ n, Y (n + 2) - Y (n + 1) ≤ Y (n + 1) - Y n) {D : ℕ}
    (h : genSpeedup Y c (D + 1) < genSpeedup Y c D) :
    ∀ e ≥ D, genSpeedup Y c (e + 1) < genSpeedup Y c e := by
  intro e he
  induction e, he using Nat.le_induction with
  | base => exact h
  | succ n hn ih => exact decline_propagates hc (hconc n) ih

lemma genSpeedup_le_of_ge {Y : ℕ → ℝ} {c : ℝ} (hc : 0 ≤ c)
    (hconc : ∀ n, Y (n + 2) - Y (n + 1) ≤ Y (n + 1) - Y n) {D : ℕ}
    (h : genSpeedup Y c (D + 1) < genSpeedup Y c D) :
    ∀ e ≥ D, genSpeedup Y c e ≤ genSpeedup Y c D := by
  intro e he
  induction e, he using Nat.le_induction with
  | base => exact le_rfl
  | succ n hn ih =>
      exact le_trans (le_of_lt (decline_persists hc hconc h n hn)) ih

/-- **Greedy depth tuning is exact.**  If every step up to `D` improved throughput and the
step from `D` to `D + 1` does not, then `D` is a globally optimal draft depth. -/
theorem greedy_depth_optimal {Y : ℕ → ℝ} {c : ℝ} (hc : 0 ≤ c)
    (hconc : ∀ n, Y (n + 2) - Y (n + 1) ≤ Y (n + 1) - Y n) {D : ℕ}
    (hup : ∀ k < D, genSpeedup Y c k ≤ genSpeedup Y c (k + 1))
    (hstop : genSpeedup Y c (D + 1) < genSpeedup Y c D) :
    ∀ d : ℕ, genSpeedup Y c d ≤ genSpeedup Y c D := by
  intro d
  rcases le_or_gt D d with hd | hd
  · exact genSpeedup_le_of_ge hc hconc hstop d hd
  · -- climb from `d` up to `D`
    have key : ∀ m : ℕ, ∀ k : ℕ, k + m = D → genSpeedup Y c k ≤ genSpeedup Y c D := by
      intro m
      induction m with
      | zero => intro k hk; subst hk; simp
      | succ n ih =>
          intro k hk
          have hkD : k < D := by omega
          exact le_trans (hup k hkD) (ih (k + 1) (by omega))
    exact key (D - d) d (by omega)

/-! ## The i.i.d. yield is concave, so the model is unimodal -/

lemma yieldGeom_increment (a : ℝ) (d : ℕ) :
    yieldGeom a (d + 1) - yieldGeom a d = a ^ (d + 1) := by
  simp only [yieldGeom, Finset.sum_range_succ]
  ring

lemma yieldGeom_concave {a : ℝ} (ha : 0 ≤ a) (ha1 : a ≤ 1) (n : ℕ) :
    yieldGeom a (n + 2) - yieldGeom a (n + 1) ≤ yieldGeom a (n + 1) - yieldGeom a n := by
  rw [yieldGeom_increment a (n + 1), yieldGeom_increment a n]
  exact pow_le_pow_of_le_one ha ha1 (by omega)

/-- **Unimodality of the CPU speculative-decoding model.**  Hill-climbing the draft depth
and stopping at the first non-improving step returns the throughput-optimal depth. -/
theorem geom_greedy_depth_optimal {a c : ℝ} (ha : 0 ≤ a) (ha1 : a ≤ 1) (hc : 0 ≤ c)
    {D : ℕ} (hup : ∀ k < D, speedup a c k ≤ speedup a c (k + 1))
    (hstop : speedup a c (D + 1) < speedup a c D) :
    ∀ d : ℕ, speedup a c d ≤ speedup a c D :=
  greedy_depth_optimal (Y := yieldGeom a) hc (yieldGeom_concave ha ha1) hup hstop

/-! ## The measured domain split in optimal depth -/

/-- Prose (measured acceptance `47.7%` at the 0.5B draft cost): the model's optimal draft
depth is `2`, and this is optimal among **all** depths, not just the measured grid. -/
theorem prose_optimal_depth_two :
    ∀ d : ℕ, speedup (477/1000) (118/1000) d ≤ speedup (477/1000) (118/1000) 2 := by
  refine geom_greedy_depth_optimal (by norm_num) (by norm_num) (by norm_num) ?_ ?_
  · intro k hk
    interval_cases k
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 0)
        (blockCost_pos (by norm_num) 1)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 1)
        (blockCost_pos (by norm_num) 2)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
  · rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
    norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-- Code (measured acceptance `63.0%` at the same draft cost): the model's optimal draft
depth is `3`. -/
theorem code_optimal_depth_three :
    ∀ d : ℕ, speedup (630/1000) (118/1000) d ≤ speedup (630/1000) (118/1000) 3 := by
  refine geom_greedy_depth_optimal (by norm_num) (by norm_num) (by norm_num) ?_ ?_
  · intro k hk
    interval_cases k
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 0)
        (blockCost_pos (by norm_num) 1)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 1)
        (blockCost_pos (by norm_num) 2)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
    · rw [speedup, speedup, div_le_div_iff₀ (blockCost_pos (by norm_num) 2)
        (blockCost_pos (by norm_num) 3)]
      norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
  · rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
    norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-- **Optimal depth is domain-parameterised.**  At one and the same decision — whether to
draft a third token — prose and code disagree: it is a loss for prose and a gain for code.
Consequently the two globally optimal depths differ (`2` versus `3`), and no static depth
setting is optimal for both domains. -/
theorem optimal_depth_domain_split :
    speedup (477/1000) (118/1000) 3 < speedup (477/1000) (118/1000) 2 ∧
    speedup (630/1000) (118/1000) 2 < speedup (630/1000) (118/1000) 3 ∧
    (∀ d : ℕ, speedup (477/1000) (118/1000) d ≤ speedup (477/1000) (118/1000) 2) ∧
    (∀ d : ℕ, speedup (630/1000) (118/1000) d ≤ speedup (630/1000) (118/1000) 3) := by
  refine ⟨?_, ?_, prose_optimal_depth_two, code_optimal_depth_three⟩
  · rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
    norm_num [yieldGeom, blockCost, Finset.sum_range_succ]
  · rw [speedup_lt_speedup_iff (by norm_num) (by norm_num)]
    norm_num [yieldGeom, blockCost, Finset.sum_range_succ]

/-- **Monotone greedy selector.**  Combining unimodality with the acceptance-monotone
frontier of cycle 1: if the greedy search stops at depth `D` for acceptance `a'`, then for
every smaller acceptance `a` the step from `D` to `D + 1` is also non-improving.  Higher
acceptance therefore never lowers the stopping depth — the code/prose split is forced. -/
theorem greedy_stop_antitone {a a' c : ℝ} {D : ℕ} (ha : 0 < a) (haa : a ≤ a')
    (hc : 0 ≤ c) (h : speedup a' c (D + 1) < speedup a' c D) :
    speedup a c (D + 1) < speedup a c D := by
  by_contra hcon
  push_neg at hcon
  exact absurd (depth_frontier_monotone ha haa hc (Nat.lt_succ_self D) hcon) (not_le.2 h)

end SpecDecCPU