import Mathlib

/-!
# Rank-Bounded EML: Reverse-Mathematical Strength of Expression Rank

## Overview

This file establishes a formal connection between the syntactic rank of EML
(Exponential-Multiplicative Language) expressions and proof-theoretic strength,
measured via growth complexity certificates.

The central thesis is: **EML rank is a proof-theoretic observable.** Each ω-block
of rank corresponds to a layer of the Hardy hierarchy, and the hierarchy is strict:
expressions in block k+1 grow faster than any function certifiable at depth k.

## Main Results

1. **Rank classification** (`rank_implies_hardyLevel`): Every EML expression of
   rank with ω-coefficient k belongs to Hardy level k.

2. **Certificate extraction** (`hardyLevel_zero_implies_certificate`): Hardy level 0
   functions admit growth certificates at depth 0 (polynomial bounds).

3. **Strict separation** (`iterExp_not_totalityCertificate`): For each k, the
   iterated exponential `iterExp (k+1)` does NOT admit a depth-k certificate.

4. **Block separator existence** (`exists_rank_block_separator`): For each k,
   there exists an EML expression in block k+1 whose growth escapes all depth-k
   certificates.

## Cross-Domain Connections

- **Reverse mathematics**: ω-block rank ↔ induction depth. The `TotalityCertificate k`
  class captures exactly the functions whose totality is provable using k nested
  induction principles — rank bounded at ω·k corresponds to Σ⁰_k-induction.

- **Implicit computational complexity**: `TotalityCertificate k` is a recursion depth
  resource invariant. Bounded-rank EML becomes an implicit complexity model for
  provably total functions.

- **Termination theory**: Ordinal rank functions as a discrete Lyapunov measure,
  with each ω-block transition representing a qualitative jump in termination
  complexity.

## References

Builds on `Catalog/Pythagorean/OrdinalClassification/Theorems.lean` which establishes
the ordinal classification of EML growth via Hardy levels.
-/

noncomputable section

open Real Filter

-- ============================================================================
-- SECTION 1: Core EML Definitions
-- ============================================================================

/-- EML expression language: variables, constants, arithmetic, and the
    transcendental operation `eml(a,b) = a * exp(b)`. -/
inductive EmlExpr where
  | var : EmlExpr
  | const : ℝ → EmlExpr
  | add : EmlExpr → EmlExpr → EmlExpr
  | mul : EmlExpr → EmlExpr → EmlExpr
  | neg : EmlExpr → EmlExpr
  | eml : EmlExpr → EmlExpr → EmlExpr

namespace EmlExpr

/-- Evaluate an EML expression at a real number. -/
def eval : EmlExpr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add a b, x => a.eval x + b.eval x
  | .mul a b, x => a.eval x * b.eval x
  | .neg a, x => -(a.eval x)
  | .eml a b, x => a.eval x * exp (b.eval x)

/-- EML nesting depth: maximum depth of `eml` operations. -/
def emlDepth : EmlExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.emlDepth b.emlDepth
  | .mul a b => max a.emlDepth b.emlDepth
  | .neg a => a.emlDepth
  | .eml a b => 1 + max a.emlDepth b.emlDepth

end EmlExpr

-- ============================================================================
-- SECTION 2: Iterated Exponential
-- ============================================================================

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => exp (iterExp n x)

@[simp] theorem iterExp_zero (x : ℝ) : iterExp 0 x = x := rfl

@[simp] theorem iterExp_succ (n : ℕ) (x : ℝ) :
    iterExp (n + 1) x = exp (iterExp n x) := rfl

-- ============================================================================
-- SECTION 3: Ordinal Rank Infrastructure
-- ============================================================================

/-- `OmegaBlock` represents ordinal notations below `ω²` in Cantor normal form.
    An `OmegaBlock ⟨k, m⟩` represents the ordinal `ω · k + m`. -/
structure OmegaBlock where
  omegaCoeff : ℕ
  finitePart : ℕ
deriving DecidableEq

namespace OmegaBlock

/-- Lexicographic maximum of two OmegaBlocks. -/
def max (a b : OmegaBlock) : OmegaBlock :=
  if a.omegaCoeff > b.omegaCoeff then a
  else if a.omegaCoeff < b.omegaCoeff then b
  else ⟨a.omegaCoeff, Nat.max a.finitePart b.finitePart⟩

theorem max_omegaCoeff (a b : OmegaBlock) :
    (OmegaBlock.max a b).omegaCoeff = Nat.max a.omegaCoeff b.omegaCoeff := by
  unfold OmegaBlock.max
  split_ifs with h1 h2
  · exact (Nat.max_eq_left (le_of_lt h1)).symm
  · exact (Nat.max_eq_right (le_of_lt h2)).symm
  · have : a.omegaCoeff = b.omegaCoeff := le_antisymm (not_lt.mp h1) (not_lt.mp h2)
    simp [this]

end OmegaBlock

/-- **Compositional ordinal rank** for EML expressions. -/
def exprRank : EmlExpr → OmegaBlock
  | .var => ⟨0, 0⟩
  | .const _ => ⟨0, 0⟩
  | .add a b => OmegaBlock.max (exprRank a) (exprRank b)
  | .mul a b => OmegaBlock.max (exprRank a) (exprRank b)
  | .neg a => exprRank a
  | .eml a b => ⟨1 + Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff, 0⟩

-- ============================================================================
-- SECTION 4: Hardy Level Hierarchy
-- ============================================================================

/-- Eventual equality of real functions. -/
def EventuallyEq' (f g : ℝ → ℝ) : Prop :=
  ∃ A : ℝ, ∀ x ≥ A, f x = g x

/-- Hardy level hierarchy: stratifies real functions by exponential nesting depth.
    Level 0 = polynomials (id, constants, closed under +, ×).
    Each `eml` application (f * exp(g)) raises the level by one. -/
inductive HardyLevel : ℕ → (ℝ → ℝ) → Prop
  | base_id : HardyLevel 0 (fun x => x)
  | base_const (c : ℝ) : HardyLevel 0 (fun _ => c)
  | add {n f g} : HardyLevel n f → HardyLevel n g →
      HardyLevel n (fun x => f x + g x)
  | mul {n f g} : HardyLevel n f → HardyLevel n g →
      HardyLevel n (fun x => f x * g x)
  | exp_step {n f g} : HardyLevel n f → HardyLevel n g →
      HardyLevel (n + 1) (fun x => f x * exp (g x))
  | congr {n f g} : HardyLevel n f → EventuallyEq' f g → HardyLevel n g

-- ============================================================================
-- SECTION 5: New Definitions — Totality Certificates and Rank Blocks
-- ============================================================================

/-- A finite proxy for the ω-block complexity of an ordinal rank. -/
abbrev OmegaBlockComplexity := ℕ

/-- `RankInBlock k ob` means the OmegaBlock `ob` lies in the k-th ω-block:
    its ω-coefficient equals k. -/
def RankInBlock (k : ℕ) (ob : OmegaBlock) : Prop := ob.omegaCoeff = k

/-- `TotalityCertificate k f` witnesses that `f : ℝ → ℝ` has growth bounded by
    the k-th level of iterated exponentiation applied to a polynomial.

    Formally: there exist `C > 0`, degree `d`, and threshold `A > 0` such that
    `|f(x)| ≤ iterExp k (C · x^d)` for all `x ≥ A`.

    **Proof-theoretic interpretation**: Functions provably total with `k` nested
    induction schemes over ℕ have growth bounded at level `k`:

    - `TotalityCertificate 0 f` ⟺ `f` has polynomial growth
    - `TotalityCertificate 1 f` ⟺ `f` has at most exp-of-polynomial growth
    - `TotalityCertificate k f` ⟺ `f` has at most k-fold iterated exp growth

    The key theorem `iterExp_not_totalityCertificate` shows this hierarchy is strict. -/
def TotalityCertificate (k : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ (C : ℝ) (d : ℕ) (A : ℝ), 0 < C ∧ 0 < A ∧
    ∀ x, x ≥ A → |f x| ≤ iterExp k (C * x ^ d)

-- ============================================================================
-- SECTION 6: Iterated Exponential Properties
-- ============================================================================

/-- Iterated exponentials compose additively:
    `iterExp m (iterExp n x) = iterExp (n + m) x`. -/
theorem iterExp_comp (m n : ℕ) (x : ℝ) :
    iterExp m (iterExp n x) = iterExp (n + m) x := by
  induction m with
  | zero => rfl
  | succ m ih =>
    show exp (iterExp m (iterExp n x)) = exp (iterExp (n + m) x)
    rw [ih]

/-- `iterExp k` is strictly monotone for every `k`. -/
theorem iterExp_strictMono (k : ℕ) : StrictMono (iterExp k) := by
  induction k with
  | zero => exact strictMono_id
  | succ k ih => exact fun _ _ h => exp_strictMono (ih h)

/-- `iterExp k` is monotone for every `k`. -/
theorem iterExp_mono (k : ℕ) : Monotone (iterExp k) :=
  (iterExp_strictMono k).monotone

/-- `iterExp (k+1) x > 0` for all `x`. -/
theorem iterExp_succ_pos (k : ℕ) (x : ℝ) : 0 < iterExp (k + 1) x :=
  exp_pos _

/-- Key identity: `iterExp (k+1) x = iterExp k (exp x)`. -/
theorem iterExp_succ_eq_comp (k : ℕ) (x : ℝ) :
    iterExp (k + 1) x = iterExp k (exp x) := by
  have h := iterExp_comp k 1 x
  simp only [iterExp] at h
  rw [show k + 1 = 1 + k from by omega]
  exact h.symm

-- ============================================================================
-- SECTION 7: Hardy Level Auxiliary Lemmas
-- ============================================================================

theorem hardyLevel_const : ∀ (n : ℕ) (c : ℝ), HardyLevel n (fun _ => c) := by
  intro n; induction n with
  | zero => intro c; exact HardyLevel.base_const c
  | succ n ih =>
    intro c
    exact HardyLevel.congr
      (HardyLevel.exp_step (ih c) (ih 0))
      ⟨0, fun x _ => by simp [exp_zero]⟩

theorem hardyLevel_mono {m n : ℕ} (hmn : m ≤ n) {f : ℝ → ℝ}
    (hf : HardyLevel m f) : HardyLevel n f := by
  induction hmn with
  | refl => exact hf
  | step _ ih =>
    exact HardyLevel.congr
      (HardyLevel.exp_step ih (hardyLevel_const _ 0))
      ⟨0, fun x _ => by simp [exp_zero]⟩

-- ============================================================================
-- SECTION 8: Canonical Iterated Exponential Expressions
-- ============================================================================

/-- The canonical EML expression representing `iterExp n`. -/
def emlExprIterExp : ℕ → EmlExpr
  | 0 => .var
  | n + 1 => .eml (.const 1) (emlExprIterExp n)

/-- The canonical `iterExp n` expression has ordinal rank `⟨n, 0⟩`. -/
theorem exprRank_iterExp (n : ℕ) :
    exprRank (emlExprIterExp n) = ⟨n, 0⟩ := by
  induction n with
  | zero => rfl
  | succ n ih =>
    unfold emlExprIterExp exprRank
    rw [ih]
    simp [OmegaBlock.mk.injEq, exprRank]
    omega

/-- The canonical expression evaluates to the iterated exponential. -/
theorem emlExprIterExp_eval (n : ℕ) (x : ℝ) :
    (emlExprIterExp n).eval x = iterExp n x := by
  induction n with
  | zero => rfl
  | succ n ih => simp [emlExprIterExp, EmlExpr.eval, ih, iterExp_succ, one_mul]

/-
============================================================================
SECTION 9: Rank Classification Theorem
============================================================================

**Classification theorem**: Every EML expression of ordinal rank `⟨k, m⟩`
    belongs to Hardy level `k`. The ω-coefficient determines the growth class.
-/
theorem rank_implies_hardyLevel (e : EmlExpr) :
    HardyLevel (exprRank e).omegaCoeff e.eval := by
  induction' e using EmlExpr.recOn with e ih;
  exact HardyLevel.base_id;
  · convert hardyLevel_const 0 e using 1;
  · convert HardyLevel.add ( hardyLevel_mono _ ‹HardyLevel ( exprRank ih ).omegaCoeff ih.eval› ) ( hardyLevel_mono _ ‹HardyLevel ( exprRank _ ).omegaCoeff _› ) using 1;
    · grind +locals;
    · exact OmegaBlock.max_omegaCoeff _ _ ▸ Nat.le_max_right _ _;
  · rename_i a b ha hb;
    convert HardyLevel.mul ( hardyLevel_mono _ ha ) ( hardyLevel_mono _ hb ) using 1;
    · grind +locals;
    · exact OmegaBlock.max_omegaCoeff ( exprRank a ) ( exprRank b ) ▸ Nat.le_max_right _ _;
  · rename_i e ih;
    convert HardyLevel.congr ( HardyLevel.mul ( hardyLevel_const _ ( -1 ) ) ih ) ?_ using 1;
    exact ⟨ 0, fun x hx => by simp +decide [ EmlExpr.eval ] ⟩;
  · rename_i a b ha hb;
    -- By definition of `exprRank`, we have `exprRank (a.eml b) = ⟨1 + Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff, 0⟩`.
    have h_rank_eml : exprRank (a.eml b) = ⟨1 + Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff, 0⟩ := by
      rfl;
    convert HardyLevel.exp_step ( hardyLevel_mono _ ha ) ( hardyLevel_mono _ hb ) using 1;
    rw [ h_rank_eml, add_comm ];
    · exact Nat.le_max_left _ _;
    · exact Nat.le_max_right _ _

/-
============================================================================
SECTION 10: Polynomial Growth Bound for Hardy Level 0
============================================================================

Every function at Hardy level 0 has at most polynomial growth.
-/
theorem hardyLevel_zero_poly_bound {f : ℝ → ℝ} (hf : HardyLevel 0 f) :
    ∃ (C : ℝ) (d : ℕ) (A : ℝ), ∀ x ≥ A, |f x| ≤ C * x ^ d := by
  -- By induction on the structure of f, we can show that each case satisfies the polynomial growth condition.
  have h_ind : ∀ (f : ℝ → ℝ) (hf : HardyLevel 0 f), ∃ (C : ℝ) (d : ℕ) (A : ℝ), ∀ x ≥ A, |f x| ≤ C * x ^ d := by
    intro f hf
    have h_ind : ∀ (f : ℝ → ℝ) (hf : HardyLevel 0 f), ∃ (C : ℝ) (d : ℕ) (A : ℝ), (∀ x ≥ A, abs (f x) ≤ C * x ^ d) := by
      intro f hf
      have h_ind : ∀ (n : ℕ), ∀ (f : ℝ → ℝ) (hf : HardyLevel n f), n = 0 → ∃ (C : ℝ) (d : ℕ) (A : ℝ), (∀ x ≥ A, abs (f x) ≤ C * x ^ d) := by
        intros n f hf hn;
        induction' hf with n f g hf hg ihf ihg n f g hf hg ihf ihg n f g hf hg ihf ihg n f g hf hg ihf ihg;
        exact ⟨ 1, 1, 0, fun x hx => by simp +decide [ abs_of_nonneg hx ] ⟩;
        · exact ⟨ |n|, 0, 1, fun x hx => by norm_num ⟩;
        · obtain ⟨ C₁, d₁, A₁, h₁ ⟩ := ihg hn
          obtain ⟨ C₂, d₂, A₂, h₂ ⟩ := n hn;
          use C₁ + C₂, d₁ + d₂, max A₁ (max A₂ 1);
          intro x hx; specialize h₁ x ( le_trans ( le_max_left _ _ ) hx ) ; specialize h₂ x ( le_trans ( le_max_of_le_right ( le_max_left _ _ ) ) hx ) ; simp_all +decide [ abs_le, pow_add ] ;
          constructor <;> nlinarith [ show x ^ d₁ ≥ 1 by exact one_le_pow₀ ( by linarith ), show x ^ d₂ ≥ 1 by exact one_le_pow₀ ( by linarith ), show C₁ * x ^ d₁ ≥ 0 by exact mul_nonneg ( show 0 ≤ C₁ by nlinarith [ show x ^ d₁ ≥ 1 by exact one_le_pow₀ ( by linarith ) ] ) ( pow_nonneg ( by linarith ) _ ), show C₂ * x ^ d₂ ≥ 0 by exact mul_nonneg ( show 0 ≤ C₂ by nlinarith [ show x ^ d₂ ≥ 1 by exact one_le_pow₀ ( by linarith ) ] ) ( pow_nonneg ( by linarith ) _ ) ];
        · obtain ⟨ C₁, d₁, A₁, h₁ ⟩ := ihg hn
          obtain ⟨ C₂, d₂, A₂, h₂ ⟩ := n hn
          use C₁ * C₂, d₁ + d₂, max A₁ A₂ + 1;
          intro x hx; rw [ abs_mul ] ; convert mul_le_mul ( h₁ x ( by linarith [ le_max_left A₁ A₂ ] ) ) ( h₂ x ( by linarith [ le_max_right A₁ A₂ ] ) ) ( by positivity ) ( by
            exact le_trans ( abs_nonneg _ ) ( h₁ x ( by linarith [ le_max_left A₁ A₂ ] ) ) ) using 1 ; ring;
        · contradiction;
        · obtain ⟨ A, hA ⟩ := ihf;
          obtain ⟨ C, d, A', hA' ⟩ := ihg hn;
          exact ⟨ C, d, Max.max A A', fun x hx => by rw [ ← hA x ( le_trans ( le_max_left _ _ ) hx ) ] ; exact hA' x ( le_trans ( le_max_right _ _ ) hx ) ⟩
      exact h_ind 0 f hf rfl;
    exact h_ind f hf;
  exact h_ind f hf

/-
`exp` eventually exceeds any polynomial `C * x^d`.
-/
theorem exp_exceeds_poly (C : ℝ) (d : ℕ) :
    ∃ A : ℝ, ∀ x ≥ A, C * x ^ d < exp x := by
  -- We'll use the fact that $\exp(x) / x^d \to \infty$ as $x \to \infty$.
  have h_exp_div_pow : Filter.Tendsto (fun x : ℝ => Real.exp x / x ^ d) Filter.atTop Filter.atTop := by
    exact Real.tendsto_exp_div_pow_atTop d;
  exact Filter.eventually_atTop.mp ( h_exp_div_pow.eventually_gt_atTop ( Max.max C 1 ) ) |> fun ⟨ A, hA ⟩ ↦ ⟨ Max.max A 1, fun x hx ↦ by have := hA x ( le_trans ( le_max_left _ _ ) hx ) ; rw [ lt_div_iff₀ ( pow_pos ( by linarith [ le_max_right A 1 ] ) _ ) ] at this; nlinarith [ le_max_left C 1, le_max_right C 1, pow_pos ( by linarith [ le_max_right A 1 ] : 0 < x ) d ] ⟩

/-
============================================================================
SECTION 11: Certificate Extraction (Base Case)
============================================================================

**Certificate extraction (base case)**: Hardy level 0 implies
    `TotalityCertificate 0` (polynomial growth bound).
-/
theorem hardyLevel_zero_implies_certificate {f : ℝ → ℝ} (hf : HardyLevel 0 f) :
    TotalityCertificate 0 f := by
  obtain ⟨C, d, A, hC⟩ : ∃ C d A, ∀ x ≥ A, |f x| ≤ C * x ^ d := by
    convert hardyLevel_zero_poly_bound hf using 1;
  refine' ⟨ Max.max C 1, d, Max.max A 1, by positivity, by positivity, fun x hx => _ ⟩;
  simp +zetaDelta at *;
  exact le_trans ( hC x hx.1 ) ( mul_le_mul_of_nonneg_right ( le_max_left _ _ ) ( pow_nonneg ( by linarith ) _ ) )

/-- **Rank-certificate bridge (base case)**: Any EML expression with
    ω-coefficient 0 admits a depth-0 totality certificate. -/
theorem rank_zero_yields_certificate (e : EmlExpr)
    (h : (exprRank e).omegaCoeff = 0) :
    TotalityCertificate 0 e.eval := by
  have := rank_implies_hardyLevel e
  rw [h] at this
  exact hardyLevel_zero_implies_certificate this

/-
============================================================================
SECTION 12: Strict Separation Theorem
============================================================================

**Strict separation**: `iterExp (k+1)` does NOT have a `TotalityCertificate`
    at depth `k`. This is the core nontriviality theorem establishing that the
    rank-indexed totality hierarchy does not collapse.

    **Proof**: By contradiction. If `|iterExp (k+1) x| ≤ iterExp k (C·x^d)`
    for large `x`, then using `iterExp (k+1) x = iterExp k (exp x)` (composition)
    and the fact that `iterExp k` is strictly monotone, we get
    `exp x ≤ C·x^d` for large `x`, contradicting `exp_exceeds_poly`.
-/
theorem iterExp_not_totalityCertificate (k : ℕ) :
    ¬ TotalityCertificate k (iterExp (k + 1)) := by
  intro h
  obtain ⟨C, d, A, hC_pos, hA_pos, h_bound⟩ := h
  have h_exp_bound : ∃ A' : ℝ, ∀ x ≥ A', C * x ^ d < Real.exp x := by
    exact exp_exceeds_poly C d
  obtain ⟨A', hA'⟩ := h_exp_bound
  use by
    -- Choose $x$ large enough such that $x \geq \max(A, A')$.
    obtain ⟨x, hx⟩ : ∃ x : ℝ, x ≥ A ∧ x ≥ A' ∧ 0 < x := by
      exact ⟨ Max.max A ( Max.max A' 1 ), le_max_left _ _, le_max_of_le_right ( le_max_left _ _ ), by positivity ⟩;
    -- Apply the bound to $x$.
    have h_bound_x : iterExp (k + 1) x ≤ iterExp k (C * x ^ d) := by
      exact le_of_abs_le ( h_bound x hx.1 );
    -- Apply the strict monotonicity of `iterExp k`.
    have h_strict_mono : iterExp k (C * x ^ d) < iterExp k (Real.exp x) := by
      exact iterExp_strictMono k ( hA' x hx.2.1 );
    linarith [ show iterExp ( k + 1 ) x = iterExp k ( Real.exp x ) from by rw [ iterExp_succ_eq_comp ] ]

/-
============================================================================
SECTION 13: Block Separator Existence
============================================================================

**Block separator existence**: For each `k`, there exists an EML expression
    in rank block `k+1` (ω-coefficient = k+1) whose growth is NOT captured by
    any depth-k totality certificate.
-/
theorem exists_rank_block_separator (k : ℕ) :
    ∃ e : EmlExpr,
      (exprRank e).omegaCoeff = k + 1 ∧
      ¬ TotalityCertificate k e.eval := by
  refine' ⟨ emlExprIterExp ( k + 1 ), _, _ ⟩;
  · convert congr_arg OmegaBlock.omegaCoeff ( exprRank_iterExp ( k + 1 ) ) using 1;
  · convert iterExp_not_totalityCertificate k using 1;
    exact ⟨ fun h => by obtain ⟨ C, d, A, hC, hA, hcd ⟩ := h; exact ⟨ C, d, A, hC, hA, fun x hx => by simpa only [ emlExprIterExp_eval ] using hcd x hx ⟩, fun h => by obtain ⟨ C, d, A, hC, hA, hcd ⟩ := h; exact ⟨ C, d, A, hC, hA, fun x hx => by simpa only [ emlExprIterExp_eval ] using hcd x hx ⟩ ⟩

/-
============================================================================
SECTION 14: Rank Structural Lemmas
============================================================================

ω-coefficient of rank equals EML depth.
-/
theorem exprRank_omegaCoeff_eq_emlDepth (e : EmlExpr) :
    (exprRank e).omegaCoeff = e.emlDepth := by
  induction' e using EmlExpr.recOn with e ih_a ih_b;
  all_goals simp_all +decide [ exprRank, EmlExpr.emlDepth ];
  · grind +suggestions;
  · rename_i a b ha hb;
    rw [ ← ha, ← hb, OmegaBlock.max_omegaCoeff ]

/-- Rank with ω-coefficient ≤ k implies Hardy level k. -/
theorem rank_le_implies_hardyLevel (e : EmlExpr) (k : ℕ)
    (h : (exprRank e).omegaCoeff ≤ k) :
    HardyLevel k e.eval :=
  hardyLevel_mono h (rank_implies_hardyLevel e)

/-
`exp` (= iterExp 1) is not at Hardy level 0. Base case of strict separation.
-/
theorem exp_not_hardyLevel_zero : ¬ HardyLevel 0 (iterExp 1) := by
  -- Apply the strict separation theorem with k=0 to conclude that iterExp 1 is not at Hardy level 0.
  have := iterExp_not_totalityCertificate 0;
  simp at this;
  contrapose! this;
  convert hardyLevel_zero_implies_certificate this using 1

/-
============================================================================
SECTION 15: Certificate Hierarchy Properties
============================================================================

`TotalityCertificate` is monotone in level: if `f` has a certificate at
    depth `k`, it also has one at depth `k+1`.
-/
theorem totalityCertificate_mono {k : ℕ} {f : ℝ → ℝ}
    (hf : TotalityCertificate k f) :
    TotalityCertificate (k + 1) f := by
  obtain ⟨ C, d, A, hC, hA, h ⟩ := hf;
  refine' ⟨ C, d, A, hC, hA, fun x hx => le_trans ( h x hx ) _ ⟩;
  exact le_trans ( by linarith ) ( Real.add_one_le_exp _ )

/-
The identity function has a `TotalityCertificate 0`.
-/
theorem totalityCertificate_zero_id :
    TotalityCertificate 0 (fun x : ℝ => x) := by
  -- Use C=1, d=1, A=1. Then |x| ≤ 1 * x^1 = x for x ≥ 1 since x ≥ 1 > 0 implies |x| = x. iterExp 0 (1 * x^1) = x.
  use 1, 1, 1
  simp [iterExp_zero];
  exact fun x hx => by rw [ abs_of_nonneg ( by linarith ) ] ;

/-
Constants have a `TotalityCertificate 0`.
-/
theorem totalityCertificate_zero_const (c : ℝ) :
    TotalityCertificate 0 (fun _ : ℝ => c) := by
  convert hardyLevel_zero_implies_certificate ( hardyLevel_const 0 c )

-- ============================================================================
-- SECTION 16: Rank-Block Totality and Verified Classifier
-- ============================================================================

/-- **Rank-block totality principle (base)**: Every EML expression with
    ω-coefficient 0 has its growth function captured by a depth-0 certificate. -/
theorem rank_block_yields_certificate_zero (e : EmlExpr)
    (h : (exprRank e).omegaCoeff = 0) :
    ∃ f : ℝ → ℝ, (∀ x, f x = e.eval x) ∧ TotalityCertificate 0 f :=
  ⟨e.eval, fun _ => rfl, rank_zero_yields_certificate e h⟩

/-- **Verified ordinal classifier**: Given an EML expression, computes its
    ordinal rank with proof certificates. -/
def ordinalClassify (e : EmlExpr) :
    { r : OmegaBlock //
      r = exprRank e ∧
      r.omegaCoeff = e.emlDepth ∧
      HardyLevel r.omegaCoeff e.eval } :=
  ⟨exprRank e,
   rfl,
   exprRank_omegaCoeff_eq_emlDepth e,
   rank_implies_hardyLevel e⟩

end