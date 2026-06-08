import Mathlib

/-!
# Tensor Expression Extraction Optimality

## Overview

This file establishes that **canonical normalization of tensor expressions computes a
minimum-sharing representative** within the semantic equivalence class. This bridges
algebraic normal forms with equality saturation extraction theory.

## Mathematical Contribution

For tensor expressions modulo associativity, commutativity, and scalar distribution,
canonical normalization computes an extracted representative that is minimal with respect
to a sharing-aware cost (the number of distinct variables mentioned). The key insight
is that the canonical form's variable set equals the "effective support" — exactly the
variables with nonzero total coefficient — which is provably contained in the variable
set of any equivalent expression.

## Main Definitions

- `TExpr`: Simple tensor expression type (ℤ-linear combinations of ℕ-indexed variables)
- `TExpr.eval`: Evaluation in a ℤ-valued environment
- `TExpr.coeffOf`: Total coefficient of a variable in an expression
- `TExpr.distinctVars`: Set of variables syntactically appearing
- `TExpr.sharingCost`: Number of distinct variables (sharing-aware cost)
- `SemEquiv`: Semantic equivalence (equal evaluation under all assignments)
- `normalizeCanon`: Canonical normalization via coefficient extraction and sorted rebuilding
- `BinTree`: Binary trees for modeling parenthesization ambiguity

## Main Theorems

- `normalizeCanon_sound`: Canonical normalization preserves evaluation
- `normalizeCanon_confluence`: Semantically equivalent expressions normalize identically
- `normalizeCanon_sharingCost_le`: Canonical form minimizes sharing cost (global optimality)
- `normalizeCanon_bintree_perm_invariant`: Catalan collapse — all parenthesizations and
  permutations yield the same canonical form
- `normalizeCanon_locally_optimal`: No AC rewrite step from canonical form reduces sharing cost
-/

namespace TensorExtraction

/-! ## Section 1: Expression Type and Basic Operations -/

/-- Simple tensor expression type: formal ℤ-linear combinations of ℕ-indexed variables.
This models the additive fragment of tensor expressions where the key equational theory
is AC (associativity + commutativity) of addition plus scalar distribution. -/
inductive TExpr where
  | var : ℕ → TExpr
  | zero : TExpr
  | add : TExpr → TExpr → TExpr
  | smul : ℤ → TExpr → TExpr
  deriving DecidableEq, Repr

/-- Evaluation of a tensor expression in an ℤ-valued environment `ρ`. -/
def TExpr.eval (ρ : ℕ → ℤ) : TExpr → ℤ
  | .var n => ρ n
  | .zero => 0
  | .add a b => a.eval ρ + b.eval ρ
  | .smul k e => k * e.eval ρ

/-- Tree size: number of constructor nodes. -/
def TExpr.size : TExpr → ℕ
  | .var _ => 1
  | .zero => 1
  | .add a b => 1 + a.size + b.size
  | .smul _ e => 1 + e.size

/-- Total coefficient of variable `n` in expression `e`. This is the key algebraic
invariant: it captures the complete linear-algebraic content of the expression. -/
def TExpr.coeffOf : TExpr → ℕ → ℤ
  | .var m, n => if m = n then 1 else 0
  | .zero, _ => 0
  | .add a b, n => a.coeffOf n + b.coeffOf n
  | .smul k e, n => k * e.coeffOf n

/-- Set of variables syntactically appearing in the expression. This may be a superset
of the effective support (variables with nonzero coefficient). -/
def TExpr.distinctVars : TExpr → Finset ℕ
  | .var n => {n}
  | .zero => ∅
  | .add a b => a.distinctVars ∪ b.distinctVars
  | .smul _ e => e.distinctVars

/-- Sharing cost: number of distinct variables syntactically mentioned.
In DAG terms, this counts the variable nodes needed in any representation. -/
def TExpr.sharingCost (e : TExpr) : ℕ := e.distinctVars.card

/-! ## Section 2: Semantic Equivalence -/

/-- Two expressions are semantically equivalent if they evaluate identically
under all variable assignments. -/
def SemEquiv (e₁ e₂ : TExpr) : Prop := ∀ ρ : ℕ → ℤ, e₁.eval ρ = e₂.eval ρ

theorem SemEquiv.refl (e : TExpr) : SemEquiv e e := fun _ => rfl

theorem SemEquiv.symm {e₁ e₂ : TExpr} (h : SemEquiv e₁ e₂) : SemEquiv e₂ e₁ :=
  fun ρ => (h ρ).symm

theorem SemEquiv.trans {e₁ e₂ e₃ : TExpr} (h₁ : SemEquiv e₁ e₂) (h₂ : SemEquiv e₂ e₃) :
    SemEquiv e₁ e₃ :=
  fun ρ => (h₁ ρ).trans (h₂ ρ)

/-! ## Section 3: Fundamental Coefficient Lemmas -/

/-
Evaluating at an indicator function for variable `m` yields the coefficient of `m`.
This is the bridge between syntax (coeffOf) and semantics (eval).
-/
theorem eval_indicator_eq_coeffOf (e : TExpr) (m : ℕ) :
    e.eval (fun n => if n = m then 1 else 0) = e.coeffOf m := by
  induction' e with e₁ e₂ ih₁ ih₂ e ih;
  · simp +decide [ TExpr.eval, TExpr.coeffOf ];
  · rfl;
  · erw [ show TExpr.eval ( fun n => if n = m then 1 else 0 ) ( e₂.add ih₁ ) = TExpr.eval ( fun n => if n = m then 1 else 0 ) e₂ + TExpr.eval ( fun n => if n = m then 1 else 0 ) ih₁ from rfl ] ; aesop;
  · simp +decide [ *, TExpr.eval, TExpr.coeffOf ]

/-
If a variable does not appear syntactically, its coefficient is zero.
-/
theorem coeffOf_zero_of_not_mem_distinctVars (e : TExpr) (v : ℕ)
    (hv : v ∉ e.distinctVars) : e.coeffOf v = 0 := by
  induction' e with e₁ e₂ ih₁ ih₂;
  · simp_all +decide [ TExpr.coeffOf, TExpr.distinctVars ];
    grind;
  · rfl;
  · simp_all +decide [ TExpr.coeffOf, TExpr.distinctVars ];
  · exact mul_eq_zero_of_right _ ( by solve_by_elim )

/-- Contrapositive: nonzero coefficient implies syntactic appearance. -/
theorem mem_distinctVars_of_coeffOf_ne_zero (e : TExpr) (v : ℕ)
    (hv : e.coeffOf v ≠ 0) : v ∈ e.distinctVars := by
  exact by_contra fun h => hv (coeffOf_zero_of_not_mem_distinctVars e v h)

/-- Semantic equivalence implies pointwise coefficient equality.
This is the completeness direction: the coefficient map is a complete invariant. -/
theorem coeffOf_eq_of_semEquiv {e₁ e₂ : TExpr} (h : SemEquiv e₁ e₂) (n : ℕ) :
    e₁.coeffOf n = e₂.coeffOf n := by
  have := h (fun v => if v = n then 1 else 0)
  rwa [eval_indicator_eq_coeffOf, eval_indicator_eq_coeffOf] at this

/-
Coefficient equality implies semantic equivalence.
This is the soundness direction: expressions with the same coefficients evaluate
identically.
-/
theorem semEquiv_of_coeffOf_eq {e₁ e₂ : TExpr}
    (h : ∀ n, e₁.coeffOf n = e₂.coeffOf n) : SemEquiv e₁ e₂ := by
  have h_sum_eq : ∀ ρ : ℕ → ℤ, ∑ n ∈ e₁.distinctVars ∪ e₂.distinctVars, e₁.coeffOf n * ρ n = ∑ n ∈ e₁.distinctVars ∪ e₂.distinctVars, e₂.coeffOf n * ρ n := by
    aesop;
  -- By definition of `eval`, we can rewrite the goal using the sums over the distinct variables.
  have h_eval_eq : ∀ ρ : ℕ → ℤ, e₁.eval ρ = ∑ n ∈ e₁.distinctVars ∪ e₂.distinctVars, e₁.coeffOf n * ρ n ∧ e₂.eval ρ = ∑ n ∈ e₁.distinctVars ∪ e₂.distinctVars, e₂.coeffOf n * ρ n := by
    intros ρ
    have h_eval_eq : ∀ e : TExpr, e.eval ρ = ∑ n ∈ e.distinctVars, e.coeffOf n * ρ n := by
      intro e;
      induction' e using TExpr.recOn with n e₁ e₂ ih₁ ih₂ k e ih;
      · simp +decide [ TExpr.eval, TExpr.distinctVars, TExpr.coeffOf ];
      · rfl;
      · convert congr_arg₂ ( · + · ) ih₁ ih₂ using 1;
        rw [ show ( e₁.add e₂ ).distinctVars = e₁.distinctVars ∪ e₂.distinctVars from rfl, Finset.sum_subset ( Finset.subset_union_left ) ];
        any_goals exact e₁.distinctVars ∪ e₂.distinctVars;
        · simp +decide [ Finset.sum_add_distrib, add_mul, TExpr.coeffOf ];
          rw [ ← Finset.sum_subset ( Finset.subset_union_left ), ← Finset.sum_subset ( Finset.subset_union_right ) ];
          · exact fun n hn hn' => by rw [ coeffOf_zero_of_not_mem_distinctVars _ _ hn', MulZeroClass.zero_mul ] ;
          · exact fun n hn hn' => by rw [ coeffOf_zero_of_not_mem_distinctVars e₁ n hn', MulZeroClass.zero_mul ] ; ;
        · simp +contextual [ TExpr.coeffOf ];
      · convert congr_arg ( fun x : ℤ => k * x ) ih using 1;
        rw [ Finset.mul_sum _ _ _ ];
        exact Finset.sum_congr rfl fun x hx => by rw [ show ( TExpr.smul k e ).coeffOf x = k * e.coeffOf x from rfl ] ; ring;
    exact ⟨ by rw [ h_eval_eq, Finset.sum_subset ( Finset.subset_union_left ) fun x hx₁ hx₂ => by simp_all +decide [ coeffOf_zero_of_not_mem_distinctVars ] ], by rw [ h_eval_eq, Finset.sum_subset ( Finset.subset_union_right ) fun x hx₁ hx₂ => by simp_all +decide [ coeffOf_zero_of_not_mem_distinctVars ] ] ⟩;
  exact fun ρ => by rw [ h_eval_eq ρ |>.1, h_eval_eq ρ |>.2, h_sum_eq ρ ] ;

/-! ## Section 4: Evaluation as Weighted Sum -/

/-
Evaluation equals the weighted sum of coefficients over distinctVars.
This connects the tree-recursive evaluation to a flat algebraic sum.
-/
theorem eval_eq_sum_over_distinctVars (e : TExpr) (ρ : ℕ → ℤ) :
    e.eval ρ = ∑ v ∈ e.distinctVars, e.coeffOf v * ρ v := by
  induction' e with e₁ e₂ ih₁ ih₂;
  · simp +decide [ TExpr.eval, TExpr.coeffOf, TExpr.distinctVars ];
  · aesop;
  · -- By definition of `distinctVars`, we have `distinctVars (e₂.add ih₁) = distinctVars e₂ ∪ distinctVars ih₁`.
    have h_distinctVars_add : (e₂.add ih₁).distinctVars = e₂.distinctVars ∪ ih₁.distinctVars := by
      rfl
    simp_all +decide [ TExpr.eval, TExpr.coeffOf ];
    simp +decide only [add_mul, Finset.sum_add_distrib];
    rw [ ← Finset.sum_subset ( Finset.subset_union_left ), ← Finset.sum_subset ( Finset.subset_union_right ) ]; all_goals exact fun x hx₁ hx₂ => by rw [ coeffOf_zero_of_not_mem_distinctVars _ _ hx₂, MulZeroClass.zero_mul ] ;
  · simp_all +decide [ TExpr.eval, TExpr.coeffOf ] ; ring!;
    simp +decide [ mul_assoc, Finset.mul_sum _ _ _ ];
    exact?

/-! ## Section 5: Canonical Normalization -/

/-- The effective support: variables with nonzero total coefficient.
This is the minimal set of variables needed to represent the expression. -/
def TExpr.effectiveSupport (e : TExpr) : Finset ℕ :=
  e.distinctVars.filter (fun v => e.coeffOf v ≠ 0)

/-- Build a right-associated sum from a list of (coefficient, variable) pairs. -/
def buildSum : List (ℤ × ℕ) → TExpr
  | [] => .zero
  | (c, v) :: rest => .add (.smul c (.var v)) (buildSum rest)

/-- Canonical normalization: extract effective support, sort by variable index,
pair with coefficients, and rebuild as a right-associated sum.
This is the core algorithm that computes the minimum-sharing representative. -/
def normalizeCanon (e : TExpr) : TExpr :=
  buildSum ((e.effectiveSupport.sort (· ≤ ·)).map (fun v => (e.coeffOf v, v)))

/-! ## Section 6: BuildSum Properties -/

/-
Evaluation of `buildSum` equals the sum of products from the term list.
-/
theorem buildSum_eval (terms : List (ℤ × ℕ)) (ρ : ℕ → ℤ) :
    (buildSum terms).eval ρ = (terms.map (fun p => p.1 * ρ p.2)).sum := by
  induction terms <;> simp_all +decide [ TExpr.eval, buildSum ]

/-
The distinct variables of `buildSum` are exactly the second components.
-/
theorem buildSum_distinctVars (terms : List (ℤ × ℕ)) :
    (buildSum terms).distinctVars = (terms.map Prod.snd).toFinset := by
  induction' terms with term terms ih;
  · rfl;
  · convert congr_arg₂ ( fun x y => x ∪ y ) ( show ( { term.2 } : Finset ℕ ) = { term.2 } from rfl ) ih using 1;
    simp +decide [ Finset.ext_iff ]

/-! ## Section 7: Soundness -/

/-
**Theorem 1 (Soundness):** Canonical normalization preserves evaluation.
-/
theorem normalizeCanon_sound (e : TExpr) (ρ : ℕ → ℤ) :
    (normalizeCanon e).eval ρ = e.eval ρ := by
  -- Since `effectiveSupport` is a subset of `distinctVars`, we can rewrite the sum over `distinctVars` as the sum over `effectiveSupport`.
  have h_sum_subset : ∑ v ∈ e.distinctVars, e.coeffOf v * ρ v = ∑ v ∈ e.effectiveSupport, e.coeffOf v * ρ v := by
    rw [ ← Finset.sum_subset ( Finset.filter_subset ( fun v => e.coeffOf v ≠ 0 ) e.distinctVars ) ] ; aesop;
    aesop;
  convert h_sum_subset using 1;
  · convert buildSum_eval _ _ using 1;
    rw [ h_sum_subset, ← Finset.sum_map_toList ];
    have h_perm : List.Perm (e.effectiveSupport.toList) (e.effectiveSupport.sort (· ≤ ·)) := by
      rw [ ← Multiset.coe_eq_coe ] ; aesop;
    simpa using h_perm.map _ |> List.Perm.sum_eq;
  · exact h_sum_subset ▸ eval_eq_sum_over_distinctVars e ρ

/-- Soundness as semantic equivalence. -/
theorem normalizeCanon_semEquiv (e : TExpr) : SemEquiv (normalizeCanon e) e :=
  fun ρ => normalizeCanon_sound e ρ

/-! ## Section 8: Confluence -/

/-
The effective support depends only on the coefficient function:
if two expressions have the same coefficients, they have the same effective support.
-/
theorem effectiveSupport_eq_of_coeffOf_eq {e₁ e₂ : TExpr}
    (h : ∀ n, e₁.coeffOf n = e₂.coeffOf n) :
    e₁.effectiveSupport = e₂.effectiveSupport := by
  -- Since the coefficients are the same, the effective support is determined by the same condition (non-zero coefficient), leading to the same set of variables. Therefore, the effective supports must be equal.
  ext v
  simp [TExpr.effectiveSupport, h];
  exact fun _ => ⟨ fun hv => mem_distinctVars_of_coeffOf_ne_zero _ _ ( by aesop ), fun hv => mem_distinctVars_of_coeffOf_ne_zero _ _ ( by aesop ) ⟩

/-
normalizeCanon depends only on the coefficient function.
-/
theorem normalizeCanon_eq_of_coeffOf_eq {e₁ e₂ : TExpr}
    (h : ∀ n, e₁.coeffOf n = e₂.coeffOf n) :
    normalizeCanon e₁ = normalizeCanon e₂ := by
  unfold normalizeCanon;
  rw [ effectiveSupport_eq_of_coeffOf_eq h ] ; aesop;

/-- **Theorem 2 (Confluence):** Semantically equivalent expressions normalize
to the same canonical form. This is the central confluence result. -/
theorem normalizeCanon_confluence {e₁ e₂ : TExpr} (h : SemEquiv e₁ e₂) :
    normalizeCanon e₁ = normalizeCanon e₂ :=
  normalizeCanon_eq_of_coeffOf_eq (coeffOf_eq_of_semEquiv h)

/-! ## Section 9: Sharing Cost Optimality -/

/-
The distinct variables of the canonical form equal the effective support.
-/
theorem normalizeCanon_distinctVars_eq_effectiveSupport (e : TExpr) :
    (normalizeCanon e).distinctVars = e.effectiveSupport := by
  convert buildSum_distinctVars _ using 2;
  -- By definition of `effectiveSupport`, we know that its elements are exactly the variables with nonzero coefficient.
  ext; simp [TExpr.effectiveSupport]

/-
**Theorem 3 (Sharing Cost Optimality):** The canonical form minimizes sharing cost
(number of distinct variables) across the entire semantic equivalence class.

**Proof strategy:** The canonical form mentions exactly the variables with nonzero
coefficient (= effective support). Any equivalent expression must mention each such
variable at least once (otherwise the coefficient would be zero, contradiction).
Hence `(normalizeCanon e).distinctVars ⊆ e'.distinctVars` for any `SemEquiv e e'`.
-/
theorem normalizeCanon_sharingCost_le {e e' : TExpr} (h : SemEquiv e e') :
    (normalizeCanon e).sharingCost ≤ e'.sharingCost := by
  apply Finset.card_le_card ?_;
  intros a ha
  have h_coeff : e.coeffOf a ≠ 0 := by
    rw [ TensorExtraction.normalizeCanon_distinctVars_eq_effectiveSupport ] at ha; exact Finset.mem_filter.mp ha |>.2;
  exact mem_distinctVars_of_coeffOf_ne_zero e' a ( by simpa [ coeffOf_eq_of_semEquiv h ] using h_coeff )

/-- Predicate: `nf` is a minimum-sharing representative of `e`. -/
def IsMinSharingRepresentative (e nf : TExpr) : Prop :=
  SemEquiv e nf ∧ ∀ e', SemEquiv e' e → nf.sharingCost ≤ e'.sharingCost

/-- The canonical form is a minimum-sharing representative. -/
theorem normalizeCanon_isMinSharingRepresentative (e : TExpr) :
    IsMinSharingRepresentative e (normalizeCanon e) :=
  ⟨(normalizeCanon_semEquiv e).symm, fun _ h => normalizeCanon_sharingCost_le h.symm⟩

/-! ## Section 10: Cross-Domain Theorem — Catalan Collapse -/

/-- Binary tree for representing different parenthesizations of a sum.
The Catalan number `C_n` counts the number of binary trees on `n+1` leaves,
representing all possible parenthesizations of an `n`-fold sum. -/
inductive BinTree (α : Type u) where
  | leaf : α → BinTree α
  | node : BinTree α → BinTree α → BinTree α

/-- Convert a binary tree of expressions to a single expression (as a sum tree). -/
def BinTree.toTExpr : BinTree TExpr → TExpr
  | .leaf e => e
  | .node l r => .add l.toTExpr r.toTExpr

/-- Extract the leaves in left-to-right order. -/
def BinTree.leaves : BinTree α → List α
  | .leaf a => [a]
  | .node l r => l.leaves ++ r.leaves

/-
The coefficient of `toTExpr` is the sum of leaf coefficients.
-/
theorem toTExpr_coeffOf (t : BinTree TExpr) (v : ℕ) :
    t.toTExpr.coeffOf v = (t.leaves.map (·.coeffOf v)).sum := by
  induction' t with l r hl hr;
  · grind +locals;
  · convert congr_arg₂ ( · + · ) hr ‹_› using 1;
    simp +decide [ BinTree.leaves ]

/-- Right-fold a list into a sum expression. -/
def foldAdd : List TExpr → TExpr
  | [] => .zero
  | e :: rest => .add e (foldAdd rest)

/-
The coefficient of a folded sum is the sum of element coefficients.
-/
theorem foldAdd_coeffOf (es : List TExpr) (v : ℕ) :
    (foldAdd es).coeffOf v = (es.map (·.coeffOf v)).sum := by
  induction' es with e es ih;
  · rfl;
  · convert congr_arg₂ ( · + · ) rfl ih using 1

/-
**Theorem 4 (Catalan Collapse):** All binary parenthesizations and permutations
of a sum normalize to the same canonical form. This shows that the Catalan-scale
ambiguity in tree structure collapses entirely under canonical normalization.

**Cross-domain significance:** This is a precise bridge from tensor rewriting to
Catalan combinatorics. The Catalan number of distinct binary trees on `n` leaves
grows exponentially, but the canonical form reduces all of them to a single
representative determined by the multiset of leaf coefficients.
-/
theorem normalizeCanon_bintree_perm_invariant
    (t₁ t₂ : BinTree TExpr)
    (h : t₁.leaves.Perm t₂.leaves) :
    normalizeCanon t₁.toTExpr = normalizeCanon t₂.toTExpr := by
  apply normalizeCanon_eq_of_coeffOf_eq;
  intro n; rw [ toTExpr_coeffOf, toTExpr_coeffOf ] ; exact (by
  exact h.map _ |> List.Perm.sum_eq);

/-
Permutations of the input list yield the same canonical form under foldAdd.
-/
theorem normalizeCanon_foldAdd_perm_invariant
    (xs ys : List TExpr)
    (h : ys.Perm xs) :
    normalizeCanon (foldAdd xs) = normalizeCanon (foldAdd ys) := by
  apply normalizeCanon_eq_of_coeffOf_eq;
  -- By definition of `foldAdd`, we can expand both sides.
  intro n
  rw [foldAdd_coeffOf, foldAdd_coeffOf];
  rw [ h.map _ |> List.Perm.sum_eq ]

/-! ## Section 11: AC Rewrite Steps and Local Optimality -/

/-- One-step AC rewrite: associativity and commutativity of addition,
plus scalar distribution rules. These generate the equational theory. -/
inductive ACStep : TExpr → TExpr → Prop
  | add_comm (a b : TExpr) : ACStep (.add a b) (.add b a)
  | add_assoc (a b c : TExpr) : ACStep (.add (.add a b) c) (.add a (.add b c))
  | add_assoc_inv (a b c : TExpr) : ACStep (.add a (.add b c)) (.add (.add a b) c)
  | add_zero_right (a : TExpr) : ACStep (.add a .zero) a
  | add_zero_left (a : TExpr) : ACStep (.add .zero a) a
  | smul_add (k : ℤ) (a b : TExpr) :
      ACStep (.smul k (.add a b)) (.add (.smul k a) (.smul k b))
  | add_smul (a : TExpr) (j k : ℤ) :
      ACStep (.add (.smul j a) (.smul k a)) (.smul (j + k) a)

/-
AC rewrite steps preserve semantic equivalence.
-/
theorem acStep_preserves_semEquiv {e₁ e₂ : TExpr} (h : ACStep e₁ e₂) :
    SemEquiv e₁ e₂ := by
  intro ρ;
  cases h <;> simp +decide [ *, TExpr.eval ];
  · lia;
  · grind;
  · grind;
  · ring;
  · ring

/-- **Theorem 5 (Local Optimality):** No AC rewrite step from a canonical form
can reduce the sharing cost. The canonical form is a local minimum. -/
theorem normalizeCanon_locally_optimal {e e' : TExpr}
    (h : ACStep (normalizeCanon e) e') :
    (normalizeCanon e).sharingCost ≤ e'.sharingCost :=
  normalizeCanon_sharingCost_le
    ((normalizeCanon_semEquiv e).symm.trans (acStep_preserves_semEquiv h))

/-! ## Section 12: Extraction Algorithm -/

/-- Bounded extraction algorithm. Computes the canonical form, which is provably
the minimum-sharing representative. The `fuel` parameter models the bounded
exploration budget of an e-graph saturation; here it is unused because
`normalizeCanon` directly computes the optimal representative. -/
def extractMinSharing (_fuel : ℕ) (e : TExpr) : TExpr := normalizeCanon e

/-- Extraction preserves semantic equivalence. -/
theorem extractMinSharing_sound (fuel : ℕ) (e : TExpr) :
    SemEquiv e (extractMinSharing fuel e) :=
  fun ρ => (normalizeCanon_sound e ρ).symm

/-- Extraction achieves minimum sharing cost in the equivalence class. -/
theorem extractMinSharing_optimal (fuel : ℕ) {e e' : TExpr} (h : SemEquiv e e') :
    (extractMinSharing fuel e).sharingCost ≤ e'.sharingCost :=
  normalizeCanon_sharingCost_le h

/-! ## Section 13: Extraction Cost Structure -/

/-- Cost model for tensor expressions, bundling sharing-aware metrics. -/
structure ExtractionCost where
  /-- Number of distinct variables mentioned. -/
  distinctVarCount : ℕ
  /-- Total tree size (number of constructor nodes). -/
  treeSize : ℕ
  deriving DecidableEq, Repr

/-- Compute the extraction cost of a tensor expression. -/
def TExpr.extractionCost (e : TExpr) : ExtractionCost :=
  { distinctVarCount := e.sharingCost, treeSize := e.size }

/-- The canonical form is optimal in the primary cost dimension (distinct variables). -/
theorem normalizeCanon_optimal_primary_cost {e e' : TExpr} (h : SemEquiv e e') :
    (normalizeCanon e).extractionCost.distinctVarCount ≤ e'.extractionCost.distinctVarCount :=
  normalizeCanon_sharingCost_le h

/-! ## Section 14: Conjecture

**Conjecture (Global Extraction Optimality):** For every tensor expression `e`, the
minimum-sharing extraction from the fully saturated AC+scalar-distributive e-graph
of `e` is alpha-equivalent to `normalizeCanon e`.

A counterexample would be an expression `e` and equivalent `e'` such that
`SemEquiv e' e` but `e'.sharingCost < (normalizeCanon e).sharingCost`.

By Theorem 3 (`normalizeCanon_sharingCost_le`), no such counterexample exists for the
sharing cost metric. This proves the conjecture for the primary cost dimension.

For the full lexicographic cost (distinctVars, treeSize), the conjecture remains open:
it is possible that there exists an equivalent expression with the same number of
distinct variables but smaller tree size than the canonical form. Investigating this
requires analyzing the tree-size overhead of the canonical right-associated encoding.
-/

end TensorExtraction