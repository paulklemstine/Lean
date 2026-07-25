import Mathlib

/-! # CatalogBuild.Computation.StackMachine

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 20
-/


noncomputable section

/-- The EML operation. -/
def EML_sm (a b : ℝ) : ℝ := Real.exp a - Real.log b




/-- [Section: # CatalogBuild.Computation.StackMachine
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 20] -/
inductive Instr where
  | PUSH : ℝ → Instr
  | EML : Instr




/-- [Section: # CatalogBuild.Computation.StackMachine
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 20] -/
abbrev Program := List Instr



abbrev Stack := List ℝ




def step (i : Instr) (s : Stack) : Option Stack :=
  match i with
  | .PUSH v => some (v :: s)
  | .EML =>
    match s with
    | b :: a :: rest => some (EML_sm a b :: rest)
    | _ => none




def run : Program → Stack → Option Stack
  | [], s => some s
  | i :: rest, s =>
    match step i s with
    | some s' => run rest s'
    | none => none




theorem prog_exp (a : ℝ) :
    run [.PUSH a, .PUSH 1, .EML] [] = some [Real.exp a] := by
  simp [run, step, EML_sm, Real.log_one]




theorem prog_one_minus_log (b : ℝ) :
    run [.PUSH 0, .PUSH b, .EML] [] = some [1 - Real.log b] := by
  simp [run, step, EML_sm]




theorem prog_ln (b : ℝ) :
    run [.PUSH 0, .PUSH 0, .PUSH b, .EML, .PUSH 1, .EML, .EML] [] =
    some [Real.log b] := by
  simp [run, step, EML_sm, Real.log_one, Real.log_exp]




theorem prog_sub (a b : ℝ) (ha : 0 < a) :
    run [.PUSH (Real.log a), .PUSH (Real.exp b), .EML] [] = some [a - b] := by
  simp [run, step, EML_sm, Real.exp_log ha, Real.log_exp]




theorem prog_add (a b : ℝ) (ha : 0 < a) :
    run [.PUSH (Real.log a), .PUSH (Real.exp (-b)), .EML] [] = some [a + b] := by
  simp [run, step, EML_sm, Real.exp_log ha, Real.log_exp]




theorem run_append (p1 p2 : Program) (s : Stack) :
    run (p1 ++ p2) s =
    match run p1 s with
    | some s' => run p2 s'
    | none => none := by
  induction p1 generalizing s with
  | nil => simp [run]
  | cons i rest ih =>
    simp [run, List.cons_append]
    cases step i s with
    | none => simp [run]
    | some s' => exact ih s'




def emlOps : Program → ℕ
  | [] => 0
  | .EML :: rest => 1 + emlOps rest
  | .PUSH _ :: rest => emlOps rest




def pushOps : Program → ℕ
  | [] => 0
  | .PUSH _ :: rest => 1 + pushOps rest
  | .EML :: rest => pushOps rest




theorem prog_length (p : Program) : p.length = emlOps p + pushOps p := by
  induction p with
  | nil => simp [emlOps, pushOps]
  | cons i rest ih =>
    cases i with
    | PUSH v => simp [emlOps, pushOps, ih]; omega
    | EML => simp [emlOps, pushOps, ih]; omega




/-- Program computing e↑↑n. -/
def eTowerProg : ℕ → Program
  | 0 => [.PUSH 1]
  | n + 1 => eTowerProg n ++ [.PUSH 1, .EML]




def eTow_sm : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTow_sm n)




theorem eTowerProg_correct (n : ℕ) :
    run (eTowerProg n) [] = some [eTow_sm n] := by
  induction n with
  | zero => simp [eTowerProg, eTow_sm, run, step]
  | succ n ih =>
    simp [eTowerProg, run_append, ih, run, step, EML_sm, Real.log_one, eTow_sm]




/-- emlOps for appended lists. -/
theorem emlOps_append (p1 p2 : Program) : emlOps (p1 ++ p2) = emlOps p1 + emlOps p2 := by
  induction p1 with
  | nil => simp [emlOps]
  | cons i rest ih =>
    cases i with
    | PUSH v => simp [emlOps, ih]
    | EML => simp [emlOps, ih]; omega




theorem eTowerProg_eml_count (n : ℕ) : emlOps (eTowerProg n) = n := by
  induction n with
  | zero => simp [eTowerProg, emlOps]
  | succ n ih => simp [eTowerProg, emlOps_append, ih, emlOps]




end
