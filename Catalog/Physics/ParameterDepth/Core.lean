import Mathlib

/-!
# Parameter-derived depth, I: the abstract budget/threshold layer

A physical hierarchy (a renormalisation cascade, a refinement of a spacetime
lattice, a nested error-correcting code) is built level by level.  Realising the
levels `0, 1, …, d` consumes some resource — cells, degrees of freedom, energy —
and the model only makes sense while that consumption stays below a *threshold*
`T` fixed by the physics (a holographic bound, a detector resolution, an energy
budget).

This file isolates the purely order-theoretic core of that situation:

* `Physics.ParameterDepth.Supported cost T d` — depth `d` is affordable;
* `Physics.ParameterDepth.maxDepth cost T`   — the *computed* largest affordable depth;
* `Physics.ParameterDepth.isGreatest_maxDepth` — **maximality**: `maxDepth` really is the
  greatest element of the set of supported depths, hence unique;
* `Physics.ParameterDepth.supported_iff_le_maxDepth` — the whole support set is the
  initial segment `[0, maxDepth]`, so a single number determines the model;
* monotonicity of `maxDepth` in the threshold and antitonicity in the cost.

The hypotheses are minimal: a strictly monotone cost with `cost 0 ≤ T`.  Strict
monotonicity is what forces the supported set to be finite (`d ≤ cost d`), and it is
what every concrete cascade in the sequel satisfies.

Downstream files (`Physics.ParameterDepth.TreeDepth`,
`Physics.ParameterDepth.Asymptotics`) instantiate this layer with concrete `B`, `T`
and derive *closed forms* for the maximal depth.
-/

namespace Physics.ParameterDepth

/-- Depth `d` is **supported** by the threshold `T` when the cumulative cost of
building the hierarchy down to level `d` does not exceed `T`. -/
def Supported (cost : ℕ → ℕ) (T d : ℕ) : Prop := cost d ≤ T

instance (cost : ℕ → ℕ) (T d : ℕ) : Decidable (Supported cost T d) := by
  unfold Supported; infer_instance

/-- The set of depths supported by the threshold `T`. -/
def supportSet (cost : ℕ → ℕ) (T : ℕ) : Set ℕ := {d | Supported cost T d}

/-- The **largest supported depth**.  Computed by a bounded search; the bound `T` is
legitimate because a strictly monotone cost satisfies `d ≤ cost d`. -/
def maxDepth (cost : ℕ → ℕ) (T : ℕ) : ℕ := Nat.findGreatest (Supported cost T) T

/-- A strictly monotone cost grows at least as fast as the depth, so any supported
depth is itself bounded by the threshold. -/
theorem le_threshold_of_supported {cost : ℕ → ℕ} (hc : StrictMono cost) {T d : ℕ}
    (h : Supported cost T d) : d ≤ T :=
  le_trans hc.le_apply h

/-- Support is downward closed: if a deep level is affordable, so is every shallower
one.  (This is the only place monotonicity of the cost is used qualitatively.) -/
theorem supported_of_le {cost : ℕ → ℕ} (hc : Monotone cost) {T d e : ℕ} (hde : e ≤ d)
    (h : Supported cost T d) : Supported cost T e :=
  le_trans (hc hde) h

/-- Every supported depth is at most `maxDepth`. -/
theorem le_maxDepth {cost : ℕ → ℕ} (hc : StrictMono cost) {T d : ℕ}
    (h : Supported cost T d) : d ≤ maxDepth cost T :=
  Nat.le_findGreatest (le_threshold_of_supported hc h) h

/-- `maxDepth` is itself supported, provided the ground level `0` is. -/
theorem supported_maxDepth {cost : ℕ → ℕ} {T : ℕ} (h0 : Supported cost T 0) :
    Supported cost T (maxDepth cost T) :=
  Nat.findGreatest_spec (Nat.zero_le T) h0

/-- **Maximality.**  `maxDepth cost T` is the greatest supported depth. -/
theorem isGreatest_maxDepth {cost : ℕ → ℕ} (hc : StrictMono cost) {T : ℕ}
    (h0 : Supported cost T 0) : IsGreatest (supportSet cost T) (maxDepth cost T) :=
  ⟨supported_maxDepth h0, fun _ hd => le_maxDepth hc hd⟩

/-- The supported depths form the initial segment `[0, maxDepth]`. -/
theorem supported_iff_le_maxDepth {cost : ℕ → ℕ} (hc : StrictMono cost) {T : ℕ}
    (h0 : Supported cost T 0) (d : ℕ) : Supported cost T d ↔ d ≤ maxDepth cost T := by
  refine ⟨le_maxDepth hc, fun h => ?_⟩
  exact supported_of_le hc.monotone h (supported_maxDepth h0)

/-- The next level is *not* supported: the computed depth is genuinely a frontier,
not merely an upper bound. -/
theorem not_supported_succ_maxDepth {cost : ℕ → ℕ} (hc : StrictMono cost) {T : ℕ} :
    ¬ Supported cost T (maxDepth cost T + 1) := by
  intro h
  have := le_maxDepth hc h
  omega

/-- **Uniqueness.**  Any greatest supported depth coincides with the computed one; so
`maxDepth` is *the* answer, independent of how it is found. -/
theorem eq_maxDepth_of_isGreatest {cost : ℕ → ℕ} (hc : StrictMono cost) {T d : ℕ}
    (h0 : Supported cost T 0) (h : IsGreatest (supportSet cost T) d) :
    d = maxDepth cost T :=
  h.unique (isGreatest_maxDepth hc h0)

/-- A convenient certificate: to identify the maximal depth it suffices to exhibit one
supported level whose successor fails. -/
theorem maxDepth_eq_of_frontier {cost : ℕ → ℕ} (hc : StrictMono cost) {T d : ℕ}
    (hd : Supported cost T d) (hd' : ¬ Supported cost T (d + 1)) :
    maxDepth cost T = d := by
  have h0 : Supported cost T 0 := supported_of_le hc.monotone (Nat.zero_le d) hd
  refine le_antisymm ?_ (le_maxDepth hc hd)
  by_contra hlt
  push_neg at hlt
  exact hd' (supported_of_le hc.monotone hlt (supported_maxDepth h0))

/-- Raising the threshold cannot decrease the supported depth. -/
theorem maxDepth_mono_threshold {cost : ℕ → ℕ} (hc : StrictMono cost) {T T' : ℕ}
    (hT : T ≤ T') (h0 : Supported cost T 0) :
    maxDepth cost T ≤ maxDepth cost T' := by
  have h0' : Supported cost T' 0 := le_trans h0 hT
  exact le_maxDepth hc (le_trans (supported_maxDepth h0) hT)

/-- Making every level more expensive cannot increase the supported depth. -/
theorem maxDepth_antitone_cost {cost cost' : ℕ → ℕ} (hc : StrictMono cost)
    (hle : ∀ d, cost d ≤ cost' d) {T : ℕ} (h0' : Supported cost' T 0) :
    maxDepth cost' T ≤ maxDepth cost T :=
  le_maxDepth hc (le_trans (hle _) (supported_maxDepth h0'))

/-- If even the ground level exceeds the threshold, the search returns `0` — the
degenerate regime, recorded so that no statement above is silently vacuous. -/
theorem maxDepth_eq_zero_of_not_supported_zero {cost : ℕ → ℕ} (hc : Monotone cost) {T : ℕ}
    (h0 : ¬ Supported cost T 0) : maxDepth cost T = 0 := by
  rw [maxDepth, Nat.findGreatest_eq_zero_iff]
  intro m _ _ hs
  exact h0 (supported_of_le hc (Nat.zero_le m) hs)

end Physics.ParameterDepth