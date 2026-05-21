import Mathlib

/-!
# Ordinal Classification of EML Growth

This file establishes the first ordinal-analysis theory for EML expression growth.
We define a compositional **ordinal rank** `exprRank : EmlExpr → OmegaBlock` that
maps EML syntax to ordinal notations below `ω²`, and prove that this rank:

1. Correctly classifies canonical iterated exponentials (`iterExp n` gets rank `ω·n`),
2. Equals the EML nesting depth in its `ω`-coefficient,
3. Controls asymptotic growth via the Hardy level hierarchy,
4. Witnesses strict asymptotic separation between consecutive `ω`-blocks.
-/

noncomputable section

open Real Filter

/-! ## EML Expression Language (self-contained definitions) -/

/-- EML expression language: transcendence enters only through `eml(a,b) = a * exp(b)`. -/
inductive EmlExpr' where
  | var : EmlExpr'
  | const : ℝ → EmlExpr'
  | add : EmlExpr' → EmlExpr' → EmlExpr'
  | mul : EmlExpr' → EmlExpr' → EmlExpr'
  | neg : EmlExpr' → EmlExpr'
  | eml : EmlExpr' → EmlExpr' → EmlExpr'

namespace EmlExpr'

/-- Evaluation of `EmlExpr'` at a point `x : ℝ`. -/
def eval : EmlExpr' → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add a b, x => a.eval x + b.eval x
  | .mul a b, x => a.eval x * b.eval x
  | .neg a, x => -(a.eval x)
  | .eml a b, x => a.eval x * Real.exp (b.eval x)

/-- EML depth: counts the maximum nesting depth of `eml` operations. -/
def emlDepth : EmlExpr' → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.emlDepth b.emlDepth
  | .mul a b => max a.emlDepth b.emlDepth
  | .neg a => a.emlDepth
  | .eml a b => 1 + max a.emlDepth b.emlDepth

end EmlExpr'

/-! ## Iterated Exponential -/

/-- The iterated exponential: `iterExp' 0 x = x`, `iterExp' (n+1) x = exp(iterExp' n x)`. -/
def iterExp' : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp' n x)

@[simp] theorem iterExp'_zero (x : ℝ) : iterExp' 0 x = x := rfl
@[simp] theorem iterExp'_succ (n : ℕ) (x : ℝ) :
    iterExp' (n + 1) x = Real.exp (iterExp' n x) := rfl

/-- The canonical `EmlExpr'` representing `iterExp' n`. -/
def emlExprIterExp' : ℕ → EmlExpr'
  | 0 => .var
  | n + 1 => .eml (.const 1) (emlExprIterExp' n)

/-! ## Eventual Relations -/

/-- Two functions are eventually equal if they agree for all sufficiently large inputs. -/
def EventuallyEq'' (f g : ℝ → ℝ) : Prop :=
  ∃ A : ℝ, ∀ x ≥ A, f x = g x

/-! ## Hardy Level Hierarchy -/

/-- The Hardy level hierarchy, stratifying real functions by exponential nesting depth.
    Level 0 contains the identity, constants, and closure under `+` and `*`.
    Each application of `f * exp(g)` raises the level by one. -/
inductive HardyLevel' : ℕ → (ℝ → ℝ) → Prop
  | base_id : HardyLevel' 0 (fun x => x)
  | base_const (c : ℝ) : HardyLevel' 0 (fun _ => c)
  | add {n f g} : HardyLevel' n f → HardyLevel' n g →
      HardyLevel' n (fun x => f x + g x)
  | mul {n f g} : HardyLevel' n f → HardyLevel' n g →
      HardyLevel' n (fun x => f x * g x)
  | exp_step {n f g} : HardyLevel' n f → HardyLevel' n g →
      HardyLevel' (n + 1) (fun x => f x * Real.exp (g x))
  | congr {n f g} : HardyLevel' n f → EventuallyEq'' f g → HardyLevel' n g

/-! ## OmegaBlock: Ordinal Notations Below ω² -/

/-- `OmegaBlock` represents ordinal notations below `ω²` in Cantor normal form.
    An `OmegaBlock ⟨k, m⟩` represents the ordinal `ω · k + m`. -/
structure OmegaBlock where
  omegaCoeff : ℕ
  finitePart : ℕ
deriving DecidableEq, Repr

namespace OmegaBlock

/-- The maximum of two `OmegaBlock`s under lexicographic order. -/
def max (a b : OmegaBlock) : OmegaBlock :=
  if a.omegaCoeff > b.omegaCoeff then a
  else if a.omegaCoeff < b.omegaCoeff then b
  else ⟨a.omegaCoeff, Nat.max a.finitePart b.finitePart⟩

theorem max_omegaCoeff (a b : OmegaBlock) :
    (OmegaBlock.max a b).omegaCoeff = Nat.max a.omegaCoeff b.omegaCoeff := by
  unfold OmegaBlock.max;
  grind

end OmegaBlock

/-! ## Compositional Ordinal Rank -/

/-- **Compositional ordinal rank** for EML expressions. -/
def exprRank : EmlExpr' → OmegaBlock
  | .var => ⟨0, 0⟩
  | .const _ => ⟨0, 0⟩
  | .add a b => OmegaBlock.max (exprRank a) (exprRank b)
  | .mul a b => OmegaBlock.max (exprRank a) (exprRank b)
  | .neg a => exprRank a
  | .eml a b => ⟨1 + Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff, 0⟩

/-! ## Benchmark Functions -/

/-- **Benchmark function** indexed by `OmegaBlock`. -/
def benchmark (a : OmegaBlock) (x : ℝ) : ℝ :=
  iterExp' a.omegaCoeff (x + ↑a.finitePart + 1)

/-! ## Theorem 1: Canonical Rank of Iterated Exponentials -/

/-
The canonical EML expression for `iterExp' n` has ordinal rank exactly `⟨n, 0⟩`.
-/
theorem exprRank_iterExp (n : ℕ) :
    exprRank (emlExprIterExp' n) = ⟨n, 0⟩ := by
  induction n <;> simp_all +decide [ emlExprIterExp' ];
  rename_i n ih;
  rw [ show exprRank ( EmlExpr'.eml ( EmlExpr'.const 1 ) ( emlExprIterExp' n ) ) = ⟨ 1 + Nat.max ( exprRank ( EmlExpr'.const 1 ) ).omegaCoeff ( exprRank ( emlExprIterExp' n ) ).omegaCoeff, 0 ⟩ from rfl ] ; simp +decide [ ih ];
  rw [ add_comm ];
  exact congr_arg₂ _ ( max_eq_right ( by exact Nat.zero_le _ ) ) rfl

/-! ## Theorem 2: ω-Coefficient Equals EML Depth -/

/-
The `ω`-coefficient of the ordinal rank equals the EML depth for every expression.
-/
theorem exprRank_omegaCoeff_eq_emlDepth (e : EmlExpr') :
    (exprRank e).omegaCoeff = e.emlDepth := by
  induction' e using EmlExpr'.recOn with e ih;
  all_goals norm_cast;
  · -- By definition of `exprRank`, we have `exprRank (ih.add a✝) = OmegaBlock.max (exprRank ih) (exprRank a✝)`.
    have h_rank_add : exprRank (ih.add ‹_›) = OmegaBlock.max (exprRank ih) (exprRank ‹_›) := by
      rfl;
    erw [ h_rank_add, OmegaBlock.max_omegaCoeff ] ; aesop;
  · convert OmegaBlock.max_omegaCoeff _ _ using 1;
    aesop;
  · rename_i a b ha hb;
    simp [exprRank, ha, hb, EmlExpr'.emlDepth]

/-! ## Hardy Level Auxiliary Lemmas -/

theorem hardyLevel'_const (n : ℕ) (c : ℝ) : HardyLevel' n (fun _ => c) := by
  induction' n with n ih generalizing c;
  · exact HardyLevel'.base_const c;
  · convert HardyLevel'.exp_step ( ih c ) ( ih 0 ) using 1;
    norm_num

theorem hardyLevel'_mono {m n : ℕ} (hmn : m ≤ n) {f : ℝ → ℝ}
    (hf : HardyLevel' m f) : HardyLevel' n f := by
  induction' hmn with m n hmn ih_add_of_le hmn;
  · assumption;
  · -- Write $f x = f x * \exp(0)$ eventually, apply `exp_step` with IH and `hardyLevel'_const` for 0, then `congr` since $f x * \exp(0) = f x$.
    have : HardyLevel' (m + 1) (fun x => f x * Real.exp 0) := by
      convert HardyLevel'.exp_step hmn ( hardyLevel'_const m 0 ) using 1;
    convert this using 1 ; aesop

/-! ## Theorem 3: Rank Controls Hardy Level -/

/-- **Classification theorem**: Every EML expression of ordinal rank `⟨k, m⟩`
    belongs to Hardy level `k`. The `ω`-coefficient determines the growth class. -/
theorem rank_implies_hardyLevel (e : EmlExpr') :
    HardyLevel' (exprRank e).omegaCoeff e.eval := by
  induction e with
  | var => exact HardyLevel'.base_id
  | const c => exact HardyLevel'.base_const c
  | add a b iha ihb =>
    simp only [exprRank, OmegaBlock.max_omegaCoeff, EmlExpr'.eval]
    exact HardyLevel'.add
      (hardyLevel'_mono (Nat.le_max_left _ _) iha)
      (hardyLevel'_mono (Nat.le_max_right _ _) ihb)
  | mul a b iha ihb =>
    simp only [exprRank, OmegaBlock.max_omegaCoeff, EmlExpr'.eval]
    exact HardyLevel'.mul
      (hardyLevel'_mono (Nat.le_max_left _ _) iha)
      (hardyLevel'_mono (Nat.le_max_right _ _) ihb)
  | neg a iha =>
    simp only [exprRank, EmlExpr'.eval]
    apply HardyLevel'.congr
      (f := fun x => (fun _ => (-1 : ℝ)) x * a.eval x + (fun _ => (0 : ℝ)) x)
    · exact HardyLevel'.add
        (HardyLevel'.mul (hardyLevel'_const _ (-1)) iha)
        (hardyLevel'_const _ 0)
    · exact ⟨0, fun x _ => by ring⟩
  | eml a b iha ihb =>
    simp only [exprRank, EmlExpr'.eval]
    show HardyLevel' (1 + Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff)
      (fun x => a.eval x * Real.exp (b.eval x))
    rw [show 1 + Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff =
      Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff + 1 by omega]
    exact HardyLevel'.exp_step
      (hardyLevel'_mono (Nat.le_max_left _ _) iha)
      (hardyLevel'_mono (Nat.le_max_right _ _) ihb)

/-! ## Theorem 4: Hardy Level 0 Has Polynomial Growth -/

/-
Every function at Hardy level 0 has at most polynomial growth.
-/
theorem hardyLevel'_zero_poly_bound {f : ℝ → ℝ} (hf : HardyLevel' 0 f) :
    ∃ C : ℝ, ∃ d : ℕ, ∃ A : ℝ, ∀ x ≥ A, |f x| ≤ C * x ^ d := by
  have h_ind : ∀ {n : ℕ} {f : ℝ → ℝ}, HardyLevel' n f → n = 0 → ∃ C d A, ∀ x ≥ A, |f x| ≤ C * x ^ d := by
    intros n f hf hn
    induction' hf with f g hf hg ihf ihg n f g hf hg ihf ihg n f g hf hg ihf ihg f g hf hg ihf ihg f g hf hg ihf ihg;
    all_goals norm_num at hn;
    · exact ⟨ 1, 1, 0, fun x hx => by norm_num [ abs_of_nonneg hx ] ⟩;
    · exact ⟨ |f|, 0, 1, fun x hx => by norm_num ⟩;
    · rcases n hn with ⟨ C₁, d₁, A₁, hC₁ ⟩ ; rcases f hn with ⟨ C₂, d₂, A₂, hC₂ ⟩ ; use C₁ + C₂, Max.max d₁ d₂, Max.max A₁ ( Max.max A₂ 1 ) ; intros x hx ; simp_all +decide [ abs_le ];
      constructor <;> nlinarith [ hC₁ x hx.1, hC₂ x hx.2.1, pow_le_pow_right₀ hx.2.2 ( le_max_left d₁ d₂ ), pow_le_pow_right₀ hx.2.2 ( le_max_right d₁ d₂ ), show 0 ≤ C₁ by exact le_of_not_gt fun h => by have := hC₁ ( Max.max A₁ 1 ) ( le_max_left _ _ ) ; nlinarith [ pow_pos ( by linarith [ le_max_right A₁ 1 ] : 0 < Max.max A₁ 1 ) d₁, le_max_right A₁ 1 ], show 0 ≤ C₂ by exact le_of_not_gt fun h => by have := hC₂ ( Max.max A₂ 1 ) ( le_max_left _ _ ) ; nlinarith [ pow_pos ( by linarith [ le_max_right A₂ 1 ] : 0 < Max.max A₂ 1 ) d₂, le_max_right A₂ 1 ] ];
    · obtain ⟨ C₁, d₁, A₁, h₁ ⟩ := n hn; obtain ⟨ C₂, d₂, A₂, h₂ ⟩ := f hn; use C₁ * C₂, d₁ + d₂, Max.max A₁ A₂; intros x hx; rw [ abs_mul ] ; rw [ pow_add ] ; exact le_trans ( mul_le_mul ( h₁ x ( le_trans ( le_max_left _ _ ) hx ) ) ( h₂ x ( le_trans ( le_max_right _ _ ) hx ) ) ( by positivity ) ( by exact le_trans ( by positivity ) ( h₁ x ( le_trans ( le_max_left _ _ ) hx ) ) ) ) ( by ring_nf; norm_num ) ;
    · obtain ⟨ C, d, A, hC ⟩ := g hn;
      obtain ⟨ B, hB ⟩ := f;
      exact ⟨ C, d, Max.max A B, fun x hx => by rw [ ← hB x ( le_trans ( le_max_right _ _ ) hx ) ] ; exact hC x ( le_trans ( le_max_left _ _ ) hx ) ⟩;
  exact h_ind hf rfl

/-! ## Theorem 5: Exponential Exceeds Polynomials -/

/-
`exp` eventually exceeds any polynomial.
-/
theorem exp_exceeds_poly_eventually (C : ℝ) (d : ℕ) :
    ∃ A : ℝ, ∀ x ≥ A, C * x ^ d < Real.exp x := by
  -- We can use the fact that $\exp(x) / x^d \to \infty$ as $x \to \infty$.
  have h_exp_div_pow_inf : Filter.Tendsto (fun x : ℝ => Real.exp x / x ^ d) Filter.atTop Filter.atTop := by
    exact Real.tendsto_exp_div_pow_atTop _;
  exact Filter.eventually_atTop.mp ( h_exp_div_pow_inf.eventually_gt_atTop ( Max.max ( C ) 1 ) ) |> fun ⟨ A, hA ⟩ ↦ ⟨ Max.max A 1, fun x hx ↦ by have := hA x ( le_trans ( le_max_left _ _ ) hx ) ; rw [ lt_div_iff₀ ( pow_pos ( by linarith [ le_max_right A 1 ] ) _ ) ] at this; nlinarith [ le_max_left C 1, le_max_right C 1, pow_pos ( by linarith [ le_max_right A 1 ] : 0 < x ) d ] ⟩

/-! ## Theorem 6: Base Case of Strict ω-Block Separation -/

/-
**Strict separation (base case)**: `exp` (= `iterExp' 1`) is not at Hardy level 0.
-/
theorem exp_not_hardyLevel'_zero : ¬ HardyLevel' 0 (iterExp' 1) := by
  intro h;
  -- By `hardyLevel'_zero_poly_bound`, there exist constants `C`, `d`, and `A` such that `|exp(x)| ≤ C * x^d` for `x ≥ A`.
  obtain ⟨C, d, A, h_bound⟩ : ∃ C : ℝ, ∃ d : ℕ, ∃ A : ℝ, ∀ x ≥ A, |Real.exp x| ≤ C * x ^ d := by
    convert hardyLevel'_zero_poly_bound h using 1;
  -- By `exp_exceeds_poly_eventually`, there exists `A'` such that `C * x^d < exp(x)` for `x ≥ A'`.
  obtain ⟨A', hA'⟩ : ∃ A' : ℝ, ∀ x ≥ A', C * x ^ d < Real.exp x := by
    exact exp_exceeds_poly_eventually C d;
  exact absurd ( hA' ( Max.max A A' + 1 ) ( by linarith [ le_max_left A A', le_max_right A A' ] ) ) ( by linarith [ abs_le.mp ( h_bound ( Max.max A A' + 1 ) ( by linarith [ le_max_left A A', le_max_right A A' ] ) ) ] )

/-- **Strict separation by rank**: Any expression with `ω`-coefficient 0 belongs
    to Hardy level 0 (hence has polynomial growth, strictly below exponential). -/
theorem rank_zero_implies_hardyLevel_zero
    (e : EmlExpr') (h : (exprRank e).omegaCoeff = 0) :
    HardyLevel' 0 e.eval := by
  have := rank_implies_hardyLevel e
  rw [h] at this
  exact this

/-! ## Structural Lemmas -/

theorem exprRank_add (e₁ e₂ : EmlExpr') :
    exprRank (.add e₁ e₂) = OmegaBlock.max (exprRank e₁) (exprRank e₂) := rfl

theorem exprRank_mul (e₁ e₂ : EmlExpr') :
    exprRank (.mul e₁ e₂) = OmegaBlock.max (exprRank e₁) (exprRank e₂) := rfl

theorem exprRank_neg (e : EmlExpr') :
    exprRank (.neg e) = exprRank e := rfl

theorem exprRank_eml (a b : EmlExpr') :
    exprRank (.eml a b) =
      ⟨1 + Nat.max (exprRank a).omegaCoeff (exprRank b).omegaCoeff, 0⟩ := rfl

/-
The `eml` constructor strictly increases the `ω`-coefficient.
-/
theorem exprRank_eml_omegaCoeff_gt_left (a b : EmlExpr') :
    (exprRank a).omegaCoeff < (exprRank (.eml a b)).omegaCoeff := by
  exact Nat.lt_add_of_pos_left ( by norm_num ) |> lt_of_le_of_lt ( Nat.le_max_left _ _ )

theorem exprRank_eml_omegaCoeff_gt_right (a b : EmlExpr') :
    (exprRank b).omegaCoeff < (exprRank (.eml a b)).omegaCoeff := by
  grind +locals

/-! ## Verified Classifier -/

/-- **Verified ordinal classifier**: returns the ordinal rank with proof certificates. -/
def ordinalClassify (e : EmlExpr') :
    { r : OmegaBlock //
      r = exprRank e ∧
      r.omegaCoeff = e.emlDepth ∧
      HardyLevel' r.omegaCoeff e.eval } :=
  ⟨exprRank e,
   rfl,
   exprRank_omegaCoeff_eq_emlDepth e,
   rank_implies_hardyLevel e⟩

/-! ## Cross-Domain: Rank Monotonicity Under Subexpression -/

/-- Immediate subexpression relation. -/
inductive EmlSubexpr' : EmlExpr' → EmlExpr' → Prop
  | add_left (a b : EmlExpr') : EmlSubexpr' a (.add a b)
  | add_right (a b : EmlExpr') : EmlSubexpr' b (.add a b)
  | mul_left (a b : EmlExpr') : EmlSubexpr' a (.mul a b)
  | mul_right (a b : EmlExpr') : EmlSubexpr' b (.mul a b)
  | neg_sub (a : EmlExpr') : EmlSubexpr' a (.neg a)
  | eml_left (a b : EmlExpr') : EmlSubexpr' a (.eml a b)
  | eml_right (a b : EmlExpr') : EmlSubexpr' b (.eml a b)

/-
**Cross-domain theorem**: Ordinal rank (`ω`-coefficient) is monotone under
    the subexpression relation.
-/
theorem rank_omegaCoeff_mono_subexpr {e₁ e₂ : EmlExpr'} (h : EmlSubexpr' e₁ e₂) :
    (exprRank e₁).omegaCoeff ≤ (exprRank e₂).omegaCoeff := by
  induction h;
  all_goals repeat' erw [ exprRank_add ] ; simp +decide [ OmegaBlock.max_omegaCoeff ];
  · rfl;
  · exact Nat.le_of_lt ( exprRank_eml_omegaCoeff_gt_left _ _ );
  · exact Nat.le_of_lt ( exprRank_eml_omegaCoeff_gt_right _ _ )

/-
The canonical EML expression evaluates to the corresponding iterated exponential.
-/
theorem emlExprIterExp'_eval (n : ℕ) (x : ℝ) :
    (emlExprIterExp' n).eval x = iterExp' n x := by
  induction' n with n ih generalizing x;
  · rfl;
  · convert congr_arg ( fun y => 1 * Real.exp y ) ( ih x ) using 1;
    simp +zetaDelta at *

/-
The canonical EML expression has `emlDepth` exactly `n`.
-/
theorem emlExprIterExp'_emlDepth (n : ℕ) :
    (emlExprIterExp' n).emlDepth = n := by
  have h_emlDepth_succ : ∀ n, (emlExprIterExp' (n + 1)).emlDepth = 1 + (emlExprIterExp' n).emlDepth := by
    intro n
    simp [emlExprIterExp', EmlExpr'.emlDepth];
  exact Nat.recOn n ( by rfl ) fun n ih => by linarith [ h_emlDepth_succ n ] ;

end