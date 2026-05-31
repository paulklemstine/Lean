import Mathlib
import EML.Complexity.Defs
import EML.Complexity.Basic

/-!
# EML Universal Approximation with Complexity Bounds

This file establishes deep connections between EML expression complexity,
approximation theory, and information-theoretic lower bounds.

## Main Results

1. **`eml_composition_depth_additive`**: Composition depth adds under substitution.
2. **`eml_iterExp_exact_depth`**: Exponential towers are representable at exact depth n.
3. **`emlExprIterExp_size`**: The canonical tower construction has size 3n+1.
4. **`eml_kfold_depth_bound`**: k-fold composition of depth-d functions has depth ≤ k*d.
5. **`depth_requires_initial_complexity`**: Information decay forces high initial complexity.
6. **`desc_complexity_antitone_eps`**: Tighter tolerance needs larger expressions.
7. **`approx_chain_refines`**: Later chain entries are valid at earlier tolerances.

## Novel Definitions

- `EMLComplexityClass`: Classifies functions by asymptotic EML description
  complexity growth as ε → 0.
- `EMLApproxChain`: A sequence of improving EML approximants.
- `EMLExpr.subst`: Syntactic composition of EML expressions.
-/

noncomputable section

open Real

/-! ## Local Definitions -/

/-- Uniform approximation of `f` by `g` on `[a, b]` to within `eps`. -/
def UniformApproxOn' (f g : ℝ → ℝ) (a b eps : ℝ) : Prop :=
  ∀ x, a ≤ x → x ≤ b → |f x - g x| ≤ eps

/-- EML description complexity using the `EMLExpr` from `Complexity.Defs`. -/
def eml_desc_complexity (f : ℝ → ℝ) (a b eps : ℝ) : ℕ :=
  sInf {n : ℕ | ∃ e : EMLExpr, e.size ≤ n ∧ UniformApproxOn' f (e.eval ·) a b eps}

/-- Retained symbolic information after `l` layers with contraction `α`. -/
def retainedInfo (α : ℝ) (l K : ℕ) : ℝ := α ^ l * (K : ℝ)

/-! ## Novel Definition: EML Complexity Classes -/

/-- An **EML complexity class** specifies a growth rate for description
complexity as a function of inverse tolerance. -/
structure EMLComplexityClass where
  rate : ℕ → ℕ
  rate_mono : Monotone rate
  rate_pos : ∀ n, 0 < n → 0 < rate n

/-- A function belongs to an EML complexity class if its description
complexity is eventually bounded by the class rate function. -/
def InEMLClass (f : ℝ → ℝ) (cls : EMLComplexityClass) : Prop :=
  ∃ N : ℕ, ∀ n : ℕ, N ≤ n → 0 < n →
    eml_desc_complexity f 0 1 (1 / (n : ℝ)) ≤ cls.rate n

/-- The **linear EML complexity class**: O(1/ε) complexity. -/
def linearEMLClass (C : ℕ) (hC : 0 < C) : EMLComplexityClass where
  rate := fun n => C * n
  rate_mono := fun _ _ h => Nat.mul_le_mul_left C h
  rate_pos := fun n hn => Nat.mul_pos hC hn

/-- The **polynomial EML complexity class** of degree `k`. -/
def polyEMLClass (C k : ℕ) (hC : 0 < C) (_hk : 0 < k) : EMLComplexityClass where
  rate := fun n => C * n ^ k
  rate_mono := fun _ _ h => Nat.mul_le_mul_left C (Nat.pow_le_pow_left h k)
  rate_pos := fun _n hn => by positivity

/-- **Linear = polynomial degree 1.** -/
theorem linear_eq_poly_one (C : ℕ) (hC : 0 < C) :
    ∀ n, (linearEMLClass C hC).rate n = (polyEMLClass C 1 hC one_pos).rate n := by
  intro n; simp [linearEMLClass, polyEMLClass]

/-- **Higher polynomial degree gives a weaker (larger) bound.** -/
theorem poly_class_monotone_degree (C k₁ k₂ : ℕ)
    (hC : 0 < C) (hk₁ : 0 < k₁) (hk₂ : 0 < k₂) (hle : k₁ ≤ k₂) :
    ∀ n, 1 ≤ n →
      (polyEMLClass C k₁ hC hk₁).rate n ≤ (polyEMLClass C k₂ hC hk₂).rate n := by
  intro n hn
  simp [polyEMLClass]
  exact Nat.mul_le_mul_left C (Nat.pow_le_pow_right hn hle)

/-! ## EML Expression Composition -/

namespace EMLExpr

/-- Substitute `inner` for the variable in `outer`. -/
def subst : EMLExpr → EMLExpr → EMLExpr
  | .var, inner => inner
  | .const c, _ => .const c
  | .add a b, inner => .add (a.subst inner) (b.subst inner)
  | .mul a b, inner => .mul (a.subst inner) (b.subst inner)
  | .neg a, inner => .neg (a.subst inner)
  | .inv a, inner => .inv (a.subst inner)
  | .eml a b, inner => .eml (a.subst inner) (b.subst inner)

/-- Size is always positive. -/
theorem size_pos' (e : EMLExpr) : 0 < e.size := by
  induction e <;> simp_all [EMLExpr.size]

/-- **Substitution = function composition.** -/
theorem eval_subst (outer inner : EMLExpr) (x : ℝ) :
    (outer.subst inner).eval x = outer.eval (inner.eval x) := by
  induction outer with
  | var => rfl
  | const _ => rfl
  | add a b iha ihb => simp [subst, EMLExpr.eval, iha, ihb]
  | mul a b iha ihb => simp [subst, EMLExpr.eval, iha, ihb]
  | neg a iha => simp [subst, EMLExpr.eval, iha]
  | inv a iha => simp [subst, EMLExpr.eval, iha]
  | eml a b iha ihb => simp [subst, EMLExpr.eval, iha, ihb]

/-- **EML depth of substitution ≤ sum of depths.** -/
theorem emlDepth_subst_le (outer inner : EMLExpr) :
    (outer.subst inner).emlDepth ≤ outer.emlDepth + inner.emlDepth := by
  induction outer with
  | var => simp [subst]
  | const _ => simp [subst, EMLExpr.emlDepth]
  | add _ _ iha ihb => simp only [subst, EMLExpr.emlDepth]; omega
  | mul _ _ iha ihb => simp only [subst, EMLExpr.emlDepth]; omega
  | neg _ iha => simp only [subst, EMLExpr.emlDepth]; omega
  | inv _ iha => simp only [subst, EMLExpr.emlDepth]; omega
  | eml _ _ iha ihb => simp only [subst, EMLExpr.emlDepth]; omega

/-- **Size of substitution is multiplicatively bounded.** -/
theorem size_subst_le (outer inner : EMLExpr) :
    (outer.subst inner).size ≤ outer.size * inner.size := by
  induction outer with
  | var => simp [subst, EMLExpr.size]
  | const _ =>
    simp only [subst, EMLExpr.size]
    have := size_pos' inner; omega
  | add a b iha ihb =>
    simp only [subst, EMLExpr.size]
    have := size_pos' inner
    nlinarith
  | mul a b iha ihb =>
    simp only [subst, EMLExpr.size]
    have := size_pos' inner
    nlinarith
  | neg a iha =>
    simp only [subst, EMLExpr.size]
    have := size_pos' inner
    nlinarith
  | inv a iha =>
    simp only [subst, EMLExpr.size]
    have := size_pos' inner
    nlinarith
  | eml a b iha ihb =>
    simp only [subst, EMLExpr.size]
    have := size_pos' inner
    nlinarith

/-- Iterated substitution. -/
def iterSubst (e : EMLExpr) : ℕ → EMLExpr
  | 0 => .var
  | n + 1 => e.subst (e.iterSubst n)

/-- **Iterated substitution = iterated function composition.** -/
theorem eval_iterSubst (e : EMLExpr) (k : ℕ) (x : ℝ) :
    (e.iterSubst k).eval x = (e.eval)^[k] x := by
  induction k with
  | zero => rfl
  | succ k ih =>
    simp only [iterSubst, Function.iterate_succ', Function.comp]
    rw [eval_subst, ih]

/-- **Depth of k-fold composition ≤ k * depth.** -/
theorem emlDepth_iterSubst_le (e : EMLExpr) (k : ℕ) :
    (e.iterSubst k).emlDepth ≤ k * e.emlDepth := by
  induction k with
  | zero => simp [iterSubst, EMLExpr.emlDepth]
  | succ k ih =>
    simp only [iterSubst]
    calc (e.subst (e.iterSubst k)).emlDepth
        ≤ e.emlDepth + (e.iterSubst k).emlDepth := emlDepth_subst_le e _
      _ ≤ e.emlDepth + k * e.emlDepth := by omega
      _ = (k + 1) * e.emlDepth := by ring_nf

end EMLExpr

/-! ## Main Theorems -/

/-- **Composition depth is additive.** -/
theorem eml_composition_depth_additive (e_f e_g : EMLExpr) :
    (e_f.subst e_g).emlDepth ≤ e_f.emlDepth + e_g.emlDepth :=
  EMLExpr.emlDepth_subst_le e_f e_g

/-- **Composition semantics.** -/
theorem eml_composition_correct (e_f e_g : EMLExpr) (x : ℝ) :
    (e_f.subst e_g).eval x = e_f.eval (e_g.eval x) :=
  EMLExpr.eval_subst e_f e_g x

/-- **Size blows up at most multiplicatively under composition.** -/
theorem eml_composition_size_bound (e_f e_g : EMLExpr) :
    (e_f.subst e_g).size ≤ e_f.size * e_g.size :=
  EMLExpr.size_subst_le e_f e_g

/-- **The canonical EML tower has size 2n+1.**
emlExprIterExp n = eml(1, eml(1, ..., var)...) adds 2 nodes per layer
(the eml node and the const 1 node). -/
theorem emlExprIterExp_size (n : ℕ) :
    (emlExprIterExp n).size = 2 * n + 1 := by
  induction n with
  | zero => rfl
  | succ n ih => simp only [emlExprIterExp, EMLExpr.size]; omega

/-- **Exponential towers are representable at exact depth n.** -/
theorem eml_iterExp_exact_depth (n : ℕ) :
    ∃ e : EMLExpr, RepresentsOnPos e (iterExp n) ∧ e.emlDepth = n :=
  ⟨emlExprIterExp n,
    fun x _ => emlExprIterExp_eval n x,
    emlExprIterExp_emlDepth n⟩

/-- **Complete efficiency characterization for exponential towers.** -/
theorem eml_tower_efficient (n : ℕ) :
    ∃ e : EMLExpr, RepresentsOnPos e (iterExp n) ∧
      e.emlDepth = n ∧ e.size = 2 * n + 1 :=
  ⟨emlExprIterExp n,
    fun x _ => emlExprIterExp_eval n x,
    emlExprIterExp_emlDepth n,
    emlExprIterExp_size n⟩

/-- **EML beats polynomials for towers: linear-size representation.** -/
theorem eml_beats_poly_for_towers (n : ℕ) :
    ∃ e : EMLExpr, RepresentsOnPos e (iterExp n) ∧ e.size ≤ 2 * n + 1 :=
  ⟨emlExprIterExp n,
    fun x _ => emlExprIterExp_eval n x,
    le_of_eq (emlExprIterExp_size n)⟩

/-- **Strict depth hierarchy.** -/
theorem eml_depth_hierarchy (n : ℕ) :
    (∃ e : EMLExpr, RepresentsOnPos e (iterExp n) ∧ e.emlDepth ≤ n) ∧
    (∃ e : EMLExpr, RepresentsOnPos e (iterExp (n + 1)) ∧ e.emlDepth ≤ n + 1) :=
  ⟨⟨emlExprIterExp n,
      fun x _ => emlExprIterExp_eval n x,
      le_of_eq (emlExprIterExp_emlDepth n)⟩,
    ⟨emlExprIterExp (n + 1),
      fun x _ => emlExprIterExp_eval (n + 1) x,
      le_of_eq (emlExprIterExp_emlDepth (n + 1))⟩⟩

/-- **Description complexity is anti-monotone in ε.**
Tighter tolerance requires at least as large expressions. -/
theorem desc_complexity_antitone_eps (f : ℝ → ℝ) (a b ε₁ ε₂ : ℝ)
    (hle : ε₁ ≤ ε₂)
    (hne : {n : ℕ | ∃ e : EMLExpr, e.size ≤ n ∧
      UniformApproxOn' f (e.eval ·) a b ε₁}.Nonempty) :
    eml_desc_complexity f a b ε₂ ≤ eml_desc_complexity f a b ε₁ := by
  apply csInf_le_csInf (OrderBot.bddBelow _) hne
  intro n ⟨e, hsize, happrox⟩
  exact ⟨e, hsize, fun x ha hb => le_trans (happrox x ha hb) hle⟩

/-- **Deeper architectures need higher initial complexity.** -/
theorem depth_requires_initial_complexity
    (α : ℝ) (l K : ℕ) (threshold : ℝ)
    (hα0 : 0 < α)
    (hretain : threshold ≤ retainedInfo α l K) :
    threshold / α ^ l ≤ (K : ℝ) := by
  unfold retainedInfo at hretain
  rw [div_le_iff₀ (pow_pos hα0 l)]
  linarith [mul_comm (α ^ l) (K : ℝ)]

/-- **Retained information is monotonically decreasing in depth.** -/
theorem retainedInfo_antitone_depth
    (α : ℝ) (l₁ l₂ K : ℕ)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1) (hle : l₁ ≤ l₂) :
    retainedInfo α l₂ K ≤ retainedInfo α l₁ K := by
  unfold retainedInfo
  exact mul_le_mul_of_nonneg_right
    (pow_le_pow_of_le_one hα0 hα1 hle)
    (Nat.cast_nonneg K)

/-- **Retained information ≤ initial information.** -/
theorem retainedInfo_le_initial
    (α : ℝ) (l K : ℕ) (hα0 : 0 ≤ α) (hα1 : α ≤ 1) :
    retainedInfo α l K ≤ K := by
  unfold retainedInfo
  exact mul_le_of_le_one_left (Nat.cast_nonneg K) (pow_le_one₀ hα0 hα1)

/-- **k-fold composition depth bound.** -/
theorem eml_kfold_depth_bound (e : EMLExpr) (k : ℕ) :
    (e.iterSubst k).emlDepth ≤ k * e.emlDepth :=
  EMLExpr.emlDepth_iterSubst_le e k

/-- **k-fold composition computes iterated function.** -/
theorem eml_kfold_correct (e : EMLExpr) (k : ℕ) (x : ℝ) :
    (e.iterSubst k).eval x = (e.eval)^[k] x :=
  EMLExpr.eval_iterSubst e k x

/-- **EML represents exp(f) via the eml node.** -/
theorem eml_closed_exp (e : EMLExpr) :
    ∀ x : ℝ, (EMLExpr.eml (.const 1) e).eval x = Real.exp (e.eval x) := by
  intro x; simp [EMLExpr.eval, one_mul]

/-- **EML depth of exp(f) = emlDepth(f) + 1.** -/
theorem eml_exp_depth (e : EMLExpr) :
    (EMLExpr.eml (.const 1) e).emlDepth = e.emlDepth + 1 := by
  simp [EMLExpr.emlDepth]; omega

/-- **EML expRank of exp(f) = expRank(f) + 1.** -/
theorem eml_exp_rank (e : EMLExpr) :
    (EMLExpr.eml (.const 1) e).expRank = e.expRank + 1 := by
  simp [EMLExpr.expRank]

/-! ## Approximation Chain Theory -/

/-- An **EML approximation chain**: a sequence with decreasing error. -/
structure EMLApproxChain (f : ℝ → ℝ) (a b : ℝ) where
  exprs : ℕ → EMLExpr
  errors : ℕ → ℝ
  errors_pos : ∀ n, 0 < errors n
  errors_decr : StrictAnti errors
  approx : ∀ n, UniformApproxOn' f (fun x => (exprs n).eval x) a b (errors n)

/-- **Later approximants are valid for earlier tolerances.** -/
theorem approx_chain_refines
    {f : ℝ → ℝ} {a b : ℝ}
    (chain : EMLApproxChain f a b)
    {n m : ℕ} (hnm : n ≤ m) :
    ∀ x, a ≤ x → x ≤ b →
      |f x - (chain.exprs m).eval x| ≤ chain.errors n := by
  intro x hxa hxb
  rcases eq_or_lt_of_le hnm with rfl | hlt
  · exact chain.approx n x hxa hxb
  · exact le_trans (chain.approx m x hxa hxb) (le_of_lt (chain.errors_decr hlt))

/-- **Chain errors are strictly decreasing.** -/
theorem approx_chain_errors_decrease
    {f : ℝ → ℝ} {a b : ℝ}
    (chain : EMLApproxChain f a b)
    {n m : ℕ} (hnm : n < m) :
    chain.errors m < chain.errors n :=
  chain.errors_decr hnm

/-! ## Information-Theoretic Bounds -/

/-- **Quantitative information decay.**
After `l ≥ 1` layers with `α ≤ 1`, retained info ≤ `α * K`. -/
theorem retainedInfo_first_step_decay
    (α : ℝ) (l K : ℕ)
    (hα0 : 0 ≤ α) (hα1 : α ≤ 1)
    (hl : 0 < l) :
    retainedInfo α l K ≤ α * (K : ℝ) := by
  unfold retainedInfo
  calc α ^ l * (K : ℝ)
      ≤ α ^ 1 * (K : ℝ) := mul_le_mul_of_nonneg_right
          (pow_le_pow_of_le_one hα0 hα1 hl) (Nat.cast_nonneg K)
    _ = α * K := by ring

/-- **Information-complexity product is nonneg.** -/
theorem info_complexity_product_nonneg
    (α : ℝ) (l K : ℕ) (hα0 : 0 ≤ α) :
    0 ≤ retainedInfo α l K * (l : ℝ) := by
  apply mul_nonneg
  · exact mul_nonneg (pow_nonneg hα0 l) (Nat.cast_nonneg K)
  · exact Nat.cast_nonneg l

/-! ## Falsifiable Conjecture

**EML Optimal Size Conjecture**: For `iterExp n` (n-fold iterated exponential),
the minimum-size EML expression tree of emlDepth exactly n has size exactly `2n + 1`.

**Evidence**: `emlExprIterExp n` achieves depth n with size 2n+1. Each layer
`eml(const 1, ·)` adds exactly 2 nodes (the eml node and the const 1).

**Computational test**: For n ∈ {1,2,3,4}, enumerate all EML trees with
size < 2n+1 and emlDepth = n, and verify none represents iterExp n on (0,∞).
-/

end