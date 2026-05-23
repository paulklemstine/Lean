/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Hennessy–Milner Completeness for Image-Finite LTS

This file proves the classical Hennessy–Milner theorem: for image-finite
labeled transition systems, HM-equivalence coincides with bisimilarity.

The proof constructs finite distinguishing conjunctions from the finitely
many successors of each state, assembling them into modal separator
formulas that force a contradiction with HM-equivalence.

## Main Results

* `satisfies_listConj_iff` — Semantics of finite conjunction
* `exists_distinguishing_formula` — Extraction of one-sided distinguishing formula
* `exists_finitary_separator` — Finite conjunction separating one state from a finite set
* `hm_equiv_transfer_of_imageFinite` — Transfer property for HM-equivalence
* `hm_equiv_iff_bisimilar_of_imageFinite` — **Hennessy–Milner completeness**
* `separator_induces_distinction` — Algorithmic bridge to partition refinement

## References

* R. Milner, *A Calculus of Communicating Systems*, 1980
* M. Hennessy, R. Milner, *Algebraic Laws for Nondeterminism and Concurrency*, 1985
* D. Sangiorgi, *Introduction to Bisimulation and Coinduction*, 2012
-/

import Mathlib

namespace HennessyMilner

open Classical

universe u

/-! ## Core LTS Definitions (self-contained) -/

/-- A labeled transition system. -/
structure LTS (Act : Type u) where
  State : Type u
  step : State → Act → State → Prop

/-- Bisimulation zigzag condition. -/
structure IsBisimulation {Act : Type u} (P Q : LTS Act)
    (R : P.State → Q.State → Prop) : Prop where
  zig : ∀ s t a s', R s t → P.step s a s' → ∃ t', Q.step t a t' ∧ R s' t'
  zag : ∀ s t a t', R s t → Q.step t a t' → ∃ s', P.step s a s' ∧ R s' t'

/-- Two states are bisimilar if connected by some bisimulation. -/
def Bisimilar {Act : Type u} (P Q : LTS Act) (s : P.State) (t : Q.State) : Prop :=
  ∃ R : P.State → Q.State → Prop, IsBisimulation P Q R ∧ R s t

/-! ## Hennessy–Milner Logic -/

/-- Hennessy–Milner logic formulas. -/
inductive HMFormula (Act : Type*) : Type _ where
  | tt : HMFormula Act
  | conj : HMFormula Act → HMFormula Act → HMFormula Act
  | neg : HMFormula Act → HMFormula Act
  | diamond : Act → HMFormula Act → HMFormula Act

/-- The box modality: `[a]φ` = `¬◇a(¬φ)`. -/
def HMFormula.box (a : Act) (φ : HMFormula Act) : HMFormula Act :=
  HMFormula.neg (HMFormula.diamond a (HMFormula.neg φ))

/-- Satisfaction relation for HM logic. -/
def HMSatisfies {Act : Type*} (P : LTS Act) : P.State → HMFormula Act → Prop
  | _, HMFormula.tt => True
  | s, HMFormula.conj φ ψ => HMSatisfies P s φ ∧ HMSatisfies P s ψ
  | s, HMFormula.neg φ => ¬ HMSatisfies P s φ
  | s, HMFormula.diamond a φ => ∃ s', P.step s a s' ∧ HMSatisfies P s' φ

/-- Two states are HM-equivalent if they satisfy the same formulas. -/
def HMEquiv {Act : Type*} (P Q : LTS Act) (s : P.State) (t : Q.State) : Prop :=
  ∀ φ : HMFormula Act, HMSatisfies P s φ ↔ HMSatisfies Q t φ

/-- **Soundness**: bisimilar states satisfy the same HM formulas. -/
theorem bisimilar_implies_hm_equiv {Act : Type*} {P Q : LTS Act}
    {R : P.State → Q.State → Prop} (hR : IsBisimulation P Q R)
    {s : P.State} {t : Q.State} (hst : R s t) :
    HMEquiv P Q s t := by
  intro φ
  induction φ generalizing s t with
  | tt => simp [HMSatisfies]
  | conj φ ψ ihφ ihψ =>
    simp only [HMSatisfies]
    exact ⟨fun ⟨hφ, hψ⟩ => ⟨(ihφ hst).mp hφ, (ihψ hst).mp hψ⟩,
           fun ⟨hφ, hψ⟩ => ⟨(ihφ hst).mpr hφ, (ihψ hst).mpr hψ⟩⟩
  | neg φ ih =>
    simp only [HMSatisfies]
    exact ⟨fun h hq => h ((ih hst).mpr hq), fun h hp => h ((ih hst).mp hp)⟩
  | diamond a φ ih =>
    simp only [HMSatisfies]
    constructor
    · rintro ⟨s', hstep, hsat⟩
      obtain ⟨t', ht', hR'⟩ := hR.zig s t a s' hst hstep
      exact ⟨t', ht', (ih hR').mp hsat⟩
    · rintro ⟨t', hstep, hsat⟩
      obtain ⟨s', hs', hR'⟩ := hR.zag s t a t' hst hstep
      exact ⟨s', hs', (ih hR').mpr hsat⟩

/-- Bisimilarity implies HM-equivalence. -/
theorem bisimilar_implies_hm_equiv' {Act : Type*} {P Q : LTS Act}
    {s : P.State} {t : Q.State} (h : Bisimilar P Q s t) :
    HMEquiv P Q s t := by
  obtain ⟨R, hR, hst⟩ := h
  exact bisimilar_implies_hm_equiv hR hst

/-- HM-equivalence is symmetric. -/
theorem hm_equiv_symm {Act : Type*} {P Q : LTS Act}
    {s : P.State} {t : Q.State}
    (h : HMEquiv P Q s t) : HMEquiv Q P t s :=
  fun φ => (h φ).symm

/-! ## Image-Finite LTS with Computational Content -/

/-- An image-finite labeled transition system with computational content. -/
structure ImageFiniteLTS (Act : Type*) extends LTS Act where
  succs : State → Act → Finset State
  mem_succs_iff : ∀ s a t, t ∈ succs s a ↔ step s a t

/-! ## Finite Conjunction of HM Formulas -/

/-- Conjunction of a list of HM formulas. -/
def listConj {Act : Type*} : List (HMFormula Act) → HMFormula Act
  | [] => HMFormula.tt
  | φ :: l => HMFormula.conj φ (listConj l)

/-
**Finite conjunction semantics**: a state satisfies a list conjunction
    iff it satisfies every formula in the list.
-/
theorem satisfies_listConj_iff {Act : Type*} {P : LTS Act} {s : P.State}
    {l : List (HMFormula Act)} :
    HMSatisfies P s (listConj l) ↔ ∀ φ ∈ l, HMSatisfies P s φ := by
  induction' l with φ l ih generalizing s;
  · exact iff_of_true trivial fun φ h => by contradiction;
  · simp +decide [listConj];
    exact ⟨ fun h => ⟨ h.1, fun a ha => ih.mp h.2 a ha ⟩, fun h => ⟨ h.1, ih.mpr h.2 ⟩ ⟩

/-! ## Distinguishing Formula Extraction -/

/-
If two states in the same LTS are not HM-equivalent, there exists a formula
    satisfied by the first but not the second.
-/
theorem exists_distinguishing_formula {Act : Type*} {P : LTS Act}
    {s t : P.State}
    (h : ¬ HMEquiv P P s t) :
    ∃ φ : HMFormula Act, HMSatisfies P s φ ∧ ¬ HMSatisfies P t φ := by
  contrapose! h;
  intro φ; have := h φ; have := h ( HMFormula.neg φ ) ; simp_all +decide [ HMSatisfies ] ;
  grind +splitImp

/-! ## Finite Separator Construction -/

/-
**Finitary separator theorem**: if `s'` is HM-distinguishable from every
    member of a finite set `ts`, then there is a single formula satisfied
    by `s'` and falsified by every element of `ts`.
-/
theorem exists_finitary_separator {Act : Type*} {P : LTS Act}
    {s' : P.State} {ts : Finset P.State}
    (hsep : ∀ t' ∈ ts, ¬ HMEquiv P P s' t') :
    ∃ ψ : HMFormula Act,
      HMSatisfies P s' ψ ∧
      ∀ t' ∈ ts, ¬ HMSatisfies P t' ψ := by
  induction' ts using Finset.induction with t' ts ih generalizing s';
  · exact ⟨ HMFormula.tt, trivial, by simp +decide ⟩;
  · obtain ⟨ ψ₁, hψ₁, hψ₁' ⟩ := ‹∀ { s' : P.State }, ( ∀ t' ∈ ts, ¬HMEquiv P P s' t' ) → ∃ ψ, HMSatisfies P s' ψ ∧ ∀ t' ∈ ts, ¬HMSatisfies P t' ψ› ( fun t' ht' => hsep t' ( Finset.mem_insert_of_mem ht' ) );
    obtain ⟨ ψ₂, hψ₂, hψ₂' ⟩ := exists_distinguishing_formula ( hsep t' ( Finset.mem_insert_self t' ts ) );
    refine' ⟨ HMFormula.conj ψ₁ ψ₂, _, _ ⟩ <;> simp_all +decide [ HMSatisfies ]

/-! ## The Transfer Property -/

/-
**HM-equivalence satisfies the bisimulation transfer condition**
    for image-finite systems.
-/
theorem hm_equiv_transfer_of_imageFinite {Act : Type*}
    (M : ImageFiniteLTS Act)
    {s t : M.State}
    (hEq : HMEquiv M.toLTS M.toLTS s t) :
    ∀ ⦃a s'⦄, M.step s a s' →
      ∃ t', M.step t a t' ∧ HMEquiv M.toLTS M.toLTS s' t' := by
  -- Assume for contradiction that there is no matching $t'$ such that $M.step t a t'$ and $HMEquiv s' t'$.
  by_contra hNoMatch
  push_neg at hNoMatch;
  obtain ⟨ a, s', h₁, h₂ ⟩ := hNoMatch
  have h separator : HMSatisfies M.toLTS s (HMFormula.diamond a separator) ↔ ∃ t', M.step t a t' ∧ HMSatisfies M.toLTS t' separator := by
    convert hEq ( HMFormula.diamond a separator ) using 1;
  -- By the finitary separator theorem, there exists a formula $\psi$ such that $s' \models \psi$ and for all $t' \in \text{succs } t a$, $t' \not\models \psi$.
  obtain ⟨ψ, hψ⟩ : ∃ ψ : HMFormula Act, HMSatisfies M.toLTS s' ψ ∧ ∀ t' ∈ M.succs t a, ¬HMSatisfies M.toLTS t' ψ := by
    convert exists_finitary_separator _;
    exact fun t' ht' => h₂ t' ( M.mem_succs_iff _ _ _ |>.1 ht' );
  specialize h ψ;
  exact absurd ( h.mp ⟨ s', h₁, hψ.1 ⟩ ) ( by rintro ⟨ t', ht', ht'' ⟩ ; exact hψ.2 t' ( by simpa [ M.mem_succs_iff ] using ht' ) ht'' )

/-! ## Hennessy–Milner Completeness -/

/-- HM-equivalence is a bisimulation on image-finite systems. -/
theorem hm_equiv_is_bisimulation_of_imageFinite {Act : Type*}
    (M : ImageFiniteLTS Act) :
    IsBisimulation M.toLTS M.toLTS (fun s t => HMEquiv M.toLTS M.toLTS s t) where
  zig := by
    intro s t a s' hEq hstep
    exact hm_equiv_transfer_of_imageFinite M hEq hstep
  zag := by
    intro s t a t' hEq hstep
    have hEq' := hm_equiv_symm hEq
    obtain ⟨s', hs', hEq''⟩ := hm_equiv_transfer_of_imageFinite M hEq' hstep
    exact ⟨s', hs', hm_equiv_symm hEq''⟩

/-- **Hennessy–Milner Completeness Theorem**: for image-finite systems,
    HM-equivalence coincides with bisimilarity. -/
theorem hm_equiv_iff_bisimilar_of_imageFinite {Act : Type*}
    (M : ImageFiniteLTS Act)
    {s t : M.State} :
    HMEquiv M.toLTS M.toLTS s t ↔ Bisimilar M.toLTS M.toLTS s t := by
  constructor
  · intro hEq
    exact ⟨fun s t => HMEquiv M.toLTS M.toLTS s t,
           hm_equiv_is_bisimulation_of_imageFinite M, hEq⟩
  · intro hBisim
    exact bisimilar_implies_hm_equiv' hBisim

/-! ## Algorithmic Bridge: Separator Certificates -/

/-- The one-step modal separator: `◇a (⋀ Γ)`. -/
def stepSeparator {Act : Type*} (a : Act) (Γ : List (HMFormula Act)) :
    HMFormula Act :=
  HMFormula.diamond a (listConj Γ)

/-
A separator formula induces a distinction between states.
-/
theorem separator_induces_distinction {Act : Type*} {P : LTS Act}
    {s t : P.State}
    {a : Act} {Γ : List (HMFormula Act)}
    (hs : HMSatisfies P s (stepSeparator a Γ))
    (ht : ¬ HMSatisfies P t (stepSeparator a Γ)) :
    s ≠ t := by
  exact fun h => ht <| h ▸ hs

/-- **Modal depth** of an HM formula. -/
def modalDepth {Act : Type*} : HMFormula Act → ℕ
  | HMFormula.tt => 0
  | HMFormula.conj φ ψ => max (modalDepth φ) (modalDepth ψ)
  | HMFormula.neg φ => modalDepth φ
  | HMFormula.diamond _ φ => modalDepth φ + 1

/-
The modal depth of a list conjunction equals the maximum depth.
-/
theorem modalDepth_listConj {Act : Type*} {l : List (HMFormula Act)} :
    modalDepth (listConj l) = l.foldr (fun φ d => max (modalDepth φ) d) 0 := by
  induction' l with l hl;
  · rfl;
  · convert congr_arg₂ max rfl ‹modalDepth ( listConj hl ) = List.foldr ( fun φ d => max ( modalDepth φ ) d ) 0 hl› using 1

end HennessyMilner