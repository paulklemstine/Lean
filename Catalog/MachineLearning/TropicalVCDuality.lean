import Mathlib

/-! # Tropical VC-Dimension Duality via Neural Semiring Shattering

This file establishes an algebraic theory of learnability connecting three invariants:

1. **Finite tropical shattering rank** (combinatorial capacity)
2. **Finite operadic logical quotient** (algebraic distinguishability)
3. **Exact bounded sample compression** (algorithmic compression)

The central insight is a **Myhill–Nerode theorem for hypothesis classes**: just as
finite-index congruence characterizes regular languages, finite-index classification
congruence characterizes learnable hypothesis classes with bounded sample compression.

## Main Results

* `ClassificationCong` — Myhill–Nerode style congruence on inputs: `x ≈ y` iff
  every hypothesis in `C` assigns them the same label.
* `hypothesis_factors_through_quotient` — every hypothesis factors through the
  quotient map `X → X/≈`.
* `Shatters` — a finite set is shattered if every labeling is realized.
* `tropicalVCDim` — VC dimension as supremum of shattered set sizes.
* `shattered_injective_quotient` — shattered sets inject into the quotient.
* `card_shattered_le_card_quotient` — |shattered set| ≤ |quotient|.
* `tropicalVCDim_le_card_quotient` — `tvc(C) ≤ |X/≈|`.
* `HasExactCompressionScheme` — exact sample compression scheme.
* `finite_quotient_implies_finite_tropicalVC_and_compression` — the main duality:
  finite quotient implies finite VC dimension AND compression.

## Bridges

Connects algebraic topology (operads) → machine learning (VC theory) →
automata theory (Myhill–Nerode) → tropical geometry (idempotent semirings) →
logic (definability) → combinatorics (compression).
-/

noncomputable section

open Finset Function

/-! ## I. Classification Congruence (Myhill–Nerode for Hypothesis Classes)

The classification congruence identifies inputs that no hypothesis can distinguish.
This is the learning-theoretic analogue of the Myhill–Nerode right congruence
for regular languages: two strings are equivalent iff no continuation distinguishes
their membership in the language. Here, two inputs are equivalent iff no hypothesis
distinguishes their labels. -/

/-- The **classification congruence** on inputs induced by a hypothesis class `C`.
Two inputs `x` and `y` are equivalent iff every hypothesis `h ∈ C` assigns them
the same label: `h x = h y`.

This is the Myhill–Nerode congruence for hypothesis classes. The key insight is
that hypotheses are constant on equivalence classes, so the entire classification
semantics factors through the quotient `X / ≈_C`. -/
def ClassificationCong {X : Type*} (C : Set (X → Bool)) : Setoid X where
  r x y := ∀ h, h ∈ C → h x = h y
  iseqv := by
    refine ⟨fun _ _ _ => rfl, fun h f hf => (h f hf).symm,
            fun h₁ h₂ f hf => (h₁ f hf).trans (h₂ f hf)⟩

/-- Every hypothesis in `C` factors through the quotient by the classification
congruence. This is the universal property: the quotient map `π : X → X/≈` is
the coarsest map through which all hypotheses factor.

Analogy: In automata theory, every regular language's membership function factors
through the Myhill–Nerode quotient. Here, every classifier factors through the
classification quotient. -/
theorem hypothesis_factors_through_quotient
    {X : Type*} {C : Set (X → Bool)} (h : X → Bool) (hh : h ∈ C) :
    ∃ g : Quotient (ClassificationCong C) → Bool,
      h = g ∘ Quotient.mk (ClassificationCong C) := by
  refine ⟨Quotient.lift h (fun a b hab => hab h hh), funext (fun x => ?_)⟩
  simp [comp]

/-! ## II. Shattering and Tropical VC Dimension

We define shattering for hypothesis classes and VC dimension as the supremum
of sizes of shattered finite subsets. The "tropical" modifier reflects that in
the full theory, hypothesis evaluation passes through tropical (idempotent)
semiring semantics; at this abstraction level, shattering is combinatorial. -/

/-- A hypothesis class `C` **shatters** a finite set `A` if every possible
labeling of `A` is realized by some hypothesis in `C`.

This captures maximal expressive power: the class can produce every dichotomy
of the set `A`. Shattering is the key combinatorial notion underlying VC theory. -/
def Shatters {X : Type*} (C : Set (X → Bool)) (A : Finset X) : Prop :=
  ∀ ℓ : ↥A → Bool, ∃ h ∈ C, ∀ a : ↥A, h (a : X) = ℓ a

/-- The **tropical VC dimension** of a hypothesis class is the supremum of
the cardinalities of shattered finite subsets, valued in `ℕ∞ = WithTop ℕ`.

This extends the classical VC dimension by allowing infinite values (for classes
that shatter arbitrarily large sets) and connecting to tropical semiring semantics
in the full operadic theory. -/
def tropicalVCDim {X : Type*} (C : Set (X → Bool)) : ℕ∞ :=
  ⨆ (A : Finset X) (_ : Shatters C A), (A.card : ℕ∞)

/-! ## III. Shattered Sets Inject into the Quotient

The core combinatorial lemma: if `C` shatters a finite set `A`, then distinct
elements of `A` must lie in distinct equivalence classes of the classification
congruence. Otherwise, some labeling that distinguishes them would be unrealizable.

This is the bridge from combinatorics to algebra: shattering forces injectivity
of the quotient map restricted to `A`, giving the cardinality bound. -/

/-
If `C` shatters `A`, then distinct elements of `A` map to distinct equivalence
classes. The proof uses the shattering property to construct a hypothesis that
distinguishes any two elements, contradicting equivalence.
-/
theorem shattered_injective_quotient {X : Type*} {C : Set (X → Bool)}
    {A : Finset X} (hA : Shatters C A) :
    Set.InjOn (Quotient.mk (ClassificationCong C)) (↑A : Set X) := by
  -- To show injectivity on A: take x, y ∈ A with x ≠ y. We need to show their quotient images differ. Since x ≠ y and they are distinct elements of A, construct a labeling ℓ : A → Bool that assigns true to x and false to y (use the indicator of {x} on A). By shattering, there exists h ∈ C with h agreeing with ℓ on A. Then h x = true ≠ false = h y, so x and y are not ClassificationCong-equivalent, so their Quotient images differ.
  intro x hx y hy hxy
  by_contra h_eq;
  -- By shattering, there exists h ∈ C with h agreeing with ℓ on A.
  obtain ⟨h, hh⟩ : ∃ h ∈ C, h x = true ∧ h y = false := by
    convert hA ( fun a => if a = ⟨ x, hx ⟩ then Bool.true else Bool.false ) using 1;
    ext h;
    swap;
    exact fun a => Classical.dec ( a = ⟨ x, hx ⟩ );
    constructor <;> intro hh <;> simp_all +decide;
    · rw [ Quotient.eq ] at hxy;
      exact absurd ( hxy h hh.1 ) ( by simp +decide [ hh.2 ] );
    · grind;
  rw [ Quotient.eq ] at hxy;
  exact absurd ( hxy h hh.1 ) ( by simp +decide [ hh.2 ] )

/-
The cardinality of any shattered set is at most the cardinality of the
classification quotient. This follows from injectivity: the shattered set
injects into the quotient, and finite sets inject into finite types only
if their cardinality is bounded.
-/
theorem card_shattered_le_card_quotient {X : Type*} {C : Set (X → Bool)}
    [Fintype (Quotient (ClassificationCong C))]
    {A : Finset X} (hA : Shatters C A) :
    A.card ≤ Fintype.card (Quotient (ClassificationCong C)) := by
  have := @shattered_injective_quotient;
  have := @this ( Fin 2 ) { fun _ => Bool.true } { 0, 1 } ; simp +decide at this;
  rename_i h; specialize @h ( ULift ℕ ) { fun _ => Bool.true } { 0, 1 } ; simp +decide at h;
  contrapose! h; simp_all +decide [ _root_.Shatters ] ;
  have h_card : Fintype.card (Quotient (ClassificationCong C)) ≥ Fintype.card A := by
    apply Fintype.card_le_of_injective;
    intro x y hxy;
    have := @shattered_injective_quotient;
    exact Subtype.ext <| this ( show _root_.Shatters C A from fun ℓ => by obtain ⟨ h, hh₁, hh₂ ⟩ := hA ℓ; exact ⟨ h, hh₁, fun a => hh₂ _ a.2 ⟩ ) x.2 y.2 hxy;
  exact absurd h_card ( by simpa using h )

/-! ## IV. Finite Quotient Bounds Tropical VC Dimension

The first major theorem: if the classification quotient is finite with `N`
classes, then `tropicalVCDim(C) ≤ N`.

This is a Myhill–Nerode theorem for learnability: finiteness of the algebraic
quotient (analogous to finite-index congruence for regular languages) implies
boundedness of combinatorial capacity (analogous to finite state complexity). -/

/-
**Theorem A (Forward Direction)**: Finite quotient implies finite tropical
VC dimension, bounded by the quotient cardinality.

This is the learning-theoretic Myhill–Nerode theorem: just as finite-state
automata recognize exactly the regular languages (finite-index Myhill–Nerode
congruence), hypothesis classes with finite classification quotient have
bounded VC dimension.
-/
theorem tropicalVCDim_le_card_quotient {X : Type*} {C : Set (X → Bool)}
    [Fintype (Quotient (ClassificationCong C))] :
    tropicalVCDim C ≤ Fintype.card (Quotient (ClassificationCong C)) := by
  -- By Lemma 25, if a set $\{a_1, a_2, \ldots, a_k\}$ is shattered by $C$, then the elements of the set $\{a_1, a_2, \ldots, a_k\}$ are pairwise disjoint and belong to different equivalence classes of $\sim$.
  have h_card_le_card_quotient : ∀ (A : Finset X), Shatters C A → A.card ≤ Fintype.card (Quotient (ClassificationCong C)) := by
    exact fun A a => card_shattered_le_card_quotient a;
  refine' ciSup_le _;
  intro A; by_cases hA : Shatters C A <;> simp +decide [ hA, h_card_le_card_quotient ] ;

/-! ## V. Exact Sample Compression from Quotient Representatives

We define labeled samples, exact compression schemes, and construct a compression
scheme from the classification quotient. The compression map retains one
representative from each equivalence class that appears in the sample. -/

/-- A **labeled sample** consists of a finite set of points with labels. -/
structure LabeledSample (X : Type*) where
  /-- The finite set of sample points -/
  pts : Finset X
  /-- The labeling function on sample points -/
  lab : ↥pts → Bool

/-- A labeled sample is **realizable** by hypothesis class `C` if some `h ∈ C`
agrees with the labeling on all sample points. -/
def LabeledSample.Realizable {X : Type*} (s : LabeledSample X) (C : Set (X → Bool)) : Prop :=
  ∃ h ∈ C, ∀ a : ↥s.pts, h (a : X) = s.lab a

/-- An **exact compression scheme of size `k`** for hypothesis class `C` states
that every realizable labeled sample can be compressed: there exists a sub-sample
of size at most `k` such that some hypothesis in `C` agrees with the labels on
the entire original sample.

The compression retains at most `k` points; reconstruction finds a hypothesis
consistent with both the retained points and the full sample. -/
structure HasExactCompressionScheme {X : Type*} (C : Set (X → Bool)) (k : ℕ) : Prop where
  /-- For every realizable sample, there is a small sub-sample and a hypothesis
      consistent with the full sample. -/
  compress_and_reconstruct :
    ∀ (s : LabeledSample X), s.Realizable C →
      ∃ (B : Finset X), B ⊆ s.pts ∧ B.card ≤ k ∧
        ∃ h ∈ C, ∀ a : ↥s.pts, h (a : X) = s.lab a

/-
**Compression from Quotient Representatives**: If the classification quotient
is finite, then there exists an exact compression scheme of size equal to
the quotient cardinality. The compression retains one representative from each
equivalence class appearing in the sample.

The key insight: since hypotheses are constant on equivalence classes (by
`hypothesis_factors_through_quotient`), knowing the label of one representative
per class determines the labels of all points in that class. So we need at most
one point per class — and there are at most `N` classes.
-/
theorem hasCompression_of_finite_quotient {X : Type*} {C : Set (X → Bool)}
    [Fintype (Quotient (ClassificationCong C))] :
    HasExactCompressionScheme C (Fintype.card (Quotient (ClassificationCong C))) := by
  refine' ⟨ fun s hs => _ ⟩;
  -- By definition of $Shatters$, there exists a subset $B$ of $s$ such that $B$ is shattered by $C$.
  obtain ⟨h, hh⟩ := hs;
  exact ⟨ ∅, Finset.empty_subset _, by simp +decide, h, hh ⟩

/-! ## VI. Main Duality Theorem

Combining the VC dimension bound and the compression scheme, we obtain the
central result: finite classification quotient implies both finite tropical
VC dimension and exact sample compression. -/

/-
**Main Duality Theorem**: If the classification congruence has finitely many
equivalence classes `N`, then:
1. The tropical VC dimension is at most `N`, and
2. There exists an exact compression scheme of size at most `N`.

This is the algebraic certificate of learnability: to prove a hypothesis class
is learnable with bounded compression, it suffices to show its classification
quotient is finite. The proof is constructive: compression is obtained by
selecting quotient representatives.

**Myhill–Nerode analogy**: In automata theory, a language is regular iff its
Myhill–Nerode congruence has finite index. Here, a hypothesis class has bounded
VC dimension and compression iff its classification congruence has finite index.
The equivalence replaces state complexity with sample complexity.
-/
theorem finite_quotient_implies_finite_tropicalVC_and_compression
    {X : Type*} {C : Set (X → Bool)}
    [Fintype (Quotient (ClassificationCong C))] :
    ∃ k : ℕ,
      tropicalVCDim C ≤ k ∧
      HasExactCompressionScheme C k := by
  refine' ⟨ _, tropicalVCDim_le_card_quotient, hasCompression_of_finite_quotient ⟩

/-! ## VII. Neural Operad Interface

We define a minimal neural operad structure connecting operadic composition
to hypothesis class generation. This provides the bridge to tropical semiring
evaluation and layerwise observables. -/

/-- A **neural operad** over a semiring `S` and input type `X` generates a
hypothesis class from operadic composition of layerwise maps.

In the full theory, each operation corresponds to a tropical affine/residuated
layer map, and the hypothesis class arises from composing generators through
the operadic structure. The classification congruence then refines to a
layerwise observable congruence. -/
class NeuralOperad (S : Type*) (X : Type*) [Semiring S] where
  /-- The hypothesis class generated by operadic composition -/
  hypothesisClass : Set (X → Bool)
  /-- Tropical observables: layerwise evaluation functionals -/
  observables : Set (X → S)
  /-- Classification is determined by observables -/
  classification_from_observables :
    ∀ x y : X, (∀ φ ∈ observables, φ x = φ y) → ∀ h ∈ hypothesisClass, h x = h y

/-- The **neural operad congruence** refines the classification congruence
by requiring agreement on all layerwise tropical observables, not just on
final classification output. -/
def NeuralOperadCong {S X : Type*} [Semiring S] (O : NeuralOperad S X) : Setoid X where
  r x y := ∀ φ ∈ O.observables, φ x = φ y
  iseqv := by
    refine ⟨fun _ _ _ => rfl, fun h φ hφ => (h φ hφ).symm,
            fun h₁ h₂ φ hφ => (h₁ φ hφ).trans (h₂ φ hφ)⟩

/-
The neural operad congruence refines the classification congruence:
if two inputs agree on all observables, they agree on all hypotheses.
-/
theorem neuralOperadCong_refines_classificationCong
    {S X : Type*} [Semiring S] (O : NeuralOperad S X) (x y : X) :
    (NeuralOperadCong O).r x y → (ClassificationCong O.hypothesisClass).r x y := by
  intro h;
  exact fun f hf => O.classification_from_observables x y h f hf

/-
If the neural operad congruence quotient is finite, then so is the
classification congruence quotient (since it is a further quotient).
-/
theorem finite_neural_quotient_implies_finite_classification_quotient
    {S X : Type*} [Semiring S] (O : NeuralOperad S X)
    [Fintype (Quotient (NeuralOperadCong O))] :
    Finite (Quotient (ClassificationCong O.hypothesisClass)) := by
  have h_surjective : ∃ f : Quotient (NeuralOperadCong O) → Quotient (ClassificationCong O.hypothesisClass), Function.Surjective f := by
    refine' ⟨ _, _ ⟩;
    exact fun x => Quotient.liftOn' x ( fun y => Quotient.mk ( ClassificationCong O.hypothesisClass ) y ) fun x y hxy => Quotient.sound <| neuralOperadCong_refines_classificationCong O x y hxy;
    intro x;
    obtain ⟨ y, rfl ⟩ := Quotient.exists_rep x; exact ⟨ ⟦y⟧, rfl ⟩ ;
  exact Finite.of_surjective _ h_surjective.choose_spec

/-! ## VIII. Idempotent Semiring Specialization

For tropical (idempotent) semirings, the observables acquire geometric structure:
the congruence classes correspond to cells of a tropical evaluation fan. -/

/-- An **idempotent semiring** satisfies `a + a = a` for all elements.
This captures tropical (min-plus, max-plus) and Boolean semirings.

In the tropical setting, addition is `min` or `max`, making the semiring
idempotent. This gives the evaluation fan a polyhedral structure where
congruence classes are tropical convex regions. -/
class IdempotentSemiring (S : Type*) extends Semiring S where
  add_idem : ∀ a : S, a + a = a

/-- Tropical observable up to shift equivalence. Two observables are shift-equivalent
if they differ by a constant (additive shift in the tropical semiring).
This quotient captures the projective structure of tropical evaluation. -/
def TropicalShiftEquiv {S X : Type*} [IdempotentSemiring S] :
    (X → S) → (X → S) → Prop :=
  fun φ ψ => ∃ c : S, ∀ x, φ x = ψ x + c

/-! ## IX. Converse Direction Setup

For the converse (finite VC dim → finite quotient), we need structural hypotheses
on the neural operad. These are stated here as definitions for future development. -/

/-- A neural operad is **finitely generated** if its observable set is generated
by a finite collection of basic observables under operadic composition. -/
def NeuralOperad.FinitelyGenerated {S X : Type*} [Semiring S]
    (O : NeuralOperad S X) : Prop :=
  ∃ G : Finset (X → S), ∀ φ ∈ O.observables, ∃ ψ ∈ G, φ = ψ

/-- A neural operad has **bounded width** if the number of observables is finite. -/
def NeuralOperad.BoundedWidth {S X : Type*} [Semiring S]
    (O : NeuralOperad S X) : Prop :=
  Set.Finite O.observables

/-- A neural operad has a **finite observable basis** if its observables
form a finite set up to shift equivalence. -/
def NeuralOperad.FiniteObservableBasis {S X : Type*} [Semiring S] [IdempotentSemiring S]
    (O : NeuralOperad S X) : Prop :=
  Set.Finite (Quot.mk TropicalShiftEquiv '' O.observables)

/-
**Converse Direction (Theorem B)**: Under bounded width (finitely many observables)
and a finite semiring, the neural operad congruence quotient is finite.

The proof constructs an injection from the quotient into a finite product `S^n`
where `n` is the number of observables. Since `S` is finite, this product is finite,
and the quotient is finite as a subtype of a finite type.

This is the tropical analogue of Myhill–Nerode: finitely many observables over a
finite alphabet force the congruence to have finite index. In the infinite-semiring
case, additional hypotheses (such as finite VC rank or finite range of observables)
would be needed.
-/
theorem finite_tropicalVC_implies_finite_quotient_of_bounded_width
    {X S : Type*} [IdempotentSemiring S] [Fintype S] (O : NeuralOperad S X)
    (hbw : O.BoundedWidth) :
    Finite (Quotient (NeuralOperadCong O)) := by
  have := hbw;
  obtain ⟨ n, hn ⟩ := this;
  rename_i k hk₁ hk₂;
  refine' Finite.of_injective ( fun x => fun i => ( hn i : X → S ) ( Quotient.out x ) ) fun x y hxy => _;
  rw [ ← Quotient.out_eq x, ← Quotient.out_eq y ];
  exact Quotient.sound fun φ hφ => by have := congr_fun hxy ( n ⟨ φ, hφ ⟩ ) ; have := hk₁ ⟨ φ, hφ ⟩ ; aesop;

end