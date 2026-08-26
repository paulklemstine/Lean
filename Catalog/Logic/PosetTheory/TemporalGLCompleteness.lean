import Logic.PosetTheory.TemporalGLDeduction
import Logic.PosetTheory.TemporalGLFiniteModel

/-!
# Temporal Gödel–Löb logic: the finite canonical model and completeness

This file closes the last gap in the finite-model conjecture for the calculus TGL.
Rather than building an (infinite) canonical model — which for Gödel–Löb logic is *not*
a legal frame, since converse well-foundedness fails — we build the **finite canonical
model over the subformula closure of a single formula**, using exactly the relations
`filtR` / `filtT` from `TemporalGLFiniteModel.lean`.

Worlds are the consistent "decided subsets" `t ⊆ Cl` of a subformula-closed finite set
`Cl`: the list `gammaList Cl t` asserts every member of `t` and the negation of every
member of `Cl \ t`, and `t` is a world when that list is TGL-consistent.

The two existence lemmas are the mathematical core:

* `exists_box_succ` — if `◻B ∉ t`, there is a world `s` with `filtR Cl t s` and `B ∉ s`.
  Its proof runs the classical **Löb argument**: were the candidate hypothesis list
  inconsistent, boxing it and applying Löb's axiom would force `◻B ∈ t`.
* `exists_glob_succ` — the temporal analogue, whose proof uses `◼`-necessitation, the
  `4` axiom for `◼`, and the interaction axiom `◻A ⟹ ◼◻A`.

Combining these with the truth lemma `can_truth_lemma` yields

* `completeness` — every valid formula is derivable, and
* `finite_model_property` — **the conjecture**: every non-derivable `A` has a
  `TemporalGL.TempFrame` countermodel with at most `2 ^ (2 * subformulaCount A)` worlds.
-/

namespace TemporalGLDeep

open TemporalGL

/-! ## 1. Subformula-closed sets -/

/-- A finite set of formulas closed under immediate subformulas. -/
structure Closed (Cl : Finset TForm) : Prop where
  /-- Closure under the two immediate subformulas of an implication. -/
  imp : ∀ {B C : TForm}, (B ⟹ C) ∈ Cl → B ∈ Cl ∧ C ∈ Cl
  /-- Closure under un-boxing. -/
  box : ∀ {B : TForm}, (◻B) ∈ Cl → B ∈ Cl
  /-- Closure under removing a temporal box. -/
  glob : ∀ {B : TForm}, (◼B) ∈ Cl → B ∈ Cl

theorem closed_subformulas (A : TForm) : Closed (subformulas A) where
  imp h := ⟨mem_subformulas_imp_left h, mem_subformulas_imp_right h⟩
  box h := mem_subformulas_box h
  glob h := mem_subformulas_glob h

/-- Remove one `◻`. -/
def TForm.unbox : TForm → TForm
  | .box C => C
  | X => X

/-- Remove one `◼`. -/
def TForm.unglob : TForm → TForm
  | .glob C => C
  | X => X

/-! ## 2. Decided subsets and consistency -/

/-- The hypothesis list determined by `t ⊆ Cl`: each formula of `Cl` is asserted if it
lies in `t` and negated otherwise. -/
noncomputable def gammaList (Cl t : Finset TForm) : List TForm :=
  Cl.toList.map (fun B => if B ∈ t then B else B.neg)

theorem mem_gammaList_pos {Cl t : Finset TForm} {B : TForm} (h₁ : B ∈ Cl) (h₂ : B ∈ t) :
    B ∈ gammaList Cl t := by
  refine List.mem_map.2 ⟨B, Finset.mem_toList.2 h₁, ?_⟩
  simp [h₂]

theorem mem_gammaList_neg {Cl t : Finset TForm} {B : TForm} (h₁ : B ∈ Cl) (h₂ : B ∉ t) :
    B.neg ∈ gammaList Cl t := by
  refine List.mem_map.2 ⟨B, Finset.mem_toList.2 h₁, ?_⟩
  simp [h₂]

/-- `t` is a *consistent decided subset* of `Cl`. -/
def Cons (Cl t : Finset TForm) : Prop := ListCons (gammaList Cl t)

/-- Anything derivable from a consistent decided subset and lying in `Cl` belongs to it. -/
theorem mem_of_Der {Cl t : Finset TForm} (hc : Cons Cl t) {B : TForm} (hB : B ∈ Cl)
    (h : Der (gammaList Cl t) B) : B ∈ t := by
  by_contra hn
  exact hc (Der_mp (Der_of_mem (mem_gammaList_neg hB hn)) h)

/-- The worlds of the finite canonical model over `Cl`. -/
noncomputable def CanW (Cl : Finset TForm) : Finset (Finset TForm) :=
  @Finset.filter _ (fun t => Cons Cl t) (Classical.decPred _) Cl.powerset

theorem mem_CanW {Cl t : Finset TForm} : t ∈ CanW Cl ↔ t ⊆ Cl ∧ Cons Cl t := by
  simp only [CanW, Finset.mem_filter, Finset.mem_powerset]

/-- **Lindenbaum for a finite closure.**  Any consistent hypothesis list is realised by
a world of the canonical model, which agrees with the list on all its members. -/
theorem exists_world (Cl : Finset TForm) (Γ : List TForm) (hΓ : ListCons Γ) :
    ∃ t, t ∈ CanW Cl ∧ (∀ x ∈ Γ, x ∈ Cl → x ∈ t) ∧ (∀ B : TForm, B.neg ∈ Γ → B ∉ t) := by
  obtain ⟨Γ', hsub, hdec, hcons⟩ := extend_list Cl.toList Γ hΓ
  classical
  refine ⟨Cl.filter (fun B => B ∈ Γ'), ?_, ?_, ?_⟩
  · refine mem_CanW.2 ⟨Finset.filter_subset _ _, ?_⟩
    intro hbad
    refine hcons (Der_mono (fun x hx => ?_) hbad)
    obtain ⟨B, hB, hBx⟩ := List.mem_map.1 hx
    rw [Finset.mem_toList] at hB
    by_cases hmem : B ∈ Cl.filter (fun B => B ∈ Γ')
    · rw [if_pos hmem] at hBx
      subst hBx
      exact (Finset.mem_filter.1 hmem).2
    · rw [if_neg hmem] at hBx
      subst hBx
      have hBΓ : B ∉ Γ' := fun hc => hmem (Finset.mem_filter.2 ⟨hB, hc⟩)
      rcases hdec B (Finset.mem_toList.2 hB) with h | h
      · exact absurd h hBΓ
      · exact h
  · intro x hx hxCl
    exact Finset.mem_filter.2 ⟨hxCl, hsub x hx⟩
  · intro B hB hmem
    have h1 : B ∈ Γ' := (Finset.mem_filter.1 hmem).2
    exact not_mem_of_neg_mem hcons h1 (hsub _ hB)

/-! ## 3. Lists of boxed / temporally boxed members of a world -/

/-- The `◻`-formulas of `Cl` belonging to `t`. -/
noncomputable def boxList (Cl t : Finset TForm) : List TForm :=
  Cl.toList.filter (fun C => C.isBox && decide (C ∈ t))

/-- The `◼`-formulas of `Cl` belonging to `t`. -/
noncomputable def globList (Cl t : Finset TForm) : List TForm :=
  Cl.toList.filter (fun C => C.isGlob && decide (C ∈ t))

theorem mem_boxList {Cl t : Finset TForm} {x : TForm} (h : x ∈ boxList Cl t) :
    ∃ D, x = ◻D ∧ (◻D) ∈ Cl ∧ (◻D) ∈ t := by
  rw [boxList, List.mem_filter] at h
  obtain ⟨hx, hp⟩ := h
  rw [Finset.mem_toList] at hx
  simp only [Bool.and_eq_true, decide_eq_true_eq] at hp
  cases x with
  | box D => exact ⟨D, rfl, hx, hp.2⟩
  | atom p => simp [TForm.isBox] at hp
  | bot => simp [TForm.isBox] at hp
  | imp B C => simp [TForm.isBox] at hp
  | glob B => simp [TForm.isBox] at hp

theorem mem_boxList_of {Cl t : Finset TForm} {D : TForm} (h₁ : (◻D) ∈ Cl) (h₂ : (◻D) ∈ t) :
    (◻D) ∈ boxList Cl t := by
  rw [boxList, List.mem_filter]
  exact ⟨Finset.mem_toList.2 h₁, by simp [TForm.isBox, h₂]⟩

theorem mem_globList {Cl t : Finset TForm} {x : TForm} (h : x ∈ globList Cl t) :
    ∃ D, x = ◼D ∧ (◼D) ∈ Cl ∧ (◼D) ∈ t := by
  rw [globList, List.mem_filter] at h
  obtain ⟨hx, hp⟩ := h
  rw [Finset.mem_toList] at hx
  simp only [Bool.and_eq_true, decide_eq_true_eq] at hp
  cases x with
  | glob D => exact ⟨D, rfl, hx, hp.2⟩
  | atom p => simp [TForm.isGlob] at hp
  | bot => simp [TForm.isGlob] at hp
  | imp B C => simp [TForm.isGlob] at hp
  | box B => simp [TForm.isGlob] at hp

theorem mem_globList_of {Cl t : Finset TForm} {D : TForm} (h₁ : (◼D) ∈ Cl) (h₂ : (◼D) ∈ t) :
    (◼D) ∈ globList Cl t := by
  rw [globList, List.mem_filter]
  exact ⟨Finset.mem_toList.2 h₁, by simp [TForm.isGlob, h₂]⟩

/-! ## 4. The two existence lemmas -/

/-- **Existence lemma for `◻` (the Löb argument).**  If `◻B` is not in the consistent
world `t`, there is a world `s` accessible from `t` in the filtration order in which `B`
fails.  Consistency of the candidate hypothesis list is proved by contradiction: boxing
it and applying Löb's axiom would derive `◻B` inside `t`. -/
theorem exists_box_succ {Cl : Finset TForm} (hCl : Closed Cl) {t : Finset TForm}
    (hcons : Cons Cl t) {B : TForm} (hB : (◻B) ∈ Cl) (hnot : (◻B) ∉ t) :
    ∃ s, s ∈ CanW Cl ∧ filtR Cl t s ∧ B ∉ s := by
  classical
  set D0 : List TForm := boxList Cl t with hD0
  set D1 : List TForm := D0.map TForm.unbox ++ D0 with hD1
  set D2 : List TForm := D1 ++ [◻B, B.neg] with hD2
  have hcons2 : ListCons D2 := by
    intro hbad
    have h1 : Der D1 ((◻B) ⟹ B) := by
      refine Der_of_Der_taut (fun v hall hv => ?_) hbad
      show evalProp v (◻B) → evalProp v B
      intro hboxB
      by_contra hnb
      refine hall (fun x hx => ?_)
      rw [hD2] at hx
      rcases List.mem_append.1 hx with hx | hx
      · exact hv x hx
      · have hx' : x = ◻B ∨ x = B.neg := by simpa using hx
        rcases hx' with rfl | rfl
        · exact hboxB
        · exact hnb
    have h2 : Der (D1.map TForm.box) (◻((◻B) ⟹ B)) := Der_box h1
    have h3 : Der (D1.map TForm.box) (◻B) := Der_mp (Der_of_derivable Derivable.loeb) h2
    have h4 : ∀ x ∈ D1.map TForm.box, Der (gammaList Cl t) x := by
      intro x hx
      obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hx
      rw [hD1] at hy
      rcases List.mem_append.1 hy with hy | hy
      · obtain ⟨z, hz, rfl⟩ := List.mem_map.1 hy
        obtain ⟨E, rfl, hECl, hEt⟩ := mem_boxList hz
        exact Der_of_mem (mem_gammaList_pos hECl hEt)
      · obtain ⟨E, rfl, hECl, hEt⟩ := mem_boxList hy
        exact Der_mp (Der_of_derivable (derivable_four E))
          (Der_of_mem (mem_gammaList_pos hECl hEt))
    exact hnot (mem_of_Der hcons hB (Der_cut h4 h3))
  obtain ⟨s, hsW, hspos, hsneg⟩ := exists_world Cl D2 hcons2
  have hboxmem : ∀ {E : TForm}, (◻E) ∈ Cl → (◻E) ∈ t → (◻E) ∈ D2 ∧ E ∈ D2 := by
    intro E h1 h2
    constructor
    · rw [hD2]
      exact List.mem_append.2 (Or.inl (List.mem_append.2 (Or.inr (mem_boxList_of h1 h2))))
    · rw [hD2]
      exact List.mem_append.2 (Or.inl (List.mem_append.2 (Or.inl
        (List.mem_map.2 ⟨◻E, mem_boxList_of h1 h2, rfl⟩))))
  have hBmem : (◻B) ∈ D2 := by
    rw [hD2]; exact List.mem_append.2 (Or.inr (by simp))
  have hnegmem : B.neg ∈ D2 := by
    rw [hD2]; exact List.mem_append.2 (Or.inr (by simp))
  refine ⟨s, hsW, ⟨?_, ?_⟩, hsneg B hnegmem⟩
  · intro E hECl hEt
    obtain ⟨h1, h2⟩ := hboxmem hECl hEt
    exact ⟨hspos E h2 (hCl.box hECl), hspos _ h1 hECl⟩
  · exact ⟨B, hB, hspos (◻B) hBmem hB, hnot⟩

/-- **Existence lemma for `◼`.**  If `◼B` is not in the consistent world `t`, there is a
world `s` with `filtT Cl t s` in which `B` fails.  The proof uses `◼`-necessitation, the
`4` axiom for `◼`, and the interaction axiom `◻A ⟹ ◼◻A` (which is exactly what forces
the `◻`-clause of `filtT`). -/
theorem exists_glob_succ {Cl : Finset TForm} (hCl : Closed Cl) {t : Finset TForm}
    (hcons : Cons Cl t) {B : TForm} (hB : (◼B) ∈ Cl) (hnot : (◼B) ∉ t) :
    ∃ s, s ∈ CanW Cl ∧ filtT Cl t s ∧ B ∉ s := by
  classical
  set G0 : List TForm := globList Cl t with hG0
  set B0 : List TForm := boxList Cl t with hB0
  set D1 : List TForm := G0.map TForm.unglob ++ G0 ++ B0 with hD1
  set D2 : List TForm := D1 ++ [B.neg] with hD2
  have hcons2 : ListCons D2 := by
    intro hbad
    have h1 : Der D1 B := by
      refine Der_of_Der_taut (fun v hall hv => ?_) hbad
      by_contra hnb
      refine hall (fun x hx => ?_)
      rw [hD2] at hx
      rcases List.mem_append.1 hx with hx | hx
      · exact hv x hx
      · have hx' : x = B.neg := by simpa using hx
        subst hx'
        exact hnb
    have h2 : Der (D1.map TForm.glob) (◼B) := Der_glob h1
    have h3 : ∀ x ∈ D1.map TForm.glob, Der (gammaList Cl t) x := by
      intro x hx
      obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hx
      rw [hD1] at hy
      rcases List.mem_append.1 hy with hy | hy
      · rcases List.mem_append.1 hy with hy | hy
        · obtain ⟨z, hz, rfl⟩ := List.mem_map.1 hy
          obtain ⟨E, rfl, hECl, hEt⟩ := mem_globList hz
          exact Der_of_mem (mem_gammaList_pos hECl hEt)
        · obtain ⟨E, rfl, hECl, hEt⟩ := mem_globList hy
          exact Der_mp (Der_of_derivable Derivable.glob4)
            (Der_of_mem (mem_gammaList_pos hECl hEt))
      · obtain ⟨E, rfl, hECl, hEt⟩ := mem_boxList hy
        exact Der_mp (Der_of_derivable Derivable.compatAx)
          (Der_of_mem (mem_gammaList_pos hECl hEt))
    exact hnot (mem_of_Der hcons hB (Der_cut h3 h2))
  obtain ⟨s, hsW, hspos, hsneg⟩ := exists_world Cl D2 hcons2
  have hglobmem : ∀ {E : TForm}, (◼E) ∈ Cl → (◼E) ∈ t → (◼E) ∈ D2 ∧ E ∈ D2 := by
    intro E h1 h2
    constructor
    · rw [hD2]
      exact List.mem_append.2 (Or.inl (List.mem_append.2 (Or.inl
        (List.mem_append.2 (Or.inr (mem_globList_of h1 h2))))))
    · rw [hD2]
      exact List.mem_append.2 (Or.inl (List.mem_append.2 (Or.inl
        (List.mem_append.2 (Or.inl (List.mem_map.2 ⟨◼E, mem_globList_of h1 h2, rfl⟩))))))
  have hboxmem : ∀ {E : TForm}, (◻E) ∈ Cl → (◻E) ∈ t → (◻E) ∈ D2 := by
    intro E h1 h2
    rw [hD2]
    exact List.mem_append.2 (Or.inl (List.mem_append.2 (Or.inr (mem_boxList_of h1 h2))))
  have hnegmem : B.neg ∈ D2 := by
    rw [hD2]; exact List.mem_append.2 (Or.inr (by simp))
  refine ⟨s, hsW, ⟨?_, ?_⟩, hsneg B hnegmem⟩
  · intro E hECl hEt
    obtain ⟨h1, h2⟩ := hglobmem hECl hEt
    exact ⟨hspos E h2 (hCl.glob hECl), hspos _ h1 hECl⟩
  · intro E hECl hEt
    exact hspos _ (hboxmem hECl hEt) hECl

/-! ## 5. The finite canonical model -/

/-- The worlds of the canonical model over `Cl`. -/
def CanWorld (Cl : Finset TForm) : Type := {t : Finset TForm // t ∈ CanW Cl}

noncomputable instance (Cl : Finset TForm) : Fintype (CanWorld Cl) := FinsetCoe.fintype _

/-- **The finite canonical frame.**  Accessibility and the temporal order are the
filtration relations of `TemporalGLFiniteModel.lean`; Löb's condition is the counting
argument `filtR_wf`, reflexivity of time comes from the axiom `◼A ⟹ A`, and the
interaction condition is `filtT_filtR_compat`. -/
noncomputable def canFrame (Cl : Finset TForm) (hCl : Closed Cl) : TempFrame where
  W := CanWorld Cl
  R := fun t s => filtR Cl t.1 s.1
  T := fun t s => filtT Cl t.1 s.1
  R_trans := fun _ _ _ h₁ h₂ => filtR_trans _ h₁ h₂
  R_wf := filtR_wf Cl (fun t : CanWorld Cl => t.1)
  T_refl := by
    intro t
    refine ⟨fun E hECl hEt => ⟨?_, hEt⟩, fun _ _ h => h⟩
    exact mem_of_Der (mem_CanW.1 t.2).2 (hCl.glob hECl)
      (Der_mp (Der_of_derivable Derivable.globT) (Der_of_mem (mem_gammaList_pos hECl hEt)))
  T_trans := fun _ _ _ h₁ h₂ => filtT_trans _ h₁ h₂
  compat := fun hT hR => filtT_filtR_compat _ hT hR

/-- The canonical model: an atom holds at a world iff it belongs to it. -/
noncomputable def canModel (Cl : Finset TForm) (hCl : Closed Cl) : TempModel where
  F := canFrame Cl hCl
  V := fun p t => (TForm.atom p) ∈ t.1

/-- **Truth lemma for the finite canonical model.**  For every formula of the closure,
truth at a world coincides with membership in that world. -/
theorem can_truth_lemma {Cl : Finset TForm} (hCl : Closed Cl) :
    ∀ B, B ∈ Cl → ∀ t : (canModel Cl hCl).F.W, ((canModel Cl hCl).sat t B ↔ B ∈ t.1) := by
  intro B
  induction B with
  | atom p => intro _ _; exact Iff.rfl
  | bot =>
      intro hmem t
      refine ⟨fun h => h.elim, fun h => ?_⟩
      exact absurd (Der_of_mem (mem_gammaList_pos hmem h)) (mem_CanW.1 t.2).2
  | imp B C ihB ihC =>
      intro hmem t
      obtain ⟨hBCl, hCCl⟩ := hCl.imp hmem
      have hcons := (mem_CanW.1 t.2).2
      have hB := ihB hBCl t
      have hC := ihC hCCl t
      constructor
      · intro h
        have h' : B ∈ t.1 → C ∈ t.1 := fun hb => hC.1 (h (hB.2 hb))
        refine mem_of_Der hcons hmem ?_
        by_cases hbt : B ∈ t.1
        · exact Der_of_Der_taut (fun _ h1 hv _ => h1 hv)
            (Der_of_mem (mem_gammaList_pos hCCl (h' hbt)))
        · exact Der_of_Der_taut (fun _ h1 hv hb => (h1 hv hb).elim)
            (Der_of_mem (mem_gammaList_neg hBCl hbt))
      · intro h hb
        refine hC.2 (mem_of_Der hcons hCCl ?_)
        exact Der_mp (Der_of_mem (mem_gammaList_pos hmem h))
          (Der_of_mem (mem_gammaList_pos hBCl (hB.1 hb)))
  | box B ih =>
      intro hmem t
      have hBCl := hCl.box hmem
      have hcons := (mem_CanW.1 t.2).2
      constructor
      · intro hsat
        by_contra hn
        obtain ⟨s, hsW, hRts, hBs⟩ := exists_box_succ hCl hcons hmem hn
        exact hBs ((ih hBCl ⟨s, hsW⟩).1 (hsat ⟨s, hsW⟩ hRts))
      · intro hin s hRs
        exact (ih hBCl s).2 (hRs.1 B hmem hin).1
  | glob B ih =>
      intro hmem t
      have hBCl := hCl.glob hmem
      have hcons := (mem_CanW.1 t.2).2
      constructor
      · intro hsat
        by_contra hn
        obtain ⟨s, hsW, hTts, hBs⟩ := exists_glob_succ hCl hcons hmem hn
        exact hBs ((ih hBCl ⟨s, hsW⟩).1 (hsat ⟨s, hsW⟩ hTts))
      · intro hin s hTs
        exact (ih hBCl s).2 (hTs.1 B hmem hin).1

theorem card_canWorld_le (Cl : Finset TForm) :
    Nat.card (CanWorld Cl) ≤ 2 ^ Cl.card := by
  have h1 : Nat.card (CanWorld Cl) = (CanW Cl).card := by
    rw [Nat.card_eq_fintype_card]; exact Fintype.card_coe _
  have h2 : (CanW Cl).card ≤ (Cl.powerset).card :=
    Finset.card_le_card (fun t ht => Finset.mem_powerset.2 (mem_CanW.1 ht).1)
  rw [h1, ← Finset.card_powerset]
  exact h2

/-! ## 6. Completeness and the finite model property -/

/-- **Weak completeness of TGL.**  Every formula valid on all temporal Gödel–Löb frames
of the catalog is derivable in the Hilbert calculus. -/
theorem completeness {A : TForm} (h : Valid A) : Derivable A := by
  by_contra hA
  have hcons : ListCons [A.neg] := by
    intro hbad
    have ht : Derivable ((A.neg ⟹ TForm.bot) ⟹ A) :=
      Derivable.taut (by
        intro v hv
        by_contra hn
        exact hv (fun ha => hn ha))
    exact hA (Derivable.mp ht hbad)
  obtain ⟨t, htW, _, hneg⟩ := exists_world (subformulas A) [A.neg] hcons
  have hnA : A ∉ t := hneg A (by simp)
  exact hnA ((can_truth_lemma (closed_subformulas A) A (self_mem_subformulas A)
    ⟨t, htW⟩).1 (h (canModel _ (closed_subformulas A)) ⟨t, htW⟩))

/-- **Soundness and completeness**: derivability in TGL is exactly validity on the
catalog's temporal Gödel–Löb frames. -/
theorem derivable_iff_valid (A : TForm) : Derivable A ↔ Valid A :=
  ⟨soundness, completeness⟩

/-- **The conjecture, sharp form.**  Every non-derivable formula `A` has a
`TemporalGL.TempFrame` countermodel with at most `2 ^ subformulaCount A` worlds. -/
theorem finite_model_property_sharp (A : TForm) (hA : ¬ Derivable A) :
    ∃ (N : TempModel) (v : N.F.W), Finite N.F.W ∧
      Nat.card N.F.W ≤ 2 ^ subformulaCount A ∧ ¬ N.sat v A := by
  have hcons : ListCons [A.neg] := by
    intro hbad
    have ht : Derivable ((A.neg ⟹ TForm.bot) ⟹ A) :=
      Derivable.taut (by
        intro v hv
        by_contra hn
        exact hv (fun ha => hn ha))
    exact hA (Derivable.mp ht hbad)
  obtain ⟨t, htW, _, hneg⟩ := exists_world (subformulas A) [A.neg] hcons
  refine ⟨canModel _ (closed_subformulas A), ⟨t, htW⟩, ?_, ?_, ?_⟩
  · show Finite (CanWorld (subformulas A))
    infer_instance
  · exact card_canWorld_le (subformulas A)
  · intro hsat
    exact hneg A (by simp)
      ((can_truth_lemma (closed_subformulas A) A (self_mem_subformulas A) ⟨t, htW⟩).1 hsat)

/-- **The conjecture as stated.**  Every non-derivable formula `A` of the temporal
Gödel–Löb calculus has a `TemporalGL.TempFrame` countermodel with at most
`2 ^ (2 * subformulaCount A)` worlds. -/
theorem finite_model_property (A : TForm) (hA : ¬ Derivable A) :
    ∃ (N : TempModel) (v : N.F.W), Finite N.F.W ∧
      Nat.card N.F.W ≤ 2 ^ (2 * subformulaCount A) ∧ ¬ N.sat v A :=
  finite_model_property_of_completeness (fun _ hv => completeness hv) A hA

/-! ## 7. Consequences and non-degeneracy

The results above are only interesting if TGL really is a non-trivial logic in which the
two modalities interact but do not collapse.  This section records that. -/

/-- **Derivability is decided by a bounded semantic check.**  Combining soundness,
completeness and filtration: `A` is a theorem of TGL iff it holds in every temporal GL
model with at most `2 ^ (2 * subformulaCount A)` worlds.  This is the precise sense in
which "exhaustive bounded model search" is a correct decision procedure for TGL. -/
theorem derivable_iff_bounded_check (A : TForm) :
    Derivable A ↔ ∀ (N : TempModel) (v : N.F.W), Finite N.F.W →
      Nat.card N.F.W ≤ 2 ^ (2 * subformulaCount A) → N.sat v A :=
  (derivable_iff_valid A).trans (valid_iff_valid_on_bounded A)

/-- **Löb's rule** is admissible: from `⊢ ◻A ⟹ A` infer `⊢ A`. -/
theorem loeb_rule {A : TForm} (h : Derivable ((◻A) ⟹ A)) : Derivable A :=
  Derivable.mp h (Derivable.mp Derivable.loeb (Derivable.boxNec h))

/-- **Gödel's second incompleteness theorem, in the object language.**  The consistency
statement `◻⊥ ⟹ ⊥` (equivalently `¬◻⊥`) is *not* a theorem of TGL. -/
theorem not_derivable_own_consistency : ¬ Derivable ((◻TForm.bot) ⟹ TForm.bot) := by
  intro h
  exact soundness h falseModel () (fun v hv => hv.elim)

/-- The consistency statement therefore has a countermodel of the promised size. -/
theorem godel_two_small_countermodel :
    ∃ (N : TempModel) (v : N.F.W), Finite N.F.W ∧
      Nat.card N.F.W ≤ 2 ^ (2 * subformulaCount ((◻TForm.bot) ⟹ TForm.bot)) ∧
      ¬ N.sat v ((◻TForm.bot) ⟹ TForm.bot) :=
  finite_model_property _ not_derivable_own_consistency

/-- A temporal GL frame whose time order is trivial (only the present) but whose
accessibility relation is not: `true` sees `false`, and nothing else. -/
def rigidTimeFrame : TempFrame where
  W := Bool
  R := fun a b => a = true ∧ b = false
  T := fun a b => a = b
  R_trans := by intro a b c hab hbc; revert a b c; decide
  R_wf := by
    have : Std.Irrefl (fun a b : Bool => b = true ∧ a = false) :=
      ⟨by intro a; revert a; decide⟩
    have : IsTrans Bool (fun a b : Bool => b = true ∧ a = false) :=
      ⟨by intro a b c; revert a b c; decide⟩
    exact Finite.wellFounded_of_trans_of_irrefl _
  T_refl := fun _ => rfl
  T_trans := by intro a b c hab hbc; exact hab.trans hbc
  compat := by intro w w' v h hR; cases h; exact hR

/-- The model on `rigidTimeFrame` in which the atom holds exactly at `true`. -/
def rigidModel : TempModel where
  F := rigidTimeFrame
  V := fun _ b => b = true

/-- **The temporal box does not imply the provability box.**  Even though provability
persists through time (`◻A ⟹ ◼◻A` is an axiom), the two modalities are independent. -/
theorem not_derivable_glob_imp_box :
    ¬ Derivable ((◼(TForm.atom 0)) ⟹ ◻(TForm.atom 0)) := by
  intro h
  have := soundness h rigidModel true (fun v hv => by
    show v = true
    exact hv.symm)
  exact absurd (this false ⟨rfl, rfl⟩) (by simp [rigidModel, Sat])

/-- **The provability box does not imply the temporal box** either. -/
theorem not_derivable_box_imp_glob :
    ¬ Derivable ((◻(TForm.atom 0)) ⟹ ◼(TForm.atom 0)) := by
  intro h
  exact soundness h falseModel () (fun v hv => hv.elim) () trivial

/-! ## 8. Machine-checked data points for the bound

The bound `2 ^ (2 * subformulaCount A)` is far from tight on concrete formulas; the two
theorems below record explicitly verified minimal countermodels, which are what a
bounded model search would actually return. -/

/-- The consistency statement `◻⊥ ⟹ ⊥` is already refuted in a **one-world** model,
against a permitted bound of `2 ^ (2 * 3) = 64`. -/
theorem consistency_countermodel_one_world :
    ¬ falseModel.sat () ((◻TForm.bot) ⟹ TForm.bot) ∧ Nat.card falseModel.F.W = 1 := by
  refine ⟨fun h => h (fun v hv => hv.elim), ?_⟩
  show Nat.card Unit = 1
  simp

/-- `◼p ⟹ ◻p` is refuted in a **two-world** model, against a permitted bound of
`2 ^ (2 * 4) = 256`. -/
theorem glob_box_countermodel_two_worlds :
    ¬ rigidModel.sat true ((◼(TForm.atom 0)) ⟹ ◻(TForm.atom 0)) ∧
      Nat.card rigidModel.F.W = 2 := by
  constructor
  · intro h
    have h1 : rigidModel.sat true (◼(TForm.atom 0)) := by
      intro v hv
      show v = true
      exact hv.symm
    exact absurd (h h1 false ⟨rfl, rfl⟩) (by simp [rigidModel, Sat])
  · show Nat.card Bool = 2
    simp

end TemporalGLDeep