import Mathlib
import Logic.LambdaCalculus.Syntax

/-!
# Parallel β-Reduction and Church–Rosser Theorem

This module formalizes parallel β-reduction and proves the diamond property,
from which confluence (Church–Rosser) of β-reduction follows.

## Main Results

* `parBeta_diamond` — Diamond property for parallel β-reduction
* `beta_confluent` — Church–Rosser theorem: β-reduction is confluent
* `normal_form_unique` — Normal forms are unique up to reachability
-/

namespace LambdaCalculus

/-- Parallel β-reduction: reduces zero or more redexes simultaneously. -/
inductive ParBeta : Lam → Lam → Prop where
  | pvar (n : ℕ) : ParBeta (.var n) (.var n)
  | papp {t t' u u' : Lam} : ParBeta t t' → ParBeta u u' →
      ParBeta (.app t u) (.app t' u')
  | plam {t t' : Lam} : ParBeta t t' → ParBeta (.lam t) (.lam t')
  | pbeta {t t' u u' : Lam} : ParBeta t t' → ParBeta u u' →
      ParBeta (.app (.lam t) u) (Lam.subst0 u' t')

/-- ParBeta is reflexive -/
theorem ParBeta.refl : ∀ t : Lam, ParBeta t t
  | .var n => .pvar n
  | .app t u => .papp (ParBeta.refl t) (ParBeta.refl u)
  | .lam t => .plam (ParBeta.refl t)

/-- One-step β is included in parallel β -/
theorem beta_sub_parBeta {t u : Lam} (h : Beta t u) : ParBeta t u := by
  induction h with
  | redex t u => exact .pbeta (.refl t) (.refl u)
  | app_left u _ ih => exact .papp ih (.refl u)
  | app_right t _ ih => exact .papp (.refl t) ih
  | lam_body _ ih => exact .plam ih

/-- Reflexive-transitive closure of Beta applied under app_left -/
theorem Beta.rtc_app_left {t t' : Lam} (u : Lam)
    (h : Relation.ReflTransGen Beta t t') :
    Relation.ReflTransGen Beta (.app t u) (.app t' u) := by
  induction h with
  | refl => exact .refl
  | tail _ hab ih => exact ih.tail (.app_left u hab)

/-- Reflexive-transitive closure of Beta applied under app_right -/
theorem Beta.rtc_app_right (t : Lam) {u u' : Lam}
    (h : Relation.ReflTransGen Beta u u') :
    Relation.ReflTransGen Beta (.app t u) (.app t u') := by
  induction h with
  | refl => exact .refl
  | tail _ hab ih => exact ih.tail (.app_right t hab)

/-- Reflexive-transitive closure of Beta applied under lam -/
theorem Beta.rtc_lam {t t' : Lam} (h : Relation.ReflTransGen Beta t t') :
    Relation.ReflTransGen Beta (.lam t) (.lam t') := by
  induction h with
  | refl => exact .refl
  | tail _ hab ih => exact ih.tail (.lam_body hab)

/-- Parallel β is included in the reflexive-transitive closure of one-step β -/
theorem parBeta_sub_beta_rtc {t u : Lam} (h : ParBeta t u) :
    Relation.ReflTransGen Beta t u := by
  induction h with
  | pvar => exact .refl
  | papp _ _ iht ihu =>
    exact (Beta.rtc_app_left _ iht).trans (Beta.rtc_app_right _ ihu)
  | plam _ ih => exact Beta.rtc_lam ih
  | pbeta _ _ iht ihu =>
    exact ((Beta.rtc_app_left _ (Beta.rtc_lam iht)).trans
      (Beta.rtc_app_right _ ihu)).tail (.redex _ _)

/-
============================================================
Substitution compatibility with parallel reduction
============================================================

Lifting preserves parallel reduction
-/
theorem parBeta_lift {t t' : Lam} (h : ParBeta t t') (d c : ℕ) :
    ParBeta (Lam.lift d c t) (Lam.lift d c t') := by
  induction h generalizing d c;
  · exact ParBeta.refl (Lam.lift d c (.var _));
  · exact ParBeta.papp ( by solve_by_elim ) ( by solve_by_elim );
  · exact ParBeta.plam ( by solve_by_elim );
  · rename_i h₁ h₂ h₃ h₄;
    convert ParBeta.pbeta ( h₃ d ( c + 1 ) ) ( h₄ d c ) using 1;
    exact Lam.lift_subst0_comm _ _ d c

/-- Key lemma: lift commutes with subst0 appropriately -/
theorem lift_subst0_comm (u t : Lam) (d c : ℕ) :
    Lam.lift d c (Lam.subst0 u t) =
    Lam.subst0 (Lam.lift d c u) (Lam.lift d (c + 1) t) :=
  Lam.lift_subst0_comm u t d c

/-
Key lemma: substitution at index k is compatible with parallel reduction
-/
theorem parBeta_substAt {t t' σ σ' : Lam} (ht : ParBeta t t')
    (hσ : ParBeta σ σ') (k : ℕ) :
    ParBeta (Lam.substAt σ k t) (Lam.substAt σ' k t') := by
  induction' ht with t t' ht ih generalizing k σ σ';
  · unfold Lam.substAt;
    split_ifs <;> [ exact ParBeta.pvar _; exact parBeta_lift hσ _ _; exact ParBeta.pvar _ ];
  · exact ParBeta.papp ( by solve_by_elim ) ( by solve_by_elim );
  · exact ParBeta.plam ( by solve_by_elim );
  · rename_i h₁ h₂ h₃ h₄;
    convert ParBeta.pbeta ( h₃ hσ ( k + 1 ) ) ( h₄ hσ k ) using 1;
    convert Lam.substAt_subst0 _ _ _ _ using 1

/-- Substitution at 0 is compatible with parallel reduction -/
theorem parBeta_subst0 {t t' u u' : Lam} (ht : ParBeta t t') (hu : ParBeta u u') :
    ParBeta (Lam.subst0 u t) (Lam.subst0 u' t') :=
  parBeta_substAt ht hu 0

-- ============================================================
-- Complete development and diamond property
-- ============================================================

/-- Complete development: contracts ALL β-redexes in one step. -/
def Lam.maxDev : Lam → Lam
  | .var n => .var n
  | .app (.lam t) u => Lam.subst0 u.maxDev t.maxDev
  | .app t u => .app t.maxDev u.maxDev
  | .lam t => .lam t.maxDev

/-
Every parallel reduct further parallel-reduces to the complete development.
-/
theorem parBeta_to_maxDev {t u : Lam} (h : ParBeta t u) :
    ParBeta u t.maxDev := by
  induction' h with t t' u u' ht hu ih1 ih2;
  · exact ParBeta.pvar _;
  · cases' t' with t' t' <;> simp_all +decide [ Lam.maxDev ];
    · apply ParBeta.papp <;> assumption;
    · exact ParBeta.papp ih2 ‹_›;
    · cases hu;
      convert ParBeta.pbeta _ _ using 1;
      · cases ih2 ; tauto;
      · assumption;
  · exact ParBeta.plam ‹_›;
  · apply_rules [ ParBeta.pbeta, parBeta_subst0 ]

/-- **Diamond property for parallel β-reduction**.

  For all lambda terms `t`, `u`, `v`: if `t ⇛ u` and `t ⇛ v`,
  then there exists `w` such that `u ⇛ w` and `v ⇛ w`. -/
theorem parBeta_diamond {t u v : Lam} (hu : ParBeta t u) (hv : ParBeta t v) :
    ∃ w, ParBeta u w ∧ ParBeta v w :=
  ⟨t.maxDev, parBeta_to_maxDev hu, parBeta_to_maxDev hv⟩

/-
============================================================
Strip lemma and confluence
============================================================

Strip lemma: one-step diamond extends to multi-step.
-/
theorem parBeta_strip {t u v : Lam} (hu : ParBeta t u)
    (hv : Relation.ReflTransGen ParBeta t v) :
    ∃ w, Relation.ReflTransGen ParBeta u w ∧ ParBeta v w := by
  induction' hv with x y hxy hy ih;
  · grind;
  · obtain ⟨ w, hw₁, hw₂ ⟩ := ih;
    obtain ⟨ z, hz₁, hz₂ ⟩ := parBeta_diamond hw₂ hy;
    exact ⟨ z, hw₁.tail hz₁, hz₂ ⟩

/-
Confluence of the reflexive-transitive closure of ParBeta
-/
theorem parBeta_rtc_confluent {t u v : Lam}
    (hu : Relation.ReflTransGen ParBeta t u)
    (hv : Relation.ReflTransGen ParBeta t v) :
    ∃ w, Relation.ReflTransGen ParBeta u w ∧
         Relation.ReflTransGen ParBeta v w := by
  induction hu;
  · exact ⟨ v, hv, by rfl ⟩;
  · rename_i b c hb hc ih;
    obtain ⟨ w, hw₁, hw₂ ⟩ := ih;
    obtain ⟨ x, hx₁, hx₂ ⟩ := parBeta_strip hc hw₁;
    exact ⟨ x, hx₁, hw₂.tail hx₂ ⟩

/-
**Church–Rosser theorem**: β-reduction is confluent.

  If `t →β* u` and `t →β* v`, then there exists `w` with `u →β* w` and `v →β* w`.
-/
theorem beta_confluent {t u v : Lam}
    (hu : Relation.ReflTransGen Beta t u) (hv : Relation.ReflTransGen Beta t v) :
    ∃ w, Relation.ReflTransGen Beta u w ∧ Relation.ReflTransGen Beta v w := by
  -- Apply the diamond property for ParBeta to get the required w.
  obtain ⟨w, hw⟩ : ∃ w, Relation.ReflTransGen ParBeta u w ∧ Relation.ReflTransGen ParBeta v w := by
    apply parBeta_rtc_confluent;
    exact hu.mono fun x y h => beta_sub_parBeta h;
    exact hv.mono fun x y h => beta_sub_parBeta h;
  -- Since ParBeta is a subset of Beta*, we can conclude that there exists a w such that u →β* w and v →β* w.
  have h_beta : ∀ {t u : Lam}, Relation.ReflTransGen ParBeta t u → Relation.ReflTransGen Beta t u := by
    intros t u h; induction h; aesop;
    exact Relation.ReflTransGen.trans ‹_› ( parBeta_sub_beta_rtc ‹_› );
  exact ⟨ w, h_beta hw.1, h_beta hw.2 ⟩

/-
If t is a normal form and t →β* u, then t = u
-/
theorem NormalForm.eq_of_rtc {t u : Lam} (hnf : NormalForm t)
    (h : Relation.ReflTransGen Beta t u) : t = u := by
  -- By definition of normal form, if t is a normal form and there's a reduction from t to u, then u must be equal to t.
  have h_eq : ∀ u, Relation.ReflTransGen Beta t u → u = t := by
    intros u hu;
    induction hu;
    · rfl;
    · exact False.elim <| hnf _ <| by subst_vars; assumption;
  exact Eq.symm ( h_eq u h )

/-
**Uniqueness of normal forms**: if two normal forms are reachable from the same
  term, they must be equal.
-/
theorem normal_form_unique {t u v : Lam}
    (hu : Relation.ReflTransGen Beta t u)
    (hv : Relation.ReflTransGen Beta t v)
    (nfu : NormalForm u)
    (nfv : NormalForm v) :
    u = v := by
  obtain ⟨ w, hw₁, hw₂ ⟩ := beta_confluent hu hv;
  -- Since u is a normal form, u = w by NormalForm.eq_of_rtc.
  have huw : u = w := by
    apply NormalForm.eq_of_rtc nfu hw₁;
  rw [ huw, NormalForm.eq_of_rtc nfv hw₂ ]

end LambdaCalculus