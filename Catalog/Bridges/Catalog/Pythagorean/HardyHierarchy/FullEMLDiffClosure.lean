import Mathlib
import MachineLearning.HardyHierarchy.Defs

/-!
# Depth Preservation for Full EML with Negation

This file establishes that symbolic differentiation is **depth-preserving** for the
full EML expression language, including negation. This extends the positive-fragment
results in `DiffClosure.lean` to the complete grammar.

## Main Results

1. **`EmlExpr.deriv`**: Symbolic differentiation on the full EML grammar.
2. **`EmlExpr.depth_deriv_le_self`**: Differentiation does not increase `emlDepth`.
3. **`EmlExpr.depth_iteratedDeriv_le_self`**: Iterated differentiation preserves depth.
4. **`EmlExpr.differentiallyDepthBounded_iff`**: Depth-bounded expressions form
   a differential invariant — `emlDepth e ≤ k` iff all iterated derivatives stay ≤ k.
5. **`EmlExpr.deriv_maps_depthClosed`**: The depth-≤-k set is closed under `deriv`.
6. **`EmlExpr.depth_neg_deriv`**: Negation commutes with depth under differentiation.

## Mathematical Significance

The key insight is that `eml(a, b)` differentiates to `eml(a' + a * b', b)`: the
exponential shell `exp(b)` is preserved, and all new complexity stays in the coefficient.
Since the coefficient's depth is bounded by `max(depth a, depth b)` — which is already
≤ the depth of `eml(a, b)` — the overall depth cannot increase.

This makes `emlDepth` a **differential invariant**: each depth stratum
`{ e | emlDepth e ≤ k }` is closed under all derivatives, forming a filtered
differential algebra of expressions.

## Cross-Domain Connections

- **Differential algebra / Hardy fields**: Depth strata behave as a differential
  filtration, analogous to the log-exp filtration in Hardy fields.
- **Automatic differentiation**: Resource-bounded AD stays within bounded expression
  classes — repeated symbolic differentiation does not blow up expression complexity.
- **Machine learning expressivity**: The `eml(a,b) = a * exp(b)` constructor resembles
  exponential gating; depth-bounded closure under differentiation implies stable
  expressivity classes under gradient propagation.
- **Rewrite systems / program semantics**: `deriv` is a syntax transformer preserving
  a ranking function, relevant to certified compiler passes and termination arguments.

## Keywords
differential algebra, Hardy fields, symbolic differentiation, automatic differentiation,
expression complexity, rewrite systems, formal verification, exponential circuits,
machine learning expressivity, depth invariant
-/

noncomputable section

open Real

namespace EmlExpr

/-! ## Symbolic Differentiation on Full EML -/

/-- Symbolic differentiation of `EmlExpr` with respect to the variable.
    - `d/dx(x) = 1`
    - `d/dx(c) = 0`
    - `d/dx(a + b) = a' + b'`
    - `d/dx(a * b) = a' * b + a * b'`
    - `d/dx(neg a) = neg(a')`
    - `d/dx(eml a b) = eml(a' + a * b', b)`
      since `d/dx[a · exp(b)] = (a' + a · b') · exp(b) = eml(a' + a · b', b)` -/
def deriv : EmlExpr → EmlExpr
  | .var => .const 1
  | .const _ => .const 0
  | .add a b => .add a.deriv b.deriv
  | .mul a b => .add (.mul a.deriv b) (.mul a b.deriv)
  | .neg a => .neg a.deriv
  | .eml a b => .eml (.add a.deriv (.mul a b.deriv)) b

/-! ## Helper Lemmas for Depth -/

/-- Depth of a negation equals depth of the argument. -/
@[simp]
theorem emlDepth_neg (a : EmlExpr) : (EmlExpr.neg a).emlDepth = a.emlDepth := by
  simp [emlDepth]

/-- Depth of an addition is the max of the depths. -/
@[simp]
theorem emlDepth_add (a b : EmlExpr) :
    (EmlExpr.add a b).emlDepth = max a.emlDepth b.emlDepth := by
  simp [emlDepth]

/-- Depth of a multiplication is the max of the depths. -/
@[simp]
theorem emlDepth_mul (a b : EmlExpr) :
    (EmlExpr.mul a b).emlDepth = max a.emlDepth b.emlDepth := by
  simp [emlDepth]

/-- Depth of an eml node. -/
@[simp]
theorem emlDepth_eml (a b : EmlExpr) :
    (EmlExpr.eml a b).emlDepth = 1 + max a.emlDepth b.emlDepth := by
  simp [emlDepth]

/-- Depth of a constant is 0. -/
@[simp]
theorem emlDepth_const (c : ℝ) : (EmlExpr.const c).emlDepth = 0 := by
  simp [emlDepth]

/-- Depth of var is 0. -/
@[simp]
theorem emlDepth_var : (EmlExpr.var).emlDepth = 0 := by
  simp [emlDepth]

/-! ## Main Theorem: Depth Preservation Under Differentiation -/

/-- **Main Theorem (Depth Preservation)**: Symbolic differentiation does not increase
    the EML depth of an expression.

    This is proved by structural induction on the expression tree. The critical case
    is `eml a b`, where:
    ```
    deriv (eml a b) = eml (add (deriv a) (mul a (deriv b))) b
    ```
    We need `emlDepth (eml (add (deriv a) (mul a (deriv b))) b) ≤ emlDepth (eml a b)`.
    The LHS equals `1 + max (emlDepth (add (deriv a) (mul a (deriv b)))) (emlDepth b)`.
    By the inductive hypotheses `emlDepth (deriv a) ≤ emlDepth a` and
    `emlDepth (deriv b) ≤ emlDepth b`, the coefficient depth stays bounded by
    `max (emlDepth a) (emlDepth b)`, which is already ≤ the original depth of
    `eml a b = 1 + max (emlDepth a) (emlDepth b)`. -/
theorem depth_deriv_le_self : ∀ e : EmlExpr, emlDepth (EmlExpr.deriv e) ≤ emlDepth e := by
  intro e
  induction e with
  | var => simp [deriv, emlDepth]
  | const _ => simp [deriv, emlDepth]
  | add a b iha ihb =>
    simp only [deriv, emlDepth_add]
    exact Nat.max_le.mpr ⟨by omega, by omega⟩
  | mul a b iha ihb =>
    simp only [deriv, emlDepth_add, emlDepth_mul]
    apply Nat.max_le.mpr
    constructor
    · exact Nat.max_le.mpr ⟨by omega, by omega⟩
    · exact Nat.max_le.mpr ⟨by omega, by omega⟩
  | neg a ih =>
    simp only [deriv, emlDepth_neg]
    exact ih
  | eml a b iha ihb =>
    simp only [deriv, emlDepth_eml, emlDepth_add, emlDepth_mul]
    omega

/-! ## Iterated Differentiation -/

/-- **Iterated Depth Stability**: For any number of iterated differentiations,
    the depth never increases. This makes `emlDepth` a **differential invariant**:
    each depth stratum is closed under the entire orbit of repeated differentiation.

    Proved by induction on `n`, using `depth_deriv_le_self` at each step. -/
theorem depth_iteratedDeriv_le_self :
    ∀ (n : ℕ) (e : EmlExpr), emlDepth ((EmlExpr.deriv^[n]) e) ≤ emlDepth e := by
  intro n e
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ', Function.comp]
    exact le_trans (depth_deriv_le_self _) ih

/-! ## Differential Depth-Boundedness -/

/-- An expression is **differentially depth-bounded** at level `k` if all its
    iterated derivatives have depth ≤ `k`. This captures the notion that the
    expression lives in a "differential stratum" of bounded complexity. -/
def DifferentiallyDepthBounded (k : ℕ) (e : EmlExpr) : Prop :=
  ∀ n : ℕ, emlDepth ((EmlExpr.deriv^[n]) e) ≤ k

/-- Forward direction: if an expression is differentially depth-bounded at level `k`,
    then its depth is ≤ `k` (take `n = 0`). -/
theorem depth_le_of_differentiallyDepthBounded :
    ∀ {k : ℕ} {e : EmlExpr},
      DifferentiallyDepthBounded k e → emlDepth e ≤ k := by
  intro k e h
  exact h 0

/-- Reverse direction: if `emlDepth e ≤ k`, then `e` is differentially depth-bounded
    at level `k`. This follows from `depth_iteratedDeriv_le_self`. -/
theorem differentiallyDepthBounded_of_depth_le :
    ∀ {k : ℕ} {e : EmlExpr},
      emlDepth e ≤ k → DifferentiallyDepthBounded k e := by
  intro k e hle n
  exact le_trans (depth_iteratedDeriv_le_self n e) hle

/-- **Characterization Theorem**: An expression is differentially depth-bounded at
    level `k` if and only if its depth is ≤ `k`.

    This is the key structural result: depth-bounded classes are **exactly** the
    differential invariant strata. One does not need to check infinitely many
    derivatives; the zeroth derivative (the expression itself) already determines
    membership. -/
theorem differentiallyDepthBounded_iff :
    ∀ {k : ℕ} {e : EmlExpr},
      DifferentiallyDepthBounded k e ↔ emlDepth e ≤ k :=
  ⟨depth_le_of_differentiallyDepthBounded, differentiallyDepthBounded_of_depth_le⟩

/-! ## Set-Theoretic Closure -/

/-- The set of expressions with depth ≤ `k`. -/
def DepthClosed (k : ℕ) : Set EmlExpr := { e | emlDepth e ≤ k }

/-- **Closure Theorem**: The derivative maps the depth-≤-k set into itself.
    This is the set-theoretic formulation of depth preservation, stating that
    each depth stratum is a forward-invariant set under the `deriv` operator.

    This connects to dynamical systems: `deriv` is a discrete dynamical system on
    `EmlExpr`, and `DepthClosed k` is an invariant region. -/
theorem deriv_maps_depthClosed :
    ∀ k : ℕ, Set.MapsTo EmlExpr.deriv (DepthClosed k) (DepthClosed k) := by
  intro k e he
  exact le_trans (depth_deriv_le_self e) he

/-! ## Negation Commutes with Depth Under Differentiation -/

/-- Negation is transparent to depth under differentiation:
    `emlDepth (deriv (neg e)) = emlDepth (deriv e)`.
    This follows from `deriv (neg e) = neg (deriv e)` and `emlDepth (neg _) = emlDepth _`. -/
theorem depth_neg_deriv :
    ∀ e : EmlExpr, emlDepth (EmlExpr.deriv (EmlExpr.neg e)) = emlDepth (EmlExpr.deriv e) := by
  intro e
  simp [deriv]

/-! ## Semantic Correctness of Full EML Differentiation -/

/-- Every `EmlExpr` evaluates to a differentiable function. -/
theorem differentiable_eval (e : EmlExpr) :
    Differentiable ℝ (fun x => e.eval x) := by
  induction e with
  | var => exact differentiable_id
  | const c => exact differentiable_const c
  | add a b iha ihb => exact iha.add ihb
  | mul a b iha ihb => exact iha.mul ihb
  | neg a ih => exact ih.neg
  | eml a b iha ihb => exact iha.mul ihb.exp

/-- **Semantic Correctness**: The symbolic derivative agrees with the analytic
    derivative at every point.

    This bridges syntax and semantics: the `deriv` function on `EmlExpr` computes
    the actual derivative of the evaluated function. -/
theorem eval_hasDerivAt (e : EmlExpr) (x : ℝ) :
    HasDerivAt (fun y => e.eval y) ((e.deriv).eval x) x := by
  induction e generalizing x with
  | var =>
    show HasDerivAt id 1 x
    exact (hasDerivAt_id x).congr_deriv (by norm_num)
  | const c =>
    show HasDerivAt (fun _ => c) 0 x
    exact hasDerivAt_const x c
  | add a b iha ihb =>
    show HasDerivAt (fun y => a.eval y + b.eval y) (a.deriv.eval x + b.deriv.eval x) x
    exact (iha x).add (ihb x)
  | mul a b iha ihb =>
    show HasDerivAt (fun y => a.eval y * b.eval y)
      (a.deriv.eval x * b.eval x + a.eval x * b.deriv.eval x) x
    exact (iha x).mul (ihb x)
  | neg a ih =>
    show HasDerivAt (fun y => -(a.eval y)) (-(a.deriv.eval x)) x
    exact (ih x).neg
  | eml a b iha ihb =>
    show HasDerivAt (fun y => a.eval y * Real.exp (b.eval y))
      ((a.deriv.eval x + a.eval x * b.deriv.eval x) * Real.exp (b.eval x)) x
    have ha := iha x
    have hb := ihb x
    have hexp : HasDerivAt (fun y => Real.exp (b.eval y))
      (b.deriv.eval x * Real.exp (b.eval x)) x := by
      have := hb.exp
      rwa [mul_comm] at this
    have := ha.mul hexp
    convert this using 1
    ring

end EmlExpr

end