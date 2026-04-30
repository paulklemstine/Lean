import Mathlib

/-! # CatalogBuild.EML.Universality

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 11
-/

noncomputable section

/-- The EML operator on complex numbers. -/
def emlU (x y : ℂ) : ℂ := Complex.exp x - Complex.log y

/-- exp(x) = emlU(x, 1) — the exponential is a depth-1 EML expression. -/
theorem emlU_recovers_exp (x : ℂ) : emlU x 1 = Complex.exp x := by
  simp [emlU, Complex.log_one]

/-- e = emlU(1, 1) — Euler's number from a depth-1 expression. -/
theorem emlU_recovers_e : emlU 1 1 = Complex.exp 1 := by
  simp [emlU, Complex.log_one]

/-- The EML closure: smallest set of complex numbers containing 1 and
closed under emlU application. -/
inductive EMLClosure : ℂ → Prop where
  | const_one : EMLClosure 1
  | apply_eml : EMLClosure x → EMLClosure y → EMLClosure (emlU x y)

/-- e = exp(1) is in the EML closure. -/
theorem exp_one_in_closure : EMLClosure (Complex.exp 1) := by
  have h := EMLClosure.apply_eml EMLClosure.const_one EMLClosure.const_one
  rwa [emlU_recovers_e] at h

/-- The EDL (Exp-Div-Log) operator: edl(x,y) = exp(x) / log(y). -/
def edlU (x y : ℂ) : ℂ := Complex.exp x / Complex.log y

/-- The anti-EML operator: antiEml(x,y) = log(x) - exp(y). -/
def antiEmlU (x y : ℂ) : ℂ := Complex.log x - Complex.exp y

/-- [Section: # CatalogBuild.EML.Universality
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 11] -/
theorem antiEml_eq_neg_eml_swap (x y : ℂ) :
    antiEmlU x y = -emlU y x := by
  unfold antiEmlU emlU ; ring

/-- EML expression with variables. -/
inductive EMLExprU where
  | one : EMLExprU
  | var : ℕ → EMLExprU
  | eml : EMLExprU → EMLExprU → EMLExprU

/-- Evaluate an EML expression. -/
def EMLExprU.evalWith (e : EMLExprU) (vars : ℕ → ℂ) : ℂ :=
  match e with
  | .one => 1
  | .var n => vars n
  | .eml l r => emlU (l.evalWith vars) (r.evalWith vars)

/-- Depth of expression. -/
def EMLExprU.depth : EMLExprU → ℕ
  | .one => 0
  | .var _ => 0
  | .eml l r => 1 + max l.depth r.depth

end

end

end

end
