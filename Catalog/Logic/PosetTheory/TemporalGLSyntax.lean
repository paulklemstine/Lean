import Logic.PosetTheory.TemporalGL

/-!
# Temporal Gödel–Löb logic: syntax, Hilbert calculus, and soundness

`Catalog/Logic/PosetTheory/TemporalGL.lean` develops *temporal Gödel–Löb logic* (TGL)
in a **shallow** form: modal operators are combinators on predicates `W → Prop` over a
`TemporalGL.TempFrame`.  A shallow presentation cannot express a *finite model
property*, because there is no object-level notion of a formula, of its subformulas, or
of derivability.

This file supplies the missing **deep** layer:

* `TForm` — the object language: propositional atoms, `⊥`, `⟹`, the Gödel–Löb box `◻`
  and the temporal "always in the future" operator `◼`.
* `subformulas` / `subformulaCount` — the Fischer–Ladner style closure of a formula and
  its cardinality, the parameter of the finite-model bound.
* `TempModel` / `Sat` — Kripke semantics interpreting `TForm` on the catalog's
  `TemporalGL.TempFrame`, so that `Sat` for `◻`/`◼` is literally
  `TemporalGL.Box`/`TemporalGL.Glob`.
* `Derivable` — a Hilbert calculus **TGL**: all classical propositional tautologies,
  modus ponens, `K` and Löb for `◻`, `K`, `T` and `4` for `◼`, the *interaction axiom*
  `◻A ⟹ ◼◻A` matching `TempFrame.compat`, and the two necessitation rules.
* `soundness` — every theorem of TGL is valid on every temporal GL frame.  The `◻`-Löb
  case is discharged by the catalog theorem `TemporalGL.loeb_box_sound` and the
  interaction axiom by `TemporalGL.provability_persists`, so the calculus is exactly
  calibrated to the catalog's frame class.
* `not_derivable_bot`, `not_derivable_atom` — the calculus is consistent and does not
  prove everything (so the finite-model question is non-vacuous).
* `derivable_four` — a genuinely syntactic derivation: the `4` axiom `◻A ⟹ ◻◻A` is a
  *theorem* of TGL, derived from Löb (no transitivity axiom is assumed).

The filtration and the explicit `2 ^ (2 * subformulaCount A)` bound live in
`TemporalGLFiniteModel.lean`.
-/

namespace TemporalGLDeep

open TemporalGL

/-! ## 1. Object language -/

/-- Formulas of temporal Gödel–Löb logic. -/
inductive TForm where
  /-- A propositional atom. -/
  | atom : ℕ → TForm
  /-- Falsity. -/
  | bot : TForm
  /-- Implication. -/
  | imp : TForm → TForm → TForm
  /-- The Gödel–Löb provability box, interpreted along `TempFrame.R`. -/
  | box : TForm → TForm
  /-- The temporal "always in the future" operator, interpreted along `TempFrame.T`. -/
  | glob : TForm → TForm
  deriving DecidableEq, Repr

@[inherit_doc] scoped infixr:25 " ⟹ " => TForm.imp
@[inherit_doc] scoped prefix:80 "◻" => TForm.box
@[inherit_doc] scoped prefix:80 "◼" => TForm.glob

/-- Negation, as an abbreviation. -/
def TForm.neg (A : TForm) : TForm := A ⟹ TForm.bot

/-- Is the formula a `◻`? -/
def TForm.isBox : TForm → Bool
  | .box _ => true
  | _ => false

/-- Is the formula a `◼`? -/
def TForm.isGlob : TForm → Bool
  | .glob _ => true
  | _ => false

/-! ## 2. Subformulas -/

/-- The (finite) set of subformulas of a formula, including the formula itself. -/
def subformulas : TForm → Finset TForm
  | .atom p => {.atom p}
  | .bot => {.bot}
  | .imp B C => insert (.imp B C) (subformulas B ∪ subformulas C)
  | .box B => insert (.box B) (subformulas B)
  | .glob B => insert (.glob B) (subformulas B)

/-- The number of distinct subformulas of `A`.  This is the parameter appearing in the
finite-model bound `2 ^ (2 * subformulaCount A)`. -/
def subformulaCount (A : TForm) : ℕ := (subformulas A).card

/-- The syntactic size (number of nodes) of a formula. -/
def TForm.size : TForm → ℕ
  | .atom _ => 1
  | .bot => 1
  | .imp B C => B.size + C.size + 1
  | .box B => B.size + 1
  | .glob B => B.size + 1

@[simp] theorem self_mem_subformulas (A : TForm) : A ∈ subformulas A := by
  cases A <;> simp [subformulas]

/-- `subformulas` is closed under taking subformulas. -/
theorem subformulas_subset {A B : TForm} (h : B ∈ subformulas A) :
    subformulas B ⊆ subformulas A := by
  induction A with
  | atom p => simp [subformulas] at h; subst h; exact Finset.Subset.refl _
  | bot => simp [subformulas] at h; subst h; exact Finset.Subset.refl _
  | imp C D ihC ihD =>
      simp only [subformulas, Finset.mem_insert, Finset.mem_union] at h
      rcases h with h | h | h
      · subst h; exact Finset.Subset.refl _
      · exact (ihC h).trans (by intro x hx; simp [subformulas, Finset.mem_union]; tauto)
      · exact (ihD h).trans (by intro x hx; simp [subformulas, Finset.mem_union]; tauto)
  | box C ih =>
      simp only [subformulas, Finset.mem_insert] at h
      rcases h with h | h
      · subst h; exact Finset.Subset.refl _
      · exact (ih h).trans (by intro x hx; simp [subformulas]; tauto)
  | glob C ih =>
      simp only [subformulas, Finset.mem_insert] at h
      rcases h with h | h
      · subst h; exact Finset.Subset.refl _
      · exact (ih h).trans (by intro x hx; simp [subformulas]; tauto)

theorem mem_subformulas_imp_left {A B C : TForm} (h : (B ⟹ C) ∈ subformulas A) :
    B ∈ subformulas A :=
  subformulas_subset h (by simp [subformulas, Finset.mem_union, self_mem_subformulas])

theorem mem_subformulas_imp_right {A B C : TForm} (h : (B ⟹ C) ∈ subformulas A) :
    C ∈ subformulas A :=
  subformulas_subset h (by simp [subformulas, Finset.mem_union, self_mem_subformulas])

theorem mem_subformulas_box {A B : TForm} (h : (◻B) ∈ subformulas A) :
    B ∈ subformulas A :=
  subformulas_subset h (by simp [subformulas, self_mem_subformulas])

theorem mem_subformulas_glob {A B : TForm} (h : (◼B) ∈ subformulas A) :
    B ∈ subformulas A :=
  subformulas_subset h (by simp [subformulas, self_mem_subformulas])

/-- The number of distinct subformulas never exceeds the syntactic size, so the
finite-model bound below also holds with `size` in place of `subformulaCount`. -/
theorem subformulaCount_le_size (A : TForm) : subformulaCount A ≤ A.size := by
  induction A with
  | atom p => simp [subformulaCount, subformulas, TForm.size]
  | bot => simp [subformulaCount, subformulas, TForm.size]
  | imp B C ihB ihC =>
      have h := Finset.card_insert_le (TForm.imp B C) (subformulas B ∪ subformulas C)
      have h2 := Finset.card_union_le (subformulas B) (subformulas C)
      simp only [subformulaCount, subformulas, TForm.size] at *
      omega
  | box B ih =>
      have h := Finset.card_insert_le (TForm.box B) (subformulas B)
      simp only [subformulaCount, subformulas, TForm.size] at *
      omega
  | glob B ih =>
      have h := Finset.card_insert_le (TForm.glob B) (subformulas B)
      simp only [subformulaCount, subformulas, TForm.size] at *
      omega

theorem subformulaCount_pos (A : TForm) : 0 < subformulaCount A :=
  Finset.card_pos.2 ⟨A, self_mem_subformulas A⟩

/-! ## 3. Kripke semantics on the catalog's temporal GL frames -/

/-- A **temporal GL model**: a `TemporalGL.TempFrame` together with a valuation of the
propositional atoms. -/
structure TempModel where
  /-- The underlying temporal Gödel–Löb frame from the catalog. -/
  F : TempFrame
  /-- The valuation of propositional atoms. -/
  V : ℕ → F.W → Prop

/-- Satisfaction of a formula at a world. -/
def Sat (F : TempFrame) (V : ℕ → F.W → Prop) : TForm → F.W → Prop
  | .atom p, w => V p w
  | .bot, _ => False
  | .imp B C, w => Sat F V B w → Sat F V C w
  | .box B, w => ∀ v, F.R w v → Sat F V B v
  | .glob B, w => ∀ v, F.T w v → Sat F V B v

/-- `M ⊨ A` at world `w`. -/
def TempModel.sat (M : TempModel) (w : M.F.W) (A : TForm) : Prop := Sat M.F M.V A w

@[simp] theorem sat_atom (M : TempModel) (w : M.F.W) (p : ℕ) :
    M.sat w (.atom p) ↔ M.V p w := Iff.rfl

@[simp] theorem sat_bot (M : TempModel) (w : M.F.W) : ¬ M.sat w .bot := id

@[simp] theorem sat_imp (M : TempModel) (w : M.F.W) (B C : TForm) :
    M.sat w (B ⟹ C) ↔ (M.sat w B → M.sat w C) := Iff.rfl

@[simp] theorem sat_box (M : TempModel) (w : M.F.W) (B : TForm) :
    M.sat w (◻B) ↔ ∀ v, M.F.R w v → M.sat v B := Iff.rfl

@[simp] theorem sat_glob (M : TempModel) (w : M.F.W) (B : TForm) :
    M.sat w (◼B) ↔ ∀ v, M.F.T w v → M.sat v B := Iff.rfl

/-- Satisfaction of `◻B` is exactly the catalog's shallow `TemporalGL.Box`. -/
theorem sat_box_eq_Box (M : TempModel) (B : TForm) :
    (fun w => M.sat w (◻B)) = Box M.F.R (fun v => M.sat v B) := rfl

/-- Satisfaction of `◼B` is exactly the catalog's shallow `TemporalGL.Glob`. -/
theorem sat_glob_eq_Glob (M : TempModel) (B : TForm) :
    (fun w => M.sat w (◼B)) = Glob M.F.T (fun v => M.sat v B) := rfl

/-- Validity on the whole class of temporal GL frames. -/
def Valid (A : TForm) : Prop := ∀ (M : TempModel) (w : M.F.W), M.sat w A

/-! ## 4. Propositional tautologies of the object language -/

/-- Boolean-style evaluation of a formula treating atoms *and* every `◻`/`◼` formula as
an unanalysed propositional letter. -/
def evalProp (v : TForm → Prop) : TForm → Prop
  | .atom p => v (.atom p)
  | .bot => False
  | .imp B C => evalProp v B → evalProp v C
  | .box B => v (.box B)
  | .glob B => v (.glob B)

/-- `A` is a **classical propositional tautology** of the object language: it is true
under every assignment to atoms and to boxed/temporal formulas. -/
def Taut (A : TForm) : Prop := ∀ v : TForm → Prop, evalProp v A

theorem sat_eq_evalProp (M : TempModel) (w : M.F.W) (A : TForm) :
    M.sat w A ↔ evalProp (fun B => M.sat w B) A := by
  induction A with
  | atom p => rfl
  | bot => rfl
  | imp B C ihB ihC => simp only [evalProp, sat_imp, ihB, ihC]
  | box B => rfl
  | glob B => rfl

theorem taut_sound {A : TForm} (h : Taut A) : Valid A := by
  intro M w
  exact (sat_eq_evalProp M w A).2 (h _)

/-! ## 5. The Hilbert calculus TGL -/

/-- The Hilbert-style calculus **TGL** for temporal Gödel–Löb logic. -/
inductive Derivable : TForm → Prop
  /-- Every classical propositional tautology is an axiom. -/
  | taut {A : TForm} : Taut A → Derivable A
  /-- Modus ponens. -/
  | mp {A B : TForm} : Derivable (A ⟹ B) → Derivable A → Derivable B
  /-- Distribution axiom `K` for the provability box. -/
  | boxK {A B : TForm} : Derivable ((◻(A ⟹ B)) ⟹ ((◻A) ⟹ ◻B))
  /-- Löb's axiom. -/
  | loeb {A : TForm} : Derivable ((◻((◻A) ⟹ A)) ⟹ ◻A)
  /-- Distribution axiom `K` for the temporal box. -/
  | globK {A B : TForm} : Derivable ((◼(A ⟹ B)) ⟹ ((◼A) ⟹ ◼B))
  /-- Reflexivity of time. -/
  | globT {A : TForm} : Derivable ((◼A) ⟹ A)
  /-- Transitivity of time. -/
  | glob4 {A : TForm} : Derivable ((◼A) ⟹ ◼◼A)
  /-- The interaction axiom matching `TempFrame.compat`: provability persists in time. -/
  | compatAx {A : TForm} : Derivable ((◻A) ⟹ ◼◻A)
  /-- Necessitation for the provability box. -/
  | boxNec {A : TForm} : Derivable A → Derivable (◻A)
  /-- Necessitation for the temporal box. -/
  | globNec {A : TForm} : Derivable A → Derivable (◼A)

/-! ## 6. Soundness -/

/-- **Soundness of TGL.**  Every derivable formula is valid on every temporal GL frame
of the catalog.  Löb's axiom is discharged by `TemporalGL.loeb_box_sound` and the
interaction axiom by `TemporalGL.provability_persists`. -/
theorem soundness {A : TForm} (h : Derivable A) : Valid A := by
  induction h with
  | taut ht => exact taut_sound ht
  | mp _ _ ihAB ihA => intro M w; exact ihAB M w (ihA M w)
  | boxK => intro M w hK hA v hv; exact hK v hv (hA v hv)
  | @loeb A =>
      intro M w h
      exact loeb_box_sound M.F (fun v => M.sat v A) w h
  | globK => intro M w hK hA v hv; exact hK v hv (hA v hv)
  | globT => intro M w h; exact h w (M.F.T_refl w)
  | glob4 => intro M w h v hv u hu; exact h u (M.F.T_trans hv hu)
  | @compatAx A =>
      intro M w h
      exact provability_persists M.F (fun v => M.sat v A) w h
  | boxNec _ ih => intro M w v _; exact ih M v
  | globNec _ ih => intro M w v _; exact ih M v

/-! ## 7. Non-triviality: the calculus is consistent and incomplete-as-a-set -/

/-- A one-world temporal GL frame with the empty accessibility relation. -/
def pointFrame : TempFrame where
  W := Unit
  R := fun _ _ => False
  T := fun _ _ => True
  R_trans := by intro a b c h _; exact h.elim
  R_wf := by
    constructor
    intro a
    exact ⟨a, fun y h => h.elim⟩
  T_refl := fun _ => trivial
  T_trans := by intro a b c _ _; trivial
  compat := by intro w w' v _ h; exact h.elim

/-- The one-world model in which the atom `p` is false everywhere. -/
def falseModel : TempModel where
  F := pointFrame
  V := fun _ _ => False

/-- **TGL is consistent**: `⊥` is not derivable. -/
theorem not_derivable_bot : ¬ Derivable TForm.bot := by
  intro h
  exact soundness h falseModel ()

/-- **TGL is not trivial**: no propositional atom is derivable. -/
theorem not_derivable_atom (p : ℕ) : ¬ Derivable (.atom p) := by
  intro h
  exact soundness h falseModel ()

/-! ## 8. A syntactic derivation: the `4` axiom follows from Löb

No transitivity axiom is postulated in `Derivable`.  It is a classical fact about GL
that `◻A ⟹ ◻◻A` is nevertheless derivable from Löb's axiom; we carry the derivation
out in full, using the standard auxiliary formula `A ∧ ◻A`. -/

/-- Conjunction, encoded with `⟹` and `⊥`. -/
def TForm.and (A B : TForm) : TForm := (A ⟹ (B ⟹ TForm.bot)) ⟹ TForm.bot

/-- Chaining derivable implications. -/
theorem derivable_trans {A B C : TForm} (h₁ : Derivable (A ⟹ B)) (h₂ : Derivable (B ⟹ C)) :
    Derivable (A ⟹ C) :=
  Derivable.mp (Derivable.mp (Derivable.taut (by intro v hAB hBC hA; exact hBC (hAB hA))) h₁) h₂

/-- The box is monotone: a derivable implication may be boxed. -/
theorem derivable_box_mono {A B : TForm} (h : Derivable (A ⟹ B)) :
    Derivable ((◻A) ⟹ ◻B) :=
  Derivable.mp Derivable.boxK (Derivable.boxNec h)

/-- The temporal box is monotone. -/
theorem derivable_glob_mono {A B : TForm} (h : Derivable (A ⟹ B)) :
    Derivable ((◼A) ⟹ ◼B) :=
  Derivable.mp Derivable.globK (Derivable.globNec h)

/-- **The `4` axiom is a theorem of TGL.**  Only Löb's axiom, `K`, necessitation and
propositional logic are used; transitivity of `R` is *not* assumed syntactically. -/
theorem derivable_four (A : TForm) : Derivable ((◻A) ⟹ ◻◻A) := by
  set C : TForm := TForm.and A (◻A) with hC
  -- `⊢ C ⟹ ◻A` and `⊢ C ⟹ A` are tautologies.
  have t1 : Derivable (C ⟹ ◻A) := Derivable.taut (by
    intro v; simp only [hC, TForm.and, evalProp]; tauto)
  have t2 : Derivable (C ⟹ A) := Derivable.taut (by
    intro v; simp only [hC, TForm.and, evalProp]; tauto)
  -- Box them.
  have b1 : Derivable ((◻C) ⟹ ◻◻A) := derivable_box_mono t1
  have b2 : Derivable ((◻C) ⟹ ◻A) := derivable_box_mono t2
  -- From `b2`, propositionally: `⊢ A ⟹ (◻C ⟹ C)`.
  have t4 : Derivable (A ⟹ ((◻C) ⟹ C)) :=
    Derivable.mp (Derivable.taut (by
      intro v; simp only [hC, TForm.and, evalProp]; tauto)) b2
  -- Box and apply Löb.
  have b3 : Derivable ((◻A) ⟹ ◻((◻C) ⟹ C)) := derivable_box_mono t4
  have b4 : Derivable ((◻A) ⟹ ◻C) := derivable_trans b3 Derivable.loeb
  exact derivable_trans b4 b1

/-- The `4` axiom for the temporal box, derived from `glob4`. -/
theorem derivable_glob_four (A : TForm) : Derivable ((◼A) ⟹ ◼◼A) := Derivable.glob4

end TemporalGLDeep