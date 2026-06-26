import Mathlib

/-!
# Untyped λ-calculus: syntax, substitution and β-reduction (de Bruijn)

This file develops the untyped λ-calculus with de Bruijn indices.  It provides the
basic syntactic apparatus that the rest of the `Logic.LambdaCalculus` development
(confluence, Böhm approximants, …) builds on.

## Main definitions

* `Lam`            — λ-terms with de Bruijn indices.
* `Lam.lift`       — shift of free variables above a cutoff.
* `Lam.subst`      — capture-avoiding substitution for a single variable.
* `Lam.subst0`     — substitution for the outermost bound variable (β-contraction).
* `Beta`           — single-step β-reduction.
* `BetaStar`       — its reflexive–transitive closure.
* `NormalForm`     — a term with no β-redex.
* `Lam.I`, `Lam.Delta`, `Lam.omega` — the combinators `I = λx.x`, `Δ = λx.x x`
  and `Ω = Δ Δ`.

## Main results

The fundamental **substitution algebra** of de Bruijn terms:

* `lift_lift`, `subst_lift_cancel`, `lift_subst_le`, `lift_subst_ge`,
  and the *substitution lemma* `subst_subst`.

These commutation identities are exactly what is needed to make parallel
reduction respect substitution, which in turn powers the Church–Rosser theorem
in `Logic.LambdaCalculus.Confluence`.

-- !-- Lab Notes -- !--
Hypothesis (H0): A small, well-chosen set of lift/subst commutation lemmas
(`lift_lift`, `subst_lift_cancel`, `lift_subst_le`, `lift_subst_ge`,
`subst_subst`) suffices to drive every later substitution obligation.
Experiment: each identity was first validated by exhaustive `#eval` over all
terms of depth ≤ 2 with variable indices < 4 and all cutoffs < 4 before being
proved.  Analysis: the de Bruijn arithmetic is entirely discharged by `omega`
once the term induction is `generalizing` the cutoff/index.  Critique: the two
directions `lift_subst_le`/`lift_subst_ge` are genuinely different (different
index shifts under a binder) and both are needed.
-- !-- End Lab Notes -- !--
-/

namespace LambdaCalculus

/-- λ-terms with de Bruijn indices. -/
inductive Lam : Type where
  | var : ℕ → Lam
  | lam : Lam → Lam
  | app : Lam → Lam → Lam
deriving DecidableEq, Repr

namespace Lam

/-- `lift c t` increments every free variable of `t` whose index is `≥ c`.
This is the de Bruijn shift used when pushing a term under a binder. -/
def lift (c : ℕ) : Lam → Lam
  | var k => if k < c then var k else var (k + 1)
  | lam t => lam (lift (c + 1) t)
  | app a b => app (lift c a) (lift c b)

/-- `subst j s t` substitutes `s` for the variable `j` in `t`, decrementing the
variables strictly above `j` (capture-avoiding via `lift` under binders). -/
def subst (j : ℕ) (s : Lam) : Lam → Lam
  | var k => if k = j then s else if j < k then var (k - 1) else var k
  | lam t => lam (subst (j + 1) (lift 0 s) t)
  | app a b => app (subst j s a) (subst j s b)

/-- β-contraction substitution: replace the outermost bound variable. -/
def subst0 (s t : Lam) : Lam := subst 0 s t

/-- The combinator `I = λx. x`. -/
def I : Lam := lam (var 0)

/-- The self-application `Δ = λx. x x`. -/
def Delta : Lam := lam (app (var 0) (var 0))

/-- The looping term `Ω = Δ Δ = (λx. x x)(λx. x x)`. -/
def omega : Lam := app Delta Delta

/-! ### Substitution algebra -/

/-
Lifts commute (raising the second cutoff when applied innermost).
-/
theorem lift_lift (t : Lam) {i j : ℕ} (h : i ≤ j) :
    lift i (lift j t) = lift (j + 1) (lift i t) := by
      induction' t with t ih generalizing i j;
      · grind +locals;
      · simp +decide [ *, Lam.lift ];
      · simp +decide [ *, Lam.lift ]

/-
Substituting at a cutoff that was just created by `lift` is the identity.
-/
theorem subst_lift_cancel (t : Lam) (i : ℕ) (s : Lam) :
    subst i s (lift i t) = t := by
      induction' t with t ih generalizing s i <;> simp +decide [ subst, lift ] at *;
      · split_ifs <;> simp_all +decide [ subst ]; all_goals grind;
      · convert ‹∀ ( i : ℕ ) ( s : Lam ), subst i s ( lift i ih ) = ih› ( i + 1 ) ( lift 0 s ) using 1;
      · aesop

/-
`lift` pushed through a `subst` when the lift cutoff is `≤` the substituted
variable.
-/
theorem lift_subst_le (t : Lam) {i j : ℕ} (h : i ≤ j) (s : Lam) :
    lift i (subst j s t) = subst (j + 1) (lift i s) (lift i t) := by
      -- We proceed by induction on `t`.
      induction' t with t ih generalizing i j s;
      · simp +decide [ Lam.lift, Lam.subst ];
        split_ifs <;> simp_all +decide [ Lam.lift, Lam.subst ];
        · linarith;
        · grind;
        · grind;
        · grind;
        · grind;
      · simp +decide [ *, Lam.lift, Lam.subst ];
        rw [ lift_lift s ( Nat.zero_le i ) ];
      · simp_all +decide [ Lam.lift, Lam.subst ]

/-
`lift` pushed through a `subst` when the lift cutoff is `≥` the substituted
variable.
-/
theorem lift_subst_ge (t : Lam) {i j : ℕ} (h : j ≤ i) (s : Lam) :
    lift i (subst j s t) = subst j (lift i s) (lift (i + 1) t) := by
      induction' t with t ih generalizing i j s;
      · simp +decide [ lift, subst ];
        split_ifs <;> simp_all +decide [ lift, subst ];
        · omega;
        · lia;
        · grind;
        · grind;
      · simp +decide [ *, Lam.lift, Lam.subst ];
        rw [ lift_lift s ( Nat.zero_le i ) ];
      · rename_i a b ih₁ ih₂; exact congr_arg₂ _ ( ih₁ h s ) ( ih₂ h s ) ;

/-
The **substitution lemma** for de Bruijn terms.
-/
theorem subst_subst (e : Lam) {n m : ℕ} (h : n ≤ m) (w v : Lam) :
    subst m w (subst n v e) =
      subst n (subst m w v) (subst (m + 1) (lift n w) e) := by
        induction' e with e ih generalizing n m w v;
        · simp +decide [ Lam.subst ];
          split_ifs <;> simp_all +decide [ Lam.subst ];
          any_goals omega;
          · rw [ subst_lift_cancel ];
          · grind;
          · grind;
          · grind;
        · simp_all +decide [ Lam.subst ];
          grind +suggestions;
        · simp_all +decide [ Lam.subst ]

/-- Special case of `subst_subst` for β-contraction (`n = 0`). -/
theorem subst0_subst (e : Lam) (j : ℕ) (w v : Lam) :
    subst j w (subst0 v e) = subst0 (subst j w v) (subst (j + 1) (lift 0 w) e) := by
  simpa [subst0] using subst_subst e (Nat.zero_le j) w v

end Lam

/-! ### β-reduction -/

open Lam

/-- Single-step β-reduction. -/
inductive Beta : Lam → Lam → Prop
  | beta (t u : Lam) : Beta (app (lam t) u) (subst0 u t)
  | appL {a a' : Lam} (b : Lam) : Beta a a' → Beta (app a b) (app a' b)
  | appR (a : Lam) {b b' : Lam} : Beta b b' → Beta (app a b) (app a b')
  | lam {t t' : Lam} : Beta t t' → Beta (lam t) (lam t')

/-- Multi-step β-reduction: the reflexive–transitive closure of `Beta`. -/
def BetaStar : Lam → Lam → Prop := Relation.ReflTransGen Beta

/-- A term is in normal form when no β-step applies. -/
def NormalForm (t : Lam) : Prop := ∀ u, ¬ Beta t u

end LambdaCalculus