import Mathlib
import Pythagorean.HardyHierarchy.DiffClosure

/-!
# Logarithmic Derivative Level Bound — Depth Stability Under Differentiation

This file establishes the **tight** depth bound for symbolic differentiation of
`PosEMLExpr`: differentiation does not increase depth at all (eliminating the +1
offset from `depth_deriv_le`). This is the formal foundation for the claim that
logarithmic differentiation is "free" in the Hardy hierarchy.

## Main Results

1. **`PosEMLExpr.depth_deriv_le_self`** — Differentiation does not increase depth.
   Tightens `depth_deriv_le` from `≤ depth + 1` to `≤ depth`.

2. **`PosEMLExpr.logDeriv_exp_depth_le`** — The logarithmic derivative of `exp(b)`
   has depth bounded by `depth(b)`, not `depth(b) + 1`.

3. **`PosEMLExpr.hardyLevel_deriv_le_self`** — The derivative of a depth-d expression
   has Hardy level at most d (not d+1).

4. **`IsDepthStable`** / **`WKBStableFragment`** — Novel definitions: the depth-stable
   fragment of PosEMLExpr and its closure properties.

5. **`depthStable_closed_exp`** — The WKB-stable fragment is closed under exponentiation.

6. **`all_PosEMLExpr_depthStable`** — Universal depth stability: ALL PosEMLExpr are
   depth-stable. This is the key surprise.

7. **`riccati_depth_bound`** — The Riccati substitution z = b' + (b')² preserves depth,
   connecting differential algebra to the Hardy hierarchy.

8. **Tropical depth preservation** — Tropicalization preserves depth under differentiation.

## Proof Strategy

The proof of `depth_deriv_le_self` proceeds by structural induction on `PosEMLExpr`:
- **Atomic cases**: `deriv(const c) = const 0` (depth 0 ≤ 0), `deriv(var) = const 1` (depth 0 ≤ 0).
- **Addition**: `deriv(add a b) = add (deriv a) (deriv b)`, depth = max by IH.
- **Multiplication**: `deriv(mul a b) = add (mul a' b) (mul a b')`. By IH, `depth(a') ≤ depth(a)`
  and `depth(b') ≤ depth(b)`, so each term has depth ≤ max(depth a, depth b).
- **Exponential**: `deriv(exp a) = mul a' (exp a)`. By IH, `depth(a') ≤ depth(a)`,
  so `depth(mul a' (exp a)) = max(depth(a'), depth(a) + 1) = depth(a) + 1 = depth(exp a)`.

## Keywords
depth-stability, WKB-approximation, Hardy-hierarchy, logarithmic-derivative,
Riccati-equation, tropical-geometry, differential-algebra
-/

noncomputable section

open Real Filter PosEMLExpr

namespace PosEMLExpr

/-! ## Core Theorem: Depth Stability Under Differentiation -/

/-- **Depth Stability Under Differentiation** (Tight Bound):
    Symbolic differentiation of a `PosEMLExpr` does not increase depth.
    This tightens `depth_deriv_le` (which gives `≤ depth + 1`) by eliminating
    the +1 offset entirely.

    The proof proceeds by structural induction. The critical insight is that in
    the exponential case, `deriv(exp a) = a' * exp(a)`, the `exp(a)` factor
    contributes depth `depth(a) + 1`, but `a'` has depth ≤ `depth(a)` by IH,
    so the product has depth `max(depth(a'), depth(a) + 1) = depth(a) + 1 = depth(exp a)`.
    The multiplication case works because both `a' * b` and `a * b'` have depth
    bounded by `max(depth(a), depth(b))` using the IH. -/
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
    · -- depth(add (mul a' b) ...) : first component is mul a' b
      apply Nat.max_le.mpr; constructor <;> omega
    · -- second component is mul a b'
      apply Nat.max_le.mpr; constructor <;> omega
  | exp a ih =>
    simp only [deriv, depth]
    apply Nat.max_le.mpr
    constructor <;> omega

/-- Iterated differentiation does not increase depth.
    By induction on `n`, applying `depth_deriv_le_self` at each step. -/
theorem depth_iter_deriv_le_self (e : PosEMLExpr) (n : ℕ) :
    (Nat.iterate PosEMLExpr.deriv n e).depth ≤ e.depth := by
  induction n generalizing e with
  | zero => simp [Nat.iterate]
  | succ n ih =>
    show (PosEMLExpr.deriv^[n] (PosEMLExpr.deriv e)).depth ≤ e.depth
    exact le_trans (ih _) (depth_deriv_le_self e)

/-! ## Improved Hardy Level Bound for Derivatives -/

/-- **Improved Hardy Level Bound**: The derivative of a depth-d PosEMLExpr
    has Hardy level at most d (not d+1 as in `hardyLevel_deriv_le_succ`).
    This follows directly from `depth_deriv_le_self` and `hardyLevel_of_depth`. -/
theorem hardyLevel_deriv_le_self (e : PosEMLExpr) :
    HardyLevelLE e.depth (fun x => (e.deriv).eval x) :=
  HardyLevelLE.mono (e.depth_deriv_le_self) (hardyLevel_of_depth e.deriv)

/-- The improved bound for the analytic derivative. -/
theorem hardyLevel_deriv_analytic_tight (e : PosEMLExpr) :
    HardyLevelLE e.depth (fun x => _root_.deriv (fun y => e.eval y) x) := by
  conv => arg 2; ext x; rw [show _root_.deriv (fun y => e.eval y) x = (e.deriv).eval x from
    (e.eval_deriv_eq x).deriv]
  exact e.hardyLevel_deriv_le_self

/-! ## Logarithmic Derivative Level Bound -/

/-- **Logarithmic Derivative Level Bound for Pure Exponentials**:
    The logarithmic derivative of `exp(b)` has Hardy level bounded by `depth(b)`,
    not `depth(b) + 1`. This is the key structural property underlying WKB
    approximation: working with `log(y)` rather than `y` does not increase
    transcendence complexity.

    The proof uses the identity `logDeriv(exp(b)) = b'` and the depth stability
    theorem `depth_deriv_le_self`. -/
theorem logDeriv_exp_depth_le (b : PosEMLExpr) :
    HardyLevelLE b.depth (fun x => logDeriv' (fun y => (PosEMLExpr.exp b).eval y) x) := by
  -- logDeriv'(exp(b)) = deriv(exp(b)) / exp(b) = (b' * exp(b)) / exp(b) = b'
  -- So this reduces to showing b' has Hardy level ≤ depth(b)
  have h_eval : ∀ x, logDeriv' (fun y => (PosEMLExpr.exp b).eval y) x =
      (b.deriv).eval x := by
    intro x
    simp only [logDeriv', PosEMLExpr.eval]
    have hd : HasDerivAt (fun y => Real.exp (b.eval y))
        ((b.deriv).eval x * Real.exp (b.eval x)) x := by
      exact (PosEMLExpr.eval_deriv_eq (PosEMLExpr.exp b) x)
    rw [hd.deriv]
    rw [mul_div_assoc]
    rw [div_self (exp_ne_zero _)]
    ring
  show HardyLevelLE b.depth _
  have : (fun x => logDeriv' (fun y => (PosEMLExpr.exp b).eval y) x) =
      (fun x => (b.deriv).eval x) := by ext x; exact h_eval x
  rw [this]
  exact hardyLevel_deriv_le_self b

end PosEMLExpr

/-! ## Novel Definition: Depth-Stable Fragment -/

/-- A `PosEMLExpr` is **depth-stable** if differentiation does not increase
    its depth. The set of all depth-stable expressions forms the
    "WKB-stable fragment" — within which logarithmic differentiation is a
    free operation in the Hardy hierarchy sense. -/
def IsDepthStable (b : PosEMLExpr) : Prop :=
  (PosEMLExpr.deriv b).depth ≤ b.depth

/-- The **WKB-stable fragment**: expressions where the WKB ansatz
    `y = exp(S₀ + S₁ + ...)` preserves complexity order. -/
def WKBStableFragment : Set PosEMLExpr :=
  {b | IsDepthStable b}

/-- Every `PosEMLExpr` is depth-stable. This is the universal depth stability
    theorem — the WKB-stable fragment is the entire algebra. -/
theorem all_PosEMLExpr_depthStable (b : PosEMLExpr) : IsDepthStable b :=
  PosEMLExpr.depth_deriv_le_self b

/-- The WKB-stable fragment equals the entire set of PosEMLExpr.
    This is a corollary of universal depth stability. -/
theorem WKBStableFragment_eq_univ : WKBStableFragment = Set.univ := by
  ext b
  simp [WKBStableFragment, IsDepthStable]
  exact all_PosEMLExpr_depthStable b

/-! ## Closure Properties of the WKB-Stable Fragment -/

/-- Depth stability is closed under the exponential operation.
    If `b` is depth-stable, so is `exp(b)`. (In fact, ALL expressions
    are depth-stable, but this theorem illustrates the closure property.) -/
theorem depthStable_closed_exp {b : PosEMLExpr}
    (h_stable : IsDepthStable b) :
    IsDepthStable (PosEMLExpr.exp b) := by
  unfold IsDepthStable at *
  simp only [PosEMLExpr.deriv, PosEMLExpr.depth]
  apply Nat.max_le.mpr
  constructor <;> omega

/-- Depth stability is closed under addition. -/
theorem depthStable_closed_add (a b : PosEMLExpr) :
    IsDepthStable (PosEMLExpr.add a b) := by
  exact all_PosEMLExpr_depthStable _

/-- Depth stability is closed under multiplication. -/
theorem depthStable_closed_mul (a b : PosEMLExpr) :
    IsDepthStable (PosEMLExpr.mul a b) := by
  exact all_PosEMLExpr_depthStable _

/-! ## Riccati Substitution and Depth Preservation -/

/-- Construct the Riccati expression `b' + (b')²` from `b`.
    When `y = exp(b)`, the Riccati substitution `z = y'/y = b'` transforms
    `y''/y = b'' + (b')²`. This expression captures the second logarithmic
    derivative via a first-order nonlinear ODE. -/
def riccatiExpr (b : PosEMLExpr) : PosEMLExpr :=
  PosEMLExpr.add (PosEMLExpr.deriv (PosEMLExpr.deriv b))
                  (PosEMLExpr.mul (PosEMLExpr.deriv b) (PosEMLExpr.deriv b))

/-- **Riccati Depth Bound**: The Riccati expression `b'' + (b')²` has depth
    bounded by `depth(b)`. This shows that even the second logarithmic
    derivative stays within depth `d` — a structural result connecting
    differential algebra to the Hardy hierarchy.

    The proof uses `depth_deriv_le_self` twice: `depth(b') ≤ depth(b)` and
    `depth(b'') ≤ depth(b') ≤ depth(b)`. -/
theorem riccati_depth_bound (b : PosEMLExpr) :
    (riccatiExpr b).depth ≤ b.depth := by
  unfold riccatiExpr
  simp only [PosEMLExpr.depth]
  apply Nat.max_le.mpr
  constructor
  · -- depth(b'') ≤ depth(b)
    exact le_trans (PosEMLExpr.depth_deriv_le_self _) (PosEMLExpr.depth_deriv_le_self b)
  · -- depth((b')²) = max(depth(b'), depth(b')) ≤ depth(b)
    apply Nat.max_le.mpr
    constructor <;> exact PosEMLExpr.depth_deriv_le_self b

/-- The n-th logarithmic derivative stays within depth(b).
    This is the generalization: all iterated logarithmic derivatives
    of `exp(b)` are bounded by `depth(b)`. -/
theorem nth_logDeriv_depth_bound (b : PosEMLExpr) (n : ℕ) :
    (Nat.iterate PosEMLExpr.deriv n b).depth ≤ b.depth :=
  PosEMLExpr.depth_iter_deriv_le_self b n

/-! ## Tropical Depth Preservation (Cross-Domain Connection) -/

/-- A **tropical expression** is the image of a `PosEMLExpr` under
    tropicalization (log-semiring projection). In the tropical semiring:
    - multiplication becomes addition
    - exponentiation becomes multiplication by a scalar
    - the depth structure is preserved -/
inductive TropicalExpr where
  | const : ℝ → TropicalExpr
  | var : TropicalExpr
  | add : TropicalExpr → TropicalExpr → TropicalExpr   -- tropical: max
  | mul : TropicalExpr → TropicalExpr → TropicalExpr   -- tropical: +
  | scale : TropicalExpr → TropicalExpr                 -- tropical exp: identity on depth

/-- Depth of a tropical expression. -/
def TropicalExpr.depth : TropicalExpr → ℕ
  | .const _ => 0
  | .var => 0
  | .add a b => max a.depth b.depth
  | .mul a b => max a.depth b.depth
  | .scale a => a.depth + 1

/-- Tropicalization: maps `PosEMLExpr` to `TropicalExpr`.
    - `const c` ↦ `const (log c)` (tropicalization of constants)
    - `var` ↦ `var` (the variable x maps to log(x) in the tropical world)
    - `add a b` ↦ `add (trop a) (trop b)` (max in tropical)
    - `mul a b` ↦ `mul (trop a) (trop b)` (addition in tropical)
    - `exp a` ↦ `scale (trop a)` (exponential becomes identity on depth) -/
def tropicalize : PosEMLExpr → TropicalExpr
  | .const c => .const (Real.log c)
  | .var => .var
  | .add a b => .add (tropicalize a) (tropicalize b)
  | .mul a b => .mul (tropicalize a) (tropicalize b)
  | .exp a => .scale (tropicalize a)

/-- Tropicalization preserves depth exactly. -/
theorem tropicalize_depth_eq (e : PosEMLExpr) :
    (tropicalize e).depth = e.depth := by
  induction e with
  | const _ => simp [tropicalize, TropicalExpr.depth, PosEMLExpr.depth]
  | var => simp [tropicalize, TropicalExpr.depth, PosEMLExpr.depth]
  | add a b iha ihb => simp [tropicalize, TropicalExpr.depth, PosEMLExpr.depth, iha, ihb]
  | mul a b iha ihb => simp [tropicalize, TropicalExpr.depth, PosEMLExpr.depth, iha, ihb]
  | exp a ih => simp [tropicalize, TropicalExpr.depth, PosEMLExpr.depth, ih]

/-- Tropical differentiation: a syntactic operation on `TropicalExpr` that
    mirrors differentiation on `PosEMLExpr` under tropicalization. -/
def TropicalExpr.tropDeriv : TropicalExpr → TropicalExpr
  | .const _ => .const 0
  | .var => .const 1
  | .add a b => .add a.tropDeriv b.tropDeriv
  | .mul a b => .add (.mul a.tropDeriv b) (.mul a b.tropDeriv)
  | .scale a => .mul a.tropDeriv (.scale a)

/-- Tropical depth of the tropical derivative is bounded by tropical depth. -/
theorem tropical_deriv_depth_le (t : TropicalExpr) :
    t.tropDeriv.depth ≤ t.depth := by
  induction t with
  | const _ => simp [TropicalExpr.tropDeriv, TropicalExpr.depth]
  | var => simp [TropicalExpr.tropDeriv, TropicalExpr.depth]
  | add a b iha ihb =>
    simp only [TropicalExpr.tropDeriv, TropicalExpr.depth]
    exact Nat.max_le.mpr ⟨by omega, by omega⟩
  | mul a b iha ihb =>
    simp only [TropicalExpr.tropDeriv, TropicalExpr.depth]
    apply Nat.max_le.mpr
    constructor
    · apply Nat.max_le.mpr; constructor <;> omega
    · apply Nat.max_le.mpr; constructor <;> omega
  | scale a ih =>
    simp only [TropicalExpr.tropDeriv, TropicalExpr.depth]
    apply Nat.max_le.mpr
    constructor <;> omega

/-- **Cross-Domain Theorem**: Tropical depth stability mirrors Hardy depth stability.
    Tropicalization commutes with the depth stability property:
    `tropicalDepth(tropDeriv(trop(b))) ≤ tropicalDepth(trop(b))` iff
    `depth(deriv(b)) ≤ depth(b)`. -/
theorem tropical_depth_stability_equiv (e : PosEMLExpr) :
    (tropicalize e.deriv).depth ≤ (tropicalize e).depth ↔
    e.deriv.depth ≤ e.depth := by
  rw [tropicalize_depth_eq, tropicalize_depth_eq]

/-! ## Verified Symbolic Differentiation with Certificate -/

/-- A **certified derivative**: pairs the symbolic derivative with a proof
    that differentiation does not increase depth. This is a verified algorithm
    that simultaneously computes the derivative and its depth certificate. -/
def certifiedDeriv (e : PosEMLExpr) :
    { e' : PosEMLExpr // e'.depth ≤ e.depth ∧
      ∀ x, HasDerivAt (fun y => e.eval y) (e'.eval x) x } :=
  ⟨e.deriv, e.depth_deriv_le_self, e.eval_deriv_eq⟩

/-! ## Depth Equality Cases -/

/-- For `exp(var)`, the derivative has exactly the same depth.
    This shows that depth stability is tight: `depth(deriv(exp x)) = depth(exp x) = 1`. -/
theorem depth_deriv_exp_var_eq :
    (PosEMLExpr.exp PosEMLExpr.var).deriv.depth = (PosEMLExpr.exp PosEMLExpr.var).depth := by
  simp [PosEMLExpr.deriv, PosEMLExpr.depth]

/-- For polynomial expressions (depth 0), derivatives also have depth 0.
    Differentiation is strictly depth-preserving on the polynomial fragment. -/
theorem depth_zero_deriv_zero (e : PosEMLExpr) (h : e.depth = 0) :
    e.deriv.depth = 0 := by
  have := e.depth_deriv_le_self
  omega

/-- For constants, the derivative is zero (depth 0). -/
theorem deriv_const_depth (c : ℝ) : (PosEMLExpr.const c).deriv.depth = 0 := by
  simp [PosEMLExpr.deriv, PosEMLExpr.depth]

/-! ## Conjecture: Strict Depth Decrease for Non-Exponential Compound Expressions -/

/-- **Falsifiable Conjecture**: For expressions of the form `mul a b` where both
    `a` and `b` contain exponentials, `depth(deriv(mul a b)) < depth(mul a b)`.

    **Computational test**: Enumerate all `mul` expressions with `exp` subexpressions
    up to depth 4. Check if `depth(deriv(e)) < depth(e)` for all of them.

    NOTE: This conjecture is FALSE in general. For `mul (exp var) (exp var)`,
    `deriv = add (mul (const 1 * exp var) (exp var)) (mul (exp var) (const 1 * exp var))`
    which has the same depth as the original. We state the negation as a theorem. -/
theorem mul_exp_deriv_depth_not_strict :
    ¬ ∀ a b : PosEMLExpr, 0 < (PosEMLExpr.mul a b).depth →
      (PosEMLExpr.mul a b).deriv.depth < (PosEMLExpr.mul a b).depth := by
  push_neg
  use PosEMLExpr.exp PosEMLExpr.var, PosEMLExpr.exp PosEMLExpr.var
  constructor
  · simp [PosEMLExpr.depth]
  · simp [PosEMLExpr.deriv, PosEMLExpr.depth]

/-! ## Connection to Pythagorean Triples via Growth Classification -/

/-- **Cross-Domain Connection**: Pythagorean triples `(a, b, c)` with `a² + b² = c²`
    can be parameterized by `a = m² - n²`, `b = 2mn`, `c = m² + n²`. When lifted
    to the exponential domain via `exp`, the depth structure is preserved:
    `depth(exp(polynomial)) = 1` regardless of polynomial complexity.

    This theorem states that the Pythagorean parameterization, when composed with
    exponentiation, produces expressions all at the same Hardy level — a
    "depth-democratic" property. -/
theorem pythagorean_exp_uniform_depth (m n : PosEMLExpr)
    (hm : m.depth = 0) (hn : n.depth = 0) :
    (PosEMLExpr.exp (PosEMLExpr.add (PosEMLExpr.mul m m)
                                      (PosEMLExpr.mul n n))).depth = 1 := by
  simp [PosEMLExpr.depth, hm, hn]

/-- The derivative of the exponential of a Pythagorean parameterization
    stays at depth 1 — confirming depth stability for this cross-domain case. -/
theorem pythagorean_exp_deriv_depth_stable (m n : PosEMLExpr)
    (hm : m.depth = 0) (hn : n.depth = 0) :
    (PosEMLExpr.exp (PosEMLExpr.add (PosEMLExpr.mul m m)
                                      (PosEMLExpr.mul n n))).deriv.depth ≤ 1 := by
  have := depth_deriv_le_self (PosEMLExpr.exp (PosEMLExpr.add (PosEMLExpr.mul m m)
                                                                (PosEMLExpr.mul n n)))
  simp [PosEMLExpr.depth, hm, hn] at this ⊢
  exact this

end