/-
# EML Compilation: Correctness and Size Bounds

This file defines the compiler from UExpr (elementary expressions) to EMLExpr
(expressions using only the eml primitive), and proves:
  1. Semantic correctness (compile_correct)
  2. Linear size bound (compile_size_linear)
  3. Transcendence rank control (compile_rank_control)
  4. Polynomial bounded EML for all expressions (polyBoundedEML_of_compile)
-/
import EML.Defs

noncomputable section

open Real

/-! ## The Compiler

The key translations are:
- `exp(e)` becomes `eml(e, 1)`, since `eml(x, 1) = exp(x) - log(1) = exp(x)`
- `log(e)` becomes `sub(const 1, eml(const 0, e))`, since
  `eml(0, y) = exp(0) - log(y) = 1 - log(y)`, so `log(y) = 1 - eml(0, y)` -/

/-- Compile a UExpr into an EMLExpr by replacing exp and log with eml. -/
def compile : UExpr → EMLExpr
  | .var       => .var
  | .const c   => .const c
  | .add e₁ e₂ => .add (compile e₁) (compile e₂)
  | .sub e₁ e₂ => .sub (compile e₁) (compile e₂)
  | .mul e₁ e₂ => .mul (compile e₁) (compile e₂)
  | .div e₁ e₂ => .div (compile e₁) (compile e₂)
  | .exp e     => .eml (compile e) (.const 1)
  | .log e     => .sub (.const 1) (.eml (.const 0) (compile e))

/-! ## Theorem 1: Compilation Correctness

The compiler preserves semantics exactly: for every real x and value y,
the compiled expression evaluates to y if and only if the original does. -/

/-
The compiler produces semantically equivalent expressions:
    `eeval (compile e) x = some y ↔ eval e x = some y` for all x, y.
-/
theorem compile_correct (e : UExpr) :
    ∀ x y : ℝ, (compile e).eeval x = some y ↔ e.eval x = some y := by
      induction' e with e₁ e₂ ih₁ ih₂;
      all_goals norm_num [ UExpr.eval, EMLExpr.eeval, compile ];
      all_goals simp_all +decide [ Option.bind_eq_some_iff ];
      grind +splitIndPred

/-! ## Theorem 2: Linear Size Bound

The compilation increases expression size by at most a factor of 4.
This is tight: the worst case is a chain of log nodes. -/

/-
The compiled expression has size at most 4 times the original.
-/
theorem compile_size_linear (e : UExpr) :
    (compile e).esize ≤ 4 * e.size := by
      induction' e with e₁ e₂ ih₁ ih₂;
      all_goals norm_num [ EMLExpr.esize, UExpr.size, compile ];
      all_goals linarith

/-! ## Theorem 3: Transcendence Rank Control

Each transcendental operation (exp or log) in the source produces exactly one
eml node in the target. The eml rank equals the transcendence rank. -/

/-
Compilation preserves transcendental gate count exactly.
-/
theorem compile_rank_exact (e : UExpr) :
    (compile e).emlRank = e.transcendenceRank := by
      induction' e with e₁ e₂ ih₁ ih₂;
      all_goals simp_all! +arith +decide

/-
Corollary: EML rank is bounded by source transcendence rank plus source size.
-/
theorem compile_rank_control (e : UExpr) :
    (compile e).emlRank ≤ e.transcendenceRank + e.size := by
      exact le_add_right ( compile_rank_exact e ▸ le_rfl )

/-! ## Theorem 4: Every UExpr is Polynomial-Bounded in EML

As a direct corollary of the linear size bound and correctness,
every elementary expression admits a polynomial (in fact linear) EML representation. -/

/-
Every unary elementary expression has a polynomial-bounded EML representation.
-/
theorem polyBoundedEML_of_compile (e : UExpr) : PolyBoundedEML e := by
  -- For `e: UExpr`, use `k=1`, `C=4`, and `t = compile e`.
  use 1, 4, compile e;
  exact ⟨ compile_correct e, le_trans ( compile_size_linear e ) ( by linarith ) ⟩

/-! ## Compilation Preserves Safety -/

/-
The output of compile is always EMLSafe.
-/
theorem compile_emlSafe (e : UExpr) : (compile e).EMLSafe := by
  induction' e with e₁ e₂ ih₁ ih₂;
  all_goals first | exact EMLExpr.EMLSafe.var | exact EMLExpr.EMLSafe.const | exact EMLExpr.EMLSafe.add ‹_› ‹_› | exact EMLExpr.EMLSafe.sub ‹_› ‹_› | exact EMLExpr.EMLSafe.mul ‹_› ‹_› | exact EMLExpr.EMLSafe.div ‹_› ‹_› | exact EMLExpr.EMLSafe.eml ‹_› ( EMLExpr.EMLSafe.const ) | exact EMLExpr.EMLSafe.sub ( EMLExpr.EMLSafe.const ) ( EMLExpr.EMLSafe.eml ( EMLExpr.EMLSafe.const ) ‹_› )

/-! ## Domain Preservation -/

/-
Compilation preserves the natural domain exactly.
-/
theorem compile_preserves_domain (e : UExpr) :
    ∀ x : ℝ, x ∈ e.NaturalDomain ↔ x ∈ (compile e).NaturalDomain := by
      intro x;
      constructor <;> intro h;
      · exact ⟨ _, compile_correct e x _ |>.2 h.choose_spec ⟩;
      · exact ⟨ _, ( compile_correct e x _ ).mp h.choose_spec ⟩

end