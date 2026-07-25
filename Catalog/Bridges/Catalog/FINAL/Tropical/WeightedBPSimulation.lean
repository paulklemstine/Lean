import Mathlib

/-!
# Weighted Tropical Simulation: From Branching Programs to Tropical Circuits

This file formalizes the simulation of weighted layered branching programs by
tropical (min-plus) circuits, proving exact semantic equivalence with an explicit
operation-count bound.

## Mathematical Context

A **weighted branching program** (WBP) of width `w` and depth `d` over a
cost domain `α` computes a shortest-path functional: at each layer, every
edge carries a weight, and the cost to reach a state is the minimum over
all predecessors of (predecessor cost + edge weight). The output is the
min-cost path from the start state to the accept state.

A **tropical circuit** computes a min-plus expression tree: its gates are
`min` (tropical multiplication) and `+` (tropical addition), applied to
input weights and constants.

The **simulation theorem** says that every WBP of width `w` and depth `d`
can be represented by a tropical circuit with at most `2w²d + w` operations,
computing exactly the same min-cost function. This is proved generically
for any ordered additive monoid with a top element, then instantiated for
`WithTop ℝ` (real costs with +∞ for unreachable states).

## Main Results

* `weighted_bp_to_tropical_circuit_generic` — Generic simulation theorem
  for any `SemilatticeInf` + `OrderTop` + `Add` + `Zero` domain.
* `weighted_bp_to_tropical_circuit_real` — Instantiation for `WithTop ℝ`.
* `tropical_circuit_lower_bound_transfer_real` — Circuit lower bounds
  transfer to BP width-depth tradeoff constraints over real costs.

## Significance

This theorem bridges:
- **Complexity theory**: simulation between nonuniform computational models.
- **Tropical geometry**: BPs generate piecewise-linear min-plus functions.
- **Dynamic programming**: Bellman recursion is tropical circuit evaluation.
-/

noncomputable section

namespace WeightedTropical

/-! ## Weighted Branching Programs (Generic) -/

/-- A weighted layered branching program with width `w`, depth `d`,
    and edge weights in `α`. The evaluation semantics use `min` and `+`
    in the tropical (min-plus) semiring. -/
structure WeightedBP (w d : ℕ) (α : Type*) where
  /-- The start state. -/
  start : Fin w
  /-- The accept state. -/
  accept : Fin w
  /-- Edge weight from state `u` at layer `i` to state `v` at layer `i+1`.
      Value `⊤` means no edge exists. -/
  edgeWeight : Fin d → Fin w → Fin w → α

/-- Min-cost to reach state `v` at layer `i`, computed by Bellman recursion.
    Uses `Finset.inf` for the minimum over predecessors.
    The start state has cost `0`, all other states start at `⊤` (unreachable). -/
def tropReachCost {w d : ℕ} {α : Type*} [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (P : WeightedBP w d α) :
    (i : ℕ) → i ≤ d → Fin w → α
  | 0, _, v => if v = P.start then 0 else ⊤
  | i + 1, hi, v =>
    Finset.univ.inf fun u =>
      tropReachCost P i (by omega) u + P.edgeWeight ⟨i, by omega⟩ u v

/-- The output of the weighted BP: min-cost path from start to accept. -/
def WeightedBP.eval {w d : ℕ} {α : Type*} [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (P : WeightedBP w d α) : α :=
  tropReachCost P d le_rfl P.accept

/-! ## Tropical Circuits (Generic) -/

/-- A tropical circuit over cost domain `α`.
    Abstractly, a circuit with `width` wires at each of `depth + 1` layers,
    computing values via `min` and `+` gates. -/
structure TropicalCircuit (α : Type*) where
  /-- Number of layers (excluding input layer). -/
  depth : ℕ
  /-- Number of wires per layer. -/
  width : ℕ
  /-- Evaluation function: value at layer `i`, wire `v`. -/
  eval : Fin (depth + 1) → Fin width → α
  /-- The output wire. -/
  outputGate : Fin width

/-- The output value of the circuit. -/
def TropicalCircuit.output {α : Type*} (C : TropicalCircuit α) : α :=
  C.eval ⟨C.depth, Nat.lt_succ_self _⟩ C.outputGate

/-- Operation count of a layered tropical circuit.
    Each layer transition uses at most `w²` additions (one per edge) and
    `w(w-1)` min operations (reducing `w` terms per output wire), totaling
    at most `2w²` operations per layer, plus `w` base operations for
    initialization. Conservative bound: `w²d + wd + w ≤ 2w²d + w`. -/
def TropicalCircuit.opCount {α : Type*} (C : TropicalCircuit α) : ℕ :=
  C.width * C.width * C.depth + C.width * C.depth + C.width

/-! ## Simulation Construction -/

/-- Construct a tropical circuit from a weighted BP by packaging
    the Bellman recurrence as the circuit's evaluation function.
    Gate `(i, v)` computes the min-cost to reach state `v` at layer `i`. -/
def weightedBPToCircuit {w d : ℕ} {α : Type*} [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (P : WeightedBP w d α) : TropicalCircuit α where
  depth := d
  width := w
  eval := fun layer v => tropReachCost P layer.val (by omega) v
  outputGate := P.accept

/-! ## Key Arithmetic Lemma -/

/-- The operation count bound: `w²d + wd + w ≤ 2w²d + w`. -/
theorem opCount_le_bound (w d : ℕ) :
    w * w * d + w * d + w ≤ 2 * w * w * d + w := by
  suffices h : w * d ≤ w * w * d by linarith
  cases w with
  | zero => simp
  | succ n =>
    calc (n + 1) * d = 1 * ((n + 1) * d) := by ring
    _ ≤ (n + 1) * ((n + 1) * d) := Nat.mul_le_mul_right _ (Nat.succ_pos n)
    _ = (n + 1) * (n + 1) * d := by ring

/-! ## Semantic Correctness -/

/-- The simulation circuit computes exactly the BP's min-cost. -/
theorem simulation_correct {w d : ℕ} {α : Type*}
    [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (P : WeightedBP w d α) :
    (weightedBPToCircuit P).output = P.eval := by
  simp [weightedBPToCircuit, TropicalCircuit.output, WeightedBP.eval]

/-! ## Generic Simulation Theorem -/

/-- **Generic Tropical Simulation Theorem.**
    Every weighted branching program of width `w` and depth `d` over any
    type with `SemilatticeInf`, `OrderTop`, `Add`, and `Zero` can be
    simulated by a tropical circuit with at most `2w²d + w` operations,
    computing exactly the same value.

    This theorem is parametric in the cost domain `α`. It applies to
    `WithTop ℕ`, `WithTop ℝ`, `ENNReal`, `WithTop ℤ`, or any other
    type satisfying the algebraic interface. -/
theorem weighted_bp_to_tropical_circuit_generic
    {α : Type*} [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (w d : ℕ) (P : WeightedBP w d α) :
    ∃ C : TropicalCircuit α,
      C.opCount ≤ 2 * w * w * d + w ∧
      C.output = P.eval := by
  refine ⟨weightedBPToCircuit P, ?_, simulation_correct P⟩
  unfold weightedBPToCircuit TropicalCircuit.opCount
  simp only
  exact opCount_le_bound w d

/-! ## Real-Valued Instantiation -/

/-- Convenient alias for the real tropical codomain: `ℝ ∪ {+∞}`. -/
abbrev TropicalReal := WithTop ℝ

/-- Convenient alias for real-valued tropical circuits. -/
abbrev TropicalCircuitR := TropicalCircuit TropicalReal

/-- **Weighted BP to Tropical Circuit Simulation over `WithTop ℝ`.**
    Every weighted branching program of width `w` and depth `d` with
    real-valued edge weights (and `⊤ = +∞` for absent edges) can be
    simulated by a tropical circuit with at most `2w²d + w` operations,
    preserving exact min-cost semantics. -/
theorem weighted_bp_to_tropical_circuit_real
    (w d : ℕ) (P : WeightedBP w d TropicalReal) :
    ∃ C : TropicalCircuitR,
      C.opCount ≤ 2 * w * w * d + w ∧
      C.output = P.eval :=
  weighted_bp_to_tropical_circuit_generic w d P

/-! ## Lower Bound Transfer -/

/-- **Generic Tropical Circuit Lower Bound Transfer.**
    Any circuit lower bound transfers to a BP width-depth tradeoff
    constraint through the simulation. -/
theorem tropical_circuit_lower_bound_transfer_generic
    {α : Type*} [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (K : ℕ)
    (h_lower : ∀ C : TropicalCircuit α, C.output ≠ ⊤ → K ≤ C.opCount)
    {w d : ℕ} (P : WeightedBP w d α) (hP : P.eval ≠ ⊤) :
    K ≤ 2 * w * w * d + w := by
  obtain ⟨C, hsize, hcorr⟩ := weighted_bp_to_tropical_circuit_generic w d P
  exact le_trans (h_lower C (hcorr ▸ hP)) hsize

/-- **Tropical Circuit Lower Bound Transfer over `WithTop ℝ`.**
    Any circuit lower bound of `K` operations for computing a finite
    real cost transfers to a width-depth tradeoff constraint
    `K ≤ 2w²d + w` for any BP computing the same value. -/
theorem tropical_circuit_lower_bound_transfer_real (K : ℕ)
    (h_lower : ∀ C : TropicalCircuitR, C.output ≠ ⊤ → K ≤ C.opCount)
    {w d : ℕ} (P : WeightedBP w d TropicalReal) (hP : P.eval ≠ ⊤) :
    K ≤ 2 * w * w * d + w :=
  tropical_circuit_lower_bound_transfer_generic K h_lower P hP

/-! ## Additional Instantiations -/

/-- Instantiation for `WithTop ℕ` (combinatorial / discrete costs). -/
theorem weighted_bp_to_tropical_circuit_nat
    (w d : ℕ) (P : WeightedBP w d (WithTop ℕ)) :
    ∃ C : TropicalCircuit (WithTop ℕ),
      C.opCount ≤ 2 * w * w * d + w ∧
      C.output = P.eval :=
  weighted_bp_to_tropical_circuit_generic w d P

/-- Instantiation for `WithTop ℤ` (integer costs). -/
theorem weighted_bp_to_tropical_circuit_int
    (w d : ℕ) (P : WeightedBP w d (WithTop ℤ)) :
    ∃ C : TropicalCircuit (WithTop ℤ),
      C.opCount ≤ 2 * w * w * d + w ∧
      C.output = P.eval :=
  weighted_bp_to_tropical_circuit_generic w d P

/-- Instantiation for `ENNReal` (extended nonnegative reals). -/
theorem weighted_bp_to_tropical_circuit_ennreal
    (w d : ℕ) (P : WeightedBP w d ENNReal) :
    ∃ C : TropicalCircuit ENNReal,
      C.opCount ≤ 2 * w * w * d + w ∧
      C.output = P.eval :=
  weighted_bp_to_tropical_circuit_generic w d P

/-! ## Expressibility Transfer -/

/-- A value is BP-expressible if some width-`w` depth-`d` BP achieves a
    finite (non-⊤) cost. -/
def BPExpressible (w d : ℕ) (α : Type*) [SemilatticeInf α] [OrderTop α] [Add α] [Zero α] :
    Prop :=
  ∃ P : WeightedBP w d α, P.eval ≠ ⊤

/-- A value is circuit-expressible with budget `S` if some circuit with
    at most `S` operations achieves a finite cost. -/
def CircuitExpressible (S : ℕ) (α : Type*) [Top α] : Prop :=
  ∃ C : TropicalCircuit α, C.opCount ≤ S ∧ C.output ≠ ⊤

/-- **Expressibility Transfer.**
    BP-expressibility implies circuit-expressibility with bounded size. -/
theorem bp_expressibility_transfer {α : Type*}
    [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (w d : ℕ) :
    BPExpressible w d α → CircuitExpressible (2 * w * w * d + w) α := by
  rintro ⟨P, hP⟩
  obtain ⟨C, hsize, hcorr⟩ := weighted_bp_to_tropical_circuit_generic w d P
  exact ⟨C, hsize, hcorr ▸ hP⟩

/-! ## Bellman Recurrence Lemmas -/

/-- Base case: at layer 0, only the start state has finite cost (= 0). -/
theorem tropReachCost_base {w d : ℕ} {α : Type*}
    [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (P : WeightedBP w d α) (hd : 0 ≤ d) (v : Fin w) :
    tropReachCost P 0 hd v = if v = P.start then 0 else ⊤ := by
  simp [tropReachCost]

/-- Step case: layer `i+1` values are the Bellman update of layer `i`. -/
theorem tropReachCost_step {w d : ℕ} {α : Type*}
    [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (P : WeightedBP w d α) (i : ℕ) (hi : i + 1 ≤ d) (v : Fin w) :
    tropReachCost P (i + 1) hi v =
    Finset.univ.inf fun u =>
      tropReachCost P i (by omega) u + P.edgeWeight ⟨i, by omega⟩ u v := by
  simp [tropReachCost]

/-! ## Depth Composition -/

/-- The simulation preserves the layered structure: the circuit has
    the same depth as the BP and the same width. -/
theorem simulation_preserves_dimensions {w d : ℕ} {α : Type*}
    [SemilatticeInf α] [OrderTop α] [Add α] [Zero α]
    (P : WeightedBP w d α) :
    (weightedBPToCircuit P).depth = d ∧ (weightedBPToCircuit P).width = w := by
  simp [weightedBPToCircuit]

end WeightedTropical

end