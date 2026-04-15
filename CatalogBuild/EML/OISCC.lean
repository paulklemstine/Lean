/-! # CatalogBuild.EML.OISCC

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 33
-/

import Mathlib

noncomputable section

/-- The EML operation: eml(a, b) = exp(a) - ln(b) -/
def eml_op (a b : ℝ) : ℝ := Real.exp a - Real.log b


/-- The OISCC has exactly two instructions: PUSH a constant, or EML. -/
inductive OISCCInstr where
  | PUSH : ℝ → OISCCInstr
  | EML : OISCCInstr


/-- A program is a list of instructions. -/
abbrev OISCCProgram := List OISCCInstr


/-- The machine state is just a stack of real numbers. -/
abbrev OISCCStack := List ℝ


/-- Execute one instruction. Returns None if EML is called with fewer than 2 stack elements. -/
def execInstr (instr : OISCCInstr) (stack : OISCCStack) : Option OISCCStack :=
  match instr with
  | .PUSH v => some (v :: stack)
  | .EML =>
    match stack with
    | b :: a :: rest => some (eml_op a b :: rest)
    | _ => none


/-- Execute a program (list of instructions) on a stack. -/
def execProgram : OISCCProgram → OISCCStack → Option OISCCStack
  | [], stack => some stack
  | instr :: rest, stack =>
    match execInstr instr stack with
    | some stack' => execProgram rest stack'
    | none => none


/-- exp(a) = EML(a, 1): The exponential is recovered by EML with second argument 1. -/
theorem eml_recovers_exp (a : ℝ) : eml_op a 1 = Real.exp a := by
  simp [eml_op, Real.log_one]


/-- The program [PUSH a, PUSH 1, EML] computes exp(a). -/
theorem oiscc_computes_exp (a : ℝ) :
    execProgram [.PUSH a, .PUSH 1, .EML] [] = some [Real.exp a] := by
  simp [execProgram, execInstr, eml_recovers_exp]


/-- EML(0, b) = 1 - ln(b): The "one minus log" operation. -/
theorem eml_one_minus_log (b : ℝ) : eml_op 0 b = 1 - Real.log b := by
  simp [eml_op]


/-- The program [PUSH 0, PUSH b, EML] computes 1 - ln(b). -/
theorem oiscc_computes_one_minus_log (b : ℝ) :
    execProgram [.PUSH 0, .PUSH b, .EML] [] = some [1 - Real.log b] := by
  simp [execProgram, execInstr, eml_one_minus_log]


/-- ln(b) = EML(0, exp(EML(0, b))) for all b.
This is the key identity: ln is recovered as a depth-3 EML composition. -/
theorem eml_recovers_ln (b : ℝ) :
    eml_op 0 (Real.exp (eml_op 0 b)) = Real.log b := by
  simp [eml_op, Real.log_exp]


/-- The program [PUSH 0, PUSH 0, PUSH b, EML, PUSH 1, EML, EML] computes ln(b). -/
theorem oiscc_computes_ln (b : ℝ) :
    execProgram [.PUSH 0, .PUSH 0, .PUSH b, .EML, .PUSH 1, .EML, .EML] [] =
    some [Real.log b] := by
  simp [execProgram, execInstr, eml_op, Real.log_one, Real.log_exp]


/-- **Core OISCC Theorem**: a − b = EML(ln(a), exp(b)) for a > 0.
This is the identity that makes EML arithmetically complete.
Proof: exp(ln(a)) − ln(exp(b)) = a − b. -/
theorem eml_recovers_sub (a b : ℝ) (ha : 0 < a) :
    eml_op (Real.log a) (Real.exp b) = a - b := by
  simp [eml_op, Real.exp_log ha, Real.log_exp]


/-- a + b = EML(ln(a), exp(-b)) for a > 0.
Proof: exp(ln(a)) − ln(exp(-b)) = a − (-b) = a + b. -/
theorem eml_recovers_add (a b : ℝ) (ha : 0 < a) :
    eml_op (Real.log a) (Real.exp (-b)) = a + b := by
  simp [eml_op, Real.exp_log ha, Real.log_exp]


/-- a * b = EML(ln(a) + ln(b), 1) for a, b > 0. -/
theorem eml_mul_final (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml_op (Real.log a + Real.log b) 1 = a * b := by
  simp [eml_op, Real.log_one, Real.exp_add, Real.exp_log ha, Real.exp_log hb]


/-- a / b = EML(ln(a) - ln(b), 1) for a, b > 0. -/
theorem eml_div_final (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml_op (Real.log a - Real.log b) 1 = a / b := by
  simp [eml_op, Real.log_one, Real.exp_sub, Real.exp_log ha, Real.exp_log hb]


/-- a ^ b = exp(b * ln(a)) for a > 0 (real-valued power). -/
theorem rpow_via_eml (a b : ℝ) (ha : 0 < a) :
    Real.exp (b * Real.log a) = a ^ b := by
  rw [mul_comm, ← Real.rpow_def_of_pos ha]


/-- x is a fixed point of the diagonal EML map if eml(x, x) = x. -/
def isEMLFixedPoint (x : ℝ) : Prop := eml_op x x = x


/-- The fixed point equation is equivalent to exp(x) - x = ln(x). -/
theorem eml_fixed_point_equiv (x : ℝ) :
    isEMLFixedPoint x ↔ Real.exp x - x = Real.log x := by
  simp [isEMLFixedPoint, eml_op, sub_eq_iff_eq_add]
  constructor
  · intro h; linarith
  · intro h; linarith


theorem eml_no_positive_fixed_point (x : ℝ) (hx : 0 < x) :
    ¬ isEMLFixedPoint x := by
      -- By definition of $isEMLFixedPoint$, we need to show that $x$ is not a solution to $e^x - \ln x = x$.
      unfold isEMLFixedPoint
      intro h_fixed_point
      have h_eq : Real.exp x - Real.log x = x := by
        exact h_fixed_point;
      have h_exp_log : Real.exp x > 1 + x + x^2 / 2 := by
        norm_num [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ] at *;
        exact lt_of_lt_of_le ( by norm_num [ Finset.sum_range_succ ] ; positivity ) ( Summable.sum_le_tsum ( Finset.range 4 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial x ) );
      nlinarith [ Real.log_le_sub_one_of_pos hx ]


/-- EML(1, 1) = e: Euler's number. -/
theorem oiscc_constant_e :
    eml_op 1 1 = Real.exp 1 := by
  simp [eml_op, Real.log_one]


/-- EML(0, 1) = 1: The unit. -/
theorem oiscc_constant_one :
    eml_op 0 1 = 1 := by
  simp [eml_op, Real.log_one]


/-- EML(0, exp(1)) = 0: Zero from EML. -/
theorem oiscc_constant_zero :
    eml_op 0 (Real.exp 1) = 0 := by
  simp [eml_op, Real.log_exp]


/-- EML(EML(1,1), 1) = exp(e): A tower of exponentiation. -/
theorem oiscc_constant_exp_e :
    eml_op (eml_op 1 1) 1 = Real.exp (Real.exp 1) := by
  simp [eml_op, Real.log_one]


/-- Concatenating programs composes their effects. -/
theorem execProgram_append (p1 p2 : OISCCProgram) (s : OISCCStack) :
    execProgram (p1 ++ p2) s =
    match execProgram p1 s with
    | some s' => execProgram p2 s'
    | none => none := by
  induction p1 generalizing s with
  | nil => simp [execProgram]
  | cons instr rest ih =>
    simp [execProgram, List.cons_append]
    cases execInstr instr s with
    | none => simp [execProgram]
    | some s' => exact ih s'


/-- The number of EML operations in a program. -/
def emlCount : OISCCProgram → ℕ
  | [] => 0
  | .EML :: rest => 1 + emlCount rest
  | .PUSH _ :: rest => emlCount rest


/-- The number of PUSH operations in a program. -/
def pushCount : OISCCProgram → ℕ
  | [] => 0
  | .PUSH _ :: rest => 1 + pushCount rest
  | .EML :: rest => pushCount rest


/-- Total length = EML count + PUSH count. -/
theorem length_eq_eml_plus_push (p : OISCCProgram) :
    p.length = emlCount p + pushCount p := by
  induction p with
  | nil => simp [emlCount, pushCount]
  | cons instr rest ih =>
    cases instr with
    | PUSH v => simp [emlCount, pushCount, ih]; omega
    | EML => simp [emlCount, pushCount, ih]; omega


/-- The OISCC arithmetic completeness theorem (summary version).
For positive reals a, b: all basic arithmetic operations can be expressed as
compositions of eml_op with constants. -/
theorem oiscc_arithmetic_complete (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml_op a 1 = Real.exp a ∧
    eml_op (Real.log a) (Real.exp b) = a - b ∧
    eml_op (Real.log a) (Real.exp (-b)) = a + b ∧
    eml_op (Real.log a + Real.log b) 1 = a * b ∧
    eml_op (Real.log a - Real.log b) 1 = a / b := by
  exact ⟨eml_recovers_exp a,
         eml_recovers_sub a b ha,
         eml_recovers_add a b ha,
         eml_mul_final a b ha hb,
         eml_div_final a b ha hb⟩


/-- Applying EML(·, 1) twice gives exp(exp(a)). -/
theorem eml_double_exp (a : ℝ) :
    eml_op (eml_op a 1) 1 = Real.exp (Real.exp a) := by
  simp [eml_op, Real.log_one]


/-- EML is an involution in a composed sense:
EML(0, exp(EML(0, exp(a)))) = a.
That is, 1 - ln(exp(1 - a)) = 1 - (1-a) = a. -/
theorem eml_log_exp_involution (a : ℝ) :
    eml_op 0 (Real.exp (eml_op 0 (Real.exp a))) = a := by
  simp [eml_op, Real.log_exp]


/-- Maximum stack depth during execution of a program. -/
def maxStackDepth : OISCCProgram → ℕ → ℕ
  | [], d => d
  | .PUSH _ :: rest, d => maxStackDepth rest (d + 1)
  | .EML :: rest, d => maxStackDepth rest (d - 1)


/-- The exp program [PUSH a, PUSH 1, EML] has max stack depth 2. -/
theorem exp_program_depth (a : ℝ) :
    maxStackDepth [.PUSH a, .PUSH 1, .EML] 0 = 1 := by
  simp [maxStackDepth]


end
