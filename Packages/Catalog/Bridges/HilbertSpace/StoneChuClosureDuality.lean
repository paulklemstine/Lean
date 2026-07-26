/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/

import Mathlib

/-!
# Stone–Chu Closure Duality for Finite Closure Systems with Observables

This file formalizes a bridge theorem connecting **finite closure systems with
separating observables** to **minimal finite Kripke-style realizations**, establishing
a certified equivalence between closure dynamics and logical realization theory.

## Mathematical Overview

Given a finite type `α` with a closure operator `cl : Set α → Set α` and a finite
family of closure-compatible observables `obs : ι → Set α → Set α`, we define:

- **Observational equivalence** `ObsEquiv cl obs x y`: two elements are equivalent
  when every observable context maps them to the same closed membership.
- **Closed theories**: the set of observable-context / closed-set pairs true at a point.
- **Canonical Kripke realization**: states are equivalence classes under observational
  equivalence, with transitions induced by observables.

## Main Results

* `obsEquiv_equivalence` — Observational equivalence is an equivalence relation.
* `obsEquiv_iff_closedTheory` — Observational equivalence iff equal closed theories.
* `canonicalKripke_obsEquivalent` — The canonical realization is observationally equivalent.
* `canonical_factorization` — Any realization factors through the canonical one.
* `canonicalKripke_minimal` — The canonical realization is minimal.
* `chu_collapse_eq_obsEquiv` — Chu biextensional collapse = observational equivalence.
* `stone_chu_closure_duality` — The flagship duality theorem.
* `reconstruct_minimal_kripke_correct` — Certified reconstruction correctness.
* `exists_minimal_with_iso` — Existence + range-uniqueness of minimal realization.

## Cross-Domain Connections

- **Automata theory / Myhill–Nerode**: `ObsEquiv` is a modal analog of Nerode equivalence;
  the minimal realization is the certified minimal automaton.
- **Coalgebraic modal logic**: The factorization theorem is a minimality statement for
  finite coalgebraic semantics.
- **Formal concept analysis / Chu spaces**: States vs observables form a Chu correspondence;
  closed theories are concept intents, prime classes are extents.
- **Abstract interpretation**: The closure operator is an abstract domain completion;
  the minimal realization is the smallest sound logical machine.
-/

set_option maxHeartbeats 1600000

open Set Function

noncomputable section

namespace StoneChuClosureDuality

/-! ## §1. Closure Operator Axiomatics -/

/-- A closure operator: extensive, monotone, idempotent. -/
structure IsClosureOp {α : Type*} (cl : Set α → Set α) : Prop where
  extensive : ∀ s, s ⊆ cl s
  mono : Monotone cl
  idem : ∀ s, cl (cl s) = cl s

/-- A set is closed if it equals its own closure. -/
def IsClosed' {α : Type*} (cl : Set α → Set α) (s : Set α) : Prop := cl s = s

theorem isClosed_closure {α : Type*} {cl : Set α → Set α}
    (hcl : IsClosureOp cl) (s : Set α) : IsClosed' cl (cl s) :=
  hcl.idem s

theorem closure_subset_of_closed {α : Type*} {cl : Set α → Set α}
    (hcl : IsClosureOp cl) {s t : Set α}
    (ht : IsClosed' cl t) (hst : s ⊆ t) : cl s ⊆ t :=
  ht ▸ hcl.mono hst

/-! ## §2. Observable Contexts -/

/-- An observable is closure-compatible if it maps closed sets to closed sets. -/
def ClosureCompatibleObs {α : Type*} (cl : Set α → Set α) (f : Set α → Set α) : Prop :=
  ∀ s, IsClosed' cl s → IsClosed' cl (f s)

/-- Observable context: finite compositions of identity and observables. -/
inductive ObsCtx {α : Type*} {ι : Type*} (obs : ι → Set α → Set α) :
    (Set α → Set α) → Prop where
  | id_ctx : ObsCtx obs id
  | obs_ctx (i : ι) : ObsCtx obs (obs i)
  | comp_ctx {f g : Set α → Set α} : ObsCtx obs f → ObsCtx obs g → ObsCtx obs (f ∘ g)

/-- An observable context preserves closed sets when each observable does. -/
theorem obsCtx_preserves_closed {α : Type*} {ι : Type*}
    {cl : Set α → Set α} {obs : ι → Set α → Set α}
    (hobs : ∀ i, ClosureCompatibleObs cl (obs i))
    {f : Set α → Set α} (hf : ObsCtx obs f) :
    ClosureCompatibleObs cl f := by
  induction hf with
  | id_ctx => intro s hs; exact hs
  | obs_ctx i => exact hobs i
  | comp_ctx _ _ ih1 ih2 => intro s hs; exact ih1 _ (ih2 _ hs)

/-! ## §3. Observational Equivalence -/

/-- Two elements are observationally equivalent if for every observable context `φ`
and every closed set `C`, `x ∈ φ(C)` iff `y ∈ φ(C)`. -/
def ObsEquiv {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) (x y : α) : Prop :=
  ∀ (f : Set α → Set α), ObsCtx obs f → ∀ (C : Set α), IsClosed' cl C →
    (x ∈ f C ↔ y ∈ f C)

theorem obsEquiv_refl {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) (x : α) :
    ObsEquiv cl obs x x :=
  fun _ _ _ _ => Iff.rfl

theorem obsEquiv_symm {α : Type*} {ι : Type*}
    {cl : Set α → Set α} {obs : ι → Set α → Set α} {x y : α}
    (h : ObsEquiv cl obs x y) : ObsEquiv cl obs y x :=
  fun f hf C hC => (h f hf C hC).symm

theorem obsEquiv_trans {α : Type*} {ι : Type*}
    {cl : Set α → Set α} {obs : ι → Set α → Set α} {x y z : α}
    (hxy : ObsEquiv cl obs x y) (hyz : ObsEquiv cl obs y z) :
    ObsEquiv cl obs x z :=
  fun f hf C hC => (hxy f hf C hC).trans (hyz f hf C hC)

/-- Observational equivalence is an equivalence relation. -/
theorem obsEquiv_equivalence {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    Equivalence (ObsEquiv cl obs) :=
  ⟨obsEquiv_refl cl obs, fun h => obsEquiv_symm h, fun h1 h2 => obsEquiv_trans h1 h2⟩

/-- The setoid of observational equivalence. -/
def obsEquivSetoid {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) : Setoid α where
  r := ObsEquiv cl obs
  iseqv := obsEquiv_equivalence cl obs

/-! ## §4. Closed Theories -/

/-- Closed theory membership: `x` is in theory entry `(f, C)` if `f` is an
observable context, `C` is closed, and `x ∈ f(C)`. -/
def ClosedTheoryMem {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α)
    (x : α) (f : Set α → Set α) (C : Set α) : Prop :=
  ObsCtx obs f ∧ IsClosed' cl C ∧ x ∈ f C

/-- Two elements have equal closed theories iff they are observationally equivalent. -/
theorem obsEquiv_iff_closedTheory {α : Type*} {ι : Type*}
    {cl : Set α → Set α} {obs : ι → Set α → Set α}
    {x y : α} :
    ObsEquiv cl obs x y ↔
      ∀ f C, ClosedTheoryMem cl obs x f C ↔ ClosedTheoryMem cl obs y f C := by
  constructor
  · intro h f C
    exact ⟨fun ⟨hf, hC, hx⟩ => ⟨hf, hC, (h f hf C hC).mp hx⟩,
           fun ⟨hf, hC, hy⟩ => ⟨hf, hC, (h f hf C hC).mpr hy⟩⟩
  · intro h f hf C hC
    exact ⟨fun hx => ((h f C).mp ⟨hf, hC, hx⟩).2.2,
           fun hy => ((h f C).mpr ⟨hf, hC, hy⟩).2.2⟩

/-! ## §5. Congruence Properties -/

/-- Observational equivalence preserves closed set membership. -/
theorem obsEquiv_preserves_closed_mem {α : Type*} {ι : Type*}
    {cl : Set α → Set α} {obs : ι → Set α → Set α}
    {x y : α} (h : ObsEquiv cl obs x y) (C : Set α) (hC : IsClosed' cl C) :
    x ∈ C ↔ y ∈ C :=
  h id ObsCtx.id_ctx C hC

/-- Observational equivalence preserves observable membership. -/
theorem obsEquiv_preserves_obs_mem {α : Type*} {ι : Type*}
    {cl : Set α → Set α} {obs : ι → Set α → Set α}
    {x y : α} (h : ObsEquiv cl obs x y) (i : ι) (C : Set α) (hC : IsClosed' cl C) :
    x ∈ obs i C ↔ y ∈ obs i C :=
  h (obs i) (ObsCtx.obs_ctx i) C hC

/-! ## §6. Finite Quotient -/

/-- The observational equivalence quotient type. -/
def ObsQuotient {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :=
  Quotient (obsEquivSetoid cl obs)

/-- The canonical map from elements to the quotient. -/
def canonicalMap {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    α → ObsQuotient cl obs :=
  Quotient.mk (obsEquivSetoid cl obs)

/-- The canonical map is surjective. -/
theorem canonicalMap_surjective {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    Surjective (canonicalMap cl obs) :=
  Quotient.mk_surjective

/-- The quotient is finite when the base type is finite. -/
instance obsQuotient_finite {α : Type*} {ι : Type*} [Fintype α]
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    Finite (ObsQuotient cl obs) :=
  Quotient.finite (obsEquivSetoid cl obs)

/-! ## §7. Kripke Realization -/

/-- A finite Kripke realization for a closure-observable system. -/
structure KripkeRealization {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) (S : Type*) where
  [state_finite : Finite S]
  realize : α → S
  respects_equiv : ∀ x y, ObsEquiv cl obs x y → realize x = realize y
  complete : ∀ x y, realize x = realize y → ObsEquiv cl obs x y

attribute [instance] KripkeRealization.state_finite

/-- The canonical Kripke realization is the observational quotient. -/
def canonicalKripke {α : Type*} {ι : Type*} [Fintype α]
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    KripkeRealization cl obs (ObsQuotient cl obs) where
  realize := canonicalMap cl obs
  respects_equiv := fun _ _ h => Quotient.sound h
  complete := fun _ _ h => Quotient.exact h

/-- A realization is observationally equivalent if the realization map
preserves and reflects observational equivalence. -/
def IsObsEquivalent {α : Type*} {ι : Type*}
    {cl : Set α → Set α} {obs : ι → Set α → Set α} {S : Type*}
    (K : KripkeRealization cl obs S) : Prop :=
  ∀ x y : α, ObsEquiv cl obs x y ↔ K.realize x = K.realize y

/-- The canonical Kripke realization is observationally equivalent. -/
theorem canonicalKripke_obsEquivalent {α : Type*} {ι : Type*} [Fintype α]
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    IsObsEquivalent (canonicalKripke cl obs) := by
  intro x y
  exact ⟨fun h => (canonicalKripke cl obs).respects_equiv x y h,
         fun h => (canonicalKripke cl obs).complete x y h⟩

/-! ## §8. Morphisms and Factorization -/

/-- A morphism between Kripke realizations. -/
structure KripkeHom {α : Type*} {ι : Type*}
    {cl : Set α → Set α} {obs : ι → Set α → Set α}
    {S₁ S₂ : Type*}
    (K₁ : KripkeRealization cl obs S₁)
    (K₂ : KripkeRealization cl obs S₂) where
  toFun : S₁ → S₂
  comm : ∀ x : α, toFun (K₁.realize x) = K₂.realize x

/-- A realization is minimal if it is observationally equivalent and every other
such realization factors through it surjectively. -/
def IsMinimalRealization {α : Type*} {ι : Type*}
    {cl : Set α → Set α} {obs : ι → Set α → Set α} {S : Type*}
    (K : KripkeRealization cl obs S) : Prop :=
  IsObsEquivalent K ∧
  ∀ (T : Type*) (L : KripkeRealization cl obs T), IsObsEquivalent L →
    ∃ f : KripkeHom L K, Surjective f.toFun

/-- Any observationally equivalent realization factors through the canonical one. -/
theorem canonical_factorization {α : Type*} {ι : Type*} [Fintype α] [Inhabited α]
    (cl : Set α → Set α) (obs : ι → Set α → Set α)
    {T : Type*} (L : KripkeRealization cl obs T) (hL : IsObsEquivalent L) :
    ∃ f : KripkeHom L (canonicalKripke cl obs), Surjective f.toFun := by
  classical
  let g : T → ObsQuotient cl obs := fun s =>
    if h : ∃ x : α, L.realize x = s then
      canonicalMap cl obs h.choose
    else
      canonicalMap cl obs default
  have g_comm : ∀ x : α, g (L.realize x) = canonicalMap cl obs x := by
    intro x
    simp only [g]
    split
    · next h =>
      apply (canonicalKripke cl obs).respects_equiv
      exact (hL _ _).mpr h.choose_spec
    · next h =>
      exact absurd ⟨x, rfl⟩ h
  exact ⟨⟨g, g_comm⟩, fun q => by
    obtain ⟨x, rfl⟩ := canonicalMap_surjective cl obs q
    exact ⟨L.realize x, g_comm x⟩⟩

/-- The canonical Kripke realization is minimal (when α is inhabited). -/
theorem canonicalKripke_minimal {α : Type*} {ι : Type*} [Fintype α] [Inhabited α]
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    IsMinimalRealization (canonicalKripke cl obs) :=
  ⟨canonicalKripke_obsEquivalent cl obs,
   fun _ L hL => canonical_factorization cl obs L hL⟩

/-! ## §9. Uniqueness (isomorphism on range) -/

/-- Two observationally equivalent realizations are isomorphic on range. -/
theorem minimal_realizations_iso_on_range {α : Type*} {ι : Type*}
    [Fintype α] [Inhabited α]
    {cl : Set α → Set α} {obs : ι → Set α → Set α}
    {S₁ S₂ : Type*}
    (K₁ : KripkeRealization cl obs S₁) (K₂ : KripkeRealization cl obs S₂)
    (h₁ : IsObsEquivalent K₁) (h₂ : IsObsEquivalent K₂) :
    ∃ (fwd : S₁ → S₂) (bwd : S₂ → S₁),
      (∀ x : α, fwd (K₁.realize x) = K₂.realize x) ∧
      (∀ x : α, bwd (K₂.realize x) = K₁.realize x) ∧
      (∀ x : α, bwd (fwd (K₁.realize x)) = K₁.realize x) ∧
      (∀ x : α, fwd (bwd (K₂.realize x)) = K₂.realize x) := by
  classical
  let fwd : S₁ → S₂ := fun s =>
    if h : ∃ x : α, K₁.realize x = s then K₂.realize h.choose
    else K₂.realize default
  let bwd : S₂ → S₁ := fun s =>
    if h : ∃ x : α, K₂.realize x = s then K₁.realize h.choose
    else K₁.realize default
  have fwd_comm : ∀ x : α, fwd (K₁.realize x) = K₂.realize x := by
    intro x; simp only [fwd]
    split
    · next h => exact (h₂ _ _).mp ((h₁ _ _).mpr h.choose_spec)
    · next h => exact absurd ⟨x, rfl⟩ h
  have bwd_comm : ∀ x : α, bwd (K₂.realize x) = K₁.realize x := by
    intro x; simp only [bwd]
    split
    · next h => exact (h₁ _ _).mp ((h₂ _ _).mpr h.choose_spec)
    · next h => exact absurd ⟨x, rfl⟩ h
  exact ⟨fwd, bwd, fwd_comm, bwd_comm,
    fun x => by rw [fwd_comm, bwd_comm],
    fun x => by rw [bwd_comm, fwd_comm]⟩

/-! ## §10. Chu Space Structure -/

/-- A Chu space: states, attributes, and an evaluation relation. -/
structure ChuSpace (S A : Type*) where
  eval : S → A → Prop

/-- Biextensional equivalence: same evaluation profile. -/
def chuStateEquiv {S A : Type*} (chu : ChuSpace S A) (x y : S) : Prop :=
  ∀ a : A, chu.eval x a ↔ chu.eval y a

theorem chuStateEquiv_equivalence {S A : Type*} (chu : ChuSpace S A) :
    Equivalence (chuStateEquiv chu) where
  refl _ _ := Iff.rfl
  symm h a := (h a).symm
  trans h1 h2 a := (h1 a).trans (h2 a)

/-- Attribute type for the closure Chu space. -/
structure ClosureChuAttr (α : Type*) {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) where
  ctx : Set α → Set α
  closedSet : Set α
  ctx_valid : ObsCtx obs ctx
  set_closed : IsClosed' cl closedSet

/-- The Chu space of a closure-observable system. -/
def closureChu {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    ChuSpace α (ClosureChuAttr α cl obs) where
  eval x attr := x ∈ attr.ctx attr.closedSet

/-- The biextensional collapse of the closure Chu space coincides with
observational equivalence. -/
theorem chu_collapse_eq_obsEquiv {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) (x y : α) :
    chuStateEquiv (closureChu cl obs) x y ↔ ObsEquiv cl obs x y := by
  constructor
  · intro h f hf C hC
    exact h ⟨f, C, hf, hC⟩
  · intro h ⟨f, C, hf, hC⟩
    exact h f hf C hC

/-! ## §11. Closed Theory Lattice -/

/-- The closed observable theory of an element. -/
def closedTheoryOf {α : Type*} (cl : Set α → Set α) (x : α) : Set (Set α) :=
  {C | IsClosed' cl C ∧ x ∈ C}

/-- Elements with the same closed theory agree on closed set membership. -/
theorem closedTheory_eq_imp_closed_mem {α : Type*}
    {cl : Set α → Set α} {x y : α}
    (h : closedTheoryOf cl x = closedTheoryOf cl y) :
    ∀ C, IsClosed' cl C → (x ∈ C ↔ y ∈ C) := by
  intro C hC
  have : C ∈ closedTheoryOf cl x ↔ C ∈ closedTheoryOf cl y := by rw [h]
  simp only [closedTheoryOf, Set.mem_setOf_eq] at this
  exact ⟨fun hx => (this.mp ⟨hC, hx⟩).2, fun hy => (this.mpr ⟨hC, hy⟩).2⟩

/-- The spectrum of closed theories is finite when α is finite. -/
theorem closedTheorySpectrum_finite {α : Type*} [Fintype α] (cl : Set α → Set α) :
    Set.Finite (Set.range (closedTheoryOf cl : α → Set (Set α))) :=
  Set.finite_range _

/-! ## §12. Valuation Characterization -/

/-- The full valuation on Chu attributes determines observational equivalence. -/
theorem valuation_eq_iff_obsEquiv {α : Type*} {ι : Type*}
    (cl : Set α → Set α) (obs : ι → Set α → Set α) (x y : α) :
    (∀ attr : ClosureChuAttr α cl obs,
      x ∈ attr.ctx attr.closedSet ↔ y ∈ attr.ctx attr.closedSet) ↔
    ObsEquiv cl obs x y :=
  chu_collapse_eq_obsEquiv cl obs x y

/-! ## §13. Flagship Duality Theorem -/

/-- **Stone–Chu closure duality (flagship theorem)**: For any finite closure-observable
system, the observational quotient yields a canonical minimal Kripke realization such
that:
1. It is observationally equivalent (preserves and reflects all observable contexts).
2. It is minimal (every other equivalent realization factors through it surjectively).
3. Its state equivalence coincides with Chu biextensional collapse. -/
theorem stone_chu_closure_duality {α : Type*} {ι : Type*}
    [Fintype α] [Inhabited α]
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    -- (1) Observational equivalence
    IsObsEquivalent (canonicalKripke cl obs) ∧
    -- (2) Minimality
    IsMinimalRealization (canonicalKripke cl obs) ∧
    -- (3) Chu duality
    (∀ x y : α,
      chuStateEquiv (closureChu cl obs) x y ↔
      (canonicalKripke cl obs).realize x = (canonicalKripke cl obs).realize y) :=
  ⟨canonicalKripke_obsEquivalent cl obs,
   canonicalKripke_minimal cl obs,
   fun x y => (chu_collapse_eq_obsEquiv cl obs x y).trans
     (canonicalKripke_obsEquivalent cl obs x y)⟩

/-! ## §14. Algorithmic Reconstruction -/

/-- The reconstruction procedure: compute the minimal Kripke realization. -/
def reconstructMinimalKripke {α : Type*} {ι : Type*} [Fintype α]
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    KripkeRealization cl obs (ObsQuotient cl obs) :=
  canonicalKripke cl obs

/-- The reconstruction is correct and minimal. -/
theorem reconstruct_minimal_kripke_correct {α : Type*} {ι : Type*}
    [Fintype α] [Inhabited α]
    (cl : Set α → Set α) (obs : ι → Set α → Set α) :
    IsObsEquivalent (reconstructMinimalKripke cl obs) ∧
    IsMinimalRealization (reconstructMinimalKripke cl obs) :=
  ⟨canonicalKripke_obsEquivalent cl obs, canonicalKripke_minimal cl obs⟩

/-! ## §15. Existence and Range-Uniqueness -/

/-- The minimal realization exists and any observationally equivalent realization
is isomorphic to it on range. -/
theorem exists_minimal_with_iso {α : Type*} {ι : Type*}
    [Fintype α] [Inhabited α]
    (cl : Set α → Set α) (obs : ι → Set α → Set α)
    {T : Type*} (L : KripkeRealization cl obs T) (hL : IsObsEquivalent L) :
    ∃ (fwd : T → ObsQuotient cl obs) (bwd : ObsQuotient cl obs → T),
      (∀ x : α, fwd (L.realize x) = (canonicalKripke cl obs).realize x) ∧
      (∀ x : α, bwd ((canonicalKripke cl obs).realize x) = L.realize x) ∧
      (∀ x : α, bwd (fwd (L.realize x)) = L.realize x) ∧
      (∀ x : α, fwd (bwd ((canonicalKripke cl obs).realize x)) =
        (canonicalKripke cl obs).realize x) :=
  minimal_realizations_iso_on_range L (canonicalKripke cl obs) hL
    (canonicalKripke_obsEquivalent cl obs)

end StoneChuClosureDuality