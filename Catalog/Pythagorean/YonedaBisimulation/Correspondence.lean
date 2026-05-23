/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Yoneda-Bisimulation Correspondence

This file proves the central correspondence between bisimulation and
experiment-based equivalence for labeled transition systems.

## Main Results

* `yoneda_bisim_det_iff` — Bisimilarity ↔ trace equivalence for deterministic LTS
* `functional_bisim_is_bisim` — Functional bisimulations are bisimulations
* `bisimilar_implies_hm_equiv` — Soundness: bisimilar states satisfy same HM formulas
* `hm_box_iff` — Characterization of the box modality
-/

import Pythagorean.YonedaBisimulation.Properties

namespace YonedaBisimulation

variable {Act : Type*}

/-- Given a state that accepts `a :: σ`, extract a witness successor. -/
theorem trace_accepted_step {P : LTS Act} {s : P.State} {a : Act} {σ : Trace Act}
    (h : TraceAccepted P s (a :: σ)) :
    ∃ s', P.step s a s' ∧ TraceAccepted P s' σ := by
  cases h with
  | cons _ _ _ s' hstep hacc => exact ⟨s', hstep, hacc⟩

/-- A deterministic LTS has at most one successor per state and action. -/
class Deterministic {Act : Type*} (P : LTS Act) : Prop where
  unique_step : ∀ s a s₁ s₂, P.step s a s₁ → P.step s a s₂ → s₁ = s₂

/-! ## Deterministic Correspondence -/

/-- For a deterministic LTS, trace equivalence is a bisimulation. -/
theorem trace_equiv_is_bisim_self (P : LTS Act) [Deterministic P] :
    IsBisimulation P P (fun s t => TraceEquiv P P s t) where
  zig := by
    intro s t a s' hst hstep
    have hs_acc : TraceAccepted P s [a] :=
      TraceAccepted.cons s a [] s' hstep (TraceAccepted.nil s')
    have ht_acc : TraceAccepted P t [a] := (hst [a]).mp hs_acc
    obtain ⟨t', ht_step, _⟩ := trace_accepted_step ht_acc
    refine ⟨t', ht_step, fun σ => ⟨fun hs' => ?_, fun ht' => ?_⟩⟩
    · have : TraceAccepted P s (a :: σ) := TraceAccepted.cons s a σ s' hstep hs'
      have : TraceAccepted P t (a :: σ) := (hst (a :: σ)).mp this
      obtain ⟨t'', ht_step', ht''⟩ := trace_accepted_step this
      exact Deterministic.unique_step t a t' t'' ht_step ht_step' ▸ ht''
    · have : TraceAccepted P t (a :: σ) := TraceAccepted.cons t a σ t' ht_step ht'
      have : TraceAccepted P s (a :: σ) := (hst (a :: σ)).mpr this
      obtain ⟨s'', hs_step', hs''⟩ := trace_accepted_step this
      exact Deterministic.unique_step s a s' s'' hstep hs_step' ▸ hs''
  zag := by
    intro s t a t' hst hstep
    have ht_acc : TraceAccepted P t [a] :=
      TraceAccepted.cons t a [] t' hstep (TraceAccepted.nil t')
    have hs_acc : TraceAccepted P s [a] := (hst [a]).mpr ht_acc
    obtain ⟨s', hs_step, _⟩ := trace_accepted_step hs_acc
    refine ⟨s', hs_step, fun σ => ⟨fun hs' => ?_, fun ht' => ?_⟩⟩
    · have : TraceAccepted P s (a :: σ) := TraceAccepted.cons s a σ s' hs_step hs'
      have : TraceAccepted P t (a :: σ) := (hst (a :: σ)).mp this
      obtain ⟨t'', ht_step', ht''⟩ := trace_accepted_step this
      exact Deterministic.unique_step t a t' t'' hstep ht_step' ▸ ht''
    · have : TraceAccepted P t (a :: σ) := TraceAccepted.cons t a σ t' hstep ht'
      have : TraceAccepted P s (a :: σ) := (hst (a :: σ)).mpr this
      obtain ⟨s'', hs_step', hs''⟩ := trace_accepted_step this
      exact Deterministic.unique_step s a s' s'' hs_step hs_step' ▸ hs''

/-- For a deterministic LTS, trace equivalence implies bisimilarity. -/
theorem trace_equiv_implies_bisimilar_det (P : LTS Act) [Deterministic P]
    {s t : P.State} (h : TraceEquiv P P s t) : Bisimilar P P s t :=
  ⟨fun s t => TraceEquiv P P s t, trace_equiv_is_bisim_self P, h⟩

/-- **Yoneda-Bisimulation Correspondence for deterministic LTS:**
    Two states in a deterministic LTS are bisimilar iff trace-equivalent.

    This is the "naturality ↔ zigzag" principle: for deterministic systems,
    agreement on all experiments equals the existence of a bisimulation. -/
theorem yoneda_bisim_det_iff (P : LTS Act) [Deterministic P]
    (s t : P.State) :
    Bisimilar P P s t ↔ TraceEquiv P P s t :=
  ⟨bisimilar_implies_trace_equiv, trace_equiv_implies_bisimilar_det P⟩

/-! ## Functional Bisimulation -/

/-- A functional bisimulation: maps back and forth witnessing zigzag. -/
structure FunctionalBisim (P Q : LTS Act) where
  toFun : P.State → Q.State
  invFun : Q.State → P.State
  sim_forward : ∀ s a s', P.step s a s' → Q.step (toFun s) a (toFun s')
  sim_backward : ∀ t a t', Q.step t a t' → P.step (invFun t) a (invFun t')
  left_inv : ∀ s, invFun (toFun s) = s
  right_inv : ∀ t, toFun (invFun t) = t

/-- A functional bisimulation induces a bisimulation relation. -/
theorem functional_bisim_is_bisim {P Q : LTS Act} (fb : FunctionalBisim P Q) :
    IsBisimulation P Q (fun s t => fb.toFun s = t) where
  zig := by
    intro s t a s' hst hstep
    subst hst
    exact ⟨fb.toFun s', fb.sim_forward s a s' hstep, rfl⟩
  zag := by
    intro s t a t' hst hstep
    subst hst
    refine ⟨fb.invFun t', ?_, fb.right_inv t'⟩
    have h := fb.sim_backward (fb.toFun s) a t' hstep
    rwa [fb.left_inv] at h

/-- A functional bisimulation gives bisimilarity. -/
theorem functional_bisim_gives_bisimilar {P Q : LTS Act}
    (fb : FunctionalBisim P Q) (s : P.State) :
    Bisimilar P Q s (fb.toFun s) :=
  ⟨fun s t => fb.toFun s = t, functional_bisim_is_bisim fb, rfl⟩

/-- A functional bisimulation preserves trace acceptance.
    This is the functoriality of the nerve construction. -/
theorem functional_bisim_preserves_traces {P Q : LTS Act}
    (fb : FunctionalBisim P Q) (s : P.State) (σ : Trace Act) :
    TraceAccepted P s σ → TraceAccepted Q (fb.toFun s) σ := by
  intro h
  induction σ generalizing s with
  | nil => exact TraceAccepted.nil _
  | cons a σ ih =>
    obtain ⟨s', hstep, hacc⟩ := trace_accepted_step h
    exact TraceAccepted.cons _ a σ (fb.toFun s')
      (fb.sim_forward s a s' hstep) (ih s' hacc)

/-! ## Hennessy-Milner Logic -/

/-- Hennessy-Milner logic formulas. -/
inductive HMFormula (Act : Type*) : Type _ where
  | tt : HMFormula Act
  | conj : HMFormula Act → HMFormula Act → HMFormula Act
  | neg : HMFormula Act → HMFormula Act
  | diamond : Act → HMFormula Act → HMFormula Act

/-- The box modality: `[a]φ` means all `a`-successors satisfy `φ`. -/
def HMFormula.box (a : Act) (φ : HMFormula Act) : HMFormula Act :=
  HMFormula.neg (HMFormula.diamond a (HMFormula.neg φ))

/-- Satisfaction relation. -/
def HMSatisfies {Act : Type*} (P : LTS Act) : P.State → HMFormula Act → Prop
  | _, HMFormula.tt => True
  | s, HMFormula.conj φ ψ => HMSatisfies P s φ ∧ HMSatisfies P s ψ
  | s, HMFormula.neg φ => ¬ HMSatisfies P s φ
  | s, HMFormula.diamond a φ => ∃ s', P.step s a s' ∧ HMSatisfies P s' φ

/-- Two states are HM-equivalent if they satisfy the same formulas. -/
def HMEquiv {Act : Type*} (P Q : LTS Act) (s : P.State) (t : Q.State) : Prop :=
  ∀ φ : HMFormula Act, HMSatisfies P s φ ↔ HMSatisfies Q t φ

/-- **Soundness**: Bisimilar states satisfy the same HM formulas.
    This is the fundamental invariance property — a bisimulation preserves
    all observable properties expressible in HM logic. -/
theorem bisimilar_implies_hm_equiv {P Q : LTS Act}
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

/-- Bisimilarity implies HM-equivalence (soundness of HM logic). -/
theorem bisimilar_implies_hm_equiv' {P Q : LTS Act}
    {s : P.State} {t : Q.State} (h : Bisimilar P Q s t) :
    HMEquiv P Q s t := by
  obtain ⟨R, hR, hst⟩ := h
  exact bisimilar_implies_hm_equiv hR hst

/-- The box modality `[a]φ` is satisfied iff all `a`-successors satisfy `φ`. -/
theorem hm_box_iff {P : LTS Act} {s : P.State} {a : Act} {φ : HMFormula Act} :
    HMSatisfies P s (HMFormula.box a φ) ↔
    ∀ s', P.step s a s' → HMSatisfies P s' φ := by
  constructor
  · intro h s' hstep
    by_contra hns'
    exact h ⟨s', hstep, hns'⟩
  · intro h hs
    obtain ⟨s', hstep, hns'⟩ := hs
    exact hns' (h s' hstep)

/-- HM-equivalence is reflexive. -/
theorem hm_equiv_refl (P : LTS Act) (s : P.State) : HMEquiv P P s s :=
  fun _ => Iff.rfl

/-- HM-equivalence is symmetric. -/
theorem hm_equiv_symm {P Q : LTS Act} {s : P.State} {t : Q.State}
    (h : HMEquiv P Q s t) : HMEquiv Q P t s :=
  fun φ => (h φ).symm

/-- HM-equivalence is transitive. -/
theorem hm_equiv_trans {P Q R₀ : LTS Act}
    {s : P.State} {t : Q.State} {u : R₀.State}
    (h1 : HMEquiv P Q s t) (h2 : HMEquiv Q R₀ t u) :
    HMEquiv P R₀ s u :=
  fun φ => (h1 φ).trans (h2 φ)

end YonedaBisimulation