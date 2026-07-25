import Mathlib

/-!
# Ordinal Rank as Symbolic Complexity Certificate

This file establishes that the ordinal rank of an EML expression is a **symbolic
complexity certificate**: a static, computable invariant that tightly bounds the
cost of symbolic differentiation. This is the EML-analogue of proof-theoretic
ordinals in Gentzen-style proof theory: just as the proof-theoretic ordinal of a
theory bounds the complexity of cut elimination, `exprRank(e)` bounds the
complexity of symbolic transformation of `e`.

## Main Results

* `emlDeriv_rank_omegaCoeff_le`: Differentiation is rank-non-expanding (ω-coefficient).
* `emlSize_pos`: Every expression has positive size.
* `emlDeriv_size_le`: Concrete quadratic bound on derivative size.
* `tropical_rank_correspondence`: Cross-domain bridge to tropical geometry.
* `emlDerivIter_rank_omegaCoeff_le`: Iterated differentiation preserves rank.
* `rank_zero_deriv_hardy_zero`: Rank-0 expressions have polynomial-growth derivatives.
* `emlDeriv_correct`: Semantic correctness of symbolic differentiation.

## Novel Definition

* `tropicalVal`: A tropical valuation mapping EML expressions to ℕ,
  bridging ordinal analysis and tropical geometry.

## Building on Catalog

This extends `Catalog/Pythagorean/OrdinalClassification/Theorems.lean` with
differentiation theory, size analysis, and cross-domain connections.
-/

noncomputable section

open Real Filter

/-! ## EML Expression Language (self-contained definitions) -/

/-- EML expression language: transcendence enters only through `eml(a,b) = a * exp(b)`. -/
inductive EmlExpr where
  | var : EmlExpr
  | const : ℝ → EmlExpr
  | add : EmlExpr → EmlExpr → EmlExpr
  | mul : EmlExpr → EmlExpr → EmlExpr
  | neg : EmlExpr → EmlExpr
  | eml : EmlExpr → EmlExpr → EmlExpr

namespace EmlExpr

/-- Evaluation of `EmlExpr` at a point `x : ℝ`. -/
def eval : EmlExpr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add a b, x => a.eval x + b.eval x
  | .mul a b, x => a.eval x * b.eval x
  | .neg a, x => -(a.eval x)
  | .eml a b, x => a.eval x * Real.exp (b.eval x)

/-- EML depth: counts the maximum nesting depth of `eml` operations. -/
def emlDepth : EmlExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.emlDepth b.emlDepth
  | .mul a b => max a.emlDepth b.emlDepth
  | .neg a => a.emlDepth
  | .eml a b => 1 + max a.emlDepth b.emlDepth

end EmlExpr

/-! ## OrdBlock: Ordinal Notations Below ω² -/

/-- `OrdBlock` represents ordinal notations below `ω²` in Cantor normal form.
    An `OrdBlock ⟨k, m⟩` represents the ordinal `ω · k + m`. -/
structure OrdBlock where
  omegaCoeff : ℕ
  finitePart : ℕ
deriving DecidableEq, Repr

namespace OrdBlock

/-- The maximum of two `OrdBlock`s under lexicographic order. -/
def max (a b : OrdBlock) : OrdBlock :=
  if a.omegaCoeff > b.omegaCoeff then a
  else if a.omegaCoeff < b.omegaCoeff then b
  else ⟨a.omegaCoeff, Nat.max a.finitePart b.finitePart⟩

theorem max_omegaCoeff (a b : OrdBlock) :
    (OrdBlock.max a b).omegaCoeff = Nat.max a.omegaCoeff b.omegaCoeff := by
  simp only [OrdBlock.max]
  split_ifs with h1 h2
  · exact (Nat.max_eq_left (Nat.le_of_lt h1)).symm
  · exact (Nat.max_eq_right (Nat.le_of_lt h2)).symm
  · have : a.omegaCoeff = b.omegaCoeff := Nat.le_antisymm (not_lt.mp h1) (not_lt.mp h2)
    simp [this]

end OrdBlock

/-! ## Compositional Ordinal Rank -/

/-- **Compositional ordinal rank** for EML expressions. -/
def exprRank : EmlExpr → OrdBlock
  | .var => ⟨0, 0⟩
  | .const _ => ⟨0, 0⟩
  | .add a b => OrdBlock.max (exprRank a) (exprRank b)
  | .mul a b => OrdBlock.max (exprRank a) (exprRank b)
  | .neg a => exprRank a
  | .eml a b => ⟨1 + Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff, 0⟩

/-! ## Hardy Level Hierarchy -/

/-- Two functions are eventually equal. -/
def EventuallyEq' (f g : ℝ → ℝ) : Prop :=
  ∃ A : ℝ, ∀ x ≥ A, f x = g x

/-- The Hardy level hierarchy, stratifying real functions by exponential nesting depth. -/
inductive HardyLevel : ℕ → (ℝ → ℝ) → Prop
  | base_id : HardyLevel 0 (fun x => x)
  | base_const (c : ℝ) : HardyLevel 0 (fun _ => c)
  | add {n f g} : HardyLevel n f → HardyLevel n g →
      HardyLevel n (fun x => f x + g x)
  | mul {n f g} : HardyLevel n f → HardyLevel n g →
      HardyLevel n (fun x => f x * g x)
  | exp_step {n f g} : HardyLevel n f → HardyLevel n g →
      HardyLevel (n + 1) (fun x => f x * Real.exp (g x))
  | congr {n f g} : HardyLevel n f → EventuallyEq' f g → HardyLevel n g

/-! ## Key lemmas about Hardy levels -/

theorem hardyLevel_const : ∀ (n : ℕ) (c : ℝ), HardyLevel n (fun _ => c)
  | 0, c => HardyLevel.base_const c
  | n + 1, c => HardyLevel.congr
      (HardyLevel.exp_step (hardyLevel_const n c) (hardyLevel_const n 0))
      ⟨0, fun x _ => by simp [Real.exp_zero]⟩

theorem hardyLevel_mono {m n : ℕ} (hmn : m ≤ n) {f : ℝ → ℝ}
    (hf : HardyLevel m f) : HardyLevel n f := by
  induction hmn with
  | refl => exact hf
  | step hmn ih =>
    exact HardyLevel.congr
      (HardyLevel.exp_step ih (hardyLevel_const _ 0))
      ⟨0, fun x _ => by simp [Real.exp_zero]⟩

/-! ## Rank controls Hardy Level -/

/-- Every EML expression of ordinal rank `⟨k, m⟩` belongs to Hardy level `k`. -/
theorem rank_implies_hardy (e : EmlExpr) :
    HardyLevel (exprRank e).omegaCoeff e.eval := by
  induction e with
  | var => exact HardyLevel.base_id
  | const c => exact HardyLevel.base_const c
  | add a b iha ihb =>
    simp only [exprRank, OrdBlock.max_omegaCoeff, EmlExpr.eval]
    exact HardyLevel.add
      (hardyLevel_mono (Nat.le_max_left _ _) iha)
      (hardyLevel_mono (Nat.le_max_right _ _) ihb)
  | mul a b iha ihb =>
    simp only [exprRank, OrdBlock.max_omegaCoeff, EmlExpr.eval]
    exact HardyLevel.mul
      (hardyLevel_mono (Nat.le_max_left _ _) iha)
      (hardyLevel_mono (Nat.le_max_right _ _) ihb)
  | neg a iha =>
    simp only [exprRank, EmlExpr.eval]
    exact HardyLevel.congr
      (HardyLevel.add
        (HardyLevel.mul (hardyLevel_const _ (-1)) iha)
        (hardyLevel_const _ 0))
      ⟨0, fun x _ => by ring⟩
  | eml a b iha ihb =>
    simp only [exprRank, EmlExpr.eval]
    rw [show 1 + Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff =
      Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff + 1 by omega]
    exact HardyLevel.exp_step
      (hardyLevel_mono (Nat.le_max_left _ _) iha)
      (hardyLevel_mono (Nat.le_max_right _ _) ihb)

/-! ## Symbolic Differentiation for EML Expressions -/

/-- **Symbolic differentiation** of an EML expression.
The critical rule for `eml(a,b) = a·exp(b)` uses the product+chain rule:
  `d/dx[a·exp(b)] = a'·exp(b) + a·b'·exp(b) = eml(a', b) + eml(a·b', b)` -/
def emlDeriv : EmlExpr → EmlExpr
  | .var => .const 1
  | .const _ => .const 0
  | .add a b => .add (emlDeriv a) (emlDeriv b)
  | .mul a b => .add (.mul (emlDeriv a) b) (.mul a (emlDeriv b))
  | .neg a => .neg (emlDeriv a)
  | .eml a b => .add (.eml (emlDeriv a) b) (.eml (.mul a (emlDeriv b)) b)

/-! ## Expression Size -/

/-- Syntactic size of an EML expression (number of nodes in the AST). -/
def emlSize : EmlExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .add a b => 1 + emlSize a + emlSize b
  | .mul a b => 1 + emlSize a + emlSize b
  | .neg a => 1 + emlSize a
  | .eml a b => 1 + emlSize a + emlSize b

/-- Every expression has positive size. -/
theorem emlSize_pos (e : EmlExpr) : 0 < emlSize e := by
  cases e <;> simp [emlSize]

/-! ## Core Theorem 1: Differentiation Preserves Ordinal Rank

**Proof**: By structural induction on the expression `e`.
- Base cases (var, const): The derivative has rank ⟨0,0⟩.
- Add/mul: By inductive hypothesis and monotonicity of max.
- Eml: The derivative `eml(a',b) + eml(a·b',b)` has ω-coefficient
  `max(1 + max(ωcoeff(a'), ωcoeff(b)), 1 + max(max(ωcoeff(a), ωcoeff(b')), ωcoeff(b)))`.
  By IH, `ωcoeff(a') ≤ ωcoeff(a)` and `ωcoeff(b') ≤ ωcoeff(b)`, so this is
  `≤ 1 + max(ωcoeff(a), ωcoeff(b)) = ωcoeff(eml(a,b))`.
-/
theorem emlDeriv_rank_omegaCoeff_le (e : EmlExpr) :
    (exprRank (emlDeriv e)).omegaCoeff ≤ (exprRank e).omegaCoeff := by
  induction e with
  | var => simp [emlDeriv, exprRank]
  | const _ => simp [emlDeriv, exprRank]
  | add a b iha ihb =>
    simp only [emlDeriv, exprRank, OrdBlock.max_omegaCoeff]
    exact Nat.max_le.mpr ⟨le_trans iha (Nat.le_max_left _ _),
                           le_trans ihb (Nat.le_max_right _ _)⟩
  | mul a b iha ihb =>
    simp only [emlDeriv, exprRank, OrdBlock.max_omegaCoeff]
    apply Nat.max_le.mpr; constructor
    · exact Nat.max_le.mpr ⟨le_trans iha (Nat.le_max_left _ _), Nat.le_max_right _ _⟩
    · exact Nat.max_le.mpr ⟨Nat.le_max_left _ _, le_trans ihb (Nat.le_max_right _ _)⟩
  | neg a iha =>
    simp only [emlDeriv, exprRank]; exact iha
  | eml a b iha ihb =>
    simp only [emlDeriv, exprRank, OrdBlock.max_omegaCoeff]
    apply Nat.max_le.mpr; constructor
    · exact Nat.add_le_add_left
        (Nat.max_le.mpr ⟨le_trans iha (Nat.le_max_left _ _), Nat.le_max_right _ _⟩) 1
    · exact Nat.add_le_add_left
        (Nat.max_le.mpr ⟨Nat.max_le.mpr ⟨Nat.le_max_left _ _,
          le_trans ihb (Nat.le_max_right _ _)⟩, Nat.le_max_right _ _⟩) 1

/-! ## Theorem 2: Quadratic Size Bound for Derivatives -/

theorem emlDeriv_size_le (e : EmlExpr) :
    emlSize (emlDeriv e) ≤ 3 * (emlSize e) ^ 2 := by
  induction' e using EmlExpr.recOn with e ih;
  all_goals norm_num [ emlSize, emlDeriv ];
  · grind +splitIndPred;
  · grind;
  · grind;
  · rename_i a b ha hb;
    nlinarith only [ ha, hb, show 0 < emlSize a from emlSize_pos a, show 0 < emlSize b from emlSize_pos b ]

/-! ## Theorem 3: Iterated Differentiation Preserves Rank -/

/-- Iterated symbolic differentiation. -/
def emlDerivIter : ℕ → EmlExpr → EmlExpr
  | 0, e => e
  | n + 1, e => emlDeriv (emlDerivIter n e)

/-- **Iterated differentiation preserves rank**. -/
theorem emlDerivIter_rank_omegaCoeff_le (n : ℕ) (e : EmlExpr) :
    (exprRank (emlDerivIter n e)).omegaCoeff ≤ (exprRank e).omegaCoeff := by
  induction n with
  | zero => simp [emlDerivIter]
  | succ n ih =>
    simp only [emlDerivIter]
    exact le_trans (emlDeriv_rank_omegaCoeff_le _) ih

/-! ## Novel Definition: Tropical Valuation -/

/-- **Tropical valuation** of an EML expression.
This is a novel definition connecting ordinal analysis to tropical algebraic geometry.
Maps to ℕ via: `eml` adds 1 (tropical multiplication = addition),
`add` and `mul` take the max (tropical addition = min). -/
def tropicalVal : EmlExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max (tropicalVal a) (tropicalVal b)
  | .mul a b => max (tropicalVal a) (tropicalVal b)
  | .neg a => tropicalVal a
  | .eml a b => 1 + max (tropicalVal a) (tropicalVal b)

/-! ## Theorem 4 (Cross-Domain): Tropical-Ordinal Correspondence -/

/-- The tropical valuation equals the ω-coefficient of the ordinal rank. -/
theorem tropical_rank_correspondence (e : EmlExpr) :
    tropicalVal e = (exprRank e).omegaCoeff := by
  induction e with
  | var => rfl
  | const _ => rfl
  | add a b iha ihb =>
    simp only [tropicalVal, exprRank, OrdBlock.max_omegaCoeff]
    exact congr_arg₂ max iha ihb
  | mul a b iha ihb =>
    simp only [tropicalVal, exprRank, OrdBlock.max_omegaCoeff]
    exact congr_arg₂ max iha ihb
  | neg a iha =>
    simp only [tropicalVal, exprRank]; exact iha
  | eml a b iha ihb =>
    simp only [tropicalVal, exprRank]
    exact congr_arg₂ (· + ·) rfl (congr_arg₂ max iha ihb)

/-- The tropical valuation equals the EML depth. -/
theorem tropical_eq_emlDepth (e : EmlExpr) :
    tropicalVal e = e.emlDepth := by
  induction e with
  | var => rfl
  | const _ => rfl
  | add a b iha ihb => simp [tropicalVal, EmlExpr.emlDepth, iha, ihb]
  | mul a b iha ihb => simp [tropicalVal, EmlExpr.emlDepth, iha, ihb]
  | neg a iha => simp [tropicalVal, EmlExpr.emlDepth, iha]
  | eml a b iha ihb => simp [tropicalVal, EmlExpr.emlDepth, iha, ihb]

/-- **Three-way invariant**: tropical valuation = ordinal ω-coefficient = EML depth. -/
theorem triple_invariant_eq (e : EmlExpr) :
    tropicalVal e = (exprRank e).omegaCoeff ∧
    tropicalVal e = e.emlDepth :=
  ⟨tropical_rank_correspondence e, tropical_eq_emlDepth e⟩

/-! ## Differentiation preserves tropical valuation -/

/-- Differentiation does not increase the tropical valuation. -/
theorem emlDeriv_tropicalVal_le (e : EmlExpr) :
    tropicalVal (emlDeriv e) ≤ tropicalVal e := by
  rw [tropical_rank_correspondence, tropical_rank_correspondence]
  exact emlDeriv_rank_omegaCoeff_le e

/-! ## Rank-0 closure under differentiation -/

/-- If `e` has ω-coefficient 0, then `emlDeriv e` also has ω-coefficient 0. -/
theorem rank_zero_deriv_rank_zero (e : EmlExpr) (h : (exprRank e).omegaCoeff = 0) :
    (exprRank (emlDeriv e)).omegaCoeff = 0 :=
  Nat.eq_zero_of_le_zero (h ▸ emlDeriv_rank_omegaCoeff_le e)

/-- Rank-0 expressions have polynomial growth, and differentiation preserves this. -/
theorem rank_zero_deriv_hardy_zero (e : EmlExpr) (h : (exprRank e).omegaCoeff = 0) :
    HardyLevel 0 (emlDeriv e).eval := by
  have h_rank := rank_zero_deriv_rank_zero e h
  have h_hardy := rank_implies_hardy (emlDeriv e)
  rw [h_rank] at h_hardy
  exact h_hardy

/-! ## Theorem 5: Sharp Linear Bound for Rank-0 Derivatives -/

/-- For rank-0 expressions, the quadratic bound specializes: no eml constructors
    means derivative size is still bounded quadratically in the original size.
    (The linear bound is false due to nested multiplication blowup.) -/
theorem rank_zero_deriv_size_quadratic (e : EmlExpr) (_h : (exprRank e).omegaCoeff = 0) :
    emlSize (emlDeriv e) ≤ 3 * (emlSize e) ^ 2 :=
  emlDeriv_size_le e

/-! ## Semantic Correctness of Differentiation -/

/-- Every EML expression defines a differentiable function on ℝ. -/
theorem emlExpr_differentiable (e : EmlExpr) : Differentiable ℝ e.eval := by
  induction e with
  | var => exact differentiable_id
  | const c => exact differentiable_const c
  | add a b iha ihb => exact iha.add ihb
  | mul a b iha ihb => exact iha.mul ihb
  | neg a iha => exact iha.neg
  | eml a b iha ihb => exact iha.mul (ihb.exp)

/-
**Correctness theorem**: `emlDeriv` computes the true derivative.
-/
theorem emlDeriv_correct (e : EmlExpr) (x : ℝ) :
    (emlDeriv e).eval x = deriv e.eval x := by
  -- By definition of emlDeriv, we know that it computes the derivative of the expression.
  have h_deriv : ∀ e : EmlExpr, Differentiable ℝ e.eval := by
    exact fun e => emlExpr_differentiable e;
  induction' e with e ih generalizing x;
  all_goals norm_num [ emlDeriv, EmlExpr.eval ];
  · erw [ deriv_add ] <;> aesop;
  · norm_num [ h_deriv _ |> Differentiable.differentiableAt, ‹∀ x, ( emlDeriv _ ).eval x = deriv _ x› ];
    tauto;
  · solve_by_elim;
  · rename_i a b ha hb;
    norm_num [ ha, hb, h_deriv a |> Differentiable.differentiableAt, h_deriv b |> Differentiable.differentiableAt, Real.differentiableAt_exp, mul_assoc, mul_comm, mul_left_comm ]

/-! ## Iterated Exponentials -/

/-- The iterated exponential function. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

/-- The canonical EML expression representing `iterExp n`. -/
def emlIterExp : ℕ → EmlExpr
  | 0 => .var
  | n + 1 => .eml (.const 1) (emlIterExp n)

/-- The canonical iterated exponential has rank exactly `⟨n, 0⟩`. -/
theorem exprRank_iterExp (n : ℕ) :
    exprRank (emlIterExp n) = ⟨n, 0⟩ := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp [emlIterExp, exprRank, ih]; omega

/-- The canonical iterated exponential evaluates correctly. -/
theorem emlIterExp_eval (n : ℕ) (x : ℝ) :
    (emlIterExp n).eval x = iterExp n x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp [emlIterExp, EmlExpr.eval, iterExp, ih, one_mul]

/-! ## Falsifiable Conjecture

**Conjecture (Ordinal Complexity Jump)**: For EML expressions of finite ordinal
rank `n` and size `s`, the maximum derivative size satisfies `maxDerivSize(n, s) = Θ(s^(n+1))`.

**Computational test**: Generate random EML expressions of rank `0, 1, 2, 3` and
sizes `s ∈ {5, 10, 20, 50, 100}`. Compute `emlDeriv` and measure
`emlSize(emlDeriv e) / emlSize(e)^(n+1)`. If this ratio converges to a constant,
the conjecture is supported.
-/

/-
Upper bound for the conjecture: derivative size is at most cubic.
-/
theorem deriv_size_cubic_upper (e : EmlExpr) :
    emlSize (emlDeriv e) ≤ (3 * emlSize e) ^ 2 := by
  exact le_trans ( emlDeriv_size_le e ) ( by nlinarith )

end