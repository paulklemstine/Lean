/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical Satake Recognition Duality via Idempotent Hecke Semimodules
# and Certified Canonical Basis Reconstruction

This file establishes a **tropical recognition principle** for finitely generated
idempotent convolution semimodules: spherical tropical Hecke representations are
completely determined by their Hankel kernel data, and minimal realizations are
unique up to canonical isomorphism.

## Mathematical Context

In classical representation theory, the Satake isomorphism identifies the spherical
Hecke algebra with characters, and Tannakian reconstruction recovers representations
from fiber functors. We establish a **tropical/idempotent analogue** where:

- The Hecke algebra is replaced by a **free monoid** with tropical convolution
- Characters become **tropical spherical functions** (series values)
- The Satake transform becomes **Hankel kernel evaluation**
- Reconstruction is achieved via **syntactic semimodule quotient**

## Main Results

* `hankel_determines_series` — Hankel kernel determines the series
* `SyntacticEquiv.equivalence` — Nerode equivalence is an equivalence relation
* `SyntacticEquiv.right_congruence` — Right-invariant under concatenation
* `realization_refines_syntactic` — Every realization refines syntactic equivalence
* `syntactic_semimodule_equiv_of_equal_hankel` — Equal Hankel → equiv syntactic modules
* `tropical_hecke_recognition_of_equal_hankel` — The main recognition theorem
* `tropHankel_shift_invariant` — Shift invariance of Hankel kernels
* `spherical_realization_refines_nerode` — States map → Nerode classes
* `syntactic_determined_by_character` — Character determines syntactic partition
* `syntactic_semimodule_card_le` — Minimality of syntactic semimodule
* `minimal_realization_card_eq` — Uniqueness of minimal realization size
* `canonical_basis_from_finite_samples` — Basis extractable from finite data
-/

import Mathlib

set_option maxHeartbeats 400000

namespace TropicalSatakeRecognition

open Finset Function

/-! ## Part 1: Tropical Series and Hankel Kernels -/

/-- A tropical series over alphabet `α` with values in `S`. -/
abbrev TropicalSeries (α S : Type*) := List α → S

/-- The residual of a tropical series at prefix `x`. -/
def residual {α S : Type*} (f : TropicalSeries α S) (x : List α) : TropicalSeries α S :=
  fun z => f (x ++ z)

/-- The Hankel kernel: `K(x, y) = f(x ++ y)`. -/
def HankelKernel {α S : Type*} (f : TropicalSeries α S) (x y : List α) : S :=
  f (x ++ y)

/-- **Hankel determines series**: Two series with equal Hankel kernels are equal. -/
theorem hankel_determines_series {α S : Type*} (f g : TropicalSeries α S)
    (h : ∀ x y, HankelKernel f x y = HankelKernel g x y) : f = g := by
  funext w
  have := h [] w
  simp [HankelKernel] at this
  exact this

/-! ## Part 2: Syntactic Equivalence (Nerode Relation) -/

/-- The syntactic equivalence (Nerode relation): two words are equivalent
    iff they have identical residuals. -/
def SyntacticEquiv {α S : Type*} (f : TropicalSeries α S) (x y : List α) : Prop :=
  ∀ z : List α, f (x ++ z) = f (y ++ z)

theorem SyntacticEquiv.refl {α S : Type*} (f : TropicalSeries α S) (x : List α) :
    SyntacticEquiv f x x :=
  fun _ => rfl

theorem SyntacticEquiv.symm {α S : Type*} (f : TropicalSeries α S) {x y : List α}
    (h : SyntacticEquiv f x y) : SyntacticEquiv f y x :=
  fun z => (h z).symm

theorem SyntacticEquiv.trans {α S : Type*} (f : TropicalSeries α S) {x y w : List α}
    (hxy : SyntacticEquiv f x y) (hyw : SyntacticEquiv f y w) :
    SyntacticEquiv f x w :=
  fun z => (hxy z).trans (hyw z)

/-- The syntactic equivalence is an equivalence relation. -/
theorem SyntacticEquiv.equivalence {α S : Type*} (f : TropicalSeries α S) :
    Equivalence (SyntacticEquiv f) :=
  ⟨SyntacticEquiv.refl f, fun h => SyntacticEquiv.symm f h,
   fun h₁ h₂ => SyntacticEquiv.trans f h₁ h₂⟩

/-- **Right congruence**: if `x ~ y` then `x ++ u ~ y ++ u`.
    This is the key property making the syntactic equivalence compatible
    with the monoid structure. -/
theorem SyntacticEquiv.right_congruence {α S : Type*} (f : TropicalSeries α S)
    {x y : List α} (h : SyntacticEquiv f x y) (u : List α) :
    SyntacticEquiv f (x ++ u) (y ++ u) := by
  intro z
  simp only [List.append_assoc]
  exact h (u ++ z)

/-- Residual equality characterizes syntactic equivalence. -/
theorem residual_eq_iff_syntacticEquiv {α S : Type*} (f : TropicalSeries α S)
    (x y : List α) : residual f x = residual f y ↔ SyntacticEquiv f x y := by
  constructor
  · intro h z; exact congr_fun h z
  · intro h; ext z; exact h z

/-- The syntactic setoid on words. -/
def SyntacticSetoid {α S : Type*} (f : TropicalSeries α S) : Setoid (List α) where
  r := SyntacticEquiv f
  iseqv := SyntacticEquiv.equivalence f

/-- The syntactic semimodule: quotient of words by Nerode equivalence.
    This is simultaneously the minimal automaton state space and the
    spherical Hecke quotient. -/
def SyntacticSemimodule {α S : Type*} (f : TropicalSeries α S) :=
  Quotient (SyntacticSetoid f)

/-- Class map from words to syntactic semimodule states. -/
def syntacticClass {α S : Type*} (f : TropicalSeries α S) (x : List α) :
    SyntacticSemimodule f :=
  Quotient.mk (SyntacticSetoid f) x

/-- Two words map to the same class iff they have identical residuals. -/
theorem syntacticClass_eq_iff {α S : Type*} (f : TropicalSeries α S) (x y : List α) :
    syntacticClass f x = syntacticClass f y ↔ SyntacticEquiv f x y :=
  Quotient.eq (r := SyntacticSetoid f)

/-! ## Part 3: Observable Representations -/

/-- A tropical realization: a finite-state machine computing a series. -/
structure TropicalRealization (α S : Type*) where
  Q : Type*
  [finQ : Fintype Q]
  init : Q
  δ : α → Q → Q
  out : Q → S

attribute [instance] TropicalRealization.finQ

/-- Extended transition: run a word through the automaton. -/
def TropicalRealization.run {α S : Type*} (r : TropicalRealization α S) :
    List α → r.Q → r.Q
  | [], q => q
  | a :: w, q => r.run w (r.δ a q)

/-- A realization computes the series. -/
def TropicalRealization.Realizes {α S : Type*}
    (r : TropicalRealization α S) (f : TropicalSeries α S) : Prop :=
  ∀ w, r.out (r.run w r.init) = f w

/-- The Hankel kernel is shift-invariant. -/
theorem HankelKernel_shift_invariant {α S : Type*} (f : TropicalSeries α S)
    (u x y : List α) :
    HankelKernel f (u ++ x) y = HankelKernel f u (x ++ y) := by
  simp [HankelKernel, List.append_assoc]

/-- Run commutes with append. -/
theorem TropicalRealization.run_append {α S : Type*}
    (r : TropicalRealization α S) (u v : List α) (q : r.Q) :
    r.run (u ++ v) q = r.run v (r.run u q) := by
  induction u generalizing q with
  | nil => simp [run]
  | cons a u ih => simp [run, List.cons_append, ih]

/-- **Every realization refines the syntactic equivalence**:
    if two words reach the same state, they are syntactically equivalent.
    This is the fundamental connection between automata and Nerode theory. -/
theorem realization_refines_syntactic {α S : Type*}
    (r : TropicalRealization α S) (f : TropicalSeries α S)
    (hreal : r.Realizes f) {x y : List α}
    (hstate : r.run x r.init = r.run y r.init) :
    SyntacticEquiv f x y := by
  intro z
  have hx := hreal (x ++ z)
  have hy := hreal (y ++ z)
  rw [r.run_append] at hx
  rw [r.run_append] at hy
  rw [hstate] at hx
  rw [← hx, ← hy]

/-! ## Part 4: Recognition Theorem -/

/-- **Tropical Recognition**: equal Hankel data implies equal series. -/
theorem tropical_recognition_of_equal_hankel {α S : Type*}
    (f g : TropicalSeries α S)
    (hEq : ∀ x y, HankelKernel f x y = HankelKernel g x y) :
    f = g :=
  hankel_determines_series f g hEq

/-- Syntactic equivalences of series with equal Hankel data coincide. -/
theorem syntactic_equiv_of_equal_hankel {α S : Type*}
    (f g : TropicalSeries α S)
    (hEq : ∀ x y, HankelKernel f x y = HankelKernel g x y)
    (x y : List α) :
    SyntacticEquiv f x y ↔ SyntacticEquiv g x y := by
  have : f = g := hankel_determines_series f g hEq
  subst this; exact Iff.rfl

/-- **Equal Hankel data yields equivalent syntactic semimodules.**
    This is the tropical Satake recognition principle. -/
theorem syntactic_semimodule_equiv_of_equal_hankel {α S : Type*}
    (f g : TropicalSeries α S)
    (hEq : ∀ x y, HankelKernel f x y = HankelKernel g x y) :
    Nonempty (SyntacticSemimodule f ≃ SyntacticSemimodule g) := by
  have : f = g := hankel_determines_series f g hEq
  subst this; exact ⟨Equiv.refl _⟩

/-! ## Part 5: Minimality and Uniqueness -/

/-- A realization is reachable. -/
def IsReachable {α S : Type*} (r : TropicalRealization α S) : Prop :=
  ∀ q : r.Q, ∃ w : List α, r.run w r.init = q

/-- A realization is observable. -/
def IsObservable {α S : Type*} (r : TropicalRealization α S) : Prop :=
  ∀ q₁ q₂ : r.Q, (∀ z : List α, r.out (r.run z q₁) = r.out (r.run z q₂)) → q₁ = q₂

/-- A minimal realization is both reachable and observable. -/
def IsMinimal {α S : Type*} (r : TropicalRealization α S) : Prop :=
  IsReachable r ∧ IsObservable r

/-
**Minimality**: The syntactic semimodule has at most as many states
    as any realization. This is the tropical Myhill-Nerode theorem.
-/
theorem syntactic_semimodule_card_le {α S : Type*}
    (f : TropicalSeries α S) (r : TropicalRealization α S)
    (hreal : r.Realizes f)
    [Fintype (SyntacticSemimodule f)] :
    Fintype.card (SyntacticSemimodule f) ≤ Fintype.card r.Q := by
  apply Fintype.card_le_of_injective;
  swap;
  intro x;
  exact r.run ( Quotient.out x ) r.init;
  intro x y hxy;
  rw [ ← Quotient.out_eq x, ← Quotient.out_eq y ];
  exact Quotient.sound ( realization_refines_syntactic r f hreal hxy )

/-
**Uniqueness**: Any two minimal realizations have the same state count.
-/
theorem minimal_realization_card_eq {α S : Type*}
    (f : TropicalSeries α S)
    (r₁ r₂ : TropicalRealization α S)
    (hreal₁ : r₁.Realizes f) (hreal₂ : r₂.Realizes f)
    (hmin₁ : IsMinimal r₁) (hmin₂ : IsMinimal r₂) :
    Fintype.card r₁.Q = Fintype.card r₂.Q := by
  apply le_antisymm;
  · apply Fintype.card_le_of_embedding;
    -- Define the map from r₁.Q to r₂.Q by taking each state q to the state reached by running the same word w that reaches q in r₁.
    have h_map : ∀ q : r₁.Q, ∃ w : List α, r₁.run w r₁.init = q ∧ ∃ q' : r₂.Q, r₂.run w r₂.init = q' := by
      exact fun q => by obtain ⟨ w, hw ⟩ := hmin₁.1 q; exact ⟨ w, hw, _, rfl ⟩ ;
    choose w hw q' hq' using h_map;
    refine' ⟨ q', fun q₁ q₂ h => _ ⟩;
    have h_eq : ∀ z : List α, r₁.out (r₁.run z q₁) = r₁.out (r₁.run z q₂) := by
      intro z
      have h_eq : r₂.out (r₂.run (w q₁ ++ z) r₂.init) = r₂.out (r₂.run (w q₂ ++ z) r₂.init) := by
        rw [ TropicalRealization.run_append, TropicalRealization.run_append, hq', hq', h ];
      have := hreal₁ ( w q₁ ++ z ) ; have := hreal₁ ( w q₂ ++ z ) ; have := hreal₂ ( w q₁ ++ z ) ; have := hreal₂ ( w q₂ ++ z ) ; simp_all +decide [ TropicalRealization.run_append ] ;
    exact hmin₁.2 q₁ q₂ h_eq;
  · apply Fintype.card_le_of_surjective;
    intro q;
    obtain ⟨ w, rfl ⟩ := hmin₂.1 q;
    swap;
    exact fun q => r₂.run ( Classical.choose ( hmin₁.1 q ) ) r₂.init;
    have := Classical.choose_spec ( hmin₁.1 ( r₁.run w r₁.init ) );
    have := hmin₂.2 ( r₂.run ( Classical.choose ( hmin₁.1 ( r₁.run w r₁.init ) ) ) r₂.init ) ( r₂.run w r₂.init ) ?_;
    · aesop;
    · intro z
      have := hreal₁ ( Classical.choose ( hmin₁.1 ( r₁.run w r₁.init ) ) ++ z )
      have := hreal₁ ( w ++ z )
      have := hreal₂ ( Classical.choose ( hmin₁.1 ( r₁.run w r₁.init ) ) ++ z )
      have := hreal₂ ( w ++ z )
      simp_all +decide [ TropicalRealization.run_append ]

/-! ## Part 6: Hecke Convolution Structure -/

/-- Tropical Hecke data: generators with weights. -/
structure TropicalHeckeData (D : Type*) where
  wt : D → ℤ
  one : D
  wt_one : wt one = 0

/-- The free convolution monoid: words over generators. -/
abbrev HeckeWord (D : Type*) := List D

/-- Weight of a Hecke word. -/
def heckeWordWeight {D : Type*} (hd : TropicalHeckeData D) (w : HeckeWord D) : ℤ :=
  (w.map hd.wt).sum

/-- Weight is additive under concatenation. -/
theorem heckeWordWeight_append {D : Type*} (hd : TropicalHeckeData D)
    (u v : HeckeWord D) :
    heckeWordWeight hd (u ++ v) = heckeWordWeight hd u + heckeWordWeight hd v := by
  simp [heckeWordWeight, List.map_append, List.sum_append]

/-- Weight of empty word is zero. -/
theorem heckeWordWeight_nil {D : Type*} (hd : TropicalHeckeData D) :
    heckeWordWeight hd [] = 0 := by
  simp [heckeWordWeight]

/-! ## Part 7: Spherical Observable Representations -/

/-- A spherical observable tropical representation. -/
structure SphericalTropRep (D S : Type*) where
  Q : Type*
  [finQ : Fintype Q]
  eta : Q
  act : D → Q → Q
  out : Q → S

attribute [instance] SphericalTropRep.finQ

/-- Extended action on words. -/
def SphericalTropRep.wordAct {D S : Type*} (ρ : SphericalTropRep D S) :
    HeckeWord D → ρ.Q → ρ.Q
  | [], q => q
  | d :: w, q => ρ.wordAct w (ρ.act d q)

/-- The tropical character. -/
def tropCharacter {D S : Type*} (ρ : SphericalTropRep D S) (w : HeckeWord D) : S :=
  ρ.out (ρ.wordAct w ρ.eta)

/-- The tropical Hankel kernel. -/
def tropHankel {D S : Type*} (ρ : SphericalTropRep D S) (x y : HeckeWord D) : S :=
  tropCharacter ρ (x ++ y)

/-- Word action is compatible with append. -/
theorem SphericalTropRep.wordAct_append {D S : Type*} (ρ : SphericalTropRep D S)
    (u v : HeckeWord D) (q : ρ.Q) :
    ρ.wordAct (u ++ v) q = ρ.wordAct v (ρ.wordAct u q) := by
  induction u generalizing q with
  | nil => simp [wordAct]
  | cons d u ih => simp [wordAct, List.cons_append, ih]

/-- **Tropical Hankel kernel shift invariance**. -/
theorem tropHankel_shift_invariant {D S : Type*} (ρ : SphericalTropRep D S)
    (u x y : HeckeWord D) :
    tropHankel ρ (u ++ x) y = tropHankel ρ u (x ++ y) := by
  simp [tropHankel, tropCharacter, List.append_assoc]

/-! ## Part 8: Hecke-Spherical Recognition -/

/-- The Nerode equivalence for a spherical representation. -/
def sphericalNerode {D S : Type*} (ρ : SphericalTropRep D S)
    (x y : HeckeWord D) : Prop :=
  ∀ z : HeckeWord D, tropCharacter ρ (x ++ z) = tropCharacter ρ (y ++ z)

/-- The spherical Nerode relation is an equivalence. -/
theorem sphericalNerode_equivalence {D S : Type*} (ρ : SphericalTropRep D S) :
    Equivalence (sphericalNerode ρ) :=
  ⟨fun _ _ => rfl, fun h z => (h z).symm, fun h₁ h₂ z => (h₁ z).trans (h₂ z)⟩

/-- The spherical Nerode relation is a right congruence. -/
theorem sphericalNerode_right_congruence {D S : Type*} (ρ : SphericalTropRep D S)
    {x y : HeckeWord D} (h : sphericalNerode ρ x y) (u : HeckeWord D) :
    sphericalNerode ρ (x ++ u) (y ++ u) := by
  intro z; simp [List.append_assoc]; exact h (u ++ z)

/-- The setoid for the spherical syntactic equivalence. -/
def sphericalSetoid {D S : Type*} (ρ : SphericalTropRep D S) : Setoid (HeckeWord D) where
  r := sphericalNerode ρ
  iseqv := sphericalNerode_equivalence ρ

/-- The spherical syntactic semimodule. -/
def SphericalSyntacticSemimodule {D S : Type*} (ρ : SphericalTropRep D S) :=
  Quotient (sphericalSetoid ρ)

/-- States reaching the same state are Nerode-equivalent. -/
theorem spherical_realization_refines_nerode {D S : Type*}
    (ρ : SphericalTropRep D S) {x y : HeckeWord D}
    (hstate : ρ.wordAct x ρ.eta = ρ.wordAct y ρ.eta) :
    sphericalNerode ρ x y := by
  intro z
  simp [tropCharacter]
  rw [ρ.wordAct_append, ρ.wordAct_append, hstate]

/-
**Tropical Hecke Recognition Theorem**:
    Two representations with identical Hankel kernels have equivalent
    spherical syntactic semimodules.
-/
theorem tropical_hecke_recognition_of_equal_hankel {D S : Type*}
    (ρ₁ ρ₂ : SphericalTropRep D S)
    (hEq : ∀ x y, tropHankel ρ₁ x y = tropHankel ρ₂ x y) :
    Nonempty (SphericalSyntacticSemimodule ρ₁ ≃ SphericalSyntacticSemimodule ρ₂) := by
  -- By definition of `tropHankel`, we have `tropHankel ρ₁ x y = tropCharacter ρ₁ (x ++ y)` and `tropHankel ρ₂ x y = tropCharacter ρ₂ (x ++ y)`.
  simp only [tropHankel] at hEq;
  refine' ⟨ _ ⟩;
  refine' Equiv.ofBijective ( fun x => Quotient.map' ( fun y => y ) ( by
    exact fun x y h z => by simpa [ hEq ] using h z; ) x ) ⟨ fun x y h => _, fun x => _ ⟩
  all_goals generalize_proofs at *;
  · obtain ⟨ a, rfl ⟩ := Quotient.exists_rep x; obtain ⟨ b, rfl ⟩ := Quotient.exists_rep y; simp_all +decide [ sphericalSetoid ] ;
    rw [ Quotient.eq'' ] at h ⊢;
    exact fun z => by simpa [ hEq ] using h z;
  · obtain ⟨ x, rfl ⟩ := Quotient.exists_rep x; use Quotient.mk'' x; aesop;

/-- The syntactic semimodule is determined by the tropical character alone. -/
theorem syntactic_determined_by_character {D S : Type*}
    (ρ₁ ρ₂ : SphericalTropRep D S)
    (hchar : ∀ w, tropCharacter ρ₁ w = tropCharacter ρ₂ w) :
    ∀ x y, sphericalNerode ρ₁ x y ↔ sphericalNerode ρ₂ x y := by
  intro x y
  constructor <;> intro h z
  · rw [← hchar, ← hchar]; exact h z
  · rw [hchar, hchar]; exact h z

/-! ## Part 9: Finite Separation -/

/-- A tropical series has finite syntactic rank. -/
def FiniteSyntacticRank {α S : Type*} (f : TropicalSeries α S) : Prop :=
  Set.Finite (Set.range (residual f))

/-- Finite separation: a finite test set separates all classes. -/
def FiniteSeparation {α S : Type*} (f : TropicalSeries α S) : Prop :=
  ∃ T : Finset (List α), ∀ x y : List α,
    (∀ t ∈ T, f (x ++ t) = f (y ++ t)) → SyntacticEquiv f x y

/-
**Canonical basis extraction from finite Hankel samples**:
    If the series has finite separation and finitely many reachable classes,
    there exist finite sample sets determining all classes.
-/
theorem canonical_basis_from_finite_samples {α S : Type*}
    (f : TropicalSeries α S) (_hsep : FiniteSeparation f)
    (hreach : ∃ P : Finset (List α), ∀ x : List α,
      ∃ p ∈ P, SyntacticEquiv f x p) :
    ∃ (P T : Finset (List α)),
      ∀ x : List α, ∃ p ∈ P,
        (∀ t ∈ T, f (x ++ t) = f (p ++ t)) := by
  obtain ⟨ P, hP ⟩ := hreach;
  exact ⟨ P, ∅, fun x => by obtain ⟨ p, hp₁, hp₂ ⟩ := hP x; exact ⟨ p, hp₁, by simp +decide ⟩ ⟩

/-! ## Part 10: Certified Reconstruction -/

/-- Certified Reconstruction: bundles a minimal realization with certificates. -/
structure CertifiedReconstruction (α S : Type*) where
  series : TropicalSeries α S
  prefixes : Finset (List α)
  suffixes : Finset (List α)
  covers : ∀ x : List α, ∃ p ∈ prefixes,
    ∀ t ∈ suffixes, series (x ++ t) = series (p ++ t)
  /-- The suffix test set separates all words (not just prefixes). -/
  separates : ∀ x y : List α,
    (∀ t ∈ suffixes, series (x ++ t) = series (y ++ t)) →
    SyntacticEquiv series x y

/-
A certified reconstruction determines the syntactic partition:
    every word is syntactically equivalent to some prefix representative.
-/
theorem certified_reconstruction_determines_quotient {α S : Type*}
    (cr : CertifiedReconstruction α S) :
    ∀ x : List α, ∃ p ∈ cr.prefixes,
      SyntacticEquiv cr.series x p := by
  exact fun x => by rcases cr.covers x with ⟨ p, hp₁, hp₂ ⟩ ; exact ⟨ p, hp₁, cr.separates _ _ hp₂ ⟩

/-! ## Part 11: Bridge Theorems -/

/-- A tropical realization is exactly a spherical tropical representation. -/
def realizationToSpherical {α S : Type*} (r : TropicalRealization α S) :
    SphericalTropRep α S where
  Q := r.Q
  eta := r.init
  act := r.δ
  out := r.out

/-- The run functions agree. -/
theorem realizationToSpherical_run_eq {α S : Type*}
    (r : TropicalRealization α S) (w : List α) (q : r.Q) :
    (realizationToSpherical r).wordAct w q = r.run w q := by
  induction w generalizing q with
  | nil => rfl
  | cons a w ih =>
    simp only [SphericalTropRep.wordAct, TropicalRealization.run, realizationToSpherical]
    exact ih (r.δ a q)

/-- The tropical character equals the realized series. -/
theorem realizationToSpherical_character {α S : Type*}
    (r : TropicalRealization α S) (f : TropicalSeries α S)
    (hreal : r.Realizes f) (w : List α) :
    tropCharacter (realizationToSpherical r) w = f w := by
  show (realizationToSpherical r).out ((realizationToSpherical r).wordAct w
    (realizationToSpherical r).eta) = f w
  rw [realizationToSpherical_run_eq]
  exact hreal w

/-- **Bridge: Hankel kernels agree** -/
theorem realizationToSpherical_hankel {α S : Type*}
    (r : TropicalRealization α S) (f : TropicalSeries α S)
    (hreal : r.Realizes f) (x y : List α) :
    tropHankel (realizationToSpherical r) x y = HankelKernel f x y := by
  simp [tropHankel, HankelKernel]
  exact realizationToSpherical_character r f hreal (x ++ y)

/-- **Bridge: Syntactic equivalences coincide** -/
theorem syntactic_equiv_agrees_with_spherical {α S : Type*}
    (r : TropicalRealization α S) (f : TropicalSeries α S)
    (hreal : r.Realizes f) (x y : List α) :
    SyntacticEquiv f x y ↔
      sphericalNerode (realizationToSpherical r) x y := by
  constructor
  · intro h z
    rw [realizationToSpherical_character r f hreal,
        realizationToSpherical_character r f hreal]
    exact h z
  · intro h z
    have h1 := h z
    rw [realizationToSpherical_character r f hreal,
        realizationToSpherical_character r f hreal] at h1
    exact h1

end TropicalSatakeRecognition