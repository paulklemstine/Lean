import Mathlib
import Speculative.DifferentialClosure.Defs

/-!
# Differential Closure, Minimality, and Generator Separation

This file proves the structural theorems about the elementary expression algebra:
- The full class is differentiation-stable (closure)
- Any set containing generators and closed under constructors contains all expressions (minimality)
- The exp-free and log-free subclasses are each independently differentiation-stable (separation)
- Derivative size is bounded

## Main results

* `EExpr.all_mem_generated` — Minimality: any GeneratedByExpLog set contains all EExpr
* `EExpr.univ_diff_closed` — The full EExpr class is differentiation-closed
* `EExpr.derivE_noexp` — The exp-free subclass is differentiation-stable
* `EExpr.derivE_nolog` — The log-free subclass is differentiation-stable
* `EExpr.size_derivE_le` — Derivative size bound
-/

noncomputable section

open EExpr

/-! ## Minimality / Initiality -/

/-
**Minimality Theorem (Initiality).**
Any set `S` of expressions that contains the variable, all constants, and is closed
under all elementary constructors must contain every elementary expression.
This characterizes `EExpr` as the *initial* algebra of the elementary signature.

Proof by structural induction on the expression.
-/
theorem EExpr.all_mem_generated {S : Set EExpr} (hS : GeneratedByExpLog S) :
    ∀ e : EExpr, e ∈ S := by
      intro e;
      induction' e using EExpr.recOn with a b ih_a ih_b;
      all_goals have := hS; unfold GeneratedByExpLog at this; aesop;

/-- **Differential Closure of the Elementary Class.**
Since `derivE` maps every `EExpr` to an `EExpr`, and every `EExpr` belongs to any
GeneratedByExpLog set, the full class `Set.univ` is differentiation-closed. -/
theorem EExpr.univ_diff_closed : DiffClosed (Set.univ : Set EExpr) := by
  intro e _
  exact Set.mem_univ _

/-- The full class with its generator structure is differentiation-closed. -/
theorem EExpr.EML_diff_closed {S : Set EExpr} (hS : GeneratedByExpLog S) :
    DiffClosed S := by
  intro e he
  exact all_mem_generated hS (derivE e)

/-! ## Generator Separation: Exp-free and Log-free Subclasses -/

/-
**Exp-free stability.**
The symbolic derivative of an exp-free expression is again exp-free.
This means the exp-free subclass is independently differentiation-stable.
-/
theorem EExpr.derivE_noexp (e : EExpr) (h : containsExp e = false) :
    containsExp (derivE e) = false := by
      induction' e with e ih;
      all_goals simp_all +decide [ EExpr.containsExp, EExpr.derivE ]

/-
**Log-free stability.**
The symbolic derivative of a log-free expression is again log-free.
This means the log-free subclass is independently differentiation-stable.
-/
theorem EExpr.derivE_nolog (e : EExpr) (h : containsLog e = false) :
    containsLog (derivE e) = false := by
      -- By induction on the structure of `e`, we can show that if `e` contains no `EExpr.log`, then its derivative also contains no `EExpr.log`.
      induction' e with e ih;
      all_goals simp_all +decide [ EExpr.containsLog, EExpr.derivE ]

/-- The exp-free subclass is differentiation-closed. -/
theorem EExpr.noexp_diff_closed : DiffClosed {e : EExpr | containsExp e = false} := by
  intro e he
  exact derivE_noexp e he

/-- The log-free subclass is differentiation-closed. -/
theorem EExpr.nolog_diff_closed : DiffClosed {e : EExpr | containsLog e = false} := by
  intro e he
  exact derivE_nolog e he

/-- **Counterexample to naive generator-removal conjecture.**
Both `exp` and `log` can be independently removed without breaking differential closure.
This shows the naive claim "removing any primitive generator breaks closure" is false.
The correct statement is that both generators are needed for *expressiveness* (representing
all elementary functions), not for *differential stability* of any subclass. -/
theorem EExpr.both_subclasses_diff_closed :
    DiffClosed {e : EExpr | containsExp e = false} ∧
    DiffClosed {e : EExpr | containsLog e = false} :=
  ⟨noexp_diff_closed, nolog_diff_closed⟩

/-! ## Derivative Size Bound -/

/-
The size of the symbolic derivative is at most quadratic in the input size.
This gives a verified complexity bound for the differentiation algorithm.
The quadratic growth arises from the product and quotient rules, which
duplicate subexpressions.
-/
theorem EExpr.size_derivE_le (e : EExpr) :
    size (derivE e) ≤ 6 * size e ^ 2 := by
      -- By induction on the structure of `e`, we can show that the size of `derivE e` is bounded by `6 * size e ^ 2`.
      induction' e with e ih;
      all_goals norm_num [ EExpr.derivE, EExpr.size ];
      grind +extAll;
      · grind +suggestions;
      · lia;
      · grind;
      · grind +splitImp;
      · grind

end