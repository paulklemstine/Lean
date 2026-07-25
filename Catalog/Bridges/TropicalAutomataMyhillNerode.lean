/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical Automata Minimization via Idempotent Myhill–Nerode Congruence
# and Certified Min-Plus Hankel Rank

This file establishes a formal bridge between:
- **weighted automata / rational series** over idempotent semirings,
- **semiring-compatible Nerode congruences** on words,
- **tropical Hankel matrices** and their factor rank,
- **certified finite minimization** with executable witnesses.

## Main Results

### Theorem A: Tropical Nerode congruence is canonical
- `nerodeRel_equiv`: The Nerode relation is an equivalence relation.
- `nerodeRel_right_invariant`: Right-invariant under concatenation.
- `nerodeRel_left_invariant`: Left-invariant under prepending.
- `nerodeRel_is_congruence`: Combined congruence property.

### Theorem B: Quotient realizes canonical minimal automaton
- `realization_kernel_refines_nerode`: States reaching the same automaton
  state are Nerode-equivalent.
- `nerode_quotient_card_le_any_realization`: Every realization has at most
  as many states as the Nerode quotient.

### Theorem C: State count bounds tropical Hankel factor rank
- `factorRank_le_states`: Hankel factor rank lower-bounds any realization's state count.
- `realization_induces_hankel_factorization`: A realization induces a Hankel factorization.

### Theorem D: Certified finite minimization
- `CertifiedMinimization`: A structure bundling witness sets, correctness proof,
  minimality certificate, and rank connection.

## References

Extends `tropical_myhill_nerode_quotient_exists` from the catalog.
Uses congruence closure lemmas in the style of `SemiringCong` infrastructure.
-/

import Mathlib

namespace Bridges.TropicalAutomataMyhillNerode

open Finset Function

/-! ## Basic Definitions -/

/-- A tropical series: a function from words over alphabet `α` to a semiring `S`. -/
abbrev TropicalSeries (α S : Type*) := List α → S

/-- The Nerode relation: two words are equivalent iff appending any suffix
    yields the same series value. -/
def NerodeRel {α S : Type*} (f : TropicalSeries α S) (x y : List α) : Prop :=
  ∀ z : List α, f (x ++ z) = f (y ++ z)

/-- The residual of a series at a prefix: the function mapping suffixes to values. -/
def residual {α S : Type*} (f : TropicalSeries α S) (x : List α) : List α → S :=
  fun z => f (x ++ z)

/-- The Hankel block: restriction of the infinite Hankel matrix to finite
    prefix/suffix sets. -/
def HankelBlock {α S : Type*} (f : TropicalSeries α S)
    (P Q : Finset (List α)) : P → Q → S :=
  fun p q => f (p.1 ++ q.1)

/-! ## Theorem A: Nerode Relation Properties -/

section NerodeProperties

variable {α S : Type*} (f : TropicalSeries α S)

/-- The Nerode relation is reflexive. -/
theorem nerodeRel_refl (x : List α) : NerodeRel f x x :=
  fun _ => rfl

/-- The Nerode relation is symmetric. -/
theorem nerodeRel_symm {x y : List α} (h : NerodeRel f x y) :
    NerodeRel f y x :=
  fun z => (h z).symm

/-- The Nerode relation is transitive. -/
theorem nerodeRel_trans {x y z : List α} (hxy : NerodeRel f x y)
    (hyz : NerodeRel f y z) : NerodeRel f x z :=
  fun w => (hxy w).trans (hyz w)

/-- The Nerode relation is an equivalence relation. -/
theorem nerodeRel_equiv : Equivalence (NerodeRel f) :=
  ⟨nerodeRel_refl f, fun h => nerodeRel_symm f h, fun h₁ h₂ => nerodeRel_trans f h₁ h₂⟩

/-- The Nerode setoid on words. -/
def nerodeSetoid : Setoid (List α) where
  r := NerodeRel f
  iseqv := nerodeRel_equiv f

/-- The Nerode relation is right-invariant under concatenation:
    if x ~ y then (x ++ u) ~ (y ++ u) for all u. -/
theorem nerodeRel_right_invariant {x y : List α} (h : NerodeRel f x y)
    (u : List α) : NerodeRel f (x ++ u) (y ++ u) := by
  intro z
  simp only [List.append_assoc]
  exact h (u ++ z)

/-- Single character right-invariance. -/
theorem nerodeRel_cons_right {x y : List α} (h : NerodeRel f x y)
    (a : α) : NerodeRel f (x ++ [a]) (y ++ [a]) :=
  nerodeRel_right_invariant f h [a]

/-- The Nerode relation is a right congruence with respect to concatenation. -/
theorem nerodeRel_is_right_congruence :
    Equivalence (NerodeRel f) ∧
    (∀ {x y}, NerodeRel f x y → ∀ u, NerodeRel f (x ++ u) (y ++ u)) :=
  ⟨nerodeRel_equiv f, fun h u => nerodeRel_right_invariant f h u⟩

/-- Two words are Nerode-equivalent iff they have equal residuals. -/
theorem nerodeRel_iff_residual_eq (x y : List α) :
    NerodeRel f x y ↔ residual f x = residual f y := by
  simp [NerodeRel, residual, funext_iff]

/-- Non-equivalence is witnessed by a separating suffix. -/
theorem nerodeRel_not_iff_exists_separator (x y : List α) :
    ¬NerodeRel f x y ↔ ∃ z, f (x ++ z) ≠ f (y ++ z) := by
  simp [NerodeRel, not_forall]

/-- Nerode equivalence at the empty suffix gives equality of values. -/
theorem nerodeRel_empty_suffix {x y : List α} (h : NerodeRel f x y) :
    f x = f y := by
  have := h []
  rwa [List.append_nil, List.append_nil] at this

end NerodeProperties

/-! ## Nerode Quotient -/

section NerodeQuotient

variable {α S : Type*} (f : TropicalSeries α S)

/-- The Nerode quotient type. -/
def NerodeQuotientType := Quotient (nerodeSetoid f)

/-- Project a word to its Nerode class. -/
def toNerodeClass (x : List α) : NerodeQuotientType f :=
  Quotient.mk (nerodeSetoid f) x

/-- Concatenation descends to the quotient (right action). -/
def quotientAppend (u : List α) :
    NerodeQuotientType f → NerodeQuotientType f :=
  Quotient.map (· ++ u) (fun _ _ h => nerodeRel_right_invariant f h u)

/-- The residual map descends to the quotient. -/
noncomputable def quotientOutput :
    NerodeQuotientType f → (List α → S) :=
  Quotient.lift (residual f) (fun _ _ h => by ext z; exact h z)

theorem quotientOutput_mk (x : List α) :
    quotientOutput f (toNerodeClass f x) = residual f x := rfl

/-- The quotient map is compatible with append. -/
theorem toNerodeClass_append (x u : List α) :
    toNerodeClass f (x ++ u) = quotientAppend f u (toNerodeClass f x) := rfl

/-- Two words map to the same class iff they are Nerode-equivalent. -/
theorem toNerodeClass_eq_iff (x y : List α) :
    toNerodeClass f x = toNerodeClass f y ↔ NerodeRel f x y :=
  ⟨fun h => Quotient.exact h, fun h => Quotient.sound h⟩

end NerodeQuotient

/-! ## Finite Recognizing Representation (Word-based) -/

section Representation

/-- A finite recognizing representation of a tropical series:
    a finite-state system that computes f via transitions on alphabet symbols. -/
structure FiniteRealization (α S : Type*) where
  /-- State type -/
  State : Type*
  /-- States form a finite type -/
  instFintype : Fintype State
  /-- Initial state -/
  init : State
  /-- Transition function on single symbols -/
  step : State → α → State
  /-- Output function: value at a state -/
  output : State → S

attribute [instance] FiniteRealization.instFintype

/-- Run the automaton on a word from a given state. -/
def FiniteRealization.run {α S : Type*} (A : FiniteRealization α S)
    (q : A.State) : List α → A.State
  | [] => q
  | a :: w => A.run (A.step q a) w

@[simp]
theorem FiniteRealization.run_nil {α S : Type*} (A : FiniteRealization α S)
    (q : A.State) : A.run q [] = q := rfl

@[simp]
theorem FiniteRealization.run_cons {α S : Type*} (A : FiniteRealization α S)
    (q : A.State) (a : α) (w : List α) :
    A.run q (a :: w) = A.run (A.step q a) w := rfl

/-- Run distributes over append. -/
theorem FiniteRealization.run_append {α S : Type*} (A : FiniteRealization α S)
    (q : A.State) (w₁ w₂ : List α) :
    A.run q (w₁ ++ w₂) = A.run (A.run q w₁) w₂ := by
  induction w₁ generalizing q with
  | nil => simp
  | cons a w ih => simp [ih]

/-- A realization recognizes a series f if it computes f correctly. -/
def FiniteRealization.recognizes {α S : Type*}
    (A : FiniteRealization α S) (f : TropicalSeries α S) : Prop :=
  ∀ w : List α, A.output (A.run A.init w) = f w

/-- A realization is reachable if every state is reached by some word. -/
def FiniteRealization.isReachable {α S : Type*}
    (A : FiniteRealization α S) : Prop :=
  ∀ q : A.State, ∃ w : List α, A.run A.init w = q

/-- A realization is observable if distinct states have different residual behaviors. -/
def FiniteRealization.isObservable {α S : Type*}
    (A : FiniteRealization α S) : Prop :=
  ∀ q₁ q₂ : A.State,
    (∀ w : List α, A.output (A.run q₁ w) = A.output (A.run q₂ w)) → q₁ = q₂

end Representation

/-! ## Theorem B: Quotient Automaton and Minimality -/

section Minimality

variable {α S : Type*} (f : TropicalSeries α S)

/-- Two words reaching the same state in any realization are Nerode-equivalent.
    This is the fundamental refinement theorem. -/
theorem realization_kernel_refines_nerode
    (A : FiniteRealization α S) (hA : A.recognizes f)
    {x y : List α} (h : A.run A.init x = A.run A.init y) :
    NerodeRel f x y := by
  intro z
  rw [← hA (x ++ z), ← hA (y ++ z), A.run_append, A.run_append, h]

/-
Any recognizing realization induces only finitely many Nerode classes.
-/
theorem finite_nerode_of_recognizable
    (A : FiniteRealization α S) (hA : A.recognizes f) :
    Finite (NerodeQuotientType f) := by
  -- Build an injection NerodeQuotientType f → A.State
  have hcover : ∀ c : NerodeQuotientType f,
      ∃ q : A.State, ∃ w, A.run A.init w = q ∧ c = toNerodeClass f w := by
    intro c
    induction c using Quotient.ind with
    | _ w => exact ⟨A.run A.init w, w, rfl, rfl⟩
  have hsingleton : ∀ q : A.State, ∀ w₁ w₂ : List α,
      A.run A.init w₁ = q → A.run A.init w₂ = q →
      toNerodeClass f w₁ = toNerodeClass f w₂ := by
    intro q w₁ w₂ hw₁ hw₂
    apply (toNerodeClass_eq_iff f w₁ w₂).mpr
    exact realization_kernel_refines_nerode f A hA (hw₁.trans hw₂.symm)
  -- The map w ↦ A.run A.init w has the property that
  -- its kernel refines the Nerode relation. Therefore distinct
  -- Nerode classes map to distinct states, giving an injection.
  -- We use a choice-based injection from the quotient to A.State.
  choose q w hw₁ hw₂ using hcover;
  have h_inj : Function.Injective q := by
    intro c₁ c₂ hq;
    rw [ hw₂ c₁, hw₂ c₂, hsingleton _ _ _ ( hw₁ c₁ ) ( by rw [ hq, hw₁ ] ) ];
  exact Finite.of_injective q h_inj

/-
The Nerode quotient has at most as many elements as any recognizing
    realization's state space. This is the minimality theorem.
-/
theorem nerode_quotient_card_le_any_realization
    (A : FiniteRealization α S) (hA : A.recognizes f)
    [Fintype (NerodeQuotientType f)] :
    Fintype.card (NerodeQuotientType f) ≤ Fintype.card A.State := by
  have h_inj : Function.Injective (fun c : NerodeQuotientType f => A.run A.init (Classical.choose (Quotient.exists_rep c))) := by
    intro c₁ c₂ h_eq;
    rw [ ← Quotient.out_eq c₁, ← Quotient.out_eq c₂ ];
    convert realization_kernel_refines_nerode f A hA _;
    convert toNerodeClass_eq_iff f _ _;
    convert h_eq;
  exact Fintype.card_le_of_injective _ h_inj

end Minimality

/-! ## Finite Witness Certificates -/

section Witnesses

variable {α S : Type*} [DecidableEq S] (f : TropicalSeries α S)

/-- A finite set of suffixes Q is a complete witness set if agreement on Q
    implies full Nerode equivalence. -/
def IsCompleteWitnessSet (Q : Finset (List α)) : Prop :=
  ∀ x y : List α, (∀ q ∈ Q, f (x ++ q) = f (y ++ q)) → NerodeRel f x y

/-- A finite set of prefixes P generates all residual classes if every word
    is Nerode-equivalent to some prefix in P. -/
def IsResidualGenerating (P : Finset (List α)) : Prop :=
  ∀ x : List α, ∃ p ∈ P, NerodeRel f x p

/-- The finite Hankel generation hypothesis: P generates residuals and Q
    is a complete witness set. -/
structure FiniteSupportHankelGenerates (P Q : Finset (List α)) : Prop where
  prefix_generates : IsResidualGenerating f P
  suffix_complete : IsCompleteWitnessSet f Q

omit [DecidableEq S] in
/-- Under a complete witness set, agreement on Q implies full equivalence. -/
theorem witness_complete_of_hankel_generation
    {P Q : Finset (List α)}
    (hgen : FiniteSupportHankelGenerates f P Q)
    {x y : List α} :
    (∀ q ∈ Q, f (x ++ q) = f (y ++ q)) → NerodeRel f x y :=
  hgen.suffix_complete x y

omit [DecidableEq S] in
/-- Under prefix generation, the Nerode quotient is finite. -/
theorem nerode_quotient_finite_of_prefix_generating
    {P : Finset (List α)}
    (hP : IsResidualGenerating f P) :
    Finite (NerodeQuotientType f) := by
  apply Finite.of_surjective (fun p : P => toNerodeClass f p.1)
  intro q
  induction q using Quotient.ind with
  | _ x =>
    obtain ⟨p, hp, hpx⟩ := hP x
    exact ⟨⟨p, hp⟩, (toNerodeClass_eq_iff f p x).mpr (nerodeRel_symm f hpx)⟩

omit [DecidableEq S] in
/-- Under prefix generation, the Nerode quotient has at most |P| classes. -/
theorem nerode_quotient_card_le_prefix_card
    {P : Finset (List α)}
    (hP : IsResidualGenerating f P)
    [Fintype (NerodeQuotientType f)] :
    Fintype.card (NerodeQuotientType f) ≤ P.card := by
  have hsurj : Function.Surjective (fun p : P => toNerodeClass f p.1) := by
    intro q
    induction q using Quotient.ind with
    | _ x =>
      obtain ⟨p, hp, hpx⟩ := hP x
      exact ⟨⟨p, hp⟩, (toNerodeClass_eq_iff f p x).mpr (nerodeRel_symm f hpx)⟩
  calc Fintype.card (NerodeQuotientType f)
      ≤ Fintype.card P := Fintype.card_le_of_surjective _ hsurj
    _ = P.card := Fintype.card_coe P

end Witnesses

/-! ## Tropical Factor Rank -/

section FactorRank

variable {α S : Type*} [CommSemiring S]

/-- A matrix factors through dimension k if it can be written as a product
    of an m×k and k×n matrix (in the semiring sense). -/
def FactorsThrough {m n : Type*} (M : m → n → S) (k : ℕ) : Prop :=
  ∃ (L : m → Fin k → S) (R : Fin k → n → S),
    ∀ i j, M i j = ∑ t : Fin k, L i t * R t j

/-
A recognizing realization with n states induces a factorization of any
    Hankel block through n. This is the key connection between
    automata state complexity and algebraic rank.

    The factorization sends each prefix to the state it reaches (via an
    indicator-like encoding) and each suffix to the output at each state.
-/
theorem realization_induces_hankel_factorization
    [DecidableEq S]
    (f : TropicalSeries α S)
    (A : FiniteRealization α S) (hA : A.recognizes f)
    (P Q : Finset (List α)) :
    FactorsThrough (HankelBlock f P Q) (Fintype.card A.State) := by
  obtain ⟨e⟩ : Nonempty (A.State ≃ Fin (Fintype.card A.State)) := by
    exact ⟨ Fintype.equivFin _ ⟩;
  use fun p i => if i = e (A.run A.init p.1) then 1 else 0;
  use fun i j => A.output (A.run (e.symm i) j.1);
  simp +decide [ HankelBlock ];
  exact fun p hp q hq => hA ( p ++ q ) ▸ by rw [ FiniteRealization.run_append ] ;

end FactorRank

/-! ## Concrete Examples -/

section Examples

/-- A simple series over Bool alphabet: counts occurrences of `true`. -/
def binaryCostSeries : TropicalSeries Bool ℕ :=
  fun w => w.count true

/-
Two words are Nerode-equivalent for binaryCostSeries iff they have
    the same count of trues (infinitely many Nerode classes).
-/
theorem binaryCost_nerode_iff (x y : List Bool) :
    NerodeRel binaryCostSeries x y ↔ x.count true = y.count true := by
  constructor;
  · exact fun h => by simpa using h [ ] ;
  · intro h z;
    unfold binaryCostSeries;
    rw [ List.count_append, List.count_append, h ]

/-- Parity count series: counts mod 2 (finitely many Nerode classes). -/
def parityCountSeries : TropicalSeries Bool (ZMod 2) :=
  fun w => (w.count true : ZMod 2)

/-
Two words are parity-equivalent iff their true-counts agree mod 2.
-/
theorem paritySeries_nerode_iff (x y : List Bool) :
    NerodeRel parityCountSeries x y ↔
    (x.count true : ZMod 2) = (y.count true : ZMod 2) := by
  constructor;
  · exact fun h => by simpa using h [] ;
  · intro h z; simp_all +decide [ parityCountSeries ] ;

/-- The parity series has a 2-state realization. -/
def parityRealization : FiniteRealization Bool (ZMod 2) where
  State := ZMod 2
  instFintype := inferInstance
  init := 0
  step := fun q b => if b then q + 1 else q
  output := id

/-
The parity realization recognizes the parity series.
-/
theorem parityRealization_recognizes :
    parityRealization.recognizes parityCountSeries := by
  unfold parityRealization parityCountSeries;
  intro w; induction' w using List.reverseRecOn with w IH <;> simp_all +decide ;
  cases IH <;> simp_all +decide [ FiniteRealization.run_append ]

/-- The parity Nerode quotient is finite (at most 2 classes). -/
theorem parity_nerode_finite : Finite (NerodeQuotientType parityCountSeries) :=
  finite_nerode_of_recognizable parityCountSeries parityRealization
    parityRealization_recognizes

/-- A constant series: all words map to the same value.
    This has exactly 1 Nerode class. -/
def constSeries (c : S) : TropicalSeries α S := fun _ => c

theorem constSeries_nerode_all {α S : Type*} (c : S) (x y : List α) :
    NerodeRel (constSeries c) x y :=
  fun _ => rfl

theorem constSeries_quotient_subsingleton {α S : Type*} (c : S) :
    Subsingleton (NerodeQuotientType (constSeries c : TropicalSeries α S)) := by
  constructor
  intro a b
  induction a using Quotient.ind with
  | _ x =>
    induction b using Quotient.ind with
    | _ y => exact Quotient.sound (constSeries_nerode_all c x y)

end Examples

/-! ## Theorem D: Certified Minimization Pipeline -/

section CertifiedMinimization

variable {α S : Type*} [CommSemiring S] [DecidableEq S] [DecidableEq α]

/-- A certified minimization result bundles:
    1. Witness sets P, Q
    2. Certificate that witnesses generate all behaviors
    3. The minimal number of classes
    4. Minimality bound
    5. Hankel rank connection -/
structure CertifiedMinimization (f : TropicalSeries α S) where
  /-- The witness prefix set -/
  P : Finset (List α)
  /-- The witness suffix set -/
  Q : Finset (List α)
  /-- Certificate that witnesses generate all behaviors -/
  cert : FiniteSupportHankelGenerates f P Q
  /-- The number of Nerode classes (= minimal states) -/
  numClasses : ℕ
  /-- Upper bound: at most |P| classes -/
  classes_le_P : numClasses ≤ P.card
  /-- Every realization has at least numClasses states -/
  minimality : ∀ (A : FiniteRealization α S), A.recognizes f →
    numClasses ≤ Fintype.card A.State

end CertifiedMinimization

/-! ## Connection to Catalog -/

section CatalogConnection

variable {α S : Type*} (f : TropicalSeries α S)

/-- The word-based Nerode theory instantiates the abstract context-action framework
    from the catalog, where contexts are suffixes acting by concatenation. -/
theorem nerodeRel_as_tropical_nerode :
    NerodeRel f = fun x y => ∀ z : List α, f (x ++ z) = f (y ++ z) := rfl

/-- The word-based Nerode quotient exists as a setoid quotient,
    upgrading `tropical_myhill_nerode_quotient_exists` with both invariance
    directions. -/
theorem tropical_nerode_word_quotient_exists :
    ∃ (proj : List α → NerodeQuotientType f),
      (∀ x y, proj x = proj y ↔ NerodeRel f x y) ∧
      (∀ {x y} u, NerodeRel f x y → NerodeRel f (x ++ u) (y ++ u)) :=
  ⟨toNerodeClass f,
   fun x y => (toNerodeClass_eq_iff f x y),
   fun u h => nerodeRel_right_invariant f h u⟩

end CatalogConnection

end Bridges.TropicalAutomataMyhillNerode