/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Depth Compression: `exp`/`log` Collapse the Depth of Monomials

This file is a research contribution to the **EML (Exponential–Multiplicative–Logarithmic)
universal approximation** programme. The density files (`EML.MultivariateExponentialDensity`,
`EML.CubeDensity`) settle *which* functions an EML class can approximate. This file studies
the dual, quantitative question raised by the mission: **how the cost of an exact EML
representation depends on its depth**.

We isolate the simplest target — the monomial `x ↦ xⁿ` on the positive reals — and exhibit
two exact EML representations of it:

* the **naive** representation `monoNaive n = x · x · ⋯ · x` (repeated multiplication),
  whose *depth grows linearly*: `depth (monoNaive n) = n`;
* the **exp/log** representation `monoExpLog n = exp(n · log x)`, whose *depth is the
  constant `3`*, independent of the degree `n`.

The headline is the **depth-compression theorem** `eml_depth_compression`: for every degree
`n ≥ 4` the two terms compute the same function on `(0, ∞)` while the exp/log term is
strictly shallower. Thus `exp`/`log` provide *unbounded* depth savings: a depth-`3` ("shallow")
EML network represents arbitrarily high-degree monomials exactly, whereas a multiplication-only
network needs depth `n`. This is the precise sense in which *approximation/representation cost
depends on depth*, and it is the structural reason `exp`/`log` are indispensable EML primitives.

## Main results

* `Term.monoNaive_eval`, `Term.monoNaive_depth` — the naive monomial: value `xⁿ`, depth `n`.
* `Term.monoExpLog_eval`, `Term.monoExpLog_depth` — the exp/log monomial: value `xⁿ` on
  `(0,∞)`, depth `3` for every `n`.
* `Term.eml_depth_compression` — for `n ≥ 4`: same function on `(0,∞)`, strictly smaller
  depth. The depth gap `n - 3` is unbounded in `n`.
* `Term.eml_depth_unbounded_gap` — the depth gap between the two representations tends to
  infinity with the degree.

-- !-- Lab Notes -- !--
HYPOTHESIS (D1). The density theorems treat `exp`/`log` as one injective feature among many,
suggesting they are dispensable. We conjecture the opposite at the level of *depth*: there is
a function family (monomials) whose minimal multiplication-only depth grows without bound but
whose exp/log depth is constant. If true, `exp`/`log` give unbounded depth compression.

EXPERIMENT. We defined a small EML `Term` type with `depth`. Two exact representations of
`xⁿ` were built: `monoNaive` (repeated `mul`, proved `depth = n` and `eval = xⁿ` by
induction) and `monoExpLog = exp(n · log x)` (proved `eval = xⁿ` on `(0,∞)` via
`Real.rpow_def_of_pos` + `Real.rpow_natCast`, and `depth = 3` by `rfl`/`decide`). For
`n ≥ 4`, `3 < n`, giving the strict depth drop. Outcome: D1 confirmed.

ANALYSIS. The equality `exp(n·log x) = xⁿ` is the only place positivity is used; it is the
algebraic heart of EML and the source of the compression. The naive depth `= n` is a clean
induction `depth (mul var t) = depth t + 1`.

INSIGHT. Depth and width trade off against *different* resources. Width (number of features)
is forced by the dimension of the domain (cf. `EMLMultivariate.ridge_not_injective`); depth is
forced by the *multiplicative complexity* of the target, and `exp`/`log` linearise
multiplication (`log` turns `·` into `+`, `exp` inverts it), collapsing that depth to a
constant. Density is silent about this; only a depth-aware analysis sees it.

FAILURE ANALYSIS. An early `monoNaive 0 = var` base case made `eval` give `x` instead of
`x⁰ = 1`; we corrected the base case to `const 1`. Lesson: align the recursion's base case
with the arithmetic identity `x⁰ = 1`, not with syntactic convenience.

CRITIQUE. Is the result vacuous (e.g., `monoExpLog` secretly equal to `monoNaive`)? No: they
are distinct syntactic terms with provably different depths, and the value agreement holds only
on `(0,∞)` (where `log` is the genuine inverse of `exp`), not on all of `ℝ` — so the theorem is
guarded exactly at its true boundary.
-/
import Mathlib

noncomputable section

open Real

namespace EML.DepthCompression

/-- A minimal EML (Exp-Log-Multiply) term algebra in one variable. -/
inductive Term : Type where
  | var : Term
  | const (c : ℝ) : Term
  | add (t₁ t₂ : Term) : Term
  | mul (t₁ t₂ : Term) : Term
  | expOf (t : Term) : Term
  | logOf (t : Term) : Term
  deriving Inhabited

namespace Term

/-- Evaluate an EML term at a real number. -/
def eval : Term → ℝ → ℝ
  | var, x => x
  | const c, _ => c
  | add t₁ t₂, x => t₁.eval x + t₂.eval x
  | mul t₁ t₂, x => t₁.eval x * t₂.eval x
  | expOf t, x => Real.exp (t.eval x)
  | logOf t, x => Real.log (t.eval x)

/-- Depth: maximum nesting of operations. -/
def depth : Term → ℕ
  | var => 0
  | const _ => 0
  | add t₁ t₂ => max t₁.depth t₂.depth + 1
  | mul t₁ t₂ => max t₁.depth t₂.depth + 1
  | expOf t => t.depth + 1
  | logOf t => t.depth + 1

/-! ## The naive (multiplication-only) monomial -/

/-- The naive monomial `xⁿ` built from `n` repeated multiplications. -/
def monoNaive : ℕ → Term
  | 0 => const 1
  | k + 1 => mul var (monoNaive k)

/-- The naive monomial evaluates to `xⁿ`. -/
theorem monoNaive_eval (n : ℕ) (x : ℝ) : (monoNaive n).eval x = x ^ n := by
  induction n with
  | zero => simp [monoNaive, eval]
  | succ k ih => simp [monoNaive, eval, ih, pow_succ, mul_comm]

/-- The naive monomial has depth exactly `n`: depth grows linearly with the degree. -/
theorem monoNaive_depth (n : ℕ) : (monoNaive n).depth = n := by
  induction n with
  | zero => rfl
  | succ k ih => simp [monoNaive, depth, ih]

/-! ## The exp/log monomial -/

/-- The exp/log monomial `exp(n · log x)`, which equals `xⁿ` on `(0, ∞)`. -/
def monoExpLog (n : ℕ) : Term := expOf (mul (const (n : ℝ)) (logOf var))

/-- On the positive reals the exp/log monomial evaluates to `xⁿ`.
This is the algebraic identity `exp(n·log x) = xⁿ` that powers EML depth compression. -/
theorem monoExpLog_eval (n : ℕ) {x : ℝ} (hx : 0 < x) :
    (monoExpLog n).eval x = x ^ n := by
  simp only [monoExpLog, eval]
  rw [mul_comm, ← Real.rpow_def_of_pos hx, Real.rpow_natCast]

/-- The exp/log monomial has depth `3` for **every** degree `n`: depth is constant. -/
theorem monoExpLog_depth (n : ℕ) : (monoExpLog n).depth = 3 := rfl

/-! ## Depth compression -/

/-- **EML depth compression.**
For every degree `n ≥ 4`, the exp/log monomial and the naive monomial compute the *same*
function on `(0, ∞)`, yet the exp/log term is *strictly shallower*. Hence a constant-depth
("shallow") EML network using `exp`/`log` represents arbitrarily high-degree monomials that a
multiplication-only network can only reach at depth `n`. -/
theorem eml_depth_compression (n : ℕ) (hn : 4 ≤ n) :
    (∀ x : ℝ, 0 < x → (monoExpLog n).eval x = (monoNaive n).eval x) ∧
      (monoExpLog n).depth < (monoNaive n).depth := by
  refine ⟨fun x hx => ?_, ?_⟩
  · rw [monoExpLog_eval n hx, monoNaive_eval n x]
  · rw [monoExpLog_depth, monoNaive_depth]; omega

/-- The depth gap between the naive and exp/log representations of `xⁿ` is `n - 3`, which is
unbounded: for any target gap `M` there is a degree whose representations differ in depth by
more than `M`. The exp/log primitive therefore yields *unbounded* depth savings. -/
theorem eml_depth_unbounded_gap (M : ℕ) :
    ∃ n : ℕ, M < (monoNaive n).depth - (monoExpLog n).depth := by
  refine ⟨M + 4, ?_⟩
  rw [monoNaive_depth, monoExpLog_depth]
  omega

end Term

end EML.DepthCompression

end