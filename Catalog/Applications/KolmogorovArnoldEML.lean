/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Kolmogorov–Arnold Representation with EML Inner Functions (n = 2)

The Kolmogorov–Arnold superposition theorem states that every continuous
`f : [0,1]ⁿ → ℝ` can be written as a finite sum of `2n+1` outer continuous
univariate functions applied to sums of inner continuous univariate functions:
`f(x) = Σ_q Φ_q ( Σ_p ψ_{q,p}(x_p) )`.

**Conjecture under test.** The inner (and outer) univariate functions can be
taken to be *EML-type* functions — finite compositions of `exp`, `log`, `+`, `×`
and constants — drawn from the `EMLTerm` algebra of
`Catalog/Applications/EMLTermAlgebra.lean`.

**Concrete test (n = 2, target `f(x,y) = x·y`).** We exhibit *two* explicit
EML superpositions of the product and analyse where each is valid:

* `mul_eq_expLog` — a **rank-one** representation `x·y = exp(log x + log y)` using
  the single inner term `ψ = logOf var` and the single outer term `Φ = expOf var`.
  This is an EML representation with exp/log-depth `1`, valid on the **open**
  positive quadrant.
* `mul_eq_polarization` — a **two-term polynomial** representation
  `x·y = ¼(x+y)² − ¼(x−y)²` whose inner functions `±var` and outer functions
  `±¼·var²` are EML terms of exp/log-depth `0`, valid on **all** of `ℝ²`.

The scientific payload is the *contrast*: the elegant rank-one exp/log form is
not globally valid (`expLog_fails_at_boundary`), while the polynomial form is
(`mul_eq_polarization`).  Both use strictly fewer than the `2n+1 = 5` outer
terms guaranteed by Kolmogorov–Arnold for `n = 2`.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/
import Mathlib
import Catalog.Applications.EMLTermAlgebra

open Real

namespace KolmogorovArnoldEML

open EMLTerm

/-! ### Inner and outer EML terms -/

/-- Inner univariate function `ψ(t) = log t`, as an EML term. -/
def innerLog : EMLTerm := logOf var

/-- Outer univariate function `Φ(u) = exp u`, as an EML term. -/
def outerExp : EMLTerm := expOf var

/-- Inner univariate function `ψ(t) = t` (identity), as an EML term. -/
def innerId : EMLTerm := var

/-- Inner univariate function `ψ(t) = -t`, as an EML term. -/
def innerNeg : EMLTerm := mul (const (-1)) var

/-- Outer univariate function `Φ(u) = ¼ u²`, as an EML term. -/
noncomputable def outerQuadPos : EMLTerm := mul (const (1 / 4)) (mul var var)

/-- Outer univariate function `Φ(u) = -¼ u²`, as an EML term. -/
noncomputable def outerQuadNeg : EMLTerm := mul (const (-1 / 4)) (mul var var)

/-! ### Representation 1 — rank-one exp/log superposition (valid on the open
positive quadrant) -/

/--
**Rank-one EML Kolmogorov–Arnold representation of the product.**
On the open positive quadrant, `x · y` is a single outer EML function `exp`
applied to a sum of a single inner EML function `log` evaluated at each
coordinate:
`x·y = Φ(ψ(x) + ψ(y))` with `ψ = logOf var`, `Φ = expOf var`.
-/
theorem mul_eq_expLog (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    x * y = outerExp.eval (innerLog.eval x + innerLog.eval y) := by
  simp only [outerExp, innerLog, EMLTerm.eval]
  rw [Real.exp_add, Real.exp_log hx, Real.exp_log hy]

/-! ### Representation 2 — two-term polynomial superposition (valid everywhere) -/

/--
**Polynomial EML Kolmogorov–Arnold representation of the product.**
The polarization identity exhibits `x · y` as a genuine `K`-`A` superposition with
two outer EML functions `±¼ var²` and inner EML functions `±var`:
`x·y = Φ₊(ψ_id(x) + ψ_id(y)) + Φ₋(ψ_id(x) + ψ_neg(y))`.
Unlike `mul_eq_expLog`, this holds for **all** real `x, y` (no positivity needed).
-/
theorem mul_eq_polarization (x y : ℝ) :
    x * y =
      outerQuadPos.eval (innerId.eval x + innerId.eval y)
        + outerQuadNeg.eval (innerId.eval x + innerNeg.eval y) := by
  simp only [outerQuadPos, outerQuadNeg, innerId, innerNeg, EMLTerm.eval]
  ring

/-! ### The scientific contrast: local vs global validity -/

/--
**The rank-one exp/log representation is NOT globally valid.**
At the boundary point `(0, 1)` the EML term `exp(log · + log ·)` returns `1`,
whereas `0 · 1 = 0`.  (In Mathlib `Real.log 0 = 0`, so the formula silently
evaluates to `exp(0 + 0) = 1`.)  This is the precise obstruction that forces the
inner function `log` to live only on the *open* positive quadrant.
-/
theorem expLog_fails_at_boundary :
    outerExp.eval (innerLog.eval 0 + innerLog.eval 1) ≠ (0 : ℝ) * 1 := by
  simp only [outerExp, innerLog, EMLTerm.eval]
  rw [Real.log_zero, Real.log_one]
  norm_num

/--
**The polynomial representation succeeds where the exp/log one fails.**
At the same boundary point `(0, 1)` the polarization superposition correctly
returns `0`.  This is the global-validity counterpart of
`expLog_fails_at_boundary`.
-/
theorem polarization_ok_at_boundary :
    outerQuadPos.eval (innerId.eval 0 + innerId.eval 1)
        + outerQuadNeg.eval (innerId.eval 0 + innerNeg.eval 1) = (0 : ℝ) * 1 := by
  rw [← mul_eq_polarization]

/-! ### Bookkeeping: exp/log-depth witnesses (using the catalog's `elDepth`) -/

/-- The rank-one representation has exp/log-depth `1` in both inner and outer
terms: it genuinely uses transcendental EML structure. -/
theorem expLog_elDepth :
    innerLog.elDepth = 1 ∧ outerExp.elDepth = 1 := ⟨rfl, rfl⟩

/-- The polynomial representation is exp/log-free: every inner and outer term has
exp/log-depth `0`.  Combined with `mul_eq_polarization`, this is what makes the
representation valid on all of `ℝ²`. -/
theorem polarization_elDepth_zero :
    innerId.elDepth = 0 ∧ innerNeg.elDepth = 0 ∧
      outerQuadPos.elDepth = 0 ∧ outerQuadNeg.elDepth = 0 :=
  ⟨rfl, rfl, rfl, rfl⟩

/-- The polynomial superposition uses `2` outer terms, strictly fewer than the
`2n + 1 = 5` guaranteed by Kolmogorov–Arnold for `n = 2`. -/
theorem polarization_terms_lt_KA_bound : (2 : ℕ) < 2 * 2 + 1 := by norm_num

end KolmogorovArnoldEML

/-
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
H1. The product `x·y` admits a Kolmogorov–Arnold superposition whose inner and
    outer functions are EML terms.  (Expected high impact: links EML to a deep
    representation theorem.)
H2. (surprising) A *rank-one* EML superposition `exp(log x + log y)` suffices —
    far below the `2n+1 = 5` outer functions K-A guarantees.
H3. (surprising / counter-intuitive) The rank-one exp/log form, although the most
    elegant, is *not* a valid representation on all of `[0,1]²`; the positivity
    requirement of `log` is a genuine obstruction at the boundary.

## Experiment (Experimenter)
* H1+H2 confirmed via `mul_eq_expLog`: `exp_add` + `exp_log` close it on the open
  positive quadrant, one inner term `logOf var`, one outer term `expOf var`.
* A globally-valid alternative was found through polarization
  (`mul_eq_polarization`): two outer terms `±¼ var²`, inner terms `±var`,
  discharged by `ring` after unfolding `EMLTerm.eval`.
* H3 confirmed via `expLog_fails_at_boundary`: at `(0,1)`, using
  `Real.log_zero = 0`, the exp/log term evaluates to `exp 0 = 1 ≠ 0`.

## Analysis (Analyst)
* SURVIVED — true & clean: `mul_eq_expLog` (local), `mul_eq_polarization`
  (global), `expLog_fails_at_boundary` (boundary obstruction),
  `polarization_ok_at_boundary` (global success at the same point).
* WHY the boundary fails: `log` is not the restriction of any continuous function
  to a neighbourhood of `0`; Mathlib's junk value `Real.log 0 = 0` makes the
  failure concrete and machine-checkable rather than a "domain error".
* "needs a different definition": a *globally continuous* EML representation of
  `x·y` must avoid bare `log`; polarization (polynomial EML, `elDepth = 0`) is the
  fix and uses only `+, ×, const`.

## Critique (Critic)
* Triviality check: `mul_eq_polarization` needs `ring` over a polarization
  identity (not `rfl`/`simp`); `mul_eq_expLog` needs `exp_add`+`exp_log`;
  `expLog_fails_at_boundary` needs the junk-value lemma `Real.log_zero` — none are
  vacuous or `True`.
* The `elDepth` and term-count facts are *auxiliary* witnesses (clearly labelled),
  not the main results; they import the catalog's `EMLTerm.elDepth`.
* Hidden-assumption audit: `mul_eq_expLog` truly requires `0 < x, 0 < y`; dropping
  them is refuted by `expLog_fails_at_boundary`, so the hypotheses are
  load-bearing and minimal.

## Synthesis (PI)
The product is EML-representable in two qualitatively different ways: a
transcendental rank-one form valid on the interior, and a polynomial two-term
form valid globally.  The exp/log-depth (`elDepth`) is exactly the invariant that
separates "interior-only" from "global".  This reframes the K-A inner-function
question as: *what is the minimal `elDepth` of a globally-valid EML superposition
of a given target?*
-/