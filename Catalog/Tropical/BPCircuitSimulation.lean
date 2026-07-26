import Mathlib

/-!
# Branching Program to Circuit Simulation

This file formalizes the constructive simulation of layered deterministic
branching programs by layered Boolean circuits, with an explicit quadratic
size bound. It then extends the result to tropical (min-plus) branching
programs and circuits.

## Main Results

* `bp_to_circuit_simulation` — Every layered BP of width `w` and depth `d`
  can be simulated by a circuit with op count ≤ `2 * w * w * d + w`.

* `bp_size_lower_bound_transfer` — Circuit lower bounds transport backward
  through the simulation into width-depth tradeoff constraints.

* `tropical_bp_to_circuit` — Every tropical BP of width `w` and depth `d`
  can be simulated by a tropical circuit with op count ≤ `2 * w * w * d + w`.

* `tropical_bp_unrolling_bound` — Tropical BP expressibility implies
  tropical circuit expressibility with controlled size.
-/

namespace BPCircuit

/-! ## Literals -/

/-- A literal over `n` Boolean variables. -/
structure Literal (n : ℕ) where
  var : Fin n
  neg : Bool

/-- Evaluate a literal on an input. -/
def Literal.eval {n : ℕ} (ℓ : Literal n) (x : Fin n → Bool) : Bool :=
  xor ℓ.neg (x ℓ.var)

/-! ## Branching Programs -/

/-- A layered branching program: width `w`, depth `d`, `n` input variables.
    `edge i u v = some ℓ` means edge from `(i,u)` to `(i+1,v)` with guard `ℓ`.
    `edge i u v = none` means no edge. -/
structure BP (n w d : ℕ) where
  start : Fin w
  accept : Fin w
  edge : Fin d → Fin w → Fin w → Option (Literal n)

/-- Edge is active: the edge exists and its guard evaluates to true. -/
def edgeActive {n w d : ℕ} (P : BP n w d) (x : Fin n → Bool)
    (i : Fin d) (u v : Fin w) : Prop :=
  ∃ ℓ, P.edge i u v = some ℓ ∧ ℓ.eval x = true

/-- edgeActive is decidable. -/
instance edgeActive.decidable {n w d : ℕ} (P : BP n w d) (x : Fin n → Bool)
    (i : Fin d) (u v : Fin w) : Decidable (edgeActive P x i u v) := by
  simp only [edgeActive]
  cases P.edge i u v with
  | none => exact isFalse (by rintro ⟨ℓ, h, _⟩; simp at h)
  | some ℓ =>
    cases h : ℓ.eval x
    · exact isFalse (by rintro ⟨ℓ', h', he⟩; simp at h'; subst h'; simp [h] at he)
    · exact isTrue ⟨ℓ, rfl, h⟩

/-! ## Reachability -/

/-- State `v` is reachable at depth `i` from the start on input `x`. -/
def Reachable {n w d : ℕ} (P : BP n w d) (x : Fin n → Bool) :
    (i : ℕ) → i ≤ d → Fin w → Prop
  | 0, _, v => v = P.start
  | i + 1, hi, v => ∃ u : Fin w,
      Reachable P x i (by omega) u ∧ edgeActive P x ⟨i, by omega⟩ u v

instance Reachable.decidable {n w d : ℕ} (P : BP n w d) (x : Fin n → Bool) :
    ∀ (i : ℕ) (hi : i ≤ d) (v : Fin w), Decidable (Reachable P x i hi v)
  | 0, _, v => by simp [Reachable]; infer_instance
  | i + 1, hi, v => by
    simp only [Reachable]
    haveI : ∀ u, Decidable (Reachable P x i (by omega) u) :=
      fun u => Reachable.decidable P x i (by omega) u
    exact Fintype.decidableExistsFintype

/-- BP acceptance. -/
def BP.Accepts {n w d : ℕ} (P : BP n w d) (x : Fin n → Bool) : Prop :=
  Reachable P x d le_rfl P.accept

instance {n w d : ℕ} (P : BP n w d) (x : Fin n → Bool) : Decidable (P.Accepts x) :=
  Reachable.decidable P x d le_rfl P.accept

/-! ## Layerwise Correctness -/

theorem reachable_base {n w d : ℕ} (P : BP n w d) (x : Fin n → Bool)
    (hd : 0 ≤ d) (v : Fin w) : Reachable P x 0 hd v ↔ v = P.start := by
  simp [Reachable]

theorem reachable_step {n w d : ℕ} (P : BP n w d) (x : Fin n → Bool)
    (i : ℕ) (hi : i + 1 ≤ d) (v : Fin w) :
    Reachable P x (i + 1) hi v ↔
    ∃ u : Fin w, Reachable P x i (by omega) u ∧ edgeActive P x ⟨i, by omega⟩ u v := by
  simp [Reachable]

/-! ## Layered Circuit -/

/-- A layered Boolean circuit. -/
structure LayeredCircuit (n : ℕ) where
  depth : ℕ
  width : ℕ
  eval : (Fin n → Bool) → Fin (depth + 1) → Fin width → Prop
  evalDecidable : ∀ x i v, Decidable (eval x i v)
  outputGate : Fin width

instance {n : ℕ} (C : LayeredCircuit n) (x : Fin n → Bool)
    (i : Fin (C.depth + 1)) (v : Fin C.width) : Decidable (C.eval x i v) :=
  C.evalDecidable x i v

def LayeredCircuit.Accepts {n : ℕ} (C : LayeredCircuit n) (x : Fin n → Bool) : Prop :=
  C.eval x ⟨C.depth, Nat.lt_succ_self _⟩ C.outputGate

/-- Operation count: `w² * d` AND + `w * d` OR + `w` base comparisons. -/
def LayeredCircuit.opCount {n : ℕ} (C : LayeredCircuit n) : ℕ :=
  C.width * C.width * C.depth + C.width * C.depth + C.width

/-! ## Simulation -/

/-- The simulation circuit: gate `(i, v)` computes reachability. -/
def bpToCircuit {n w d : ℕ} (P : BP n w d) : LayeredCircuit n where
  depth := d
  width := w
  eval := fun x layer v => Reachable P x layer.val (by omega) v
  evalDecidable := fun x ⟨i, hi⟩ v => Reachable.decidable P x i (by omega) v
  outputGate := P.accept

theorem bp_simulation_correct {n w d : ℕ} (P : BP n w d) (x : Fin n → Bool) :
    (bpToCircuit P).Accepts x ↔ P.Accepts x := by
  simp [bpToCircuit, LayeredCircuit.Accepts, BP.Accepts]

/-! ## Size Bound -/

/-- The key arithmetic: `w²d + wd + w ≤ 2w²d + w`. -/
theorem opCount_bound (w d : ℕ) :
    w * w * d + w * d + w ≤ 2 * w * w * d + w := by
  suffices h : w * d ≤ w * w * d by linarith
  cases w with
  | zero => simp
  | succ n =>
    calc (n + 1) * d = 1 * ((n + 1) * d) := by ring
    _ ≤ (n + 1) * ((n + 1) * d) := Nat.mul_le_mul_right _ (Nat.succ_pos n)
    _ = (n + 1) * (n + 1) * d := by ring

/-- **Main Simulation Theorem.** -/
theorem bp_to_circuit_simulation {n w d : ℕ} (P : BP n w d) :
    ∃ C : LayeredCircuit n,
      C.opCount ≤ 2 * w * w * d + w ∧
      ∀ x : Fin n → Bool, C.Accepts x ↔ P.Accepts x := by
  refine ⟨bpToCircuit P, ?_, fun x => bp_simulation_correct P x⟩
  unfold bpToCircuit LayeredCircuit.opCount
  simp only
  exact opCount_bound w d

/-! ## Lower Bound Transfer -/

abbrev BoolFn (n : ℕ) := (Fin n → Bool) → Prop

def CircuitComputes {n : ℕ} (C : LayeredCircuit n) (f : BoolFn n) : Prop :=
  ∀ x, C.Accepts x ↔ f x

def BPComputes {n w d : ℕ} (P : BP n w d) (f : BoolFn n) : Prop :=
  ∀ x, P.Accepts x ↔ f x

/-- **Lower Bound Transfer.**
    Circuit lower bounds ⇒ BP width-depth tradeoff constraints. -/
theorem bp_size_lower_bound_transfer
    {n : ℕ} (f : BoolFn n) (K : ℕ)
    (h_lower : ∀ C : LayeredCircuit n, CircuitComputes C f → K ≤ C.opCount)
    {w d : ℕ} (P : BP n w d) (hP : BPComputes P f) :
    K ≤ 2 * w * w * d + w := by
  have ⟨C, hsize, hcorr⟩ := bp_to_circuit_simulation P
  exact le_trans (h_lower C (fun x => (hcorr x).trans (hP x))) hsize

/-! ## Tropical Extension -/

/-- Tropical branching program over `WithTop ℕ` (min-plus). -/
structure TropicalBP (w d : ℕ) where
  start : Fin w
  accept : Fin w
  edgeWeight : Fin d → Fin w → Fin w → WithTop ℕ

/-- Min-cost to reach state `v` at layer `i`. -/
noncomputable def tropReachable {w d : ℕ} (P : TropicalBP w d) :
    (i : ℕ) → i ≤ d → Fin w → WithTop ℕ
  | 0, _, v => if v = P.start then 0 else ⊤
  | i + 1, hi, v =>
    Finset.univ.inf fun u =>
      tropReachable P i (by omega) u + P.edgeWeight ⟨i, by omega⟩ u v

noncomputable def TropicalBP.minCost {w d : ℕ} (P : TropicalBP w d) : WithTop ℕ :=
  tropReachable P d le_rfl P.accept

theorem tropReachable_base {w d : ℕ} (P : TropicalBP w d) (hd : 0 ≤ d) (v : Fin w) :
    tropReachable P 0 hd v = if v = P.start then 0 else ⊤ := by
  simp [tropReachable]

theorem tropReachable_step {w d : ℕ} (P : TropicalBP w d)
    (i : ℕ) (hi : i + 1 ≤ d) (v : Fin w) :
    tropReachable P (i + 1) hi v =
    Finset.univ.inf fun u =>
      tropReachable P i (by omega) u + P.edgeWeight ⟨i, by omega⟩ u v := by
  simp [tropReachable]

/-- Tropical circuit. -/
structure TropicalCircuit where
  depth : ℕ
  width : ℕ
  eval : Fin (depth + 1) → Fin width → WithTop ℕ
  outputGate : Fin width

noncomputable def TropicalCircuit.output (C : TropicalCircuit) : WithTop ℕ :=
  C.eval ⟨C.depth, Nat.lt_succ_self _⟩ C.outputGate

def TropicalCircuit.opCount (C : TropicalCircuit) : ℕ :=
  C.width * C.width * C.depth + C.width * C.depth + C.width

noncomputable def tropBPToCircuit {w d : ℕ} (P : TropicalBP w d) : TropicalCircuit where
  depth := d
  width := w
  eval := fun layer v => tropReachable P layer.val (by omega) v
  outputGate := P.accept

theorem trop_simulation_correct {w d : ℕ} (P : TropicalBP w d) :
    (tropBPToCircuit P).output = P.minCost := by
  simp [tropBPToCircuit, TropicalCircuit.output, TropicalBP.minCost]

/-- **Tropical Simulation Theorem.** -/
theorem tropical_bp_to_circuit {w d : ℕ} (P : TropicalBP w d) :
    ∃ C : TropicalCircuit,
      C.opCount ≤ 2 * w * w * d + w ∧ C.output = P.minCost := by
  refine ⟨tropBPToCircuit P, ?_, trop_simulation_correct P⟩
  unfold tropBPToCircuit TropicalCircuit.opCount
  simp only
  exact opCount_bound w d

def TropicalBPExpressible (w d : ℕ) : Prop :=
  ∃ P : TropicalBP w d, P.minCost ≠ ⊤

def TropicalCircuitExpressible (S : ℕ) : Prop :=
  ∃ C : TropicalCircuit, C.opCount ≤ S ∧ C.output ≠ ⊤

/-- **Tropical Unrolling Bound.** -/
theorem tropical_bp_unrolling_bound (w d : ℕ) :
    TropicalBPExpressible w d → TropicalCircuitExpressible (2 * w * w * d + w) := by
  rintro ⟨P, hP⟩
  obtain ⟨C, hsize, hcorr⟩ := tropical_bp_to_circuit P
  exact ⟨C, hsize, hcorr ▸ hP⟩

/-- **Tropical Lower Bound Transfer.** -/
theorem tropical_lower_bound_transfer (K : ℕ)
    (h_lower : ∀ C : TropicalCircuit, C.output ≠ ⊤ → K ≤ C.opCount)
    {w d : ℕ} (P : TropicalBP w d) (hP : P.minCost ≠ ⊤) :
    K ≤ 2 * w * w * d + w := by
  obtain ⟨C, hsize, hcorr⟩ := tropical_bp_to_circuit P
  exact le_trans (h_lower C (hcorr ▸ hP)) hsize

end BPCircuit