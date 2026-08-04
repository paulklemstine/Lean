import Mathlib

/-!
# Depth compression of exponential–logarithmic expressions

An **EML term** is a syntactic expression in one real variable built from the
variable, real constants, `+`, `*`, `Real.exp` and `Real.log`.  Its *depth* is
the height of its syntax tree.

The theme of this file is **depth compression**: the exponential–logarithmic
primitives collapse an unbounded amount of multiplicative structure into a
bounded amount of syntax.  Concretely:

* `Term.naivePow n` computes `y ↦ y ^ n` by iterated multiplication and has
  depth exactly `n` (for `n ≥ 1`), i.e. depth growing linearly in `n`
  (`Term.naivePow_depth`);
* `Term.monoExpLog n` computes the *same* function on the positive half-line
  through `y ↦ exp (n · log y)` and has depth `3`, independently of `n`
  (`Term.monoExpLog_eval`, `Term.monoExpLog_depth`);
* more generally `Term.rpowExpLog a` computes the real power `y ↦ y ^ a` for
  every real exponent `a`, again in depth `3` (`Term.rpowExpLog_eval`).

The separation is recorded in `depth_compression` and
`depth_compression_unbounded`: the naive family has unbounded depth while the
exp–log family computing the same functions is uniformly of depth `3`.

Basic structural facts (`Term.eval_add`, `Term.depth_mul`, …) and the fact that
depth-`0` terms are exactly the variable and the constants
(`Term.eval_of_depth_eq_zero`) round out the API.
-/

namespace EML.DepthCompression

/-- Syntax of exponential–logarithmic (EML) terms in one real variable. -/
inductive Term : Type
  | var : Term
  | const : ℝ → Term
  | add : Term → Term → Term
  | mul : Term → Term → Term
  | exp : Term → Term
  | log : Term → Term
  deriving Inhabited

namespace Term

/-- Interpretation of an EML term as a real function.  Outside its natural
domain the junk value `Real.log 0 = 0` is used. -/
noncomputable def eval : Term → ℝ → ℝ
  | var, y => y
  | const c, _ => c
  | add a b, y => eval a y + eval b y
  | mul a b, y => eval a y * eval b y
  | exp a, y => Real.exp (eval a y)
  | log a, y => Real.log (eval a y)

/-- The depth (syntax-tree height) of an EML term. -/
def depth : Term → ℕ
  | var => 0
  | const _ => 0
  | add a b => 1 + max (depth a) (depth b)
  | mul a b => 1 + max (depth a) (depth b)
  | exp a => 1 + depth a
  | log a => 1 + depth a

@[simp] theorem eval_var (y : ℝ) : eval var y = y := rfl
@[simp] theorem eval_const (c y : ℝ) : eval (const c) y = c := rfl
@[simp] theorem eval_add (a b : Term) (y : ℝ) : eval (add a b) y = eval a y + eval b y := rfl
@[simp] theorem eval_mul (a b : Term) (y : ℝ) : eval (mul a b) y = eval a y * eval b y := rfl
@[simp] theorem eval_exp (a : Term) (y : ℝ) : eval (exp a) y = Real.exp (eval a y) := rfl
@[simp] theorem eval_log (a : Term) (y : ℝ) : eval (log a) y = Real.log (eval a y) := rfl

@[simp] theorem depth_var : depth var = 0 := rfl
@[simp] theorem depth_const (c : ℝ) : depth (const c) = 0 := rfl
@[simp] theorem depth_add (a b : Term) : depth (add a b) = 1 + max (depth a) (depth b) := rfl
@[simp] theorem depth_mul (a b : Term) : depth (mul a b) = 1 + max (depth a) (depth b) := rfl
@[simp] theorem depth_exp (a : Term) : depth (exp a) = 1 + depth a := rfl
@[simp] theorem depth_log (a : Term) : depth (log a) = 1 + depth a := rfl

/-- A term of depth `0` is either the variable or a constant; consequently its
value function is the identity or a constant function. -/
theorem eval_of_depth_eq_zero (t : Term) (h : depth t = 0) :
    eval t = id ∨ ∃ c : ℝ, eval t = fun _ => c := by
  cases t with
  | var => exact Or.inl rfl
  | const c => exact Or.inr ⟨c, rfl⟩
  | add a b => simp [depth] at h
  | mul a b => simp [depth] at h
  | exp a => simp [depth] at h
  | log a => simp [depth] at h

/-! ## The naive (iterated multiplication) representation of a monomial -/

/-- `naivePow n` is the term `y * (y * (⋯ * 1))` with `n` factors: the monomial
`y ^ n` written using multiplications only. -/
def naivePow : ℕ → Term
  | 0 => const 1
  | n + 1 => mul var (naivePow n)

@[simp] theorem naivePow_eval (n : ℕ) (y : ℝ) : eval (naivePow n) y = y ^ n := by
  induction n with
  | zero => simp [naivePow]
  | succ n ih => simp [naivePow, ih, pow_succ, mul_comm]

/-- The naive monomial term has depth exactly `n` (for `n ≥ 1`): iterated
multiplication costs one unit of depth per factor. -/
theorem naivePow_depth (n : ℕ) : depth (naivePow (n + 1)) = n + 1 := by
  induction n with
  | zero => simp [naivePow, depth]
  | succ n ih =>
      have h : depth (naivePow (n + 1 + 1)) = 1 + max 0 (depth (naivePow (n + 1))) := rfl
      rw [h, ih]
      omega

/-! ## The exp–log (depth 3) representation -/

/-- `rpowExpLog a` is the depth-3 term `exp (a * log y)`, which computes the real
power `y ↦ y ^ a` on the positive half-line. -/
def rpowExpLog (a : ℝ) : Term := exp (mul (const a) (log var))

/-- `monoExpLog n` is the depth-3 term `exp (n * log y)` computing the monomial
`y ↦ y ^ n` on the positive half-line. -/
def monoExpLog (n : ℕ) : Term := rpowExpLog (n : ℝ)

theorem rpowExpLog_eval (a : ℝ) {y : ℝ} (hy : 0 < y) :
    eval (rpowExpLog a) y = y ^ a := by
  simp [rpowExpLog, Real.rpow_def_of_pos hy, mul_comm]

@[simp] theorem rpowExpLog_depth (a : ℝ) : depth (rpowExpLog a) = 3 := by
  simp [rpowExpLog, depth]

/-- **Exp–log representation of a monomial.**  For `y > 0`,
`exp (n · log y) = y ^ n`. -/
theorem monoExpLog_eval (n : ℕ) {y : ℝ} (hy : 0 < y) :
    eval (monoExpLog n) y = y ^ n := by
  rw [monoExpLog, rpowExpLog_eval _ hy, Real.rpow_natCast]

/-- **Constant depth.**  The exp–log representation of `y ^ n` has depth `3`,
uniformly in `n`. -/
@[simp] theorem monoExpLog_depth (n : ℕ) : depth (monoExpLog n) = 3 :=
  rpowExpLog_depth _

end Term

/-! ## The compression theorem -/

open Term in
/-- **Depth compression.**  For every `n`, the monomial `y ↦ y ^ (n+1)` is
computed on the positive half-line by a term of depth `3`, while the naive
representation by iterated multiplication needs depth `n + 1`. -/
theorem depth_compression (n : ℕ) :
    depth (monoExpLog (n + 1)) = 3 ∧
    depth (naivePow (n + 1)) = n + 1 ∧
    ∀ y : ℝ, 0 < y →
      eval (monoExpLog (n + 1)) y = eval (naivePow (n + 1)) y :=
  ⟨monoExpLog_depth _, naivePow_depth n, fun y hy => by
    rw [monoExpLog_eval _ hy, naivePow_eval]⟩

open Term in
/-- The depth of the naive monomial representations is unbounded: for every
bound `B` there is a monomial whose naive term exceeds it, even though all these
monomials are computed in depth `3` by exp–log terms. -/
theorem depth_compression_unbounded (B : ℕ) :
    ∃ n : ℕ, B < depth (naivePow (n + 1)) ∧ depth (monoExpLog (n + 1)) = 3 :=
  ⟨B, by rw [naivePow_depth]; omega, monoExpLog_depth _⟩

end EML.DepthCompression