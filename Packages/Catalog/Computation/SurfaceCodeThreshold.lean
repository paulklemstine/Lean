import Mathlib
import Computation.EastinKnillLie
import Computation.FaultToleranceThreshold

/-!
# The surface-code accuracy threshold and its `1 %` value

The threshold of a *topological* code is not produced by a recursion (that is
`Computation.FaultToleranceThreshold`) but by a **counting** argument.  For the surface
code with i.i.d. noise of rate `p`, a logical error requires an error chain that connects
two opposite boundaries, hence has weight at least half the code distance, and the number
of chains of weight `ℓ` that can do this grows at most like `N · μ ^ ℓ`, where `μ` is the
chain-growth (connective) constant of the lattice and `N` counts anchor positions.  The
resulting failure bound is a geometric series in `μ p`, so it is suppressed exactly when

  `p < 1 / μ`.

With the growth constant `μ = 100` used in the standard combinatorial estimate for the
surface code subject to depolarizing noise, this reads `p < 1 %` — the celebrated
one-percent threshold.

**Honesty statement.**  What is *proved* here is the counting theorem: given the
chain-counting hypothesis with growth constant `μ`, the logical failure probability is
suppressed exponentially in the code distance if and only if `p < 1/μ`, and `μ = 100`
gives exactly `1 %`.  The value `μ = 100` is an input (a modelling constant); the
frequently quoted numerical value `≈ 1.1 %` for minimum-weight-matching decoding of the
surface code under depolarizing noise is a Monte-Carlo result and is *not* claimed here.
`Computation.SurfaceCodeChainCounting` proves a rigorous lattice bound of the same
shape (with the non-backtracking growth constant `3`), showing how such a constant is
obtained.

## Main results

* `tsum_chain_geometric` — the chain series sums to `q ^ m / (1 - q)`, `q = μ p`.
* `failureBound_le` — the logical failure probability bound in closed form.
* `suppression_iff` — **sharp**: the bound is suppressed as the distance grows *iff*
  `μ p < 1`.
* `surface_threshold_one_percent` — the specialisation `μ = 100`: suppression iff
  `p < 1/100`.
* `failureBound_le_of_halfDistance`, `surface_qubit_overhead_polylog` — the overhead law:
  `O(log (1/ε))` distance and hence `O(log² (1/ε))` physical qubits per logical qubit.
* `eastin_knill_forces_distillation` — the cross-file synthesis: transversal gates on a
  code give only phases (Eastin–Knill, `Computation.EastinKnillLie`), so universality must
  come from magic-state distillation, whose recursion converges below *its* threshold
  (`Computation.FaultToleranceThreshold`).

-- !-- Lab Notebook -- !--
-- Hypothesis:  The topological threshold and the concatenation threshold are the same
--   phenomenon seen through different lenses: a geometric series in `μ p` versus a
--   doubly-exponential recursion in `a p`.  Both are governed by a single rescaled
--   variable crossing `1`.
-- Result:  Confirmed structurally.  `suppression_iff` (this file) and
--   `FaultTolerance.ftIter_tendsto_zero_iff` (companion file) are both sharp `iff`s in
--   the rescaled variable, and both fail *at* the critical point.  The difference is the
--   rate: `q ^ m` (exponential in distance) versus `q ^ (k ^ n)` (doubly exponential in
--   levels).  Consequence for overheads: `log² (1/ε)` qubits topologically versus
--   `polylog` with `log log (1/ε)` levels by concatenation.
-- Experiment (negative result, kept):  A first formulation defined the failure bound as
--   the raw `tsum` and tried to prove "suppressed iff q < 1" for it.  This is FALSE as
--   stated in Lean, and instructively so: for `q ≥ 1` the series is not summable and
--   Mathlib's `tsum` returns `0`, so the divergent case would masquerade as perfect
--   suppression.  The fix is to state sharpness on the leading term `N q ^ m`
--   (`suppression_iff`) and to use the `tsum` only where summability holds
--   (`tsum_chain_geometric`).  Classified as "needs a different definition".
-- Numerical spot-check of `failureBound 1 (100 p) m` at p = 0.9 %:  q = 0.9, and the
--   bound at half-distances m = 5, 10, 20 is 5.9, 3.5, 1.2·10⁰ — i.e. suppression is
--   real but slow near threshold, as expected; at p = 0.1 % (q = 0.1) the same
--   half-distances give 1.1·10⁻⁵, 1.1·10⁻¹⁰, 1.1·10⁻²⁰.
-/

open Filter Topology

namespace SurfaceCode

/-! ## The chain-counting series -/

/-- The weight-`ℓ` chain series of a topological code: `∑' ℓ, q ^ (m + ℓ)` where
`q = μ p` combines the physical error rate with the chain-growth constant and `m` is the
minimal weight of an error chain that can cause a logical error (half the distance). -/
theorem tsum_chain_geometric {q : ℝ} (h0 : 0 ≤ q) (h1 : q < 1) (m : ℕ) :
    ∑' ℓ : ℕ, q ^ (m + ℓ) = q ^ m / (1 - q) := by
  simp only [pow_add]
  rw [tsum_mul_left, tsum_geometric_of_lt_one h0 h1]
  field_simp

/-- The chain-counting upper bound on the logical failure probability of a topological
code of half-distance `m`: `N` anchor positions, chain-growth constant folded into
`q = μ p`. -/
noncomputable def failureBound (N q : ℝ) (m : ℕ) : ℝ := N * ∑' ℓ : ℕ, q ^ (m + ℓ)

/-- Closed form of the chain-counting bound below threshold. -/
theorem failureBound_le {N q : ℝ} (h0 : 0 ≤ q) (h1 : q < 1) (m : ℕ) :
    failureBound N q m = N * q ^ m / (1 - q) := by
  rw [failureBound, tsum_chain_geometric h0 h1 m]
  ring

/-! ## Sharpness of the topological threshold -/

/-- **The topological threshold is sharp.**  With `N > 0` anchor positions, the
chain-counting failure bound `N q ^ m` is suppressed as the code distance grows **iff**
the rescaled error rate `q = μ p` is below `1`.  At `q = 1` the bound is the constant
`N`, and above it, it diverges — there is no intermediate regime. -/
theorem suppression_iff {N q : ℝ} (hN : 0 < N) (h0 : 0 ≤ q) :
    Tendsto (fun m : ℕ => N * q ^ m) atTop (𝓝 0) ↔ q < 1 := by
  constructor
  · intro h
    by_contra hge
    push_neg at hge
    have hlow : ∀ m : ℕ, N ≤ N * q ^ m := fun m => by
      nlinarith [one_le_pow₀ hge (n := m), hN.le]
    have : N ≤ (0 : ℝ) := ge_of_tendsto h (Eventually.of_forall hlow)
    linarith
  · intro h
    have := (tendsto_pow_atTop_nhds_zero_of_lt_one h0 h).const_mul N
    simpa using this

/-- Below threshold the failure bound decays exponentially in the half-distance. -/
theorem failureBound_tendsto_zero {N q : ℝ} (h0 : 0 ≤ q) (h1 : q < 1) :
    Tendsto (fun m : ℕ => failureBound N q m) atTop (𝓝 0) := by
  have h : Tendsto (fun m : ℕ => N * q ^ m / (1 - q)) atTop (𝓝 0) := by
    have := ((tendsto_pow_atTop_nhds_zero_of_lt_one h0 h1).const_mul N).div_const (1 - q)
    simpa using this
  exact h.congr fun m => (failureBound_le h0 h1 m).symm

/-! ## The surface code with depolarizing noise: the `1 %` threshold -/

/-- The chain-growth constant entering the standard combinatorial estimate for the
surface code with depolarizing noise. -/
def surfaceGrowth : ℝ := 100

/-- The resulting accuracy threshold of the surface code: `1 / surfaceGrowth = 1 / 100`,
i.e. one percent. -/
noncomputable def surfaceThreshold : ℝ := 1 / surfaceGrowth

/-- **The one-percent threshold, sharply.**  For the surface code with the chain-growth
constant `μ = 100`, the chain-counting logical-failure bound is suppressed with growing
code distance **exactly** when the physical error rate is below `1 %`. -/
theorem surface_threshold_one_percent {N p : ℝ} (hN : 0 < N) (hp : 0 ≤ p) :
    Tendsto (fun m : ℕ => N * (surfaceGrowth * p) ^ m) atTop (𝓝 0) ↔ p < surfaceThreshold := by
  rw [suppression_iff hN (by rw [surfaceGrowth]; positivity)]
  constructor
  · intro h
    rw [surfaceThreshold, surfaceGrowth] at *
    linarith
  · intro h
    rw [surfaceThreshold, surfaceGrowth] at *
    linarith

/-- Just below threshold (`p = 0.9 %`) the surface-code failure bound is driven to zero
as the distance grows. -/
theorem surface_below_threshold_suppressed :
    Tendsto (fun m : ℕ => failureBound 1 (surfaceGrowth * (9 / 1000)) m) atTop (𝓝 0) :=
  failureBound_tendsto_zero (by norm_num [surfaceGrowth]) (by norm_num [surfaceGrowth])

/-- Just above threshold (`p = 1.1 %`) the bound is not suppressed: it grows without
bound, so the counting argument gives no protection.  This is the negative half of the
sharp transition. -/
theorem surface_above_threshold_not_suppressed :
    ¬ Tendsto (fun m : ℕ => (1 : ℝ) * (surfaceGrowth * (11 / 1000)) ^ m) atTop (𝓝 0) := by
  rw [surface_threshold_one_percent (by norm_num) (by norm_num)]
  norm_num [surfaceThreshold, surfaceGrowth]

/-! ## Distance and qubit overhead -/

/-- If the half-distance `m` is at least `log (ε (1-q) / N) / log q`, the chain-counting
bound is below the target failure probability `ε`. -/
theorem failureBound_le_of_halfDistance {N q ε : ℝ} (hN : 0 < N) (h0 : 0 < q) (h1 : q < 1)
    (heps : 0 < ε) {m : ℕ} (hm : Real.log (ε * (1 - q) / N) / Real.log q ≤ m) :
    failureBound N q m ≤ ε := by
  have hlogq : Real.log q < 0 := Real.log_neg h0 h1
  have hone : (0 : ℝ) < 1 - q := by linarith
  have htarget : (0 : ℝ) < ε * (1 - q) / N := by positivity
  have hstep : (m : ℝ) * Real.log q ≤ Real.log (ε * (1 - q) / N) := by
    nlinarith [hm, hlogq, div_mul_cancel₀ (Real.log (ε * (1 - q) / N)) hlogq.ne]
  have hqm : q ^ m ≤ ε * (1 - q) / N := by
    have hpos : (0 : ℝ) < q ^ m := pow_pos h0 m
    have hlog : Real.log (q ^ m) ≤ Real.log (ε * (1 - q) / N) := by rwa [Real.log_pow]
    exact (Real.log_le_log_iff hpos htarget).1 hlog
  rw [failureBound_le h0.le h1, div_le_iff₀ hone]
  calc N * q ^ m ≤ N * (ε * (1 - q) / N) := by nlinarith [hN, hqm]
  _ = ε * (1 - q) := by field_simp

/-- Physical qubits of a rotated surface code of distance `d = 2 m`. -/
def surfaceQubits (m : ℕ) : ℕ := (2 * m) ^ 2

/-- **Polylogarithmic overhead.**  For any target logical error rate `ε` there is a
surface-code half-distance whose failure bound is below `ε` and which uses at most
`4 (max L 0 + 1)²` physical qubits, where `L = log (ε (1-q)/N) / log q` grows like
`log (1/ε)`.
So `O(log² (1/ε))` physical qubits per logical qubit suffice — the qubit cost of fault
tolerance is polylogarithmic in the target accuracy. -/
theorem surface_qubit_overhead_polylog {N q ε : ℝ} (hN : 0 < N) (h0 : 0 < q) (h1 : q < 1)
    (heps : 0 < ε) :
    ∃ m : ℕ, failureBound N q m ≤ ε ∧
      (surfaceQubits m : ℝ) ≤ 4 * (max (Real.log (ε * (1 - q) / N) / Real.log q) 0 + 1) ^ 2 := by
  set L := Real.log (ε * (1 - q) / N) / Real.log q with hL
  refine ⟨⌈L⌉₊, failureBound_le_of_halfDistance hN h0 h1 heps (Nat.le_ceil L), ?_⟩
  have hm0 : (0 : ℝ) ≤ (⌈L⌉₊ : ℝ) := Nat.cast_nonneg _
  have hub : (⌈L⌉₊ : ℝ) ≤ max L 0 + 1 := by
    rcases lt_or_ge L 0 with hLneg | hLpos
    · have hz : ⌈L⌉₊ = 0 := Nat.ceil_eq_zero.2 hLneg.le
      rw [hz]
      have : max L 0 = 0 := max_eq_right hLneg.le
      rw [this]
      norm_num
    · have : max L 0 = L := max_eq_left hLpos
      rw [this]
      exact (Nat.ceil_lt_add_one hLpos).le
  have hL1 : (0 : ℝ) ≤ max L 0 + 1 := le_trans hm0 hub
  have : (surfaceQubits ⌈L⌉₊ : ℝ) = 4 * (⌈L⌉₊ : ℝ) ^ 2 := by
    simp [surfaceQubits]
    ring
  rw [this]
  nlinarith [hm0, hub, hL1]

/-! ## Synthesis: why the two thresholds must be combined

Eastin–Knill (`Computation.EastinKnillLie`) says the *gates* one gets for free on a code
are only phases; a universal set therefore needs an extra, non-transversal resource, and
the standard one is magic-state distillation, whose recursion has its own threshold
(`Computation.FaultToleranceThreshold`).  The following theorem packages the two halves
of a fault-tolerant architecture that were proved in the two companion files. -/

/-- **The fault-tolerant architecture theorem.**  Simultaneously:

1. no code-preserving detectable (in particular, no transversal) generator implements the
   logical `X̄` gate on a code — continuous transversal symmetry gives only phases
   (Eastin–Knill); and
2. the 15-to-1 magic-state distillation recursion `p ↦ 35 p³`, which supplies the missing
   non-transversal gate, drives an input error rate of `10 %` to zero.

Together: universality is impossible transversally, and the standard replacement
converges, provided one is below the relevant threshold. -/
theorem eastin_knill_forces_distillation :
    (¬ ∃ (A : Matrix (Fin 4) (Fin 4) ℂ) (c t : ℂ),
        EastinKnill.CodePreserving EastinKnill.qubitCode A ∧
        EastinKnill.Detectable EastinKnill.qubitCode A c ∧
        NormedSpace.exp (t • A) * EastinKnill.qubitCode.P
          = EastinKnill.logicalXbar * EastinKnill.qubitCode.P)
    ∧ Tendsto (FaultTolerance.ftIter (Real.sqrt 35) 2 (1 / 10)) atTop (𝓝 0) :=
  ⟨EastinKnill.logicalX_not_transversally_generated,
    FaultTolerance.magic_state_distillation_15to1_converges⟩

end SurfaceCode