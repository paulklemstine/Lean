/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bisimulation Properties

This file proves that bisimilarity is an equivalence relation and that
bisimilarity implies trace equivalence. These are foundational results
for the Yoneda-Bisimulation Correspondence.

## Main Results

* `bisimulation_refl` — The identity relation is a bisimulation (reflexivity)
* `bisimulation_symm` — The converse of a bisimulation is a bisimulation (symmetry)
* `bisimulation_trans` — The composition of bisimulations is a bisimulation (transitivity)
* `bisimilar_refl` — Bisimilarity is reflexive
* `bisimilar_symm` — Bisimilarity is symmetric
* `bisimilar_trans` — Bisimilarity is transitive
* `bisimilar_implies_trace_equiv` — Bisimilar states are trace-equivalent
-/

import Pythagorean.YonedaBisimulation.Defs

namespace YonedaBisimulation

variable {Act : Type*}

/-! ## Bisimulation is an equivalence relation -/

/-- The identity relation is a bisimulation: any LTS is bisimilar to itself. -/
theorem bisimulation_refl (P : LTS Act) : IsBisimulation P P (idRel P) where
  zig := by
    intro s t a s' hst hstep
    simp [idRel] at hst
    exact ⟨s', hst ▸ hstep, rfl⟩
  zag := by
    intro s t a t' hst hstep
    simp [idRel] at hst
    exact ⟨t', hst ▸ hstep, rfl⟩

/-- Bisimilarity is reflexive. -/
theorem bisimilar_refl (P : LTS Act) (s : P.State) : Bisimilar P P s s :=
  ⟨idRel P, bisimulation_refl P, rfl⟩

/-- The converse of a bisimulation is a bisimulation. -/
theorem bisimulation_symm {P Q : LTS Act} {R : P.State → Q.State → Prop}
    (h : IsBisimulation P Q R) : IsBisimulation Q P (convRel R) where
  zig := by
    intro s t a s' hst hstep
    obtain ⟨t', ht', hR⟩ := h.zag t s a s' hst hstep
    exact ⟨t', ht', hR⟩
  zag := by
    intro s t a t' hst hstep
    obtain ⟨s', hs', hR⟩ := h.zig t s a t' hst hstep
    exact ⟨s', hs', hR⟩

/-- Bisimilarity is symmetric. -/
theorem bisimilar_symm {P Q : LTS Act} {s : P.State} {t : Q.State}
    (h : Bisimilar P Q s t) : Bisimilar Q P t s := by
  obtain ⟨R, hR, hst⟩ := h
  exact ⟨convRel R, bisimulation_symm hR, hst⟩

/-- The composition of two bisimulations is a bisimulation. -/
theorem bisimulation_trans {P Q R₀ : LTS Act}
    {R : P.State → Q.State → Prop} {S : Q.State → R₀.State → Prop}
    (hR : IsBisimulation P Q R) (hS : IsBisimulation Q R₀ S) :
    IsBisimulation P R₀ (compRel R S) where
  zig := by
    intro s u a s' ⟨t, hst, htu⟩ hstep
    obtain ⟨t', ht', hR'⟩ := hR.zig s t a s' hst hstep
    obtain ⟨u', hu', hS'⟩ := hS.zig t u a t' htu ht'
    exact ⟨u', hu', t', hR', hS'⟩
  zag := by
    intro s u a u' ⟨t, hst, htu⟩ hstep
    obtain ⟨t', ht', hS'⟩ := hS.zag t u a u' htu hstep
    obtain ⟨s', hs', hR'⟩ := hR.zag s t a t' hst ht'
    exact ⟨s', hs', t', hR', hS'⟩

/-- Bisimilarity is transitive. -/
theorem bisimilar_trans {P Q R₀ : LTS Act}
    {s : P.State} {t : Q.State} {u : R₀.State}
    (h1 : Bisimilar P Q s t) (h2 : Bisimilar Q R₀ t u) :
    Bisimilar P R₀ s u := by
  obtain ⟨R, hR, hst⟩ := h1
  obtain ⟨S, hS, htu⟩ := h2
  exact ⟨compRel R S, bisimulation_trans hR hS, t, hst, htu⟩

/-! ## Bisimilarity implies trace equivalence

This is one direction of the Yoneda-Bisimulation Correspondence:
if two states are bisimilar, they satisfy the same experiments (traces).
This corresponds to the "only if" direction — a bisimulation relation
induces a natural transformation between nerve presheaves. -/

/-- Bisimilar states accept the same traces: if `s ~ t` and `s` can perform
    trace `σ`, then `t` can also perform `σ`. This is the forward direction. -/
theorem bisimilar_trace_forward {P Q : LTS Act}
    {R : P.State → Q.State → Prop} (hR : IsBisimulation P Q R)
    {s : P.State} {t : Q.State} (hst : R s t) :
    ∀ σ, TraceAccepted P s σ → TraceAccepted Q t σ := by
  intro σ
  induction σ generalizing s t with
  | nil => intro _; exact TraceAccepted.nil t
  | cons a σ ih =>
    intro h
    cases h with
    | cons _ _ _ s' hstep hacc =>
      obtain ⟨t', ht', hR'⟩ := hR.zig s t a s' hst hstep
      exact TraceAccepted.cons t a σ t' ht' (ih hR' hacc)

/-- Bisimilar states accept the same traces: backward direction. -/
theorem bisimilar_trace_backward {P Q : LTS Act}
    {R : P.State → Q.State → Prop} (hR : IsBisimulation P Q R)
    {s : P.State} {t : Q.State} (hst : R s t) :
    ∀ σ, TraceAccepted Q t σ → TraceAccepted P s σ := by
  intro σ
  induction σ generalizing s t with
  | nil => intro _; exact TraceAccepted.nil s
  | cons a σ ih =>
    intro h
    cases h with
    | cons _ _ _ t' hstep hacc =>
      obtain ⟨s', hs', hR'⟩ := hR.zag s t a t' hst hstep
      exact TraceAccepted.cons s a σ s' hs' (ih hR' hacc)

/-- **Bisimilarity implies trace equivalence.**
    This is one half of the Yoneda-Bisimulation Correspondence:
    a bisimulation between two LTS induces agreement on all experiments,
    which in presheaf language means the nerve presheaves are naturally isomorphic. -/
theorem bisimilar_implies_trace_equiv {P Q : LTS Act}
    {s : P.State} {t : Q.State} (h : Bisimilar P Q s t) :
    TraceEquiv P Q s t := by
  obtain ⟨R, hR, hst⟩ := h
  intro σ
  exact ⟨bisimilar_trace_forward hR hst σ, bisimilar_trace_backward hR hst σ⟩

/-! ## The union of all bisimulations is a bisimulation

This shows that bisimilarity itself (the union of all bisimulations) is
the largest bisimulation. This is a key structural fact. -/

/-- Bisimilarity is itself a bisimulation — the largest one.
    This is the categorical content: the bisimilarity relation is the
    terminal object in the category of bisimulations. -/
theorem bisimUnion_is_bisimulation (P Q : LTS Act) :
    IsBisimulation P Q (bisimUnion P Q) where
  zig := by
    intro s t a s' hst hstep
    obtain ⟨R, hR, hRst⟩ := hst
    obtain ⟨t', ht', hR'⟩ := hR.zig s t a s' hRst hstep
    exact ⟨t', ht', R, hR, hR'⟩
  zag := by
    intro s t a t' hst hstep
    obtain ⟨R, hR, hRst⟩ := hst
    obtain ⟨s', hs', hR'⟩ := hR.zag s t a t' hRst hstep
    exact ⟨s', hs', R, hR, hR'⟩

end YonedaBisimulation