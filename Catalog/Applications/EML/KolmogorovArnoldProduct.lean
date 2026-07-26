import Mathlib
import Bridges.PosetTheory.EMLInterpolation

/-!
# An exact five-channel EML Kolmogorov–Arnold representation of multiplication

For the concrete target `f(x,y)=x*y`, this file gives five explicit ridge channels
of Kolmogorov–Arnold form

`sum q, outer q (leftInner q x + rightInner q y)`.

Every coordinate inner expression is built in the catalog's existing `EMLExpr`
syntax.  The nonconstant coordinate is deliberately written as `log (exp x)`,
rather than merely as the variable, so the construction is explicitly exp–log.
The positive polarization term is split equally among three channels, so all
five outer functions are nonzero while the width is exactly `2*2+1=5`.
-/

noncomputable section

open scoped BigOperators

namespace EMLKolmogorovArnold

/-- The identity represented as a genuine exp–log composition. -/
def expLogIdentity : EMLExpr :=
  .log (.exp .var)

/-- The zero univariate EML expression. -/
def zeroExpr : EMLExpr :=
  .const 0

/-- Evaluation of the explicit exp–log identity. -/
theorem expLogIdentity_eval (x : ℝ) : expLogIdentity.eval x = x := by
  simp [expLogIdentity, EMLExpr.eval]

/-- Evaluation of the zero EML expression. -/
theorem zeroExpr_eval (x : ℝ) : zeroExpr.eval x = 0 := by
  simp [zeroExpr, EMLExpr.eval]

/-- The five left-coordinate inner univariate EML expressions. -/
def leftInner : Fin 5 → EMLExpr
  | 0 => expLogIdentity
  | 1 => expLogIdentity
  | 2 => zeroExpr
  | 3 => expLogIdentity
  | 4 => expLogIdentity

/-- The five right-coordinate inner univariate EML expressions. -/
def rightInner : Fin 5 → EMLExpr
  | 0 => expLogIdentity
  | 1 => zeroExpr
  | 2 => expLogIdentity
  | 3 => expLogIdentity
  | 4 => expLogIdentity

/-- The five scalar outer functions.  The positive polarization term is split
among channels `0`, `3`, and `4`, making every outer function nonzero. -/
def outer : Fin 5 → ℝ → ℝ
  | 0 => fun z => z ^ 2 / 6
  | 1 => fun z => -(z ^ 2) / 2
  | 2 => fun z => -(z ^ 2) / 2
  | 3 => fun z => z ^ 2 / 6
  | 4 => fun z => z ^ 2 / 6

/-- The ridge argument in channel `q`, formed by adding two univariate EML
inner evaluations. -/
def ridgeInner (q : Fin 5) (x y : ℝ) : ℝ :=
  (leftInner q).eval x + (rightInner q).eval y

/-- The explicit five-channel Kolmogorov–Arnold sum. -/
def fiveChannelRepresentation (x y : ℝ) : ℝ :=
  ∑ q : Fin 5, outer q (ridgeInner q x y)

/-- Each outer function in the explicit construction is continuous. -/
theorem continuous_outer (q : Fin 5) : Continuous (outer q) := by
  fin_cases q <;> simp [outer] <;> fun_prop

/-- Each of the ten coordinate inner functions is continuous. -/
theorem continuous_coordinate_inners (q : Fin 5) :
    Continuous (fun x => (leftInner q).eval x) ∧
      Continuous (fun y => (rightInner q).eval y) := by
  fin_cases q <;>
    simp only [leftInner, rightInner, expLogIdentity_eval, zeroExpr_eval] <;>
    constructor <;> fun_prop

/-- The five ridge arguments evaluate respectively to `x+y`, `x`, `y`, `x+y`,
and `x+y`. -/
theorem ridgeInner_values (x y : ℝ) :
    ridgeInner 0 x y = x + y ∧
    ridgeInner 1 x y = x ∧
    ridgeInner 2 x y = y ∧
    ridgeInner 3 x y = x + y ∧
    ridgeInner 4 x y = x + y := by
  simp [ridgeInner, leftInner, rightInner, expLogIdentity_eval, zeroExpr_eval]

/-- **Exact EML K–A test case.** The five explicit channels represent
multiplication on all of `ℝ²`, hence in particular on `[0,1]²`. -/
theorem fiveChannelRepresentation_eq_mul (x y : ℝ) :
    fiveChannelRepresentation x y = x * y := by
  simp only [fiveChannelRepresentation]
  simp [Fin.sum_univ_ofNat, outer, ridgeInner, leftInner, rightInner,
    expLogIdentity, zeroExpr, EMLExpr.eval]
  ring

/-- The requested unit-square formulation.  Its bounds are retained to state the
application domain, while the exact identity is stronger and needs no bounds. -/
theorem fiveChannelRepresentation_on_unitSquare
    {x y : ℝ} (_hx : x ∈ Set.Icc (0 : ℝ) 1) (_hy : y ∈ Set.Icc (0 : ℝ) 1) :
    fiveChannelRepresentation x y = x * y := by
  exact fiveChannelRepresentation_eq_mul x y

end EMLKolmogorovArnold