/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The `tropical` Tactic

A proof-producing decision procedure for the additive-commutative-idempotent
fragment of tropical (min-plus) algebra.

## What the tactic solves

Goals of the form `⊢ t₁ = t₂` where `t₁, t₂` are built from:
- Real-valued variables
- Binary `min`
- Binary `+` (real addition)

## Usage

```lean
example (a b c : ℝ) : min (a + b) (b + a) = a + b := by tropical
```
-/

import Tropical.Reflection
import Lean

open Lean Meta Elab Tactic
open CTropExpr

/-! ## Reification Engine -/

/-- State for the reifier: maps Lean expressions to CTropExpr variable indices. -/
structure ReifyState where
  /-- Pairs of (Lean expression, variable index) -/
  varMap : Array (Expr × ℕ) := #[]
  /-- Next fresh variable index -/
  nextVar : ℕ := 0

/-- Look up or create a variable index for a Lean expression. -/
def ReifyState.getOrInsert (s : ReifyState) (e : Expr) : ReifyState × ℕ := Id.run do
  for (e', idx) in s.varMap do
    if e == e' then return (s, idx)
  let idx := s.nextVar
  ({ varMap := s.varMap.push (e, idx), nextVar := idx + 1 }, idx)

/-- Reify a Lean expression of type ℝ into a CTropExpr syntax term. -/
partial def reifyExpr (s : ReifyState) (e : Expr) : MetaM (ReifyState × Expr) := do
  let e ← whnfR e
  -- Try to match `Min.min a b`
  match e.getAppFnArgs with
  | (``Min.min, #[_, _, a, b]) =>
    let (s, ea) ← reifyExpr s a
    let (s, eb) ← reifyExpr s b
    return (s, mkApp2 (mkConst ``CTropExpr.tmin) ea eb)
  | (``HAdd.hAdd, #[_, _, _, _, a, b]) =>
    let (s, ea) ← reifyExpr s a
    let (s, eb) ← reifyExpr s b
    return (s, mkApp2 (mkConst ``CTropExpr.add) ea eb)
  | _ =>
    -- Treat as a variable
    let (s, idx) := s.getOrInsert e
    return (s, mkApp (mkConst ``CTropExpr.var) (mkNatLit idx))

/-- Build the σ function as a Lean expression: `fun n => ...` with nested ite. -/
def buildSigma (s : ReifyState) : MetaM Expr := do
  let realTy := mkConst ``Real
  let zeroExpr ← mkAppOptM ``OfNat.ofNat #[some realTy, some (mkNatLit 0), none]
  withLocalDeclD `n (mkConst ``Nat) fun nVar => do
    let mut body := zeroExpr
    for i in List.range s.varMap.size |>.reverse do
      let (expr, idx) := s.varMap[i]!
      let condExpr ← mkAppM ``Eq #[nVar, mkNatLit idx]
      let instExpr ← mkAppM ``instDecidableEqNat #[nVar, mkNatLit idx]
      body ← mkAppOptM ``ite #[some realTy, some condExpr, some instExpr, some expr, some body]
    mkLambdaFVars #[nVar] body

/-- The `tropical` tactic: automatically solves tropical min-plus equalities. -/
elab "tropical" : tactic => withMainContext do
  let goal ← getMainGoal
  let goalTy ← goal.getType
  let some (_, lhs, rhs) := goalTy.eq?
    | throwError "tropical: goal is not an equality"
  -- Reify both sides
  let (s, eLhs) ← reifyExpr {} lhs
  let (s, eRhs) ← reifyExpr s rhs
  -- Build σ
  let sigma ← buildSigma s
  -- Build the normalization equality goal
  let normEqTy ← mkAppM ``Eq #[
    mkApp (mkConst ``CTropExpr.cnormalize_ca) eLhs,
    mkApp (mkConst ``CTropExpr.cnormalize_ca) eRhs]
  -- Create an auxiliary goal for the normalization equality and solve with native_decide
  let normEqProof ← mkFreshExprMVar normEqTy
  let normEqGoalId := normEqProof.mvarId!
  -- Use native_decide to solve the normalization equality
  try
    let gs ← Tactic.run normEqGoalId (evalTactic (← `(tactic| native_decide)))
    unless gs.isEmpty do
      throwError "tropical: native_decide left unsolved goals"
  catch _ =>
    throwError "tropical: normalization did not produce equal forms — the expressions may not be ACI-equivalent"
  -- Apply the reflection theorem
  let proof := mkApp3 (mkConst ``cnormalize_ca_eq_implies_semantic_eq) eLhs eRhs normEqProof
  let proofApp := mkApp proof sigma
  goal.assign proofApp