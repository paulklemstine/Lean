import Logic.PosetTheory.TemporalGLSyntax

/-!
# Temporal Gödel–Löb logic: filtration and an explicit finite-model bound

This file proves the **small model property** for the temporal Gödel–Löb calculus TGL
of `TemporalGLSyntax.lean` over the catalog's frame class `TemporalGL.TempFrame`:

> if a formula `A` fails somewhere in *some* temporal GL model, then it already fails in
> a temporal GL model with at most `2 ^ (2 * subformulaCount A)` worlds.

The construction is a **filtration** through the subformulas of `A`, but a naive
filtration will not do: the quotient relation must simultaneously

* stay transitive (`TempFrame.R_trans`),
* stay **converse well-founded** (`TempFrame.R_wf`) — the Löb condition,
* keep the temporal order a preorder (`T_refl`, `T_trans`),
* and preserve the *interaction* condition `TempFrame.compat`
  (`T w w' → R w' v → R w v`), which is what validates the axiom `◻A ⟹ ◼◻A`.

The relation `filtR` below is the Segerberg-style GL filtration (successors must
*strictly increase* the set of realised boxes, which yields converse well-foundedness
from a counting argument), and `filtT` is its temporal companion, strengthened by a
`◻`-clause precisely so that `compat` survives filtration.  The strengthening is sound
because `compat` in the original model already forces `◻`-formulas to persist along `T`.

## Main results

* `filtR_measure_lt` — every `filtR`-step strictly increases the number of realised
  boxed subformulas; this is the combinatorial heart of converse well-foundedness.
* `filtFrame` — the filtered frame is a genuine `TemporalGL.TempFrame`.
* `truth_lemma` — the filtration lemma: on realised worlds the filtered model agrees
  with the original model on every subformula of `A`.
* `bounded_countermodel` — **main theorem**: any countermodel can be shrunk to one with
  at most `2 ^ subformulaCount A` (hence at most `2 ^ (2 * subformulaCount A)`) worlds.
* `finite_model_property_of_completeness` — the conjectured finite model property with
  the explicit bound `2 ^ (2 * subformulaCount A)`, for every non-derivable `A`, given
  weak completeness of TGL.
* `decidable_validity_reduces_to_bounded_check` — validity is equivalent to validity on
  models of size at most `2 ^ (2 * subformulaCount A)`, which is the statement that
  makes "exhaustive bounded model search" a correct decision procedure.
-/

namespace TemporalGLDeep

open TemporalGL

/-! ## 1. The filtration relations

Both relations are defined on arbitrary finite sets of formulas; `Cl` will always be
`subformulas A`. -/

/-- The filtered accessibility relation.  `filtR Cl S S'` holds when every boxed formula
of `Cl` realised at `S` is, together with its argument, realised at `S'`, **and** at
least one boxed formula of `Cl` is realised at `S'` but not at `S`.  The second clause
is what makes the filtered relation converse well-founded. -/
def filtR (Cl : Finset TForm) (S S' : Finset TForm) : Prop :=
  (∀ B, (◻B) ∈ Cl → (◻B) ∈ S → (B ∈ S' ∧ (◻B) ∈ S')) ∧
  (∃ B, (◻B) ∈ Cl ∧ (◻B) ∈ S' ∧ (◻B) ∉ S)

/-- The filtered temporal relation.  Besides the usual clause for `◼`, it demands that
boxed formulas persist; this extra clause is what makes `TempFrame.compat` survive
filtration, and it is satisfied by the original model precisely because of `compat`. -/
def filtT (Cl : Finset TForm) (S S' : Finset TForm) : Prop :=
  (∀ B, (◼B) ∈ Cl → (◼B) ∈ S → (B ∈ S' ∧ (◼B) ∈ S')) ∧
  (∀ B, (◻B) ∈ Cl → (◻B) ∈ S → (◻B) ∈ S')

theorem filtR_trans (Cl : Finset TForm) {S₁ S₂ S₃ : Finset TForm}
    (h₁ : filtR Cl S₁ S₂) (h₂ : filtR Cl S₂ S₃) : filtR Cl S₁ S₃ := by
  refine ⟨fun B hB hS => ?_, ?_⟩
  · exact h₂.1 B hB (h₁.1 B hB hS).2
  · obtain ⟨B, hBCl, hBS₂, hBS₁⟩ := h₁.2
    exact ⟨B, hBCl, (h₂.1 B hBCl hBS₂).2, hBS₁⟩

theorem filtT_trans (Cl : Finset TForm) {S₁ S₂ S₃ : Finset TForm}
    (h₁ : filtT Cl S₁ S₂) (h₂ : filtT Cl S₂ S₃) : filtT Cl S₁ S₃ :=
  ⟨fun B hB hS => h₂.1 B hB (h₁.1 B hB hS).2,
   fun B hB hS => h₂.2 B hB (h₁.2 B hB hS)⟩

/-- **The interaction condition survives filtration.**  This is the reason for the
second clause of `filtT`. -/
theorem filtT_filtR_compat (Cl : Finset TForm) {S S₁ S₂ : Finset TForm}
    (hT : filtT Cl S S₁) (hR : filtR Cl S₁ S₂) : filtR Cl S S₂ := by
  refine ⟨fun B hB hS => hR.1 B hB (hT.2 B hB hS), ?_⟩
  obtain ⟨B, hBCl, hBS₂, hBS₁⟩ := hR.2
  exact ⟨B, hBCl, hBS₂, fun hBS => hBS₁ (hT.2 B hBCl hBS)⟩

/-! ## 2. The counting measure and converse well-foundedness -/

/-- The boxed formulas occurring in `Cl`. -/
def boxCl (Cl : Finset TForm) : Finset TForm := Cl.filter (fun C => C.isBox)

/-- The number of boxed formulas of `Cl` realised at `S`. -/
def boxCount (Cl S : Finset TForm) : ℕ := ((boxCl Cl).filter (fun C => C ∈ S)).card

theorem boxCount_le (Cl S : Finset TForm) : boxCount Cl S ≤ (boxCl Cl).card :=
  Finset.card_filter_le _ _

theorem mem_boxCl {Cl : Finset TForm} {C : TForm} (h : C ∈ boxCl Cl) :
    ∃ B, C = ◻B ∧ (◻B) ∈ Cl := by
  simp only [boxCl, Finset.mem_filter] at h
  obtain ⟨hCl, hbox⟩ := h
  cases C with
  | box B => exact ⟨B, rfl, hCl⟩
  | atom p => simp [TForm.isBox] at hbox
  | bot => simp [TForm.isBox] at hbox
  | imp B C => simp [TForm.isBox] at hbox
  | glob B => simp [TForm.isBox] at hbox

/-- **The combinatorial heart of the construction**: a `filtR`-step strictly increases
the number of realised boxed subformulas.  Since that number is bounded by `|boxCl Cl|`,
the filtered relation is converse well-founded, i.e. the filtered frame validates Löb. -/
theorem filtR_measure_lt (Cl : Finset TForm) {S S' : Finset TForm} (h : filtR Cl S S') :
    boxCount Cl S < boxCount Cl S' := by
  have hsub : (boxCl Cl).filter (fun C => C ∈ S) ⊆ (boxCl Cl).filter (fun C => C ∈ S') := by
    intro C hC
    simp only [Finset.mem_filter] at hC ⊢
    obtain ⟨hCbox, hCS⟩ := hC
    obtain ⟨B, rfl, hBCl⟩ := mem_boxCl hCbox
    exact ⟨hCbox, (h.1 B hBCl hCS).2⟩
  obtain ⟨B, hBCl, hBS', hBS⟩ := h.2
  have hmemBox : (◻B) ∈ boxCl Cl := by
    simp only [boxCl, Finset.mem_filter]
    exact ⟨hBCl, by simp [TForm.isBox]⟩
  refine Finset.card_lt_card ((Finset.ssubset_iff_of_subset hsub).2 ⟨◻B, ?_, ?_⟩)
  · simp only [Finset.mem_filter]; exact ⟨hmemBox, hBS'⟩
  · simp only [Finset.mem_filter]; tauto

/-- Converse well-foundedness of any relation pulled back from `filtR`, by the counting
measure.  This is what makes a filtered/canonical frame validate Löb. -/
theorem filtR_wf (Cl : Finset TForm) {α : Type} (f : α → Finset TForm) :
    WellFounded (fun a b : α => filtR Cl (f b) (f a)) := by
  have key : ∀ a b : α, filtR Cl (f b) (f a) →
      (boxCl Cl).card - boxCount Cl (f a) < (boxCl Cl).card - boxCount Cl (f b) := by
    intro a b h
    have h1 := filtR_measure_lt Cl h
    have h2 := boxCount_le Cl (f a)
    omega
  exact Subrelation.wf (fun {a b} h => key a b h)
    (InvImage.wf (fun a : α => (boxCl Cl).card - boxCount Cl (f a)) Nat.lt_wfRel.wf)

/-! ## 3. The filtered model -/

variable (M : TempModel) (A : TForm)

/-- The subformula-theory of a world: the set of subformulas of `A` true at `u`. -/
noncomputable def theta (u : M.F.W) : Finset TForm :=
  @Finset.filter _ (fun B => M.sat u B) (Classical.decPred _) (subformulas A)

theorem mem_theta {u : M.F.W} {B : TForm} :
    B ∈ theta M A u ↔ B ∈ subformulas A ∧ M.sat u B := by
  simp only [theta, Finset.mem_filter]

theorem theta_subset (u : M.F.W) : theta M A u ⊆ subformulas A := by
  intro B hB; exact (mem_theta M A).1 hB |>.1

/-- The worlds of the filtered model: the *realised* subformula-theories. -/
noncomputable def Wset : Finset (Finset TForm) :=
  @Finset.filter _ (fun S => ∃ u : M.F.W, theta M A u = S) (Classical.decPred _)
    (subformulas A).powerset

theorem mem_Wset {S : Finset TForm} :
    S ∈ Wset M A ↔ S ⊆ subformulas A ∧ ∃ u : M.F.W, theta M A u = S := by
  simp only [Wset, Finset.mem_filter, Finset.mem_powerset]

/-- The world type of the filtered model. -/
def FWorld : Type := {S : Finset TForm // S ∈ Wset M A}

noncomputable instance : Fintype (FWorld M A) := FinsetCoe.fintype _

instance : DecidableEq (FWorld M A) := fun _ _ => decidable_of_iff _ Subtype.ext_iff.symm

/-- The filtered world attached to an original world. -/
noncomputable def thetaW (u : M.F.W) : FWorld M A :=
  ⟨theta M A u, (mem_Wset M A).2 ⟨theta_subset M A u, ⟨u, rfl⟩⟩⟩

theorem exists_rep (S : FWorld M A) : ∃ u : M.F.W, thetaW M A u = S := by
  obtain ⟨-, u, hu⟩ := (mem_Wset M A).1 S.2
  exact ⟨u, Subtype.ext hu⟩

/-- The filtered frame is a genuine temporal Gödel–Löb frame. -/
noncomputable def filtFrame : TempFrame where
  W := FWorld M A
  R := fun S S' => filtR (subformulas A) S.1 S'.1
  T := fun S S' => filtT (subformulas A) S.1 S'.1
  R_trans := fun _ _ _ h₁ h₂ => filtR_trans _ h₁ h₂
  R_wf := filtR_wf (subformulas A) (fun S : FWorld M A => S.1)
  T_refl := by
    intro S
    obtain ⟨u, rfl⟩ := exists_rep M A S
    refine ⟨fun B hB hS => ⟨?_, hS⟩, fun _ _ hS => hS⟩
    have := (mem_theta M A).1 hS
    exact (mem_theta M A).2 ⟨mem_subformulas_glob hB, this.2 u (M.F.T_refl u)⟩
  T_trans := fun _ _ _ h₁ h₂ => filtT_trans _ h₁ h₂
  compat := fun hT hR => filtT_filtR_compat _ hT hR

/-- The filtered valuation: an atom holds at a theory iff it belongs to it. -/
def filtVal : ℕ → (filtFrame M A).W → Prop := fun p S => (TForm.atom p) ∈ S.1

/-- The filtered model. -/
noncomputable def filtModel : TempModel where
  F := filtFrame M A
  V := filtVal M A

/-! ## 4. The truth (filtration) lemma -/

/-- **Filtration lemma.**  On the realised worlds of the filtered model, satisfaction of
every subformula of `A` agrees with satisfaction in the original model.  The `◻` case
uses converse well-foundedness of the original frame to pick an `R`-maximal
counterexample world; the `◼` case uses reflexivity, transitivity and `compat`. -/
theorem truth_lemma :
    ∀ B, B ∈ subformulas A → ∀ u : M.F.W,
      (filtModel M A).sat (thetaW M A u) B ↔ M.sat u B := by
  intro B
  induction B with
  | atom p =>
      intro hmem u
      simp only [TempModel.sat, filtModel, Sat, filtVal, thetaW]
      rw [mem_theta]
      exact ⟨fun h => h.2, fun h => ⟨hmem, h⟩⟩
  | bot => intro _ u; exact Iff.rfl
  | imp B C ihB ihC =>
      intro hmem u
      have hB := ihB (mem_subformulas_imp_left hmem) u
      have hC := ihC (mem_subformulas_imp_right hmem) u
      simp only [TempModel.sat, Sat] at *
      exact ⟨fun h hb => hC.1 (h (hB.2 hb)), fun h hb => hC.2 (h (hB.1 hb))⟩
  | box B ih =>
      intro hmem u
      have hBmem : B ∈ subformulas A := mem_subformulas_box hmem
      constructor
      · intro hf
        by_contra hnot
        have hex : ∃ x, M.F.R u x ∧ ¬ M.sat x B := by
          by_contra hc
          push_neg at hc
          exact hnot (fun v hv => hc v hv)
        obtain ⟨m, hm, hmin⟩ :=
          M.F.R_wf.has_min {y | M.F.R u y ∧ ¬ M.sat y B} (by
            obtain ⟨x, hx⟩ := hex; exact ⟨x, hx⟩)
        have hmBox : M.sat m (◻B) := by
          intro y hy
          by_contra hyB
          exact hmin y ⟨M.F.R_trans hm.1 hy, hyB⟩ hy
        have hstep : filtR (subformulas A) (theta M A u) (theta M A m) := by
          constructor
          · intro D hD hDu
            have hDsat : M.sat u (◻D) := ((mem_theta M A).1 hDu).2
            refine ⟨(mem_theta M A).2 ⟨mem_subformulas_box hD, hDsat m hm.1⟩,
                    (mem_theta M A).2 ⟨hD, fun y hy => hDsat y (M.F.R_trans hm.1 hy)⟩⟩
          · refine ⟨B, hmem, (mem_theta M A).2 ⟨hmem, hmBox⟩, ?_⟩
            intro hc
            exact hnot ((mem_theta M A).1 hc).2
        have := hf (thetaW M A m) hstep
        exact hm.2 ((ih hBmem m).1 this)
      · intro hu S' hRS'
        obtain ⟨v, rfl⟩ := exists_rep M A S'
        refine (ih hBmem v).2 ?_
        have hBu : (◻B) ∈ theta M A u := (mem_theta M A).2 ⟨hmem, hu⟩
        exact ((mem_theta M A).1 (hRS'.1 B hmem hBu).1).2
  | glob B ih =>
      intro hmem u
      have hBmem : B ∈ subformulas A := mem_subformulas_glob hmem
      constructor
      · intro hf
        by_contra hnot
        have hex : ∃ x, M.F.T u x ∧ ¬ M.sat x B := by
          by_contra hc
          push_neg at hc
          exact hnot (fun v hv => hc v hv)
        obtain ⟨x, hx, hxB⟩ := hex
        have hstep : filtT (subformulas A) (theta M A u) (theta M A x) := by
          constructor
          · intro D hD hDu
            have hDsat : M.sat u (◼D) := ((mem_theta M A).1 hDu).2
            exact ⟨(mem_theta M A).2 ⟨mem_subformulas_glob hD, hDsat x hx⟩,
                   (mem_theta M A).2 ⟨hD, fun y hy => hDsat y (M.F.T_trans hx hy)⟩⟩
          · intro D hD hDu
            have hDsat : M.sat u (◻D) := ((mem_theta M A).1 hDu).2
            exact (mem_theta M A).2 ⟨hD, fun y hy => hDsat y (M.F.compat hx hy)⟩
        exact hxB ((ih hBmem x).1 (hf (thetaW M A x) hstep))
      · intro hu S' hTS'
        obtain ⟨v, rfl⟩ := exists_rep M A S'
        refine (ih hBmem v).2 ?_
        have hBu : (◼B) ∈ theta M A u := (mem_theta M A).2 ⟨hmem, hu⟩
        exact ((mem_theta M A).1 (hTS'.1 B hmem hBu).1).2

/-! ## 5. The size bound -/

theorem card_filtWorld_le : Nat.card (FWorld M A) ≤ 2 ^ subformulaCount A := by
  have h1 : Nat.card (FWorld M A) = (Wset M A).card := by
    rw [Nat.card_eq_fintype_card]
    exact Fintype.card_coe _
  have h2 : (Wset M A).card ≤ ((subformulas A).powerset).card :=
    Finset.card_le_card (fun S hS => Finset.mem_powerset.2 ((mem_Wset M A).1 hS).1)
  rw [h1]
  refine h2.trans ?_
  rw [Finset.card_powerset]
  exact le_of_eq rfl

/-! ## 6. Main theorems -/

/-- **Small model property with an explicit bound.**  If `A` fails at some world of some
temporal GL model, then `A` fails at some world of a temporal GL model with at most
`2 ^ subformulaCount A` worlds — a fortiori at most `2 ^ (2 * subformulaCount A)`. -/
theorem bounded_countermodel {A : TForm} {M : TempModel} {w : M.F.W} (h : ¬ M.sat w A) :
    ∃ (N : TempModel) (v : N.F.W), Finite N.F.W ∧
      Nat.card N.F.W ≤ 2 ^ (2 * subformulaCount A) ∧ ¬ N.sat v A := by
  refine ⟨filtModel M A, thetaW M A w, ?_, ?_, ?_⟩
  · show Finite (FWorld M A)
    infer_instance
  · refine (card_filtWorld_le M A).trans (Nat.pow_le_pow_right (by norm_num) ?_)
    omega
  · intro hsat
    exact h ((truth_lemma M A A (self_mem_subformulas A) w).1 hsat)

/-- The sharper form of the bound actually obtained: `2 ^ subformulaCount A`. -/
theorem bounded_countermodel_sharp {A : TForm} {M : TempModel} {w : M.F.W}
    (h : ¬ M.sat w A) :
    ∃ (N : TempModel) (v : N.F.W), Finite N.F.W ∧
      Nat.card N.F.W ≤ 2 ^ subformulaCount A ∧ ¬ N.sat v A := by
  refine ⟨filtModel M A, thetaW M A w, ?_, card_filtWorld_le M A, ?_⟩
  · show Finite (FWorld M A)
    infer_instance
  · exact fun hsat => h ((truth_lemma M A A (self_mem_subformulas A) w).1 hsat)

/-- **Validity is decided by bounded models.**  A formula is valid on all temporal GL
frames iff it is valid on all such frames with at most `2 ^ (2 * subformulaCount A)`
worlds.  This is exactly the statement that exhaustive bounded model search is a
*correct* (complete) semantic test — the search space is finite for each `A`. -/
theorem valid_iff_valid_on_bounded (A : TForm) :
    Valid A ↔ ∀ (N : TempModel) (v : N.F.W), Finite N.F.W →
      Nat.card N.F.W ≤ 2 ^ (2 * subformulaCount A) → N.sat v A := by
  constructor
  · intro h N v _ _; exact h N v
  · intro h M w
    by_contra hc
    obtain ⟨N, v, hfin, hcard, hns⟩ := bounded_countermodel hc
    exact hns (h N v hfin hcard)

/-- Soundness plus filtration: a **derivable** formula holds in every model, and a
formula failing in some model is not derivable *and* fails in a small model. -/
theorem not_derivable_and_small_countermodel {A : TForm} {M : TempModel} {w : M.F.W}
    (h : ¬ M.sat w A) :
    ¬ Derivable A ∧ ∃ (N : TempModel) (v : N.F.W), Finite N.F.W ∧
      Nat.card N.F.W ≤ 2 ^ (2 * subformulaCount A) ∧ ¬ N.sat v A :=
  ⟨fun hd => h (soundness hd M w), bounded_countermodel h⟩

/-- **The conjectured finite model property, modulo weak completeness.**

Given weak completeness of the calculus TGL for the frame class `TemporalGL.TempFrame`,
every non-derivable formula `A` has a `TempFrame` countermodel with at most
`2 ^ (2 * subformulaCount A)` worlds.  The completeness hypothesis is the *only*
missing ingredient: everything model-theoretic is supplied by the filtration above. -/
theorem finite_model_property_of_completeness
    (completeness : ∀ B : TForm, Valid B → Derivable B) (A : TForm) (hA : ¬ Derivable A) :
    ∃ (N : TempModel) (v : N.F.W), Finite N.F.W ∧
      Nat.card N.F.W ≤ 2 ^ (2 * subformulaCount A) ∧ ¬ N.sat v A := by
  have hnv : ¬ Valid A := fun hv => hA (completeness A hv)
  simp only [Valid, not_forall] at hnv
  obtain ⟨M, w, hw⟩ := hnv
  exact bounded_countermodel hw

/-- Contrapositive packaging: *if* there is no small countermodel, the formula is valid.
This direction needs no completeness assumption, and is what justifies reading a
successful exhaustive bounded search as a proof of validity. -/
theorem valid_of_no_small_countermodel (A : TForm)
    (h : ¬ ∃ (N : TempModel) (v : N.F.W), Finite N.F.W ∧
      Nat.card N.F.W ≤ 2 ^ (2 * subformulaCount A) ∧ ¬ N.sat v A) : Valid A := by
  intro M w
  by_contra hc
  exact h (bounded_countermodel hc)

end TemporalGLDeep