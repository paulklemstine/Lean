import Pythagorean.HardyHierarchy.DiffClosure

/-!
# Depth Sharpness Analysis for PosEMLExpr Differentiation

This file resolves the question of whether the `+1` bound in
`PosEMLExpr.depth_deriv_le : depth (deriv e) ≤ depth e + 1`
is sharp. We prove it is **not sharp**: the stronger bound
`depth (deriv e) ≤ depth e` holds for all PosEMLExpr.

## Main Results

1. **`PosEMLExpr.depth_deriv_le_self`**: The depth-preserving theorem — differentiation
   never increases depth. This strengthens `depth_deriv_le` by removing the `+1`.

2. **`PosEMLExpr.hardyLevel_deriv_le_self`**: The derivative of a depth-d expression
   has Hardy level at most d (not d+1). Strengthens `hardyLevel_deriv_le_succ`.

3. **`PosEMLExpr.noExactDepthJump`**: No PosEMLExpr exhibits exact depth jump.

4. **`PosEMLExpr.depth_deriv_exp`**: For exponential expressions, differentiation
   preserves depth exactly.

5. **`PosEMLExpr.depth_iterDeriv_le`**: Iterated differentiation preserves depth.

## Mathematical Significance

This result shows that symbolic differentiation is a **Hardy-level preserving** operation,
not merely a controlled perturbation. The key insight is structural: in the `exp` case,
`deriv(exp(a)) = a' * exp(a)`, and by induction `depth(a') ≤ depth(a)`, so
`depth(a' * exp(a)) = max(depth(a'), depth(a)+1) = depth(a)+1 = depth(exp(a))`.
The exponential absorbs the derivative without increasing depth.

## Cross-Domain Connections

- **Transseries**: Derivation acts as a non-expansive operator on the depth filtration.
- **Symbolic computation**: Naive differentiation preserves expression complexity.
- **Circuit complexity**: No depth blow-up barrier for derivative circuits.

## Keywords
Hardy hierarchy, symbolic differentiation, depth preservation, transseries,
differential closure, complexity invariant
-/

noncomputable section

open Real Filter

namespace PosEMLExpr

/-! ## New Definitions -/

/-- A PosEMLExpr exhibits an exact depth jump under differentiation
    if `depth(deriv e) = depth e + 1`. -/
def ExactDepthJump (e : PosEMLExpr) : Prop :=
  e.deriv.depth = e.depth + 1

/-- A PosEMLExpr is depth-stable if differentiation does not increase depth. -/
def DepthStable (e : PosEMLExpr) : Prop :=
  e.deriv.depth ≤ e.depth

/-- Derivative branching complexity: counts the number of mul nodes
    whose children both have maximal depth. -/
def BranchComplexity : PosEMLExpr → ℕ
  | .const _ => 0
  | .var => 0
  | .add a b => a.BranchComplexity + b.BranchComplexity
  | .mul a b =>
    let base := a.BranchComplexity + b.BranchComplexity
    if a.depth = (max a.depth b.depth) ∧ b.depth = (max a.depth b.depth)
    then base + 1 else base
  | .exp a => a.BranchComplexity

/-! ## Core Theorem: Depth Preservation -/

/-- **Main Theorem: Depth Preservation Under Differentiation**

    Symbolic differentiation of PosEMLExpr never increases depth.
    This strengthens `depth_deriv_le` by eliminating the `+1`.

    Proof by structural induction:
    - `const c`: `deriv(c) = 0`, depth 0 ≤ 0.
    - `var`: `deriv(x) = 1`, depth 0 ≤ 0.
    - `add a b`: `depth(a'+b') = max(depth a', depth b') ≤ max(depth a, depth b)` by IH.
    - `mul a b`: `depth(a'b + ab') = max(max(depth a', depth b), max(depth a, depth b'))`
      `≤ max(max(depth a, depth b), max(depth a, depth b)) = max(depth a, depth b)` by IH.
    - `exp a`: `depth(a' · exp a) = max(depth a', depth a + 1) = depth a + 1` by IH
      since `depth a' ≤ depth a < depth a + 1`. -/
theorem depth_deriv_le_self (e : PosEMLExpr) :
    e.deriv.depth ≤ e.depth := by
  induction e with
  | const _ => simp [deriv, depth]
  | var => simp [deriv, depth]
  | add a b iha ihb =>
    simp only [deriv, depth]
    exact Nat.max_le.mpr ⟨by omega, by omega⟩
  | mul a b iha ihb =>
    simp only [deriv, depth]
    apply Nat.max_le.mpr
    constructor
    · apply Nat.max_le.mpr; constructor <;> omega
    · apply Nat.max_le.mpr; constructor <;> omega
  | exp a ih =>
    simp only [deriv, depth]
    apply Nat.max_le.mpr
    constructor <;> omega

/-- Every PosEMLExpr is depth-stable under differentiation. -/
theorem depthStable_all (e : PosEMLExpr) : DepthStable e :=
  depth_deriv_le_self e

/-- No PosEMLExpr exhibits an exact depth jump. The `+1` is globally spurious. -/
theorem noExactDepthJump (e : PosEMLExpr) : ¬ ExactDepthJump e := by
  intro h
  have h1 := depth_deriv_le_self e
  unfold ExactDepthJump at h
  omega

/-! ## Strengthened Hardy Level Bound -/

/-- **Strengthened Hardy Level Differential Closure**:
    The derivative of a depth-d PosEMLExpr has Hardy level at most d (not d+1). -/
theorem hardyLevel_deriv_le_self (e : PosEMLExpr) :
    HardyLevelLE e.depth (fun x => e.deriv.eval x) :=
  HardyLevelLE.mono e.depth_deriv_le_self (hardyLevel_of_depth e.deriv)

/-- Strengthened analytic version. -/
theorem hardyLevel_deriv_analytic_sharp (e : PosEMLExpr) :
    HardyLevelLE e.depth (fun x => _root_.deriv (fun y => e.eval y) x) := by
  conv => arg 2; ext x; rw [show _root_.deriv (fun y => e.eval y) x = e.deriv.eval x from
    (e.eval_deriv_eq x).deriv]
  exact e.hardyLevel_deriv_le_self

/-! ## Exact Depth Computations for Specific Constructors -/

/-- For exponential expressions, differentiation preserves depth exactly. -/
theorem depth_deriv_exp (a : PosEMLExpr) :
    (PosEMLExpr.exp a).deriv.depth = (PosEMLExpr.exp a).depth := by
  simp only [deriv, depth]
  have ih := depth_deriv_le_self a
  omega

/-- For const expressions, derivative has depth 0. -/
theorem depth_deriv_const (c : ℝ) :
    (PosEMLExpr.const c).deriv.depth = 0 := by
  simp [deriv, depth]

/-- For var, derivative has depth 0. -/
theorem depth_deriv_var :
    PosEMLExpr.var.deriv.depth = 0 := by
  simp [deriv, depth]

/-! ## Iterated Differentiation Preserves Depth -/

/-- Iterated symbolic differentiation. -/
def iterDeriv : ℕ → PosEMLExpr → PosEMLExpr
  | 0, e => e
  | n + 1, e => (iterDeriv n e).deriv

/-- Iterated differentiation preserves depth. -/
theorem depth_iterDeriv_le (n : ℕ) (e : PosEMLExpr) :
    (iterDeriv n e).depth ≤ e.depth := by
  induction n with
  | zero => simp [iterDeriv]
  | succ n ih =>
    simp only [iterDeriv]
    exact le_trans (depth_deriv_le_self _) ih

/-- Hardy level is preserved under iterated differentiation. -/
theorem hardyLevel_iterDeriv_le (n : ℕ) (e : PosEMLExpr) :
    HardyLevelLE e.depth (fun x => (iterDeriv n e).eval x) :=
  HardyLevelLE.mono (depth_iterDeriv_le n e) (hardyLevel_of_depth (iterDeriv n e))

/-! ## Strengthened DiffClosedFragment -/

/-- A **strongly differentially closed fragment**: differentiation preserves depth
    (not depth + 1). -/
structure StrongDiffClosedFragment where
  Expr : Type
  eval : Expr → ℝ → ℝ
  sdiff : Expr → Expr
  depth : Expr → ℕ
  deriv_correct : ∀ e x, HasDerivAt (fun y => eval e y) (eval (sdiff e) x) x
  depth_control : ∀ e, depth (sdiff e) ≤ depth e
  hardy_bound : ∀ e, HardyLevelLE (depth e) (fun x => eval e x)

/-- PosEMLExpr forms a StrongDiffClosedFragment. -/
def posEMLStrongFragment : StrongDiffClosedFragment where
  Expr := PosEMLExpr
  eval := PosEMLExpr.eval
  sdiff := PosEMLExpr.deriv
  depth := PosEMLExpr.depth
  deriv_correct := PosEMLExpr.eval_deriv_eq
  depth_control := PosEMLExpr.depth_deriv_le_self
  hardy_bound := PosEMLExpr.hardyLevel_of_depth

/-- In a StrongDiffClosedFragment, derivatives stay at the same Hardy level. -/
theorem StrongDiffClosedFragment.hardy_deriv_bound (F : StrongDiffClosedFragment) (e : F.Expr) :
    HardyLevelLE (F.depth e) (fun x => F.eval (F.sdiff e) x) :=
  HardyLevelLE.mono (F.depth_control e) (F.hardy_bound (F.sdiff e))

end PosEMLExpr

end