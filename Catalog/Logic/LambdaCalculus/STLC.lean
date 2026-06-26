import Logic.LambdaCalculus.Syntax

/-!
# The simply-typed λ-calculus (Curry-style) and subject reduction

We equip the de Bruijn terms of `Syntax.lean` with simple types and a typing
judgement `HasType Γ t T` over a context `Γ : List Ty` (index `0` is the most
recently bound variable, i.e. the head of the list).  The central results are
the structural **weakening** and **substitution** lemmas and, as their payoff,
**subject reduction** (type preservation) for β-reduction and its transitive
closure.

## Main results

* `HasType.weakening`        — inserting a fresh hypothesis preserves typing
  (matched to the de Bruijn shift `lift`).
* `HasType.subst_preserves`  — the substitution lemma (matched to `subst`).
* `HasType.subst0_preserves` — its β-contraction instance (matched to `subst0`).
* `HasType.preservation`     — types are preserved by a β-step.
* `HasType.preservation_star`— types are preserved by `BetaStar`.

-- !-- Lab Notes -- !--
Hypothesis (H3): For Curry-style STLC over de Bruijn terms, subject reduction
holds and reduces (via the β-case) to a single substitution lemma, which in turn
needs weakening.
Experiment: the load-bearing design choice is the *statement* of the
substitution lemma.  The naive "substituted term typed in the suffix `Γ₂`"
fails, because de Bruijn `subst` re-`lift`s the inserted term under every binder.
The correct invariant is that `s` is typed in `Γ₁ ++ Γ₂` (the context that
*remains* after deletion); then the `lam` case lines up exactly with
`weakening` at cut-point `0`.
Analysis: the var cases are pure `List.getElem?`/`List.length` arithmetic closed
by `omega` after the right `split_ifs`.  Critique: the lemma is not vacuous —
`HasType.lam`/`HasType.app` exhibit genuinely typeable open and closed terms,
and β-reduction really can fire (the β-case of `preservation` is non-trivial).
-- !-- End Lab Notes -- !--
-/

namespace LambdaCalculus

open Lam

/-- Simple types: one base type and function types. -/
inductive Ty : Type where
  | base : Ty
  | arrow : Ty → Ty → Ty
deriving DecidableEq, Repr

/-- The Curry-style typing judgement over a de Bruijn context. -/
inductive HasType : List Ty → Lam → Ty → Prop
  | var {Γ : List Ty} {n : ℕ} {T : Ty} : Γ[n]? = some T → HasType Γ (var n) T
  | lam {Γ : List Ty} {b : Lam} {A B : Ty} :
      HasType (A :: Γ) b B → HasType Γ (lam b) (Ty.arrow A B)
  | app {Γ : List Ty} {f a : Lam} {A B : Ty} :
      HasType Γ f (Ty.arrow A B) → HasType Γ a A → HasType Γ (app f a) B

namespace HasType

/-
**Weakening.**  Inserting a fresh hypothesis `A` at cut-point `|Γ₁|`
preserves typing, with the term shifted by `lift |Γ₁|`.
-/
theorem weakening {Γ₁ Γ₂ : List Ty} {t : Lam} {T : Ty} (A : Ty)
    (h : HasType (Γ₁ ++ Γ₂) t T) :
    HasType (Γ₁ ++ A :: Γ₂) (lift Γ₁.length t) T := by
      induction' t with t ih generalizing T Γ₁ Γ₂ A;
      · convert HasType.var ?_;
        rotate_left;
        exact if t < Γ₁.length then t else t + 1;
        · cases h;
          grind +splitImp;
        · unfold lift; aesop;
      · cases h;
        constructor;
        grind +qlia;
      · cases h;
        exact HasType.app ( by aesop ) ( by aesop )

/-- Front-weakening: the `|Γ₁| = 0` instance of `weakening`. -/
theorem weaken0 {Γ : List Ty} {s : Lam} {A B : Ty} (h : HasType Γ s B) :
    HasType (A :: Γ) (lift 0 s) B := by
  have := weakening (Γ₁ := []) (Γ₂ := Γ) A h
  simpa using this

/-
**Substitution lemma.**  If `t` is typeable with a hypothesis `A` at
cut-point `|Γ₁|`, and `s : A` is typeable in the *remaining* context `Γ₁ ++ Γ₂`,
then `subst |Γ₁| s t` is typeable in `Γ₁ ++ Γ₂`.
-/
theorem subst_preserves {Γ₁ Γ₂ : List Ty} {t s : Lam} {A T : Ty}
    (h : HasType (Γ₁ ++ A :: Γ₂) t T) (hs : HasType (Γ₁ ++ Γ₂) s A) :
    HasType (Γ₁ ++ Γ₂) (subst Γ₁.length s t) T := by
      revert t s;
      intro t s;
      induction' t with t ih generalizing s Γ₁ T;
      · intro h₁ h₂;
        cases h₁;
        simp_all +decide [ List.getElem?_append ];
        split_ifs at * <;> simp_all +decide [ subst ];
        · rw [ if_neg ( by linarith ), if_neg ( by linarith ) ];
          convert HasType.var _;
          grind;
        · split_ifs <;> simp_all +decide [ List.getElem?_eq_some_iff ];
          · convert HasType.var _ using 1;
            grind;
          · omega;
      · rintro ⟨ B, C, h ⟩ hs;
        apply HasType.lam;
        convert ‹∀ {Γ₁ : List Ty} {T : Ty} {s : Lam}, HasType (Γ₁ ++ A :: Γ₂) ih T → HasType (Γ₁ ++ Γ₂) s A → HasType (Γ₁ ++ Γ₂) (subst Γ₁.length s ih) T› ( show HasType ( ( _ :: Γ₁ ) ++ A :: Γ₂ ) ih _ from by simpa [ List.cons_append ] using ‹HasType ( _ :: ( Γ₁ ++ A :: Γ₂ ) ) ih _› ) ( HasType.weaken0 hs ) using 1;
      · rename_i h₁ h₂;
        rintro ( h | h | h ) hs;
        exact HasType.app ( h₁ h hs ) ( h₂ ‹_› hs )

/-- β-contraction instance of the substitution lemma. -/
theorem subst0_preserves {Γ : List Ty} {t s : Lam} {A T : Ty}
    (ht : HasType (A :: Γ) t T) (hs : HasType Γ s A) :
    HasType Γ (subst0 s t) T := by
  have := subst_preserves (Γ₁ := []) (Γ₂ := Γ) (A := A) (by simpa using ht)
    (by simpa using hs)
  simpa [subst0] using this

/-
**Subject reduction** for a single β-step.
-/
theorem preservation {Γ : List Ty} {t u : Lam} {T : Ty}
    (h : HasType Γ t T) (hr : Beta t u) : HasType Γ u T := by
      induction hr generalizing Γ T;
      · cases h;
        rename_i h₁ h₂;
        convert subst0_preserves _ h₁;
        cases h₂ ; tauto;
      · cases h;
        exact HasType.app ( by solve_by_elim ) ( by assumption );
      · cases h;
        exact HasType.app ‹_› ( by solve_by_elim );
      · cases h;
        exact HasType.lam ( by solve_by_elim )

/-- **Subject reduction** for many β-steps. -/
theorem preservation_star {Γ : List Ty} {t u : Lam} {T : Ty}
    (h : HasType Γ t T) (hr : BetaStar t u) : HasType Γ u T := by
  induction hr with
  | refl => exact h
  | tail _ hstep ih => exact preservation ih hstep

end HasType

end LambdaCalculus