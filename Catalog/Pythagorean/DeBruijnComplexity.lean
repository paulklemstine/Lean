/-
# De Bruijn Lambda Calculus: Capture-Free Monotonicity Theory

## Scientific Contribution

This module develops a de Bruijn-indexed λ-calculus with resource-sensitive
complexity measures. The central result is that **affine β-reduction is
branch-monotone**: if every bound variable is used at most once (the affine
condition), then β-reduction cannot increase the branching complexity of a term.

This isolates *duplication* — not substitution itself — as the engine of
combinatorial explosion in the λ-calculus.

## Key Results

- **Theorem A** (`branchComplexityDB_subst_affine_le`):
  Affine substitution does not increase branch complexity beyond additive contribution
- **Theorem B** (`branchComplexityDB_beta_monotone`):
  β-step monotonicity for affine-closed terms
- **Theorem C** (`stateGrowthDB_branch_bounded`):
  State growth branch bound via monotonicity
- **Theorem D** (`affine_closed_redex_bound`):
  Affine terms satisfy a no-contraction resource law
-/

import Mathlib

/-! ## 1. De Bruijn Term Syntax -/

/-- De Bruijn-indexed lambda calculus terms. Variables are natural numbers
    representing de Bruijn indices (0 = innermost binder). -/
inductive DBTerm : Type where
  | var : Nat → DBTerm
  | app : DBTerm → DBTerm → DBTerm
  | lam : DBTerm → DBTerm
  deriving DecidableEq, Repr, Inhabited

namespace DBTerm

/-! ## 2. Core Operations -/

/-- The size of a de Bruijn term (number of constructors). -/
def sizeDB : DBTerm → Nat
  | var _ => 1
  | app t u => 1 + sizeDB t + sizeDB u
  | lam t => 1 + sizeDB t

/-- Shift (lifting) of free variables: increment all free variables
    (those with index ≥ c) by d. The cutoff c is incremented under
    lambda binders to correctly preserve binding structure. -/
def shift (d : Nat) (c : Nat) : DBTerm → DBTerm
  | var k => if k < c then var k else var (k + d)
  | app t u => app (shift d c t) (shift d c u)
  | lam t => lam (shift d (c + 1) t)

/-- Capture-avoiding substitution: replace variable j with term s in term t.
    Variables above j are decremented since the binder is consumed.
    Under lambda binders, j is incremented and s is shifted. -/
def subst (j : Nat) (s : DBTerm) : DBTerm → DBTerm
  | var k =>
    if k = j then s
    else if k < j then var k
    else var (k - 1)
  | app t u => app (subst j s t) (subst j s u)
  | lam t => lam (subst (j + 1) (shift 1 0 s) t)

/-! ## 3. Variable Occurrence Counting -/

/-- Count occurrences of variable at de Bruijn index k in term t.
    Under lambda binders, the index is incremented to track the same
    "semantic" variable through the scope. -/
def varOccurrences (k : Nat) : DBTerm → Nat
  | var j => if j = k then 1 else 0
  | app t u => varOccurrences k t + varOccurrences k u
  | lam t => varOccurrences (k + 1) t

/-! ## 4. Affine Predicates -/

/-- A term is affine at index k if variable k occurs at most once. -/
def AffineAt (k : Nat) (t : DBTerm) : Prop :=
  varOccurrences k t ≤ 1

/-- A term is affine-closed if every bound variable is used at most once in its scope.
    Under every lambda binder, variable 0 occurs at most once,
    and all subterms are recursively affine-closed. -/
def AffineClosed : DBTerm → Prop
  | var _ => True
  | app t u => AffineClosed t ∧ AffineClosed u
  | lam t => AffineAt 0 t ∧ AffineClosed t

/-! ## 5. Branching Complexity and Redex Count -/

/-- Branching complexity: counts application nodes (branching points). -/
def branchComplexityDB : DBTerm → Nat
  | var _ => 0
  | app t u => 1 + branchComplexityDB t + branchComplexityDB u
  | lam t => branchComplexityDB t

/-- Redex count: number of β-redexes in a term. -/
def redexCountDB : DBTerm → Nat
  | var _ => 0
  | app (lam _) u => 1 + redexCountDB u
  | app t u => redexCountDB t + redexCountDB u
  | lam t => redexCountDB t

/-! ## 6. One-Step β-Reduction -/

/-- One-step β-reduction for de Bruijn terms. -/
inductive BetaDB : DBTerm → DBTerm → Prop where
  | beta (t s : DBTerm) : BetaDB (app (lam t) s) (subst 0 s t)
  | appLeft {t t' : DBTerm} (u : DBTerm) (h : BetaDB t t') :
      BetaDB (app t u) (app t' u)
  | appRight (t : DBTerm) {u u' : DBTerm} (h : BetaDB u u') :
      BetaDB (app t u) (app t u')
  | lamBody {t t' : DBTerm} (h : BetaDB t t') :
      BetaDB (lam t) (lam t')

/-! ## 7. Branch Complexity of Shift and Substitution -/

/-- Branch complexity is invariant under shifting (which only renames variables). -/
theorem branchComplexityDB_shift (t : DBTerm) (d c : Nat) :
    branchComplexityDB (shift d c t) = branchComplexityDB t := by
  induction t generalizing c with
  | var k => simp [shift]; split <;> simp [branchComplexityDB]
  | app t u iht ihu => simp [shift, branchComplexityDB, iht, ihu]
  | lam t ih => simp [shift, branchComplexityDB, ih]

private theorem subst_var_bc (k j : Nat) (s : DBTerm) (h : ¬ k = j) :
    branchComplexityDB (subst j s (var k)) = 0 := by
  simp [subst, h]
  split <;> simp [branchComplexityDB]

/-- When a variable has zero occurrences, substitution preserves branch complexity. -/
theorem branchComplexityDB_subst_zero_occ (t s : DBTerm) (j : Nat)
    (h : varOccurrences j t = 0) :
    branchComplexityDB (subst j s t) = branchComplexityDB t := by
  induction t generalizing j s with
  | var k =>
    simp [varOccurrences] at h
    exact subst_var_bc k j s h
  | app t u iht ihu =>
    simp [varOccurrences] at h
    simp [subst, branchComplexityDB, iht s j (by omega), ihu s j (by omega)]
  | lam t ih =>
    simp [varOccurrences] at h
    simp [subst, branchComplexityDB, ih (shift 1 0 s) (j + 1) h]

/-! ## 8. Theorem A — Affine Substitution Bound -/

/-- **Theorem A**: When variable j occurs at most once, substitution adds at most
    the branch complexity of the substituted term. -/
theorem branchComplexityDB_subst_affine_le (t s : DBTerm) (j : Nat)
    (h : AffineAt j t) :
    branchComplexityDB (subst j s t) ≤
      branchComplexityDB t + branchComplexityDB s := by
  unfold AffineAt at h
  induction t generalizing j s with
  | var k =>
    by_cases hk : k = j
    · simp [subst, hk, branchComplexityDB]
    · rw [subst_var_bc k j s hk]; simp [branchComplexityDB]
  | app t₁ t₂ ih1 ih2 =>
    simp [varOccurrences] at h
    simp only [subst, branchComplexityDB]
    by_cases h1 : varOccurrences j t₁ = 0
    · rw [branchComplexityDB_subst_zero_occ t₁ s j h1]
      have := ih2 s j (by omega)
      omega
    · rw [branchComplexityDB_subst_zero_occ t₂ s j (by omega)]
      have := ih1 s j (by omega)
      omega
  | lam t ih =>
    simp [varOccurrences] at h
    simp only [subst, branchComplexityDB]
    have := ih (shift 1 0 s) (j + 1) h
    rw [branchComplexityDB_shift] at this
    exact this

/-! ## 9. AffineClosed Subterm Lemmas -/

theorem AffineClosed_app_left {t u : DBTerm} (h : AffineClosed (app t u)) :
    AffineClosed t := h.1

theorem AffineClosed_app_right {t u : DBTerm} (h : AffineClosed (app t u)) :
    AffineClosed u := h.2

theorem AffineClosed_lam_body {t : DBTerm} (h : AffineClosed (lam t)) :
    AffineClosed t := h.2

theorem AffineClosed_lam_affineAt {t : DBTerm} (h : AffineClosed (lam t)) :
    AffineAt 0 t := h.1

/-! ## 10. Theorem B — β-Step Monotonicity -/

/-- **Theorem B (β-Step Monotonicity)**: For affine-closed terms, one-step
    β-reduction does not increase branching complexity.

    The key case is the root β-redex: `bc(app (lam body) arg) = 1 + bc(body) + bc(arg)`,
    and by Theorem A, `bc(subst 0 arg body) ≤ bc(body) + bc(arg)`, so bc strictly decreases. -/
theorem branchComplexityDB_beta_monotone {t u : DBTerm}
    (hac : AffineClosed t) (hbeta : BetaDB t u) :
    branchComplexityDB u ≤ branchComplexityDB t := by
  induction hbeta with
  | beta body arg =>
    simp [branchComplexityDB]
    have hAff : AffineAt 0 body := hac.1.1
    have bound := branchComplexityDB_subst_affine_le body arg 0 hAff
    omega
  | appLeft u _ ih =>
    simp [branchComplexityDB]
    have := ih (AffineClosed_app_left hac)
    omega
  | appRight t _ ih =>
    simp [branchComplexityDB]
    have := ih (AffineClosed_app_right hac)
    omega
  | lamBody _ ih =>
    simp [branchComplexityDB]
    exact ih (AffineClosed_lam_body hac)

/-! ## 11. Theorem D — No-Contraction Resource Law -/

/-- **Theorem D (No-Contraction Resource Law)**: In an affine-closed term,
    the number of redexes is bounded by the term size. This is the λ-calculus
    analogue of the absence of contraction in linear logic. -/
theorem affine_closed_redex_bound (t : DBTerm) (hac : AffineClosed t) :
    redexCountDB t ≤ sizeDB t := by
  induction t with
  | var _ => simp [redexCountDB, sizeDB]
  | app t u iht ihu =>
    have hL := AffineClosed_app_left hac
    have hR := AffineClosed_app_right hac
    cases t with
    | lam body =>
      simp only [redexCountDB, sizeDB]
      have := ihu hR; omega
    | var k =>
      simp only [redexCountDB, sizeDB]
      have := iht hL; have := ihu hR; omega
    | app a b =>
      simp only [redexCountDB, sizeDB]
      have h1 := iht hL; have h2 := ihu hR
      simp only [sizeDB] at h1; omega
  | lam t ih =>
    simp only [redexCountDB, sizeDB]
    have := ih (AffineClosed_lam_body hac); omega

/-! ## 12. Shift Preserves Variable Occurrences Below Cutoff -/

/-- Key identity: shifting doesn't change variable occurrences below the cutoff.
    This is because variables with index < c are left unchanged by shift,
    and variables with index ≥ c are shifted to indices ≥ c + d > c > k. -/
theorem varOccurrences_shift_below (t : DBTerm) (d c k : Nat) (hk : k < c) :
    varOccurrences k (shift d c t) = varOccurrences k t := by
  induction t generalizing c k with
  | var j =>
    simp [shift, varOccurrences]
    split
    · rfl  -- j < c: var j stays as var j
    · rename_i h  -- j ≥ c: var (j+d)
      push_neg at h
      simp only [varOccurrences]
      have : j + d ≠ k := by omega
      have : j ≠ k := by omega
      simp [*]
  | app t u iht ihu =>
    simp [shift, varOccurrences, iht c k hk, ihu c k hk]
  | lam t ih =>
    simp [shift, varOccurrences, ih (c + 1) (k + 1) (by omega)]

/-! ## 13. Shift Preserves AffineClosed -/

/-- **Shifting preserves AffineClosed**. Since shift preserves the binding structure
    and doesn't duplicate variables, the affine property is maintained.

    The proof uses the key fact that `varOcc k (shift d c t) = varOcc k t` for `k < c`
    (Lemma `varOccurrences_shift_below`), so under any lambda whose bound variable
    has index < the shift cutoff, the occurrence count is exactly preserved. -/
theorem AffineClosed_shift (t : DBTerm) (d c : Nat)
    (h : AffineClosed t) : AffineClosed (shift d c t) := by
  induction t generalizing c with
  | var j =>
    simp [shift]; split <;> exact trivial
  | app t u iht ihu =>
    exact ⟨iht c h.1, ihu c h.2⟩
  | lam t ih =>
    constructor
    · -- AffineAt 0 (shift d (c+1) t): varOcc 0 (shift d (c+1) t) ≤ 1
      -- Since 0 < c+1, by varOccurrences_shift_below: = varOcc 0 t ≤ 1
      show varOccurrences 0 (shift d (c + 1) t) ≤ 1
      rw [varOccurrences_shift_below t d (c + 1) 0 (by omega)]
      exact h.1
    · exact ih (c + 1) h.2

/-! ## 14. Variable Occurrence Preservation Under Substitution -/

/-
Variable 0 does not occur in shift 1 0 applied to any term.
    Since shift 1 0 increments all free variables by 1 (and the cutoff
    under lambdas prevents bound variable 0 from being affected),
    no variable can end up at index 0 in the result.
-/
theorem varOccurrences_zero_shift10 (s : DBTerm) :
    varOccurrences 0 (shift 1 0 s) = 0 := by
  -- By definition of `varOccurrences`, we can see that the occurrence of 0 in `shift 1 0 s` is zero because there are no variables with index 0 in the result.
  have h_varOccurrences_zero : ∀ (t : DBTerm) (c : Nat), varOccurrences c (shift 1 c t) = 0 := by
    intro t c;
    induction' t with t ih generalizing c;
    · by_cases h : t < c <;> simp +decide [ h, varOccurrences, shift ];
      · grind +revert;
      · grind;
    · convert congr_arg₂ ( · + · ) ( ‹∀ c : ℕ, varOccurrences c ( DBTerm.shift 1 c ih ) = 0› c ) ( ‹∀ c : ℕ, varOccurrences c ( DBTerm.shift 1 c _ ) = 0› c ) using 1;
    · convert ‹∀ c, varOccurrences c ( shift 1 c _ ) = 0› ( c + 1 ) using 1;
  exact h_varOccurrences_zero s 0

/-
Substitution at index j with a term whose varOcc k is 0 preserves
    varOcc k when k < j.
    In the var case: vars < j stay unchanged; var j is replaced by s
    with varOcc k s = 0; vars > j are decremented but stay above k.
-/
theorem varOccurrences_subst_below (t s : DBTerm) (j k : Nat)
    (hk : k < j) (hs : varOccurrences k s = 0) :
    varOccurrences k (subst j s t) = varOccurrences k t := by
  induction' t with t ih generalizing j k s;
  · grind +locals;
  · convert congr_arg₂ ( · + · ) ( ‹∀ ( s : DBTerm ) ( j k : ℕ ), k < j → varOccurrences k s = 0 → varOccurrences k ( subst j s ih ) = varOccurrences k ih› s j k hk hs ) ( ‹∀ ( s : DBTerm ) ( j k : ℕ ), k < j → varOccurrences k s = 0 → varOccurrences k ( subst j s _ ) = varOccurrences k _› s j k hk hs ) using 1;
  · have h_shift : varOccurrences (k + 1) (shift 1 0 s) = varOccurrences k s := by
      have h_shift : ∀ t : DBTerm, ∀ d c k, k ≥ c → varOccurrences (k + d) (shift d c t) = varOccurrences k t := by
        intros t d c k hk_c
        induction' t with t ih generalizing d c k;
        · simp +decide [ varOccurrences, shift ];
          split_ifs <;> simp_all +decide [ varOccurrences ];
          · grind;
          · grind;
        · convert congr_arg₂ ( · + · ) ( ‹∀ ( d c k : ℕ ), k ≥ c → varOccurrences ( k + d ) ( shift d c ih ) = varOccurrences k ih› d c k hk_c ) ( ‹∀ ( d c k : ℕ ), k ≥ c → varOccurrences ( k + d ) ( shift d c _ ) = varOccurrences k _› d c k hk_c ) using 1;
        · convert ‹∀ ( d c k : ℕ ), k ≥ c → varOccurrences ( k + d ) ( shift d c _ ) = varOccurrences k _ › d ( c + 1 ) ( k + 1 ) ( by linarith ) using 1;
          grind +locals;
      exact h_shift s 1 0 k ( Nat.zero_le _ );
    convert ‹∀ ( s : DBTerm ) ( j k : ℕ ), k < j → varOccurrences k s = 0 → varOccurrences k ( subst j s _ ) = varOccurrences k _› ( shift 1 0 s ) ( j + 1 ) ( k + 1 ) ( by linarith ) ( by aesop ) using 1

/-! ## 15. Substitution Preserves AffineClosed -/

/-
Substitution preserves AffineClosed when the body is affine at the
    substitution index and the substitute is affine-closed.
-/
theorem AffineClosed_subst (t s : DBTerm) (j : Nat) :
    AffineClosed t → AffineClosed s → AffineAt j t →
    AffineClosed (subst j s t) := by
  induction t generalizing j s;
  · grind +locals;
  · grind +locals;
  · intro h1 h2 h3;
    apply And.intro;
    · exact le_trans ( varOccurrences_subst_below _ _ _ _ ( Nat.zero_lt_succ _ ) ( varOccurrences_zero_shift10 _ ) |> le_of_eq ) ( by cases h1 ; tauto );
    · apply_assumption;
      · cases h1 ; tauto;
      · exact AffineClosed_shift _ _ _ h2;
      · exact h3

/-
Variable occurrence accounting for substitution: when AffineAt j t,
    varOcc k (subst j s t) ≤ varOcc k t + varOcc k s for k < j.
    (Because the variable at j can appear at most once, contributing
    at most varOcc k s, and variables above j are decremented but stay above k.)
-/
theorem varOccurrences_subst_affine_le_below (t s : DBTerm) (j k : Nat)
    (hk : k < j) (hAff : AffineAt j t) :
    varOccurrences k (subst j s t) ≤
      varOccurrences k t + varOccurrences k s := by
  revert t s k j;
  intro t s j k hk hAff
  have h_varOcc : varOccurrences k (subst j s t) ≤ varOccurrences k t + (varOccurrences j t) * (varOccurrences k s) := by
    induction' t with t ih generalizing j k s;
    · -- By definition of varOccurrences, we have:
      simp [varOccurrences, subst];
      split_ifs <;> simp_all +decide [ varOccurrences ];
      omega;
    · grind +locals;
    · simp_all +decide [ AffineAt ];
      rename_i t ih;
      convert ih ( shift 1 0 s ) ( j + 1 ) ( k + 1 ) ( by linarith ) _ using 1;
      · rw [ show varOccurrences ( k + 1 ) ( shift 1 0 s ) = varOccurrences k s from ?_ ];
        · rfl;
        · have h_shift : ∀ (t : DBTerm) (d c k : Nat), k ≥ c → varOccurrences (k + d) (shift d c t) = varOccurrences k t := by
            intros t d c k hk;
            induction' t with t ih generalizing d c k;
            · simp [shift, varOccurrences];
              split_ifs <;> simp_all +decide [ varOccurrences ];
              · linarith;
              · grind;
            · grind +locals;
            · rename_i t ih;
              convert ih d ( c + 1 ) ( k + 1 ) ( by linarith ) using 1;
              grind +locals;
          exact h_shift s 1 0 k ( Nat.zero_le k );
      · exact hAff;
  exact h_varOcc.trans ( by nlinarith [ show varOccurrences j t ≤ 1 from hAff ] )

/-
Generalized shift identity: varOcc (k+d) (shift d c t) = varOcc k t for k ≥ c.
-/
theorem varOccurrences_shift_ge (t : DBTerm) (d c k : Nat) (hk : k ≥ c) :
    varOccurrences (k + d) (shift d c t) = varOccurrences k t := by
  induction' t with k t u ihk ihu generalizing c k d;
  · simp +arith +decide [ shift, varOccurrences ];
    split_ifs <;> simp_all +arith +decide [ varOccurrences ];
    · linarith;
    · linarith;
  · convert congr_arg₂ ( · + · ) ( ihk d c k hk ) ( ihu d c k hk ) using 1;
  · convert ‹∀ ( d c k : ℕ ), k ≥ c → varOccurrences ( k + d ) ( shift d c _ ) = varOccurrences k _ › d ( c + 1 ) ( k + 1 ) ( by linarith ) using 1;
    rw [ show k + 1 + d = k + d + 1 by ring ];
    rfl

/-
Substitution at the same index: varOcc k (subst k s t) ≤ varOcc k s * varOcc k t + varOcc (k+1) t.
    This accounts for replacing var k with s (contributing varOcc k s per occurrence)
    and decrementing vars above k (var (k+1) becomes var k).
-/
theorem varOccurrences_subst_same_le (t s : DBTerm) (k : Nat) :
    varOccurrences k (subst k s t) ≤
      varOccurrences k s * varOccurrences k t + varOccurrences (k + 1) t := by
  induction' t with t ih generalizing k s;
  · by_cases h : t = k <;> simp +decide [ h, varOccurrences, subst ];
    split_ifs <;> simp_all +decide [ varOccurrences ];
    omega;
  · rename_i h₁ h₂;
    convert add_le_add ( h₁ s k ) ( h₂ s k ) using 1 ; ring!;
    rw [ show varOccurrences k ( ih.app _ ) = varOccurrences k ih + varOccurrences k _ from rfl, show varOccurrences ( 1 + k ) ( ih.app _ ) = varOccurrences ( 1 + k ) ih + varOccurrences ( 1 + k ) _ from rfl ] ; ring;
  · convert ‹∀ ( s : DBTerm ) ( k : ℕ ), varOccurrences k ( subst k s _ ) ≤ varOccurrences k s * varOccurrences k _ + varOccurrences ( k + 1 ) _› ( shift 1 0 s ) ( k + 1 ) using 1;
    rw [ varOccurrences_shift_ge ] <;> norm_num;
    rfl

/-
AffineAt k is non-increasing under β-reduction for AffineClosed terms.
-/
theorem affineAt_beta_monotone {t u : DBTerm} (k : Nat)
    (hac : AffineClosed t) (hAff : AffineAt k t) (hbeta : BetaDB t u) :
    AffineAt k u := by
  have h_subst_bound : ∀ (t s : DBTerm) (j k : Nat), varOccurrences k (subst j s t) ≤ varOccurrences j t * varOccurrences k s + varOccurrences (if k ≥ j then k + 1 else k) t := by
    intros t s j k
    induction' t with t ih generalizing s j k;
    · grind +locals;
    · simp +arith +decide [ varOccurrences ] at *;
      rename_i h₁ h₂;
      convert add_le_add ( h₁ s j k ) ( h₂ s j k ) using 1 ; ring;
    · convert ‹∀ ( s : DBTerm ) ( j k : ℕ ), varOccurrences k ( subst j s _ ) ≤ varOccurrences j _ * varOccurrences k s + varOccurrences ( if k ≥ j then k + 1 else k ) _› ( shift 1 0 s ) ( j + 1 ) ( k + 1 ) using 1;
      rw [ varOccurrences_shift_ge ] <;> norm_num;
      split_ifs <;> rfl;
  have h_affine_closed_subst : ∀ (t u : DBTerm) (k : Nat), t.AffineClosed → t.BetaDB u → varOccurrences k u ≤ varOccurrences k t + branchComplexityDB t * 0 := by
    intros t u k hac hbeta
    induction' hbeta with t u hbeta ih generalizing k;
    · nontriviality;
      have := h_subst_bound t u 0 k; simp_all +decide [ DBTerm.AffineClosed ] ;
      nontriviality;
      exact this.trans ( by rw [ show varOccurrences k ( t.lam.app u ) = varOccurrences ( k + 1 ) t + varOccurrences k u by rfl ] ; nlinarith [ hac.1.1, show varOccurrences 0 t ≤ 1 from hac.1.1 ] );
    · rename_i h₁ h₂;
      convert add_le_add ( h₂ k ( AffineClosed_app_left hac ) ) le_rfl using 1;
    · rename_i t u u' hbeta ih;
      convert add_le_add_left ( ih k ( AffineClosed_app_right hac ) ) ( varOccurrences k t ) using 1;
      · exact add_comm _ _;
      · simp +arith +decide [ DBTerm.varOccurrences, DBTerm.branchComplexityDB ];
    · rename_i t u hbeta ih;
      convert ih ( k + 1 ) ( AffineClosed_lam_body hac ) using 1;
  exact le_trans ( h_affine_closed_subst t u k hac hbeta ) hAff

/-! ## 15. AffineClosed Preservation Under β-Reduction -/

/-- AffineClosed is preserved by one-step β-reduction. -/
theorem affineClosed_preserved_step {t u : DBTerm}
    (hac : AffineClosed t) (hbeta : BetaDB t u) :
    AffineClosed u := by
  induction hbeta with
  | beta body arg =>
    exact AffineClosed_subst body arg 0 (AffineClosed_lam_body hac.1)
      hac.2 hac.1.1
  | appLeft u _ ih =>
    exact ⟨ih (AffineClosed_app_left hac), AffineClosed_app_right hac⟩
  | appRight t _ ih =>
    exact ⟨AffineClosed_app_left hac, ih (AffineClosed_app_right hac)⟩
  | lamBody h ih =>
    exact ⟨affineAt_beta_monotone 0 (AffineClosed_lam_body hac)
      (AffineClosed_lam_affineAt hac) h, ih (AffineClosed_lam_body hac)⟩

/-! ## 16. Bounded Reachability and State Growth -/

/-- Bounded reachability for de Bruijn terms. -/
inductive ReachableDB : Nat → DBTerm → DBTerm → Prop where
  | refl (d : Nat) (t : DBTerm) : ReachableDB d t t
  | step {d : Nat} {t v u : DBTerm}
      (h₁ : ReachableDB d t v) (h₂ : BetaDB v u) :
      ReachableDB (d + 1) t u

/-- The set of terms reachable within d steps. -/
noncomputable def StateSetDB (t : DBTerm) (d : Nat) : Set DBTerm :=
  {u | ReachableDB d t u}

/-- State growth: number of distinct reachable terms. -/
noncomputable def stateGrowthDB (t : DBTerm) (d : Nat) : Nat :=
  Set.ncard (StateSetDB t d)

/-- AffineClosed is preserved along reduction paths. -/
theorem affineClosed_preserved_reachable {t u : DBTerm} {d : Nat}
    (hac : AffineClosed t) (hr : ReachableDB d t u) :
    AffineClosed u := by
  induction hr with
  | refl => exact hac
  | step h₁ h₂ =>
    rename_i ih
    exact affineClosed_preserved_step (ih hac) h₂

/-- Multi-step branch complexity monotonicity. -/
theorem branchComplexityDB_reachable_monotone {t u : DBTerm} {d : Nat}
    (hac : AffineClosed t) (hr : ReachableDB d t u) :
    branchComplexityDB u ≤ branchComplexityDB t := by
  induction hr with
  | refl => exact le_refl _
  | step h₁ h₂ =>
    rename_i ih
    have hv_ac := affineClosed_preserved_reachable hac h₁
    have hle := ih hac
    have := branchComplexityDB_beta_monotone hv_ac h₂
    omega

/-- **Theorem C (State Growth Branch Bound)**: For affine-closed terms,
    all reachable terms have branch complexity bounded by the initial term's. -/
theorem stateGrowthDB_branch_bounded {t : DBTerm} {d : Nat}
    (hac : AffineClosed t) :
    ∀ u ∈ StateSetDB t d, branchComplexityDB u ≤ branchComplexityDB t := by
  intro u hu
  exact branchComplexityDB_reachable_monotone hac hu

/-! ## 17. Computational Examples -/

def idDB : DBTerm := lam (var 0)
def constDB : DBTerm := lam (lam (var 1))
def falseDB : DBTerm := lam (lam (var 0))
def dupDB : DBTerm := lam (app (var 0) (var 0))
def pairAppDB : DBTerm := lam (lam (app (var 1) (var 0)))

theorem idDB_affineClosed : AffineClosed idDB := by
  exact ⟨by simp [AffineAt, varOccurrences], trivial⟩

theorem constDB_affineClosed : AffineClosed constDB := by
  exact ⟨by simp [AffineAt, varOccurrences], by simp [AffineAt, varOccurrences], trivial⟩

theorem falseDB_affineClosed : AffineClosed falseDB := by
  exact ⟨by simp [AffineAt, varOccurrences], by simp [AffineAt, varOccurrences], trivial⟩

theorem dupDB_not_affineClosed : ¬AffineClosed dupDB := by
  intro ⟨h, _⟩; simp [AffineAt, varOccurrences] at h

theorem branchComplexityDB_id : branchComplexityDB idDB = 0 := by
  simp [idDB, branchComplexityDB]

theorem branchComplexity_id_app_reduces (s : DBTerm) :
    branchComplexityDB (subst 0 s (var 0)) ≤
    branchComplexityDB (app (lam (var 0)) s) := by
  simp [subst, branchComplexityDB]

theorem pairAppDB_affineClosed : AffineClosed pairAppDB := by
  refine ⟨?_, ?_, ?_⟩
  · simp [AffineAt, varOccurrences]
  · simp [AffineAt, varOccurrences]
  · constructor <;> trivial

theorem branchComplexityDB_pairApp : branchComplexityDB pairAppDB = 1 := by
  simp [pairAppDB, branchComplexityDB]

end DBTerm