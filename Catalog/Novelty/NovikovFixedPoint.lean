import Mathlib

open Filter Topology

/-!
# Novikov-Fixed-Point: Unique Self-Consistent Histories for Causally Loop-Closed Spacetimes

The **Novikov Self-Consistency Principle** asserts that, in a spacetime containing
closed timelike curves (a "causally loop-closed" spacetime, e.g. one with a
traversable wormhole time machine), the *only* physically realisable histories are
those that are globally self-consistent: whatever influence a system exerts on its
own past must be exactly the influence that produced its present. A billiard ball
that travels back in time and strikes its earlier self may only follow a trajectory
that is consistent with having been struck.

Mathematically this is a **fixed-point condition**. Model the relevant boundary /
initial data on the causal loop by a point of a state space `α`, and let
`evolve : α → α` be the map that carries a candidate history once around the loop
(propagate forward, pass through the time machine, and read off the resulting
influence on the initial data). A history is *self-consistent* precisely when it is
a fixed point, `evolve x = x`.

We formalise the principle in the regime where the round-trip map is a
**contraction** (`rate < 1`): the loop damps discrepancies rather than amplifying
them. On a nonempty complete state space this is exactly the hypothesis of the
Banach fixed-point theorem, so a self-consistent history

* **exists**,
* is **unique**, and
* is the **limit of the naive relaxation iteration** `evolveⁿ x₀` from *any*
  starting guess `x₀` — the physical picture of "the timeline settling down".

## Main results

* `NovikovFixedPoint.CausalLoop.existsUnique` — existence and uniqueness of a
  self-consistent history (the Novikov principle as a theorem).
* `NovikovFixedPoint.CausalLoop.iterate_tendsto` — relaxation to self-consistency
  from an arbitrary initial guess.
* `NovikovFixedPoint.CausalLoop.dist_history_le` — an a-priori bound on how far any
  candidate lies from the self-consistent history (the *consistency defect*).
* `NovikovFixedPoint.stability` — a perturbation bound: the self-consistent history
  depends Lipschitz-continuously on the physics of the loop, so a small change of
  the round-trip law moves the timeline only a little.
* `NovikovFixedPoint.affineLoop` and `NovikovFixedPoint.affineLoop_history` — the
  textbook billiard-through-a-wormhole model `evolve x = a·x + b` with `|a| < 1`:
  its unique self-consistent value is exactly `b / (1 - a)`.
-/

namespace NovikovFixedPoint

variable {α : Type*} [MetricSpace α]

/-- A **causal loop** on a state space `α`: the round-trip self-consistency map
`evolve`, together with a contraction `rate < 1` witnessing that the loop damps
discrepancies. -/
structure CausalLoop (α : Type*) [MetricSpace α] where
  /-- The map carrying a candidate history once around the causal loop. -/
  evolve : α → α
  /-- The contraction rate of the round trip. -/
  rate : NNReal
  /-- The round-trip map is a contraction: it strictly shrinks distances. -/
  isContracting : ContractingWith rate evolve

variable [Nonempty α] [CompleteSpace α]

/-- The unique self-consistent history of the loop — the Novikov solution. -/
noncomputable def CausalLoop.history (L : CausalLoop α) : α :=
  ContractingWith.fixedPoint L.evolve L.isContracting

/-- The self-consistent history is a fixed point of the round-trip map. -/
theorem CausalLoop.history_isFixedPt (L : CausalLoop α) :
    Function.IsFixedPt L.evolve L.history :=
  ContractingWith.fixedPoint_isFixedPt L.isContracting

/-- **Self-consistency.** Carrying the Novikov history once around the loop
reproduces it exactly. -/
theorem CausalLoop.selfConsistent (L : CausalLoop α) :
    L.evolve L.history = L.history :=
  L.history_isFixedPt

/-- Any self-consistent history equals the Novikov history: uniqueness. -/
theorem CausalLoop.history_unique (L : CausalLoop α) {x : α}
    (hx : L.evolve x = x) : x = L.history :=
  ContractingWith.fixedPoint_unique L.isContracting hx

/-- **Novikov Self-Consistency Principle.** A causally loop-closed spacetime whose
round-trip map is a contraction admits one and only one self-consistent history. -/
theorem CausalLoop.existsUnique (L : CausalLoop α) :
    ∃! x : α, L.evolve x = x := by
  refine ⟨L.history, L.selfConsistent, ?_⟩
  intro y hy
  exact L.history_unique hy

/-- **Relaxation to self-consistency.** Iterating the round-trip map on *any*
initial guess converges to the unique self-consistent history: the timeline settles
down regardless of where the bookkeeping starts. -/
theorem CausalLoop.iterate_tendsto (L : CausalLoop α) (x : α) :
    Tendsto (fun n => L.evolve^[n] x) atTop (𝓝 L.history) :=
  ContractingWith.tendsto_iterate_fixedPoint L.isContracting x

/-- **A-priori consistency bound.** The distance from any candidate history `x` to
the self-consistent history is controlled by its one-step *consistency defect*
`dist x (evolve x)` divided by `1 - rate`. -/
theorem CausalLoop.dist_history_le (L : CausalLoop α) (x : α) :
    dist x L.history ≤ dist x (L.evolve x) / (1 - L.rate) :=
  ContractingWith.dist_fixedPoint_le L.isContracting x

/-- **Structural stability of the timeline.** If the round-trip law is perturbed,
the self-consistent history moves by no more than the perturbation's effect on the
*unperturbed* history, divided by `1 - rate`. Concretely, the Novikov solution of
`L₁` is close to that of `L₂` whenever `L₁`'s law nearly fixes `L₂`'s history. This
is the sense in which a self-consistent timeline depends continuously on the physics
of the causal loop. -/
theorem stability (L₁ L₂ : CausalLoop α) :
    dist L₁.history L₂.history
      ≤ dist (L₁.evolve L₂.history) L₂.history / (1 - L₁.rate) := by
  have h := L₁.isContracting.dist_inequality L₁.history L₂.history
  rw [L₁.selfConsistent] at h
  simp only [dist_self, zero_add] at h
  calc dist L₁.history L₂.history
      ≤ dist L₂.history (L₁.evolve L₂.history) / (1 - L₁.rate) := h
    _ = dist (L₁.evolve L₂.history) L₂.history / (1 - L₁.rate) := by rw [dist_comm]

/-!
## The billiard-through-a-wormhole model

The canonical thought experiment behind the Novikov principle is a billiard ball
that enters a wormhole time machine, emerges in its own past, and deflects its
earlier self. Linearising the deflection law about a nominal trajectory gives an
affine round-trip map `evolve x = a·x + b` on the real line, where `x` records the
relevant one-dimensional datum (an impact parameter, say). The loop is damping
exactly when `|a| < 1`, and the Novikov principle then predicts a single consistent
value. We verify that this value is `b / (1 - a)`.
-/

/-- The affine billiard-through-a-wormhole causal loop `x ↦ a·x + b` on `ℝ`, damping
whenever `|a| < 1`. -/
noncomputable def affineLoop (a b : ℝ) (ha : |a| < 1) : CausalLoop ℝ where
  evolve := fun x => a * x + b
  rate := Real.toNNReal |a|
  isContracting := by
    constructor
    · rw [show (1 : NNReal) = Real.toNNReal 1 by simp,
        Real.toNNReal_lt_toNNReal_iff (by norm_num)]
      exact ha
    · rw [lipschitzWith_iff_dist_le_mul]
      intro x y
      rw [Real.dist_eq, Real.dist_eq, Real.coe_toNNReal _ (abs_nonneg a),
        show (a * x + b) - (a * y + b) = a * (x - y) by ring, abs_mul]

/-- **The self-consistent billiard trajectory.** The unique Novikov history of the
affine loop `x ↦ a·x + b` is `b / (1 - a)`. -/
theorem affineLoop_history (a b : ℝ) (ha : |a| < 1) :
    (affineLoop a b ha).history = b / (1 - a) := by
  have h1 : a < 1 := (abs_lt.mp ha).2
  have hne : (1 - a) ≠ 0 := by linarith
  symm
  apply CausalLoop.history_unique
  show a * (b / (1 - a)) + b = b / (1 - a)
  field_simp
  ring

end NovikovFixedPoint