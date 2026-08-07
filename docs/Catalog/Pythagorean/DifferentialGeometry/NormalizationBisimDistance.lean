/-
# Normalization Cost as Bisimulation Distance

## Overview

This file establishes a quantitative bridge between proof complexity,
coalgebraic behavior, and metric semantics for the lambda calculus.
β-normalization budgets induce observable bisimulation radii, and the
resulting distance function satisfies pseudometric axioms.

## Main Results

1. **Bridge Theorem** (`weakBisimilar_of_joinBudget`): Joinability within
   budget k implies weak bisimilarity at depth k.

2. **Pseudometric Axioms** for `eqPathDist`:
   - `eqPathDist_self`: d(t,t) = 0
   - `eqPathDist_comm`: d(t,u) = d(u,t)
   - `eqPathDist_triangle`: d(t,v) ≤ d(t,u) + d(u,v)

3. **Cost Upper Bound** (`eqPathDist_le_of_joinBudget`): The behavioral
   distance is bounded by the joinability budget.

4. **Context Nonexpansiveness**: Application and lambda abstraction
   are nonexpansive with respect to eqPathDist.
-/

import Mathlib
import Pythagorean.BoundedBetaDefs

open Classical

/-! ## Joinability Budget -/

/-- Terms are `k`-joinably bounded if they reduce to a common term using
at most `k` total β-steps (summing both sides). -/
def JoinBudgetBound (k : ℕ) (t u : Lam) : Prop :=
  ∃ v : Lam, ∃ k₁ k₂ : ℕ, k₁ + k₂ ≤ k ∧
    ReachableWithin k₁ t v ∧ ReachableWithin k₂ u v

theorem JoinBudgetBound.refl (t : Lam) : JoinBudgetBound 0 t t :=
  ⟨t, 0, 0, le_refl 0, ReachableWithin.refl 0 t, ReachableWithin.refl 0 t⟩

theorem JoinBudgetBound.symm {k : ℕ} {t u : Lam}
    (h : JoinBudgetBound k t u) : JoinBudgetBound k u t := by
  obtain ⟨v, k₁, k₂, hle, h₁, h₂⟩ := h
  exact ⟨v, k₂, k₁, by omega, h₂, h₁⟩

theorem JoinBudgetBound.mono {k₁ k₂ : ℕ} {t u : Lam}
    (h : JoinBudgetBound k₁ t u) (hle : k₁ ≤ k₂) : JoinBudgetBound k₂ t u := by
  obtain ⟨v, j₁, j₂, hjle, h₁, h₂⟩ := h
  exact ⟨v, j₁, j₂, le_trans hjle hle, h₁, h₂⟩

theorem JoinBudgetBound.betaEq {k : ℕ} {t u : Lam}
    (h : JoinBudgetBound k t u) : BetaEq t u := by
  obtain ⟨v, _, _, _, h₁, h₂⟩ := h
  exact BetaEq.trans (reachableWithin_betaEq h₁) (BetaEq.symm (reachableWithin_betaEq h₂))

/-! ## Weak Bisimilarity at Depth -/

/-- Behavioral indistinguishability visible within unfolding depth `k`. -/
def WeaklyBisimilarAtDepth (k : ℕ) (t u : Lam) : Prop :=
  ∃ R : Lam → Lam → Prop,
    R t u ∧
    (∀ a b, R a b → ∀ a',
      (toFTS k t).step a a' →
      ∃ b', Relation.ReflTransGen (toFTS k u).step b b' ∧ R a' b') ∧
    (∀ a b, R a b → ∀ b',
      (toFTS k u).step b b' →
      ∃ a', Relation.ReflTransGen (toFTS k t).step a a' ∧ R a' b')

/-- β-equivalent terms are weakly bisimilar at all depths. -/
theorem weaklyBisimilarAtDepth_of_betaEq (k : ℕ) {t u : Lam}
    (h : BetaEq t u) : WeaklyBisimilarAtDepth k t u := by
  refine ⟨BetaEq, h, ?_, ?_⟩
  · intro a b hab a' ha'
    simp only [toFTS] at ha'
    exact ⟨b, Relation.ReflTransGen.refl,
      BetaEq.trans (BetaEq.symm (BetaEq.step ha'.2.2)) hab⟩
  · intro a b hab b' hb'
    simp only [toFTS] at hb'
    exact ⟨a, Relation.ReflTransGen.refl,
      BetaEq.trans hab (BetaEq.step hb'.2.2)⟩

/-- **Bridge Theorem**: Joinability within budget k implies weak bisimilarity
at depth k. This converts proof-theoretic convergence into coalgebraic
indistinguishability. -/
theorem weakBisimilar_of_joinBudget {t u : Lam} {k : ℕ}
    (h : JoinBudgetBound k t u) : WeaklyBisimilarAtDepth k t u :=
  weaklyBisimilarAtDepth_of_betaEq k h.betaEq

/-! ## Normal Forms and Normalization Cost -/

/-- A term is in β-normal form. -/
def IsNormalForm (t : Lam) : Prop := ∀ u, ¬ BetaStep t u

/-- A term normalizes within k steps. -/
def NormalizesIn (k : ℕ) (t : Lam) : Prop :=
  ∃ nf : Lam, IsNormalForm nf ∧ ReachableWithin k t nf

/-- A term has a β-normal form. -/
def HasNormalForm (t : Lam) : Prop := ∃ k, NormalizesIn k t

theorem IsNormalForm.var (n : ℕ) : IsNormalForm (.var n) := by
  intro u h; cases h

/-- Normalization cost: minimal steps to reach a normal form. 0 if no normal form. -/
noncomputable def normCost (t : Lam) : ℕ :=
  sInf {k | NormalizesIn k t}

theorem normCost_of_normalForm {t : Lam} (hnf : IsNormalForm t) :
    normCost t = 0 := by
  apply Nat.eq_zero_of_le_zero
  exact Nat.sInf_le (show NormalizesIn 0 t from ⟨t, hnf, ReachableWithin.refl 0 t⟩)

theorem normCost_var (n : ℕ) : normCost (.var n) = 0 :=
  normCost_of_normalForm (IsNormalForm.var n)

/-! ## β-Equivalence with Step Counting -/

/-- β-equivalence derivation with explicit step count.
Each step is either a forward β-reduction or a backward β-expansion. -/
inductive BetaEqIn : ℕ → Lam → Lam → Prop where
  | refl (t : Lam) : BetaEqIn 0 t t
  | stepFwd {k : ℕ} {t u v : Lam} (h₁ : BetaStep t u) (h₂ : BetaEqIn k u v) :
      BetaEqIn (k + 1) t v
  | stepBwd {k : ℕ} {t u v : Lam} (h₁ : BetaStep u t) (h₂ : BetaEqIn k u v) :
      BetaEqIn (k + 1) t v

theorem BetaEqIn.toBetaEq {k : ℕ} {t u : Lam}
    (h : BetaEqIn k t u) : BetaEq t u := by
  induction h with
  | refl => exact BetaEq.refl _
  | stepFwd h₁ _ ih => exact BetaEq.trans (BetaEq.step h₁) ih
  | stepBwd h₁ _ ih => exact BetaEq.trans (BetaEq.symm (BetaEq.step h₁)) ih

/-- Composition of BetaEqIn derivations. -/
theorem BetaEqIn.append {k₁ k₂ : ℕ} {t u v : Lam}
    (h₁ : BetaEqIn k₁ t u) (h₂ : BetaEqIn k₂ u v) :
    BetaEqIn (k₁ + k₂) t v := by
  induction h₁ generalizing v with
  | refl => simpa using h₂
  | stepFwd h₁ _ ih =>
    simp [Nat.succ_add]; exact BetaEqIn.stepFwd h₁ (ih h₂)
  | stepBwd h₁ _ ih =>
    simp [Nat.succ_add]; exact BetaEqIn.stepBwd h₁ (ih h₂)

/-- Reversal of BetaEqIn derivations: symmetry with preserved step count. -/
theorem BetaEqIn.symm {k : ℕ} {t u : Lam}
    (h : BetaEqIn k t u) : BetaEqIn k u t := by
  induction h with
  | refl => exact BetaEqIn.refl _
  | stepFwd h₁ _ ih =>
    have := ih.append (BetaEqIn.stepBwd h₁ (BetaEqIn.refl _))
    simpa using this
  | stepBwd h₁ _ ih =>
    have := ih.append (BetaEqIn.stepFwd h₁ (BetaEqIn.refl _))
    simpa using this

theorem BetaEq.toBetaEqIn {t u : Lam}
    (h : BetaEq t u) : ∃ k, BetaEqIn k t u := by
  induction h with
  | refl => exact ⟨0, BetaEqIn.refl _⟩
  | step h => exact ⟨1, BetaEqIn.stepFwd h (BetaEqIn.refl _)⟩
  | symm _ ih => obtain ⟨k, hk⟩ := ih; exact ⟨k, hk.symm⟩
  | trans _ _ ih₁ ih₂ =>
    obtain ⟨k₁, hk₁⟩ := ih₁; obtain ⟨k₂, hk₂⟩ := ih₂
    exact ⟨k₁ + k₂, hk₁.append hk₂⟩

/-! ## Context Congruence for BetaEqIn -/

/-- BetaEqIn is congruent under application on the left. -/
theorem BetaEqIn.appLeft {k : ℕ} {t u : Lam} (s : Lam)
    (h : BetaEqIn k t u) : BetaEqIn k (.app t s) (.app u s) := by
  induction h with
  | refl => exact BetaEqIn.refl _
  | stepFwd h₁ _ ih => exact BetaEqIn.stepFwd (BetaStep.appLeft s h₁) ih
  | stepBwd h₁ _ ih => exact BetaEqIn.stepBwd (BetaStep.appLeft s h₁) ih

/-- BetaEqIn is congruent under application on the right. -/
theorem BetaEqIn.appRight {k : ℕ} {t u : Lam} (s : Lam)
    (h : BetaEqIn k t u) : BetaEqIn k (.app s t) (.app s u) := by
  induction h with
  | refl => exact BetaEqIn.refl _
  | stepFwd h₁ _ ih => exact BetaEqIn.stepFwd (BetaStep.appRight s h₁) ih
  | stepBwd h₁ _ ih => exact BetaEqIn.stepBwd (BetaStep.appRight s h₁) ih

/-- BetaEqIn is congruent under lambda abstraction. -/
theorem BetaEqIn.lamBody {k : ℕ} {t u : Lam} (x : ℕ)
    (h : BetaEqIn k t u) : BetaEqIn k (.lam x t) (.lam x u) := by
  induction h with
  | refl => exact BetaEqIn.refl _
  | stepFwd h₁ _ ih => exact BetaEqIn.stepFwd (BetaStep.lamBody x h₁) ih
  | stepBwd h₁ _ ih => exact BetaEqIn.stepBwd (BetaStep.lamBody x h₁) ih

/-! ## Equivalence-Path Pseudometric -/

/-- The equivalence-path distance: minimum number of β-steps (forward or backward)
in a chain connecting t to u. This is the path metric on the β-equivalence graph. -/
noncomputable def eqPathDist (t u : Lam) : ℕ :=
  sInf {k | BetaEqIn k t u}

/-- **Self-distance is zero.** -/
theorem eqPathDist_self (t : Lam) : eqPathDist t t = 0 := by
  apply Nat.eq_zero_of_le_zero
  exact Nat.sInf_le (BetaEqIn.refl t)

/-- **Symmetry of distance.** -/
theorem eqPathDist_comm (t u : Lam) : eqPathDist t u = eqPathDist u t := by
  simp only [eqPathDist]
  congr 1; ext k
  exact ⟨BetaEqIn.symm, BetaEqIn.symm⟩

/-- If every BetaEqIn k derivation for (t₁,t₂) lifts to one for (s₁,s₂)
at the same step count, and t₁,t₂ are β-equivalent, then
eqPathDist s₁ s₂ ≤ eqPathDist t₁ t₂. -/
theorem eqPathDist_le_of_lift {t₁ t₂ s₁ s₂ : Lam}
    (h : ∀ k, BetaEqIn k t₁ t₂ → BetaEqIn k s₁ s₂)
    (hne : ∃ k, BetaEqIn k t₁ t₂) :
    eqPathDist s₁ s₂ ≤ eqPathDist t₁ t₂ := by
  simp only [eqPathDist]
  apply csInf_le_csInf
  · exact ⟨0, fun x _ => Nat.zero_le x⟩
  · exact hne
  · exact h

/-
**Triangle inequality**: d(t,v) ≤ d(t,u) + d(u,v)
for β-equivalent terms. The β-equivalence hypotheses are needed because
sInf ∅ = 0 for ℕ, which would break the triangle inequality for
non-β-equivalent terms.
-/
theorem eqPathDist_triangle {t u v : Lam}
    (htu : BetaEq t u) (huv : BetaEq u v) :
    eqPathDist t v ≤ eqPathDist t u + eqPathDist u v := by
  have htu' : ∃ k, BetaEqIn k t u := BetaEq.toBetaEqIn htu;
  obtain ⟨k₁, hk₁⟩ : ∃ k₁, BetaEqIn k₁ t u := htu'
  obtain ⟨k₂, hk₂⟩ : ∃ k₂, BetaEqIn k₂ u v := BetaEq.toBetaEqIn huv;
  have h_combined : BetaEqIn (eqPathDist t u + eqPathDist u v) t v := by
    convert BetaEqIn.append ( Nat.sInf_mem ( show { k | BetaEqIn k t u }.Nonempty from ⟨ k₁, hk₁ ⟩ ) ) ( Nat.sInf_mem ( show { k | BetaEqIn k u v }.Nonempty from ⟨ k₂, hk₂ ⟩ ) ) using 1;
  exact Nat.sInf_le h_combined

/-! ## ReachableWithin → BetaEqIn -/

/-- ReachableWithin induces a BetaEqIn derivation. -/
theorem ReachableWithin.toBetaEqIn {k : ℕ} {t u : Lam}
    (h : ReachableWithin k t u) : ∃ k' : ℕ, k' ≤ k ∧ BetaEqIn k' t u := by
  induction h with
  | refl => exact ⟨0, Nat.zero_le _, BetaEqIn.refl _⟩
  | step h₁ hstep ih =>
    obtain ⟨k', hle, hk'⟩ := ih
    exact ⟨k' + 1, by omega,
      hk'.append (BetaEqIn.stepFwd hstep (BetaEqIn.refl _))⟩

/-! ## Cost Upper Bounds -/

/-- The eqPathDist is bounded by the joinability budget. -/
theorem eqPathDist_le_of_joinBudget {k : ℕ} {t u : Lam}
    (h : JoinBudgetBound k t u) : eqPathDist t u ≤ k := by
  obtain ⟨v, k₁, k₂, hle, h₁, h₂⟩ := h
  obtain ⟨k₁', hle₁, hk₁⟩ := h₁.toBetaEqIn
  obtain ⟨k₂', hle₂, hk₂⟩ := h₂.toBetaEqIn
  have htu : BetaEqIn (k₁' + k₂') t u := hk₁.append hk₂.symm
  calc eqPathDist t u ≤ k₁' + k₂' := Nat.sInf_le htu
    _ ≤ k := by omega

/-- **Normalization Cost Upper Bound**: If t and u both reduce to the same
normal form nf, then d(t,u) ≤ normCost(t) + normCost(u).
This is the fundamental quantitative bridge: computational effort
(normalization cost) bounds observational discrepancy (behavioral distance).

The proof constructs a joinability witness: t →*_{normCost t} nf and
u →*_{normCost u} nf, giving JoinBudgetBound (normCost t + normCost u) t u. -/
theorem eqPathDist_le_normCost_sum {t u nf : Lam}
    (htnf : ReachableWithin (normCost t) t nf)
    (hunf : ReachableWithin (normCost u) u nf) :
    eqPathDist t u ≤ normCost t + normCost u :=
  eqPathDist_le_of_joinBudget ⟨nf, normCost t, normCost u, le_refl _, htnf, hunf⟩

/-! ## Context Nonexpansiveness -/

/-- Application on the left is nonexpansive: d(t₁ s, t₂ s) ≤ d(t₁, t₂).
When t₁ and t₂ are β-equivalent. -/
theorem eqPathDist_app_left_le (t₁ t₂ s : Lam) (hβ : BetaEq t₁ t₂) :
    eqPathDist (.app t₁ s) (.app t₂ s) ≤ eqPathDist t₁ t₂ :=
  eqPathDist_le_of_lift (fun _ h => h.appLeft s) hβ.toBetaEqIn

/-- Application on the right is nonexpansive: d(s t₁, s t₂) ≤ d(t₁, t₂).
When t₁ and t₂ are β-equivalent. -/
theorem eqPathDist_app_right_le (s t₁ t₂ : Lam) (hβ : BetaEq t₁ t₂) :
    eqPathDist (.app s t₁) (.app s t₂) ≤ eqPathDist t₁ t₂ :=
  eqPathDist_le_of_lift (fun _ h => h.appRight s) hβ.toBetaEqIn

/-
Lambda abstraction is nonexpansive: d(λx.t₁, λx.t₂) ≤ d(t₁, t₂).
-/
theorem eqPathDist_lam_le (x : ℕ) (t₁ t₂ : Lam) :
    eqPathDist (.lam x t₁) (.lam x t₂) ≤ eqPathDist t₁ t₂ := by
  refine' Nat.le_of_not_lt fun h => _;
  -- By definition of eqPathDist, there exists a k such that t₁ and t₂ are connected by a chain of k β-steps.
  obtain ⟨k, hk⟩ : ∃ k, k < eqPathDist (Lam.lam x t₁) (Lam.lam x t₂) ∧ BetaEqIn k t₁ t₂ := by
    exact ⟨ _, h, Nat.sInf_mem ( show { k | BetaEqIn k t₁ t₂ }.Nonempty from by
                                  exact BetaEq.toBetaEqIn ( show BetaEq t₁ t₂ from by
                                                              contrapose! h;
                                                              unfold eqPathDist;
                                                              rw [ Nat.sInf_eq_zero.mpr ];
                                                              · exact Nat.zero_le _;
                                                              · right;
                                                                ext k;
                                                                simp;
                                                                intro H;
                                                                have h_beta_eq : BetaEq (Lam.lam x t₁) (Lam.lam x t₂) := by
                                                                  grind +suggestions;
                                                                have h_beta_eq : BetaEq (Lam.app (Lam.lam x t₁) (Lam.var x)) (Lam.app (Lam.lam x t₂) (Lam.var x)) := by
                                                                  have h_beta_eq : ∀ {t u : Lam}, BetaEq t u → BetaEq (Lam.app t (Lam.var x)) (Lam.app u (Lam.var x)) := by
                                                                    intros t u h_beta_eq
                                                                    induction' h_beta_eq with t u h_beta_eq ih;
                                                                    · exact BetaEq.refl _;
                                                                    · exact BetaEq.step ( BetaStep.appLeft _ ih );
                                                                    · grind +suggestions;
                                                                    · exact BetaEq.trans ‹_› ‹_›;
                                                                  exact h_beta_eq ‹_›;
                                                                have h_beta_eq : BetaEq (t₁.subst x (Lam.var x)) (t₂.subst x (Lam.var x)) := by
                                                                  have h_beta_eq : BetaEq (Lam.app (Lam.lam x t₁) (Lam.var x)) (t₁.subst x (Lam.var x)) ∧ BetaEq (Lam.app (Lam.lam x t₂) (Lam.var x)) (t₂.subst x (Lam.var x)) := by
                                                                    exact ⟨ BetaEq.step ( BetaStep.beta x t₁ ( Lam.var x ) ), BetaEq.step ( BetaStep.beta x t₂ ( Lam.var x ) ) ⟩;
                                                                  exact BetaEq.trans ( BetaEq.symm h_beta_eq.1 ) ( BetaEq.trans ‹_› h_beta_eq.2 );
                                                                have h_beta_eq : ∀ t : Lam, t.subst x (Lam.var x) = t := by
                                                                  intro t; induction t <;> simp +decide [ *, Lam.subst ] ;
                                                                  exact fun h => h.symm;
                                                                grind +revert ) |> fun ⟨ k, hk ⟩ => ⟨ k, hk ⟩ ) ⟩;
  exact hk.1.not_ge ( Nat.sInf_le <| by simpa using BetaEqIn.lamBody x hk.2 )

/-! ## Computational Methods -/

/-- Compute all one-step β-reducts of a term. -/
def Lam.betaReducts : Lam → List Lam
  | .var _ => []
  | .app (.lam x body) arg =>
    [body.subst x arg] ++
    (body.betaReducts.map (fun b' => .app (.lam x b') arg)) ++
    (arg.betaReducts.map (fun a' => .app (.lam x body) a'))
  | .app t u =>
    (t.betaReducts.map (fun t' => .app t' u)) ++
    (u.betaReducts.map (fun u' => .app t u'))
  | .lam x body =>
    body.betaReducts.map (fun b' => .lam x b')

/-- Check if a term is in β-normal form. -/
def Lam.isNormalForm : Lam → Bool
  | .var _ => true
  | .app (.lam _ _) _ => false
  | .app t u => t.isNormalForm && u.isNormalForm
  | .lam _ body => body.isNormalForm

/-- Bounded normalization cost (leftmost strategy). -/
def computeNormCostAux (fuel : ℕ) (t : Lam) : Option ℕ :=
  if t.isNormalForm then some 0
  else match fuel with
    | 0 => none
    | fuel + 1 =>
      match t.betaReducts.head? with
      | none => some 0
      | some r =>
        match computeNormCostAux fuel r with
        | some n => some (n + 1)
        | none => none

instance : BEq Lam where
  beq := fun t u => decide (t = u)

/-- Example terms. -/
def idComb : Lam := .lam 0 (.var 0)
def idId : Lam := .app idComb idComb

#eval computeNormCostAux 10 idComb      -- some 0
#eval computeNormCostAux 10 idId        -- some 1
#eval Lam.isNormalForm idComb           -- true
#eval Lam.isNormalForm idId