/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import EML.CategoryDefs

/-!
# Log-Affine Normal Form and Normalization

This file defines a syntactic representation of the multiplicative positive EML fragment
and proves a semantic normalization theorem: every expression in the multiplicative
positive fragment evaluates to a log-affine function.

## Main definitions

* `PosEMLExpr n` — Inductive syntax for the multiplicative positive fragment of EML:
  coordinate projections, positive constants, multiplication, and real powers `x^r`.

* `evalPosEML` — Semantic evaluation of `PosEMLExpr n` on positive vectors.

* `toLogAffineForm` — Syntactic normalization: every `PosEMLExpr` normalizes to
  weights `w : Fin n → ℝ` and a constant `c : ℝ`.

## Main results

* `evalPosEML_eq_logAffine` — Semantic correctness: the evaluation of any multiplicative
  positive EML expression equals its log-affine normal form `exp(∑ wᵢ log xᵢ + c)`.

* `posEML_is_logAffine` — Every multiplicative positive EML expression is `LogAffine`.

## Significance

This establishes a **normal form theorem** for the multiplicative positive fragment:
every expression built from coordinate projections, positive constants, multiplication,
and real powers is equivalent to a weighted geometric monomial. This is the algebraic
content of "log-linearization" — the multiplicative fragment secretly lives in the
affine geometry of logarithmic coordinates.
-/

noncomputable section

open Finset Real

/-! ## Syntax for the multiplicative positive fragment -/

/-- Syntactic expressions for the multiplicative positive EML fragment.
These expressions are guaranteed to evaluate to positive values on positive inputs. -/
inductive PosEMLExpr (n : ℕ) : Type where
  /-- Coordinate projection `xᵢ`. -/
  | coord (i : Fin n) : PosEMLExpr n
  /-- A positive constant `c > 0`. -/
  | posConst (c : ℝ) (hc : 0 < c) : PosEMLExpr n
  /-- Multiplication `e₁ · e₂`. -/
  | mul (e₁ e₂ : PosEMLExpr n) : PosEMLExpr n
  /-- Real power `e^r` for `r : ℝ`. -/
  | rpow (e : PosEMLExpr n) (r : ℝ) : PosEMLExpr n

/-- Semantic evaluation of a multiplicative positive EML expression on a positive vector. -/
def evalPosEML {n : ℕ} : PosEMLExpr n → PosVec n → ℝ
  | .coord i, x => x.val i
  | .posConst c _, _ => c
  | .mul e₁ e₂, x => evalPosEML e₁ x * evalPosEML e₂ x
  | .rpow e r, x => (evalPosEML e x) ^ r

/-
Evaluation of positive EML expressions is strictly positive on positive inputs.
-/
theorem evalPosEML_pos {n : ℕ} (e : PosEMLExpr n) (x : PosVec n) :
    0 < evalPosEML e x := by
  induction' e with e₁ e₂ ih₁ ih₂ e ih;
  · exact x.pos e₁;
  · exact ih₁;
  · exact mul_pos ih ‹_›;
  · exact Real.rpow_pos_of_pos ‹_› _

/-! ## Syntactic normalization to log-affine form -/

/-- Normalize a multiplicative positive EML expression to log-affine form:
returns weights `w : Fin n → ℝ` and a constant `c : ℝ` such that the expression
evaluates to `exp(∑ᵢ wᵢ · log(xᵢ) + c)`. -/
def toLogAffineForm {n : ℕ} : PosEMLExpr n → (Fin n → ℝ) × ℝ
  | .coord i => (Pi.single i 1, 0)
  | .posConst c _ => (0, Real.log c)
  | .mul e₁ e₂ =>
    let (w₁, c₁) := toLogAffineForm e₁
    let (w₂, c₂) := toLogAffineForm e₂
    (w₁ + w₂, c₁ + c₂)
  | .rpow e r =>
    let (w, c) := toLogAffineForm e
    (r • w, r * c)

/-
**Semantic correctness of normalization.** The evaluation of any multiplicative
positive EML expression equals its log-affine normal form.

For any expression `e` and positive input `x`:
  `eval(e)(x) = exp(∑ᵢ wᵢ · log(xᵢ) + c)`
where `(w, c) = toLogAffineForm(e)`.

This is the core normalization theorem: it says the syntactic normalization procedure
correctly computes the log-affine representation.
-/
theorem evalPosEML_eq_logAffine {n : ℕ} (e : PosEMLExpr n) (x : PosVec n) :
    evalPosEML e x =
      Real.exp (∑ i, (toLogAffineForm e).1 i * Real.log (x.val i) + (toLogAffineForm e).2) := by
  induction' e with e₁ e₂ ih₁ ih₂;
  · simp +decide [ evalPosEML, toLogAffineForm ];
    rw [ Finset.sum_eq_single e₁ ] <;> simp +decide [ Real.exp_log ( x.pos _ ) ];
    exact fun i hi => Or.inl <| Pi.single_eq_of_ne hi _;
  · unfold evalPosEML toLogAffineForm; norm_num [ Real.exp_log ih₁ ] ;
  · erw [ show evalPosEML ( ih₂.mul _ ) x = evalPosEML ih₂ x * evalPosEML _ x from rfl ] ; simp_all +decide [ Real.exp_add, Finset.sum_add_distrib ];
    erw [ show toLogAffineForm ( ih₂.mul _ ) = ( ( toLogAffineForm ih₂ ).1 + ( toLogAffineForm _ ).1, ( toLogAffineForm ih₂ ).2 + ( toLogAffineForm _ ).2 ) from rfl ] ; simp +decide [ Finset.sum_add_distrib, mul_assoc, ← Real.exp_add ] ; ring;
    rw [ Finset.sum_add_distrib ] ; ring;
  · simp_all +decide [ evalPosEML, toLogAffineForm ];
    rw [ ← Real.exp_mul ] ; simp +decide [ mul_add, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;

/-- Every multiplicative positive EML expression is `LogAffine`. -/
theorem posEML_is_logAffine {n : ℕ} (e : PosEMLExpr n) :
    LogAffine n (evalPosEML e) := by
  exact ⟨(toLogAffineForm e).1, (toLogAffineForm e).2,
    fun x => evalPosEML_eq_logAffine e x⟩

end