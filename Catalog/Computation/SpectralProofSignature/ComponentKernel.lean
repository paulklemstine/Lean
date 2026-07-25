/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Component Kernel of a Finite Simple Graph

This file gives a fully type-checking foundational formalization of the
*component-kernel theorem* for finite simple graphs over `ℝ`, together with a
small collection of "modular signature" corollaries.

## Mathematical content

Given a finite simple graph `G : SimpleGraph V`, view the functions `V → ℝ` as a
real vector space.  The **harmonic kernel** `harmonicKernel G` is the subspace of
functions that are constant across every edge:

  `f ∈ harmonicKernel G ↔ ∀ {u v}, G.Adj u v → f u = f v`.

Such functions are exactly the functions that are *locally constant* with respect
to the graph: they are constant along every walk and hence on every connected
component.  Consequently the harmonic kernel is naturally isomorphic, as a real
vector space, to the space of functions on the set of connected components:

  `harmonicKernel G ≃ₗ[ℝ] (G.ConnectedComponent → ℝ)`.

Taking dimensions yields the central result, that the dimension of the harmonic
kernel equals the number of connected components:

  `specModSig G = Fintype.card G.ConnectedComponent`.

We call `specModSig G := Module.finrank ℝ (harmonicKernel G)` the **spectral
modular signature** of `G`.  (Up to the usual identification of the harmonic
kernel with the kernel of the combinatorial graph Laplacian, this is the
nullity of the Laplacian; we do *not* prove that matrix identity here — the
deliverable is the purely component-theoretic statement.)

## Main results

* `harmonicKernel_walk` / `harmonicKernel_reachable` — kernel elements are
  constant along walks and on reachable pairs.
* `harmonicKernelEquiv` — the linear equivalence with component-functions.
* `specModSig_eq_card_components` — the component-kernel theorem.
* `specModSig_pos` — the signature is positive when `V` is nonempty.
* `specModSig_le_card` — the signature is at most `Fintype.card V`.
* `connected_iff_specModSig_eq_one` — connectivity is `signature = 1`.
* `specModSig_iso` — isomorphic graphs have equal signatures.
* `specModSig_eq_card_iff_edgeless` — the signature is maximal iff the graph is
  edgeless.

## Scope

This file makes **no** empirical claim about the lengths of Lean/Coq/Isabelle
proofs and proves **no** asymptotic proof-difficulty conjecture.  It isolates the
rigorous finite-dimensional linear-algebra core on which such a theory could be
built.
-/

import Mathlib

open SimpleGraph

namespace SpectralProofSignature

variable {V : Type*} (G : SimpleGraph V)

/-! ## The harmonic kernel -/

/-- The **harmonic kernel** of a graph: the subspace of real-valued vertex
functions that are constant across every edge. -/
def harmonicKernel (G : SimpleGraph V) : Submodule ℝ (V → ℝ) where
  carrier := {f | ∀ ⦃u v : V⦄, G.Adj u v → f u = f v}
  add_mem' {a b} ha hb := by intro u v h; simp [ha h, hb h]
  zero_mem' := by intro u v h; rfl
  smul_mem' c a ha := by intro u v h; simp [ha h]

@[simp] lemma mem_harmonicKernel_iff {f : V → ℝ} :
    f ∈ harmonicKernel G ↔ ∀ ⦃u v : V⦄, G.Adj u v → f u = f v := Iff.rfl

/-- A harmonic kernel element is constant along every walk. -/
lemma harmonicKernel_walk {f : V → ℝ} (hf : f ∈ harmonicKernel G) :
    ∀ {u v : V} (_ : G.Walk u v), f u = f v := by
  intro u v p
  induction p with
  | nil => rfl
  | cons h _ ih => exact (hf h).trans ih

/-- A harmonic kernel element is constant on every reachable pair of vertices. -/
lemma harmonicKernel_reachable {f : V → ℝ} (hf : f ∈ harmonicKernel G)
    {u v : V} (h : G.Reachable u v) : f u = f v := by
  obtain ⟨p⟩ := h
  exact harmonicKernel_walk G hf p

/-- Membership in the harmonic kernel is *equivalent* to being constant on every
reachable pair of vertices (not merely on adjacent ones). -/
lemma mem_harmonicKernel_iff_reachable {f : V → ℝ} :
    f ∈ harmonicKernel G ↔ ∀ ⦃u v : V⦄, G.Reachable u v → f u = f v := by
  constructor
  · intro hf u v h; exact harmonicKernel_reachable G hf h
  · intro hf u v h; exact hf h.reachable

/-! ## The component-function equivalence -/

variable [Fintype V] [DecidableEq V] [DecidableRel G.Adj]

/-- The forward map: a harmonic kernel element descends to a function on the set
of connected components, by evaluation at any representative vertex. -/
noncomputable def toComp : harmonicKernel G →ₗ[ℝ] (G.ConnectedComponent → ℝ) where
  toFun f := ConnectedComponent.lift f.1 (fun _ _ p _ => harmonicKernel_walk G f.2 p)
  map_add' f g := by funext c; induction c using ConnectedComponent.ind; rfl
  map_smul' c f := by funext x; induction x using ConnectedComponent.ind; rfl

/-- The backward map: a function on connected components pulls back to a vertex
function (which is automatically harmonic). -/
def fromComp : (G.ConnectedComponent → ℝ) →ₗ[ℝ] harmonicKernel G where
  toFun g := ⟨fun v => g (G.connectedComponentMk v), by
    intro u v h
    show g (G.connectedComponentMk u) = g (G.connectedComponentMk v)
    rw [ConnectedComponent.connectedComponentMk_eq_of_adj h]⟩
  map_add' g h := by ext v; rfl
  map_smul' c g := by ext v; rfl

/-- The harmonic kernel of `G` is linearly equivalent to the space of functions
on the connected components of `G`. -/
noncomputable def harmonicKernelEquiv :
    harmonicKernel G ≃ₗ[ℝ] (G.ConnectedComponent → ℝ) :=
  LinearEquiv.ofLinear (toComp G) (fromComp G)
    (by ext g c; induction c using ConnectedComponent.ind; rfl)
    (by ext f v; rfl)

/-! ## The spectral modular signature -/

/-- The **spectral modular signature** of `G`: the dimension of its harmonic
kernel as a real vector space. -/
noncomputable def specModSig (G : SimpleGraph V) [DecidableRel G.Adj] : ℕ :=
  Module.finrank ℝ (harmonicKernel G)

/-- **Component-kernel theorem.** The spectral modular signature equals the number
of connected components. -/
theorem specModSig_eq_card_components :
    specModSig G = Fintype.card G.ConnectedComponent := by
  rw [specModSig, (harmonicKernelEquiv G).finrank_eq, Module.finrank_fintype_fun_eq_card]

/-! ## Corollaries -/

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- The connected-component projection is surjective. -/
lemma connectedComponentMk_surjective :
    Function.Surjective G.connectedComponentMk := by
  intro c
  induction c using ConnectedComponent.ind with
  | _ v => exact ⟨v, rfl⟩

/-- For a nonempty vertex set the signature is positive. -/
theorem specModSig_pos [Nonempty V] : 0 < specModSig G := by
  rw [specModSig_eq_card_components]
  have : Nonempty G.ConnectedComponent := ⟨G.connectedComponentMk (Classical.arbitrary V)⟩
  exact Fintype.card_pos

/-- The signature is bounded above by the number of vertices. -/
theorem specModSig_le_card : specModSig G ≤ Fintype.card V := by
  rw [specModSig_eq_card_components]
  exact Fintype.card_le_of_surjective _ (connectedComponentMk_surjective G)

/-- A graph is connected iff its spectral modular signature is `1`. -/
theorem connected_iff_specModSig_eq_one :
    G.Connected ↔ specModSig G = 1 := by
  rw [specModSig_eq_card_components, connected_iff,
    Fintype.card_eq_one_iff_nonempty_unique]
  constructor
  · rintro ⟨hpre, hV⟩
    haveI := hpre.subsingleton_connectedComponent
    have hc : Nonempty G.ConnectedComponent := ⟨G.connectedComponentMk hV.some⟩
    obtain ⟨c⟩ := hc
    exact ⟨{ default := c, uniq := fun a => Subsingleton.elim a c }⟩
  · rintro ⟨u⟩
    haveI : Subsingleton G.ConnectedComponent := inferInstance
    have hpre : G.Preconnected := by
      intro a b
      have h := Subsingleton.elim (G.connectedComponentMk a) (G.connectedComponentMk b)
      rwa [ConnectedComponent.eq] at h
    obtain ⟨v, _⟩ := connectedComponentMk_surjective G u.default
    exact ⟨hpre, ⟨v⟩⟩

/-- Isomorphic graphs have equal spectral modular signatures. -/
theorem specModSig_iso {W : Type*} [Fintype W] [DecidableEq W]
    {H : SimpleGraph W} [DecidableRel H.Adj] (e : G ≃g H) :
    specModSig G = specModSig H := by
  rw [specModSig_eq_card_components, specModSig_eq_card_components,
    Fintype.card_congr e.connectedComponentEquiv]

/-- The signature attains its maximum `Fintype.card V` iff the graph is edgeless. -/
theorem specModSig_eq_card_iff_edgeless :
    specModSig G = Fintype.card V ↔ G = ⊥ := by
  rw [specModSig_eq_card_components]
  constructor
  · intro hcard
    have hbij : Function.Bijective G.connectedComponentMk :=
      (Fintype.bijective_iff_surjective_and_card _).2
        ⟨connectedComponentMk_surjective G, hcard.symm⟩
    ext u v
    rw [bot_adj]
    constructor
    · intro h
      exact (G.ne_of_adj h
        (hbij.1 (ConnectedComponent.connectedComponentMk_eq_of_adj h))).elim
    · intro h; exact h.elim
  · rintro rfl
    have hinj : Function.Injective (⊥ : SimpleGraph V).connectedComponentMk := by
      intro u v h
      rw [ConnectedComponent.eq, reachable_bot] at h
      exact h
    have hbij : Function.Bijective (⊥ : SimpleGraph V).connectedComponentMk :=
      ⟨hinj, connectedComponentMk_surjective _⟩
    exact ((Fintype.bijective_iff_surjective_and_card _).1 hbij).2.symm

end SpectralProofSignature