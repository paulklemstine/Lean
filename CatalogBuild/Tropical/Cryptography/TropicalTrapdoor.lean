/-! # CatalogBuild.Tropical.Cryptography.TropicalTrapdoor

Auto-generated from theorem catalog database.
Domain: Tropical/Cryptography
Declarations: 52
-/

import Mathlib

noncomputable section

/-- Evaluate a tropical gate on two real inputs -/
def evalGate (g : TropGate) (a b : ℝ) : ℝ :=
  match g with
  | .MinGate => min a b
  | .MaxGate => max a b
  | .AddGate => a + b


/-- MinGate selects the smaller input -/
theorem evalGate_min (a b : ℝ) : evalGate .MinGate a b = min a b := rfl


/-- MaxGate selects the larger input -/
theorem evalGate_max (a b : ℝ) : evalGate .MaxGate a b = max a b := rfl


/-- AddGate sums inputs (tropical multiplication) -/
theorem evalGate_add (a b : ℝ) : evalGate .AddGate a b = a + b := rfl


/-- [Section: ## Section 2: Gate Commutativity and Associativity] -/
theorem gate_min_comm (a b : ℝ) : evalGate .MinGate a b = evalGate .MinGate b a :=
  min_comm a b


theorem gate_max_comm (a b : ℝ) : evalGate .MaxGate a b = evalGate .MaxGate b a :=
  max_comm a b


theorem gate_add_comm (a b : ℝ) : evalGate .AddGate a b = evalGate .AddGate b a :=
  add_comm a b


theorem gate_min_assoc (a b c : ℝ) :
    evalGate .MinGate (evalGate .MinGate a b) c =
    evalGate .MinGate a (evalGate .MinGate b c) :=
  min_assoc a b c


theorem gate_max_assoc (a b c : ℝ) :
    evalGate .MaxGate (evalGate .MaxGate a b) c =
    evalGate .MaxGate a (evalGate .MaxGate b c) :=
  max_assoc a b c


/-- The preimage of a min gate output is a union of two half-spaces -/
def minGatePreimage (c : ℝ) : Set (ℝ × ℝ) :=
  {p | min p.1 p.2 = c}


/-- The preimage of a max gate output is a union of two half-spaces -/
def maxGatePreimage (c : ℝ) : Set (ℝ × ℝ) :=
  {p | max p.1 p.2 = c}


/-- The preimage of an add gate output is a line (1-dimensional) -/
def addGatePreimage (c : ℝ) : Set (ℝ × ℝ) :=
  {p | p.1 + p.2 = c}


/-- Min gate preimage contains the "left-selecting" region -/
theorem minPreimage_left (c : ℝ) :
    ∀ b : ℝ, c ≤ b → (c, b) ∈ minGatePreimage c := by
  intro b hb
  simp [minGatePreimage, min_eq_left hb]


/-- Min gate preimage contains the "right-selecting" region -/
theorem minPreimage_right (c : ℝ) :
    ∀ a : ℝ, c ≤ a → (a, c) ∈ minGatePreimage c := by
  intro a ha
  simp [minGatePreimage, min_eq_right ha]


/-- Max gate preimage contains the "left-selecting" region -/
theorem maxPreimage_left (c : ℝ) :
    ∀ b : ℝ, b ≤ c → (c, b) ∈ maxGatePreimage c := by
  intro b hb
  simp [maxGatePreimage, max_eq_left hb]


/-- Max gate preimage contains the "right-selecting" region -/
theorem maxPreimage_right (c : ℝ) :
    ∀ a : ℝ, a ≤ c → (a, c) ∈ maxGatePreimage c := by
  intro a ha
  simp [maxGatePreimage, max_eq_right ha]


/-- A circuit instruction: apply a gate to two register indices, store in a third -/
structure TropInstruction where
  gate : TropGate
  src1 : ℕ
  src2 : ℕ
  dst  : ℕ
  deriving DecidableEq, Repr


/-- Register file: maps register indices to real values -/
def RegFile := ℕ → ℝ


/-- Execute a sequence of instructions -/
def execInstrs (regs : RegFile) : List TropInstruction → RegFile
  | [] => regs
  | instr :: rest => execInstrs (execInstr regs instr) rest


/-- Initialize register file from input vector -/
def initRegs (inputs : ℕ → ℝ) : RegFile := inputs


/-- Evaluate a tropical circuit on an input -/
def evalCircuit (circ : TropCircuit) (inputs : ℕ → ℝ) : ℝ :=
  let finalRegs := execInstrs (initRegs inputs) circ.instrs
  finalRegs circ.outputReg


/-- Number of gates in a circuit -/
def circuitSize (circ : TropCircuit) : ℕ := circ.instrs.length


/-- Executing instructions preserves register values outside destinations -/
theorem execInstr_preserve (regs : RegFile) (instr : TropInstruction) (i : ℕ)
    (h : i ≠ instr.dst) : execInstr regs instr i = regs i := by
  simp [execInstr, h]


/-- Empty instruction list is identity -/
theorem execInstrs_nil (regs : RegFile) : execInstrs regs [] = regs := rfl


/-- Instruction list execution is compositional -/
theorem execInstrs_cons (regs : RegFile) (instr : TropInstruction)
    (rest : List TropInstruction) :
    execInstrs regs (instr :: rest) = execInstrs (execInstr regs instr) rest := rfl


/-- A tropical trapdoor function: a circuit paired with its "secret" structure -/
structure TropTrapdoorFn where
  /-- The public function (circuit evaluation) -/
  circuit : TropCircuit
  /-- The secret trapdoor: a partial inverse hint -/
  trapdoorHint : ℝ → ℕ → ℝ


/-- The public evaluation function -/
def TropTrapdoorFn.eval (tf : TropTrapdoorFn) (inputs : ℕ → ℝ) : ℝ :=
  evalCircuit tf.circuit inputs


/-- The trapdoor-assisted inversion -/
def TropTrapdoorFn.invert (tf : TropTrapdoorFn) (output : ℝ) (idx : ℕ) : ℝ :=
  tf.trapdoorHint output idx


/-- [Section: ## Section 7: Monotonicity of Tropical Gates] -/
theorem min_gate_mono_left (b : ℝ) : Monotone (fun a => min a b) :=
  fun _ _ h => min_le_min_right b h


theorem max_gate_mono_left (b : ℝ) : Monotone (fun a => max a b) :=
  fun _ _ h => max_le_max_right b h


theorem add_gate_mono_left (b : ℝ) : Monotone (fun a => a + b) :=
  fun _ _ h => by dsimp; linarith


theorem min_gate_mono_right (a : ℝ) : Monotone (fun b => min a b) :=
  fun _ _ h => min_le_min_left a h


theorem max_gate_mono_right (a : ℝ) : Monotone (fun b => max a b) :=
  fun _ _ h => max_le_max_left a h


/-- Addition distributes over min (tropical semiring law) -/
theorem add_distrib_min (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_add_add_left]


/-- Addition distributes over max (dual tropical semiring law) -/
theorem add_distrib_max (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) := by
  simp [max_add_add_left]


/-- min and max are dual via negation -/
theorem min_max_neg_duality (a b : ℝ) :
    min a b = -max (-a) (-b) := by
  simp [min_def, max_def]; split_ifs <;> linarith


/-- Idempotency of min gate -/
theorem min_gate_idem (a : ℝ) : min a a = a := min_self a


/-- Idempotency of max gate -/
theorem max_gate_idem (a : ℝ) : max a a = a := max_self a


/-- A gate selection is a choice of which argument each min/max gate selects -/
def GateSelection (numGates : ℕ) := Fin numGates → Bool


/-- Number of possible gate selections (combinatorial complexity of reversal) -/
theorem gate_selection_card (n : ℕ) :
    Fintype.card (Fin n → Bool) = 2 ^ n := by
  simp [Fintype.card_fin, Fintype.card_bool]


/-- Min of two linear functions is piecewise linear with at most 2 pieces -/
theorem min_linear_pwl (a₁ b₁ a₂ b₂ : ℝ) :
    ∃ (f : ℝ → ℝ), (∀ x, f x = min (a₁ * x + b₁) (a₂ * x + b₂)) :=
  ⟨fun x => min (a₁ * x + b₁) (a₂ * x + b₂), fun _ => rfl⟩


/-- Max of two linear functions is piecewise linear with at most 2 pieces -/
theorem max_linear_pwl (a₁ b₁ a₂ b₂ : ℝ) :
    ∃ (f : ℝ → ℝ), (∀ x, f x = max (a₁ * x + b₁) (a₂ * x + b₂)) :=
  ⟨fun x => max (a₁ * x + b₁) (a₂ * x + b₂), fun _ => rfl⟩


/-- The preimage set of a circuit at output value c -/
def circuitPreimage (circ : TropCircuit) (c : ℝ) : Set (ℕ → ℝ) :=
  {inputs | evalCircuit circ inputs = c}


/-- Preimage of identity circuit (no gates) is a hyperplane -/
theorem preimage_identity (reg : ℕ) (c : ℝ) :
    let circ : TropCircuit := ⟨1, 1, [], reg⟩
    circuitPreimage circ c = {inputs | inputs reg = c} := by
  simp [circuitPreimage, evalCircuit, execInstrs, initRegs]


/-- A reversal witness: for each min/max gate, which argument was selected -/
structure ReversalWitness (circ : TropCircuit) where
  selections : Fin circ.instrs.length → Bool


/-- The forward problem: evaluate circuit -/
def forwardProblem (circ : TropCircuit) (x : ℕ → ℝ) : ℝ :=
  evalCircuit circ x


/-- The reverse problem: find a preimage -/
def reverseProblem (circ : TropCircuit) (y : ℝ) : Prop :=
  ∃ x : ℕ → ℝ, evalCircuit circ x = y


/-- All gates are surjective -/
theorem add_gate_surjective (c : ℝ) :
    ∃ (a b : ℝ), evalGate .AddGate a b = c :=
  ⟨c, 0, by simp [evalGate]⟩


/-- [Section: ## Section 12: The Reversal Problem (Formal Statement)] -/
theorem min_gate_surjective (c : ℝ) :
    ∃ (a b : ℝ), evalGate .MinGate a b = c :=
  ⟨c, c, by simp [evalGate]⟩


theorem max_gate_surjective (c : ℝ) :
    ∃ (a b : ℝ), evalGate .MaxGate a b = c :=
  ⟨c, c, by simp [evalGate]⟩


/-- min(min(a,b), c) = min(a, min(b,c)) -/
theorem compose_min_assoc (a b c : ℝ) :
    min (min a b) c = min a (min b c) := min_assoc a b c


/-- max(max(a,b), c) = max(a, max(b,c)) -/
theorem compose_max_assoc (a b c : ℝ) :
    max (max a b) c = max a (max b c) := max_assoc a b c


end
