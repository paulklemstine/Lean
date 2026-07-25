import Mathlib

/-! # EML-KA Depth Theory: Depth-Independence for Monomials

This module develops the theory of **EML chains** — compositions of exp, log,
and affine maps — and proves the **depth-independence phenomenon**: every monomial
`x^a · y^b` on `(0,∞)²` admits a 1-term EML-KA decomposition with constant depth,
regardless of the exponents `a` and `b`.

## Main definitions

* `EMLChainOp` — Operations in an EML chain: exp, log, or affine.
* `EMLChain.eval`, `EMLChain.depth` — Evaluation and transcendental depth.
* `EMLKADecomp` — EML-KA decomposition with Q terms and tracked chain depth.
* `MonomialTerm`, `MonomialPoly` — Monomials and their polynomials on (0,∞)².
* `EMLExpr` — Expression trees for depth lower bound analysis.

## Main results

* `monomial_ka_spec` — The monomial decomposition evaluates to x^a · y^b.
* `monomial_ka_max_depth` — Depth is 1 regardless of exponents (depth-independence).
* `poly_ka_spec` — Polynomial decomposition is correct.
* `EMLExpr.depth_zero_is_affine` — Depth-0 expressions are affine (by structural induction).
* `EMLKADecomp.embed_eval` — Q-term decompositions embed into (Q+1)-term ones.
-/

noncomputable section
open Real Set Finset

/-! ## §1. EML Chain Operations and Depth -/

/-- An operation in an EML chain: exponential, logarithm, or affine map. -/
inductive EMLChainOp where
  | exp : EMLChainOp
  | log : EMLChainOp
  | affine (a b : ℝ) : EMLChainOp

/-- Evaluate a single EML chain operation. -/
def EMLChainOp.eval : EMLChainOp → ℝ → ℝ
  | .exp => Real.exp
  | .log => Real.log
  | .affine a b => fun x => a * x + b

/-- Predicate for non-affine (transcendental) operations. -/
def EMLChainOp.isNonAffine : EMLChainOp → Bool
  | .affine _ _ => false
  | _ => true

set_option linter.dupNamespace false
namespace EMLChain

/-- An EML chain is a sequence of operations, applied left to right. -/
abbrev EMLChain := List EMLChainOp

/-- Evaluate an EML chain by composing operations left to right. -/
def eval (chain : EMLChain) (x : ℝ) : ℝ :=
  chain.foldl (fun acc op => op.eval acc) x

/-- The **depth** of an EML chain: the count of non-affine (exp/log) operations.
    Affine operations are "free" since they don't increase complexity. -/
def depth (chain : EMLChain) : ℕ :=
  chain.countP EMLChainOp.isNonAffine

theorem depth_exp_singleton :
    depth [.exp] = 1 := by
  simp [depth, List.countP, List.countP.go, EMLChainOp.isNonAffine]

theorem depth_affine_singleton (a b : ℝ) :
    depth [.affine a b] = 0 := by
  simp [depth, List.countP, List.countP.go, EMLChainOp.isNonAffine]

end EMLChain

/-- The canonical chain for computing x^a: x ↦ log(x) ↦ a·log(x) ↦ exp(a·log(x)) = x^a. -/
def powerChain (a : ℝ) : EMLChain.EMLChain :=
  [.log, .affine a 0, .exp]

/-- The power chain has transcendental depth 2 (one log + one exp). -/
theorem powerChain_depth (a : ℝ) : EMLChain.depth (powerChain a) = 2 := by
  simp [powerChain, EMLChain.depth, List.countP, List.countP.go, EMLChainOp.isNonAffine]

/-- The power chain correctly computes x^a for x > 0. -/
theorem powerChain_eval (a x : ℝ) (hx : 0 < x) :
    EMLChain.eval (powerChain a) x = x ^ a := by
  simp only [powerChain, EMLChain.eval, List.foldl, EMLChainOp.eval, add_zero]
  rw [mul_comm, ← Real.rpow_def_of_pos hx]

/-! ## §2. EML-KA Decomposition Structure -/

/-- A Kolmogorov-Arnold decomposition with Q terms, where each term uses EML chains.
    Computes f(x,y) = Σ_q outerChain_q(chain₁_q(x) + chain₂_q(y)). -/
structure EMLKADecomp (Q : ℕ) where
  chain₁ : Fin Q → EMLChain.EMLChain
  chain₂ : Fin Q → EMLChain.EMLChain
  outerChain : Fin Q → EMLChain.EMLChain

/-- The depth of an EML-KA decomposition: max depth across all chains. -/
def EMLKADecomp.maxDepth (d : EMLKADecomp Q) : ℕ :=
  Finset.sup Finset.univ fun q =>
    max (max (EMLChain.depth (d.chain₁ q)) (EMLChain.depth (d.chain₂ q)))
        (EMLChain.depth (d.outerChain q))

/-- Evaluate an EML-KA decomposition at (x, y). -/
def EMLKADecomp.eval (d : EMLKADecomp Q) (x y : ℝ) : ℝ :=
  ∑ q : Fin Q, EMLChain.eval (d.outerChain q)
    (EMLChain.eval (d.chain₁ q) x + EMLChain.eval (d.chain₂ q) y)

/-! ## §3. Monomial Decomposition and Depth-Independence -/

/-- The monomial x^a · y^b = exp(a·log(x) + b·log(y)).
    A 1-term EML-KA decomposition with inner chains [log, affine] and outer [exp]. -/
def monomialKADecomp (a b : ℝ) : EMLKADecomp 1 where
  chain₁ := fun _ => [.log, .affine a 0]
  chain₂ := fun _ => [.log, .affine b 0]
  outerChain := fun _ => [.exp]

/-- **Correctness**: The monomial decomposition evaluates to x^a · y^b for x, y > 0. -/
theorem monomial_ka_spec (a b x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    (monomialKADecomp a b).eval x y = x ^ a * y ^ b := by
  simp only [monomialKADecomp, EMLKADecomp.eval, Fin.sum_univ_one]
  simp only [EMLChain.eval, List.foldl, EMLChainOp.eval, add_zero]
  rw [Real.exp_add, mul_comm a, ← Real.rpow_def_of_pos hx,
      mul_comm b, ← Real.rpow_def_of_pos hy]

/-- **Depth-independence**: The max chain depth of the monomial decomposition is 1,
    regardless of the exponents a and b. The decomposition complexity does not
    grow with the magnitude of the exponents. -/
theorem monomial_ka_max_depth (a b : ℝ) :
    (monomialKADecomp a b).maxDepth = 1 := by
  simp [monomialKADecomp, EMLKADecomp.maxDepth, EMLChain.depth,
        List.countP, List.countP.go, EMLChainOp.isNonAffine]

/-! ## §4. Polynomial Decomposition -/

/-- A monomial term: coefficient c times x^a · y^b. -/
structure MonomialTerm where
  coeff : ℝ
  expX : ℝ
  expY : ℝ

/-- Evaluate a monomial term at (x, y). -/
def MonomialTerm.eval (m : MonomialTerm) (x y : ℝ) : ℝ :=
  m.coeff * x ^ m.expX * y ^ m.expY

/-- An M-monomial polynomial on (0,∞)². -/
def MonomialPoly (M : ℕ) := Fin M → MonomialTerm

/-- Evaluate a monomial polynomial at (x, y). -/
def MonomialPoly.eval (p : MonomialPoly M) (x y : ℝ) : ℝ :=
  ∑ i : Fin M, (p i).eval x y

/-- EML-KA decomposition for a polynomial: one term per monomial. -/
def polyKADecomp (p : MonomialPoly M) : EMLKADecomp M where
  chain₁ := fun i => [.log, .affine (p i).expX 0]
  chain₂ := fun i => [.log, .affine (p i).expY 0]
  outerChain := fun i => [.exp, .affine (p i).coeff 0]

/-- **Correctness**: The polynomial decomposition evaluates correctly on (0,∞)². -/
theorem poly_ka_spec (p : MonomialPoly M) (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    (polyKADecomp p).eval x y = p.eval x y := by
  simp only [polyKADecomp, EMLKADecomp.eval, MonomialPoly.eval, MonomialTerm.eval]
  congr 1; ext i
  simp only [EMLChain.eval, List.foldl, EMLChainOp.eval, add_zero]
  rw [Real.exp_add, mul_comm (p i).expX, ← Real.rpow_def_of_pos hx,
      mul_comm (p i).expY, ← Real.rpow_def_of_pos hy]
  ring

/-- **Polynomial depth**: Max chain depth ≤ 1 for any polynomial, any exponents. -/
theorem poly_ka_max_depth_le (p : MonomialPoly M) :
    (polyKADecomp p).maxDepth ≤ 1 := by
  simp only [polyKADecomp, EMLKADecomp.maxDepth]
  apply Finset.sup_le
  intro i _
  simp [EMLChain.depth, List.countP, List.countP.go, EMLChainOp.isNonAffine]

/-! ## §5. EML Expression Trees and Depth Lower Bounds -/

/-- An EML expression tree for tracking compositional depth. -/
inductive EMLExpr where
  | var : EMLExpr
  | const (c : ℝ) : EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | smul (c : ℝ) : EMLExpr → EMLExpr
  | expOf : EMLExpr → EMLExpr
  | logOf : EMLExpr → EMLExpr

/-- The non-affine depth: max nesting of exp/log operations. -/
def EMLExpr.naDepth : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add e₁ e₂ => max e₁.naDepth e₂.naDepth
  | .smul _ e => e.naDepth
  | .expOf e => e.naDepth + 1
  | .logOf e => e.naDepth + 1

/-- Evaluate an EML expression at a point. -/
def EMLExpr.eval : EMLExpr → ℝ → ℝ
  | .var => id
  | .const c => fun _ => c
  | .add e₁ e₂ => fun x => e₁.eval x + e₂.eval x
  | .smul c e => fun x => c * e.eval x
  | .expOf e => fun x => Real.exp (e.eval x)
  | .logOf e => fun x => Real.log (e.eval x)

/-- **Depth-0 characterization**: An EML expression with no exp or log operations
    computes an affine function. This is the key structural result:
    transcendental operations are the only source of nonlinearity.

    Proof by structural induction on the expression tree. -/
theorem EMLExpr.depth_zero_is_affine (e : EMLExpr) (h : e.naDepth = 0) :
    ∃ a b : ℝ, ∀ x : ℝ, e.eval x = a * x + b := by
  induction e with
  | var => exact ⟨1, 0, fun x => by simp [EMLExpr.eval]⟩
  | const c => exact ⟨0, c, fun x => by simp [EMLExpr.eval]⟩
  | add e₁ e₂ ih₁ ih₂ =>
    simp [EMLExpr.naDepth] at h
    obtain ⟨a₁, b₁, h₁⟩ := ih₁ h.1
    obtain ⟨a₂, b₂, h₂⟩ := ih₂ h.2
    exact ⟨a₁ + a₂, b₁ + b₂, fun x => by simp [EMLExpr.eval, h₁ x, h₂ x]; ring⟩
  | smul c e ih =>
    simp [EMLExpr.naDepth] at h
    obtain ⟨a, b, he⟩ := ih h
    exact ⟨c * a, c * b, fun x => by simp [EMLExpr.eval, he x]; ring⟩
  | expOf e _ =>
    simp [EMLExpr.naDepth] at h
  | logOf e _ =>
    simp [EMLExpr.naDepth] at h

/-! ## §6. Decomposition Embedding (Monotonicity of Approximation) -/

/-- Embed a Q-term decomposition into (Q+1) terms by adding a zero term. -/
def EMLKADecomp.embed (d : EMLKADecomp Q) : EMLKADecomp (Q + 1) where
  chain₁ := fun i => if h : i.val < Q then d.chain₁ ⟨i.val, h⟩ else []
  chain₂ := fun i => if h : i.val < Q then d.chain₂ ⟨i.val, h⟩ else []
  outerChain := fun i => if h : i.val < Q then d.outerChain ⟨i.val, h⟩ else [.affine 0 0]

/-- **Embedding preserves evaluation**: adding a zero term doesn't change the output. -/
theorem EMLKADecomp.embed_eval (d : EMLKADecomp Q) (x y : ℝ) :
    d.embed.eval x y = d.eval x y := by
  simp only [EMLKADecomp.embed, EMLKADecomp.eval]
  rw [Fin.sum_univ_castSucc]
  have hlast : EMLChain.eval [EMLChainOp.affine 0 0]
    (EMLChain.eval [] x + EMLChain.eval [] y) = 0 := by
    simp [EMLChain.eval, List.foldl, EMLChainOp.eval]
  simp only [Fin.val_castSucc, Fin.val_last, lt_irrefl, dite_false]
  rw [hlast, add_zero]
  congr 1; ext i; simp [i.isLt]

end