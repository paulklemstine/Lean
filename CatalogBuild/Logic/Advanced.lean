/-! # CatalogBuild.Logic.Advanced

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 34
-/

import Mathlib

noncomputable section

/-- Size of a NOT circuit. -/
theorem notCircuit_size {n : ℕ} (c : NandCircuit n) :
    (notCircuit c).size = 1 + 2 * c.size := by
  simp [notCircuit, NandCircuit.size]; omega


/-- Size of an AND circuit. -/
theorem andCircuit_size {n : ℕ} (c₁ c₂ : NandCircuit n) :
    (andCircuit c₁ c₂).size = 3 + 2 * c₁.size + 2 * c₂.size := by
  simp [andCircuit, notCircuit, NandCircuit.size]; omega


/-- Size of an OR circuit. -/
theorem orCircuit_size {n : ℕ} (c₁ c₂ : NandCircuit n) :
    (orCircuit c₁ c₂).size = 3 + 2 * c₁.size + 2 * c₂.size := by
  simp [orCircuit, notCircuit, NandCircuit.size]; omega


/-- Size is always nonneg (trivial but useful). -/
theorem NandCircuit.size_nonneg {n : ℕ} (c : NandCircuit n) :
    0 ≤ c.size := Nat.zero_le _


/-- Inputs have size 0. -/
theorem input_size {n : ℕ} (i : Fin n) :
    (NandCircuit.input i).size = 0 := rfl


/-- A single NAND gate has size 1. -/
theorem single_nand_size {n : ℕ} (i j : Fin n) :
    (NandCircuit.nand (.input i) (.input j)).size = 1 := by
  simp [NandCircuit.size]


/-- A literal circuit: if polarity is true, return input; if false, return NOT input. -/
def litCircuit {n : ℕ} (i : Fin n) (polarity : Bool) : NandCircuit n :=
  if polarity then .input i else notCircuit (.input i)


/-- A minterm for 2 inputs: AND of two literals. -/
def minterm2 (p₀ p₁ : Bool) : NandCircuit 2 :=
  andCircuit (litCircuit 0 p₀) (litCircuit 1 p₁)


/-- Literal circuit evaluates correctly. -/
theorem litCircuit_correct {n : ℕ} (i : Fin n) (polarity : Bool) (assign : Fin n → Bool) :
    (litCircuit i polarity).eval assign = (if polarity then assign i else !(assign i)) := by
  simp [litCircuit]; split <;> simp [notCircuit_correct, NandCircuit.eval]


/-- Minterm evaluates correctly: true iff input matches the pattern. -/
theorem minterm2_correct (p₀ p₁ : Bool) (assign : Fin 2 → Bool) :
    (minterm2 p₀ p₁).eval assign = ((if p₀ then assign 0 else !(assign 0)) &&
                                     (if p₁ then assign 1 else !(assign 1))) := by
  simp [minterm2, andCircuit_correct, litCircuit_correct]


/-- A constant TRUE circuit (for 2 inputs). -/
def constTrue2 : NandCircuit 2 :=
  .nand (.input 0) (notCircuit (.input 0))


/-- Constant TRUE evaluates to true. -/
theorem constTrue2_correct (assign : Fin 2 → Bool) :
    constTrue2.eval assign = true := by
  simp only [constTrue2, NandCircuit.eval, notCircuit, bNand]
  cases assign 0 <;> decide


/-- Build a 2-input circuit from its truth table using DNF.
Given 4 bits (the values of f at each of the 4 inputs),
construct the appropriate circuit. -/
def dnfCircuit2 (v00 v01 v10 v11 : Bool) : NandCircuit 2 :=
  -- If all false, return AND(x0, NOT x0) which is always false
  -- If at least one true, OR the relevant minterms
  match v00, v01, v10, v11 with
  | false, false, false, false => andCircuit (.input 0) (notCircuit (.input 0))  -- const false
  | true, true, true, true => constTrue2  -- const true
  | _, _, _, _ =>
    -- General case: build OR of active minterms
    let active : List (Bool × Bool) :=
      (if v00 then [(false, false)] else []) ++
      (if v01 then [(false, true)] else []) ++
      (if v10 then [(true, false)] else []) ++
      (if v11 then [(true, true)] else [])
    match active with
    | [] => andCircuit (.input 0) (notCircuit (.input 0))  -- unreachable
    | [(p₀, p₁)] => minterm2 p₀ p₁
    | [(p₀, p₁), (q₀, q₁)] => orCircuit (minterm2 p₀ p₁) (minterm2 q₀ q₁)
    | [(p₀, p₁), (q₀, q₁), (r₀, r₁)] =>
        orCircuit (orCircuit (minterm2 p₀ p₁) (minterm2 q₀ q₁)) (minterm2 r₀ r₁)
    | _ => constTrue2


/-- [Section: # CatalogBuild.Logic.Advanced
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 34] -/
theorem dnfCircuit2_correct (v00 v01 v10 v11 : Bool) (assign : Fin 2 → Bool) :
    (dnfCircuit2 v00 v01 v10 v11).eval assign =
    match assign 0, assign 1 with
    | false, false => v00
    | false, true => v01
    | true, false => v10
    | true, true => v11 := by
  native_decide +revert


/-- [Section: # CatalogBuild.Logic.Advanced
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 34] -/
theorem all_2input_from_nand :
    ∀ f : (Fin 2 → Bool) → Bool,
    ∃ c : NandCircuit 2, ∀ assign : Fin 2 → Bool, c.eval assign = f assign := by
  intro f
  use dnfCircuit2 (f ![false, false]) (f ![false, true]) (f ![true, false]) (f ![true, true]);
  native_decide +revert


/-- The set {optLow, optHigh} is closed under opticalNand. -/
theorem opticalNand_closed (a b : Bool) :
    opticalNand (boolToOpt a) (boolToOpt b) = optLow ∨
    opticalNand (boolToOpt a) (boolToOpt b) = optHigh := by
  cases a <;> cases b <;> simp [opticalNand, boolToOpt, optHigh, optLow] <;> norm_num


/-- optHigh ≠ optLow: the two signal levels are distinct. -/
theorem optHigh_ne_optLow : optHigh ≠ optLow := by
  intro h
  have := congr_arg OpticalSignal.intensity h
  simp [optHigh, optLow] at this


/-- The noise margin of our optical NAND gate.
The minimum gap between the combined intensity for "at most one HIGH"
and "both HIGH" is exactly 1/4. -/
theorem noise_margin :
    ∀ a b : Bool, ¬(a = true ∧ b = true) →
      (boolToOpt a).intensity + (boolToOpt b).intensity ≤ 1 := by
  intro a b h
  cases a <;> cases b <;> simp_all [boolToOpt, optHigh, optLow]


/-- When both inputs are HIGH, the combined intensity is exactly 2. -/
theorem both_high_combined :
    (boolToOpt true).intensity + (boolToOpt true).intensity = 2 := by
  simp [boolToOpt, optHigh]; norm_num


/-- The threshold 3/4 is between the max "not both HIGH" average (1/2)
and the "both HIGH" average (1). -/
theorem threshold_separates :
    (1 : ℝ) / 2 < 3 / 4 ∧ (3 : ℝ) / 4 < 1 := by
  constructor <;> norm_num


/-- Composing two MZIs in series: apply MZ₁ then MZ₂. -/
def MachZehnder.compose (mz₁ mz₂ : MachZehnder) (i₁ i₂ : ℝ) : ℝ × ℝ :=
  let (o₁, o₂) := mz₁.output i₁ i₂
  mz₂.output o₁ o₂


/-- Composition of MZIs conserves total intensity. -/
theorem MachZehnder.compose_conserves (mz₁ mz₂ : MachZehnder) (i₁ i₂ : ℝ) :
    (mz₁.compose mz₂ i₁ i₂).1 + (mz₁.compose mz₂ i₁ i₂).2 = i₁ + i₂ := by
  unfold MachZehnder.compose
  rw [MachZehnder.conserves mz₂]
  exact MachZehnder.conserves mz₁ i₁ i₂


/-- The identity MZ composed with any MZ equals that MZ. -/
theorem MachZehnder.identity_compose (mz : MachZehnder) (i₁ i₂ : ℝ) :
    (MachZehnder.mk 0).compose mz i₁ i₂ = mz.output i₁ i₂ := by
  simp [MachZehnder.compose, MachZehnder.identity]


/-- [Section: # CatalogBuild.Logic.Advanced
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 34] -/
theorem MachZehnder.swap_swap (i₁ i₂ : ℝ) :
    (MachZehnder.mk Real.pi).compose (MachZehnder.mk Real.pi) i₁ i₂ = (i₁, i₂) := by
  unfold MachZehnder.compose; norm_num [ MachZehnder.swap_inputs ] ;


/-- boolToOpt is injective: distinct Booleans give distinct signals. -/
theorem boolToOpt_injective : Injective boolToOpt := by
  intro a b h
  cases a <;> cases b <;> simp_all [boolToOpt, optHigh, optLow, OpticalSignal.mk.injEq]


/-- The optical encoding preserves the Boolean structure. -/
theorem optical_encoding_faithful :
    ∀ a b : Bool, boolToOpt a = boolToOpt b ↔ a = b := by
  intro a b
  exact ⟨fun h => boolToOpt_injective h, fun h => congrArg boolToOpt h⟩


/-- An optical circuit with no gates (just an input) is trivially correct. -/
theorem input_circuit_trivial {n : ℕ} (i : Fin n) (assign : Fin n → Bool) :
    optToBool ((toOptCircuit (NandCircuit.input i)).eval (boolToOpt ∘ assign)) = assign i := by
  simp [toOptCircuit, OptCircuit.eval, optToBool_boolToOpt]


/-- Two circuits are functionally equivalent if they compute the same function. -/
def CircuitEquiv {n : ℕ} (c₁ c₂ : NandCircuit n) : Prop :=
  ∀ assign : Fin n → Bool, c₁.eval assign = c₂.eval assign


/-- Circuit equivalence is reflexive. -/
theorem CircuitEquiv.refl {n : ℕ} (c : NandCircuit n) : CircuitEquiv c c :=
  fun _ => rfl


/-- Circuit equivalence is symmetric. -/
theorem CircuitEquiv.symm {n : ℕ} {c₁ c₂ : NandCircuit n}
    (h : CircuitEquiv c₁ c₂) : CircuitEquiv c₂ c₁ :=
  fun assign => (h assign).symm


/-- Circuit equivalence is transitive. -/
theorem CircuitEquiv.trans {n : ℕ} {c₁ c₂ c₃ : NandCircuit n}
    (h₁ : CircuitEquiv c₁ c₂) (h₂ : CircuitEquiv c₂ c₃) : CircuitEquiv c₁ c₃ :=
  fun assign => (h₁ assign).trans (h₂ assign)


/-- Double negation: NOT(NOT(x)) = x. -/
theorem double_negation {n : ℕ} (c : NandCircuit n) :
    CircuitEquiv (notCircuit (notCircuit c)) c := by
  intro assign
  simp [notCircuit_correct, Bool.not_not]


/-- De Morgan's law: NOT(AND(a,b)) = OR(NOT(a), NOT(b)). -/
theorem de_morgan_nand {n : ℕ} (c₁ c₂ : NandCircuit n) :
    CircuitEquiv (notCircuit (andCircuit c₁ c₂)) (orCircuit (notCircuit c₁) (notCircuit c₂)) := by
  intro assign
  simp only [notCircuit_correct, andCircuit_correct, orCircuit_correct]
  cases c₁.eval assign <;> cases c₂.eval assign <;> simp


/-- Optical equivalence is preserved by circuit equivalence:
equivalent circuits produce the same optical output. -/
theorem circuit_equiv_optical {n : ℕ} (c₁ c₂ : NandCircuit n) (h : CircuitEquiv c₁ c₂)
    (assign : Fin n → Bool) :
    (toOptCircuit c₁).eval (boolToOpt ∘ assign) =
    (toOptCircuit c₂).eval (boolToOpt ∘ assign) := by
  rw [opt_eval_eq_boolToOpt, opt_eval_eq_boolToOpt, h assign]


end
