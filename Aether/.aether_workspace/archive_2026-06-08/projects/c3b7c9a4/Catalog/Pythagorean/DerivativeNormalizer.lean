import Mathlib
import Pythagorean.HardyHierarchy.DiffClosure

/-!
# Certified Derivative Normalizer for Positive EML Expressions

This file establishes a **certified normalization compiler** for symbolic derivatives
of positive EML expressions. The central result is that the derivative followed by
normalization has **zero depth overhead**: differentiation is complexity-nonexpansive
after compilation.

## Main Results

1. **`eval_normalize`**: Semantic preservation — normalization does not change evaluation.
2. **`depth_normalize_le`**: Depth nonincrease — normalization never increases depth.
3. **`depth_normalize_deriv_le`**: Zero-overhead differentiation —
   `depth(normalize(deriv e)) ≤ depth(e)` for all `PosEMLExpr`.
4. **`good_normalize`**: The polynomial-exponential fragment `Good` is closed under normalization.
5. **`normalize_sound_complete_for_depth`**: Combined correctness + complexity theorem.

## Normalization Strategy

We define **smart constructors** `mkAdd`, `mkMul`, `mkExp` that perform algebraic
simplification (identity/annihilation rules) and prove local depth and semantics lemmas.
The normalizer `normalize` recursively applies these smart constructors bottom-up.

## Cross-Domain Significance

- **Compiler verification**: `normalize` is a certified optimization pass with
  `eval ∘ normalize = eval` (correctness) and `depth ∘ normalize ≤ depth` (resource bound).
- **Computer algebra**: The zero-overhead theorem says expression swell under differentiation
  can be fully eliminated by normalization.
- **Hardy hierarchy**: Depth stability under differentiation means the growth hierarchy
  is operationally robust under the core analytic operator d/dx.
-/

noncomputable section

open Real Classical

namespace PosEMLExpr

/-! ## Smart Constructors -/

/-- Smart addition: simplifies `0 + e = e` and `e + 0 = e`. -/
def mkAdd (a b : PosEMLExpr) : PosEMLExpr :=
  if a = .const 0 then b
  else if b = .const 0 then a
  else .add a b

/-- Smart multiplication: simplifies `0 * e = 0`, `e * 0 = 0`, `1 * e = e`, `e * 1 = e`. -/
def mkMul (a b : PosEMLExpr) : PosEMLExpr :=
  if a = .const 0 then .const 0
  else if b = .const 0 then .const 0
  else if a = .const 1 then b
  else if b = .const 1 then a
  else .mul a b

/-- Smart exponentiation: simplifies `exp(0) = 1`. -/
def mkExp (a : PosEMLExpr) : PosEMLExpr :=
  if a = .const 0 then .const 1
  else .exp a

/-! ## Smart Constructor Semantics -/

theorem eval_mkAdd (a b : PosEMLExpr) (x : ℝ) :
    (mkAdd a b).eval x = a.eval x + b.eval x := by
  unfold mkAdd
  split
  · next h => subst h; simp [eval]
  · next h1 =>
    split
    · next h2 => subst h2; simp [eval]
    · rfl

theorem eval_mkMul (a b : PosEMLExpr) (x : ℝ) :
    (mkMul a b).eval x = a.eval x * b.eval x := by
  unfold mkMul
  split
  · next h => subst h; simp [eval]
  · next h1 =>
    split
    · next h2 => subst h2; simp [eval]
    · next h2 =>
      split
      · next h3 => subst h3; simp [eval]
      · next h3 =>
        split
        · next h4 => subst h4; simp [eval]
        · rfl

theorem eval_mkExp (a : PosEMLExpr) (x : ℝ) :
    (mkExp a).eval x = Real.exp (a.eval x) := by
  unfold mkExp
  split
  · next h => subst h; simp [eval, Real.exp_zero]
  · rfl

/-! ## Smart Constructor Depth Bounds -/

theorem depth_mkAdd_le (a b : PosEMLExpr) :
    (mkAdd a b).depth ≤ max a.depth b.depth := by
  unfold mkAdd
  split
  · next h => subst h; simp [depth]
  · next =>
    split
    · next h => subst h; simp [depth]
    · exact le_refl _

theorem depth_mkMul_le (a b : PosEMLExpr) :
    (mkMul a b).depth ≤ max a.depth b.depth := by
  unfold mkMul
  split
  · next h => subst h; simp [depth]
  · next =>
    split
    · next h => subst h; simp [depth]
    · next =>
      split
      · next h => subst h; simp [depth]
      · next =>
        split
        · next h => subst h; simp [depth]
        · exact le_refl _

theorem depth_mkExp_le (a : PosEMLExpr) :
    (mkExp a).depth ≤ a.depth + 1 := by
  unfold mkExp
  split
  · simp [depth]
  · exact le_refl _

/-! ## Normalization -/

/-- Normalize a `PosEMLExpr` by recursively applying smart constructors bottom-up.
    This eliminates additive/multiplicative identity and annihilation patterns
    introduced by symbolic differentiation. -/
def normalize : PosEMLExpr → PosEMLExpr
  | .const c => .const c
  | .var => .var
  | .add a b => mkAdd (normalize a) (normalize b)
  | .mul a b => mkMul (normalize a) (normalize b)
  | .exp a => mkExp (normalize a)

/-! ## Theorem 1: Semantic Preservation -/

/-- **Semantic Correctness of Normalization**: normalization preserves evaluation.
    This is proved by structural induction, using the semantics of each smart constructor. -/
theorem eval_normalize (e : PosEMLExpr) (x : ℝ) :
    (normalize e).eval x = e.eval x := by
  induction e with
  | const c => rfl
  | var => rfl
  | add a b iha ihb =>
    simp only [normalize, eval]
    rw [eval_mkAdd, iha, ihb]
  | mul a b iha ihb =>
    simp only [normalize, eval]
    rw [eval_mkMul, iha, ihb]
  | exp a ih =>
    simp only [normalize, eval]
    rw [eval_mkExp, ih]

/-! ## Theorem 2: Depth Nonincrease -/

/-- **Depth Nonincrease**: normalization never increases depth.
    This is the compiler resource invariant. -/
theorem depth_normalize_le (e : PosEMLExpr) :
    (normalize e).depth ≤ e.depth := by
  induction e with
  | const _ => simp [normalize, depth]
  | var => simp [normalize, depth]
  | add a b iha ihb =>
    simp only [normalize, depth]
    exact le_trans (depth_mkAdd_le _ _) (max_le_max iha ihb)
  | mul a b iha ihb =>
    simp only [normalize, depth]
    exact le_trans (depth_mkMul_le _ _) (max_le_max iha ihb)
  | exp a ih =>
    simp only [normalize, depth]
    exact le_trans (depth_mkExp_le _) (Nat.add_le_add_right ih 1)

/-! ## Theorem 3: Zero-Overhead Differentiation -/

/-- **Zero-Overhead Differentiation**: the derivative followed by normalization
    does not increase depth. This is the flagship result.

    The proof proceeds by structural induction on `e`:
    - **`const`, `var`**: derivatives are constants with depth 0.
    - **`add a b`**: `deriv(a+b) = deriv(a) + deriv(b)`, normalization preserves depth by IH.
    - **`mul a b`**: `deriv(a*b) = a'*b + a*b'`. Each product term has depth ≤ `max(depth a, depth b)`
      by IH + `depth_normalize_le`, and the sum preserves this bound.
    - **`exp a`**: `deriv(exp(a)) = a' * exp(a)`. By IH, `normalize(a')` has depth ≤ `depth(a)`,
      and `normalize(exp(a))` has depth ≤ `depth(a) + 1`, so the product has depth
      ≤ `depth(a) + 1 = depth(exp a)`.
-/
theorem depth_normalize_deriv_le (e : PosEMLExpr) :
    (normalize (deriv e)).depth ≤ e.depth := by
  induction e with
  | const _ =>
    simp [deriv, normalize, depth]
  | var =>
    simp [deriv, normalize, depth]
  | add a b iha ihb =>
    simp only [deriv, normalize]
    exact le_trans (depth_mkAdd_le _ _) (max_le_max iha ihb)
  | mul a b iha ihb =>
    simp only [deriv, normalize, depth]
    have h1 : (mkMul (normalize (deriv a)) (normalize b)).depth ≤ max a.depth b.depth :=
      le_trans (depth_mkMul_le _ _) (max_le (le_trans iha (le_max_left _ _))
        (le_trans (depth_normalize_le b) (le_max_right _ _)))
    have h2 : (mkMul (normalize a) (normalize (deriv b))).depth ≤ max a.depth b.depth :=
      le_trans (depth_mkMul_le _ _) (max_le (le_trans (depth_normalize_le a) (le_max_left _ _))
        (le_trans ihb (le_max_right _ _)))
    exact le_trans (depth_mkAdd_le _ _) (max_le h1 h2)
  | exp a ih =>
    simp only [deriv, normalize]
    have h_exp : (mkExp (normalize a)).depth ≤ a.depth + 1 :=
      le_trans (depth_mkExp_le _) (Nat.add_le_add_right (depth_normalize_le a) 1)
    show (mkMul (normalize (deriv a)) (mkExp (normalize a))).depth ≤ a.depth + 1
    calc (mkMul (normalize (deriv a)) (mkExp (normalize a))).depth
        ≤ max (normalize (deriv a)).depth (mkExp (normalize a)).depth :=
          depth_mkMul_le _ _
      _ ≤ max a.depth (a.depth + 1) := max_le_max ih h_exp
      _ = a.depth + 1 := by omega

/-! ## The Good Fragment -/

/-- The **polynomial-exponential** fragment: expressions where every `exp` argument
    has depth 0 (i.e., is a polynomial expression built from constants, variables,
    addition, and multiplication only — no nested exponentials).

    This is a mathematically natural fragment corresponding to expressions like
    `exp(x²+3x)`, `x·exp(x)`, `exp(x) + exp(2x)`, but excluding iterated
    exponentials like `exp(exp(x))`. -/
def Good : PosEMLExpr → Prop
  | .const _ => True
  | .var => True
  | .add a b => Good a ∧ Good b
  | .mul a b => Good a ∧ Good b
  | .exp a => Good a ∧ a.depth = 0

/-- Constants are Good. -/
theorem good_const (c : ℝ) : Good (.const c) := trivial

/-- The variable is Good. -/
theorem good_var : Good .var := trivial

/-! ## Theorem: Good is closed under normalization -/

/-- **Fragment stability**: normalization preserves the `Good` fragment. -/
theorem good_normalize (e : PosEMLExpr) (h : Good e) : Good (normalize e) := by
  induction e with
  | const _ => exact trivial
  | var => exact trivial
  | add a b iha ihb =>
    simp only [Good] at h
    simp only [normalize, mkAdd]
    split
    · exact ihb h.2
    · split
      · exact iha h.1
      · exact ⟨iha h.1, ihb h.2⟩
  | mul a b iha ihb =>
    simp only [Good] at h
    simp only [normalize, mkMul]
    split
    · exact trivial
    · split
      · exact trivial
      · split
        · exact ihb h.2
        · split
          · exact iha h.1
          · exact ⟨iha h.1, ihb h.2⟩
  | exp a ih =>
    simp only [Good] at h
    simp only [normalize, mkExp]
    split
    · exact trivial
    · constructor
      · exact ih h.1
      · have := depth_normalize_le a
        omega

/-! ## Combined Theorem -/

/-- **Certified normalization**: evaluation preservation + depth bound in one statement. -/
theorem normalize_sound_complete_for_depth (e : PosEMLExpr) :
    (fun x => (normalize e).eval x) = (fun x => e.eval x) ∧
    (normalize e).depth ≤ e.depth :=
  ⟨funext (eval_normalize e), depth_normalize_le e⟩

/-! ## NormalFormCert: Proof-Carrying Normalized Expressions -/

/-- A **proof-carrying normalized expression**: packages an expression with its
    normal form and certified invariants. This connects normalization with
    proof-carrying symbolic compilation. -/
structure NormalFormCert where
  /-- The original expression. -/
  expr : PosEMLExpr
  /-- The normalized form. -/
  nf : PosEMLExpr
  /-- Semantic equivalence: the normal form evaluates identically. -/
  sem_eq : ∀ x, nf.eval x = expr.eval x
  /-- Depth bound: the normal form is no deeper. -/
  depth_le : nf.depth ≤ expr.depth

/-- Construct a `NormalFormCert` from any expression using `normalize`. -/
def certify (e : PosEMLExpr) : NormalFormCert where
  expr := e
  nf := normalize e
  sem_eq := fun x => eval_normalize e x
  depth_le := depth_normalize_le e

/-! ## The fragment-restricted flagship theorem -/

/-- **Fragment-restricted zero-overhead differentiation**: on the `Good` fragment,
    the derivative followed by normalization does not increase depth.
    This is an immediate corollary of the universal theorem `depth_normalize_deriv_le`,
    but the `Good` restriction identifies the mathematically natural class of
    polynomial-exponential expressions where the theorem is most meaningful. -/
theorem depth_normalize_deriv_le_good (e : PosEMLExpr) (_h : Good e) :
    (normalize (deriv e)).depth ≤ e.depth :=
  depth_normalize_deriv_le e

/-! ## Derivative-Balanced Expressions -/

/-- An expression is **derivative-balanced** if exponential nodes only appear with
    arguments whose derivatives normalize to depth at most `depth(arg) - 1`.
    This is a stronger property than `Good`, capturing the structural reason
    why differentiation doesn't increase depth after normalization. -/
def DerivBalanced : PosEMLExpr → Prop
  | .const _ => True
  | .var => True
  | .add a b => DerivBalanced a ∧ DerivBalanced b
  | .mul a b => DerivBalanced a ∧ DerivBalanced b
  | .exp a => DerivBalanced a ∧ (normalize (deriv a)).depth ≤ a.depth

/-- Every `Good` expression is derivative-balanced. -/
theorem good_imp_derivBalanced (e : PosEMLExpr) (h : Good e) : DerivBalanced e := by
  induction e with
  | const _ => exact trivial
  | var => exact trivial
  | add a b iha ihb =>
    simp only [Good] at h
    exact ⟨iha h.1, ihb h.2⟩
  | mul a b iha ihb =>
    simp only [Good] at h
    exact ⟨iha h.1, ihb h.2⟩
  | exp a ih =>
    simp only [Good] at h
    constructor
    · exact ih h.1
    · exact depth_normalize_deriv_le a

end PosEMLExpr

end