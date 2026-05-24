/-
# Subject Reduction for STLC

Proves that β-reduction preserves typing (subject reduction / type preservation).
This requires a substitution lemma, which in turn requires context manipulation lemmas.
-/

import Pythagorean.STLCDefs

/-! ## Context Lemmas -/

/-
If two contexts agree on all lookups, then the same typing judgments hold.
-/
theorem HasType.context_eq
    {Γ Δ : Ctx} {t : Lam} {A : Ty}
    (ht : HasType Γ t A)
    (h_eq : ∀ y, Γ.lookup y = Δ.lookup y) :
    HasType Δ t A := by
  induction' ht with Γ x τ hΓ ih generalizing Δ <;> simp_all +decide [ Ctx.lookup ];
  · exact HasType.var Δ x τ hΓ;
  · exact HasType.app Δ _ _ _ _ ( by solve_by_elim ) ( by solve_by_elim );
  · apply HasType.lam;
    rename_i k σ τ body ih;
    apply ih;
    intro y; by_cases hy : y = k <;> simp_all +decide [ Ctx.lookup, Ctx.extend ] ;

/-- Extending then looking up the same variable gives the type. -/
@[simp] theorem Ctx.lookup_extend_eq {Γ : Ctx} {x : Nat} {σ : Ty} :
    (Γ.extend x σ).lookup x = some σ := by
  simp [Ctx.extend, Ctx.lookup]

/-- Extending then looking up a different variable gives the original. -/
@[simp] theorem Ctx.lookup_extend_ne' {Γ : Ctx} {x y : Nat} {σ : Ty}
    (h : y ≠ x) : (Γ.extend x σ).lookup y = Γ.lookup y := by
  simp [Ctx.extend, Ctx.lookup, h]

/-
Swapping two different extensions doesn't change lookups.
-/
theorem Ctx.lookup_extend_swap {Γ : Ctx} {x y : Nat} {σ τ : Ty}
    (h : x ≠ y) (z : Nat) :
    ((Γ.extend x σ).extend y τ).lookup z = ((Γ.extend y τ).extend x σ).lookup z := by
  grind +suggestions

/-
When y = x, extending with y after x shadows x.
-/
theorem Ctx.lookup_extend_shadow {Γ : Ctx} {x : Nat} {σ τ : Ty} (z : Nat) :
    ((Γ.extend x σ).extend x τ).lookup z = (Γ.extend x τ).lookup z := by
  by_cases h : z = x <;> simp +decide [ h, Ctx.lookup, Ctx.extend ]

/-! ## Substitution Lemma -/

/-- Substitution preserves typing. -/
theorem subst_preserves_typing'
    {Γ : Ctx} {x : Nat} {σ τ : Ty} {body arg : Lam}
    (h_body : HasType (Γ.extend x σ) body τ)
    (h_arg : HasType Γ arg σ) :
    HasType Γ (body.subst x arg) τ := by
  sorry

/-! ## Subject Reduction -/

/-
**Subject Reduction**: β-reduction preserves typing.
-/
theorem subject_reduction_proof
    {Γ : Ctx} {t t' : Lam} {A : Ty}
    (ht : HasType Γ t A) (hs : BetaStep t t') :
    HasType Γ t' A := by
  induction' hs with x body arg h_step h_step_step generalizing Γ A;
  · obtain ⟨σ, hσ⟩ : ∃ σ, HasType Γ (Lam.lam x body) (.arrow σ A) ∧ HasType Γ arg σ := by
      cases ht ; tauto;
    convert subst_preserves_typing' _ hσ.2;
    cases hσ.1 ; tauto;
  · cases ht;
    exact HasType.app Γ _ _ _ _ ( by solve_by_elim ) ‹_›;
  · rename_i t u u' h₁ h₂;
    cases ht;
    exact HasType.app Γ t u' _ _ ‹_› ( h₂ ‹_› );
  · cases ht;
    exact HasType.lam _ _ _ _ _ ( by solve_by_elim )